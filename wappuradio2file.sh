#!/bin/bash

###################################################
#              wappuradio2file.sh
#
#       Jussi Isotalo <j.isotalo91@gmail.com>
#                 MIT license
#
# Usage: 
# bash wappuradio2file.sh /target/file.mp3 "today 21:00" "today 22:00"
# Saves from 21:00 today to 22:00 today to file.mp3
###################################################





# Calls something and kills it after given period of time
# Ugly and simple
# Originally by Tomas Janousek @ http://lists.mplayerhq.hu/pipermail/mplayer-users/2007-February/065715.html
runfor(){
  end_time=$1
  shift

  "$@" &
  PID=$!
  til "$end_time"
  kill $PID
  wait
}





# Sleeps until given date
# By Camusensei (https://stackoverflow.com/a/30299084/8140625)
til(){
  local hour mins target now left initial sleft correction m sec h hm hs ms ss showSeconds toSleep
  showSeconds=true
  [[ $1 =~ ([0-9][0-9]):([0-9][0-9]) ]] || { echo >&2 "USAGE: til HH:MM"; return 1; }
  hour=${BASH_REMATCH[1]} mins=${BASH_REMATCH[2]}
  target=$(date +%s -d "$hour:$mins") || return 1
  now=$(date +%s)
  (( target > now )) || target=$(date +%s -d "tomorrow $hour:$mins")
  left=$((target - now))
  initial=$left
  while (( left > 0 )); do
    if (( initial - left < 300 )) || (( left < 300 )) || [[ ${left: -2} == 00 ]]; then
      # We enter this condition:
      # - once every 5 minutes
      # - every minute for 5 minutes after the start
      # - every minute for 5 minutes before the end
      # Here, we will print how much time is left, and re-synchronize the clock

      hs= ms= ss=
      m=$((left/60)) sec=$((left%60)) # minutes and seconds left
      h=$((m/60)) hm=$((m%60)) # hours and minutes left

      # Re-synchronise
      now=$(date +%s) sleft=$((target - now)) # recalculate time left, multiple 60s sleeps and date calls have some overhead.
      correction=$((sleft-left))
      if (( ${correction#-} > 59 )); then
        echo "System time change detected..."
        (( sleft <= 0 )) && return # terminating as the desired time passed already
        til "$1" && return # resuming the timer anew with the new time
      fi

      # plural calculations
      (( sec > 1 )) && ss=s
      (( hm != 1 )) && ms=s
      (( h > 1 )) && hs=s

      (( h > 0 )) && printf %s "$h hour$hs and "
      (( h > 0 || hm > 0 )) && printf '%2d %s' "$hm" "minute$ms"
      if [[ $showSeconds ]]; then
        showSeconds=
        (( h > 0 || hm > 0 )) && (( sec > 0 )) && printf %s " and "
        (( sec > 0 )) && printf %s "$sec second$ss"
        echo " left..."
        (( sec > 0 )) && sleep "$sec" && left=$((left-sec)) && continue
      else
        echo " left..."
      fi
    fi
    left=$((left-60))
    sleep "$((60+correction))"
    correction=0
  done
}




#Check that filename is given
if [ -z "$1" ]
then
  echo "No 1st argument (filename) given. Exiting..."
  exit
fi


#Check that time is given
if [ -z "$2" ]
then
  echo "No 2nd  argument (starting date) given. Exiting..."
  exit
fi

#Check that duration is given
if [ -z "$3" ]
then
  echo "No 3rd argument (ending date) given. Exiting..."
  exit
fi


#Check if time is acceptable date format
date -d "$2"  > /dev/null 2>&1
if [ $? -eq "1" ]
then
  echo "Faulty date $2 given. Exiting..."
  exit
fi

#Check if time is acceptable date format
date -d "$3"  > /dev/null 2>&1
if [ $? -eq "1" ]
then
  echo "Faulty date $3 given. Exiting..."
  exit
fi


# All ok!
echo "----------------------------------------------------------"
echo "  - Saving to file $1.tmp.mp3"
echo "  - Waiting for start until $2"
echo "  - Saving until $3"
echo "  - Running fixvbr afterwards and deleting .tmp.mp3 file"
echo "----------------------------------------------------------"


#Wait until clock is enough
til "$2"
echo "----------------------------------------------------------"
echo "Starting.."


#Lets save stream for given duration
runfor \
"$3" \
mplayer -cache 1024 \
http://stream.wappuradio.fi:80/wappuradio.mp3 \
-dumpstream \
-dumpfile "$1.tmp.mp3"

echo "----------------------------------------------------------"
echo "Done. Now starting fixvbr"
vbrfix "$1.tmp.mp3" "$1"
echo "fixvbr done. Deleting temp file $1.tmp.mp3"
rm -f "$1.tmp.mp3"
echo "----------------------------------------------------------"
echo "All done!"


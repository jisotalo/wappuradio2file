# wappuradio2file
Saves [Wappuradio](https://wappuradio.fi/) to mp3 file starting from given time and for given duration

# Requirements
- Install mplayer
  - `sudo apt install mplayer`

# Usage
The wappuradio2file.sh has 3 parameters
1) target filename (including .mp3 extension)
2) starting time (linux `date` command format, for example `today 22:00`)
3) recording duration (minutes)


## Save 7.5 hours (=450 minutes) starting at 23:45 today

`bash wappuradio2file.sh /wappuradio-rips/wappuradio_today.mp3 "today 23:45" 450`

# NOTE
- Might work or might not
- Made for personal use (Pekka Sauronin yöradio is broadcasted..well at night)

# wappuradio2file
Saves [Wappuradio](https://wappuradio.fi/) to mp3 file from given start time to given end time.

# Requirements
- Install mplayer
  - `sudo apt install mplayer`
- Install vbrfix
  - `sudo apt install vbrfix`

# Usage
The wappuradio2file.sh has 3 parameters
1) target filename (including .mp3 extension)
2) starting time (linux `date` command format, for example `today 21:00`)
3) ending time (linux `date` command format, for example `today 22:00`)


## Save from 22:00 today to 00:15 tomorrow (=2 hour and 15 minutes)

`bash wappuradio2file.sh /wappuradio-rips/wappuradio.mp3 "today 22:00" "tomorrow 00:15"`

## Save starting immediately and stop at 22:00 today

`bash wappuradio2file.sh /wappuradio-rips/wappuradio.mp3 "now" "today 22:00"`

# NOTE
- Might work or might not
- Made for personal use (Pekka Sauronin yöradio is broadcasted..well at night)
- First saves the stream to mp3 with `mplayer`, then fixes the vbr header problem with `vbrfix`
- NOTE: Makes some temporary files: One minute is about 1 mb and during vbrfix call, total of 3 mb would be used temporary. When recording for the whole night, you will need ~1 gb of free space.

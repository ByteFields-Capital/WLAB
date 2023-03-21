#!/bin/bash 
source ~/.bash_profile 
env > /tmp/auto.job
alerts.sh $R1 $R2


exit
https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html#//apple_ref/doc/uid/TP40001762-104142


<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>check.alerts</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/wdavid/Desktop/Shoebox/Sync/WlabPro/bin/alsert.job.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>14</integer>
        <key>Minute</key>
        <integer>30</integer>
     </dict>
</dict>
</plist>
For more information on these values, see the manual page for launchd.plist.


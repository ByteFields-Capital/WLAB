
#!/bin/bash 
source /opt/dw/.bash_profile
export WLAB_HOME=/opt/dw/WlabPro

env > /tmp/auto.job

$WLAB_HOME/bin/alerts.sh $R1 $R2 watchlist.wlab


exit
#setup 
    sudo mkdir /opt/dw
    chmod a+wrx //Users/wdavid/Desktop/Shoebox/Sync/WlabPro/bin/OSX/
    sudo ln -s /Users/wdavid/Desktop/Shoebox/Sync/WlabPro/bin/OSX .
    sudo chmod a+wrx  /opt/dw/
    cd /opt/dw ; ln ~/.bash_profile .

     sudo launchctl load  /opt/dw/OSX/test-alerts.plist 

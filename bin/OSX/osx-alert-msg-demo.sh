# watchlist.wlab
sleep 5
for i in 1  2 3 
do
 osascript -e ' display alert "WLAB ALERT DEMO #${i}"  message " ALERT #'${i}' in /tmp/alert.msg " '  >/dev/null  &
 sleep 1
done
echo "###############DONE############"

: << 'COMMENT'
IMPORTANT !!!!
# CUrrently  quote data is very limited !!!!
see funtions for details

USAGE:  [BATCH=TRUE] alerts.sh $R1 $R2 watchlist.wlab
	  ALERT={price=, date=....} in the watchlist.wlab , runs on OSX 
    BATCH=TRUE does not run OSX popups
		TODO:  
      port to AWS sh script : https://github.com/gkrizek/bash-lambda-layer
		  price alert svc in the cloud - lambada or GCP - how it works wtih DA - ???

all data is saved in  
  TMPFILE=/tmp/32uwgefi82h4f9fnc;
  DEBUG_FILE=/tmp/alerts.sh.debug
  ALERT_FILE="/tmp/alert.msg"
 
COMMENT

FNAMES="$*"
echo "$FNAMES"
TMPFILE=/tmp/32uwgefi82h4f9fnc
printf "\n####################   %s   ########################\n\n" "$(date)" >> /tmp/alerts.sh.debug
rm -f /tmp/alert.msg
rm -fr /tmp/quotes
mkdir /tmp/quotes

cd $WLAB_HOME/_Trades

#  Test it !
# echo  'ALERT;{ "condition": "PRICE_ABOVE", "ticker": "NOK", "price" : 10 , "volume" : 0 , "expiration" : "2019-07-18","note" : " COMMENT ", "date" : "2019-10-18" } 
# ALERT;{ "condition": "PRICE_BELOW", "ticker": "NOK", "price" : 3 , "volume" : 0 , "expiration" : "2019-06-19","note" : " ReEnter! Start DollarAverage", "date" : "2019-08-29" } 
# ALERT;{ "condition": "PRICE_ABOVE", "ticker": "NOK", "price" : 3 , "volume" : 0 , "expiration" : "2019-07-18","note" : " COMMENT ", "date" : "2019-10-18" } 
# ALERT;{ "condition": "PRICE_BELOW", "ticker": "NOK", "price" : 10 , "volume" : 0 , "expiration" : "2019-06-19","note" : " ReEnter! Start DollarAverage", "date" : "2019-08-29" } 
# ALERT;{ "condition": "VOLUME_ABOVE", "ticker": "NOK", "price" : 0 , "volume" : 9999999990 , "expiration" : "2019-06-19","note" : " ReEnter! Start DollarAverage", "date" : "2019-08-29" }
# ALERT;{ "condition": "VOLUME_ABOVE", "ticker": "NOK", "price" : 0 , "volume" : 200000, "expiration" : "2019-06-19","note" : " ReEnter! Start DollarAverage", "date" : "2019-08-29" } '  | \

awk -F\; -f $WLAB_HOME/bin/alerts.awk WLAB_HOME=$WLAB_HOME $FNAMES

#~/Desktop/Shoebox/Sync/WlabPro/_Trades/watchlist.wlab
#cat /tmp/alert.msg ; exit

grep 'ALERT\|QUOTE' /tmp/alerts.sh.debug

if [ ! -f /tmp/alert.msg ]; then
  echo "No alerts"
else
  if [ "$BATCH"!="TRUE" ] ; then 
    osascript -e ' display alert "WLAB ALERT"  message " NEW ALERT in /tmp/alert.msg " ' &
    #bash /tmp/alert.msg
  else
    cat /tmp/alert.msg
        #echo "$BATCH"="TRUE"

  fi
fi

exit

#  osascript -e 'display alert "WLAB ALERT"  message "$TT just hit $PP "' 
#
#################################################################
#                               HEAP
#################################################################



while read line
do  
  echo $line
done < /tmp/alert.msg 

exit
awk -F\;  'BEGIN {
    TMPFILE=/tmp/qq;

     system("date > "TMPFILE);
    "cat  "TMPFILE | getline current_time
      close("cat")
    print "Report printed on " current_time
}'

exit
 echo $TMPFILE | awk '{  QQ=system("ls -l /tmp/aa"); print QQ; } '

 exit
echo $TMPFILE | awk '{  ss="ls ~/ > "$1"-1";  system(ss) ; QQ=system("ls -l /tmp/aa"); print QQ; } '



BEGIN {
     "date" | getline current_time
     close("date")
     print "Report printed on " current_time
}
echo '

TICKER= echo $ALERT |  jq -r ' .symbol'
echo $ALERT |  jq -r ' .symbol' 

get_last_trading_day_quote  $TICKER
ALERT=$( echo $ALERT  |  jq -r ' . | [.expiration, .volume, .price[] ]  | join(";") ' )
QUTOTE=$

get_last_trading_day_quote  TICKER  | jq -r '.[].close'    [open,close,high,low,volume]
{

awk -F\; '{print $1; print$2;
    for(i=3;i<=NF;i++){ print $i }
}'



    printf "display alert \"WLAB ALERT\"  message \"%s just hit %s\"\n" AMD 24 > ${TMPFILE} 
    osascript ${TMPFILE} 	
exit

#get all dfata echo "data" | awk processor 
cat watchlist.wlab | awk -F\;  '$1=="ALERT" {print $2}' | jq -r ' . | [.expiration, .volume, .price[] ]  | @csv ' 
cat watchlist.wlab | awk -F\;  '$1=="ALERT" {print $2}' | jq -r ' . | [.expiration, .volume, .price[] ]  | join(";") ' | awk '...'

ALERT;{ "what": "ALERT", "symbol": "DHT", "price" : [ 5.5, 5.6] , "volume" : 3000000 , "expiration" : "2019-11-29" , "note" : " Enter! Satrt DollarAverage", "date" : "2019-04-29" } 

exit 

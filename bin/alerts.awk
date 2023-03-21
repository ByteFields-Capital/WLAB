
# all data is saved in  
#   TMPFILE=/tmp/32uwgefi82h4f9fnc;
#   DEBUG_FILE=/tmp/alerts.sh.debug
#   ALERT_FILE="/tmp/alert.msg"
 
BEGIN {

  #  symbol,open,high,low,price,volume,latestDay,previousClose,change,changePercent
  #  awk {printf "%-30s = %s\n",$1,$3}

  symbol                         = 1
  open                           = 2
  high                           = 3
  low                            = 4
  price                          = 5
  volume                         = 6
  latestDay                      = 7
  previousClose                  = 8
  change                         = 9
  changePercent                  = 10
  condition                      = 11
  expiration                     = 12
  note                           = 13
  FieldNames[symbol]             = "symbol";
  FieldNames[open]               = "open";
  FieldNames[high]               = "high";
  FieldNames[low]                = "low";
  FieldNames[price]              = "price";
  FieldNames[volume]             = "volume";
  FieldNames[latestDay]          = "latestDay";
  FieldNames[previousClose]      = "previousClose";
  FieldNames[change]             = "change";
  FieldNames[changePercent]      = "changePercent";
  FieldNames[condition]          = "condition";
  FieldNames[expiration]         = "expiration";
  FieldNames[note]               = "note";

  TMPFILE="/tmp/32uwgefi82h4f9fnc";
  DEBUG_FILE="/tmp/alerts.sh.debug";
  ALERT_FILE="/tmp/alert.msg"
  #fireAlert("111 " , " quoteX", " cond " ," alertX")   
 
  print("Process "FILENAME);  
  print("Patience ! There is  12s pause between quotes" );
  print("PrintOut  > /tmp/alerts.sh.debug" );
   
}

$1=="ALERT" {

  dprint(" >>>> Processing alert "$2);
  getAlert($2);
  dprint(alert[symbol] " ---alert[price] = "alert[price]);
  getQuote(alert[symbol]);
  dprint(quote[symbol] "--  quote[high] =  " quote[high]);

  dprint("alert[volume] = "alert[volume]"  ;  quote[volume] = " quote[volume]);


  if ( alert[condition] == "PRICE_BELOW"  &&  alert[price] >= quote[low] ) {
    dprint("# "FILENAME": in $1==ALERT PRICE_BELOW");
    fireAlert( alert[symbol], alert[condition],  alert[price], quote[low])
  }
  else if ( alert[condition] == "PRICE_ABOVE"  &&  alert[price] <= quote[high] ) {
    dprint("# "FILENAME": in $1==ALERT PRICE_ABOVE");
    fireAlert( alert[symbol], alert[condition],  alert[price], quote[low])
  }

  else if ( alert[condition] == "VOLUME_BELOW"  &&  alert[volume] >= quote[volume] ) {
    dprint("# "FILENAME": in $1==ALERT VOLUME_BELOW");
    fireAlert( alert[symbol], alert[condition],  alert[price], quote[low])
  }

  else if ( alert[condition] == "VOLUME_ABOVE"  &&  alert[volume] <= quote[volume] ) {
    dprint("# "FILENAME": in ALERT  VOLUME_ABOVE");
    fireAlert( alert[symbol], alert[condition],  alert[price], quote[low])
  }
  else dprint("# "FILENAME": !!! NO ALERT CONDITION MET  !!!! ");
  dprint(" ==========");
}

#just print
function fireAlert( symbolX, cond,  alertX, quoteX)
{   
  #print "#TRACE: in fireAlert"
  print   symbolX " : " quoteX" " cond " " alertX >> "/tmp/alert.msg"
}

#OSX
function fireAlert_osx( symbolX, cond,  alertX, quoteX)
{   
  dprint("#TRACE: in fireAlert");
  dprint(symbolX " : " quoteX" " cond " " alertX );
  printf( "osascript -e \x27 display alert \"WLAB ALERT\"  message \"%s %s %s %s \" \x27 &\n", symbolX ,quoteX, cond, alertX ) >> "/tmp/alert.msg"
}

function getQuote_v02(symbol)
{
	# getQuoteCmd="curl -s \"https://api.iextrading.com/1.0/stock/market/previous/batch?symbols="symbol"&types=quote\" | jq -r \x27 .[] | [ .symbol, .low, .high, .volume, .vwap ]  | join(\";\") \x27 " 
  # getQuoteCmd="curl -s \"https://cloud.iexapis.com/stable/stock/"symbol"/quote?token=pk_007e296b90f14627b5615b8eeb58a2a7\" | jq -r \x27 [ .symbol, .low, .high, .latestVolume, .latestPrice ]  | join(\";\") \x27 " 
  dprint( "getQuoteCmd = "getQuoteCmd );
  getQuoteCmd |  getline line
  close(getQuoteCmd)
  dprint(line);
  split(line,quote,";");
  dprint( "### quote begin #### ") ; for (i in quote)   dprint("### quote["FieldNames[i]"]= " quote[i]); dprint( "### quote end #### ") ;
}
# 
function getQuote_v03(ticker)
{
  #getQuoteCmd="cat  /tmp/11 | awk -F\, \x27 { printf(\"%s;;%s;%s;%s;%s\\n\" , $"symbol", $"high", $"low", $"price", $"volume" ) }  \x27 " 
  #getQuoteCmd="	sleep 12s; curl -s \"https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol="symbol"&apikey=8E409AF7G8ZJZA3F&datatype=csv\"  | tail -1 | awk \x27 { printf(\"%s;;%s;%s;%s;%s\\n\" , $"symbol", $"high", $"low", $"price", $"volume" ) }  \x27 " 
 
  getQuoteCmd=WLAB_HOME"/bin/alert_getQuoteCmd.sh "ticker" | awk -F\, \x27 { printf(\"%s;;%s;%s;%s;%s\\n\" , $"symbol", $"high", $"low", $"price", $"volume" ) }  \x27 " 
  dprint( "getQuoteCmd = "getQuoteCmd );
  getQuoteCmd | getline line
  close(getQuoteCmd)
  dprint("QUOTE  =  "line)
   split(line,quote,";");
  dprint( "### quote begin #### ") ; for (i in quote)   dprint("### quote["FieldNames[i]"]= " quote[i]); dprint( "### quote end #### ") ;
}

function getQuote(ticker)
{
  #getQuoteCmd="cat  /tmp/11 | awk -F\, \x27 { printf(\"%s;;%s;%s;%s;%s\\n\" , $"symbol", $"high", $"low", $"price", $"volume" ) }  \x27 " 
  #getQuoteCmd="	sleep 12s; curl -s \"https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol="symbol"&apikey=8E409AF7G8ZJZA3F&datatype=csv\"  | tail -1 | awk \x27 { printf(\"%s;;%s;%s;%s;%s\\n\" , $"symbol", $"high", $"low", $"price", $"volume" ) }  \x27 " 
 
  if( quotes[ticker] == 0   ) {
    getQuoteCmd=WLAB_HOME"/bin/alert_getQuoteCmd.sh "ticker" | awk -F\, \x27 { printf(\"%s;;%s;%s;%s;%s\\n\" , $"symbol", $"high", $"low", $"price", $"volume" ) }  \x27 " 
    dprint( "getQuoteCmd = "getQuoteCmd );
    getQuoteCmd | getline line
    close(getQuoteCmd)
    quotes[ticker] = line;
  }
  dprint("QUOTE  =  "quotes[ticker])
  split(quotes[ticker],quote,";");
  dprint( "### quote begin #### ") ; for (i in quote)   dprint("### quote["FieldNames[i]"]= " quote[i]); dprint( "### quote end #### ") ;
}

function getAlert(json)
{
  getAlertCmd="echo \x27"json"\x27 |  jq -r \x27 . | [  .ticker ,\"\" ,\"\",\"\", .price, .volume, \"\",\"\",\"\",\"\", .condition, .expiration, .note ]  | join(\";\") \x27 ";
  dprint("getAlertCmd = \""getAlertCmd"\"");
  getAlertCmd |  getline line
  close(getAlertCmd)
  dprint("ALERT  =  "line)
  split(line,alert,";")
  dprint( "### alert begin #### ") ; for (i in alert)   dprint("### alert["FieldNames[i]"]= " alert[i]); dprint( "### quoalertte end #### ") ;
}


function dprint(string)
{
  print "DP## "string >> DEBUG_FILE;
  #print "DP## "string ;
}


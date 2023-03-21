# Comment Code Block Ctrl+K+C/Ctrl+K+U
# Create Collapsible Region Ctrl+M+H/Ctrl+M+U

alias awk=gawk

function get_last_price()
#  get DAILY last_close price 
#  USAGE: get_last_close  TICKER  
{
	SYM=$1
	curl -s "https://api.iextrading.com/1.0//tops/last?symbols=${SYM}" |  jq -r '.[].price'
	# https://iextrading.com/developer/docs/#iex-market-data
}
#Alternative APIs :
# https://www.worldtradingdata.com/pricing
# https://rapidapi.com/collection/stock-market-apis
# 
function new_wlab_trade()
#  creates Wlab entry "NEM;2014-06-02;Buy;20.8;100;IRA; " from the last quote data ;  
#  USAGE: new_wlab_trade  TICKER [TXN=Buy|Short|Sell|Cover [sharesCount=($500/stock price)  [account = SYM]]  ]
#  new_wlab_trade ABBV Short 
{
	TOTAL=1000
	TXN="Buy"
	if [ $# -ge 2 ]; then
		TXN=$2
	fi
	if [ $# -ge 1 ]; then
		TKR=$1
	else 
		echo "USAGE: new_wlab_trade  TICKER [TXN=Buy|Short|Sell|Cover ]"
		echo "it Computes : sharesCount=($500/stock price)  , account = PAPER "
		echo "E.g. :  new_wlab_trade ABBV Short "
		exit
	fi

	DATE=$(date +%Y-%m-%d)
	PRICE=$(get_last_price $TKR )
	#awk -v TXN=$TXN -v TKR=$TKR -v TOTAL=TOTAL
	echo "$TKR $DATE $TXN $PRICE $TOTAL"| awk '{printf "%s;%s;%s;%s;%d;%s;\n",$1,$2,$3,$4,$5/$4,"PAPER"}' 
}

############################################################################
#    Limited FREE   
#    FREE API call frequency is 5 calls per minute and 500 calls per day. 
#
#  DOCS:    https://www.alphavantage.co/documentation/
# curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${TKR}&apikey=8E409AF7G8ZJZA3F&datatype=json" | jq  -r '."Global Quote"."01. symbol"'
############################################################################

function get_delayed_quote_csv()
#  get CURRENT delayed quote data ; 
#  USAGE: get_delayed_quote  TICKER  | jq  -r '."Global Quote"."01. symbol"'
#| jq -r ' [ .symbol, .low, .high, .latestVolume, .latestPrice ]  | join(";") ' 
{
	if [ -z "$*" ]; then exit; fi
	TKR=$1
		curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${TKR}&apikey=8E409AF7G8ZJZA3F&datatype=csv"  | tail -1 
		sleep 12s
	#  Field name and index for CSV
	#  symbol,open,high,low,price,volume,latestDay,previousClose,change,changePercent
    #           symbol = 1
    #             open = 2
    #             high = 3
    #              low = 4
    #            price = 5
    #           volume = 6
    #        latestDay = 7
    #    previousClose = 8
    #           change = 9
    #    changePercent = 10
}

function get_delayed_quote_json()
#  get CURRENT delayed quote data ; 
#  USAGE: get_delayed_quote  TICKER  | jq  -r '."Global Quote"."01. symbol"'
{
	if [ -z "$*" ]; then exit; fi
	TKR=$1
	curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${TKR}&apikey=8E409AF7G8ZJZA3F&datatype=json" 
	# get one field :    | jq  -r '."Global Quote"."01. symbol"'
	# get more fields :  | jq -r ' [ ."Global Quote"."01. symbol",  ."Global Quote"."04. low",  ."Global Quote"."03. high",  ."Global Quote"."06. volume",  ."Global Quote". ]  | join(";") ' 
	# {
	#   "Global Quote": {
	#     "01. symbol": "AAPL",
	#     "02. open": "204.0000",
	#     "03. high": "205.8800",
	#     "04. low": "203.7000",
	#     "05. price": "205.6600",
	#     "06. volume": "15724494",
	#     "07. latest trading day": "2019-07-18",
	#     "08. previous close": "203.3500",
	#     "09. change": "2.3100",
	#     "10. change percent": "1.1360%"
	#   }
}

 # prints new alert string
function new_alert()
#  USAGE:   : new_alerts  <TICKER> <TARGET>
{
 	if [ -z "$*" ]; then 
	 	echo "new_alert  <TICKER> <TARGET>"
	fi
	echo "Edit COMMENT and PRICE_BELOW/VOLUME_BELOW/ABOVE"
		
	D1=$(date +%Y-%m-%d)
	if [[ $ENVID == *"OSX"* ]]; then   
		D2=$(date -v+3m +%Y-%m-%d)
	else
		D2=$(date  --date='3 month' +%Y-%m-%d)
	fi
	
	TKR=$1
	TGT=$2
	printf "ALERT;{ \"condition\": \"PRICE_BELOW\", \"ticker\": \"%s\", \"price\" : %s , \"volume\" : 0 , \"expiration\" : \"%s\",\"note\" : \" New LowerLow \", \"date\" : \"%s\" }\n" $TKR $TGT $D2 $D1 
	printf "ALERT;{ \"condition\": \"PRICE_ABOVE\", \"ticker\": \"%s\", \"price\" : %s , \"volume\" : 0 , \"expiration\" : \"%s\",\"note\" : \" New HIGHER HIGH \", \"date\" : \"%s\" }\n" $TKR $TGT $D2 $D1 
	
}

#alerts.sh $R1 $R2 watchlist.wlab
function show_alerts()
#  USAGE:   : show_alerts $R1
{
 	pushdm $WLAB_HOME/_Trades
	if [ -n "$*" ]; then 
		export WLAB_FOLIOS="$*"
	fi
	grep -n 'ALERT' ${WLAB_FOLIOS}
	#awk -F\; '$1=="ALERT" { print $0 }' ${WLAB_FOLIOS}
  	popdm
}

function check_alerts()
#  USAGE:   : check_alerts $R1
{
 	pushdm $WLAB_HOME/_Trades
	if [ -n "$*" ]; then 
		export WLAB_FOLIOS="$*"
	fi
	alerts.sh ${WLAB_FOLIOS}
 	popdm
}

function folio_size() 
#	USAGE:  folio_size "da.wlab" : return $$ vlue of the folio
{
	cd $WLAB_HOME/_Trades
	rm -f /tmp/xxxaaaa
	## ARGS - 1 ="${@:1}"
	TIKS=$(get_tickers_from_wlab "${@:1}")
	#echo $TIKS
	for SYM in $TIKS
	do 
		CLOSE=$(get_last_price $SYM)
		wlab $SYM | awk -F\; -v TKR=$SYM  -v CLOSE=$CLOSE '$3=="Buy" { N+=$5; S+=$5*$4; } $3=="Sell" { N-=$5; S-=$5*$4; }  END { print S"\t"N*CLOSE >> "/tmp/xxxaaaa"}'
	done
	##  = %.2f %s for average 
	awk  -v FOLIO=$1 '{ IN+=$1; NOW+=$2; } END {printf "Total invested in %s $%\047d NOW = $%\047d\n", FOLIO,IN, NOW }' /tmp/xxxaaaa
}

function folio_sizev()
# folio_size "da.wlab" : return $$ vlue of the folio ; prints size of each position
{
	cd $WLAB_HOME/_Trades
	rm -f /tmp/xxxaaaa
	TIKS=$(get_tickers_from_wlab "${@:1}")
	for SYM in $TIKS
	do 
		CLOSE=$(get_last_price $SYM)
		echo "##### $SYM #####  $CLOSE"
		wlab $SYM | awk -F\; -v TKR=$SYM  -v CLOSE=$CLOSE '$3=="Buy" { N+=$5; S+=$5*$4; } $3=="Sell" { N-=$5; S-=$5*$4; } END { printf "Bought %d(%s) = $%\047d ; NOW = $%\047d\n",N,TKR,S,N*CLOSE  ; print S"\t"N*CLOSE >> "/tmp/xxxaaaa"}'
		#   ADD 
	done
	##  = %.2f %s for average 
	awk  -v FOLIO=$1 '{ IN+=$1; NOW+=$2; } END {printf "Total invested in %s $%\047d NOW = $%\047d\n", FOLIO,IN, NOW }' /tmp/xxxaaaa
}

function get_tickers_from_wlab() {
# USAGE : [HISTORY=yes] get_tickers_from_wlabs $R1  | tr  '\n' ' ' ; echo"" #to get one line
# print ALL tickers. with HISTORY=yes includes tickers from HISTORY section 
awk -F\; -v HISTORY=$HISTORY '  	
	$1 ~ /ALERT/ {next} 
	$1 ~ /^[A-Z]+$/ {print $1} 
	!HISTORY && $1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {nextfile;}
	' $*  | sort -u 
}
function get_tickers_from_wlabh() {
	HISTORY=yes get_tickers_from_wlab $*
}
function get_tickers_from_wlabs() {
# USAGE : [SECTION_NAME=NAME] get_tickers_from_wlabs $R1 
# print ALL tickers or  tickers in the optional SECTION NAME . Does NOT process history
awk -F\; -v SECTION_NAME=$SECTION_NAME '  	
	BEGIN {if (SECTION_NAME=="") DOIT="true"}
	DOIT && $1 ~ /^[A-Z]+$/ {print $1} 
	$1 ~ /ALERT/ {next} 
	$1 ~ /SECTION[[:space:]]+BEGIN/ && $2 ~ SECTION_NAME {DOIT="true";}
	$1 ~ /SECTION[[:space:]]+END/ {DOIT="";}
	$1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {nextfile;} 
	' $*
}

function add_sectionName_as_comment () {
# print all or only one section which name is a parameter e.g. $0 FwdLimitOrd
# do Not process history
awk -F\; -v SECTION_NAME=$2 '  
#	BEGIN { SECTION_NAME="NOSECTION"}	
	$1 ~ /^[A-Z]+$/ {print $0";"SECTION_NAME} 
	$1 ~ /SECTION[[:space:]]+BEGIN/ {SECTION_NAME=$2; }
	$1 ~ /SECTION[[:space:]]+END/ {SECTION_NAME="";}
	' $1
}

pushdm() {
    command pushd "$@" > /dev/null
}

popdm() {
    command popd "$@" > /dev/null
}

function wlab_old()
#  USAGE: wlab  TICKER  : prints TICKER position with history 
{
    pushdm $WLAB_HOME/_Trades
    TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
	awk -F\; -v TKR=$TKR '
		#FNR==1 { print "=== ",FILENAME," ==="; DOIT=0}
		FNR==1 { DOIT=0}
		$1==TKR {print $0; DOIT=1;} 
		DOIT==1 && $1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {print "=== ",FILENAME," History ===";DOIT=0;}
		' ${WLAB_FOLIOS}
        popdm
}

function wlab()
#  USAGE: wlab  TICKER  : prints TICKER position with history 
{
    pushdm $WLAB_HOME/_Trades
    TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
	awk -F\; -v TKR=$TKR -f $WLAB_HOME/bin/functions_inc.awk -e '
		FNR==1 { dprint(FILENAME); PRN_BANNER=0; HISTORY=0;}
		$1==TKR && HISTORY==0 { 
			 dprint("TKR && HISTORY==0 ");
			 dprint("PRN_BANNER="PRN_BANNER"; HISTORY="HISTORY);
			PRN_BANNER=1;
			print $0; 
		} 
		$1==TKR && HISTORY==1 { 
			 dprint("PRN_BANNER="PRN_BANNER"; HISTORY="HISTORY);
			if(PRN_BANNER==1) { print "=== ",FILENAME," History ==="; PRN_BANNER=0; }
			 dprint("TKR && HISTORY==1 ");
			print $0; 
		} 
		$1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {
			 dprint(FILENAME": HISTORY line : PRN_BANNER="PRN_BANNER"; HISTORY="HISTORY);
			HISTORY=1;
			if(PRN_BANNER==1) { 
				print "=== ",FILENAME," History ==="; PRN_BANNER=0; 
			}
			else {  #PRN_BANNER==0
				PRN_BANNER=1; 
				 dprint("set PRN_BANNER==1"); 
			}

			 dprint(FILENAME": HISTORY line : PRN_BANNER="PRN_BANNER"; HISTORY="HISTORY);
		}
		#END { if(PRN_BANNER==1) print "=== ",FILENAME," History ==="; print "EOF " }
		' ${WLAB_FOLIOS}
        popdm
}

function wlab01()
#  USAGE: wlab  TICKER  : prints TICKER position with history 
{
    pushdm $WLAB_HOME/_Trades
    TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
	awk -F\; -v TKR=$TKR -f $WLAB_HOME/bin/functions_inc.awk -f $WLAB_HOME/bin/wlab.awk  ${WLAB_FOLIOS}
    popdm
}

function wlabh()
#  USAGE: wlabh  TICKER. Uses Shoebox/wlab_trades.history and FailedSystems/*.wlab
{
        pushdm $WLAB_HOME/_Trades
        TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
		wlab $TKR
        grep \^$TKR\; Shoebox/wlab_trades.history FailedSystems/*.wlab
        popdm
}


function wlabs_v01()
#  USAGE: wlab  TICKER  : prints TICKER position and computes average position entry price 
{
    pushdm $WLAB_HOME/_Trades
    TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
	awk -F\; -v TKR=$TKR '
		$1==TKR { N+=$5; S+=$5*$4; }
		$1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {nextfile}
		END {print "total  "S " = " N " shares at $" S/N "" }
		' ${WLAB_FOLIOS}
    popdm
}

function wlabs()
#  USAGE: wlab  TICKER  : prints TICKER position and computes average position entry price 
{
    pushdm $WLAB_HOME/_Trades
    TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
	P=$(get_last_price $TKR)
	awk -F\; -f $WLAB_HOME/bin/functions_inc.awk -f $WLAB_HOME/bin/wlabs.awk TKR=$TKR  P=$P ${WLAB_FOLIOS}
    popdm
}

function wlabs01()
#  USAGE: wlab  TICKER  : prints TICKER position and computes average position entry price 
{
    pushdm $WLAB_HOME/_Trades
    TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
	P=$(get_last_price $TKR)
	awk -F\; -f $WLAB_HOME/bin/functions_inc.awk -e '
		$1==TKR && $3=="Buy" { 
			N+=$5; S+=$5*$4; 
			dprint($0);
			dprint( "N+="$5"; S+="$5*$4);
			dprint( "N="N"; S="S);
		} 
		$1==TKR && $3=="Sell" { 
			N-=$5; S-=$5*$4; 
			dprint($0);
			dprint( "N-="$5"; S-="$5*$4);
			dprint( "N="N"; S="S);
		}
		$1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {nextfile}
		END { if( S==0 || N==0 ) 
				print TKR" - No position";
			else
				dprint( "N="N"; S="S);
				# this prints  position cost REDUCED by profit .
				print TKR"("N")  EntryAVG @ "S/N" => "S " NOW @ "P" => " N*P
			}
		'  TKR=$TKR  P=$P  ${WLAB_FOLIOS}
    popdm
}

function getStory()
#  USAGE PC Data Only : getStory  TICKER  : gets data from Brieffing.com/InPlay  
{
	grep   'storyTitle">'$1' '    /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WEB/Brieffing.com/InPlay/*
}

function get_brief()
#  USAGE PC Data Only : getStory  TICKER  : gets data from Brieffing.com/InPlay  
{
    TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
#	grep   'storyTitle">'$TKR' '    /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WEB/Brieffing.com/InPlay/HTML/*
#	grep   '[:blank:]'$TKR'[:blank:]'   /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WEB/Brieffing.com/*/*.{TXT,txt}
	grep   '[[:punct:],[:space:]]'$TKR'[[:punct:],[:space:]]'   /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WEB/Brieffing.com/*/*.{TXT,txt}
}

function wlab_check_env()
#  USAGE checks if "WLAB_HOME = $WLAB_HOME or WLAB_FOLIOS = $WLAB_FOLIOS is not set"
  
{
	if [ -z "$WLAB_HOME" ] || [ -z "$WLAB_FOLIOS" ] 
		then echo "WLAB_HOME = $WLAB_HOME or WLAB_FOLIOS = $WLAB_FOLIOS is not set"
		exit
	fi
}


##################   DUMP  ###################

: << 'COMMENT'
############################################################################
#####    Third party data has moved to IEX Cloud. Get started for free.  ###
#  https://iexcloud.io/console/   mpkmtv@hotmail.com
#  DOCS:   https://iexcloud.io/docs/api/
#  curl -k 'https://cloud.iexapis.com/stable/stock/aapl/quote?token=pk_007e296b90f14627b5615b8eeb58a2a7'
#
#            NOT FREE ANYMORE !!!!
#
############################################################################

#awk -F\; -f -v INCDIR=$WLAB_HOME/bin 
#	#@include INCDIR"/functions.awk"

export YOUR_TOKEN_HERE=pk_007e296b90f14627b5615b8eeb58a2a7
# DOES NOT WORK ANYMORE !!!
	# function get_delayed_quote()
	# #  get CURRENT delayed quote data ;  Timestamp = date -r $(( $(get_delayed_quote  TICKER | jq -r '.latestUpdate') /1000))
	# #  USAGE: get_delayed_quote  TICKER  | jq -r ' [ .symbol, .low, .high, .latestVolume, .latestPrice ]  | join(";") ' 
	# {
	# 	curl -s "https://cloud.iexapis.com/stable/stock/$1/delayed-quote?token=${YOUR_TOKEN_HERE}" 
	# }


	# function get_last_price()
	# #  get LAST price from cloud.iexapis.com FREE same as tops
	# #  USAGE: get_delayed_quote  TICKER  | jq -r ' [ .symbol, .low, .high, .latestVolume, .latestPrice ]  | join(";") ' 
	# {
	# 	curl -s "https://cloud.iexapis.com/stable/stock/$1/quote?token=${YOUR_TOKEN_HERE}" 
	# }

function get_last_close()
#  get DAILY last_close price 
#  USAGE: get_last_close  TICKER  
{
	SYM=$1
	https://cloud.iexapis.com/stable/stock/${SYM}/quote?token=$YOUR_TOKEN_HERE
	curl -s "https://api.iextrading.com/1.0/stock/market/previous/batch?symbols=${SYM}&types=quote" |  jq -r '.[].close' 
#  API documentation  :  https://iextrading.com/developer/docs/#price

	#curl -s "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=${SYM}&apikey=8E409AF7G8ZJZA3F&datatype=csv" | head -2 | tail -1 | cut -f5 -d\,
    # ATTENTION !!!! FRee Alpha Vantage standard API call frequency is 5 calls per minute and 500 calls per day. 
	
 	#tail -1 /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WlabPro/DATA/ASCII/${SYM}.csv | cut -f5 -d\;
	#iax ???

}

function get_last_trading_day_quote()
#  get DAILY get_last_trading_quote data 
#  USAGE: get_last_trading_day_quote  TICKER  | jq -r '.[].close'    [open,close,high,low,volume]
{
	SYM=$1
	WHAT=$1
	curl -s "https://api.iextrading.com/1.0/stock/market/previous/batch?symbols=${SYM}&types=quote" 

}

function get_delayed_quote()
#  get CURRENT delayed quote data ;  Timestamp = date -r $(( $(get_delayed_quote  TICKER | jq -r '.latestUpdate') /1000))
#  USAGE: get_delayed_quote  TICKER  | jq -r '.[].close'    [open,close,high,low,volume]
{
	curl -s "https://api.iextrading.com/1.0/stock/$1/quote"
}


function get_trading_data() 
#  get ticker trading data for the last few days 
#	USAGE: get_trading_data  TICKER  LAST-N-DAYS
{
	SYM=$1
	CNT=$2
	
	curl -s "https://api.iextrading.com/1.0/stock/${SYM}/chart" | head -${CNT}

	#curl -s "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=${SYM}&apikey=8E409AF7G8ZJZA3F&datatype=csv" | head -${CNT}

	#tail -1 /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WlabPro/DATA/ASCII/${SYM}.csv | cut -f${CNT} -d\;

}

function wlabf()
#  USAGE:   : NOT WORKING
{
        pushdm $WLAB_HOME/_Trades
        TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
        awk -F\;  -v TKR=$TKR ' $1 ~ /^[A-Z]+$/ || /^$/  { prn=0 }  \
           $1 == TKR { prn=1 ; print "file : " FILENAME }  \
            {if ( prn==1 ) print $0 }'  ${WLAB_FOLIOS}
        popdm
}

function wlabs0()
#  USAGE: wlab  TICKER  : prints TICKER position and computes average position entry price 
{
        pushdm $WLAB_HOME/_Trades
        TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
        grep \^$TKR\; ${WLAB_FOLIOS} |  awk -F\; '$3=="Buy" { N+=$5; S+=$5*$4; print $0} $3=="Sell" { N-=$5; S-=$5*$4; print $0} END {print "total  "S " = " N " shares at $" S/N "" }'

        popdm
}


function wlabfh()
#  USAGE:   : NOT WORKING  obsolete. Uses Shoebox/wlab_trades.history
{
        pushdm $WLAB_HOME/_Trades
        TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
        awk -F\;  -v TKR=$TKR ' $1 ~ /^[A-Z]+$/ || /^$/  { prn=0 }  \
            $1 == TKR { prn=1 }  \
            {if ( prn==1 ) print $0 }'  ${WLAB_FOLIOS} wlab_trades.history
        popdm
}


COMMENT
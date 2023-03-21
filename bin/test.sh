function get_delayed_quote()
#  get CURRENT delayed quote data ;  Timestamp = date -r $(( $(get_delayed_quote  TICKER | jq -r '.latestUpdate') /1000))
#  USAGE: get_delayed_quote  TICKER  | jq -r '.[].close'    [open,close,high,low,volume]
{
	curl -s "https://api.iextrading.com/1.0/stock/$1/quote"
}




	TOTAL=1000
	TXN="Buy"
	if [ $# -ge 2 ]; then
		TXN=$2
	fi
	if [ $# -ge 1 ]; then
		TKR=$1
	else 
		echo "USAGE: new_wlab_trade  TICKER [TXN=Buy|Short|Sell|Cover [sharesCount=($500/stock price)  [account = SYM]]  ]"
		exit
	fi

	DATE=$(date +%Y-%m-%d)
	PRICE=$(get_delayed_quote $TKR | jq -r '.latestPrice' )
	#awk -v TXN=$TXN -v TKR=$TKR -v TOTAL=TOTAL
	echo "$TKR $DATE $TXN $PRICE $TOTAL"| awk '{printf "%s;%s;%s;%s;%d;%s;\n",$1,$2,$3,$4,$5/$4,"SYM"}' 

exit



if [ $# -ge 2 ]; then
    echo $1: usage: myscript name
    exit 1
else 



exit

function get_delayed_quote()
#  get CURRENT delayed quote data ;  Timestamp = date -r $(( $(get_delayed_quote  TICKER | jq -r '.latestUpdate') /1000))
#  USAGE: get_delayed_quote  TICKER  | jq -r '.[].close'    [open,close,high,low,volume]
{
	SYM=$1
	curl -s "https://api.iextrading.com/1.0/stock/${SYM}/quote"
}

function new_wlab_trade()
#  crsates Wlab entry "NEM;2014-06-02;Buy;20.8;100;IRA; " from CURRENT delayed quote data ;  
#  USAGE: new_wlab_trade  TICKER [TXN=Buy|Short|Sell|Cover [sharesCount=($500/stock price)  [account = SYM]]  ]
{
	if [ $# > 0 ]
	then 
		echo "USAGE: new_wlab_trade  TICKER [TXN=Buy|Short|Sell|Cover [sharesCount=($500/stock price)  [account = SYM]]  ]"
		exit
	fi
	if [ -z "$2" ]
	then 
		echo "USAGE: new_wlab_trade  TICKER [TXN=Buy|Short|Sell|Cover [sharesCount=($500/stock price)  [account = SYM]]  ]"
		exit
	fi
	SYM=$1
	DATE=$(date +%Y-%m-%d)
	get_delayed_quote $1 
	awk 'printf "%s;%s;Buy;%s;%s;%3.3s;\n", $6,arr[3]"-"arr[1]"-"arr[2],$8,$7,$3 >> "openLonPos.tmp" }' 
}
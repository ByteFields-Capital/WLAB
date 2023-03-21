###############################################################################
####   Various utils

#CLOSE price for SYM
curl -s "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=${SYM}&apikey=8E409AF7G8ZJZA3F&datatype=csv" | head -2 | tail -1 | cut -f5 -d\,

# total shares @ price
http://psytests.org/result?v=szn-1kTAurF
wlab ashr |  awk -F\; '$3="Buy" { N+=$5; S+=$5*$4; print $0} END {print "total  "S " = " N " shares at $" S/N "" }'

# FIND unbalanced TXNs ( sell without buy) 
awk -F \; ' \
$1 ~ /^[A-Z]+$/ &&  $3 == "Sell" { PosSz[$1"@"$6] -= $5;} \
$1 ~ /^[A-Z]+$/ &&  $3 == "Buy" { PosSz[$1"@"$6] += $5} \
$1 ~ /^[A-Z]+$/ &&  $3 == "Short" { PosSz[$1"@"$6] -= $5} \
$1 ~ /^[A-Z]+$/ &&  $3 == "Cover" { PosSz[$1"@"$6] += $5} \
END { for (key in PosSz)  { printf "%10s %d\n", key , PosSz[key] }}'  wlab_trades.history | sort -k2 -n
	
# "intersection" between "one" and "two" ":
comm -12 one two 
# compare files 
awk -F \; '$1 ~ /^[A-Z]+$/ {print $1}' ${WLAB_HOME}/_Trades/gen*.wlab eden.close.wlab eden.wlab |  tr -d "[:blank:]" | sort -u > track.txt
comm -1 -2  holdins.2017-10-31 track.txt

#get Sector by ticker
$ wget -O - 'https://api.iextrading.com/1.0/stock/aapl/quote'  /dev/null 2>1 | jq '.sector'



#print names of MLN holdings.sym which are not in wlab.sym

awk '$1 ~ /^[A-Z ]+$/ { print $1 }'  /cygdrive/c/Users/mpkmt_000/Downloads/ExportData03062018125515.txt | sort -u  > hold.sym
for i in $WLAB_FOLIOS ; do ./$i |  sed 's/\ /\n/g' >> wlab.sym; done
sort -u -o wlab.sym wlab.sym
comm -1 -3 wlab.sym hold.sym

## 

# Tickers: 
awk -F \; '$1 ~ /^[A-Z]+$/ {print $1}' ${WLAB_HOME}/_Trades/[ceg]*.wlab | awk '!x[$0]++' > trades.sym
# removing duplicate lines without sorting : 
awk '!x[$0]++'
# Mln->Holdings->export to $INFILE  
	awk '$1 ~ /^[A-Z]+$/  && $2 != "0" && $3 != "0" { print $0 }' $INFILE  >  Holdings.txt; dos2unix.exe Holdings.txt
	#get symbols  
	cut -f1 Holdings.txt | tr -d "! " | sort -u   >  Holdings.sym
	#Holdings - Gold =  
	${WLAB_HOME}/_Trades/gold.wlab > Gold.sym
	comm -23 Holdings.sym Gold.sym > Holdings-G.sym
	#get LAGEST summed up Position $$ value for each Ticker  
	cat  Holdings.txt | tr -d '$!,' |  cut -f1,4 |  LC_ALL=en_US.UTF-8  gawk  '{ x[$1] +=$2; print $1" : "$2} END { for (key in x) { printf "%s\t%\47d\n", key , x[key] }}'  |  sort -k2 -n
#FORMAT ,000
	$ echo 1234567 | LC_ALL=en_US.UTF-8 gawk '{printf "%\47d\n",$1}'
	1,234,567


#print names of holdings.sym which are not in trades.sym
awk 'BEGIN { while (getline < "trades.sym") trades[$0]++; \
	close("trades.sym"); } \
	!trades[$0]  #print $0 '  
##
awk 'BEGIN { while (getline < "trades.sym") trades[$0]++; \
	close("trades.sym"); \
	print  "length(trades)=" length(trades);\
	for (i in trades) print i;\
 	print  "=== Positions  which are not in trades.sym ===" ;}\
	#trades[$0]  {print "\t\t"$0;}\
	!trades[$0]  {print $0} '  Positions.sym

https://api.iextrading.com/1.0/stock/market/batch?symbols=aapl,fb&types=sector&last=1wlab()
{
        cd $WLAB_HOME/_Trades
        TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
        grep \^$TKR\; [gec]*.wlab
}

wlabf()
{
        cd $WLAB_HOME/_Trades
        TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
        awk -F\;  -vTKR=$TKR ' $1 ~ /^[A-Z]+$/ || /^$/  { prn=0 }  \
           $1 == TKR { prn=1 ; print "file : " FILENAME }  \
            {if ( prn==1 ) print $0 }'  [gec]*.wlab 
}

wlabh()
{
        cd $WLAB_HOME/_Trades
        TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
        grep \^$TKR\; [gec]*.wlab wlab_trades.history
}

wlabfh()
{
        cd $WLAB_HOME/_Trades
        TKR=$( echo $1 | tr '[:lower:]' '[:upper:]')
        awk -F\;  -vTKR=$TKR ' $1 ~ /^[A-Z]+$/ || /^$/  { prn=0 }  \
            $1 == TKR { prn=1 }  \
            {if ( prn==1 ) print $0 }'  [gec]*.wlab wlab_trades.history
}


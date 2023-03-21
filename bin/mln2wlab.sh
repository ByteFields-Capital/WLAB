## dos2unix !!
#
# USAGE: /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WlabPro/mln2wlab.sh /cygdrive/c/Users/mpkmt_000/Downloads/ExportData27072017024503.txt
#
# GET SYMBOLS : awk -F\; '/2017/ {print $1}' eden.wlab

export OUTFILE=trades.in

if [ -z "$1" ]
then 
	echo "what isINFILE? "
	echo "GetIT :  MLN->activity->export as txt -> e.g  /cygdrive/c/Users/mpkmt_000/Downloads/ExportData07012017215920.txt"
	exit
fi
export INFILE=$1
cd ${WLAB_HOME}/_Trades
dos2unix $INFILE
rm -f *.tmp
mv $OUTFILE ${OUTFILE}.$(date +%Y-%m-%d.%s)

# prepare WLAB import
grep 'Purchase \|Buy' $INFILE | grep -v -i SHORT |  tr -d '$, ' | awk -F"\t" '{split($1,arr,"/");  printf "%s;%s;Buy;%s;%s;%3.3s;\n", $6,arr[3]"-"arr[1]"-"arr[2],$8,$7,$3 >> "openLonPos.tmp" }' 
grep 'Sale\|Sell' $INFILE | grep -v -i SHORT |  tr -d '$, -' | awk -F"\t" '{split($1,arr,"/");  printf "%s;%s;Sell;%s;%s;%3.3s;\n", $6,arr[3]"-"arr[1]"-"arr[2],$8,$7,$3>> "closeLonPos.tmp" }' 
grep -i 'SHORT' $INFILE | grep 'Sale\|Sell\|SALE' |  tr -d '$, -' | awk -F"\t" '{split($1,arr,"/");  printf "%s;%s;Short;%s;%s;%3.3s;\n", $6,arr[3]"-"arr[1]"-"arr[2],$8,$7,$3>> "openShoPos.tmp" }' 
grep -i 'SHORT' $INFILE | grep 'Purchase\|Buy\|COVER'  |  tr -d '$, ' | awk -F"\t" '{split($1,arr,"/");  printf "%s;%s;Cover;%s;%s;%3.3s;\n", $6,arr[3]"-"arr[1]"-"arr[2],$8,$7,$3>> "closeShoPos.tmp" }' 
cat closeLonPos.tmp openLonPos.tmp closeShoPos.tmp openShoPos.tmp  | sort -k2  -t\; > $OUTFILE

#check FORMAT 
#TSRO;2017-06-29;Buy;140.26;4
awk -F";" '$1 !~ /[A-Z,0-9]+/ || $2 !~ /20[0-9][0-9]-[0-1][0-9]-[0-9][0-9]/ || $3 !~ /Short|Sell|Cover|Buy/ || $4 !~/[0-9]+/ || $5 !~/[0-9]+/ {print "bad line #" NR " : " $0 }' $OUTFILE 

##CLEAN UP
rm -f *.tmp

#GENERATE list of tickers  
grep 'Purchase\|Buy\|Sale\|Sell\|SHORT\|COVER'  $INFILE|  cut -f6 | sort -u   > trades.sym

#GENERATE trades.csv for Alerts // OLD FORMAT 
if [  "1" == "0" ]
then 
	echo "Ticker,EntryDate,EntryPrice,LongShort,Count,Target,ConfTgt,NegTgt,HardStop,StopLoss,TangentStop,TrailingStop,Strategy" > trades.csv
	grep 'Purchase \|Buy'  $INFILE | grep -v SHORT |  tr -d '$, ' | awk -F"\t" '{printf "%s,%s,%s,LONG,%s\n#\n", $6,$1,$8,$7}' >> trades.csv
	grep 'SHORT' $INFILE | grep 'Sale\|Sell\|SALE' |  tr -d '$, ' | awk -F"\t" '{printf "%s,%s,%s,SHORT,%s\n#\n", $6,$1,$8,$7}' >> trades.csv
fi

exit


## SHOW all lines with merged comment
 awk -F\; '$1~/#/{print a ";" $0;}{a=$0}'   all_trades.wlab
 awk '/#/{print a ";" $0}{a=$0}'   all_trades.wlab


$ cat  $INFILE | grep -v SHORT |  tr -d '$, ' | awk -F"\t" '/Pending/&&/Buy/ {printf "%s,%s,%s,LONG,%s\n#\n", $6,$1,$8,$7}'
ENDP,07/26/2017,11.30,LONG,50

$ cat  $INFILE | grep -v SHORT |  tr -d '$, ' | awk -F"\t" '/Pending/&&/Purchase/ {printf "%s,%s,%s,LONG,%s\n#\n", $6,$1,$8,$7}'
EXAS,07/25/2017,37.00,LONG,20

$ cat  $INFILE | grep -v SHORT |  tr -d '$, ' | awk -F"\t" '/Pending/&&/Sale/ {printf "%s,%s,%s,LONG,%s\n#\n", $6,$1,$8,$7}'
EXC,07/25/2017,37.07,LONG,-16

############################# ExportData07012017215920.txt FIELDS  ########################################
#  THERE ARE ALWAYS 10 COLUMNS FOR awk -F"\t"!!!  ; Buy/sell can be figured by GREP
TXN_DATE = $1
TICKER = $6
COUNT = $7  // is negative on sale  e.g. -10
PRICE = $8

$  cat  $INFILE | grep  Pending | grep Purchase  | grep TSRO | awk  -F"\t" '{print "NF="NF; for (i=0; i<NF; i++) print "#" i " : "$i;}'
NF=10
#0 : 07/21/2017         07/26/2017 Pending      LRG CMA-Edge 5F7-57X19  Purchase  TESARO INC ACTUAL PRICES, REMUNERAT...                TSRO    10      $131.60         -$1,316.00
#1 : 07/21/2017
#2 : 07/26/2017 Pending
#3 : LRG CMA-Edge 5F7-57X19
#4 : Purchase  TESARO INC ACTUAL PRICES, REMUNERAT...
#5 :
#6 : TSRO
#7 : 10
#8 : $131.60
#9 : -$1,316.00
$  cat  $INFILE | grep  Pending | grep CPRX | awk  -F"\t" '{print "NF="NF; for (i=0; i<NF; i++) print "#" i " : "$i;}'
NF=10
#0 : 07/21/2017         07/26/2017 Pending      LRG CMA-Edge 5F7-57X19  Sale  CATALYST PHARMACEUTICAL INC ACTUAL ...            CPRX    -200    $3.08   $615.99
#1 : 07/21/2017
#2 : 07/26/2017 Pending
#3 : LRG CMA-Edge 5F7-57X19
#4 : Sale  CATALYST PHARMACEUTICAL INC ACTUAL ...
#5 :
#6 : CPRX
#7 : -200
#8 : $3.08
#9 : $615.99
$  cat  $INFILE | grep  Pending | grep TEVA | awk  -F"\t" '{print "NF="NF; for (i=0; i<NF; i++) print "#" i " : "$i;}'
NF=10
#0 : 07/26/2017         07/31/2017 Pending      LRG CMA-Edge 5F7-57X19  Buy TEVA PHARMACTCL INDS ADR            TEVA    14      $33.03  -$462.42
#1 : 07/26/2017
#2 : 07/31/2017 Pending
#3 : LRG CMA-Edge 5F7-57X19
#4 : Buy TEVA PHARMACTCL INDS ADR
#5 :
#6 : TEVA
#7 : 14
#8 : $33.03
#9 : -$462.42
$  cat  $INFILE | grep  Sale | grep AOBC | awk  -F"\t" '{print "NF="NF; for (i=0; i<NF; i++) print "#" i " : "$i;}'
NF=10
#0 : 06/30/2017         07/06/2017      LRG CMA-Edge 5F7-57X19  Sale  AMERICAN OUTDOOR BRANDS CORP ACTUAL...            AOBC    -30     $22.27  $668.08
#1 : 06/30/2017
#2 : 07/06/2017
#3 : LRG CMA-Edge 5F7-57X19
#4 : Sale  AMERICAN OUTDOOR BRANDS CORP ACTUAL...
#5 :
#6 : AOBC
#7 : -30
#8 : $22.27
#9 : $668.08

#############################  ########################################
1. MLN->activity->export as txt -> e.g  /cygdrive/c/Users/mpkmt_000/Downloads/ExportData07012017215920.txt
#FORMATS
#  01/03/2017 	01/06/2017 	Purchase  ROCKWELL MEDICAL TECH ACTUAL PRICES... 	 	RMTI 	320 	$6.40 	-$2,048.00 	 
#  to
#  MA;30-12-2016;Buy;103.5;200

FILE Examle{
Selected account(s):LRG (CMA-Edge 5F7-57X19); SML (CMA-Edge 57X-16L46); IRA (IRRA-Edge 5F7-57365); RTH (Roth IRA-Edge 53X-58K48)
Trade Date  	Settlement Date  	Account 	Description 	Type 	Symbol/  CUSIP   	Quantity 	Price 	Amount 	  
 	 	 	 	 	 	 	 	 	 
09/27/2017 	09/29/2017 Pending 	IRA IRRA-Edge 5F7-57365 	Buy MOLECULIN BIOTECH INC SHS 	 	MBRX 	1,000 	$2.54 	-$2,540.00 	 
09/27/2017 	09/29/2017 Pending 	LRG CMA-Edge 5F7-57X19 	Sell REGIONS FINL CORP 	 	RF 	-30 	$15.00 	$449.99 	 
09/26/2017 	09/28/2017 Pending 	LRG CMA-Edge 5F7-57X19 	Pending Sale  MSA SAFETY INC SHS ACTUAL PRICES, R... 	 	MSA 	-6 	$78.00 	$467.99 	 
09/26/2017 	09/28/2017 Pending 	LRG CMA-Edge 5F7-57X19 	Pending Sale  SOTHEBY (DELAWARE) ACTUAL PRICES,... 	 	BID 	-12 	$45.30 	$543.59 	 
} 
2. In Wlab create a new DataSet i.e NewTrades with list symbols of new trades and cut-n-paste symbols from:
grep 'Purchase \|Buy'  $INFILE|  cut -f6


3.0 Create trades definition strings and paste them in importMyTrades-01
grep 'Purchase ' $INFILE | tr -d '$' |  cut -f1,5,7,6 | awk ' {printf "new StockDate(\"%s\", DateTime.ParseExact(\"%s\", \"MM/dd/yyyy\", null), %s ),\n" , $2,$1,$4}'

3.1 ALT
	Create file with trades to import by Wlabs
	grep 'Purchase ' $INFILE | cut -f1,5,7,6 | awk ' {printf "%s;%s;Buy;%s;%s\n", $2,$1,$4,$3}' | tr -d '$'
	save it as "C:\Users\mpkmt_000\Desktop\bursa\WlabPro\Trades2.csv"

4. TO Run Wlab->ImporMyPositions scrypt against every symbol in  "NewTrades"

5. Different progs to process different types of trades .... e.g. dividend stock exit rules [e.g. gap down, declining sma200, etc.] are different from momentum  
	This should be defined in the trade csv file ...

	
=================
ALL ACCOUNTS !!!! EXPORT , one account needs FIeldNo adjustment
$ INFILE=/cygdrive/c/Users/mpkmt_000/Downloads/ExportData13012017121851.txt

# TRANSFORMS
#FROM=	08/12/2016      08/17/2016      LARGE TABLE CMA-Edge 5F7-57X19  Purchase  CHEMOURS (THE) CO SHS COVER SHORT C...                CC      1,000   $11.30  -$11,300.00
#TO=	CC;08/12/2016;Buy;11.30;1000

#SHORT
OPEN = grep 'Sale.*SHORT'  $INFILE |   awk -F"\t" '{printf "%s;%s;Buy;%s;%s\n", $6,$1,$8,$7}' | tr -d '$ '
CLOSE  grep 'Purchase.*COVER'  $INFILE |   awk -F"\t" '{printf "%s;%s;Buy;%s;%s\n", $6,$1,$8,$7}' | tr -d '$ '
Pending ....

#LONG
OPEN =  grep 'Purchase'  $INFILE | grep -v SHORT |   awk -F"\t" '{printf "%s;%s;Buy;%s;%s\n", $6,$1,$8,$7}' | tr -d '$ '
CLOSE   grep 'Sale'  $INFILE  | grep -v COVER |   awk -F"\t" '{printf "%s;%s;Buy;%s;%s\n", $6,$1,$8,$7}' | tr -d '$ '
Pending ....

#Transforms to Darwin
#FROM=	08/12/2016      08/17/2016      LARGE TABLE CMA-Edge 5F7-57X19  Purchase  CHEMOURS (THE) CO SHS COVER SHORT C...                CC      1,000   $11.30  -$11,300.00
#TO=	CC,08/12/2016,4.41,Target,ConfTgt,NegTgt,HardStop,LossStop,Strategy,TermStop,TangentStop,TrailingStop,LONG,

#LONG
OPEN =  grep 'Purchase'  $INFILE | grep -v SHORT |   awk -F"\t" '{printf "%s,%s,%s,Target,ConfTgt,NegTgt,HardStop,%s,Strategy,TermStop,TangentStop,TrailingStop,LONG\n#\n", $6,$1,$8,$7}' | tr -d '$ '
#CLOSE   grep 'Sale'  $INFILE  | grep -v COVER |   awk -F"\t" '{printf "%s;%s;Buy;%s;%s\n", $6,$1,$8,$7}' | tr -d '$ '
Pending ....

#SHORT
OPEN =  grep 'Sale.*SHORT'  $INFILE | grep -v SHORT |   awk -F"\t" '{printf "%s,%s,%s,Target,ConfTgt,NegTgt,HardStop,%s,Strategy,TermStop,TangentStop,TrailingStop,SHORT\n", $6,$1,$8,$7}' | tr -d '$ '


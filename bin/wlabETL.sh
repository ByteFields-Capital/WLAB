###############################################################################
####   Various imports / exports 

if [ -z "$WLAB_HOME" ] || [ -z "$WLAB_FOLIOS" ] 
	then echo "WLAB_HOME = $WLAB_HOME or WLAB_FOLIOS = $WLAB_FOLIOS is not set"
	exit
fi

cd ${WLAB_HOME}/_Trades
if [ -n "$*" ]
then 
	export WLAB_FOLIOS="$*"
fi

for i in $WLAB_FOLIOS; do echo $(sh $i); done      #LINES
for i in $WLAB_FOLIOS; do sh $i; done              #COLUMN

###############################################################################
####  Import trades From Palisades
#Date;ForecastMadeOn;ForecastFor;Direction;SnP_UpProbability;SnP_HistoricAverageUp;SnP_DownProbability;SnP_HistoricAverageDown;NDX_UpProbability;NDX_HistoricAverageUp;NDX_DownProbability;NDX_HistoricAverageDown
#2018-03-30;March 29, 2018;April 2, 2018;Down;32%;+0.88%;68%;-1.18%;30%;+1.09%;70%;-2.06%
#2018-04-02;April 2, 2018;April 3, 2018;Up;69%;+1.38%;31%;-1.98%;73%;+2.24%;27%;-1.37%

$ tr -d "%" < /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WEB/Palisades/palisades.csv  | awk ' BEGIN {FS=";";OFS=";" }
toupper($4) == "UP"  {  print $1";SPY;GoLong;FillAtOpen" }
toupper($4) == "DOWN" {  print $1";SPY;GoShort;FillAtOpen" } '
#toupper($4) == "UP"  && $5 > 70 {  print $1";SPY;GoLong;FillAtOpen" }
#toupper($4) == "DOWN" && $5 < 30 {  print $1";SPY;GoShort;FillAtOpen" } '

exit
###############################################################################
####  Import trades From Erlanger
## to BT;2017-10-18;Buy;FillAtOpen;
TMPF=/tmp/_inf
OUTF=/tmp/_outf
OUTF=/cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WlabPro/_Trades/tmp.wlab

#rm $OUTF
#cd /tmp/XX
cd /cygdrive/c/Users/mpkmt_000/Desktop/BURSA/WEB/Erlanger/DATA
for FNAME in *-TrendChange.lst
do
	DD=$(echo $FNAME | cut -b1-10 | tr '_' '-')
	tr -d "[:blank:]" <$FNAME > $TMPF
	echo "processing $FNAME"
	awk -F\, -vDD=$DD ' 
	#{print $1","$2","$3","$4}
	$3 ~ /DOWNTREND/ &&  $4 ~ /RALLY/  {  print $2";"DD";GoShort;FillAtOpen" }
	$3 ~ /UPTREND/ &&  $4 ~ /PULLBACK/  {  print $2";"DD";GoLong;FillAtOpen" }
	$3 ~ /PULLBACK/ &&  $4 ~ /UPTREND/  {  print $2";"DD";GoLong;FillAtOpen" }
	$3 ~ /PULLBACK/ &&  $4 ~ /DOWNTREND/  {  print $2";"DD";GoShort;FillAtOpen" }
	$3 ~ /RALLY/ &&  $4 ~ /DOWNTREND/  {  print $2";"DD";GoShort;FillAtOpen" }
	$3 ~ /RALLY/ &&  $4 ~ /UPTREND/  {  print $2";"DD";GoLong;FillAtOpen" } '        $TMPF  >>  $OUTF
done

exit
	$3 ~ /DOWNTREND/ &&  $4 ~ /RALLY/  {  print $2";"DD";GoLong;FillAtOpen" }
	$3 ~ /UPTREND/ &&  $4 ~ /PULLBACK/  {  print $2";"DD";GoShort;FillAtOpen" }
	$3 ~ /PULLBACK/ &&  $4 ~ /UPTREND/  {  print $2";"DD";Buy;FillAtOpen" }
	$3 ~ /PULLBACK/ &&  $4 ~ /DOWNTREND/  {  print $2";"DD";Short;FillAtOpen" }
	$3 ~ /RALLY/ &&  $4 ~ /DOWNTREND/  {  print $2";"DD";Short;FillAtOpen" }
	$3 ~ /RALLY/ &&  $4 ~ /UPTREND/  {  print $2";"DD";Buy;FillAtOpen" }        $TMPF  >>  $OUTF

###############################################################################
####  ETL 2 Darwin ; Run Darwin ; run earnings

awk -F \; -f ${WLAB_HOME}/bin/wlab2darwin.awk   ${WLAB_FOLIOS} > ${DROPBOX_HOME}/BURSA/Folios/Wlab/trades.csv
cd $ALERTS_HOME
# run DARWIN analyis
# LTYPE=trades bash -x trades.sh Wlab
#get EARNINGS dates
LTYPE=trades bash -x get_earnings_date.sh Wlab

OR

VERYFY with : https://finance.yahoo.com/calendar/earnings/?symbol=AU 
MANY (separated by "%2C") : https://finance.yahoo.com/calendar/earnings/?symbol=AU%2CIAU%2CMDXG%2CJE%2CRAVN%2CSNPS%2CGPS%2CSLV%2CFWP%2CWDAY%2CTHO%2CKR%2CNG%2CELP%2CIBM

and extract :
IBM:
//*[@id="fin-cal-table"]/div/div[1]/table/tbody/tr[58]/td[2]/a
//*[@id="fin-cal-table"]/div/div[1]/table/tbody/tr[58]/td[4]/span[1]

PDLI:
//*[@id="fin-cal-table"]/div/div[1]/table/tbody/tr[71]/td[2]/a
//*[@id="fin-cal-table"]/div/div[1]/table/tbody/tr[71]/td[4]/span[1]


  exit

###############################################################################
#import from collective2 backtest results https://dh.collective2.com/details/105498828
#removes head line and ""
# to use with WLAB do "cp c2.wlab tmp.wlab"
#TICKERS = echo $(cut -f1 -d\; tmp.wlab | sort -u)
#### SET INFILE  and SYSNAME  #####

function ctwo2wlab {
SYSNAME=$(echo $SYSNAME | tr " " "_" )
HEAD='"Open Time ET","Side","Qty Open","Symbol","Descrip","Avg Price Open","Qty Closed","Closed Time ET","Avg Price Closed","DD as %","DD $","DD Time ET","DD Quant","DD Worst Price","Trade P/L"'
if [ "$(head -1 $INFILE)" != "$HEAD" ] ; then 
	echo "ERROR: INFILE header does not match expected CSV schema!" 
	exit
fi
echo "Processing $INFILE   $SYSNAME >> $OUTFILE"
awk -vSYSNAME="$SYSNAME" -vFPAT='([^,]*)|("[^"]+")' -vOFS=,  ' 
	NR>1 { printf ("%s;%s;Buy;%s;%s;%s;\n%s;%s;Sell;%s;%s;%s;\n" , 
	$4,substr($1, 1, 11),$6,$7,SYSNAME,$4,substr($8, 1, 11),$9,$7,SYSNAME) }'  $INFILE | tr -d \" >> $OUTFILE
}
# Import example
OUTFILE=${WLAB_HOME}/_Trades/c2.wlab
INFILE=/cygdrive/c/Users/mpkmt_000/Downloads/C2_102110837.CSV
SYSNAME='Correlation Factor'
ctwo2wlab
exit
INFILE=/cygdrive/c/Users/mpkmt_000/Downloads/C2_110186894.CSV
SYSNAME='Quantec VXS'
ctwo2wlab
INFILE=/cygdrive/c/Users/mpkmt_000/Downloads/C2_100166454.CSV
SYSNAME='CkNN Algo'
ctwo2wlab
INFILE=/cygdrive/c/Users/mpkmt_000/Downloads/C2_75800796.CSV
SYSNAME='The Momentum of Now'
ctwo2wlab
INFILE=/cygdrive/c/Users/mpkmt_000/Downloads/C2_94025749.CSV
SYSNAME='Tech Savvy'
ctwo2wlab



exit

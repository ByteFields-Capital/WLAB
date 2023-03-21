###############################################################################
####   ETL  wlab to darwin CSV format, then do whatever   
####   USAGE: awk -F\; -f $0  <input>                              ######
####  
# ETL to Darwin Alerts :

if [ -z "$WLAB_HOME" ] || [ -z "$WLAB_FOLIOS" ] 
	then echo "WLAB_HOME = $WLAB_HOME or WLAB_FOLIOS = $WLAB_FOLIOS is not set"
	exit
fi

cd ${WLAB_HOME}/_Trades
if [ -n "$*" ]
then 
	export WLAB_FOLIOS="$*"
fi

awk -F \; -f ${WLAB_HOME}/bin/wlab2darwin.awk   ${WLAB_FOLIOS} > ${DROPBOX_HOME}/BURSA/Folios/Wlab/trades.csv

# Perform DARWIN functions
cd  $ALERTS_HOME

# run DARWIN analyis
# LTYPE=trades bash -x trades.sh Wlab

#get EARNINGS dates
#LTYPE=trades bash  get_earnings_date.sh Wlab

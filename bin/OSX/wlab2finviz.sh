###############################################################################
####   OSX / Chrome version 
export TMPFILE=/tmp/tmp.Qmj58mqwqqJD5P
#export BROWSER=echo 
export BROWSER="open -na 'Google Chrome'"
export DELIM='"%2C"'
export CMDF=/tmp/tmp.Qmj58mqwqqJD5nnn
export WLAB_FOLIOS="close.wlab biotec.wlab bottomFishing.wlab energy.wlab gold.wlab growth.wlab income.wlab sys_tradeSR.wlab uptrend.wlab utilities.wlab value.wlab short.wlab"

printf "$BROWSER   --args --new-window  'https://www.finviz.com/' \n"  > $CMDF

if [ -z "$WLAB_HOME" ] || [ -z "$WLAB_FOLIOS" ] 
	then echo "WLAB_HOME = $WLAB_HOME or WLAB_FOLIOS = $WLAB_FOLIOS is not set"
	exit
fi

cd ${WLAB_HOME}/_Trades
if [ -n "$*" ]; then 
	export WLAB_FOLIOS="$*"
fi

#  echo "The number of positional parameter : $#"
# echo "All parameters or arguments passed to the function: '$@'"
if [ "$#" == "1" ]; then 
	TIKERS=$( awk -F\; '$1 ~ /^[A-Z]+$/ {print $1} $1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {exit 1;}' $1 | tr -d "[:blank:]" | sort -u | awk ' { LST=$1","LST} END { print LST}')
	if [ -n "$TIKERS" ] ; then 
		URL=https://www.finviz.com/quote.ashx?t=${TIKERS}			
		printf "$BROWSER  \"$URL\" \n" > $CMDF
	fi
else
	for LIST in  $WLAB_FOLIOS 
	do
	#	awk -F \; '$1 ~ /^[A-Z]+$/ {print $1}' $LIST | tr -d "[:blank:]" | sort -u | awk ' { LST=$1","LST} END { print LST > "/tmp/tmp.Qmj58mqwqqJD5P"}'
		awk -F\; '$1 ~ /^[A-Z]+$/ {print $1} $1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {exit 1;}' $LIST | tr -d "[:blank:]" | sort -u | awk ' { LST=$1","LST} END { print LST > "/tmp/tmp.Qmj58mqwqqJD5P"}'
		TIKERS=$(cat /tmp/tmp.Qmj58mqwqqJD5P)
		if [ -n "$TIKERS" ] ; then 
			URL="https://www.finviz.com/screener.ashx?v=141&t=${TIKERS}&o=perf1w"
			printf "$BROWSER  \"$URL\" \n"  >> $CMDF
		fi
	done
fi

if [ -n "$PRINT_ONLY" ]; then
	cat $CMDF
else
	sh $CMDF
fi

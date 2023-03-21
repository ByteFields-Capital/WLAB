#
#  for i in SPY GW AAPL ; do  ./get_grp_ind.sh $i ; done
#  works only on Windows
#
if [ -z "$WLAB_HOME" ] || [ -z "$WLAB_FOLIOS" ] 
	then echo "WLAB_HOME = $WLAB_HOME or WLAB_FOLIOS = $WLAB_FOLIOS is not set"
	exit
fi

cd ${WLAB_HOME}/bin
export IND_GRP_DB=${WLAB_HOME}/bin/ticker_grp_ind.csv	
export TmpFile=/tmp/2342dfkdfoldf.tmp
export TmpFile2=/tmp/2342dfkdfoldf2.tmp 
export TmpFile3=/tmp/2342dfkdfoldf3.tmp

export TICKER=$( echo $1 | tr '[:lower:]' '[:upper:]')
export GRP=$( awk -F\, -v TICKER=$TICKER '$1==TICKER { print $2 "," $3 }' ${IND_GRP_DB} )
#-vIND_GRP_DB=$(cygpath -w ${IND_GRP_DB}) 
if [ -z "$GRP" ]
then
	if wget -O ${TmpFile2}  https://www.finviz.com/quote.ashx?t=${TICKER} > /dev/null  2>${TmpFile3}
	then  
		echo "Got data for ${TICKER}" 
		/cygdrive/c/tools/DevTools/xidel/xidel.exe   $(cygpath -w $TmpFile2) -e '//td[@class="fullview-links"]/a[1]' -e  '//td[@class="fullview-links"]/a[2]' > ${TmpFile}
		dos2unix $TmpFile
		awk -vTICKER=$TICKER '
			NR==2 {GRP=$0 }
			NR==5 {IND=$0 } 
			END { print TICKER "," GRP "," IND} 
			' $TmpFile >> $IND_GRP_DB
#sort 
		sort -k2,3 -t\, -o ${IND_GRP_DB} ${IND_GRP_DB}
	else 
		echo "ERROR for ${TICKER} :"
		cat ${TmpFile3}
		echo "$TICKER,N/A,N/A" >> ${IND_GRP_DB}
	fi
fi
awk -F\, -v  TICKER=$TICKER  '$1==TICKER { print $2 "," $3 }'  ${IND_GRP_DB} 

exit
# get new symbols
awk -F\; '$1 ~ /^[A-Z]+$/ {print $1}' *.wlab | sort -u > all.sym
awk -F\, '$1 ~ /^[A-Z]+$/ {print $1}' ${IND_GRP_DB} | sort -u > grp.sym
export XX=$(comm -32  all.sym grp.sym)
for i in $XX ; do  ./get_grp_ind.sh $i ; done
rm all.sym grp.sym

#lookup a Industry and Group for a symbol
awk -F\; -vIND_GRP_DB=${IND_GRP_DB}'
BEGIN {
	while (getline < "IND_GRP_DB") 	{
		split($0,ft,",");
		GRP[ft[1]]=ft[2];
		IND[ft[1]]=ft[3];
	}
}
$1 ~ /^[A-Z]+$/ {print $0 ";" GRP[$1] ";" IND[$1]} 
$1 !~ /^[A-Z]+$/ '

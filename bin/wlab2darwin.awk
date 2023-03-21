###############################################################################
####   ETL  wlab to darwin CSV format   
####   USAGE: awk -F\; -f $0  <input>                              ######
####  
# ETL to Darwin Alerts :
# awk -F \; -f ${WLAB_HOME}/wlab2darwin.awk   ${WLAB_HOME}/_Trades/genOne.wlab  > ${DROPBOX_HOME}/BURSA/Folios/Wlab/trades.csv
###############################################################################
function dprint(x) {
	if ( DEBUG ) print x > "/dev/stderr";
}
function printDarwinEntry()
{
	dprint(Ticker " : " LastTradeDef ";" )
	if ( LastTradeDef ) {
		if ( match(LastTradeDef, /{[^}]*}/)) {
			SS=substr(LastTradeDef, RSTART, RLENGTH)
            #print Ticker " SS=" SS
			if (match(SS, /SIG=[^;]+;/)) Strategy = substr(SS, RSTART, RLENGTH-1); 
 			if (match(SS, /T=[^;}]+[;}]/)) { Target = strtonum (substr(SS, RSTART+length("T="), RLENGTH-1) );} 		
 			if (match(SS, /ConfT=[^;}]+[;}]/)) { ConfT = strtonum (substr(SS, RSTART+length("ConfT="), RLENGTH-1) );} 
 			if (match(SS, /NegT=[^;}]+[;}]/)) { NegT = strtonum (substr(SS, RSTART+length("NegT="), RLENGTH-1) );} 	
			if (match(SS, /Stop=[^;}]+[;}]/)) { Stop = strtonum (substr(SS, RSTART+length("Stop="), RLENGTH-1) );} 	
			if (match(SS, /Term=[^;}]+[;}]/)) { Term = strtonum (substr(SS, RSTART+length("Term="), RLENGTH-1) );} 	
			#Review Date
			if (match(LastTradeDef, /[0-9]{2}\/[0-9]{2}\/[0-9]{2}/))  { SS1=substr(LastTradeDef, RSTART, RLENGTH); split(SS1,arr,"/");  EntryDate = arr[1]"/"arr[2]"/20"arr[3]; } 
        }
		printf( "%s,%s,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%s,%d,,,%s,,,,,,,,\n",Ticker,EntryDate,EntryPrice,Target,ConfT,NegT,Stop,Stop,Strategy,Term,TradeDir);
	}
	else {
		printf( "%s,%s,%.2f,0,0,0,0,0,SIG=NO_TradeDef,%d,,,%s,,,,,,,,\n",Ticker,EntryDate,EntryPrice,Term,TradeDir);
	}
	Ticker = "";
	LastTradeDef = "";
}

BEGIN {
	print "Ticker,EntryDate,EntryPrice,Target,ConfTgt,NegTgt,HardStop,LossStop,Strategy,TermStop,TangentStop,TrailingStop,TradeDir,ExitDate,ExitPrice,ExitSignal,F17,F18,F19,F20";
	Ticker = "";
	LastTradeDef = "";
	#DEBUG=1
}

# Ticker 
$1 ~ /^[A-Z]+$/ { 
	dprint("processing "$1) ;
	if ( Ticker != $1 && Ticker != "") {
	# print previous ticker data
		printDarwinEntry() 
	}
	Ticker = $1   ;
	EntryPrice = $4   ;
	TradeDir="";
	if ( $3 == "Buy" ) TradeDir = "LONG";
	if ( $3 == "Short" ) TradeDir = "SHORT";
	
	# Defaults if TradeDef is missing 
	split($2,arr,"-");  EntryDate = arr[2]"/"arr[3]"/"arr[1]; # Buy Date	
	Strategy = "SIG=NO";
	Target=0;
	ConfT=0;
	NegT=0;
	Stop=0;
	Term=200;
}

/TradeDef=/ { 
	LastTradeDef = $0;
	#print LastTradeDef;
}
#{SIG=MFI HH/HL; T=2.1; ConfT=1.33; NegT=1; Stop=1; ExpBars=5}

#end of rows for this Ticker
/^$/ && ( Ticker )  { 
	printDarwinEntry() 
}

END  { if ( Ticker )
	printDarwinEntry() 
}

#Ticker,EntryDate,EntryPrice,Target,ConfTgt,NegTgt,HardStop,LossStop,Strategy,TermStop,TangentStop,TrailingStop,TradeDir,ExitDate,ExitPrice,ExitSignal,F17,F18,F19,F20
#GLP,09/26/2016,16.83,30,17,15,14.5,14,bought after breakout,100,,,LONG,,,,,,,

END {
}
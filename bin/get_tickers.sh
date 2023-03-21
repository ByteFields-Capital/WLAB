awk -F\; -v SECTION_NAME=$2 '  
	BEGIN {if (SECTION_NAME=="") DOIT="true"}
	DOIT && $1 ~ /^[A-Z]+$/ {print $1} 
	$1 ~ /SECTION[[:space:]]+BEGIN/ && $2 ~ SECTION_NAME {DOIT="true";}
	$1 ~ /SECTION[[:space:]]+END/ {DOIT="";}
	$1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {exit 1;}
	' $1
exit		
	$1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {exit 1;}
	$1 ~ /^[#]+[[:space:]]+SECTION_BEGIN[[:space:]]+::FwdLimitOrd[[:space:]]+/ {print "FOUND_"DOIT;DOIT="true";}
	$1 ~ /^[#]+[[:space:]]+SECTION_END[[:space:]]+::FwdLimitOrd[[:space:]]+/ {print "close_"DOIT;exit 1;}
 #  $0 ~ /SECTION/ && $0 ~ /BEGIN/ && $0 ~ /SECTION_NAME/ {print "FOUND_"DOIT;DOIT="true";}
BEGIN {SECTION_NAME=FwdLimitOrd}
| sort -u)  ; exit ; 
#SECTION_BEGIN::FwdLimitOrd
#SECTION_END::FwdLimitOrd
	$1 ~ /^[#]+[[:space:]]+SECTION_BEGIN[[:space:]]+::[^[:space:]]+[[:space:]]+/ {exit 1;}
#echo $(

function get_tickers () {
# print all  or only in section which name is a parameter e.g. $0 FwdLimitOrd
awk -F\; -v SECTION_NAME=$1 '  	
	DOIT && $1 ~ /^[A-Z]+$/ {print $1} 
	$1 ~ /SECTION[[:space:]]+BEGIN/ {print "FOUND_ "$2;DOIT="true";}
	$2 ~ SECTION_NAME {print "FOUND_1  "$2;DOIT="true";}
	' $0
}

function get_tickers_from_wlab() {
# print all or only one section which name is a parameter e.g. $0 FwdLimitOrd
# do Not process history
awk -F\; -v SECTION_NAME=$2 '  	
	BEGIN {if (SECTION_NAME=="") DOIT="true"}
	DOIT && $1 ~ /^[A-Z]+$/ {print $1} 
	$1 ~ /SECTION[[:space:]]+BEGIN/ && $2 ~ SECTION_NAME {DOIT="true";}
	$1 ~ /SECTION[[:space:]]+END/ {DOIT="";}
	$1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {exit 1;}
	' $1
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

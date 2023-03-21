
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


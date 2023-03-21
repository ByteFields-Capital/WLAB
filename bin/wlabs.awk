$1==TKR && $3=="Buy" { 
    N+=$5; S+=$5*$4; 
    dprint($0);
    dprint( "N+="$5"; S+="$5*$4);
    dprint( "N="N"; S="S);
} 
$1==TKR && $3=="Sell" { 
    N-=$5; S-=$5*$4; 
    dprint($0);
    dprint( "N-="$5"; S-="$5*$4);
    dprint( "N="N"; S="S);
}
$1 ~ /^[#]+[[:space:]]+HISTORY[[:space:]]+[#]+/ {nextfile}
END { if( S==0 || N==0 ) 
        print TKR" - No position";
    else
        dprint( "N="N"; S="S);
        # this prints  position cost REDUCED by profit .
        print TKR"("N")  EntryAVG @ "S/N" => "S " NOW @ "P" => " N*P
    }
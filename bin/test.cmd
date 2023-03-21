
set WLDIR=C:\Users\mpkmt_000\Desktop\BURSA\WlabPro
set WLDIR=C:\Users\mpkmt_000\Documents\Sync\WlabPro
set FOLIOS=fwd_test.wlab back_test.wlab watchlist.wlab

cd  %WLDIR%\_Trades

C:\bin\cygwin64\bin\gawk.exe  -F";" '{if ( $1=="%1" ) print $0 }' %FOLIOS%   > wlab.in

	TKR=$1
	sleep 12s
	curl -s "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=${TKR}&apikey=8E409AF7G8ZJZA3F&datatype=csv"  | tail -1

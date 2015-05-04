#!/bin/sh
#
#usage: ./insert.sh question-url
#

[ -z "$1" ] && {
	echo usage: $0 question-url

	exit 0
}

LEET_IDX=.leet.index

URL=`echo $1 |sed 's:/$::g'`
FILE="./src/`echo $URL |awk -F'/' '{print $NF}'`.c"
[ -f "$FILE" ] && {
	echo "$FILE is already exist."
	echo ""
	exit 0
}

wget --no-check-certificate -O - $URL 2>/dev/null > $LEET_IDX 
MOD=`cat $LEET_IDX |grep "<title>.*</title>"  | awk -F'[>|]' '{print $2}'`

#insert to README.md
echo "|[$MOD]($URL)|[C]($FILE)|`date +%F`|" >> ./README.md

echo "" >> $FILE
#insert author
TIME=`stat -c %z $FILE|awk '{print $1" "substr( $2, 0, 8) }'`
sed -i '1i\'"* Question : [$MOD] $URL" $FILE
sed -i '2i\'"* Author : wshell" $FILE
sed -i '3i\'"* Date : $TIME\n" $FILE

#insert descriptor
cat $LEET_IDX|w3m -dump -T text/html |sed -n  '/^Question.*Solution *$/,/^Show Tags$/p'| sed '/^Question.*Solution *$/d; /^Show Tags$/d' |sed '1d;$d'>> $FILE

sed -i "1i/*$(printf '%.0s*' {0..80}) \n* " $FILE 
sed -i "\$a $(printf '%.0s*' {0..80})*/\n"  $FILE

rm -f $LEET_IDX 

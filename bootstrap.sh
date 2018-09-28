#!/bin/bash
#
# Copyright Decheng Zhang
#
SCRIPT_FOLDER=~/.PNP.d
CACHE_FOLDER=~/Library/Caches/script
printHelp() {
    echo ""
}

installThirdPartyBinary(){
    
    osascript <<EOF || rc=$?
	 return "osascript Exist"
EOF
    if [ ! -z $rc ];then
	echo "Failure no osascript"
    fi
}
addingCachingFolder(){
    [ -d "$SCRIPT_FOLDER" ] || mkdir "$SCRIPT_FOLDER"
    [ -f "$CACHE_FOLDER/pnp" ] || touch $CACHE_FOLDER/pnp
     cat <<'_EOF_'> $SCRIPT_FOLDER/pnp.sh 
#!/bin/bash
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin
url=http://www.ontarioimmigration.ca/en/pnp/OI_PNPNEW.html
tempdir=~/Library/Caches/scripts
PERSONALEMAIL="dechengzhang@cmail.carleton.ca"
temp=$tempdir/pnp
if [ ! -d "$tempdir" ];then
    echo "Initialize Finish, Monitoring Start..."|terminal-notifier -title "Dont Panic"
    mkdir -p $tempdir
fi
if [[ $(date +"%T") = "10:00"* ]];then
    echo "I will always love you"|terminal-notifier -title "Don't Panic"
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


modified=$(curl -s --compressed  http://www.ontarioimmigration.ca/en/pnp/OI_PNPNEW.html ) || rc=$?
if [ ! -z $rc ];then
    modified=$(curl -s --compressed  http://www.ontarioimmigration.ca/en/pnp/OI_PNPNEW.html ) || rc=$?
    if [ ! -z $rc ]; then
	echo "NETWORK CONNECTION ERROR" | terminal-notifier -title 'Atten'
	exit 1
    fi
fi
modified=$(echo "$modified" | grep "$(date '+%B %-d, %Y')" | md5)
if [[ -f "$temp" && "$modified" != "$(head -1 $temp)" && "$modified" != "" ]];t\
hen
    modifiedDate=$(curl -s --compressed  http://www.ontarioimmigration.ca/en/pn\
p/OI_PNPNEW.html | egrep -o  -A2 '<p class=\"right\">.*$' | tr '\n' ' ' |sed 's\
/.*Last\ Modified: \(.*\)<.*>/\1/g')
    notimsg=$(sed '2q;d' $temp)"=>"$modifiedDate
    echo $notimsg|terminal-notifier  -title 'Atten' -open $url
    printf %s "$modified" > $temp
    printf \\n%s "$modifiedDate" >> $temp
    osascript <<-EOF 
tell application "Mail"
	tell (make new outgoing message)
		set subject to "PNP is changing"
		set content to "http://www.ontarioimmigration.ca/en/pnp/OI_PNPNEW.html"
		make new to recipient at end of to recipients with properties {address:"$PERSONALEMAIL"}
		send
	end tell
end tell
EOF
fi

_EOF_

chmod +x $SCRIPT_FOLDER/pnp.sh 
}
addingCronJob(){
    (crontab -l ; echo "*/3 10-17 * * 1-5 ~/.PNP.d/pnp.sh") | crontab -
}




##installThirdPartyBinary
addingCronJob
addingCachingFolder


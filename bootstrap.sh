#!/bin/bash
#
# Copyright Decheng Zhang
#
SCRIPT_FOLDER=~/.PNP.d.tmp
CACHE_FOLDER=~/Library/Caches/script
printHelp() {
    echo ""
}

installThirdPartyBinary(){
    brew install phantomjs || rc=$?
    if [ -z $rc ];then
	echo "Phantomjs Exist"
    elif [ -z $rc ] || [ $rc -ne 0 ]; then
	echo "Failure installing the phantomjs"
    fi
    brew install terminal-notifier || rc=$?
    if [ -z $rc ];then
	echo "terminal-notifier Exist"
    elif [ -z $rc ] || [ $rc -ne 0 ]; then
	echo "Failure installing the terminal-notifier"
    fi
    osascript <<EOF || rc=$?
	 return "osascript Exist"
EOF
    if [ ! -z $rc ];then
	echo "Failure no osascript"
    fi
}
addingCachingFolder(){
     [ -d "$SCRIPT_FOLDER" ] || mkdir "$SCRIPT_FOLDER"
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

modified=$(curl -s --compressed  http://www.ontarioimmigration.ca/en/pnp/OI_PNPNEW.html | egrep -o  -A2 '<p class=\"right\">.*$' | tr '\n' ' ' |sed 's/.*Last\ Modified: \(.*\)<.*>/\1/g')
if [[ -f "$temp" && "$modified" != "$(cat $temp)" && "$modified" != "" ]];then
    notimsg=$(cat $temp)"=>"$modified  
    echo $notimsg|terminal-notifier  -title 'Atten' -open $url
   
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
if [[ "$modified" != "" ]]; then
printf %s "$modified" > $temp
fi

_EOF_

     
}
addingCronJob(){
    (crontab -l ; echo "*/3 10-17 * * 1-5 ~/.PNP.d/pnp.sh") | crontab -
}




##installThirdPartyBinary
##addingCronJob
addingCachingFolder


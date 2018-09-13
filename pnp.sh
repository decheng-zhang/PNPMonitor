#!/bin/bash
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin
url=http://www.ontarioimmigration.ca/en/pnp/OI_PNPNEW.html
tempdir=~/Library/Caches/scripts
temp=$tempdir/pnp
if [ ! -d "$tempdir" ];then
    echo "Initialize Finish, Monitoring Start..."|terminal-notifier -title "Dont Panic"
mkdir -p $tempdir
fi
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


modified=$(phantomjs "$DIR/pnp.js"|grep -A2 'success'|xargs echo)
if [[ -f "$temp" && "$modified" != "$(cat $temp)" && "$modified" != "" ]];then
    notimsg=$(cat $temp)"=>"${modified#???????????????}  
    echo $notimsg|terminal-notifier  -title 'Atten' -open $url
    osascript "$DIR/email-notifier.scpt" 
#else
   # echo $modified|terminal-notifier -title 'Calm Down' -open $url
fi
if [[ "$modified" != "" ]]; then
printf %s "$modified" > $temp
fi

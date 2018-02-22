#!/bin/bash

function addtocrontab () {
        echo "Adding crontab - $2"
        local frequency=$1
        local command=$2
        local job="$frequency $command"
        cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
}
function addtocrontabroot () {
        echo "Adding crontab root- $2"
        local frequency=$1
        local command=$2
        local job="$frequency $command"
        cat <(fgrep -i -v "$command" <(sudo crontab -l)) <(echo "$job") | sudo crontab -
}

addtocrontab "0 0 * * *" "cd $HOME/server-build && /usr/bin/perl ./maintain_backup.pl > /tmp/maintain_backup.log 2>&1""
addtocrontab "* 1 * * *" "cd $HOME/server-build && /usr/bin/perl ./maintain_wordpress.pl > /tmp/maintain_wordpress.log 2>&1"
addtocrontabroot "* 2 * * 0" "cd $HOME/server-build && ./maintain_letsencrypt.sh > /tmp/maintain_letsencrypt.log >2&1"
addtocrontabroot "* 2 * * 6" "cd $HOME/server-build && ./maintain_os.sh > /tmp/maintain_os.log >2&1"

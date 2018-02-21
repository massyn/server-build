#!/bin/bash

function addtocrontab () {
        echo "Adding crontab - $2"
        local frequency=$1
        local command=$2
        local job="$frequency $command"
        cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
}

addtocrontab "0 0 * * *" "cd $HOME/server-build && /usr/bin/perl ./maintain_backup.pl > /tmp/maintain_backup.log 2>&1""
addtocrontab "* 1 * * *" "cd $HOME/server-build && /usr/bin/perl ./maintain_wordpress.pl > /tmp/maintain_wordpress.log 2>&1"

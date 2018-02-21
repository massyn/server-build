#!/bin/bash

function addtocrontab () {
        echo "Adding crontab - $2"
        local frequency=$1
        local command=$2
        local job="$frequency $command"
        cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
}

addtocrontab "0 0 * * *" "/usr/bin/perl $HOME/server-build/maintain_backup.pl"

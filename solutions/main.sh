#!/bin/bash
set -ou pipefail
set -o nounset

export URL_TO_TEST=$1
export BASE_PATH=$(pwd)

export SLACK_WEBHOOK_URL=$(yq e '.slack.webhook_url' config.yaml)
export THRESHOLD=$(yq e '.network.threshold' config.yaml)

IFS=$'\n\t'

trap ctrl_c INT

ctrl_c(){
    echo "ctrl+c received closing system"
    exit 1
}

cecho (){
    BLACK='\033[1;30m'
	RED='\033[1;31m'
	GREEN='\033[1;32m'
	YELLOW='\033[1;33m'
	BLUE='\033[1;34m'
	PURPLE='\033[1;35m'
	CYAN='\033[1;36m'
	WHITE='\033[1;37m'
	NC="\033[0m" # No Color

    printf "${!1}${2} ${NC}\n"
}

call_slack(){
    cecho "RED" "Request Routing to the Slack $1"
}

create_load(){

    regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'

    while true
    do
        if [[ $URL_TO_TEST =~ $regex ]]
        then 
            TIME_TO_RESPONSE=$(curl -w  "%{time_total}" --connect-timeout $THRESHOLD $URL_TO_TEST -o/dev/null)

            if [ "$?" -ne "0" ];
            then
                cecho "RED" "The request failed in threshold"
                call_slack $URL_TO_TEST
            else
                cecho "BLUE" "All clear ${TIME_TO_RESPONSE}"
            fi
        
        else
            cecho "RED" "Link not valid:: https://site.co"
            exit 1
        fi
    done

}

create_load
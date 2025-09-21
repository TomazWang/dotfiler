#!/bin/bash

# List all files, long format, colorized, permissions in octal
function all() {

    # $3 permissions
    # $6 user
    # $7 date
    # $8 time
    # $5 size

    arg=""
    while [ "$1" != "" ];do
        case $1 in
            -a | --all )
                arg="-a"
                ;;
            * )
                ;;
        esac
        shift
    done

   ll $arg "$@" | awk '
        {
            if($9 != "" && $9 != "." && $9 != ".."){
                MM=$6;
                dd=$7;
                tt=$8;
                size=$5;

                $1=$2=$3=$4=$5=$6=$7=$8=""

                rest=substr($0,9)

                split(rest,name,"->")

                printf("%4s %4s %6s %6s | %s\n", MM, dd, tt, size, name[1])
            }
        }'

}


# copy last command
function copyLastCmd(){

    last_cmd=$(history | tail -1 | awk '{$1=""; print$0;}' | sed 's/^[ \t]*//')
    echo $last_cmd | clipcopy
    echo "Copied: $last_cmd"
}



# ip address
function myip(){
    echo -n 'Public IP:'
    dig +short myip.opendns.com @resolver1.opendns.com
}

function localip(){
    echo -n 'Local IP:'
    ipconfig getifaddr en0
}

function ip(){
    localip
    myip
    m wifi status | awk '/SSID/' | tail -1 | sed -e 's/[\t ]//g;/^$/d'
}

# cd into whatever is the forefront Finder window.
function cdf(){
    cd "`osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)'`"
}
alias gotoFinder=cdf



# get absolute path for a file or dir
function abspath() {
    # generate absolute path from relative path
    # $1     : relative filename
    # return : absolute path
    if [ -d "$1" ]; then
        # dir
        (cd "$1"; pwd)
    elif [ -f "$1" ]; then
        # file
        if [[ $1 = /* ]]; then
            echo "$1"
        elif [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}


# depends on yank: https://github.com/mptre/yank
# depends on fzf: https://github.com/junegunn/fzf
function hiscmd(){
    if [ "$#" -gt 0 ]; then
        history | sed -E 's/^ *[0-9]+ +//p' | grep "$1" | fzf | yank -l
    else
        history | sed -nE 's/^ *[0-9]+ +//p' | fzf | yank -l
    fi
}

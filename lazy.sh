#!/bin/bash
# lazy.sh
# Licensed under "Buy me a beer, you cheap cunt" 2020. All rights reserved

##########################################################################
################################## Lazy ##################################
##########################################################################
# hack shell script because fuck doing this shit everytime I start a new Kali VM
# (or any Debian based VM with minimal changes *cough* Ubuntu).
##########################################################################

# globals
script=lazy.sh
version=0.1
year=2020
creator=dupesnduds
wally="$(dirname "$(realpath "$0")")"

debug=true
cleanup=true

##################################
# go manual install
goman=true
goman_binary=go1.14.2.linux-amd64.tar.gz
goman_checksum=6272d6e940ecb71ea5636ddb5fab3933e087c1356173c61f4a803895e947ebb3

#
go_packages=go-packages.csv

##########################################################################
## welcome *evil laugh*
# you've got top enter something, to get something ~ dupesduds
[ $# -eq 0 ] &&
    {
        echo
        echo "$script $version"
        echo "Copyright $year $developer. All rights reserved."
        echo
        echo "Usage: $0 -h"
        echo
        exit 1
    }

##########################################################################
## utilities
# duh
directory_check() {
    if [ -d "$1" ]; then
        echo "$1 found..."
        return 0
    fi

    return 1
}
# args root > new directory name
create_directory() {
    sudo mkdir -p "$1/$2/"

    # TODO: make this more flexible
    sudo chown kali:kali "$1/$2/"
}
# checksum check
checksum_check() {
    dak=$(sha256sum $1 | cut -d' ' -f1)
    if [ $dak != $2 ]; then
        # abort
        echo "Checksum mismatch. Aborting."
        exit 1
    fi
}
# the joys of windoze
remove_carriage_returns() {
    # check for arguments
    if [ "$1" == "" ] || [ $# -gt 1 ]; then
        echo
        echo "Usage: $script -r | --remove-carriage  [file]"
        echo "e.g. $script -r windows.txt"
        echo
        exit 1
    else
        sed -i 's/\r//g' $1
        echo
        echo "Stripped $1 of windoze \r\n line endings"
        echo
    fi
}
# fix missing deb do-dads
fix_deb_do_dads() {
    cd /tmp/
    wget $1
    sudo dpkg -i /tmp/$1
    sudo apt install -f
    rm $1
}
# fix temp share with host C:\temp to /home/kali/win
fix_vbox_share_permission() {
    # check for arguments
    if [ "$1" == "" ] || [ $# -gt 1 ]; then
        echo
        echo "Usage: $script -f | --fix-share [share][local]"
        echo "e.g. $script -f /path/from/share/ /root/path/for/instalation/"
        echo
        exit 1
    else
        sudo mount -t vboxsf -o uid=$UID,gid=$(id -g) $1 $2
    fi
}
# get go manually
get_manual_go() {
    echo "Manually installing Go..."
    b=~/.bashrc

    # download, install, then remove go
    cd "/tmp"

    if $debug; then
        cp ~/win/$goman_binary /tmp
    else
        # wget -c "https://dl.google.com/go/$goman_binary"
        sudo curl -O https://storage.googleapis.com/golang/$goman_binary
    fi

    if $clean; then
        sudo rm -rf /usr/local/go
        sudo rm $GOPATH
    fi

    sudo tar -zxvf /tmp/$goman_binary
    sudo mv go /usr/local
    rm -rf $goman_binary

    # append go to path
    echo -e "export GOROOT=/usr/local/go\nexport PATH=$PATH:/usr/local/go/bin" >>$b
}

##########################################################################
## packages
# download once, then install on new Kali VM from host share
# some word lists
get_wordlists() {
    p=/usr/share/wordlists

    if $cleanup; then
        sudo rm -rf $p/gist
    fi

    create_directory $p gist
    wget https://gist.githubusercontent.com/nullenc0de/96fb9e934fc16415fbda2f83f08b28e7/raw/146f367110973250785ced348455dc5173842ee4/content_discovery_nullenc0de.txt -O $p/gist/content_discovery_nullenc0de.txt
    wget https://gist.githubusercontent.com/nullenc0de/538bc891f44b6e8734ddc6e151390015/raw/a6cb6c7f4fcb4b70ee8f27977886586190bfba3d/passwords.txt -O $p/gist/passwords.txt
    wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt -O $p/gist/all.txt
    wget https://gist.githubusercontent.com/nullenc0de/9cb36260207924f8e1787279a05eb773/raw/0197d33c073a04933c5c1e2c41f447d74d2e435b/params.txt -O $p/gist/params.txt
}

# this is purely a personal preference, hence not included in
# a clean install.
local_burp_suite_install() {
    # check for arguments
    if [ "$1" == "" ] || [ $# -gt 1 ]; then
        echo
        echo "Usage: $script -b | --burp [local]"
        echo "e.g. $script -b /root/path/for/instalation/"
        echo
        exit 1
    fi

    # create opt folder if it doesnt exist
    # safe guard to prevent unnecessarily running this function.
    if directory_check "$2"; then
        echo "So... the folder exists. Therefore we've already installed Burpsuite."
        echo "Bye."
        exit 1
    else
        # remove currently installed version if it exists
        # TODO: keep things clean?

        create_directory $1 "burpsuite"

        # TODO: fix
        cp ~/win/burpsuite_community_linux_v2020_4.sh $1/burpsuite

        # install latest burp from windows share directory
        cd "$1/burpsuite/"
        ./burpsuite_community_linux_v2020_4.sh
    fi
}

# If the VM shits itself we can just start from scratch
clean_install() {
    if [ "$1" == "" ] || [ $# -gt 1 ]; then
        echo
        echo "Usage: $script -c | --clean-install [local]"
        echo "e.g. $script -c /root/path/for/instalation/"
        echo
        exit 1
    else
        if $cleanup; then
            sudo rm -rf /var/lib/apt/lists/*

        fi

        # update system's bits 'n pieces
        sudo apt update && sudo apt upgrade -y

        # TODO: remove
        if $debug; then
            # fix any problems
            sudo apt --fix-broken install -y
            sudo dpkg --configure -a
            sudo apt autoremove -y
            #sudo apt dist-upgrade -y

            fix_deb_do_dads http://ftp.debian.org/debian/pool/main/p/python3.7/libpython3.7_3.7.7-1+b1_amd64.deb
        fi

        get_wordlists

        # TODO: remove
        if $debug; then
            # NOTE: hakrawler fix
            wget https://github.com/gocolly/colly/archive/v2.0.0.zip

            sudo rm -rf colly-2.0.0/
            unzip v2.0.0.zip

            sudo rm -rf $1/colly-2.0.0/

            create_directory $1 colly
            sudo mv colly-2.0.0/ $1/
            export GOPATH=$1/colly-2.0.0/
            cd $1/colly-2.0.0/
            go install
        fi

        # install go packages'
        while IFS=$' \t\n\r', read -r one two three; do
            export GOPATH="$1/$one"

            if $clean; then
                sudo rm -rf $1/$one
            fi

            create_directory $1 $one

            go get -u "$two"
            echo "$1/$three"

            if $debug; then
                sudo rm -rf /usr/local/bin/$one
            fi

            sudo ln -s "$1/$three" "/usr/local/bin/$one"
        done <$wally/$go_packages
    fi
}

##########################################################################
## main
# details
case $1 in
-h | --help)
    echo
    echo "$script $version"
    echo "Copyright $year $developer. All rights reserved."
    echo
    echo "Usage: $0 OPTION"
    echo
    echo "NOTE: install GO first !!!"
    echo "-g [local]            --go-install [local]            Go needs to be installed first. Then 'source ~/.bashrc'"
    echo "-c [local]            --clean-install [local]         Rebuild VM with usual packages stored at local"
    echo
    echo "-f [share][local]     --fix-share [share][local]      Fix Virtualbox share permissions"
    echo
    echo "NOTE:  utilities"
    echo "-b [share][local]     --burp [share][local]           Install burpsuite from local windows share"
    echo "-r [file]             --remove-carriage [file]        Remove windows carriage returns from file"
    echo "-d [url]              --debs [url]                    Download/Install manually debs"
    echo
    ;;
-g | --go-install)
    get_manual_go $2
    ;;
-c | --clean-install)
    clean_install $2
    ;;
-f | --fix-share)
    fix_vbox_share_permission $2 $3
    ;;
-b | --burp)
    local_burp_suite_install $2 $3
    ;;
-r | --remove-carriage)
    remove_carriage_returns $2
    ;;
-d | --debs)
    fix_deb_do_dads $2
    ;;
*)
    echo
    echo "Ummm, no. Bye."
    echo
    exit 1
    ;;
esac

#!/bin/bash
## !!! We need vzlist
set -e

## Pre-check
if [ ! -x /usr/sbin/vzlist ];then
	echo "Error Please install vzlist first"
	exit 1
fi

if [ ! -x /usr/sbin/vzctl ];then
	echo "Error Please install vzctl first"
	exit 1
fi

## PATH for centos
VZCONF_PATH="/etc/vz/conf"
VZPRIVATE_PATH="/vz/private"
VZROOT_PATH="/vz/root"

UNMOUNT="0"
SHOWOPTION="-f \"Unmount old CTID\"\n -h \"Show help\" \n"

while [ $# -gt 0 ];
do
    case "$1" in
        -h) /usr/bin/printf "usage: vzmove [OPTION] OLDCTID NEWCTID\n $SHOWOPTION";exit 1;;
        -f) UNMOUNT="1";;
        -*) /usr/bin/printf "Please use \"-h\"\n" ;exit 1;;
        *)
            OLDCTID="$1"
            NEWCTID="$2"
            # Test if we have two argument (old and new CTID)
            if [ $# -eq 2 ];then
                ## Test if we use correct numeric CTID
                if [[ $OLDCTID == ?(-|+)+([0-9]) && $NEWCTID == ?(+|-)+([0-9]) ]];then
                    # Test if the old CTID is correctly stopped
                    if [[ $(/usr/sbin/vzlist -o status $OLDCTID | grep "stopped") || $UNMOUNT == "1" ]]; then
                        if [[ $UNMOUNT == "1" ]];then
                            vzctl stop $OLDCTID
                        fi
                        # Test if the new CTID is available
                        if [[ $(/usr/sbin/vzlist $NEWCTID) -ne "1" ]];then
                            #echo "Moving the config file of VZ $OLDCTID to VZ $NEWCTID"
                            /bin/mv -v "$VZCONF_PATH"/"$OLDCTID".conf "$VZCONF_PATH"/"$NEWCTID".conf

                            #echo "Moving the private content of VZ $OLDCTID to VZ $NEWCTID"
                            /bin/mv -v "$VZPRIVATE_PATH"/"$OLDCTID" "$VZPRIVATE_PATH"/"$NEWCTID"

                            #echo "Moving the root content of VZ $OLDCTID to VZ $NEWCTID"
                            /bin/mv -v "$VZROOT_PATH"/"$OLDCTID" "$VZROOT_PATH"/"$NEWCTID"
                        else
                            /bin/echo "ERROR: New CTID unavaible"
                            exit
                        fi
                    else
                        /bin/echo "ERROR: Please stop $OLDCTID first or use -f option"
                        exit
                    fi
                else
                    /bin/echo "ERROR: Please use number for old and new CTID"
                fi
                break;
            else
                /bin/echo "ERROR: Number of argument doesn't match"
                exit 1;
            fi;
            ;;
    esac
    shift
done


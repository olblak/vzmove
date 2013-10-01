#!/bin/bash
## !!! We need vzlist
set -e
vflag=off
force="0"
SHOWOPTION="-f \"Unmount old CTID\"\n -h \"Show help\" \n -v \"Activate verbose mode\"\n"

while [ $# -gt 0 ];
do
    case "$1" in
        -v) vflag=on;;
        -h) printf "usage: vzmove [OPTION] OLDCTID NEWCTID\n $SHOWOPTION";exit 1;;
        -f) force="1";;
        -*) printf "Please use \"-h\"\n" ;exit 1;;
        *)
            OLDCTID="$1"
            NEWCTID="$2"
            # Test if we have two argument (old and new CTID)
            if [ $# -eq 2 ];then
                ## Test if we use correct numeric CTID
                if [[ $OLDCTID == ?(-|+)+([0-9]) && $NEWCTID == ?(+|-)+([0-9]) ]];then
                    # Test if the old CTID is correctly stopped
                    if [[ $(vzlist -o status $OLDCTID | grep "stopped") || $force == "1" ]]; then
                        if [[ $force == "1" ]];then
                            vzctl stop $OLDCTID
                        fi
                        # Test if the new CTID is available
                        if [[ $(vzlist $NEWCTID) -ne "1" ]];then
                            #echo "Moving the config file of VZ $OLDCTID to VZ $NEWCTID"
                            mv -v /etc/vz/conf/$OLDCTID.conf /etc/vz/conf/$NEWCTID.conf

                            #echo "Moving the private content of VZ $OLDCTID to VZ $NEWCTID"
                            mv -v /vz/private/$OLDCTID /vz/private/$NEWCTID

                            #echo "Moving the root content of VZ $OLDCTID to VZ $NEWCTID"
                            mv -v /vz/root/$OLDCTID /vz/root/$NEWCTID
                        else
                            echo "ERROR: New CTID unavaible"
                            exit
                        fi
                    else
                        echo "ERROR: Please stop $OLDCTID first or use -f option"
                        exit
                    fi
                else
                    echo "ERROR: Please use number for old and new CTID"
                fi
                break;
            else
                echo "ERROR: Number of argument doesn't match"
                exit 1;
            fi;
            ;;
    esac
    shift
done


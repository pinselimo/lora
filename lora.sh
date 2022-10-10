#!/usr/bin/env sh
readonly HELP_TEXT="
Welcome to LORA - the LibreOffice Recovery Assistant

Usage: lora [OPTION]...
Edit the recovery registry of libreoffice and open files listed there.

Options:
        -h, --help
                Shows this help message and exits.
        -n, --noprompt
                Suppresses libreoffice's recovery dialogue.
                Has no effect on recovering unsaved files with --unsaved.
        -d, --delete
                Delete the recovery list entries.
                Combine this option with --noprompt to leave the recovery process entirely to LORA.
        -f, --forget
                Do not open files listed for recovery.
                In combination with --delete this can be used to just clear the recovery list.
        -u, --unsaved
                Restore previously unsaved files as well.
                This option requires the recovery dialogue of libreoffice.
        -b, --backup
                Force backup of the libreoffice registrymodifications.
                A backup is automatically created if the registrymodifications are altered by the --forget option.
                Use --backup to overwrite any previous backups.
        -r, --restore
                Restore libreoffice registrymodifications from backup file.
        -c, --clean
                Remove all backup files and directories created by LORA.
        -v, --verbose
                Prints log during process.

Website:
        https://github.com/pinselimo/lora
"
set -o errexit -o pipefail -o noclobber -o nounset

readonly REGISTRYMOD=~/.config/libreoffice/4/user/registrymodifications.xcu
readonly CONFIGDIR=~/.config/lora
readonly BACKUP="$CONFIGDIR/registrymodifications.xcu"
readonly LONGOPTS=help,delete,forget,noprompt,backup,verbose,unsaved,restore,clean
readonly OPTIONS=hdfnbvurc
! readonly PARSED=$(getopt --options="$OPTIONS" --longoptions="$LONGOPTS" --name "$0" -- "$@")

function ctrl_c {
        echo "** [CTRL-C] Aborted."
}

function backup {
        cp "$REGISTRYMOD" "$BACKUP"
}

function restore {
        local tmp=$(<"$REGISTRYMOD")
        cp "$BACKUP" "$REGISTRYMOD"
        echo "$tmp" > "$BACKUP"
}

function empty_recoverylist {
        if [ $(xq ' .[].item[]
                  | select(."@oor:path" == "/org.openoffice.Office.Recovery/RecoveryList")
                  ' "$REGISTRYMOD") ]
        then
                local tmp=$(xq --xml-dtd -x '."oor:items".item
                             = ([ ."oor:items".item[]
                                | select(."@oor:path" == "/org.openoffice.Office.Recovery/RecoveryList")
                                = [] ])' "$REGISTRYMOD")
                printf "%s" "$tmp" >| "$REGISTRYMOD"
        else
                echo "Nothing to delete. Exiting."
                exit 1
        fi
}

function cleanup {
        if [ -d "$CONFIGDIR" ]
        then
                rm -r "$CONFIGDIR"
        fi
}

trap ctrl_c INT

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    exit 2 #  getopt has complained about wrong arguments to stdout
fi

eval set -- "$PARSED" # read getopt’s output this way to handle the quoting right:

addargs="" d=n f=n r=n b=n u=n
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -h|--help)
            echo "$HELP_TEXT"
            exit 0
            ;;
        -n|--noprompt)
            addargs="$addargs --norestore"
            shift
            ;;
        -d|--delete)
            d=y
            shift
            ;;
        -f|--forget)
            f=y
            shift
            ;;
        -v|--verbose)
            set -o verbose -o xtrace
            shift
            ;;
        -b|--backup)
            b=y
            shift
            ;;
        -u|--unsaved)
            u=y
            shift
            ;;
        -r|--restore)
            r=y
            shift
            ;;
        -c|--clean)
            cleanup
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            exit 3
            ;;
    esac
done

# Initial invocation
if [ ! -e "$CONFIGDIR" ]
then
        mkdir "$CONFIGDIR"
        backup
fi

# Restore backup
if [ "$r" = "y" ]; then restore; else
        # Backup registry
        if [ "$b" = "y" ]; then backup; fi
fi

if [ ! $(pgrep -x "libreoffice" > /dev/null) ] && [ "$f" = "n" ]
then
        readonly URLS=$(xq ' .[].item[]
                            | select(."@oor:path" == "/org.openoffice.Office.Recovery/RecoveryList")
                            | .node.prop
                            | select(. != null)
                            | map(select(."@oor:name" == "OriginalURL"))
                            | .[].value
                            ' "$REGISTRYMOD")
        for url in "$URLS"; do
                if [ "$url" ];
                then
                        echo "Opening libreoffice with:" "$*" "$addargs" "$url"
                        if [ "$url" = "null" ]
                        then if [ "$u" = "y" ]; then libreoffice "$*"; fi
                        else
                             libreoffice "$*" "$addargs" $(sed 's/[""]//g;s/file:\/\///g' <<< "$url")
                        fi
                fi
        done
fi

if [ "$d" = "y" ]
then
     # Backup registry
     if [ ! -e "$BACKUP" ]; then backup; fi
     empty_recoverylist
fi

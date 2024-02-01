#!/bin/bash -l

# export LOGDIR=/path/to/logfiles
# export DATE=`date +"%Y%m%d"`
# export DATETIME=`date +"%Y%m%d_%H%M%S"`
# NO_JOB_LOGGING="false"

ScriptName=$(basename $0)
# Job=`basename $0 .sh`"_whatever_I_want" # Add _whatever_I_want after basename
Job=$(basename $0 .sh)
JobClass=$(basename $0 .sh)

colblk='\033[0;30m' # Black - Regular
colred='\033[0;31m' # Red
colgrn='\033[0;32m' # Green
colora='\033[0;33m' # Brown/Orange
colblu='\033[0;34m' # Blue
colpur='\033[0;35m' # Purple
colcya='\033[0;36m' # Cyan
collgr='\033[0;36m' # Light Gray
colwht='\033[0;97m' # White
colrst='\033[0m'    # Text Reset

verbosity=4

### verbosity levels
silent_lvl=0
crt_lvl=1
err_lvl=2
wrn_lvl=3
ntf_lvl=4
inf_lvl=5
dbg_lvl=6

## esilent prints output even in silent mode
function esilent ()  { verb_lvl=$silent_lvl elog "$@" ;}
function enotify ()  { verb_lvl=$ntf_lvl elog "$@" ;}
function eok ()      { verb_lvl=$ntf_lvl elog "${colgrn}SUCCESS${colrst} - $@" ;}
function ewarn ()    { verb_lvl=$wrn_lvl elog "${colora}WARNING${colrst} - $@" ;}
function einfo ()    { verb_lvl=$inf_lvl elog "${collgr}INFO${colrst} - $@" ;}
function edebug ()   { verb_lvl=$dbg_lvl elog "${colcya}DEBUG${colrst} - $@" ;}
function eerror ()   { verb_lvl=$err_lvl elog "${colred}ERROR${colrst} - $@" ;}
function ecrit ()    { verb_lvl=$crt_lvl elog "${colpur}FATAL${colrst} - $@" ;}
function edumpvar () { for var in $@ ; do edebug "$var=${!var}" ; done }
function elog() {
        if [ $verbosity -ge $verb_lvl ]; then
                datestring=$(date +"%Y-%m-%d %H:%M:%S")
                echo -e "$datestring - $@"
        fi
}

function Log_Open() {
        if [ $NO_JOB_LOGGING ] ; then
                einfo "Not logging to a logfile because -Z option specified." #(*)
        else
                [[ -d $LOGDIR/$JobClass ]] || mkdir -p $LOGDIR/$JobClass
                Pipe=${LOGDIR}/$JobClass/${Job}_${DATETIME}.pipe
                mkfifo -m 700 $Pipe
                LOGFILE=${LOGDIR}/$JobClass/${Job}_${DATETIME}.log
                exec 3>&1
                tee ${LOGFILE} <$Pipe >&3 &
                teepid=$!
                exec 1>$Pipe
                PIPE_OPENED=1
                enotify Logging to $LOGFILE  # (*)
                [ $SUDO_USER ] && enotify "Sudo user: $SUDO_USER" #(*)
        fi
}

function Log_Close() {
        if [ ${PIPE_OPENED} ] ; then
                exec 1<&3
                sleep 0.2
                ps --pid $teepid >/dev/null
                if [ $? -eq 0 ] ; then
                        # a wait $teepid whould be better but some
                        # commands leave file descriptors open
                        sleep 1
                        kill  $teepid
                fi
                rm $Pipe
                unset PIPE_OPENED
        fi
}


OPTIND=1
while getopts ":sVGZ" opt ; do
# shellcheck disable=SC2220
        case $opt in
        s)
                verbosity=$silent_lvl
                edebug "-s specified: Silent mode"
                ;;
        V)
                verbosity=$inf_lvl
                edebug "-V specified: Verbose mode"
                ;;
        G)
                verbosity=$dbg_lvl
                edebug "-G specified: Debug mode"
                ;;
        Z)
                NO_JOB_LOGGING="true"
                ;;
        esac
done

# Options for logging
# ewarn "this is a warning"
# eerror "this is an error"
# einfo "this is an information"
# edebug "debugging"
# ecrit "CRITICAL MESSAGE!"
# edumpvar HOSTNAME
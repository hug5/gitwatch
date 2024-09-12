#!/usr/bin/bash
# // 2024-09-09 Mon 14:07
set -e
# The set -e option instructs the shell to exit immediately if any command or pipeline returns a non-zero exit status, which usually indicates an error or failure.


declare -i INTERVAL=3
  # in seconds; sleep interval time; eg 3 seconds
declare -i PING_EVERY=10
  # In minutes; Interval to ping remote; eg every 5 minutes;
  # debian sudo timeout should be 15min
declare -i N_COUNTER=0
  # N counter;
declare WINDOW=''
  # default unset; active window
declare PANE=0
  # 0/top pane by default;
declare -i PING_TIME=0


# custom bash commands here:
function _do_something() {

    git add --all
    # git commit --amend --allow-empty --no-edit
      # --allow-empty may be necessary if you make a change; commit/push;
      # then reverse that exact change and want to commit/push;
    git commit --amend --no-edit
    git push --force
    # tmux send-keys -t top "git pull --rebase" enter
    # tmux send-keys -t top "url" enter
    tmux send-keys -t ${WINDOW}.${PANE} "git pull --rebase" enter
    tmux send-keys -t ${WINDOW}.${PANE} "url" enter
}


function _show_help() {
cat << EOF
NAME
    Gitwatch: Watch git files for changes and then do something.

DESCRIPTION
    Gitwatch can run your custom bash commands when git
    files change. Specifically, it is designed to add,
    commit, and push changes to your git repo; and
    then pull git changes from your remote server.

    For example, you would SSH into your remote in
    pane 0, and run gitwatch in a separate pane. When
    git changes are detected, gitwatch will commit,
    push and then pull from your remote in pane 0.

    Gitwatch solves the labor of adding, commiting, and
    pulling your changes manually. You can work on your
    git project locally and update your remote
    automatically.

    Pings remote server every 10min. to keep sudo alive.
    Requires Tmux.


EOF
_show_usage
}

function _show_usage() {
cat << EOF
USAGE
    $ gitwatch [-w W] [-p PANE] [-i INTERVAL]

EXAMPLE
    $ gitwatch
      # Use default settings: watch 3 second intervals; pull remote from pane 0 in current active window.
    $ gitwatch -w 2 -p 0 -i 5
      # set window to 2; remote pane to 0; interval at 5 seconds
    $ gitwatch -w vps -p 2
      # set window to vps; remote pane to 2; interval at default, 3 seconds

FLAGS
    -w WINDOW     Tmux window, denoted by name or number.
    -p PANE       Tmux pane of your remote, denoted by number.
    -i INTERVAL   Sleep interval between checks in seconds.
    -h            This help.
EOF
}


function _calc_ping_time() {

    PING_TIME=$(( 60 * $PING_EVERY / $INTERVAL ))
    # PING_TIME=$(( 60 / $INTERVAL * $PING_EVERY ))
      # lsp says this order makes result more precise
      # How many N second loops are required to get to PING_EVERY in minutes?
      # Given N (in seconds), PING_EVERY (in minutes), how many counter loops it takes to achieve PING_EVERY
      # PING_TIME=$((60/$N * $PING_EVERY ))
}


# Check flags:
function _check_flags() {
    local OPTIND                               # Make this a local; is the index of the next argument index, not current;
    local regex_isa_num='^[0-9]+$'             # Regex: match whole numbers only;

    while getopts ":hw:p:i:" OPTIONS; do       # Loop: Get the next option;
        case "${OPTIONS}" in

          w)
            WINDOW="${OPTARG}"
            ;;
          p)
            PANE="${OPTARG}"
            if [[ $PANE -lt 0 || ! "$PANE" =~ $regex_isa_num ]]; then
                echo "Error: -p should be an integer >= 0."
                _show_usage; exit;
            fi

            ;;
          i)
            INTERVAL="${OPTARG}"
            if [[ $INTERVAL -lt 1 || ! "$INTERVAL" =~ $regex_isa_num ]]; then
                echo "Error: -i should be an integer > 0."
                _show_usage; exit;
            fi
            ;;
          h)
            _show_help; exit;
            ;;
          :)                        # If flag has expected argument omitted;
            echo "Error: -"${OPTARG}" requires an argument."
            _show_usage; exit;
            ;;

          # \?)
          *)                        # If unknown (any other) option:
            echo "Error: Unknown option."
            _show_usage; exit;
            ;;
        esac
    done
}


function _begin_watch() {

    while true; do

        GRESULT=$(git status -s)
          # get git status; if no changes, then blank;

        if [[ -n $GRESULT ]]; then

            N_COUNTER=0  # Reset N_COUNTER
            # echo "Git changed ⚡️";
            # echo "Git changed ⭐";
            echo "☡  Git changed";
            _do_something

        else
            echo -n ". ";
            (( N_COUNTER++ ))
            if [[ "$N_COUNTER" -gt "$PING_TIME" ]]; then
                # tmux send-keys -t 0 "sudo echo ping" enter
                tmux send-keys -t ${WINDOW}.${PANE} "sudo echo ping" enter
                echo -n "ping remote "
                echo -n "$(date +%M) ";
                N_COUNTER=0
            fi
        fi
        sleep $INTERVAL
    done
}


_check_flags "$@"
_calc_ping_time

# echo $PING_EVERY
# echo $PANE
# echo $INTERVAL
# echo $PING_TIME
# exit

tmux send-keys -t ${WINDOW}.${PANE} "# Gitwatch Ready" enter

git status
echo -n "Watching ${INTERVAL}s "
_begin_watch




#------------------------------------------------------

## TODO
  # Enable custom time; eg: $ gitwatch 4
  # flags to do ca or cm commits; but since this is a monitor, that could have limited usefulness;
  # set timer with flag
  # Could put the command to run in a config file; but that might be overcomplicating a simple script
  # Every so often run a command in pane 0 in order to keep the "sudo" status alive;

  # Flag for specific functions:
    # -p : to run remote pull from remote server
    # But again, if you don't want this, why would you be running this script??
    # You're running this because you want to add amend, commit, push and pull;

#------------------------------------------------------

## Notes
  # Was originally trying to do this using the watch command;
  # But was having trying to get it to run the inline bash command; and or run a function within bash, which it can't do;
  # then realized that I can just use sleep and do a loop instead!

  # $(watch -tn1 -x check_git()

  # $(watch -tn1 -x echo "hello")
  # result=$(echo hello); \
  # watch -tn1 \
  # result="hello"; \
  # if [[ -n "$result" ]]; then \
  #     echo "git different"; \
  # else \
  #     echo "git same"; \
  # fi


  #----------------




    # $ tmux send-keys -t 1.0 "url" Enter


    # tmux send-keys -t 0 "git pull --rebase" enter
    # tmux send-keys -t 0 "url" enter

    # The problemwith this tmux send-keys command is that it sends to pane zero of the active window; if you switch windows, it will send the command to pane 0 of that active window; not ideal!
    #

#    echo -n "Git repo updated | ";
#    echo $(date +%H:%M:%S);

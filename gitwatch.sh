#!/usr/bin/bash
# // 2024-09-09 Mon 14:07
set -e
# The set -e option instructs the shell to exit immediately if any command or pipeline returns a non-zero exit status, which usually indicates an error or failure.

# ---------------------------------------------------------------

declare -i INTERVAL=3
  # in seconds; sleep interval time; eg 3 seconds
declare -i COMMAND_EVERY=0
  # In minutes; Interval to run custom command;
  # If <= 0, then it's turned off;
declare -i N_COUNTER=0
  # N counter;
declare WINDOW=''
  # default unset; active window
declare PANE=0
  # 0/top pane by default;
declare -i COMMAND_TIME=0


# ---------------------------------------------------------------

## custom bash commands here on git change:
function do_something() {

    # sass options:
      # https://sass-lang.com/documentation/cli/dart-sass/
      # sass --w --style=compressed style.container.scss style.min2.css
      # sass --watch ---poll --style=compressed style.container.scss style.min2.css
      # --no-source-map
      # --update
        # compile stylesheets whose dependencies have been modified more recently than the corresponding CSS file was generated
      # --embed-sources
        # embed the entire contents of the Sass files that contributed to the generated CSS in the source map;
        # this creates a surprisingly very large source file!
      # --embed-source-map
        # embed the contents of the source map file in the generated CSS
        # Thise creates a process css file that is the original + source file; which is only marginally larger;

    local SCSS1="jug/www/static/scss/style.container.scss"
    local SCSS2="jug/www/static/css/style.min2.css"

    sass --update --no-source-map --style=compressed "$SCSS1" "$SCSS2"


    # local action:
    git add --all
    # git commit --amend --allow-empty --no-edit
      # --allow-empty may be necessary if you make a change; commit/push;
      # then reverse that exact change and want to commit/push;
    git commit --amend --no-edit
    git push --force

    # remote action:
    # tmux send-keys -t top "git pull --rebase" enter
    # tmux send-keys -t top "url" enter
    tmux send-keys -t ${WINDOW}.${PANE} "git pull --rebase" enter
    tmux send-keys -t ${WINDOW}.${PANE} "url" enter
    # Delete the scss folder
    tmux send-keys -t ${WINDOW}.${PANE} "rm jug/www/static/scss/*" enter

    announce_remote_ready
}

## Custom command every N minutes
function run_custom_command() {
    # tmux send-keys -t ${WINDOW}.${PANE} "sudo echo ping" enter
    # echo -n "ping remote "
    echo -n "🌀$(date +%H:%M) "
}


# ---------------------------------------------------------------

function show_help() {
cat << EOF
NAME
    Gitwatch: Watch git files for changes and then do something.

DESCRIPTION

    Gitwatch can run custom bash commands when git
    files change. Specifically, it is designed to add,
    commit, and push changes to your git repo; and
    then pull git changes from your remote server.

    This would typically require 2 active panes running
    Tmux.

    For example, you would SSH into your remote in
    pane 0, and run gitwatch in a separate pane. When
    git changes are detected, gitwatch will commit,
    push and then pull from your remote in pane 0.

    Gitwatch solves the labor of adding, commiting, and
    pulling your changes manually. You can work on your
    git project locally and update your remote
    automatically.

    Optionally, can also run a command every N minutes.
    You can use to this feature to keep sudo active on
    the remote or for any other custom activities.

    Again, this script typically works in Tmux,
    assuming you want to run commands in two console
    windows.

EOF
show_usage
}

function show_usage() {
cat << EOF
USAGE
    $ gitwatch [-w W] [-p PANE] [-i INTERVAL] [-c Minutes]

EXAMPLE
    $ gitwatch
      # Use default settings: watch 3 second intervals; pull remote from pane 0 in current active window.
    $ gitwatch -w 2 -p 0 -i 5
      # set window to 2; remote pane to 0; interval at 5 seconds.
    $ gitwatch -w vps -p 2
      # set window to vps; remote pane to 2; interval at default, 3 seconds.
    $ gitwatch -w 1 -p 0 -c 7
      # Set window to 1; remote pane to 0; and run custom command every 7 minutes.

FLAGS
    -w WINDOW     Tmux window, denoted by name or number.
    -p PANE       Tmux pane of your remote, denoted by number.
    -i N          Number > 0; Sleep interval between checks in seconds.
    -c N          Number > 0; Run custom command ever N minutes.
    -h            This help.
EOF
}

# ---------------------------------------------------------------


function calc_command_time() {

    COMMAND_TIME=$(( 60 * $COMMAND_EVERY / $INTERVAL ))
    # COMMAND_TIME=$(( 60 / $INTERVAL * $COMMAND_EVERY ))
      # lsp says this order makes result more precise
      # How many N second loops are required to get to COMMAND_EVERY in minutes?
      # Given N (in seconds), COMMAND_EVERY (in minutes), how many counter loops it takes to achieve COMMAND_EVERY
      # COMMAND_TIME=$((60/$N * $COMMAND_EVERY ))
}


# Check flags:
function check_flags() {
    local OPTIND                               # Make this a local; is the index of the next argument index, not current;
    local regex_isa_num='^[0-9]+$'             # Regex: match whole numbers only;

    while getopts ":hw:p:i:c:" OPTIONS; do       # Loop: Get the next option;
        case "${OPTIONS}" in

          w)
            WINDOW="${OPTARG}"
            ;;
          p)
            PANE="${OPTARG}"
            if [[ $PANE -lt 0 || ! "$PANE" =~ $regex_isa_num ]]; then
                echo "Error: -p should be an integer >= 0."
                show_usage; exit;
            fi

            ;;
          i)
            INTERVAL="${OPTARG}"
            if [[ $INTERVAL -lt 1 || ! "$INTERVAL" =~ $regex_isa_num ]]; then
                echo "Error: -i should be an integer > 0."
                show_usage; exit;
            fi
            ;;
          c)
            COMMAND_EVERY="${OPTARG}"
            if [[ $COMMAND_EVERY -lt 1 || ! "$COMMAND_EVERY" =~ $regex_isa_num ]]; then
                echo "Error: -i should be an integer > 0."
                show_usage; exit;
            fi
            ;;

          h)
            show_help; exit;
            ;;
          :)                        # If flag has expected argument omitted;
            echo "Error: -"${OPTARG}" requires an argument."
            show_usage; exit;
            ;;

          # \?)
          *)                        # If unknown (any other) option:
            echo "Error: Unknown option."
            show_usage; exit;
            ;;
        esac
    done
}

function announce_local_watching() {
    # Just a function to announce that script is ready and watching locally:
    echo -n "🔥 Watching ${INTERVAL}s "
}

function announce_remote_ready() {
    # Sleep a bit because when touch url on remote, it takes a while for its message to ouput;
    sleep 1
    # Just a function to annount that remote pane is ready:
    tmux send-keys -t ${WINDOW}.${PANE} "#- 🧭 Gitwatch Ready" enter
}

function begin_watch() {

    while true; do

        GRESULT=$(git status -s)
          # get git status; if no changes, then blank;

        if [[ -n $GRESULT ]]; then

            N_COUNTER=0  # Reset N_COUNTER

            echo "☡  Git changed";
            do_something

            echo "Done."
            announce_local_watching

        else
            echo -n ". "
            # (( N_COUNTER+=1 ))  # this works
            # (( N_COUNTER++ ))   # When set -e, seems to hang here; but okay if N=1 initially?? Not sure why;
            (( ++N_COUNTER ))   # this works


            # run custom command;
            if [[ "$COMMAND_TIME" -gt 0 && "$N_COUNTER" -gt "$COMMAND_TIME" ]]; then
                run_custom_command
                N_COUNTER=0
            fi


        fi
        sleep $INTERVAL
    done
}


# ---------------------------------------------------------------

check_flags "$@"
calc_command_time
git status
announce_remote_ready
announce_local_watching
begin_watch



#------------------------------------------------------



## TODO
  # flags to do ca or cm commits; but since this is a monitor, that could have limited usefulness;
  # Could put the command to run in a config file; but that might be overcomplicating a simple script

  # Flag for specific functions:
    # -p : to run remote pull from remote server
    # But again, if you don't want this, why would you be running this script??
    # You're running this because you want to add amend, commit, push and pull;

## DONE

  # // 2024-10-11 Fri 19:28
  # Remove this ping sudo features;
  # add sass command

  # Every so often run a command in pane 0 in order to keep the "sudo" status alive;
  # Enable custom time; eg: $ gitwatch -i 4


#------------------------------------------------------

## Notes

  # Don't think I need to ping the server in order to keep sudo alive; don't seem to need it if I'm "touching" a local file, not a root file; Should I keep the option available? Or just remove it??

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

  # echo "Git changed ⚡️";
  # echo "Git changed ⭐";

  #----------------

    # $ tmux send-keys -t 1.0 "url" Enter


    # tmux send-keys -t 0 "git pull --rebase" enter
    # tmux send-keys -t 0 "url" enter

    # The problemwith this tmux send-keys command is that it sends to pane zero of the active window; if you switch windows, it will send the command to pane 0 of that active window; not ideal!
    #

#    echo -n "Git repo updated | ";
#    echo $(date +%H:%M:%S);

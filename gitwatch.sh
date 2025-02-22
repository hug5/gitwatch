#!/usr/bin/bash
# // 2024-09-09 Mon 14:07
set -e
# The set -e option instructs the shell to exit immediately if any command or pipeline returns a non-zero exit status, which usually indicates an error or failure.

# ---------------------------------------------------------------

declare GW_FILE='.gw-command.sh'
  # The conf command sh file looked for

declare OPEN_FILE_PATH=''
  # path to custom shell command file
declare SH_FILE=''
  # Contents of sh file
declare -i INTERVAL=3
  # in seconds; sleep interval time; eg 3 seconds
declare -i PERIODIC_COMMAND_INTERVAL=10
  # In minutes; Interval to run custom command;
  # If <= 0, then it's turned off;
declare -i N_COUNTER=0
  # N counter;
declare WINDOW=''
  # default unset; active window
declare PANE=0
  # 0/top pane by default;
declare -i PERIODIC_COMMAND_TIME=0
  # Given the INTERVAL, how many such intervals
  # will make it == PERIODIC_COMMAND_INTERVAL


# ---------------------------------------------------------------

## custom bash commands here on git change:
function do_something() {

    # echo "●"

    while read -r line; do
        line=$(echo "$line" | sed "s/{remote}/tmux send-keys -t ${WINDOW}.${PANE}/")
          # sed replace '{remote}'' with 'tmux'

        eval "$line"
          # Executes argument as shell command;
          # eval is a built-in shell command used to evaluate and execute strings as a shell command.
          # Takes argument, construct a command, and execute it as a shell command; this is in contrast to  the shell executing the result of a command substitution rather than evaluating it.

    done <<< "$SH_FILE"

    announce_remote_ready

    # --------------------------------------

      # while read -r line; do
         # eval "$line"
      # done < ./gitwatch.conf

      # sed -i 's/okay/great/g' $LINE
      # $ var=$(sed "s/OldText/NewText/" <<< $var)
      # $ echo $var
      # This line is with NewText

      # $ echo howtogonk | sed 's/gonk/geek/'
      # echo $var | sed "s/OldText/NewText/g"

      # Will use {remote} to signify remote server:
      # echo $line | sed "s/{remote}/tmux send-keys -t ${WINDOW}.${PANE}/"

      # echo "{remote} ls enter" | sed "s/{remote}/tmux send-keys -t ${WINDOW}.${PANE}/"

      # xx=$(echo "{remote} ls enter" | sed "s/{remote}/tmux send-keys -t ${WINDOW}.${PANE}/")
      # echo $xx
      # eval "$xx"

    # --------------------------------------

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

      # local SCSS="jug/www/static/scss/style.container.scss"
      # local CSS="jug/www/static/css/style.min2.css"

      # sass --update --no-source-map --style=compressed "$SCSS" "$CSS"

      # # sass --update --no-source-map --style=compressed "jug/www/static/scss/style.container.scss" "jug/www/static/css/style.min2.css"



      # # local action:
      # git add --all
      # # git commit --amend --allow-empty --no-edit
      #   # --allow-empty may be necessary if you make a change; commit/push;
      #   # then reverse that exact change and want to commit/push;
      # git commit --amend --no-edit
      # git push --force

      # # remote action:
      # # tmux send-keys -t top "git pull --rebase" enter
      # # tmux send-keys -t top "url" enter
      # tmux send-keys -t ${WINDOW}.${PANE} "git reset HEAD --hard" enter
      #   # Undo scss deletes so that we can pull again;
      # sleep 1
      #   # Prob. not necessary, but commands are printed out below;
      # tmux send-keys -t ${WINDOW}.${PANE} "git pull --rebase" enter
      # sleep 1

      # tmux send-keys -t ${WINDOW}.${PANE} "url" enter
      # sleep 1

      # tmux send-keys -t ${WINDOW}.${PANE} "rm jug/www/static/scss/*" enter
      #   # Delete the scss folder; but will have to reverse it to git pull again;

}


# ---------------------------------------------------------------

function show_help() {
cat << EOF
NAME
    Gitwatch: Watch git files for changes and then do something.

DESCRIPTION

    Gitwatch can run custom bash commands when git files change.
    Specifically, it is designed to add, commit, and push changes
    to your git repo; and then pull git changes from your remote
    server.

    This would commonly require 2 active panes on Tmux.

    For example, you could SSH into your remote in pane 0, and run
    gitwatch in a separate pane, pane 1. When git changes are
    detected, gitwatch will commit, push in pane 1 and pull from
    your remote in pane 0.

    Of course, exactly how you do this depends on your custom
    commands. You can run whatever commands you like.
    See sample $GW_FILE file.

    Custom commands should be saved in a file named gw-command.sh.
    Gitwatch will look for the command file in the current folder.
    If not found, then it will try your home directory.
    You may also specificy a differently named file in any location
    with the -o flag. eg, "gitwatch -o /path/to/command/file".

    Gitwatch solves the labor of adding, commiting, and pulling
    your changes manually and runnning other custom commands.
    You can work on your git project locally and update your
    remote automatically and run custom commands.

EOF
show_usage
}

function show_usage() {
cat << EOF
USAGE
    $ gitwatch [-w W] [-p PANE] [-i INTERVAL] [-o /path/to/command/file]

EXAMPLE
    $ gitwatch
      # Use default settings: watch 3 second intervals; pull remote from pane 0 in current active window.
    $ gitwatch -w 2 -p 0 -i 5
      # set window to 2; remote pane to 0; interval at 5 seconds.
    $ gitwatch -w vps -p 2
      # set window to vps; remote pane to 2; interval at default, 3 seconds.
    $ gitwatch -w 1 -p 0 -o ~/$GW_FILE
      # Set window to 1; remote pane to 0; and run custom command every 7 minutes.

FLAGS
    -w WINDOW     Tmux window, denoted by name or number.
    -p PANE       Tmux pane of your remote, denoted by number.
    -i N          Number > 0; Sleep interval between checks in seconds.
    -o            Path to custom shell command file.
                  By default, current folder, named: $GW_FILE.
    -h            This help.

EOF
}

# ---------------------------------------------------------------


function periodic_command_time() {

    PERIODIC_COMMAND_TIME=$(( 60 * $PERIODIC_COMMAND_INTERVAL / $INTERVAL ))
    # PERIODIC_COMMAND_TIME=$(( 60 / $INTERVAL * $PERIODIC_COMMAND_INTERVAL ))
      # lsp says this order makes result more precise
      # How many N second loops are required to get to PERIODIC_COMMAND_INTERVAL in minutes?
      # Given N (in seconds), PERIODIC_COMMAND_INTERVAL (in minutes), how many counter loops it takes to achieve PERIODIC_COMMAND_INTERVAL
      # PERIODIC_COMMAND_TIME=$((60/$N * $PERIODIC_COMMAND_INTERVAL ))
}


function run_periodic_command() {
    echo -n "🌀 "
}


# Check flags:
function check_flags() {
    local OPTIND                               # Make this a local; is the index of the next argument index, not current;
    local regex_isa_num='^[0-9]+$'             # Regex: match whole numbers only;

    while getopts ":hw:p:i:o:" OPTIONS; do       # Loop: Get the next option;
        case "${OPTIONS}" in

          w)
            WINDOW="${OPTARG}"
            ;;
          p)
            PANE="${OPTARG}"
            if [[ $PANE -lt 0 || ! "$PANE" =~ $regex_isa_num ]]; then
                echo "Argghh!! -p should be an integer >= 0."
                show_usage; exit;
            fi

            ;;
          i)
            INTERVAL="${OPTARG}"
            if [[ $INTERVAL -lt 1 || ! "$INTERVAL" =~ $regex_isa_num ]]; then
                echo "Argghh!! -i should be an integer > 0."
                show_usage; exit;
            fi
            ;;
          o)
            OPEN_FILE_PATH="${OPTARG}"
            if ! [[ -f "$OPEN_FILE_PATH" ]]; then
                echo "Argghh!! Bad file path."
                exit;
            fi
            SH_FILE=$(cat "$OPEN_FILE_PATH")
            ;;

          h)
            show_help; exit;
            ;;
          :)                        # If flag has expected argument omitted;
            echo "Argghh!! -"${OPTARG}" requires an argument."
            show_usage; exit;
            ;;

          # \?)
          *)                        # If unknown (any other) option:
            echo "Argghh!! Unknown option."
            show_usage; exit;
            ;;
        esac
    done
}

function check_SH_FILE() {

  if [[ -z $SH_FILE ]]; then

      # Try to find $GW_FILE in local folder; then $HOME;
      OPEN_FILE_PATH="./$GW_FILE"
      if ! [[ -f "$OPEN_FILE_PATH" ]]; then
          OPEN_FILE_PATH="$HOME/$GW_FILE"
          if ! [[ -f "$OPEN_FILE_PATH" ]]; then
              echo "Argghh!! Need $GW_FILE file."
              echo "Or specify a command file with -o flag."
              echo
              show_usage
              exit
          fi
      fi
      SH_FILE=$(cat "$OPEN_FILE_PATH")
  fi
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
            # (( N_COUNTER+=1 ))  # this works
            # (( N_COUNTER++ ))   # When set -e, seems to hang here; but okay if N=1 initially?? Not sure why;
            (( ++N_COUNTER ))   # this works


            # run custom command;
            if [[ "$PERIODIC_COMMAND_TIME" -gt 0 && "$N_COUNTER" -gt "$PERIODIC_COMMAND_TIME" ]]; then
                run_periodic_command
                N_COUNTER=0
            else
                echo -n ". "
            fi


        fi
        sleep $INTERVAL
    done
}


# ---------------------------------------------------------------

check_flags "$@"
check_SH_FILE
periodic_command_time
git status
announce_remote_ready
announce_local_watching
begin_watch



#------------------------------------------------------



## TODO

  # // 2024-10-12 Sat 15:16
  # Think I need to put the commands in a separate sh file;
  # python and sh project requirements are too different;
  # eg, With python, I may want to delete the scss files in the remote;
  # Just with that single addition, it's a hassle to switch between simple sh projects and others;

  # More practical to remove the "custom command" feature; having 2 external sh files isn't very convenient, though possible to do;

  # flags to do ca or cm commits; but since this is a monitor, that could have limited usefulness;
  # Could put the command to run in a config file; but that might be overcomplicating a simple script
  # Perhaps more practical to have a limit of when ca does a cm; too many cas don't seem to be good;


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

#!/usr/bin/bash
# // 2024-09-09 Mon 14:07


# declare -rx color_light_green='\033[1;32m'
declare -i N=2            # Sleep in integer seconds
declare -i PINGTIME=150   # Interval to ping remote
declare -i PING_COUNTER=0        # Ping counter

  # 150, with N=2, should be about 5 minutes

git status

while true; do

    GRESULT=$(git status -s)
      # get git status; if no changes, then blank;

    if [[ -n $GRESULT ]]; then

        echo "git changed. committing changes...";

        #---- Commands to run:

        git add --all
        git commit --amend --no-edit
        git push --force
        tmux send-keys -t 0 "git pull --rebase" enter
        tmux send-keys -t 0 "url" enter

        echo -n "git repo updated | ";
        echo $(date +%H:%M:%S);


        #---- End commands

        PING_COUNTER=0  # Reset PING_COUNTER

    else
        echo -n ". ";
        (( PING_COUNTER++ ))
        if [[ "$PING_COUNTER" -gt "$PINGTIME" ]]; then
            tmux send-keys -t 0 "sudo echo ping" enter
            echo -n "ping remote "
            PING_COUNTER=0
        fi
    fi

    # sleep "$1"
    sleep $N
done



#------------------------------------------------------

## TODO
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

# Basic generic commands

# if [[ -z $gw_counter ]]; then
#     export gw_counter=0
# fi

# (( gw_counter++ ))
# echo $gw_counter
# exit

# Can export variable, but won't keep unless you source the script;
# Another option is to use a random number; randomly do ca or cm;


# Do commit is false, but commit update;
# Randomly, about 1/30, we commit with message;
DOCM=false
  # git commit with wip message (true)? Or git amend (false)?
# 1 out of 30 chance that we make DOCM=true;
RAND=$((1 + $RANDOM % 30))
if [[ RAND -eq 1 ]]; then DOCM=true; fi


# local action:
git add --all
#sleep .3

# can also use -q; but it only prints 3 lines; most verbosity comes from the push --force below;
if [[ $DOCM == false ]]; then echo "gca"; git commit --amend --no-edit; else echo "gcmm"; git commit -m "wip"; fi
#sleep .3

# Most of the verbosity seems to come from here:
git push --force -q

sleep .3

# ===== Doing this in remote server pane =====

# tmux send-keys -t ${WINDOW}.${PANE} "git reset HEAD --hard" enter
{remote} "git reset HEAD --hard" enter
  # {remote} is a placeholder variable; like a template; will be replaced with tmux command
  # Will be replaced like so in gitwatch.sh file:
   # line=$(echo "$line" | sed "s/{remote}/tmux send-keys -t ${WINDOW}.${PANE}/")
  # Undo scss deletes so that we can pull again;

sleep .3
{remote} "git pull --rebase" enter

sleep .5
{remote} "url" enter


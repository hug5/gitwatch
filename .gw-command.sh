## Sample command file
# // 2024-10-13

# Run SASS
SCSS="jug/www/static/scss/style.container.scss"
CSS="jug/www/static/css/style.min.css"
sass --update --no-source-map --style=compressed "$SCSS" "$CSS"

sleep .3
# Run local git commands
git add --all
# git commit --amend --allow-empty --no-edit
  # --allow-empty may be necessary if you make a change; commit/push;
  # then reverse that exact change and want to commit/push;
git commit --amend --no-edit
sleep .3
git push --force


#----------------------------------

# Run remote commands on Tmux pane N (Whichever you elected);
# Normally, assuming the remote pane is pane 0, in window 1, you would do:
# $ tmux send-keys -t 1.0 "<some command>" enter
# $ tmux send-keys -t 1.0 "git pull --rebase" enter

# Or use a variable to denote the window and pane:
# $ tmux send-keys -t ${WINDOW}.${PANE} "git pull --rebase" enter
# This is better as WINDOW and PANE variables will capture your flag options;

# Or as a shortcut, can replace the tmux specific statement with {remote}
# So you could do:
# $ {remote} "git pull --rebase" enter
# This would be the most concise syntax;
# When gitwatch sees {remote}, it'll replace it with the full 'tmux-send-keys...' command.

sleep .3
# Pull git:
{remote} "git pull --rebase" enter

sleep .3
# Run a custom alias command named, url:
{remote} "url" enter


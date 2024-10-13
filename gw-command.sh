## Sample command file

# Run SASS
SCSS="jug/www/static/scss/style.container.scss"
CSS="jug/www/static/css/style.min.css"
sass --update --no-source-map --style=compressed "$SCSS" "$CSS"

# Run local git commands
git add --all
# git commit --amend --allow-empty --no-edit
  # --allow-empty may be necessary if you make a change; commit/push;
  # then reverse that exact change and want to commit/push;
git commit --amend --no-edit
git push --force


#--------------

# Run remote commands on Tmux pane N (Whichever you elected);
# Normally, assuming the remote pane is pane 0, in window 1, you would do:
# $ tmux send-keys -t 1.0 "<some command>" enter
# $ tmux send-keys -t 1.0 "git pull --rebase" enter
# But as a shortcut, can replace the tmux specific statement with {remote}
# So you could do:
# $ {remote} "git pull --rebase" enter


# Pull git:
{remote} "git pull --rebase" enter

# Run a custom alias command named, url:
{remote} "url" enter


# gitwatch

### Gitwatch: Watch git files for changes and then do something.

A simple git bash script that automates local git commits and remote updates.

Watches your git project for changes and then does something:

```   
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

USAGE

    $ gitwatch [-w W] [-p PANE] [-i INTERVAL]

EXAMPLE

    $ gitwatch
      # Use default settings: watch 3 second intervals; 
      # pull remote from pane 0 in current active window.
      
    $ gitwatch -w 2 -p 0 -i 5
      # set window to 2; remote pane to 0; interval at 5 seconds
    
    $ gitwatch -w vps -p 2
      # set window to vps; remote pane to 2; interval at default, 3 seconds

FLAGS
    -w WINDOW     Tmux window, denoted by name or number.
    -p PANE       Tmux pane of your remote, denoted by number.
    -i INTERVAL   Sleep interval between checks in seconds.
    -h            This help.

Bash commands gitwatch runs by default:

  $ git add --all
  $ git commit --amend --no-edit
  $ git push --force
  $ tmux send-keys -t ${WINDOW}.${PANE} "git pull --rebase" enter
  $ tmux send-keys -t ${WINDOW}.${PANE} "url" enter
    # This is a custom command I use; you will want to delete it;
  
  # You can customize commands as you like.
  
```

# gitwatch

### Gitwatch: Watch git files for changes and then do something.

A simple git bash script that automates local git commits and remote updates.

Watches your git project for changes and then does something:

```   
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

  
```

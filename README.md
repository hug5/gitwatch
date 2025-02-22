# gitwatch

### Gitwatch: Watch git files for changes and then do something.

A simple git bash script that automates local git commits and remote updates and running other custom shell commands.

In short, watches your git project for changes and then does something:

```   
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

    Custom commands should be saved in a file named gw-command.sh.
    Gitwatch will look for the command file in the current folder.
    If not found, then it will try your home directory.
    You may also specificy a differently named file in any location
    with the -o flag. eg, "gitwatch -o /path/to/command/file".

    Gitwatch solves the labor of adding, commiting, and pulling
    your changes manually and runnning other custom commands.
    You can work on your git project locally and update your
    remote automatically and run custom commands.

USAGE
    $ gitwatch [-w W] [-p PANE] [-i INTERVAL] [-o /path/to/custom/command/file]

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

  
```

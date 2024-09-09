# gitwatch

### A simple git bash script.
Watches your git project for changes and then does something:
```
  $ git add --all
    # Add all changes to git;
  $ git commit --amend --no-edit
    # commit changes with amend flags;
  $ git push --force
    # Push changes to repo;
  
  # Assumes you're running tmux, with remote on pane 0 
  $ tmux send-keys -t 0 "git pull --rebase" enter 
    # Pull changes from git and rebase changes;
  
  # Run another custom command;
  $ tmux send-keys -t 0 "url" enter
```

Other features:
- Monitors for changes every 2 seconds.
- Pings the remote server ~5 minutes to keep sudo alive.
- Commands and options can be customized to needs.


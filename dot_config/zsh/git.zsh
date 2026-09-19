# ============================================================================
#  git.zsh - git shell aliases (ported verbatim from YADR).
#  These rely on git subcommand aliases defined in ~/.gitconfig
#  (git l, git ci, git co, git b, git nb, ...). Both are kept in sync.
# ============================================================================

# status
alias gs='git status'          # your screenshot workflow
alias gst='git status'

# stash
alias gstsh='git stash'
alias gsta='git stash'
alias gsp='git stash pop'
alias gsa='git stash apply'
alias gsl='git stash list'

# show
alias gsh='git show'
alias gshow='git show'

# add
alias ga='git add -A'
alias gap='git add -p'

# commit
alias gcm='git commit -m'      # your screenshot workflow
alias gcim='git commit -m'
alias gci='git commit'
alias gca='git commit -am'
alias gam='git commit --amend --reset-author'

# checkout / branch
alias gco='git checkout'
alias co='git checkout'
alias gnb='git checkout -b'     # new branch
alias gb='git branch -v'
alias gcp='git cherry-pick -x'

# reset / unstage
alias guns='git reset HEAD'
alias gunc='git reset --soft HEAD^'
alias grs='git reset'
alias grsh='git reset --hard'

# merge / rebase
alias gm='git merge'
alias gms='git merge --squash'
alias gr='git rebase'
alias gra='git rebase --abort'
alias grc='git rebase --continue'
alias gbi='git rebase --interactive'

# diff
alias gd='git diff'
alias gdc='git diff --cached -w'
alias gds='git diff --staged -w'

# log  (git l = pretty graph log, defined in gitconfig)
alias gl='git l'               # your screenshot workflow
alias glg='git l'
alias glog='git l'

# fetch / pull / push
alias gf='git fetch'
alias gfp='git fetch --prune'
alias gfa='git fetch --all'
alias gfap='git fetch --all --prune'
alias gpl='git pull'           # your screenshot workflow
alias gplr='git pull --rebase'
alias gps='git push'
alias gpsh='git push -u origin "$(git rev-parse --abbrev-ref HEAD)"'

# remote
alias grv='git remote -v'
alias grad='git remote add'
alias grr='git remote rm'

# clean
alias gcln='git clean'
alias gclndf='git clean -df'
alias gclndfx='git clean -dfx'

# submodule
alias gsm='git submodule'
alias gsmi='git submodule init'
alias gsmu='git submodule update'

# tag / bisect
alias gt='git tag -n'
alias gbg='git bisect good'
alias gbb='git bisect bad'

# housekeeping: delete branches already merged into current
alias gdmb='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'

# ignore file
alias gi="\${EDITOR:-nvim} .gitignore"

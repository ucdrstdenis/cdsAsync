# .bashrc

export MY_LIB_DIR=cdsAsync
export MY_SIM_DIR=cdsAsync/simulation
export MY_GIT_DIR=cdsAsync
##########################
## Useful Cadence Aliases
##########################
# Check in all designs. 
alias cdscheckin='clsAdminTool -are $MY_LIB_DIR'

# Start distributed processing
alias startDist = 'sudo cdsqmgr /root/distproc'

# Launch Cadence Job Monitor for distributed processing
alias jobMonitor='nohup cdsJobMonitor > /dev/null 2>&1 &'

# Keep virtuoso running if the terminal closes...
virtuosity () {
    cd $MY_LIB_DIR;
    nohup virtuoso > /tmp/virtuoso-terminal.log 2>&1 &
}

# Remove all locked, temporary, and panic files
cdsunlock () {
    curWD=`pwd`
    cdscheckin
    cdcds
    find . -name "*cdslck*" -exec rm -rfv {} \;
    find . -name "*~" -type f -exec rm -rfv {} \;
    find . -name "*panic*" -exec rm -rfv {} \;
    cd ~/
    find . -name "*cdslck*" -exec rm -rfv {} \;
    find . -name "*~" -type f -exec rm -rfv {} \;
    find . -name "*panic*" -exec rm -rfv {} \;
    cdscheckin
    cd $curWD
}

# CD aliases
alias cdcds='cd $MY_LIB_DIR'
alias cdcdsd='cd $MY_LIB_DIR; cd $1'

alias cdsim='cd $MY_SIM_DIR'
alias cdsimd='cd $MY_SIM_DIR; cd $1'

# Update and commit git repository
# Usage: update_git "message to display with commit"
update_git () {
    curWD=`pwd`
    cdsunlock
    rsync -avuhP --del $MY_LIB_DIR/ $MY_GIT_DIR/ --exclude=.git --exclude=waveforms --exclude=data
    cd $MY_GIT_DIR
    git add .
    git add -u
    git add -A
    git commit -m "$1"
    git push -u
    cd $curWD
}


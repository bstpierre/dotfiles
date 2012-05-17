#!/bin/bash
#
# Tests for dotfile.

set -e
set -x

home1=`mktemp -d /tmp/dotfiletest.XXXXXXXXX`
home2=`mktemp -d /tmp/dotfiletest.XXXXXXXXX`
repo=`mktemp -d /tmp/dotfiletest.XXXXXXXXX`

function cleanup()
{
    rm -rf $home1 $home2 $repo
}

trap cleanup EXIT

# Configure git in fake homedir on machine 1.
export HOME=$home1
git config --global user.name "Dummy Name"
git config --global user.email dummy@example.com

# Configure git in fake homedir on machine2.
export HOME=$home2
git config --global user.name "Dummy Name"
git config --global user.email dummy@example.com

export HOME=$home1

# Set up.
dotfiles init $repo
dotfiles install $repo

# Add a couple of files.
echo testing1 > $HOME/.exrc
echo testing2 > $HOME/.emacs
dotfiles add $HOME/.exrc
dotfiles add $HOME/.emacs

# Save to repo.
dotfiles push 'New files'

# Pull down "on a new machine".
export HOME=$home2
dotfiles install $repo
diff $home1/.exrc $home2/.exrc
diff $home1/.emacs $home2/.emacs

# Make changes on the "new machine" and push.
echo testingAA >> $home2/.exrc
echo testingBB >> $home2/.emacs
echo testingCC >> $home2/.foo
dotfiles add $HOME/.foo
dotfiles push 'Changed files, added a file'

# Resync on the "original machine".
export HOME=$home1
dotfiles pull
diff $home1/.exrc $home2/.exrc
diff $home1/.emacs $home2/.emacs
diff $home1/.foo $home2/.foo

# Now for subdirs.
mkdir $home1/.subdir
mkdir $home1/.subdir/xx
mkdir $home1/.subdir/yy
echo hey > $home1/.subdir/xx/hhh
echo yo > $home1/.subdir/yy/zzz
dotfiles add $home1/.subdir
dotfiles push 'Added subdir with a couple of files'

export HOME=$home2
dotfiles pull
diff $home1/.exrc $home2/.exrc
diff $home1/.emacs $home2/.emacs
diff $home1/.foo $home2/.foo
diff $home1/.subdir/xx/hhh $home2/.subdir/xx/hhh
diff $home1/.subdir/yy/zzz $home2/.subdir/yy/zzz

# What about files in a subdir that isn't itself controlled?
mkdir $home2/.uncontrolled-subdir
echo zzz > $home2/.uncontrolled-subdir/zzz
dotfiles add $home2/.uncontrolled-subdir/zzz
dotfiles push 'Adding untrolled subdir with controlled file.'

export HOME=$home1
dotfiles pull
diff $home1/.uncontrolled-subdir/zzz $home2/.uncontrolled-subdir/zzz

exit 0

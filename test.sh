#!/bin/bash
#
# Tests for dotfile.

set -e
set -x

home1=`mktemp -d /tmp/dotfiletest.XXXXXXXXX`
home2=`mktemp -d /tmp/dotfiletest.XXXXXXXXX`
repo=`mktemp -d /tmp/dotfiletest.XXXXXXXXX`
export HOME=$home1

function cleanup()
{
    rm -rf $home1 $home2 $repo
}

trap cleanup EXIT

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

exit 0

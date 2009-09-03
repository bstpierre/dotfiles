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

# Pull down "on a new machine".
export HOME=$home2
dotfiles install $repo
diff $home1/.exrc $home2/.exrc
diff $home1/.emacs $home2/.emacs

exit 0

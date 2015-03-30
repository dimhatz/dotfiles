#!/bin/sh

INFO_FILE="$HOME/.vim/bundle/.neobundle/install_info"
[ -r $INFO_FILE ] && cp -f --verbose $INFO_FILE ./neobundle-install-info

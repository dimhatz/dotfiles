source: https://github.com/seebi/dircolors-solarized#256dark
to install according to readme:

eval `dircolors /path/to/dircolorsdb`

To activate the theme for all future shell sessions, copy or link that file to ~/.dir_colors, and include the above command in your ~/.profile (for bash) or ~/.zshrc (for zsh).

For Ubuntu 14.04 it is sufficient to copy or link database file to ~/.dircolors. Statement in ~/.bashrc will take care about triggering eval command.

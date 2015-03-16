#!/bin/sh
# Base16 Default - Shell color setup script
# Chris Kempson (http://chriskempson.com)
# modded by dimx for jellybat theme

if [ "${TERM%%-*}" = 'linux' ]; then
    # This script doesn't support linux console (use 'vconsole' template instead)
    return 2>/dev/null || exit 0
fi

color00="18/18/18" # Base 00 - Black
color01="ab/46/42" # Base 08 - Red
color02="a1/b5/6c" # Base 0B - Green
color03="f7/ca/88" # Base 0A - Yellow
color04="7c/af/c2" # Base 0D - Blue
color05="ba/8b/af" # Base 0E - Magenta
color06="86/c1/b9" # Base 0C - Cyan
color07="d8/d8/d8" # Base 05 - White
color08="58/58/58" # Base 03 - Bright Black
color09=$color01 # Base 08 - Bright Red
color10=$color02 # Base 0B - Bright Green
color11=$color03 # Base 0A - Bright Yellow
color12=$color04 # Base 0D - Bright Blue
color13=$color05 # Base 0E - Bright Magenta
color14=$color06 # Base 0C - Bright Cyan
color15="f8/f8/f8" # Base 07 - Bright White
color16="dc/96/56" # Base 09
color17="a1/69/46" # Base 0F
color18="28/28/28" # Base 01
color19="38/38/38" # Base 02
color20="b8/b8/b8" # Base 04
color21="e8/e8/e8" # Base 06
#color_foreground="d8/d8/d8" # Base 05
#color_background="18/18/18" # Base 00
#color_cursor="d8/d8/d8" # Base 05

color_foreground="e8/e8/d3" # Base 05
color_background="15/15/15" # Base 00
color_cursor="ea/e7/88" # Base 05

color022="2f/63/00"
color024="00/54/78"
color053="66/20/69"
color079="5b/d4/bc"
color088="75/28/22"
color100="b8/b5/6b"
color111="88/b8/f6"
color113="86/bf/52"
color137="7a/6e/4e"
color167="e5/79/6d"
color172="ff/b9/64"
color176="cf/7a/c9"
color179="e8/a7/5d"
color183="c6/b6/ee"
color185="cf/c9/6e"
color186="ea/e7/88"
color188="e8/e8/d3"
color196="ff/20/27"
color218="f0/a0/c0"
color230="ff/ff/d7"
color232="00/00/00"
color233="15/15/15"
color234="1c/1c/1c"
color235="26/26/26"
color236="30/20/28"
color238="44/44/44"
color239="4e/4e/4e"
color243="7d/74/68"
color254="f0/f0/f0"
color255="fb/fb/fb"

if [ -n "$TMUX" ]; then
  # tell tmux to pass the escape sequences through
  # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
  printf_template="\033Ptmux;\033\033]4;%d;rgb:%s\007\033\\"
  printf_template_var="\033Ptmux;\033\033]%d;rgb:%s\007\033\\"
  printf_template_custom="\033Ptmux;\033\033]%s%s\007\033\\"
elif [ "${TERM%%-*}" = "screen" ]; then
  # GNU screen (screen, screen-256color, screen-256color-bce)
  printf_template="\033P\033]4;%d;rgb:%s\007\033\\"
  printf_template_var="\033P\033]%d;rgb:%s\007\033\\"
  printf_template_custom="\033P\033]%s%s\007\033\\"
else
  printf_template="\033]4;%d;rgb:%s\033\\"
  printf_template_var="\033]%d;rgb:%s\033\\"
  printf_template_custom="\033]%s%s\033\\"
fi

# 16 color space
printf $printf_template 0  $color00
printf $printf_template 1  $color01
printf $printf_template 2  $color02
printf $printf_template 3  $color03
printf $printf_template 4  $color04
printf $printf_template 5  $color05
printf $printf_template 6  $color06
printf $printf_template 7  $color07
printf $printf_template 8  $color08
printf $printf_template 9  $color09
printf $printf_template 10 $color10
printf $printf_template 11 $color11
printf $printf_template 12 $color12
printf $printf_template 13 $color13
printf $printf_template 14 $color14
printf $printf_template 15 $color15

# 256 color space
printf $printf_template 16 $color16
printf $printf_template 17 $color17
printf $printf_template 18 $color18
printf $printf_template 19 $color19
printf $printf_template 20 $color20
printf $printf_template 21 $color21

# dimx addition
printf $printf_template 22 $color022
printf $printf_template 24 $color024
printf $printf_template 53 $color053
printf $printf_template 79 $color079
printf $printf_template 88 $color088
printf $printf_template 100 $color100
printf $printf_template 111 $color111
printf $printf_template 113 $color113
printf $printf_template 137 $color137
printf $printf_template 167 $color167
printf $printf_template 172 $color172
printf $printf_template 176 $color176
printf $printf_template 179 $color179
printf $printf_template 183 $color183
printf $printf_template 185 $color185
printf $printf_template 186 $color186
printf $printf_template 188 $color188
printf $printf_template 196 $color196
printf $printf_template 218 $color218
printf $printf_template 230 $color230
printf $printf_template 232 $color232
printf $printf_template 233 $color233
printf $printf_template 234 $color234
printf $printf_template 235 $color235
printf $printf_template 236 $color236
printf $printf_template 238 $color238
printf $printf_template 239 $color239
printf $printf_template 243 $color243
printf $printf_template 254 $color254
printf $printf_template 255 $color255

# foreground / background / cursor color
if [ -n "$ITERM_SESSION_ID" ]; then
  # iTerm2 proprietary escape codes
  printf $printf_template_custom Pg d8d8d8 # forground
  printf $printf_template_custom Ph 181818 # background
  printf $printf_template_custom Pi d8d8d8 # bold color
  printf $printf_template_custom Pj 383838 # selection color
  printf $printf_template_custom Pk d8d8d8 # selected text color
  printf $printf_template_custom Pl d8d8d8 # cursor
  printf $printf_template_custom Pm 181818 # cursor text
else
  printf $printf_template_var 10 $color_foreground
  printf $printf_template_var 11 $color_background
  printf $printf_template_var 12 $color_cursor
fi

# clean up
unset printf_template
unset printf_template_var
unset color00
unset color01
unset color02
unset color03
unset color04
unset color05
unset color06
unset color07
unset color08
unset color09
unset color10
unset color11
unset color12
unset color13
unset color14
unset color15
unset color16
unset color17
unset color18
unset color19
unset color20
unset color21
unset color_foreground
unset color_background
unset color_cursor

#dimx
unset color022
unset color024
unset color053
unset color079
unset color088
unset color100
unset color111
unset color113
unset color137
unset color167
unset color172
unset color176
unset color179
unset color183
unset color185
unset color186
unset color188
unset color196
unset color218
unset color230
unset color232
unset color233
unset color234
unset color235
unset color236
unset color238
unset color239
unset color243
unset color254
unset color255

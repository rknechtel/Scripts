#!/bin/bash

# -----------------------------------------------------------------------------
# Script Name: ansi_color_lib.sh
# Description: Script of Variables for doing ANSI Coloering in a Shell
# Author: Richard Knechtel
# Date: 09/12/2022
#
# Note:
# With the help of the source command, we we can access these Variables from another script.
# Copy this script to the same directory as your script(s).
# Put this in the top part of your script:
# source ansi_color_lib.sh
#
# Example usages:
# echo -e "${RED}This is some red text, ${ENDCOLOR}"
# echo -e "${GREEN}And this is some green text.${ENDCOLOR}"
# echo -e "${BOLDGREEN}Behold! Bold, green text.${ENDCOLOR}"
# echo -e "${FAINTBLUE}Behold! Faint, blue text.${ENDCOLOR}"
# echo -e "${ITALICRED}Italian italics${ENDCOLOR}"
# echo -e "${UNDERLINECYAN}Undeline Cyan${ENDCOLOR}"
#
# -----------------------------------------------------------------------------

# Foreground Text Colors
BLACK_FG="\e[30m"
RED_FG="\e[31m"
GREEN_FG="\e[32m"
YELLOW_FG="\e[33m"
BLUE_FG="\e[34m"
MAGENTA_FG="\e[35m"
CYAN_FG="\e[36m"
WHITE_FG="\e[37m"
DEFAULT_FG="\e[39m"
BRIGHTBLACK_FG="\e[90m"
BRIGHTRED_FG="\e[91m"
BRIGHTGREEN_FG="\e[92m"
BRIGHTYELLOW_FG="\e[93m"
BRIGHTBLUE_FG="\e[94m"
BRIGHTMAGENTA_FG="\e[95m"
BRIGHTCYAN_FG="\e[96m"
BRIGHTWHITE_FG="\e[97m"


# Bolded Text Foreground Colors
BOLDBLACK_FG="\e[1;${BLACK_FG}m"
BOLDRED_FG="\e[1;${RED_FG}m"
BOLDBGREEN_FG="\e[1;${GREEN_FG}m"
BOLDYELLOW_FG="\e[1;${YELLOW_FG}m"
BOLDBLUE_FG="\e[1;${BLUE_FG}m"
BOLDMAGENTA_FG="\e[1;${MAGENTA_FG}m"
BOLDCYAN_FG="\e[1;${CYAN_FG}m"
BOLDWHITE_FG="\e[1;${WHITE_FG}m"
BOLDBRIGHTBLACK_FG="\e[1;${BRIGHTBLACK_FG}m"
BOLDBRIGHTRED_FG="\e[1;${BRIGHTRED_FG}m"
BOLDBRIGHTGREEN_FG="\e[1;${BRIGHTGREEN_FG}m"
BOLDBRIGHTYELLOW_FG="\e[1;${BRIGHTYELLOW_FG}m"
BOLDBRIGHTBLUE_FG="\e[1;${BRIGHTBLUE_FG}m"
BOLDBRIGHTMAGENTA_FG="\e[1;${BRIGHTMAGENTA_FG}m"
BOLDBRIGHTCYAN_FG="\e[1;${BRIGHTCYAN_FG}m"
BOLDBRIGHTWHITE_FG="\e[1;${BRIGHTWHITE_FG}m"


# Faint Text Foreground Colors
FAINTBLACK_FG="\e[2;${BLACK_FG}m"
FAINTRED_FG="\e[2;${RED_FG}m"
FAINTBGREEN_FG="\e[2;${GREEN_FG}m"
FAINTYELLOW_FG="\e[2;${YELLOW_FG}m"
FAINTBLUE_FG="\e[2;${BLUE_FG}m"
FAINTMAGENTA_FG="\e[2;${MAGENTA_FG}m"
FAINTCYAN_FG="\e[2;${CYAN_FG}m"
FAINTWHITE_FG="\e[2;${WHITE_FG}m"
FAINTBRIGHTBLACK_FG="\e[2;${BRIGHTBLACK_FG}m"
FAINTBRIGHTRED_FG="\e[2;${BRIGHTRED_FG}m"
FAINTBRIGHTGREEN_FG="\e[2;${BRIGHTGREEN_FG}m"
FAINTBRIGHTYELLOW_FG="\e[2;${BRIGHTYELLOW_FG}m"
FAINTBRIGHTBLUE_FG="\e[2;${BRIGHTBLUE_FG}m"
FAINTBRIGHTMAGENTA_FG="\e[2;${BRIGHTMAGENTA_FG}m"
FAINTBRIGHTCYAN_FG="\e[2;${BRIGHTCYAN_FG}m"
FAINTBRIGHTWHITE_FG="\e[2;${BRIGHTWHITE_FG}m"


# Italic Text Foreground Colors
ITALICBLACK_FG="\e[3;${BLACK_FG}m"
ITALICRED_FG="\e[3;${RED_FG}m"
ITALICBGREEN_FG="\e[3;${GREEN_FG}m"
ITALICYELLOW_FG="\e[3;${YELLOW_FG}m"
ITALICBLUE_FG="\e[3;${BLUE_FG}m"
ITALICMAGENTA_FG="\e[3;${MAGENTA_FG}m"
ITALICCYAN_FG="\e[3;${CYAN_FG}m"
ITALICWHITE_FG="\e[3;${WHITE_FG}m"
ITALICBRIGHTBLACK_FG="\e[3;${BRIGHTBLACK_FG}m"
ITALICBRIGHTRED_FG="\e[3;${BRIGHTRED_FG}m"
ITALICBRIGHTGREEN_FG="\e[3;${BRIGHTGREEN_FG}m"
ITALICBRIGHTYELLOW_FG="\e[3;${BRIGHTYELLOW_FG}m"
ITALICBRIGHTBLUE_FG="\e[3;${BRIGHTBLUE_FG}m"
ITALICBRIGHTMAGENTA_FG="\e[3;${BRIGHTMAGENTA_FG}m"
ITALICBRIGHTCYAN_FG="\e[3;${BRIGHTCYAN_FG}m"
ITALICBRIGHTWHITE_FG="\e[3;${BRIGHTWHITE_FG}m"


# Underline Text Foreground Colors
UNDERLINEBLACK_FG="\e[4;${BLACK_FG}m"
UNDERLINERED_FG="\e[4;${RED_FG}m"
UNDERLINEBGREEN_FG="\e[4;${GREEN_FG}m"
UNDERLINEYELLOW_FG="\e[4;${YELLOW_FG}m"
UNDERLINEBLUE_FG="\e[4;${BLUE_FG}m"
UNDERLINEMAGENTA_FG="\e[4;${MAGENTA_FG}m"
UNDERLINECYAN_FG="\e[4;${CYAN_FG}m"
UNDERLINEWHITE_FG="\e[4;${WHITE_FG}m"
UNDERLINEBRIGHTBLACK_FG="\e[4;${BRIGHTBLACK_FG}m"
UNDERLINEBRIGHTRED_FG="\e[4;${BRIGHTRED_FG}m"
UNDERLINEBRIGHTGREEN_FG="\e[4;${BRIGHTGREEN_FG}m"
UNDERLINEBRIGHTYELLOW_FG="\e[4;${BRIGHTYELLOW_FG}m"
UNDERLINEBRIGHTBLUE_FG="\e[4;${BRIGHTBLUE_FG}m"
UNDERLINEBRIGHTMAGENTA_FG="\e[4;${BRIGHTMAGENTA_FG}m"
UNDERLINEBRIGHTCYAN_FG="\e[4;${BRIGHTCYAN_FG}m"
UNDERLINEBRIGHTWHITE_FG="\e[4;${BRIGHTWHITE_FG}m"


# Background Colors
BLACK_BG="\e[40m"
RED_BG="\e[41m"
GREEN_BG="\e[42m"
YELLOW_BG="\e[43m"
BLUE_BG="\e[44m"
MAGENTA_BG="\e[45m"
CYAN_BG="\e[46m"
WHITE_BG="\e[47m"
DEFAULT_BG="\e[49m"
BRIGHTBLACK_BG="\e[100m"
BRIGHTRED_BG="\e[101m"
BRIGHTGREEN_BG="\e[102m"
BRIGHTYELLOW_BG="\e[103m"
BRIGHTBLUE_BG="\e[104m"
BRIGHTMAGENTA_BG="\e[105m"
BRIGHTCYAN_BG="\e[106m"
BRIGHTWHITE_BG="\e[107m"

ENDCOLOR="\e[0m"

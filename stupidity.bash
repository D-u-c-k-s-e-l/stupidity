#!/bin/bash

# stupidity - Keyboard Layout Switcher
#
# I wrote this script primarily to become layoutfluid in Dvorak, QWERTY, and
# Colemak. This script allows you to set some layouts that can optionally
# be chosen as the daily layout. The daily layout cycles through the
# available layouts based on the current day of the year.
# There's also a next layout command and some commands to get info about the
# current layout.


### CONFIG ###

# Define layouts as an array of strings.
# structure:
# arr[
#   "
#       layout name           (colon)
#       config                (colon)
#       2-letter abbreviation (space) -.
#       3-letter abbreviation (space)  |- Abbreviations
#       5-letter abbreviation (space)  |
#       proper name                   -'
#   "*
# ]
# Layout properties are separated by colons.
# Abbreviations are separated by spaces.
# NOTE: Layouts must be added in the main keyd config
#       file, the config param only sets the layout.
LAYOUTS=(
    "qwerty::qw qwe qwert QWERTY"
    "dvorak:default_layout = dvorak:dv dvk dvrak Dvorak"
    "colemak:default_layout = colemak:cm cmk colmk Colemak"
)
# Which layouts can be chosen as the daily layout. 
AVAILABLE_FOR_DAILY=("qwerty" "dvorak" "colemak")
# Default layout
DEFAULT_LAYOUT="qwerty"
# File to store the keyd configuration for the current layout.
# Please symlink a file in the keyd config directory to this file.
LAYOUT_FILE=~/dotfiles/state/current_layout.keyd
# File to store the name of the current layout.
CURRENT_LAYOUT_FILE=~/dotfiles/state/current_layout_name.txt

### v...LOGIC BELOW THIS POINT...v ###

function find_layout() {
    local layout_name="$1"
    for layout in "${LAYOUTS[@]}"; do
        IFS=':' read -r name config abbrevs <<< "$layout"
        if [[ "$name" == "$layout_name" ]]; then
            echo "${layout}"
            return 0
        fi
        abbreviations=($abbrevs)
        if [[ " ${abbreviations[@]} " =~ " $layout_name " ]]; then
            echo "${layout}"
            return 0
        fi
    done
    return 1
}

function change_layout() {
    layout_name="$1"
    layout_info=$(find_layout "$layout_name")
    IFS=':' read -r name config abbrevs <<< "$layout_info"
    if [[ -z "$name" ]]; then
        echo "Error: Layout '$layout_name' not found."
        exit 1
    fi
    echo "Changing layout to '$name' ..."
    echo "[global]" > "$LAYOUT_FILE"
    echo "$config" >> "$LAYOUT_FILE"
    echo "$name" > "$CURRENT_LAYOUT_FILE"
    sudo keyd reload
}

function next_layout() {
    current_layout=$(get_layout)
    if [[ "$current_layout" == "No layout set." ]]; then
        echo "No layout set. Please set a layout first."
        return 1
    fi
    for i in "${!LAYOUTS[@]}"; do
        IFS=':' read -r name config abbrevs <<< "${LAYOUTS[$i]}"
        if [[ "$name" == "$current_layout" ]]; then
            next_index=$(( (i + 1) % ${#LAYOUTS[@]} ))
            change_layout "$(echo "${LAYOUTS[$next_index]}" | cut -d':' -f1)"
            return 0
        fi
    done
    echo "Current layout not found in the list."
    return 1
}

function get_layout() {
    if [[ -f "$CURRENT_LAYOUT_FILE" ]]; then
        cat "$CURRENT_LAYOUT_FILE"
    else
        echo "No layout set."
    fi
}

function get_current_abbrev() {
    abbrev_type="$1"
    layout_name=$(get_layout)
    if [[ "$layout_name" == "No layout set." ]]; then
        echo "N/A"
        return 1
    fi
    IFS=':' read -r name config abbrevs <<< "$(find_layout "$layout_name")"
    abb=($abbrevs)
    echo "${abb[$abbrev_type]}"
}

function list_layouts() {
    echo "Available layouts:"
    for layout in "${LAYOUTS[@]}"; do
        IFS=':' read -r name config abbrevs <<< "$layout"
        echo "- $name ($(echo $abbrevs | sed 's/ /, /g'))"
    done
}

function help() {
    #    "----.----1----.----2----.----3----.----4----.----5----.----6"
    echo "Usage: stupidity <command> [args]"
    echo "Commands:"
    echo "  change <layout_name>    Change to the specified layout"
    echo "  default                 Set the layout to the default"
    echo "  daily                   Set the layout to the daily special"
    echo "                           (Randomized based on the current"
    echo "                           day!)"
    echo "  next                    Change to the next layout in the list"
    echo "                           (wraps around to the first layout)"
    echo "  get                     Get the current layout"
    echo "  abv <type>              Get the current abbreviation of"
    echo "                           the specified type:"
    echo "                              0: 2-letter"
    echo "                              1: 3-letter"
    echo "                              2: long abbreviation"
    echo "                              3: proper name"
    echo "  list                    List all available layouts"
    echo "  help                    Show this help message"
}

command="$1"
argument="$2"

case "$command" in
    change)
        if [[ -z "$argument" ]]; then
            echo "Error: No layout name provided."
            exit 1
        fi
        change_layout "$argument"
        ;;
    default)
        change_layout "$DEFAULT_LAYOUT"
        ;;
    daily)
        # Randomize based on the current day
        day_of_year=$(date +%j) # get day of the year (1-366)
        total_layouts=${#AVAILABLE_FOR_DAILY[@]} # get total number of layouts
        if [[ $total_layouts -eq 0 ]]; then
            echo "Error: No layouts available for daily selection."
            echo "Please configure this within the script."
            exit 1
        fi
        index=$((day_of_year % total_layouts)) # calculate index into layouts
        layout_name="${AVAILABLE_FOR_DAILY[$index]}" # get layout name
        echo "Today's layout is...."
        echo -e "\t\t${layout_name}!"
        change_layout "$layout_name" # change to the daily layout
        ;;
    next)
        next_layout
        ;;
    get)
        get_layout
        ;;
    abv)
        if [[ -z "$argument" ]]; then
            echo "Error: No abbreviation type provided."
            exit 1
        fi
        get_current_abbrev "$argument"
        ;;
    list)
        list_layouts
        ;;
    help|''|-h|--help)
        help
        ;;
    *)
        echo "Error: Unknown command '$command'."
        echo "Use 'help' to see available commands."
        exit 1
        ;;
esac

exit 0
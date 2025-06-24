#!/bin/bash
layout="$(~/dotfiles/scripts/stupidity abv 3)"
abbrev="$(~/dotfiles/scripts/stupidity abv 0)"
echo "{\"text\":\"$abbrev\",\"tooltip\":\"$layout\"}"

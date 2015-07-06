#!/bin/bash
set -euo pipefail
# Set our root directory for backgrounds
backgrounddir=~/Documents/Backgrounds
masterimage=/tmp/background.png
# capture xrandr output so we're not constantly hitting the GPUs
xrandr=$(xrandr)

# figure out our total size
total=$(echo "$xrandr" | head -n 1 | sed -e 's/.*current \(.*\),.*$/\1/;' | sed -e 's/ //g')
# make our blank canvas
convert -size "$total" xc:#3f526c "$masterimage"

# loop through each of our displays
echo "$xrandr" | grep \ connected | sed 's/primary //g;s/^.* connected \([0-9x]*\)\([^ ]*\) .*$/\1 \2/;' | while read -r res offset; do
	echo "$res" | grep -qv "x" && continue
	# pick out a random image
	image=""
	while [ -z "$image" ] || grep -q "$image" "/tmp/background.log"; do
		length="$(find "$backgrounddir" -type f | wc -l)"
		image="$(find "$backgrounddir" -type f | shuf -n 1)"
		$(identify -format "[ %w -gt %h ]" "$image") && imageorient="vert" || imageorient="horiz"
		[ ${res//x/ -gt } ] && screenorient="vert" || screenorient="horiz"
		if [ "$imageorient" != "$screenorient" ]; then
			echo "Skipping $image because of orientation" >> /tmp/background.log
			image=""
		fi
		[ "$(wc -l < /tmp/background.log)" -ge "$length" ] && rm /tmp/background.log
	done
	echo "Picking $image at random" >> /tmp/background.log
	convert "$image" -resize "$res^" -gravity center -extent "$res^" /tmp/converted.png
	# pick out a random color if we don't have any images
	# find the offset of the display
	# slap the background or color onto the master image in the right spot
	composite -geometry "$offset" /tmp/converted.png "$masterimage" "$masterimage"
	rm /tmp/converted.png
done

# finally set the background 
feh --bg-scale "$masterimage" --no-xinerama

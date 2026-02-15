#!/bin/sh

THEME="dark"
WPS_DIR=".rockbox/wps/breezepod_$THEME"

# Checks if .rockbox folder already exists
if [ -d ".rockbox" ]; then
    echo "Theme output folder (.rockbox) already exists, replacing contents..."
    rm -rf .rockbox
fi

mkdir -p "$WPS_DIR"

# WPS Compositing and conversion to bmp
echo "Compositing WPS screen..."
magick assets/bg.png \
  -resize 320x240^ \
  -gravity center \
  -extent 320x240 \
  -alpha set \
  -virtual-pixel background \
  -background transparent \
  -blur 0x8 \
  \( -size 320x240 xc:black -alpha set -channel A -evaluate set 50% +channel \) \
  -compose over -composite \
  \( assets/wps_$THEME.svg -resize 320x240 -background none -alpha set \) \
  -gravity center -composite \
  -background black \
  -alpha remove -alpha off \
  BMP3:"$WPS_DIR/bgwps.bmp"

# Converts SBS svg file to bmp
echo "Converting SBS screen."
magick assets/sbs_$THEME.svg \
    BMP3:"$WPS_DIR/bgsbs.bmp"

# Create themes folder
mkdir -p .rockbox/themes
mkdir -p .rockbox/icons

# Converts and copies icons
cd assets/icons
for icon in *_"$THEME".*; do
    filename=$(basename "$icon")
    base="${filename/_$THEME/}"

    # Use mogrify to convert to BMP in the output directory
    magick mogrify -background "#00000000" -format bmp -path "../../$WPS_DIR" "$icon"

    # Rename the output BMP to remove _$THEME
    bmp_name="${filename%.*}.bmp"
    new_name="${base%.*}.bmp"
    mv "../../$WPS_DIR/$bmp_name" "../../$WPS_DIR/$new_name"
done
cd ../../

# Copy various files and folders
cp -r assets/wps/* $WPS_DIR
cp -r assets/fonts .rockbox/fonts
cp assets/breezepod_$THEME.cfg .rockbox/themes/breezepod_$THEME.cfg
cp assets/breezepod_$THEME.wps .rockbox/wps/breezepod_$THEME.wps
cp assets/breezepod_$THEME.sbs .rockbox/wps/breezepod_$THEME.sbs
cp assets/bp_icons_$THEME.bmp .rockbox/icons/bp_icons_$THEME.bmp

echo "Finished!"

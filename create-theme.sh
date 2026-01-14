#!/bin/sh

THEME="light"
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

# Copy various files and folders
cp -r assets/wps/* $WPS_DIR
cp -r assets/fonts .rockbox/fonts
cp assets/breezepod_$THEME.cfg .rockbox/themes/breezepod.cfg
cp assets/breezepod.wps .rockbox/wps/breezepod.wps
cp assets/breezepod.sbs .rockbox/wps/breezepod.sbs
cp assets/bp_icons_$THEME.bmp .rockbox/icons/bp_icons_$THEME.bmp

echo "Finished!"

#!/bin/bash

PLAYER=$(playerctl -l 2>/dev/null | grep -E "(spotify|simplemusic|mpd)" | head -n1)

if [ -z "$PLAYER" ]; then
  echo ""
  exit 0
fi

STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)

if [ "$STATUS" = "Playing" ]; then
  TITLE=$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null)

  if [ -z "$TITLE" ]; then
    echo ""
    exit 0
  fi

  ARTIST=$(playerctl -p "$PLAYER" metadata xesam:artist 2>/dev/null | sed 's/&/\\&/g')
  TITLE=$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null | sed 's/&/\\&/g')

  if [ ${#TITLE} -gt 30 ]; then
    TITLE="${TITLE:0:27}..."
  fi

  echo " $ARTIST - $TITLE"
else
  echo ""
fi

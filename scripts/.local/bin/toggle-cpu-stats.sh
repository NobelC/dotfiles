#!/bin/bash
if eww active-windows | grep -q ': sys-stats$'; then
  eww close sys-stats sys-stats-bg
else
  eww open sys-stats-bg
  eww open sys-stats
fi

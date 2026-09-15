#!/bin/bash
# Lanza Firefox en un sandbox de red restrictivo

bwrap \
  --dev /dev \
  --proc /proc \
  --ro-bind /usr /usr \
  --ro-bind /lib /lib \
  --ro-bind /lib64 /lib64 \
  --ro-bind /etc/ssl /etc/ssl \
  --ro-bind /etc/resolv.conf /etc/resolv.conf \
  --bind /home/nobel/.mozilla /home/nobel/.mozilla \
  --bind /home/nobel/Downloads /home/nobel/Downloads \
  --unshare-all \
  --share-net \
  --die-with-parent \
  firefox %U

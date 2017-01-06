#!/bin/bash
eval $(sed -re '/^#/d; s/^([^#]*):(.*):(.*)$/.\/grades.sh "\1" "\2" "\3" >> log 2>\&1 \& /g' $1)

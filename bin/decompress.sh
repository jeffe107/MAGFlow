#!/bin/bash

files=$1

for file in ${files}/*.gz; do
  [ -e "$file" ] && gunzip -q "$file"
done
echo "done"

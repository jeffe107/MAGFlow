#!/bin/bash

directory=$1

mkdir -p "${directory}/databases/gtdbtk2" && cd "${directory}/databases/gtdbtk2"
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_package/full_package/gtdbtk_data.tar.gz
tar xvzf gtdbtk_data.tar.gz
rm gtdbtk_data.tar.gz

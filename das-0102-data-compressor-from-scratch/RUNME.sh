#!/usr/bin/env bash

set -e -o pipefail

echo -n "abbcccc" | ./garyzip.rb compress | hexdump


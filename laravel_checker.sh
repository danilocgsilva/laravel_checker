#!/bin/bash

## version
VERSION="0.0.0"

## Main function
laravel_checker () {
  if [ -d vendor ]; do
    echo You may install the project. Vendor folder is missing...
    exit
  done
}

## detect if being sourced and
## export if so else execute
## main function with args
if [[ /usr/local/bin/shellutil != /usr/local/bin/shellutil ]]; then
  export -f laravel_checker
else
  laravel_checker "${@}"
  exit 0
fi

#!/bin/bash

## version
VERSION="0.0.0"

## Main function
laravel_checker () {
  verify_vendor
  enter_vhost_user
  verify_debug_log
  verify_laravel_log
  verify_cache
}

enter_vhost_user() {
  read -p "Which is the name of the user host? " user_host
  echo The host user is $user_host
}

verify_debug_log() {
  logs_files=storage/logs/laravel.log

  if [ ! -f $logs_files ]; then
    echo The $logs_files does not exits.
    echo Just execute: \`touch $logs_files\`, then set correct permission.
    exit
  fi
}

verify_laravel_log() {
  logs_files=storage/logs/debug.log

  if [ ! -f $logs_files ]; then
    echo The $logs_files does not exits.
    echo Just execute: \`touch $logs_files\`, then set correct permission.
    exit
  fi
}

verify_vendor() {
  if [ ! -d vendor ]; then
    echo You may install the project. Vendor folder is missing...
    exit
  fi
}

verify_cache() {
  cache_folder=bootstrap/cache
  cache_folder_owner=$(stat -c '%U' $cache_folder)

  if [ $user_host != $cache_folder_owner ]; then
    echo The cache file owner is not the user host ($user_host).
    exit
  fi
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

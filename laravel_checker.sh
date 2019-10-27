#!/bin/bash

## version
VERSION="0.1.2"

user_host_file=~/.laravel_checker

## Main function
laravel_checker () {
  verify_vendor
  enter_vhost_user
  verify_debug_log
  verify_laravel_log
  verify_cache
  verify_storage_views
  check_node_folder
  verify_env
}

enter_vhost_user() {

  if [[ $(fetches_locally_saved_server_host) = "" ]]
  then
    read -p "Which is the name of the user host? " user_host
    save_host_user_to_machine
  else
    user_host=$(fetches_locally_saved_server_host)
  fi
}

fetches_locally_saved_server_host() {

  if [ -f $user_host_file ]
  then
    cat $user_host_file
  else
    echo ""
  fi
}

extract_file_owner() {
  stat -c "%U" $1
}

verify_debug_log() {
  logs_files=storage/logs/laravel.log

  if [ ! -f $logs_files ]; then
    echo The $logs_files does not exits.
    creates_empty_file $logs_files
    echo The log file $logs_files has just been created.
  fi

  if [[ $(extract_file_owner $logs_files) != $user_host ]]; then
    echo Caution! The file $logs_files does not is owned by the web server user.
    if change_file_permission $logs_files $user_host ; then
      echo To $logs_files has been setted the correct permission
    else
      echo run \'chown $user_host $logs_files\'
    fi
  fi
}

verify_laravel_log() {
  logs_files=storage/logs/debug.log

  if [ ! -f $logs_files ]; then
    echo The $logs_files does not exits.
    creates_empty_file $logs_files
    echo The file $logs_files has just been created.
    #echo Just execute: \`touch $logs_files\`, then set correct permission.

    echo --Sugestion for permissions:
    echo ----\`chmod 775 $logs_files\`
    echo ----\`chown $(whoami):$user_host $logs_files\`
  elif [ $(extract_file_owner $logs_files) != $user_host ]; then
    echo Caution! The file $logs_files does not is owned by the web server user.
    echo run \'chown $user_host $logs_files\'
  fi
}

verify_vendor() {
  if [ ! -d vendor ]; then
    echo You may install the project. Vendor folder is missing...
  fi
}

verify_cache() {
  cache_folder=bootstrap/cache
  cache_folder_owner=$(stat -c '%U' $cache_folder)

  if [ $user_host != $cache_folder_owner ]; then
    echo The cache file owner is not the user host \($user_host\).
    echo Execute \`chown $(fetches_locally_saved_server_host) $cache_folder\`.
  fi
}

verify_storage_views() {
  storage_views_path=storage/framework/views
  views_path_owner=$(stat -c '%U' $storage_views_path)

  if [ $user_host != $views_path_owner ]; then
    echo The $storage_views_path owner is not the user host \($user_host\)
    echo Execute \`chown $user_host $storage_views_path\`.
  fi
}

save_host_user_to_machine() {
  echo $user_host > $user_host_file
  echo "The user host has been saved locally in the computer."
}

check_node_folder() {
  if [ ! -d node_modules ]; then
    echo I have not found the node_modules folder.
    echo Does not your Laravel installation needs frontend compilation?
    echo May you need run \`npm install\`.
  fi
}

creates_empty_file() {
  path_only_folders="${1%/*}"
  mkdir -p $path_only_folders
  touch $1
}

## First argument stands for file
## Second argument stands for owner
change_file_permission() {
  chown $2 $1
}

verify_env() {
  if ! [ -f .env ]; then
    cp .env.example .env
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

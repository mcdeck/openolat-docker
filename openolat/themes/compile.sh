#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


OLAT_THEMES=${THEME_DIR:-/mnt/c/Users/olive/Downloads/openolat_1728/static/themes}

while IFS= read -d $'\0' -r folder ; do 
    echo $folder
    for sassfile in "theme" "email" "content"; do
      echo - $sassfile
      sass -I ${OLAT_THEMES} $folder/$sassfile.scss $folder/$sassfile.css
    done
done < <(find ${SCRIPT_DIR} -mindepth 1 -maxdepth 1 -type d -print0)


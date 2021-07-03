#! /bin/bash

if [ "$#" -ne 2 ]; then
    echo "You must enter exactly 2 command line arguments"
    exit 1
fi
for arg in "$@"
do
    case $arg in
        -e|--email)
        FILE="$HOME/.scripts/servicesemail.txt"
        shift # Remove --initialize from processing
        ;;
        -p|--password)
        FILE="$HOME/.scripts/serviceskey.txt"
        shift # Remove --initialize from processing
        ;;
        *)
        KEYWORD=$1
        shift # Remove generic argument from processing
        ;;
    esac
done
VALUE=$(grep $KEYWORD $FILE | awk -F= '{print $2}')
ydotool type "$VALUE"

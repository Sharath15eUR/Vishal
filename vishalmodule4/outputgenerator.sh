#!/bin/bash

#Check if the output file is already existent, if not create the output file
if [ ! -f "output.txt" ];then
        touch "output.txt"
fi

#Read the file line by line using while loop
while read -r line; do
    #Retrieving the key value using awk command using ":" as the field seperator
    keyword=$(echo $line  | awk -F ":" '{print $1}')
    #Checks if the key value matches any one of the given parameters,if matched, it appends the whole line to the output.txt file
    if [[ $keyword == "\"frame.time\"" || $keyword == "\"wlan.fc.type\"" || $keyword == "\"wlan.fc.subtype\"" ]]; then
        echo "$line" >> "output.txt" 
    fi
#Input text file is given using redirection 
done < "input.txt"

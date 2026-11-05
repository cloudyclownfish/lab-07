#!/bin/bash

for folder in Testcase1 Testcase2 Testcase3 Testcase4
do
    if [ -d "$folder" ] && [[ "$folder" != *Diff ]]
    then
        testcase=${folder#Testcase}
        output_dir="Testcase${testcase}Diff"

        rm -rf "$output_dir"

        for file1 in "$folder"/*.1.txt
        do
            if [ -f "$file1" ]
            then
                file2="${file1%.1.txt}.2.txt"
                if [ -f "$file2" ]
                then
                    filename=$(basename "$file1")
                    output_name="${filename%.1.txt}Diff.txt"

                    if ! diff -u "$file1" "$file2" > /tmp/diff_output
                    then
                        mkdir -p "$output_dir"
                        mv /tmp/diff_output "$output_dir/$output_name"
                    fi
                fi
            fi
        done
    fi
done

rm -f /tmp/diff_output

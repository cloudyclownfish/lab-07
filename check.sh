#!/bin/bash

final_status=0

for number in 1 2 3 4
do
    folder="Testcase${number}"
    output_directory="Testcase${number}Diff"

    testcase_status=0
    difference=0
    expected_files=()

    if [ ! -d "$folder" ]
    then
        testcase_status=1
    else
        for file1 in "$folder"/*.1.txt
        do
            if [ ! -f "$file1" ]
            then
                continue
            fi

            file2="${file1%.1.txt}.2.txt"

            if [ ! -f "$file2" ]
            then
                testcase_status=1
            else
                filename=$(basename "$file1")
                output_name="${filename%.1.txt}Diff.txt"
                output_file="$output_directory/$output_name"

                if cmp -s "$file1" "$file2"
                then
                    if [ -e "$output_file" ] || [ -L "$output_file" ]
                    then
                        testcase_status=1
                    fi
                else
                    difference=1
                    expected_files+=("$output_name")

                    if [ ! -f "$output_file" ]
                    then
                        testcase_status=1
                    else
                        if ! diff -u \
                            <(diff -u "$file1" "$file2" | tail -n +3) \
                            <(tail -n +3 "$output_file") > /dev/null
                        then
                            testcase_status=1
                        fi
                    fi
                fi
            fi
        done
    fi

    if [ "$difference" -eq 1 ]
    then
        if [ ! -d "$output_directory" ]
        then
            testcase_status=1
        fi
    else
        if [ -e "$output_directory" ] || [ -L "$output_directory" ]
        then
            testcase_status=1
        fi
    fi

    if [ -d "$output_directory" ]
    then
        for file in "$output_directory"/*
        do
            if [ ! -e "$file" ] && [ ! -L "$file" ]
            then
                continue
            fi

            name=$(basename "$file")
            found=0

            if [ ! -f "$file" ]
            then
                testcase_status=1
            fi

            for expected in "${expected_files[@]}"
            do
                if [ "$name" = "$expected" ]
                then
                    found=1
                fi
            done

            if [ "$found" -eq 0 ]
            then
                testcase_status=1
            fi
        done
    fi

    if [ "$testcase_status" -eq 0 ]
    then
        echo "Testcase${number}: PASS"
    else
        echo "Testcase${number}: FAIL"
        final_status=1
    fi
done

exit "$final_status"

#!/bin/bash

mkdir -p out/pr
mkdir -p out/target
mkdir -p out-default-values/pr
mkdir -p out-default-values/target
mkdir -p comment-files
for env in pr target; do
  cd ${env}/platform-apps/charts
  for chart in $( ls ); do
    echo ${chart}
    helm dependency update ${chart}
    for value in $( find ${chart} -type f -name "values-*" ); do
      valuefile=$( basename ${value} )
      mkdir -p ../../../out/${env}/${chart}/${valuefile}
      helm template ${chart} -f ${value} --output-dir ../../../out/${env}/${chart}/${valuefile}
    done
    # get default values of subchart
    helm show values ${chart}/charts/* > ../../../out-default-values/${env}/${chart}_default-values.out || true
  done
  cd -
done
diff -U 4 -r out-default-values/target out-default-values/pr > out/default-values-diff.txt || true
diff -U 4 -r out/target out/pr > out/diff.txt || true
csplit -f comment-files/comment out/diff.txt --elide-empty-files /^diff\ \-U/ '{*}'

comment_files_csplit=$( find comment-files -type f | sort )

# Define the maximum size in bytes
MAX_SIZE=131072

# Initialize output file counter and base name
OUTPUT_BASE_NAME="combined_file"
output_file_count=1
OUTPUT_FILE="${OUTPUT_BASE_NAME}_${output_file_count}.txt"

# Remove existing files with the same base name to start fresh
rm -f "${OUTPUT_BASE_NAME}_*.txt"

# Current size of the output file
current_size=0

# Loop through all the files passed as arguments to the script
for file in ${comment_files_csplit}; do
  if [ -f "$file" ]; then  # Check if the argument is a valid file
    # Get the size of the file to be added
    file_size=$(stat -c %s "$file")

    # Check if adding this file will exceed the limit
    if (( current_size + file_size > MAX_SIZE )); then
      # Start a new output file
      output_file_count=$((output_file_count + 1))
      OUTPUT_FILE="${OUTPUT_BASE_NAME}_${output_file_count}.txt"
      current_size=0  # Reset current size for the new output file

      echo "Reached size limit. Creating new output file: $OUTPUT_FILE."
    fi

    # Concatenate the file to the current output file
    cat "$file" >> "$OUTPUT_FILE"

    # Update the current size
    current_size=$((current_size + file_size))

    echo "Added '$file' to '$OUTPUT_FILE'. Current size: $current_size bytes."
  else
    echo "'$file' is not a valid file. Skipping."
  fi
done

echo "Concatenation completed. Total output files: $output_file_count."

combined_files=$( ls combined_file* )
for combined_file in ${combined_files} ; do
  sed  's/DESCRIPTION_HERE/Changes Rendered Chart/g' pr/.github/pr-diff-template.txt > out/comment-diff-${combined_file}
  sed  -e "/DIFF_HERE/{r ${combined_file}" -e "d}" out/comment-diff-${combined_file} > comment-files/comment-result-${combined_file}
done

# default values comparison (we assume they will not be bigger than comment size limit)
sed  's/DESCRIPTION_HERE/Changes Default Values/g' pr/.github/pr-diff-template.txt > out/comment-diff-default-values.txt
sed  -e "/DIFF_HERE/{r out/default-values-diff.txt" -e "d}" out/comment-diff-default-values.txt > comment-files/comment-default-values-result.txt


# output for matrix build
echo "matrix={\"comment-files\": $( jq -n '$ARGS.positional' --args $( ls comment-files/comment-result-* ) | tr "\n" " ")}" >> $GITHUB_OUTPUT


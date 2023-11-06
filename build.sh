#!/usr/bin/env bash

set -e

rm -f Coverup-Fixed-*.zip

temp_dir="$(mktemp -d)"
cp -r Coverup/ "$temp_dir"

version_num="$(<version.txt)"
output_file="Coverup-Fixed_$version_num.zip"

sed -i "s/%version%/$version_num/g" "$temp_dir/Coverup/info.json"

(
set -e
cd "$temp_dir"
zip -r "$output_file" "Coverup"
)
mv "$temp_dir/$output_file" "$output_file"
rm -rf "$temp_dir"

echo "Built: $output_file"

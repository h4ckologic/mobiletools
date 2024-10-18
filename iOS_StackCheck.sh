#!/bin/bash

read -p "Enter the path to the Frameworks directory: " FRAMEWORKS_DIR

if [[ ! -d "$FRAMEWORKS_DIR" ]]; then
    echo "Error: The directory $FRAMEWORKS_DIR does not exist."
    exit 1
fi

if ! command -v otool &> /dev/null; then
    echo "Error: otool not found. Please install it to use this script."
    exit 1
fi

check_stack_canary() {
    local binary="$1"
    if otool -Iv "$binary" | grep -q '__stack_chk_guard'; then
        echo "[+] Stack canary present in $binary"
    else
        echo "[-] No stack canary found in $binary"
    fi
}

echo "Checking for stack canaries in binaries under $FRAMEWORKS_DIR..."

find "$FRAMEWORKS_DIR" -type d -name "*.framework" | while read -r framework; do
    framework_name=$(basename "$framework" .framework)
    binary_path="$framework/$framework_name"

    if [[ -f "$binary_path" ]]; then
        echo "Checking $binary_path..."
        check_stack_canary "$binary_path"
    else
        echo "[-] No binary found for $framework_name in $framework"
    fi
done

echo "Stack canary check completed."


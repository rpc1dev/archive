#!/bin/bash
# Generate an SQLite database of links from Google Drive content
# before using this script, you should first create a links.db as follows:
#
# sqlite> CREATE TABLE links(path TEXT PRIMARY KEY, url TEXT);
# sqlite> .save links.db
# sqlite> .quit
#
# Alternatively, if you want to import the existing links.sql:
#
# sqlite> .read links.sql
# sqlite> .save links.db
# sqlite> .quit

ROOT=/home/archive/public_html
TARGET_DB=/home/archive/links.db
shopt -s globstar nullglob nocasematch

# Parse a directory and populate all the Google Drive links from its content
list_dir() {
    echo $1
    for path in "$1"/*; do
        p=${path#"$ROOT/"}
        u=$(rclone link "gdrive:archive/$p" 2>&1) || { printf 'ERROR %s %s\n' "gdrive:archive/$p" "$u"; u="$p"; }
        sqlite3 $TARGET_DB "INSERT INTO links VALUES(\"$p\", \"$u\");"
        if [ -d "$path" ]; then
            list_dir "$path"
        fi
    done
}

list_dir "$ROOT"

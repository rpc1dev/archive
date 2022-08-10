#!/bin/bash
# Generate Apache-like directory indexes from a folder or Google Drive content

USE_GDRIVE=$true
ROOT=/home/archive/public_html
TARGET=/home/archive/static_html
shopt -s globstar nullglob nocasematch

# Return an icon image according to an extension
get_icon() {
    case $1 in
    zip | gz | tgz | ace | rar | bz | bz2 | Z | 7z | sit)
        echo -n /icons/compressed.png
        ;;
    a)
        echo -n /icons/a.png
        ;;
    c | cpp | h | hpp)
        echo -n /icons/c.png
        ;;
    tar)
        echo -n /icons/tar.png
        ;;
    css)
        echo -n /icons/layout.png
        ;;
    exe | dll)
        echo -n /icons/exe.png
        ;;
    html | htm)
        echo -n /icons/world.png
        ;;
    sh | php | scripti | pl | perl )
        echo -n /icons/script.png
        ;;
    hex) 
        echo -n /icons/binhex.png
        ;;
    img | vhd) 
        echo -n /icons/diskimg.png
        ;;
    patch | diff)
        echo -n /icons/patch.png
        ;;
    pdf)
        echo -n /icons/pdf.png
        ;;
    ps)
        echo -n /icons/ps.png
        ;;
    txt | ion)
        echo -n /icons/txt.png
        ;;
    obj | bin)
        echo -n /icons/binary.png
        ;;
    ico | jpg | jpeg | png | gif | bmp | svg | webp)
        echo -n /icons/image.png
        ;;
    avi | mov | mkv | mp4)
        echo -n /icons/movie.png
        ;;
    snd | wav | mp3 | aac)
        echo -n /icons/sound.png
        ;;
    *)
        echo -n /icons/generic.png
        ;;
    esac
}

# Create the HTML directoy index for the specified folder
list_dir() {
    echo $1
    # Remove the $ROOT part
    local d=${1#"$ROOT"}
    mkdir "${TARGET}/${d}" > /dev/null 2>&1
    local index=${TARGET}/${d}/index.html

    # Compute the max length of all the entries in this directory
    local max_length=23
    for path in "$1"/*; do
        p="${path##*/}"
        if [ -d "$path" ]; then
            p="$p/"
        fi
        (( (${#p} > $max_length) )) && max_length=${#p}
    done

    # Print page header
    printf "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2 Final//EN\">\n" > "$index"
    printf "<html>\n<head>\n<title>Index of %s</title>\n</head>\n<body>\n" "$d" >> "$index"
    printf "<pre><h1>Index of %s</h1><img src=\"/icons/blank.png\" alt=\"Icon\" width=\"32\" height=\"32\"> " "$d" >> "$index"
    printf "%-${max_length}s Last modified      Size  Description<hr>" "Name" >> "$index"
    u=${1#"$ROOT"}
    u="$(dirname $u)"
    l=$(($max_length - 16))
    printf "<a href=\"%s\"><img src=\"/icons/back.png\" alt=\"[PARENTDIR]\" width=\"32\" height=\"32\"></a> <a href=\"%s\">Parent Directory</a>%*s                     -\n" "$u" "$u" $l "" >> "$index"
  
    # Process all directories so that they appear first
    for path in "$1"/*; do
        local p="${path##*/}"
        if [ -d "$path" ]; then
            p="$p/"
            i=/icons/folder.png
            t=$(date -r "$path" "+%Y-%m-%d %H:%M")
            l=$(($max_length - ${#p}))
            printf "<a href=\"%s\"><img src=\"%s\" alt=\"[DIR]\" width=\"32\" height=\"32\"></a> <a href=\"%s\">%s</a>%*s %s    -\n" "$p" "$i" "$p" "$p" $l "" "$t" >> "$index"
            list_dir "$path"
        fi
    done

    # Now process all files
    for path in "$1"/*; do
        local p="${path##*/}"
        if [ -f "$path" ]; then
            f=${path#"$ROOT"}
            if [ $USE_GDRIVE ]; then
                u=$(rclone link "gdrive:archive$f" 2>&1) || { printf 'ERROR %s %s\n' "gdrive:archive$f" "$u"; u="$p"; }
            else
                u="$p"
            fi
            i=$(get_icon "${path##*.}")
            t=$(date -r "$path" "+%Y-%m-%d %H:%M")
            l=$(($max_length - ${#p}))
            s=$(ls -lh "$path" | awk '{print  $5}')
            printf "<a href=\"%s\"><img src=\"%s\" alt=\"[   ]\" width=\"32\" height=\"32\"></a> <a href=\"%s\">%s</a>%*s %s %5s\n" "$u" "$i" "$u" "$p" $l "" "$t" "$s" >> "$index"
        fi
    done
 
    # Print page footer
    printf "<hr></pre>\n</body>\n</html>\n" >> "$index"
}

list_dir "$ROOT"

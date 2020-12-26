function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }

BEGIN {
    RS="#";
    FS=":";
    printf "[";
}

NR==1 { next }

{
    group=trim($1);
    split($2, parts, "\n")
    description=trim(parts[1]);
    shortcut=trim(parts[2]);
    sub(/-/, "+", shortcut)
    printf "%s{\"group\": \"%s\", \"description\": \"%s\", \"shortcut\": \"%s\"}", seperator, group, description, shortcut
    seperator=","
}

END {
    printf "]"
}

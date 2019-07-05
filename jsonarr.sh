VAR="one two three"
VAR=$(echo $VAR | sed -e 's/\(\w*\)/,"\1"/g' | cut -d , -f 2-)
echo "{var: [$VAR]}"

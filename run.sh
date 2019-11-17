#!/bin/bash
# CI for http://github.com/one-data-model/playground

lint1() {
    if node ipso-odm/odmlint/odmlint.js "$1" "$2" >out
    then :
    else echo "---"
         echo "schema: $3"
         echo "file: '$i'"
         printf "errors: "
         cat out
         echo "..."
    fi
}

case $# in
    0)
        git clone --depth 1 http://github.com/EricssonResearch/ipso-odm
        (cd ipso-odm/odmlint; npm install)
        find . -name \*.json -exec ./run.sh \{\} \;
        ;;
    *)
        for i
        do
            case "$i" in
                ./ipso-odm/*) ;;
                ./package-lock.json) ;;
                *) 
                    lint1 "$i" ipso-odm/sdf-schema.json base
                    lint1 "$i" ipso-odm/sdf-alt-schema.json alt
            esac
        done
esac

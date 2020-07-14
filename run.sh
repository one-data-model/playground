#!/bin/bash
# CI for http://github.com/one-data-model/playground
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright 2019, 2020 Carsten Bormann
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

lint1() {
    if node tools/sdflint/sdflint.js "$1" "$2" >out
    then :
    else echo "---"
         echo "syntax: $3"
         echo "file: '$i'"
         printf "errors: "
         cat out
         echo "..."
    fi
}

case $# in
    0)
        git clone --depth 1 http://github.com/one-data-model/tools
        (cd tools/sdflint; npm install)
        find . -name \*.sdf.json -exec ./run.sh \{\} \;
        echo '---'
        ruby pointercheck.rb
        ;;
    *)
        for i
        do
            case "$i" in
                ./sdflint/*) ;;
                ./package-lock.json) ;;
                *)
                    lint1 "$i" sdf-framework.jso.json "SDF framework syntax"
                    lint1 "$i" sdf-validation.jso.json "SDF validation syntax"
                    echo $i
            esac
        done
esac

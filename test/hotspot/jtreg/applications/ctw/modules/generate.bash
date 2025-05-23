#!/bin/bash
#
#  Copyright (c) 2017, 2025, Oracle and/or its affiliates. All rights reserved.
#  DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
#  This code is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License version 2 only, as
#  published by the Free Software Foundation.
#
#  This code is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
#  version 2 for more details (a copy is included in the LICENSE file that
#  accompanied this code).
#
#  You should have received a copy of the GNU General Public License version
#  2 along with this work; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
#
#  Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
#  or visit www.oracle.com if you need additional information or have any
#  questions.
#

# generates CTW tests for modules passed as argument

# generates a wrapper file
# arguments:
#   $1 - file number. Like '_2' (can be empty)
#   $2 - classes range in perecents. Like ' 0% 50%' (can be empty)
generate_file() {
    local full_name=${file}${1}.java
    echo creating $full_name for $module...

    [[ -z $2 ]] && scope_str="all" || scope_str="some"

    cat > ${full_name} <<EOF
/*
 * Copyright (c) 2017, ${YEAR}, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

/*
 * @test
 * @summary run CTW for ${scope_str} classes from $module module
 *
 * @library /test/lib / /testlibrary/ctw/src
 * @modules java.base/jdk.internal.access
 *          java.base/jdk.internal.jimage
 *          java.base/jdk.internal.misc
 *          java.base/jdk.internal.reflect
 * @modules $module
 *
 * @build jdk.test.whitebox.WhiteBox
 * @run driver jdk.test.lib.helpers.ClassFileInstaller jdk.test.whitebox.WhiteBox
 * @run driver/timeout=7200 sun.hotspot.tools.ctw.CtwRunner modules:${module}${2}
 */
EOF
}

if [ "$#" -eq 0 ]; then
    echo "No arguments given, scanning open/src for modules"
    MODULES=$(find ../../../../../../src -name module-info.java | \
        grep share/classes/module-info.java |                         `# only standard modules are taken` \
        sed 's/.*src\///' | sed 's/\/.*//')                            # cleaning the module name of leading and trailing paths
else
    echo "Using provided arguments as module(s) list"
    MODULES=$@
fi

YEAR=$(date +%Y)

for module in $MODULES
do
    file=${module//./_}

    case $module in
        # Those are too large, we split them into 2 wrappers
        "java.base")      generate_file "" " 0% 50%"; generate_file "_2" " 50% 100%" ;;
        "java.desktop")   generate_file "" " 0% 50%"; generate_file "_2" " 50% 100%" ;;
        "jdk.localedata") generate_file "" " 0% 50%"; generate_file "_2" " 50% 100%" ;;

        # Those have no classes (needs to be checked on re-generations)!
        "jdk.jdwp.agent") ;;
        "jdk.graal.compiler") ;;
        "jdk.graal.compiler.management") ;;
        "jdk.crypto.ec") ;;
        "java.se") ;;

        # a more-or-less "standard" module
        *) generate_file "" ""

    esac
done

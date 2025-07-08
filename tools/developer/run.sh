#!/bin/bash

set -e

DIR=$(git rev-parse --show-toplevel)
pushd "${DIR}" > /dev/null || exit 1

# Some vroom prerequisites
# sudo apt-get install libssl-dev libasio-dev libglpk-dev

# copy this file into the root of your repository
# ADJUST TO YOUR NEEDS

VERSION=$(grep -Po '(?<=project\(VRPROUTING VERSION )[^;]+' CMakeLists.txt)
echo "VRPROUTING VERSION ${VERSION}"

# VROOM
VROOMVER="1.12"

# set up your postgres version, port and compiler (if more than one)
PGVERSION="15"
PGPORT="5432"
PGBIN="/usr/lib/postgresql/${PGVERSION}/bin"
PGINC="/usr/include/postgresql/${PGVERSION}/server"

# When more than one compiler is installed
GCC=""

QUERIES_DIRS=$(ls -1 docqueries)
TAP_DIRS=$(ls -1 pgtap)


QUERIES_DIRS="
"

TAP_DIRS="
"

function install_vroom {
    cd "${DIR}"
    rm -rf ./vroom-v${VROOMVER}.0
    git clone --depth 1 --branch "v${VROOMVER}.0" https://github.com/VROOM-Project/vroom "./vroom-v${VROOMVER}.0"
    pushd "./vroom-v${VROOMVER}.0"
    git submodule update --init
    # This line is needed on g++ 8+
    perl -pi -e 's/const SizeType length/SizeType length/' include/rapidjson/document.h
    cd src/
    USE_ROUTING=false make shared
    popd
}

function set_cmake {

: <<'END'
    # with debuging information
    cmake -DPROJECT_DEBUG=ON ..

    # with clang
    CXX=clang++ CC=clang cmake "-DPOSTGRESQL_BIN=${PGBIN}" "-DPostgreSQL_INCLUDE_DIR=${PGINC}" \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug \
        -DVROOM_INSTALL_PATH="${DIR}/vroom-v${VROOMVER}.0" ..
END

    # with gcc
    cmake "-DPOSTGRESQL_BIN=${PGBIN}" "-DPostgreSQL_INCLUDE_DIR=${PGINC}" \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug \
        -DVROOM_INSTALL_PATH="${DIR}/vroom-v${VROOMVER}.0" ..

    # with users documentation
    cmake -DBUILD_HTML=ON ..

    # with developers documentation
    cmake -DBUILD_DOXY=ON ..

}

function tap_test {
    echo --------------------------------------------
    echo pgTap test all
    echo --------------------------------------------

    bash tools/testers/pg_prove_tests.sh -U vicky -p 5432 -c

}

function action_tests {
    echo --------------------------------------------
    echo  Update signatures
    echo --------------------------------------------

    bash .github/scripts/get_signatures.sh -p ${PGPORT}
    tools/scripts/notes2news.pl
    bash .github/scripts/test_signatures.sh
    bash .github/scripts/test_shell.sh
    bash .github/scripts/test_license.sh
    bash tools/scripts/code_checker.sh
    bash .github/scripts/update_locale.sh
    tools/testers/doc_queries_generator.pl  -documentation  -pgport $PGPORT
}

function set_compiler {
    echo ------------------------------------
    echo ------------------------------------
    echo "Compiling with G++-$1"
    echo ------------------------------------

    if [ -n "$1" ]; then
        update-alternatives --set gcc "/usr/bin/gcc-$1"
    fi
}

function build_doc {
    pushd build > /dev/null || exit 1
    #rm -rf doc/*
    make doc
    #make linkcheck
    #rm -rf doxygen/*
    #make doxy
    popd > /dev/null || exit 1
}

function build {
    pushd build > /dev/null || exit 1
    set_cmake
    make -j 16
    #make VERBOSE=1
    sudo make install
    popd > /dev/null || exit 1

}

function check {
    pushd build > /dev/null || exit 1
    cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .
    cppcheck --project=compile_commands.json -q
    popd > /dev/null || exit 1
}

function test_compile {

    set_compiler "${GCC}"

    build

    echo --------------------------------------------
    echo  Execute tap_directories
    echo --------------------------------------------
    for d in ${TAP_DIRS}
    do
        bash taptest.sh  "pgtap/${d}"  -p "${PGPORT}"
    done

    echo --------------------------------------------
    echo  Execute documentation queries
    echo --------------------------------------------
    for d in ${QUERIES_DIRS}
    do
        #tools/testers/doc_queries_generator.pl  -alg "docqueries/${d}" -doc  -pgport "${PGPORT}" -venv "${VENV}"
        #tools/testers/doc_queries_generator.pl  -alg "${d}" -debug1  -pgport "${PGPORT}" -venv "${VENV}"
        tools/testers/doc_queries_generator.pl  -alg "${d}" -pgport "${PGPORT}" -venv "${VENV}"
    done

    build_doc

    tap_test
    action_tests
    install_vroom
}
test_compile

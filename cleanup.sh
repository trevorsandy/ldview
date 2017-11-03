#!/bin/bash

result=${PWD##*/}

echo " "
echo "Validating working directory: ${result}..."
if [[ $result == 'ldview' ]]; then
    echo " "
    echo "This script will remove the follwing occurrences recursively:"
    echo "  LDView       - CUI and GUI - in LDView.app/Contents/MacOS/"
    echo "  Headerize    - Headerze utility application"
    echo "  *.osmesa     - OSMesa Makefile"
    echo "  *.qt5        - GUI Makefile"
    echo "  *-qt5.a      - GUI static library"
    echo "  *-osmesa.a   - CUI static library"
    echo "  ui_*         - GUI forms"
    echo "  moc_*        - Meta object compiler"
    echo "  *.o          - compiled object"
    echo "  qrc_resource - resource file"
    find . -name "Headerize" -type f -delete
    find . -name "LDView" -type f -delete
    find . -name "*.osmesa" -type f -delete
    find . -name "*.qtgui" -type f -delete
    find . -name "*-qt5.a" -type f -delete
    find . -name "*-osmesa.a" -type f -delete
    find . -name "*.o" -not -path "./3rdParty*" -type f -delete
    find . -name "ui_*" -type f -delete
    find . -name "moc_*" -type f -delete
    find . -name "qrc_resources.cpp" -type f -delete
    if [[ $1 == '-a' ]]; then
        echo " "
        echo "  also removing these occurences in 3rd party libraries:"
        echo "  *.ldview     - 3rdParty Makefile"
        echo "  *.o          - 3rdParty compiled object"
        echo "  libminizip.a - 3rdParty static library"
        echo "  libtinyxml.a - 3rdParty static library"
        echo "  libgl2ps.a   - 3rdParty static library"
        echo "  libgpng.a    - 3rdParty static library"
        echo "  libgz.a      - 3rdParty static library"
        echo "  libjpeg.a    - 3rdParty static library"
        echo "  lib3ds.a     - 3rdParty static library"
        find ./3rdParty -name "*.o" -type f -delete
        find ./3rdParty -name "*.ldview" -type f -delete
        find ./3rdParty/minizip -name "libminizip.a" -type f -delete
        find ./3rdParty/tinyxml -name "libtinyxml.a" -type f -delete
        find ./3rdParty/gl2ps -name "libgl2ps.a" -type f -delete
        find ./3rdParty/libpng -name "libpng.a" -type f -delete
				find ./3rdParty/libpng -name "libpng16.a" -type f -delete
        find ./3rdParty/zlib -name "libz.a" -type f -delete
        find ./3rdParty/libjpeg -name "libjpeg.a" -type f -delete
        find ./3rdParty/lib3ds -name "lib3ds.a" -type f -delete
    fi
    echo " "
    echo "Clean!"
else
    echo "Invalid working directory '${result}', 'ldview' expected - nothing done."
fi
echo "Finshed."
echo " "

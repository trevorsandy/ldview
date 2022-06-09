TEMPLATE=subdirs
CONFIG+=ordered # This tells Qt to compile the following SUBDIRS in order

# LDView directory and project file structre
# ------------
# /LDView
#  |
#  |--- LDView.pro                         Subdirs project file - structures GUI and CUI subdirs
#  |--- LDViewGlobal.pri                   Global declarations and directives project include
#  |--- 3rdParty.pri                       3rdParty library declarations and directives project include
#  |
#  `--- /QT
#  |     |--- LDView_GUI_Qt.pro            Executable GUI project file - declatations and dirctivies - consumes LDViewGlobal.pri
#  |
#  `--- /OSMesa
#  |     |--- LDView_CUI_OSMesa.pro        Executable CUI project file - declarations and directives - consumes LDViewGlobal.pri
#  |     |--- Headerize_CUI_OSMesa.pro     Executable headerizer project file - declarations and directives - consumes LDViewGlobal.pri
#  |     |--- LDViewCUITest.pri            Executable test project include file - sets up the .ldviewrc and runs a simple rendering test
#  |
#  `--- /LDLib
#  |     |--- LDLib.pri                    Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- LDLib_GUI_Qt.pro             Library GUI project file - consumes LDLib.pri
#  |     |--- LDLib_CUI_OSMesa.pro         Library CUI project file - consumes LDLib.pri
#  |
#  `--- /TRE
#  |     |--- TRE.pri                      Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- TRE_GUI_Qt.pro               Library GUI project file - consumes TRE.pri
#  |     |--- TRE_CUI_OSMesa.pro           Library CUI project file - consumes TRE.pri
#  |
#  `--- /TCFoundation
#  |     |--- TCFoundation.pri             Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- TCFoundation_GUI_Qt.pro      Library GUI project file - consumes TCFoundation.pri
#  |     |--- TCFoundation_CUI_OSMesa.pro  Library CUI project file - consumes TCFoundation.pri
#  |
#  `--- /LDLoader
#  |     |--- LDLoader.pri                 Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- LDLoader_GUI_Qt.pro          Library GUI project file - consumes LDLoader.pri
#  |     |--- LDLoader_CUI_OSMesa.pro      Library CUI project file - consumes LDLoader.pri
#  |
#  `--- /LDExporter
#  |     |--- LDExporter.pri               Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- LDExporter_GUI_Qt.pro        Library GUI project file - consumes LDExporter.pri
#  |     |--- LDExporter_CUI_OSMesa.pro    Library CUI project file - consumes LDExporter.pri
#  |
#  `--- /LGEOTables
#  |     |--- LGEOTables.pri               Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- LGEOTables_CUI_OSMesa.pro    Library CUI project file - consumes LDExporter.pri
#  |
#  `--- /3rdParty
#        |
#        `--- /tinyxml
#        |     |--- 3rdParty_tinyxml.pro   3rdParty library project file - consumes 3rdParty.pri
#        |
#        `--- /gl2ps
#        |     |--- 3rdParty_gl2ps.pro     3rdParty library project file - consumes 3rdParty.pri
#        |
#        `--- /minizip
#        |     |--- 3rdParty_minizip.pro   3rdParty library project file - consumes 3rdParty.pri
#        |
#        `--- /lib3ds
#        |     |--- 3rdParty_3ds.pro       3rdParty library project file - consumes 3rdParty.pri (override with USE_3RD_PARTY_PREBUILT_3DS)
#        |
#        `--- /libpng
#        |     |--- 3rdParty_png.pro       3rdParty library project file - consumes 3rdParty.pri
#        |
#        `--- /libjpeg
#        |     |--- 3rdParty_jpeg.pro      3rdParty library project file - consumes 3rdParty.pri
#
win32:HOST = $$system(systeminfo | findstr /B /C:\"OS Name\")
unix:!macx:HOST = $$system(. /etc/os-release 2>/dev/null; [ -n \"$PRETTY_NAME\" ] && echo \"$PRETTY_NAME\" || echo `uname`)
macx:HOST = $$system(echo `sw_vers -productName` `sw_vers -productVersion`)
isEmpty(HOST):HOST = UNKNOWN HOST

# qmake Configuration settings
# CONFIG+=BUILD_CHECK
# CONFIG+=BUILD_FLATPAK
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_linux_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_macos_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_windows_3rdparty
# CONFIG+=USE_3RD_PARTY_LIBS
# CONFIG+=USE_3RD_PARTY_PREBUILT_3DS  # override USE_3RD_PARTY_3DS to use static pre-built lib3ds.a
# CONFIG+=USE_SYSTEM_LIBS
# CONFIG+=USE_OSMESA_STATIC
# CONFIG+=BUILD_PNG
# CONFIG+=BUILD_GL2PS
# CONFIG+=BUILD_TINYXML
# CONFIG+=BUILD_GUI_ONLY
# CONFIG+=BUILD_CUI_ONLY
# CONFIG+=USE_SYSTEM_OSMESA    # override USE_3RD_PARTY_LIBS for OSMesa libs
# Trusty does have the correct versions for libpng and lib3ds so use the 3rd party
# version if 'use system libs' selected.

BUILD_GUI = YES
BUILD_CUI = YES
BUILD_GUI_ONLY: BUILD_CUI = NO
BUILD_CUI_ONLY: BUILD_GUI = NO
USE_3RD_PARTY_LIBS:USE_SYSTEM_LIBS {
    message("~~~ NOTICE: 'USE_3RD_PARTY_LIBS' and 'USE_SYSTEM_LIBS' Specified. Using 'USE_3RD_PARTY_LIBS'")
    CONFIG -= USE_SYSTEM_LIBS
}

TEMPLATE=subdirs

# This tells Qt to compile the following SUBDIRS in order
CONFIG 	+= ordered

MAKEFILE_3RDPARTY = Makefile.ldview

# system lib3ds does not appear to have lib3ds.h - so always use 3rd party version pre or demand built
!USE_3RD_PARTY_PREBUILT_3DS: USE_3RD_PARTY_3DS = YES

# Build 3rdParty Libraries'
USE_3RD_PARTY_LIBS {

    SUBDIRS = 3rdParty_zlib
    3rdParty_zlib.file       = $$PWD/3rdParty/zlib/3rdParty_zlib.pro
    3rdParty_zlib.makefile   = $${MAKEFILE_3RDPARTY}
    3rdParty_zlib.target     = sub-3rdParty_zlib
    3rdParty_zlib.depends    =

    SUBDIRS += 3rdParty_png
    3rdParty_png.file        = $$PWD/3rdParty/libpng/3rdParty_png.pro
    3rdParty_png.makefile    = $${MAKEFILE_3RDPARTY}
    3rdParty_png.target      = sub-3rdParty_png
    3rdParty_png.depends     =

    SUBDIRS += 3rdParty_jpeg
    3rdParty_jpeg.file       = $$PWD/3rdParty/libjpeg/3rdParty_jpeg.pro
    3rdParty_jpeg.makefile   = $${MAKEFILE_3RDPARTY}
    3rdParty_jpeg.target     = sub-3rdParty_jpeg
    3rdParty_jpeg.depends    =

    SUBDIRS += 3rdParty_tinyxml
    3rdParty_tinyxml.file     = $$PWD/3rdParty/tinyxml/3rdParty_tinyxml.pro
    3rdParty_tinyxml.makefile = $${MAKEFILE_3RDPARTY}
    3rdParty_tinyxml.target   = sub-3rdParty_tinyxml
    3rdParty_tinyxml.depends  =

    contains(USE_3RD_PARTY_3DS, YES) {
        SUBDIRS += 3rdParty_3ds
        3rdParty_3ds.file     = $$PWD/3rdParty/lib3ds/3rdParty_3ds.pro
        3rdParty_3ds.makefile = $${MAKEFILE_3RDPARTY}
        3rdParty_3ds.target   = sub-3rdParty_3ds
        3rdParty_3ds.depends  =
    }

    SUBDIRS += 3rdParty_minizip
    3rdParty_minizip.file     = $$PWD/3rdParty/minizip/3rdParty_minizip.pro
    3rdParty_minizip.makefile = $${MAKEFILE_3RDPARTY}
    3rdParty_minizip.target   = sub-3rdParty_minizip
    !USE_SYSTEM_LIBS: 3rdParty_minizip.depends = 3rdParty_zlib

    SUBDIRS += 3rdParty_gl2ps
    3rdParty_gl2ps.file       = $$PWD/3rdParty/gl2ps/3rdParty_gl2ps.pro
    3rdParty_gl2ps.makefile   = $${MAKEFILE_3RDPARTY}
    3rdParty_gl2ps.target     = sub-3rdParty_gl2ps
    3rdParty_gl2ps.depends    =
}

# Open Build Service overrides
BUILD_TINYXML {
    USE_3RD_PARTY_TINYXML = YES
}

BUILD_GL2PS {
    USE_3RD_PARTY_GL2PS = YES
}

# Ubuntu Trusty uses libpng12 which is too old
if (contains(HOST, Ubuntu):contains(HOST, 14.04.5):USE_SYSTEM_LIBS|BUILD_GL2PS|BUILD_PNG) {
    USE_3RD_PARTY_PNG = YES
}

USE_SYSTEM_LIBS {
    # always built...
    contains(USE_3RD_PARTY_3DS, YES) {
        SUBDIRS = 3rdParty_3ds
        3rdParty_3ds.file         = $$PWD/3rdParty/lib3ds/3rdParty_3ds.pro
        3rdParty_3ds.makefile     = $${MAKEFILE_3RDPARTY}
        3rdParty_3ds.target       = sub-3rdParty_3ds
        3rdParty_3ds.depends      =
    }
    # built for Ubuntu Trusty and for libgl2ps for OBS build-from-source requirements
    contains(USE_3RD_PARTY_PNG, YES) {
        SUBDIRS += 3rdParty_png
        3rdParty_png.file         = $$PWD/3rdParty/libpng/3rdParty_png.pro
        3rdParty_png.makefile     = $${MAKEFILE_3RDPARTY}
        3rdParty_png.target       = sub-3rdParty_png
        3rdParty_png.depends      =
    }
    # Open Build Service build-from-source requirements
    contains(USE_3RD_PARTY_TINYXML, YES) {
        SUBDIRS += 3rdParty_tinyxml
        3rdParty_tinyxml.file     = $$PWD/3rdParty/tinyxml/3rdParty_tinyxml.pro
        3rdParty_tinyxml.makefile = $${MAKEFILE_3RDPARTY}
        3rdParty_tinyxml.target   = sub-3rdParty_tinyxml
        3rdParty_tinyxml.depends  =
    }
    contains(USE_3RD_PARTY_GL2PS, YES) {
        SUBDIRS += 3rdParty_gl2ps
        3rdParty_gl2ps.file       = $$PWD/3rdParty/gl2ps/3rdParty_gl2ps.pro
        3rdParty_gl2ps.makefile   = $${MAKEFILE_3RDPARTY}
        3rdParty_gl2ps.target     = sub-3rdParty_gl2ps
        3rdParty_gl2ps.depends    = 3rdParty_png
    }
}

# Build Qt Graphic User Interface (GUI)
contains(BUILD_GUI, YES) {

    MAKEFILE_GUI_QT = Makefile.qtgui
    SUBDIRS += LDLib_GUI_Qt \
               TRE_GUI_Qt \
               TCFoundation_GUI_Qt \
               LDLoader_GUI_Qt \
               LDExporter_GUI_Qt \
               LDView_GUI_Qt

    LDLib_GUI_Qt.file     = $$PWD/LDLib/LDLib_GUI_Qt.pro
    LDLib_GUI_Qt.makefile = $$MAKEFILE_GUI_QT
    LDLib_GUI_Qt.target   = sub-LDLib_GUI_Qt
    LDLib_GUI_Qt.depends  = 3rdParty_gl2ps

    TRE_GUI_Qt.file     = $$PWD/TRE/TRE_GUI_Qt.pro
    TRE_GUI_Qt.makefile = $$MAKEFILE_GUI_QT
    TRE_GUI_Qt.target   = sub-TRE_GUI_Qt
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS) {
        TRE_GUI_Qt.depends = 3rdParty_gl2ps
    }

    TCFoundation_GUI_Qt.file     = $$PWD/TCFoundation/TCFoundation_GUI_Qt.pro
    TCFoundation_GUI_Qt.makefile = $$MAKEFILE_GUI_QT
    TCFoundation_GUI_Qt.target   = sub-TCFoundation_GUI_Qt
    USE_3RD_PARTY_LIBS: TCFoundation_GUI_Qt.depends = 3rdParty_minizip

    LDLoader_GUI_Qt.file     = $$PWD/LDLoader/LDLoader_GUI_Qt.pro
    LDLoader_GUI_Qt.makefile = $$MAKEFILE_GUI_QT
    LDLoader_GUI_Qt.target   = sub-LDLoader_GUI_Qt
    LDLoader_GUI_Qt.depends  =

    LDExporter_GUI_Qt.file     = $$PWD/LDExporter/LDExporter_GUI_Qt.pro
    LDExporter_GUI_Qt.makefile = $$MAKEFILE_GUI_QT
    LDExporter_GUI_Qt.target   = sub-LDExporter_GUI_Qt
    if (USE_3RD_PARTY_LIBS|BUILD_TINYXML) {
        LDExporter_GUI_Qt.depends = 3rdParty_tinyxml
    }

    # Main
    LDView_GUI_Qt.file      = $$PWD/QT/LDView_GUI_Qt.pro
    LDView_GUI_Qt.makefile  = $$MAKEFILE_GUI_QT
    LDView_GUI_Qt.target    = sub-LDView_GUI_Qt
    LDView_GUI_Qt.depends   = LDLib_GUI_Qt
    LDView_GUI_Qt.depends  += TRE_GUI_Qt
    LDView_GUI_Qt.depends  += TCFoundation_GUI_Qt
    LDView_GUI_Qt.depends  += LDLoader_GUI_Qt
    LDView_GUI_Qt.depends  += LDExporter_GUI_Qt
    contains(USE_3RD_PARTY_PNG, YES):LDView_GUI_Qt.depends += 3rdParty_png
    contains(USE_3RD_PARTY_3DS, YES):LDView_GUI_Qt.depends += 3rdParty_3ds
    USE_3RD_PARTY_LIBS: LDView_GUI_Qt.depends += 3rdParty_minizip
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS) {
        LDView_GUI_Qt.depends += 3rdParty_gl2ps
    }
    USE_3RD_PARTY_LIBS:!USE_SYSTEM_LIBS: LDView_GUI_Qt.depends += 3rdParty_zlib
}

# Build OSMesa Console User Interface (CUI)
contains(BUILD_CUI, YES) {

    MAKEFILE_CUI_OSMESA = Makefile.osmesa
    SUBDIRS += LDLib_CUI_OSMesa \
               TRE_CUI_OSMesa \
               TCFoundation_CUI_OSMesa \
               LDLoader_CUI_OSMesa \
               LDExporter_CUI_OSMesa \
               Headerize_CUI_OSMesa \
               LGEOTables_CUI_OSMesa \
               LDView_CUI_OSMesa

    LDLib_CUI_OSMesa.file     = $$PWD/LDLib/LDLib_CUI_OSMesa.pro
    LDLib_CUI_OSMesa.makefile = $$MAKEFILE_CUI_OSMESA
    LDLib_CUI_OSMesa.target   = sub-LDLib_CUI_OSMesa
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS) {
        LDLib_CUI_OSMesa.depends = 3rdParty_gl2ps
    }

    TRE_CUI_OSMesa.file     = $$PWD/TRE/TRE_CUI_OSMesa.pro
    TRE_CUI_OSMesa.makefile = $$MAKEFILE_CUI_OSMESA
    TRE_CUI_OSMesa.target   = sub-TRE_CUI_OSMesa
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS) {
        TRE_CUI_OSMesa.depends = 3rdParty_gl2ps
    }

    TCFoundation_CUI_OSMesa.file     = $$PWD/TCFoundation/TCFoundation_CUI_OSMesa.pro
    TCFoundation_CUI_OSMesa.makefile = $$MAKEFILE_CUI_OSMESA
    TCFoundation_CUI_OSMesa.target   = sub-TCFoundation_CUI_OSMesa
    USE_3RD_PARTY_LIBS: TCFoundation_CUI_OSMesa.depends = 3rdParty_minizip

    LDLoader_CUI_OSMesa.file     = $$PWD/LDLoader/LDLoader_CUI_OSMesa.pro
    LDLoader_CUI_OSMesa.makefile = $$MAKEFILE_CUI_OSMESA
    LDLoader_CUI_OSMesa.target   = sub-LDLoader_CUI_OSMesa
    LDLoader_CUI_OSMesa.depends  =

    LDExporter_CUI_OSMesa.file     = $$PWD/LDExporter/LDExporter_CUI_OSMesa.pro
    LDExporter_CUI_OSMesa.makefile = $$MAKEFILE_CUI_OSMESA
    LDExporter_CUI_OSMesa.target   = sub-LDExporter_CUI_OSMesa
    if (USE_3RD_PARTY_LIBS|BUILD_TINYXML) {
        LDExporter_CUI_OSMesa.depends = 3rdParty_tinyxml
    }

    Headerize_CUI_OSMesa.file     = $$PWD/OSMesa/Headerize_CUI_OSMesa.pro
    Headerize_CUI_OSMesa.makefile = Makefile-head.osmesa
    Headerize_CUI_OSMesa.target   = sub-Headerize_CUI_OSMesa
    Headerize_CUI_OSMesa.depends  = TCFoundation_CUI_OSMesa
    USE_3RD_PARTY_LIBS:!USE_SYSTEM_LIBS: Headerize_CUI_OSMesa.depends += 3rdParty_zlib

    LGEOTables_CUI_OSMesa.file     = $$PWD/LGEOTables/LGEOTables_CUI_OSMesa.pro
    LGEOTables_CUI_OSMesa.makefile = $$MAKEFILE_CUI_OSMESA
    LGEOTables_CUI_OSMesa.target   = sub-LGEOTables_CUI_OSMesa
    if (USE_3RD_PARTY_LIBS|BUILD_TINYXML) {
        LGEOTables_CUI_OSMesa.depends = 3rdParty_tinyxml
    }

    # Main
    LDView_CUI_OSMesa.file      = $$PWD/OSMesa/LDView_CUI_OSMesa.pro
    LDView_CUI_OSMesa.makefile  = $$MAKEFILE_CUI_OSMESA
    LDView_CUI_OSMesa.target    = sub-LDView_CUI_OSMesa
    LDView_CUI_OSMesa.depends   = LDLib_CUI_OSMesa
    LDView_CUI_OSMesa.depends  += TRE_CUI_OSMesa
    LDView_CUI_OSMesa.depends  += TCFoundation_CUI_OSMesa
    LDView_CUI_OSMesa.depends  += LDLoader_CUI_OSMesa
    LDView_CUI_OSMesa.depends  += LDExporter_CUI_OSMesa
    LDView_CUI_OSMesa.depends  += Headerize_CUI_OSMesa
    contains(USE_3RD_PARTY_PNG, YES):LDView_CUI_OSMesa.depends += 3rdParty_png
    contains(USE_3RD_PARTY_3DS, YES):LDView_CUI_OSMesa.depends += 3rdParty_3ds
    if (USE_3RD_PARTY_LIBS|BUILD_TINYXML) {
        LDView_CUI_OSMesa.depends += 3rdParty_tinyxml
    }
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS) {
        LDView_CUI_OSMesa.depends += 3rdParty_gl2ps
    }
    USE_3RD_PARTY_LIBS:!USE_SYSTEM_LIBS: LDView_CUI_OSMesa.depends += 3rdParty_zlib
}

OTHER_FILES += $$PWD/LDViewMessages.ini \
               $$PWD/cleanup.sh \
               $$PWD/.gitignore

BUILD_ARCH = $$(TARGET_CPU)
!contains(QT_ARCH, unknown):  BUILD_ARCH = $$QT_ARCH
else: isEmpty(BUILD_ARCH):    BUILD_ARCH = UNKNOWN ARCH
CONFIG(debug, debug|release): BUILD = DEBUG BUILD
else:                         BUILD = RELEASE BUILD
message("~~~ LDVIEW $$upper($$BUILD_ARCH) $${BUILD} ON $$upper($$HOST) ~~~")

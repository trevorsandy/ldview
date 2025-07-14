# qmake Configuration settings
# CONFIG+=BUILD_CHECK
# CONFIG+=BUILD_FLATPAK
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_linux_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_msys_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_macos_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_windows_3rdparty
# CONFIG+=USE_3RD_PARTY_LIBS
# CONFIG+=USE_3RD_PARTY_PREBUILT_3DS     # override USE_3RD_PARTY_3DS to use static pre-built lib3ds.a
# CONFIG+=USE_3RD_PARTY_PREBUILT_MINIZIP # override USE_3RD_PARTY_MINIZIP to use static pre-built libminizip.a
# CONFIG+=USE_SYSTEM_LIBS
# CONFIG+=BUILD_PNG          # override USE_SYSTEM_LIBS for libpng
# CONFIG+=BUILD_GL2P         # override USE_SYSTEM_LIBS for libgl2ps
# CONFIG+=BUILD_TINYXML      # override USE_SYSTEM_LIBS for libtinyxml
# CONFIG+=BUILD_MINIZIP      # override USE_SYSTEM_LIBS for libminizip
# CONFIG+=BUILD_GUI_ONLY     # only build Graphic User Interface package
# CONFIG+=BUILD_CUI_ONLY     # only build Console User Interface package
# CONFIG+=CUI_QT             # build CUI using Qt OpenGL
# CONFIG+=CUI_WGL            # build CUI using WGL OpenGL
# CONFIG+=CUI_OSMESA         # build CUI using OSMesa OpenGL - this is the default behaviour
# CONFIG+=OSMESA_NO_LLVM     # LLVM not needed for specified OSMesa configuration
# CONFIG+=USE_EGL            # only compile for EGL - used when libOSMesa is not present, e.g. Arch Linux
# CONFIG+=USE_OSMESA_STATIC  # build static OSMesa libraray and use system LLVM library
# CONFIG+=USE_OSMESA_LOCAL   # use local OSmesa and LLVM libraries - for OBS images w/o OSMesa stuff (e.g. RHEL)
# CONFIG+=USE_SYSTEM_PNG     # override USE_3RD_PARTY_LIBS for libpng
# CONFIG+=USE_SYSTEM_JPEG    # override USE_3RD_PARTY_LIBS for libjpeg
# CONFIG+=USE_SYSTEM_Z       # override USE_3RD_PARTY_LIBS for libz
# CONFIG+=USE_SYSTEM_OSMESA  # override USE_3RD_PARTY_LIBS for OSMesa
# CONFIG+=USE_SYSTEM_MINIZIP # override USE_3RD_PARTY_LIBS for libminizip

# LDView directory and project file structre
# ------------------------------------------
# /LDView
#  |
#  |--- LDView.pro                         Subdirs project file - structures GUI and CUI subdirs
#  |--- LDView_CUI_WGL.pro                 Executable WGL CUI project file - declatations and dirctivies - consumes LDViewGlobal.pri
#  |--- LDViewGlobal.pri                   Global declarations and directives project include
#  |--- LDViewTest.pri                     Executable test project include file - sets up the .ldviewrc and runs a simple rendering test
#  |--- 3rdParty.pri                       3rdParty library declarations and directives project include
#  |
#  `--- /QT
#  |     |--- LDView_GUI_QT.pro            Executable Qt GUI project file - declatations and dirctivies - consumes LDViewGlobal.pri
#  |     |--- LDView_CUI_QT.pro            Executable Qt CUI project file - declarations and directives - consumes LDViewGlobal.pri
#  |
#  `--- /OSMesa
#  |     |--- LDView_CUI_OSMesa.pro        Executable OSMesa CUI project file - declarations and directives - consumes LDViewGlobal.pri
#  |     |--- Headerize_CUI.pro            Executable headerizer project file - declarations and directives - consumes LDViewGlobal.pri
#  |
#  `--- /LDLib
#  |     |--- LDLib.pri                    Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- LDLib_QT.pro                 Library Qt project file - consumes LDLib.pri
#  |     |--- LDLib_OSMesa.pro             Library OSMesa project file - consumes LDLib.pri
#  |
#  `--- /CUI
#  |     |--- CUI.pri                      Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- CUI_WGL.pro                  Library OSMesa project file - consumes CUI.pri
#  |
#  `--- /TRE
#  |     |--- TRE.pri                      Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- TRE_QT.pro                   Library Qt project file - consumes TRE.pri
#  |     |--- TRE_OSMesa.pro               Library OSMesa project file - consumes TRE.pri
#  |
#  `--- /TCFoundation
#  |     |--- TCFoundation.pri             Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- TCFoundation_QT.pro          Library Qt project file - consumes TCFoundation.pri
#  |     |--- TCFoundation_OSMesa.pro      Library OSMesa project file - consumes TCFoundation.pri
#  |
#  `--- /LDLoader
#  |     |--- LDLoader.pri                 Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- LDLoader_QT.pro              Library Qt project file - consumes LDLoader.pri
#  |     |--- LDLoader_OSMesa.pro          Library OSMesa project file - consumes LDLoader.pri
#  |
#  `--- /LDExporter
#  |     |--- LDExporter.pri               Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- LDExporter_QT.pro            Library Qt project file - consumes LDExporter.pri
#  |     |--- LDExporter_OSMesa.pro        Library OSMesa project file - consumes LDExporter.pri
#  |
#  `--- /LGEOTables
#  |     |--- LGEOTables.pri               Library declarations and directives project include - consumes LDViewGlobal.pri
#  |     |--- LGEOTables_CUI.pro           Library OSMesa project file - consumes LDExporter.pri
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
#        |     |--- 3rdParty_minizip.pro   3rdParty library project file - consumes 3rdParty.pri (override with USE_3RD_PARTY_PREBUILT_MINIZIP)
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
CONFIG  += ordered

# Always build tinyxml
!contains(CONFIG, BUILD_TINYXML): \
CONFIG += BUILD_TINYXML

# Except for MSVC (use pre-built), always build 3rd party lib3ds
win32-arm64-msvc|win32-msvc* {
    CONFIG += BUILD_MINIZIP BUILD_GL2PS
} else {
    !USE_3RD_PARTY_PREBUILT_3DS: CONFIG += BUILD_3DS
}

BUILD_3DS {
    USE_3RD_PARTY_3DS = YES
}

# Open Build Service overrides
BUILD_TINYXML {
    USE_3RD_PARTY_TINYXML = YES
}

BUILD_GL2PS {
    USE_3RD_PARTY_GL2PS = YES
}

BUILD_MINIZIP {
    USE_3RD_PARTY_MINIZIP = YES
}

# Ubuntu Trusty uses libpng12 which is too old
if (contains(HOST, Ubuntu):contains(HOST, 14.04.5):USE_SYSTEM_LIBS|BUILD_GL2PS|BUILD_PNG) {
    USE_3RD_PARTY_PNG = YES
}

# Build 3rdParty Libraries'
USE_3RD_PARTY_LIBS {

    SUBDIRS = 3rdParty_zlib
    3rdParty_zlib.file       = $$PWD/3rdParty/zlib/3rdParty_zlib.pro
    3rdParty_zlib.makefile   = Makefile.zlib
    3rdParty_zlib.target     = sub-3rdParty_zlib
    3rdParty_zlib.depends    =

    SUBDIRS += 3rdParty_png
    3rdParty_png.file        = $$PWD/3rdParty/libpng/3rdParty_png.pro
    3rdParty_png.makefile    = Makefile.png
    3rdParty_png.target      = sub-3rdParty_png
    3rdParty_png.depends     =

    SUBDIRS += 3rdParty_jpeg
    3rdParty_jpeg.file       = $$PWD/3rdParty/libjpeg/3rdParty_jpeg.pro
    3rdParty_jpeg.makefile   = Makefile.jpeg
    3rdParty_jpeg.target     = sub-3rdParty_jpeg
    3rdParty_jpeg.depends    =

    SUBDIRS += 3rdParty_tinyxml
    3rdParty_tinyxml.file     = $$PWD/3rdParty/tinyxml/3rdParty_tinyxml.pro
    3rdParty_tinyxml.makefile = Makefile.tinyxml
    3rdParty_tinyxml.target   = sub-3rdParty_tinyxml
    3rdParty_tinyxml.depends  =

    SUBDIRS += 3rdParty_3ds
    3rdParty_3ds.file         = $$PWD/3rdParty/lib3ds/3rdParty_3ds.pro
    3rdParty_3ds.makefile     = Makefile.3ds
    3rdParty_3ds.target       = sub-3rdParty_3ds
    3rdParty_3ds.depends      =

    SUBDIRS += 3rdParty_minizip
    3rdParty_minizip.file     = $$PWD/3rdParty/minizip/3rdParty_minizip.pro
    3rdParty_minizip.makefile = Makefile.minizip
    3rdParty_minizip.target   = sub-3rdParty_minizip
    !USE_SYSTEM_LIBS: 3rdParty_minizip.depends = 3rdParty_zlib

    SUBDIRS += 3rdParty_gl2ps
    3rdParty_gl2ps.file       = $$PWD/3rdParty/gl2ps/3rdParty_gl2ps.pro
    3rdParty_gl2ps.makefile   = Makefile.gl2ps
    3rdParty_gl2ps.target     = sub-3rdParty_gl2ps
    3rdParty_gl2ps.depends    =
}

USE_SYSTEM_LIBS {
    contains(USE_3RD_PARTY_ZLIB, YES) {
        SUBDIRS = 3rdParty_zlib
        3rdParty_zlib.file       = $$PWD/3rdParty/zlib/3rdParty_zlib.pro
        3rdParty_zlib.makefile   = Makefile.zlib
        3rdParty_zlib.target     = sub-3rdParty_zlib
        3rdParty_zlib.depends    =
    }
    contains(USE_3RD_PARTY_JPEG, YES) {
        SUBDIRS += 3rdParty_jpeg
        3rdParty_jpeg.file       = $$PWD/3rdParty/libjpeg/3rdParty_jpeg.pro
        3rdParty_jpeg.makefile   = Makefile.jpeg
        3rdParty_jpeg.target     = sub-3rdParty_jpeg
        3rdParty_jpeg.depends    =
    }
    # always built unless prebuilt instance specified...
    contains(USE_3RD_PARTY_3DS, YES) {
        SUBDIRS = 3rdParty_3ds
        3rdParty_3ds.file         = $$PWD/3rdParty/lib3ds/3rdParty_3ds.pro
        3rdParty_3ds.makefile     = Makefile.3ds
        3rdParty_3ds.target       = sub-3rdParty_3ds
        3rdParty_3ds.depends      =
    }
    # built for Ubuntu Trusty and for libgl2ps for OBS build-from-source requirements
    contains(USE_3RD_PARTY_PNG, YES) {
        SUBDIRS += 3rdParty_png
        3rdParty_png.file         = $$PWD/3rdParty/libpng/3rdParty_png.pro
        3rdParty_png.makefile     = Makefile.png
        3rdParty_png.target       = sub-3rdParty_png
        3rdParty_png.depends      =
    }
    # Open Build Service build-from-source requirements
    contains(USE_3RD_PARTY_TINYXML, YES) {
        SUBDIRS += 3rdParty_tinyxml
        3rdParty_tinyxml.file     = $$PWD/3rdParty/tinyxml/3rdParty_tinyxml.pro
        3rdParty_tinyxml.makefile = Makefile.tinyxml
        3rdParty_tinyxml.target   = sub-3rdParty_tinyxml
        3rdParty_tinyxml.depends  =
    }
    contains(USE_3RD_PARTY_GL2PS, YES) {
        SUBDIRS += 3rdParty_gl2ps
        3rdParty_gl2ps.file       = $$PWD/3rdParty/gl2ps/3rdParty_gl2ps.pro
        3rdParty_gl2ps.makefile   = Makefile.gl2ps
        3rdParty_gl2ps.target     = sub-3rdParty_gl2ps
        3rdParty_gl2ps.depends    = 3rdParty_png
    }
    contains(USE_3RD_PARTY_MINIZIP, YES) {
        SUBDIRS += 3rdParty_minizip
        3rdParty_minizip.file     = $$PWD/3rdParty/minizip/3rdParty_minizip.pro
        3rdParty_minizip.makefile = Makefile.minizip
        3rdParty_minizip.target   = sub-3rdParty_minizip
        3rdParty_minizip.depends  =
    }
}

# Build Qt Graphic User Interface (GUI)
contains(BUILD_GUI, YES) {

    POSTFIX  = QT

    SUBDIRS += LDLib_$${POSTFIX} \
               TRE_$${POSTFIX} \
               TCFoundation_$${POSTFIX} \
               LDLoader_$${POSTFIX} \
               LDExporter_$${POSTFIX} \
               LDView_GUI_$${POSTFIX}

    LDLib_$${POSTFIX}.file     = $$PWD/LDLib/LDLib_$${POSTFIX}.pro
    LDLib_$${POSTFIX}.makefile = Makefile-ldlib.$$lower($${POSTFIX})
    LDLib_$${POSTFIX}.target   = sub-LDLib_$${POSTFIX}
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS): \
    LDLib_$${POSTFIX}.depends  = 3rdParty_gl2ps

    TRE_$${POSTFIX}.file     = $$PWD/TRE/TRE_$${POSTFIX}.pro
    TRE_$${POSTFIX}.makefile = Makefile-tre.$$lower($${POSTFIX})
    TRE_$${POSTFIX}.target   = sub-TRE_$${POSTFIX}
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS): \
    TRE_$${POSTFIX}.depends  = 3rdParty_gl2ps

    TCFoundation_$${POSTFIX}.file     = $$PWD/TCFoundation/TCFoundation_$${POSTFIX}.pro
    TCFoundation_$${POSTFIX}.makefile = Makefile-headerize.$$lower($${POSTFIX})
    TCFoundation_$${POSTFIX}.target   = sub-TCFoundation_$${POSTFIX}
    USE_3RD_PARTY_LIBS: \
    TCFoundation_$${POSTFIX}.depends  = 3rdParty_minizip

    LDLoader_$${POSTFIX}.file     = $$PWD/LDLoader/LDLoader_$${POSTFIX}.pro
    LDLoader_$${POSTFIX}.makefile = Makefile-ldloader.$$lower($${POSTFIX})
    LDLoader_$${POSTFIX}.target   = sub-LDLoader_$${POSTFIX}
    LDLoader_$${POSTFIX}.depends  =

    LDExporter_$${POSTFIX}.file     = $$PWD/LDExporter/LDExporter_$${POSTFIX}.pro
    LDExporter_$${POSTFIX}.makefile = Makefile-ldexporter.$$lower($${POSTFIX})
    LDExporter_$${POSTFIX}.target   = sub-LDExporter_$${POSTFIX}
    if (USE_3RD_PARTY_LIBS|BUILD_TINYXML): \
    LDExporter_$${POSTFIX}.depends  = 3rdParty_tinyxml

    # Main
    LDView_GUI_$${POSTFIX}.file      = $$PWD/$${POSTFIX}/LDView_GUI_$${POSTFIX}.pro
    LDView_GUI_$${POSTFIX}.makefile  = Makefile.$$lower($${POSTFIX})
    LDView_GUI_$${POSTFIX}.target    = sub-LDView_GUI_$${POSTFIX}
    LDView_GUI_$${POSTFIX}.depends   = LDLib_$${POSTFIX}
    LDView_GUI_$${POSTFIX}.depends  += TRE_$${POSTFIX}
    LDView_GUI_$${POSTFIX}.depends  += TCFoundation_$${POSTFIX}
    LDView_GUI_$${POSTFIX}.depends  += LDLoader_$${POSTFIX}
    LDView_GUI_$${POSTFIX}.depends  += LDExporter_$${POSTFIX}
    contains(USE_3RD_PARTY_PNG, YES): \
    LDView_GUI_$${POSTFIX}.depends  += 3rdParty_png
    contains(USE_3RD_PARTY_3DS, YES): \
    LDView_GUI_$${POSTFIX}.depends  += 3rdParty_3ds
    USE_3RD_PARTY_LIBS: \
    LDView_GUI_$${POSTFIX}.depends  += 3rdParty_minizip
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS): \
    LDView_GUI_$${POSTFIX}.depends  += 3rdParty_gl2ps
    USE_3RD_PARTY_LIBS:!USE_SYSTEM_LIBS: \
    LDView_GUI_$${POSTFIX}.depends  += 3rdParty_zlib
}

# Build Qt/OSMesa/WinDB Console User Interface (CUI)
contains(BUILD_CUI, YES) {

    # Qt/OSMesa library identifiers
    CUI_QT: \
    POSTFIX  = QT
    else: CUI_WGL: \
    POSTFIX  = WGL
    else: \
    POSTFIX  = OSMesa

    contains(POSTFIX,WGL): \
    SUBDIRS += CUI_$${POSTFIX}
    SUBDIRS += LDLib_$${POSTFIX} \
               TRE_$${POSTFIX} \
               TCFoundation_$${POSTFIX} \
               LDLoader_$${POSTFIX} \
               LDExporter_$${POSTFIX} \
               Headerize_CUI \
               LGEOTables_CUI \
               LDView_CUI_$${POSTFIX}

    CUI_$${POSTFIX}.file     = $$PWD/CUI/CUI_$${POSTFIX}.pro
    CUI_$${POSTFIX}.makefile = Makefile-cui.$$lower($${POSTFIX})
    CUI_$${POSTFIX}.target   = sub-CUI_$${POSTFIX}
    CUI_$${POSTFIX}.depends  =

    LDLib_$${POSTFIX}.file     = $$PWD/LDLib/LDLib_$${POSTFIX}.pro
    LDLib_$${POSTFIX}.makefile = Makefile-ldlib.$$lower($${POSTFIX})
    LDLib_$${POSTFIX}.target   = sub-LDLib_$${POSTFIX}
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS): \
    LDLib_$${POSTFIX}.depends  = 3rdParty_gl2ps

    TRE_$${POSTFIX}.file     = $$PWD/TRE/TRE_$${POSTFIX}.pro
    TRE_$${POSTFIX}.makefile = Makefile-tre.$$lower($${POSTFIX})
    TRE_$${POSTFIX}.target   = sub-TRE_$${POSTFIX}
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS): \
    TRE_$${POSTFIX}.depends  = 3rdParty_gl2ps

    TCFoundation_$${POSTFIX}.file     = $$PWD/TCFoundation/TCFoundation_$${POSTFIX}.pro
    TCFoundation_$${POSTFIX}.makefile = Makefile-tcfoundation.$$lower($${POSTFIX})
    TCFoundation_$${POSTFIX}.target   = sub-TCFoundation_$${POSTFIX}
    USE_3RD_PARTY_LIBS: \
    TCFoundation_$${POSTFIX}.depends  = 3rdParty_minizip

    LDLoader_$${POSTFIX}.file     = $$PWD/LDLoader/LDLoader_$${POSTFIX}.pro
    LDLoader_$${POSTFIX}.makefile = Makefile-ldloader.$$lower($${POSTFIX})
    LDLoader_$${POSTFIX}.target   = sub-LDLoader_$${POSTFIX}
    LDLoader_$${POSTFIX}.depends  =

    LDExporter_$${POSTFIX}.file     = $$PWD/LDExporter/LDExporter_$${POSTFIX}.pro
    LDExporter_$${POSTFIX}.makefile = Makefile-ldexporter.$$lower($${POSTFIX})
    LDExporter_$${POSTFIX}.target   = sub-LDExporter_$${POSTFIX}
    if (USE_3RD_PARTY_LIBS|BUILD_TINYXML): \
    LDExporter_$${POSTFIX}.depends  = 3rdParty_tinyxml

    # Headerize utility
    Headerize_CUI.file     = $$PWD/OSMesa/Headerize_CUI.pro
    Headerize_CUI.makefile = Makefile-headerize.$$lower($${POSTFIX})
    Headerize_CUI.target   = sub-Headerize_CUI
    Headerize_CUI.depends  = TCFoundation_$${POSTFIX}
    if (USE_3RD_PARTY_LIBS:!USE_SYSTEM_LIBS): \
    Headerize_CUI.depends += 3rdParty_zlib

    # LGEOTables utility
    LGEOTables_CUI.file     = $$PWD/LGEOTables/LGEOTables_CUI.pro
    LGEOTables_CUI.makefile = Makefile-lgeotables.$$lower($${POSTFIX})
    LGEOTables_CUI.target   = sub-LGEOTables_CUI
    if (USE_3RD_PARTY_LIBS|BUILD_TINYXML): \
    LGEOTables_CUI.depends  = 3rdParty_tinyxml

    # Main
    contains(POSTFIX,WGL): \
    PROJECT_FILE = $$PWD/LDView_CUI_$${POSTFIX}.pro
    else: \
    PROJECT_FILE = $$PWD/$${POSTFIX}/LDView_CUI_$${POSTFIX}.pro
    LDView_CUI_$${POSTFIX}.file      = $${PROJECT_FILE}
    LDView_CUI_$${POSTFIX}.makefile  = Makefile.$$lower($${POSTFIX})
    LDView_CUI_$${POSTFIX}.target    = sub-LDView_CUI_$${POSTFIX}
    LDView_CUI_$${POSTFIX}.depends   = LDLib_$${POSTFIX}
    LDView_CUI_$${POSTFIX}.depends  += TRE_$${POSTFIX}
    LDView_CUI_$${POSTFIX}.depends  += TCFoundation_$${POSTFIX}
    LDView_CUI_$${POSTFIX}.depends  += LDLoader_$${POSTFIX}
    LDView_CUI_$${POSTFIX}.depends  += LDExporter_$${POSTFIX}
    contains(POSTFIX,WGL): \
    LDView_CUI_$${POSTFIX}.depends  += CUI_$${POSTFIX}
    LDView_CUI_$${POSTFIX}.depends  += Headerize_CUI
    contains(USE_3RD_PARTY_PNG, YES): \
    LDView_CUI_$${POSTFIX}.depends  += 3rdParty_png
    contains(USE_3RD_PARTY_3DS, YES): \
    LDView_CUI_$${POSTFIX}.depends  += 3rdParty_3ds
    if (USE_3RD_PARTY_LIBS|BUILD_TINYXML): \
    LDView_CUI_$${POSTFIX}.depends  += 3rdParty_tinyxml
    if (USE_3RD_PARTY_LIBS|BUILD_GL2PS): \
    LDView_CUI_$${POSTFIX}.depends  += 3rdParty_gl2ps
    if (USE_3RD_PARTY_LIBS|BUILD_MINIZIP): \
    LDView_CUI_$${POSTFIX}.depends  += 3rdParty_minizip
    if (USE_3RD_PARTY_LIBS:!USE_SYSTEM_LIBS): \
    LDView_CUI_$${POSTFIX}.depends  += 3rdParty_zlib
}

OTHER_FILES += $$PWD/LDViewMessages.ini \
               $$PWD/8464.mpd \
               $$PWD/cleanup.sh \
               $$PWD/.gitignore \
               $$PWD/.github/workflows/build.yml \
               $$PWD/.github/workflows/codeql.yml \
               $$PWD/build.cmd \
               $$PWD/ImageInfo.bat \
               $$PWD/QT/PKGBUILD \
               $$PWD/QT/APKBUILD \
               $$PWD/QT/builddmg.sh \
               $$PWD/QT/LDView.spec \
               $$PWD/QT/CMakeLists.txt \
               $$PWD/QT/OBS/_service \
               $$PWD/QT/OBS/_service_obs_scm \
               $$PWD/QT/OBS/appimage.yml \
               $$PWD/QT/OBS/backup.sh \
               $$PWD/QT/OBS/flatpak.yaml \
               $$PWD/QT/OBS/LDView.dsc \
               $$PWD/QT/OBS/LDView-qt5.dsc \
               $$PWD/QT/OBS/LDView-qt6.dsc \
               $$PWD/QT/debian/control \
               $$PWD/QT/debian/rules \
               $$PWD/QT/debian/source/local-options \
               $$PWD/QT/docker/compile.sh \
               $$PWD/QT/docker/docker.sh \
               $$PWD/QT/docker/docker-compose.yml \
               $$PWD/QT/docker/docker-desktop.sh \
               $$PWD/QT/docker/install-devel-packages.sh \
               $$PWD/QT/docker/os-report.sh \
               $$PWD/QT/docker/query-package.sh


BUILD_ARCH = $$(TARGET_CPU)
isEmpty(BUILD_ARCH): \
!contains(QT_ARCH, unknown): \
BUILD_ARCH = $$QT_ARCH
isEmpty(BUILD_ARCH): BUILD_ARCH = UNKNOWN ARCH
CONFIG(debug, debug|release): BUILD = DEBUG BUILD
else:                         BUILD = RELEASE BUILD
msys:                         BUILD = MSYS $$BUILD
USE_SYSTEM_LIBS:              WHICH_LIBS = SYSTEM
else: USE_3RD_PARTY_LIBS:     WHICH_LIBS = 3RD PARTY
else:                         WHICH_LIBS = PRE-COMPILED
static|staticlib:             TYPE  = STATIC
else:                         TYPE  = SHARED
message("~~~ LDVIEW $$upper($$BUILD_ARCH) $${BUILD} ON $$upper($$HOST) ~~~")
contains(BUILD_CUI, NO): \
message("~~~ BUILDING LDVIEW $${TYPE} $${POSTFIX} GRAPHIC USER INTERFACE MODULE ONLY ~~~")
else: contains(BUILD_GUI, NO): \
message("~~~ BUILDING LDVIEW $${TYPE} $${POSTFIX} CONSOLE USER INTERFACE MODULE ONLY ~~~")
else: \
message("~~~ BUILDING LDVIEW $${TYPE} $${POSTFIX} GRAPHIC AND CONSOLE USER INTERFACE MODULES ~~~")
message("~~~ LDVIEW USING $${WHICH_LIBS} AND $${POSTFIX} OPENGL LIBS ~~~")
msys: message("~~~ MSYS2 SYSTEM_PREFIX $${PREFIX} ~~~ ")
#message("~~~ DEBUG_CONFIG: $$CONFIG ~~~")

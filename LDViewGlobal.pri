# qmake Configuration settings
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_linux_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_macos_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_windows_3rdparty
# CONFIG+=USE_3RD_PARTY_LIBS
# CONFIG+=USE_SYSTEM_LIBS
# CONFIG+=BUILD_GUI_ONLY
# CONFIG+=BUILD_CUI_ONLY
# CONFIG+=USE_SYSTEM_PNG     # override USE_3RD_PARTY_LIBS for libPng
# CONFIG+=USE_SYSTEM_JPEG    # override USE_3RD_PARTY_LIBS for libJpeg
# CONFIG+=USE_SYSTEM_Z       # override USE_3RD_PARTY_LIBS for libz
# CONFIG+=USE_SYSTEM_OSMESA  # override USE_3RD_PARTY_LIBS for OSMesa

# LDView global directives

# Get fine-grained host identification
win32:HOST = $$system(systeminfo | findstr /B /C:"OS Name")
unix:!macx:HOST = $$system(. /etc/os-release && if test \"$PRETTY_NAME\" != \"\"; then echo \"$PRETTY_NAME\"; else echo `uname`; fi)
macx:HOST = $$system(echo `sw_vers -productName` `sw_vers -productVersion`)

# Ubuntu Trusty uses libpng12 which is too old
contains(HOST, Ubuntu):contains(HOST, 14.04.5): \
USE_SYSTEM_LIBS {
    USE_3RD_PARTY_PNG = YES
}
# Macos homebrew only updates tinyxml2
contains(HOST, Mac):contains(HOST, OS): \
USE_SYSTEM_LIBS {
    USE_3RD_PARTY_TINYXML = YES
}

# system lib3ds dpoes not appear to have lib3ds.h - so always use 3rd party version
USE_3RD_PARTY_3DS = YES

# GUI/CUI switch
contains(DEFINES, _QT):     CONFIG += _QT_GUI
contains(DEFINES, _OSMESA): CONFIG += _OSM_CUI

# platform switch
contains(QT_ARCH, x86_64): ARCH = 64
else:                      ARCH = 32

# build type
CONFIG(debug, debug|release) {
    BUILD = DEBUG
    DESTDIR = $$join(ARCH,,,bit_debug)
} else {
    BUILD = RELEASE
    DESTDIR = $$join(ARCH,,,bit_release)
}

# GUI/CUI environment identifiers
_QT_GUI {
    POSTFIX  = -qt$${QT_MAJOR_VERSION}
    BUILD   += QT
} else: _OSM_CUI {
    POSTFIX  = -osmesa
    BUILD   += OSMESA
}
BUILD += BUILD ON $$upper($$HOST)

# 3ds
!freebsd: DEFINES   += EXPORT_3DS
else:     DEFINES   -= EXPORT_3DS

# Basically, this project include file is set up to allow some options for selecting your LDView libraries.
# The default is to select the pre-defined libraries in ../lib and headers in ../include.
# The is an option to build all the libraries dynamically as you compile the solution.
# This option is enabled by setting the directive CONFIG+=USE_3RD_PARTY_LIBS. On MacOSX, you can
# choose to use the navive X11 OSMesa and GL drivers at /usr/X11 by selecting the directive
# CONFIG+=USE_SYSTEM_OSMESA_LIBS. On Note that these options USE_3RD_PARTY_LIBS and  USE_SYSTEM_OSMESA_LIBS
# are mutually exclusive.
# Additionally, you have the option to use system library path(s) to access libraries
# you may already have on your system e.g. usr/include and usr/lib. To enable this
# option, be sure to set SYSTEM_PREFIX_ below along with the directive CONFIG+=USE_SYSTEM_LIBS

# 3rdParty libraries - compiled from source during build (some, not all)
3RD_PARTY_PREFIX_       = ../3rdParty

# You can modify library paths below to match your system
# for default settings, place headers in ../include/..
# place required pre-compiled static libs in ../lib/..
# You may also set alternative locations for your libraries and headers
unix {
    # System libraries - on Unix, change to or add /usr/local if you want
    SYSTEM_PREFIX_  = /usr

    # Static library extension
    S_EXT_          = a

    # pre-compiled libraries heaers location
    LIBINC_         = $$_PRO_FILE_PWD_/../include       # zlib.h and zconf.h, glext and wglext headers

    # base names
    USE_SYSTEM_LIBS {
        LIB_PNG    = png
        LIB_OSMESA = OSMesa
    } else {
        LIB_PNG    = png16
        LIB_OSMESA = OSMesa32
    }
    LIB_JPEG       = jpeg
    LIB_GLU        = GLU
    LIB_GL2PS      = gl2ps
    LIB_Z          = z
    LIB_TINYXML    = tinyxml
    LIB_3DS        = 3ds

    macx {
        # pre-compiled libraries location
        LIBDIR_     = $$_PRO_FILE_PWD_/../lib/MacOSX
        # dynamic library extension
        EXT_        = dylib

        # frameworks
        OSX_FRAMEWORKS_CORE = -framework CoreFoundation -framework CoreServices

    } else {
        # pre-compiled libraries location
        equals(ARCH, 64): LIBDIR_ = $$_PRO_FILE_PWD_/../lib/Linux/x86_64
        else:             LIBDIR_ = $$_PRO_FILE_PWD_/../lib/Linux/i386

        # dynamic library extension
        EXT_        = so
    }

} else {
    # Windows MinGW stuff...
    SYSTEM_PREFIX_  = C:/Program Files
    # dynamic library extensions
    EXT_            = dll
    # static library extensions
    S_EXT_          = a

    # base names
    LIB_PNG       = png16
    LIB_JPEG      = jpeg
    LIB_OSMESA    = OSMesa32
    LIB_GLU       = GLU
    LIB_GL2PS     = gl2ps
    LIB_Z         = z
    LIB_TINYXML   = tinyxml
    LIB_3DS       = 3ds
}

# pre-compiled libraries
# Library variables - you can modify the items below if
# you want to set individual libray paths/names etc...

LIBS_INC            = $${LIBINC_}
LIBS_DIR            = -L$${LIBDIR_}
# -------------------------------
WHICH_LIBS          = PRE-COMPILED

PNG_INC             = $${LIBINC_}
PNG_LIBDIR          = -L$${LIBDIR_}

JPEG_INC            = $${LIBINC_}
JPEG_LIBDIR         = -L$${LIBDIR_}

GL2PS_INC           = $${LIBINC_}
GL2PS_LIBDIR        = -L$${LIBDIR_}

TINYXML_INC         = $${LIBINC_}
TINYXML_LIBDIR      = -L$${LIBDIR_}

3DS_INC             = $${LIBINC_}
3DS_LIBDIR          = -L$${LIBDIR_}

ZLIB_INC            = $${LIBINC_}
ZLIB_LIBDIR         = -L$${LIBDIR_}

OSMESA_INC          = $${LIBINC_}
OSMESA_LIBDIR       = -L$${LIBDIR_}
OSMESA_LDLIBS       = $${LIBDIR_}/lib$${LIB_OSMESA}.$${S_EXT_} \
                      $${LIBDIR_}/lib$${LIB_GLU}.$${S_EXT_}

MINIZIP_INC         = $${LIBINC_}
MINIZIP_LIBDIR      = -L$${LIBDIR_}

# Update Libraries
# ===============================
LIBS_PRI            = -l$${LIB_PNG} \
                      -l$${LIB_JPEG} \
                      -l$${LIB_GL2PS} \
                      -l$${LIB_TINYXML} \
                      -l$${LIB_Z}

# conditional libraries
contains(DEFINES, EXPORT_3DS) {
    LIBS_PRI += -l$${LIB_3DS}
}

contains(HOST, Fedora):contains(HOST, 25): \
USE_SYSTEM_LIBS {
    LIBS_PRI += -lGL
}

# 3rd party libreries - compiled from source
# Be careful not to move this chunk. moving it will affect to overall logic flow.
USE_3RD_PARTY_LIBS {
    WHICH_LIBS      = 3RD PARTY

    # headers and static compiled libs
    GL2PS_INC       = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/gl2ps
    GL2PS_LIBDIR    = -L$${3RD_PARTY_PREFIX_}/gl2ps/$$DESTDIR

    MINIZIP_INC     = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/minizip
    MINIZIP_LIBDIR  = -L$${3RD_PARTY_PREFIX_}/minizip/$$DESTDIR

    TINYXML_INC     = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/tinyxml
    TINYXML_LIBDIR  = -L$${3RD_PARTY_PREFIX_}/tinyxml/$$DESTDIR

    3DS_INC         = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/lib3ds
    3DS_LIBDIR      = -L$${3RD_PARTY_PREFIX_}/lib3ds/$$DESTDIR

    JPEG_INC        = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/libjpeg
    JPEG_LIBDIR     = -L$${3RD_PARTY_PREFIX_}/libjpeg/$$DESTDIR

    PNG_INC         = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/libpng
    PNG_LIBDIR      = -L$${3RD_PARTY_PREFIX_}/libpng/$$DESTDIR

    ZLIB_INC        = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/zlib
    ZLIB_LIBDIR     = -L$${3RD_PARTY_PREFIX_}/zlib/$$DESTDIR

    # overwrite pre-compiled path (reset) with 3rd party path
    # ===============================
    LIBS_INC =  $${PNG_INC} \
                $${JPEG_INC} \
                $${TINYXML_INC} \
                $${3DS_INC} \
                $${MINIZIP_INC} \
                $${GL2PS_INC} \
                $${ZLIB_INC}

    _OSM_CUI: LIBS_INC += $${OSMESA_INC}

    LIBS_DIR =  $${PNG_LIBDIR} \
                $${JPEG_LIBDIR} \
                $${TINYXML_LIBDIR} \
                $${3DS_LIBDIR} \
                $${MINIZIP_LIBDIR} \
                $${GL2PS_LIBDIR} \
                $${ZLIB_LIBDIR}

    _OSM_CUI: LIBS_DIR += $${OSMESA_LIBDIR}
}

unix {
    # Be careful not to move these chunks. moving it will affect to overall logic flow.

    # detect system libraries paths
    SYS_LIBINC_         = $${SYSTEM_PREFIX_}/include
    macx {                                                           # OSX
        SYS_LIBINC_     = $${SYSTEM_PREFIX_}/local/include \
                          $${SYSTEM_PREFIX_}/X11/include
        SYS_LIBDIR_     = $${SYSTEM_PREFIX_}/local/lib \
                          $${SYSTEM_PREFIX_}/X11/lib
    } else: exists($${SYSTEM_PREFIX_}/lib/$$QT_ARCH-linux-gnu) {     # Debian
        SYS_LIBDIR_     = $${SYSTEM_PREFIX_}/lib/$$QT_ARCH-linux-gnu
    } else: exists($${SYSTEM_PREFIX_}/lib$$ARCH/) {                  # RedHat (64bit)
        SYS_LIBDIR_     = $${SYSTEM_PREFIX_}/lib$$ARCH
    } else {                                                         # Arch, RedHat (32bit)
        SYS_LIBDIR_     = $${SYSTEM_PREFIX_}/lib
    }

    USE_3RD_PARTY_LIBS {
        # detect system libraries
        _LIB_OSMESA = OSMesa
        _LIB_PNG    = png
        USE_SYSTEM_OSMESA:exists($${SYS_LIBDIR_}/lib$${_LIB_OSMESA}.$${EXT_}):_OSM_CUI: USE_SYSTEM_OSMESA_LIB = YES
        USE_SYSTEM_PNG:!USE_3RD_PARTY_PNG:exists($${SYS_LIBDIR_}/lib$${_LIB_PNG}.$${EXT_}): USE_SYSTEM_PNG_LIB = YES
        USE_SYSTEM_JPEG:exists($${SYS_LIBDIR_}/lib$${LIB_JPEG}.$${EXT_}): USE_SYSTEM_JPEG_LIB = YES
        USE_SYSTEM_Z:exists($${SYS_LIBDIR_}/libz.$${EXT_}): USE_SYSTEM_Z_LIB = YES

        # override 3rd party library paths
        contains(USE_SYSTEM_OSMESA_LIB, YES): _OSM_CUI {
            # use sytem lib name
            LIB_OSMESA          = OSMesa
            # remove 3rdParty lib reference
            USE_3RD_PARTY_LIBS {
                LIBS_INC       -= $${OSMESA_INC}
                LIBS_DIR       -= $${OSMESA_LIBDIR}
            }
            # reset individual library entry
            OSMESA_INC          = $${SYS_LIBINC_}
            OSMESA_LIBDIR       = -L$${SYS_LIBDIR_}
            OSMESA_LDLIBS       = $${SYS_LIBDIR_}/lib$${LIB_OSMESA}.$${EXT_} \
                                  $${SYS_LIBDIR_}/lib$${LIB_GLU}.$${EXT_}
        }

        contains(USE_SYSTEM_PNG_LIB, YES) {
            # remove lib reference
            LIBS_PRI     -= -l$${LIB_PNG}
            # use sytem lib name - only macos will trigger this logic
            LIB_PNG       = png
            # remove 3rdParty lib reference
            USE_3RD_PARTY_LIBS {
                LIBS_INC -= $${PNG_INC}
                LIBS_DIR -= $${PNG_LIBDIR}
            }
            # reset individual library entry
            PNG_INC       = $${SYS_LIBINC_}
            PNG_LIBDIR    = -L$${SYS_LIBDIR_}
            PNG_LDLIBS    = $${SYS_LIBDIR_}/lib$${LIB_PNG}.$${EXT_}
        }

        contains(USE_SYSTEM_JPEG_LIB, YES) {
            # remove lib reference
            LIBS_PRI     -= -l$${LIB_JPEG}
            # remove 3rdParty lib reference
            USE_3RD_PARTY_LIBS {
                LIBS_INC -= $${JPEG_INC}
                LIBS_DIR -= $${JPEG_LIBDIR}
            }
            # reset individual library entry
            JPEG_INC      = $${SYS_LIBINC_}
            JPEG_LIBDIR   = -L$${SYS_LIBDIR_}
            JPEG_LDLIBS   = $${SYS_LIBDIR_}/lib$${LIB_JPEG}.$${EXT_}
        }

        contains(USE_SYSTEM_Z_LIB, YES) {
            # remove lib reference
            LIBS_PRI     -= -l$${LIB_Z}
            # remove 3rdParty lib reference
            USE_3RD_PARTY_LIBS {
                LIBS_INC -= $${ZLIB_INC}
                LIBS_DIR -= $${ZLIB_LIBDIR}
            }
            # reset individual library entry
            ZLIB_INC      = $${SYS_LIBINC_}
            ZLIB_LIBDIR   = -L$${SYS_LIBDIR_}
            ZLIB_LDLIBS   = $${SYS_LIBDIR_}/lib$${LIB_Z}.$${EXT_}
        }
    }

    USE_SYSTEM_LIBS {
        WHICH_LIBS          = SYSTEM

        # update base names
        LIB_OSMESA          = OSMesa
        LIB_PNG             = png

        # remove pre-compiled libs path
        LIBS_INC           -= -L$${LIBINC_}
        LIBS_DIR           -= -L$${LIBDIR_}

        # append system library paths
        # ===============================}
        LIBS_INC           += $${SYS_LIBINC_}
        LIBS_DIR           += -L$${SYS_LIBDIR_}

        # -------------------------------
        GL2PS_INC           = $${SYS_LIBINC_}
        GL2PS_LIBDIR        = -L$${SYS_LIBDIR_}

        TINYXML_INC         = $${SYS_LIBINC_}
        TINYXML_LIBDIR      = -L$${SYS_LIBDIR_}

        MINIZIP_INC         = $${SYS_LIBINC_}
        MINIZIP_LIBDIR      = -L$${SYS_LIBDIR_}

        3DS_INC             = $${SYS_LIBINC_}
        3DS_LIBDIR          = -L$${SYS_LIBDIR_}

        PNG_INC             = $${SYS_LIBINC_}
        PNG_LIBDIR          = -L$${SYS_LIBDIR_}

        JPEG_INC            = $${SYS_LIBINC_}
        JPEG_LIBDIR         = -L$${SYS_LIBDIR_}

        ZLIB_INC            = $${SYS_LIBINC_}
        ZLIB_LIBDIR         = -L$${SYS_LIBDIR_}

        OSMESA_INC          = $${SYS_LIBINC_}
        OSMESA_LIBDIR       = -L$${SYS_LIBDIR_}
        OSMESA_LDLIBS       = $${SYS_LIBDIR_}/lib$${LIB_OSMESA}.$${EXT_} \
                              $${SYS_LIBDIR_}/lib$${LIB_GLU}.$${EXT_}

        # override system libraries with 3rd party library paths as specified
        contains(USE_3RD_PARTY_PNG, YES) {
            # remove lib reference
            LIBS_PRI       -= -l$${LIB_PNG}
            # update base name
            LIB_PNG         = png16
            # reset individual library entry
            PNG_INC         = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/libpng
            PNG_LIBDIR      = -L$${3RD_PARTY_PREFIX_}/libpng/$$DESTDIR
            PNG_LDLIBS      = $${3RD_PARTY_PREFIX_}/libpng/$$DESTDIR/lib$${LIB_PNG}.$${S_EXT_}
            # update libs path
            LIBS_INC       += $${PNG_INC}
            #LIBS_DIR       += $${PNG_LIBDIR}
        }

        contains(USE_3RD_PARTY_TINYXML, YES) {
            # remove lib reference
            LIBS_PRI       -= -l$${LIB_TINYXML}
            # reset individual library entry
            TINYXML_INC     = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/tinyxml
            TINYXML_LIBDIR  = -L$${3RD_PARTY_PREFIX_}/tinyxml/$$DESTDIR
            TINYXML_LDLIBS  = $${3RD_PARTY_PREFIX_}/tinyxml/$$DESTDIR/lib$${LIB_TINYXML}.$${S_EXT_}
            # update libs path
            LIBS_INC       += $${TINYXML_INC}
            #LIBS_DIR       += $${TINYXML_LIBDIR}
        }

        contains(USE_3RD_PARTY_JPEG, YES) {
            # remove lib reference
            LIBS_PRI       -= -l$${LIB_JPEG}
            # reset individual library entry
            JPEG_INC        = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/libJPEG
            JPEG_LIBDIR     = -L$${3RD_PARTY_PREFIX_}/libJPEG/$$DESTDIR
            JPEG_LDLIBS     = $${3RD_PARTY_PREFIX_}/libJPEG/$$DESTDIR/lib$${LIB_JPEG}.$${S_EXT_}
            # update libs path
            LIBS_INC       += $${JPEG_INC}
            #LIBS_DIR       += $${JPEG_LIBDIR}
        }

        contains(USE_3RD_PARTY_3DS, YES) {
            # remove lib reference
            LIBS_PRI       -= -l$${LIB_3DS}
            # reset individual library entry
            3DS_INC         = $$_PRO_FILE_PWD_/$${3RD_PARTY_PREFIX_}/lib3ds
            3DS_LIBDIR      = -L$${3RD_PARTY_PREFIX_}/lib3ds/$$DESTDIR
            3DS_LDLIBS      = $${3RD_PARTY_PREFIX_}/lib3ds/$$DESTDIR/lib$${LIB_3DS}.$${S_EXT_}
            # update libs path
            LIBS_INC       += $${3DS_INC}
            #LIBS_DIR       += $${3DS_LIBDIR}
        }
    }
}

message("~~~ USING $${WHICH_LIBS} LIBS ~~~")

DEPENDPATH  += .
INCLUDEPATH += . ..

# USE GNU_SOURCE
unix:!macx: DEFINES += _GNU_SOURCE

# USE CPP 11
DEFINES += USE_CPP11
contains(DEFINES, USE_CPP11) {
    unix:!freebsd:!macx {
        GCC_VERSION = $$system(g++ -dumpversion)
        greaterThan(GCC_VERSION, 4.6) {
            QMAKE_CXXFLAGS += -std=c++11
        } else {
            QMAKE_CXXFLAGS += -std=c++0x
        }
    } else {
        CONFIG += c++11
    }
}

# Boost
!contains(CONFIG, USE_BOOST): {
    DEFINES		+= _NO_BOOST
} else {
    INCLUDEPATH         += $$_PRO_FILE_PWD_/../boost/include
    LIBS 		+= -L$$_PRO_FILE_PWD_/../boost/lib
}

# dirs
OBJECTS_DIR        = $$DESTDIR/.obj$${POSTFIX}
win32 {
    CONFIG        += windows
    QMAKE_EXT__OBJ = .obj
}

# Platform-specific
unix {
    freebsd {
        LIBS_INC  +=  /usr/local/include
    }

    # slurm is media.peeron.com
    OSTYPE = $$system(hostname)
    contains(OSTYPE, slurm) {
        OSMESA_INC  += ../../Mesa-7.0.2/include
    }

    OSTYPE = $$system(hostname | cut -d. -f2-)
    contains(OSTYPE, pair.com) {
        LIBS_INC    +=  /usr/local/include
        OSMESA_INC  += $$_PRO_FILE_PWD_/../../Mesa-7.11/include
        DEFINES	+= _GL_POPCOLOR_BROKEN
    }

    exists (/usr/include/qt3) {
        LIBS_INC    +=    += /usr/include/qt3
    }
}

# suppress warnings
QMAKE_CFLAGS_WARN_ON =  -Wall -W \
                        -Wno-unused-parameter \
                        -Wno-parentheses \
                        -Wno-unused-variable \
                        -Wno-deprecated-declarations \
                        -Wno-return-type \
                        -Wno-sign-compare \
                        -Wno-uninitialized \
                        -Wno-unused-result
macx {
QMAKE_CFLAGS_WARN_ON += -Wno-implicit-function-declaration \
                        -Wno-incompatible-pointer-types-discards-qualifiers \
                        -Wno-incompatible-pointer-types \
                        -Wno-undefined-bool-conversion \
                        -Wno-invalid-source-encoding \
                        -Wno-mismatched-new-delete \
                        -Wno-for-loop-analysis \
                        -Wno-int-conversion \
                        -Wno-reorder
} else {
QMAKE_CFLAGS_WARN_ON += -Wno-clobbered
}
QMAKE_CXXFLAGS_WARN_ON = $${QMAKE_CFLAGS_WARN_ON}

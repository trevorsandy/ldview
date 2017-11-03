
# LDView global directives

#Uncomment right side of directive to manually enable
!contains(CONFIG, USE_3RD_PARTY_LIBS):      # CONFIG+=USE_3RD_PARTY_LIBS        # must also manually set/unset in LDView.pro
!contains(CONFIG, USE_SYSTEM_LIBS):         # CONFIG+=USE_SYSTEM_LIBS           # must also manually set/unset in LDView.pro
!contains(CONFIG, USE_SYSTEM_OSMESA):       # CONFIG+=USE_SYSTEM_OSMESA         # override USE_3RD_PARTY_LIBS for OSMesa libs

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
    LIB_3DS     = 3ds
    LIB_PNG     = png16
    LIB_JPEG    = jpeg
    LIB_OSMESA  = OSMesa32
    LIB_GLU     = GLU

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
    LIB_3DS     = 3ds
    LIB_PNG     = png16
    LIB_JPEG    = jpeg
    LIB_OSMESA  = OSMesa32
    LIB_GLU     = GLU
}

# pre-compiled libraries
# Library variables - you can modify the items below if
# you want to set individual libray paths/names etc...

LIBS_INC            = $${LIBINC_}
LIBS_DIR            = -L$${LIBDIR_}
# -------------------------------
WHICH_LIBS = PRE-COMPILED

GL2PS_INC           = $${LIBINC_}
GL2PS_LIBDIR        = -L$${LIBDIR_}

TINYXML_INC         = $${LIBINC_}
TINYXML_LIBDIR      = -L$${LIBDIR_}

MINIZIP_INC         = $${LIBINC_}
MINIZIP_LIBDIR      = -L$${LIBDIR_}

3DS_INC             = $${LIBINC_}
3DS_LIBDIR          = -L$${LIBDIR_}

PNG_INC             = $${LIBINC_}
PNG_LIBDIR          = -L$${LIBDIR_}

JPEG_INC            = $${LIBINC_}
JPEG_LIBDIR         = -L$${LIBDIR_}

ZLIB_INC            = $${LIBINC_}
ZLIB_LIBDIR         = -L$${LIBDIR_}

OSMESA_INC          = $${LIBINC_}
OSMESA_LIBDIR       = -L$${LIBDIR_}
OSMESA_LDLIBS       = $${LIBDIR_}/lib$${LIB_OSMESA}.$${S_EXT_} \
                      $${LIBDIR_}/lib$${LIB_GLU}.$${S_EXT_}

# 3rd party libreries - compiled from source
# Be careful not to move this chunk. moving it will affect to overall logic flow.
USE_3RD_PARTY_LIBS {
    WHICH_LIBS = 3RD PARTY

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

    # overwrite (reset)
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

    # detect libraries paths
    SYS_LIBINC_         = $${SYSTEM_PREFIX_}/include
    macx {                                                           # OSX
        SYS_LIBINC_    += $${SYSTEM_PREFIX_}/X11/include
        SYS_LIBDIR_     = $${SYSTEM_PREFIX_}/X11/lib
    } else: exists($${SYSTEM_PREFIX_}/lib/$$QT_ARCH-linux-gnu) {     # Debian
        SYS_LIBDIR_     = $${SYSTEM_PREFIX_}/lib/$$QT_ARCH-linux-gnu
    } else: exists($${SYSTEM_PREFIX_}/lib$$ARCH/) {                  # RedHat (64bit)
        SYS_LIBDIR_     = $${SYSTEM_PREFIX_}/lib$$ARCH
    } else {                                                         # Arch, RedHat (32bit)
        SYS_LIBDIR_     = $${SYSTEM_PREFIX_}/lib
    }

    # detect libraries
    USE_SYSTEM_OSMESA {
        _LIB_OSMESA  = OSMesa
        exists($${SYS_LIBDIR_}/lib$${_LIB_OSMESA}.$${EXT_}): _OSM_CUI: USE_SYSTEM_OSMESA_LIB=YES
    }

    USE_SYSTEM_LIBS {
        WHICH_LIBS = SYSTEM
        # detect system libraries
        _LIB_OSMESA  = OSMesa
        exists($${SYS_LIBDIR_}/lib$${_LIB_OSMESA}.$${EXT_}): _OSM_CUI: USE_SYSTEM_OSMESA_LIB=YES
        exists($${SYS_LIBDIR_}/lib$${LIB_JPEG}.$${EXT_}): USE_SYSTEM_JPEG_LIB=YES
        exists($${SYS_LIBDIR_}/libz.$${EXT_}): USE_SYSTEM_Z_LIB=YES

        # special situation for libpng
        macx {
            _LIB_PNG = png
            # use system png on macos only - version of libpng on Ubuntu is too low
            exists($${SYS_LIBDIR_}/lib$${_LIB_PNG}.$${EXT_}): USE_SYSTEM_PNG_LIB=YES
        }

        # remove these for now, we'll append them at the end
        !USE_3RD_PARTY_LIBS {
            LIBS_INC -= -L$${LIBINC_}
            LIBS_DIR -= -L$${LIBDIR_}
        }
        # append...
        # ===============================}
        LIBS_INC     += $${SYS_LIBINC_}
        LIBS_DIR     += -L$${SYS_LIBDIR_}
    }

    contains(USE_SYSTEM_PNG_LIB, YES) {
        # use sytem lib name - only macos will trigger this logic
        LIB_PNG = png
        # remove 3rdParty lib reference
        USE_3RD_PARTY_LIBS {
            LIBS_INC -= $${PNG_INC}
            LIBS_DIR -= $${PNG_LIBDIR}
        }
        # reset individual library entry
        PNG_INC      = $${SYS_LIBINC_}
        PNG_LIBDIR   = -L$${SYS_LIBDIR_}
        PNG_LDLIBS   = $${SYS_LIBDIR_}/lib$${LIB_PNG}.$${EXT_}
    }

    contains(USE_SYSTEM_JPEG_LIB, YES) {
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
        # remove 3rdParty lib reference
        USE_3RD_PARTY_LIBS {
            LIBS_INC -= $${ZLIB_INC}
            LIBS_DIR -= $${ZLIB_LIBDIR}
        }
        # reset individual library entry
        ZLIB_INC      = $${SYS_LIBINC_}
        ZLIB_LIBDIR   = -L$${SYS_LIBDIR_}
        ZLIB_LDLIBS   = $${SYS_LIBDIR_}/libz.$${EXT_}
    }

    contains(USE_SYSTEM_OSMESA_LIB, YES): _OSM_CUI {
        # use sytem lib name
        LIB_OSMESA  = OSMesa
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

    # append these the end to include missing system headers and libs
    USE_SYSTEM_LIBS: !USE_3RD_PARTY_LIBS {
        LIBS_INC += -L$${LIBINC_}
        LIBS_DIR += -L$${LIBDIR_}
    }

}

message("~~~ USING $${WHICH_LIBS} LIBS ~~~")

# GUI/CUI environment identifiers
_QT_GUI {
    POSTFIX  = -qt$${QT_MAJOR_VERSION}
    BUILD   += QT
} else: _OSM_CUI {
    POSTFIX  = -osmesa
    BUILD   += OSMESA
}
win32: BUILD += WINDOWS
else:  BUILD += $$upper($$system(uname))

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

# 3ds
!freebsd: DEFINES	+= EXPORT_3DS
else:     DEFINES	-= EXPORT_3DS

# Boost
!contains(CONFIG, USE_BOOST): {
    DEFINES		+= _NO_BOOST
} else {
    INCLUDEPATH         += $$_PRO_FILE_PWD_/../boost/include
    LIBS 		+= -L$$_PRO_FILE_PWD_/../boost/lib
}

# dirs
OBJECTS_DIR       = $$DESTDIR/.obj$${POSTFIX}
win32 {
    CONFIG       += windows
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

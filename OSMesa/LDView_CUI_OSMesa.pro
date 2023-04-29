######################################################################
# Automatically generated by qmake (2.01a) Sat 3. Jun 19:52:21 2017
######################################################################

TEMPLATE     = app
TARGET       =
QT          += core
QT          -= opengl
QT          -= gui
CONFIG      -= qt
CONFIG      -= opengl
CONFIG      += thread
CONFIG      += warn_on
win32: CONFIG   += console
macx:  CONFIG   -= app_bundle   # on OSX don't bundle - for now...

contains(DEFINES, _QT): DEFINES -= _QT
DEFINES         += _OSMESA

include(../LDViewGlobal.pri)

# The ABI version.
VER_MAJ = 4
VER_MIN = 5
VER_PAT = 0
VER_BLD = 0
win32: VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT"."$$VER_BLD  # major.minor.patch.build
else:  VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT              # major.minor.patch
DEFINES += VERSION_INFO=\\\"$$VERSION\\\"
DEFINES += ARCH=\\\"$$join(ARCH,,,bit)\\\"

message("~~~ LDVIEW ($$join(ARCH,,,bit)) VERSION $$VERSION CUI EXECUTABLE $${BUILD} ~~~")

DEFINES     += QT_THREAD_SUPPORT

QMAKE_CXXFLAGS  += $(Q_CXXFLAGS)
QMAKE_CFLAGS    += $(Q_CFLAGS)
QMAKE_LFLAGS    += $(Q_LDFLAGS)

unix:!macx: TARGET = ldview
else:       TARGET = LDView

unix {
    exists($${OSMESA_INC}/GL/osmesa.h):!USE_SYSTEM_LIBS {
        message("~~~ NOTICE: Using LDView Pre-defined OSMESA library ~~~")
    } else:USE_SYSTEM_LIBS:!USE_OSMESA_STATIC {
        exists($${OSMESA_LOCAL_PREFIX_}/include/GL/osmesa.h): message("~~~ NOTICE: Using LOCAL OSMESA library ~~~")
        else:exists($${SYSTEM_PREFIX_}/include/GL/osmesa.h): message("~~~ NOTICE: Using SYSTEM OSMESA library ~~~")
        else:exists($${SYSTEM_PREFIX_}/X11/include/GL/osmesa.h): message("~~~ NOTICE: Using X11 SYSTEM OSMESA library ~~~")
    } else:USE_3RD_PARTY_LIBS:contains(USE_SYSTEM_OSMESA_LIB, YES) {
        exists($${SYSTEM_PREFIX_}/X11/include/GL/osmesa.h): message("~~~ NOTICE: Using X11 SYSTEM OSMESA library ~~~")
        else:exists($${SYSTEM_PREFIX_}/include/GL/osmesa.h): message("~~~ NOTICE: Using SYSTEM OSMESA library ~~~")
    } else:USE_OSMESA_STATIC {
        message("~~~ NOTICE: Using OSMESA BUILT FROM SOURCE library ~~~")
    } else {
        message("CRITICAL: OSMESA LIBRARIES NOT FOUND!")
    }
}

3RD_PARTY_INSTALL {
    isEmpty(3RD_PACKAGE_VER):3RD_PACKAGE_VER = $$TARGET-$$VER_MAJ"."$$VER_MIN
    isEmpty(3RD_BINDIR):3RD_BINDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/bin/$$QT_ARCH
    isEmpty(3RD_DOCDIR):3RD_DOCDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/docs
    isEmpty(3RD_RESOURCES):3RD_RESOURCES     = $$3RD_PREFIX/$$3RD_PACKAGE_VER/resources
    isEmpty(3RD_HEADERS):3RD_HEADERS         = $$3RD_PREFIX/$$3RD_PACKAGE_VER/include

    message("~~~ CUI 3RD PARTY INSTALL PREFIX $${3RD_PREFIX} ~~~")

    COPY_CMD = cp -f
    MAKE_HDR_DIRS_CMD = if test -e $$3RD_HEADERS; then rm -rf $$3RD_HEADERS; fi; \
                        mkdir -p $$3RD_HEADERS/LDExporter $$3RD_HEADERS/LDLib \
                        $$3RD_HEADERS/LDLoader $$3RD_HEADERS/TRE $$3RD_HEADERS/TCFoundation \
                        $$3RD_HEADERS/3rdParty $$3RD_HEADERS/GL

    system( $$MAKE_HDR_DIRS_CMD )
    system( $$COPY_CMD ../LDLib/*.h $${3RD_HEADERS}/LDLib/ )
    system( $$COPY_CMD ../LDExporter/*.h $${3RD_HEADERS}/LDExporter/ )
    system( $$COPY_CMD ../LDLoader/*.h $${3RD_HEADERS}/LDLoader/ )
    system( $$COPY_CMD ../TRE/*.h $${3RD_HEADERS}/TRE/ )
    system( $$COPY_CMD ../TCFoundation/*.h $${3RD_HEADERS}/TCFoundation/ )
    system( $$COPY_CMD ../include/*.h $${3RD_HEADERS}/3rdParty/ )
    system( $$COPY_CMD ../include/GL/*.h $${3RD_HEADERS}/GL/ )

    exists($$3RD_HEADERS/TCFoundation/TCObject.h): \
    message("~~~ $$upper( $$TARGET ) HEADERS COPIED TO $${3RD_HEADERS} ~~~")

    target.path                 = $${3RD_BINDIR}
    documentation.path          = $${3RD_DOCDIR}
    documentation.files         = ../Readme.txt ../Help.html ../license.txt \
                                  ../ChangeHistory.html ldview.1
    resources.path              = $${3RD_RESOURCES}
    resources.files             = ../m6459.ldr ../8464.mpd ldviewrc.sample \
                                  ../LDViewMessages.ini ../LDExporter/LDExportMessages.ini \
                                  ../LDExporter/LGEO.xml
    resources_config.path       = $${3RD_RESOURCES}/config
    resources_config.files      = ldview.ini ldviewPOV.ini LDViewCustomIni

    libraries.path              = $${3RD_BINDIR}
    libraries.files             = ../TCFoundation/$$DESTDIR/libTCFoundation$${POSTFIX}.a \
                                  ../LDLoader/$$DESTDIR/libLDLoader$${POSTFIX}.a \
                                  ../TRE/$$DESTDIR/libTRE$${POSTFIX}.a \
                                  ../LDLib/$$DESTDIR/libLDraw$${POSTFIX}.a \
                                  ../LDExporter/$$DESTDIR/libLDExporter$${POSTFIX}.a

    contains(USE_3RD_PARTY_3DS, YES) {
        exists($$OUT_PWD/$${3DS_LDLIBS}): 3DS_LIB_FOUND = YES
        else: message("~~~ 3DS Library not found at $$OUT_PWD/$${3DS_LDLIBS} ~~~")
    } else {
        # pre-built 3ds path is already abs so use without $$OUT_PWD
        exists($${3DS_LDLIBS}): 3DS_LIB_FOUND = YES
        else: message("~~~ 3DS Library not found at $${3DS_LDLIBS} ~~~")
    }
    contains(3DS_LIB_FOUND, YES) {
        # Treat Mageia 'error adding symbols: Archive has no index...'
        contains(HOST,Mageia) {
            message("~~~ COPY lib$${LIB_3DS}.$${EXT_S} TO $${3RD_BINDIR}/ ~~~")
            3RD_3DS_COPY_CMD    = if ! test -e $${3RD_BINDIR}; then mkdir -p $${3RD_BINDIR}; fi; \
                                  cp -f $${3DS_LDLIBS} $${3RD_BINDIR}/
            system( $${3RD_3DS_COPY_CMD} )
        } else {
            libraries.files    += $${3DS_LDLIBS}
        }
    }
    contains(USE_3RD_PARTY_PNG, YES) {
        exists($$OUT_PWD/$${PNG_LDLIBS}): \
        libraries.files += $${PNG_LDLIBS}
        else: message("~~~ PNG Library not found at $$OUT_PWD/$${PNG_LDLIBS} ~~~")
    }
    contains(USE_3RD_PARTY_JPEG, YES) {
        exists($$OUT_PWD/$${JPEG_LDLIBS}): \
        libraries.files         += $${JPEG_LDLIBS}
        else: message("~~~ JPEG Library not found at $$OUT_PWD/$${JPEG_LDLIBS} ~~~")
    }
    contains(USE_3RD_PARTY_GL2PS, YES) {
        exists($$OUT_PWD/$${GL2PS_LDLIBS}): \
        libraries.files         += $${GL2PS_LDLIBS}
        else: message("~~~ GL2PS Library not found at $$OUT_PWD/$${GL2PS_LDLIBS} ~~~")
    }
    contains(USE_3RD_PARTY_TINYXML, YES) {
        exists($$OUT_PWD/$${TINYXML_LDLIBS}): \
        libraries.files         += $${TINYXML_LDLIBS}
        else: message("~~~ TINYXML Library not found at $$OUT_PWD/$${TINYXML_LDLIBS} ~~~")
    }
    !contains(USE_SYSTEM_Z_LIB, YES) {
        exists($$OUT_PWD/$${ZLIB_LDLIBS}): \
        libraries.files         += $${ZLIB_LDLIBS}
        else: message("~~~ Z Library not found at $$OUT_PWD/$${ZLIB_LDLIBS} ~~~")
    }

    INSTALLS += target documentation resources resources_config libraries

} else {

    unix: !macx {

        isEmpty(PREFIX):PREFIX          = /usr
        isEmpty(BINDIR):BINDIR          = $$PREFIX/bin
        isEmpty(DATADIR):DATADIR        = $$PREFIX/share
        isEmpty(DOCDIR):DOCDIR          = $$DATADIR/doc
        isEmpty(MANDIR):MANDIR          = $$DATADIR/man

        target.path         = $${BINDIR}
        documentation.path  = $${DOCDIR}/$${TARGET}
        documentation.files = ../Readme.txt ../Help.html ../license.txt \
                              ../m6459.ldr \
                              ../ChangeHistory.html ../8464.mpd todo.txt \
                              ../Textures/SansSerif.fnt \
                              ../LDExporter/LGEO.xml
        man.path            = $${MANDIR}/man1
        man.extra           = $(INSTALL_FILE) LDView.1 desktop/ldraw-thumbnailer.1 $(INSTALL_ROOT)$${MANDIR}/man1 ; $(COMPRESS) $(INSTALL_ROOT)$${MANDIR}/man1/*.1
        INSTALLS += target documentation
    }

}


macx: LIBS += $${OSX_FRAMEWORKS_CORE}

LDLIBS = ../TCFoundation/$$DESTDIR/libTCFoundation$${POSTFIX}.a \
         ../LDLoader/$$DESTDIR/libLDLoader$${POSTFIX}.a \
         ../TRE/$$DESTDIR/libTRE$${POSTFIX}.a \
         ../LDLib/$$DESTDIR/libLDraw$${POSTFIX}.a \
         ../LDExporter/$$DESTDIR/libLDExporter$${POSTFIX}.a

LDLIBS += $${OSMESA_LDLIBS}

LDLIBDIRS = -L../TCFoundation/$$DESTDIR \
            -L../TRE/$$DESTDIR \
            -L../LDLoader/$$DESTDIR \
            -L../LDLib/$$DESTDIR \
            -L../LDExporter/$$DESTDIR

LIBDIRS += $${LDLIBDIRS}

LIBS_    = -lLDraw$${POSTFIX} \
           -lTRE$${POSTFIX} \
           -lLDLoader$${POSTFIX} \
           -lTCFoundation$${POSTFIX} \
           -lLDExporter$${POSTFIX}

# override system or 3rdparty libraries as specified
if (USE_SYSTEM_LIBS|USE_3RD_PARTY_LIBS) {
   LIBS_ +=  $${PNG_LDLIBS} \
             $${JPEG_LDLIBS} \
             $${3DS_LDLIBS} \
             $${GL2PS_LDLIBS} \
             $${TINYXML_LDLIBS} \
             $${ZLIB_LDLIBS}
}

LIBS_   += $${LIBS_PRI}

INCLUDEPATH += .. $${LIBS_INC}

# Platform-specific
unix {
    freebsd {
        LIBDIRS      += -L/usr/local/lib
    }

    # slurm is media.peeron.com
    OSTYPE = $$system(hostname)
    contains(OSTYPE, slurm) {
        LIBDIRS  -= $${OSMESA_LIBDIR}
        LIBDIRS  += -L../../Mesa-7.0.2/lib
        CONFIG   -= static  # reverse static directive - not sure about this ?
    }

    OSTYPE = $$system(hostname | cut -d. -f2-)
    contains(OSTYPE, pair.com) {
        LIBDIRS  -= $${OSMESA_LIBDIR}
        LIBDIRS  += -L../../Mesa-7.11/lib -L/usr/local/lib/pth -L/usr/local/lib
        LIBS_    += -lpth
    }

    exists (/usr/include/qt3) {
        INCLUDEPATH  += /usr/include/qt3
    }
}

USE_OSMESA_STATIC {
    NO_GALLIUM {
      message("~~~ LLVM not needed - Gallium driver not used ~~~")
    } else {
      isEmpty(LLVM_PREFIX_): LLVM_PREFIX_ = $${SYSTEM_PREFIX_}
      exists($${LLVM_PREFIX_}/bin/llvm-config) {
        LLVM_LDFLAGS   = $$system($${LLVM_PREFIX_}/bin/llvm-config --ldflags)
        LLVM_LIBS     += $${LLVM_LDFLAGS}
        isEmpty(LLVM_LDFLAGS): message("~~~ LLVM - ERROR llvm ldflags not found ~~~")
        LLVM_LIB_NAME  = $$system($${LLVM_PREFIX_}/bin/llvm-config --libs engine mcjit)
        LLVM_LIBS     += $${LLVM_LIB_NAME}
        isEmpty(LLVM_LIBS): message("~~~ LLVM - ERROR llvm library not found ~~~")
        _LIBS         += $${LLVM_LIBS}
      } else {
        message("~~~ LLVM - ERROR llvm-config not found ~~~")
      }
    }
}

LIBS += $${LDLIBS} $${LIBDIRS} $${LIBS_DIR} $${_LIBS} $${LIBS_}

LDV_MESSAGES = $$system_path( $$absolute_path( $$_PRO_FILE_PWD_/../LDViewMessages.ini ))
LDV_EXP_MESSAGES = $$system_path( $$absolute_path( $$_PRO_FILE_PWD_/../LDExporter/LDExportMessages.ini ))
LDV_CONCAT_MESSAGES = $$_PRO_FILE_PWD_/LDViewMessages.ini
exists($$LDV_MESSAGES) {
    message("~~~ MESSAGES LDViewMessages found at $$LDV_MESSAGES ~~~")
    exists($$LDV_EXP_MESSAGES) {
        message("~~~ MESSAGES LDExportMessages found at $$LDV_EXP_MESSAGES ~~~")
        LDV_MESSAGES_CMD = cat $$LDV_MESSAGES $$LDV_EXP_MESSAGES > $$LDV_CONCAT_MESSAGES
        # message("~~~ LDV_MESSAGES_CMD $$LDV_MESSAGES_CMD ~~~")
        BUILD_FLATPAK {
            system( $$LDV_MESSAGES_CMD )
            exists($$LDV_CONCAT_MESSAGES): message("~~~ MESSAGES $$LDV_CONCAT_MESSAGES concatenated ~~~")
            else: message("~~~ ERROR $$LDV_CONCAT_MESSAGES was not concatenated ~~~")
        } else {
            ini.target = LDViewMessages.ini
            ini.depends = $$LDV_MESSAGES $$LDV_EXP_MESSAGES
            ini.commands = $$LDV_MESSAGES_CMD
            QMAKE_EXTRA_TARGETS += ini
        }
    } else {
        message("~~~ ERROR $$LDV_EXP_MESSAGES was not found ~~~")
    }
} else {
    message("~~~ ERROR $$LDV_MESSAGES was not found ~~~")
}

LDV_STUD_LOGO_TEXTURE = $$_PRO_FILE_PWD_/../Textures/StudLogo.png
!equals(PWD, $${OUT_PWD}) {
    message("~~~ YESSIR! Shadow building ~~~")
    ldviewmessages_commands = ./$$DESTDIR/Headerize $$LDV_CONCAT_MESSAGES; mv LDViewMessages.h $$_PRO_FILE_PWD_/LDViewMessages.h
    studlogo_commands = ./$$DESTDIR/Headerize $$LDV_STUD_LOGO_TEXTURE; mv StudLogo.h $$_PRO_FILE_PWD_/StudLogo.h
} else {
    message("~~~ NOSIR! Not shadow building ~~~")
    ldviewmessages_commands = ./$$DESTDIR/Headerize $$LDV_CONCAT_MESSAGES
    studlogo_commands = ./$$DESTDIR/Headerize $$LDV_STUD_LOGO_TEXTURE
}

studlogo.target = StudLogo.h
studlogo.depends = $$DESTDIR/Headerize $$LDV_STUD_LOGO_TEXTURE
studlogo.commands = $$studlogo_commands

ldviewmessages.target = LDViewMessages.h
ldviewmessages.depends = $$DESTDIR/Headerize $$LDV_CONCAT_MESSAGES
ldviewmessages.commands = $$ldviewmessages_commands

QMAKE_EXTRA_TARGETS += studlogo ldviewmessages
PRE_TARGETDEPS += LDViewMessages.ini LDViewMessages.h StudLogo.h

# tests on unix (linux OSX)
BUILD_CHECK: unix {
    # LDraw library path - needed for tests
    LDRAW_PATH = $$(LDRAWDIR)
    !isEmpty(LDRAW_PATH){
        message("~~~ LDRAW LIBRARY $${LDRAW_PATH} ~~~")

        LDRAW_DIR = LDrawDir=$${LDRAW_PATH}
        DEV_DIR   = $${_PRO_FILE_PWD_}
        LN_13=12
        LN_57=60
        ldviewini.target = LDViewCustomIni
        ldviewini.depends = ldviewiniMessage
        !macx: ldviewini.commands = @sed -i      \'$${LN_13}s%.*%$${LDRAW_DIR}%\' $${DEV_DIR}/LDViewCustomIni
        else:  ldviewini.commands = @sed -i \'\' \'$${LN_13}s%.*%$${LDRAW_DIR}%\' $${DEV_DIR}/LDViewCustomIni
        ldviewiniMessage.commands = @echo && echo "Project MESSAGE: Updating LDViewCustomIni with entry $${LDRAW_DIR} at line $${LN_13}"

        exists($${LDRAW_PATH}/lgeo/LGEO.xml) {
            LGEO_DIR = XmlMapPath=$${LDRAW_PATH}/lgeo
            message("~~~ LGEO LIBRARY $${LGEO_DIR} ~~~")

            !macx: ldviewini.commands += ; sed -i      \'$${LN_57}s%.*%$${LGEO_DIR}%\' $${DEV_DIR}/LDViewCustomIni
            else:  ldviewini.commands += ; sed -i \'\' \'$${LN_57}s%.*%$${LGEO_DIR}%\' $${DEV_DIR}/LDViewCustomIni
            ldviewiniMessage.commands += ; echo "Project MESSAGE: Updating LDViewCustomIni with entry $${LGEO_DIR} at line $${LN_57}"
        } else {
            message("~~~ LGEO LIBRARY NOT FOUND ~~~")

            !macx: ldviewini.commands += ; sed -i      \'$${LN_57}s%.*%%\' $${DEV_DIR}/LDViewCustomIni
            else:  ldviewini.commands += ; sed -i \'\' \'$${LN_57}s%.*%%\' $${DEV_DIR}/LDViewCustomIni
            ldviewiniMessage.commands += ; echo "Project MESSAGE: Removing LDViewCustomnIni entry XmlMapPath at line $${LN_57}"
        }

        exists($$(HOME)/.ldviewrc) {
            ldviewiniMessage.commands += ; echo "Project MESSAGE: Found ldviewc at $$(HOME)/.ldviewrc"
        } else: exists($$(HOME)/.config/LDView/ldviewrc) {
            ldviewiniMessage.commands += ; echo "Project MESSAGE: Found ldviewc at $$(HOME)/.config/LDView"
        } else {
            ldviewiniMessage.commands += ; echo "Project MESSAGE: $$(HOME)/.ldviewrc will be created"
        }

        QMAKE_EXTRA_TARGETS += ldviewini ldviewiniMessage
        PRE_TARGETDEPS += LDViewCustomIni

        # Test
        #./ldview ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=/home/trevor/projects/ldview/OSMesa/LDViewCustomIni -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0
        # Set CONFIG+=USE_SOFTPIPE to test LLVM softpipe driver
        contains(USE_SYSTEM_OSMESA_LIB, YES): CONFIG+=USE_SWRAST

        include(LDViewCUITest.pri)

    } else {
        message("WARNING: LDRAW LIBRARY NOT DEFINED - LDView CUI cannot be tested")
    }
}

QMAKE_CLEAN += LDViewMessages.ini LDViewMessages.h StudLogo.h

# Input
HEADERS += GLInfo.h
SOURCES += ldview.cpp \
           GLInfo.cpp
OTHER_FILES += \
           LDViewCustomIni \
           ldview.1 \
           ldview.ini \
           ldviewPOV.ini \
           ldviewrc.sample

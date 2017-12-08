######################################################################
# Automatically generated by qmake (2.01a) Sat 3. Jun 19:52:21 2017
######################################################################

TEMPLATE         = app
TARGET           =
QT  		+= core
QT  		-= opengl
QT  		-= gui
CONFIG		-= qt
CONFIG		-= opengl
CONFIG		+= thread
CONFIG		+= warn_on
win32: CONFIG   += console
macx:  CONFIG   -= app_bundle   # on OSX don't bundle - for now...

contains(DEFINES, _QT): DEFINES -= _QT
DEFINES         += _OSMESA

include(../LDViewGlobal.pri)

# The ABI version.
VER_MAJ = 4
VER_MIN = 3
VER_PAT = 0
VER_BLD = 0
win32: VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT"."$$VER_BLD  # major.minor.patch.build
else:  VERSION = $$VER_MAJ"."$$VER_MIN"."$$VER_PAT              # major.minor.patch
DEFINES += VERSION_INFO=\\\"$$VERSION\\\"
DEFINES += ARCH=\\\"$$join(ARCH,,,bit)\\\"

message("~~~ LDVIEW ($$join(ARCH,,,bit)) VERSION $$VERSION CUI EXECUTABLE $${BUILD} ~~~")

DEFINES		+= QT_THREAD_SUPPORT

QMAKE_CXXFLAGS	+= $(Q_CXXFLAGS)
QMAKE_CFLAGS   	+= $(Q_CFLAGS)
QMAKE_LFLAGS   	+= $(Q_LDFLAGS)

unix:!macx: TARGET = ldview
else:       TARGET = LDView

unix {
    exists($${OSMESA_INC}/GL/osmesa.h):!USE_SYSTEM_LIBS {
        message("~~~ NOTICE: Using LDView Pre-defined OSMESA library ~~~")
    } else:USE_SYSTEM_LIBS {
        exists($${SYSTEM_PREFIX_}/X11/include/GL/osmesa.h): message("~~~ NOTICE: Using X11 SYSTEM OSMESA library ~~~")
        else:exists($${SYSTEM_PREFIX_}/include/GL/osmesa.h): message("~~~ NOTICE: Using SYSTEM OSMESA library ~~~")
    } else:USE_3RD_PARTY_LIBS:contains(USE_SYSTEM_OSMESA_LIB, YES) {
        exists($${SYSTEM_PREFIX_}/X11/include/GL/osmesa.h): message("~~~ NOTICE: Using X11 SYSTEM OSMESA library ~~~")
        else:exists($${SYSTEM_PREFIX_}/include/GL/osmesa.h): message("~~~ NOTICE: Using SYSTEM OSMESA library ~~~")
    } else {
        message("CRITICAL: OSMESA LIBRARIES NOT FOUND!")
    }
}

3RD_PARTY_INSTALL {
    isEmpty(3RD_PACKAGE_VER):3RD_PACKAGE_VER = $$TARGET-$$VER_MAJ"."$$VER_MIN
    isEmpty(3RD_BINDIR):3RD_BINDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/bin/$$QT_ARCH
    isEmpty(3RD_DOCDIR):3RD_DOCDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/docs
    isEmpty(3RD_RESOURCES):3RD_RESOURCES     = $$3RD_PREFIX/$$3RD_PACKAGE_VER/resources

    message("~~~ CUI 3RD PARTY INSTALL PREFIX $${3RD_PREFIX} ~~~")

    target.path                 = $${3RD_BINDIR}
    documentation.path          = $${3RD_DOCDIR}
    documentation.files         = ../Readme.txt ../Help.html ../license.txt \
                                  ../ChangeHistory.html ldview.1
    resources.path              = $${3RD_RESOURCES}
    resources.files             = ../m6459.ldr ../8464.mpd ldviewrc.sample \
                                  ../LDExporter/LGEO.xml
    resources_config.path       = $${3RD_RESOURCES}/config
    resources_config.files      = ldview.ini ldviewPOV.ini LDViewCustomIni
    INSTALLS += target documentation resources resources_config

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
             $${ZLIB_LDLIBS}
}

LIBS_   += $${LIBS_PRI}

INCLUDEPATH += .. $${LIBS_INC}

# Platform-specific
unix {
    freebsd {
        LIBDIRS 	 += -L/usr/local/lib
    }

    # slurm is media.peeron.com
    OSTYPE = $$system(hostname)
    contains(OSTYPE, slurm) {
        LIBDIRS  -= $${OSMESA_LIBDIR}
        LIBDIRS	 += -L../../Mesa-7.0.2/lib
        CONFIG 	 -= static	# reverse static directive - not sure about this ?
    }

    OSTYPE = $$system(hostname | cut -d. -f2-)
    contains(OSTYPE, pair.com) {
        LIBDIRS  -= $${OSMESA_LIBDIR}
        LIBDIRS	 += -L../../Mesa-7.11/lib -L/usr/local/lib/pth -L/usr/local/lib
        LIBS_	 += -lpth
    }

    exists (/usr/include/qt3) {
        INCLUDEPATH  += /usr/include/qt3
    }
}

USE_OSMESA_STATIC {
    exists (/usr/bin/llvm-config) {
        LLVM_LDFLAGS     = $$system(/usr/bin/llvm-config --ldflags)
        isEmpty(LLVM_LDFLAGS): message("~~~ LLVM - ERROR llvm ldflags not found ~~~")
        else: LLVM_LIBS += $${LLVM_LDFLAGS}
        LLVM_LIB_NAME    = $$system(/usr/bin/llvm-config --libs engine mcjit)
        isEmpty(LLVM_LIBS): message("~~~ LLVM - ERROR llvm library not found ~~~")
        else: LLVM_LIBS += $${LLVM_LIB_NAME}

        LIBS_     += $${LLVM_LIBS}
    } else {
        message("~~~ LLVM - ERROR llvm-config not found ~~~")
    }
}

LIBS               += $${LDLIBS} $${LIBDIRS} $${LIBS_DIR} $${LIBS_}

ini.target = LDViewMessages.ini
ini.depends = $$_PRO_FILE_PWD_/../LDViewMessages.ini $$_PRO_FILE_PWD_/../LDExporter/LDExportMessages.ini
ini.commands = cat $$_PRO_FILE_PWD_/../LDViewMessages.ini $$_PRO_FILE_PWD_/../LDExporter/LDExportMessages.ini > $$_PRO_FILE_PWD_/LDViewMessages.ini

!equals(PWD, $${OUT_PWD}) {
    message("~~~ YESSIR!, shadow building ~~~")
    ldviewmessages_commands = ./$$DESTDIR/Headerize $$_PRO_FILE_PWD_/LDViewMessages.ini; mv LDViewMessages.h $$_PRO_FILE_PWD_/LDViewMessages.h
    studlogo_commands = ./$$DESTDIR/Headerize $$_PRO_FILE_PWD_/../Textures/StudLogo.png; mv StudLogo.h $$_PRO_FILE_PWD_/StudLogo.h
} else {
    message("~~~ NOSIR! not shadow building ~~~")
    ldviewmessages_commands = ./$$DESTDIR/Headerize $$_PRO_FILE_PWD_/LDViewMessages.ini
    studlogo_commands = ./$$DESTDIR/Headerize $$_PRO_FILE_PWD_/../Textures/StudLogo.png
}

ldviewmessages.target = LDViewMessages.h
ldviewmessages.depends = $$DESTDIR/Headerize $$_PRO_FILE_PWD_/LDViewMessages.ini
ldviewmessages.commands = $$ldviewmessages_commands

studlogo.target = StudLogo.h
studlogo.depends = $$DESTDIR/Headerize $$_PRO_FILE_PWD_/../Textures/StudLogo.png
studlogo.commands = $$studlogo_commands

QMAKE_EXTRA_TARGETS += ini ldviewmessages studlogo
PRE_TARGETDEPS += LDViewMessages.ini LDViewMessages.h StudLogo.h

# tests on unix (linux OSX)
BUILD_CHECK: unix {
    # LDraw library path - needed for tests
    LDRAW_PATH = $$(LDRAWDIR)
    !isEmpty(LDRAW_PATH){
        message("~~~ LDRAW LIBRARY $${LDRAW_PATH} ~~~")

        LDRAW_DIR = LDrawDir=$${LDRAW_PATH}
        DEV_DIR   = $${_PRO_FILE_PWD_}
        LN_13=13
        LN_57=57
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
            ldviewiniMessage.commands += ; echo "Project MESSAGE: Removing LDViewCustomnIi entry XmlMapPath at line $${LN_57}"
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

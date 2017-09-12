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

message("~~~ LDVIEW ($$join(ARCH,,,bit)) $${BUILD} CUI EXECUTABLE VERSION $$VERSION ~~~")

DEFINES		+= QT_THREAD_SUPPORT

QMAKE_CXXFLAGS	+= $(Q_CXXFLAGS)
QMAKE_CFLAGS   	+= $(Q_CFLAGS)
QMAKE_LFLAGS   	+= $(Q_LDFLAGS)

unix:!macx: TARGET = ldview
else:       TARGET = LDView

unix {
    exists($${OSMESA_INC}/GL/osmesa.h): !USE_SYSTEM_LIBS {
        message("~~~ Using LOCAL OSMESA library ~~~")
    } else: exists($${SYSTEM_PREFIX_}/X11/include/GL/osmesa.h): contains(USE_SYSTEM_OSMESA_LIB, YES) {
        message("~~~ NOTICE: Using X11 SYSTEM OSMESA library ~~~")
    } else: exists($${SYSTEM_PREFIX_}/include/GL/osmesa.h): contains(USE_SYSTEM_OSMESA_LIB, YES) {
        message("~~~ NOTICE: Using SYSTEM OSMESA library ~~~")
    } else {
        message("CRITICAL: OSMESA LIBRARIES NOT FOUND!")
    }

    !macx: !3RD_PARTY_INSTALL {

        isEmpty(PREFIX):PREFIX          = /usr
        isEmpty(BINDIR):BINDIR          = $$PREFIX/bin
        isEmpty(DATADIR):DATADIR        = $$PREFIX/share
        isEmpty(DOCDIR):DOCDIR          = $$DATADIR/doc
        isEmpty(MANDIR):MANDIR          = $$DATADIR/man

        target.path         = $${BINDIR}
        documentation.path  = $${DOCDIR}/ldview
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

# some funky processing to get the prefix passed in on the command line
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_linux_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_macos_3rdparty
# CONFIG+=3RD_PARTY_INSTALL=../../lpub3d_windows_3rdparty
3RD_ARG = $$find(CONFIG, 3RD_PARTY_INSTALL.*)
!isEmpty(3RD_ARG): CONFIG -= $$3RD_ARG
CONFIG += $$section(3RD_ARG, =, 0, 0)

3RD_PARTY_INSTALL {
    3RD_PREFIX                               = $$_PRO_FILE_PWD_/$$section(3RD_ARG, =, 1, 1)
    isEmpty(3RD_PREFIX):3RD_PREFIX           = $$_PRO_FILE_PWD_/../3rdPartyInstall
    isEmpty(3RD_PACKAGE_VER):3RD_PACKAGE_VER = $$TARGET-$$VER_MAJ"."$$VER_MIN
    isEmpty(3RD_BINDIR):3RD_BINDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/bin/$$QT_ARCH
    isEmpty(3RD_DOCDIR):3RD_DOCDIR           = $$3RD_PREFIX/$$3RD_PACKAGE_VER/docs
    isEmpty(3RD_RESOURCES):3RD_RESOURCES     = $$3RD_PREFIX/$$3RD_PACKAGE_VER/resources

    message("~~~ CUI 3RD INSTALL PREFIX $${3RD_PREFIX} ~~~")

    target.path                 = $${3RD_BINDIR}
    documentation.path          = $${3RD_DOCDIR}
    documentation.files         = ../Readme.txt ../Help.html ../license.txt \
                                  ../ChangeHistory.html ldview.1
    resources.path              = $${3RD_RESOURCES}
    resources.files             = ../m6459.ldr ../8464.mpd ldviewrc.sample
    resources_config.path       = $${3RD_RESOURCES}/config
    resources_config.files      = ldview.ini ldviewPOV.ini LDViewCustomIni
    INSTALLS += target documentation resources resources_config
}


macx: LIBS += $${OSX_FRAMEWORKS_CORE}

LDLIBS = ../TCFoundation/$$DESTDIR/libTCFoundation$${POSTFIX}.a \
         ../LDLoader/$$DESTDIR/libLDLoader$${POSTFIX}.a \
         ../TRE/$$DESTDIR/libTRE$${POSTFIX}.a \
         ../LDLib/$$DESTDIR/libLDraw$${POSTFIX}.a \
         ../LDExporter/$$DESTDIR/libLDExporter$${POSTFIX}.a

LDLIBS += $${OSMESA_LDLIBS}

USE_SYSTEM_LIBS {
    LDLIBS +=   $${PNG_LDLIBS} \
                $${JPEG_LDLIBS} \
                $${ZLIB_LDLIBS}
}

LDLIBDIRS = -L../TCFoundation/$$DESTDIR \
            -L../TRE/$$DESTDIR \
            -L../LDLoader/$$DESTDIR \
            -L../LDLib/$$DESTDIR \
            -L../LDExporter/$$DESTDIR

LIBDIRS += $${LDLIBDIRS}

LIBS_  = -lLDraw$${POSTFIX} \
         -lTRE$${POSTFIX} \
         -lLDLoader$${POSTFIX} \
         -lTCFoundation$${POSTFIX} \
         -lLDExporter$${POSTFIX} \
         -l$${LIB_PNG} \
         -l$${LIB_JPEG} \
         -l$${LIB_OSMESA} \
         -l$${LIB_GLU} \
         -lgl2ps \
         -lz \
         -ltinyxml

# 3ds
contains(DEFINES, EXPORT_3DS) {
    LIBS_ += -l$${LIB_3DS}
}

INCLUDEPATH += .. $${LIBS_INC}

# Platform-specific
unix {
    freebsd {
        LIBDIRS 	 += -L/usr/local/lib
    }

    # slurm is media.peeron.com
    OSTYPE = $$system(hostname)
    contains(OSTYPE, slurm) {
        LIBDIRS      -= $${OSMESA_LIBDIR}
        LIBDIRS	 += -L../../Mesa-7.0.2/lib
        CONFIG 	 -= static	# reverse static directive - not sure about this ?
    }

    OSTYPE = $$system(hostname | cut -d. -f2-)
    contains(OSTYPE, pair.com) {
        LIBDIRS      -= $${OSMESA_LIBDIR}
        LIBDIRS	 += -L../../Mesa-7.11/lib -L/usr/local/lib/pth -L/usr/local/lib
        LIBS_	 += -lpth
    }

    exists (/usr/include/qt3) {
        INCLUDEPATH  += /usr/include/qt3
    }
}

!contains(USE_SYSTEM_OSMESA_LIB, YES) {
    macx:        QMAKE_LFLAGS += -Wl,-search_paths_first -Wl,-headerpad_max_install_names
    unix: !macx: QMAKE_LFLAGS += -Wl,--no-as-needed
    LLVM_LIBS       = -lLLVMX86Disassembler -lLLVMX86AsmParser -lLLVMX86CodeGen -lLLVMGlobalISel -lLLVMSelectionDAG \
                      -lLLVMAsmPrinter -lLLVMDebugInfoCodeView -lLLVMDebugInfoMSF -lLLVMCodeGen -lLLVMScalarOpts \
                      -lLLVMInstCombine -lLLVMTransformUtils -lLLVMBitWriter -lLLVMX86Desc -lLLVMMCDisassembler \
                      -lLLVMX86Info -lLLVMX86AsmPrinter -lLLVMX86Utils -lLLVMMCJIT -lLLVMExecutionEngine \
                      -lLLVMTarget -lLLVMAnalysis -lLLVMProfileData -lLLVMRuntimeDyld -lLLVMObject \
                      -lLLVMMCParser -lLLVMBitReader -lLLVMMC -lLLVMCore -lLLVMSupport -lLLVMDemangle
    macx:        LLVM_LIBS += -lm
    unix: !macx: LLVM_LIBS += -lrt -ldl -lm

    LIBS_          += $${LLVM_LIBS}
}

LIBS               += $${LDLIBS} $${LIBDIRS} $${LIBS_DIR} $${LIBS_}

ini.target = LDViewMessages.ini
ini.depends = $$_PRO_FILE_PWD_/../LDViewMessages.ini $$_PRO_FILE_PWD_/../LDExporter/LDExportMessages.ini
ini.commands = cat $$_PRO_FILE_PWD_/../LDViewMessages.ini $$_PRO_FILE_PWD_/../LDExporter/LDExportMessages.ini > $$_PRO_FILE_PWD_/LDViewMessages.ini

ldviewmessages.target = LDViewMessages.h
ldviewmessages.depends = $$DESTDIR/Headerize $$_PRO_FILE_PWD_/LDViewMessages.ini
ldviewmessages.commands = ./$$DESTDIR/Headerize $$_PRO_FILE_PWD_/LDViewMessages.ini; mv LDViewMessages.h $$_PRO_FILE_PWD_/LDViewMessages.h

studlogo.target = StudLogo.h
studlogo.depends = $$DESTDIR/Headerize $$_PRO_FILE_PWD_/../Textures/StudLogo.png
studlogo.commands = ./$$DESTDIR/Headerize $$_PRO_FILE_PWD_/../Textures/StudLogo.png; mv StudLogo.h $$_PRO_FILE_PWD_/StudLogo.h

QMAKE_EXTRA_TARGETS += ini ldviewmessages studlogo
PRE_TARGETDEPS += LDViewMessages.ini LDViewMessages.h StudLogo.h

unix: !macx: exists(/usr/local/ldraw/parts/3001.dat) {
    LDRAW_PATH = /usr/local/ldraw
} else: macx: exists(/Library/ldraw/parts/3001.dat) {
    LDRAW_PATH = /Library/ldraw
} else: macx: exists($$(HOME)/Library/ldraw/parts/3001.dat) {
    LDRAW_PATH = $$(HOME)/Library/ldraw
} else: win32: exists($$(USERPROFILE)\\LDraw\\parts\\3001.dat)  {
    LDRAW_PATH = $$(USERPROFILE)\\LDraw
}

# tests on unix (linux OSX)
unix {
    !isEmpty(LDRAW_PATH) {
        message("~~~ LDRAW LIBRARY $${LDRAW_PATH} ~~~")

        LDRAW_DIR = LDrawDir=$${LDRAW_PATH}
        DEV_DIR   = $${_PRO_FILE_PWD_}
        LN_13=13
        LN_57=57
        ldviewini.target = LDViewCustomIni
        ldviewini.depends = ldviewiniMessage
        !macx: ldviewini.commands = sed -i      \'$${LN_13}s%.*%$${LDRAW_DIR}%\' $${DEV_DIR}/LDViewCustomIni
        else:  ldviewini.commands = sed -i \'\' \'$${LN_13}s%.*%$${LDRAW_DIR}%\' $${DEV_DIR}/LDViewCustomIni
        ldviewiniMessage.commands = @echo Project MESSAGE: Updating LDViewCustomIni entry $${LDRAW_DIR}

        exists($${LDRAW_PATH}/lgeo/LGEO.xml) {
            LGEO_DIR = XmlMapPath=$${LDRAW_PATH}/lgeo
            message("~~~ LGEO LIBRARY $${LGEO_DIR} ~~~")

            !macx: ldviewini.commands += ; sed -i      \'$${LN_57}s%.*%$${LGEO_DIR}%\' $${DEV_DIR}/LDViewCustomIni
            else:  ldviewini.commands += ; sed -i \'\' \'$${LN_57}s%.*%$${LGEO_DIR}%\' $${DEV_DIR}/LDViewCustomIni
            ldviewiniMessage.commands += ; echo Project MESSAGE: Updating LDViewCustomIni entry $${LGEO_DIR}
        } else {
            message("~~~ LGEO LIBRARY NOT FOUND ~~~")

            !macx: ldviewini.commands += ; sed -i      \'$${LN_57}s\' $${DEV_DIR}/LDViewCustomIni
            else:  ldviewini.commands += ; sed -i \'\' \'$${LN_57}s\' $${DEV_DIR}/LDViewCustomIni
            ldviewiniMessage.commands += ; echo Project MESSAGE: Removing LDViewCustomnIi entry XmlMapPath
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
        !3RD_PARTY_INSTALL: include(LDViewCUITest.pri)

    } else {
        message("WARNING: LDRAW LIBRARY NOT FOUND - LDView CUI cannot be tested")
    }
}

QMAKE_CLEAN += LDViewMessages.ini LDViewMessages.h StudLogo.h

# Input
HEADERS += glinfo.h
SOURCES += ldview.cpp \
           glinfo.cpp

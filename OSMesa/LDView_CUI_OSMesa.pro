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

VERSION = 4.3.0

contains(DEFINES, _QT): DEFINES -= _QT
DEFINES         += _OSMESA

include(../LDViewGlobal.pri)

message("~~~ LDVIEW ($$join(ARCH,,,bit)) $${BUILD} CUI EXECUTABLE VERSION $$VERSION ~~~")

DEFINES		+= QT_THREAD_SUPPORT

macx: isEmpty(PREFIX):PREFIX    = $$_PRO_FILE_PWD_/../Build_OSX/usr
else: isEmpty(PREFIX):PREFIX    = /usr
isEmpty(BINDIR):BINDIR		= $$PREFIX/bin
isEmpty(DATADIR):DATADIR	= $$PREFIX/share
isEmpty(DOCDIR):DOCDIR		= $$DATADIR/doc
isEmpty(MANDIR):MANDIR		= $$DATADIR/man
isEmpty(SYSCONFDIR):SYSCONFDIR	= /etc

QMAKE_CXXFLAGS	+= $(Q_CXXFLAGS)
QMAKE_CFLAGS   	+= $(Q_CFLAGS)
QMAKE_LFLAGS   	+= $(Q_LDFLAGS)

unix:!macx: TARGET = ldview
else:       TARGET = LDView

unix {
    exists($${OSMESA_INC}/GL/osmesa.h):!USE_X11_SYSTEM_LIBS {
        message("~~~ Using LOCAL OSMESA library ~~~")
    } else: exists($${SYSTEM_PREFIX_}/X11/include/GL/osmesa.h): USE_X11_SYSTEM_LIBS {
        message("~~~ NOTICE: Using X11 SYSTEM OSMESA library ~~~")
    } else: exists($${SYSTEM_PREFIX_}/include/GL/osmesa.h) {
        message("~~~ NOTICE: Using SYSTEM OSMESA library ~~~")
    } else {
        message("CRITICAL: OSMesa libraries not detected!")
    }

    documentation.depends += compiler_translations_make_all
    documentation.path = $${DOCDIR}/ldview
    documentation.files = ../Readme.txt ../Help.html ../license.txt \
                            ../m6459.ldr \
                            ../ChangeHistory.html ../8464.mpd todo.txt \
                            ../Textures/SansSerif.fnt \
                            ../LDExporter/LGEO.xml \
                            ldview_de.qm ldview_cz.qm ldview_it.qm ldview_en.qm ldview_hu.qm
    INSTALLS += documentation
} 

macx: LIBS += $${OSX_FRAMEWORKS_CORE}

LDLIBS = ../TCFoundation/libTCFoundation$${POSTFIX}.a \
         ../LDLoader/libLDLoader$${POSTFIX}.a \
         ../TRE/libTRE$${POSTFIX}.a \
         ../LDLib/libLDraw$${POSTFIX}.a \
         ../LDExporter/libLDExporter$${POSTFIX}.a

LDLIBS += $${OSMESA_LDLIBS}

USE_SYSTEM_ZLIB:     LDLIBS += $${ZLIB_LDLIBS}

LDLIBDIRS = -L../TCFoundation \
            -L../TRE \
            -L../LDLoader \
            -L../LDLib \
            -L../LDExporter

LIBDIRS += $${LDLIBDIRS}

LIBS_  = -lLDraw$${POSTFIX} \
         -lTRE$${POSTFIX} \
         -lLDLoader$${POSTFIX} \
         -lTCFoundation$${POSTFIX} \
         -lLDExporter$${POSTFIX} \
         -lgl2ps \
         -l$${LIB_PNG} \
         -ljpeg \
         -l$${LIB_OSMESA} \
         -l$${LIB_GLU} \
         -lz \
         -ltinyxml

# 3ds
contains(DEFINES, EXPORT_3DS){
    macx {
        LIBS_ += -l3ds
    } else {
        equals (ARCH, 64) {
            LIBDIRS += -L/usr/lib64
            LIBS_   += -l3ds-64
        } else {
            LIBDIRS += -L/usr/lib32
            LIBS_   += -l3ds
        }
    }
}

INCLUDEPATH += .. $${LIBS_INC}

# Platform-specific
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

!USE_X11_SYSTEM_LIBS {
    QMAKE_LFLAGS   += -Wl,-search_paths_first
    LLVM_LIBS       = -lLLVMX86Disassembler -lLLVMX86AsmParser -lLLVMX86CodeGen -lLLVMGlobalISel -lLLVMSelectionDAG \
                      -lLLVMAsmPrinter -lLLVMDebugInfoCodeView -lLLVMDebugInfoMSF -lLLVMCodeGen -lLLVMScalarOpts \
                      -lLLVMInstCombine -lLLVMTransformUtils -lLLVMBitWriter -lLLVMX86Desc -lLLVMMCDisassembler \
                      -lLLVMX86Info -lLLVMX86AsmPrinter -lLLVMX86Utils -lLLVMMCJIT -lLLVMExecutionEngine \
                      -lLLVMTarget -lLLVMAnalysis -lLLVMProfileData -lLLVMRuntimeDyld -lLLVMObject \
                      -lLLVMMCParser -lLLVMBitReader -lLLVMMC -lLLVMCore -lLLVMSupport -lLLVMDemangle -lm
    LIBS_          += $${LLVM_LIBS}
}

LIBS               += $${LDLIBS} $${LIBDIRS} $${LIBS_} $${LIBS_DIR}

ini.target = LDViewMessages.ini
ini.depends = ../LDViewMessages.ini ../LDExporter/LDExportMessages.ini
ini.commands = cat ../LDViewMessages.ini ../LDExporter/LDExportMessages.ini > LDViewMessages.ini

ldviewmessages.target = LDViewMessages.h
ldviewmessages.depends = Headerize LDViewMessages.ini
ldviewmessages.commands = ./Headerize LDViewMessages.ini

studlogo.target = StudLogo.h
studlogo.depends = Headerize ../Textures/StudLogo.png
studlogo.commands = ./Headerize ../Textures/StudLogo.png

QMAKE_EXTRA_TARGETS += ini ldviewmessages studlogo
PRE_TARGETDEPS += LDViewMessages.ini LDViewMessages.h StudLogo.h

# just to test the different gallium drivers
!USE_X11_SYSTEM_LIBS {
    galliumdriver.target = osmesa
    USE_SOFTPIPE: galliumdriver.commands = export GALLIUM_DRIVER=softpipe
    else:         galliumdriver.commands = export GALLIUM_DRIVER=llvmpipe
    QMAKE_EXTRA_TARGETS += galliumdriver
    PRE_TARGETDEPS += osmesa
}

QMAKE_CLEAN += LDViewMessages.ini LDViewMessages.h StudLogo.h

# Input
SOURCES += ldview.cpp

# Test
#./LDView ../8464.mpd -SaveSnapshot=/tmp/8464.png -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0
include(LDViewCUITest.pri)

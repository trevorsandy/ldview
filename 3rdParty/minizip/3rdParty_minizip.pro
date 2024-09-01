######################################################################
# Automatically generated by qmake (2.01a) Sun 4. Jun 23:55:59 2017
######################################################################

TARGET = minizip
include(../../3rdParty.pri)

message("~~~ libminizip.a LIBRARY $${BUILD} ~~~")

!USE_SYSTEM_ZLIB {
	INCLUDEPATH  += $$_PRO_FILE_PWD_/../zlib
} else {
    INCLUDEPATH  += $$_PRO_FILE_PWD_/../../include   # for zlib.h and zconf.h
}

# MacOSX is a flavour of unix.
macx: DEFINES     += unix

# Input
HEADERS += $$PWD/crypt.h \
           $$PWD/mztools.h \
           $$PWD/unzip.h \
           $$PWD/zip.h
win32: HEADERS += $$PWD/iowin32.h
else:  HEADERS += $$PWD/ioapi.h

SOURCES += $$PWD/miniunz.c \
           $$PWD/minizip.c \
           $$PWD/mztools.c \
           $$PWD/unzip.c \
           $$PWD/zip.c

win32: SOURCES += $$$PWD/iowin32.c
else:  SOURCES += $$PWD/ioapi.c

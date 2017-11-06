######################################################################
# Automatically generated by qmake (3.0) Tue Jun 13 12:20:05 2017
######################################################################

TARGET = png16
include(../../3rdParty.pri)

message("~~~ libpng.a LIBRARY $${BUILD} ~~~")

# link libpng to libpng16
#PNG_COMMAND = ln -s $$DESTDIR/libpng16.a $$DESTDIR/libpng.a
#QMAKE_POST_LINK +=  $$escape_expand(\n\t) \
#                    $$PNG_COMMAND

# Input
HEADERS += png.h \
           pngconf.h \
           pngdebug.h \
           pnginfo.h \
           pnglibconf.h \
           pngpriv.h \
           pngstruct.h
SOURCES += png.c \
           pngerror.c \
           pngget.c \
           pngmem.c \
           pngpread.c \
           pngread.c \
           pngrio.c \
           pngrtran.c \
           pngrutil.c \
           pngset.c \
           pngtrans.c \
           pngwio.c \
           pngwrite.c \
           pngwtran.c \
           pngwutil.c

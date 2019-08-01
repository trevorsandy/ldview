######################################################################
# Automatically generated by qmake (2.01a) Sat 3. Jun 19:52:21 2017
######################################################################

TEMPLATE         = app
QT  		-= core
QT              -= opengl
QT  		-= gui
CONFIG		-= qt
CONFIG		-= opengl
CONFIG		+= warn_on
win32: CONFIG   += console
macx:  CONFIG   -= app_bundle

contains(DEFINES, _QT): DEFINES -= _QT
DEFINES         += _OSMESA

include(../LDViewGlobal.pri)

message("~~~ LGEOTables MODULE $$BUILD ~~~")

TARGET      = LGEOTables

INCLUDEPATH = $${TINYXML_INC}

DEFINES 	 += TIXML_USE_STL

LIBS       += $${TINYXML_LIBDIR} -ltinyxml

# Input
SOURCES    += LGEOTables.cpp
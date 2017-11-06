######################################################################
# Automatically generated by qmake (2.01a) Sat 3. Jun 19:48:48 2017
######################################################################

TEMPLATE = lib
QT 	+= core
QT 	-= opengl
QT 	-= gui
CONFIG 	+= qt
CONFIG 	-= opengl
CONFIG	+= thread
CONFIG  += staticlib
CONFIG 	+= warn_on

include(../LDViewGlobal.pri)

message("~~~ libLDExporter$$POSTFIX.a MODULE $$BUILD ~~~")

TARGET =  LDExporter$$POSTFIX

DEFINES 	+= TIXML_USE_STL

INCLUDEPATH     += $${TINYXML_INC}

contains(DEFINES, EXPORT_3DS): INCLUDEPATH += $${3DS_INC}

contains(DEFINES, _OSMESA): INCLUDEPATH += $${OSMESA_INC}

# Input
HEADERS += $$PWD/LD3dsExporter.h \
           $$PWD/LDExporter.h \
           $$PWD/LDExporterSetting.h \
           $$PWD/LDLdrExporter.h \
           $$PWD/LDPovExporter.h \
           $$PWD/LDStlExporter.h
SOURCES += $$PWD/LD3dsExporter.cpp \
           $$PWD/LDExporter.cpp \
           $$PWD/LDExporterSetting.cpp \
           $$PWD/LDLdrExporter.cpp \
           $$PWD/LDPovExporter.cpp \
           $$PWD/LDStlExporter.cpp
OTHER_FILES += $$PWD/LDExportMessages.ini \
               $$PWD/LGEO.xml
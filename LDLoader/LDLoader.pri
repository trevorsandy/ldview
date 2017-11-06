######################################################################
# Automatically generated by qmake (2.01a) Sat 3. Jun 19:48:16 2017
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

message("~~~ libLDLoader$$POSTFIX.a MODULE $$BUILD ~~~")

TARGET = LDLoader$$POSTFIX

# Input
HEADERS += $$PWD/LDLActionLine.h \
           $$PWD/LDLAutoCamera.h \
           $$PWD/LDLCamera.h \
           $$PWD/LDLCommentLine.h \
           $$PWD/LDLConditionalLineLine.h \
           $$PWD/LDLEmptyLine.h \
           $$PWD/LDLError.h \
           $$PWD/LDLFacing.h \
           $$PWD/LDLFileLine.h \
           $$PWD/LDLFindFileAlert.h \
           $$PWD/LDLLineLine.h \
           $$PWD/LDLMacros.h \
           $$PWD/LDLMainModel.h \
           $$PWD/LDLModel.h \
           $$PWD/LDLModelLine.h \
           $$PWD/LDLPalette.h \
           $$PWD/LDLPrimitiveCheck.h \
           $$PWD/LDLQuadLine.h \
           $$PWD/LDLShapeLine.h \
           $$PWD/LDLTriangleLine.h \
           $$PWD/LDLUnknownLine.h \
           $$PWD/LDrawIni.h \
           $$PWD/LDrawInP.h
SOURCES += $$PWD/LDLActionLine.cpp \
           $$PWD/LDLAutoCamera.cpp \
           $$PWD/LDLCamera.cpp \
           $$PWD/LDLCommentLine.cpp \
           $$PWD/LDLConditionalLineLine.cpp \
           $$PWD/LDLEmptyLine.cpp \
           $$PWD/LDLError.cpp \
           $$PWD/LDLFacing.cpp \
           $$PWD/LDLFileLine.cpp \
           $$PWD/LDLFindFileAlert.cpp \
           $$PWD/LDLLineLine.cpp \
           $$PWD/LDLMainModel.cpp \
           $$PWD/LDLModel.cpp \
           $$PWD/LDLModelLine.cpp \
           $$PWD/LDLPalette.cpp \
           $$PWD/LDLPrimitiveCheck.cpp \
           $$PWD/LDLQuadLine.cpp \
           $$PWD/LDLShapeLine.cpp \
           $$PWD/LDLTriangleLine.cpp \
           $$PWD/LDLUnknownLine.cpp \
           $$PWD/LDrawIni.c

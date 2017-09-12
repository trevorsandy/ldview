# 3rd party library directives

#requires(USE_THIRD_PARTY_LIBS)

TEMPLATE = lib
QT 	-= core
QT 	-= gui
CONFIG 	-= qt
CONFIG  += staticlib 
CONFIG 	+= warn_on

# platform switch
contains(QT_ARCH, x86_64) {
    ARCH = 64
} else {
    ARCH = 32
}

# build type
CONFIG(debug, debug|release) {
    BUILD = DEBUG
    DESTDIR = debug
} else {
    BUILD = RELEASE
    DESTDIR = release
}
win32: BUILD += WINDOWS
else:  BUILD += $$upper($$system(uname))

INCLUDEPATH += $$PWD

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

OBJECTS_DIR       = $$DESTDIR/.obj
win32 {
    CONFIG       += windows
    QMAKE_EXT_OBJ = .obj
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
                        -Wno-format \
                        -Wno-switch \
                        -Wno-comment \
                        -Wno-unused-result \
                        -Wno-unused-but-set-variable

QMAKE_CXXFLAGS_WARN_ON = $${QMAKE_CFLAGS_WARN_ON}

QMAKE_CFLAGS_WARN_ON +=  \
                        -Wno-implicit-function-declaration \
                        -Wno-incompatible-pointer-types
macx {
QMAKE_CFLAGS_WARN_ON += -Wno-incompatible-pointer-types-discards-qualifiers \
                        -Wno-undefined-bool-conversion \
                        -Wno-invalid-source-encoding \
                        -Wno-mismatched-new-delete \
                        -Wno-for-loop-analysis \
                        -Wno-int-conversion \
                        -Wno-reorder
}


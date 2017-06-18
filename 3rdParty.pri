# 3rd party library directives

#requires(USE_THIRD_PARTY_LIBS)

TEMPLATE = lib
QT 	-= core
QT 	-= gui
CONFIG 	-= qt
CONFIG  += staticlib 
CONFIG 	+= warn_on

contains(QT_ARCH, x86_64) {
    ARCH = 64
} else {
    ARCH = 32
}

CONFIG(debug, debug|release) {
    BUILD = DEBUG
} else {
    BUILD = RELEASE
}
BUILD += $$upper($$system(uname))

INCLUDEPATH += $$PWD

# USE GNU_SOURCE
unix:!macx: DEFINES += _GNU_SOURCE

# USE CPP 11
DEFINES -= USE_CPP11
macx: freebsd: DEFINES += USE_CPP11
else: lessThan(QT_MAJOR_VERSION, 5): DEFINES += USE_CPP11
contains(DEFINES, USE_CPP11) {
    unix:!freebsd:!macx {
        GCC_VERSION = $$system(g++ -dumpversion)
        greaterThan(GCC_VERSION, 4.6) {
            QMAKE_CXXFLAGS += -std=c++11
        } else {
            QMAKE_CXXFLAGS += -std=c++0x
        }
    } else {
        QMAKE_CXXFLAGS += -std=c++11
    }
}

OBJECTS_DIR       = .obj
MOC_DIR           = .moc
win32 {
    CONFIG       += windows
    QMAKE_EXT_OBJ = .obj
}

QMAKE_CFLAGS_WARN_ON =  -Wall -W \
                        -Wno-unused-parameter \
                        -Wno-parentheses \
                        -Wno-unused-variable \
                        -Wno-implicit-function-declaration \
                        -Wno-int-conversion \
                        -Wno-incompatible-pointer-types-discards-qualifiers \
                        -Wno-incompatible-pointer-types \
                        -Wno-invalid-source-encoding \
                        -Wno-deprecated-declarations \
                        -Wno-return-type \
                        -Wno-undefined-bool-conversion \
                        -Wno-reorder \
                        -Wno-sign-compare \
                        -Wno-uninitialized \
                        -Wno-for-loop-analysis \
                        -Wno-format \
                        -Wno-switch \
                        -Wno-comment \
                        -Wno-mismatched-new-delete
QMAKE_CXXFLAGS_WARN_ON = $${QMAKE_CFLAGS_WARN_ON}

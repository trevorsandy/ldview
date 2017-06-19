
unix {

    USE_SOFTPIPE: GAL_DRIVER = softpipe
    else:         GAL_DRIVER = llvmpipe

#       ./LDView ../8464.mpd -SaveSnapshot=/tmp/8464.png -IniFile=LDViewCustomIni -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

    RUN_CUI_INI_TEST {
        INI_FILE   = $$(HOME)/Projects/ldview/OSMesa/LDViewCustomIni
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                            \
                                if [ -f /tmp/8464.png ] ; then rm -f /tmp/8464.png ; fi                     \
                           $$escape_expand(\n\t)                                                            \
                                export GALLIUM_DRIVER=$$GAL_DRIVER                                          \
                           $$escape_expand(\n\t)                                                            \
                                echo Project MESSAGE: Using custom IniFile: $${INI_FILE}                    \
                           $$escape_expand(\n\t)                                                            \
                                ./$${TARGET} ../8464.mpd -SaveSnapshot=/tmp/8464.png -IniFile=$${INI_FILE}  \
                                -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0              \
                           $$escape_expand(\n\t)                                                            \
                                file /tmp/8464.png                                                          \
                           $$escape_expand(\n\t)                                                            \
                                for a in eog gthumb ; do                                                    \
                                    if which $$a >/dev/null 2>/dev/null ; then                              \
                                        $$a /tmp/8464.png ;                                                 \
                                        break ;                                                             \
                                    fi                                                                      \
                                done                                                                        \
                            $$escape_expand(\n\t)                                                           \
                                echo Project MESSAGE: Test completed.
    } else: RUN_CUI_STD_TEST {

#       ./LDView ../8464.mpd -SaveSnapshot=/tmp/8464.png -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

        UNIX_DEF_LD_DIR = /usr/share/ldraw
        OSX_DEF_LD_DIR  = /Library/ldraw
        OSX_HOME_LD_DIR = ~/Library/ldraw
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                    \
                                if [ ! -f ~/.ldviewrc  ] ; then                                                     \
                                    if [ ! -f ~/.config/LDView/ldviewrc ] ; then                                    \
                                        cp ldviewrc.sample ~/.ldviewrc ;                                            \
                                        echo Project MESSAGE: Default .ldviewrc created ;                           \
                                    else                                                                            \
                                        echo Project MESSAGE: Found .ldviewc at ~/.config/LDView ;                  \
                                    fi                                                                              \
                                else                                                                                \
                                    echo Project MESSAGE: Found .ldviewc at ~/ ;                                    \
                                fi                                                                                  \
                            $$escape_expand(\n\t)                                                                   \
                                if [ -f ~/.ldviewrc ] && [ -d "`grep ^LDrawDir ~/.ldviewrc | cut -f2 -d=`" ] ; then \
                                    echo Project MESSAGE: Using LDraw dir:                                          \
                                            `grep ^LDrawDir ~/.ldviewrc | cut -f2 -d=` ;                            \
                                elif [ -f ~/.config/LDView/ldviewrc ] && [ -d "`grep ^LDrawDir ~/.config/LDView/ldviewrc | cut -f2 -d=`" ] ; then   \
                                    echo Project MESSAGE: Using LDraw dir:                                          \
                                            `grep ^LDrawDir ~/.config/LDView/ldviewrc | cut -f2 -d=`;               \
                                elif [ -f /usr/share/ldraw/parts/3001.dat ] ; then                                  \
                                    echo Project MESSAGE: Using LDraw dir default: /usr/share/ldraw ;               \
                                   #sed -i "2s/.*/LDrawDir=$${UNIX_DEF_LD_DIR}/" "~/.ldviewrc" ;                    \
                                elif [ `uname` == "Darwin" ] && [ -f /Library/ldraw/parts/3001.dat ] ; then         \
                                    echo Project MESSAGE: Using LDraw dir default: /Library/ldraw ;                 \
                                   #sed -i "2s/.*/LDrawDir=$${OSX_DEF_LD_DIR}/" "~/.ldviewrc" ;                     \
                                elif [ `uname` == "Darwin" ] && [ -f ~/Library/ldraw/parts/3001.dat ] ; then        \
                                    echo Project MESSAGE: Using LDraw dir: ~/Library/ldraw ;                        \
                                   #sed -i "2s/.*/LDrawDir=$${OSX_HOME_LD_DIR}/" "~/.ldviewrc" ;                    \
                                else                                                                                \
                                    echo Project MESSAGE: ERROR Neiter LDraw dir nor ldviewrc file were found! ;    \
                                    exit 1;                                                                         \
                                fi                                                                                  \
                            $$escape_expand(\n\t)                                                                   \
                                if [ -f /tmp/8464.png ] ; then rm -f /tmp/8464.png ; fi                             \
                            $$escape_expand(\n\t)                                                                   \
                                ./$${TARGET} ../8464.mpd -SaveSnapshot=/tmp/8464.png                                \
                                -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0                      \
                            $$escape_expand(\n\t)                                                                   \
                                file /tmp/8464.png                                                                  \
                            $$escape_expand(\n\t)                                                                   \
                                for a in eog gthumb ; do                                                            \
                                    if which $$a >/dev/null 2>/dev/null ; then                                      \
                                        $$a /tmp/8464.png ;                                                         \
                                        break ;                                                                     \
                                    fi                                                                              \
                                done                                                                                \
                            $$escape_expand(\n\t)                                                                   \
                                echo Project MESSAGE: Test completed.
    }
}

#Old Test
#./LDView ../8464.mpd -SaveSnapshot=/tmp/8464.png -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

#unix {
#    UNIX_DEF_LD_DIR = /usr/share/ldraw
#    OSX_DEF_LD_DIR  = /Library/ldraw
#    OSX_HOME_LD_DIR = ~/Library/ldraw
#    QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                    \
#                            if [ ! -f ~/.ldviewrc  ] ; then                                                     \
#                                if [ ! -f ~/.config/LDView/ldviewrc ] ; then                                    \
#                                    cp ldviewrc.sample ~/.ldviewrc ;                                            \
#                                    echo Project MESSAGE: Default .ldviewrc created ;                           \
#                                else                                                                            \
#                                    echo Project MESSAGE: Found .ldviewc at ~/.config/LDView ;                  \
#                                fi                                                                              \
#                            else                                                                                \
#                                echo Project MESSAGE: Found .ldviewc at ~/ ;                                    \
#                            fi                                                                                  \
#                        $$escape_expand(\n\t)                                                                   \
#                            if [ -f ~/.ldviewrc ] && [ -d "`grep ^LDrawDir ~/.ldviewrc | cut -f2 -d=`" ] ; then \
#                                echo Project MESSAGE: Using LDraw dir:                                          \
#                                        `grep ^LDrawDir ~/.ldviewrc | cut -f2 -d=` ;                            \
#                            elif [ -f ~/.config/LDView/ldviewrc ] && [ -d "`grep ^LDrawDir ~/.config/LDView/ldviewrc | cut -f2 -d=`" ] ; then   \
#                                echo Project MESSAGE: Using LDraw dir:                                          \
#                                        `grep ^LDrawDir ~/.config/LDView/ldviewrc | cut -f2 -d=`;               \
#                            elif [ -f /usr/share/ldraw/parts/3001.dat ] ; then                                  \
#                                echo Project MESSAGE: Using LDraw dir default: /usr/share/ldraw ;               \
#                                sed -i "2s/.*/LDrawDir=$${UNIX_DEF_LD_DIR}/" "~/.ldviewrc" ;                    \
#                            elif [ `uname` == "Darwin" ] && [ -f /Library/ldraw/parts/3001.dat ] ; then         \
#                                echo Project MESSAGE: Using LDraw dir default: /Library/ldraw ;                 \
#                                sed -i "2s/.*/LDrawDir=$${OSX_DEF_LD_DIR}/" "~/.ldviewrc" ;                     \
#                            elif [ `uname` == "Darwin" ] && [ -f ~/Library/ldraw/parts/3001.dat ] ; then        \
#                                echo Project MESSAGE: Using LDraw dir: ~/Library/ldraw ;                        \
#                                sed -i "2s/.*/LDrawDir=$${OSX_HOME_LD_DIR}/" "~/.ldviewrc" ;                    \
#                            else                                                                                \
#                                echo Project MESSAGE: ERROR Neiter LDraw dir nor ldviewrc file were found! ;    \
#                                exit 1;                                                                         \
#                            fi                                                                                  \
#                        $$escape_expand(\n\t)                                                                   \
#                            if [ -f /tmp/8464.png ] ; then rm -f /tmp/8464.png ; fi                             \
#                        $$escape_expand(\n\t)                                                                   \
#                            ./$${TARGET} ../8464.mpd -SaveSnapshot=/tmp/8464.png                                \
#                            -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0                      \
#                        $$escape_expand(\n\t)                                                                   \
#                            file /tmp/8464.png                                                                  \
#                        $$escape_expand(\n\t)                                                                   \
#                            for a in eog gthumb ; do                                                            \
#                                if which $$a >/dev/null 2>/dev/null ; then                                      \
#                                    $$a /tmp/8464.png ;                                                         \
#                                    break ;                                                                     \
#                                fi                                                                              \
#                            done                                                                                \
#                        $$escape_expand(\n\t)                                                                   \
#                            echo Project MESSAGE: Test completed.
#}


#LDRAW_PATH = LDrawDir=$$(HOME)/Library/LDraw
#LGEO_PATH  = XmlMapPath=$${LDRAW_PATH}/lgeo
#INI_FILE   = ./LDViewCustomIni
#FOO        = $${LITERAL_DOLLAR}
#LN_13      = 13
#LN_57      = 57
#INI_FILE   = $$(HOME)/Projects/ldview/OSMesa/LDViewCustomIni

#message("FOOO $${LITERAL_DOLLAR}0")
#message("FOOO $${FOO}")

#unix {
#    macx {
#        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                            \
#                        if [ -f /usr/share/ldraw/parts/3001.dat ] ; then                                    \
#                             echo Project MESSAGE: Using default LDraw dir: /usr/share/ldraw ;              \
#                             awk 'NR==$${LN_13} {$${FOO}="$${LDRAW_PATH}"} 1' $${INI_FILE} ;                    \
#                             awk 'NR==$${LN_57} {$${FOO}="$${LDRAW_PATH}"} 1' $${INI_FILE} ;                    \
#                        elif [ `uname` == 'Darwin' ] && [ -f /Library/ldraw/parts/3001.dat ] ; then         \
#                             echo Project MESSAGE: Using default LDraw dir: /Library/ldraw ;                \
#                             awk 'NR==$${LN_13} {$${FOO}="$${LDRAW_PATH}"} 1' $${INI_FILE} ;                    \
#                             awk 'NR==$${LN_57} {$${FOO}="$${LDRAW_PATH}"} 1' $${INI_FILE} ;                    \
#                        elif [ `uname` == 'Darwin' ] && [ -f ~/Library/ldraw/parts/3001.dat ] ; then        \
#                             echo Project MESSAGE: Using LDraw dir: ~/Library/ldraw ;                       \
#                             awk 'NR==$${LN_13} {$${LITERAL_DOLLAR}0="$${LDRAW_PATH}"} 1' $${INI_FILE} ;                    \
#                             awk 'NR==$${LN_57} {$${LITERAL_DOLLAR}0="$${LDRAW_PATH}"} 1' $${INI_FILE} ;                    \
#                        else                                                                                \
#                            echo Project MESSAGE: ERROR Neiter LDraw dir nor ldviewrc file were found! ;    \
#                            exit 1;                                                                         \
#                        fi
#    } else {
#        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                            \
#                        if [ -f /usr/share/ldraw/parts/3001.dat ] ; then                                    \
#                             echo Project MESSAGE: Using default LDraw dir: /usr/share/ldraw ;              \
#                             sed -i '$${LN_13}s/.*/$${LDRAW_PATH}/' '$${INI_FILE}' ;                        \
#                             sed -i '$${LN_57}s/.*/$${LGEO_PATH}/' '$${INI_FILE}' ;                         \
#                        elif [ `uname` == 'Darwin' ] && [ -f /Library/ldraw/parts/3001.dat ] ; then         \
#                             echo Project MESSAGE: Using default LDraw dir: /Library/ldraw ;                \
#                             sed -i '$${LN_13}s/.*/$${LDRAW_PATH}/' '$${INI_FILE}' ;                        \
#                             sed -i '$${LN_57}s/.*/$${LGEO_PATH}/' '$${INI_FILE}' ;                         \
#                        elif [ `uname` == 'Darwin' ] && [ -f ~/Library/ldraw/parts/3001.dat ] ; then        \
#                             echo Project MESSAGE: Using LDraw dir: ~/Library/ldraw ;                       \
#                             sed -i '$${LN_13}s/.*/$${LDRAW_PATH}/' '$${INI_FILE}' ;                        \
#                             sed -i '$${LN_57}s/.*/$${LGEO_PATH}/' '$${INI_FILE}' ;                         \
#                        else                                                                                \
#                            echo Project MESSAGE: ERROR Neiter LDraw dir nor ldviewrc file were found! ;    \
#                            exit 1;                                                                         \
#                        fi
#     }
#        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                            \
#                                if [ -f /tmp/8464.png ] ; then rm -f /tmp/8464.png ; fi                     \
#                           $$escape_expand(\n\t)                                                            \
#                                ./$${TARGET} ../8464.mpd -SaveSnapshot=/tmp/8464.png IniFile=$${INI_FILE}   \
#                                -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0              \
#                           $$escape_expand(\n\t)                                                            \
#                                file /tmp/8464.png                                                          \
#                           $$escape_expand(\n\t)                                                            \
#                                for a in eog gthumb ; do                                                    \
#                                    if which $$a >/dev/null 2>/dev/null ; then                              \
#                                        $$a /tmp/8464.png ;                                                 \
#                                        break ;                                                             \
#                                    fi                                                                      \
#                                done                                                                        \
#                           $$escape_expand(\n\t)                                                            \
#                                echo Project MESSAGE: Test completed.
#}

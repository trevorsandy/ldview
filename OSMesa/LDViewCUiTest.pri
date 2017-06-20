
unix {

    USE_SOFTPIPE: GAL_DRIVER = softpipe
    else:         GAL_DRIVER = llvmpipe

#   ./LDView ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=$HOME/Projects/ldview/OSMesa/LDViewCustomIni -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

    INI_FILE   = $$(HOME)/Projects/ldview/OSMesa/LDViewCustomIni
    QMAKE_POST_LINK += $$escape_expand(\n\t)                                                            \
                            export GALLIUM_DRIVER=$$GAL_DRIVER                                          \
                       $$escape_expand(\n\t)                                                            \
                            echo Project MESSAGE: Using custom IniFile: $${INI_FILE}                    \
                       $$escape_expand(\n\t)                                                            \
                            if [ -f /tmp/8464i.png ] ; then rm -f /tmp/8464i.png ; fi                   \
                       $$escape_expand(\n\t)                                                            \
                            ./$${TARGET} ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=$${INI_FILE} \
                            -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0      \
                       $$escape_expand(\n\t)                                                            \
                            file /tmp/8464i.png                                                         \
                       $$escape_expand(\n\t)                                                            \
                            for a in eog gthumb ; do                                                    \
                                if which $$a >/dev/null 2>/dev/null ; then                              \
                                    $$a /tmp/8464i.png ;                                                \
                                    break ;                                                             \
                                fi                                                                      \
                            done                                                                        \
                        $$escape_expand(\n\t)                                                           \
                            echo Project MESSAGE: Test completed.


#   ./LDView ../8464.mpd -SaveSnapshot=/tmp/8464.png -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

    QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                    \
                            if [ ! -f ~/.ldviewrc  ] ; then                                                     \
                                if [ ! -f ~/.config/LDView/ldviewrc ] ; then                                    \
                                    cp ldviewrc.sample ~/.ldviewrc ;                                            \
                                fi                                                                              \
                            fi                                                                                  \
                        $$escape_expand(\n\t)                                                                   \
                            if [ -f ~/.ldviewrc ] && [ -d "`grep ^LDrawDir ~/.ldviewrc | cut -f2 -d=`" ] ; then \
                                echo Project MESSAGE: Using LDraw dir:                                          \
                                        `grep ^LDrawDir ~/.ldviewrc | cut -f2 -d=` ;                            \
                            elif [ -f ~/.config/LDView/ldviewrc ] && [ -d "`grep ^LDrawDir ~/.config/LDView/ldviewrc | cut -f2 -d=`" ] ; then   \
                                echo Project MESSAGE: Using LDraw dir:                                          \
                                        `grep ^LDrawDir ~/.config/LDView/ldviewrc | cut -f2 -d=`;               \
                            else                                                                                \
                                echo Project MESSAGE: Using LDraw directory: $${LDRAW_PATH} ;                   \
                                sed -i \'\' \'2s%.*%$${LDRAW_DIR}%\' ~/.ldviewrc ;                              \
                            fi                                                                                  \
                        $$escape_expand(\n\t)                                                                   \
                            if [ -f /tmp/8464.png ] ; then rm -f /tmp/8464.png ; fi                             \
                        $$escape_expand(\n\t)                                                                   \
                            export GALLIUM_DRIVER=$$GAL_DRIVER                                                  \
                        $$escape_expand(\n\t)                                                                   \
                            ./$${TARGET} ../8464.mpd -SaveSnapshot=/tmp/8464.png -Info=1                        \
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


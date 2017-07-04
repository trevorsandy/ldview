
unix {

    USE_SWRAST:   GAL_DRIVER = swrast
    USE_SOFTPIPE: GAL_DRIVER = softpipe
    else: macx:   GAL_DRIVER = llvmpipe
    else:         GAL_DRIVER = swr

#   ./ldview ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=/home/trevor/projects/ldview/OSMesa/LDViewCustomIni Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

    INI_FILE   = $$(HOME)/projects/ldview/OSMesa/LDViewCustomIni
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
                            echo Project MESSAGE: Command line INI test completed.


#   ./ldview ../8464.mpd -SaveSnapshot=/tmp/8464.png -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

    !exists($$(HOME)/.ldviewrc): !exists($$(HOME)/.config/LDView/ldviewrc) {
        CLEAN_LDVIEWRC = YES
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                \
                                cp ldviewrc.sample $$(HOME)/.ldviewrc                                           \
                           $$escape_expand(\n\t)                                                                \
                                echo Project MESSAGE: Created temporary user INI file at $$(HOME)/.ldviewrc
    }
    macx {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                \
                            if [ -f $$(HOME)/.ldviewrc ] &&                                                     \
                               [ -d "`grep ^LDrawDir $$(HOME)/.ldviewrc | cut -f2 -d=`" ] ; then                \
                                echo Project MESSAGE: Using LDraw dir:                                          \
                                        `grep ^LDrawDir $$(HOME)/.ldviewrc | cut -f2 -d=` ;                     \
                            elif [ -f $$(HOME)/.config/LDView/ldviewrc ] &&                                     \
                                 [ -d "`grep ^LDrawDir $$(HOME)/.config/LDView/ldviewrc | cut -f2 -d=`" ] ; then\
                                echo Project MESSAGE: Using LDraw dir:                                          \
                                        `grep ^LDrawDir $$(HOME)/.config/LDView/ldviewrc | cut -f2 -d=`;        \
                            else                                                                                \
                                echo Project MESSAGE: Using LDraw directory: $${LDRAW_PATH} ;                   \
                                sed -i \'\' \'2s%.*%$${LDRAW_DIR}%\' $$(HOME)/.ldviewrc ;                       \
                            fi
    } else {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                \
                            if [ -f $$(HOME)/.ldviewrc ] &&                                                     \
                               [ -d "`grep ^LDrawDir $$(HOME)/.ldviewrc | cut -f2 -d=`" ] ; then                \
                                echo Project MESSAGE: Using LDraw dir:                                          \
                                        `grep ^LDrawDir $$(HOME)/.ldviewrc | cut -f2 -d=` ;                     \
                            elif [ -f $$(HOME)/.config/LDView/ldviewrc ] &&                                     \
                                 [ -d "`grep ^LDrawDir $$(HOME)/.config/LDView/ldviewrc | cut -f2 -d=`" ] ; then\
                                echo Project MESSAGE: Using LDraw dir:                                          \
                                        `grep ^LDrawDir $$(HOME)/.config/LDView/ldviewrc | cut -f2 -d=`;        \
                            else                                                                                \
                                echo Project MESSAGE: Using LDraw directory: $${LDRAW_PATH} ;                   \
                                sed -i \'2s%.*%$${LDRAW_DIR}%\' $$(HOME)/.ldviewrc ;                            \
                            fi
    }
    QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                    \
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
                            done
    contains(CLEAN_LDVIEWRC, YES) {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                \
                                rm -f $$(HOME)/.ldviewrc                                                        \
                           $$escape_expand(\n\t)                                                                \
                                echo Project MESSAGE: Removed temporary user INI file from $$(HOME)/.ldviewrc
    }
    QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                    \
                            echo Project MESSAGE: User INI test completed.
}


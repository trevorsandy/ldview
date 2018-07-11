
unix {

    USE_SWRAST:   GAL_DRIVER = swrast
    USE_SOFTPIPE: GAL_DRIVER = softpipe
    else: macx:   GAL_DRIVER = llvmpipe
    else:         GAL_DRIVER = swr

# Linux  ./ldview ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=/home/trevor/projects/ldview/OSMesa/LDViewCustomIni -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0
# MacOS  ./ldview ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=/Users/trevorsandy/Projects/ldview/OSMesa/LDViewCustomIni -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

    INI_FILE   = $$_PRO_FILE_PWD_/LDViewCustomIni
    QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                            \
                           @export GALLIUM_DRIVER=$$GAL_DRIVER                                                          \
                      $$escape_expand(\n\t)                                                                             \
                           @echo "Project MESSAGE: Using custom IniFile: $${INI_FILE}"                                  \
                      $$escape_expand(\n\t)                                                                             \
                           @if [ -f /tmp/8464i.png ] ; then rm -f /tmp/8464i.png ; fi                                   \
                      $$escape_expand(\n\t)                                                                             \
                           @cd $${OUT_PWD}/$${DESTDIR} && ./$${TARGET} $$_PRO_FILE_PWD_/../8464.mpd                     \
                           -SaveSnapshot=/tmp/8464i.png -IniFile=$${INI_FILE} -Info=1                                   \
                           -SaveWidth=1024 -SaveHeight=1024 -ShowErrors=0 -SaveActualSize=0                             \
                           -LDConfig=$${LDRAW_PATH}/LDCfgalt.ldr                                                        \
                      $$escape_expand(\n\t)                                                                             \
                           @if [ -f /tmp/8464i.png ] ; then                                                             \
                             file /tmp/8464i.png ;                                                                      \
                             for a in eog gthumb ; do                                                                   \
                               if which $$a >/dev/null 2>/dev/null ; then                                               \
                                 $$a /tmp/8464i.png;                                                                    \
                                 break ;                                                                                \
                               fi                                                                                       \
                             done                                                                                       \
                           fi                                                                                           \
                      $$escape_expand(\n\t)                                                                             \
                           @echo && echo "Project MESSAGE: Command line INI test completed."


#   ./ldview ../8464.mpd -SaveSnapshot=/tmp/8464.png -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0

    !exists($$(HOME)/.ldviewrc): !exists($$(HOME)/.config/LDView/ldviewrc) {
        CLEAN_LDVIEWRC = YES
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                         \
                                @cp $$_PRO_FILE_PWD_/ldviewrc.sample $$(HOME)/.ldviewrc &&                               \
                                echo && echo "Project MESSAGE: Created temporary user INI file at $$(HOME)/.ldviewrc"
    }
    macx {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                         \
                                @if [ -f $$(HOME)/.ldviewrc ] &&                                                         \
                                   [ -d "`grep ^LDrawDir $$(HOME)/.ldviewrc | cut -f2 -d=`" ] ; then                     \
                                    echo "Project MESSAGE: Using LDraw dir:                                              \
                                            `grep ^LDrawDir $$(HOME)/.ldviewrc | cut -f2 -d=`" ;                         \
                                elif [ -f $$(HOME)/.config/LDView/ldviewrc ] &&                                          \
                                     [ -d "`grep ^LDrawDir $$(HOME)/.config/LDView/ldviewrc | cut -f2 -d=`" ] ; then     \
                                    echo "Project MESSAGE: Using LDraw dir:                                              \
                                            `grep ^LDrawDir $$(HOME)/.config/LDView/ldviewrc | cut -f2 -d=`" ;           \
                                else                                                                                     \
                                    echo "Project MESSAGE: Using LDraw directory: $${LDRAW_PATH}" ;                      \
                                    sed -i \'\' \'2s%.*%$${LDRAW_DIR}%\' $$(HOME)/.ldviewrc ;                            \
                                fi
    } else {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                         \
                                @if [ -f $$(HOME)/.ldviewrc ] &&                                                         \
                                   [ -d "`grep ^LDrawDir $$(HOME)/.ldviewrc | cut -f2 -d=`" ] ; then                     \
                                    echo "Project MESSAGE: Using LDraw dir:                                              \
                                            `grep ^LDrawDir $$(HOME)/.ldviewrc | cut -f2 -d=`" ;                         \
                                elif [ -f $$(HOME)/.config/LDView/ldviewrc ] &&                                          \
                                     [ -d "`grep ^LDrawDir $$(HOME)/.config/LDView/ldviewrc | cut -f2 -d=`" ] ; then     \
                                    echo "Project MESSAGE: Using LDraw dir:                                              \
                                            `grep ^LDrawDir $$(HOME)/.config/LDView/ldviewrc | cut -f2 -d=`" ;           \
                                else                                                                                     \
                                    echo "Project MESSAGE: Using LDraw directory: $${LDRAW_PATH}" ;                      \
                                    sed -i \'2s%.*%$${LDRAW_DIR}%\' $$(HOME)/.ldviewrc ;                                 \
                                fi
    }
    QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                           @if [ -f /tmp/8464.png ] ; then rm -f /tmp/8464.png ; fi                                      \
                       $$escape_expand(\n\t)                                                                             \
                           @export GALLIUM_DRIVER=$$GAL_DRIVER                                                           \
                       $$escape_expand(\n\t)                                                                             \
                           @cd $${OUT_PWD}/$${DESTDIR} && ./$${TARGET} $$_PRO_FILE_PWD_/../8464.mpd                      \
                           -SaveSnapshot=/tmp/8464.png -IniFile=$${INI_FILE} -Info=1                                     \
                           -SaveWidth=1024 -SaveHeight=1024 -ShowErrors=0 -SaveActualSize=0                              \
                       $$escape_expand(\n\t)                                                                             \
                           @if [ -f /tmp/8464.png ] ; then                                                              \
                             file /tmp/8464.png ;                                                                       \
                             for a in eog gthumb ; do                                                                    \
                               if which $$a >/dev/null 2>/dev/null ; then                                                \
                                 $$a /tmp/8464.png;                                                                     \
                                 break ;                                                                                 \
                               fi                                                                                        \
                             done                                                                                        \
                           fi
    contains(CLEAN_LDVIEWRC, YES) {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                         \
                                @rm -rf $$(HOME)/.ldviewrc                                                               \
                           $$escape_expand(\n\t)                                                                         \
                                @echo && echo "Project MESSAGE: Removed temporary user INI file from $$(HOME)/.ldviewrc"
    }
    QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                            @echo && echo "Project MESSAGE: User INI test completed." && echo

}

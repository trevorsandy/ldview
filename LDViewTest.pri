unix|win32 {
    msys|win32-arm64-msvc|win32-msvc* {
        LDVIEW_INI           = ldview.ini
        LDVIEW_EXE           = $${TARGET}.exe
        LDV_RC_FILE          = $${LDVIEW_INI}
    } else {
        LDVIEW_INI           = ldviewrc.sample
        LDVIEW_EXE           = ./$${TARGET}
        LDV_RC_FILE          = .ldviewrc
    }

    if (mingw:ide_qtcreator)|win32-arm64-msvc|win32-msvc* {
        LDV_TEST_TYPE        = Basic
        LDV_COPY_CMD         = copy /v /y
        LDV_DEL_CMD          = del /q
        LDV_ECHO_LL          = echo.
        LDV_ECHO_NL          = echo. & echo
        LDV_INI_DIR          = $$(USERPROFILE)
        LDV_IMAGE_FILE       = %TEMP%\\8464i.png
        LDV_IMAGE_INFO_BAT   = $$dirname(LDV_MPD_FILE)/ImageInfo.bat
        LDV_IMAGE_DEL_CMD    = if exist \"$${LDV_IMAGE_FILE}\" \( $${LDV_DEL_CMD} $${LDV_IMAGE_FILE} \)
        LDV_IMAGE_INFO_CMD   = if exist \"$${LDV_IMAGE_FILE}\" \( $${LDV_IMAGE_INFO_BAT} $${LDV_IMAGE_FILE} \)
    } else {
        LDV_TEST_TYPE        = Standard
        LDV_COPY_CMD         = cp -f
        LDV_DEL_CMD          = rm -f
        LDV_ECHO_LL          = echo ""
        LDV_ECHO_NL          = echo && echo
        LDV_INI_DIR          = $$(HOME)
        LDV_IMAGE_FILE       = /tmp/8464i.png
        LDV_IMAGE_DEL_CMD    = if [ -f $${LDV_IMAGE_FILE} ] ; then rm -f $${LDV_IMAGE_FILE} ; fi
        LDV_IMAGE_INFO_CMD   = if [ -f $${LDV_IMAGE_FILE} ] ; then                                                \
                                 file $${LDV_IMAGE_FILE} ;                                                        \
                                 for a in eog gthumb ; do                                                         \
                                   if which $$a >/dev/null 2>/dev/null ; then $$a $${LDV_IMAGE_FILE} ; break ; fi \
                                 done                                                                             \
                               fi                                                                                 \
    }

    QMAKE_POST_LINK         += $$escape_expand(\n\t) \
                               @$${LDV_ECHO_NL} "Project MESSAGE: ~~~ Performing $${LDV_TEST_TYPE} build test ~~~"

    LDV_STANDARD_INI         = $$shell_path($${LDV_RC_DIR}/$${LDVIEW_INI})
    LDV_DEFAULT_INI          = $$shell_path($${LDV_INI_DIR}/$${LDV_RC_FILE})
    LDV_INI_CFG_RC           = $$shell_path($${LDV_INI_DIR}/.config/LDView/ldviewrc)

    LDRAWDIR                 = $$(LDRAWDIR)
    exists($${LDRAWDIR}/parts) {
        LDRAW_PATH           = $$shell_path($$absolute_path($${LDRAWDIR}))
        LDRAW_DIR            = LDrawDir=$${LDRAW_PATH}
        LDRAW_ZIP_FILE       = $$shell_path($$absolute_path($${3RD_PREFIX}/complete.zip))
        message("~~~ LDRAW PARTS LIBRARY $${LDRAW_PATH} ~~~")
        exists($${LDRAW_ZIP_FILE}) {
            LDRAW_ZIP        = LDrawZip=$${LDRAW_ZIP_FILE}
            message("~~~ LDRAW ZIP PARTS LIBRARY $${LDRAW_ZIP_FILE} ~~~")
        }

        contains(LDV_TEST_TYPE, Standard) {
            LDRAW_DIR_LN     = 12
            LDRAW_ZIP_LN     = 13
            LGEO_DIR_LN      = 64

            default_ini_message.target   = DefaultIniMessage
            default_ini_message.commands = @echo "Project MESSAGE: ~~~ Updating LDViewDefaultIni with entry $${LDRAW_DIR} at line $${LDRAW_DIR_LN} ~~~"
            default_ini.target           = LDViewDefaultIni
            default_ini.depends          = default_ini_message
            !macx: default_ini.commands  = @sed -i      \'$${LDRAW_DIR_LN}s%.*%$${LDRAW_DIR}%\' $${LDV_STANDARD_INI}
            else:  default_ini.commands  = @sed -i \'\' \'$${LDRAW_DIR_LN}s%.*%$${LDRAW_DIR}%\' $${LDV_STANDARD_INI}

            custom_ini_message.target    = CustomIniMessage
            custom_ini_message.commands  = @echo "Project MESSAGE: ~~~ Updating LDViewCustomIni with entry $${LDRAW_DIR} at line $${LDRAW_DIR_LN} ~~~"
            custom_ini.target            = LDViewCustomIni
            custom_ini.depends           = custom_ini_message
            !macx: custom_ini.commands   = @sed -i      \'$${LDRAW_DIR_LN}s%.*%$${LDRAW_DIR}%\' $${LDV_CUSTOM_INI}
            else:  custom_ini.commands   = @sed -i \'\' \'$${LDRAW_DIR_LN}s%.*%$${LDRAW_DIR}%\' $${LDV_CUSTOM_INI}

            exists($${LDRAW_ZIP_FILE}) {
                !macx: default_ini.commands  += ; sed -i      \'$${LDRAW_ZIP_LN}s%.*%$${LDRAW_ZIP}%\' $${LDV_STANDARD_INI}
                else:  default_ini.commands  += ; sed -i \'\' \'$${LDRAW_ZIP_LN}s%.*%$${LDRAW_ZIP}%\' $${LDV_STANDARD_INI}
                default_ini_message.commands += ; echo "Project MESSAGE: ~~~ Updating LDViewDefaultIni with entry $${LDRAW_ZIP} at line $${LDRAW_ZIP_LN} ~~~"

                !macx: custom_ini.commands   += ; sed -i      \'$${LDRAW_ZIP_LN}s%.*%$${LDRAW_ZIP}%\' $${LDV_CUSTOM_INI}
                else:  custom_ini.commands   += ; sed -i \'\' \'$${LDRAW_ZIP_LN}s%.*%$${LDRAW_ZIP}%\' $${LDV_CUSTOM_INI}
                custom_ini_message.commands  += ; echo "Project MESSAGE: ~~~ Updating LDViewCustomIni with entry $${LDRAW_ZIP} at line $${LDRAW_ZIP_LN} ~~~"
            }

            exists($${LDRAW_PATH}/lgeo/LGEO.xml) {
                LGEO_DIR = XmlMapPath=$${LDRAW_PATH}/lgeo
                message("~~~ LGEO LIBRARY $${LGEO_DIR} ~~~")
                !macx: custom_ini.commands   += ; sed -i      \'$${LGEO_DIR_LN}s%.*%$${LGEO_DIR}%\' $${LDV_CUSTOM_INI}
                else:  custom_ini.commands   += ; sed -i \'\' \'$${LGEO_DIR_LN}s%.*%$${LGEO_DIR}%\' $${LDV_CUSTOM_INI}
                custom_ini_message.commands  += ; echo "Project MESSAGE: ~~~ Updating LDViewCustomIni with entry $${LGEO_DIR} at line $${LGEO_DIR_LN} ~~~"
            } else {
                message("~~~ LGEO LIBRARY NOT FOUND ~~~")
                !macx: custom_ini.commands   += ; sed -i      \'$${LGEO_DIR_LN}s%.*%%\' $${LDV_CUSTOM_INI}
                else:  custom_ini.commands   += ; sed -i \'\' \'$${LGEO_DIR_LN}s%.*%%\' $${LDV_CUSTOM_INI}
                custom_ini_message.commands  += ; echo "Project MESSAGE: ~~~ Removing LDViewCustomIni entry XmlMapPath at line $${LGEO_DIR_LN} ~~~"
            }

            QMAKE_EXTRA_TARGETS += default_ini default_ini_message custom_ini custom_ini_message
            PRE_TARGETDEPS      += LDViewDefaultIni LDViewCustomIni

            # Test
            #./ldview ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=/home/trevor/projects/ldview/OSMesa/LDViewCustomIni -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0 -IgnoreEGL
            # Set CONFIG+=USE_SOFTPIPE to test LLVM softpipe driver
            contains(USE_SYSTEM_OSMESA_LIB, YES): CONFIG+=USE_SWRAST
        }   # Standard Test
    } else {
        isEmpty(LDRAW_PATH): \
        message("~~~ WARNING: LDRAW PATH NOT DEFINED - Test aborted ~~~")
        else: \
        message("~~~ WARNING: LDRAW PATH INVALID $${LDRAW_PATH} - Test aborted ~~~")
    }

    USE_SWRAST:   GAL_DRIVER = swrast
    USE_SOFTPIPE: GAL_DRIVER = softpipe
    else: macx:   GAL_DRIVER = llvmpipe
    else:         GAL_DRIVER = swr

    # For MSVC builds, ensure ${QTDIR}/bin is appended to PATH
    CUI_QT:!exists($${OUT_PWD}/$${DESTDIR}/Qt5Widgets.dll) {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @cd $${OUT_PWD}/$${DESTDIR} && windeployqt.exe --no-translations $${LDVIEW_EXE}
    }

    exists($${LDV_DEFAULT_INI}) {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @echo "Project MESSAGE: ~~~ Found user IniFile: $${LDV_DEFAULT_INI} ~~~"
    } else: exists($${LDV_INI_CFG_RC}) {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @echo "Project MESSAGE: ~~~ Found user CfgIniFile: $${LDV_DEFAULT_INI} ~~~"
        LDV_DEFAULT_INI  = $${LDV_INI_CFG_RC}
    } else {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @$${LDV_COPY_CMD} $${LDV_STANDARD_INI} $${LDV_DEFAULT_INI}                                   \
                           $$escape_expand(\n\t)                                                                             \
                                @echo "Project MESSAGE: ~~~ Created temporary user IniFile at $${LDV_DEFAULT_INI} ~~~"
        LDV_REMOVE_INI   = YES
    }

    contains(LDV_TEST_TYPE, Standard) {
        # Linux  ./ldview ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=/home/trevor/projects/ldview/OSMesa/LDViewCustomIni -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0 -IgnoreEGL
        # MacOS  ./ldview ../8464.mpd -SaveSnapshot=/tmp/8464i.png -IniFile=/Users/trevorsandy/Projects/ldview/OSMesa/LDViewCustomIni -Info=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0 -IgnoreEGL
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @echo "Project MESSAGE: ~~~ Using custom IniFile: $${LDV_CUSTOM_INI} ~~~"                    \
                           $$escape_expand(\n\t)                                                                             \
                                @export GALLIUM_DRIVER=$$GAL_DRIVER                                                          \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_IMAGE_DEL_CMD}                                                                       \
                           $$escape_expand(\n\t)                                                                             \
                                @cd $${OUT_PWD}/$${DESTDIR} && $${LDVIEW_EXE} $${LDV_MPD_FILE}                               \
                                -SaveSnapshot=$${LDV_IMAGE_FILE} -IniFile=$${LDV_CUSTOM_INI} -Info=1                         \
                                -SaveWidth=1024 -SaveHeight=1024 -ShowErrors=0 -SaveActualSize=0 -IgnoreEGL                  \
                                -LDConfig=$${LDRAW_PATH}/LDCfgalt.ldr                                                        \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_IMAGE_INFO_CMD}                                                                      \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_ECHO_NL} "Project MESSAGE: ~~~ Command line custom IniFile test completed. ~~~"

        #./ldview ../8464.mpd -SaveSnapshot=/tmp/8464.png -Arguments=1 -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0 -IgnoreEGL
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @echo "Project MESSAGE: ~~~ Using default IniFile: $${LDV_DEFAULT_INI} ~~~"
        macx:                                                                                                                \
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @if [ -f $${LDV_DEFAULT_INI} ] &&                                                            \
                                    [ -d "`grep ^LDrawDir $${LDV_DEFAULT_INI} | cut -f2 -d=`" ] ; then                       \
                                    echo "Project MESSAGE: ~~~ Using IniFile LDraw directory:                                \
                                            `grep ^LDrawDir $${LDV_DEFAULT_INI} | cut -f2 -d =` ~~~" ;                       \
                                elif [ -f $${LDV_INI_CFG_RC} ] &&                                                            \
                                     [ -d "`grep ^LDrawDir $${LDV_INI_CFG_RC} | cut -f2 -d=`" ] ; then                       \
                                    echo "Project MESSAGE: ~~~ Using CfgIniFile LDraw directory:                             \
                                            `grep ^LDrawDir $${LDV_INI_CFG_RC} | cut -f2 -d =` ~~~" ;                        \
                                else                                                                                         \
                                    echo "Project MESSAGE: ~~~ Using LDraw directory: $${LDRAW_PATH} ~~~" ;                  \
                                    sed -i \'\' \'2s%.*%$${LDRAW_DIR}%\' $${LDV_DEFAULT_INI} ;                               \
                                fi
        else:                                                                                                                \
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @if [ -f $${LDV_DEFAULT_INI} ] &&                                                            \
                                   [ -d "`grep ^LDrawDir $${LDV_DEFAULT_INI} | cut -f2 -d=`" ] ; then                        \
                                    echo "Project MESSAGE: ~~~ Using IniFile LDraw directory:                                \
                                            `grep ^LDrawDir $${LDV_DEFAULT_INI} | cut -f2 -d =` ~~~" ;                       \
                                elif [ -f $${LDV_INI_CFG_RC} ] &&                                                            \
                                     [ -d "`grep ^LDrawDir $${LDV_INI_CFG_RC} | cut -f2 -d=`" ] ; then                       \
                                    echo "Project MESSAGE: ~~~ Using CfgIniFile LDraw directory:                             \
                                            `grep ^LDrawDir $${LDV_INI_CFG_RC} | cut -f2 -d =` ~~~" ;                        \
                                else                                                                                         \
                                    echo "Project MESSAGE: ~~~ Using LDraw directory: $${LDRAW_PATH} ~~~" ;                  \
                                    sed -i \'2s%.*%$${LDRAW_DIR}%\' $${LDV_DEFAULT_INI} ;                                    \
                                fi
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @export GALLIUM_DRIVER=$$GAL_DRIVER                                                          \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_IMAGE_DEL_CMD}                                                                       \
                           $$escape_expand(\n\t)                                                                             \
                                @cd $${OUT_PWD}/$${DESTDIR} && $${LDVIEW_EXE} $${LDV_MPD_FILE}                               \
                                -SaveSnapshot=$${LDV_IMAGE_FILE} -IniFile=$${LDV_DEFAULT_INI} -Arguments=1                   \
                                -SaveWidth=1024 -SaveHeight=1024 -ShowErrors=0 -SaveActualSize=0 -IgnoreEGL                  \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_IMAGE_INFO_CMD}                                                                      \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_ECHO_NL} "Project MESSAGE: ~~~ Command line default IniFile test completed. ~~~"
    } else: contains(LDV_TEST_TYPE, Basic) {
        # For Basic check, the LDraw Path is not added to the IniFile so we must add it to the command
        LDV_IMAGE_CMD    = -$${LDRAW_DIR}
        !isEmpty(LDRAW_ZIP):                                                                                                 \
        LDV_IMAGE_CMD   += -$${LDRAW_ZIP}
        LDV_IMAGE_CMD   += -SaveSnapshot=$${LDV_IMAGE_FILE} -SaveWidth=1024 -SaveHeight=1024                                 \
                           -ShowErrors=0 -SaveActualSize=0 -IgnoreEGL -Info=1
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @$${LDV_IMAGE_DEL_CMD}                                                                       \
                           $$escape_expand(\n\t)                                                                             \
                                @cd $${OUT_PWD}/$${DESTDIR} && $${LDVIEW_EXE} $${LDV_MPD_FILE} $${LDV_IMAGE_CMD}             \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_IMAGE_INFO_CMD}
    } else {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @echo "Project MESSAGE: ~~~ Display $${TARGET} Info ~~~"                                     \
                           $$escape_expand(\n\t)                                                                             \
                                @cd $${OUT_PWD}/$${DESTDIR} && $${LDVIEW_EXE} -IgnoreEGL -Info=1                             \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_ECHO_LL}
    }

    contains(LDV_REMOVE_INI, YES) {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @$${LDV_DEL_CMD} $${LDV_DEFAULT_INI}                                                         \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_ECHO_NL} "Project MESSAGE: ~~~ Removed temporary user IniFile $${LDV_DEFAULT_INI} ~~~"
    }

    if (contains(LDV_TEST_TYPE, Basic)|contains(LDV_TEST_TYPE, Standard)) {
        QMAKE_POST_LINK += $$escape_expand(\n\t)                                                                             \
                                @$${LDV_ECHO_NL} "Project MESSAGE: ~~~ $${LDV_TEST_TYPE} build test completed. ~~~"          \
                           $$escape_expand(\n\t)                                                                             \
                                @$${LDV_ECHO_LL}
    }
}

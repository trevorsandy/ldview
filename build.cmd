@ECHO OFF &SETLOCAL

Title LDView Windows auto build script

rem This script uses MSBuild to configure and build LDView for Windows.
rem The primary purpose is to automatically build both the 32bit and 64bit
rem LDView distributions and package the build contents (exe, doc and
rem resources ) as LPub3D 3rd Party components.
rem --
rem  Trevor SANDY <trevor.sandy@gmail.com>
rem  Last Update: July 01, 2021
rem  Copyright (c) 2020 - 2021 by Trevor SANDY
rem --
rem This script is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

CALL :ELAPSED_BUILD_TIME Start

SET PWD=%CD%

rem Variables
rem Static defaults
IF "%GITHUB%" EQU "True" (
  IF [%LP3D_DIST_DIR_PATH%] == [] (
    ECHO.
    ECHO  -ERROR: Distribution directory path not defined.
    ECHO  -%~nx0 terminated!
    GOTO :ERROR_END
  )
  IF "%GITHUB_RUNNER_IMAGE%" == "Visual Studio 2019" (
    SET LP3D_VSVERSION=2019
  )
  SET DIST_DIR=%LP3D_DIST_DIR_PATH%
  SET LDRAW_DOWNLOAD_DIR=%LP3D_3RD_PARTY_PATH%
  SET LDRAW_DIR=%LP3D_LDRAW_DIR_PATH%
)

IF "%APPVEYOR%" EQU "True" (
  IF [%LP3D_DIST_DIR_PATH%] == [] (
    ECHO.
    ECHO  -ERROR: Distribution directory path not defined.
    ECHO  -%~nx0 terminated!
    GOTO :ERROR_END
  )
  IF "%APPVEYOR_BUILD_WORKER_IMAGE%" == "Visual Studio 2019" (
    SET LP3D_VSVERSION=2019
  )
  SET DIST_DIR=%LP3D_DIST_DIR_PATH%
  SET LDRAW_DOWNLOAD_DIR=%APPVEYOR_BUILD_FOLDER%
  SET LDRAW_DIR=%APPVEYOR_BUILD_FOLDER%\LDraw
)

IF "%GITHUB%" NEQ "True" (
  IF "%APPVEYOR%" NEQ "True" (
    SET LP3D_VSVERSION=2019
    SET LDRAW_DOWNLOAD_DIR=%USERPROFILE%
    SET LDRAW_DIR=%USERPROFILE%\LDraw
    SET DIST_DIR=..\lpub3d_windows_3rdparty
  )
)

IF EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build" (
  SET LP3D_VCVARSALL=C:\Program Files ^(x86^)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build
)
IF EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build" (
  SET LP3D_VCVARSALL=C:\Program Files ^(x86^)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build
)
IF EXIST "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build" (
  SET LP3D_VCVARSALL=C:\Program Files ^(x86^)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build
)
IF "%LP3D_VCVARSALL%" == "" (
  ECHO.
  ECHO  -ERROR: Microsoft Visual Studio C++ environment not defined.
  ECHO  -%~nx0 terminated!
  GOTO :ERROR_END
)

rem Visual C++ 2012 -vcvars_ver=11.0
rem Visual C++ 2013 -vcvars_ver=12.0
rem Visual C++ 2015 -vcvars_ver=14.0
rem Visual C++ 2017 -vcvars_ver=14.1
rem Visual C++ 2019 -vcvars_ver=14.2
SET LP3D_VCVARSALL_VER=-vcvars_ver=14.0
SET LP3D_VCVERSION=8.1
SET LP3D_VCTOOLSET=v140

SET INI_POV_FILE=%PWD%\OSMesa\ldviewPOV.ini
SET zipWin64=C:\program files\7-zip
SET OfficialCONTENT=complete.zip

SET PACKAGE=LDView
SET VERSION=4.4
SET PROJECT=LDView.vcxproj
SET CONFIGURATION=Release

SET MINIMUM_LOGGING=unknown
SET THIRD_INSTALL=unknown
SET INSTALL_32BIT=unknown
SET INSTALL_64BIT=unknown
SET PLATFORM=unknown
SET INI_FILE=unknown
SET CHECK=unknown

ECHO.
ECHO -Start %PACKAGE% %~nx0 with commandline args: [%*].

rem Verify 1st input flag options
IF NOT [%1]==[] (
  IF NOT "%1"=="x86" (
    IF NOT "%1"=="x86_64" (
      IF NOT "%1"=="-all" (
        IF NOT "%1"=="-help" GOTO :PLATFORM_ERROR
      )
    )
  )
)

rem Parse platform input flag
IF [%1]==[] (
  SET PLATFORM=-all
  GOTO :SET_CONFIGURATION
)
IF /I "%1"=="x86" (
  SET PLATFORM=Win32
  GOTO :SET_CONFIGURATION
)
IF /I "%1"=="x86_64" (
  SET PLATFORM=x64
  GOTO :SET_CONFIGURATION
)
IF /I "%1"=="-all" (
  SET PLATFORM=-all
  GOTO :SET_CONFIGURATION
)
IF /I "%1"=="-help" (
  GOTO :USAGE
)
rem If we get here display invalid command message.
GOTO :COMMAND_ERROR

:SET_CONFIGURATION
rem Verify 2nd input flag options
IF NOT [%2]==[] (
  IF NOT "%2"=="-ins" (
    IF NOT "%2"=="-chk" GOTO :CONFIGURATION_ERROR
  )
)

rem Verify 3rd input flag options
IF NOT [%3]==[] (
  IF NOT "%3"=="-chk" (
    IF NOT "%3"=="-minlog" GOTO :CONFIGURATION_ERROR
  )
)

rem Verify 4th input flag options
IF NOT [%4]==[] (
  IF NOT "%4"=="-minlog" GOTO :CONFIGURATION_ERROR
)

rem Set third party install as default behaviour
IF [%2]==[] (
  SET THIRD_INSTALL=1
  GOTO :BUILD
)

IF /I "%2"=="-ins" (
  SET THIRD_INSTALL=1
  GOTO :BUILD
)

rem Set build check flag
IF /I "%2"=="-chk" (
  SET CHECK=1
  GOTO :BUILD
)

:BUILD
rem Display build settings
IF "%GITHUB%" EQU "True" (
  ECHO   BUILD_HOST.............[GITHUB CONTINUOUS INTEGRATION SERVICE]
  ECHO   BUILD_WORKER_IMAGE.....[%GITHUB_RUNNER_IMAGE%]
  ECHO   BUILD_JOB..............[%GITHUB_JOB%]
  ECHO   GITHUB_REF.............[%GITHUB_REF%]
  ECHO   GITHUB_RUNNER_OS.......[%RUNNER_OS%]
  ECHO   PROJECT REPOSITORY.....[%GITHUB_REPOSITORY%]
  ECHO   DIST_DIRECTORY.........[%DIST_DIR%]
)
IF "%APPVEYOR%" EQU "True" (
  ECHO   BUILD_HOST.............[APPVEYOR CONTINUOUS INTEGRATION SERVICE]
  ECHO   BUILD_WORKER_IMAGE.....[%APPVEYOR_BUILD_WORKER_IMAGE%]
  ECHO   BUILD_ID...............[%APPVEYOR_BUILD_ID%]
  ECHO   BUILD_BRANCH...........[%APPVEYOR_REPO_BRANCH%]
  ECHO   PROJECT_NAME...........[%APPVEYOR_PROJECT_NAME%]
  ECHO   REPOSITORY_NAME........[%APPVEYOR_REPO_NAME%]
  ECHO   REPO_PROVIDER..........[%APPVEYOR_REPO_PROVIDER%]
  ECHO   DIST_DIRECTORY.........[%DIST_DIR%]
)
ECHO   PACKAGE................[%PACKAGE%]
ECHO   VERSION................[%VERSION%]
ECHO   MSVC_VERSION...........[%LP3D_VCVERSION%]
ECHO   MSVC_TOOLSET...........[%LP3D_VCTOOLSET%]
ECHO   WORKING_DIR............[%CD%]
ECHO   LDRAW_DIR..............[%LDRAW_DIR%]
ECHO.  LDRAW_DOWNLOAD_DIR.....[%LDRAW_DOWNLOAD_DIR%]

rem Perform build check
IF /I "%3"=="-chk" (
  SET CHECK=1
)

rem Console output - see https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference
rem Set console output logging level - (normal:all output or minlog=only error output)
IF /I "%3"=="-minlog" (
  SET MINIMUM_LOGGING=1
)
IF /I "%4"=="-minlog" (
  SET MINIMUM_LOGGING=1
)
IF /I %MINIMUM_LOGGING%==1 (
  SET LOGGING_FLAGS=/clp:ErrorsOnly /nologo
)

rem Console output logging level message
CALL :OUTPUT_LOGGING_MESSAGE %MINIMUM_LOGGING%

rem Backup ini files
CALL :BACKUP_INI_FILES

rem If check specified, update inifile with ldraw directory path
CALL :UPDATE_INI_POV_FILE

rem Check if build all platforms
IF /I "%PLATFORM%"=="-all" (
  GOTO :BUILD_ALL
)

rem Check if build Win32 and vs2019, set to vs2017 for WinXP compat
IF "%LP3D_VSVERSION%"=="2019" (
  CALL :CONFIGURE_VCTOOLS %PLATFORM%
)

rem Initialize the Visual Studio command line development environment
CALL :CONFIGURE_BUILD_ENV

rem Display platform setting
ECHO.
ECHO -Building %PLATFORM% Platform...
ECHO.
rem Assemble command line
SET COMMAND_LINE=msbuild /m /p:Configuration=%CONFIGURATION% /p:Platform=%PLATFORM% /p:WindowsTargetPlatformVersion=%LP3D_VCVERSION% /p:PlatformToolset=%LP3D_VCTOOLSET% %PROJECT% %LOGGING_FLAGS%
ECHO -Command: %COMMAND_LINE%
rem Launch msbuild
%COMMAND_LINE%
rem Perform build check if specified
IF %CHECK%==1 CALL :CHECK_BUILD %PLATFORM%
rem Package 3rd party install content
IF %THIRD_INSTALL%==1 (
  IF %PLATFORM%==Win32 SET INSTALL_32BIT=1
  IF %PLATFORM%==x64 SET INSTALL_64BIT=1
  CALL :3RD_PARTY_INSTALL
)
rem Restore ini file
CALL :RESTORE_INI_FILES
GOTO :END

:BUILD_ALL
rem Launch msbuild across all platform builds
ECHO.
ECHO -Build x86 and x86_64 platforms...
FOR %%P IN ( Win32, x64 ) DO (
  ECHO.
  ECHO -Building %%P Platform...
  ECHO.
  rem Initialize the Visual Studio command line development environment
  SET PLATFORM=%%P
  IF "%LP3D_VSVERSION%"=="2019" (
    CALL :CONFIGURE_VCTOOLS %%P
  )
  CALL :CONFIGURE_BUILD_ENV
  rem Assemble command line parameters
  SET COMMAND_LINE=msbuild /m /p:Configuration=%CONFIGURATION% /p:Platform=%%P /p:WindowsTargetPlatformVersion=%LP3D_VCVERSION% /p:PlatformToolset=%LP3D_VCTOOLSET% %PROJECT% %LOGGING_FLAGS%
  SETLOCAL ENABLEDELAYEDEXPANSION
  ECHO -Build Command: !COMMAND_LINE!
  rem Launch msbuild
  !COMMAND_LINE!
  IF %%P == x64 (
    SET EXE=Build\%CONFIGURATION%64\%PACKAGE%64.exe
  ) ELSE (
    SET EXE=Build\%CONFIGURATION%\%PACKAGE%.exe
  )
  IF NOT EXIST "!EXE!" (
    ECHO.
    ECHO "-ERROR - !EXE! was not successfully built - build will trminate."
    GOTO :ERROR_END
  )
  ENDLOCAL
  rem Perform build check if specified
  IF %CHECK%==1 CALL :CHECK_BUILD %%P
)
rem Restore ini file
CALL :RESTORE_INI_FILES
rem Package 3rd party install
IF %THIRD_INSTALL%==1 (
  SET INSTALL_32BIT=1
  SET INSTALL_64BIT=1
  CALL :3RD_PARTY_INSTALL
)
GOTO :END

:CONFIGURE_VCTOOLS
IF %1==x64 (
  SET LP3D_VCVARSALL_VER=-vcvars_ver=14.2
  SET LP3D_VCVERSION=10.0
  SET LP3D_VCTOOLSET=v142
)
ECHO.
ECHO -Set %1 MSBuild platform toolset to %LP3D_VCTOOLSET%
EXIT /b

:CONFIGURE_BUILD_ENV
ECHO.
ECHO -Configure %PACKAGE% %PLATFORM% build environment...
rem Set vcvars for AppVeyor or local build environments
IF "%PATH_PREPENDED%" NEQ "True" (
  IF %PLATFORM% EQU Win32 (
    ECHO.
    IF EXIST "%LP3D_VCVARSALL%\vcvars32.bat" (
      CALL "%LP3D_VCVARSALL%\vcvars32.bat" %LP3D_VCVARSALL_VER%
    ) ELSE (
      ECHO -ERROR: vcvars32.bat not found.
      ECHO -%~nx0 terminated!
      GOTO :ERROR_END
    )
  ) ELSE (
    ECHO.
    IF EXIST "%LP3D_VCVARSALL%\vcvars64.bat" (
      CALL "%LP3D_VCVARSALL%\vcvars64.bat" %LP3D_VCVARSALL_VER%
    ) ELSE (
      ECHO -ERROR: vcvars64.bat not found.
      ECHO -%~nx0 terminated!
      GOTO :ERROR_END
    )
  )
  rem Display MSVC Compiler settings
  echo _MSC_VER > %TEMP%\settings.c
  cl -Bv -EP %TEMP%/settings.c > NUL
  ECHO.
) ELSE (
  ECHO.
  ECHO -%PLATFORM% build environment already configured...
)
EXIT /b

:UPDATE_INI_POV_FILE
IF EXIST "%LDRAW_DIR%\lgeo" (
SET /a LineToReplace=51
SET "Replacement=XmlMapPath=%LDRAW_DIR%\lgeo"
ECHO.
SETLOCAL ENABLEDELAYEDEXPANSION
ECHO -Update %INI_POV_FILE% at line !LineToReplace! with !Replacement!
ENDLOCAL
(FOR /f "tokens=1*delims=:" %%a IN ('findstr /n "^" "%INI_POV_FILE%"') DO (
  SET "Line=%%b"
  IF %%a EQU %LineToReplace% SET "Line=%Replacement%"
  SETLOCAL ENABLEDELAYEDEXPANSION
  ECHO(!Line!
  ENDLOCAL
))>"%INI_POV_FILE%.new"
MOVE /Y "%INI_POV_FILE%.new" "%INI_POV_FILE%" >nul 2>&1
) ELSE (
  ECHO.
  ECHO -LGEO directory %LDRAW_DIR%\lgeo does not exist - LGEO Update ignored.
)
EXIT /b

:CHECK_BUILD
ECHO.
ECHO -Perform build check for %CONFIGURATION% Configuration, %1 Platform using Ini file %INI_POV_FILE%......
CALL :CHECK_LDRAW_DIR
IF %1==Win32 SET PL=
IF %1==x64 SET PL=64
SET INI_FILE=%INI_POV_FILE%
SET IN_FILE=8464.mpd
SET OUT_FILE=8464.TestResult.%1.png
SET ALT_LDCONFIG_FILE=%LDRAW_DIR%\LDCfgalt.ldr
SET ARGS=-SaveWidth=1024 -SaveHeight=1024 -SaveActualSize=0 -HaveStdOut=1 -v
SET PACKAGE_PATH=Build\%CONFIGURATION%%PL%\%PACKAGE%%PL%.exe
SET COMMAND_LINE_ARGS= "%IN_FILE%" -LDrawDir="%LDRAW_DIR%" -SaveSnapshot="%OUT_FILE%" -IniFile="%INI_FILE%" %ARGS% -LDConfig="%ALT_LDCONFIG_FILE%"
SET COMMAND=%PACKAGE_PATH% %COMMAND_LINE_ARGS%
IF %CHECK%==1 (
  ECHO.
  ECHO   PACKAGE................[%PACKAGE%]
  ECHO   PACKAGE_PATH...........[%PACKAGE_PATH%]
  ECHO   ARGUMENTS..............[%ARGS%]
  ECHO   INI_FILE...............[%INI_FILE%]
  ECHO   OUT_FILE...............[%OUT_FILE%]
  ECHO   IN_FILE................[%IN_FILE%]
  ECHO   LDRAW_DIRECTORY........[%LDRAW_DIR%]
  ECHO   COMMAND................[%COMMAND%]
  IF EXIST "%OUT_FILE%" (
    DEL /Q "%OUT_FILE%"
  )
  %COMMAND% > Check.out 2>&1
  IF EXIST "Check.out" (
    FOR %%R IN (Check.out) DO IF NOT %%~zR lss 1 ECHO. & TYPE "Check.out"
    DEL /Q "Check.out"
  )
  IF EXIST "%OUT_FILE%" (
    ECHO.
    ECHO -Build Check, create %OUT_FILE% from %IN_FILE% - Test successful!
  )
) ELSE (
  ECHO -Check is not possible
)
EXIT /b

:3RD_PARTY_INSTALL
ECHO.
ECHO -Installing distribution files...
SET COPY_CMD=COPY /V /Y
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\bin\i386
IF %INSTALL_32BIT% == 1 (
  ECHO.
  ECHO -Installing %PACKAGE% 32bit exe to [%DIST_INSTALL_PATH%]...
  IF NOT EXIST "%DIST_INSTALL_PATH%\" (
    MKDIR "%DIST_INSTALL_PATH%\"
  )
  %COPY_CMD% "Build\Release\%PACKAGE%.exe*" "%DIST_INSTALL_PATH%\" /B
  ECHO.
  ECHO -Installing %PACKAGE% 32bit libraries to [%DIST_INSTALL_PATH%]...
  %COPY_CMD% "LDLib\Build\Release\LDLib.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "LDExporter\Build\Release\LDExporter.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "LDLoader\Build\Release\LDLoader.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "TRE\Build\Release\TRE.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "TCFoundation\Build\Release\TCFoundation.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "3rdParty\gl2ps\Build\Release\gl2ps.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "3rdParty\tinyxml\Build\Release\tinyxml_STL.lib*" "%DIST_INSTALL_PATH%\" /B
  IF "%LP3D_VSVERSION%"=="2019" (
    %COPY_CMD% "lib\*-vs2017.lib" "%DIST_INSTALL_PATH%\" /B
  ) ELSE (
    %COPY_CMD% "lib\*-vs2015.lib" "%DIST_INSTALL_PATH%\" /B
  )
  IF EXIST "Build\Debug\LDView.exe" (
    ECHO.
    ECHO -Installing %PACKAGE% 32bit Debug libraries to [%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug]...
    IF NOT EXIST "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug\" (
      MKDIR "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug\"
    )
    %COPY_CMD% "Build\Debug\*.lib" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug\" /B
    %COPY_CMD% "Build\Debug\*.bsc" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug\" /B
    %COPY_CMD% "Build\Debug\*.pdb" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug\" /B
    IF "%LP3D_VSVERSION%"=="2019" (
      %COPY_CMD% "lib\*-vs2017.lib" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug\" /B
    ) ELSE (
      %COPY_CMD% "lib\*-vs2015.lib" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug\" /B
    )
  )
)
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\bin\x86_64
IF %INSTALL_64BIT% == 1 (
  ECHO.
  ECHO -Installing %PACKAGE% 64bit exe to [%DIST_INSTALL_PATH%]...
  IF NOT EXIST "%DIST_INSTALL_PATH%\" (
    MKDIR "%DIST_INSTALL_PATH%\"
  )
  %COPY_CMD% "Build\Release64\%PACKAGE%64.exe*" "%DIST_INSTALL_PATH%\" /B
  ECHO.
  ECHO -Installing %PACKAGE% 64bit libraries to [%DIST_INSTALL_PATH%]...
  %COPY_CMD% "LDLib\Build\Release64\LDLib.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "LDExporter\Build\Release64\LDExporter.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "LDLoader\Build\Release64\LDLoader.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "TRE\Build\Release64\TRE.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "TCFoundation\Build\Release64\TCFoundation.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "3rdParty\gl2ps\Build\Release64\gl2ps.lib*" "%DIST_INSTALL_PATH%\" /B
  %COPY_CMD% "3rdParty\tinyxml\Build\Release64\tinyxml_STL.lib*" "%DIST_INSTALL_PATH%\" /B
  IF "%LP3D_VSVERSION%"=="2019" (
    %COPY_CMD% "lib\x64\*-vs2019.lib" "%DIST_INSTALL_PATH%\" /B
  ) ELSE (
    %COPY_CMD% "lib\x64\*-vs2015.lib" "%DIST_INSTALL_PATH%\" /B
  )
  IF EXIST "Build\Debug64\LDView64.exe" (
    ECHO.
    ECHO -Installing %PACKAGE% 64bit Debug libraries to [%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug64]...
    IF NOT EXIST "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug64\" (
      MKDIR "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug64\"
    )
    %COPY_CMD% "Build\Debug64\*.lib" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug64\" /B
    %COPY_CMD% "Build\Debug64\*.bsc" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug64\" /B
    %COPY_CMD% "Build\Debug64\*.pdb" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug64\" /B
    IF "%LP3D_VSVERSION%"=="2019" (
      %COPY_CMD% "lib\x64\*-vs2019.lib" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug64\" /B
    ) ELSE (
      %COPY_CMD% "lib\x64\*-vs2015.lib" "%DIST_DIR%\%PACKAGE%-%VERSION%\Build\Debug64\" /B
    )
  )
)
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\include
ECHO.
ECHO -Installing %PACKAGE% Headers to [%DIST_INSTALL_PATH%]...
IF NOT EXIST "%DIST_INSTALL_PATH%\LDExporter\" (
  MKDIR "%DIST_INSTALL_PATH%\LDExporter\"
)
IF NOT EXIST "%DIST_INSTALL_PATH%\LDLib\" (
  MKDIR "%DIST_INSTALL_PATH%\LDLib\"
)
IF NOT EXIST "%DIST_INSTALL_PATH%\LDLoader\" (
  MKDIR "%DIST_INSTALL_PATH%\LDLoader\"
)
IF NOT EXIST "%DIST_INSTALL_PATH%\TRE\" (
  MKDIR "%DIST_INSTALL_PATH%\TRE"
)
IF NOT EXIST "%DIST_INSTALL_PATH%\TCFoundation\" (
  MKDIR "%DIST_INSTALL_PATH%\TCFoundation\"
)
IF NOT EXIST "%DIST_INSTALL_PATH%\3rdParty\" (
  MKDIR "%DIST_INSTALL_PATH%\3rdParty\"
)
IF NOT EXIST "%DIST_INSTALL_PATH%\GL\" (
  MKDIR "%DIST_INSTALL_PATH%\GL\"
)
%COPY_CMD% "LDLib\*.h" "%DIST_INSTALL_PATH%\LDLib\" /A
%COPY_CMD% "LDExporter\*.h" "%DIST_INSTALL_PATH%\LDExporter\" /A
%COPY_CMD% "LDLoader\*.h" "%DIST_INSTALL_PATH%\LDLoader\" /A
%COPY_CMD% "TRE\*.h" "%DIST_INSTALL_PATH%\TRE\" /A
%COPY_CMD% "TCFoundation\*.h" "%DIST_INSTALL_PATH%\TCFoundation\" /A
%COPY_CMD% "include\*.h" "%DIST_INSTALL_PATH%\3rdParty\" /A
%COPY_CMD% "include\GL\*.h" "%DIST_INSTALL_PATH%\GL\" /A
ECHO.
ECHO -Installing %PACKAGE% Documentaton to [%DIST_DIR%\%PACKAGE%-%VERSION%\docs]...
IF NOT EXIST "%DIST_DIR%\%PACKAGE%-%VERSION%\docs\" (
  MKDIR "%DIST_DIR%\%PACKAGE%-%VERSION%\docs\"
)
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\docs\
%COPY_CMD% "Readme.txt*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "Help.html*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "license.txt*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "ChangeHistory.html*" "%DIST_INSTALL_PATH%" /A
IF NOT EXIST "%DIST_DIR%\%PACKAGE%-%VERSION%\resources\config\" (
  MKDIR "%DIST_DIR%\%PACKAGE%-%VERSION%\resources\config\"
)
ECHO.
ECHO -Installing %PACKAGE% Ini Files to [%DIST_DIR%\%PACKAGE%-%VERSION%\resources\config]...
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\resources\config\
%COPY_CMD% "OSMesa\LDViewCustomIni*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "OSMesa\ldview.ini*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "OSMesa\ldviewPOV.ini*" "%DIST_INSTALL_PATH%" /A
ECHO.
ECHO -Installing %PACKAGE% Resource Files to [%DIST_DIR%\%PACKAGE%-%VERSION%\resources]...
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\resources\
%COPY_CMD% "m6459.ldr*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "8464.mpd*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "LDViewMessages.ini*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "LDExporter\LGEO.xml*" "%DIST_INSTALL_PATH%" /A
%COPY_CMD% "LDExporter\LDExportMessages.ini*" "%DIST_INSTALL_PATH%" /A
EXIT /b

:BACKUP_INI_FILES
ECHO.
ECHO -Backing up ini files before build check...
SET INI_FILE=%PWD%\OSMesa\ldviewPOV.ini
COPY /V /Y "%INI_FILE%" "%INI_FILE%.hold" /A
SET INI_FILE=%PWD%\OSMesa\ldview.ini
COPY /V /Y "%INI_FILE%" "%INI_FILE%.hold" /A
EXIT /b

:RESTORE_INI_FILES
ECHO.
ECHO -Restoring ini files after build check...
SET INI_FILE=%PWD%\OSMesa\ldviewPOV.ini
MOVE /Y "%INI_FILE%.hold" "%INI_FILE%" >nul 2>&1
SET INI_FILE=%PWD%\OSMesa\ldview.ini
MOVE /Y "%INI_FILE%.hold" "%INI_FILE%" >nul 2>&1
EXIT /b

:CHECK_LDRAW_DIR
ECHO.
ECHO -%PACKAGE% - Check for LDraw library...
IF NOT EXIST "%LDRAW_DIR%\parts" (
  REM SET CHECK=0
  IF NOT EXIST "%LDRAW_DOWNLOAD_DIR%\%OfficialCONTENT%" (
    ECHO.
    ECHO -LDraw directory %LDRAW_DIR% does not exist - Downloading...

    CALL :DOWNLOAD_LDRAW_LIBS
  )
  IF EXIST "%LDRAW_DOWNLOAD_DIR%\%OfficialCONTENT%" (
    IF EXIST "%zipWin64%" (
      ECHO.
      ECHO -7zip exectutable found at "%zipWin64%"
      ECHO.
      ECHO -Extracting %OfficialCONTENT%...
      ECHO.
      "%zipWin64%\7z.exe" x -o"%LDRAW_DOWNLOAD_DIR%\" "%LDRAW_DOWNLOAD_DIR%\%OfficialCONTENT%" | findstr /i /r /c:"^Extracting\>" /c:"^Everything\>"
      IF EXIST "%LDRAW_DIR%\parts" (
        ECHO.
        ECHO -LDraw directory %LDRAW_DIR% extracted.
        ECHO.
        ECHO -Cleanup %OfficialCONTENT%...
        DEL /Q "%LDRAW_DOWNLOAD_DIR%\%OfficialCONTENT%"
      )
    ) ELSE (
      ECHO [WARNING] Could not find 7zip executable.
      SET CHECK=0
    )
  ) ELSE (
    ECHO.
    ECHO -[WARNING] Could not find %LDRAW_DOWNLOAD_DIR%\%OfficialCONTENT%.
    SET CHECK=0
  )
) ELSE (
  ECHO.
  ECHO -LDraw directory exist at %LDRAW_DIR%.
)
EXIT /b

:DOWNLOAD_LDRAW_LIBS
ECHO.
ECHO - Download LDraw archive libraries...

SET OutputPATH=%LDRAW_DOWNLOAD_DIR%

ECHO.
ECHO - Prepare BATCH to VBS to Web Content Downloader...

IF NOT EXIST "%TEMP%\$" (
  MD "%TEMP%\$"
)

SET vbs=WebContentDownload.vbs
SET t=%TEMP%\$\%vbs% ECHO

IF EXIST %TEMP%\$\%vbs% (
 DEL %TEMP%\$\%vbs%
)

:WEB CONTENT SAVE-AS Download-- VBS
>%t% Option Explicit
>>%t% On Error Resume Next
>>%t%.
>>%t% Dim args, http, fileSystem, adoStream, url, target, status
>>%t%.
>>%t% Set args = Wscript.Arguments
>>%t% Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
>>%t% url = args(0)
>>%t% target = args(1)
>>%t% WScript.Echo "- Getting '" ^& target ^& "' from '" ^& url ^& "'...", vbLF
>>%t%.
>>%t% http.Open "GET", url, False
>>%t% http.Send
>>%t% status = http.Status
>>%t%.
>>%t% If status ^<^> 200 Then
>>%t% WScript.Echo "- FAILED to download: HTTP Status " ^& status, vbLF
>>%t% WScript.Quit 1
>>%t% End If
>>%t%.
>>%t% Set adoStream = CreateObject("ADODB.Stream")
>>%t% adoStream.Open
>>%t% adoStream.Type = 1
>>%t% adoStream.Write http.ResponseBody
>>%t% adoStream.Position = 0
>>%t%.
>>%t% Set fileSystem = CreateObject("Scripting.FileSystemObject")
>>%t% If fileSystem.FileExists(target) Then fileSystem.DeleteFile target
>>%t% If Err.Number ^<^> 0 Then
>>%t%   WScript.Echo "- Error - CANNOT DELETE: '" ^& target ^& "', " ^& Err.Description
>>%t%   WScript.Echo "  The file may be in use by another process.", vbLF
>>%t%   adoStream.Close
>>%t%   Err.Clear
>>%t% Else
>>%t%  adoStream.SaveToFile target
>>%t%  adoStream.Close
>>%t%  WScript.Echo "- Download successful!"
>>%t% End If
>>%t%.
>>%t% 'WebContentDownload.vbs
>>%t% 'Title: BATCH to VBS to Web Content Downloader
>>%t% 'CMD ^> cscript //Nologo %TEMP%\$\%vbs% WebNAME WebCONTENT
>>%t% 'VBS Created on %date% at %time%
>>%t%.

ECHO.
ECHO - VBS file "%vbs%" is done compiling
ECHO.
ECHO - LDraw archive library download path: %OutputPATH%

SET LibraryOPTION=Official
SET WebCONTENT="%OutputPATH%\%OfficialCONTENT%"
SET WebNAME=http://www.ldraw.org/library/updates/complete.zip

ECHO.
ECHO - Download archive file: %WebCONTENT%...

IF EXIST %WebCONTENT% (
 DEL %WebCONTENT%
)

ECHO.
cscript //Nologo %TEMP%\$\%vbs% %WebNAME% %WebCONTENT% && @ECHO off

IF EXIST %OfficialCONTENT% (
  ECHO.
  ECHO - LDraw archive library %OfficialCONTENT% downloaded
)
EXIT /b

:OUTPUT_LOGGING_MESSAGE
SET STATE=Normal build output enabled - all output displayed - Default.
IF %1==1 SET STATE=Minimum build output enabled - only error output displayed.
ECHO.
ECHO -%STATE%
EXIT /b

:PLATFORM_ERROR
ECHO.
CALL :USAGE
ECHO.
ECHO -01. (FLAG ERROR) Platform or usage flag is invalid. Use x86, x86_64 or -build_all [%~nx0 %*].
ECHO      For usage help use -help.
GOTO :ERROR_END

:CONFIGURATION_ERROR
ECHO.
CALL :USAGE
ECHO.
ECHO -02. (FLAG ERROR) Configuration flag is invalid [%~nx0 %*].
ECHO      Use -rel (release), or -3rd (3rd party install).
GOTO :ERROR_END

:COMMAND_ERROR
ECHO.
CALL :USAGE
ECHO.
ECHO -03. (COMMAND ERROR) Invalid command string [%~nx0 %*].
ECHO      See Usage.
GOTO :ERROR_END


:USAGE
ECHO ----------------------------------------------------------------
ECHO.
ECHO LDView Windows auto build script.
ECHO.
ECHO ----------------------------------------------------------------
ECHO Usage:
ECHO  build [ -help]
ECHO  build [ x86 ^| x86_64 ^| -all ] [ -ins ^| -chk ] [ -chk ]
ECHO.
ECHO ----------------------------------------------------------------
ECHO Build 64bit, Release and perform build check
ECHO build x86_64 -chk
ECHO.
ECHO Build 32bit, Release and perform build check
ECHO build x86 -chk
ECHO.
ECHO Build 32bit, Release and perform build check, output only build errors
ECHO build x86 -chk -minlog
ECHO.
ECHO Build 64bit and32bit, Release and perform build check
ECHO build -all -chk
ECHO.
ECHO Build 64bit and32bit, Release, perform install and build check
ECHO build -all -ins -chk
ECHO.
ECHO Build 64bit and32bit, Release, perform install and build check, output only build errors
ECHO build -all -ins -chk -minlog
ECHO.
ECHO Flags:
ECHO ----------------------------------------------------------------
ECHO ^| Flag    ^| Pos ^| Type             ^| Description
ECHO ----------------------------------------------------------------
ECHO  -help......1......Useage flag         [Default=Off] Display useage.
ECHO  x86........1......Platform flag       [Default=Off] Build 32bit architecture.
ECHO  x86_64.....1......Platform flag       [Default=Off] Build 64bit architecture.
ECHO  -all.......1......Configuraiton flag  [Default=On ] Build both  32bit and 64bit architectures
ECHO  -ins.......2......Project flag        [Default=Off] Install distribution as LPub3D 3rd party installation
ECHO  -chk.......2,3....Project flag        [Default=On ] Perform a quick image redering check using command line ini file
ECHO  -minlog....4,3....Project flag        [Default=Off] Minimum build logging - only display build errors
ECHO.
ECHO Be sure the set your LDraw directory in the variables section above if you expect to use the '-chk' option.
ECHO.
ECHO Flags are case sensitive, use lowere case.
ECHO.
ECHO If no flag is supplied, 64bit platform, Release Configuration built by default.
ECHO ----------------------------------------------------------------
EXIT /b

:ELAPSED_BUILD_TIME
IF [%1] EQU [] (SET start=%build_start%) ELSE (
  IF "%1"=="Start" (
    SET build_start=%time%
    EXIT /b
  ) ELSE (
    SET start=%1
  )
)
ECHO.
ECHO -%~nx0 finished.
SET end=%time%
SET options="tokens=1-4 delims=:.,"
FOR /f %options% %%a IN ("%start%") DO SET start_h=%%a&SET /a start_m=100%%b %% 100&SET /a start_s=100%%c %% 100&SET /a start_ms=100%%d %% 100
FOR /f %options% %%a IN ("%end%") DO SET end_h=%%a&SET /a end_m=100%%b %% 100&SET /a end_s=100%%c %% 100&SET /a end_ms=100%%d %% 100

SET /a hours=%end_h%-%start_h%
SET /a mins=%end_m%-%start_m%
SET /a secs=%end_s%-%start_s%
SET /a ms=%end_ms%-%start_ms%
IF %ms% lss 0 SET /a secs = %secs% - 1 & SET /a ms = 100%ms%
IF %secs% lss 0 SET /a mins = %mins% - 1 & SET /a secs = 60%secs%
IF %mins% lss 0 SET /a hours = %hours% - 1 & SET /a mins = 60%mins%
IF %hours% lss 0 SET /a hours = 24%hours%
IF 1%ms% lss 100 SET ms=0%ms%
ECHO -Elapsed build time %hours%:%mins%:%secs%.%ms%
ENDLOCAL
EXIT /b

:ERROR_END
CALL :ELAPSED_BUILD_TIME
EXIT /b 3

:END
CALL :ELAPSED_BUILD_TIME
EXIT /b
@ECHO off

Title LDView Windows auto build script

:: This script uses MSBuild to configure and build LDView for Windows.
:: The primary purpose is to automatically build both the 32bit and 64bit
:: LDView distributions and package the build contents (exe, doc and
:: resources ) as LPub3D 3rd Party components.
:: --
::  Trevor SANDY <trevor.sandy@gmail.com>
::  Last Update: July 07, 2017
::  Copyright (c) 2017 by Trevor SANDY
:: --
:: This script is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

SET PWD=%~dp0

:: Variables
SET APPNAME=LDView
SET VERSION=4.3
SET LDRAW_DIR=%USERPROFILE%\LDraw
SET DIST_DIR_ROOT=..\lpub3d-windows-3rdparty
SET INI_FILE="%PWD%\OSMesa\LDViewCustomIni"
SET CONFIGURATION=Release
SET PLATFORM=unknown
SET THIRD_INSTALL=unknown

:: Check if invalid platform flag
IF NOT [%1]==[] (
  IF NOT "%1"=="x86" (
    IF NOT "%1"=="x86_64" (
      IF NOT "%1"=="-all" (
        IF NOT "%1"=="-help" GOTO :PLATFORM_ERROR
      )
    )
  )
)

:: Parse platform input flag
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
:: If we get here display invalid command message.
GOTO :COMMAND_ERROR

:SET_CONFIGURATION
:: Only build release configuraion
IF NOT [%2]==[] (
  IF NOT "%2"=="-ins" (
  	IF NOT "%2"=="-chk" GOTO :CONFIGURATION_ERROR
  )
)

:: Parse configuration input flag
IF [%2]==[] (
  GOTO :BUILD
)

IF /I "%2"=="-ins" (
  SET THIRD_INSTALL=1
  GOTO :BUILD
)

:: Perform quick check
IF /I "%2"=="-chk" (
	SET CHECK=1
	GOTO :BUILD
)

:BUILD
:: Initialize the Visual Studio command line development environment
:: Note you can change this line to your specific environment - I am using VS2017 here.
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"

:: If check specified, update inifile with ldraw directory path
IF %CHECK%==1 CALL :UPDATE_INI_FILE

:: Check if build all platforms
IF /I "%PLATFORM%"=="-all" (
  GOTO :BUILD_ALL
)

:: Display platform setting
ECHO.
ECHO -Building %PLATFORM% Platform...
ECHO.

:: Launch msbuild
msbuild /m /p:Configuration=%CONFIGURATION% /p:Platform=%PLATFORM% LDView.vcxproj
:: Perform build check if specified
IF %CHECK%==1 CALL :CHECK_BUILD %PLATFORM%
:: Package 3rd party install
IF %THIRD_INSTALL%==1 GOTO :3RD_PARTY_INSTALL
:: Finish
EXIT /b

:BUILD_ALL
:: Launch msbuild across all platform builds
FOR %%P IN ( Win32, x64 ) DO (
  ECHO.
  ECHO -All Platforms: Building %%P Platform...
  ECHO.
  msbuild /m /p:Configuration=%CONFIGURATION% /p:Platform=%%P LDView.vcxproj
  :: Perform build check if specified
  IF %CHECK%==1 CALL :CHECK_BUILD %%P
)
:: Perform 3rd party install if specified
IF %THIRD_INSTALL%==1 GOTO :3RD_PARTY_INSTALL
:: Finish
EXIT /b

:3RD_PARTY_INSTALL
ECHO.
ECHO -Copying 3rd party distribution files...
ECHO.
ECHO -Copying 32bit exe...
IF NOT EXIST "%DIST_DIR_ROOT%\bin\%APPNAME%-%VERSION%\i386\" (
  MKDIR "%DIST_DIR_ROOT%\bin\%APPNAME%-%VERSION%\i386\"
)
COPY /V /Y "Build\Release\%APPNAME%.exe" "%DIST_DIR_ROOT%\bin\%APPNAME%-%VERSION%\i386\" /B

ECHO -Copying 64bit exe...
IF NOT EXIST "%DIST_DIR_ROOT%\bin\%APPNAME%-%VERSION%\x86_64\" (
  MKDIR "%DIST_DIR_ROOT%\bin\%APPNAME%-%VERSION%\x86_64\"
)
COPY /V /Y "Build\Release64\%APPNAME%64.exe" "%DIST_DIR_ROOT%\bin\%APPNAME%-%VERSION%\x86_64\" /B

ECHO -Copying Documentaton...
IF NOT EXIST "%DIST_DIR_ROOT%\docs\%APPNAME%-%VERSION%\" (
  MKDIR "%DIST_DIR_ROOT%\docs\%APPNAME%-%VERSION%\"
)
SET DIST_DIR="%DIST_DIR_ROOT%\docs\%APPNAME%-%VERSION%\"
COPY /V /Y "Readme.txt" "%DIST_DIR%" /A
COPY /V /Y "Help.html" "%DIST_DIR%" /A
COPY /V /Y "license.txt" "%DIST_DIR%" /A
COPY /V /Y "ChangeHistory.html" "%DIST_DIR%" /A

ECHO -Copying Resources...
IF NOT EXIST "%DIST_DIR_ROOT%\resources\%APPNAME%-%VERSION%\" (
  MKDIR "%DIST_DIR_ROOT%\resources\%APPNAME%-%VERSION%\"
)
SET DIST_DIR="%DIST_DIR_ROOT%\resources\%APPNAME%-%VERSION%\"
COPY /V /Y "m6459.ldr" "%DIST_DIR%" /A
COPY /V /Y "8464.mpd" "%DIST_DIR%" /A
COPY /V /Y "OSMesa\LDViewCustomIni" "%DIST_DIR%" /A
COPY /V /Y "OSMesa\LDViewCustomIni" "%DIST_DIR%" /A
:: Finish
EXIT /b

:CHECK_BUILD
SET PWD=%~dp0
IF %1==Win32 SET PL=
IF %1==x64 SET PL=64
ECHO.
ECHO -Check %CONFIGURATION% Configuration, %1 Platform...
ECHO.
ECHO -Command: %APPNAME%%PL%.exe "8464.mpd" -SaveSnapshot="8464.TestResult.%1.png" -IniFile=%INI_FILE% -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0
IF EXIST "8464.TestResult.%1.png" (
	DEL /Q "8464.TestResult.%1.png"
)
Build\release%PL%\%APPNAME%%PL%.exe "8464.mpd" -SaveSnapshot="8464.TestResult.%1.png" -IniFile=%INI_FILE% -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0
EXIT /b

:UPDATE_INI_FILE
IF NOT EXIST %LDRAW_DIR% (
	SET CHECK=0
	ECHO.
	ECHO -LDraw directory %LDRAW_DIR% does not exist.
	ECHO -Check aborted.
	ECHO.
	EXIT /b
)
ECHO.
ECHO -Check requested.
SET /a LineToReplace=31
SET "Replacement=LDrawDir=%LDRAW_DIR%"
ECHO - Upating %INI_FILE% at line %LineToReplace% with %Replacement%
(FOR /f "tokens=1*delims=:" %%a IN ('findstr /n "^" "%INI_FILE%"') DO (
  SET "Line=%%b"
  IF %%a equ %LineToReplace% SET "Line=%Replacement%"
    SETLOCAL ENABLEDELAYEDEXPANSION
    ECHO(!Line!
    ENDLOCAL
))>"%INI_FILE%.new"
MOVE /Y %INI_FILE%.new %INI_FILE% >nul 2>&1
SET /a LineToReplace=57
SET "Replacement=XmlMapPath=%LDRAW_DIR%\lgeo"
ECHO - Upating %INI_FILE% at line %LineToReplace% with %Replacement%
(FOR /f "tokens=1*delims=:" %%a IN ('findstr /n "^" "%INI_FILE%"') DO (
  SET "Line=%%b"
  IF %%a equ %LineToReplace% SET "Line=%Replacement%"
    SETLOCAL ENABLEDELAYEDEXPANSION
    ECHO(!Line!
    ENDLOCAL
))>"%INI_FILE%.new"
MOVE /Y %INI_FILE%.new %INI_FILE% >nul 2>&1
ECHO.
EXIT /b

:PLATFORM_ERROR
ECHO.
ECHO -(FLAG ERROR) Platform or usage flag is invalid. Use x86, x86_64 or -build_all. For usage help use -help.
GOTO :USAGE

:CONFIGURATION_ERROR
ECHO.
ECHO -(FLAG ERROR) Configuration flag is invalid. Use -rel (release), or -3rd (3rd party install).
GOTO :USAGE

:COMMAND_ERROR
ECHO.
ECHO -(COMMAND ERROR) Invalid command string.
GOTO :USAGE

:USAGE
ECHO.
ECHO LDView Windows auto build script.
ECHO.
ECHO Usage:
ECHO  build [ -help]
ECHO  build [ x86 ^| x86_64 ^| -all ] [ -ins ^| -chk ]
ECHO.
ECHO  -help....1.Useage flag - Display useage.
ECHO  x86......1.Platform flag - Build 32bit architecture.
ECHO  x86_64...1.Platform flag - Build 64bit architecture.
ECHO  -all.....1.Configuraiton flag - [Default] Build both  32bit and 64bit architectures
ECHO  -ins.....2.Project flag - Install distribution as LPub3D 3rd party installation
ECHO  -chk.....2.Project flag - Perform a quick image redering check using command line ini file
ECHO.
ECHO Be sure the set your LDraw directory in the variables section above if you expect to use the '-chk' option.
ECHO.
ECHO Flags are case sensitive, use lowere case.
ECHO.
ECHO If no flag is supplied, 64bit platform, Release Configuration built by default.
EXIT /b

:END
:: Done

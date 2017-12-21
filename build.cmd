@ECHO OFF &SETLOCAL

Title LDView Windows auto build script

rem This script uses MSBuild to configure and build LDView for Windows.
rem The primary purpose is to automatically build both the 32bit and 64bit
rem LDView distributions and package the build contents (exe, doc and
rem resources ) as LPub3D 3rd Party components.
rem --
rem  Trevor SANDY <trevor.sandy@gmail.com>
rem  Last Update: November 23, 2017
rem  Copyright (c) 2017 by Trevor SANDY
rem --
rem This script is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

SET PWD=%CD%

rem Variables
rem Static defaults
IF "%APPVEYOR%" EQU "True" (
  IF [%LP3D_DIST_DIR_PATH%] == [] (
    ECHO.
    ECHO  -ERROR: Distribution directory path not defined.
    ECHO  -%~nx0 terminated!
    GOTO :END
  )
  SET DIST_DIR=%LP3D_DIST_DIR_PATH%
  SET LDRAW_DOWNLOAD_DIR=%APPVEYOR_BUILD_FOLDER%
  SET LDRAW_DIR=%APPVEYOR_BUILD_FOLDER%\LDraw
) ELSE (
  SET LDRAW_DOWNLOAD_DIR=%USERPROFILE%
  SET LDRAW_DIR=%USERPROFILE%\LDraw
  SET DIST_DIR=..\lpub3d_windows_3rdparty
)
SET INI_POV_FILE=%PWD%\OSMesa\ldviewPOV.ini
SET zipWin64=C:\program files\7-zip
SET OfficialCONTENT=complete.zip

SET PACKAGE=LDView
SET VERSION=4.3
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
rem Initialize the Visual Studio command line development environment
rem Note you can change this line to your specific environment - I am using VS2017 here.
ECHO.
ECHO -Initialize Microsoft Build VS2017...
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"

rem Display build settings
IF "%APPVEYOR%" EQU "True" (
  ECHO   BUILD_HOST.............[APPVEYOR CONTINUOUS INTEGRATION SERVICE]
  ECHO   BUILD_ID...............[%APPVEYOR_BUILD_ID%]
  ECHO   BUILD_BRANCH...........[%APPVEYOR_REPO_BRANCH%]
  ECHO   PROJECT_NAME...........[%APPVEYOR_PROJECT_NAME%]
  ECHO   REPOSITORY_NAME........[%APPVEYOR_REPO_NAME%]
  ECHO   REPO_PROVIDER..........[%APPVEYOR_REPO_PROVIDER%]
  ECHO   DIST_DIRECTORY.........[%DIST_DIR%]
)
ECHO   PACKAGE................[%PACKAGE%]
ECHO   VERSION................[%VERSION%]
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

rem Display platform setting
ECHO.
ECHO -Building %PLATFORM% Platform...
ECHO.
rem Assemble command line
SET COMMAND_LINE=msbuild /m /p:Configuration=%CONFIGURATION% /p:Platform=%PLATFORM% LDView.vcxproj %LOGGING_FLAGS%
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
ECHO -Build x86 and x86_64 platform...
FOR %%P IN ( Win32, x64 ) DO (
  ECHO.
  ECHO -Building %%P Platforms...
  ECHO.
  rem Assemble command line
  SET COMMAND_LINE=msbuild /m /p:Configuration=%CONFIGURATION% /p:Platform=%%P LDView.vcxproj %LOGGING_FLAGS%
  SETLOCAL ENABLEDELAYEDEXPANSION
  ECHO -Build Command: !COMMAND_LINE!
  !COMMAND_LINE!
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

:UPDATE_INI_POV_FILE
IF EXIST "%LDRAW_DIR%\lgeo" (
SET /a LineToReplace=50
SET "Replacement=XmlMapPath=%LDRAW_DIR%\lgeo"
ECHO.
SETLOCAL ENABLEDELAYEDEXPANSION
ECHO -Update %INI_POV_FILE% at line !LineToReplace! with !Replacement!
ENDLOCAL
(FOR /f "tokens=1*delims=:" %%a IN ('findstr /n "^" "%INI_POV_FILE%"') DO (
  SET "Line=%%b"
  IF %%a equ %LineToReplace% SET "Line=%Replacement%"
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
SET ARGS=-SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0
SET PACKAGE_PATH=Build\%CONFIGURATION%%PL%\%PACKAGE%%PL%.exe
SET COMMAND_LINE_ARGS= "%IN_FILE%" -LDrawDir="%LDRAW_DIR%" -SaveSnapshot="%OUT_FILE%" -IniFile="%INI_FILE%" %ARGS%
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
IF %INSTALL_32BIT% == 1 (
	ECHO.
	ECHO -Installing %PACKAGE%32bit exe to [%DIST_DIR%\%PACKAGE%-%VERSION%\bin\i386]...
	IF NOT EXIST "%DIST_DIR%\%PACKAGE%-%VERSION%\bin\i386\" (
	  MKDIR "%DIST_DIR%\%PACKAGE%-%VERSION%\bin\i386\"
	)
	COPY /V /Y "Build\Release\%PACKAGE%.exe" "%DIST_DIR%\%PACKAGE%-%VERSION%\bin\i386\" /B
)
IF %INSTALL_64BIT% == 1 (
	ECHO.
	ECHO -Installing %PACKAGE%64bit exe to [%DIST_DIR%\%PACKAGE%-%VERSION%\bin\x86_64]...
	IF NOT EXIST "%DIST_DIR%\%PACKAGE%-%VERSION%\bin\x86_64\" (
	  MKDIR "%DIST_DIR%\%PACKAGE%-%VERSION%\bin\x86_64\"
	)
	COPY /V /Y "Build\Release64\%PACKAGE%64.exe" "%DIST_DIR%\%PACKAGE%-%VERSION%\bin\x86_64\" /B
)
ECHO.
ECHO -Installing Documentaton to [%DIST_DIR%\%PACKAGE%-%VERSION%\docs]...
IF NOT EXIST "%DIST_DIR%\%PACKAGE%-%VERSION%\docs\" (
  MKDIR "%DIST_DIR%\%PACKAGE%-%VERSION%\docs\"
)
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\docs\
COPY /V /Y "Readme.txt" "%DIST_INSTALL_PATH%" /A
COPY /V /Y "Help.html" "%DIST_INSTALL_PATH%" /A
COPY /V /Y "license.txt" "%DIST_INSTALL_PATH%" /A
COPY /V /Y "ChangeHistory.html" "%DIST_INSTALL_PATH%" /A
IF NOT EXIST "%DIST_DIR%\%PACKAGE%-%VERSION%\resources\config\" (
  MKDIR "%DIST_DIR%\%PACKAGE%-%VERSION%\resources\config\"
)
ECHO.
ECHO -Installing Ini Files to [%DIST_DIR%\%PACKAGE%-%VERSION%\resources\config]...
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\resources\config\
COPY /V /Y "OSMesa\LDViewCustomIni" "%DIST_INSTALL_PATH%" /A
COPY /V /Y "OSMesa\ldview.ini" "%DIST_INSTALL_PATH%" /A
COPY /V /Y "OSMesa\ldviewPOV.ini" "%DIST_INSTALL_PATH%" /A
ECHO.
ECHO -Installing Resource Files to [%DIST_DIR%\%PACKAGE%-%VERSION%\resources]...
SET DIST_INSTALL_PATH=%DIST_DIR%\%PACKAGE%-%VERSION%\resources\
COPY /V /Y "m6459.ldr" "%DIST_INSTALL_PATH%" /A
COPY /V /Y "8464.mpd" "%DIST_INSTALL_PATH%" /A
COPY /V /Y "LDExporter\LGEO.xml" "%DIST_INSTALL_PATH%" /A
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
GOTO :END

:CONFIGURATION_ERROR
ECHO.
CALL :USAGE
ECHO.
ECHO -02. (FLAG ERROR) Configuration flag is invalid [%~nx0 %*].
ECHO      Use -rel (release), or -3rd (3rd party install).
GOTO :END

:COMMAND_ERROR
ECHO.
CALL :USAGE
ECHO.
ECHO -03. (COMMAND ERROR) Invalid command string [%~nx0 %*].
ECHO      See Usage.
GOTO :END


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

:END
ECHO.
ECHO -%~nx0 [%PACKAGE% v%VERSION%] finished.
ENDLOCAL
EXIT /b

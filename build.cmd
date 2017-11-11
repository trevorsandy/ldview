@ECHO OFF &SETLOCAL

Title LDView Windows auto build script

rem This script uses MSBuild to configure and build LDView for Windows.
rem The primary purpose is to automatically build both the 32bit and 64bit
rem LDView distributions and package the build contents (exe, doc and
rem resources ) as LPub3D 3rd Party components.
rem --
rem  Trevor SANDY <trevor.sandy@gmail.com>
rem  Last Update: November 11, 2017
rem  Copyright (c) 2017 by Trevor SANDY
rem --
rem This script is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

SET PWD=%~dp0

rem Variables
rem Static defaults
IF "%APPVEYOR%" EQU "True" (
  IF [%LDV_DIST_DIR_PATH%] == [] (
    ECHO.
    ECHO  -ERROR: Distribution directory path not defined.
    ECHO  -%~nx0 terminated!
    GOTO :END
  )
  SET DIST_DIR_ROOT=%LDV_DIST_DIR_PATH%
  SET LDRAW_DOWNLOAD_DIR=%LDV_LDRAW_ROOT%
  SET LDRAW_DIR=%LDV_LDRAW_ROOT%\LDraw
) ELSE (
  SET LDRAW_DOWNLOAD_DIR=%USERPROFILE%
  SET LDRAW_DIR=%USERPROFILE%\LDraw
  SET DIST_DIR_ROOT=..\lpub3d_windows_3rdparty
)
rem Set console output logging level - (0=normal:all output or 1=minimum:error output)
SET MIN_CONSOLE_OUTPUT=1
SET PACKAGE=LDView
SET VERSION=4.3

SET zipWin64=C:\program files\7-zip
SET OfficialCONTENT=complete.zip
SET UnofficialCONTENT=ldrawunf.zip

SET INI_POV_FILE=%PWD%OSMesa\ldviewPOV.ini
SET CONFIGURATION=Release
SET PLATFORM=unknown
SET INI_FILE=unknown
SET THIRD_INSTALL=unknown
SET CHECK=unknown
SET zipExe=unknown

rem Check if invalid platform flag
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
rem Only build release configuraion
IF NOT [%2]==[] (
  IF NOT "%2"=="-ins" (
  	IF NOT "%2"=="-chk" GOTO :CONFIGURATION_ERROR
  )
)

rem Only build release configuraion
IF NOT [%3]==[] (
  IF NOT "%3"=="-chk" GOTO :CONFIGURATION_ERROR
)

rem Parse configuration input flag
IF [%2]==[] (
  SET THIRD_INSTALL=1
  GOTO :BUILD
)

IF /I "%2"=="-ins" (
  SET THIRD_INSTALL=1
  GOTO :BUILD
)

rem Perform quick check
IF /I "%2"=="-chk" (
	SET CHECK=1
	GOTO :BUILD
)

:BUILD
rem Initialize the Visual Studio command line development environment
rem Note you can change this line to your specific environment - I am using VS2017 here.
CALL "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"

rem Console output - see https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference
IF %MIN_CONSOLE_OUTPUT%==1 (
  SET CONSOLE_OUTPUT_FLAGS=/clp:ErrorsOnly /nologo
)

rem Display build settings
IF "%APPVEYOR%" EQU "True" (
  ECHO   BUILD_HOST..........[APPVEYOR CONTINUOUS INTEGRATION SERVICE]
  ECHO   BUILD_ID............[%APPVEYOR_BUILD_ID%]
  ECHO   BUILD_BRANCH........[%APPVEYOR_REPO_BRANCH%]
  ECHO   PROJECT_NAME........[%APPVEYOR_PROJECT_NAME%]
  ECHO   REPOSITORY_NAME.....[%APPVEYOR_REPO_NAME%]
  ECHO   REPO_PROVIDER.......[%APPVEYOR_REPO_PROVIDER%]
  ECHO   DIST_DIRECTORY......[%DIST_DIR_ROOT%]
)
ECHO   PACKAGE.............[%PACKAGE%]
ECHO   VERSION.............[%VERSION%]
ECHO   LDRAW_DIR...........[%LDRAW_DIR%]
ECHO.  LDRAW_DOWNLOAD_DIR..[%LDRAW_DOWNLOAD_DIR%]

rem Console output logging level message
CALL :CONSOLE_OUTPUT_MESSAGE %MIN_CONSOLE_OUTPUT%

rem Backup ini files
CALL :BACKUP_INI_FILES

rem If check specified, update inifile with ldraw directory path
CALL :UPDATE_INI_POV_FILE

rem Perform quick check
IF /I "%3"=="-chk" (
  SET CHECK=1
)

rem Check if build all platforms
IF /I "%PLATFORM%"=="-all" (
  GOTO :BUILD_ALL
)

rem Display platform setting
ECHO.
ECHO -Building %PLATFORM% Platform...
ECHO.
rem Assemble command line
SET COMMAND_LINE=msbuild /m /p:Configuration=%CONFIGURATION% /p:Platform=%PLATFORM% LDView.vcxproj %CONSOLE_OUTPUT_FLAGS%
ECHO -Command: %COMMAND_LINE%
rem Launch msbuild
%COMMAND_LINE%
rem Perform build check if specified
IF %CHECK%==1 CALL :CHECK_BUILD %PLATFORM%
rem Package 3rd party install
IF %THIRD_INSTALL%==1 CALL :3RD_PARTY_INSTALL
rem Restore ini file
CALL :RESTORE_INI_FILES
GOTO :END

:BUILD_ALL
rem Launch msbuild across all platform builds
FOR %%P IN ( Win32, x64 ) DO (
  ECHO.
  ECHO -All Platforms: Building %%P Platform...
  ECHO.
  rem Assemble command line
  SET COMMAND_LINE=msbuild /m /p:Configuration=%CONFIGURATION% /p:Platform=%%P LDView.vcxproj %CONSOLE_OUTPUT_FLAGS%
  SETLOCAL ENABLEDELAYEDEXPANSION
  ECHO -Command: !COMMAND_LINE!
  !COMMAND_LINE!
  ENDLOCAL
  rem Perform build check if specified
  IF %CHECK%==1 CALL :CHECK_BUILD %%P
)
rem Restore ini file
CALL :RESTORE_INI_FILES
rem Package 3rd party install
IF %THIRD_INSTALL%==1 CALL :3RD_PARTY_INSTALL
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
	ECHO -LGEO directory %LDRAW_DIR%\lgeo does not exist - Update LDview.ini ignored.
)
EXIT /b

:CHECK_BUILD
CALL :CHECK_LDRAW_DIR
IF %CHECK%==1 (
SET INI_FILE=%INI_POV_FILE%
IF %1==Win32 SET PL=
IF %1==x64 SET PL=64
IF EXIST "8464.TestResult.%1.png" (
	DEL /Q "8464.TestResult.%1.png"
)
SETLOCAL ENABLEDELAYEDEXPANSION
ECHO.
ECHO -Check %CONFIGURATION% Configuration, %1 Platform using Ini file !INI_FILE!...
ECHO.
SET COMMAND_LINE=Build\release%PL%\%PACKAGE%%PL%.exe "8464.mpd" -SaveSnapshot="8464.TestResult.%1.png" -IniFile=!INI_FILE! -SaveWidth=128 -SaveHeight=128 -ShowErrors=0 -SaveActualSize=0
ECHO -Command: !COMMAND_LINE!
!COMMAND_LINE!
ENDLOCAL
IF EXIST "8464.TestResult.%1.png" (
  ECHO.
  ECHO -Create 8464.TestResult.%1.png from 8464.mpd - Test successful!
)
) ELSE (
  ECHO -Check is not possible
)
EXIT /b

:3RD_PARTY_INSTALL
ECHO.
ECHO -Copying 3rd party distribution files...
ECHO.
ECHO -Copying 32bit exe...
IF NOT EXIST "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\bin\i386\" (
  MKDIR "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\bin\i386\"
)
COPY /V /Y "Build\Release\%PACKAGE%.exe" "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\bin\i386\" /B

ECHO -Copying 64bit exe...
IF NOT EXIST "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\bin\x86_64\" (
  MKDIR "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\bin\x86_64\"
)
COPY /V /Y "Build\Release64\%PACKAGE%64.exe" "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\bin\x86_64\" /B

ECHO -Copying Documentaton...
IF NOT EXIST "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\docs\" (
  MKDIR "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\docs\"
)
SET DIST_DIR=%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\docs\
COPY /V /Y "Readme.txt" "%DIST_DIR%" /A
COPY /V /Y "Help.html" "%DIST_DIR%" /A
COPY /V /Y "license.txt" "%DIST_DIR%" /A
COPY /V /Y "ChangeHistory.html" "%DIST_DIR%" /A

ECHO -Copying Ini Files...
IF NOT EXIST "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\resources\config\" (
  MKDIR "%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\resources\config\"
)
SET DIST_DIR=%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\resources\config
COPY /V /Y "OSMesa\LDViewCustomIni" "%DIST_DIR%" /A
COPY /V /Y "OSMesa\ldview.ini" "%DIST_DIR%" /A
COPY /V /Y "OSMesa\ldviewPOV.ini" "%DIST_DIR%" /A

ECHO -Copying Resources...
SET DIST_DIR=%DIST_DIR_ROOT%\%PACKAGE%-%VERSION%\resources\
COPY /V /Y "m6459.ldr" "%DIST_DIR%" /A
COPY /V /Y "8464.mpd" "%DIST_DIR%" /A
COPY /V /Y "LDExporter\LGEO.xml" "%DIST_DIR%" /A
EXIT /b

:BACKUP_INI_FILES
ECHO.
ECHO -Backing up ini files...
SET INI_FILE=%PWD%\OSMesa\ldviewPOV.ini
COPY /V /Y "%INI_FILE%" "%INI_FILE%.hold" /A
SET INI_FILE=%PWD%\OSMesa\ldview.ini
COPY /V /Y "%INI_FILE%" "%INI_FILE%.hold" /A
EXIT /b

:RESTORE_INI_FILES
ECHO.
ECHO -Restoring ini files...
SET INI_FILE=%PWD%\OSMesa\ldviewPOV.ini
MOVE /Y "%INI_FILE%.hold" "%INI_FILE%" >nul 2>&1
SET INI_FILE=%PWD%\OSMesa\ldview.ini
MOVE /Y "%INI_FILE%.hold" "%INI_FILE%" >nul 2>&1
EXIT /b

:CHECK_LDRAW_DIR
ECHO.
ECHO -Check LDraw library requested.
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
      )
    ) ELSE (
      ECHO [WARNING] Could not find zip executable.
      SET CHECK=0
    )
  ) ELSE (
    ECHO.
    ECHO -[WARNING] Could not find %LDRAW_DOWNLOAD_DIR%\%OfficialCONTENT%.
    SET CHECK=0
  )
) ELSE (
  ECHO.
  ECHO -LDraw directory %LDRAW_DIR% exist.
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
>>%t%   WScript.Echo " The file may be in use by another process.", vbLF
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
ECHO.
ECHO - LDraw archive library download finshed.
EXIT /b

:CONSOLE_OUTPUT_MESSAGE
SET STATE=Normal console display enabled - all output displayed - Default.
IF %1==1 SET STATE=Minimum console display enabled - only error output displayed.
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
ECHO Build 64bit and32bit, Release and perform build check
ECHO build -all -chk
ECHO.
ECHO Build 64bit and32bit, Release, perfform install and build check
ECHO build -all -ins -chk
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
ECHO.
ECHO Be sure the set your LDraw directory in the variables section above if you expect to use the '-chk' option.
ECHO.
ECHO Flags are not case sensitive, use lowere case.
ECHO.
ECHO If no flag is supplied, 64bit platform, Release Configuration built by default.
ECHO ----------------------------------------------------------------
EXIT /b

:END
ECHO Finished.
ENDLOCAL
EXIT /b

@echo off

rem useage: setFileAssoc.cmd .sh "Shell Script" "C:\Windows\System32\wsl.exe $(wslpath "%1")"

:: Arguments
set FILE_EXT=%~1
set APP_NAME=%~2
set  APP_CMD=%~3

call:CheckArg "%FILE_EXT%"
if %errorlevel% neq 0 goto help
call:CheckArg "%APP_NAME%"
if %errorlevel% neq 0 goto help
call:CheckArg "%APP_CMD%"
if %errorlevel% neq 0 goto help
call:CheckArg "%~4%"
if %errorlevel% equ 0 goto help

echo :: Arguments ---
echo FILE_EXT: %FILE_EXT%
echo APP_NAME: %APP_NAME%
echo APP_CMD : %APP_CMD%
echo ----------------
echo:

set APP_CMD=%APP_CMD:"="""%

rem goto skip

:: set classes root registry
        :: Windows Registry Editor Version 5.00
        :: [.%FILE_EXT%]
        :: @="%APP_NAME%"
        :: [%APP_NAME%\shell\Open\command]
        :: @="%APP_CMD%"
reg add "HKCR\%FILE_EXT%" /d "%APP_NAME%" /t REG_SZ /f >nul
reg add "HKCR\%APP_NAME%\shell\Open\command" /d "%APP_CMD%" /t REG_EXPAND_SZ /f >nul

:: set assoc/ftype
assoc %FILE_EXT%=%APP_NAME% >nul
ftype %APP_NAME%=%APP_CMD% >nul

:: set user associate registry
reg add "HKCU\Software\Classes\%FILE_EXT%" /d "%APP_NAME%" /t REG_SZ /f >nul
reg add "HKCU\Software\Classes\%APP_NAME%\shell\Open\command" /d "%APP_CMD%" /t REG_EXPAND_SZ /f >nul

reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%\UserChoice" 1>nul 2>&1
if %errorlevel% equ 0 reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%\UserChoice" /f >nul

reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%" 1>nul 2>&1
if %errorlevel% equ 0 reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%" /f >nul

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%" /v Application /t REG_SZ /d "%APP_NAME%" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%\OpenWithProgids" /v "%APP_NAME%" /t REG_BINARY /d "" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%\UserChoice" /v ProgId /t REG_SZ /d "%APP_NAME%" /f >nul

reg add "HKLM\Software\Classes\%FILE_EXT%" /d "%APP_NAME%" /t REG_SZ /f >nul
reg add "HKLM\Software\Classes\%APP_NAME%\shell\Open\command" /d "%APP_CMD%" /t REG_EXPAND_SZ /f >nul

reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%\UserChoice" 1>nul 2>&1
if %errorlevel% equ 0 reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%\UserChoice" /f >nul

reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%" 1>nul 2>&1
if %errorlevel% equ 0 reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%" /f >nul

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%" /v Application /t REG_SZ /d "%APP_NAME%" /f >nul
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%\OpenWithProgids" /v "%APP_NAME%" /t REG_BINARY /d "" /f >nul
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%FILE_EXT%\UserChoice" /v ProgId /t REG_SZ /d "%APP_NAME%" /f >nul

:skip
echo Done.
exit /b 0

:: --- Function --- ::
:help
echo usage:
echo   setFileAssoc.cmd ^<FileExtension^> ^<AppName^> ^<AppExecuteCommand^>
echo:
echo   NOTE: if pass with space, should input like ""C:/Program Files/Test.exe "%%1""
exit /b 0

:CheckArg
set ARG=%~1
if "%ARG%" == "" exit /b -1
set ARG=%ARG:"=%
set ARG=%ARG:(= %
set ARG=%ARG:)= %
if "%ARG%" == "" exit /b -1
goto:eof
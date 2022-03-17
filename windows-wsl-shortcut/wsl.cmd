@echo off
for /f "tokens=1,* delims= " %%a in ("%*") do set ALL_BUT_FIRST=%%b
C:\Windows\System32\wsl.exe $(wslpath "%~1") %ALL_BUT_FIRST%

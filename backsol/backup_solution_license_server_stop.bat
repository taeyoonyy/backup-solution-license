@echo off
@echo Administrative permissions required. Detecting permissions...

@net session >nul 2>&1
if %errorLevel% == 0 (set is_admin="true") else (set is_admin="false")

REM Discover the release root directory from the directory of this script
@set release_root_dir=%~dp0

REM Call the interactor stop / uninstall script
if %is_admin% == "true" (
  @echo Stopping your License Server, Please wait
  call %release_root_dir%_build\prod\rel\backsol\erts-10.7\bin\erlsrv.exe stop backsol_backsol
  @echo Your License Server is now Stopped
) else (
  @echo You do not have administrator permissions. Please login as an administrator to proceed.
)
TIMEOUT 10 >NUL
goto :eof
:test
exit /b

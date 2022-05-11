@echo off

@echo Administrative permissions required. Detecting permissions...
net session >nul 2>&1
if %errorLevel%==0 (set is_admin="true") else (set is_admin="false")

@set release_root_dir_start=%~dp0

if %is_admin%=="true" (
  :while0
  echo Starting your License Server, Please wait...
  call %release_root_dir_start%_build\prod\rel\backsol\erts-10.7\bin\erlsrv.exe start backsol_backsol > service_check.txt 2>&1
  for /f "usebackq " %%I in (`findstr /I terminate "service_check.txt"`) do (
  	ECHO Found Error in starting License Server
  	ECHO Now, making it ready to start again. Please wait...
  	call backup_solution_license_server_stop.bat
  	call :test
  	goto :eof
  )
  for /f "usebackq " %%I in (`findstr /I started "service_check.txt"`) do (
  	@ECHO License Server started
  	@echo License Server is now Running
    @echo ----------------------------------------------------------------
    @echo To Login into your License Server, open browser and type as follow
    @echo http://{IP_ADDRESS}:4000/management
    @echo Register with user id and password for the first time user
    @echo ----------------------------------------------------------------
  )
  for /f "usebackq " %%I in (`findstr /I Failed  "service_check.txt"`) do (
  	@ECHO License Server is already running
    @ECHO If you want to restart, Please start after stop.
  )

  @DEL service_check.txt
  ) else (
  @echo You do not have administrator permissions. Please login as an administrator to proceed.

)
TIMEOUT 10 >NUL
goto :eof
:test
exit /b
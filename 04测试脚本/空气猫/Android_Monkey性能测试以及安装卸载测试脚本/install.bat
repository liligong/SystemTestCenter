@echo off

SET PCEXE_DIR=%CD%
SET CURRENT_DIR=%PCEXE_DIR%

cd %CURRENT_DIR%
echo current path=%CURRENT_DIR%

if "%1" == "h" goto begin
mshta vbscript:createobject("wscript.shell").run("%~nx0 h",0)(window.close)&&exit

:begin
echo fail > install_result.txt	
rem install apk
	echo "adb install EnvMonitor-1.0.0.1.21-qa-release.apk"
	adb install EnvMonitor-1.0.0.1.21-qa-release.apk > tmp
	sleep 1000
	type tmp
	type tmp | find "Success"
	if NOT ERRORLEVEL 1 (
		echo pass pass 
		echo pass > install_result.txt
	)
	echo FINISH > DONE
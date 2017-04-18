@echo off

SET PCEXE_DIR=%CD%
SET CURRENT_DIR=%PCEXE_DIR%
SET SCRIPT_PATH=/data/local/tmp

SET Test_COUNT=300
goto MonkeyTest
cd %CURRENT_DIR%
echo current path=%CURRENT_DIR%
if exist install_result.txt del install_result.txt
rem push monkey script to %SCRIPT_PATH%
	adb push install.script %SCRIPT_PATH%
	if ERRORLEVEL 1 goto pushFail
	
:installAndUninstallTest
SET /a COUNT=%COUNT%+1

echo %COUNT% >> debug


echo "***********************"
echo "********Count = %COUNT%"
echo "***********************"

:installApk
rem install apk
	adb uninstall com.phicomm.envmonitor
	echo "Start install.bat"
	echo "del install_result.txt"
	if exist install_result.txt del install_result.txt
	if exist DONE del DONE
	start install.bat
	echo sleep 10000
	sleep 10000
	
	echo "Start monkey script to enable install"
	adb shell monkey -f %SCRIPT_PATH%/install.script 1	
	if ERRORLEVEL 1 goto scriptFail
	echo sleep 1000
	sleep 1000
	echo "enable install Script finish!"

:waitInstallFinish
rem check install result
	echo "check install result"
	sleep 300
	if not exist DONE goto waitInstallFinish	
	type install_result.txt >> debug
	echo "***************"
	type install_result.txt
	type install_result.txt | find "pass"
	if ERRORLEVEL 1 goto installApk
rem launch apk
	echo "launch apk"
	adb shell "am start -n com.phicomm.envmonitor/com.phicomm.envmonitor.activities.SplashActivity"
	sleep 500
	adb shell "ps | grep com.phicomm.envmonitor" > tmp
	type tmp | find "com.phicomm.envmonitor"
	if ERRORLEVEL 1 goto launchFail
	
echo "please login, and press any key to continue"
pause	
:MonkeyTest
adb shell monkey -p com.phicomm.envmonitor -s 500 --ignore-crashes --ignore-timeouts --ignore-security-exceptions --ignore-native-crashes --monitor-native-crashes -v -v 90000> monkey_log.txt
goto PASS

:installFail
set errStr=installFail
goto ERROR

:pushFail
set errStr=pushFail
goto ERROR

:uninstallFail
set errStr=uninstallFail
goto ERROR

:scriptFail
set errStr=scriptFail
goto ERROR

:launchFail
set errStr=launchFail
goto ERROR

rem *****************
:ERROR
echo %errStr%
echo ###################################
echo #   ******    *     ***** *       #
echo #   *        * *      *   *       #
echo #   ******  *   *     *   *       #
echo #   *      *******    *   *       #
echo #   *     *       * ***** *****   #
echo ###################################
echo FAIL! FAIL! FAIL!
color C0
goto END

rem *****************
:PASS
echo #####################################
echo #   ******     *     ****** ******  #
echo #   *    *    * *    *      *       #
echo #   ******   *   *   ****** ******  #
echo #   *       *******       *      *  #
echo #   *      *       * ****** ******  #
echo #####################################
echo PASS PASS PASS
color a0
rem adb shell monkey -p com.phicomm.envmonitor -s 500 --ignore-crashes --ignore-timeouts --monitor-native-crashes -v -v 10000 > monkey_log.txt
:END

cd %PCEXE_DIR%
pause
color
@echo off
title OSTFIH_NE1-Flasher (BETA_v1.1.3.0)
mode 120,500

:strt
echo.
echo  a) Type "1" to install the "Factory Firmware"
echo.
echo  b) Type "2" to ERASE the "FRP" partition and Wipe the data
echo.
set /p fih=Enter the digit: 
cls
if %fih% == 1 goto reinstall the firmware
if %fih% == 2 goto erase FRP

:reinstall the firmware
echo ********* Service Bootloader Authorisation *********
echo.
.\fastboot\fastbootfih.exe oem alive
.\fastboot\fastbootfih.exe oem CustomerSKUID get
.\fastboot\fastbootfih.exe oem getversions
.\fastboot\fastbootfih.exe getvar productid
.\fastboot\fastbootfih.exe oem getBootloaderType
echo.
echo ========================================================
.\fastboot\fastbootfih.exe oem getSecurityVersion
.\fastboot\fastbootfih.exe oem getProjectCode
.\fastboot\fastbootfih.exe oem dm-veracity
echo ========================================================
echo.
echo Please calculate the above given "Challenge Code" to validate the device into Service mode.
echo --------------------------------------------------------------------------------------------
echo.
set Signature=Default
set /p Signature=Enter the Signature Code: 
echo %Signature% > Signature.txt
dir /b > list.txt
findstr "Signature.txt" list.txt > tmp.txt
set /p Signature=<tmp.txt
certutil -decode %Signature% veracity.bin
del tmp.txt
del list.txt
del Signature.txt
echo.
dir /b > list.txt
findstr "veracity.bin" list.txt > tmp.txt
set /p veracity=<tmp.txt
.\fastboot\fastbootfih.exe flash veracity %veracity%
del tmp.txt
del list.txt
del veracity.bin
dir /b > list.txt
findstr "lk_service.img" list.txt > tmp.txt
set /p lk=<tmp.txt
.\fastboot\fastbootfih.exe flash lk %lk%
del tmp.txt
del list.txt
.\fastboot\fastboot.exe reboot-bootloader
echo.
echo ********* Authorisation Completed *********

echo.
echo REBOOTING INTO DOWNLOAD MODE...
ping localhost -n 8 >nul
.\fastboot\fastbootfih.exe oem getBootloaderType
echo.

echo ********* Device RootStatus Authorisation *********
echo.
.\fastboot\fastbootfih.exe oem alive
.\fastboot\fastbootfih.exe oem CustomerSKUID get
.\fastboot\fastbootfih.exe oem getversions
.\fastboot\fastbootfih.exe getvar productid
.\fastboot\fastbootfih.exe oem getRootStatus
echo.
echo ========================================================
.\fastboot\fastbootfih.exe oem getSecurityVersion
.\fastboot\fastbootfih.exe oem getProjectCode
.\fastboot\fastbootfih.exe oem getUID
echo ========================================================
echo.
echo Please calculate the above given "Challenge Code" to Enable the device RootStatus.
echo -----------------------------------------------------------------------------------
echo.
set Signature=Default
set /p Signature=Enter the Signature Code: 
echo %Signature% > Signature.txt
dir /b > list.txt
findstr "Signature.txt" list.txt > tmp.txt
set /p Signature=<tmp.txt
certutil -decode %Signature% encUID.bin
del tmp.txt
del list.txt
del Signature.txt
dir /b > list.txt
findstr "encUID.bin" list.txt > tmp.txt
set /p encUID=<tmp.txt
.\fastboot\fastbootfih.exe flash encUID %encUID%
.\fastboot\fastbootfih.exe oem selectKey service
.\fastboot\fastbootfih.exe oem doKeyVerify
del tmp.txt
del list.txt
echo.
echo ********* Authorisation Completed *********

echo.
echo Check Device RootStatus...
ping localhost -n 5 >nul
.\fastboot\fastbootfih.exe oem getRootStatus
echo.

dir /b > list.txt
findstr "preloader_NE1.bin" list.txt > tmp.txt
set /p PRELOADER=<tmp.txt
findstr "lk_service.img" list.txt > tmp.txt
set /p lk=<tmp.txt
findstr "tee.img" list.txt > tmp.txt
set /p tee=<tmp.txt
findstr "secro.img" list.txt > tmp.txt
set /p SECRO=<tmp.txt
findstr "logo.bin" list.txt > tmp.txt
set /p LOGO=<tmp.txt
findstr "boot.img" list.txt > tmp.txt
set /p boot=<tmp.txt
findstr "recovery.img" list.txt > tmp.txt
set /p RECOVERY=<tmp.txt
findstr "fver" list.txt > tmp.txt
set /p sys_info=<tmp.txt
findstr "cda.img" list.txt > tmp.txt
set /p cda=<tmp.txt
findstr "system.img" list.txt > tmp.txt
set /p ANDSYSIMG=<tmp.txt
findstr "sutinfo.img" list.txt > tmp.txt
set /p sutinfo=<tmp.txt
findstr "cache.img" list.txt > tmp.txt
set /p CACHE=<tmp.txt
findstr "userdata.img" list.txt > tmp.txt
set /p USERDATA=<tmp.txt
findstr "md4.dat" list.txt > tmp.txt
set /p MD4CHECKSUM=<tmp.txt
del list.txt
del tmp.txt

echo ********* [Device Flashing] *********
echo.
.\fastboot\fastboot.exe flash preloader %PRELOADER%
.\fastboot\fastboot.exe flash lk %lk%
.\fastboot\fastboot.exe flash tee1 %tee%
.\fastboot\fastboot.exe flash tee2 %tee%
.\fastboot\fastboot.exe flash secro %SECRO%
.\fastboot\fastboot.exe flash logo %LOGO%
.\fastboot\fastboot.exe reboot-bootloader

echo.
echo REBOOTING INTO DOWNLOAD MODE...
ping localhost -n 8 >nul
echo.

.\fastboot\fastbootfih.exe oem alive
.\fastboot\fastbootfih.exe oem getSecurityVersion
.\fastboot\fastbootfih.exe oem getProjectCode
.\fastboot\fastbootfih.exe oem getUID
dir /b > list.txt
findstr "encUID.bin" list.txt > tmp.txt
set /p encUID=<tmp.txt
.\fastboot\fastbootfih.exe flash encUID %encUID%
.\fastboot\fastbootfih.exe oem selectKey service
.\fastboot\fastbootfih.exe oem doKeyVerify
del tmp.txt
del list.txt
echo.
.\fastboot\fastboot.exe flash boot %BOOT%
.\fastboot\fastboot.exe flash recovery %RECOVERY%
.\fastboot\fastboot.exe flash secro %secro%
.\fastboot\fastboot.exe flash logo %LOGO%
.\fastboot\fastboot.exe flash system %ANDSYSIMG%
.\fastboot\fastboot.exe flash sutinfo %sutinfo%
.\fastboot\fastboot.exe flash sys_info %sys_info%
.\fastboot\fastboot.exe flash cache %CACHE%
.\fastboot\fastboot.exe flash userdata %USERDATA%
.\fastboot\fastboot.exe flash lk %lk%
.\fastboot\fastbootfih.exe erase FRP
.\fastboot\fastbootfih.exe erase box
.\fastboot\fastbootfih.exe -w
.\fastboot\fastboot.exe reboot-bootloader
echo.
echo ********* [Device Partition Flashed Successfully] *********

echo.
echo REBOOTING INTO DOWNLOAD MODE...
ping localhost -n 8 >nul
echo.

echo ********* [Device info Validation Started] *********
echo.
.\fastboot\fastbootfih.exe oem alive
.\fastboot\fastbootfih.exe oem getversions
.\fastboot\fastbootfih.exe oem CustomerSKUID get
.\fastboot\fastboot.exe reboot
echo.
echo ********* [Device Flashed Successfully] *********
del encUID.bin
echo.
pause
goto strt

:erase FRP
echo ********* Service Bootloader Authorisation *********
echo.
.\fastboot\fastbootfih.exe oem alive
.\fastboot\fastbootfih.exe oem getversions
.\fastboot\fastbootfih.exe getvar productid
.\fastboot\fastbootfih.exe oem getBootloaderType
echo.
echo ========================================================
.\fastboot\fastbootfih.exe oem getSecurityVersion
.\fastboot\fastbootfih.exe oem getProjectCode
.\fastboot\fastbootfih.exe oem dm-veracity
echo ========================================================
echo.
echo Please calculate the above given "Challenge Code" to validate the device into Service mode.
echo --------------------------------------------------------------------------------------------
echo.
set Signature=Default
set /p Signature=Enter the Signature Code: 
echo %Signature% > Signature.txt
dir /b > list.txt
findstr "Signature.txt" list.txt > tmp.txt
set /p Signature=<tmp.txt
certutil -decode %Signature% veracity.bin
del tmp.txt
del list.txt
del Signature.txt
echo.
dir /b > list.txt
findstr "veracity.bin" list.txt > tmp.txt
set /p veracity=<tmp.txt
.\fastboot\fastbootfih.exe flash veracity %veracity%
del tmp.txt
del list.txt
del veracity.bin
dir /b > list.txt
findstr "lk_service.img" list.txt > tmp.txt
set /p lk=<tmp.txt
.\fastboot\fastbootfih.exe flash lk %lk%
del tmp.txt
del list.txt
.\fastboot\fastboot.exe reboot-bootloader
echo.
echo ********* Authorisation Completed *********

echo.
echo REBOOTING INTO DOWNLOAD MODE...
ping localhost -n 8 >nul
.\fastboot\fastbootfih.exe oem getBootloaderType
echo.

echo ********* Device RootStatus Authorisation *********
echo.
.\fastboot\fastbootfih.exe oem alive
.\fastboot\fastbootfih.exe oem getversions
.\fastboot\fastbootfih.exe getvar productid
.\fastboot\fastbootfih.exe oem getRootStatus
echo.
echo ========================================================
.\fastboot\fastbootfih.exe oem getSecurityVersion
.\fastboot\fastbootfih.exe oem getProjectCode
.\fastboot\fastbootfih.exe oem getUID
echo ========================================================
echo.
echo Please calculate the above given "Challenge Code" to Enable the device RootStatus.
echo -----------------------------------------------------------------------------------
echo.
set Signature=Default
set /p Signature=Enter the Signature Code: 
echo %Signature% > Signature.txt
dir /b > list.txt
findstr "Signature.txt" list.txt > tmp.txt
set /p Signature=<tmp.txt
certutil -decode %Signature% encUID.bin
del tmp.txt
del list.txt
del Signature.txt
dir /b > list.txt
findstr "encUID.bin" list.txt > tmp.txt
set /p encUID=<tmp.txt
.\fastboot\fastbootfih.exe flash encUID %encUID%
.\fastboot\fastbootfih.exe oem selectKey service
.\fastboot\fastbootfih.exe oem doKeyVerify
del tmp.txt
del list.txt
del encUID.bin
echo.
echo ********* Authorisation Completed *********

echo.
echo Check Device RootStatus...
ping localhost -n 5 >nul
.\fastboot\fastbootfih.exe oem getRootStatus
echo.

echo ********* Erasing FRP & Wiping the data *********
echo.
.\fastboot\fastbootfih.exe erase frp
.\fastboot\fastbootfih.exe erase box
.\fastboot\fastbootfih.exe -w
echo.
echo ********* Erased Successfully *********
echo.
pause
cls
goto strt
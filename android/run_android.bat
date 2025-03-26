@echo off
setlocal enabledelayedexpansion

:: Colors for output
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "NC=[0m"

echo %GREEN%Starting Android app...%NC%

:: Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo %RED%Flutter is not installed. Please install Flutter first.%NC%
    exit /b 1
)

:: Check if Android Studio is installed
where adb >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo %RED%Android Debug Bridge (adb) is not installed. Please install Android Studio first.%NC%
    exit /b 1
)

:: Function to check if an emulator is running
:check_emulator
adb devices | findstr "emulator" >nul
if %ERRORLEVEL% EQU 0 (
    exit /b 0
) else (
    exit /b 1
)

:: Function to start an emulator
:start_emulator
echo %YELLOW%No emulator found. Starting a new emulator...%NC%

:: List available emulators
echo Available emulators:
flutter emulators

:: Start the first available emulator
for /f "tokens=1" %%a in ('flutter emulators ^| findstr /r "^[^ ]"') do (
    set "EMULATOR=%%a"
    goto :launch_emulator
)

:launch_emulator
if not defined EMULATOR (
    echo %RED%No emulators found. Please create an emulator first.%NC%
    exit /b 1
)

flutter emulators --launch %EMULATOR%

:: Wait for emulator to start
echo %YELLOW%Waiting for emulator to start...%NC%
:wait_loop
call :check_emulator
if %ERRORLEVEL% NEQ 0 (
    timeout /t 2 /nobreak >nul
    echo | set /p="."
    goto :wait_loop
)
echo.
echo %GREEN%Emulator is ready!%NC%
exit /b 0

:: Main script
call :check_emulator
if %ERRORLEVEL% NEQ 0 (
    call :start_emulator
)

:: Get the emulator device ID
for /f "tokens=1" %%a in ('adb devices ^| findstr "emulator"') do (
    set "DEVICE_ID=%%a"
)

if not defined DEVICE_ID (
    echo %RED%No emulator device found. Please start an emulator manually.%NC%
    exit /b 1
)

echo %GREEN%Running app on emulator: %DEVICE_ID%%NC%

:: Get dependencies
echo %YELLOW%Getting dependencies...%NC%
flutter pub get

:: Run the app with verbose logging
echo %GREEN%Starting the app with verbose logging...%NC%
cd ..
flutter run -d %DEVICE_ID% -v 
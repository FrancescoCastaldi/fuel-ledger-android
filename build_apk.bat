@echo off
setlocal enabledelayedexpansion

REM Keep aligned with versionName in app\build.gradle.kts
set "VERSION=0.2.0"

cd /d "%~dp0"
set "TOOLS=%~dp0..\..\Tool_e_Config\tools"
if not defined JAVA_HOME (
    if exist "%TOOLS%\jdk-21\jdk-21" set "JAVA_HOME=%TOOLS%\jdk-21\jdk-21"
)
if not defined ANDROID_HOME (
    if exist "%TOOLS%\android-sdk" set "ANDROID_HOME=%TOOLS%\android-sdk"
)
if defined JAVA_HOME set "PATH=%JAVA_HOME%\bin;%PATH%"

echo ========================================================
echo   FUEL LEDGER v%VERSION%: tests and release APK
echo ========================================================

echo [1/3] Running unit tests...
call gradlew.bat testDebugUnitTest --console=plain
if errorlevel 1 (
    echo [ERROR] Tests failed. Build stopped.
    exit /b 1
)

echo [2/3] Building release APK...
call gradlew.bat assembleRelease --console=plain
if errorlevel 1 (
    echo [ERROR] Build failed.
    exit /b 1
)

echo [3/3] Copying versioned APK...
copy /Y "app\build\outputs\apk\release\app-release.apk" "FuelLedger-v%VERSION%.apk" >nul
if errorlevel 1 exit /b 1

echo ========================================================
echo   Ready: FuelLedger-v%VERSION%.apk
echo ========================================================

@echo off
setlocal enabledelayedexpansion

REM Keep aligned with versionName in app\build.gradle.kts
set "VERSION=0.3.0"

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

REM The signing password lives in the workspace .env (D:\Actual\.env); without it, ask with hidden input.
set "WORKSPACE_ENV=%~dp0..\..\..\.env"
if exist "keystore.properties" if not defined FUEL_LEDGER_KEY_PASSWORD if exist "%WORKSPACE_ENV%" (
    for /f "usebackq tokens=1,* delims==" %%A in (`findstr /b /c:"FUEL_LEDGER_KEY_PASSWORD=" "%WORKSPACE_ENV%"`) do set "FUEL_LEDGER_KEY_PASSWORD=%%B"
)
if exist "keystore.properties" if not defined FUEL_LEDGER_KEY_PASSWORD (
    for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$s = Read-Host 'Signing key password' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($s))"`) do set "FUEL_LEDGER_KEY_PASSWORD=%%P"
)
if exist "keystore.properties" if not defined FUEL_LEDGER_KEY_PASSWORD (
    echo [ERROR] keystore.properties found but no signing password was entered.
    exit /b 1
)

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

echo [3/3] Copying versioned APK to dist...
if not exist "dist" mkdir "dist"
copy /Y "app\build\outputs\apk\release\app-release.apk" "dist\FuelLedger-v%VERSION%.apk" >nul
if errorlevel 1 exit /b 1

REM Only the latest APK is kept: the new one is in place, so older builds in dist\ are removed.
for %%F in ("dist\FuelLedger-v*.apk") do (
    if /i not "%%~nxF"=="FuelLedger-v%VERSION%.apk" (
        echo Removing old build %%~nxF
        del /q "%%F"
    )
)

echo ========================================================
echo   Ready: dist\FuelLedger-v%VERSION%.apk
echo ========================================================

@echo off
setlocal
REM Fuel Ledger release in one go: unit tests, signed APK in dist\, then a verification pass.
REM The console shows progress and the final RESULT; all the detail goes to build_apk.log.
REM   build_apk.bat            build and verify
REM   build_apk.bat verify     verify the APK already in dist\ (no build)
REM   add "nopause" to skip the final pause

REM Keep aligned with versionName in app\build.gradle.kts
set "VERSION=0.7.0"

set "NOPAUSE="
set "VERIFYONLY="
if /i "%~1"=="nopause" set "NOPAUSE=1"
if /i "%~2"=="nopause" set "NOPAUSE=1"
if /i "%~1"=="verify" set "VERIFYONLY=1"
if /i "%~2"=="verify" set "VERIFYONLY=1"

cd /d "%~dp0"
set "LOG=%~dp0build_apk.log"
set "RC=1"
set "TOOLS=%~dp0..\..\Tool_e_Config\tools"
if not defined JAVA_HOME (
    if exist "%TOOLS%\jdk-21\jdk-21" set "JAVA_HOME=%TOOLS%\jdk-21\jdk-21"
)
if not defined ANDROID_HOME (
    if exist "%TOOLS%\android-sdk" set "ANDROID_HOME=%TOOLS%\android-sdk"
)
if defined JAVA_HOME set "PATH=%JAVA_HOME%\bin;%PATH%"

echo ========================================================
echo   FUEL LEDGER v%VERSION%: build and verify
echo ========================================================
echo Fuel Ledger v%VERSION%: build and verify> "%LOG%"
echo Started %DATE% %TIME%>> "%LOG%"

if defined VERIFYONLY goto :verifyphase

REM Signing password: the ignored keystore.properties (storePassword), else the workspace vault .env, else a hidden prompt.
set "WORKSPACE_ENV=%~dp0..\..\..\.env"
if not exist "%WORKSPACE_ENV%" set "WORKSPACE_ENV=%~dp0..\..\..\00_Sicurezza_e_Credenziali\Vault_USB\.env"
if exist "keystore.properties" if not defined FUEL_LEDGER_KEY_PASSWORD (
    findstr /b /c:"storePassword=" "keystore.properties" >nul && set "FUEL_LEDGER_KEY_PASSWORD=from-keystore-properties"
)
if exist "keystore.properties" if not defined FUEL_LEDGER_KEY_PASSWORD if exist "%WORKSPACE_ENV%" (
    for /f "usebackq tokens=1,* delims==" %%A in (`findstr /b /c:"FUEL_LEDGER_KEY_PASSWORD=" "%WORKSPACE_ENV%"`) do set "FUEL_LEDGER_KEY_PASSWORD=%%B"
)
if exist "keystore.properties" if not defined FUEL_LEDGER_KEY_PASSWORD (
    for /f "usebackq delims=" %%P in (`powershell -NoProfile -Command "$s = Read-Host 'Signing key password' -AsSecureString; [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($s))"`) do set "FUEL_LEDGER_KEY_PASSWORD=%%P"
)
if exist "keystore.properties" if not defined FUEL_LEDGER_KEY_PASSWORD (
    echo RESULT: BUILD FAILED. keystore.properties found but no signing password.
    echo RESULT: BUILD FAILED, no signing password>> "%LOG%"
    goto :finish
)

echo [1/2] Unit tests and signed release APK. This takes a few minutes...
echo.>> "%LOG%"
echo ===== BUILD =====>> "%LOG%"
call :build >> "%LOG%" 2>&1
if errorlevel 1 (
    echo RESULT: BUILD FAILED. See build_apk.log
    echo RESULT: BUILD FAILED>> "%LOG%"
    goto :finish
)

:verifyphase
echo [2/2] Verifying the APK...
echo.>> "%LOG%"
echo ===== VERIFY =====>> "%LOG%"
set /a FAILED=0
call :verify >> "%LOG%" 2>&1
if %FAILED% GTR 0 (
    echo RESULT: VERIFY FAILED ^(%FAILED% checks^). See build_apk.log
    echo RESULT: VERIFY FAILED>> "%LOG%"
    goto :finish
)
echo RESULT: PASS. dist\FuelLedger-v%VERSION%.apk is ready.
echo RESULT: PASS>> "%LOG%"
set "RC=0"

:finish
echo Finished %DATE% %TIME%>> "%LOG%"
if not defined NOPAUSE pause
exit /b %RC%


REM ---------------------------------------------------------------------------
:build
echo Running unit tests...
call "%~dp0gradlew.bat" testDebugUnitTest --console=plain
if errorlevel 1 (
    echo [ERROR] Tests failed. Build stopped.
    exit /b 1
)

echo Building release APK...
call "%~dp0gradlew.bat" assembleRelease --console=plain
if errorlevel 1 (
    echo [ERROR] Build failed.
    exit /b 1
)

echo Copying versioned APK to dist...
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
exit /b 0


REM ---------------------------------------------------------------------------
REM One PASS/WARN/FAIL line per check; :fail counts them in FAILED.
:verify
set "BT="
for /d %%D in ("%ANDROID_HOME%\build-tools\*") do set "BT=%%~fD"
if defined BT if exist "%BT%\aapt.exe" if exist "%BT%\apksigner.bat" (call :pass "Android build-tools found (aapt, apksigner)") else (call :fail "aapt or apksigner missing in %BT%")
if not defined BT call :fail "Android build-tools not found in %ANDROID_HOME%"

REM Versions agree everywhere.
set "VNAME="
set "VCODE="
for /f "tokens=3 delims= " %%A in ('findstr /r /c:"^ *versionName = " app\build.gradle.kts') do set "VNAME=%%~A"
for /f "tokens=3 delims= " %%A in ('findstr /r /c:"^ *versionCode = " app\build.gradle.kts') do set "VCODE=%%~A"
echo [INFO] build.gradle.kts: versionName %VNAME%, versionCode %VCODE%
if "%VERSION%"=="%VNAME%" (call :pass "VERSION in build_apk.bat matches versionName") else (call :fail "VERSION in build_apk.bat is %VERSION%, versionName is %VNAME%")
findstr /c:"## [%VNAME%]" CHANGELOG.md >nul && (call :pass "CHANGELOG has a [%VNAME%] section") || (call :fail "CHANGELOG has no [%VNAME%] section")
if exist "docs\releases\v%VNAME%.md" (call :pass "docs\releases\v%VNAME%.md exists") else (call :fail "docs\releases\v%VNAME%.md is missing")

REM dist\ holds exactly the latest APK.
set "APKNAME=FuelLedger-v%VNAME%.apk"
set "APK=%~dp0dist\%APKNAME%"
set /a NAPK=0
for %%F in ("dist\*.apk") do set /a NAPK+=1
if exist "%APK%" (call :pass "dist\%APKNAME% exists") else (call :fail "dist\%APKNAME% is missing")
if %NAPK% EQU 1 (call :pass "dist\ holds only the latest APK") else (call :fail "dist\ holds %NAPK% APK files")
for %%F in ("*.apk") do echo [WARN] APK in the repository root: %%~nxF
if not exist "%APK%" goto :gitinfo

forfiles /p "dist" /m "%APKNAME%" /d +0 >nul 2>&1 && (call :pass "APK was built today") || (call :fail "APK was not built today")
set "SHA="
for /f "skip=1 tokens=*" %%H in ('certutil -hashfile "%APK%" SHA256') do if not defined SHA set "SHA=%%H"
echo [INFO] APK SHA-256 %SHA%
for %%F in ("%APK%") do echo [INFO] APK size %%~zF bytes

REM Manifest facts from aapt.
set "BADGING=%TEMP%\fuel-ledger-badging.txt"
"%BT%\aapt.exe" dump badging "%APK%" > "%BADGING%" 2>&1
findstr /c:"package: name='com.fcastaldi.fuelledger' versionCode='%VCODE%' versionName='%VNAME%'" "%BADGING%" >nul && (call :pass "APK package, versionCode and versionName match the sources") || (call :fail "APK package or version differs from the sources")
findstr /c:"uses-permission: name='android.permission.INTERNET'" "%BADGING%" >nul && (call :pass "INTERNET declared (update check)") || (call :fail "INTERNET is not declared")
findstr /c:"uses-permission: name='android.permission.CAMERA'" "%BADGING%" >nul && (call :pass "CAMERA declared (dashboard scan)") || (call :fail "CAMERA is not declared")
findstr /c:"ACCESS_NETWORK_STATE" "%BADGING%" >nul && (call :fail "ACCESS_NETWORK_STATE is declared") || (call :pass "ACCESS_NETWORK_STATE not declared")
findstr /c:"POST_NOTIFICATIONS" "%BADGING%" >nul && (call :pass "POST_NOTIFICATIONS declared (reminders)") || (call :fail "POST_NOTIFICATIONS is not declared")
findstr /r /c:"^locales:.* 'it'" "%BADGING%" >nul && (call :pass "Italian resources are packaged") || (call :fail "Italian resources are missing")
findstr /r /c:"^locales:.* 'de'" "%BADGING%" >nul && (call :fail "Library resources for other languages are packaged (resourceConfigurations)") || (call :pass "Only English and Italian resources are packaged")
findstr /c:"native-code: 'arm64-v8a'" "%BADGING%" >nul && (call :pass "ARM native code is present") || (call :fail "ARM native code is missing")

REM Signature: valid, and the certificate is the documented release key, not the debug key.
set "SIGNER=%TEMP%\fuel-ledger-signer.txt"
call "%BT%\apksigner.bat" verify --print-certs "%APK%" > "%SIGNER%" 2>&1
if errorlevel 1 (call :fail "APK signature does not verify") else (call :pass "APK signature verifies")
set "ACTUAL="
for /f "tokens=2 delims=:" %%A in ('findstr /c:"Signer #1 certificate SHA-256 digest" "%SIGNER%"') do set "ACTUAL=%%A"
set "ACTUAL=%ACTUAL: =%"
set "DOCUMENTED="
for /f "tokens=2 delims= " %%A in ('findstr /b /c:"SHA-256: " docs\install.md') do if not defined DOCUMENTED set "DOCUMENTED=%%A"
set "DOCUMENTED=%DOCUMENTED::=%"
if not defined ACTUAL (call :fail "No certificate digest in the apksigner output") else if /i "%DOCUMENTED%"=="%ACTUAL%" (call :pass "Signing certificate equals the fingerprint in docs\install.md") else (call :fail "Signing certificate %ACTUAL% differs from docs\install.md")

:gitinfo
set "TAGFOUND="
for /f %%T in ('git tag -l "v%VNAME%"') do set "TAGFOUND=%%T"
if defined TAGFOUND (echo [WARN] tag v%VNAME% already exists) else (echo [INFO] tag v%VNAME% is free)
for /f %%B in ('git rev-parse --abbrev-ref HEAD') do set "BRANCH=%%B"
for /f %%H in ('git rev-parse --short HEAD') do set "HEADSHA=%%H"
echo [INFO] branch %BRANCH%, HEAD %HEADSHA%
exit /b 0

:pass
echo [PASS] %~1
exit /b 0

:fail
echo [FAIL] %~1
set /a FAILED+=1
exit /b 0

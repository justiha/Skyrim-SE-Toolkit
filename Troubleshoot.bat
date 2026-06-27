@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

:: Define the spacer (exactly 60 spaces between the quotes)
set "SPACER=                                                            ."
set "CONFIG_FILE=skyrim_config.ini"

:: --- 1. SPLASH SCREEN / STARTUP CHECK ---
cls
echo ┌───────────────────────────────────────────────────────────────┐
echo  │ [PRO-MOD DIAGNOSTIC HUB]                                    │
echo  │ Initializing...                                             │
echo └───────────────────────────────────────────────────────────────┘
timeout /t 3 /nobreak >nul

if exist "Skyrim SE or AE toolkit v2.bat" (
    echo  [OK] Main Tool Found.
) else (
    echo  [❌] Toolkit can't be found or is not installed, please make sure Skyrim SE or AE toolkit.bat and  troubleshoot.bat is  together and not in seperate folders
    echo.
    echo  1. Download/Open Nexus Mods
    echo  2. Close Tool
    set /p start_choice="Select: "
    if "!start_choice!"=="1" (
        start "" "https://www.nexusmods.com/skyrimspecialedition/mods/183354?tab=files"
        exit
    ) else (exit)
)

:: --- 2. CONFIG VALIDATION (The "Gatekeeper") ---
if not exist "%CONFIG_FILE%" (
    echo.
    echo  [!] Configuration file missing. Please select option 2 to setup.
    timeout /t 3 /nobreak >nul
)

goto MAIN_MENU

:: --- MAIN MENU ---
:MAIN_MENU
call :LOAD_CONFIG
cls
:: --- SECTION: CONFIG CHECK ---
set "CFG_MSG=[❌] CRITICAL: config.ini NOT FOUND, type 2 to launch the main tool to Fix the Error"
set "CFG_COL=RED"
if exist "%CONFIG_FILE%" (
    set "CFG_MSG=[✅] Config Loaded"
    set "CFG_COL=GREEN"
)

:: --- SECTION: CONFIG CHECK ---
:: Only draw this box if something is wrong
if not exist "%CONFIG_FILE%" (
echo ┌───────────────────────────────────────────────────────────────┐
echo │ [Config File]                                                 │
:: Everything below prints on ONE line to keep the right border intact
<nul set /p "= │ Status: "
call :COLOR_TEXT "%CFG_MSG%" "%CFG_COL%"
echo.
echo └───────────────────────────────────────────────────────────────┘
)

:: --- SECTION: SKYRIM & SKSE ---
if exist "%CONFIG_FILE%" (
    :: 1. Pre-calculate statuses
    set "SKY_STATUS=[❌] SkyrimSE.exe NOT FOUND"
    set "SKY_COLOR=RED"
    set "SKSE_STATUS=[❌] SKSE_64.exe NOT FOUND"
    set "SKSE_COLOR=RED"
    
    set "SKY_FOUND=0"
    set "SKSE_FOUND=0"

    if exist "!SKYRIM_DIR!\SkyrimSE.exe" (
        set "SKY_STATUS=[OK] SkyrimSE.exe Found"
        set "SKY_COLOR=GREEN"
        set "SKY_FOUND=1"
    )

    if exist "!SKSE_PATH!" (
        set "SKSE_STATUS=[OK] SKSE_64.exe Found"
        set "SKSE_COLOR=GREEN"
        set "SKSE_FOUND=1"
    )

    :: 2. Draw the Box
    echo ┌────────────────────────────────────────────┐
    <nul set /p "= │ Status: "
    call :COLOR_TEXT "!SKY_STATUS!" "!SKY_COLOR!"
echo.

    :: 3. Conditional Connector Logic
    if "!SKY_FOUND!!SKSE_FOUND!"=="11" (
        echo │┌───────────────────────────────────────────┘
        echo │└──────────────────────────────────────┐
    ) else if "!SKY_FOUND!!SKSE_FOUND!"=="10" (
        echo │┌───────────────────────────────────────────┘
echo ││ SKSE missing. Optional for base game, required for advanced modding.
        echo │└──────────────────────────────────────┐
    ) else if "!SKY_FOUND!!SKSE_FOUND!"=="01" (
        echo │┌───────────────────────────────────────────┘
echo ││ SkyrimSE.exe missing. Required for SKSE. Verify/Repair via your launcher
        echo │└──────────────────────────────────────┐
    ) else (
        echo │┌───────────────────────────────────────────┘─────────────────────┐
echo ││ ERROR Detected type 1^>1 to fix game Directory or download game  │
        echo │└──────────────────────────────────────┐──────────────────────────┘
    )

    <nul set /p "= │ Status: "
    call :COLOR_TEXT "!SKSE_STATUS!" "!SKSE_COLOR!"
echo.
    echo └───────────────────────────────────────┘
)

:: --- SECTION: MOD MANAGER ---

if exist "%CONFIG_FILE%" (
echo ┌────────────────────────────────────────────────────────────────────────┐
    echo │ [Mod Manager]  !VORTEX_EXE!
    <nul set /p "= │ Status: "
    if exist "!VORTEX_EXE!" (
        call :COLOR_TEXT "[OK] Mod Manager Found" "GREEN"
    ) else (
        call :COLOR_TEXT "[❌] Mod Manager MISSING" "RED"
    )
    echo.
    echo └────────────────────────────────────────────────────────────────────────┘
	)

:: --- 1. PRE-CALCULATE LOGIC (Do this outside the box drawing) ---
set "STAGING_STATUS=[❌] Staging folder missing."
set "STAGING_COLOR=RED"
set "STAGING_MSG=Status: "

if exist "!VORTEX_DIR!" (
    for /f %%A in ('dir /b /a-d "!VORTEX_DIR!" 2^>nul ^| find /c /v ""') do set "filecount=%%A"
    for /f %%A in ('dir /b /ad "!VORTEX_DIR!" 2^>nul ^| find /c /v ""') do set "foldercount=%%A"
    set "STAGING_STATUS=[OK] !filecount! files and !foldercount! folders found."
    set "STAGING_COLOR=GREEN"
)

:: --- 2. DRAW BOX (This never changes and won't crash) ---
if exist "!VORTEX_DIR!" (
   echo ┌───────────────────────────────────────────────────────────────┐
   echo │ [Mod Staging]                                                 │
   echo │ Path: !VORTEX_DIR!                                 │
   <nul set /p "= │ Status: "
   call :COLOR_TEXT "%STAGING_STATUS%" "%STAGING_COLOR%"
   echo.                   │
   echo └───────────────────────────────────────────────────────────────┘
)
:: --- SECTION: DOCUMENTS ---
if exist "%CONFIG_FILE%" (
    :: 1. Pre-calculate the status
    set "DOCS_STATUS=[❌] Skyrim.ini MISSING"
    set "DOCS_COLOR=RED"

    if exist "!DOCS_BASE!\My Games\Skyrim Special Edition\Skyrim.ini" (
        if exist "!SAVE_DIR!" (
            set "DOCS_STATUS=[OK] INI Found and Saves Folder Found"
            set "DOCS_COLOR=GREEN"
        ) else (
            set "DOCS_STATUS=[OK] INI Found, but Saves Folder Missing [❌]"
            set "DOCS_COLOR=RED"
        )
    )

    :: 2. Draw the box
    echo ┌───────────────────────────────────────────────────────────────┐
    echo │ [Documents]                                                   │
    echo │ Path: !DOCS_BASE!                       │
    <nul set /p "= │ Status: "
    call :COLOR_TEXT "!DOCS_STATUS!" "!DOCS_COLOR!"
	echo                  │
    )
    echo └───────────────────────────────────────────────────────────────┘
	)

:: 3. Conditional Hint (Only if missing)
    if not exist "!DOCS_BASE!\My Games\Skyrim Special Edition" (
        echo │ [!] Hint: Try: C:\Users\USERNAME\OneDrive\Documents
		)

:: Closing bracket ensures NOTHING prints for this section if config is missing

echo =================================================================
call :COLOR_TEXT " 1. FIX_PATHS " "THEME"
echo.
call :COLOR_TEXT " 2. Launch Skyrim SE or AE toolkit " "THEME"
echo.
call :COLOR_TEXT " 3. Change theme (also effects Toolkit) " "THEME"
echo.
call :COLOR_TEXT " 4. About troubleshoot.bat " "THEME"
ECHO.
echo =================================================================
set /p choice="Select an option: "

if "%choice%"=="1" goto FIX_PATHS
if "%choice%"=="2" (
    echo.
    echo Launching Skyrim SE or AE toolkit...
    start "" "Skyrim SE or AE toolkit v2.bat"
    echo.
    echo This diagnostic window will close in 3 seconds...
    timeout /t 3 >nul
    exit
)
if "%choice%"=="3" goto CHANGE_THEME
if "%choice%"=="4" goto README
goto MAIN_MENU

:: --- 1. PATH FIXER (Option 2) ---
:FIX_PATHS
cls
echo =================================================================
call :COLOR_TEXT " PATH CONFIGURATION TOOL " "THEME"
echo.
echo =================================================================
call :COLOR_TEXT " 1. Fix Skyrim Directory" "THEME"
echo.
call :COLOR_TEXT " 2. Fix Mod Manager Executable" "THEME"
echo.
call :COLOR_TEXT " 3. Fix Staging Area Folder" "THEME"
echo.
call :COLOR_TEXT " 4. Fix Documents Area Folder" "THEME"
echo.
call :COLOR_TEXT " 5. Back to Main Menu" "THEME"
echo.
echo =================================================================
set /p pathfix="Select option: "

:: Use simple IF blocks to jump to a dedicated label
if "%pathfix%"=="1" goto GET_SKYRIM
if "%pathfix%"=="2" goto GET_VORTEX_EXE
if "%pathfix%"=="3" goto GET_VORTEX_DIR
if "%pathfix%"=="4" goto GET_DOCS
if "%pathfix%"=="5" goto MAIN_MENU
goto FIX_PATHS

:GET_SKYRIM
set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "%ps_cmd%"`) do set "SKYRIM_DIR=%%I"
goto WRITE_INI_DATABASE

:GET_VORTEX_EXE
set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Filter = 'Executable|*.exe'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.FileName }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "%ps_cmd%"`) do set "VORTEX_EXE=%%I"
goto WRITE_INI_DATABASE

:GET_VORTEX_DIR
set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "%ps_cmd%"`) do set "VORTEX_DIR=%%I"
goto WRITE_INI_DATABASE

:GET_DOCS
set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "%ps_cmd%"`) do set "DOCS_BASE=%%I"
goto WRITE_INI_DATABASE

:: --- Path Selection Subroutines ---
:GET_PATH_SKYRIM
:: 1. Force the path into a temp file
powershell -NoProfile -Command "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }" > "%temp%\path.tmp"

:: 2. Read the file into the variable
set /p SKYRIM_DIR=<"%temp%\path.tmp"
del "%temp%\path.tmp"

:: 3. Validation
if "%SKYRIM_DIR%"=="" goto FIX_PATHS
goto WRITE_INI_DATABASE

:GET_PATH_VORTEX_EXE
set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.OpenFileDialog; $f.Filter = 'Executable|*.exe'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.FileName }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "%ps_cmd%"`) do set "VORTEX_EXE=%%I"
goto WRITE_INI_DATABASE

:GET_PATH_VORTEX_DIR
set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "%ps_cmd%"`) do set "VORTEX_DIR=%%I"
goto WRITE_INI_DATABASE

:GET_PATH_DOCS
set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -Command "%ps_cmd%"`) do set "DOCS_BASE=%%I"
goto WRITE_INI_DATABASE

:CHANGE_THEME
cls
echo ==================================================
call :COLOR_TEXT "             THEME COLOR SELECTION" "THEME"
echo.
echo ==================================================
call :COLOR_TEXT " 1. Green    " "92"
call :COLOR_TEXT " 2. Red      " "91"
call :COLOR_TEXT " 3. White (preview is broken but works)  " "90"
call :COLOR_TEXT " 4. Yellow   " "93"
echo.
call :COLOR_TEXT " 5. Cyan     " "96"
call :COLOR_TEXT " 6. Blue     " "94"
call :COLOR_TEXT " 7. Magenta  " "95"
call :COLOR_TEXT " 8. Gray     " "90"
echo.
echo 9. Back to Main Menu
echo 10. More/Help
echo ==================================================
set /p theme_choice="Select: "

if "%theme_choice%"=="1" set "UI_COLOR=92"
if "%theme_choice%"=="2" set "UI_COLOR=91"
if "%theme_choice%"=="3" set "UI_COLOR=97"
if "%theme_choice%"=="4" set "UI_COLOR=93"
if "%theme_choice%"=="5" set "UI_COLOR=96"
if "%theme_choice%"=="6" set "UI_COLOR=94"
if "%theme_choice%"=="7" set "UI_COLOR=95"
if "%theme_choice%"=="8" set "UI_COLOR=90"
if "%theme_choice%"=="9" goto MAIN_MENU
if "%theme_choice%"=="10" (
    echo.
    echo These are the Bright ANSI codes.
    echo 90-97 are the standard colors used for 
    echo high-contrast terminal themes.
    pause
    goto CHANGE_THEME
)

:: Now save the NUMBER to the config
(
echo SKYRIM_DIR=%SKYRIM_DIR%
echo SKSE_PATH=%SKSE_PATH%
echo VORTEX_DIR=%VORTEX_DIR%
echo VORTEX_EXE=%VORTEX_EXE%
echo DOCS_BASE=%DOCS_BASE%
echo SAVE_DIR=%SAVE_DIR%
echo UI_COLOR=%UI_COLOR%
) > "%CONFIG_FILE%"
goto MAIN_MENU



echo.

echo Paths updated and database re-compiled!

timeout /t 2 >nul

)

goto FIX_PATHS   

:README
cls
echo =================================================================
call :COLOR_TEXT " ABOUT PRO-MOD DIAGNOSTIC HUB " "THEME"
echo.
echo =================================================================
echo  Version: 1.0.0
echo  Purpose: Automates path detection for Skyrim SE/AE modding.
echo.
echo  How to use:
echo  - If a status is [❌], use '1. FIX_PATHS' to point the tool 
echo    to the correct folder.
echo  - The tool persists settings in skyrim_config.ini.
echo =================================================================
pause
goto MAIN_MENU

:LOAD_CONFIG
:: Set defaults first
set "UI_COLOR=92"
:: Override with config file if it exists
if exist "%CONFIG_FILE%" (
    for /f "usebackq tokens=1* delims==" %%A in ("%CONFIG_FILE%") do (
        set "%%A=%%B"
    )
)
goto :eof



:: --- COLOR HELPER ---

:: Usage: call :COLOR_TEXT "Status: [!!] ERROR" "RED"

:COLOR_TEXT
:: If THEME, it uses the variable !UI_COLOR! from your skyrim_config.ini
if "%~2"=="THEME"   <nul set /p "=[!UI_COLOR!m%~1[0m"

:: Standard/Previously defined
if "%~2"=="RED"     <nul set /p "=[91m%~1[0m"
if "%~2"=="GREEN"   <nul set /p "=[92m%~1[0m"
if "%~2"=="WHITE"   <nul set /p "=[97m%~1[0m"
if "%~2"=="93"      <nul set /p "=[93m%~1[0m"
if "%~2"=="95"      <nul set /p "=[95m%~1[0m"
if "%~2"=="96"      <nul set /p "=[96m%~1[0m"

:: Newly added Bright ANSI codes
if "%~2"=="90"      <nul set /p "=[90m%~1[0m"  :: Gray
if "%~2"=="91"      <nul set /p "=[91m%~1[0m"  :: Bright Red
if "%~2"=="92"      <nul set /p "=[92m%~1[0m"  :: Bright Green
if "%~2"=="94"      <nul set /p "=[94m%~1[0m"  :: Bright Blue
goto :eof

:WRITE_INI_DATABASE
:: Strip quotes (This is safe to run even if already stripped)
set "SKYRIM_DIR=%SKYRIM_DIR:"=%"
set "VORTEX_DIR=%VORTEX_DIR:"=%"
set "VORTEX_EXE=%VORTEX_EXE:"=%"
set "DOCS_BASE=%DOCS_BASE:"=%"

:: Auto-calculate pathways
set "SKSE_PATH=%SKYRIM_DIR%\skse64_loader.exe"
set "SAVE_DIR=%DOCS_BASE%\My Games\Skyrim Special Edition\Saves"

:: Default UI_COLOR if it hasn't been set yet
if "%UI_COLOR%"=="" set "UI_COLOR=97"

:: Compile everything
(
    echo SKYRIM_DIR=%SKYRIM_DIR%
    echo SKSE_PATH=%SKSE_PATH%
    echo VORTEX_DIR=%VORTEX_DIR%
    echo VORTEX_EXE=%VORTEX_EXE%
    echo DOCS_BASE=%DOCS_BASE%
    echo SAVE_DIR=%SAVE_DIR%
    echo UI_COLOR=%UI_COLOR%
) > "%CONFIG_FILE%"
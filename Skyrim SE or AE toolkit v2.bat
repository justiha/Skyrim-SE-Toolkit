@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: =================================================================
:: INITIALIZATION & ENVIRONMENT SETUP
:: =================================================================

:: Get the current year for archiving tools
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set "Yeardate=%datetime:~0,4%"

:: Load configuration
set "CONFIG_FILE=%~dp0skyrim_config.ini"

:INIT_CHECK
if not exist "%CONFIG_FILE%" goto SETUP_CHANGE_THEME
for /f "usebackq delims=" %%I in ("%CONFIG_FILE%") do set "%%I"

:: Add this default if the user hasn't set a theme yet
if "%UI_COLOR%"=="" set "UI_COLOR=92"

:: Validate required paths
if "%SKYRIM_DIR%"=="" goto RUN_SETUP_ROUTINE
if "%SKSE_PATH%"=="" goto RUN_SETUP_ROUTINE
if "%VORTEX_EXE%"=="" goto RUN_SETUP_ROUTINE
if "%VORTEX_DIR%"=="" goto RUN_SETUP_ROUTINE

:MAIN_MENU
:: =================================================================
:: MAIN MENU CRASH LOG AUTO-DETECTOR
:: =================================================================
set "NEW_LOG_FOUND=FALSE"

:: Define standard crash log locations using your config's DOCS_BASE
set "SKSE_LOG_DIR=%DOCS_BASE%\My Games\Skyrim Special Edition\SKSE"
set "NETSCRIPT_LOG_DIR=%DOCS_BASE%\My Games\Skyrim Special Edition\NetScriptFramework\Crash"

:: Check SKSE CrashLogger files modified today
if exist "%SKSE_LOG_DIR%\crash-*.log" (
    forfiles /p "%SKSE_LOG_DIR%" /m "crash-*.log" /d +0 >nul 2>&1 && set "NEW_LOG_FOUND=TRUE"
)

:: Check NetScriptFramework files modified today
if exist "%NETSCRIPT_LOG_DIR%\crash-*.txt" (
    forfiles /p "%NETSCRIPT_LOG_DIR%" /m "crash-*.txt" /d +0 >nul 2>&1 && set "NEW_LOG_FOUND=TRUE"
)

cls
echo =================================================================
call :COLOR_TEXT "             SKYRIM SE/AE CONTROL CENTER ENGINE v2.0" "THEME"
echo.
echo =================================================================
:: Using THEME for the headers to make them pop
call :COLOR_TEXT "   [Skyrim Dir]    " "THEME"
echo %SKYRIM_DIR%
call :COLOR_TEXT "   [Mod Staging]   " "THEME"
echo %VORTEX_DIR%
call :COLOR_TEXT "   [Documents]     " "THEME"
echo %DOCS_BASE%
echo =================================================================

if "!NEW_LOG_FOUND!"=="TRUE" (
    echo  [⚠️ NOTICE] A new crash log was detected from today!
    echo              Type L to analyze it directly.
    echo =================================================================
) 
:: <--- MAKE SURE THIS CLOSING PARENTHESIS IS HERE!

:: Now start your menu items
call :COLOR_TEXT "   [1] 🌐 WEB:       Open Nexus Mods Skyrim SE Hub" "THEME"
echo.
echo.
call :COLOR_TEXT "   [2] 🛠️  UTILITY:  Launch Mod Manager (Background)" "THEME"
echo.
echo      Note: Initialization logs from the manager may appear briefly.
echo.
call :COLOR_TEXT "   [3] 📂 EXPLORER: Directory Hub & Crash Log Analyzer" "THEME"
echo.
echo.
call :COLOR_TEXT "   [4] 🚀 LAUNCH:    Boot Game (SKSE Loader / Vanilla Game EXE)" "THEME"
echo.
echo.
call :COLOR_TEXT "   [5] 📋 INVENTORY: Scan Active Data Plugins (.esp/.esm/.esl)" "THEME"
echo.
echo.
call :COLOR_TEXT "   [6] 🩺 DIAGNOSTIC: Pro-Mod Plugin and Health Analysis" "THEME"
echo.
echo.
call :COLOR_TEXT "   [7] 🔄 RESETUP:   Wipe INI Profile and Rerun Setup Wizard" "THEME"
echo.
echo.
call :COLOR_TEXT "   [8] 🎨 Visual Configuration: Customize Font Color"  "THEME"
echo.
echo.
call :COLOR_TEXT "   [9] 🛠️ About My New Troubleshooting Program"  "THEME"
echo.
echo.
call :COLOR_TEXT "   [X] ❌ EXIT:      Terminate Engine Safely" "THEME"
echo.
echo.
echo =================================================================
echo.
set "main_choice="
set /p main_choice="Select execution routine (1-7, X): "

if "%main_choice%"=="1" goto HUB_NEXUS
if "%main_choice%"=="2" goto HUB_VORTEX
if "%main_choice%"=="3" goto SUB_MENU_EXPLORER
if "%main_choice%"=="4" goto SUB_MENU_LAUNCH
if "%main_choice%"=="5" goto SCAN_LOAD_ORDER
if "%main_choice%"=="6" goto ANALYZE_MOD_SIZE
if "%main_choice%"=="7" (del /q "%CONFIG_FILE%" 2>nul & goto RUN_SETUP_ROUTINE)
if "%main_choice%"=="8" goto CHANGE_THEME
if "%main_choice%"=="9" goto Troubleshoot
if "%main_choice%"=="l" goto ANALYZE_LATEST_CRASH
if /i "%main_choice%"=="X" exit
goto MAIN_MENU

:: ===================================================
:: [1] HUB: OPEN NEXUS MODS (CMD STAYS OPEN)
:: ===================================================
:HUB_NEXUS
cls
echo Starting browser context thread for Nexus Mods...
start "" "https://www.nexusmods.com/skyrimspecialedition"
timeout /t 3 > nul
goto MAIN_MENU

:: ===================================================
:: [2] HUB: LAUNCH VORTEX (CMD STAYS OPEN)
:: ===================================================
:HUB_VORTEX
cls
echo Starting Mod Manager...
echo.
echo [INFO] Initializing handshake with external process...
echo [INFO] Note: Any initialization logs appearing below are 
echo        generated by the manager, not the Control Center.
echo.
:: Using the redirect to keep it cleaner, but this covers you if it still leaks
start "" "%VORTEX_EXE%" >nul 2>&1
echo Manager launched successfully. Returning to menu...
timeout /t 5 >nul
goto MAIN_MENU

:: ===================================================
:: [3] SUB-MENU: DIRECTORY HUB
:: ===================================================
:SUB_MENU_EXPLORER
cls
echo =================================================================
call :COLOR_TEXT "                     [3] Directory HUB & CRASH LOG ANALYZER" "THEME"
echo.
echo =================================================================
call :COLOR_TEXT "    [1] 📂 DIR: Open Root Skyrim Common Installation Folder (File Explorer)" "THEME"
echo.
echo.
call :COLOR_TEXT "    [2] 📦 DIR: Open Vortex Mod Staging Folder (File Explorer)" "THEME"
echo.
echo.
call :COLOR_TEXT "    [3] 📄 DIR: Open SKSE Crash Log Dump Directory (File Explorer)" "THEME"
echo.
echo.
call :COLOR_TEXT "    [4] 🔍 SCAN: Analyze Latest Crash Log (CMD)" "THEME"
echo.
echo.
call :COLOR_TEXT "    [B] ❌ BACK: Return to Main Menu" "THEME"
echo.
echo.
echo =================================================================
echo.
set "exp_choice="
set /p exp_choice="Select hub pipeline: "

if "%exp_choice%"=="1" (explorer "%SKYRIM_DIR%" & goto SUB_MENU_EXPLORER)
if "%exp_choice%"=="2" (explorer "%VORTEX_DIR%" & goto SUB_MENU_EXPLORER)
if "%exp_choice%"=="3" (explorer "%DOCS_BASE%\My Games\Skyrim Special Edition\SKSE" & goto SUB_MENU_EXPLORER)
if "%exp_choice%"=="4" goto ANALYZE_LATEST_CRASH
if /i "%exp_choice%"=="B" goto MAIN_MENU
goto SUB_MENU_EXPLORER

:: ===================================================
:: AUTOMATED SKSE CRASH LOG INTELLIGENCE SCANNER
:: ===================================================
:ANALYZE_LATEST_CRASH
cls
echo =================================================================
call :COLOR_TEXT "      🔍SKSE LAUNCHER LOG ^& CRASH ANALYZER - SELECT FILE" "THEME"
echo.
echo =================================================================
set "LOG_DIR=%DOCS_BASE%\My Games\Skyrim Special Edition\SKSE"

:: 1. List the newest 10 log/txt files with numbers
echo  Select a log file to analyze (1-10):
echo.
set "count=0"
pushd "%LOG_DIR%"
for /f "tokens=*" %%F in ('dir /b /o-d *.log *.txt 2^>nul') do (
    set /a count+=1
    set "FILE_!count!=%%F"
    echo   [!count!] %%F
    if !count! GEQ 10 goto :LIST_DONE
)
:LIST_DONE
popd

if %count%==0 (
    echo  [NOTICE] No logs found.
    pause & goto SUB_MENU_EXPLORER
)

:: 2. Get user input
echo.
set /p "choice=Enter selection [1-%count%] or [B] to back: "
if /i "%choice%"=="B" goto SUB_MENU_EXPLORER
if not defined FILE_%choice% goto ANALYZE_LATEST_CRASH

set "LATEST_LOG=!FILE_%choice%!"

:: 3. Perform the analysis on the selected file
cls
echo  Analyzing: %LATEST_LOG%
echo -----------------------------------------------------------------
call :COLOR_TEXT "      =================== CRASH SIGNATURE ANALYSIS ===================" "THEME"
set "found_lines=0"
for /f "tokens=*" %%L in ('findstr /i /c:"EXCEPTION_ACCESS_VIOLATION" /c:"Module" /c:".dll" /c:".esp" /c:".esm" "%LOG_DIR%\%LATEST_LOG%" 2^>nul') do (
    echo   -^> %%L
    set /a found_lines+=1
)
echo.
echo -----------------------------------------------------------------
echo  [DIAGNOSTIC HINT]
if %found_lines% GTR 0 (
    echo  If you see "Module: [Name].dll" above, that is your primary suspect.
) else (
    echo  [!] No obvious crash markers found. Showing top 15 lines:
    echo.
    powershell -NoProfile -Command "Get-Content '%LOG_DIR%\%LATEST_LOG%' -TotalCount 15"
)
echo =================================================================
pause
goto ANALYZE_LATEST_CRASH

:: ===================================================
:: [4] SUB-MENU: GAME LAUNCH PIPELINE
:: ===================================================
:SUB_MENU_LAUNCH
cls
echo =================================================================
call :COLOR_TEXT "   🚀 GAME LAUNCH PIPELINE" "THEME"
echo.
echo =================================================================
echo.
call :COLOR_TEXT "   [1] 🧪 SKSE:   Launch via SKSE Loader (Recommended for modded games)" "THEME"
echo.
echo.
call :COLOR_TEXT "   [2] 🛡️ STOCK: Launch via Vanilla Game EXE (Safe for unmodded play)" "THEME"
echo.
echo.
call :COLOR_TEXT "   [B] ❌ BACK:   Return to Main Menu" "THEME"
echo.
echo =================================================================
echo.
set "launch_choice="
set /p launch_choice="Select execution system: "

if "%launch_choice%"=="1" goto LAUNCH_SKSE
if "%launch_choice%"=="2" goto LAUNCH_VANILLA
if /i "%launch_choice%"=="B" goto MAIN_MENU
goto SUB_MENU_LAUNCH

:LAUNCH_SKSE
cls
echo Initializing SKSE execution sequence...
if exist "%SKSE_PATH%" (
    start "" "%SKSE_PATH%"
    timeout /t 3 > nul
    exit
) else (
    echo [ERROR] skse64_loader.exe execution vector failed. Check paths.
    pause
)
goto SUB_MENU_LAUNCH

:LAUNCH_VANILLA
cls
echo Initializing Vanilla engine bypass launch...
if exist "%SKYRIM_DIR%\SkyrimSE.exe" (
    start "" "%SKYRIM_DIR%\SkyrimSE.exe"
    timeout /t 3 > nul
    exit
) else (
    echo [ERROR] SkyrimSE.exe target execution target missed.
    pause
)
goto SUB_MENU_LAUNCH

:: =================================================================
:: [5] PLUGINS MATRIX SCANNER (V. 1.3 - AUTO-SCALE SIZE AUDIT)
:: =================================================================
:SCAN_LOAD_ORDER
cls
echo =================================================================
call :COLOR_TEXT "            📋 ACTIVE PLUGINS MANIFEST & ARCHIVE SCANNER" "THEME"
echo.
echo =================================================================
call :COLOR_TEXT " [TARGET PATH] %SKYRIM_DIR%\Data" "WHITE"
echo.
echo =================================================================
echo.
set esm_count=0
set esp_count=0
set esl_count=0

:: --- MASTER ARCHIVES ---
call :COLOR_TEXT " ┌──────────────────────────────────────────────────────────────┐" "THEME"
echo.
call :COLOR_TEXT " │ [CORE MASTER ARCHIVES]                                       │" "THEME"
echo.
call :COLOR_TEXT " └──────────────────────────────────────────────────────────────┘" "THEME"
echo.
pushd "%SKYRIM_DIR%\Data"
for /f "delims=" %%F in ('dir /b *.esm 2^>nul') do (
    set /a esm_count+=1
    set "bytes=%%~zF"
    set /a "size=bytes/1024"
    if !bytes! GEQ 1048576 (set /a "size=bytes/1048576" & set "unit=MB") else (set "unit=KB")
    <nul set /p "=   ├── "
    call :COLOR_TEXT "[ESM]" "96"
    <nul set /p "= [!size! !unit!] "
    call :COLOR_TEXT "%%F" "WHITE"
    echo.
)
if !esm_count!==0 echo    └── (No master files detected)

:: --- ESL PLUGINS ---
echo.
call :COLOR_TEXT " ┌──────────────────────────────────────────────────────────────┐" "THEME"
echo.
call :COLOR_TEXT " │ [LIGHT ES-LIGHT PLUGINS]                                     │" "THEME"
echo.
call :COLOR_TEXT " └──────────────────────────────────────────────────────────────┘" "THEME"
echo.
for /f "delims=" %%F in ('dir /b *.esl 2^>nul') do (
    set /a esl_count+=1
    set "bytes=%%~zF"
    set /a "size=bytes/1024"
    if !bytes! GEQ 1048576 (set /a "size=bytes/1048576" & set "unit=MB") else (set "unit=KB")
    <nul set /p "=   ├── "
    call :COLOR_TEXT "[ESL]" "95"
    <nul set /p "= [!size! !unit!] "
    call :COLOR_TEXT "%%F" "WHITE"
    echo.
)
if !esl_count!==0 echo    └── (No light patches detected)

:: --- ESP PLUGINS ---
echo.
call :COLOR_TEXT " ┌──────────────────────────────────────────────────────────────┐" "THEME"
echo.
call :COLOR_TEXT " │ [STANDARD MODIFICATION PLUGINS]                              │" "THEME"
echo.
call :COLOR_TEXT " └──────────────────────────────────────────────────────────────┘" "THEME"
echo.
for /f "delims=" %%F in ('dir /b *.esp 2^>nul') do (
    set /a esp_count+=1
    set "bytes=%%~zF"
    set /a "size=bytes/1024"
    if !bytes! GEQ 1048576 (set /a "size=bytes/1048576" & set "unit=MB") else (set "unit=KB")
    <nul set /p "=   ├── "
    call :COLOR_TEXT "[ESP]" "93"
    <nul set /p "= [!size! !unit!] "
    call :COLOR_TEXT "%%F" "WHITE"
    echo.
)
if !esp_count!==0 echo    └── (No standard plugins detected)
popd
echo.
cls
echo =================================================================
call :COLOR_TEXT "                     LOAD ORDER STATISTICS" "THEME"
echo.
echo =================================================================
echo.
<nul set /p "=   [+] Total Master Files (.esm):    "
call :COLOR_TEXT "!esm_count!" "96"
echo.
<nul set /p "=   [+] Total Light Plugins (.esl):   "
call :COLOR_TEXT "!esl_count!" "95"
echo.
<nul set /p "=   [+] Total Standard Plugins (.esp): "
call :COLOR_TEXT "!esp_count!" "93"
echo.
echo -----------------------------------------------------------------
set /a total_plugins=esm_count+esp_count+esl_count
<nul set /p "=   [=] TOTAL ACTIVE PLUGINS COUNTER:  "
call :COLOR_TEXT "!total_plugins!" "WHITE"
echo.
echo =================================================================
echo.
pause
goto MAIN_MENU

:: =================================================================
:: [6] DIAGNOSTIC: CUSTOM MOD ARCHIVE ^& CORES SCANNER
:: =================================================================
:ANALYZE_MOD_SIZE
cls
echo ==========================================================
call :COLOR_TEXT "             🩺 PRO-MOD DIAGNOSTIC HUB" "THEME"
echo.
echo ==========================================================
echo.
call :COLOR_TEXT "    [1] 📊 OVERVIEW: Core File Counts & Heavy BSA Scan" "THEME"
echo.
echo.
call :COLOR_TEXT "    [2] 🛡️  AUDITOR:  Creation Club & Master Checks" "THEME"
echo.
echo.
call :COLOR_TEXT "    [3] 💾 SYSTEM:   Dirty Plugins & Save File Health" "THEME"
echo.
echo.
call :COLOR_TEXT "    [4] 📅 SCAN:     Recent Plugin Modifications (Last 30 Days)" "THEME"
echo.
echo.
call :COLOR_TEXT "    [5] 🗄️  TOOL:     Archive Old Save Games (Keep 50)" "THEME"
echo.
echo.
call :COLOR_TEXT "    [6] 🔍 AUDITOR: PLUGIN INTEGRITY & CORRUPTION SCAN" "THEME"
echo.
echo.
call :COLOR_TEXT "    [B] ❌ EXIT:     Return to Main Menu" "THEME"
echo.
echo ==========================================================
set /p "CHOICE=Select diagnostic routine: "

if "%CHOICE%"=="1" goto SCAN_1
if "%CHOICE%"=="2" goto SCAN_2
if "%CHOICE%"=="3" goto SCAN_3
if "%CHOICE%"=="4" goto SCAN_4
if "%CHOICE%"=="5" goto SCAN_5
if "%CHOICE%"=="6" goto SCAN_6
if /i "%CHOICE%"=="b" goto MAIN_MENU
goto ANALYZE_MOD_SIZE

:SCAN_1
cls
:: Define your theme color for PowerShell (e.g., 92=Green, 96=Cyan, 93=Yellow)
:: We'll use a map to keep it simple.
powershell -NoProfile -Command ^
    "$color = 'Cyan'; " ^
    "Write-Host '==========================================================' -ForegroundColor $color;" ^
    "Write-Host '            CUSTOM MOD ARCHIVE & CORES SCANNER' -ForegroundColor $color;" ^
    "Write-Host '==========================================================' -ForegroundColor $color;" ^
    "$allFiles = Get-ChildItem '%SKYRIM_DIR%\Data' -File -ErrorAction SilentlyContinue;" ^
    "Write-Host '----------------------------------------------------------';" ^
    "Write-Host '==================== PHYSICAL FILE COUNTS ====================';" ^
    "Write-Host ' [+] Raw Master Files (.esm):      ' $esms;" ^
    "Write-Host ' [+] Raw Light Files (.esl):       ' $esls;" ^
    "Write-Host ' [+] Raw Standard Files (.esp):    ' $esps;" ^
    "Write-Host '----------------------------------------------------------';" ^
    "Write-Host '==================== HEAVIEST CUSTOM MODS ====================';" ^
    "if ($topBSAs) { foreach ($i in 0..($topBSAs.Count-1)) { Write-Host \"    [$($i+1)] $($topBSAs[$i].Name) ($([math]::round($topBSAs[$i].Length/1MB, 2)) MB)\"; } } else { Write-Host ' No custom BSA files found.' }" ^
    "Write-Host '=========================================================='"
echo.
set /p "CHECK_DISK=If you'd like to view disk space/engine limits press Y (otherwise press Enter): "
if /i "%CHECK_DISK%"=="Y" goto DISK_MATH
goto :ANALYZE_MOD_SIZE

:DISK_MATH
:: Get the drive letter from the SKYRIM_DIR path (which is G:\...)
:: This grabs the first letter of the string (G)
set "DRIVE_LETTER=%SKYRIM_DIR:~0,1%"

powershell -NoProfile -Command ^
    "$modSize = [math]::round((Get-ChildItem '%VORTEX_DIR%' -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB, 2);" ^
    "$drive = Get-Volume -DriveLetter '%DRIVE_LETTER%' -ErrorAction SilentlyContinue;" ^
    "if ($drive) {" ^
    "  $driveFree = [math]::round($drive.SizeRemaining / 1GB, 2);" ^
    "  $driveTotal = [math]::round($drive.Size / 1GB, 2);" ^
    "  $freePercent = if ($driveTotal -gt 0) { [math]::round(($driveFree / $driveTotal) * 100, 1) } else { 0 };" ^
    "  Write-Host '=================================================================';" ^
    "  Write-Host '            DIAGNOSTIC: ENGINE LIMITS & STORAGE HEALTH';" ^
    "  Write-Host '=================================================================';" ^
    "  Write-Host \"  Vortex Mod Directory Size : $modSize GB\";" ^
    "  Write-Host \"  Drive Free Space on %DRIVE_LETTER%: : $driveFree GB / $driveTotal GB ($freePercent%% Free)\";" ^
    "} else {" ^
    "  Write-Host ' [!] Could not retrieve volume info for drive %DRIVE_LETTER%:' -ForegroundColor Red;" ^
    "}" ^
    "Write-Host '======================= ENGINE LIMITS ========================';" ^
    "Write-Host '  Heavy Plugins (ESP/ESM)   : 319 / 254';" ^
    "Write-Host '  Light Plugins (ESL)       : 14 / 4096';" ^
    "Write-Host '==============================================================';" ^
    "if (319 -gt 254) { Write-Host ' [⚠️ WARNING] Approaching ESP/ESM Hard Limit.' -ForegroundColor Yellow; }"
pause
goto :ANALYZE_MOD_SIZE

:SCAN_2
cls
echo ==========================================================
call :COLOR_TEXT "            🛡️ AUDITOR: CREATION CLUB CHECK" "THEME"
echo.
echo ==========================================================
powershell -NoProfile -Command ^
    "$ccFiles = Get-ChildItem '%SKYRIM_DIR:"=%' -Filter 'cc*.esp' -Recurse;" ^
    "if ($ccFiles.Count -gt 0) { Write-Host ' [+] Found' $ccFiles.Count 'Creation Club plugin files.' -ForegroundColor Cyan; " ^
    "$ccFiles | Select-Object -First 10 | ForEach-Object { Write-Host '    -' $_.Name }; } " ^
    "else { Write-Host ' [!] No specific Creation Club plugins detected.'; }"
echo ----------------------------------------------------------
pause
goto :ANALYZE_MOD_SIZE

:SCAN_3
cls
echo ==========================================================
call :COLOR_TEXT "         💾 SYSTEM: DIRTY PLUGINS & SAVE FILE HEALTH" "THEME"
echo.
echo ==========================================================
:: Safety Gate
if "%SAVE_DIR%"=="" (
    echo [!] ERROR: SAVE_DIR is not defined in your config.
    pause
    goto :ANALYZE_MOD_SIZE
)

:: Running command
powershell -NoProfile -Command " & { $d = Get-ChildItem '%DATA_DIR%' -Filter *.esp | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }; $s = if(Test-Path '%SAVE_DIR%') { Get-ChildItem '%SAVE_DIR%' -Filter *.ess } else { @() }; Write-Host ' [+] Modified Plugins (Last 24h):' $d.Count; Write-Host ' [+] Total Save Files in Profile:' $s.Count; if($s.Count -gt 1000) { Write-Host ' [!] High save count detected' -ForegroundColor Yellow } }"
echo ----------------------------------------------------------
pause
goto :ANALYZE_MOD_SIZE
)

:: If safe, run the command
powershell -NoProfile -Command " & { $d = Get-ChildItem '%DATA_DIR%' -Filter *.esp | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) }; $s = if(Test-Path '%SAVE_DIR%') { Get-ChildItem '%SAVE_DIR%' -Filter *.ess } else { @() }; Write-Host ' [+] Modified Plugins (Last 24h):' $d.Count; Write-Host ' [+] Total Save Files in Profile:' $s.Count; if($s.Count -gt 1000) { Write-Host ' [!] High save count detected' -ForegroundColor Yellow } }"
echo ----------------------------------------------------------
pause
goto :ANALYZE_MOD_SIZE

:SCAN_4
cls
echo ==========================================================
call :COLOR_TEXT "         📅 SCAN: RECENT PLUGIN MODIFICATIONS" "THEME"
echo.
echo ==========================================================
powershell -NoProfile -Command "& { $found = Get-ChildItem '%DATA_DIR%' -Filter *.esp | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-30) }; if ($found.Count -eq 0) { Write-Host ' No plugins modified in the last 30 days. Load order is stable.' -ForegroundColor Green } else { $found | ForEach-Object { Write-Host ' [!] Found: ' $_.Name ' (Modified:' $_.LastWriteTime ')' -ForegroundColor Yellow } } }"
echo ----------------------------------------------------------
pause
goto :ANALYZE_MOD_SIZE

:SCAN_5
cls
echo ==========================================================
call :COLOR_TEXT "             🗄️ TOOL: ARCHIVE OLD SAVE GAMES (%Yeardate%)" "THEME"
echo.
echo ==========================================================
if not exist "%SAVE_DIR%\Archive_%Yeardate%" mkdir "%SAVE_DIR%\Archive_%Yeardate%"

powershell -NoProfile -Command "& { $saves = Get-ChildItem '%SAVE_DIR%' -Filter *.ess; Write-Host 'Total saves found:' $saves.Count; if ($saves.Count -gt 50) { Write-Host 'Archiving oldest saves...' -ForegroundColor Cyan; $sorted = $saves | Sort-Object LastWriteTime; $toArchive = $sorted[0..($sorted.Count-51)]; foreach ($s in $toArchive) { Move-Item -Path $s.FullName -Destination '%SAVE_DIR%\Archive_%Yeardate%' }; Write-Host 'Successfully moved' $toArchive.Count 'saves.' -ForegroundColor Green } else { Write-Host 'Save count is' $saves.Count '. Nothing to archive.' -ForegroundColor Yellow } }"
echo ----------------------------------------------------------
pause
goto :ANALYZE_MOD_SIZE

:SCAN_6
cls
echo ==========================================================
call :COLOR_TEXT "      🔍 AUDITOR: PLUGIN INTEGRITY ^& CORRUPTION SCAN" "THEME"
echo.
echo ==========================================================
echo  STATUS: Physical file health.
echo  ACTION: If a plugin is flagged RED, redownload/reinstall 
echo          the mod in your Mod Manager.
echo ==========================================================
echo ==========================================================
:: We list files to ensure the directory is readable and healthy
powershell -NoProfile -Command ^
    "$plugins = Get-ChildItem '%DATA_DIR%' -Filter *.esp;" ^
    "foreach ($p in $plugins) {" ^
    "    if ($p.Length -lt 100) {" ^
    "        Write-Host ' [!] SUSPICIOUSLY SMALL PLUGIN:' $p.Name -ForegroundColor Red;" ^
    "    } else {" ^
    "        Write-Host ' [OK] Plugin verified:' $p.Name -ForegroundColor Green;" ^
    "    }" ^
    "}"
echo ----------------------------------------------------------
echo  Scan complete.
echo  [!] If a plugin is marked RED, it is missing or corrupted.
echo      ACTION: Redownload/Reinstall the mod in Vortex.
echo  [?] If you still have issues, check Vortex for 
echo      "Missing Master" dependency errors.
echo ----------------------------------------------------------
pause
goto :ANALYZE_MOD_SIZE

:SETUP_CHANGE_THEME
cls
echo ==================================================
call :COLOR_TEXT "             THEME COLOR SELECTION" "THEME"
echo.
echo ==================================================
call :COLOR_TEXT " 1. Green    " "92"
call :COLOR_TEXT " 2. Red      " "91"
call :COLOR_TEXT "  3. Standard White, Preview is broken but works " "90"
call :COLOR_TEXT " 4. Yellow   " "93"
echo.
call :COLOR_TEXT " 5. Cyan     " "96"
call :COLOR_TEXT " 6. Blue     " "94"
call :COLOR_TEXT " 7. Magenta  " "95"
call :COLOR_TEXT " 8. Gray     " "90"
echo.
echo.
call :COLOR_TEXT " 9. More/Help      " "91"
echo.
echo.
echo.
echo ==================================================
set /p theme_choice="Select: "

:: Mapping Logic
if "%theme_choice%"=="1" set "UI_COLOR=92" goto RUN_SETUP_ROUTINE
if "%theme_choice%"=="2" set "UI_COLOR=91" goto RUN_SETUP_ROUTINE
if "%theme_choice%"=="3" set "UI_COLOR=97" goto RUN_SETUP_ROUTINE
if "%theme_choice%"=="4" set "UI_COLOR=93" goto RUN_SETUP_ROUTINE
if "%theme_choice%"=="5" set "UI_COLOR=96" goto RUN_SETUP_ROUTINE
if "%theme_choice%"=="6" set "UI_COLOR=94" goto RUN_SETUP_ROUTINE
if "%theme_choice%"=="7" set "UI_COLOR=95" goto RUN_SETUP_ROUTINE
if "%theme_choice%"=="8" set "UI_COLOR=90" goto RUN_SETUP_ROUTINE
if "%theme_choice%"=="9" (
    echo.1. Green, 2. Red, 3. White, 4. Yellow  
    echo.5. Cyan, 6. Blue, 7. Magenta, 8. Gray.
    echo.
    echo.
    pause
    goto CHANGE_THEME
)
if "%theme_choice%"=="S" set "UI_COLOR=97" goto RUN_SETUP_ROUTINE

:RUN_SETUP_ROUTINE
cls
echo =================================================================
call :COLOR_TEXT "      ⚙️  SKYRIM CONTROL CENTER: INITIAL SETUP WIZARD" "THEME"
echo.
echo =================================================================
echo.
call :COLOR_TEXT "    [1] ⌨️  Standard CMD Mode: (Copy/Paste paths)" "THEME"
echo.
echo.
call :COLOR_TEXT "    [2] 🖥️  Interactive Mode:  (File Explorer Selection)" "THEME"
echo.
echo =================================================================
set "mode_choice="
set /p "mode_choice=Select configuration entry mode (1-2): "

if "%mode_choice%"=="1" goto ROUTINE_CMD_MODE
if "%mode_choice%"=="2" goto ROUTINE_POWERSHELL_MODE
goto RUN_SETUP_ROUTINE

:: -----------------------------------------------------------------
:: CMD PATH COLLECTION
:: -----------------------------------------------------------------
:ROUTINE_CMD_MODE
set "MODE=CMD"
cls
echo =================================================================
call :COLOR_TEXT "      ⚙️  SKYRIM CONTROL CENTER: PATH CONFIGURATION" "THEME"
echo.
echo =================================================================
call :COLOR_TEXT " Example: C:\SteamLibrary\steamapps\common\Skyrim Special Edition" "WHITE"
echo.
echo -----------------------------------------------------------------
set /p "SKYRIM_DIR=1. Paste your main Skyrim SE Root Installation folder: "

:: Advice: Always validate path input immediately
if not exist "!SKYRIM_DIR!\SkyrimSE.exe" (
    call :COLOR_TEXT " [!] ERROR: Could not locate SkyrimSE.exe in that directory." "RED"
    echo.
    pause
    goto ROUTINE_CMD_MODE
)
goto MOD_MANAGER_HUB

:: -----------------------------------------------------------------
:: POWERSHELL PATH COLLECTION
:: -----------------------------------------------------------------
:ROUTINE_POWERSHELL_MODE
set "MODE=PS"
cls
echo =================================================================
call :COLOR_TEXT "      ⚙️  SKYRIM CONTROL CENTER: PATH SELECTION" "THEME"
echo.
echo =================================================================
call :COLOR_TEXT " ➡️ Opening Folder Browser for Skyrim Root..." "THEME"
echo.
echo =================================================================

set "ps_cmd=Add-Type -AssemblyName System.Windows.Forms; $f = New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select your Skyrim Special Edition Root Folder'; if($f.ShowDialog() -eq 'OK') { Write-Output $f.SelectedPath }"
for /f "usebackq delims=" %%I in (`powershell -NoProfile -STA -ExecutionPolicy Bypass -Command "%ps_cmd%" 2^>nul`) do set "SKYRIM_DIR=%%I"

:: Path validation check
if "%SKYRIM_DIR%"=="" (
    call :COLOR_TEXT " [!] Selection cancelled or no folder chosen." "RED"
    echo.
    timeout /t 2 >nul
    goto RUN_SETUP_ROUTINE
)

:: Validate that it is the correct folder
if not exist "!SKYRIM_DIR!\SkyrimSE.exe" (
    call :COLOR_TEXT " [!] ERROR: SkyrimSE.exe not found in that folder!" "RED"
    echo.
    set "SKYRIM_DIR="
    pause
    goto ROUTINE_POWERSHELL_MODE
)

goto MOD_MANAGER_HUB

:MOD_MANAGER_HUB
cls
echo =================================================================
call :COLOR_TEXT "             📦 MOD ORGANIZER HUB" "THEME"
echo.
echo =================================================================
:: Using your new mapping: Vortex (93/Yellow), MO2 (96/Cyan), Wabbajack (95/Magenta)
call :COLOR_TEXT " [1] Vortex" "93"
echo           [D1] Download: https://www.nexusmods.com/site/mods/1
call :COLOR_TEXT " [2] Mod Organizer 2" "96"
echo [D2] Download: https://www.nexusmods.com/skyrimspecialedition/mods/6194
call :COLOR_TEXT " [3] Wabbajack" "95"
echo           [D3] Download: https://www.wabbajack.org/
echo.
call :COLOR_TEXT " [S] Skip All (No Manager)" "THEME"
echo.
echo =================================================================
set /p "MO_CHOICE=Select (1-3) or (D1-D3) to download: "

:: 1. Handle Downloads
if /i "%MO_CHOICE%"=="D1" start "" "https://www.nexusmods.com/site/mods/1" & goto MOD_MANAGER_HUB
if /i "%MO_CHOICE%"=="D2" start "" "https://www.nexusmods.com/skyrimspecialedition/mods/6194" & goto MOD_MANAGER_HUB
if /i "%MO_CHOICE%"=="D3" start "" "https://www.wabbajack.org/" & goto MOD_MANAGER_HUB

:: 2. Handle Skip
if /i "%MO_CHOICE%"=="S" (
    set "VORTEX_DIR=NONE"
    set "VORTEX_EXE=NONE"
    goto DOCS_PROFILE_SELECTOR
)

:: 3. Define Labels
if "%MO_CHOICE%"=="1" set "LABEL=Staging Folder"
if "%MO_CHOICE%"=="2" set "LABEL=Mods/Instance Folder"
if "%MO_CHOICE%"=="3" set "LABEL=Install/Base Folder"

if "%LABEL%"=="" goto MOD_MANAGER_HUB

:: 4. Path Collection (Themed)
if "%MODE%"=="CMD" (
    echo.
    call :COLOR_TEXT " --------------------------------------------------------------" "THEME"
    echo.
    set /p "VORTEX_DIR=Paste your %LABEL% path: "
    call :COLOR_TEXT " --------------------------------------------------------------" "THEME"
echo.  
  set /p "VORTEX_EXE=Paste full path to main .exe (or just paste the folder): "
) else (
    echo.
    call :COLOR_TEXT " ➡️ Selecting %LABEL%..." "THEME"
    echo.
    for /f "usebackq delims=" %%I in (`powershell -NoProfile -STA -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.FolderBrowserDialog; $f.Description = 'Select %LABEL%'; if($f.ShowDialog() -eq 'OK'){Write-Output $f.SelectedPath}"`) do set "VORTEX_DIR=%%I"
    
    call :COLOR_TEXT " ➡️ Locating .exe executable..." "THEME"
    echo.
    for /f "usebackq delims=" %%I in (`powershell -NoProfile -STA -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; $f=New-Object System.Windows.Forms.OpenFileDialog; $f.Title = 'Locate main .exe'; if($f.ShowDialog() -eq 'OK'){Write-Output $f.FileName}"`) do set "VORTEX_EXE=%%I"
)

:: 5. Auto-Append Executable
if not "!VORTEX_EXE!"=="" (
    set "EXE_CHECK=!VORTEX_EXE:~-4!"
    if /i not "!EXE_CHECK!"==".exe" (
        if "!VORTEX_EXE:~-1!"=="\" set "VORTEX_EXE=!VORTEX_EXE:~0,-1!"
        if "%MO_CHOICE%"=="1" set "VORTEX_EXE=!VORTEX_EXE!\vortex.exe"
        if "%MO_CHOICE%"=="2" set "VORTEX_EXE=!VORTEX_EXE!\ModOrganizer.exe"
        if "%MO_CHOICE%"=="3" set "VORTEX_EXE=!VORTEX_EXE!\Wabbajack.exe"
    )
)

goto DOCS_PROFILE_SELECTOR

:: -----------------------------------------------------------------
:: PROFILE SELECTION: VISUAL CHECK VIA WINDOWS EXPLORER
:: -----------------------------------------------------------------
:DOCS_PROFILE_SELECTOR
cls
echo =================================================================
call :COLOR_TEXT "        CRITICAL: LOCATING YOUR SKYRIM USER PROFILE" "THEME"
echo.
echo =================================================================
echo.
echo    WHY ARE YOU SEEING THIS SCREEN?
echo    Skyrim relies heavily on your Windows 'Documents' folder to load
echo    your game saves, initialization files (Skyrim.ini), and your 
echo    SKSE plugin crash logs. 
echo.
echo    Modern Windows (10 or 11) often silently relocates this folder into OneDrive.
echo    If this toolkit points to the wrong location, your Explorer Hub
echo    won't be able to find your crash logs or ini files.
echo.
echo    Let's check where your 'My Games' folder actually lives:
echo -----------------------------------------------------------------
call :COLOR_TEXT "    [1] 📂 Open Local Documents    (%USERPROFILE%\Documents)" "96"
echo.
call :COLOR_TEXT "    [2] ☁️ Open OneDrive Documents (%USERPROFILE%\OneDrive\Documents)" "95"
echo.
echo -----------------------------------------------------------------
echo    💡 Know your path already? Skip the Search and lock it in directly:
echo    [U] Fast-Lock to Local User Profile
echo    [O] Fast-Lock to OneDrive Profile
echo    [S] Skip Diagnostics (Dashboard Only)
echo -----------------------------------------------------------------
set "check_choice="
set /p "check_choice=Select menu option or command: "

:: Instant Fast-Bypass logic mapping
if /i "%check_choice%"=="U" set "DOCS_BASE=%USERPROFILE%\Documents" & goto WRITE_INI_DATABASE
if /i "%check_choice%"=="O" set "DOCS_BASE=%USERPROFILE%\OneDrive\Documents" & goto WRITE_INI_DATABASE
if /i "%check_choice%"=="S" set "DOCS_BASE=Not Available" & goto WRITE_INI_DATABASE

:: Standard Visual Scout mapping
if "%check_choice%"=="1" (
    echo Opening Local Documents window...
    explorer "%USERPROFILE%\Documents"
    goto CONFIRM_DOCS_PATH
)
if "%check_choice%"=="2" (
    echo Opening OneDrive Documents window...
    explorer "%USERPROFILE%\OneDrive\Documents"
    goto CONFIRM_DOCS_PATH
)
goto DOCS_PROFILE_SELECTOR

:CONFIRM_DOCS_PATH
cls
echo =================================================================
call :COLOR_TEXT "                 LOCK IN YOUR SELECTION" "THEME"
echo.
echo =================================================================
echo    Based on the Windows Explorer window you just looked at, 
echo    where did you successfully find your 'My Games' folder?
echo.
call :COLOR_TEXT "    [U] Locked to USER PROFILE (Local)" "96"
echo.
call :COLOR_TEXT "    [O] Locked to ONEDRIVE     (Cloud)" "95"
echo.
echo =================================================================
echo.
set "confirm_choice="
set /p "confirm_choice=Type your choice (U or O): "

if /i "%confirm_choice%"=="U" (
    set "DOCS_BASE=%USERPROFILE%\Documents"
    goto WRITE_INI_DATABASE
)
if /i "%confirm_choice%"=="O" (
    set "DOCS_BASE=%USERPROFILE%\OneDrive\Documents"
    goto WRITE_INI_DATABASE
)
goto CONFIRM_DOCS_PATH

:: =================================================================
:: SANITIZE VARIABLES & COMPILE TO .INI CONFIGURATION MATRIX
:: =================================================================
:WRITE_INI_DATABASE
cls
:: Strip quotes
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

echo =================================================================
echo                INI ENVIRONMENT DATABASE COMPILED
echo =================================================================
echo  Data successfully saved including SAVE_DIR.
timeout /t 2 > nul
goto INIT_CHECK

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
echo M. More/Help
echo B. Back to Main Menu
echo ==================================================
set /p theme_choice="Select: "

:: Mapping Logic
if "%theme_choice%"=="1" set "UI_COLOR=92"
if "%theme_choice%"=="2" set "UI_COLOR=91"
if "%theme_choice%"=="3" set "UI_COLOR=97"
if "%theme_choice%"=="4" set "UI_COLOR=93"
if "%theme_choice%"=="5" set "UI_COLOR=96"
if "%theme_choice%"=="6" set "UI_COLOR=94"
if "%theme_choice%"=="7" set "UI_COLOR=95"
if "%theme_choice%"=="8" set "UI_COLOR=90"

if "%theme_choice%"=="M" (
    echo.1. Green, 2. Red, 3. White, 4. Yellow  
    echo.5. Cyan, 6. Blue, 7. Magenta, 8. Gray.
    echo.
    echo.
    pause
    goto CHANGE_THEME
)

if "%theme_choice%"=="b" goto MAIN_MENU



:: Save and Exit
call :WRITE_INI_DATABASE
echo.
call :COLOR_TEXT " [+] Theme updated and database re-compiled!" "GREEN"
timeout /t 2 >nul
goto CHANGE_THEME

:TROUBLESHOOT
cls
call :COLOR_TEXT "   ======================================================= "  "THEME"
echo.
call :COLOR_TEXT "   ARE YOU TRYING TO RUN YOUR GAME BUT IT WON'T LAUNCH, OR MAYBE JUST "  "THEME"
echo. 
call :COLOR_TEXT "   WANT TO CHEEK IF EVERYTHING IS SET UP CORRECTLY? "  "THEME"
echo.
call :COLOR_TEXT "   THIS IS A NEW TOOL THAT WILL HELP FIX ISSUES THAT WON'T RUN. "  "THEME"
echo.
call :COLOR_TEXT "   ======================================================= "  "THEME"
echo.
echo.
echo [1] Launch Troubleshoot Tool
echo [B] Back to Main Menu
set /p "ts_choice=Selection: "

if "%ts_choice%"=="1" goto MAIN_MENU_2
if "%ts_choice%"=="b" goto MAIN_MENU

:: If they typed something else, loop back
goto TROUBLESHOOT

:MAIN_MENU_2
call :LOAD_CONFIG
cls
:: --- SECTION: CONFIG CHECK ---
set "CFG_MSG=[❌] CRITICAL: config.ini NOT FOUND, type 2 to launch the main tool to Fix the Error"
set "CFG_COL=RED"
if exist "%CONFIG_FILE%" (
    set "CFG_MSG=[✅] Config Loaded"
    set "CFG_COL=GREEN"
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

    if exist "%SKYRIM_DIR%\SkyrimSE.exe" (
        set "SKY_STATUS=[OK] SkyrimSE.exe Found"
        set "SKY_COLOR=GREEN"
        set "SKY_FOUND=1"
    )

    if exist "%SKSE_PATH%" (
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
echo ││ ERROR Detected type 1^>1 to fix game Directory or redownload game  │
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
call :COLOR_TEXT " Refresh " "THEME"
echo.
call :COLOR_TEXT " 3. Back to toolkit " "THEME"
echo.
call :COLOR_TEXT " 4. About troubleshoot.bat " "THEME"
ECHO.
echo =================================================================
set /p choice="Select an option: "

if "%choice%"=="1" goto FIX_PATHS
if "%choice%"=="2" goto MAIN_MENU_2
if "%choice%"=="3" goto MAIN_MENU
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
call :COLOR_TEXT " B. Back to Main Menu" "THEME"
echo.
echo =================================================================
set /p pathfix="Select option: "

:: Use simple IF blocks to jump to a dedicated label
if "%pathfix%"=="1" goto GET_SKYRIM
if "%pathfix%"=="2" goto GET_VORTEX_EXE
if "%pathfix%"=="3" goto GET_VORTEX_DIR
if "%pathfix%"=="4" goto GET_DOCS
if "%pathfix%"=="b" goto MAIN_MENU_2
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
goto MAIN_MENU_2

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
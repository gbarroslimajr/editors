@echo off
setlocal enabledelayedexpansion

rem Define o título da janela
title Void Portable

rem Obtém o diretório do script e define o diretório base
cd /d "%~dp0"
set "BASE_DIR=%cd%"
set "APP_DIR=%BASE_DIR%\{code_GetDestDir}"
set "CERTS_DIR=C:\install\devkit-master\certs"

rem Verifica se o diretório de certificados existe
if exist "%CERTS_DIR%" (
    rem Define variáveis para certificados
    set "NODE_EXTRA_CA_CERTS=%CERTS_DIR%"
    set "SSL_CERT_DIR=%CERTS_DIR%"
    set "SSL_CERT_FILE=%CERTS_DIR%\root.cer"
    set "REQUESTS_CA_BUNDLE=%CERTS_DIR%"
    set "NODE_TLS_REJECT_UNAUTHORIZED=0"
)

rem Verifica se estamos no diretório correto com o Void.exe
if not exist "%APP_DIR%\Void.exe" (
    echo Erro: Void.exe nao encontrado em %APP_DIR%
    echo Este script deve estar na pasta raiz do Void (mesmo nivel que a pasta {code_GetDestDir})
    pause
    exit /b 1
)

rem Cria um arquivo para indicar modo portátil
if not exist "%BASE_DIR%\portable-mode" (
    type nul > "%BASE_DIR%\portable-mode"
)

rem Define estrutura de pastas para dados portáteis
set "PORTABLE_DIR=%BASE_DIR%\VoidData"
set "ELECTRON_USER_DATA_DIR=%PORTABLE_DIR%\user-data"
set "VOID_PORTABLE_DATA=%PORTABLE_DIR%\data"
set "VSCODE_PORTABLE=%PORTABLE_DIR%"
set "VSCODE_EXTENSIONS=%PORTABLE_DIR%\extensions"
set "VSCODE_LOGS=%PORTABLE_DIR%\logs"
set "VSCODE_APPDATA=%PORTABLE_DIR%\appdata"
set "VSCODE_CRASH_REPORTER_DIRECTORY=%PORTABLE_DIR%\crashes"
set "ELECTRON_CACHE=%PORTABLE_DIR%\cache"
set "PORTABLE_TEMP=%PORTABLE_DIR%\temp"
if not exist "%PORTABLE_TEMP%" mkdir "%PORTABLE_TEMP%"
set "TMP=%PORTABLE_TEMP%"
set "TEMP=%PORTABLE_TEMP%"

rem Cria as pastas necessárias se não existirem
if not exist "%PORTABLE_DIR%" mkdir "%PORTABLE_DIR%"
if not exist "%ELECTRON_USER_DATA_DIR%" mkdir "%ELECTRON_USER_DATA_DIR%"
if not exist "%VOID_PORTABLE_DATA%" mkdir "%VOID_PORTABLE_DATA%"
if not exist "%VSCODE_EXTENSIONS%" mkdir "%VSCODE_EXTENSIONS%"
if not exist "%VSCODE_LOGS%" mkdir "%VSCODE_LOGS%"
if not exist "%VSCODE_APPDATA%" mkdir "%VSCODE_APPDATA%"
if not exist "%VSCODE_CRASH_REPORTER_DIRECTORY%" mkdir "%VSCODE_CRASH_REPORTER_DIRECTORY%"
if not exist "%ELECTRON_CACHE%" mkdir "%ELECTRON_CACHE%"

rem Verifica se é Windows 11 64-bit
wmic os get Caption /value | find "Windows 11" >nul
if %ERRORLEVEL% NEQ 0 (
    echo Aviso: Este aplicativo foi otimizado para Windows 11
    echo Seu sistema pode ter compatibilidade limitada
    timeout /t 5
)

rem Define variáveis de ambiente para modo portátil
set ELECTRON_NO_ATTACH_CONSOLE=1
set ELECTRON_ENABLE_LOGGING=1
set ELECTRON_NO_ASAR=1
set VOID_PORTABLE=1
set VSCODE_CLI=1
set VSCODE_DEV=
set NODE_ENV=production
set VOID_DISABLE_TELEMETRY=1
set VOID_DISABLE_UPDATES=1
set VSCODE_SKIP_PRELAUNCH=1
set VSCODE_PIPE_LOGGING=true
set VSCODE_VERBOSE_LOGGING=true
set VSCODE_SHELL_LOGIN=1

rem Configurações de segurança e certificados
set ELECTRON_DEFAULT_ERROR_MODE=1
set ELECTRON_FORCE_IS_PACKAGED=true
set ELECTRON_SKIP_BINARY_DOWNLOAD=1
set NODE_SKIP_PLATFORM_CHECK=1
set ELECTRON_CUSTOM_DIR="%APP_DIR%"
set ELECTRON_OVERRIDE_DIST_PATH="%APP_DIR%"

rem Configurações específicas para 64-bit
set "PATH=%APP_DIR%\bin;%APP_DIR%;%CERTS_DIR%;%PATH%"

rem Define configurações de NLS
set "VSCODE_NLS_CONFIG={\"locale\":\"pt-br\",\"osLocale\":\"pt-br\",\"availableLanguages\":{}}"

rem Cria arquivo de configuração argv.json se não existir
if not exist "%PORTABLE_DIR%\argv.json" (
    echo { "portable": "%PORTABLE_DIR%" } > "%PORTABLE_DIR%\argv.json"
)

rem Cria e configura o settings.json se não existir
set "SETTINGS_DIR=%ELECTRON_USER_DATA_DIR%\User"
set "SETTINGS_FILE=%SETTINGS_DIR%\settings.json"

if not exist "%SETTINGS_DIR%" mkdir "%SETTINGS_DIR%"

if not exist "%SETTINGS_FILE%" (
    echo {> "%SETTINGS_FILE%"
    echo   "window.titleBarStyle": "custom",>> "%SETTINGS_FILE%"
    echo   "security.workspace.trust.enabled": false,>> "%SETTINGS_FILE%"
    echo   "telemetry.telemetryLevel": "off",>> "%SETTINGS_FILE%"
    echo   "update.mode": "none",>> "%SETTINGS_FILE%"
    echo   "extensions.autoUpdate": false,>> "%SETTINGS_FILE%"
    echo   "workbench.enableExperiments": false,>> "%SETTINGS_FILE%"
    echo   "workbench.settings.enableNaturalLanguageSearch": false,>> "%SETTINGS_FILE%"
    echo   "remote.downloadExtensionsLocally": true,>> "%SETTINGS_FILE%"
    echo   "remote.restoreForwardedPorts": true,>> "%SETTINGS_FILE%"
    echo   "remote.autoForwardPorts": true,>> "%SETTINGS_FILE%"
    echo   "terminal.integrated.persistentSessionScrollback": 1000,>> "%SETTINGS_FILE%"
    echo   "terminal.integrated.enablePersistentSessions": true,>> "%SETTINGS_FILE%"
    echo   "files.hotExit": "onExitAndWindowClose",>> "%SETTINGS_FILE%"
    echo   "files.restoreUndoStack": true,>> "%SETTINGS_FILE%"
    echo   "workbench.localHistory.enabled": true,>> "%SETTINGS_FILE%"
    echo   "workbench.localHistory.maxFileSize": 1024,>> "%SETTINGS_FILE%"
    echo   "workbench.localHistory.maxFileEntries": 50,>> "%SETTINGS_FILE%"
    echo   "window.restoreWindows": "preserve",>> "%SETTINGS_FILE%"
    echo   "window.newWindowDimensions": "inherit">> "%SETTINGS_FILE%"
    echo }>> "%SETTINGS_FILE%"
)

rem Inicia o aplicativo com argumentos otimizados para Windows 11
cd /d "%APP_DIR%"
start "" "Void.exe" ^
    --no-sandbox ^
    --disable-gpu-sandbox ^
    --disable-telemetry ^
    --disable-updates ^
    --ignore-certificate-errors ^
    --allow-insecure-localhost ^
    --disable-workspace-trust ^
    --disable-dev-shm-usage ^
    --no-proxy-server ^
    --extensions-dir="%VSCODE_EXTENSIONS%" ^
    --user-data-dir="%ELECTRON_USER_DATA_DIR%" ^
    --crash-reporter-directory="%VSCODE_CRASH_REPORTER_DIRECTORY%" ^
    --enable-hardware-acceleration ^
    --high-dpi-support=1 ^
    --force-device-scale-factor=1

rem Espera um momento para garantir que o app iniciou
timeout /t 2 >nul

echo Void iniciado com sucesso em %DATE% às %TIME% >> "%PORTABLE_DIR%\void.log"

exit /b 0

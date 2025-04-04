@echo off

rem === CONFIG INICIAL ===
set "SCRIPT_VERSION=1.0.2"

for /f "tokens=2 delims==." %%I in ('"wmic os get localdatetime /value"') do set "RUNTIME_DATE=%%I"
set "RUNTIME_DATE=%RUNTIME_DATE:~6,2%/%RUNTIME_DATE:~4,2%/%RUNTIME_DATE:~0,4% %RUNTIME_DATE:~8,2%:%RUNTIME_DATE:~10,2%:%RUNTIME_DATE:~12,2%"

title Void Portable v%SCRIPT_VERSION%

echo ========================================
echo         VOID PORTABLE LAUNCHER
echo ----------------------------------------
echo Versao do Script : v%SCRIPT_VERSION%
echo Data de Execucao : %RUNTIME_DATE%
echo ========================================
echo.

echo [INFO] Iniciando Void em modo portable...
echo.

rem === Diretórios principais ===
cd /d "%~dp0"
set "BASE_DIR=%cd%"
set "APP_DIR=%BASE_DIR%\code_getdestdir"
set "CERTS_DIR=C:\install\devkit-master\certs"

echo [INFO] Diretorio base: %BASE_DIR%
echo [INFO] Diretorio do aplicativo: %APP_DIR%
echo.

rem === Certificados ===
echo [INFO] Verificando certificados...
if exist "%CERTS_DIR%" (
    echo [OK] Certificados encontrados em %CERTS_DIR%
    set "NODE_EXTRA_CA_CERTS=%CERTS_DIR%"
    set "SSL_CERT_DIR=%CERTS_DIR%"
    set "SSL_CERT_FILE=%CERTS_DIR%\root.cer"
    set "REQUESTS_CA_BUNDLE=%CERTS_DIR%"
    set "NODE_TLS_REJECT_UNAUTHORIZED=0"
) else (
    echo [AVISO] Diretorio de certificados nao encontrado
)
echo.

rem === Verificar executável Void.exe ===
set "VOID_EXE=%APP_DIR%\Void.exe"
echo [INFO] Verificando executavel do Void...
echo [DEBUG] Tentando acessar: "%VOID_EXE%"

if exist "%VOID_EXE%" (
    echo [OK] Void.exe encontrado em %APP_DIR%
    echo [DEBUG] Prosseguindo com a inicializacao...
) else (
    echo [ERRO] Void.exe NAO encontrado no caminho informado!
    pause
    exit /b 1
)
echo.

rem === Marcar modo portátil ===
if not exist "%BASE_DIR%\portable-mode" (
    type nul > "%BASE_DIR%\portable-mode"
    echo [OK] Arquivo portable-mode criado
) else (
    echo [OK] Modo portable ja configurado
)
echo.

rem === Estrutura de dados portátil ===
set "PORTABLE_DIR=%BASE_DIR%\VoidData"
set "ELECTRON_USER_DATA_DIR=%PORTABLE_DIR%\user-data"
set "VSCODE_EXTENSIONS=%PORTABLE_DIR%\extensions"
set "VSCODE_LOGS=%PORTABLE_DIR%\logs"
set "VSCODE_APPDATA=%PORTABLE_DIR%\appdata"
set "VSCODE_CRASH_REPORTER_DIRECTORY=%PORTABLE_DIR%\crashes"
set "ELECTRON_CACHE=%PORTABLE_DIR%\cache"
set "PORTABLE_TEMP=%PORTABLE_DIR%\temp"

echo [INFO] Criando estrutura de diretorios...
for %%D in ("%PORTABLE_DIR%" "%ELECTRON_USER_DATA_DIR%" "%VSCODE_EXTENSIONS%" "%VSCODE_LOGS%" "%VSCODE_APPDATA%" "%VSCODE_CRASH_REPORTER_DIRECTORY%" "%ELECTRON_CACHE%" "%PORTABLE_TEMP%") do (
    if not exist %%D (
        mkdir %%D
        echo [OK] Criado: %%~nxD
    )
)
set "TMP=%PORTABLE_TEMP%"
set "TEMP=%PORTABLE_TEMP%"
echo.

rem === Compatibilidade do sistema ===
echo [INFO] Verificando compatibilidade do sistema...
wmic os get Caption /value | find "Windows 11" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] Este aplicativo foi otimizado para Windows 11
    timeout /t 3
) else (
    echo [OK] Sistema Windows 11 detectado
)
echo.

rem === Variáveis de ambiente ===
echo [INFO] Configurando variaveis de ambiente...
set ELECTRON_NO_ATTACH_CONSOLE=1
set ELECTRON_ENABLE_LOGGING=1
set ELECTRON_NO_ASAR=1
set VOID_PORTABLE=1
set NODE_ENV=production
set VOID_DISABLE_TELEMETRY=1
set VOID_DISABLE_UPDATES=1
set ELECTRON_DEFAULT_ERROR_MODE=1
set ELECTRON_FORCE_IS_PACKAGED=true
set ELECTRON_SKIP_BINARY_DOWNLOAD=1
set NODE_SKIP_PLATFORM_CHECK=1
set "PATH=%APP_DIR%\bin;%APP_DIR%;%CERTS_DIR%;%PATH%"
set "VSCODE_NLS_CONFIG={\"locale\":\"pt-br\",\"osLocale\":\"pt-br\",\"availableLanguages\":{}}"
echo [OK] Variaveis configuradas
echo.

rem === Criar argv.json ===
if not exist "%PORTABLE_DIR%\argv.json" (
    echo { "portable": "%PORTABLE_DIR%" } > "%PORTABLE_DIR%\argv.json"
    echo [OK] argv.json criado
)
echo.

rem === Criar settings.json em user-data\User ===
set "SETTINGS_DIR=%ELECTRON_USER_DATA_DIR%\User"
set "SETTINGS_FILE=%SETTINGS_DIR%\settings.json"

if not exist "%SETTINGS_DIR%" mkdir "%SETTINGS_DIR%"

if not exist "%SETTINGS_FILE%" (
    echo {> "%SETTINGS_FILE%"
    echo   "window.zoomLevel": 1.5,>> "%SETTINGS_FILE%"
    echo   "window.titleBarStyle": "custom",>> "%SETTINGS_FILE%"
    echo   "security.workspace.trust.enabled": false,>> "%SETTINGS_FILE%"
    echo   "telemetry.telemetryLevel": "off",>> "%SETTINGS_FILE%"
    echo   "update.mode": "none",>> "%SETTINGS_FILE%"
    echo   "extensions.autoUpdate": false,>> "%SETTINGS_FILE%"
    echo   "workbench.enableExperiments": false,>> "%SETTINGS_FILE%"
    echo   "files.hotExit": "onExitAndWindowClose",>> "%SETTINGS_FILE%"
    echo   "window.restoreWindows": "preserve",>> "%SETTINGS_FILE%"
    echo   "window.newWindowDimensions": "inherit">> "%SETTINGS_FILE%"
    echo }>> "%SETTINGS_FILE%"
    echo [OK] settings.json criado em user-data
)
echo.

rem === Criar settings.json em appdata\Void\User ===
set "SETTINGS_DIR_ALT=%VSCODE_APPDATA%\Void\User"
set "SETTINGS_FILE_ALT=%SETTINGS_DIR_ALT%\settings.json"

if not exist "%SETTINGS_DIR_ALT%" mkdir "%SETTINGS_DIR_ALT%"

if not exist "%SETTINGS_FILE_ALT%" (
    echo {> "%SETTINGS_FILE_ALT%"
    echo   "window.zoomLevel": 1.5,>> "%SETTINGS_FILE_ALT%"
    echo   "window.titleBarStyle": "custom",>> "%SETTINGS_FILE_ALT%"
    echo   "security.workspace.trust.enabled": false,>> "%SETTINGS_FILE_ALT%"
    echo   "telemetry.telemetryLevel": "off",>> "%SETTINGS_FILE_ALT%"
    echo   "update.mode": "none",>> "%SETTINGS_FILE_ALT%"
    echo   "extensions.autoUpdate": false,>> "%SETTINGS_FILE_ALT%"
    echo   "workbench.enableExperiments": false,>> "%SETTINGS_FILE_ALT%"
    echo   "files.hotExit": "onExitAndWindowClose",>> "%SETTINGS_FILE_ALT%"
    echo   "window.restoreWindows": "preserve",>> "%SETTINGS_FILE_ALT%"
    echo   "window.newWindowDimensions": "inherit">> "%SETTINGS_FILE_ALT%"
    echo }>> "%SETTINGS_FILE_ALT%"
    echo [OK] settings.json criado em appdata\Void
)
echo.

rem === Iniciar o Void ===
echo [INFO] Iniciando Void...
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
    --force-device-scale-factor=1.5 ^
    --enable-pinch ^
    --force-color-profile=srgb

echo [OK] Void iniciado em %RUNTIME_DATE%
echo Void iniciado em %RUNTIME_DATE% >> "%PORTABLE_DIR%\void.log"
echo.
exit /b 0

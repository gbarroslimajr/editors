@echo off
setlocal enabledelayedexpansion

rem ==== Informações do Script ====
set "SCRIPT_VERSION=1.0.0"
for /f "tokens=2 delims==." %%I in ('"wmic os get localdatetime /value"') do set "RUNTIME_DATE=%%I"
set "RUNTIME_DATE=!RUNTIME_DATE:~6,2!/!RUNTIME_DATE:~4,2!/!RUNTIME_DATE:~0,4! !RUNTIME_DATE:~8,2!:!RUNTIME_DATE:~10,2!:!RUNTIME_DATE:~12,2!"

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


rem Define o título da janela
title Void Portable
echo [INFO] Iniciando Void em modo portable...
echo.

rem Obtém o diretório do script e define o diretório base
cd /d "%~dp0"
set "BASE_DIR=%cd%"
set "APP_DIR=%BASE_DIR%\code_GetDestDir"
set "CERTS_DIR=C:\install\devkit-master\certs"
echo [INFO] Diretorio base: %BASE_DIR%
echo [INFO] Diretorio do aplicativo: %APP_DIR%
echo.

rem Verifica se o diretório de certificados existe
echo [INFO] Verificando certificados...
if exist "%CERTS_DIR%" (
    echo [OK] Certificados encontrados em %CERTS_DIR%
    rem Define variáveis para certificados
    set "NODE_EXTRA_CA_CERTS=%CERTS_DIR%"
    set "SSL_CERT_DIR=%CERTS_DIR%"
    set "SSL_CERT_FILE=%CERTS_DIR%\root.cer"
    set "REQUESTS_CA_BUNDLE=%CERTS_DIR%"
    set "NODE_TLS_REJECT_UNAUTHORIZED=0"
) else (
    echo [AVISO] Diretorio de certificados nao encontrado
)
echo.

rem Verifica se estamos no diretório correto com o Void.exe
echo [INFO] Verificando executavel do Void...
echo [DEBUG] Tentando acessar: "%APP_DIR%\Void.exe"

if exist "%APP_DIR%\Void.exe" (
    echo [OK] Void.exe encontrado em %APP_DIR%
    echo [DEBUG] Prosseguindo com a inicializacao...
) else (
    echo [ERRO] Void.exe NAO encontrado no caminho informado!
    echo [ERRO] Verifique se o nome do arquivo esta correto (Void.exe) e se nao ha bloqueios do Windows Defender ou de permissao.
    pause
    exit /b 1
)


rem Cria um arquivo para indicar modo portátil
echo [INFO] Configurando modo portable...
if not exist "%BASE_DIR%\portable-mode" (
    type nul > "%BASE_DIR%\portable-mode"
    echo [OK] Arquivo portable-mode criado
) else (
    echo [OK] Modo portable ja configurado
)
echo.

rem Define e cria estrutura de pastas
echo [INFO] Criando estrutura de diretorios...
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

if not exist "%PORTABLE_DIR%" mkdir "%PORTABLE_DIR%" && echo [OK] Criado: VoidData
if not exist "%ELECTRON_USER_DATA_DIR%" mkdir "%ELECTRON_USER_DATA_DIR%" && echo [OK] Criado: user-data
if not exist "%VOID_PORTABLE_DATA%" mkdir "%VOID_PORTABLE_DATA%" && echo [OK] Criado: data
if not exist "%VSCODE_EXTENSIONS%" mkdir "%VSCODE_EXTENSIONS%" && echo [OK] Criado: extensions
if not exist "%VSCODE_LOGS%" mkdir "%VSCODE_LOGS%" && echo [OK] Criado: logs
if not exist "%VSCODE_APPDATA%" mkdir "%VSCODE_APPDATA%" && echo [OK] Criado: appdata
if not exist "%VSCODE_CRASH_REPORTER_DIRECTORY%" mkdir "%VSCODE_CRASH_REPORTER_DIRECTORY%" && echo [OK] Criado: crashes
if not exist "%ELECTRON_CACHE%" mkdir "%ELECTRON_CACHE%" && echo [OK] Criado: cache
if not exist "%PORTABLE_TEMP%" mkdir "%PORTABLE_TEMP%" && echo [OK] Criado: temp
echo.

rem Configura diretório temporário
set "TMP=%PORTABLE_TEMP%"
set "TEMP=%PORTABLE_TEMP%"
echo [INFO] Diretorio temporario configurado: %PORTABLE_TEMP%
echo.

rem Verifica se é Windows 11 64-bit
echo [INFO] Verificando compatibilidade do sistema...
wmic os get Caption /value | find "Windows 11" >nul
if %ERRORLEVEL% NEQ 0 (
    echo [AVISO] Este aplicativo foi otimizado para Windows 11
    echo [AVISO] Seu sistema pode ter compatibilidade limitada
    timeout /t 5
) else (
    echo [OK] Sistema Windows 11 detectado
)
echo.

rem Define variáveis de ambiente
echo [INFO] Configurando variaveis de ambiente...
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
echo [OK] Variaveis de ambiente configuradas
echo.

rem Configurações de segurança
echo [INFO] Aplicando configuracoes de seguranca...
set ELECTRON_DEFAULT_ERROR_MODE=1
set ELECTRON_FORCE_IS_PACKAGED=true
set ELECTRON_SKIP_BINARY_DOWNLOAD=1
set NODE_SKIP_PLATFORM_CHECK=1
set ELECTRON_CUSTOM_DIR="%APP_DIR%"
set ELECTRON_OVERRIDE_DIST_PATH="%APP_DIR%"
echo [OK] Configuracoes de seguranca aplicadas
echo.

rem Configurações de PATH
echo [INFO] Configurando PATH do sistema...
set "PATH=%APP_DIR%\bin;%APP_DIR%;%CERTS_DIR%;%PATH%"
echo [OK] PATH atualizado
echo.

rem Configurações de NLS
echo [INFO] Configurando idioma...
set "VSCODE_NLS_CONFIG={\"locale\":\"pt-br\",\"osLocale\":\"pt-br\",\"availableLanguages\":{}}"
echo [OK] Idioma configurado para pt-BR
echo.

rem Configuração do argv.json
echo [INFO] Configurando argv.json...
if not exist "%PORTABLE_DIR%\argv.json" (
    echo { "portable": "%PORTABLE_DIR%" } > "%PORTABLE_DIR%\argv.json"
    echo [OK] argv.json criado
) else (
    echo [OK] argv.json ja existe
)
echo.

rem Configuração do settings.json
echo [INFO] Configurando settings.json...
set "SETTINGS_DIR=%ELECTRON_USER_DATA_DIR%\User"
set "SETTINGS_FILE=%SETTINGS_DIR%\settings.json"

if not exist "%SETTINGS_DIR%" mkdir "%SETTINGS_DIR%"

if not exist "%SETTINGS_FILE%" (
    echo [INFO] Criando novo settings.json...
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
    echo [OK] settings.json criado e configurado
) else (
    echo [OK] settings.json ja existe
)
echo.

rem Inicia o aplicativo
echo [INFO] Iniciando Void...
cd /d "%APP_DIR%"
echo [INFO] Aplicando argumentos de inicializacao...
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

rem Espera um momento e registra o início
timeout /t 2 >nul
echo [OK] Void iniciado com sucesso
echo Void iniciado com sucesso em %DATE% às %TIME% >> "%PORTABLE_DIR%\void.log"
echo [INFO] Log registrado em %PORTABLE_DIR%\void.log
echo.
echo [INFO] Inicializacao concluida!
exit /b 0

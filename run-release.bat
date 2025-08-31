@echo off

chcp 65001 >nul
echo ================================================
echo.
echo  ███████████  ███ 2>nul
echo ▒█▒▒▒███▒▒▒█ ▒▒▒ 2>nul
echo ▒   ▒███  ▒  ████   ██████   ████████ 2>nul
echo     ▒███    ▒▒███  ▒▒▒▒▒███ ▒▒███▒▒███ 2>nul
echo     ▒███     ▒███   ███████  ▒███ ▒███ 2>nul
echo     ▒███     ▒███  ███▒▒███  ▒███ ▒███ 2>nul
echo     █████    █████▒▒████████ ████ █████ 2>nul
echo    ▒▒▒▒▒    ▒▒▒▒▒  ▒▒▒▒▒▒▒▒ ▒▒▒▒ ▒▒▒▒▒ 2>nul
echo.
echo ================================================

REM Destination folder
set DEST=%~dp0mod-release
echo Preparing to copy files and folders to: %DEST%
echo.

REM Delete the destination folder if it exists
if exist "%DEST%" (
    echo Deleting existing folder: %DEST%
    echo.
    rmdir /S /Q "%DEST%"
) else (
    echo No existing folder found, creating new one...
    echo.
)

REM Recreate the destination folder
echo Creating destination folder: %DEST%
echo.
mkdir "%DEST%"

REM Now copy files and folders
echo Copying files and folders from mod-release-file-list.txt...
echo.

for /f "usebackq delims=" %%f in ("mod-release-file-list.txt") do (
    if exist "%%f" (
        if exist "%%f\" (
            echo Copying folder: %%f
            xcopy "%%f" "%DEST%\%%f" /S /E /Y /I >nul
            echo Folder %%f copied successfully.
        ) else (
            echo Copying file: %%f
            xcopy "%%f" "%DEST%" /Y >nul
            echo File %%f copied successfully.
        )
    ) else (
        echo WARNING: File or folder %%f does not exist.
    )
)

echo.
echo All files and folders copied to %DEST%
pause

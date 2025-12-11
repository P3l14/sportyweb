@echo off
:: This script sets up the C Compile environment on windows which is necessary for the compilation of the argon2 sources

IF defined VCVARSAL_PATH (
    echo "VCVARSAL_PATH path is set %VCVARSAL_PATH%"
) ELSE (
    echo "No Path to VCVARSAL_PATH defined, searching in subfoldes of C:\Program Files (x86)\"
    for /f "delims=" %%F in ('dir "C:\Program Files (x86)\Microsoft Visual Studio\vcvarsall.bat" /s /b 2^>nul') do (
        set "VCVARSAL_PATH=%%F"
        
    )
)


IF defined VCVARSAL_PATH (
    echo "Call %VCVARSAL_PATH% to set environment for latter compilation of c dependencies"
    call "%VCVARSAL_PATH%" amd64
) ELSE (
    echo "VCVARSAL_PATH not found. Make sure Microsoft Visual Studio C++ Development tools are installed."
    exit
)
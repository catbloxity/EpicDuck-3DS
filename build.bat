@echo off
if "%DEVKITPRO%"=="" (
  echo Install devkitPro and its 3DS development packages first.
  pause
  exit /b 1
)
make
pause

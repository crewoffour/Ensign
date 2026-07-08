@echo off
rem Copyright 2026 Jason Griffin
rem Licensed under the Apache License, Version 2.0. See LICENSE.
rem
rem Runs the Node side of the frame oracle on Windows: milsymbol
rem reference renders and the pixel diff. The Ensign renders require
rem CoreGraphics, so produce them on the Mac with:
rem   swift run -c release ensign-catalog render tools/extract/sidcs-frames.txt tools/extract/out/ensign 200
rem and make sure out\ensign is populated before running the diff.
rem Run from tools\extract. Requires npm install to have been run once.

setlocal
set SIDCS=%1
if "%SIDCS%"=="" set SIDCS=sidcs-frames.txt
set PIXELS=%2
if "%PIXELS%"=="" set PIXELS=200

echo == milsymbol reference renders ==
node reference-render.js --sidcs %SIDCS% --out out/refs --pixels %PIXELS%
if errorlevel 1 exit /b 1

echo.
echo == Pixel diff ==
node diff.js --refs out/refs --candidates out/ensign --out out/diffs
endlocal

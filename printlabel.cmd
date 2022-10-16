@echo off

set CONVERT="C:\Program Files\ImageMagick-7.0.11-Q16-HDRI\convert.exe"
set DISPLAY="C:\Program Files\ImageMagick-7.0.11-Q16-HDRI\imdisplay.exe"

setlocal
:PROMPT
SET /P UPPERC="Use big fonts with uppercase letters/digits (Y/[N])? "
IF /I "%UPPERC%" NEQ "Y" GOTO LOWERC

:UPPERC
echo UPPERCASE MODE (bigger font)
%CONVERT% -pointsize 86 -background white -bordercolor white label:"%1" -fill black -splice 0x5 -border 10x10 label.png
goto CONT

:LOWERC
echo Standard font
%CONVERT% -size x82 -gravity south -splice 0x15 -background white -bordercolor white label:"%1" -fill black label.png
goto CONT

:CONT
%DISPLAY% label.png
python3 labelmaker.py -i label.png "%2"
del label.png

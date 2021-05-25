echo off
:menu
cls
keyb ru 866
rkm.com
tasm.exe /l /zi /c %1
tlink.exe /v /l /m /t /x %1

echo on
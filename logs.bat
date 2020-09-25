@ECHO OFF
findstr /i "LUA dzVents" "C:\Share\Drive\Logs\domo.log" | findstr /V /I "Write" | findstr /V /I "response: 28" | findstr /V /I "EventSystem" | findstr /V /I "generated_scripts" > "C:\Share\Drive\Logs\domoF.log"
EXIT
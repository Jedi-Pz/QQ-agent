@echo off
rem NapCat protocol endpoint launcher.
rem NOTE: keep this file ASCII-only. cmd parses .bat in GBK on Chinese
rem Windows; UTF-8 Chinese comments swallow the newline and break parsing.
cd /d "%~dp0napcat\shell"

if not exist "node.exe" goto missing
if not exist "index.js" goto missing

if not exist "crypto.dll" (
  echo [NapCat] WARNING: crypto.dll / ssl.dll missing.
  echo [NapCat] Copy them from installed QQ: versions\<ver>\resources\app\
  echo [NapCat] into: %~dp0napcat\shell\
  echo [NapCat] Otherwise NapCat fails with "The specified module could not be found".
  echo.
)
if not exist "ssl.dll" (
  echo [NapCat] WARNING: ssl.dll missing - see note above.
  echo.
)

echo [NapCat] starting protocol endpoint...
echo [NapCat] WebUI / QR login: http://127.0.0.1:6099
echo [NapCat] closing this window stops the endpoint; the bot goes offline.
echo.
"node.exe" "index.js"

echo.
echo [NapCat] exited, code %ERRORLEVEL%
pause
exit /b

:missing
echo [NapCat] not installed. In the 0.4 folder run: npm run setup:napcat
pause
exit /b

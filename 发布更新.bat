@echo off
chcp 65001 >nul
cd /d %~dp0

set "GIT=C:\Users\34703\AppData\Local\Atlassian\SourceTree\git_local\cmd\git.exe"
set "GCM=C:\Users\34703\AppData\Local\Atlassian\SourceTree\git_local\mingw64\bin\git-credential-manager.exe"

echo ==========================================
echo   一键发布：缓存版本 +1  提交  推送
echo ==========================================
echo.

rem 1) 自动把 sw.js 的 CACHE 版本号 +1，让手机丢掉旧缓存
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0bump-cache.ps1"
if errorlevel 1 (
  echo.
  echo [已停止] 版本号没有升成功，什么都没推送
  pause
  exit /b 1
)
echo.

rem 2) 配置 git
"%GIT%" config --global credential.helper "%GCM%"
"%GIT%" config --global http.proxy http://127.0.0.1:7897
"%GIT%" config --global https.proxy http://127.0.0.1:7897

rem 3) 提交
"%GIT%" add -A
"%GIT%" commit -m "更新手势花朵 PWA（缓存版本已自动递增）" || echo     （没有新的改动，继续推送）

rem 4) 推送
echo.
echo 推送到 GitHub（可能弹出浏览器，请点 Authorize）...
echo.
"%GIT%" push -u origin main
echo.
echo ------------------------------------------
echo 完成。等约 1 分钟，手机上重新打开页面就是新版。
echo 如果手机上还是旧的：把页面从上往下拉刷新一次，或关掉标签页重开。
echo ------------------------------------------
echo.
pause

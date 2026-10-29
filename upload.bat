@echo off
chcp 65001 >nul
cd /d %~dp0

set "GIT=C:\Users\34703\AppData\Local\Atlassian\SourceTree\git_local\cmd\git.exe"
set "GCM=C:\Users\34703\AppData\Local\Atlassian\SourceTree\git_local\mingw64\bin\git-credential-manager.exe"

echo ==========================================
echo  手势花朵 PWA  -^>  GitHub Pages
echo ==========================================
echo.

"%GIT%" config --global credential.helper "%GCM%"
"%GIT%" config --global http.proxy http://127.0.0.1:7897
"%GIT%" config --global https.proxy http://127.0.0.1:7897

if not exist ".git" (
  echo [1/4] 初始化本地仓库 ...
  "%GIT%" init -b main >nul
  "%GIT%" remote add origin https://github.com/zhangshengdong86-arch/hand-flower.git
) else (
  echo [1/4] 仓库已存在，跳过初始化
)

echo [2/4] 添加文件 ...
"%GIT%" add -A

echo [3/4] 提交 ...
"%GIT%" commit -m "手势花朵 PWA: 左手花朵 / 右手爱心 / 靠近镜头进入粒子内部" || echo     （没有新的改动，继续推送）

echo [4/4] 推送到 GitHub（可能弹出浏览器，请点 Authorize）...
echo.
"%GIT%" push -u origin main

echo.
echo 退出码: %errorlevel%
echo.
echo ------------------------------------------
echo 推送成功后，第一次还需开启 GitHub Pages：
echo   https://github.com/zhangshengdong86-arch/hand-flower/settings/pages
echo   Source: Deploy from a branch
echo   Branch: main  /  (root)  -^>  Save
echo.
echo 约 1 分钟后手机访问：
echo   https://zhangshengdong86-arch.github.io/hand-flower/
echo ------------------------------------------
echo.
pause

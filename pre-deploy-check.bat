@echo off
REM ==========================================
REM Pre-deployment check script
REM ==========================================

echo.
echo ===================================
echo   Pre-Deployment Check
echo ===================================
echo.

REM Check Git status
echo [1/5] Checking Git status...
git status --porcelain > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Not a git repository!
    echo Please run: git init
    pause
    exit /b 1
)
echo [OK] Git repository found

REM Check if there are changes to commit
git status --porcelain | findstr . > nul
if errorlevel 1 (
    echo [WARNING] No changes to commit
) else (
    echo [OK] Changes detected
)

REM Check SSH connection
echo.
echo [2/5] Testing SSH connection to server...
ssh -o ConnectTimeout=5 root@31.97.129.5 "echo 'SSH connection successful'" > nul 2>&1
if errorlevel 1 (
    echo [ERROR] Cannot connect to server via SSH!
    echo Please check your SSH key and network connection
    pause
    exit /b 1
)
echo [OK] SSH connection successful

REM Check server services
echo.
echo [3/5] Checking server services...
ssh root@31.97.129.5 "pm2 status" > nul 2>&1
if errorlevel 1 (
    echo [WARNING] PM2 might not be running properly
) else (
    echo [OK] PM2 is running
)

REM Check Nginx
echo.
echo [4/5] Checking Nginx...
ssh root@31.97.129.5 "nginx -t" > nul 2>&1
if errorlevel 1 (
    echo [WARNING] Nginx configuration might have issues
) else (
    echo [OK] Nginx configuration is valid
)

REM Check disk space
echo.
echo [5/5] Checking server disk space...
ssh root@31.97.129.5 "df -h /home/emailapp | tail -1 | awk '{print $5}' | sed 's/%%//'" > temp_disk.txt
set /p disk_usage=<temp_disk.txt
del temp_disk.txt

if %disk_usage% GTR 90 (
    echo [WARNING] Disk usage is at %disk_usage%%%!
    echo Consider cleaning up before deployment
) else (
    echo [OK] Disk usage is at %disk_usage%%%
)

echo.
echo ===================================
echo   Pre-deployment check complete!
echo ===================================
echo.
echo All systems are ready for deployment.
echo You can now run one of the deployment scripts:
echo - deploy-to-github-and-vps.bat
echo - deploy-complete.ps1
echo.

pause
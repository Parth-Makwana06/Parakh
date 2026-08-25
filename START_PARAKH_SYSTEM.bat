@echo off
title Parakh - LMPC 2011 AI System Launcher (Team InsightX)
color 0B

echo ========================================================
echo   PARAKH - LEGAL METROLOGY AI SYSTEM (SIH 2026)
echo   Team: InsightX  ^|  Problem Statement: 26034
echo ========================================================
echo.

echo [1/4] Setting up USB ADB Port Forwarding...
if exist "P:\Android\Sdk\platform-tools\adb.exe" (
    "P:\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
    echo ADB Port 8000 reversed successfully!
)

echo.
echo [2/4] Starting FastAPI Backend Server on port 8000...
start cmd /k "cd /d %~dp0backend && title Parakh Backend Server && color 0A && python -m uvicorn main:app --host 0.0.0.0 --port 8000"

echo.
echo [3/4] Opening Admin Dashboard in Web Browser...
timeout /t 3 /nobreak > nul
start "" "%~dp0frontend_web\login.html"

echo.
echo [4/4] Starting Flutter Mobile Application...
start cmd /k "cd /d %~dp0mobile_app && title Parakh Mobile App && flutter run"

echo.
echo ========================================================
echo   System is LIVE!
echo   - Web Dashboard: Admin Login Page Opened
echo   - Backend API: http://localhost:8000
echo   - Swagger Docs: http://localhost:8000/docs
echo ========================================================
pause

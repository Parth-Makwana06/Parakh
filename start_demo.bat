@echo off
title Parakh AI - System Startup
color 0B

echo =======================================================
echo          PARAKH (METROLOGYLENS) - DEMO LAUNCHER
echo =======================================================
echo.

echo [1/3] Starting Python FastAPI Backend Server...
:: Opens a new terminal window for the backend so it runs independently
start "Parakh Backend Server" cmd /k "cd backend && title Parakh Backend Server && color 0A && echo Starting Server... && uvicorn main:app --reload"

echo [2/3] Waiting for backend to initialize (3 seconds)...
timeout /t 3 /nobreak > nul

echo [3/3] Opening Admin Dashboard in your Web Browser...
:: Uses %~dp0 to get the current folder path and opens login.html
start "" "%~dp0frontend_web\login.html"

echo.
echo =======================================================
echo SUCCESS! System is Online! 
echo.
echo Next Steps:
echo 1. Login to the dashboard using admin / admin123
echo 2. Open Flutter / VS Code and run your Mobile App
echo =======================================================
echo.
pause

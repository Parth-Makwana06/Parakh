@echo off
title Parakh - LMPC 2011 AI System Launcher (Team InsightX)
echo ========================================================
echo   PARAKH - LEGAL METROLOGY AI SYSTEM (SIH 2026)
echo   Team: InsightX  ^|  Problem Statement: 26034
echo ========================================================
echo.
echo [1/2] Starting FastAPI Backend Server on port 8000...
start cmd /k "cd /d %~dp0backend && python -m uvicorn main:app --host 0.0.0.0 --port 8000"
echo.
echo [2/2] Starting Flutter Mobile Application...
start cmd /k "cd /d %~dp0mobile_app && flutter run"
echo.
echo ========================================================
echo   System is LIVE!
echo   - Backend API: http://localhost:8000
echo   - Swagger Docs: http://localhost:8000/docs
echo ========================================================
pause

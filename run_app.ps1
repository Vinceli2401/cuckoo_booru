#!/usr/bin/env pwsh

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "   CuckooBooru Flutter App Launcher" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is available
Write-Host "[1/4] Checking Flutter installation..." -ForegroundColor Yellow
try {
    $null = flutter --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter command failed"
    }
    Write-Host "[OK] Flutter detected successfully!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter and add it to your PATH" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Check if Windows desktop is enabled
Write-Host "[2/4] Checking Windows desktop support..." -ForegroundColor Yellow
try {
    $configOutput = flutter config --list 2>$null
    if ($configOutput -match "enable-windows-desktop: true") {
        Write-Host "[OK] Windows desktop support already enabled!" -ForegroundColor Green
    } else {
        Write-Host "[INFO] Enabling Windows desktop support..." -ForegroundColor Blue
        flutter config --enable-windows-desktop | Out-Null
        Write-Host "[OK] Windows desktop support enabled!" -ForegroundColor Green
    }
} catch {
    Write-Host "[ERROR] Failed to configure Windows desktop support: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Check available devices
Write-Host "[3/4] Checking available devices..." -ForegroundColor Yellow
try {
    $devices = flutter devices 2>$null
    if ($devices -match "Windows \(desktop\)") {
        Write-Host "[OK] Windows desktop device found!" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Windows desktop device not found" -ForegroundColor Red
        Write-Host "Please ensure Windows desktop support is properly configured" -ForegroundColor Red
        Write-Host ""
        Read-Host "Press Enter to exit"
        exit 1
    }
} catch {
    Write-Host "[ERROR] Failed to check devices: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Run the Flutter app
Write-Host "[4/4] Starting CuckooBooru app..." -ForegroundColor Yellow
Write-Host "This may take a moment on first run..." -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop the app when running" -ForegroundColor Gray
Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan

try {
    flutter run -d windows
} catch {
    Write-Host ""
    Write-Host "[ERROR] App failed to start: $_" -ForegroundColor Red
} finally {
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "App execution finished." -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
} 
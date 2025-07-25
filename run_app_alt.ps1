Write-Host "Running CuckooBooru on Windows..." -ForegroundColor Green
Write-Host ""

# Check if Visual Studio is properly configured
Write-Host "Checking Visual Studio configuration..." -ForegroundColor Yellow
& flutter doctor -v

Write-Host ""
Write-Host "Cleaning previous build..." -ForegroundColor Yellow
& flutter clean

Write-Host ""
Write-Host "Getting dependencies..." -ForegroundColor Yellow
& flutter pub get

Write-Host ""
Write-Host "Attempting to run on Windows (debug mode)..." -ForegroundColor Yellow
& flutter run -d windows

Write-Host ""
Write-Host "If the Windows build fails, try running on web instead:" -ForegroundColor Cyan
Write-Host "flutter run -d chrome" -ForegroundColor White

Read-Host "Press Enter to exit"
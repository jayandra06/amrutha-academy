# Flutter Installation Script for Windows
# This script downloads and sets up Flutter SDK

Write-Host "Flutter Installation Script" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green
Write-Host ""

# Check if Flutter is already installed
$flutterPath = "C:\src\flutter\bin\flutter.bat"
if (Test-Path $flutterPath) {
    Write-Host "Flutter appears to be already installed at C:\src\flutter" -ForegroundColor Yellow
    Write-Host "Checking version..." -ForegroundColor Yellow
    & $flutterPath --version
    exit 0
}

# Check if flutter command exists in PATH
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Flutter is already installed and in PATH!" -ForegroundColor Green
        flutter --version
        exit 0
    }
} catch {
    # Flutter not in PATH, continue with installation
}

Write-Host "Flutter is not installed. Starting installation..." -ForegroundColor Yellow
Write-Host ""

# Create installation directory
$installPath = "C:\src\flutter"
Write-Host "Installation path: $installPath" -ForegroundColor Cyan

if (-not (Test-Path "C:\src")) {
    Write-Host "Creating C:\src directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "C:\src" -Force | Out-Null
}

# Download Flutter SDK
$flutterZip = "C:\src\flutter_windows.zip"
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"

Write-Host "Downloading Flutter SDK (this may take a few minutes)..." -ForegroundColor Yellow
Write-Host "URL: $flutterUrl" -ForegroundColor Gray

try {
    Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip -UseBasicParsing
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Error downloading Flutter: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download manually from:" -ForegroundColor Yellow
    Write-Host "https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Cyan
    exit 1
}

# Extract Flutter
Write-Host ""
Write-Host "Extracting Flutter SDK..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $flutterZip -DestinationPath "C:\src" -Force
    Write-Host "Extraction completed!" -ForegroundColor Green
} catch {
    Write-Host "Error extracting Flutter: $_" -ForegroundColor Red
    exit 1
}

# Clean up zip file
Remove-Item $flutterZip -Force

# Add to PATH (User PATH)
Write-Host ""
Write-Host "Adding Flutter to PATH..." -ForegroundColor Yellow
$flutterBinPath = "$installPath\bin"
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($currentPath -notlike "*$flutterBinPath*") {
    $newPath = $currentPath + ";$flutterBinPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Flutter added to PATH!" -ForegroundColor Green
    Write-Host ""
    Write-Host "IMPORTANT: Please restart your terminal/IDE for PATH changes to take effect!" -ForegroundColor Yellow
} else {
    Write-Host "Flutter is already in PATH" -ForegroundColor Green
}

# Verify installation
Write-Host ""
Write-Host "Verifying installation..." -ForegroundColor Yellow
$flutterExe = "$installPath\bin\flutter.bat"
if (Test-Path $flutterExe) {
    Write-Host "Flutter installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Restart your terminal/IDE" -ForegroundColor White
    Write-Host "2. Run: flutter doctor" -ForegroundColor White
    Write-Host "3. Run: cd amrutha-academy\amrutha-academy" -ForegroundColor White
    Write-Host "4. Run: flutter pub get" -ForegroundColor White
} else {
    Write-Host "Installation may have failed. Please check manually." -ForegroundColor Red
}

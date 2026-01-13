# E-Voting System - Complete Startup Script
# Checks environment, starts Docker, waits for health, and opens browser

Write-Host "🚀 Starting E-Voting System Setup..." -ForegroundColor Cyan

# 1. Check if Docker is running
Write-Host "🔍 Checking Docker status..."
$dockerStatus = docker info 2>&1
if ($LastExitCode -ne 0) {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again."
    exit 1
}
Write-Host "✅ Docker is running." -ForegroundColor Green

# 2. Stop any running containers
Write-Host "🛑 Stopping existing containers..."
docker-compose down
Write-Host "✅ Containers stopped." -ForegroundColor Green

# 3. Build and Start
Write-Host "🏗️  Building and starting services..."
docker-compose up -d --build

if ($LastExitCode -ne 0) {
    Write-Host "❌ Docker Compose failed!" -ForegroundColor Red
    exit 1
}

# 4. Wait for Backend Health
Write-Host "⏳ Waiting for backend to be healthy..." -ForegroundColor Yellow
$maxRetries = 30
$retryCount = 0
$healthy = $false

while ($retryCount -lt $maxRetries) {
    Start-Sleep -Seconds 2
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8000/health" -UseBasicParsing -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            $healthy = $true
            break
        }
    } catch {
        Write-Host "." -NoNewline
    }
    $retryCount++
}

Write-Host ""
if ($healthy) {
    Write-Host "✅ System is healthy and ready!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Backend didn't respond in time, but containers are running." -ForegroundColor Yellow
}

# 5. Open Browser
Write-Host "🌐 Opening application..."
Start-Process "http://localhost:3000"
Start-Process "http://localhost:8000/docs"

Write-Host "🎉 DONE! The E-voting system is live." -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:3000"
Write-Host "   API Docs: http://localhost:8000/docs"
Write-Host ""
Write-Host "ℹ️  To reset the data and restart testing:"
Write-Host "   Run: .\reset_demo.ps1"

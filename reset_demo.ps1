# Reset E-Voting System Demo Data
# Clears database and restarts backend

Write-Host "🔄 Resetting E-Voting Demo Data..." -ForegroundColor Cyan

# Call the reset API endpoint
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/mock/reset-database" -Method POST -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Database cleared successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to clear database. Is the backend running?" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)"
}

Write-Host ""
Write-Host "ℹ️  You can now start a fresh test workflow in the Frontend at:"
Write-Host "   http://localhost:3000"

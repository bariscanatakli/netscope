Write-Host "Running comprehensive tests for full coverage..."

# Create directory structure if it doesn't exist
New-Item -Path "test\speedtest-results" -ItemType Directory -Force
New-Item -Path "test\traceroute-map-features" -ItemType Directory -Force
New-Item -Path "test\auth-user-management" -ItemType Directory -Force
New-Item -Path "test\core-features-ui" -ItemType Directory -Force

# Run tests with coverage
flutter test --coverage

# Generate HTML report
./create_coverage_report.ps1

Write-Host "Testing complete. Coverage report generated."

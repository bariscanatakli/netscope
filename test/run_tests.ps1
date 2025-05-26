# NetScope Test Runner (PowerShell)
param(
    [switch]$all,
    [switch]$unit,
    [switch]$widget,
    [switch]$integration,
    [switch]$coverage,
    [switch]$help
)

# Function to display usage
function Show-Usage {
    Write-Host "NetScope Test Runner"
    Write-Host "-------------------"
    Write-Host "Usage:"
    Write-Host "  .\run_tests.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -all           Run all tests"
    Write-Host "  -unit          Run only unit tests"
    Write-Host "  -widget        Run only widget tests"
    Write-Host "  -integration   Run only integration tests"
    Write-Host "  -coverage      Generate coverage report"
    Write-Host "  -help          Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\run_tests.ps1 -unit"
    Write-Host "  .\run_tests.ps1 -coverage -widget"
    Write-Host "  .\run_tests.ps1 -all -coverage"
}

# Show help if requested
if ($help) {
    Show-Usage
    exit 0
}

# If no test type specified, run all
if (-not ($all -or $unit -or $widget -or $integration)) {
    $all = $true
}

Write-Host "NetScope Test Runner"
Write-Host "-------------------"

# Function to run tests with or without coverage
function Run-Tests {
    param(
        [string]$testPath
    )
    
    if ($coverage) {
        Write-Host "Running tests with coverage: $testPath"
        flutter test $testPath --coverage
    } else {
        Write-Host "Running tests: $testPath"
        flutter test $testPath
    }
}

# Run unit tests
if ($all -or $unit) {
    Write-Host "Running unit tests..."
    Run-Tests "test/unit/"
}

# Run widget tests
if ($all -or $widget) {
    Write-Host "Running widget tests..."
    Run-Tests "test/widget/"
}

# Run integration tests
if ($all -or $integration) {
    Write-Host "Running integration tests..."
    Run-Tests "test/integration/"
}

# Generate coverage report if requested
if ($coverage) {
    Write-Host "Generating coverage report..."
    
    # Check if lcov is installed
    $lcovInstalled = $null -ne (Get-Command lcov -ErrorAction SilentlyContinue)
    
    if ($lcovInstalled) {
        # Generate HTML report
        genhtml coverage/lcov.info -o coverage/html
        
        Write-Host "Coverage report generated in coverage/html/index.html"
    } else {
        Write-Host "lcov not found. Please install lcov to generate HTML coverage reports."
        Write-Host "Raw coverage data available in coverage/lcov.info"
    }
}

Write-Host "Testing complete!"

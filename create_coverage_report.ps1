# First run tests with coverage
flutter test --coverage

# Read lcov.info content
$lcovContent = Get-Content coverage/lcov.info -Raw

if ($null -eq $lcovContent -or $lcovContent -eq '') {
    Write-Host "Error: lcov.info is empty. No coverage data found."
    exit 1
}

Write-Host "Coverage data found. Generating report..."

# Define modules and targets
$modules = @{
    "Authentication & User Management" = @{
        "assignee" = "Mustafa Morsy";
        "target" = 90;
        "patterns" = @("auth_", "login", "user", "profile", "account", "password", "auth/", "auth", "auth_service", "auth_provider");
        "files" = @{};
        "lines" = 0;
        "covered" = 0;
    };
    "Speed Test & Results" = @{
        "assignee" = "Baris Can Atakli";
        "target" = 95;
        "patterns" = @("speed", "test", "result", "speedtest", "speed_test");
        "files" = @{};
        "lines" = 0;
        "covered" = 0;
    };
    "Traceroute & Map Features" = @{
        "assignee" = "Bayram Gurbuz";
        "target" = 85;
        "patterns" = @("map", "route", "trace", "location", "geo", "traceroute");
        "files" = @{};
        "lines" = 0;
        "covered" = 0;
    };
    "Core Features & Network Scanner" = @{
        "assignee" = "Alaa Hosny Saber";
        "target" = 90;
        "patterns" = @("network", "scan", "core", "info", "services", "settings", "home");
        "files" = @{};
        "lines" = 0;
        "covered" = 0;
    }
}

# Create HTML report with enhanced Netscope styling
$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Netscope - Coverage Report</title>
    <style>
        :root {
            --primary: #0088cc;
            --secondary: #005580;
            --success: #4caf50;
            --warning: #ff9800;
            --danger: #f44336;
            --light: #f8f9fa;
            --dark: #343a40;
            --border: #dee2e6;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f7f9;
            color: #333;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--secondary) 100%);
            color: white;
            padding: 30px 20px;
            margin-bottom: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 600;
        }
        
        .project-info {
            margin-top: 10px;
            font-size: 16px;
            opacity: 0.9;
        }
        
        .summary-box {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .summary-stat {
            text-align: center;
            padding: 0 20px;
        }
        
        .summary-stat-value {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .summary-stat-label {
            font-size: 14px;
            color: #666;
            text-transform: uppercase;
        }
        
        .coverage-gauge {
            width: 150px;
            height: 150px;
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0 auto;
        }
        
        .gauge-fill {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            background: conic-gradient(
                var(--success) 0% var(--percentage), 
                #e9ecef var(--percentage) 100%
            );
            position: absolute;
        }
        
        .gauge-center {
            width: 110px;
            height: 110px;
            background: white;
            border-radius: 50%;
            position: absolute;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
        }
        
        .gauge-percentage {
            font-size: 24px;
            font-weight: bold;
            color: var(--dark);
        }
        
        .gauge-label {
            font-size: 12px;
            color: #666;
        }
        
        .section {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 30px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
        
        .section-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            color: var(--secondary);
            display: flex;
            align-items: center;
        }
        
        .section-title::before {
            content: '';
            display: inline-block;
            width: 4px;
            height: 20px;
            background-color: var(--primary);
            margin-right: 10px;
            border-radius: 2px;
        }
        
        table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 10px;
        }
        
        th {
            background-color: #f5f7f9;
            color: var(--secondary);
            text-align: left;
            padding: 12px;
            font-weight: 600;
            border-bottom: 2px solid var(--border);
        }
        
        td {
            padding: 12px;
            border-bottom: 1px solid var(--border);
        }
        
        tr:hover {
            background-color: rgba(0, 136, 204, 0.05);
        }
        
        .file-path {
            font-family: 'Consolas', monospace;
        }
        
        .coverage-cell {
            display: flex;
            align-items: center;
        }
        
        .coverage-bar {
            height: 8px;
            width: 100px;
            background-color: #e9ecef;
            border-radius: 4px;
            margin-right: 10px;
            overflow: hidden;
        }
        
        .coverage-bar-fill {
            height: 100%;
            border-radius: 4px;
        }
        
        .high .coverage-bar-fill {
            background-color: var(--success);
        }
        
        .medium .coverage-bar-fill {
            background-color: var(--warning);
        }
        
        .low .coverage-bar-fill {
            background-color: var(--danger);
        }
        
        .coverage-percentage {
            min-width: 45px;
            text-align: right;
        }
        
        .coverage-details {
            color: #666;
            font-size: 14px;
        }
        
        .module-card {
            background-color: white;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }
        
        .module-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border);
        }
        
        .module-title {
            font-size: 16px;
            font-weight: bold;
            color: var(--secondary);
        }
        
        .module-meta {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .module-assignee {
            font-size: 14px;
            display: flex;
            align-items: center;
        }
        
        .assignee-avatar {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background-color: var(--primary);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 6px;
            font-size: 12px;
        }
        
        .module-targets {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .target-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .target-label {
            font-size: 12px;
            color: #666;
        }
        
        .target-value {
            font-weight: bold;
            font-size: 14px;
        }
        
        .target-value.met {
            color: var(--success);
        }
        
        .target-value.not-met {
            color: var(--danger);
        }
        
        .progress-container {
            margin-top: 10px;
            position: relative;
        }
        
        .progress {
            height: 10px;
            background-color: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
        }
        
        .progress-bar {
            height: 100%;
            border-radius: 4px;
        }
        
        .target-marker {
            position: absolute;
            top: -5px;
            height: 20px;
            width: 2px;
            background-color: #666;
        }
        
        .target-marker::after {
            content: '';
            position: absolute;
            top: 0;
            left: -4px;
            width: 10px;
            height: 10px;
            background-color: #666;
            border-radius: 50%;
        }
        
        .module-table {
            margin-top: 15px;
        }
        
        .assignee-tag {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            margin-left: 5px;
        }
        
        .gap-analysis {
            margin-top: 5px;
            font-size: 12px;
        }
        
        footer {
            text-align: center;
            padding: 20px;
            color: #666;
            font-size: 14px;
            border-top: 1px solid var(--border);
            margin-top: 40px;
        }
        
        .module-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Netscope Coverage Report</h1>
            <div class="project-info">
                Mobile network diagnostics and performance analysis tool
            </div>
        </div>
"@

# Parse lcov.info
$files = @{}
$totalLines = 0
$coveredLines = 0
$currentFile = ""

# Catch-all for files that don't match any module
$uncategorized = @{
    "files" = @{};
    "lines" = 0;
    "covered" = 0;
}

foreach ($line in ($lcovContent -split "`n")) {
    if ($line.StartsWith("SF:")) {
        $currentFile = $line.Substring(3)
    }
    elseif ($line.StartsWith("LF:")) {
        $fileLines = [int]$line.Substring(3)
        $totalLines += $fileLines
        if (-not $files.ContainsKey($currentFile)) {
            $files[$currentFile] = @{}
        }
        $files[$currentFile]["lines"] = $fileLines
        
        # Categorize by module
        $categorized = $false
        foreach ($moduleName in $modules.Keys) {
            foreach ($pattern in $modules[$moduleName]["patterns"]) {
                if ($currentFile -match $pattern) {
                    $modules[$moduleName]["files"][$currentFile] = @{}
                    $modules[$moduleName]["files"][$currentFile]["lines"] = $fileLines
                    $modules[$moduleName]["lines"] += $fileLines
                    $categorized = $true
                    break
                }
            }
            if ($categorized) { break }
        }
        
        # If not categorized, put in uncategorized
        if (-not $categorized) {
            $uncategorized["files"][$currentFile] = @{}
            $uncategorized["files"][$currentFile]["lines"] = $fileLines
            $uncategorized["lines"] += $fileLines
        }
    }
    elseif ($line.StartsWith("LH:")) {
        $fileCovered = [int]$line.Substring(3)
        $coveredLines += $fileCovered
        $files[$currentFile]["covered"] = $fileCovered
        
        # Update module coverage
        $categorized = $false
        foreach ($moduleName in $modules.Keys) {
            if ($modules[$moduleName]["files"].ContainsKey($currentFile)) {
                $modules[$moduleName]["files"][$currentFile]["covered"] = $fileCovered
                $modules[$moduleName]["covered"] += $fileCovered
                $categorized = $true
                break
            }
        }
        
        # If not categorized, update uncategorized
        if (-not $categorized) {
            $uncategorized["files"][$currentFile]["covered"] = $fileCovered
            $uncategorized["covered"] += $fileCovered
        }
    }
}

# Calculate coverage percentages
$totalCoverage = 0
if ($totalLines -gt 0) {
    $totalCoverage = [math]::Round(($coveredLines / $totalLines) * 100, 2)
}

# Add summary with gauge chart
$html += @"
        <div class="summary-box">
            <div class="summary-stat">
                <div class="summary-stat-value">$totalLines</div>
                <div class="summary-stat-label">Total Lines</div>
            </div>
            
            <div class="summary-stat">
                <div class="coverage-gauge">
                    <div class="gauge-fill" style="--percentage: ${totalCoverage}%;"></div>
                    <div class="gauge-center">
                        <div class="gauge-percentage">$totalCoverage%</div>
                        <div class="gauge-label">Coverage</div>
                    </div>
                </div>
            </div>
            
            <div class="summary-stat">
                <div class="summary-stat-value">$coveredLines</div>
                <div class="summary-stat-label">Covered Lines</div>
            </div>
        </div>
        
        <div class="section">
            <div class="section-title">Coverage by Module</div>
"@

# Calculate and add module coverage cards
$html += @"
            <div class="module-grid">
"@

# Add module cards
foreach ($moduleName in $modules.Keys) {
    $moduleLines = $modules[$moduleName]["lines"]
    $moduleCovered = $modules[$moduleName]["covered"]
    $modulePercentage = 0
    if ($moduleLines -gt 0) {
        $modulePercentage = [math]::Round(($moduleCovered / $moduleLines) * 100, 2)
    }
    $targetPercentage = $modules[$moduleName]["target"]
    $assignee = $modules[$moduleName]["assignee"]
    
    # Fixed: Create initials without Join-String
    $nameParts = $assignee -split ' '
    $assigneeInitials = ""
    foreach ($part in $nameParts) {
        if ($part.Length -gt 0) {
            $assigneeInitials += $part.Substring(0,1)
        }
    }
    
    $targetMet = $modulePercentage -ge $targetPercentage
    $targetClass = if ($targetMet) { "met" } else { "not-met" }
    $progressColor = if ($modulePercentage -ge 80) { "--success" } elseif ($modulePercentage -ge 50) { "--warning" } else { "--danger" }
    
    $gapToTarget = $targetPercentage - $modulePercentage
    $gapMessage = ""
    if ($gapToTarget -gt 0) {
        $linesToCover = [math]::Ceiling(($moduleLines * $targetPercentage / 100) - $moduleCovered)
        $gapMessage = "Need to cover $linesToCover more lines to reach target."
    }
    
    $html += @"
                <div class="module-card">
                    <div class="module-header">
                        <div class="module-title">$moduleName</div>
                        <div class="module-meta">
                            <div class="module-assignee">
                                <div class="assignee-avatar">$assigneeInitials</div>
                                <span>$assignee</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="module-targets">
                        <div class="target-item">
                            <span class="target-label">Current:</span>
                            <span class="target-value $targetClass">$modulePercentage%</span>
                        </div>
                        <div class="target-item">
                            <span class="target-label">Target:</span>
                            <span class="target-value">$targetPercentage%</span>
                        </div>
                        <div class="target-item">
                            <span class="target-label">Lines:</span>
                            <span class="target-value">$moduleCovered/$moduleLines</span>
                        </div>
                    </div>
                    
                    <div class="progress-container">
                        <div class="progress">
                            <div class="progress-bar" style="width: $modulePercentage%; background-color: var($progressColor);"></div>
                        </div>
                        <div class="target-marker" style="left: $targetPercentage%;"></div>
                    </div>
                    
                    <div class="gap-analysis">
                        $gapMessage
                    </div>
                </div>
"@
}

$html += @"
            </div>
        </div>
"@

# Add detailed modules sections
foreach ($moduleName in $modules.Keys) {
    if ($modules[$moduleName]["files"].Count -gt 0) {
        $moduleLines = $modules[$moduleName]["lines"]
        $moduleCovered = $modules[$moduleName]["covered"]
        $modulePercentage = 0
        if ($moduleLines -gt 0) {
            $modulePercentage = [math]::Round(($moduleCovered / $moduleLines) * 100, 2)
        }
        
        $html += @"
        <div class="section">
            <div class="section-title">$moduleName <span class="assignee-tag" style="background-color: var(--secondary); color: white;">$($modules[$moduleName]["assignee"])</span></div>
            <table class="module-table">
                <tr>
                    <th>File</th>
                    <th>Coverage</th>
                    <th>Lines</th>
                </tr>
"@
        
        # Sort files by coverage (lowest first)
        $sortedFiles = $modules[$moduleName]["files"].GetEnumerator() | 
            Sort-Object { 
                if ($_.Value.lines -gt 0) {
                    [math]::Round(($_.Value.covered / $_.Value.lines) * 100, 2)
                } else { 
                    0 
                }
            }
        
        foreach ($fileEntry in $sortedFiles) {
            $file = $fileEntry.Key
            $fileData = $fileEntry.Value
            $fileLines = $fileData["lines"]
            $fileCovered = $fileData["covered"]
            $fileCoverage = 0
            
            if ($fileLines -gt 0) {
                $fileCoverage = [math]::Round(($fileCovered / $fileLines) * 100, 2)
            }
            
            $class = "low"
            if ($fileCoverage -ge 80) { $class = "high" }
            elseif ($fileCoverage -ge 50) { $class = "medium" }
            
            $fileName = [System.IO.Path]::GetFileName($file)
            
            $html += @"
                <tr class="$class">
                    <td class="file-path" title="$file">$fileName</td>
                    <td>
                        <div class="coverage-cell">
                            <div class="coverage-bar">
                                <div class="coverage-bar-fill" style="width: $fileCoverage%;"></div>
                            </div>
                            <div class="coverage-percentage">$fileCoverage%</div>
                        </div>
                    </td>
                    <td class="coverage-details">$fileCovered/$fileLines</td>
                </tr>
"@
        }
        
        $html += @"
            </table>
        </div>
"@
    }
}

# Add uncategorized files if any
if ($uncategorized["files"].Count -gt 0) {
    $uncategorizedLines = $uncategorized["lines"]
    $uncategorizedCovered = $uncategorized["covered"]
    $uncategorizedPercentage = 0
    if ($uncategorizedLines -gt 0) {
        $uncategorizedPercentage = [math]::Round(($uncategorizedCovered / $uncategorizedLines) * 100, 2)
    }
    
    $html += @"
        <div class="section">
            <div class="section-title">Other Files</div>
            <table class="module-table">
                <tr>
                    <th>File</th>
                    <th>Coverage</th>
                    <th>Lines</th>
                </tr>
"@
    
    # Sort files by coverage (lowest first)
    $sortedFiles = $uncategorized["files"].GetEnumerator() | 
        Sort-Object { 
            if ($_.Value.lines -gt 0) {
                [math]::Round(($_.Value.covered / $_.Value.lines) * 100, 2)
            } else { 
                0 
            }
        }
    
    foreach ($fileEntry in $sortedFiles) {
        $file = $fileEntry.Key
        $fileData = $fileEntry.Value
        $fileLines = $fileData["lines"]
        $fileCovered = $fileData["covered"]
        $fileCoverage = 0
        
        if ($fileLines -gt 0) {
            $fileCoverage = [math]::Round(($fileCovered / $fileLines) * 100, 2)
        }
        
        $class = "low"
        if ($fileCoverage -ge 80) { $class = "high" }
        elseif ($fileCoverage -ge 50) { $class = "medium" }
        
        $fileName = [System.IO.Path]::GetFileName($file)
        
        $html += @"
                <tr class="$class">
                    <td class="file-path" title="$file">$fileName</td>
                    <td>
                        <div class="coverage-cell">
                            <div class="coverage-bar">
                                <div class="coverage-bar-fill" style="width: $fileCoverage%;"></div>
                            </div>
                            <div class="coverage-percentage">$fileCoverage%</div>
                        </div>
                    </td>
                    <td class="coverage-details">$fileCovered/$fileLines</td>
                </tr>
"@
    }
    
    $html += @"
            </table>
        </div>
"@
}

# Finish HTML
$html += @"
        <footer>
            Netscope Coverage Report | Generated on $(Get-Date) | Flutter Test Coverage
        </footer>
    </div>
</body>
</html>
"@

# Write to file
$html | Out-File "coverage-report.html" -Encoding UTF8
Write-Host "Report generated: coverage-report.html"
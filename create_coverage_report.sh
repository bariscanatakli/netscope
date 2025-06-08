#!/bin/bash
# filepath: d:/netscope/generate_coverage.sh

# First run tests with coverage
flutter test --coverage

# Check if lcov.info exists and has content
if [ ! -f "coverage/lcov.info" ] || [ ! -s "coverage/lcov.info" ]; then
  echo "Error: lcov.info is empty or doesn't exist. No coverage data found."
  exit 1
fi

echo "Coverage data found. Generating report..."

# Function to calculate coverage percentage
calculate_percentage() {
  local covered=$1
  local total=$2
  if [ "$total" -eq 0 ]; then
    echo 0
  else
    echo "scale=2; ($covered * 100) / $total" | bc
  fi
}

# Define modules and targets
declare -A auth_module
auth_module["assignee"]="Mustafa Morsy"
auth_module["target"]=90
auth_module["patterns"]="auth_|login|user|profile|account|password|auth/|auth|auth_service|auth_provider"
auth_module["lines"]=0
auth_module["covered"]=0
declare -A auth_files

declare -A speed_module
speed_module["assignee"]="Barış Can Ataklı"
speed_module["target"]=95
speed_module["patterns"]="speed|test|result|speedtest|speed_test"
speed_module["lines"]=0
speed_module["covered"]=0
declare -A speed_files

declare -A trace_module
trace_module["assignee"]="Bayram Gürbüz"
trace_module["target"]=85
trace_module["patterns"]="map|route|trace|location|geo|traceroute"
trace_module["lines"]=0
trace_module["covered"]=0
declare -A trace_files

declare -A core_module
core_module["assignee"]="Alaa Hosny Saber"
core_module["target"]=90
core_module["patterns"]="network|scan|core|info|services|settings|home"
core_module["lines"]=0
core_module["covered"]=0
declare -A core_files

declare -A uncategorized
uncategorized["lines"]=0
uncategorized["covered"]=0
declare -A other_files

# Initialize counters
total_lines=0
covered_lines=0
current_file=""

# Parse lcov.info file
while IFS= read -r line; do
  if [[ $line == SF:* ]]; then
    current_file="${line#SF:}"
  elif [[ $line == LF:* ]]; then
    file_lines="${line#LF:}"
    total_lines=$((total_lines + file_lines))
    
    # Try to categorize file by module
    categorized=false
    
    # Authentication module
    if [[ $current_file =~ ${auth_module["patterns"]} ]]; then
      auth_files["$current_file,lines"]=$file_lines
      auth_module["lines"]=$((auth_module["lines"] + file_lines))
      categorized=true
    # Speed test module
    elif [[ $current_file =~ ${speed_module["patterns"]} ]]; then
      speed_files["$current_file,lines"]=$file_lines
      speed_module["lines"]=$((speed_module["lines"] + file_lines))
      categorized=true
    # Traceroute module
    elif [[ $current_file =~ ${trace_module["patterns"]} ]]; then
      trace_files["$current_file,lines"]=$file_lines
      trace_module["lines"]=$((trace_module["lines"] + file_lines))
      categorized=true
    # Core module
    elif [[ $current_file =~ ${core_module["patterns"]} ]]; then
      core_files["$current_file,lines"]=$file_lines
      core_module["lines"]=$((core_module["lines"] + file_lines))
      categorized=true
    fi
    
    # If not categorized, put in uncategorized
    if [ "$categorized" = false ]; then
      other_files["$current_file,lines"]=$file_lines
      uncategorized["lines"]=$((uncategorized["lines"] + file_lines))
    fi
    
  elif [[ $line == LH:* ]]; then
    file_covered="${line#LH:}"
    covered_lines=$((covered_lines + file_covered))
    
    # Try to update module coverage
    if [[ -n "${auth_files["$current_file,lines"]}" ]]; then
      auth_files["$current_file,covered"]=$file_covered
      auth_module["covered"]=$((auth_module["covered"] + file_covered))
    elif [[ -n "${speed_files["$current_file,lines"]}" ]]; then
      speed_files["$current_file,covered"]=$file_covered
      speed_module["covered"]=$((speed_module["covered"] + file_covered))
    elif [[ -n "${trace_files["$current_file,lines"]}" ]]; then
      trace_files["$current_file,covered"]=$file_covered
      trace_module["covered"]=$((trace_module["covered"] + file_covered))
    elif [[ -n "${core_files["$current_file,lines"]}" ]]; then
      core_files["$current_file,covered"]=$file_covered
      core_module["covered"]=$((core_module["covered"] + file_covered))
    else
      other_files["$current_file,covered"]=$file_covered
      uncategorized["covered"]=$((uncategorized["covered"] + file_covered))
    fi
  fi
done < coverage/lcov.info

# Calculate total coverage percentage
total_coverage=$(calculate_percentage $covered_lines $total_lines)

# Calculate module coverage percentages
auth_coverage=$(calculate_percentage ${auth_module["covered"]} ${auth_module["lines"]})
speed_coverage=$(calculate_percentage ${speed_module["covered"]} ${speed_module["lines"]})
trace_coverage=$(calculate_percentage ${trace_module["covered"]} ${trace_module["lines"]})
core_coverage=$(calculate_percentage ${core_module["covered"]} ${core_module["lines"]})
other_coverage=$(calculate_percentage ${uncategorized["covered"]} ${uncategorized["lines"]})

# Get initials for assignees
get_initials() {
  local name=$1
  local initials=""
  for word in $name; do
    initials="$initials${word:0:1}"
  done
  echo "$initials"
}

auth_initials=$(get_initials "${auth_module["assignee"]}")
speed_initials=$(get_initials "${speed_module["assignee"]}")
trace_initials=$(get_initials "${trace_module["assignee"]}")
core_initials=$(get_initials "${core_module["assignee"]}")

# Generate gap analysis
generate_gap_message() {
  local coverage=$1
  local target=$2
  local lines=$3
  local covered=$4
  
  local gap=$(echo "$target - $coverage" | bc)
  if (( $(echo "$gap > 0" | bc -l) )); then
    local lines_to_cover=$(echo "scale=0; (($lines * $target / 100) - $covered + 0.5) / 1" | bc)
    echo "Need to cover $lines_to_cover more lines to reach target."
  else
    echo ""
  fi
}

auth_gap=$(generate_gap_message $auth_coverage ${auth_module["target"]} ${auth_module["lines"]} ${auth_module["covered"]})
speed_gap=$(generate_gap_message $speed_coverage ${speed_module["target"]} ${speed_module["lines"]} ${speed_module["covered"]})
trace_gap=$(generate_gap_message $trace_coverage ${trace_module["target"]} ${trace_module["lines"]} ${trace_module["covered"]})
core_gap=$(generate_gap_message $core_coverage ${core_module["target"]} ${core_module["lines"]} ${core_module["covered"]})

# Create module card HTML
generate_module_card() {
  local name=$1
  local coverage=$2
  local target=$3
  local assignee=$4
  local initials=$5
  local lines=$6
  local covered=$7
  local gap_message=$8
  
  local target_met="not-met"
  if (( $(echo "$coverage >= $target" | bc -l) )); then
    target_met="met"
  fi
  
  local progress_color="--danger"
  if (( $(echo "$coverage >= 80" | bc -l) )); then
    progress_color="--success"
  elif (( $(echo "$coverage >= 50" | bc -l) )); then
    progress_color="--warning"
  fi
  
  cat << EOF
<div class="module-card">
  <div class="module-header">
    <div class="module-title">$name</div>
    <div class="module-meta">
      <div class="module-assignee">
        <div class="assignee-avatar">$initials</div>
        <span>$assignee</span>
      </div>
    </div>
  </div>
                    
  <div class="module-targets">
    <div class="target-item">
      <span class="target-label">Current:</span>
      <span class="target-value $target_met">$coverage%</span>
    </div>
    <div class="target-item">
      <span class="target-label">Target:</span>
      <span class="target-value">$target%</span>
    </div>
    <div class="target-item">
      <span class="target-label">Lines:</span>
      <span class="target-value">$covered/$lines</span>
    </div>
  </div>
                    
  <div class="progress-container">
    <div class="progress">
      <div class="progress-bar" style="width: $coverage%; background-color: var($progress_color);"></div>
    </div>
    <div class="target-marker" style="left: $target%;"></div>
  </div>
                    
  <div class="gap-analysis">
    $gap_message
  </div>
</div>
EOF
}

# Create module files HTML table
generate_files_table() {
  local module_name=$1
  local files_array_name=$2
  local assignee=$3
  
  echo "<div class=\"section\">"
  echo "<div class=\"section-title\">$module_name <span class=\"assignee-tag\" style=\"background-color: var(--secondary); color: white;\">$assignee</span></div>"
  echo "<table class=\"module-table\">"
  echo "<tr><th>File</th><th>Coverage</th><th>Lines</th></tr>"
  
  # Get all files in this module
  local files=()
  local coverages=()
  local file_lines=()
  local file_covered=()
  
  for key in ${!other_files[@]}; do
    if [[ $key == *",lines" && $files_array_name == "other_files" ]]; then
      local file="${key%,lines}"
      local lines=${other_files[$key]}
      local covered=${other_files["$file,covered"]}
      
      if [ -n "$covered" ] && [ -n "$lines" ]; then
        files+=("$file")
        file_lines+=($lines)
        file_covered+=($covered)
        
        if [ "$lines" -eq 0 ]; then
          coverages+=(0)
        else
          coverages+=($(echo "scale=2; ($covered * 100) / $lines" | bc))
        fi
      fi
    elif [[ $key == *",lines" && $files_array_name == "auth_files" ]]; then
      local file="${key%,lines}"
      local lines=${auth_files[$key]}
      local covered=${auth_files["$file,covered"]}
      
      if [ -n "$covered" ] && [ -n "$lines" ]; then
        files+=("$file")
        file_lines+=($lines)
        file_covered+=($covered)
        
        if [ "$lines" -eq 0 ]; then
          coverages+=(0)
        else
          coverages+=($(echo "scale=2; ($covered * 100) / $lines" | bc))
        fi
      fi
    elif [[ $key == *",lines" && $files_array_name == "speed_files" ]]; then
      local file="${key%,lines}"
      local lines=${speed_files[$key]}
      local covered=${speed_files["$file,covered"]}
      
      if [ -n "$covered" ] && [ -n "$lines" ]; then
        files+=("$file")
        file_lines+=($lines)
        file_covered+=($covered)
        
        if [ "$lines" -eq 0 ]; then
          coverages+=(0)
        else
          coverages+=($(echo "scale=2; ($covered * 100) / $lines" | bc))
        fi
      fi
    elif [[ $key == *",lines" && $files_array_name == "trace_files" ]]; then
      local file="${key%,lines}"
      local lines=${trace_files[$key]}
      local covered=${trace_files["$file,covered"]}
      
      if [ -n "$covered" ] && [ -n "$lines" ]; then
        files+=("$file")
        file_lines+=($lines)
        file_covered+=($covered)
        
        if [ "$lines" -eq 0 ]; then
          coverages+=(0)
        else
          coverages+=($(echo "scale=2; ($covered * 100) / $lines" | bc))
        fi
      fi
    elif [[ $key == *",lines" && $files_array_name == "core_files" ]]; then
      local file="${key%,lines}"
      local lines=${core_files[$key]}
      local covered=${core_files["$file,covered"]}
      
      if [ -n "$covered" ] && [ -n "$lines" ]; then
        files+=("$file")
        file_lines+=($lines)
        file_covered+=($covered)
        
        if [ "$lines" -eq 0 ]; then
          coverages+=(0)
        else
          coverages+=($(echo "scale=2; ($covered * 100) / $lines" | bc))
        fi
      fi
    fi
  done
  
  # Now output each file row
  for ((i=0; i<${#files[@]}; i++)); do
    local file="${files[$i]}"
    local coverage="${coverages[$i]}"
    local lines="${file_lines[$i]}"
    local covered="${file_covered[$i]}"
    local filename=$(basename "$file")
    
    local class="low"
    if (( $(echo "$coverage >= 80" | bc -l) )); then
      class="high"
    elif (( $(echo "$coverage >= 50" | bc -l) )); then
      class="medium"
    fi
    
    echo "<tr class=\"$class\">"
    echo "<td class=\"file-path\" title=\"$file\">$filename</td>"
    echo "<td>"
    echo "<div class=\"coverage-cell\">"
    echo "<div class=\"coverage-bar\">"
    echo "<div class=\"coverage-bar-fill\" style=\"width: $coverage%;\"></div>"
    echo "</div>"
    echo "<div class=\"coverage-percentage\">$coverage%</div>"
    echo "</div>"
    echo "</td>"
    echo "<td class=\"coverage-details\">$covered/$lines</td>"
    echo "</tr>"
  done
  
  echo "</table>"
  echo "</div>"
}

# Generate HTML file
cat > coverage-report.html << EOF
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

        <div class="summary-box">
            <div class="summary-stat">
                <div class="summary-stat-value">$total_lines</div>
                <div class="summary-stat-label">Total Lines</div>
            </div>
            
            <div class="summary-stat">
                <div class="coverage-gauge">
                    <div class="gauge-fill" style="--percentage: ${total_coverage}%;"></div>
                    <div class="gauge-center">
                        <div class="gauge-percentage">$total_coverage%</div>
                        <div class="gauge-label">Coverage</div>
                    </div>
                </div>
            </div>
            
            <div class="summary-stat">
                <div class="summary-stat-value">$covered_lines</div>
                <div class="summary-stat-label">Covered Lines</div>
            </div>
        </div>
        
        <div class="section">
            <div class="section-title">Coverage by Module</div>
            <div class="module-grid">
$(generate_module_card "Authentication & User Management" "$auth_coverage" "${auth_module["target"]}" "${auth_module["assignee"]}" "$auth_initials" "${auth_module["lines"]}" "${auth_module["covered"]}" "$auth_gap")
$(generate_module_card "Speed Test & Results" "$speed_coverage" "${speed_module["target"]}" "${speed_module["assignee"]}" "$speed_initials" "${speed_module["lines"]}" "${speed_module["covered"]}" "$speed_gap")
$(generate_module_card "Traceroute & Map Features" "$trace_coverage" "${trace_module["target"]}" "${trace_module["assignee"]}" "$trace_initials" "${trace_module["lines"]}" "${trace_module["covered"]}" "$trace_gap")
$(generate_module_card "Core Features & Network Scanner" "$core_coverage" "${core_module["target"]}" "${core_module["assignee"]}" "$core_initials" "${core_module["lines"]}" "${core_module["covered"]}" "$core_gap")
            </div>
        </div>
        
$(generate_files_table "Authentication & User Management" "auth_files" "${auth_module["assignee"]}")
$(generate_files_table "Speed Test & Results" "speed_files" "${speed_module["assignee"]}")
$(generate_files_table "Traceroute & Map Features" "trace_files" "${trace_module["assignee"]}")
$(generate_files_table "Core Features & Network Scanner" "core_files" "${core_module["assignee"]}")
$(generate_files_table "Other Files" "other_files" "")

        <footer>
            Netscope Coverage Report | Generated on $(date) | Flutter Test Coverage
        </footer>
    </div>
</body>
</html>
EOF

echo "Report generated: coverage-report.html"
#!/bin/bash
# NetScope test runner script

# Function to display usage
function show_usage() {
  echo "NetScope Test Runner"
  echo "-------------------"
  echo "Usage:"
  echo "  run_tests.sh [options]"
  echo ""
  echo "Options:"
  echo "  --all           Run all tests"
  echo "  --unit          Run only unit tests"
  echo "  --widget        Run only widget tests"
  echo "  --integration   Run only integration tests"
  echo "  --coverage      Generate coverage report"
  echo "  --help          Show this help message"
  echo ""
  echo "Examples:"
  echo "  run_tests.sh --unit"
  echo "  run_tests.sh --coverage --widget"
  echo "  run_tests.sh --all --coverage"
}

# Default options
RUN_UNIT=0
RUN_WIDGET=0
RUN_INTEGRATION=0
GENERATE_COVERAGE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --all)
      RUN_UNIT=1
      RUN_WIDGET=1
      RUN_INTEGRATION=1
      shift
      ;;
    --unit)
      RUN_UNIT=1
      shift
      ;;
    --widget)
      RUN_WIDGET=1
      shift
      ;;
    --integration)
      RUN_INTEGRATION=1
      shift
      ;;
    --coverage)
      GENERATE_COVERAGE=1
      shift
      ;;
    --help)
      show_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $key"
      show_usage
      exit 1
      ;;
  esac
done

# If no test type specified, run all
if [[ $RUN_UNIT -eq 0 && $RUN_WIDGET -eq 0 && $RUN_INTEGRATION -eq 0 ]]; then
  RUN_UNIT=1
  RUN_WIDGET=1
  RUN_INTEGRATION=1
fi

echo "NetScope Test Runner"
echo "-------------------"

# Function to run tests with or without coverage
function run_tests() {
  if [[ $GENERATE_COVERAGE -eq 1 ]]; then
    echo "Running tests with coverage: $1"
    flutter test $1 --coverage
  else
    echo "Running tests: $1"
    flutter test $1
  fi
}

# Run unit tests
if [[ $RUN_UNIT -eq 1 ]]; then
  echo "Running unit tests..."
  run_tests "test/unit/"
fi

# Run widget tests
if [[ $RUN_WIDGET -eq 1 ]]; then
  echo "Running widget tests..."
  run_tests "test/widget/"
fi

# Run integration tests
if [[ $RUN_INTEGRATION -eq 1 ]]; then
  echo "Running integration tests..."
  run_tests "test/integration/"
fi

# Generate coverage report if requested
if [[ $GENERATE_COVERAGE -eq 1 ]]; then
  echo "Generating coverage report..."
  
  # Check if lcov is installed
  if command -v lcov >/dev/null 2>&1; then
    # Generate HTML report
    genhtml coverage/lcov.info -o coverage/html
    
    echo "Coverage report generated in coverage/html/index.html"
  else
    echo "lcov not found. Please install lcov to generate HTML coverage reports."
    echo "Raw coverage data available in coverage/lcov.info"
  fi
fi

echo "Testing complete!"

#!/bin/bash

# Aux iOS App Build and Deployment Script
# Automates the build, archive, and App Store submission process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCHEME="Aux"
CONFIGURATION="Release"
WORKSPACE="src/app/ios/Aux/Aux.xcodeproj/project.xcworkspace"
PROJECT="src/app/ios/Aux/Aux.xcodeproj"
BUNDLE_ID="com.elcruzo.aux"

# Directories
BUILD_DIR="build"
ARCHIVE_DIR="$BUILD_DIR/archives"
EXPORT_DIR="$BUILD_DIR/exports"
LOGS_DIR="$BUILD_DIR/logs"

# Create directories
mkdir -p "$ARCHIVE_DIR" "$EXPORT_DIR" "$LOGS_DIR"

echo -e "${BLUE}🚀 Starting Aux iOS Build Process${NC}"
echo "=================================="

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}$1${NC}"
    echo "$(printf '%.0s-' {1..50})"
}

# Function to check command success
check_command() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1 successful${NC}"
    else
        echo -e "${RED}❌ $1 failed${NC}"
        exit 1
    fi
}

# Function to bump version
bump_version() {
    local bump_type=$1
    print_section "Bumping Version ($bump_type)"
    
    # Get current version
    CURRENT_VERSION=$(xcodebuild -project "$PROJECT" -showBuildSettings | grep -m1 "MARKETING_VERSION" | awk '{print $3}')
    BUILD_NUMBER=$(xcodebuild -project "$PROJECT" -showBuildSettings | grep -m1 "CURRENT_PROJECT_VERSION" | awk '{print $3}')
    
    echo "Current Version: $CURRENT_VERSION ($BUILD_NUMBER)"
    
    # Increment build number
    NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
    
    # Update build number
    xcrun agvtool new-version -all $NEW_BUILD_NUMBER > /dev/null 2>&1
    
    echo -e "${GREEN}Version updated: $CURRENT_VERSION ($NEW_BUILD_NUMBER)${NC}"
}

# Function to validate environment
validate_environment() {
    print_section "Validating Environment"
    
    # Check Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        echo -e "${RED}❌ Xcode command line tools not installed${NC}"
        exit 1
    fi
    
    # Check if we're in the right directory
    if [ ! -f "$PROJECT" ]; then
        echo -e "${RED}❌ Xcode project not found at $PROJECT${NC}"
        exit 1
    fi
    
    # Check for required certificates
    echo "Checking certificates..."
    security find-identity -v -p codesigning | grep "Apple Distribution" > /dev/null
    check_command "Certificate validation"
    
    echo -e "${GREEN}✅ Environment validation complete${NC}"
}

# Function to clean build
clean_build() {
    print_section "Cleaning Build"
    
    xcodebuild clean \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        > "$LOGS_DIR/clean.log" 2>&1
    
    check_command "Clean"
    
    # Remove derived data
    rm -rf ~/Library/Developer/Xcode/DerivedData/Aux-*
    echo -e "${GREEN}✅ Derived data cleared${NC}"
}

# Function to run tests
run_tests() {
    print_section "Running Tests"
    
    echo "Running unit tests..."
    xcodebuild test \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
        > "$LOGS_DIR/tests.log" 2>&1
    
    check_command "Unit tests"
    
    echo -e "${GREEN}✅ All tests passed${NC}"
}

# Function to build and archive
build_and_archive() {
    print_section "Building and Archiving"
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local archive_path="$ARCHIVE_DIR/Aux_$timestamp.xcarchive"
    
    echo "Creating archive..."
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -archivePath "$archive_path" \
        -allowProvisioningUpdates \
        CODE_SIGN_STYLE="Automatic" \
        > "$LOGS_DIR/archive.log" 2>&1
    
    check_command "Archive creation"
    
    echo "Archive created at: $archive_path"
    echo "$archive_path" > "$BUILD_DIR/latest_archive.txt"
}

# Function to export for App Store
export_for_appstore() {
    print_section "Exporting for App Store"
    
    local archive_path=$(cat "$BUILD_DIR/latest_archive.txt")
    local export_path="$EXPORT_DIR/AppStore"
    
    # Create export options plist
    cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>export</string>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>\$(DEVELOPMENT_TEAM)</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF
    
    echo "Exporting archive..."
    xcodebuild -exportArchive \
        -archivePath "$archive_path" \
        -exportPath "$export_path" \
        -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
        > "$LOGS_DIR/export.log" 2>&1
    
    check_command "App Store export"
    
    echo "Export completed at: $export_path"
    echo "$export_path/Aux.ipa" > "$BUILD_DIR/latest_ipa.txt"
}

# Function to validate app
validate_app() {
    print_section "Validating App"
    
    local ipa_path=$(cat "$BUILD_DIR/latest_ipa.txt")
    
    echo "Validating IPA..."
    xcrun altool --validate-app \
        -f "$ipa_path" \
        -t ios \
        --apiKey "$APP_STORE_CONNECT_API_KEY" \
        --apiIssuer "$APP_STORE_CONNECT_ISSUER" \
        > "$LOGS_DIR/validation.log" 2>&1
    
    check_command "App validation"
}

# Function to upload to App Store Connect
upload_to_appstore() {
    print_section "Uploading to App Store Connect"
    
    local ipa_path=$(cat "$BUILD_DIR/latest_ipa.txt")
    
    echo "Uploading to App Store Connect..."
    xcrun altool --upload-app \
        -f "$ipa_path" \
        -t ios \
        --apiKey "$APP_STORE_CONNECT_API_KEY" \
        --apiIssuer "$APP_STORE_CONNECT_ISSUER" \
        > "$LOGS_DIR/upload.log" 2>&1
    
    check_command "App Store upload"
    
    echo -e "${GREEN}🎉 Upload completed successfully!${NC}"
    echo "Your app should appear in App Store Connect within 10-15 minutes."
}

# Function to create TestFlight build
upload_to_testflight() {
    print_section "Uploading to TestFlight"
    
    local ipa_path=$(cat "$BUILD_DIR/latest_ipa.txt")
    
    echo "Uploading to TestFlight..."
    xcrun altool --upload-app \
        -f "$ipa_path" \
        -t ios \
        --apiKey "$APP_STORE_CONNECT_API_KEY" \
        --apiIssuer "$APP_STORE_CONNECT_ISSUER" \
        > "$LOGS_DIR/testflight.log" 2>&1
    
    check_command "TestFlight upload"
    
    echo -e "${GREEN}🧪 TestFlight upload completed!${NC}"
}

# Function to generate build report
generate_report() {
    print_section "Generating Build Report"
    
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local version=$(cat "$BUILD_DIR/latest_archive.txt" | xargs xcodebuild -exportArchive -archivePath | grep "MARKETING_VERSION" || echo "Unknown")
    
    cat > "$BUILD_DIR/build_report.txt" << EOF
AUX iOS BUILD REPORT
===================

Build Date: $timestamp
Version: $version
Configuration: $CONFIGURATION
Scheme: $SCHEME

Files Generated:
- Archive: $(cat "$BUILD_DIR/latest_archive.txt" 2>/dev/null || echo "Not created")
- IPA: $(cat "$BUILD_DIR/latest_ipa.txt" 2>/dev/null || echo "Not created")

Build Logs:
- Clean: $LOGS_DIR/clean.log
- Tests: $LOGS_DIR/tests.log
- Archive: $LOGS_DIR/archive.log
- Export: $LOGS_DIR/export.log
- Validation: $LOGS_DIR/validation.log
- Upload: $LOGS_DIR/upload.log

Next Steps:
1. Check App Store Connect for build processing
2. Submit for App Store review if ready
3. Configure TestFlight groups if using beta testing
EOF
    
    echo -e "${GREEN}📊 Build report generated: $BUILD_DIR/build_report.txt${NC}"
    cat "$BUILD_DIR/build_report.txt"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --clean-only          Only clean the build"
    echo "  --test-only           Only run tests"
    echo "  --build-only          Only build and archive"
    echo "  --testflight          Upload to TestFlight"
    echo "  --app-store           Upload to App Store"
    echo "  --full                Complete build and App Store submission"
    echo "  --skip-tests          Skip running tests"
    echo "  --skip-validation     Skip app validation"
    echo "  --bump-version TYPE   Bump version (patch/minor/major)"
    echo "  --help                Show this help message"
    echo ""
    echo "Environment Variables Required:"
    echo "  APP_STORE_CONNECT_API_KEY    - App Store Connect API Key ID"
    echo "  APP_STORE_CONNECT_ISSUER     - App Store Connect Issuer ID"
    echo ""
    echo "Examples:"
    echo "  $0 --testflight              # Build and upload to TestFlight"
    echo "  $0 --full --bump-version patch   # Full build with version bump"
    echo "  $0 --build-only              # Just build and archive"
}

# Main execution
main() {
    local clean_only=false
    local test_only=false
    local build_only=false
    local testflight=false
    local app_store=false
    local full_build=false
    local skip_tests=false
    local skip_validation=false
    local bump_version_type=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean-only)
                clean_only=true
                shift
                ;;
            --test-only)
                test_only=true
                shift
                ;;
            --build-only)
                build_only=true
                shift
                ;;
            --testflight)
                testflight=true
                shift
                ;;
            --app-store)
                app_store=true
                shift
                ;;
            --full)
                full_build=true
                shift
                ;;
            --skip-tests)
                skip_tests=true
                shift
                ;;
            --skip-validation)
                skip_validation=true
                shift
                ;;
            --bump-version)
                bump_version_type="$2"
                shift 2
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check required environment variables for uploads
    if [[ "$testflight" == true || "$app_store" == true || "$full_build" == true ]]; then
        if [[ -z "$APP_STORE_CONNECT_API_KEY" || -z "$APP_STORE_CONNECT_ISSUER" ]]; then
            echo -e "${RED}❌ Missing required environment variables for App Store Connect${NC}"
            echo "Please set APP_STORE_CONNECT_API_KEY and APP_STORE_CONNECT_ISSUER"
            exit 1
        fi
    fi
    
    # Execute based on options
    if [[ "$clean_only" == true ]]; then
        validate_environment
        clean_build
    elif [[ "$test_only" == true ]]; then
        validate_environment
        run_tests
    elif [[ "$build_only" == true ]]; then
        validate_environment
        if [[ -n "$bump_version_type" ]]; then
            bump_version "$bump_version_type"
        fi
        clean_build
        if [[ "$skip_tests" == false ]]; then
            run_tests
        fi
        build_and_archive
        export_for_appstore
    elif [[ "$testflight" == true ]]; then
        validate_environment
        if [[ -n "$bump_version_type" ]]; then
            bump_version "$bump_version_type"
        fi
        clean_build
        if [[ "$skip_tests" == false ]]; then
            run_tests
        fi
        build_and_archive
        export_for_appstore
        if [[ "$skip_validation" == false ]]; then
            validate_app
        fi
        upload_to_testflight
        generate_report
    elif [[ "$app_store" == true || "$full_build" == true ]]; then
        validate_environment
        if [[ -n "$bump_version_type" ]]; then
            bump_version "$bump_version_type"
        fi
        clean_build
        if [[ "$skip_tests" == false ]]; then
            run_tests
        fi
        build_and_archive
        export_for_appstore
        if [[ "$skip_validation" == false ]]; then
            validate_app
        fi
        upload_to_appstore
        generate_report
    else
        echo -e "${YELLOW}No action specified. Use --help for usage information.${NC}"
        show_usage
        exit 1
    fi
    
    echo -e "\n${GREEN}🎉 Build process completed successfully!${NC}"
}

# Run main function with all arguments
main "$@"
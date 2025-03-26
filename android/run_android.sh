#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Android app...${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter is not installed. Please install Flutter first.${NC}"
    exit 1
fi

# Check if Android Studio is installed
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Android Debug Bridge (adb) is not installed. Please install Android Studio first.${NC}"
    exit 1
fi

# Function to check if an emulator is running
check_emulator() {
    adb devices | grep -q "emulator"
    return $?
}

# Function to start an emulator
start_emulator() {
    echo -e "${YELLOW}No emulator found. Starting a new emulator...${NC}"
    
    # List available emulators
    echo "Available emulators:"
    flutter emulators
    
    # Start the first available emulator
    flutter emulators --launch $(flutter emulators | grep -o '^[^ ]*' | head -n 1)
    
    # Wait for emulator to start
    echo -e "${YELLOW}Waiting for emulator to start...${NC}"
    while ! check_emulator; do
        sleep 2
        echo -n "."
    done
    echo -e "\n${GREEN}Emulator is ready!${NC}"
}

# Check if an emulator is running
if ! check_emulator; then
    start_emulator
fi

# Get the emulator device ID
DEVICE_ID=$(adb devices | grep "emulator" | cut -f1)

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}No emulator device found. Please start an emulator manually.${NC}"
    exit 1
fi

echo -e "${GREEN}Running app on emulator: $DEVICE_ID${NC}"

# Clean the project
echo -e "${YELLOW}Cleaning project...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Run the app
echo -e "${GREEN}Starting the app...${NC}"
flutter run -d $DEVICE_ID

# Handle any errors
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to run the app. Please check the error messages above.${NC}"
    exit 1
fi

cd E:\Calendar_Project\calendar_app 
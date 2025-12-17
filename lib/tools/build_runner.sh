#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting build process...${NC}"

# Clean build
echo -e "${GREEN}Cleaning build...${NC}"
flutter clean

# Get dependencies
echo -e "${GREEN}Getting dependencies...${NC}"
flutter pub get

# Generate routes
echo -e "${GREEN}Generating routes...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs

# Generate translations
echo -e "${GREEN}Generating translations...${NC}"
# Add translation generation commands here

# Build for different platforms
case $1 in
  "android")
    echo -e "${GREEN}Building for Android...${NC}"
    flutter build apk --release
    ;;
  "ios")
    echo -e "${GREEN}Building for iOS...${NC}"
    flutter build ios --release
    ;;
  "web")
    echo -e "${GREEN}Building for Web...${NC}"
    flutter build web --release
    ;;
  *)
    echo -e "${GREEN}Building app...${NC}"
    flutter build apk --release
    ;;
esac

echo -e "${GREEN}Build completed successfully!${NC}"
#!/bin/bash

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "🔧 Building Stretch Reminder App..."

# 1. Swift Package 빌드
echo -e "${YELLOW}Building Swift package...${NC}"
swift build -c release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"

# 2. 앱 번들 디렉토리 구조 생성
echo -e "${YELLOW}Creating app bundle...${NC}"

APP_NAME="StretchReminder.app"
APP_DIR="build/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# 기존 빌드 정리
rm -rf build
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 3. 실행 파일 복사
cp .build/release/StretchReminder "$MACOS_DIR/"

# 4. Info.plist 복사
cp Info.plist "$CONTENTS_DIR/"

# 5. 아이콘 생성 (기본 아이콘)
echo -e "${YELLOW}Creating app icon...${NC}"

# 간단한 아이콘 생성 (iconutil이 있는 경우)
ICONSET_DIR="$RESOURCES_DIR/AppIcon.iconset"
mkdir -p "$ICONSET_DIR"

# SVG를 사용하여 다양한 크기의 아이콘 생성
for size in 16 32 64 128 256 512; do
    size2x=$((size * 2))

    # sips 명령을 사용하여 기본 이미지 생성 (macOS 내장)
    # 단색 아이콘을 생성
    echo "P3 $size $size 255" > "/tmp/icon_$size.ppm"
    for ((i=0; i<size*size; i++)); do
        # 보라색 그라데이션 효과
        echo "128 0 255" >> "/tmp/icon_$size.ppm"
    done

    sips -s format png "/tmp/icon_$size.ppm" --out "$ICONSET_DIR/icon_${size}x${size}.png" 2>/dev/null

    if [ $size -ne 512 ]; then
        echo "P3 $size2x $size2x 255" > "/tmp/icon_${size2x}.ppm"
        for ((i=0; i<size2x*size2x; i++)); do
            echo "128 0 255" >> "/tmp/icon_${size2x}.ppm"
        done
        sips -s format png "/tmp/icon_${size2x}.ppm" --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" 2>/dev/null
    fi
done

# iconutil을 사용하여 .icns 파일 생성
if command -v iconutil &> /dev/null; then
    iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns" 2>/dev/null
    rm -rf "$ICONSET_DIR"
fi

# 6. 실행 권한 설정
chmod +x "$MACOS_DIR/StretchReminder"

# 7. 코드 서명 (선택사항 - 개발자 인증서가 있는 경우)
if security find-identity -p codesigning &>/dev/null; then
    echo -e "${YELLOW}Code signing...${NC}"
    codesign --force --deep --sign - "$APP_DIR"
fi

echo -e "${GREEN}✅ App bundle created successfully!${NC}"
echo -e "${GREEN}📦 Location: $(pwd)/build/$APP_NAME${NC}"
echo ""
echo "To run the app:"
echo "  1. Open Finder and navigate to $(pwd)/build/"
echo "  2. Double-click on $APP_NAME"
echo "  OR"
echo "  Run: open build/$APP_NAME"
echo ""
echo "To install to Applications:"
echo "  cp -r build/$APP_NAME /Applications/"
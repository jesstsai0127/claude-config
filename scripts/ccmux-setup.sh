#!/bin/bash
# ccmux-setup.sh
# 安裝 Shin-sibainu/ccmux（單機 UI friendly terminal multiplexer）
# 用於人在電腦前時，取代原生 terminal 操作 Claude Code

set -e

echo "📦 安裝 ccmux（Rust 版，跨平台單一 binary）..."

OS="$(uname -s)"
case "$OS" in
  Linux*)
    echo "偵測到 Linux，下載對應 binary..."
    curl -fsSL https://github.com/Shin-sibainu/ccmux/releases/latest/download/ccmux-linux-x64.tar.gz | tar xz
    sudo mv ccmux /usr/local/bin/
    ;;
  Darwin*)
    echo "偵測到 macOS..."
    curl -fsSL https://github.com/Shin-sibainu/ccmux/releases/latest/download/ccmux-macos.tar.gz | tar xz
    sudo mv ccmux /usr/local/bin/
    ;;
  *)
    echo "⚠️  未自動偵測到對應平台，請至以下網址手動下載："
    echo "    https://github.com/Shin-sibainu/ccmux/releases"
    exit 1
    ;;
esac

echo "✅ ccmux 安裝完成"
echo ""
echo "使用方式："
echo "  cd 你的專案資料夾"
echo "  ccmux            # 啟動，會自動帶 file tree sidebar 與 status bar"
echo ""
echo "提醒：當 Claude Code 正在執行任務時，該 pane 邊框會變橘色，"
echo "      不需要切換視窗確認，一眼就能看到哪個 session 在忙"

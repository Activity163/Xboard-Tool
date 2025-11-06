#!/bin/bash
# 一键安装 cloudflared 并注册服务
# 用法: ./install_cloudflared.sh <TOKEN>

set -e

TOKEN="$1"

if [ -z "$TOKEN" ]; then
  echo "❌ 请提供 cloudflared 的安装令牌"
  echo "用法: $0 <TOKEN>"
  exit 1
fi

echo "▶️ 检查 cloudflared 是否已安装..."
if command -v cloudflared >/dev/null 2>&1; then
  echo "✅ 已检测到 cloudflared，跳过安装步骤"
else
  echo "▶️ 添加 Cloudflare GPG key..."
  sudo mkdir -p --mode=0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg \
    | sudo tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

  echo "▶️ 添加 Cloudflare apt 仓库..."
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main" \
    | sudo tee /etc/apt/sources.list.d/cloudflared.list

  echo "▶️ 更新并安装 cloudflared..."
  sudo apt-get update && sudo apt-get install -y cloudflared
fi

echo "▶️ 注册 cloudflared 服务..."
sudo cloudflared service install "$TOKEN"

echo "▶️ 设置 cloudflared 服务开机自启..."
sudo systemctl enable cloudflared

echo "▶️ 检查 cloudflared 服务状态..."
if systemctl is-active --quiet cloudflared; then
  echo "✅ cloudflared 服务正在运行"
else
  echo "⚠️ cloudflared 服务未运行，尝试启动..."
  sudo systemctl restart cloudflared
  if systemctl is-active --quiet cloudflared; then
    echo "✅ cloudflared 服务已成功启动"
  else
    echo "❌ 启动 cloudflared 服务失败，请手动检查日志："
    echo "   sudo journalctl -u cloudflared -f"
  fi
fi

echo "🎉 全部完成！cloudflared 已安装并配置为开机自启"

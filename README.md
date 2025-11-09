# 🚀 Xboard-Tool.sh + Cloudflare Tunnel

基于 **Docker** 的一键部署脚本，快速安装并运行 **Xboard 管理面板**。  
搭配 **Cloudflare Tunnel 自动安装脚本**，无需 Nginx，即可实现端口反代、自动 SSL 部署，享受 **Cloudflare 全球加速**。

## 📖 功能亮点
  - 🐳 **Docker 一键部署**：自动检测并安装 Docker  
  - 🔒 **自动 SSL**：无需手动证书挂载，Cloudflare 隧道自动配置  
  - 🌍 **全球加速**：借助 Cloudflare 网络提升访问速度与稳定性  
  - ⚡ **免 Nginx**：直接通过隧道完成反向代理  
  - 💾 **数据库备份**：自动输出至 `/root/SQL`  

## 🛠️ 使用方法

### 1️⃣ 部署 Xboard 管理面板
```bash
# 下载脚本
wget https://raw.githubusercontent.com/Activity163/Xboard-Tool/refs/heads/main/Xboard-Tool.sh

# 添加执行权限
chmod +x Xboard-Tool.sh

# 运行脚本
./Xboard-Tool.sh

```

- 默认管理员邮箱：`admin@demo.com`  
- 安装前请确认 `/root` 目录下不存在 `xboard` 文件夹，如存在请删除

### 2️⃣ 安装 Cloudflare Tunnel
```bash
# 下载脚本
wget https://raw.githubusercontent.com/Activity163/Xboard-Tool/refs/heads/main/Install-CloudFlare-Tunnels.sh

# 添加执行权限
chmod +x install_cloudflared.sh

# 运行脚本（需提供 Cloudflare TOKEN）
./install_cloudflared.sh <TOKEN>

```

脚本会自动完成以下操作：  

- 🔍 检查并安装 cloudflared
- 📝 注册服务并配置开机自启
- ▶️ 启动并验证服务状态
## 📂 目录结构

```text
/root
 ├── xboard        # Xboard 管理面板目录
 └── SQL           # 数据库备份目录
```

## 🌟 组合效果
  - **Xboard-Tool.sh**：快速部署管理面板
  - **install_cloudflared.sh**：自动反代端口 + SSL 部署
  - 组合使用：无需 Nginx，即可实现安全、稳定、全球加速的访问体验

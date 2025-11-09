# 🚀 Xboard-Tool.sh

基于 **Docker** 的一键部署脚本，快速安装并运行 **Xboard 管理面板**。  
无需繁琐配置，脚本自动检测环境，助你轻松完成部署。

---

## 📖 使用说明

- ✅ 脚本自带 **Docker 安装检测**，无需手动安装 Docker  
- ⚠️ 安装前请确认 `/root` 目录下不存在 `xboard` 文件夹，如存在请删除  
- 👤 默认管理员邮箱：`admin@demo.com`  
- 💾 数据库备份输出目录：`/root/SQL`

---

## 🛠️ 快速开始

```bash
# 下载脚本
wget https://your-repo-url/Xboard-Tool.sh

# 添加执行权限
chmod +x Xboard-Tool.sh

# 运行脚本
./Xboard-Tool.sh

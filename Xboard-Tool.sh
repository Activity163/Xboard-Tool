#!/bin/bash
set -e

echo "=============================="
echo " Xboard 一键安装/卸载/数据库管理脚本"
echo "=============================="
echo "1) 安装 Xboard"
echo "2) 卸载 Xboard"
echo "3) 数据库管理"
read -p "请选择操作 (1/2/3): " choice

# =========================
# 卸载流程
# =========================
if [ "$choice" = "2" ]; then
    echo ">>> 卸载选项:"
    echo "   1) 只卸载 Xboard (保留 Docker)"
    echo "   2) 卸载 Xboard + Docker (彻底清理)"
    read -p "请选择卸载方式 (1/2): " uninstall_choice

    if [ "$uninstall_choice" = "1" ]; then
        echo ">>> 开始卸载 Xboard (保留 Docker)..."
        cd ~/xboard || true
        docker compose down -v || true
        rm -rf ~/xboard
        echo ">>> 已卸载 Xboard，Docker 环境保留。"
        exit 0
    fi

    if [ "$uninstall_choice" = "2" ]; then
        echo ">>> 开始彻底卸载 Xboard 和 Docker..."
        if command -v docker &>/dev/null; then
            docker compose down -v || true
            docker stop $(docker ps -aq) || true
            docker rm -f $(docker ps -aq) || true
            docker rmi -f $(docker images -q) || true
            docker volume rm $(docker volume ls -q) || true
            docker network rm $(docker network ls -q) || true
        fi
        rm -rf ~/xboard
        apt-get remove --purge -y docker docker-engine docker.io containerd runc docker-compose-plugin
        apt-get autoremove -y
        apt-get autoclean -y
        echo ">>> 已彻底卸载 Xboard 和 Docker。"
        exit 0
    fi
fi

# =========================
# 数据库管理
# =========================
if [ "$choice" = "3" ]; then
    echo ">>> 数据库管理选项:"
    echo "   1) 备份数据库"
    echo "   2) 恢复数据库"
    read -p "请选择操作 (1/2): " db_choice

    CONTAINER_NAME=$(docker compose ps -q web | xargs docker inspect --format '{{.Name}}' | sed 's/^\///')
    if [ -z "$CONTAINER_NAME" ]; then
        echo ">>> 未检测到 web 容器，请确认服务已启动"
        exit 1
    fi

    DB_PATH=$(docker exec -i "$CONTAINER_NAME" sh -c "grep DB_DATABASE /www/.env | cut -d '=' -f2" || true)
    if [ -z "$DB_PATH" ]; then
        DB_PATH="/www/.docker/.data/database.sqlite"
    fi
    if [[ "$DB_PATH" != /* ]]; then
        DB_PATH="/www/$DB_PATH"
    fi

    if [ "$db_choice" = "1" ]; then
        echo ">>> 开始备份数据库..."
        mkdir -p /root/SQL
        BACKUP_FILE="/root/SQL/database_$(date +%F).sqlite"
        docker cp "$CONTAINER_NAME":"$DB_PATH" "$BACKUP_FILE"
        echo ">>> 数据库已备份到 $BACKUP_FILE"
        exit 0
    fi

    if [ "$db_choice" = "2" ]; then
        read -p "请输入要恢复的数据库备份文件路径: " backup_path
        if [ -f "$backup_path" ]; then
            echo ">>> 恢复数据库中..."
            docker cp "$backup_path" "$CONTAINER_NAME":"$DB_PATH"
            echo ">>> 执行数据库迁移..."
            docker compose exec web php artisan migrate || true
            echo ">>> 重启服务..."
            docker compose restart web
            echo ">>> 数据库已恢复成功！"
        else
            echo ">>> 提供的路径无效，未找到文件。"
        fi
        exit 0
    fi
fi

# =========================
# 安装流程
# =========================
if [ "$choice" = "1" ]; then
    echo ">>> 更新系统依赖..."
    apt update -y && apt install -y wget curl git sudo

    echo ">>> 检查 Docker 是否已安装..."
    if ! command -v docker &>/dev/null; then
        echo ">>> 未检测到 Docker，开始安装..."
        curl -fsSL https://get.docker.com | bash -s docker
    else
        echo ">>> 已检测到 Docker，跳过安装。"
    fi

    echo ">>> 检查 Docker Compose 插件是否已安装..."
    if ! docker compose version &>/dev/null; then
        echo ">>> 未检测到 Docker Compose 插件，开始安装..."
        apt install -y docker-compose-plugin
    else
        echo ">>> 已检测到 Docker Compose 插件，跳过安装。"
    fi

    echo ">>> 克隆 Xboard 项目 (compose 分支)..."
    if [ ! -d "./xboard" ]; then
        git clone -b compose --depth 1 https://github.com/cedar2025/Xboard ./xboard
    else
        echo ">>> 已存在 xboard 目录，跳过克隆。"
    fi

    cd xboard

    echo ">>> 执行安装命令..."
    docker compose run -it --rm \
        -e ENABLE_SQLITE=true \
        -e ENABLE_REDIS=true \
        -e ADMIN_ACCOUNT=admin@demo.com \
        web php artisan xboard:install

    echo ">>> 启动服务..."
    docker compose up -d

    echo ">>> 安装流程完成！"
fi

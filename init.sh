#!/bin/bash
# init.sh — 从 tpl-app 模板初始化一个新项目
#
# 用法:
#   ./init.sh <app-name> [gitee-user]
#
# 示例:
#   ./init.sh investment sunmoonlion
#
# 效果:
#   - 在四个子模块内将 tpl / Tpl / TPL 替换为 <app-name>
#   - 重命名四个子模块目录，并修正各子模块 .git 指针
#   - 更新 .gitmodules 中的远程 URL
#   - 完成后需手动将父目录 tpl-app 重命名为 <app-name>-app

set -e

APP_NAME="$1"
GITEE_USER="${2:-sunmoonlion}"

if [ -z "$APP_NAME" ]; then
  echo "用法: ./init.sh <app-name> [gitee-user]"
  echo "示例: ./init.sh investment sunmoonlion"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo ">>> 初始化项目: $APP_NAME (Gitee 用户: $GITEE_USER)"

# 1. 替换四个子模块内部文件中的 tpl → app-name
echo ">>> [1/4] 替换子模块内部文件..."
for dir in tpl-admin-frontend tpl-web-backend tpl-web-frontend tpl-admin-backend; do
  find "$SCRIPT_DIR/$dir" -type f \
    ! -path "*/.git" \
    ! -path "*/.git/*" \
    ! -name "*.lock" \
    ! -name "pnpm-lock.yaml" \
    ! -name "CHANGELOG.md" \
    | while read -r file; do
        if grep -qE 'tpl|TPL|Tpl' "$file" 2>/dev/null; then
          sed -i \
            -e "s/TPL/${APP_NAME^^}/g" \
            -e "s/Tpl/${APP_NAME^}/g" \
            -e "s/tpl/${APP_NAME}/g" \
            "$file"
        fi
      done
  echo "    done: $dir"
done

# 1b. 替换父仓根目录文件中的 tpl → app-name（README、.mdc 规则、CLAUDE.md 等）
echo ">>> [1b/4] 替换父仓根目录文件..."
find "$SCRIPT_DIR" -maxdepth 2 -type f \
  ! -path "*/.git" \
  ! -path "*/.git/*" \
  ! -path "*/tpl-*/*" \
  ! -name "*.lock" \
  ! -name "pnpm-lock.yaml" \
  ! -name "CHANGELOG.md" \
  ! -name "init.sh" \
  | while read -r file; do
      if grep -qE 'tpl|TPL|Tpl' "$file" 2>/dev/null; then
        sed -i \
          -e "s/TPL/${APP_NAME^^}/g" \
          -e "s/Tpl/${APP_NAME^}/g" \
          -e "s/tpl/${APP_NAME}/g" \
          "$file"
      fi
    done
echo "    done: 父仓根目录"

# 2. 更新 .gitmodules
echo ">>> [2/4] 更新 .gitmodules..."
cat > "$SCRIPT_DIR/.gitmodules" <<EOF
[submodule "${APP_NAME}-admin-frontend"]
	path = ${APP_NAME}-admin-frontend
	url = https://gitee.com/${GITEE_USER}/${APP_NAME}-admin-frontend.git
[submodule "${APP_NAME}-web-backend"]
	path = ${APP_NAME}-web-backend
	url = https://gitee.com/${GITEE_USER}/${APP_NAME}-web-backend.git
[submodule "${APP_NAME}-web-frontend"]
	path = ${APP_NAME}-web-frontend
	url = https://gitee.com/${GITEE_USER}/${APP_NAME}-web-frontend.git
[submodule "${APP_NAME}-admin-backend"]
	path = ${APP_NAME}-admin-backend
	url = https://gitee.com/${GITEE_USER}/${APP_NAME}-admin-backend.git
EOF

# 3. 重命名子模块目录
echo ">>> [3/4] 重命名子模块目录..."
mv "$SCRIPT_DIR/tpl-admin-frontend" "$SCRIPT_DIR/${APP_NAME}-admin-frontend"
mv "$SCRIPT_DIR/tpl-web-backend"    "$SCRIPT_DIR/${APP_NAME}-web-backend"
mv "$SCRIPT_DIR/tpl-web-frontend"   "$SCRIPT_DIR/${APP_NAME}-web-frontend"
mv "$SCRIPT_DIR/tpl-admin-backend"  "$SCRIPT_DIR/${APP_NAME}-admin-backend"

# 修正 .git 文件指向（子模块内的 .git 是文件，指向父仓库 modules 目录）
for sub in admin-frontend web-backend web-frontend admin-backend; do
  echo "gitdir: ../.git/modules/${APP_NAME}-${sub}" \
    > "$SCRIPT_DIR/${APP_NAME}-${sub}/.git"
done

# 4. 提示重命名父目录
echo ""
echo ">>> [4/4] 完成！请手动将父目录重命名："
echo "    mv tpl-app ${APP_NAME}-app"
echo ""
echo ">>> 接下来还需要："
echo "    1. 在 Gitee 上将四个仓库改名为:"
echo "       ${APP_NAME}-admin-frontend"
echo "       ${APP_NAME}-web-backend"
echo "       ${APP_NAME}-web-frontend"
echo "       ${APP_NAME}-admin-backend"
echo "    2. 在父仓库执行: git submodule sync"
echo "    3. 分别进入各子模块提交改动"

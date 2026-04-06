# tpl-app

通用应用模板，包含三个子模块，用于快速初始化新项目。

## 仓库结构

```
tpl-app/
├── init.sh                  # 初始化脚本
├── tpl-admin-frontend/      # 管理后台前端（CSR）
├── tpl-web-backend/         # Web BFF 后端
└── tpl-web-frontend/        # Web 前端（SSR）
```

## 使用方法

### 1. 复制模板

```bash
cp -r tpl-app <新项目名>-app
```

### 2. 执行初始化脚本

```bash
cd <新项目名>-app
bash init.sh <项目名> <Gitee用户名>
```

示例：

```bash
bash init.sh investment sunmoonlion
```

脚本会自动完成：
- 将所有文件中的 `tpl` / `Tpl` / `TPL` 替换为项目名
- 重命名三个子模块目录
- 更新 `.gitmodules` 中的远程 URL

### 3. 重命名父目录

```bash
cd ..
mv <新项目名>-app <正式目录名>   # 例：mv investment-app investment-app
```

### 4. 在 Gitee 上新建仓库

需要新建四个仓库（均为空仓库，不加 README）：

- `<项目名>-app`
- `<项目名>-admin-frontend`
- `<项目名>-web-backend`
- `<项目名>-web-frontend`

### 5. 推送

```bash
# 推送三个子模块
cd <项目名>-admin-frontend && git push -u origin master && cd ..
cd <项目名>-web-backend    && git push -u origin master && cd ..
cd <项目名>-web-frontend   && git push -u origin master && cd ..

# 推送父仓库
cd ..
git remote set-url origin https://gitee.com/<Gitee用户名>/<项目名>-app.git
git push -u origin master
```

## 子模块说明

| 子模块 | 技术栈 | 说明 |
|--------|--------|------|
| tpl-admin-frontend | Vue 3 + Vite | 管理后台，CSR 模式 |
| tpl-web-backend | NestJS + TypeScript | BFF 层，聚合后端服务 |
| tpl-web-frontend | Nuxt.js | 用户端前端，SSR 模式 |

---
description: Sync upstream, manage original vs custom branches, deploy to Zeabur
---

# OpenClaw 双版本管理 + Zeabur 部署工作流

## 分支说明

| 分支 | 用途 | Zeabur 部署 |
|------|------|-------------|
| `main` | 同步 upstream 原版 + Zeabur 配置 | 部署原版 |
| `custom` | 基于 main 的自定义修改 | 部署修改版 |

---

## 1. 同步 upstream 到 main

```bash
git checkout main
git fetch upstream
git merge upstream/main
# 解决冲突（如果有）
git push origin main
```

## 2. 将 upstream 更新合并到 custom

```bash
git checkout custom
git merge main
# 解决冲突（如果有）
git push origin custom
```

## 3. 在 custom 分支上开发修改

```bash
git checkout custom
# ... 编辑代码 ...
git add -A
git commit -m "feat: your changes"
git push origin custom
```

## 4. Zeabur 部署

### 初次设置
1. 登录 [Zeabur Dashboard](https://dash.zeabur.com)
2. 创建新项目 → 添加服务 → 选择 **Git (GitHub)**
3. 选择 `wenyongteng/openclaw` 仓库
4. 选择分支：`main`（原版）或 `custom`（修改版）
5. 设置环境变量（必需）：
   - `OPENCLAW_GATEWAY_TOKEN` — 随机长 token
   - `OPENAI_API_KEY` 或 `ANTHROPIC_API_KEY` — 至少一个 AI provider key
6. 可选：挂载 Volume 到 `/home/node/.openclaw` 以持久化数据

### 切换版本
- 在 Zeabur 服务设置中修改部署分支即可切换原版/修改版

### 部署修改版专用实例
- 可创建第二个 Zeabur 服务，指向同一仓库但选择不同分支
- 这样原版和修改版可以同时运行

## 5. 推荐的开发流程

```
1. upstream 发布新版本
2. git fetch upstream && git checkout main && git merge upstream/main
3. git push origin main    → Zeabur 原版实例自动更新
4. git checkout custom && git merge main
5. 解决冲突 → git push origin custom → Zeabur 修改版实例自动更新
```

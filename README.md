# AI 计划助手

学习你的计划风格，自动生成个性化的日/周/月计划。

## 部署步骤

### 第一步：创建 Supabase 项目（后端）

1. 打开 [supabase.com](https://supabase.com)，注册并创建一个新项目
2. 进入项目后，点击左侧 **SQL Editor**
3. 将 `supabase-schema.sql` 文件的全部内容粘贴进去，点击 **Run** 执行
4. 进入 **Authentication → Settings**，确保 Email 登录已启用
5. 进入 **Project Settings → API**，复制以下两个值：
   - `Project URL`（如 `https://xxxxx.supabase.co`）
   - `anon public key`（以 `eyJ` 开头的长字符串）

### 第二步：配置前端

打开 `index.html`，找到顶部的配置区域：

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

替换为你在第一步中复制的值。

### 第三步：推送到 GitHub

```bash
cd AI计划助手
git init
git add .
git commit -m "AI 计划助手 v2.0 - 云端版"
git branch -M main
git remote add origin https://github.com/你的用户名/ai-plan-assistant.git
git push -u origin main
```

### 第四步：部署到 Vercel（前端托管）

1. 打开 [vercel.com](https://vercel.com)，用 GitHub 账号登录
2. 点击 **Import Project**，选择刚才推送的 GitHub 仓库
3. Framework Preset 选 **Other**
4. 点击 **Deploy**

部署完成后会得到一个在线地址（如 `https://ai-plan-xxx.vercel.app`），发给朋友即可使用。

### 自动更新

完成以上步骤后，每次你修改代码并 `git push` 到 GitHub，Vercel 会自动重新部署，线上版本实时更新。

## 技术架构

- **前端**：纯 HTML + CSS + JS（单文件），托管在 Vercel
- **后端**：Supabase（PostgreSQL + Auth + Storage）
- **AI**：通过 OpenRouter API 调用多种大模型
- **部署**：GitHub → Vercel 自动部署

## 安全说明

- Supabase anon key 是可公开的（类似 Stripe publishable key），所有数据由 Row Level Security 保护
- 每个用户只能访问自己的数据
- OpenRouter API Key 存储在用户自己的数据库行中，仅用户本人可见

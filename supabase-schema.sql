-- ============================================================
-- AI 计划助手 - Supabase 数据库 Schema
-- 在 Supabase Dashboard → SQL Editor 中运行此脚本
-- ============================================================

-- 1. 上传的历史计划
CREATE TABLE uploaded_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('text', 'image')),
    content TEXT,
    file_path TEXT,
    mime_type TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. 风格画像
CREATE TABLE style_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    profile JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. 月目标
CREATE TABLE monthly_goals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    month TEXT NOT NULL,
    content TEXT NOT NULL,
    input_type TEXT DEFAULT 'text',
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, month)
);

-- 4. 周计划
CREATE TABLE weekly_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    week_key TEXT NOT NULL,
    content TEXT NOT NULL,
    month_ref TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, week_key)
);

-- 5. 日计划
CREATE TABLE daily_plans (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date_key TEXT NOT NULL,
    original TEXT,
    current_text TEXT,
    sections JSONB,
    completion_status JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, date_key)
);

-- 6. 每日总结
CREATE TABLE summaries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date_key TEXT NOT NULL,
    content TEXT NOT NULL,
    stats JSONB,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, date_key)
);

-- 7. 修改历史
CREATE TABLE modification_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date_key TEXT NOT NULL,
    diff JSONB NOT NULL,
    learnings JSONB,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. API 配置（每个用户的 OpenRouter Key）
CREATE TABLE api_configs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    api_key TEXT,
    model TEXT DEFAULT 'google/gemini-3-flash-preview',
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- Row Level Security (RLS) - 每个用户只能访问自己的数据
-- ============================================================

ALTER TABLE uploaded_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE style_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE modification_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_configs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "own_uploaded_plans" ON uploaded_plans FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_style_profiles" ON style_profiles FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_monthly_goals" ON monthly_goals FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_weekly_plans" ON weekly_plans FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_daily_plans" ON daily_plans FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_summaries" ON summaries FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_modification_history" ON modification_history FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "own_api_configs" ON api_configs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- Storage Bucket - 存储上传的图片文件
-- ============================================================

INSERT INTO storage.buckets (id, name, public) VALUES ('plan-files', 'plan-files', false);

CREATE POLICY "upload_own_files" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'plan-files' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "read_own_files" ON storage.objects FOR SELECT USING (
    bucket_id = 'plan-files' AND auth.uid()::text = (storage.foldername(name))[1]
);
CREATE POLICY "delete_own_files" ON storage.objects FOR DELETE USING (
    bucket_id = 'plan-files' AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Oral Prep Database Setup
-- Run this script in your Supabase SQL Editor

-- Create profiles table
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Create projects table
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 120),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Create project_documents table
create table if not exists public.project_documents (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null,
  path text not null,
  size_bytes bigint not null check (size_bytes <= 50 * 1024 * 1024),
  content_type text not null,
  created_at timestamptz default now()
);

-- Create index for faster queries
create index if not exists idx_documents_project on public.project_documents(project_id);
create index if not exists idx_projects_owner on public.projects(owner_id);

-- Enable Row Level Security
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.project_documents enable row level security;

-- Drop existing policies if they exist
drop policy if exists "Profile is self" on public.profiles;
drop policy if exists "Projects are owned" on public.projects;
drop policy if exists "Docs through owned project" on public.project_documents;

-- RLS Policies for profiles
create policy "Profile is self" on public.profiles
  for all using (id = auth.uid()) with check (id = auth.uid());

-- RLS Policies for projects
create policy "Projects are owned" on public.projects
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- RLS Policies for project_documents
create policy "Docs through owned project" on public.project_documents
  for all using (
    exists(select 1 from public.projects p where p.id = project_id and p.owner_id = auth.uid())
  ) with check (
    exists(select 1 from public.projects p where p.id = project_id and p.owner_id = auth.uid())
  );

-- Create storage bucket for project documents
insert into storage.buckets (id, name, public) 
values ('project-docs','project-docs', false)
on conflict (id) do nothing;

-- Drop existing storage policies if they exist
drop policy if exists "Users read own objects" on storage.objects;
drop policy if exists "Users write own objects" on storage.objects;
drop policy if exists "Users update/delete own objects" on storage.objects;

-- Storage policies: user-scoped paths users/{uid}/{projectId}/docs/*
create policy "Users read own objects" on storage.objects 
for select using (
  bucket_id = 'project-docs' and 
  (storage.foldername(name))[1] = 'users' and
  (storage.foldername(name))[2] = auth.uid()::text
);

create policy "Users write own objects" on storage.objects 
for insert with check (
  bucket_id = 'project-docs' and 
  (storage.foldername(name))[1] = 'users' and
  (storage.foldername(name))[2] = auth.uid()::text
);

create policy "Users update/delete own objects" on storage.objects 
for delete using (
  bucket_id = 'project-docs' and 
  (storage.foldername(name))[1] = 'users' and
  (storage.foldername(name))[2] = auth.uid()::text
);

create policy "Users update own objects" on storage.objects 
for update using (
  bucket_id = 'project-docs' and 
  (storage.foldername(name))[1] = 'users' and
  (storage.foldername(name))[2] = auth.uid()::text
);

-- Function to enforce max 10 documents per project
create or replace function public.enforce_max_documents()
returns trigger language plpgsql as $$
begin
  if (select count(*) from public.project_documents d where d.project_id = new.project_id) >= 10 then
    raise exception 'Vous ne pouvez pas ajouter plus de 10 documents à ce projet.';
  end if;
  return new;
end;
$$;

-- Drop existing trigger if it exists
drop trigger if exists trg_max_docs on public.project_documents;

-- Create trigger for max documents constraint
create trigger trg_max_docs
before insert on public.project_documents
for each row execute function public.enforce_max_documents();

-- Function to automatically create profile on user signup
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$$;

-- Drop existing trigger if it exists
drop trigger if exists on_auth_user_created on auth.users;

-- Create trigger for new user profile creation
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Grant necessary permissions
grant usage on schema public to anon, authenticated;
grant all on public.profiles to anon, authenticated;
grant all on public.projects to anon, authenticated;
grant all on public.project_documents to anon, authenticated;


-- ===== 第二版新增：共享圖片、自動加入人員 =====
-- 已經執行過舊版 supabase.sql 的人，只要在 SQL Editor 貼上這一段執行即可。

create table if not exists images (
  id text primary key,
  tc text not null,
  data text not null,
  created_at timestamptz not null default now()
);
create table if not exists members (
  tc text not null,
  acct text not null,
  name text not null,
  joined_at timestamptz not null default now(),
  primary key (tc, acct)
);
alter table images enable row level security;
alter table members enable row level security;
revoke all on images, members from anon, authenticated;

-- 編輯者上傳圖片（要有該行程的編輯碼）
create or replace function put_image(p_ec text, p_id text, p_data text)
returns boolean language plpgsql security definer set search_path = public as $$
declare v_tc text;
begin
  select tc into v_tc from trips where ec = p_ec;
  if v_tc is null then return false; end if;
  if p_id is null or length(p_id) < 4 or length(p_data) > 700000 then return false; end if;
  insert into images(id, tc, data) values (p_id, v_tc, p_data)
  on conflict (id) do update set data = excluded.data where images.tc = excluded.tc;
  return true;
end $$;

-- 任何有旅行碼的人可讀取圖片
create or replace function get_image(p_tc text, p_id text)
returns text language sql stable security definer set search_path = public as $$
  select data from images where tc = p_tc and id = p_id;
$$;

-- 輸入旅行碼的人自動加入人員（顯示名稱）
create or replace function join_trip(p_tc text, p_acct text, p_name text)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from trips where tc = p_tc) then return false; end if;
  if coalesce(length(p_acct),0) < 1 or coalesce(length(p_name),0) < 1 then return false; end if;
  insert into members(tc, acct, name) values (p_tc, p_acct, p_name)
  on conflict (tc, acct) do update set name = excluded.name;
  return true;
end $$;

create or replace function get_members(p_tc text)
returns json language sql stable security definer set search_path = public as $$
  select coalesce(json_agg(json_build_object('acct', acct, 'name', name) order by joined_at), '[]'::json)
  from members where tc = p_tc;
$$;

grant execute on function put_image(text,text,text), get_image(text,text),
  join_trip(text,text,text), get_members(text) to anon, authenticated;

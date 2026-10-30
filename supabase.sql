-- 出去玩：Supabase 資料庫設定
-- 用法：Supabase 後台 → SQL Editor → New query → 貼上全部 → Run
-- 設計：三張資料表全部鎖住（開啟 RLS 且不建立任何 policy），
--       前端只能呼叫下面的函式；編輯碼只在伺服器端比對，不會回傳給任何人。

create table if not exists accounts (
  id text primary key,
  name text not null,
  created_at timestamptz not null default now()
);

create table if not exists trips (
  tc text primary key,                 -- 旅行碼（可閱讀）
  ec text unique not null,             -- 編輯碼（可修改，不外流）
  data jsonb not null default '{}',    -- 行程內容（不含圖片、不含編輯碼）
  v bigint not null default 0,         -- 版本（時間戳）
  upd_by text,
  upd_at timestamptz not null default now()
);

create table if not exists expenses (
  tc text not null,
  acct text not null,
  data jsonb not null default '[]',    -- 該帳號上傳的群體支出
  updated_at timestamptz not null default now(),
  primary key (tc, acct)
);

alter table accounts enable row level security;
alter table trips enable row level security;
alter table expenses enable row level security;
revoke all on accounts, trips, expenses from anon, authenticated;

create or replace function create_account(p_id text, p_name text)
returns boolean language plpgsql security definer set search_path = public as $$
declare n int;
begin
  if coalesce(length(p_id),0) < 1 or coalesce(length(p_name),0) < 1 then return false; end if;
  insert into accounts(id, name) values (p_id, p_name) on conflict do nothing;
  get diagnostics n = row_count;
  return n > 0;
end $$;

create or replace function get_account(p_id text)
returns json language sql stable security definer set search_path = public as $$
  select json_build_object('id', id, 'name', name) from accounts where id = p_id;
$$;

create or replace function create_trip(p_tc text, p_ec text, p_data jsonb, p_by text)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  if p_tc is null or p_ec is null or p_tc = p_ec or length(p_tc) < 4 or length(p_ec) < 4 then return false; end if;
  if exists (select 1 from trips where tc in (p_tc, p_ec) or ec in (p_tc, p_ec)) then return false; end if;
  insert into trips(tc, ec, data, v, upd_by) values (p_tc, p_ec, p_data, (extract(epoch from now()) * 1000)::bigint, p_by);
  return true;
end $$;

create or replace function get_trip(p_tc text)
returns json language sql stable security definer set search_path = public as $$
  select json_build_object('data', data, 'v', v, 'upd_by', upd_by, 'upd_at', upd_at) from trips where tc = p_tc;
$$;

create or replace function find_by_ec(p_ec text)
returns json language sql stable security definer set search_path = public as $$
  select json_build_object('tc', tc, 'data', data, 'v', v, 'upd_by', upd_by, 'upd_at', upd_at) from trips where ec = p_ec;
$$;

create or replace function update_trip(p_ec text, p_data jsonb, p_v bigint, p_by text)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  update trips set data = p_data, v = p_v, upd_by = p_by, upd_at = now() where ec = p_ec;
  return found;
end $$;

create or replace function upload_expenses(p_tc text, p_acct text, p_data jsonb)
returns boolean language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from trips where tc = p_tc) then return false; end if;
  insert into expenses(tc, acct, data) values (p_tc, p_acct, p_data)
  on conflict (tc, acct) do update set data = excluded.data, updated_at = now();
  return true;
end $$;

create or replace function get_expenses(p_tc text)
returns json language sql stable security definer set search_path = public as $$
  select coalesce(json_agg(json_build_object('acct', acct, 'data', data)), '[]'::json) from expenses where tc = p_tc;
$$;

grant execute on function create_account(text,text), get_account(text),
  create_trip(text,text,jsonb,text), get_trip(text), find_by_ec(text),
  update_trip(text,jsonb,bigint,text), upload_expenses(text,text,jsonb), get_expenses(text)
  to anon, authenticated;

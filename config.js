// Supabase 設定：把下面兩個值換成你自己專案的（Project Settings → API）。
// 這兩個值是「可公開」的前端金鑰（anon / publishable key），資料表本身由 supabase.sql 鎖住。
// 絕對不要貼 service_role 金鑰。
window.SUPABASE = {
  url: "https://YOUR-PROJECT.supabase.co",
  key: "YOUR-ANON-OR-PUBLISHABLE-KEY"
};

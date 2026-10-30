# 出去玩（旅行 app）安裝說明

資料夾建議放在：`C:\Users\user\Desktop\Trip-APP`

## 一、檔案說明
- `index.html`：整個 app
- `config.js`：**你要編輯這個**，填入 Supabase 的網址與金鑰
- `supabase.sql`：貼到 Supabase 執行的資料庫設定
- `manifest.webmanifest`、`sw.js`、`icons/`：讓它能裝到手機桌面、離線可用、圖示（icon A：飛機＋太陽＋虛線航跡）

上傳時，`index.html`、`config.js`、`manifest.webmanifest`、`sw.js`、`icons` 資料夾要在同一層。`supabase.sql` 與 `README.md` 不用上傳。

## 二、建立 Supabase（免費）
1. 到 https://supabase.com 註冊並登入，按 **New project**，取名（例如 `chuqu`）、設定資料庫密碼、選離你近的地區（例如 Tokyo 或 Singapore），按建立，等 1～2 分鐘。
2. 左側 **SQL Editor → New query**，打開本資料夾的 `supabase.sql`，把全部內容貼上，按 **Run**。看到 Success 就完成。
3. 左側 **Project Settings → API**（或 Data API / API Keys），找到：
   - **Project URL**（`https://xxxx.supabase.co`）
   - **anon public key**（`eyJ…` 開頭），或 **Publishable key**（`sb_publishable_…` 開頭）
4. 用記事本打開 `config.js`，把 `YOUR-PROJECT.supabase.co` 換成你的網址、`YOUR-ANON-OR-PUBLISHABLE-KEY` 換成金鑰，存檔。

**只能貼 anon / publishable 金鑰，絕對不要貼 service_role 金鑰。** anon 金鑰是設計成可公開的前端金鑰；因為資料表已被鎖住，前端只能呼叫 `supabase.sql` 裡的函式，編輯碼只在伺服器端比對，不會傳回給任何人。

## 三、放到 GitHub Pages
1. GitHub 新增 repository（名稱如 `chuqu`），選 **Public**。
2. **Add file → Upload files**，把 `index.html`、`config.js`、`manifest.webmanifest`、`sw.js`、`icons` 資料夾拖進去，**Commit changes**。
3. **Settings → Pages**：Source 選 **Deploy from a branch**，Branch 選 **main**、**/(root)**，**Save**。
4. 1～3 分鐘後得到網址：`https://你的帳號.github.io/chuqu/`

## 四、Google Maps 示範金鑰（免信用卡）
1. 打開 https://mapsplatform.google.com/intl/zh-TW_tw/maps-demo-key/ → 「免費體驗」→ 用 Google 帳號登入 → 取得金鑰（`AIza…`）。
2. 在 app 的「設定 → Google Maps 金鑰」貼上、儲存。
3. 示範金鑰每個 API 有每日上限，達到後暫停一天、不收費；適合個人旅行使用。
4. 金鑰存在每支手機的設定裡，不會寫進程式檔。

地標靠「座標」：短網址（maps.app.goo.gl）取不到座標，請在編輯頁「座標」欄貼上經緯度（Google 地圖長按地點可複製），或貼完整網址。

## 五、裝到手機
- iPhone（Safari）：打開網址 →「分享」→「加入主畫面」，之後用桌面圖示開啟。
- Android（Chrome）：⋮ →「安裝應用程式」。

第一次要連線打開一次，之後離線也能用。

## 六、Supabase 啟用後的運作方式
- **帳號**：「設定 → 創建帳號」會登記在雲端，別支手機輸入帳號就能登入同一個名稱。（沒有密碼，知道帳號就能登入。）
- **旅行碼 / 編輯碼**：「編輯 → ＋」建立行程時自訂兩組碼，存到雲端。別人在「設定 → 加行程」輸入旅行碼就能閱讀；在「編輯」輸入編輯碼就能修改。編輯碼由伺服器比對。
- **編輯**需要網路；修改後離線時會先存在手機，連線後自動上傳。
- **記帳**：每個人在自己手機記帳，按「上傳」把群體支出送上雲端；打開「最簡結算」時會把旅伴上傳的支出一起算進去（用「重新整理」鈕抓最新）。個人記帳不會上傳。
- **憑證**只存手機的 IndexedDB，沒有任何上傳路徑。

## 七、更新 app
修改檔案後重新上傳覆蓋。若改了圖示或 `sw.js`，把 `sw.js` 第一行的 `chuqu-v1` 改成 `chuqu-v2`，手機才會更新快取。

## 八、已知限制
- 背景照片與地點圖片不會同步，只存在拍照的那支手機。
- 沒有登入密碼：知道帳號、旅行碼或記帳資料的人，就能以該身分操作。請只把碼分享給信任的旅伴。
- 任何人都能呼叫公開的建立函式（帳號、行程）；個人使用風險低，若擔心被濫用，可在 Supabase 後台限制或定期檢查資料表。
- 天氣仍需手動填寫。
- 若不填 `config.js`，app 仍可純本機使用，只是不同步。

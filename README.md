# 出去玩（旅行 app）安裝與上架說明

## 一、檔案說明
- `index.html`：整個 app（行程、行前準備、記帳、地圖、編輯、設定）
- `manifest.webmanifest`：讓手機認得這是 app（名稱「出去玩」、圖示、全螢幕）
- `sw.js`：離線快取，沒網路也能開啟
- `icons/`：app 圖示（桌面圖示、遮罩圖示、iPhone 圖示、網頁小圖示）

這 4 樣要放在同一層：`index.html`、`manifest.webmanifest`、`sw.js`、`icons` 資料夾。

## 二、放到 GitHub Pages（免費）
1. 登入 GitHub，右上角「＋」→ **New repository**。
2. Repository name 輸入 `chuqu`（可自訂），選 **Public**，按 **Create repository**。
3. 進到新 repo，按 **Add file → Upload files**。
4. 把解壓縮後的 **所有檔案與 icons 資料夾** 拖進去（要連 icons 資料夾一起），按 **Commit changes**。
5. 上方 **Settings → Pages**。
6. **Source** 選 **Deploy from a branch**，Branch 選 **main**、資料夾選 **/(root)**，按 **Save**。
7. 等 1～3 分鐘，頁面上方會出現網址：`https://你的帳號.github.io/chuqu/`。
8. 用手機打開這個網址，確認能看到 app。

備註：免費帳號的 GitHub Pages 通常要用公開（Public）repo；公開代表別人看得到你的程式檔，但看不到你在 app 裡填的旅行資料與金鑰（那些只存在手機）。

## 三、申請 Google Maps 示範金鑰（不用信用卡）
1. 打開 https://mapsplatform.google.com/intl/zh-TW_tw/maps-demo-key/
2. 按「免費體驗」，用 Google 帳號登入，同意條款，取得金鑰（`AIza` 開頭的一串字）。
3. 在 app 的「設定 → Google Maps 金鑰」貼上，按「儲存金鑰」。
4. 到「地圖」頁，連線時就會顯示真正的 Google 地圖。

示範金鑰的特性（依 Google 官方頁面）：
- 免信用卡、免帳單帳戶，適合原型與測試。
- 每個 API 有每日上限；達到後地圖會暫停到隔天，不會收費。
- 若之後想要更高用量，可在 Google 那邊升級並綁定帳單。

金鑰是貼在手機的設定裡，不會寫進 `index.html`，所以不會被放到 GitHub 上。

注意：地標位置靠「座標」。短網址（maps.app.goo.gl）無法直接取得座標，請在編輯頁的「座標」欄貼上經緯度（Google 地圖長按地點即可複製），或貼完整網址（含 `@緯度,經度`）。

## 四、裝到手機桌面
- **iPhone（Safari）**：打開網址 → 底部「分享」→「加入主畫面」→ 新增。請用主畫面的圖示開啟。
- **Android（Chrome）**：打開網址 → 右上角「⋮」→「安裝應用程式」或「加到主畫面」。

第一次要連線打開一次，之後離線也能用（地圖底圖仍需網路）。

## 五、更新 app
1. 修改檔案後，在 GitHub repo 重新上傳同名檔案（覆蓋）。
2. 若更動了圖示或 `sw.js`，請把 `sw.js` 第一行的 `chuqu-v1` 改成 `chuqu-v2`（版本號 +1），手機才會更新快取。
3. 手機連線後重新開啟 app 即可。

## 六、已知限制
- **資料只存在這支手機**（行程、記帳、憑證、帳號）。清除瀏覽器資料或換手機會不見。iPhone 建議一定要「加入主畫面」後再使用。
- **旅行碼、編輯碼、帳號只在同一支手機有效**：在 claude.ai 上的雲端同步，搬到自己網站後不會啟用。要跨手機分享行程、多人合記帳，需要接 Supabase（下一階段）。
- 天氣目前是手動填寫；自動抓天氣需要接天氣服務（下一階段）。
- 憑證圖片存在手機的 IndexedDB，沒有任何上傳路徑。

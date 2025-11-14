## 概要

PaperCut Hive/Pocketのグループポリシーによる展開は、**Edge Node**と**Print Client**の2段階で実施する。

### Edge Nodeの展開

- コンピュータアプリは管理者権限で実行（ユーザーログイン不要）
- PaperCut Hive/Pocket Edge NodeのWindowsサービスとプリンタオブジェクトを作成
- Print Clientなしでも展開可能（例：Windows ServerへのSuper Node導入）
- **必ずPrint Clientより先に展開すること**

### Print Clientの展開

- コンピュータアプリがジョブ送信用のプリントクライアントプロセスを作成
- ユーザーセキュリティコンテキスト内にファイルとプロセスをインストール
- 「ログオンユーザーとして実行」で動作
- 実行後、ユーザーはメール招待経由でリンクプロセスを実行する必要あり

## 前提条件

- Microsoft Group Policyの知識があること
- PaperCut Hive/Pocketインストーラーをホストする共有ネットワーク場所

---

## 手順1：Edge Node用GPOの作成

### 1.1 インストーラーとコマンドの準備

1. PaperCut Hive/Pocket管理コンソールで **Manage > Edge Mesh > Add an edge node** を開く
2. **Manually deploy edge nodes** を選択
3. **Download for Windows** をクリックして `papercut-hive.exe` または `papercut-pocket.exe` をダウンロード
4. ダウンロードしたファイルをエンドユーザーPCからアクセス可能な共有ネットワーク場所にコピー
5. Step 2の **Copy** ボタンをクリックしてコマンドラインをコピーし、テキストエディタに貼り付け
6. `/systemkey` と `/region`（該当する場合）の値を控える

### 1.2 PowerShellスクリプトの作成

新規Notepadファイルに以下のスクリプトを貼り付け：

```powershell
# PowerShell Example Script to install PaperCut Hive edge node v1.0 via GPO

# 変数定義（随時変更可能）

$localInstallFolder = 'C:\Program files\PaperCut Hive'  # インストール済みかチェックするローカルフォルダ
$networkInstallerPath = "\\your-network-share\installers\papercut-hive.exe"     # インストーラーがある共有フォルダ
$region = "RegionA"  # 利用するリージョン
$systemKey = "YOUR-SYSTEM-KEY"  # システムキー

if (-not (Test-Path -Path $localInstallFolder)) {
    Start-Process -FilePath $networkInstallerPath `
        -ArgumentList "/VERYSILENT /region=`"$region`" /systemKey=`"$systemKey`""
} else {
    # Folder already exists, no action needed
}
```

**編集項目：**

- `/region` の値を手順1.1で控えた値に置換（該当しない場合は削除）
- `/systemkey` の値を手順1.1で控えた値に置換
- `-FilePath` を実際のUNCパスに変更

**保存：** `PaperCut_Hive_edge_node_`[`install.ps`](http://install.ps)`1` として保存

### 1.3 GPOの構成

1. グループ ポリシーの管理を開き、適用対象の **ドメイン** と **OU** に移動
2. OUを右クリック → **この OU に GPO を作成し、この場所にリンクする...**
3. GPO名を入力（例：`PaperCut Hive edge node Install`）
4. ソース スターター GPOは **(なし)** のまま
5. 作成したGPOを右クリック → **編集**
6. **コンピューターの構成 > ポリシー > Windowsの設定 > スクリプト (スタートアップ/シャットダウン)** を展開
7. 右ペインで **スタートアップ** をダブルクリック
8. **PowerShell スクリプト** タブを選択 → **追加** をクリック
9. 手順1.2で作成したPowerShellスクリプトを参照
10. **OK** → **OK** で閉じる

---

## 手順2：Print Client用GPOの作成

### 2.1 インストールコマンドの取得

1. PaperCut Hive/Pocket管理コンソールで **Manage > Add-ons > All Add-ons > Desktop App Deployment with Microsoft Intune** を開く
2. **Learn More** → **Add** をクリック
3. **I agree that:** にチェック → **Agree**
4. **these instructions** を選択して手順を開く
5. **View setup Process** を選択 → **Install user component** までスクロール
6. Step 6の **Install command** 文字列をコピーしてテキストエディタに貼り付け
7. `/userkey`、`/orgid`、`/region` の値を控える

### 2.2 PowerShellスクリプトの作成

新規Notepadファイルに以下のスクリプトを貼り付け：

```powershell
# PowerShell Script to install PaperCut Hive print client via GPO

# 変数定義
$localInstallFolder = "$env:LOCALAPPDATA\Programs\PaperCut Hive"
$networkInstallerPath = "\\your-network-share\installers\PaperCutHiveClientInstaller.exe"
$userKey = "YOUR-USER-KEY"
$orgId = "YOUR-ORG-ID"

# インストール済みかチェック
if (-not (Test-Path -Path $localInstallFolder)) {
    Start-Process -FilePath $networkInstallerPath `
        -ArgumentList "/VERYSILENT /CURRENTUSER /userkey=`"$userKey`" /orgId=`"$orgId`""
} else {
    # フォルダが既に存在する場合は何もしない
}
```

**編集項目：**

- `/region` の値を手順2.1で控えた値に置換（該当しない場合は削除）
- `/userkey` の値を手順2.1で控えた値に置換
- `/orgid` の値を手順2.1で控えた値に置換
- `-FilePath` を実際のUNCパスに変更

**保存：** `PaperCut_Hive_print_client_`[`install.ps`](http://install.ps)`1` として保存

### 2.3 GPOの構成

1. グループ ポリシーの管理で、Edge Node GPOを作成したのと同じOUに移動
2. OUを右クリック → **この OU に GPO を作成し、この場所にリンクする...**
3. GPO名を入力（例：`PaperCut Hive print client Install`）
4. ソース スターター GPOは **(なし)** のまま
5. 作成したGPOを右クリック → **編集**
6. **ユーザーの構成 > ポリシー > Windowsの設定 > スクリプト (ログオン/ログオフ)** を展開
7. 右ペインで **ログオン** をダブルクリック
8. **PowerShell スクリプト** タブを選択 → **追加** をクリック
9. 手順2.2で作成したPowerShellスクリプトを参照
10. **OK** → **OK** で閉じる

---

## 展開後のチェック

数台のWindows PCで以下を確認：

### タスクマネージャーでのプロセス確認

1. **`pc-edgenode-service`** が実行中であること
    - Edge Mesh機能（ジョブ受信、レプリケーション、印刷）に必要
2. **`pc-print-client-service.exe`** が実行中であること
    - ユーザーのPaperCut Hive/Pocketへのリンクとジョブ送信に必要

<aside>
⚠️

**いずれかが実行されていない場合：**
PaperCutリセラーに連絡し、ログを提供すること

</aside>

---

## ログの場所

### Edge Nodeサービス・セットアップログ

`C:\Program Files\PaperCut Hive\data\logs`

または

`C:\Program Files\PaperCut Pocket\data\logs`

### ユーザープリントクライアントログ

`%AppData%\Local\Programs\PaperCut Hive\data\logs`

または

`%AppData%\Local\Programs\PaperCut Pocket\data\logs`

### ユーザークライアントセットアップログ

- `%AppData%\Local\Programs\PaperCut Hive\data\logs`
- `%AppData%\Local\Programs\PaperCut Pocket\data\logs`
- `%AppData%\Local\Temp`

---

## 参考資料

[Deploying with Group Policy - PaperCut Manual](https://www.papercut.com/help/manuals/pocket-hive/plan-and-get-started/bulk-deployment/deploying-with-group-policy/)

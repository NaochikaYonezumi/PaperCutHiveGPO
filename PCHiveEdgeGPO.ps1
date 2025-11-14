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
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
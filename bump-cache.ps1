# 把 sw.js 里的 CACHE 版本号自动 +1（hand-flower-v1 -> hand-flower-v2 -> ...）
# 由"发布更新.bat"调用，也可以单独右键"使用 PowerShell 运行"

$ErrorActionPreference = 'Stop'
$path = Join-Path $PSScriptRoot 'sw.js'

if (-not (Test-Path $path)) {
    Write-Host "[失败] 找不到 sw.js" -ForegroundColor Red
    exit 1
}

$text = [System.IO.File]::ReadAllText($path)

if ($text -match 'hand-flower-v(\d+)') {
    $old = [int]$Matches[1]
    $new = $old + 1
    $updated = $text -replace 'hand-flower-v\d+', "hand-flower-v$new"

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $updated, $utf8NoBom)

    Write-Host "缓存版本: hand-flower-v$old  ->  hand-flower-v$new" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "[失败] sw.js 里没找到 hand-flower-v数字 这样的版本号" -ForegroundColor Red
    exit 1
}

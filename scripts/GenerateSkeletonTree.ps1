param(
    [string]$RootPath = (Get-Location).Path,
    [string[]]$ExcludePatterns = @(
        'node_modules',
        '\.git',
        '\.dart_tool',
        'build',
        'dist',
        '\.vscode',
        '\.idea',
        '\.gradle',
        'Pods',
        '\.flutter',
        '\.dart',
        '\.g\.dart',
        'android/\.gradle',
        'ios/Pods'
    )
)

# Combine the exclude patterns into a single regex
$excludeRegex = ($ExcludePatterns -join '|')

function Get-TreeLines {
    param(
        [System.IO.DirectoryInfo]$Dir,
        [int]$Level = 0
    )

    $lines = @()
    $items = Get-ChildItem -LiteralPath $Dir.FullName -Force |
             Where-Object { $_.FullName -notmatch $excludeRegex } |
             Sort-Object @{Expression = { -not $_.PSIsContainer }}, Name

    foreach ($item in $items) {
        $indent = '  ' * $Level
        if ($item.PSIsContainer) {
            $lines += "${indent}- **[DIR]** ``$($item.Name)``"
            $lines += Get-TreeLines -Dir $item -Level ($Level + 1)
        } else {
            $lines += "${indent}- [FILE] ``$($item.Name)``"
        }
    }

    return $lines
}

# Entry point
$rootDir = Get-Item -LiteralPath $RootPath
$header = "# Project Tree (filtered)`n`n**Root Path:** ``$RootPath```n`n"
$treeLines = Get-TreeLines -Dir $rootDir
$output = $header + ($treeLines -join "`n") + "`n"

# Define output file path in project root
$outputFile = Join-Path -Path $RootPath -ChildPath "file_tree_nesery_release.md"
Set-Content -Path $outputFile -Value $output -Encoding UTF8

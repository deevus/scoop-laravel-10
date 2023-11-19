param($dir)

function Enable-Extension([string]$laravel_ini_content, [string]$extension) {
    # ensure laravel ini contains extension
    if ($laravel_ini_content -contains "extension=$extension" -ne $true) {
        "extension=$extension" | Out-File -Path $laravel_ini -Append
    }
}

# Create directory for custom PHP configuration
$confd = "$dir\conf.d"

if (!(Test-Path $confd)) {
    (New-Item -Type directory $confd) | Out-Null
}

# (Get-Content "$dir\php.ini-development") | Where-Object { $_ -notmatch '^;' }  | ? {$_.trim() -ne '' } | Set-Content "$persist_dir\development.ini"
$prod_ini = "$dir\php.ini-production"
if (!(Test-Path "$dir\php.ini-production")) {
    $prod_ini = "$dir\php.ini-dist"
}

# Enable extensions to be found in installation-relative folder (the default is to search C:/php)
if (Test-Path $prod_ini) {
    (Get-Content "$prod_ini") | ForEach-Object { $_ -replace '; extension_dir = "ext"', 'extension_dir = "ext"' } | Set-Content "$dir\php.ini"
}

Copy-Item -ErrorAction Ignore "$dir\php.ini-development" $persist_dir

# Enable extensions required by Laravel
$laravel_ini = Join-Path -Path $confd -ChildPath "laravel-extensions.ini"
if (!(Test-Path $laravel_ini)) {
    'extension_dir="ext"' | Out-File -Path $laravel_ini
}

$laravel_ini_content = (Get-Content $laravel_ini)

Enable-Extension $laravel_ini_content "openssl"
Enable-Extension $laravel_ini_content "curl"
Enable-Extension $laravel_ini_content "xml"
Enable-Extension $laravel_ini_content "fileinfo"
Enable-Extension $laravel_ini_content "mbstring"
Enable-Extension $laravel_ini_content "pdo_mysql"
Enable-Extension $laravel_ini_content "pdo_oci"
Enable-Extension $laravel_ini_content "pdo_odbc"
Enable-Extension $laravel_ini_content "pdo_pgsql"
Enable-Extension $laravel_ini_content "pdo_sqlite"
Enable-Extension $laravel_ini_content "pgsql"

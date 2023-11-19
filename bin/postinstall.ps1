param($dir)

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
    New-Item -Type File -Path $laravel_ini
}

$laravel_ini_content = (Get-Content $laravel_ini)

# laravel ini contains "extension=openssl"?
if ($laravel_ini_content -contains "extension=openssl" -ne $true) {
    Out-File -Path $laravel_ini -Append "extension=openssl"
}

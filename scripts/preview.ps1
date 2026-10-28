# Use the official portable Ruby prepared in this workspace, if available.
# Otherwise use a normally installed Ruby. Run from any working directory.
param([int]$Port = 4000)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $projectRoot
$env:RUBYOPT = '-EUTF-8:UTF-8'
$env:BUNDLE_USER_HOME = Join-Path $projectRoot '.cache/bundle-home'
$env:BUNDLE_USER_CACHE = Join-Path $projectRoot '.cache/bundle-cache'
$portableRuby = Get-ChildItem -Path (Join-Path $projectRoot '.tools/ruby/*/bin/ruby.exe') -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $portableRuby -and (Test-Path -LiteralPath '.cache/runtime-path.txt')) {
    $runtimePath = (Get-Content -LiteralPath '.cache/runtime-path.txt' -Raw).Trim()
    $portableRuby = Get-ChildItem -Path (Join-Path $runtimePath 'ruby/*/bin/ruby.exe') -ErrorAction SilentlyContinue | Select-Object -First 1
}
if ($portableRuby) {
    $env:PATH = "$($portableRuby.DirectoryName);$env:PATH"
}
if (-not (Get-Command ruby -ErrorAction SilentlyContinue)) {
    throw 'Ruby is required. Install Ruby 3.3 with Devkit from https://rubyinstaller.org/ and run bundle install.'
}
# The entry point loads Bundler after normalizing Windows path encodings.
ruby scripts/jekyll.rb serve --host 127.0.0.1 --port $Port --force_polling
exit $LASTEXITCODE

param(
  [string]$TemplateFile = "LinkToMonitoringSink.yaml",
  [string]$StackName = "oam-link"
)

$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) {
  throw ".env file not found at $envFile"
}

Get-Content $envFile | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -match '^\s*$') { return }
  $parts = $_ -split '=',2
  if ($parts.Count -eq 2) {
    $name = $parts[0].Trim()
    $value = $parts[1].Trim()
    Set-Item -Path "Env:$name" -Value $value
  }
}

if (-not $env:MONITORING_ACCOUNT_ID -or -not $env:SINK_IDENTIFIER) {
  throw "MONITORING_ACCOUNT_ID and SINK_IDENTIFIER must be set in .env"
}

aws cloudformation deploy `
  --template-file (Join-Path $PSScriptRoot $TemplateFile) `
  --stack-name $StackName `
  --capabilities CAPABILITY_NAMED_IAM `
  --parameter-overrides `
    MonitoringAccountId=$env:MONITORING_ACCOUNT_ID `
    SinkIdentifier=$env:SINK_IDENTIFIER
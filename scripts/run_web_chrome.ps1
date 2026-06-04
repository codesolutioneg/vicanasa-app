# Flutter web on localhost cannot use Odoo session cookies without CORS + SameSite=None
# (server module partner_financial_portal >= 18.0.1.5.0) OR use this dev-only Chrome flag:
Set-Location $PSScriptRoot\..
flutter run -d chrome `
  --web-browser-flag "--disable-web-security" `
  --web-browser-flag "--user-data-dir=$env:TEMP\vicansa_chrome_dev"

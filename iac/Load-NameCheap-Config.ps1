param(
    [string]$ClientIp
)

Write-Host "Make sure to dot-source this file!"

$env:NAMECHEAP_USER_NAME = op read "op://Private/Namecheap API key/username"
$env:NAMECHEAP_API_KEY = op read "op://Private/Namecheap API key/credential"
$env:NAMECHEAP_API_USER = op read "op://Private/Namecheap API key/api_user"

if ($ClientIp) {
    $env:NAMECHEAP_CLIENT_IP = $ClientIp
}

Write-Host "Loaded NAMECHEAP_USER_NAME, NAMECHEAP_API_KEY, and NAMECHEAP_API_USER from 1Password."

if ($env:NAMECHEAP_CLIENT_IP) {
    Write-Host "Using NAMECHEAP_CLIENT_IP=$env:NAMECHEAP_CLIENT_IP"
} else {
    Write-Host "NAMECHEAP_CLIENT_IP is not set. If Namecheap requires it for your account, set it before running tofu."
}

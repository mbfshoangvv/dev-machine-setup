Write-Host "=== AUTO SETUP DEV MACHINE ===" -ForegroundColor Green

# Kiểm tra quyền Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Script phai chay voi quyen Administrator!" -ForegroundColor Red
    Write-Host "Vui long: Click chuot phai vao PowerShell -> Run as Administrator" -ForegroundColor Yellow
    exit 1
}

# Cho phép chạy script
Set-ExecutionPolicy Bypass -Scope Process -Force

# =============================
# Menu lựa chọn
# =============================
function Show-Menu {
    Write-Host "`n=== MENU LUA CHON CAI DAT ===" -ForegroundColor Cyan
    Write-Host "1. Cai dat Chocolatey" -ForegroundColor Yellow
    Write-Host "2. Cai dat PowerShell 7" -ForegroundColor Yellow
    Write-Host "3. Cai dat Scoop" -ForegroundColor Yellow
    Write-Host "4. Cai dat DEV tools (git, docker, ripgrep, mise)" -ForegroundColor Yellow
    Write-Host "5. Cai dat Windows Apps (Chrome, VSCode, 7zip, etc.)" -ForegroundColor Yellow
    Write-Host "6. Cai dat Build Tools (Visual Studio, .NET SDK)" -ForegroundColor Yellow
    Write-Host "7. Cau hinh Git" -ForegroundColor Yellow
    Write-Host "8. Cai dat TAT CA" -ForegroundColor Green
    Write-Host "9. Kich hoat Windows" -ForegroundColor Green
    Write-Host "10. Dat gio Ho Chi Minh +7 va tat Firewall" -ForegroundColor Green
    Write-Host "0. Thoat" -ForegroundColor Red
    Write-Host "`nNhap so de chon: " -NoNewline -ForegroundColor White
}

function Install-Chocolatey {
    Write-Host "`n=== 1. CAI DAT CHOCOLATEY ===" -ForegroundColor Green
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Host "Chocolatey already installed" -ForegroundColor Cyan
    }
}

function Install-PowerShell7 {
    Write-Host "`n=== 2. CAI DAT POWERSHELL 7 ===" -ForegroundColor Green
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey chua duoc cai dat. Vui long cai dat Chocolatey truoc!" -ForegroundColor Red
        return
    }
    if (!(Get-Command pwsh -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell 7..."
        choco install powershell-core -y
    } else {
        Write-Host "PowerShell 7 already installed" -ForegroundColor Cyan
    }
}

function Install-Scoop {
    Write-Host "`n=== 3. CAI DAT SCOOP ===" -ForegroundColor Green
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..."
        iwr -useb get.scoop.sh | iex
    } else {
        Write-Host "Scoop already installed" -ForegroundColor Cyan
    }
    
    # Add Scoop buckets
    Write-Host "Adding Scoop buckets..."
    scoop bucket add extras 2>$null
    scoop bucket add versions 2>$null
}

function Install-DevTools {
    Write-Host "`n=== 4. CAI DAT DEV TOOLS ===" -ForegroundColor Green
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Scoop chua duoc cai dat. Vui long cai dat Scoop truoc!" -ForegroundColor Red
        return
    }
    
    $devTools = @(
        "git",
        "docker",
        "ripgrep",
        "mise"
    )
    
    Write-Host "Installing dev tools..."
    foreach ($tool in $devTools) {
        Write-Host "Installing $tool..." -ForegroundColor Cyan
        scoop install $tool
    }
}

function Install-WindowsApps {
    Write-Host "`n=== 5. CAI DAT WINDOWS APPS ===" -ForegroundColor Green
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey chua duoc cai dat. Vui long cai dat Chocolatey truoc!" -ForegroundColor Red
        return
    }
    
    $apps = @(
        "googlechrome",
        "vscode",
        "notepadplusplus",
        "7zip",
        "localsend",
        "libreoffice"
    )
    
    Write-Host "Installing Windows apps..."
    $retryCount = 3
    $retryDelay = 5
    $success = $false
    
    for ($i = 1; $i -le $retryCount; $i++) {
        try {
            choco install $apps -y
            $success = $true
            break
        } catch {
            if ($i -lt $retryCount) {
                Write-Host "Retry $i/$retryCount after $retryDelay seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds $retryDelay
            } else {
                Write-Host "Failed to install apps after $retryCount attempts" -ForegroundColor Red
            }
        }
    }
}

function Install-BuildTools {
    Write-Host "`n=== 6. CAI DAT BUILD TOOLS ===" -ForegroundColor Green
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey chua duoc cai dat. Vui long cai dat Chocolatey truoc!" -ForegroundColor Red
        return
    }
    
    $buildTools = @(
        "visualstudio2022buildtools",
        "dotnet-sdk",
        "windows-sdk-10"
    )
    
    Write-Host "Installing build tools (this may take a while)..." -ForegroundColor Yellow
    foreach ($tool in $buildTools) {
        Write-Host "Installing $tool..." -ForegroundColor Cyan
        $retryCount = 3
        $retryDelay = 5
        $success = $false
        
        for ($i = 1; $i -le $retryCount; $i++) {
            try {
                choco install $tool -y
                $success = $true
                break
            } catch {
                if ($i -lt $retryCount) {
                    Write-Host "Retry $i/$retryCount after $retryDelay seconds..." -ForegroundColor Yellow
                    Start-Sleep -Seconds $retryDelay
                } else {
                    Write-Host "Failed to install $tool after $retryCount attempts" -ForegroundColor Red
                }
            }
        }
    }
}

function Configure-Git {
    Write-Host "`n=== 7. CAU HINH GIT ===" -ForegroundColor Green
    if (!(Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git chua duoc cai dat. Vui long cai dat Git truoc!" -ForegroundColor Red
        return
    }
    
    git config --global user.name "MBFS Hoang Vo"
    git config --global user.email "hoangvv@mobifonesolutions.vn"
    Write-Host "Git configured successfully!" -ForegroundColor Cyan
}

function Activate-Windows {
    Write-Host "`n=== 9. KICH HOAT WINDOWS ===" -ForegroundColor Green

    Write-Host "For Windows 8, 10, 11: 📌" -ForegroundColor Yellow
    Write-Host "  > irm https://get.activated.win | iex" -ForegroundColor Yellow
    Write-Host "If the above is blocked (by ISP/DNS), try this (needs updated Windows 10 or 11):" -ForegroundColor Yellow
    Write-Host "  > iex (curl.exe -s --doh-url https://1.1.1.1/dns-query https://get.activated.win | Out-String)" -ForegroundColor Yellow
    Write-Host "For Windows 7 and later:" -ForegroundColor Yellow
    Write-Host "  > iex ((New-Object Net.WebClient).DownloadString('https://get.activated.win'))" -ForegroundColor Yellow

    Write-Host "`nRun with Administrator permission" -ForegroundColor Gray
}

function Configure-TimeAndFirewall {
    Write-Host "`n=== 10. DAT GIO HO CHI MINH +7 VA TAT FIREWALL ===" -ForegroundColor Green
    
    # Set timezone to Ho Chi Minh (SE Asia Standard Time)
    Write-Host "`nDang dat timezone thanh Ho Chi Minh (UTC+7)..." -ForegroundColor Cyan
    try {
        $timezone = "SE Asia Standard Time"
        tzutil /s $timezone
        Write-Host "Da dat timezone thanh: $timezone" -ForegroundColor Green
        
        # Verify timezone
        $currentTZ = tzutil /g
        Write-Host "Timezone hien tai: $currentTZ" -ForegroundColor Cyan
    } catch {
        Write-Host "Loi khi dat timezone: $_" -ForegroundColor Red
    }
    
    # Disable Windows Firewall for all profiles
    Write-Host "`nDang tat Windows Firewall..." -ForegroundColor Cyan
    try {
        # Disable Firewall for Domain profile
        Set-NetFirewallProfile -Profile Domain -Enabled False -ErrorAction SilentlyContinue
        Write-Host "Da tat Firewall cho Domain profile" -ForegroundColor Green
        
        # Disable Firewall for Private profile
        Set-NetFirewallProfile -Profile Private -Enabled False -ErrorAction SilentlyContinue
        Write-Host "Da tat Firewall cho Private profile" -ForegroundColor Green
        
        # Disable Firewall for Public profile
        Set-NetFirewallProfile -Profile Public -Enabled False -ErrorAction SilentlyContinue
        Write-Host "Da tat Firewall cho Public profile" -ForegroundColor Green
        
        # Verify firewall status
        Write-Host "`nTrang thai Firewall:" -ForegroundColor Cyan
        Get-NetFirewallProfile | Format-Table Profile, Enabled -AutoSize
        
        Write-Host "Da tat hoan toan Windows Firewall!" -ForegroundColor Green
    } catch {
        Write-Host "Loi khi tat Firewall: $_" -ForegroundColor Red
        Write-Host "Thu dung lenh netsh..." -ForegroundColor Yellow
        try {
            netsh advfirewall set allprofiles state off
            Write-Host "Da tat Firewall bang netsh" -ForegroundColor Green
        } catch {
            Write-Host "Khong the tat Firewall. Vui long kiem tra quyen Administrator!" -ForegroundColor Red
        }
    }
    
    Write-Host "`nHoan thanh!" -ForegroundColor Cyan
}

function Install-All {
    Write-Host "`n=== CAI DAT TAT CA ===" -ForegroundColor Green
    Install-Chocolatey
    Install-PowerShell7
    Install-Scoop
    Install-DevTools
    Install-WindowsApps
    Install-BuildTools
    Configure-Git
    Write-Host "`n=== SETUP COMPLETE ===" -ForegroundColor Cyan
}

# =============================
# Main Menu Loop
# =============================
do {
    Show-Menu
    $choice = Read-Host
    
    switch ($choice) {
        "1" { Install-Chocolatey }
        "2" { Install-PowerShell7 }
        "3" { Install-Scoop }
        "4" { Install-DevTools }
        "5" { Install-WindowsApps }
        "6" { Install-BuildTools }
        "7" { Configure-Git }
        "8" { Install-All }
        "9" { Activate-Windows }
        "10" { Configure-TimeAndFirewall }
        "0" { 
            Write-Host "`nThoat chuong trinh. Tam biet!" -ForegroundColor Yellow
            break 
        }
        default { 
            Write-Host "`nLua chon khong hop le! Vui long chon tu 0-10." -ForegroundColor Red
        }
    }
    
    if ($choice -ne "0" -and $choice -ne "8") {
        Write-Host "`nNhan Enter de tiep tuc..." -ForegroundColor Gray
        Read-Host
    }
} while ($choice -ne "0")
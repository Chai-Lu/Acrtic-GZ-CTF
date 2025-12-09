param (
    [string]$Command,
    [string]$Target
)

# Data extracted from src/GZCTF/ClientApp/src/utils/Shared.tsx and src/GZCTF/ClientApp/src/locales/zh-CN/challenge.json
$challenges = @{
    "misc" = @{
        Name = "Misc";
        Label = "安全杂项";
        Icon = "mdiGamepadVariantOutline";
        Color = "teal";
        DescriptionKey = "challenge.category.misc";
    };
    "pwn" = @{
        Name = "Pwn";
        Label = "二进制漏洞利用";
        Icon = "mdiBomb";
        Color = "red";
        DescriptionKey = "challenge.category.pwn";
    };
    "web" = @{
        Name = "Web";
        Label = "网络安全";
        Icon = "mdiWeb";
        Color = "blue";
        DescriptionKey = "challenge.category.web";
    };
    "reverse" = @{
        Name = "Reverse";
        Label = "逆向工程";
        Icon = "mdiChevronTripleLeft";
        Color = "yellow";
        DescriptionKey = "challenge.category.reverse";
    };
    "crypto" = @{
        Name = "Crypto";
        Label = "密码学";
        Icon = "mdiMatrix";
        Color = "violet";
        DescriptionKey = "challenge.category.crypto";
    };
    "blockchain" = @{
        Name = "Blockchain";
        Label = "区块链";
        Icon = "mdiEthereum";
        Color = "green";
        DescriptionKey = "challenge.category.blockchain";
    };
    "forensics" = @{
        Name = "Forensics";
        Label = "数字取证";
        Icon = "mdiFingerprint";
        Color = "indigo";
        DescriptionKey = "challenge.category.forensics";
    };
    "hardware" = @{
        Name = "Hardware";
        Label = "硬件安全";
        Icon = "mdiChip";
        Color = "revert (Theme Dependent)";
        DescriptionKey = "challenge.category.hardware";
    };
    "mobile" = @{
        Name = "Mobile";
        Label = "移动安全";
        Icon = "mdiCellphoneCog";
        Color = "pink";
        DescriptionKey = "challenge.category.mobile";
    };
    "ppc" = @{
        Name = "PPC";
        Label = "专业编程";
        Icon = "mdiConsole";
        Color = "cyan";
        DescriptionKey = "challenge.category.ppc";
    };
    "ai" = @{
        Name = "AI";
        Label = "人工智能安全";
        Icon = "mdiRobotLoveOutline";
        Color = "lime";
        DescriptionKey = "challenge.category.ai";
    };
    "osint" = @{
        Name = "OSINT";
        Label = "开源情报";
        Icon = "mdiSearchWeb";
        Color = "orange";
        DescriptionKey = "challenge.category.osint";
    };
    "pentest" = @{
        Name = "Pentest";
        Label = "渗透测试";
        Icon = "mdiLanPending";
        Color = "grape";
        DescriptionKey = "challenge.category.pentest";
    };
}

function Show-Help {
    Write-Host "Usage:"
    Write-Host "  .\list_challenges.ps1 ls all"
    Write-Host "  .\list_challenges.ps1 cat '<category>'"
}

if ([string]::IsNullOrEmpty($Command)) {
    Show-Help
    exit
}

switch ($Command.ToLower()) {
    "ls" {
        if ($Target -eq "all") {
            Write-Host "Available Challenge Categories:" -ForegroundColor Cyan
            $challenges.Keys | Sort-Object | ForEach-Object { Write-Host "  $_" }
        } else {
            Show-Help
        }
    }
    "cat" {
        if ($challenges.ContainsKey($Target.ToLower())) {
            $info = $challenges[$Target.ToLower()]
            Write-Host "Category: $($info.Name)" -ForegroundColor Green
            Write-Host "------------------------"
            Write-Host "Label (zh-CN): $($info.Label)"
            Write-Host "Icon (MDI):    $($info.Icon)"
            Write-Host "Color:         $($info.Color)"
            Write-Host "i18n Key:      $($info.DescriptionKey)"
        } else {
            Write-Host "Category '$Target' not found." -ForegroundColor Red
            Write-Host "Available categories: $($challenges.Keys -join ', ')"
        }
    }
    default {
        Show-Help
    }
}

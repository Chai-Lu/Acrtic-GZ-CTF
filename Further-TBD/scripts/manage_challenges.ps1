param (
    [string]$Command,
    [string]$Name,
    [switch]$n, # New
    [switch]$a, # All
    # Optional params for non-interactive mode
    [string]$Label,
    [string]$LabelEn,
    [string]$Icon,
    [string]$Color,
    [string]$EnumName
)

$RootPath = "$PSScriptRoot\..\.."
$ScriptsDir = "$PSScriptRoot"
$NameDir = "$ScriptsDir\name"
$BackupDir = "$ScriptsDir\backup"
$LocalesDir = "$RootPath\src\GZCTF\ClientApp\src\locales"

# File Paths
$EnumFile = "$RootPath\src\GZCTF\Utils\Enums.cs"
$SharedFile = "$RootPath\src\GZCTF\ClientApp\src\utils\Shared.tsx"
$ThemeFile = "$RootPath\src\GZCTF\ClientApp\src\utils\ThemeOverride.ts"

# Ensure directories exist
if (-not (Test-Path $NameDir)) { New-Item -ItemType Directory -Path $NameDir | Out-Null }

function Get-Locales {
    return Get-ChildItem $LocalesDir -Directory | Select-Object -ExpandProperty Name
}

function Initialize-System {
    if (Test-Path $BackupDir) {
        Write-Host "Backup directory exists." -ForegroundColor Yellow
        $response = Read-Host "Overwrite existing backup with current files? (Y/N) [Warning: This will destroy the previous backup]"
        if ($response -ne 'Y') { 
            Write-Host "Skipping backup creation." -ForegroundColor Gray
            return 
        }
    } else {
        New-Item -ItemType Directory -Path $BackupDir | Out-Null
    }

    Write-Host "Backing up files..." -ForegroundColor Cyan
    Copy-Item $EnumFile "$BackupDir\Enums.cs" -Force
    Copy-Item $SharedFile "$BackupDir\Shared.tsx" -Force
    Copy-Item $ThemeFile "$BackupDir\ThemeOverride.ts" -Force
    
    # Backup all locales
    $locales = Get-Locales
    foreach ($lang in $locales) {
        $src = "$LocalesDir\$lang\challenge.json"
        if (Test-Path $src) {
            $destDir = "$BackupDir\locales\$lang"
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Copy-Item $src "$destDir\challenge.json" -Force
        }
    }

    Write-Host "Parsing existing categories..." -ForegroundColor Cyan
    
    # Read zh-CN and en-US for base labels
    $cnFile = "$LocalesDir\zh-CN\challenge.json"
    $enFile = "$LocalesDir\en-US\challenge.json"
    
    $jsonContent = Get-Content $cnFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $jsonContentEn = Get-Content $enFile -Raw -Encoding UTF8 | ConvertFrom-Json
    
    $categories = $jsonContent.category | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

    # Read Shared.tsx for Icons/Colors
    $sharedContent = Get-Content $SharedFile -Raw -Encoding UTF8

    foreach ($cat in $categories) {
        $label = $jsonContent.category.$cat
        $labelEn = $jsonContentEn.category.$cat
        if ([string]::IsNullOrEmpty($labelEn)) { $labelEn = $cat } # Fallback
        
        # Map json key to Enum Name (TitleCase usually)
        $enumName = (Get-Culture).TextInfo.ToTitleCase($cat)
        if ($cat -eq "ppc") { $enumName = "PPC" }
        if ($cat -eq "ai") { $enumName = "AI" }
        if ($cat -eq "osint") { $enumName = "OSINT" }

        # Regex to find properties in Shared.tsx
        $pattern = "(?s)ChallengeCategory\.$enumName,\s*\{\s*desrc:.*?icon:\s*(?<icon>[\w\d]+).*?color:\s*'(?<color>[\w\d]+)'"
        if ($sharedContent -match $pattern) {
            $icon = $matches['icon']
            $color = $matches['color']
        } else {
            $icon = "Unknown"
            $color = "Unknown"
        }

        # Collect other translations
        $translations = @{}
        foreach ($lang in $locales) {
            if ($lang -eq "zh-CN" -or $lang -eq "en-US") { continue }
            $lFile = "$LocalesDir\$lang\challenge.json"
            if (Test-Path $lFile) {
                $lJson = Get-Content $lFile -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($lJson.category.PSObject.Properties[$cat]) {
                    $translations[$lang] = $lJson.category.$cat
                }
            }
        }

        $data = @{
            Name = $enumName
            Key = $cat
            Label = $label
            LabelEn = $labelEn
            Icon = $icon
            Color = $color
            Translations = $translations
        }
        
        # Save as JSON (Unescaped)
        $json = $data | ConvertTo-Json -Depth 5
        $json = [System.Text.RegularExpressions.Regex]::Unescape($json)
        Set-Content "$NameDir\$cat.json" -Value $json -Encoding UTF8
    }
    Write-Host "Initialization complete. Data saved to $NameDir" -ForegroundColor Green
}

function Show-Colors {
    Write-Host "Analyzing Color Usage..." -ForegroundColor Cyan
    
    # 1. Get Standard & Custom Colors from ThemeOverride.ts
    $themeContent = Get-Content $ThemeFile -Raw -Encoding UTF8
    $definedColors = @()
    
    # Regex to find keys in colors: { ... }
    # Matches "key: ["
    $colorMatches = [regex]::Matches($themeContent, "(\w+):\s*\[")
    foreach ($m in $colorMatches) {
        $definedColors += $m.Groups[1].Value
    }
    
    # Add standard Mantine colors if not explicitly in ThemeOverride (they are built-in)
    $mantineColors = @("red", "pink", "grape", "violet", "indigo", "blue", "cyan", "teal", "green", "lime", "yellow", "orange", "gray", "dark")
    foreach ($c in $mantineColors) {
        if ($c -notin $definedColors) { $definedColors += $c }
    }
    $definedColors = $definedColors | Sort-Object -Unique

    # 2. Analyze Usage in Categories
    $usage = @{}
    $catMap = @{}
    
    Get-ChildItem "$NameDir\*.json" | ForEach-Object {
        $data = Get-Content $_.FullName -Encoding UTF8 | ConvertFrom-Json
        $c = $data.Color
        if (-not $usage.ContainsKey($c)) { 
            $usage[$c] = 0 
            $catMap[$c] = @()
        }
        $usage[$c]++
        $catMap[$c] += $data.Name
    }

    # 3. Display
    Write-Host "`n[Available Colors]" -ForegroundColor Green
    foreach ($c in $definedColors) {
        $count = if ($usage[$c]) { $usage[$c] } else { 0 }
        $cats = if ($catMap[$c]) { $catMap[$c] -join ", " } else { "" }
        
        $colorStr = "$c".PadRight(15)
        $countStr = "Used: $count".PadRight(10)
        
        if ($count -gt 0) {
            Write-Host "  $colorStr $countStr ($cats)" -ForegroundColor Yellow
        } else {
            Write-Host "  $colorStr $countStr" -ForegroundColor Gray
        }
    }
    
    # Show undefined colors if any used
    foreach ($key in $usage.Keys) {
        if ($key -notin $definedColors) {
            Write-Host "  $key (Undefined!) Used: $($usage[$key]) ($($catMap[$key] -join ", "))" -ForegroundColor Red
        }
    }
    Write-Host ""
}

function Add-CustomColor {
    param ($ColorName, $HexCode)
    
    Write-Host "Adding custom color '$ColorName' ($HexCode) to ThemeOverride.ts..." -ForegroundColor Cyan
    
    $themeContent = Get-Content $ThemeFile -Raw -Encoding UTF8
    
    if ($themeContent -match "${ColorName}:") {
        Write-Host "Color '$ColorName' already exists in theme." -ForegroundColor Yellow
        return
    }
    
    $pattern = "(dark:\s*\[[^\]]*\],)"
    if ($themeContent -match $pattern) {
        $insert = "`n    ${ColorName}: generateColors('$HexCode'),"
        $themeContent = $themeContent -replace $pattern, "`$1$insert"
        Set-Content $ThemeFile $themeContent -Encoding UTF8
        Write-Host "  [+] Updated ThemeOverride.ts" -ForegroundColor Green
    } else {
        Write-Host "  [!] Could not find insertion point in ThemeOverride.ts" -ForegroundColor Red
    }
}

function Add-Category {
    param ($CatName)
    $CatName = $CatName.ToLower()

    if (Test-Path "$NameDir\$CatName.json") {
        Write-Host "Category '$CatName' already exists in $NameDir." -ForegroundColor Yellow
        $response = Read-Host "Overwrite? (Y/N)"
        if ($response -ne 'Y') { return }
    }

    # Load existing data for duplicate checking
    $existing = @()
    Get-ChildItem "$NameDir\*.json" | ForEach-Object {
        $existing += Get-Content $_.FullName -Encoding UTF8 | ConvertFrom-Json
    }

    if ([string]::IsNullOrEmpty($Label)) { 
        while ($true) {
            $Label = Read-Host "Enter Label (Chinese Name, e.g. '<Chinese Name>')" 
            if ($existing.Label -contains $Label) {
                Write-Host "Warning: Label '$Label' is already used." -ForegroundColor Yellow
                $c = Read-Host "Continue anyway? (Y/N)"
                if ($c -eq 'Y') { break }
                $Label = ""
            } else { break }
        }
    }

    if ([string]::IsNullOrEmpty($LabelEn)) { 
        while ($true) {
            $LabelEn = Read-Host "Enter Label (English Name, e.g. 'Open Source Intelligence')" 
            if ($existing.LabelEn -contains $LabelEn) {
                Write-Host "Warning: LabelEn '$LabelEn' is already used." -ForegroundColor Yellow
                $c = Read-Host "Continue anyway? (Y/N)"
                if ($c -eq 'Y') { break }
                $LabelEn = ""
            } else { break }
        }
    }

    if ([string]::IsNullOrEmpty($Icon)) { $Icon = Read-Host "Enter Icon (MDI Name, e.g. 'mdiSearchWeb')" }
    
    $standardColors = @("red", "pink", "grape", "violet", "indigo", "blue", "cyan", "teal", "green", "lime", "yellow", "orange", "gray", "dark", "brand", "alert", "light")
    
    if ([string]::IsNullOrEmpty($Color)) { 
        $Color = Read-Host "Enter Color (Mantine Color, e.g. 'orange')" 
    }

    # Check color usage
    $colorUsedBy = $existing | Where-Object { $_.Color -eq $Color } | Select-Object -ExpandProperty Name
    if ($colorUsedBy) {
        Write-Host "Warning: Color '$Color' is already used by: $($colorUsedBy -join ', ')" -ForegroundColor Yellow
    }

    if ($Color -notin $standardColors) {
        Write-Host "Color '$Color' is not a standard Mantine color." -ForegroundColor Yellow
        $isCustom = Read-Host "Is this a new custom color you want to add? (Y/N)"
        if ($isCustom -eq 'Y') {
            $hex = Read-Host "Enter Hex Code (e.g. #FF00FF)"
            if ($hex -match "^#[0-9a-fA-F]{6}$") {
                Add-CustomColor -ColorName $Color -HexCode $hex
            } else {
                Write-Host "Invalid Hex Code. Using 'gray' as fallback." -ForegroundColor Red
                $Color = "gray"
            }
        } else {
             Write-Host "Proceeding with '$Color' assuming it exists or you will add it manually." -ForegroundColor Gray
        }
    }

    if ([string]::IsNullOrEmpty($EnumName)) { 
        while ($true) {
            $EnumName = Read-Host "Enter Enum Name (PascalCase, e.g. 'OSINT')" 
            if ($existing.Name -contains $EnumName) {
                Write-Host "Error: Enum Name '$EnumName' is already used. It must be unique." -ForegroundColor Red
                $EnumName = ""
            } else { break }
        }
    }

    Write-Host "`nSummary:" -ForegroundColor Cyan
    Write-Host "  Key:      $CatName"
    Write-Host "  Enum:     $EnumName"
    Write-Host "  Label:    $Label"
    Write-Host "  LabelEn:  $LabelEn"
    Write-Host "  Icon:     $Icon"
    Write-Host "  Color:    $Color"

    $confirm = Read-Host "All right? (Y/N)"
    if ($confirm -ne 'Y') { return }

    $data = @{
        Name = $EnumName
        Key = $CatName
        Label = $Label
        LabelEn = $LabelEn
        Icon = $Icon
        Color = $Color
        Translations = @{}
    }
    
    $json = $data | ConvertTo-Json -Depth 5
    $json = [System.Text.RegularExpressions.Regex]::Unescape($json)
    Set-Content "$NameDir\$CatName.json" -Value $json -Encoding UTF8

    Apply-Category -Data $data
}

function Edit-Locale {
    param ($CatName)
    
    if (-not (Test-Path "$NameDir\$CatName.json")) {
        Write-Host "Category '$CatName' not found." -ForegroundColor Red
        return
    }

    $data = Get-Content "$NameDir\$CatName.json" -Encoding UTF8 | ConvertFrom-Json
    
    Write-Host "Current Translations for '$CatName':" -ForegroundColor Cyan
    Write-Host "  [zh-CN] $($data.Label)"
    Write-Host "  [en-US] $($data.LabelEn)"
    
    $locales = Get-Locales
    foreach ($lang in $locales) {
        if ($lang -eq "zh-CN" -or $lang -eq "en-US") { continue }
        $val = if ($data.Translations.$lang) { $data.Translations.$lang } else { "(Default: $($data.LabelEn))" }
        Write-Host "  [$lang] $val"
    }
    
    $targetLang = Read-Host "`nEnter language code to edit (e.g. ja-JP, or 'cancel')"
    if ($targetLang -eq "cancel" -or [string]::IsNullOrWhiteSpace($targetLang)) { return }
    
    if ($targetLang -notin $locales) {
        Write-Host "Language '$targetLang' not found in locales directory." -ForegroundColor Red
        return
    }

    $currentVal = ""
    if ($targetLang -eq "zh-CN") { $currentVal = $data.Label }
    elseif ($targetLang -eq "en-US") { $currentVal = $data.LabelEn }
    elseif ($data.Translations.$targetLang) { $currentVal = $data.Translations.$targetLang }
    
    Write-Host "Current value: $currentVal"
    $newVal = Read-Host "Enter new text"
    
    if ([string]::IsNullOrWhiteSpace($newVal)) { return }

    # Update Data Object
    if ($targetLang -eq "zh-CN") { $data.Label = $newVal }
    elseif ($targetLang -eq "en-US") { $data.LabelEn = $newVal }
    else {
        # Ensure Translations object exists
        if (-not $data.Translations) { $data | Add-Member -NotePropertyName "Translations" -NotePropertyValue @{} }
        $data.Translations.$targetLang = $newVal
    }

    # Save JSON
    $json = $data | ConvertTo-Json -Depth 5
    $json = [System.Text.RegularExpressions.Regex]::Unescape($json)
    Set-Content "$NameDir\$CatName.json" -Value $json -Encoding UTF8
    
    Write-Host "Saved to $NameDir\$CatName.json" -ForegroundColor Green
    
    $apply = Read-Host "Apply changes to source files now? (Y/N)"
    if ($apply -eq 'Y') {
        Apply-Category -Data $data
    }
}

function Apply-Category {
    param ($Data)

    Write-Host "Applying changes for $($Data.Name)..." -ForegroundColor Cyan

    # 1. Update Enums.cs
    $enumContent = Get-Content $EnumFile -Raw -Encoding UTF8
    
    # Use a specific regex to capture the ChallengeCategory block
    $blockRegex = [regex]"(public enum ChallengeCategory : byte\s*\{)([\s\S]*?)(\})"
    $match = $blockRegex.Match($enumContent)
    
    if ($match.Success) {
        $header = $match.Groups[1].Value
        $body = $match.Groups[2].Value
        $footer = $match.Groups[3].Value
        
        if ($body -notmatch "\b$($Data.Name)\b") {
            # Find max value ONLY within this block
            $enumMatches = [regex]::Matches($body, "(\w+)\s*=\s*(\d+)")
            $maxVal = 0
            foreach ($m in $enumMatches) {
                $val = [int]$m.Groups[2].Value
                if ($val -gt $maxVal) { $maxVal = $val }
            }
            $newVal = $maxVal + 1
            
            # Insert new entry
            $newEntry = "    $($Data.Name) = $newVal,"
            
            # Reconstruct the block
            $trimmedBody = $body.TrimEnd()
            # Ensure the previous item ends with a comma to prevent CS1003
            if ($trimmedBody.Length -gt 0 -and -not $trimmedBody.EndsWith(",")) {
                $trimmedBody += ","
            }
            
            $newBody = "$trimmedBody`n$newEntry`n"
            
            $newBlock = "$header$newBody$footer"
            
            $enumContent = $enumContent.Replace($match.Value, $newBlock)
            Set-Content $EnumFile $enumContent -Encoding UTF8
            Write-Host "  [+] Updated Enums.cs" -ForegroundColor Green
        } else {
            Write-Host "  [*] Enums.cs already contains $($Data.Name)" -ForegroundColor Gray
        }
    } else {
        Write-Error "Could not find ChallengeCategory enum in Enums.cs"
    }

    # 2. Update ALL Locales
    $locales = Get-Locales
    foreach ($lang in $locales) {
        $targetFile = "$LocalesDir\$lang\challenge.json"
        if (-not (Test-Path $targetFile)) { continue }
        
        $jsonContent = Get-Content $targetFile -Raw -Encoding UTF8 | ConvertFrom-Json
        
        # Determine value to write
        $valToWrite = $Data.LabelEn # Default fallback
        
        if ($lang -eq "zh-CN") {
            $valToWrite = $Data.Label
        } elseif ($lang -eq "en-US") {
            $valToWrite = $Data.LabelEn
        } elseif ($Data.Translations -and $Data.Translations.$lang) {
            $valToWrite = $Data.Translations.$lang
        }
        
        # Update if missing or different (we overwrite to ensure consistency with name/*.json)
        # Actually, let's only add if missing OR if we are explicitly applying updates.
        # Since this function is called "Apply", it should enforce the state in $Data.
        
        if (-not $jsonContent.category.PSObject.Properties[$Data.Key]) {
            $jsonContent.category | Add-Member -NotePropertyName $Data.Key -NotePropertyValue $valToWrite
            $updated = $true
        } elseif ($jsonContent.category.$($Data.Key) -ne $valToWrite) {
            $jsonContent.category.$($Data.Key) = $valToWrite
            $updated = $true
        } else {
            $updated = $false
        }

        if ($updated) {
            $jsonOutput = $jsonContent | ConvertTo-Json -Depth 10
            $jsonOutput = [System.Text.RegularExpressions.Regex]::Unescape($jsonOutput)
            Set-Content $targetFile $jsonOutput -Encoding UTF8
            Write-Host "  [+] Updated challenge.json ($lang) -> '$valToWrite'" -ForegroundColor Green
        } else {
            # Write-Host "  [*] challenge.json ($lang) up to date" -ForegroundColor Gray
        }
    }

    # 3. Update Shared.tsx
    $sharedContent = Get-Content $SharedFile -Raw -Encoding UTF8
    if ($sharedContent -notmatch "ChallengeCategory\.$($Data.Name),") {
        $newEntry = "    [
      ChallengeCategory.$($Data.Name),
      {
        desrc: t('challenge.category.$($Data.Key)'),
        icon: $($Data.Icon),
        name: ChallengeCategory.$($Data.Name),
        color: '$($Data.Color)',
        colors: theme.colors['$($Data.Color)'],
      },
    ],"
        
        # Robust insertion: Find the specific function and insert into its map
        $funcSignature = "export const useChallengeCategoryLabelMap"
        $idxFunc = $sharedContent.IndexOf($funcSignature)
        
        if ($idxFunc -ge 0) {
            # Look for the closing "  ])" of the map, starting search from the function definition
            # We use a regex to find the first occurrence of indentation + ]) after the function start
            $restOfString = $sharedContent.Substring($idxFunc)
            
            # Match "  ])" at the start of a line
            $closeRegex = [regex]::new("^\s{2}\]\)", [System.Text.RegularExpressions.RegexOptions]::Multiline)
            $match = $closeRegex.Match($restOfString)
            
            if ($match.Success) {
                # Calculate absolute insertion point
                $insertIdx = $idxFunc + $match.Index
                
                # Insert the new entry followed by a newline
                $sharedContent = $sharedContent.Insert($insertIdx, "$newEntry`n")
                
                # Handle Imports
                if ($sharedContent -notmatch "import \{.*$($Data.Icon).*\} from '@mdi/js'") {
                     $sharedContent = $sharedContent -replace "} from '@mdi/js'", ", $($Data.Icon) } from '@mdi/js'"
                }

                Set-Content $SharedFile $sharedContent -Encoding UTF8
                Write-Host "  [+] Updated Shared.tsx" -ForegroundColor Green
            } else {
                Write-Error "Could not find closing bracket for useChallengeCategoryLabelMap in Shared.tsx"
            }
        } else {
            Write-Error "Could not find function useChallengeCategoryLabelMap in Shared.tsx"
        }
    } else {
        Write-Host "  [*] Shared.tsx already contains $($Data.Name)" -ForegroundColor Gray
    }
}

function Restore-Backup {
    if (-not (Test-Path $BackupDir)) {
        Write-Host "No backup found!" -ForegroundColor Red
        return
    }
    
    Write-Host "Restoring files..." -ForegroundColor Cyan
    Copy-Item "$BackupDir\Enums.cs" $EnumFile -Force
    Copy-Item "$BackupDir\Shared.tsx" $SharedFile -Force
    Copy-Item "$BackupDir\ThemeOverride.ts" $ThemeFile -Force
    
    $locales = Get-ChildItem "$BackupDir\locales" -Directory
    foreach ($dir in $locales) {
        $lang = $dir.Name
        $src = "$dir\challenge.json"
        $dest = "$LocalesDir\$lang\challenge.json"
        if (Test-Path $src) {
            Copy-Item $src $dest -Force
        }
    }
    
    # Re-sync name/*.json with restored files to prevent re-applying bad configs
    Write-Host "Syncing name definitions with restored files..." -ForegroundColor Cyan
    
    $response = Read-Host "Do you want to reset the 'name' directory based on restored files? (Recommended) (Y/N)"
    if ($response -eq 'Y') {
        Remove-Item "$NameDir\*.json" -Force -ErrorAction SilentlyContinue
        
        # Re-parse logic (Simplified from Initialize-System)
        $cnFile = "$LocalesDir\zh-CN\challenge.json"
        $enFile = "$LocalesDir\en-US\challenge.json"
        
        if (Test-Path $cnFile) {
            $jsonContent = Get-Content $cnFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $jsonContentEn = Get-Content $enFile -Raw -Encoding UTF8 | ConvertFrom-Json
            $categories = $jsonContent.category | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
            $sharedContent = Get-Content $SharedFile -Raw -Encoding UTF8

            foreach ($cat in $categories) {
                $label = $jsonContent.category.$cat
                $labelEn = $jsonContentEn.category.$cat
                if ([string]::IsNullOrEmpty($labelEn)) { $labelEn = $cat }
                
                $enumName = (Get-Culture).TextInfo.ToTitleCase($cat)
                if ($cat -eq "ppc") { $enumName = "PPC" }
                if ($cat -eq "ai") { $enumName = "AI" }
                if ($cat -eq "osint") { $enumName = "OSINT" }

                $pattern = "(?s)ChallengeCategory\.$enumName,\s*\{\s*desrc:.*?icon:\s*(?<icon>[\w\d]+).*?color:\s*'(?<color>[\w\d]+)'"
                if ($sharedContent -match $pattern) {
                    $icon = $matches['icon']
                    $color = $matches['color']
                } else {
                    $icon = "Unknown"
                    $color = "Unknown"
                }
                
                $data = @{
                    Name = $enumName
                    Key = $cat
                    Label = $label
                    LabelEn = $labelEn
                    Icon = $icon
                    Color = $color
                    Translations = @{}
                }
                $json = $data | ConvertTo-Json -Depth 5
                $json = [System.Text.RegularExpressions.Regex]::Unescape($json)
                Set-Content "$NameDir\$cat.json" -Value $json -Encoding UTF8
            }
            Write-Host "Name definitions reset." -ForegroundColor Green
        } else {
            Write-Host "Warning: Could not find locale files to re-parse." -ForegroundColor Yellow
        }
    }

    Write-Host "Restored from backup." -ForegroundColor Yellow
}

function Show-Help {
    Write-Host "Available Commands:" -ForegroundColor Cyan
    Write-Host "  ls all                List all categories"
    Write-Host "  cat <name>            Show details of a category"
    Write-Host "  wrt <name> -n         Add a new category (Wizard)"
    Write-Host "  edit <name>           Edit translations for a category"
    Write-Host "  colors                Show available and used colors"
    Write-Host "  wrt cover -a          Apply all JSONs to source code"
    Write-Host "  wrt cancel -a         Restore from backup"
    Write-Host "  init                  Re-initialize (Backup & Parse)"
    Write-Host "  cls / clear           Clear screen"
    Write-Host "  exit                  Exit CLI"
}

function Run-CoreLogic {
    param ($Command, $Name, $n, $a)
    
    switch ($Command) {
        "ls" {
            if ($Name -eq "all") {
                Write-Host "Available Challenge Categories:" -ForegroundColor Cyan
                Get-ChildItem "$NameDir\*.json" | ForEach-Object {
                    Write-Host "  $($_.BaseName)"
                }
            } else {
                Write-Host "Usage: ls all"
            }
        }
        "cat" {
            if (Test-Path "$NameDir\$Name.json") {
                $info = Get-Content "$NameDir\$Name.json" -Encoding UTF8 | ConvertFrom-Json
                Write-Host "Category: $($info.Name)" -ForegroundColor Green
                Write-Host "------------------------"
                Write-Host "Label (zh-CN): $($info.Label)"
                Write-Host "Label (en-US): $($info.LabelEn)"
                Write-Host "Icon (MDI):    $($info.Icon)"
                Write-Host "Color:         $($info.Color)"
                Write-Host "Key:           $($info.Key)"
                if ($info.Translations) {
                    Write-Host "Translations:"
                    $info.Translations.PSObject.Properties | ForEach-Object {
                        Write-Host "  $($_.Name): $($_.Value)"
                    }
                }
            } else {
                Write-Host "Category '$Name' not found." -ForegroundColor Red
            }
        }
        "wrt" {
            if ($n) {
                Add-Category -CatName $Name
            } elseif ($Name -eq "cover" -and $a) {
                Get-ChildItem "$NameDir\*.json" | ForEach-Object {
                    $data = Get-Content $_.FullName -Encoding UTF8 | ConvertFrom-Json
                    Apply-Category -Data $data
                }
            } elseif ($Name -eq "cancel" -and $a) {
                Restore-Backup
            } else {
                Write-Host "Unknown command or missing flags."
            }
        }
        "edit" {
            Edit-Locale -CatName $Name
        }
        "colors" {
            Show-Colors
        }
        "init" { Initialize-System }
        "help" { Show-Help }
        default { Show-Help }
    }
}

# --- Main Execution Flow ---

if ($PSBoundParameters.Count -gt 0) {
    # Script Mode
    Run-CoreLogic -Command $Command -Name $Name -n:$n -a:$a
} else {
    # Interactive Mode
    if ((Get-ChildItem $NameDir).Count -eq 0) { Initialize-System }
    
    Write-Host "GZCTF Interactive CLI" -ForegroundColor Cyan
    Write-Host "Type 'help' for commands."
    
    while ($true) {
        $userInput = Read-Host "GZCTF"
        if ([string]::IsNullOrWhiteSpace($userInput)) { continue }
        $parts = $userInput.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
        
        if ($parts[0] -in "exit", "quit") { break }
        if ($parts[0] -in "cls", "clear") { Clear-Host; continue }
        
        # Parse
        $cmd = $parts[0]
        $pName = ""
        if ($parts.Count -gt 1 -and -not $parts[1].StartsWith("-")) { $pName = $parts[1] }
        $pn = $parts -contains "-n"
        $pa = $parts -contains "-a"
        
        try {
            Run-CoreLogic -Command $cmd -Name $pName -n:$pn -a:$pa
        } catch {
            Write-Error $_
        }
    }
}

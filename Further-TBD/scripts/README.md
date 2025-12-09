# GZCTF Challenge Category Manager

This directory contains utility scripts for GZCTF development and management.

## manage_challenges.ps1

This is the main utility script. It allows you to manage challenge categories in the GZCTF platform. It automates the process of adding new categories by modifying the necessary C# (`Enums.cs`), TypeScript (`Shared.tsx`), and JSON (`challenge.json`) files.

### Features

- **List Categories**: View all currently configured categories.
- **Add Category**: Interactive wizard to add a new category.
- **Edit Translations**: Modify translations for specific languages (i18n).
- **Color Analysis**: Analyze color usage across categories and detect undefined colors.
- **Custom Colors**: Define and register custom hex colors for the theme.
- **Backup & Restore**: Automatically backs up files before modification and allows easy rollback.
- **Persistence**: Saves category definitions to `name/*.json` for re-application.

### Usage

Open a PowerShell terminal in this directory.

#### Interactive Mode (Recommended)
Run the script without arguments to enter the interactive shell.
`powershell
.\manage_challenges.ps1
` 
You will see a `GZCTF` prompt. You can type commands directly:

`	ext
GZCTF> ls all
GZCTF> wrt opensource -n
GZCTF> edit opensource
GZCTF> colors
GZCTF> help
GZCTF> exit
` 

#### Script Mode (Legacy)
You can still run single commands directly from PowerShell.

**1. List Categories**
`powershell
.\manage_challenges.ps1 ls all
` 

**2. Add a New Category**
Start the interactive wizard to add a new category (e.g., "opensource").
`powershell
.\manage_challenges.ps1 wrt opensource -n
` 
You will be prompted for:
- **Label**: The display name in Chinese (e.g., "��Դ�鱨").
- **LabelEn**: The display name in English (e.g., "Open Source Intelligence").
- **Icon**: The MDI icon name (e.g., "mdiSearchWeb").
- **Color**: The Mantine color name (e.g., "orange").
- **Enum Name**: The internal C# Enum name (e.g., "OSINT").

**Internationalization (i18n):**
The script automatically detects all language folders in `src/locales`.
- When creating a category, if you only provide CN/EN labels, all other languages (e.g., `ja-JP`, `ru-RU`) will default to the English label.
- You can update these later using the `edit` command.

**3. Edit Translations**
To modify the translation for a specific language after creation:
`powershell
.\manage_challenges.ps1 edit opensource
` 
This will launch an interactive wizard where you can select a language (e.g., `ja-JP`) and enter the new translation.

#### Available Colors
The system uses the Mantine theming engine. You can use standard colors or define new ones interactively.

**Standard Mantine Colors:**
- `red`, `pink`, `grape`, `violet`, `indigo`, `blue`, `cyan`, `teal`, `green`, `lime`, `yellow`, `orange`, `gray`, `dark`

**GZCTF Custom Colors:**
- `brand` (Teal/Green variant)
- `alert` (Red variant)
- `light` (White/Light Gray variant)

**New Custom Colors:**
If you enter a color name that is not in the list above (e.g., `cyberpunk`), the script will ask if you want to create it. If you say yes, you can provide a Hex Code (e.g., `#FF00FF`), and the script will automatically register it in `ThemeOverride.ts` using Mantine's `generateColors` utility.

**4. Restore Backup**
If something goes wrong, you can restore the original files.
`powershell
.\manage_challenges.ps1 wrt cancel -a
` 

**5. Apply All Categories**
Re-apply all categories found in the `name/` directory to the source code. Useful if you have manually edited the JSON files.
`powershell
.\manage_challenges.ps1 wrt cover -a
` 

**6. Analyze Colors**
View a report of all available colors (standard + custom) and see which categories are using them. This helps prevent color clashes and identifies undefined colors.
`powershell
.\manage_challenges.ps1 colors
` 

### Directory Structure

- `manage_challenges.ps1`: The main script.
- `list_challenges.ps1`: Legacy read-only list script.
- `backup/`: Contains the original copies of modified files.
- `name/`: Contains JSON definitions for each category.

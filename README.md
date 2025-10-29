# TBlauwe's dotfiles

Personal repository to manage dotfiles across machines using [chezmoi](https://www.chezmoi.io/).

## 🔧 Required

* Powershell 7+ is recommended.

```pwsh
msiexec.exe /package PowerShell-7.5.4-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 DISABLE_TELEMETRY=1 ADD_PATH=1
```


## 🚀 QuickStart

On Unix / MacOs:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply TBlauwe 
```


On Windows:

```pwsh
iex "&{$(irm 'https://get.chezmoi.io/ps1')}" --init --apply TBLauwe
```


# snag-that-ext

Snag that Extension!

Downloads VSIX files from the VS Code Extension Marketplace for offline install

## Usage

Cross-platform, use the Powershell script on Windows and the Bash script on Linux

```txt
Snag That Extension! - Downloads the VSIX file from the VS Code Extension Marketplace for offline install

Usage:
  snag-that-ext.sh -Publisher PUBLISHER -ExtensionName EXTENSION_NAME \
                   [-Version VERSION] [-OutputPath OUTPUT_DIR]

  snag-that-ext.sh -ExtensionLink MARKETPLACE_URL \
                   [-Version VERSION] [-OutputPath OUTPUT_DIR]

Arguments:
  -Publisher     -p  Required unless -ExtensionLink is used
  -ExtensionName -n  Required unless -ExtensionLink is used
  -ExtensionLink -l  Optional, Marketplace URL, takes precedence over -Publisher and -ExtensionName if all provided

  -Version       -v  Optional, defaults to "latest"
  -OutputPath    -o  Optional, directory to save the VSIX (defaults to cwd)
  -Help          -h  Display this message
```

## Download

### Linux

Download it with:

```bash
curl -fsSL https://raw.githubusercontent.com/soda3x/snag-that-ext/main/snag-that-ext.sh -o snag-that-ext.sh
```

Make it executable with:

```bash
chmod +x snag-that-ext.sh
```

I suggest putting it on your `$PATH` and removing the `.sh` extension so you can run it like `snag-that-ext -Publisher foo -ExtensionName bar`

### Windows

```powershell
iwr https://raw.githubusercontent.com/soda3x/snag-that-ext/main/snag-that-ext.ps1 -OutFile snag-that-ext.ps1
```

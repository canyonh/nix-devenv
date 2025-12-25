# iTerm2 Configuration

## Exporting Your Current iTerm2 Settings

On your macOS machine, run:

```bash
# Export iTerm2 preferences
cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/nix-devenv/config/iterm2/

# If you use dynamic profiles, also copy those
mkdir -p ~/nix-devenv/config/iterm2/DynamicProfiles
cp ~/Library/Application\ Support/iTerm2/DynamicProfiles/* ~/nix-devenv/config/iterm2/DynamicProfiles/
```

## Alternative: Use iTerm2's Built-in Export

1. Open iTerm2
2. Go to **Preferences** → **General** → **Preferences**
3. Check "Load preferences from a custom folder or URL"
4. Set it to: `~/nix-devenv/config/iterm2/`
5. iTerm2 will save all settings there

## After Exporting

Once you've copied the files, commit them to git and home-manager will sync them across machines.

## Note

iTerm2 is macOS-only. On Linux systems, we use Alacritty instead.

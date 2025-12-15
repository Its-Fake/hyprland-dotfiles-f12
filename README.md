# Screenshots
<div>
  <img src="/screenshots/kitty+vscode.png" width="49%"> <img src="/screenshots/rofi+eww+dunst+waybar.png" width="49%">
</div>
<div>
  <img src="screenshots/wallpaperselect.png" width="49%"> <img src="/screenshots/kitty.png" width="49%">
</div>

### Chromium Pywal theme
Adapted from https://github.com/metafates/ChromiumPywal
1. Open chromium
2. Go to chrome://extensions
3. Turn on "Developer Mode" in the top right corner
4. Press "Load unpacked"
5. Select "Pywal" (by default) in the same folder with the script

Each time you change your wallpaper you have to load the extension again.

For Firefox / Thunderbird you can also use
https://github.com/Frewacom/pywalfox

(For Thunderbird it didnt work for me yet, i will try to fix it at some point)

### Discord Pywal theme
If you want your discord styled with pywal colors i recommend the following:

https://github.com/Vendicated/Vencord  
https://github.com/ZephyrCodesStuff/pywal-vencord

Create a symbolic link as follows: ln -s $HOME/.cache/wal/colors-discord.css $HOME/.config/vesktop/themes/pywal-vencord.theme.css (find the right path in discord vencord settings by opening the themes folder)

I changed the wal theme a bit so the purple colors from discord are away

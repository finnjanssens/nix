{ ... }:
{
  home.file."Library/Application Support/com.mitchellh.ghostty/config".text = ''
    # typography
    font-family = JetBrainsMono Nerd Font
    font-size=14
    font-thicken=true
    font-thicken-strength=1
    adjust-cell-height=1

    # theme
    theme = Cobalt Next

    # background
    background-opacity = 0.8
    background-blur = 80
    background-blur-radius = 20

    # Accessibility
    mouse-hide-while-typing = true
    maximize = true
  '';
}

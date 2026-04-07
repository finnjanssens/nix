{ ... }:
{
  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    theme = Blue Matrix
    font-size = 15

    background-opacity = 0.8
    background-blur = 80
    background-blur-radius = 20

    mouse-hide-while-typing = true

    keybind = super+k=clear_screen
  '';
}

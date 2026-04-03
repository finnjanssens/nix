{ ... }:
{
  xdg.configFile."ghostty/config".text = ''
    theme = Blue Matrix
    font-size = 15

    background-opacity = 0.8
    background-blur = 80
    background-blur-radius = 20

    mouse-hide-while-typing = true
    macos-option-as-alt = true
  '';
}

vim9script

#----------------------------------------------------------------------
# terminal palette of 256 colors
#----------------------------------------------------------------------
final color_definition = [
    \ { 'color': 0, 'name': 'Black', 'hex': '#000000' },
    \ { 'color': 1, 'name': 'Maroon', 'hex': '#800000' },
    \ { 'color': 2, 'name': 'Green', 'hex': '#008000' },
    \ { 'color': 3, 'name': 'Olive', 'hex': '#808000' },
    \ { 'color': 4, 'name': 'Navy', 'hex': '#000080' },
    \ { 'color': 5, 'name': 'Purple', 'hex': '#800080' },
    \ { 'color': 6, 'name': 'Teal', 'hex': '#008080' },
    \ { 'color': 7, 'name': 'Silver', 'hex': '#c0c0c0' },
    \ { 'color': 8, 'name': 'Grey', 'hex': '#808080' },
    \ { 'color': 9, 'name': 'Red', 'hex': '#ff0000' },
    \ { 'color': 10, 'name': 'Lime', 'hex': '#00ff00' },
    \ { 'color': 11, 'name': 'Yellow', 'hex': '#ffff00' },
    \ { 'color': 12, 'name': 'Blue', 'hex': '#0000ff' },
    \ { 'color': 13, 'name': 'Fuchsia', 'hex': '#ff00ff' },
    \ { 'color': 14, 'name': 'Aqua', 'hex': '#00ffff' },
    \ { 'color': 15, 'name': 'White', 'hex': '#ffffff' },
    \ { 'color': 16, 'name': 'Grey0', 'hex': '#000000' },
    \ { 'color': 17, 'name': 'NavyBlue', 'hex': '#00005f' },
    \ { 'color': 18, 'name': 'DarkBlue', 'hex': '#000087' },
    \ { 'color': 19, 'name': 'Blue3', 'hex': '#0000af' },
    \ { 'color': 20, 'name': 'Blue3', 'hex': '#0000d7' },
    \ { 'color': 21, 'name': 'Blue1', 'hex': '#0000ff' },
    \ { 'color': 22, 'name': 'DarkGreen', 'hex': '#005f00' },
    \ { 'color': 23, 'name': 'DeepSkyBlue4', 'hex': '#005f5f' },
    \ { 'color': 24, 'name': 'DeepSkyBlue4', 'hex': '#005f87' },
    \ { 'color': 25, 'name': 'DeepSkyBlue4', 'hex': '#005faf' },
    \ { 'color': 26, 'name': 'DodgerBlue3', 'hex': '#005fd7' },
    \ { 'color': 27, 'name': 'DodgerBlue2', 'hex': '#005fff' },
    \ { 'color': 28, 'name': 'Green4', 'hex': '#008700' },
    \ { 'color': 29, 'name': 'SpringGreen4', 'hex': '#00875f' },
    \ { 'color': 30, 'name': 'Turquoise4', 'hex': '#008787' },
    \ { 'color': 31, 'name': 'DeepSkyBlue3', 'hex': '#0087af' },
    \ { 'color': 32, 'name': 'DeepSkyBlue3', 'hex': '#0087d7' },
    \ { 'color': 33, 'name': 'DodgerBlue1', 'hex': '#0087ff' },
    \ { 'color': 34, 'name': 'Green3', 'hex': '#00af00' },
    \ { 'color': 35, 'name': 'SpringGreen3', 'hex': '#00af5f' },
    \ { 'color': 36, 'name': 'DarkCyan', 'hex': '#00af87' },
    \ { 'color': 37, 'name': 'LightSeaGreen', 'hex': '#00afaf' },
    \ { 'color': 38, 'name': 'DeepSkyBlue2', 'hex': '#00afd7' },
    \ { 'color': 39, 'name': 'DeepSkyBlue1', 'hex': '#00afff' },
    \ { 'color': 40, 'name': 'Green3', 'hex': '#00d700' },
    \ { 'color': 41, 'name': 'SpringGreen3', 'hex': '#00d75f' },
    \ { 'color': 42, 'name': 'SpringGreen2', 'hex': '#00d787' },
    \ { 'color': 43, 'name': 'Cyan3', 'hex': '#00d7af' },
    \ { 'color': 44, 'name': 'DarkTurquoise', 'hex': '#00d7d7' },
    \ { 'color': 45, 'name': 'Turquoise2', 'hex': '#00d7ff' },
    \ { 'color': 46, 'name': 'Green1', 'hex': '#00ff00' },
    \ { 'color': 47, 'name': 'SpringGreen2', 'hex': '#00ff5f' },
    \ { 'color': 48, 'name': 'SpringGreen1', 'hex': '#00ff87' },
    \ { 'color': 49, 'name': 'MediumSpringGreen', 'hex': '#00ffaf' },
    \ { 'color': 50, 'name': 'Cyan2', 'hex': '#00ffd7' },
    \ { 'color': 51, 'name': 'Cyan1', 'hex': '#00ffff' },
    \ { 'color': 52, 'name': 'DarkRed', 'hex': '#5f0000' },
    \ { 'color': 53, 'name': 'DeepPink4', 'hex': '#5f005f' },
    \ { 'color': 54, 'name': 'Purple4', 'hex': '#5f0087' },
    \ { 'color': 55, 'name': 'Purple4', 'hex': '#5f00af' },
    \ { 'color': 56, 'name': 'Purple3', 'hex': '#5f00d7' },
    \ { 'color': 57, 'name': 'BlueViolet', 'hex': '#5f00ff' },
    \ { 'color': 58, 'name': 'Orange4', 'hex': '#5f5f00' },
    \ { 'color': 59, 'name': 'Grey37', 'hex': '#5f5f5f' },
    \ { 'color': 60, 'name': 'MediumPurple4', 'hex': '#5f5f87' },
    \ { 'color': 61, 'name': 'SlateBlue3', 'hex': '#5f5faf' },
    \ { 'color': 62, 'name': 'SlateBlue3', 'hex': '#5f5fd7' },
    \ { 'color': 63, 'name': 'RoyalBlue1', 'hex': '#5f5fff' },
    \ { 'color': 64, 'name': 'Chartreuse4', 'hex': '#5f8700' },
    \ { 'color': 65, 'name': 'DarkSeaGreen4', 'hex': '#5f875f' },
    \ { 'color': 66, 'name': 'PaleTurquoise4', 'hex': '#5f8787' },
    \ { 'color': 67, 'name': 'SteelBlue', 'hex': '#5f87af' },
    \ { 'color': 68, 'name': 'SteelBlue3', 'hex': '#5f87d7' },
    \ { 'color': 69, 'name': 'CornflowerBlue', 'hex': '#5f87ff' },
    \ { 'color': 70, 'name': 'Chartreuse3', 'hex': '#5faf00' },
    \ { 'color': 71, 'name': 'DarkSeaGreen4', 'hex': '#5faf5f' },
    \ { 'color': 72, 'name': 'CadetBlue', 'hex': '#5faf87' },
    \ { 'color': 73, 'name': 'CadetBlue', 'hex': '#5fafaf' },
    \ { 'color': 74, 'name': 'SkyBlue3', 'hex': '#5fafd7' },
    \ { 'color': 75, 'name': 'SteelBlue1', 'hex': '#5fafff' },
    \ { 'color': 76, 'name': 'Chartreuse3', 'hex': '#5fd700' },
    \ { 'color': 77, 'name': 'PaleGreen3', 'hex': '#5fd75f' },
    \ { 'color': 78, 'name': 'SeaGreen3', 'hex': '#5fd787' },
    \ { 'color': 79, 'name': 'Aquamarine3', 'hex': '#5fd7af' },
    \ { 'color': 80, 'name': 'MediumTurquoise', 'hex': '#5fd7d7' },
    \ { 'color': 81, 'name': 'SteelBlue1', 'hex': '#5fd7ff' },
    \ { 'color': 82, 'name': 'Chartreuse2', 'hex': '#5fff00' },
    \ { 'color': 83, 'name': 'SeaGreen2', 'hex': '#5fff5f' },
    \ { 'color': 84, 'name': 'SeaGreen1', 'hex': '#5fff87' },
    \ { 'color': 85, 'name': 'SeaGreen1', 'hex': '#5fffaf' },
    \ { 'color': 86, 'name': 'Aquamarine1', 'hex': '#5fffd7' },
    \ { 'color': 87, 'name': 'DarkSlateGray2', 'hex': '#5fffff' },
    \ { 'color': 88, 'name': 'DarkRed', 'hex': '#870000' },
    \ { 'color': 89, 'name': 'DeepPink4', 'hex': '#87005f' },
    \ { 'color': 90, 'name': 'DarkMagenta', 'hex': '#870087' },
    \ { 'color': 91, 'name': 'DarkMagenta', 'hex': '#8700af' },
    \ { 'color': 92, 'name': 'DarkViolet', 'hex': '#8700d7' },
    \ { 'color': 93, 'name': 'Purple', 'hex': '#8700ff' },
    \ { 'color': 94, 'name': 'Orange4', 'hex': '#875f00' },
    \ { 'color': 95, 'name': 'LightPink4', 'hex': '#875f5f' },
    \ { 'color': 96, 'name': 'Plum4', 'hex': '#875f87' },
    \ { 'color': 97, 'name': 'MediumPurple3', 'hex': '#875faf' },
    \ { 'color': 98, 'name': 'MediumPurple3', 'hex': '#875fd7' },
    \ { 'color': 99, 'name': 'SlateBlue1', 'hex': '#875fff' },
    \ { 'color': 100, 'name': 'Yellow4', 'hex': '#878700' },
    \ { 'color': 101, 'name': 'Wheat4', 'hex': '#87875f' },
    \ { 'color': 102, 'name': 'Grey53', 'hex': '#878787' },
    \ { 'color': 103, 'name': 'LightSlateGrey', 'hex': '#8787af' },
    \ { 'color': 104, 'name': 'MediumPurple', 'hex': '#8787d7' },
    \ { 'color': 105, 'name': 'LightSlateBlue', 'hex': '#8787ff' },
    \ { 'color': 106, 'name': 'Yellow4', 'hex': '#87af00' },
    \ { 'color': 107, 'name': 'DarkOliveGreen3', 'hex': '#87af5f' },
    \ { 'color': 108, 'name': 'DarkSeaGreen', 'hex': '#87af87' },
    \ { 'color': 109, 'name': 'LightSkyBlue3', 'hex': '#87afaf' },
    \ { 'color': 110, 'name': 'LightSkyBlue3', 'hex': '#87afd7' },
    \ { 'color': 111, 'name': 'SkyBlue2', 'hex': '#87afff' },
    \ { 'color': 112, 'name': 'Chartreuse2', 'hex': '#87d700' },
    \ { 'color': 113, 'name': 'DarkOliveGreen3', 'hex': '#87d75f' },
    \ { 'color': 114, 'name': 'PaleGreen3', 'hex': '#87d787' },
    \ { 'color': 115, 'name': 'DarkSeaGreen3', 'hex': '#87d7af' },
    \ { 'color': 116, 'name': 'DarkSlateGray3', 'hex': '#87d7d7' },
    \ { 'color': 117, 'name': 'SkyBlue1', 'hex': '#87d7ff' },
    \ { 'color': 118, 'name': 'Chartreuse1', 'hex': '#87ff00' },
    \ { 'color': 119, 'name': 'LightGreen', 'hex': '#87ff5f' },
    \ { 'color': 120, 'name': 'LightGreen', 'hex': '#87ff87' },
    \ { 'color': 121, 'name': 'PaleGreen1', 'hex': '#87ffaf' },
    \ { 'color': 122, 'name': 'Aquamarine1', 'hex': '#87ffd7' },
    \ { 'color': 123, 'name': 'DarkSlateGray1', 'hex': '#87ffff' },
    \ { 'color': 124, 'name': 'Red3', 'hex': '#af0000' },
    \ { 'color': 125, 'name': 'DeepPink4', 'hex': '#af005f' },
    \ { 'color': 126, 'name': 'MediumVioletRed', 'hex': '#af0087' },
    \ { 'color': 127, 'name': 'Magenta3', 'hex': '#af00af' },
    \ { 'color': 128, 'name': 'DarkViolet', 'hex': '#af00d7' },
    \ { 'color': 129, 'name': 'Purple', 'hex': '#af00ff' },
    \ { 'color': 130, 'name': 'DarkOrange3', 'hex': '#af5f00' },
    \ { 'color': 131, 'name': 'IndianRed', 'hex': '#af5f5f' },
    \ { 'color': 132, 'name': 'HotPink3', 'hex': '#af5f87' },
    \ { 'color': 133, 'name': 'MediumOrchid3', 'hex': '#af5faf' },
    \ { 'color': 134, 'name': 'MediumOrchid', 'hex': '#af5fd7' },
    \ { 'color': 135, 'name': 'MediumPurple2', 'hex': '#af5fff' },
    \ { 'color': 136, 'name': 'DarkGoldenrod', 'hex': '#af8700' },
    \ { 'color': 137, 'name': 'LightSalmon3', 'hex': '#af875f' },
    \ { 'color': 138, 'name': 'RosyBrown', 'hex': '#af8787' },
    \ { 'color': 139, 'name': 'Grey63', 'hex': '#af87af' },
    \ { 'color': 140, 'name': 'MediumPurple2', 'hex': '#af87d7' },
    \ { 'color': 141, 'name': 'MediumPurple1', 'hex': '#af87ff' },
    \ { 'color': 142, 'name': 'Gold3', 'hex': '#afaf00' },
    \ { 'color': 143, 'name': 'DarkKhaki', 'hex': '#afaf5f' },
    \ { 'color': 144, 'name': 'NavajoWhite3', 'hex': '#afaf87' },
    \ { 'color': 145, 'name': 'Grey69', 'hex': '#afafaf' },
    \ { 'color': 146, 'name': 'LightSteelBlue3', 'hex': '#afafd7' },
    \ { 'color': 147, 'name': 'LightSteelBlue', 'hex': '#afafff' },
    \ { 'color': 148, 'name': 'Yellow3', 'hex': '#afd700' },
    \ { 'color': 149, 'name': 'DarkOliveGreen3', 'hex': '#afd75f' },
    \ { 'color': 150, 'name': 'DarkSeaGreen3', 'hex': '#afd787' },
    \ { 'color': 151, 'name': 'DarkSeaGreen2', 'hex': '#afd7af' },
    \ { 'color': 152, 'name': 'LightCyan3', 'hex': '#afd7d7' },
    \ { 'color': 153, 'name': 'LightSkyBlue1', 'hex': '#afd7ff' },
    \ { 'color': 154, 'name': 'GreenYellow', 'hex': '#afff00' },
    \ { 'color': 155, 'name': 'DarkOliveGreen2', 'hex': '#afff5f' },
    \ { 'color': 156, 'name': 'PaleGreen1', 'hex': '#afff87' },
    \ { 'color': 157, 'name': 'DarkSeaGreen2', 'hex': '#afffaf' },
    \ { 'color': 158, 'name': 'DarkSeaGreen1', 'hex': '#afffd7' },
    \ { 'color': 159, 'name': 'PaleTurquoise1', 'hex': '#afffff' },
    \ { 'color': 160, 'name': 'Red3', 'hex': '#d70000' },
    \ { 'color': 161, 'name': 'DeepPink3', 'hex': '#d7005f' },
    \ { 'color': 162, 'name': 'DeepPink3', 'hex': '#d70087' },
    \ { 'color': 163, 'name': 'Magenta3', 'hex': '#d700af' },
    \ { 'color': 164, 'name': 'Magenta3', 'hex': '#d700d7' },
    \ { 'color': 165, 'name': 'Magenta2', 'hex': '#d700ff' },
    \ { 'color': 166, 'name': 'DarkOrange3', 'hex': '#d75f00' },
    \ { 'color': 167, 'name': 'IndianRed', 'hex': '#d75f5f' },
    \ { 'color': 168, 'name': 'HotPink3', 'hex': '#d75f87' },
    \ { 'color': 169, 'name': 'HotPink2', 'hex': '#d75faf' },
    \ { 'color': 170, 'name': 'Orchid', 'hex': '#d75fd7' },
    \ { 'color': 171, 'name': 'MediumOrchid1', 'hex': '#d75fff' },
    \ { 'color': 172, 'name': 'Orange3', 'hex': '#d78700' },
    \ { 'color': 173, 'name': 'LightSalmon3', 'hex': '#d7875f' },
    \ { 'color': 174, 'name': 'LightPink3', 'hex': '#d78787' },
    \ { 'color': 175, 'name': 'Pink3', 'hex': '#d787af' },
    \ { 'color': 176, 'name': 'Plum3', 'hex': '#d787d7' },
    \ { 'color': 177, 'name': 'Violet', 'hex': '#d787ff' },
    \ { 'color': 178, 'name': 'Gold3', 'hex': '#d7af00' },
    \ { 'color': 179, 'name': 'LightGoldenrod3', 'hex': '#d7af5f' },
    \ { 'color': 180, 'name': 'Tan', 'hex': '#d7af87' },
    \ { 'color': 181, 'name': 'MistyRose3', 'hex': '#d7afaf' },
    \ { 'color': 182, 'name': 'Thistle3', 'hex': '#d7afd7' },
    \ { 'color': 183, 'name': 'Plum2', 'hex': '#d7afff' },
    \ { 'color': 184, 'name': 'Yellow3', 'hex': '#d7d700' },
    \ { 'color': 185, 'name': 'Khaki3', 'hex': '#d7d75f' },
    \ { 'color': 186, 'name': 'LightGoldenrod2', 'hex': '#d7d787' },
    \ { 'color': 187, 'name': 'LightYellow3', 'hex': '#d7d7af' },
    \ { 'color': 188, 'name': 'Grey84', 'hex': '#d7d7d7' },
    \ { 'color': 189, 'name': 'LightSteelBlue1', 'hex': '#d7d7ff' },
    \ { 'color': 190, 'name': 'Yellow2', 'hex': '#d7ff00' },
    \ { 'color': 191, 'name': 'DarkOliveGreen1', 'hex': '#d7ff5f' },
    \ { 'color': 192, 'name': 'DarkOliveGreen1', 'hex': '#d7ff87' },
    \ { 'color': 193, 'name': 'DarkSeaGreen1', 'hex': '#d7ffaf' },
    \ { 'color': 194, 'name': 'Honeydew2', 'hex': '#d7ffd7' },
    \ { 'color': 195, 'name': 'LightCyan1', 'hex': '#d7ffff' },
    \ { 'color': 196, 'name': 'Red1', 'hex': '#ff0000' },
    \ { 'color': 197, 'name': 'DeepPink2', 'hex': '#ff005f' },
    \ { 'color': 198, 'name': 'DeepPink1', 'hex': '#ff0087' },
    \ { 'color': 199, 'name': 'DeepPink1', 'hex': '#ff00af' },
    \ { 'color': 200, 'name': 'Magenta2', 'hex': '#ff00d7' },
    \ { 'color': 201, 'name': 'Magenta1', 'hex': '#ff00ff' },
    \ { 'color': 202, 'name': 'OrangeRed1', 'hex': '#ff5f00' },
    \ { 'color': 203, 'name': 'IndianRed1', 'hex': '#ff5f5f' },
    \ { 'color': 204, 'name': 'IndianRed1', 'hex': '#ff5f87' },
    \ { 'color': 205, 'name': 'HotPink', 'hex': '#ff5faf' },
    \ { 'color': 206, 'name': 'HotPink', 'hex': '#ff5fd7' },
    \ { 'color': 207, 'name': 'MediumOrchid1', 'hex': '#ff5fff' },
    \ { 'color': 208, 'name': 'DarkOrange', 'hex': '#ff8700' },
    \ { 'color': 209, 'name': 'Salmon1', 'hex': '#ff875f' },
    \ { 'color': 210, 'name': 'LightCoral', 'hex': '#ff8787' },
    \ { 'color': 211, 'name': 'PaleVioletRed1', 'hex': '#ff87af' },
    \ { 'color': 212, 'name': 'Orchid2', 'hex': '#ff87d7' },
    \ { 'color': 213, 'name': 'Orchid1', 'hex': '#ff87ff' },
    \ { 'color': 214, 'name': 'Orange1', 'hex': '#ffaf00' },
    \ { 'color': 215, 'name': 'SandyBrown', 'hex': '#ffaf5f' },
    \ { 'color': 216, 'name': 'LightSalmon1', 'hex': '#ffaf87' },
    \ { 'color': 217, 'name': 'LightPink1', 'hex': '#ffafaf' },
    \ { 'color': 218, 'name': 'Pink1', 'hex': '#ffafd7' },
    \ { 'color': 219, 'name': 'Plum1', 'hex': '#ffafff' },
    \ { 'color': 220, 'name': 'Gold1', 'hex': '#ffd700' },
    \ { 'color': 221, 'name': 'LightGoldenrod2', 'hex': '#ffd75f' },
    \ { 'color': 222, 'name': 'LightGoldenrod2', 'hex': '#ffd787' },
    \ { 'color': 223, 'name': 'NavajoWhite1', 'hex': '#ffd7af' },
    \ { 'color': 224, 'name': 'MistyRose1', 'hex': '#ffd7d7' },
    \ { 'color': 225, 'name': 'Thistle1', 'hex': '#ffd7ff' },
    \ { 'color': 226, 'name': 'Yellow1', 'hex': '#ffff00' },
    \ { 'color': 227, 'name': 'LightGoldenrod1', 'hex': '#ffff5f' },
    \ { 'color': 228, 'name': 'Khaki1', 'hex': '#ffff87' },
    \ { 'color': 229, 'name': 'Wheat1', 'hex': '#ffffaf' },
    \ { 'color': 230, 'name': 'Cornsilk1', 'hex': '#ffffd7' },
    \ { 'color': 231, 'name': 'Grey100', 'hex': '#ffffff' },
    \ { 'color': 232, 'name': 'Grey3', 'hex': '#080808' },
    \ { 'color': 233, 'name': 'Grey7', 'hex': '#121212' },
    \ { 'color': 234, 'name': 'Grey11', 'hex': '#1c1c1c' },
    \ { 'color': 235, 'name': 'Grey15', 'hex': '#262626' },
    \ { 'color': 236, 'name': 'Grey19', 'hex': '#303030' },
    \ { 'color': 237, 'name': 'Grey23', 'hex': '#3a3a3a' },
    \ { 'color': 238, 'name': 'Grey27', 'hex': '#444444' },
    \ { 'color': 239, 'name': 'Grey30', 'hex': '#4e4e4e' },
    \ { 'color': 240, 'name': 'Grey35', 'hex': '#585858' },
    \ { 'color': 241, 'name': 'Grey39', 'hex': '#626262' },
    \ { 'color': 242, 'name': 'Grey42', 'hex': '#6c6c6c' },
    \ { 'color': 243, 'name': 'Grey46', 'hex': '#767676' },
    \ { 'color': 244, 'name': 'Grey50', 'hex': '#808080' },
    \ { 'color': 245, 'name': 'Grey54', 'hex': '#8a8a8a' },
    \ { 'color': 246, 'name': 'Grey58', 'hex': '#949494' },
    \ { 'color': 247, 'name': 'Grey62', 'hex': '#9e9e9e' },
    \ { 'color': 248, 'name': 'Grey66', 'hex': '#a8a8a8' },
    \ { 'color': 249, 'name': 'Grey70', 'hex': '#b2b2b2' },
    \ { 'color': 250, 'name': 'Grey74', 'hex': '#bcbcbc' },
    \ { 'color': 251, 'name': 'Grey78', 'hex': '#c6c6c6' },
    \ { 'color': 252, 'name': 'Grey82', 'hex': '#d0d0d0' },
    \ { 'color': 253, 'name': 'Grey85', 'hex': '#dadada' },
    \ { 'color': 254, 'name': 'Grey89', 'hex': '#e4e4e4' },
    \ { 'color': 255, 'name': 'Grey93', 'hex': '#eeeeee' },
    \ ]


#----------------------------------------------------------------------
# initialize
#----------------------------------------------------------------------
var _palette: list<list<number>>
var cnames = {}

for color in color_definition
	final cc: number = str2nr(strpart(color.hex, 1), 16)
	final r: number = and(cc / 0x10000, 0xff)
	final g: number = and(cc / 0x100, 0xff)
	final b: number = and(cc, 0xff)
	final p: list<number> = [r, g, b]
	_palette += [p]
	cnames[tolower(color.name)] = color.color
endfor

final palette: list<list<number>> = deepcopy(_palette)
var _diff_lookup: list<number> = repeat([0], 512 * 3)

for i in range(256)
	final k: number = i * i
	final dr: number = k * 30 * 30
	final dg: number = k * 59 * 59
	final db: number = k * 11 * 11
	_diff_lookup[ 256 + i] = dr
	_diff_lookup[ 256 - i] = dr
	_diff_lookup[ 768 + i] = dg
	_diff_lookup[ 768 - i] = dg
	_diff_lookup[1280 + i] = db
	_diff_lookup[1280 - i] = db
endfor

final diff_lookup: list<number> = deepcopy(_diff_lookup)


#----------------------------------------------------------------------
# bestfit color
#----------------------------------------------------------------------
export def BestfitColor(r: number, g: number, b: number, limit: number = 256): number
	final R: number = (r < 256) ? r : 255
	final G: number = (g < 256) ? g : 255
	final B: number = (b < 256) ? b : 255
	final LIMIT: number = (limit < 256) ? limit : 256
	final lookup: list<number> = diff_lookup
	var lowest = 0x7fffffff
	var bestfit = 0
	var index = 0
	while index < LIMIT
		final rgb: list<number> = palette[index]
		var diff = lookup[768 + rgb[1] - G]
		if diff < lowest
			diff += lookup[256 + rgb[0] - R]
			if diff < lowest
				diff += lookup[1280 + rgb[2] - B]
				if diff < lowest
					lowest = diff
					bestfit = index
				endif
				if diff <= 0
					break
				endif
			endif
		endif
		index += 1
	endwhile
	return bestfit
enddef


#----------------------------------------------------------------------
# for 8 colors
#----------------------------------------------------------------------
export def Bestfit8(r: number, g: number, b: number): number
	return BestfitColor(r, g, b, 8)
enddef


#----------------------------------------------------------------------
# for 16 colors
#----------------------------------------------------------------------
export def Bestfit16(r: number, g: number, b: number): number
	return BestfitColor(r, g, b, 16)
enddef

#----------------------------------------------------------------------
# for 256 colors
#----------------------------------------------------------------------
export def Bestfit256(r: number, g: number, b: number): number
	return BestfitColor(r, g, b, 256)
enddef


#----------------------------------------------------------------------
# for 256 colors
#----------------------------------------------------------------------
var matched = {}

export def Match(r: number, g: number, b: number, num: number = -1): number
	final rr = (r < 256) ? r : 255
	final gg = (g < 256) ? g : 255
	final bb = (b < 256) ? b : 255
	final key: number = (rr * 4096 / 4) + (gg * 64 / 4) + (bb / 4)
	if !has_key(matched, key)
		var N: number = 256
		if num >= 0
			N = num
		else
			if exists('g:quickui#palette#number')
				N = g:quickui#palette#number
			endif
		endif
		final cc: number = BestfitColor(rr, gg, bb, N)
		matched[key] = cc
	endif
	return matched[key]
enddef


#----------------------------------------------------------------------
# convert #112233 to [0x11, 0x22, 0x33]
#----------------------------------------------------------------------
export def Hex2RGB(hex: string): list<number>
	var head: string = strpart(hex, 0, 1)
	var r: number = 0
	var g: number = 0
	var b: number = 0
	if head == '#'
		final c: number = str2nr(strpart(hex, 1), 16)
		r = and(c / 0x10000, 0xff)
		g = and(c / 0x100, 0xff)
		b = and(c, 0xff)
	elseif head == '('
		head = strpart(hex, 1, len(hex) - 2)
		final part: list<string> = split(head, ',')
		r = str2nr(part[0])
		g = str2nr(part[1])
		b = str2nr(part[2])
	endif
	return [r, g, b]
enddef


#----------------------------------------------------------------------
# hex to palette index
#----------------------------------------------------------------------
export def Hex2Index(hex: string, num: number = -1): number
	final cc: list<number> = Hex2RGB(hex)
	return Match(cc[0], cc[1], cc[2], num)
enddef


#----------------------------------------------------------------------
# search name
#----------------------------------------------------------------------
export def Name2Index(name: string, default: number = 0): number
	final head = strpart(name, 0, 1)
	if head == '#' || head == '('
		return Hex2Index(name)
	else
		final nm = tolower(name)
		if exists('v:colornames')
			if has_key(v:colornames, nm)
				final hex = v:colornames[nm]
				return Hex2Index(hex)
			endif
		endif
		return get(cnames, tolower(name), default)
	endif
enddef


#----------------------------------------------------------------------
# benchmark 
#----------------------------------------------------------------------
export def Timing(): string
	var ts = reltime()
	for i in range(256)
		Match(i, i, i)
	endfor
	var tt = reltime(ts)
	return reltimestr(tt)
enddef



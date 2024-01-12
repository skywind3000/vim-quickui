"======================================================================
"
" palette.vim - 
"
" Created by skywind on 2021/12/23
" Last Modified: 2022/09/25 01:31
"
"======================================================================

" vim: set ts=4 sw=4 tw=78 noet :


"----------------------------------------------------------------------
" terminal palette of 256 colors
"----------------------------------------------------------------------
let g:quickui#palette#colors = [
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


"----------------------------------------------------------------------
" color index to RGB
"----------------------------------------------------------------------
let g:quickui#palette#rgb = []
let g:quickui#palette#name = {}
let g:quickui#palette#number = get(g:, 'quickui_color_num', 256)

let s:palette = []
let s:matched = {}
let s:names = {}
let s:diff_lookup = repeat([0], 512 * 3)

for color in g:quickui#palette#colors
	let cc = str2nr(strpart(color.hex, 1), 16)
	let r = and(cc / 0x10000, 0xff)
	let g = and(cc / 0x100, 0xff)
	let b = and(cc, 0xff)
	let g:quickui#palette#rgb += [[r, g, b]]
	let s:palette += [[r, g, b]]
	let g:quickui#palette#name[tolower(color.name)] = color.color
	let s:names[tolower(color.name)] = color.color
endfor


"----------------------------------------------------------------------
" bestfit color
"----------------------------------------------------------------------
function! s:bestfit_color(r, g, b, limit)
	if s:diff_lookup[0] == 0
		for i in range(256)
			let k = i * i
			let dr = k * 30 * 30
			let dg = k * 59 * 59
			let db = k * 11 * 11
			let s:diff_lookup[ 256 + i] = dr
			let s:diff_lookup[ 256 - i] = dr
			let s:diff_lookup[ 768 + i] = dg
			let s:diff_lookup[ 768 - i] = dg
			let s:diff_lookup[1280 + i] = db
			let s:diff_lookup[1280 - i] = db
		endfor
		let s:diff_lookup[0] = 1
	endif
	let r = (a:r < 256)? (a:r) : 255
	let g = (a:g < 256)? (a:g) : 255
	let b = (a:b < 256)? (a:b) : 255
	let lowest = 0x7fffffff
	let bestfit = 0
	let index = 0
	let limit = (a:limit < 256)? (a:limit) : 256
	let palette = s:palette
	let lookup = s:diff_lookup
	while index < limit
		let rgb = palette[index]
		let diff = lookup[ 768 + rgb[1] - g]
		if diff < lowest
			let diff += lookup[ 256 + rgb[0] - r]
			if diff < lowest
				let diff += lookup[1280 + rgb[2] - b]
				if diff < lowest
					let lowest = diff
					let bestfit = index
				endif
				if diff <= 0
					break
				endif
			endif
		endif
		let index += 1
	endwhile
	return bestfit
endfunc


"----------------------------------------------------------------------
" find match in 8 colors
"----------------------------------------------------------------------
function! quickui#palette#bestfit8(r, g, b)
	return s:bestfit_color(a:r, a:g, a:b, 8)
endfunc


"----------------------------------------------------------------------
" find match in 8 colors
"----------------------------------------------------------------------
function! quickui#palette#bestfit16(r, g, b)
	return s:bestfit_color(a:r, a:g, a:b, 16)
endfunc


"----------------------------------------------------------------------
" find match in 8 colors
"----------------------------------------------------------------------
function! quickui#palette#bestfit256(r, g, b)
	return s:bestfit_color(a:r, a:g, a:b, 256)
endfunc


"----------------------------------------------------------------------
" consider config
"----------------------------------------------------------------------
function! quickui#palette#bestfit(r, g, b)
	return s:bestfit_color(a:r, a:g, a:b, g:quickui#palette#number)
endfunc


"----------------------------------------------------------------------
" matched
"----------------------------------------------------------------------
function! quickui#palette#match(r, g, b)
	let r = (a:r < 256)? (a:r) : 255
	let g = (a:g < 256)? (a:g) : 255
	let b = (a:b < 256)? (a:b) : 255
	let key = (r * 4096 / 4) + (g * 64 / 4) + (b / 4)
	if !has_key(s:matched, key)
		let n = g:quickui#palette#number
		let s:matched[key] = s:bestfit_color(a:r, a:g, a:b, n)
	endif
	return s:matched[key]
endfunc


"----------------------------------------------------------------------
" convert #112233 to [0x11, 0x22, 0x33]
"----------------------------------------------------------------------
function! quickui#palette#hex2rgb(hex)
	let [r, g, b] = [0, 0, 0]
	let head = strpart(a:hex, 0, 1)
	if head == '#'
		let cc = str2nr(strpart(a:hex, 1), 16)
		let r = and(cc / 0x10000, 0xff)
		let g = and(cc / 0x100, 0xff)
		let b = and(cc, 0xff)
	elseif head == '('
		let head = strpart(a:hex, 1, len(a:hex) - 2)
		let part = split(head, ',')
		let r = str2nr(part[0])
		let g = str2nr(part[1])
		let b = str2nr(part[2])
	endif
	return [r, g, b]
endfunc


"----------------------------------------------------------------------
" hex to palette index
"----------------------------------------------------------------------
function! quickui#palette#hex2index(hex)
	let [r, g, b] = quickui#palette#hex2rgb(a:hex)
	return quickui#palette#match(r, g, b)
endfunc


"----------------------------------------------------------------------
" search name
"----------------------------------------------------------------------
function! quickui#palette#name2index(name, ...)
	let head = strpart(a:name, 0, 1)
	if head == '#' || head == '('
		return quickui#palette#hex2index(a:name)
	else
		let default = (a:0 < 1)? 0 : (a:1)
		let name = tolower(a:name)
		if exists('v:colornames')
			if has_key(v:colornames, name)
				let hex = v:colornames[name]
				return quickui#palette#hex2index(hex)
			endif
		endif
		return get(s:names, tolower(a:name), default)
	endif
endfunc


"----------------------------------------------------------------------
" alpha blend
"----------------------------------------------------------------------
function! quickui#palette#blend(c1, c2, alpha)
	let c1 = a:c1
	let c2 = a:c2
	let alpha = a:alpha
	if type(c1) == 0 && type(c2) == 0
		return (c1 * (255 - alpha) + c2 * alpha) / 255
	endif
	let dst = quickui#palette#hex2rgb(c1)
	let src = quickui#palette#hex2rgb(c2)
	let r = (dst[0] * (255 - alpha) + src[0] * alpha) / 255
	let g = (dst[1] * (255 - alpha) + src[1] * alpha) / 255
	let b = (dst[2] * (255 - alpha) + src[2] * alpha) / 255
	return printf('#%02x%02x%02x', r, g, b)
endfunc


"----------------------------------------------------------------------
" palette search in desert256
"----------------------------------------------------------------------

" returns an approximate grey index for the given grey level
function! s:grey_number(x)
	if &t_Co == 88
		if a:x < 23
			return 0
		elseif a:x < 69
			return 1
		elseif a:x < 103
			return 2
		elseif a:x < 127
			return 3
		elseif a:x < 150
			return 4
		elseif a:x < 173
			return 5
		elseif a:x < 196
			return 6
		elseif a:x < 219
			return 7
		elseif a:x < 243
			return 8
		else
			return 9
		endif
	else
		if a:x < 14
			return 0
		else
			let l:n = (a:x - 8) / 10
			let l:m = (a:x - 8) % 10
			if l:m < 5
				return l:n
			else
				return l:n + 1
			endif
		endif
	endif
endfunc

" returns the actual grey level represented by the grey index
function! s:grey_level(n)
	if &t_Co == 88
		if a:n == 0
			return 0
		elseif a:n == 1
			return 46
		elseif a:n == 2
			return 92
		elseif a:n == 3
			return 115
		elseif a:n == 4
			return 139
		elseif a:n == 5
			return 162
		elseif a:n == 6
			return 185
		elseif a:n == 7
			return 208
		elseif a:n == 8
			return 231
		else
			return 255
		endif
	else
		if a:n == 0
			return 0
		else
			return 8 + (a:n * 10)
		endif
	endif
endfunc

" returns the palette index for the given grey index
function! s:grey_color(n)
	if &t_Co == 88
		if a:n == 0
			return 16
		elseif a:n == 9
			return 79
		else
			return 79 + a:n
		endif
	else
		if a:n == 0
			return 16
		elseif a:n == 25
			return 231
		else
			return 231 + a:n
		endif
	endif
endfunc

" returns an approximate color index for the given color level
function! s:rgb_number(x)
	if &t_Co == 88
		if a:x < 69
			return 0
		elseif a:x < 172
			return 1
		elseif a:x < 230
			return 2
		else
			return 3
		endif
	else
		if a:x < 75
			return 0
		else
			let l:n = (a:x - 55) / 40
			let l:m = (a:x - 55) % 40
			if l:m < 20
				return l:n
			else
				return l:n + 1
			endif
		endif
	endif
endfunc

" returns the actual color level for the given color index
function! s:rgb_level(n)
	if &t_Co == 88
		if a:n == 0
			return 0
		elseif a:n == 1
			return 139
		elseif a:n == 2
			return 205
		else
			return 255
		endif
	else
		if a:n == 0
			return 0
		else
			return 55 + (a:n * 40)
		endif
	endif
endfunc

" returns the palette index for the given R/G/B color indices
function! s:rgb_color(x, y, z)
	if &t_Co == 88
		return 16 + (a:x * 16) + (a:y * 4) + a:z
	else
		return 16 + (a:x * 36) + (a:y * 6) + a:z
	endif
endfunc

" returns the palette index to approximate the given R/G/B color levels
function! quickui#palette#color_match(r, g, b)
	" get the closest grey
	let l:gx = s:grey_number(a:r)
	let l:gy = s:grey_number(a:g)
	let l:gz = s:grey_number(a:b)

	" get the closest color
	let l:x = s:rgb_number(a:r)
	let l:y = s:rgb_number(a:g)
	let l:z = s:rgb_number(a:b)

	if l:gx == l:gy && l:gy == l:gz
		" there are two possibilities
		let l:dgr = s:grey_level(l:gx) - a:r
		let l:dgg = s:grey_level(l:gy) - a:g
		let l:dgb = s:grey_level(l:gz) - a:b
		let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
		let l:dr = s:rgb_level(l:gx) - a:r
		let l:dg = s:rgb_level(l:gy) - a:g
		let l:db = s:rgb_level(l:gz) - a:b
		let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
		if l:dgrey < l:drgb
			" use the grey
			return s:grey_color(l:gx)
		else
			" use the color
			return s:rgb_color(l:x, l:y, l:z)
		endif
	else
		" only one possibility
		return s:rgb_color(l:x, l:y, l:z)
	endif
endfun

function! quickui#palette#rgb_match(rgb) abort
	if a:rgb =~ '^#'
		let r = ("0x" . strpart(a:rgb, 1, 2)) + 0
		let g = ("0x" . strpart(a:rgb, 3, 2)) + 0
		let b = ("0x" . strpart(a:rgb, 5, 2)) + 0
	else
		let r = ("0x" . strpart(a:rgb, 0, 2)) + 0
		let g = ("0x" . strpart(a:rgb, 2, 2)) + 0
		let b = ("0x" . strpart(a:rgb, 4, 2)) + 0
	endif
	return quickui#palette#color_match(r, g, b)
endfunc


"----------------------------------------------------------------------
" benchmark
"----------------------------------------------------------------------
function! quickui#palette#timing()
	let ts = reltime()
	for i in range(256)
		call quickui#palette#match(i, i, i)
	endfor
	let tt = reltime(ts)
	return reltimestr(tt)
endfunc


"----------------------------------------------------------------------
" optimize if possible: achieve 40x times faster
"----------------------------------------------------------------------
if has('vim9script')
	import './palette9.vim'
	function! s:bestfit_color(r, g, b, limit)
		return s:palette9.BestfitColor(a:r, a:g, a:b, a:limit)
	endfunc
	function! quickui#palette#bestfit8(r, g, b)
		return s:palette9.Bestfit8(a:r, a:g, a:b)
	endfunc
	function! quickui#palette#bestfit16(r, g, b)
		return s:palette9.Bestfit16(a:r, a:g, a:b)
	endfunc
	function! quickui#palette#bestfit256(r, g, b)
		return s:palette9.Bestfit256(a:r, a:g, a:b)
	endfunc
	function! quickui#palette#match(r, g, b)
		return s:palette9.Match(a:r, a:g, a:b, g:quickui#palette#number)
	endfunc
	function! quickui#palette#hex2rgb(hex)
		return s:palette9.Hex2RGB(a:hex)
	endfunc
	function! quickui#palette#hex2index(hex)
		return s:palette9.Hex2Index(a:hex)
	endfunc
	function! quickui#palette#name2index(name, ...)
		let default = (a:0 == 0)? 0 : (a:1)
		return s:palette9.Name2Index(a:name, default)
	endfunc
endif





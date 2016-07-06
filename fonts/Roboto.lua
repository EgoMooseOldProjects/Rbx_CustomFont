--[[
	@Font Roboto
	@Sizes {96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8}
	@Author Christian Robertson
	@Link https://www.fontsquirrel.com/fonts/list/foundry/christian-robertson
--]]

local module = {};

module.atlases = {
    [1]  = "rbxassetid://392953276";
    [2]  = "rbxassetid://392953280";
    [3]  = "rbxassetid://392953283";
    [4]  = "rbxassetid://392953290";
    [5]  = "rbxassetid://392953287";
    [6]  = "rbxassetid://392953282";
    [7]  = "rbxassetid://392953288";
    [8]  = "rbxassetid://392953301";
    [9]  = "rbxassetid://392953307";
    [10] = "rbxassetid://392953298";
    [11] = "rbxassetid://392953303";
    [12] = "rbxassetid://392953305";
    [13] = "rbxassetid://392953309";
    [14] = "rbxassetid://392953313";
    [15] = "rbxassetid://392953315";
    [16] = "rbxassetid://392953317";
    [17] = "rbxassetid://393140459";
    [18] = "rbxassetid://393140480";
    [19] = "rbxassetid://393140472";
    [20] = "rbxassetid://393140476";
    [21] = "rbxassetid://393140483";
    [22] = "rbxassetid://393140490";
    [23] = "rbxassetid://393140486";
    [24] = "rbxassetid://393140499";
    [25] = "rbxassetid://393140510";
    [26] = "rbxassetid://392953353";
    [27] = "rbxassetid://393140503";
    [28] = "rbxassetid://392953351";
    [29] = "rbxassetid://392953357";
    [30] = "rbxassetid://392953363";
    [31] = "rbxassetid://392953360";
    [32] = "rbxassetid://392953362";
    [33] = "rbxassetid://393055828";
    [34] = "rbxassetid://392953667";
    [35] = "rbxassetid://393055824";
    [36] = "rbxassetid://392953669";
    [36] = "rbxassetid://393055840";
    [37] = "rbxassetid://392953672";
    [37] = "rbxassetid://393055843";
    [38] = "rbxassetid://393055845";
    [39] = "rbxassetid://393055854";
    [40] = "rbxassetid://393055846";
    [41] = "rbxassetid://393055853";
    [42] = "rbxassetid://393055869";
    [43] = "rbxassetid://393055875";
    [44] = "rbxassetid://393055866";
    [45] = "rbxassetid://393055873";
    [46] = "rbxassetid://393055880";
    [47] = "rbxassetid://393055878";
    [48] = "rbxassetid://393140507";
    [49] = "rbxassetid://393140512";
    [50] = "rbxassetid://393140514";
    [51] = "rbxassetid://393055887";
};

module.font = {
	information = {
		family = "Roboto";
		styles = {"Black", "Black Italic", "Bold", "Bold Italic", "Italic", "Light", "Light Italic", "Medium", "Medium Italic", "Regular", "Thin", "Thin Italic"};
		sizes = {96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8};
		useEnums = true;
	};
	styles = {
            Black = require(script.Black);
            ["Black Italic"] = require(script.BlackItalic);
            Bold = require(script.Bold);
            ["Bold Italic"] = require(script.BoldItalic);
            Italic = require(script.Italic);
            Light = require(script.Light);
            ["Light Italic"] = require(script.LightItalic);
            Medium = require(script.Medium);
            ["Medium Italic"] = require(script.MediumItalic);
            Regular = require(script.Regular);
            Thin = require(script.Thin);
            ["Thin Italic"] = require(script.ThinItalic);
	};
};



return module;

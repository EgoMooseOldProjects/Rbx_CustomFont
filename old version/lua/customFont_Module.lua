--[[
	Rbx_CustomFont
	Sprite creation module for custom text fonts.
	@author EgoMoose
	@link http://www.roblox.com/Rbx-CustomFont-item?id=230767320
	@date 12/12/2015
--]]

-- Github	: https://github.com/EgoMoose/Rbx_CustomFont
-- API		: https://github.com/EgoMoose/Rbx_CustomFont/wiki/API
-- Fonts	: https://github.com/EgoMoose/Rbx_CustomFont/wiki/Making-your-own-font

------------------------------------------------------------------------------------------------------------------------------
--// Setup

local fonts = script; -- Feel free to change this
local http = game:GetService("HttpService"); -- Used for JSON decoding
local content = game:GetService("ContentProvider"); -- Used to preload font atlases

local imgFrame = Instance.new("ImageLabel");
imgFrame.Size = UDim2.new();
imgFrame.BackgroundTransparency = 1;
imgFrame.ScaleType = Enum.ScaleType.Stretch;

------------------------------------------------------------------------------------------------------------------------------
--// Functions

function serializeFrame(class)
	local frame = Instance.new(class);
	frame.Name = "Sprite"..string.sub(class, 5);
	frame.Size = UDim2.new();
	frame.TextTransparency = 2;
	frame.TextStrokeTransparency = 2;
	frame.BackgroundTransparency = 2;
	return frame;
end;

function contains(tab, element, keys)
	local focus = keys or tab;
	for key, val in pairs(focus) do
		local index = keys and val or key;
		if tab[index] == element then
			return true;
		end;
	end;
end;

function find_closest(tab, num)
	table.sort(tab);
	local closest, diff;
	for _, onum in pairs(tab) do
		local new_diff = (num - onum) >= 0 and (num - onum) or -(num - onum);
		if not diff or new_diff <= diff then
			diff = new_diff;
			closest = onum;
		end;
	end;
	return closest;
end;

function multiplyUDim(ud, m)
	return UDim2.new(ud.X.Scale * m, ud.X.Offset * m, ud.Y.Scale * m, ud.Y.Offset * m);
end;

function posFrom(frame, pos, x, y)
	frame.Position = UDim2.new(
		pos.X.Scale - frame.Size.X.Scale * x,
		pos.X.Offset - frame.Size.X.Offset * x,
		pos.Y.Scale - frame.Size.Y.Scale * y,
		pos.Y.Offset - frame.Size.Y.Offset * y
	);
end;

function null(item)
	item = nil;
end;

-- Text specific

function getAlignMultiplier(enum)
	return contains({"Right", "Bottom"}, enum.Name) and 1 or (contains({"Left", "Top"}, enum.Name) and 0 or 0.5);
end;

function split(text, pattern)
	local tab, linepos = {}, 0;
	while true do
		local pos = string.find(text, pattern, linepos, true);
		if pos then
			table.insert(tab, string.sub(text, linepos, pos-1));
			linepos = pos + 1;
		else
			table.insert(tab, string.sub(text, linepos));
			break;
		end;
	end;
	return tab;
end;

function getWords(text, newlines)
	local text = string.gsub(text, "\t", string.rep(" ", 4));
	local lines, words = split(text, "\n"), {};
	for i, line in ipairs(lines) do
		for word in string.gmatch(line, "[^%s]+ *") do
			table.insert(words, word);
		end;
		if newlines and i < #lines then table.insert(words, "\n"); end;
	end;
	return words;
end;

function getLines(text)
	local text = string.gsub(text, "\t", string.rep(" ", 4));
	local lines, nlines = split(text, "\n"), {};
	for i, line in ipairs(lines) do
		table.insert(nlines, line);
		--if i < #lines then table.insert(nlines, ""); end;
	end;
	return nlines;
end;

------------------------------------------------------------------------------------------------------------------------------
--// Classes

function class_signal()
	-- Thanks to Merely for this!
	local this = {};
	local event, params = Instance.new("BindableEvent") , {};

	function this:connect(func)
		return event.Event:connect(function() func(unpack(params)) end);
	end;

	function this:fire(...)
		params = {...};
		event:Fire();
	end;

	function this:Destroy()
		event:Destroy();
	end;
	
	return this;
end;


function class_events(tab)
	local this, events = setmetatable({}, {}), {};
	
	local function init()
		for key, _ in pairs(tab) do events[key] = class_signal(); end;
		local mt = getmetatable(this);
		mt.__index = tab;
		mt.__newindex = function(t, k, v)
			if not tab[k] then events[k] = class_signal(); end;
			if tab[k] ~= v then
				tab[k] = v;
				events[k]:fire(v);
			end;
		end;
		mt.__metatable = "The metatable is locked.";
	end;

	function this:connect(key, func)
		return events[key]:connect(func);
	end;

	function this:clearEvents()
		for _, evnt in pairs(events) do evnt:Destroy(); end;
	end;

	init();
	return this;
end;

function class_wrap(object, addition)
	local this = newproxy(true);
	
	local function init()
		local mt = getmetatable(this);
		mt.__index = function(t, k) return addition[k] or object[k]; end;
		mt.__newindex = function(t, k, v) if addition[k] then addition[k] = v; else object[k] = v; end; end;
		mt.__call = function() return object; end;
		mt.__tostring = function(t) return tostring(object); end;
		mt.__metatable = "The metatable is locked.";
	end;
	
	init();
	return this;
end;

-- Settings class

function class_settings(module, object)
	local this = class_events {};
	this.data = http:JSONDecode(module.json);
	this.atlases = module.atlases;
	this.size = math.min(unpack(this.data.info.sizes));
	this.use_enums = true;

	local function preload()
		for _, asset in pairs(this.atlases) do
			content:Preload(asset);
		end;
	end;

	local function useenums()
		local default_sizes = {96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8}
		for _, size in pairs(this.data.info.sizes) do
			if not contains(default_sizes, size) then
				this.use_enums = false;
			end;
		end;
	end;

	local function failsafes()
		-- If a character isn't found replaces with "?"
		local replace = "?";
		for key, char_set in pairs(this.data.sizes) do
			setmetatable(char_set.characters, {
				__index = function(t, k)
					local k = tostring(k); -- implicitly convert to string for ease later on
					if not rawget(t, k) then
						warn(string.char(k), "is not a valid character. Replaced with, \"".. replace.. "\"");
					end;
					return rawget(t, k) or rawget(t, tostring(string.byte(replace)));
				end;
			});			
		end;
		-- If a size isn't found picks next closest
		setmetatable(this.data.sizes, {
			__index = function(t, k)
				local k = tostring(k); -- implicitly convert to string for ease later on
				if rawget(t, k) then return rawget(t, k); end;
				local c = find_closest(this.data.info.sizes, tonumber(k) or 0);
				warn(k, "is not a valid size. Using closest size,", c);
				this.size = c;
				object.FontPx.Value = c;
				pcall(function() object.FontSize = this.use_enums and "Size"..c or object.FontSize; end);
				return t[c];
			end;
		});
	end;

	local function init()
		preload();
		useenums();
		failsafes();
	end;

	init();
	return this;
end;

-- Sprite text object class

function class_spritetext(font, class)
	local this = class_events {};
	local exists = not (type(class) == "string");
	
	local overide_props = {
		TextTransparency = exists and class.TextTransparency or 0;
		BackgroundTransparency = exists and class.BackgroundTransparency or 0;
		TextFits = false;
	};
	
	local object = not exists and serializeFrame(class) or class;
	local font_mod, settings = fonts:FindFirstChild(font);
	if font_mod then settings = class_settings(require(font_mod), object); else error(font.." could not be found in the font directory."); end;
	local chars, ignore, props, events, background = {}, {}, {}, {};

	this.FullText = object.Text;
	this.FontName = font;
	this.FontPx = settings.size;
	this.Scale = 1;

	local function background()
		background = Instance.new("Frame", object);
		if object:IsA("TextButton") then
			background.MouseEnter:connect(function()
				if object.AutoButtonColor then 
					local origin = object.BackgroundColor3;
					background.BackgroundColor3 = Color3.new(origin.r - 75/255, origin.g - 75/255, origin.b - 75/255); 
				end;
			end);
			background.MouseLeave:connect(function() if object.AutoButtonColor then background.BackgroundColor3 = object.BackgroundColor3; end; end);
		end;
		background.Name = "_background";
		background.Size = UDim2.new(1, 0, 1, 0);
		background.BackgroundTransparency = type(class) == "string" and 0 or class.BackgroundTransparency;
		background.BackgroundColor3 = object.BackgroundColor3;
		background.BorderColor3 = object.BorderColor3;
		background.BorderSizePixel = object.BorderSizePixel;
		table.insert(ignore, background);
	end;

	local function hideReal()
		object.TextTransparency = 2;
		object.BackgroundTransparency = 2;
		object.TextStrokeTransparency = 2;
	end;

	local function getPixelLength(text, fs)
		local len = 0;
		for i = 1, #text do
			local char = string.byte(string.sub(text, i, i));
			len = len + settings.data.sizes[fs].characters[char].xadvance;
		end;
		return len;
	end;

	local function wrapText(text, fs)
		local mwidth, fwidth, index, lines = math.abs(object.AbsoluteSize.x), 0, 1, {};
		for _, word in pairs(getWords(text, true)) do
			if word ~= "\n" then
				-- Allows us to get the wrapping of the current size or one in the settings (for auto-sizing)
				local width = getPixelLength(word, fs or settings.size);
				lines[index] = fwidth < 1 and word or width + fwidth <= mwidth and lines[index]..word or string.gsub(lines[index], " +$", "");
				if not (fwidth < 1 or width + fwidth <= mwidth) then
					index = index + 1;
					fwidth = 0;
					lines[index] = word;
				end;
				fwidth = fwidth + width;
			else
				lines[index] = string.gsub(lines[index], " +$", "");
				index = index + 1;
				fwidth = 0;
				lines[index] = "";
			end;
		end;
		return lines;
	end;

	local function bestSize(text)
		settings.size = settings.data.info.sizes[#settings.data.info.sizes];
		for _, size in ipairs(settings.data.info.sizes) do
			-- Collect data
			local lines = object.TextWrapped and wrapText(text, size) or getLines(text);
			local y, x = settings.data.sizes[size].info.lineHeight * this.Scale * #lines, {0};
			for _, line in pairs(lines) do table.insert(x, getPixelLength(line, size)); end
			x = math.max(unpack(x));
			-- Calculate
			if y <= math.abs(object.AbsoluteSize.y) and x <= math.abs(object.AbsoluteSize.x) then
				settings.size = size;
				break;
			end;
		end;
	end;

	local function drawChar(byte, parent, pbyte)
		local sprite = imgFrame:Clone();
		sprite.Name = byte;
		sprite.Parent = parent;
		-- Carry over properties
		sprite.ImageColor3 = object.TextColor3;
		sprite.ImageTransparency = overide_props.TextTransparency;
		sprite.ZIndex = object.ZIndex;
		-- Image setup/placement
		sprite.Image = settings.atlases[settings.data.sizes[settings.size].info.atlas];
		sprite.ImageRectSize = Vector2.new(settings.data.sizes[settings.size].characters[byte].width, settings.data.sizes[settings.size].characters[byte].height);
		sprite.ImageRectOffset = Vector2.new(settings.data.sizes[settings.size].characters[byte].x, settings.data.sizes[settings.size].characters[byte].y);
		-- kerning data
		local kern = 0;
		if pbyte and settings.data.sizes[settings.size].kerning then
			local first = settings.data.sizes[settings.size].kerning[tostring(pbyte)];
			kern = (first and first[tostring(byte)]) or 0;
			--if kern ~= 0 then print(kern); end;
		end;
		-- Frame positioning and sizeing
		sprite.Position = UDim2.new(0, settings.data.sizes[settings.size].characters[byte].xoffset + kern, 0, 0);
		sprite.Size = multiplyUDim(UDim2.new(0, settings.data.sizes[settings.size].characters[byte].width, 0, settings.data.sizes[settings.size].characters[byte].height), this.Scale);
		table.insert(chars, sprite);
		return sprite, kern;
	end;

	local function drawLine(text, height, tsprites)
		local xalign = getAlignMultiplier(object.TextXAlignment);
		local lheight = settings.data.sizes[settings.size].info.lineHeight * this.Scale;
		local width, sprites, pbyte = 0, {};
		for i = 1, #text do
			local byte = string.byte(string.sub(text, i, i));
			local char, kern = drawChar(byte, background, pbyte);
			char.Position = char.Position + UDim2.new(0, width, 0, height);
			width = width + (settings.data.sizes[settings.size].characters[byte].xadvance + kern) * this.Scale;
			table.insert(sprites, char);
			pbyte = byte;
		end;
		for _, sprite in pairs(sprites) do
			sprite.Position = sprite.Position + UDim2.new(0, (xalign * math.abs(object.AbsoluteSize.x)) - xalign * width, 0, 0);
			table.insert(tsprites, sprite);
		end;
		return width;
	end

	local function drawLines(text)
		-- Pick best size if need to
		if object.TextScaled then bestSize(text); end;
		-- Get needed valued
		local lines = object.TextWrapped and wrapText(text) or getLines(text);
		local yalign, sprites, height, widths = getAlignMultiplier(object.TextYAlignment), {}, 0, {0};
		local lineHeight = settings.data.sizes[settings.size].info.lineHeight * this.Scale;
		-- Draw lines
		for _, line in pairs(lines) do
			table.insert(widths, drawLine(line, height, sprites));
			height = height + lineHeight;
		end;
		-- yAlignment
		for _, sprite in pairs(sprites) do
			sprite.Position = sprite.Position + UDim2.new(0, 0, yalign, -height * yalign);
		end;
		-- TextFits
		overide_props.TextFits = object.AbsoluteSize.x > math.max(unpack(widths)) and object.AbsoluteSize.y > height;
	end;

	local function clearAllText()
		for _, item in pairs(chars) do item:Destroy(); end;
		chars = {};
	end;

	local function redraw()
		settings.size = this.FontPx;
		clearAllText();
		drawLines(string.sub(this.FullText, 1, 10^4));
	end;

	local function buildProps()
		for key, prop in pairs({"FontName", "Scale", "FontPx"}) do
			local class = Instance.new(string.upper(string.sub(type(this[prop]), 1, 1))..string.sub(type(this[prop]), 2).."Value", object);
			class.Name = prop;
			class.Value = this[prop];
			props[prop] = class;
			table.insert(events, class.Changed:connect(function(value)
				this[prop] = value;
				if prop == "FontPx" then
					pcall(function() object.FontSize = this.use_enums and "Size"..value or object.FontSize; end);
				end;
				if prop == "FontName" then
					local font_mod = fonts:FindFirstChild(value);
					if font_mod then settings = class_settings(require(font_mod), object); else error(value.." could not be found in the font directory."); end;
				end
				redraw(); 
			end));
			table.insert(ignore, class);
		end;
	end;

	local function setconnections()
		table.insert(events, this:connect("FullText", function(val) redraw(); end));
		for _, prop in pairs({"FontName", "FontPx", "Scale"}) do
			table.insert(events, this:connect(prop, function(num)
				props[prop].Value = num;
			end));
		end;
		table.insert(events, object.Changed:connect(function(prop)
			if contains({"TextTransparency", "BackgroundTransparency", "TextStrokeTransparency"}, prop) then
				if object[prop] ~= 2 then
					if prop == "TextTransparency" then for _, char in pairs(chars) do char["ImageTransparency"] = object[prop]; end; end;
					if prop == "BackgroundTransparency" then background[prop] = object[prop]; end;
					if prop ~= "TextStrokeTransparency" then
						overide_props[prop] = object[prop];	
					end			
				end;
				object[prop] = 2;
				return;
			end;
			if settings.use_enums and prop == "FontSize" then
				this.FontPx = tonumber(string.match(object.FontSize.Name, "%d+$"));
			elseif prop == "TextColor3" then
				for _, char in pairs(chars) do char["ImageColor3"] = object[prop]; end;
			elseif prop == "ZIndex" then
				for _, char in pairs(chars) do char[prop] = object[prop]; end;
				background[prop] = object[prop];
			elseif prop == "Text" then
				this.FullText = object[prop];
			elseif contains({"AbsoluteSize", "TextWrapped", "TextScaled", "TextXAlignment", "TextYAlignment"}, prop) then				
				redraw();
			elseif not contains({"AbsolutePosition", "Position", "Size", "Parent"}, prop) and not string.match(prop, "Text") then			
				pcall(function() background[prop] = object[prop]; end);
			end;
		end));
		if object.ClassName == "TextBox" then
			table.insert(events, object.Focused:connect(function()
				if object.ClearTextOnFocus then
					object.Text = "";
				end;
			end));
		end;
	end;

	local function init()
		this.FontPx = settings.use_enums and tonumber(string.match(object.FontSize.Name, "%d+$")) or this.FontPx;
		background();
		hideReal();
		buildProps();
		setconnections();
		redraw();
	end;
	
	-- public functions
	
	function this:TextFits()
		return overide_props.TextFits;
	end;
	
	function this:Revert()
		for _, event in pairs(events) do event:disconnect(); end;
		for _, prop in pairs(props) do prop:Destroy(); end;
		for _, ign in pairs(ignore) do ign:Destroy(); end;
		object.TextTransparency = overide_props.TextTransparency;
		object.BackgroundTransparency = overide_props.BackgroundTransparency;
		clearAllText();
		this, events, props, ignore = nil, nil, nil, nil;
		return object;
	end;
	
	function this:Destroy()
		this:Revert():Destroy();
	end;
	
	function this:ClearAllChildren()
		for _, child in pairs(object:GetChildren()) do
			if not contains(chars, child) and not contains(props, child) and not contains(ignore, child) then
				child:Destroy();
			end;
		end;
	end;
	
	function this:GetChildren()
		local children = {};
		for _, child in pairs(object:GetChildren()) do
			if not contains(chars, child) and not contains(props, child) and not contains(ignore, child) then
				table.insert(children, child);
			end;
		end;
		return children;
	end;

	init();
	return class_wrap(object, this);
end;

------------------------------------------------------------------------------------------------------------------------------
--// Run

local create = {};
for _, class in pairs({"TextLabel", "TextBox", "TextButton", "TextReplace"}) do
	create[string.sub(class, 5)] = function(font_name, object)
		return class_spritetext(font_name, class == "TextReplace" and object or class);
	end;
end;

return create;
--[[
	Rbx_CustomFont
	Sprite creation module for custom text fonts.
	@author EgoMoose
	@link http://www.roblox.com/Rbx-CustomFont-item?id=230767320
	@date 28/09/2015
--]]

-- Github	: https://github.com/EgoMoose/Rbx_CustomFont
-- API		: https://github.com/EgoMoose/Rbx_CustomFont/wiki/API
-- Fonts	: https://github.com/EgoMoose/Rbx_CustomFont/wiki/Making-your-own-font

------------------------------------------------------------------------------------------------------------------------------
--// Setup

local fonts = script; -- Feel free to change this
local http = game:GetService("HttpService");
local content = game:GetService("ContentProvider");

------------------------------------------------------------------------------------------------------------------------------
--// Serialization

function serializeFrame(class)
	local frame = Instance.new(class);
	frame.Name = "Sprite"..string.sub(class, 5);
	frame.Size = UDim2.new();
	frame.TextTransparency = 2;
	frame.BackgroundTransparency = 2;
	return frame;
end;

local imgFrame = Instance.new("ImageLabel");
imgFrame.Size = UDim2.new();
imgFrame.BackgroundTransparency = 1;
imgFrame.ScaleType = Enum.ScaleType.Stretch;

------------------------------------------------------------------------------------------------------------------------------
--// Functions

function contains(tab, element, keys)
	local focus = keys or tab;
	for key, val in pairs(focus) do
		local index = keys and val or key; -- seems like it's the other way around, but alas, no...
		if tab[index] == element then
			return true;
		end;
	end;
end;

function find_closest(tab, num)
	table.sort(tab)
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

function round(num, idp)
	local mult = 10^(idp or 0);
	return math.floor(num * mult + 0.5) / mult;
end;

-- Old split method would ignore lone new lines. This is a better method, although a little bit more technical.
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

------------------------------------------------------------------------------------------------------------------------------
--// Classes

function new_wrap(object, addition)
	local this = setmetatable({}, {});
	
	--/ Private functions
	
	local function init()
		local mt = getmetatable(this);
		mt.__index = function(t, k) 
			if addition[k] then 
				local success, value = pcall(function() return addition[k].Value; end);
				return success and value or addition[k];
			else
				return object[k];
			end;
		end;
		mt.__newindex = function(t, k, v) if addition[k] then addition[k].Value = v; else object[k] = v; end; end;
		mt.__call = function() return object; end;
		mt.__metatable = "The metatable is locked.";
	end;
	
	--/ Run
	
	init();
	return this;
end;

function new_pseudoEvent(tab, key)
	local this = setmetatable({}, {});
	local sub_this = {};
	
	--/ Properties
	
	sub_this.Value = tab[key];
	sub_this.connected = {};
	
	--/ Tags
	
	local con_index = 0;

	--/ Private functions
	
	local function init()
		local mt = getmetatable(this);
		mt.__index = function(t, k) return sub_this[k]; end;
		mt.__newindex = function(t, k, v)
			local old = sub_this[k]; sub_this[k] = v;
			if k == "Value" and old ~= v then
				for _, func in pairs(sub_this.connected) do if func then func(v); end; end;
			end;
		end;
		mt.__metatable = "The metatable is locked.";
	end;
	
	--/ Public functions
	
	function sub_this:connect(func)
		con_index = con_index + 1;
		local con_this, con_index_l = {}, con_index;
		
		function con_this:disconnect()
			sub_this.connected[con_index_l] = nil;
		end;
		
		sub_this.connected[con_index_l] = func;
		return con_this;
	end;
	
	--/ Run
	
	init();
	return this;
end;

function new_fontSettings(module, real_object)
	local this = {};
	
	--/ Properties
	
	this.data = http:JSONDecode(module.json);
	this.atlases = module.atlases;
	this.size = tostring(math.min(unpack(this.data.info.sizes)));
	this.use_enums = true;
	
	--/ Private functions

	local function preload()
		for _, asset in pairs(this.atlases) do
			content:Preload(asset);
		end;
	end;
	
	local function useenums()
		for _, size in pairs(this.data.info.sizes) do
			if not contains({96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8}, size) then
				this.use_enums = false;
			end;
		end;
	end;
	
	local function failsafe()
		-- If a character isn't found replaces with "?"
		local replace = " ";
		for key, char_set in pairs(this.data.sizes) do
			setmetatable(char_set.characters, {})
			local mt = getmetatable(char_set.characters);
			mt.__index = function(t, k) 
				if rawget(t, k) then 
					return rawget(t, k);
				else 
					warn(string.char(k), "is not a valid character. Replaced with, \"".. replace.. "\"");
					return rawget(t, tostring(string.byte(replace)));
				end;
			end;			
			mt.__metatable = "The metatable is locked.";
		end;
		
		-- If a size isn't found picks next closest
		setmetatable(this.data.sizes, {});
		local mt = getmetatable(this.data.sizes);
		mt.__index = function(t, k)
			if rawget(t, k) then 
				return rawget(t, k);
			else 
				local closest = find_closest(this.data.info.sizes, tonumber(k)); 
				warn(k, "is not a valid size. Using closest size,", closest); 
				this.size = tostring(closest); 
				local fPx = real_object:FindFirstChild("FontPx");
				if fPx and fPx.Value ~= closest then fPx.Value = closest; end;
				return rawget(t, tostring(closest)); 
			end;
		end;
		mt.__metatable = "The metatable is locked.";
	end;
	
	local function init()
		preload();
		useenums();
		failsafe();
	end;
	
	--/ Run
	
	init();
	return this;
end;

function new_spriteObject(font_name, obj_class)
	local this = {};
	
	--/ Properties
	
	this.Scale = 1;
	this.FontName = font_name;
	this.FontPx = 0;
	
	--/ Local tags

	local events = {};
	local text_items = {};
	local fakeProps = {};
	
	local textTransparency = 0;
	
	local font_module = fonts:FindFirstChild(font_name);
	if not font_module or not font_module:IsA("ModuleScript") then error(table.concat({font_name, "could not be found in the font directory."}, " ")) end;
	
	--/ Object creation
	
	local real_object = type(obj_class) == "string" and serializeFrame(obj_class) or obj_class;
	local public = new_wrap(real_object, this);
	
	local settings = new_fontSettings(require(font_module), real_object);
	this.FontPx = settings.size;
	
	real_object.TextTransparency = 2;
	real_object.TextStrokeTransparency = 2;
	real_object.BackgroundTransparency = 2;
	
	--/ Private functions
	
	local function getAlignMultiplier(enum)
		return contains({"Right", "Bottom"}, enum.Name) and 1 or (contains({"Left", "Top"}, enum.Name) and 0 or 0.5);
	end;
	
	local function getPixelLength(text, fsize)
		local length = 0;
		for index = 1, string.len(text) do
			length = length + settings.data.sizes[tostring(fsize)].characters[tostring(string.byte(string.sub(text, index, index)))].xadvance;
		end;
		return length;
	end;
	
	local function getWords(text, newlines)
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

	local function getLines(text)
		local text = string.gsub(text, "\t", string.rep(" ", 4));
		local lines, nlines = split(text, "\n"), {};
		for i, line in ipairs(lines) do
			table.insert(nlines, line);
			--if i < #lines then table.insert(nlines, ""); end;
		end;
		return nlines;
	end;

	local function wrapText(text, fsize)
		local words, lines = getWords(text, true), {};
		local maxWidth, fullWidth, index = public().AbsoluteSize.x, 0, 1;
		for i, word in pairs(words) do
			if word ~= "\n" then
				local width = getPixelLength(word, fsize or settings.size);
				if fullWidth < 1 then -- Get at least one word on the line
					lines[index] = word;
				elseif width + fullWidth <= maxWidth then
					lines[index] = lines[index]..word;
				else
					lines[index] = string.gsub(lines[index], " +$", "");
					index = index + 1;
					fullWidth = 0;
					lines[index] = word;
				end;
				fullWidth = fullWidth + width;
			else
				lines[index] = string.gsub(lines[index], " +$", "");
				index = index + 1;
				fullWidth = 0;
				lines[index] = "";
			end;
		end;
		return lines;
	end;
	
	local function drawSprite(byte)
		-- Basic setup
		local sprite = imgFrame:Clone();
		sprite.Name = byte;
		
		-- Carry over properties
		sprite.ImageColor3 = real_object.TextColor3;
		sprite.ImageTransparency = textTransparency;
		sprite.ZIndex = real_object.ZIndex;
		
		-- Image setup/placement
		sprite.Image = settings.atlases[settings.data.sizes[settings.size].info.atlas];
		sprite.ImageRectSize = Vector2.new(settings.data.sizes[settings.size].characters[byte].width, settings.data.sizes[settings.size].characters[byte].height);
		sprite.ImageRectOffset = Vector2.new(settings.data.sizes[settings.size].characters[byte].x, settings.data.sizes[settings.size].characters[byte].y);

		-- Frame positioning and sizeing
		sprite.Position = UDim2.new(0, settings.data.sizes[settings.size].characters[byte].xoffset, 0, 0);
		sprite.Size = multiplyUDim(UDim2.new(0, settings.data.sizes[settings.size].characters[byte].width, 0, settings.data.sizes[settings.size].characters[byte].height), this.Scale.Value);

		table.insert(text_items, sprite);
		return sprite;
	end;
	
	local function drawLine(line, height, allSprites)
		-- Get some info to work with
		local xAlign = getAlignMultiplier(real_object.TextXAlignment);
		local lineHeight = settings.data.sizes[settings.size].info.lineHeight * this.Scale.Value;
		local width, heights, sprites = 0, {}, {};
		
		-- Draw the line
		for index = 1, string.len(line) do
			local byte = tostring(string.byte(string.sub(line, index, index)));
			-- Place the sprite
			local sprite = drawSprite(byte);
			sprite.Position = sprite.Position + UDim2.new(0, width, 0, height);
			sprite.Parent = real_object;
			-- Prep width for character
			width = width + (settings.data.sizes[settings.size].characters[byte].xadvance * this.Scale.Value);
			-- Store the sprite for xAlignment
			table.insert(sprites, sprite);
		end;
		
		-- xAlignment
		for _, sprite in pairs(sprites) do
			table.insert(allSprites, sprite);
			sprite.Position = sprite.Position + UDim2.new(0, (xAlign * real_object.AbsoluteSize.x) - xAlign * width, 0, 0);
		end;
	end;
	
	local function drawLines(text)
		-- FontScaled (picks best size)
		if real_object.TextScaled then
			settings.size = tostring(settings.data.info.sizes[#settings.data.info.sizes]);
			for _, size in ipairs(settings.data.info.sizes) do
				-- Collect data
				local lines = real_object.TextWrapped and wrapText(text, size) or getLines(text);
				local y, x = settings.data.sizes[tostring(size)].info.lineHeight * this.Scale.Value * #lines, {0};
				for _, line in pairs(lines) do
					table.insert(x, getPixelLength(text, size));
				end
				x = math.max(unpack(x));
				-- Calculate
				if (real_object.TextWrapped and y <= real_object.AbsoluteSize.y) or x <= real_object.AbsoluteSize.x then
					settings.size = tostring(size);
					break;
				end;
			end;
		end;
		
		-- Grab needed values
		local yAlign, sprites, height = getAlignMultiplier(real_object.TextYAlignment), {}, 0;
		local lines = real_object.TextWrapped and wrapText(text) or getLines(text);
		local lineHeight = settings.data.sizes[settings.size].info.lineHeight * this.Scale.Value;
		
		-- Draw lines
		for _, line in pairs(lines) do
			drawLine(line, height, sprites);
			height = height + lineHeight;
		end;
		
		-- yAlignment
		for _, sprite in pairs(sprites) do
			sprite.Position = sprite.Position + UDim2.new(0, 0, yAlign, -height * yAlign);
		end;
	end;
	
	local function clearAllText()
		for _, item in pairs(text_items) do
			item:Destroy();
		end;
		text_items = {};
	end;
	
	local function reDraw()
		settings.size = tostring(this.FontPx.Value);
		clearAllText();
		drawLines(real_object.Text);
	end;
	
	local function set_connections()
		-- Scale
		table.insert(events, this.Scale:connect(function(newScale)
			local realProp = real_object:FindFirstChild("Scale");
			if realProp and realProp.Value ~= newScale then
				realProp.Value = newScale;
			end;
			reDraw();
		end));
		
		-- Font name
		table.insert(events, this.FontName:connect(function(newFont)
			local fontModule = fonts:FindFirstChild(newFont);
			if not fontModule then error(newFont, "was not found.") end;
			
			settings = new_fontSettings(require(fontModule), real_object);
			reDraw();
			
			local realProp = real_object:FindFirstChild("FontName");
			if realProp and realProp.Value ~= newFont then
				realProp.Value = newFont;
			end;
		end));
		
		-- FontPx
		table.insert(events, this.FontPx:connect(function(newPx)
			local realProp = real_object:FindFirstChild("FontPx");
			if realProp and realProp.Value ~= newPx then
				realProp.Value = newPx;
			end;
			reDraw();
			if settings.use_enums and real_object.FontSize ~= "Size"..newPx then
				real_object.FontSize = "Size"..this.FontPx.Value;
				return
			end;
		end));
		
		-- Shared properties
		local transOverflow = false;
		table.insert(events, real_object.Changed:connect(function(prop)
			if contains({"TextTransparency", "BackgroundTransparency"}, prop) and not transOverflow then
				transOverflow = true;
				if prop == "TextTransparency" then this.Transparency.Value = public()[prop]; end;
				real_object[prop] = 2;
			else
				transOverflow = false;
			end;
			if settings.use_enums and prop == "FontSize" then this.FontPx.Value = tonumber(string.match(real_object.FontSize.Name, "%d+$")); end;
			reDraw();
		end));
		
		-- Text box
		if real_object.ClassName == "TextBox" then
			real_object.Focused:connect(function()
				if real_object.ClearTextOnFocus then
					real_object.Text = "";
				end;
			end);
		end;
	end;
	
	local function buildFakeProperties()
		local props = settings.use_enums and {"FontName", "Scale"} or {"FontName", "Scale", "FontPx"};
		for key, prop in pairs(props) do
			local thing = this[prop];
			if type(thing) == "table" then
				local class = type(thing.Value);
				if class ~= "function" then
					local rep = string.gsub(class, "^.", string.upper(string.sub(class, 1, 1))).."Value";
					local item = Instance.new(rep, public());
					item.Name = prop;
					item.Value = thing.Value;
					table.insert(events, item.Changed:connect(function(newValue)
						this[prop].Value = newValue;
					end));
					table.insert(fakeProps, item);
				end;
			end;
		end;
	end;
	
	local function init()
		-- Setup pseudo events
		for key, value in pairs(this) do
			this[key] = new_pseudoEvent(this, key);
		end;
		if settings.use_enums then this.FontPx.Value = tonumber(string.match(real_object.FontSize.Name, "%d+$")); end;
		set_connections();
		buildFakeProperties();
		reDraw();
	end;
	
	--/ Public functions
	
	function this:Destroy()
		real_object:Destroy();
		self = nil;
	end;
	
	function this:UnSprite() -- WIP needs more testing
		for _, event in pairs(events) do
			event:disconnect();
		end;
		for _, prop in pairs(fakeProps) do
			prop:Destroy();
		end;
		clearAllText();
		real_object.TextTransparency = self.Transparency;
		self = nil;
	end;
	
	function this:ClearAllChildren()
		for _, child in pairs(public():GetChildren()) do
			if not contains(text_items, child) and not contains(fakeProps, child) then
				child:Destroy();
			end;
		end;
	end;
	
	function this:GetChildren()
		local children = {};
		for _, child in pairs(public():GetChildren()) do
			if not contains(text_items, child) and not contains(fakeProps, child) then
				table.insert(children, child);
			end;
		end;
		return children;
	end;

	--/ Run
	
	init();
	return public;
end;

------------------------------------------------------------------------------------------------------------------------------
--// Run

local create = {};
for _, class in pairs({"TextLabel", "TextBox", "TextButton", "TextReplace"}) do
	create[string.sub(class, 5)] = function(font_name, object)
		return new_spriteObject(font_name, class == "TextReplace" and object or class);
	end;
end;

return create;
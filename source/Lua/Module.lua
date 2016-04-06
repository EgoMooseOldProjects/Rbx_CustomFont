--[[
	Rbx_CustomFont - C# version
	Sprite creation module for custom text fonts.
	@author EgoMoose
	@link http://www.roblox.com/Rbx-CustomFont-item?id=230767320
	@date 05/04/2016
--]]

-- Github	: https://github.com/EgoMoose/Rbx_CustomFont
-- Fonts 	: https://github.com/EgoMoose/Rbx_CustomFont/wiki/Creating-your-own-font

------------------------------------------------------------------------------------------------------------------------------
--// Setup

local fonts = script;
local content = game:GetService("ContentProvider");

local imgFrame = Instance.new("ImageLabel");
imgFrame.Size = UDim2.new();
imgFrame.BackgroundTransparency = 1;
imgFrame.ScaleType = Enum.ScaleType.Stretch;

local replace = string.byte("?"); -- what if this character doesn't exist??!?!?

local justify1 = {
	["Right"] = true;
	["Bottom"] = true
};

local justify0 = {
	["Left"] = true;
	["Top"] = true
};

local redraws = {
	["AbsoluteSize"] = true;
	["TextWrapped"] = true;
	["TextScaled"] = true;
	["TextXAlignment"] = true;
	["TextYAlignment"] = true;
};

local overwrites = {
	["TextTransparency"] = true;
	["BackgroundTransparency"] = true;
	["TextStrokeTransparency"] = true;
};

local noReplicate = {
	["AbsolutePosition"] = true;
	["AbsoluteSize"] = true;
	["Position"] = true;
	["Size"] = true;
	["Rotation"] = true;
	["Parent"] = true;
};

local customProperties = {
	["Scale"] = true;
	-- ["FullText"] = true;
	["FontName"] = true;
	["FontPx"] = true;
	["Style"] = true;
};

------------------------------------------------------------------------------------------------------------------------------
--// Functions

function getAlignMultiplier(enum)
	return (justify1[enum.Name] and 1) or (justify0[enum.Name] and 0) or 0.5;
end

function closestNumber(number, compare)
	table.sort(compare);
	local closest, diff;
	for _, otherNumber in next, compare do
		local new_diff = math.abs(number - otherNumber);
		if not diff or new_diff <= diff then
			diff = new_diff
			closest = otherNumber;
		end;
	end;
	return closest;
end;

function wrapper(child, addition)
	local this = newproxy(true);
	
	local mt = getmetatable(this);
	mt.__index = function(t, k) return addition[k] or child[k]; end;
	mt.__newindex = function(t, k, v) if addition[k] then addition[k] = v; else child[k] = v; end; end;
	mt.__call = function() return child; end;
	mt.__tostring = function(t) return tostring(child); end;
	mt.__metatable = "The metatable is locked.";
	
	return this;
end;

function split(text, pattern)
	local tab, linepos = {}, 0;
	
	while true do
		local pos = string.find(text, pattern, linepos, true);
		if pos then
			table.insert(tab, string.sub(text, linepos, pos - 1));
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
	
	for i, line in next, lines do
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
	
	for i, line in next, lines do
		table.insert(nlines, line);
		--if i < #lines then table.insert(nlines, ""); end;
	end;
	
	return nlines;
end;

function defaultHide(child)
	child.TextTransparency = 2;
	child.BackgroundTransparency = 2;
	child.TextStrokeTransparency = 2;
end;

function newBackground(child, class)
	local frame = Instance.new("Frame", child);
	
	frame.Name = "_background";
	frame.Size = UDim2.new(1, 0, 1, 0);
	frame.BackgroundTransparency = child.BackgroundTransparency;
	frame.BackgroundColor3 = child.BackgroundColor3;
	frame.BorderSizePixel = child.BorderSizePixel;
	frame.BorderColor3 = child.BorderColor3;
	frame.ZIndex = child.ZIndex;
	
	if class == "TextButton" then
		frame.MouseEnter:connect(function()
			if child.AutoButtonColor then 
				local origin = child.BackgroundColor3;
				frame.BackgroundColor3 = Color3.new(origin.r - 75/255, origin.g - 75/255, origin.b - 75/255); 
			end;
		end);
		
		child.MouseLeave:connect(function()
			if child.AutoButtonColor then
				frame.BackgroundColor3 = child.BackgroundColor3;
			end;
		end);
	end;
	
	return frame;
end;

function getStringWidth(text, settings, size)
	local len, sizeSet = 0, settings.styles[settings.style][size or settings.size];
	for index = 1, #text do	
		
		local index2 = index + 1 <= #text and index + 1;
		local byte = string.byte(string.sub(text, index, index));
		local nextByte = index2 and string.byte(string.sub(text, index2, index2));		
			
		local char = sizeSet.characters[byte];
		len = len + char.xadvance;
		
		-- apply kerning
		local kern = Vector2.new();
		if nextByte and sizeSet.kerning[byte] and sizeSet.kerning[byte][nextByte] then
			kern = Vector2.new(sizeSet.kerning[byte][nextByte].x, sizeSet.kerning[byte][nextByte].y);
		end;
		
		len = len + kern.x;
	end;
	return len;
end;

function getStringHeight(text, settings, size)
	local lens, characterSet = {0}, settings.styles[settings.style][size or settings.size].characters;
	for i = 1, #text do
		local char = characterSet[string.byte(string.sub(text, i, i))];
		table.insert(lens, char.height + char.yoffset);
	end;
	return math.max(unpack(lens));
end;

function wrapText(child, text, settings, size)
	local lines, lineWidth, index = {""}, 0, 1;
	local maxWidth = math.abs(child.AbsoluteSize.x);

	for _, word in next, getWords(text, true) do
		if word ~= "\n" then
			local width = getStringWidth(word, settings, size);
			
			if width + lineWidth <= maxWidth then
				lines[index] = lines[index] .. word;
			else
				index = index + 1;
				lineWidth = 0;
				lines[index] = word;
			end;
			
			lineWidth = lineWidth + width;
		else
			-- lines[index] = string.gsub(lines[index], "%s+$", "");
			index = index + 1;
			lineWidth = 0;
			lines[index] = "";
		end;
	end;

	return lines;
end;

function scaleText(self, child, text, settings)
	-- idk why, but without this the table keeps getting sorted from least to greatest automatically...
	table.sort(settings.information.sizes, function(a, b) return a > b; end);
	local bestSize = settings.information.sizes[1];
	
	for _, size in next, settings.information.sizes do
		local sizeSet = settings.styles[settings.style][size];
		local lines = child.TextWrapped and wrapText(child, text, settings, size) or getLines(text);	
		
		local widths, height = {}, -sizeSet.firstAdjust;
		for _, line in next, lines do
			table.insert(widths, getStringWidth(line, settings, size));
			height = height + getStringHeight(line, settings, size)
		end;
		
		local width, height = math.max(unpack(widths)) * self.Scale, (height * self.Scale);
		if width <= math.abs(child.AbsoluteSize.x) and height <= math.abs(child.AbsoluteSize.y) then
			bestSize = size;
			break;
		end;
	end;
	
	return bestSize;
end;

function drawCharacter(byte, nextByte, child, self, settings, parent)
	local sprite = imgFrame:Clone();
	local atlases = settings.atlases;
	
	local sizeSet = settings.styles[settings.style][settings.size]
	local character = sizeSet.characters[byte];

	-- fill in the properties	
	sprite.Name = byte;
	sprite.ImageColor3 = child.TextColor3;
	sprite.ImageTransparency = self.TextTransparency;
	sprite.ZIndex = child.ZIndex;
	
	-- build the sprite
	sprite.Image = atlases[character.atlas + 1];
	sprite.ImageRectSize = Vector2.new(character.width, character.height);
	sprite.ImageRectOffset = Vector2.new(character.x, character.y);
	
	-- apply kerning
	local kern = Vector2.new();
	if nextByte and sizeSet.kerning[byte] and sizeSet.kerning[byte][nextByte] then
		kern = Vector2.new(sizeSet.kerning[byte][nextByte].x, sizeSet.kerning[byte][nextByte].y);
	end;
	
	-- position and size the frame
	sprite.Position = UDim2.new(0, kern.x * self.Scale, 0, (character.yoffset + kern.y) * self.Scale);
	sprite.Size = UDim2.new(0, character.width * self.Scale, 0, character.height * self.Scale); -- multiply by scale property	
	
	--sprite.Parent = parent;
	
	return sprite, kern;
end;

local strokethickness = 2;
function textStroke(sprite, self, child, shift)
	if self.TextStrokeTransparency < 1 then
		local size = sprite.AbsoluteSize;
		local position = sprite.AbsolutePosition - child.AbsolutePosition;
		
		local top = sprite:Clone();
		top.ImageColor3 = child.TextStrokeColor3;
		top.ImageTransparency = self.TextStrokeTransparency;
		--top.Size = UDim2.new(0, size.x + (strokethickness * 3), 0, size.y);
		top.Position = UDim2.new(0, position.x, 0, position.y - strokethickness);
		
		local bottom = sprite:Clone();
		bottom.ImageColor3 = child.TextStrokeColor3;
		bottom.ImageTransparency = self.TextStrokeTransparency;
		--bottom.Size = UDim2.new(0, size.x + (strokethickness * 2), 0, size.y);
		bottom.Position = UDim2.new(0, position.x, 0, position.y + strokethickness);
		
		local left = sprite:Clone();
		left.ImageColor3 = child.TextStrokeColor3;
		left.ImageTransparency = self.TextStrokeTransparency;
		left.Size = UDim2.new(0, size.x, 0, size.y + (strokethickness*2));
		left.Position = UDim2.new(0, position.x + strokethickness, 0, position.y - strokethickness);
		
		local right = sprite:Clone();
		right.ImageColor3 = child.TextStrokeColor3;
		right.ImageTransparency = self.TextStrokeTransparency;
		right.Size = UDim2.new(0, size.x, 0, size.y + (strokethickness*2));
		right.Position = UDim2.new(0, position.x - strokethickness, 0, position.y - strokethickness);
		--]]		
		
		return {top, bottom, left, right};
	end;
end;

function drawLine(text, currentHeight, child, self, settings, parent, allSprites)
	local xalign = getAlignMultiplier(child.TextXAlignment);
	local sizeSet = settings.styles[settings.style][settings.size];
	
	local width, sprites = 0, {};
	
	for index = 1, #text do
		local index2 = index + 1 <= #text and index + 1;
		local byte = string.byte(string.sub(text, index, index));
		local nextByte = index2 and string.byte(string.sub(text, index2, index2));
		
		local character, kern = drawCharacter(byte, nextByte, child, self, settings, parent);
		character.Position = character.Position + UDim2.new(0, width, 0, currentHeight);
		
		width = width + ((index2 and sizeSet.characters[byte].xadvance or sizeSet.characters[byte].width) + kern.x) * self.Scale;
		
		table.insert(sprites, character);
		table.insert(allSprites, character);
	end;
	
	local adjust = (math.abs(child.AbsoluteSize.x) - width) * xalign;
	for _, character in next, sprites do
		character.Position = character.Position + UDim2.new(0, adjust, 0, 0);
		character.Parent = parent;
	end;
	
	return width;
end;

function drawLines(text, child, self, settings, parent)
	if child.TextScaled then
		settings.size = scaleText(self, child, text, settings);
	end;
	
	local yalign = getAlignMultiplier(child.TextYAlignment);
	local lines = child.TextWrapped and wrapText(child, text, settings, settings.size) or getLines(text);
	local lineHeight = settings.styles[settings.style][settings.size].lineHeight * self.Scale;
	
	local allSprites, widths, height = {}, {0}, -settings.styles[settings.style][settings.size].firstAdjust;	
	
	for _, line in next, lines do
		table.insert(widths, drawLine(line, height, child, self, settings, parent, allSprites));
		height = height + lineHeight;
	end;
	
	for _, sprite in next, allSprites do
		sprite.Position = sprite.Position + UDim2.new(0, 0, yalign, -height * yalign);
		local stroke = textStroke(sprite, self, child);
		if stroke then
			for _, strk in ipairs(stroke) do
				strk.Name = "stroke_"..sprite.Name;
				strk.Parent = parent;
			end;
		end;
		sprite.Parent = nil;
		sprite.Parent = parent;
	end;
	
	self.TextFits = child.AbsoluteSize.x > math.max(unpack(widths)) and child.AbsoluteSize.y > height;
	
	return allSprites;
end;

------------------------------------------------------------------------------------------------------------------------------
--// Classes

-- custom signal class

local signal = {};

function signal.new()
	local self = setmetatable({}, {__index = signal});
	
	self.event = Instance.new("BindableEvent");
	self.params = {};
	
	return self;
end;

function signal:connect(func)
	return self.event.Event:connect(function() 
		func(unpack(self.params)) 
	end);
end;

function signal:fire(...)
	self.params = {...};
	self.event:Fire();
end;

function signal:Destroy()
	self.event:Destroy()
	self.params = {};
	self = nil;
end;

-- custom event class

local cevents = {};

function cevents.new(tab)
	local events = {};
	
	for key, _ in next, tab do
		events[key] = signal.new();
	end;
	
	local this = setmetatable({}, {
		__index = tab;
		__newindex = function(t, k, v)
			if not events[k] then 
				events[k] = signal.new();
			end;
			if tab[k] ~= v then
				tab[k] = v;
				events[k]:fire(v);
			end;
		end;
		__metatable = "The metatable is locked.";
	});
	
	function this:connect(key, func)
		return events[key]:connect(func);
	end;
	
	function this:clearEvents()
		for _, event in next, events do
			event:Destroy();
		end;
	end;
	
	return this;
end;

-- settings class

local settings = {};

function settings.new(font, this)
	local self = setmetatable({}, {__index = settings});
	
	-- place data in new format for easy access
	self.information = font.font.information;
	self.atlases = font.atlases;
	self.styles = font.font.styles;
	
	-- sort from least to greatest
	table.sort(self.information.sizes, function(a, b) return a > b; end);
	
	-- establish some settings variables
	self.style = self.information.styles[1];
	self.size = math.min(unpack(self.information.sizes));
	
	-- apply failsafes
	for style, sizes in pairs(self.styles) do
		
		-- characters that DNE
		for size, characters in next, sizes do
			setmetatable(characters, {
				__index = function(t, k)
					if not rawget(t, k) then 
						warn(string.char(k), "is not a valid character. Replaced with, \"" .. string.char(replace) .. "\"");
						rawget(t, replace);
					end;
					return rawget(t, k);
				end;
			});
		end;
		
		-- sizes that DNE
		setmetatable(sizes, {
			__index = function(t, k)
				if not rawget(t, k) then 
					local closest = closestNumber(k, self.information.sizes);
					warn(k, "is not a valid size. Using closest size,", closest);
					self.size = closest;
					this.FontPx = closest;
					return rawget(t, closest);
				end;
				return rawget(t, k);
			end;
		});
	end;
	
	-- styles that DNE
	setmetatable(self.styles, {
		__index = function(t, k)
			if not rawget(t, k) then 
				local newStyle = self.information.styles[1];
				warn(k, "is not a valid style. Using first style found", newStyle);
				self.style = newStyle;
				this.Style = newStyle;
				return rawget(t, newStyle);
			end;
			return rawget(t, k);
		end;
	});
	
	return self;
end;

function settings:preload()
	for _, atlas in next, self.atlases do
		content:Preload(atlas);
	end;
end;

-- custom font class

local cfont = {};

function cfont.new(font, class, button)
	local self = cevents.new {};
	local exists = not (type(class) == "string");
	
	-- I'm taking the gloves off. If it errors, that's on you, reference a font that exists
	local child = exists and class or Instance.new(class);
	local fontModule = fonts:FindFirstChild(font);
	local settings = settings.new(require(fontModule), self);
	
	local background = newBackground(child, button and "TextButton");
	local drawnCharacters, properties, propObjects, events = {}, {}, {}, {};
	
	-- set settings
	settings:preload();
	settings.size = settings.information.useEnums and tonumber(string.match(child.FontSize.Name, "%d+$")) or settings.size;
	
	-- properties that will take physical form
	self.Scale = 1;
	self.FullText = child.Text;
	self.FontName = font;
	self.FontPx = settings.size;
	self.Style = settings.style;
	self.TextTransparency = child.TextTransparency;
	self.BackgroundTransparency = child.BackgroundTransparency;
	self.TextStrokeTransparency = 1; -- this won't do anything but maybe I'll add support in the future
	self.TextFits = false;
	
	-- build the object

	defaultHide(child);
	
	for name, _ in next, customProperties do
		local property = self[name];
		local t = type(property);
		if t ~= "function" then
			local class = string.upper(string.sub(t, 1, 1)) .. string.sub(t, 2) .. "Value";
			local physicalProperty = Instance.new(class, child);
			
			physicalProperty.Name = name;
			physicalProperty.Value = property;
			
			physicalProperty.Changed:connect(function(newValue)
				self[name] = newValue;
			end);
			
			propObjects[physicalProperty.Name] = physicalProperty;
			properties[physicalProperty] = true;
		end;
	end;
	
	local function drawText()
		background:ClearAllChildren();
		drawnCharacters = drawLines(string.sub(self.FullText, 1, 10^4), child, self, settings, background);
	end;
	
	-- connect the custom listeners
	
	self:connect("FullText", function(newValue)
		drawText();
	end);
	
	self:connect("Scale", function(newValue)
		propObjects["Scale"].Value = newValue;
		
		drawText();
	end);	
	
	self:connect("FontName", function(newValue)
		local fontModule = fonts:FindFirstChild(newValue);
		settings = settings.new(require(fontModule), self);
		settings:preload();
		propObjects["FontName"].Value = newValue;
		
		if not child.TextScaled then
			settings.size = self.FontPx;
		end;
		settings.style = self.Style;
		
		drawText();
	end);
	
	self:connect("FontPx", function(newValue)
		settings.size = newValue;
		propObjects["FontPx"].Value = settings.size;
		
		if settings.information.useEnums then
			pcall(function() child.FontSize = "Size" .. settings.size; end);
		end;
		
		drawText();
	end);
	
	self:connect("Style", function(newValue)
		settings.style = newValue;
		propObjects["Style"].Value = settings.style;
		
		drawText();
	end);
	
	self:connect("TextTransparency", function(newValue)
		for _, sprite in next, drawnCharacters do
			sprite.ImageTransparency = newValue;
		end;
	end);
	
	self:connect("BackgroundTransparency", function(newValue)
		background.BackgroundTransparency = newValue;
	end);
	
	self:connect("TextStrokeTransparency", function(newValue)
		drawText();
	end);
	
	-- connect the real listeners	
	
	table.insert(events, child.Changed:connect(function(property)
		if overwrites[property] then		
			if child[property] ~= 2 then
				self[property] = child[property]	
			end;
			child[property] = 2;
		elseif settings.information.useEnums and property == "FontSize" then
			self.FontPx = tonumber(string.match(child[property].Name, "%d+$"));
		elseif property == "TextColor3" then
			for _, sprite in next, drawnCharacters do
				sprite.ImageColor3 = child[property];
			end;
		elseif property == "ZIndex" then
			background.ZIndex = child[property];
			for _, sprite in next, drawnCharacters do
				sprite.ZIndex = child[property];
			end;
		elseif property == "Text" then
			self.FullText = child[property];
		elseif redraws[property] then
			if property == "TextScaled" and not child[property] then
				settings.size = self.FontPx;
			end;
			drawText();
		elseif not string.match(property, "Text") and not noReplicate[property] then
			pcall(function() background[property] = child[property]; end);
		end
	end));
	
	if child:IsA("TextBox") then
		table.insert(events,child.Focused:connect(function()
			if child.ClearTextOnFocus then
				child.Text = "";
			end;
		end));
	end;
	
	-- methods
	
	function self:Revert()
		self:clearEvents();
		for property, _ in next, properties do property:Destroy(); end;
		for _, event in next, events do event:disconnect(); end;
		background:Destroy();
		child.TextTransparency = self.TextTransparency;
		child.BackgroundTransparency = self.BackgroundTransparency;
		self, properties, events = nil, nil, nil;
		return child;
	end;
	
	function self:GetChildren()
		local children = {};
		for _, kid in next, child:GetChildren() do
			if kid ~= background and not properties[kid] then
				table.insert(children, kid);
			end;
		end;
		return children;
	end;
	
	function self:ClearAllChildren()
		for _, kid in next, child:GetChildren() do
			if kid ~= background and not properties[kid] then
				kid:Destroy();
			end;
		end;
	end;
	
	function self:Destroy()
		self:Revert():Destroy();
	end;
	
	-- return the custom font object wrapped up in a little bow tie!

	drawText();
	return wrapper(child, self);
end;

------------------------------------------------------------------------------------------------------------------------------
--// Setup

local module = {};

for _, class in next, {"TextLabel", "TextBox", "TextButton", "TextReplace"} do
	module[string.sub(class, 5)] = function(fontName, child)
		return cfont.new(fontName, class == "TextReplace" and child or class, class == "TextButton" or (class == "TextReplace" and child:IsA("TextButton")));
	end;
end;

wait(); -- top bar can mess with stuff if fonts called instantly

return module;
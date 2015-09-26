--[[
	Font sprites module
	Sprite creation module for custom text fonts.
	@author EgoMoose
	@link http://www.roblox.com/Sprite-Fonts-Module-item?id=230767320
	@date 20/09/2015
--]]

------------------------------------------------------------------------------------------------------------------------------
--// Setup

local fonts = script;
local http = game:GetService("HttpService");

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

function quickWrap(obj, add)
	local item = setmetatable({}, {
		__index = function(t, k)
			if add[k] then
				local success, value = pcall(function() return add[k].Value; end);
				return success and value or add[k];
			else
				return obj[k];
			end;
		end;
		__newindex = function(t, k, v) 
			if add[k] then
				add[k].Value = v;
			else
				obj[k] = v;
			end;
		end;
		__call = function() return obj; end; -- Call as function for the real object
		__metatable = "The metatable is locked";
	})
	return item;
end

function contains(tab, element, keys)
	local focus = keys or tab;
	for key, val in pairs(focus) do
		local index = keys and val or key -- seems like it's the other way around, but alas, no...
		if tab[index] == element then
			return true;
		end;
	end;
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

function fontSettings(module)
	local this = {
		data = http:JSONDecode(module.json);
		image = module.image;
	};
	for _, img in pairs(this.image) do game:GetService("ContentProvider"):Preload(img); end;
	this.size = tostring(math.min(unpack(this.data.info.sizes)));
	return this;
end;

function spriteObject(fontName, makeFakeProps, class, customSize)
	-- Properties
	local this = {
		Scale = 1;
		Transparency = 0; -- Please use text transparency
		FontName = fontName;
	};
	if customSize then this.FontPx = 0; end;
	-- Hidden properties
	local hidden = {"Transparency"};
	-- Tables
	local currentText, fakeProps = {}, {};
	local events = {};
	-- Create the object
	local public = quickWrap(type(class) == "string" and serializeFrame(class):Clone() or class, this);
	-- Info about the sprite from bmfont file.
	local validFont = fonts:FindFirstChild(fontName);
	if not validFont then error("Font not found under fonts folder!"); end;
	local settings = fontSettings(require(validFont));
	if customSize then this.FontPx = settings.size; end;
	
	public().TextTransparency = 2;
	public().TextStrokeTransparency = 2;
	public().BackgroundTransparency = 2;	

	--/ Private functions

	local function init()
		-- Pseudo events
		for key, value in pairs(this) do
			local proxy = {
				Value = value;
				connected = {};
			};
			local subThis = setmetatable({}, {
				__index = function(t, k) return proxy[k] end;
				__newindex = function(t, k, v)
					local old = proxy[k];
					proxy[k] = v;
					if k == "Value" and old ~= v then
						for _, func in pairs(proxy.connected) do
							if func then
								func(v);
							end;
						end;
					end;
				end;
			});
			local connections = 0;
			function proxy:connect(func)
				connections = connections + 1;
				local connection = {};
				local currentConnection = connections;
				proxy.connected[currentConnection] = func;
				function connection:disconnect()
					proxy.connected[currentConnection] = nil;
				end;
				return connection;
			end;
			-- Update value in this with new meta tables.
			this[key] = subThis;
		end;
	end;
	
	local function getAlignMultiplier(enum)
		return contains({"Right", "Bottom"}, enum.Name) and 1 or (contains({"Left", "Top"}, enum.Name) and 0 or 0.5);
	end;
	
	local function getStringPixelLength(text)
		local length, t = string.len(text), 0;
		for i = 1, length do
			local byte = tostring(string.byte(string.sub(text, i, i)));
			local char = settings.data.sizes[settings.size].characters[byte];
			local val = char and char["xadvance"] or 0;
			t = t + val;
		end;
		return t;
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

	local function wrapText(text)
		local words, lines = getWords(text, true), {};
		local maxWidth, fullWidth, index = public().AbsoluteSize.x, 0, 1;
		for i, word in pairs(words) do
			if word ~= "\n" then
				local width = getStringPixelLength(word);
				if fullWidth < 1 then -- Get at least one word on the line
					lines[index] = word;
				elseif width + fullWidth <= maxWidth then
					lines[index] = lines[index]..word;
				else
					index = index + 1;
					fullWidth = 0;
					lines[index] = word;
				end;
				fullWidth = fullWidth + width;
			else
				index = index + 1;
				fullWidth = 0;
				lines[index] = "";
			end;
		end;
		return lines;
	end;

	local function drawSprite(byteKey, prev)
		local prev = prev or string.byte("");
		local byteKey = settings.data.sizes[settings.size].characters[byteKey] and byteKey or "63";
		local object = imgFrame:Clone();
		object.Name = byteKey;
		object.Position = UDim2.new(0, settings.data.sizes[settings.size].characters[byteKey].xoffset, 0, 0);
		object.Size = multiplyUDim(UDim2.new(0, settings.data.sizes[settings.size].characters[byteKey].width, 0, settings.data.sizes[settings.size].characters[byteKey].height), this.Scale.Value);
		object.Image = settings.image[settings.data.sizes[settings.size].info.atlas];
		object.ImageRectSize = Vector2.new(settings.data.sizes[settings.size].characters[byteKey].width, settings.data.sizes[settings.size].characters[byteKey].height);
		object.ImageRectOffset = Vector2.new(settings.data.sizes[settings.size].characters[byteKey].x, settings.data.sizes[settings.size].characters[byteKey].y);
		object.ImageColor3 = public().TextColor3;
		object.ImageTransparency = this.Transparency.Value;
		object.ZIndex = public().ZIndex;
		table.insert(currentText, object);
		return object;
	end;
	
	local function drawLine(line, prevHeight, allObjects)
		local xAlign = getAlignMultiplier(public().TextXAlignment);
		local length, prevWidth, heights = string.len(line), 0, {};
		local objects = {};
		for index = 1, length do
			local byte = tostring(string.byte(string.sub(line, index, index)));
			local object = drawSprite(byte);
			--posFrom(object, UDim2.new(xAlign, prevWidth, yAlign, prevHeight), 0, 0);
			object.Position = object.Position + UDim2.new(xAlign, prevWidth, 0, prevHeight);
			object.Parent = public();
			local width = settings.data.sizes[settings.size].characters[byte] and settings.data.sizes[settings.size].characters[byte].xadvance or 0;
			prevWidth = prevWidth + width * this.Scale.Value;
			table.insert(objects, object);
		end
		local maxHeight = settings.data.sizes[settings.size].info.lineHeight * this.Scale.Value;
		for _, object in pairs(objects) do
			table.insert(allObjects, object);
			object.Position = object.Position - multiplyUDim(UDim2.new(0, prevWidth, 0, 0), xAlign); -- - multiplyUDim(UDim2.new(0, 0, 0, maxHeight), yAlign);
		end;
		return maxHeight;
	end;
	
	local function drawLines(text)
		local objects = {};
		local yAlign = getAlignMultiplier(public().TextYAlignment);
		local lines, lastHeight = public().TextWrapped and wrapText(text) or getLines(text), 0;
		for _, line in pairs(lines) do
			lastHeight = lastHeight + drawLine(line, lastHeight, objects);
		end;
		for _, object in pairs(objects) do
			object.Position = object.Position + UDim2.new(0, 0, yAlign, lastHeight * yAlign + (yAlign == 1 and -lastHeight*2 or (yAlign == 0.5 and -lastHeight) or 0));
			--posFrom(object, object.Position, 0, yAlign);
		end;
	end;
	
	local function clearAllText()
		for _, item in pairs(currentText) do
			item:Destroy();
		end;
		currentText = {};
	end
	
	local function reDraw()
		if not customSize then settings.size = string.match(public().FontSize.Name, "%d+$"); end;
		clearAllText();
		drawLines(public().Text);
	end;
	
	local function subProp(prop, value)
		for _, item in pairs(public():GetChildren()) do
			if item:IsA("ImageLabel") then
				item[prop] = value
			end;
		end;
	end
	
	--/ Init
	
	init();
	
	--/ Public functions
	
	function this:Destroy()
		public():Destroy();
		self = nil;
	end;
	
	function this:UnSprite()
		for _, event in pairs(events) do
			event:disconnect();
		end;
		for _, prop in pairs(fakeProps) do
			prop:Destroy();
		end;
		clearAllText();
		public().TextTransparency = self.Transparency;
		self = nil;
	end
	
	function this:ClearAllChildren()
		for _, child in pairs(public():GetChildren()) do
			if not contains(currentText, child) and not contains(fakeProps, child) then
				child:Destroy();
			end;
		end;
	end;
	
	function this:GetChildren()
		local children = {};
		for _, child in pairs(public():GetChildren()) do
			if not contains(currentText, child) and not contains(fakeProps, child) then
				table.insert(children, child);
			end;
		end;
		return children;
	end;
	
	--/ Connections

	local font_updaters = customSize and {"FontPx", "FontName"} or {"FontName"};
	for _, prop in pairs(font_updaters) do
		-- These two practically do the same thing so I loop as opposed to paste code.
		table.insert(events, this[prop]:connect(function(newValue)
			local object = fonts:FindFirstChild(this.FontName.Value);
			if object then
				settings = fontSettings(require(object));
				settings.size = customSize and tostring(this.FontPx.Value) or string.match(public().FontSize.Name, "%d+$");
				reDraw();
			else
				error("Font was not found! Setting to previous font");
			end;
			local realProp = public():FindFirstChild(prop);
			if realProp and realProp.Value ~= newValue then
				realProp.Value = newValue;
			end;
		end));
	end;
	
	table.insert(events, this.Scale:connect(function(newScale)
		local realProp = public():FindFirstChild("Scale");
		if realProp and realProp.Value ~= newScale then
			realProp.Value = newScale;
		end;
		reDraw();
	end));

	local transOverflow = false;
	table.insert(events, public().Changed:connect(function(prop)
		if contains({"TextTransparency", "BackgroundTransparency"}, prop) and not transOverflow then
			transOverflow = true;
			if prop == "TextTransparency" then
				this.Transparency.Value = public()[prop];
			end;
			public()[prop] = 2;
		else
			transOverflow = false;
		end;
		reDraw();
	end));
	
	if makeFakeProps then
		for key, thing in pairs(this) do
			if not contains(hidden, key) and type(thing) ~= "function" then
				local class = type(thing.Value);
				local rep = string.gsub(class, "^.", string.upper(string.sub(class, 1, 1))).."Value";
				local item = Instance.new(rep, public());
				item.Name = key;
				item.Value = thing.Value;
				table.insert(events, item.Changed:connect(function(newValue)
					this[key].Value = newValue
				end));
				table.insert(fakeProps, item);
			end;
		end;
	end;
	
	if public().ClassName == "TextBox" then
		public().Focused:connect(function()
			if public().ClearTextOnFocus then
				public().Text = "";
			end;
		end);
	end;
	
	--/ Run

	reDraw();
	return public;
end;

------------------------------------------------------------------------------------------------------------------------------
--// Run

local create = {};
for _, class in pairs({"TextLabel", "TextBox", "TextButton", "TextReplace"}) do
	create[string.sub(class, 5)] = function(fontName, object, customSize, fakes)
		local fakes = fakes or true;
		return spriteObject(fontName, fakes, string.sub(class, 5) == "Replace" and object or class, customSize);
	end;
end;

return create
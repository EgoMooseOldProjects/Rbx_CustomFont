# Rbx_CustomFont - API documentation

## Creating a sprite text object

Calling this module will return a table that contains four functions:
- Label - *Used for creating a sprite text label.*
- Button - *Used for creating a sprite text button.*
- Box - *Used for creating a sprite text box.*
- Replace - *Used to replace a normal text object with a sprite text object.*

Label, Button and Box all require the same parameter, the font name you plan on using:

```Lua
local fonts = require(some_location.rbx_CustomFont);

local sprite_label = fonts.Label("Times New Roman");
local sprite_box = fonts.Box("Times New Roman");
local sprite_button = fonts.Button("Times New Roman");
```

Replace on the other hand requires two parameters, the font name and the object you're replacing:

```Lua
local label = Instance.new("TextLabel");
local fonts = require(some_location.rbx_CustomFont);

label = fonts.Replace("Times New Roman", label);
```

## Integration

Sprite text objects when used and called in scripts aren't actually objects. In reality they're tables pretending to be objects. This is a good thing though! With tables metamethods can be invoked and the module can make your experience almost seamless when working with sprite text objects. That means you can interact with a sprite text object like you would with any other text object.

```Lua
local fonts = require(some_location.rbx_CustomFont);

local label = fonts.Label("Times New Roman");
label.Text = "Hello world!";
label.Size = UDim2.new();
label.Position = UDim2.new(0.5, 0, 0.5, 0);
```

However, it's important to remember that in the above case "label" is in fact a table and not actually a physical object. Which means we can't treat it as such...

```Lua
local fonts = require(some_location.rbx_CustomFont);

local label = fonts.Label("Times New Roman");
print(label); -- table: XXXXXXXX
Instance.new("Part", label); -- Error!
```

Now you might be wondering, "Ego, sometimes I need to access the actual object!". Don't worry I thought of that. In order to call the actual physical object we simply call the sprite text object like a function

```Lua
local fonts = require(some_location.rbx_CustomFont);

local label = fonts.Label("Times New Roman");
print(label()); -- TextLabel
Instance.new("Part", label()); -- Success!
```

This also affects methods but more on that below.

## Methods

As I just mentioned above sprite text objects are tables. That means that if we want to call methods that are attached to their "real object" (meaning their physcial representaion) we have to normally call the sprite text object with brackets. Hoever, there are a few methods I've writtent that can be used directly on the sprite text object as they're better suited to the uniqueness of the object.

- :Destroy()
  - Simply put the only difference is that this will remove both the object and the wrapped data.
- :ClearAllChildren()
  - Since the lettering in the text is made up of multiple sprites and the custom properties are children of the text object, using the normal method would clear the text as well. This removes all children unrelated to the custom object.
- :GetChildren()
  - Similar to above this gathers all children unrelated to the custom object.
- :UnSprite()
  - Makes the object normal text again. 
  - NOTE: This method is still in testing and is subject to change. Use with caution.

Remember you can still use any of the default methods as long as you call them on the "real object".

## Properties

The sprite text object has a few custom properties attached to it. These can be access either as a physical value object that's a direct child of the real object or, as a key index in the sprite text object table.

- Scale
  - Stretches text and shrinks the text. Don't use if you want highquality text.
- FontPx
  - This property is a bit special. It controls the font size used. It's always available in table form but it will not be created as a physical value object if the font in question has all the sizes in the current FontSize enum list. In that case it will use the FontSize property of the real object.
- FontName
  - Changes the font being used by that sprite text object.

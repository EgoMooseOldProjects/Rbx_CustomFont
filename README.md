# Rbx_CustomFont

## Custom font system for Roblox

This is a module built for Roblox studio to allow the usage of any OpenType (.otf) or TrueType (.ttf) font in Roblox by converting them into spritesheets and then wrapping normal GUI text objects so they work with the spiresheets.

This allows you to greatly expand your UI design options.

![Example menu](http://i.imgur.com/qh6htfQ.png)

If you are interested in using Rbx_CustomFont in you game(s) then please view the [API page.](https://github.com/EgoMoose/Rbx_CustomFont/wiki/API)

I have included a few fonts that come with the module, but if you would like to create your own font you are going to need the latest [.NET Framework](https://msdn.microsoft.com/en-us/vstudio/aa496123.aspx) (sorry OSX users!). On that note if you have a mac and there is enough support (please send me a message if you are interested!), I may look into attempting to create a python version of the C# I have currently or I'll look into Mono. Otherwise, if you can run the .NET framework then you can read more about setting up your own font on the [setting up you own font wiki page.](https://github.com/EgoMoose/Rbx_CustomFont/wiki/Creating-your-own-font)

##License

This project uses [Sharpfont](https://github.com/Robmaister/SharpFont) which is licensed under the MIT license.

```
Copyright (c) 2012-2016 Robert Rouhani <robert.rouhani@gmail.com>

SharpFont based on Tao.FreeType, Copyright (c) 2003-2007 Tao Framework Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

This project also uses FreeType (which is needed for sharpfont to run).
It is redistributed under the FreeType License (FTL).

```
Portions of this software are copyright (c) 2016 The FreeType Project
(www.freetype.org). All rights reserved.
```

Finally, the project itself is licensed under the MIT license which can be read [here.](https://github.com/EgoMoose/Rbx_CustomFont/blob/master/LICENSE)

## Contributors

Thanks to [Gskartwii](https://github.com/Gskartwii) for getting the font builder running on 64-bit processes!

[AdarkTheCoder](https://github.com/AdarkTheCoder) made the GUI or whatever.

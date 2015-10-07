# Rbx_CustomFont

## Information

#### Description

Roblox's font system is severly lacking when it comes to choices of size and look of the font. The goal of Rbx_CustomFont is to remove those barriers by integrating spritesheets as seamlessly as possible into the common text objects used in Roblox.

#### What can it do?

Pretty much anything the current font system can do with the exclusion of:
- Text stroke
- [Background transparency](http://anaminus.tumblr.com/post/38580091687/on-the-order-of-roblox-guis)

Here is an example of what it can do:
![Screenshot](http://i.imgur.com/ubxLZAc.png)

## How do I use it?

#### Using the module

If you plan to simply use the module and have no intention of using any fonts other than those created by myself and/or other users then things will be very easy for you assuming you have any experience modifying/creating normal GUI objects in roblox.

Please read [this](https://github.com/EgoMoose/Rbx_CustomFont/wiki/API) for more information on API. 

#### Making your own font

Now if you plan on making your own font there are a few extra steps that you need to do on your own computer. This requires a few more resources on your end all can be found in these links:
- [Python](https://www.python.org/) - I use Python 3.4.3.
- [Pillow](https://github.com/python-pillow/Pillow) - An image library for python.
- [gdx-fontpack](https://github.com/mattdesl/gdx-fontpack) - A bitmap font packing tool (Requires Java).

For more on this process read [this](https://github.com/EgoMoose/Rbx_CustomFont/wiki/Making-your-own-font).

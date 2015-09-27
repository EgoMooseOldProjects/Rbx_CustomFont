# Rbx_CustomFont - Making your own font

## Installing

### Installing python

In order to create fonts we're going to need some python code to prepare our image and the data needed to navigate the image. Python is quite easy to install and can be downloaded from [this](https://www.python.org/) website.

I use Python 3.4.3. You're welcome to try to use any future versions of python but I have no idea if they will work or not and or if pillow will be updated for them.

### Installing pillow

In order for the python code to actually work we're going to need [pillow]() which is is an imaging library for python. This lets the code crop, copy, and create images which is needed when generating a font for Rbx_CustomFont usage.

**Steps:**

I personally have a windows computer so there instructions are written for windows users. If you have a Mac you can try to follow along but in this case google may be your friend.

1. Find the python installation folder and then within that the scripts folder (For me: "C:\Python34\Scripts")
2. Open CMD
3. Type "cd scripts_folder" (so in my case "cd C:\Python34\Scripts")
4. Type "pip install pillow"
5. Let it install
6. Done!

![screenshot](http://i.imgur.com/DGKKAnh.png)

### Installing gdx-fontpack

[gdx-fontpack](https://github.com/mattdesl/gdx-fontpack) is really easy to setup all you need is Java and then you can run the jar file like you would any other program. Regardless most information on dowloading and setup can be found on the gdx-fontpack github page.

## Making a font

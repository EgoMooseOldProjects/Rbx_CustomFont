# Python bmfont atlas share
# By: EgoMoose

# Description:
# This program takes png files with their respective .fnt files generated on a single atlas in the bmfont (.fnt) format
# and places multiple fonts (or sizes) onto texture atlases with equalized cell heights all while adjusting the .fnt file data.

# Note:
# I'm a self taught programmer so I'm sure this code will look awful and follow none of the industry standards for Python.
# None the less, it works, so there's that and I suppose for all intensive purposes that's all that matters.
# Feel free to edit, modify, or take whatever you want from this program.

# Tags

import pip;
pip.main(['install', "pillow"]);

import os;
import json;
import xml.etree.ElementTree as eleTree;
import PIL.Image as image;

font_xml, font_root, font_img, font_names, font_sizes = {}, {}, {}, [], {};
build_data = {};

# Functions

def build_dictionary():
	# Where the file is placed
	directory = os.path.dirname(os.path.abspath(__file__)); 
	for dirname, dirnames, filenames in os.walk(directory):
		for filename in filenames:
			if filename[len(filename)-4:] == ".fnt":
				font_names.append(filename);
				# Store as parsed xml, cause it saves us a step later
				font_xml[filename] = eleTree.parse(filename);
				font_root[filename] = font_xml[filename].getroot();
				font_img[filename] = image.open(directory + "\\" + font_root[filename][2][0].attrib["file"]);
				font_sizes[filename] = int(font_root[filename][0].attrib["size"]);
				
def get_lineHeight(font_name):
	heights = []
	for character in font_root[font_name][3]:
		heights.append(int(character.attrib["height"]) + int(character.attrib["yoffset"]));
	return max(heights);

def build_kerning(kerns):
	kerning = {};
	for kern in kerns:
		first, second = str(kern.attrib["first"]), str(kern.attrib["second"]);
		kerning[first] = kerning.get(first, {});
		kerning[first][second] = int(kern.attrib["amount"]);
	return kerning;

def build_sizes():
	for font_name in font_names:
		# Data and variable setup
		maxHeight, lHeight = get_lineHeight(font_name), int(font_root[font_name][1].attrib["lineHeight"])
		last_x, last_y = 0, 0;
		build_data[font_name] = {
			"characters" : {},
			"kerning" : build_kerning(font_root[font_name][4]),
			"info" : {
				"lineHeight" : maxHeight > lHeight and maxHeight or lHeight,
				"image" : image.new("RGBA", (1024, 1024)),
				"atlas" : 0,
				"total_y" : 0
			}
		};
		# Build image
		for character in font_root[font_name][3]:
			# Store data in a more accessible format
			data = {
				"x" : int(character.attrib["x"]),
				"y" : int(character.attrib["y"]),
				"width" : int(character.attrib["width"]),
				"height" : int(character.attrib["height"]),
				"xoffset" : int(character.attrib["xoffset"]),
				"yoffset" : int(character.attrib["yoffset"]),
				"xadvance" : int(character.attrib["xadvance"])
			};
			# Get crop
			char_region = (data["x"], data["y"], data["x"] + data["width"], data["y"] + data["height"]);
			char_crop = font_img[font_name].crop(char_region);
			# Calc crop
			if (1024 - last_x) < data["width"]:
				last_x = 0;
				last_y = last_y + build_data[font_name]["info"]["lineHeight"];
			# Place crop
			build_data[font_name]["info"]["image"].paste(char_crop, (last_x, last_y + data["yoffset"]));
			# Update render values
			data["x"] = last_x;
			data["y"] = last_y;
			data["height"] = build_data[font_name]["info"]["lineHeight"]
			del data["yoffset"]
			build_data[font_name]["characters"][character.attrib["id"]] = data;
			# Update for next crop
			last_x = last_x + data["width"];
		build_data[font_name]["info"]["total_y"] = last_y + build_data[font_name]["info"]["lineHeight"] + 10;
		build_data[font_name]["info"]["lineHeight"] = int(font_root[font_name][1].attrib["lineHeight"]);

def build_json(data):
	file = open("atlas_font.fnt",'w');
	file.write(json.dumps(data));
	file.close();

def build_atlases():
	# Prep the main table
	render_data = {
		"info" : {"name" : "", "sizes" : [], "atlases" : 0},
		"sizes" : {}
	};
	# Prep some variables
	atlases = [image.new("RGBA", (1024, 1024))];
	last_y = 0;
	for nefont in font_names:
		# Get order from largest to smallest
		font_name = max(font_sizes, key=font_sizes.get);
		size = font_sizes[font_name];
		font_sizes[font_name] = 0;
		# Build image
		if (1024 - last_y) < build_data[font_name]["info"]["total_y"]:
			atlases.append(image.new("RGBA", (1024, 1024)));
			last_y = 0;
		index = len(atlases) - 1;
		# Crop it
		font_region = (0, 0, 1024, build_data[font_name]["info"]["total_y"]);
		font_crop = build_data[font_name]["info"]["image"].crop(font_region);
		# Paste it
		atlases[index].paste(font_crop, (0, last_y));
		# Update build values
		del build_data[font_name]["info"]["image"];
		build_data[font_name]["info"]["atlas"] = len(atlases); #Lua starts from 1 in index so no need to start with 0 here
		for index in build_data[font_name]["characters"]:
			build_data[font_name]["characters"][index]["y"] = build_data[font_name]["characters"][index]["y"] + last_y;
		# Update render values
		render_data["info"]["name"] = font_root[font_name][0].attrib["face"];
		render_data["info"]["sizes"].append(size);
		render_data["info"]["atlases"] = len(atlases);
		render_data["sizes"][size] = build_data[font_name];
		# Update for next crop
		last_y = last_y + build_data[font_name]["info"]["total_y"];
	count = 0;
	for img in atlases:
		img.save("atlas_" + str(count) + ".png", "png");
		count = count + 1;
	# Build json!
	build_json(render_data);

def main():
	build_dictionary();
	build_sizes();
	build_atlases();
	# Finish!

# Run

main();
input("Press enter to continue");

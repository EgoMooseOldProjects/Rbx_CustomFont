using System;
using System.IO;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;
using SharpFont;

namespace CustomFontRenderingForm
{
	class SpriteSheet
	{
		private Face[] faces;
		private int[] sizes;
		private int[] defaultSizes = new int[] { 96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8 };

		private uint extraSize = 0;
		private int padX = 5, padY = 5;

		public string family;
		public string characters;

		public SpriteSheet(Face[] faces, string characters, int[] sizes, string family)
		{
			this.faces = faces;
			this.characters = characters;
			this.sizes = sizes;
			this.family = family;
		}

		private void getKernWidthHeight(Face face, FontInfo info, out int width, out int maxHeight, out int firstAdjust)
		{
			width = 0;
			maxHeight = 0;
			firstAdjust = 0;

			for (int i = 0; i < characters.Length; i++)
			{
				char character1 = characters[i];
				uint index1 = face.GetCharIndex(character1);

				face.LoadGlyph(index1, LoadFlags.Default, LoadTarget.Normal);
				GlyphMetrics metrics = face.Glyph.Metrics;

				int yoffset = metrics.VerticalAdvance.ToInt32() - metrics.HorizontalBearingY.ToInt32();
				int nheight = yoffset + metrics.Height.ToInt32();
				int height = metrics.Height.ToInt32();
				if (height > maxHeight)
				{
					maxHeight = height; //nheight;
					firstAdjust = yoffset;
				}

				for (int j = 0; j < characters.Length; j++)
				{
					char character2 = characters[j];
					uint index2 = face.GetCharIndex(character2);

					FTVector26Dot6 kern = face.GetKerning(index1, index2, KerningMode.Default);
					int kernX = kern.X.ToInt32();
					int kernY = kern.Y.ToInt32();
					if (kernX != 0 || kernY != 0)
					{
						info.addKerning(new KerningInfo(character1, character2, kernX, kernY));
					}
				}

				if (i + 1 == characters.Length)
				{
					width += metrics.Width.ToInt32() + metrics.HorizontalBearingX.ToInt32() + padX;
				}
				else
				{
					width += metrics.HorizontalAdvance.ToInt32() + padX;
				}
			}
		}

		private int renderCharacter(Face face, char character, int posX, int posY, int atlas, FontInfo info, Graphics graphics)
		{
			uint index = face.GetCharIndex(character);
			face.LoadGlyph(index, LoadFlags.Default, LoadTarget.Normal);
			face.Glyph.RenderGlyph(RenderMode.Normal);

			GlyphMetrics metrics = face.Glyph.Metrics;
			int width = metrics.Width.ToInt32() + metrics.HorizontalBearingX.ToInt32();
			int xAdvance = metrics.HorizontalAdvance.ToInt32();
			int yoffset = metrics.VerticalAdvance.ToInt32() - metrics.HorizontalBearingY.ToInt32();
			int charHeight = metrics.Height.ToInt32();

			if (face.Glyph.Bitmap.Width > 0)
			{
				FTBitmap ftbmp = face.Glyph.Bitmap;
				Bitmap copy = ftbmp.ToGdipBitmap(Color.White);
				graphics.DrawImageUnscaled(copy, posX + metrics.HorizontalBearingX.ToInt32(), posY);
			}

			info.addCharacter(new CharacterInfo(character, posX, posY, width, charHeight, xAdvance, yoffset, atlas));

			return width;
		}

		private string[] getStyles()
		{
			int i = 0;
			string[] styles = new string[faces.Length];
			foreach (Face face in faces)
			{
				styles[i] = "\"" + face.StyleName + "\"";
				i++;
			}
			return styles;
		}

		private string useEnums()
		{
			bool isenum = Enumerable.SequenceEqual(sizes, defaultSizes);
			return isenum ? "true" : "false";
		}

		private string prepOutputDataJSON()
		{
			string output = "{\n\t\"information\" : {\n";
			output += "\t\t\"family\" : \"" + family + "\",\n";
			output += "\t\t\"styles\" : [" + string.Join(", ", getStyles()) + "],\n";
			output += "\t\t\"sizes\" : [" + string.Join(", ", sizes) + "],\n";
			output += "\t\t\"useEnums\" : " + useEnums() + "\n\t},\n";
			output += "\t\"styles\" : {\n";
			return output;
		}

		private string prepOutputDataLua()
		{
			string output = "{\n\tinformation = {\n";
			output += "\t\tfamily = \"" + family + "\",\n";
			output += "\t\tstyles = {" + string.Join(", ", getStyles()) + "},\n";
			output += "\t\tsizes = {" + string.Join(", ", sizes) + "},\n";
			output += "\t\tuseEnums = " + useEnums() + "\n\t},\n";
			output += "\tstyles = {\n";
			return output;
		}

		public void generateAtlases(string outputPath, int maxWidth, int maxHeight, bool genJSON, bool genRBXLua)
		{
			int atlas = 0;
			int posX = 0, posY = 0;

			List<Bitmap> bitmaps = new List<Bitmap>();
			Dictionary<string, List<FontInfo>> infos = new Dictionary<string, List<FontInfo>>();

			Bitmap bitmap = new Bitmap(maxWidth, maxHeight, PixelFormat.Format32bppArgb);
			Graphics graphics = Graphics.FromImage(bitmap);
			graphics.Clear(Color.Transparent);

			foreach (Face face in faces)
			{
				infos[face.StyleName] = new List<FontInfo>();
				for (int i = 0; i < sizes.Length; i++)
				{
					int size = sizes[i];
					FontInfo info = new FontInfo(face.StyleName, size);

					int width = 0;
					int height = 0;
					int lineHeight = 0;
					int firstAdjust = 0;

					face.SetPixelSizes((uint)size + extraSize, (uint)size + extraSize);
					face.SetUnpatentedHinting(true);

					getKernWidthHeight(face, info, out width, out lineHeight, out firstAdjust);

					if (width > maxWidth)
					{
						int overlaps = (int)Math.Truncate((float)(width / maxWidth));
						width = maxWidth;
						height = (overlaps + 1) * (lineHeight + padY);
					}
					else
					{
						width = maxWidth;
						height = lineHeight + padY;
					}

					for (int j = 0; j < characters.Length; j++)
					{
						char character = characters[j];
						uint index = face.GetCharIndex(character);
						face.LoadGlyph(index, LoadFlags.Default, LoadTarget.Normal);
						face.Glyph.RenderGlyph(RenderMode.Normal);

						// case where the glyph won't fit horizontally
						if (posX + face.Glyph.Metrics.Width + face.Glyph.BitmapLeft + padX > width)
						{
							posX = 0;
							posY += lineHeight + padY;
						}
						// case where the glyph won't fit vertically
						if (posY > maxHeight - (lineHeight + padY))
						{
							bitmaps.Add(bitmap);

							bitmap = new Bitmap(maxWidth, maxHeight, PixelFormat.Format32bppArgb);
							graphics = Graphics.FromImage(bitmap);
							graphics.Clear(Color.Transparent);

							posX = 0;
							posY = 0;
							atlas++;
						}

						// draw the character
						posX += renderCharacter(face, characters[j], posX, posY, atlas, info, graphics) + padX;
					}

					// new font size means resetting some stuff
					posX = 0;
					posY += lineHeight + padY;

					// set the info line height and first adjust
					info.lineHeight = lineHeight;
					info.firstAdjust = firstAdjust;

					// add the info to the list
					infos[face.StyleName].Add(info);
				}
			}

			// add the current bitmap
			bitmaps.Add(bitmap);
			graphics.Dispose();

			// export
			int count = 0;
			foreach (Bitmap bmp in bitmaps)
			{
				count++;
				bmp.Save(outputPath + "\\" + family + "_" + count + ".png");
			}

			// export data
			if (genJSON)
			{
				int c = 0;
				string output = prepOutputDataJSON();
				foreach (Face face in faces)
				{
					c++;
					output += "\t\t\"" + face.StyleName + "\" : {\n";
					int c2 = 0;
					foreach (FontInfo info in infos[face.StyleName])
					{
						c2++;
						output += info.makeJSON("\t\t\t") + (c2 < infos[face.StyleName].Count ? "," : "") + "\n";
					}
					output += "\t\t}" + (c < faces.Length ? "," : "") + "\n";
				}
				output += "\t}\n}";
				// write json file
				File.WriteAllText(outputPath + "\\" + family + ".json", output);
			}

			if (genRBXLua)
			{
				int c = 0;
				string output = prepOutputDataLua();
				foreach (Face face in faces)
				{
					c++;
					output += "\t\t[\"" + face.StyleName + "\"] = {\n";
					int c2 = 0;
					foreach (FontInfo info in infos[face.StyleName])
					{
						c2++;
						output += info.makeLua("\t\t\t") + (c2 < infos[face.StyleName].Count ? "," : "") + "\n";
					}
					output += "\t\t}" + (c < faces.Length ? "," : "") + "\n";
				}
				output += "\t}\n}";

				// Setup module
				string header = "--[[\n\t@Font " + family + "\n";
				header += "\t@Sizes {" + string.Join(", ", sizes) + "}\n";
				header += "\t@Author N/A\n";
				header += "\t@Link N/A\n--]]\n\n";

				header += "local module = {}\n\n";
				header += "module.atlases = {\n";

				for (int i = 1; i <= count; i++)
				{
					header += "\t[" + i + "] = \"rbxassetid://\";\n";
				}

				header += "};\n\nmodule.font = " + output;
				header += "\n\nreturn module";

				// write Lua file
				File.WriteAllText(outputPath + "\\" + family + ".lua", header);
			}
		}
	}
}
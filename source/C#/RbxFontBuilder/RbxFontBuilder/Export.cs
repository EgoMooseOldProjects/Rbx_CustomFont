using System;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;
using SharpFont;

namespace RbxFontBuilder
{
	class Export
	{
		private int maxWidth;
		private int maxHeight;
		private List<int> sizes;
		private List<Face> faces;
		public string family;
		public string characters;

		public Export(int maxWidth, int maxHeight, List<int> sizes, List<Face> faces, string family, string characters)
		{
			this.maxWidth = maxWidth;
			this.maxHeight = maxHeight;
			this.sizes = sizes;
			this.faces = faces;
			this.family = family;
			this.characters = characters;
		}

		private List<string> getStyles()
		{
			List<string> styles = new List<string>();
			foreach (Face face in faces)
			{
				styles.Add("\"" + face.StyleName + "\"");
			}
			return styles;
		}

		private Boolean listEquals(List<int> list1, List<int> list2)
		{
			foreach (int t in list1) if (!list2.Contains(t)) return false;
			foreach (int t in list2) if (!list1.Contains(t)) return false;

			return true;
		}

		private string useEnums()
		{
			List<int> enumSizes = new List<int> { 96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8 };
			if (listEquals(enumSizes, sizes) == true)
			{
				return "true";
			}
			return "false";
        }

		public void ExportFont(string outputPath)
		{
			// should this be user input?
			int padX = 5;
			int padY = 5;

			int atlas = 0;
			float posX = 0;
			float posY = 0;

			List<Bitmap> bitmaps = new List<Bitmap>();
			Dictionary<string, List<Info>> infos = new Dictionary<string, List<Info>>();

			Bitmap bitmap = new Bitmap(maxWidth, maxHeight, PixelFormat.Format32bppArgb);
			Graphics graphics = Graphics.FromImage(bitmap);
			graphics.Clear(Color.Transparent);

			string output = "local font = {\n\tinformation = {\n";
			output += "\t\tfamily = \"" + family + "\";\n";
			output += "\t\tstyles = {" + string.Join(", ", getStyles()) + "};\n";
			output += "\t\tsizes = {" + string.Join(", ", sizes) + "};\n";
			output += "\t\tuseEnums = " + useEnums() + ";\n\t};\n";

			output += "\tstyles = {\n";

			foreach (Face face in faces)
			{
				infos[face.StyleName] = new List<Info>();
				output += "\t\t[\"" + face.StyleName + "\"] = {\n";

				foreach (int size in sizes)
				{
					Info info = new Info(face.StyleName, size);

					int lineAdvance = 0;
					int firstAdjust = 0;

					float width = 0;
					float height = 0;
					float lineHeight = 0;

					face.SetCharSize(size * 96 / 72, 0, 96, 96);

					for (int i = 0; i < characters.Length; i++)
					{
						char c = characters[i];
						uint index = face.GetCharIndex(c);
						face.LoadGlyph(index, LoadFlags.Default, LoadTarget.Normal);

						width += (float)face.Glyph.Metrics.HorizontalAdvance;

						if (face.Glyph.Metrics.Height > lineHeight)
						{
							// Get extra space and subtract it from first line draw?
							firstAdjust = face.Glyph.Metrics.VerticalAdvance.ToInt32() - face.Glyph.Metrics.HorizontalBearingY.ToInt32();
							lineHeight = (float)face.Glyph.Metrics.Height;
						}

						for (int j = 0; j < characters.Length; j++)
						{
							char k = characters[j];
							uint index2 = face.GetCharIndex(k);

							FTVector26Dot6 kern = face.GetKerning(index, index2, KerningMode.Default);
							int kernx = kern.X.ToInt32();
							int kerny = kern.Y.ToInt32();

							if (kernx != 0 | kerny != 0)
							{
								info.addKerning(c, new Info.kerningInfo(k, kernx, kerny));
							}
						}
					}

					if (width > maxWidth)
					{
						int overlaps = (int)Math.Truncate(width / maxWidth);
						width = maxWidth;
						height = ((overlaps + 1) * (lineHeight + padY));
					}
					else
					{
						width = maxWidth;
						height = lineHeight + padY;
					}

					face.SetUnpatentedHinting(true);

					for (int i = 0; i < characters.Length; i++)
					{
						char c = characters[i];
						uint index = face.GetCharIndex(c);
						face.LoadGlyph(index, LoadFlags.Default, LoadTarget.Normal);
						face.Glyph.RenderGlyph(RenderMode.Normal);

						if (c == ' ')
						{
							posX += (float)face.Glyph.Metrics.HorizontalAdvance + (float)padX;
							info.addCharacter(c, new Info.characterInfo(c, face.Glyph.Metrics.HorizontalAdvance.ToInt32(), 0, 0, 0, 0, 0, atlas));
							continue;
						}

						if (posX + face.Glyph.Metrics.Width + face.Glyph.BitmapLeft + padX > width)
						{
							posX = 0;
							posY += lineHeight + padY;
						}

						if (posY > (maxHeight - (lineHeight + padY)))
						{
							bitmaps.Add(bitmap);
							bitmap = new Bitmap(maxWidth, maxHeight, PixelFormat.Format32bppArgb);
							graphics = Graphics.FromImage(bitmap);
							graphics.Clear(Color.Transparent);

							posX = 0;
							posY = 0;
							atlas += 1;
						}

						int xadvance = face.Glyph.Metrics.HorizontalAdvance.ToInt32();
						int imgWidth = face.Glyph.Metrics.Width.ToInt32();
						int imgHeight = face.Glyph.Metrics.Height.ToInt32();
						int imgX = (int)posX;
						int imgY = (int)posY;
						int yoffset = face.Glyph.Metrics.VerticalAdvance.ToInt32() - face.Glyph.Metrics.HorizontalBearingY.ToInt32();

						// some fonts that might be missing characters will leave open spaces because their bitmap is empty.
						if (face.Glyph.Bitmap.Width > 0)
						{
							FTBitmap ftbmp = face.Glyph.Bitmap;
							Bitmap copy = ftbmp.ToGdipBitmap(Color.White);
							graphics.DrawImageUnscaled(copy, imgX, imgY);
						}
                        
						info.addCharacter(c, new Info.characterInfo(c, xadvance, imgX, imgY, yoffset, imgWidth, imgHeight, atlas));

						posX += (float)imgWidth + (float)padX;
						lineAdvance = face.Glyph.Metrics.VerticalAdvance.ToInt32();
                    }

					posX = 0;
					posY += lineHeight + padY;

					info.lineHeight = lineAdvance;
					info.firstAdjust = firstAdjust;

					infos[face.StyleName].Add(info);
					output += info.buildLuaString("\t\t\t") + "\n";
				}
				output += "\t\t};\n";
			}
			output += "\t};\n};\n";

			bitmaps.Add(bitmap);
			graphics.Dispose();

			// create images
			int count = 0;
			foreach (Bitmap bmp in bitmaps)
			{
				count += 1;
				bmp.Save(outputPath + "\\" + family + "_" + count + ".png");
			}

			File.WriteAllText(outputPath + "\\" + family + ".lua", output);
		}
	}
}

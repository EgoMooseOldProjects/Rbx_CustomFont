using System.Text;
using System.Collections.Generic;

namespace RbxFontBuilder
{
	class Info
	{
		public string fontName;
		public int fontSize;
		public Dictionary<char, characterInfo> characters;
		public Dictionary<char, Dictionary<char, kerningInfo>> kerning;

		public Info(string fontName, int fontSize)
		{
			this.fontName = fontName;
			this.fontSize = fontSize;

			this.characters = new Dictionary<char, characterInfo>();
			this.kerning = new Dictionary<char, Dictionary<char, kerningInfo>>();
        }

		public void addCharacter(char character, characterInfo charInfo)
		{
			characters.Add(character, charInfo);
		}

		public void addKerning(char character, kerningInfo kernInfo)
		{
			if (kerning.ContainsKey(character))
			{
				kerning[character].Add(kernInfo.character, kernInfo);
            }
			else
			{
				kerning.Add(character, new Dictionary<char, kerningInfo>());
				kerning[character].Add(kernInfo.character, kernInfo);
			}
		}

		public string buildLuaString(string indent)
		{
			StringBuilder luaString = new StringBuilder(indent + "[" + fontSize + "] = {\n" + indent + "\t" + "characters = {\n");
			string indent2 = indent + "\t\t";

			// build characters
			foreach (KeyValuePair<char, characterInfo> kvp in characters)
			{
				characterInfo cinfo = kvp.Value;

				luaString.Append(indent2 + "[" + (byte)cinfo.character + "] = {");
				luaString.AppendFormat("xadvance = {0}, ", cinfo.xadvance);
				luaString.AppendFormat("x = {0}, ", cinfo.x);
				luaString.AppendFormat("y = {0}, ", cinfo.y);
				luaString.AppendFormat("width = {0}, ", cinfo.width);
				luaString.AppendFormat("height = {0}, ", cinfo.height);
				luaString.AppendFormat("atlas = {0}", cinfo.atlas);

				luaString.Append("};").AppendLine();
			}

			luaString.Append(indent + "\t};\n" + indent + "\tkerning = {\n");

			// build kerning
			foreach (KeyValuePair<char, Dictionary<char, kerningInfo>> kvp in kerning)
			{
				luaString.Append(indent2 + "[" + (byte)kvp.Key + "] = {\n");

				foreach (KeyValuePair<char, kerningInfo> kvp2 in kvp.Value)
				{
					luaString.Append(indent2 + "\t[" + (byte)kvp2.Key + "] = {");
					luaString.AppendFormat("kernx = {0}, ", kvp2.Value.kernx);
					luaString.AppendFormat("kerny = {0}", kvp2.Value.kerny);
					luaString.Append("};").AppendLine();
				}
				
				luaString.Append(indent2 + "};").AppendLine();
			}

			luaString.Append(indent + "\t" + "};\n" + indent + "};");

			return luaString.ToString();
		}

		public sealed class characterInfo
		{
			public char character;
			public int xadvance, x, y, width, height, atlas;

			public characterInfo(char character, int xadvance, int x, int y, int width, int height, int atlas)
			{
				this.character = character;
				this.xadvance = xadvance;
				this.x = x;
				this.y = y;
				this.width = width;
				this.height = height;
				this.atlas = atlas;
			}
		}

		public sealed class kerningInfo
		{
			public char character;
			public int kernx, kerny;

			public kerningInfo(char character, int kernx, int kerny)
			{
				this.character = character;
				this.kernx = kernx;
				this.kerny = kerny;
			}
		}
	}
}

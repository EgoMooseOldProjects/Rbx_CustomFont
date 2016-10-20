using System;
using System.Collections.Generic;
using System.Reflection;

namespace CustomFontRenderingForm
{
	class FontInfo
	{
		public string fontName;
		public int fontSize, lineHeight, firstAdjust;

		public List<CharacterInfo> characters = new List<CharacterInfo>();
		public Dictionary<char, Dictionary<char, KerningInfo>> kerning = new Dictionary<char, Dictionary<char, KerningInfo>>();

		public FontInfo(string fontName, int fontSize)
		{
			this.fontName = fontName;
			this.fontSize = fontSize;
		}

		public void addCharacter(CharacterInfo info)
		{
			characters.Add(info);
		}

		public void addKerning(KerningInfo info)
		{
			if (!kerning.ContainsKey(info.character1))
			{
				kerning[info.character1] = new Dictionary<char, KerningInfo>();
			}
			kerning[info.character1][info.character2] = info;
		}

		public string makeJSON(string indent)
		{
			string indent2 = indent + "\t";
			string indent3 = indent + "\t\t";
			string indent4 = indent + "\t\t\t";

			string json = indent + "\"" + fontSize + "\" : {\n"
				+ indent2 + "\"lineHeight\" : " + lineHeight + ",\n"
				+ indent2 + "\"firstAdjust\" : " + firstAdjust + ",\n"
				+ indent2 + "\"characters\" : {\n";

			// Reflection is pretty dope!
			int count = 0;
			foreach (CharacterInfo info in characters)
			{
				count++;
				string line = indent3 + "\"" + (byte)info.character + "\" : { ";
				FieldInfo[] fields = typeof(CharacterInfo).GetFields();
				int count2 = 0;
				for (int i = 0; i < fields.Length; i++)
				{
					FieldInfo f = fields[i];
					string prop = f.Name;
					if (prop != "character")
					{
						count2++;
						object value = f.GetValue(info);
						line += "\"" + prop + "\" : " + value + (count2 < (fields.Length - 1) ? ", " : " ");
					}
				}
				line += "}" + (count < characters.Count ? ",\n" : "\n");
				json += line;
			}
			json += indent2 + "},\n" + indent2 + "\"kerning\" : {\n";

			count = 0;
			foreach (KeyValuePair<char, Dictionary<char, KerningInfo>> kvp in kerning)
			{
				count++;
				int count2 = 0;
				string line = indent3 + "\"" + (byte)kvp.Key + "\" : {\n";
				foreach (KeyValuePair<char, KerningInfo> kvp2 in kvp.Value)
				{
					count2++;
					KerningInfo info = kvp2.Value;
					line += indent4 + "\"" + (byte)info.character2 + "\" : { "
						+ "\"kernX\" : " + info.kernX
						+ ", \"kernY\" : " + info.kernY + " }"
						+ (count2 < kvp.Value.Count ? "," : "") + "\n";
				}
				line += indent3 + "}" + (count < kerning.Count ? "," : "") + "\n";
				json += line;
			}
			json += indent2 + "}\n" + indent + "}";
			return json;
		}

		public string makeLua(string indent)
		{
			string indent2 = indent + "\t";
			string indent3 = indent + "\t\t";
			string indent4 = indent + "\t\t\t";

			string json = indent + "[\"" + fontSize + "\"] = {\n"
				+ indent2 + "lineHeight = " + lineHeight + ",\n"
				+ indent2 + "firstAdjust = " + firstAdjust + ",\n"
				+ indent2 + "characters = {\n";

			// Reflection is pretty dope!
			int count = 0;
			foreach (CharacterInfo info in characters)
			{
				count++;
				string line = indent3 + "[\"" + (byte)info.character + "\"] = { ";
				FieldInfo[] fields = typeof(CharacterInfo).GetFields();
				int count2 = 0;
				for (int i = 0; i < fields.Length; i++)
				{
					FieldInfo f = fields[i];
					string prop = f.Name;
					if (prop != "character")
					{
						count2++;
						object value = f.GetValue(info);
						line += prop + " = " + value + (count2 < (fields.Length - 1) ? ", " : " ");
					}
				}
				line += "}" + (count < characters.Count ? ",\n" : "\n");
				json += line;
			}
			json += indent2 + "},\n" + indent2 + "kerning = {\n";

			count = 0;
			foreach (KeyValuePair<char, Dictionary<char, KerningInfo>> kvp in kerning)
			{
				count++;
				int count2 = 0;
				string line = indent3 + "[\"" + (byte)kvp.Key + "\"] = {\n";
				foreach (KeyValuePair<char, KerningInfo> kvp2 in kvp.Value)
				{
					count2++;
					KerningInfo info = kvp2.Value;
					line += indent4 + "[\"" + (byte)info.character2 + "\"] = { "
						+ "kernX = " + info.kernX
						+ ", kernY = " + info.kernY + " }"
						+ (count2 < kvp.Value.Count ? "," : "") + "\n";
				}
				line += indent3 + "}" + (count < kerning.Count ? "," : "") + "\n";
				json += line;
			}
			json += indent2 + "}\n" + indent + "}";
			return json;
		}
	}

	class CharacterInfo
	{
		public char character;
		public int x, y, width, height, xadvance, yoffset, atlas;

		public CharacterInfo(char character, int x, int y, int width, int height, int xadvance, int yoffset, int atlas)
		{
			this.character = character;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.xadvance = xadvance;
			this.yoffset = yoffset;
			this.atlas = atlas;
		}
	}

	class KerningInfo
	{
		public char character1, character2;
		public int kernX, kernY;

		public KerningInfo(char character1, char character2, int kernX, int kernY)
		{
			this.character1 = character1;
			this.character2 = character2;
			this.kernX = kernX;
			this.kernY = kernY;
		}
	}
}

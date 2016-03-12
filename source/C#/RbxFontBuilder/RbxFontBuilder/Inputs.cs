using System;
using System.Windows.Forms;
using System.Collections.Generic;

namespace RbxFontBuilder
{
	class Inputs
	{

		public static string[] selectFiles()
		{
			OpenFileDialog fd = new OpenFileDialog();

			fd.Filter = "TrueType font (.ttf)|*.ttf|OpenType font (.otf)|*.otf|All Files (*.*)|*.*";
			fd.FilterIndex = 1;
			fd.Multiselect = true;

			if (fd.ShowDialog() == DialogResult.OK)
			{
				return fd.FileNames;
			}
			return new string[] { };
		}

		public static int numberInput(string msg, int backup)
		{
			Console.Write(msg);

			int number;
			bool result = int.TryParse(Console.ReadLine(), out number);
			if (result) { return number; }
			return backup;
		}

		public static string characterSet(string msg)
		{
			Console.Write(msg);

			string characters = Console.ReadLine();
			if (characters.Length > 0)
			{
				return characters;
			}
			// Generate a list otherwise
			for (int i = 32; i < 126; i++)
			{
				characters += (char)i;
			}
			return characters;
		}

		public static List<int> sizeInput(string msg)
		{
			Console.Write(msg);

			List<int> sizes = new List<int> { };
			string[] strSizes = Console.ReadLine().Split(',');

			foreach (string str in strSizes)
			{
				int number;
				bool result = int.TryParse(str, out number);
				if (result) { sizes.Add(number); }
			}

			if (sizes.Count == 0)
			{
				// Apply default sizes assuming nothing was entered (or parsed)
				sizes = new List<int> { 96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8 };
			}

			return sizes;
		}
	}
}

using System;
using System.Collections.Generic;
using SharpFont;

namespace RbxFontBuilder
{
	class Program
	{
		public static Library library = new Library();

		[STAThread]
		static void Main(string[] args)
		{
			// Console.WriteLine(Environment.Is64BitProcess);
			Console.WriteLine("Leave values empty to use default.\n");

			int width = Inputs.numberInput("Please enter max width (default: 1024): ", 1024);
			int height = Inputs.numberInput("Please enter max height (default: 1024): ", 1024);
			List<int> sizes = Inputs.sizeInput("Please enter sizes (default: studio enums): ");
			string characters = Inputs.characterSet("Please enter character list (default: bytes 32-125): ");

			string outputPath = "";
			Dictionary<string, List<Face>> families = new Dictionary<string, List<Face>>();

			foreach (string path in Inputs.selectFiles())
			{
				Face face = new Face(library, path);

				if (families.ContainsKey(face.FamilyName))
				{
					families[face.FamilyName].Add(face);
				}
				else
				{
					families[face.FamilyName] = new List<Face> { face };
				}

				outputPath = System.IO.Directory.GetParent(path).FullName;
			}

			foreach (KeyValuePair<string, List<Face>> kvp in families)
			{
				Export export = new Export(width, height, sizes, kvp.Value, kvp.Key, characters);
				export.ExportFont(outputPath);
				Console.WriteLine("Family: {0} was successfully generated!", export.family);
			}

			// allow user to read console
			Console.WriteLine("\nPress enter to continue");
			Console.ReadLine();
		}
	}
}

using System;
using System.Linq;
using System.Windows.Forms;
using System.Collections.Generic;
using System.Diagnostics;
using SharpFont;

namespace CustomFontRenderingForm
{
	public partial class InputGUI : Form
	{
		public static Library library = new Library();

		private string[] fileNames;
		private int[] sizes = new int[] { 96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8 };
		private int[] sizesdefault = new int[] { 96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8 };

		private OpenFileDialog fontSelection = new OpenFileDialog();
		private FolderBrowserDialog outputSelection = new FolderBrowserDialog();

		public InputGUI()
		{
			InitializeComponent();
			sizeBox.Text = string.Join(", ", sizes);
			outputBox.Text = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
		}

		// Private methods

		private void handleResolutions(TextBox child, string name, string backup)
		{
			int value = 0;
			if (!int.TryParse(child.Text, out value) | !(value > 0))
			{
				MessageBox.Show(name + " must be a positive Integer!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
				child.Text = backup;
			}
		}

		// Events

		private void fontButton_Click(object sender, EventArgs e)
		{
			fontSelection.Filter = "TrueType font (.ttf)|*.ttf|OpenType font (.otf)|*.otf";
			fontSelection.FilterIndex = 1;
			fontSelection.Multiselect = true;

			if (fontSelection.ShowDialog() == DialogResult.OK)
			{
				fileNames = fontSelection.FileNames;
			}
			else
			{
				fileNames = new string[] { };
			}

			fontBox.Text = string.Join(", ", fileNames);
			Debug.WriteLine(fontBox.Text);
		}

		private void outputButton_Click(object sender, EventArgs e)
		{
			if (outputSelection.ShowDialog() == DialogResult.OK)
			{
				outputBox.Text = outputSelection.SelectedPath;
			}
		}
		
		private void widthBox_Leave(object sender, EventArgs e)
		{
			handleResolutions(widthBox, "Width", "1024");
		}

		private void heightBox_Leave(object sender, EventArgs e)
		{
			handleResolutions(heightBox, "Height", "1024");
		}

		private void sizeBox_Leave(object sender, EventArgs e)
		{
			string[] stringSizes = sizeBox.Text.Split(',');
			sizeBox.Text = string.Empty;

			List<int> sizeList = new List<int>();
			foreach (string size in stringSizes)
			{
				int number;
				bool result = int.TryParse(size, out number);
				if (result && !sizeList.Contains(number) && number > 0) sizeList.Add(number);
			}

			if (sizeList.Count > 0)
			{
				sizeList.Sort();
				sizeList.Reverse();
				sizes = sizeList.ToArray();
			}
			else
			{
				sizes = sizesdefault;
			}
			sizeBox.Text = string.Join(", ", sizes);
		}

		private void characterBox_Leave(object sender, EventArgs e)
		{
			characterBox.Text = string.Concat(characterBox.Text.OrderBy(c => c).Distinct());
		}

		private void generateButton_Click(object sender, EventArgs e)
		{
			int count = 0;

			int w = 0, h = 0;
			int.TryParse(widthBox.Text, out w);
			int.TryParse(heightBox.Text, out h);

			string characters = characterBox.Text;
			if (characters.Length == 0)
			{
				for (int i = 32; i <= 126; i++)
				{
					characters += (char)i;
				}
			}

			string outputPath = string.Empty;
			if (System.IO.Directory.Exists(outputSelection.SelectedPath))
			{
				outputPath = outputSelection.SelectedPath;
			}
			else
			{
				outputPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
			}

			if (fileNames != null)
			{
				Dictionary<string, List<Face>> families = new Dictionary<string, List<Face>>();
				foreach (string path in fileNames)
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
				}

				// generate
				foreach (KeyValuePair<string, List<Face>> kvp in families)
				{
					SpriteSheet sprites = new SpriteSheet(kvp.Value.ToArray(), characters, sizes, kvp.Key);
					sprites.generateAtlases(outputPath, w, h, JSONCheckBox.Checked, RBXLuaCheckBox.Checked);
					count++;
				}

				outputMessage.Text = "Generated " + count + " font" + (count == 1 ? "" : "s") + "!";
			}
		}

		private void outputMessage_Click(object sender, EventArgs e)
		{
			outputMessage.Text = string.Empty;
		}
	}
}

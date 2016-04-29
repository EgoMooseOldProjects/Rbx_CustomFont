using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using SharpFont;

namespace RbxFontBuilder {
	public partial class InputGui : Form {
		public static Library library = new Library();
		List<int> sizeList = new List<int> { 96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8 };
		string[] fileNames;

		public InputGui() {
			InitializeComponent();
			outFolderTextbox.Text = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
		}

		// File Dialogs
		private void chooseFonts_Click(object sender, EventArgs e) {
			fontSelection.Filter = "TrueType font (.ttf)|*.ttf|OpenType font (.otf)|*.otf";
			fontSelection.FilterIndex = 1;
			fontSelection.Multiselect = true;

			if (fontSelection.ShowDialog() == DialogResult.OK) {
				fileNames = fontSelection.FileNames;
			} else {
				fileNames = new string[] { };
			}

			selectedFonts.Text = string.Concat(fileNames);
		}

		private void chooseOutput_Click(object sender, EventArgs e) {
			if (outputFolder.ShowDialog() == DialogResult.OK) {
				outFolderTextbox.Text = outputFolder.SelectedPath;
			}
		}

		// Generate Button
		private void generate_Click(object sender, EventArgs e) {
			int count = 0;

			int w = 0;
			int h = 0;
			int.TryParse(width.Text, out w);
			int.TryParse(height.Text, out h);
			// sizeList (handled below, because input validation at the same time)
			string characters = charset.Text;
			if (characters.Length == 0) {
				for (int i = 32; i <= 126; i++) {
					characters += (char)i;
				}
			}

			List<string> handled = new List<string> { };

			string outputPath = string.Empty;
			if (System.IO.Directory.Exists(outputFolder.SelectedPath)) {
				outputPath = outputFolder.SelectedPath;
			} else {
				outputPath = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
			}

			Dictionary<string, List<Face>> families = new Dictionary<string, List<Face>>();
			foreach (string path in fileNames) {
				Face face = new Face(library, path);

				if (families.ContainsKey(face.FamilyName)) {
					families[face.FamilyName].Add(face);
				} else {
					// Check if files for a given name already exist, prompt user.
					uint min = 0;
					if (System.IO.Directory.GetFiles(outputPath, face.FamilyName + ".otf", System.IO.SearchOption.TopDirectoryOnly).Length > 0) {
						min = 1;
					} else if (System.IO.Directory.GetFiles(outputPath, face.FamilyName + ".ttf", System.IO.SearchOption.TopDirectoryOnly).Length > 0) {
						min = 1;
					} // Gross, but the line is super duper long, and this is necessary.

					if (!handled.Contains(face.FamilyName)) {
						if (System.IO.Directory.GetFiles(outputPath, face.FamilyName + "*" , System.IO.SearchOption.TopDirectoryOnly).Length > min) {
							if (MessageBox.Show("Files for the font '" + face.FamilyName + "' already exist in the output directory.\nOverwrite them?", "Warning", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes) {
								families[face.FamilyName] = new List<Face> { face };
							}
							handled.Add(face.FamilyName);
						} else {
							families[face.FamilyName] = new List<Face> { face };
						}
					}
				}

				foreach (KeyValuePair<string, List<Face>> kvp in families) {
					Export export = new Export(w, h, sizeList, kvp.Value, kvp.Key, characters);
					export.ExportFont(outputPath);
					count++;
				}
			}

			outputText.Text = "Generated " + count + " font" + (count==1?"":"s") + "!";
		}

		// Input validation
		bool warnSmallShown = false;
		bool warnLargeShown = false;

		string oldWidth = "1024";
		private void width_Leave(object sender, EventArgs e) {
			uint val = 0;
			if (uint.TryParse(width.Text, out val)) {
				if (val > 1024) {
					if (!warnLargeShown) {
						MessageBox.Show("ROBLOX Images can be at most 1024x1024px", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
						warnLargeShown = true;
					}
				} else if (val < 100) {
					if (!warnSmallShown) {
						MessageBox.Show("Fonts may not render correctly at low resolutions", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
						warnSmallShown = true;
					}
				}
				oldWidth = width.Text;
			} else {
				MessageBox.Show("Width must be a positive Integer!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
				width.Text = oldWidth;
			}
		}

		string oldHeight = "1024";
		private void height_Leave(object sender, EventArgs e) {
			uint val = 0;
			if (uint.TryParse(height.Text, out val)) {
				if (val > 1024) {
					if (!warnLargeShown) {
						MessageBox.Show("ROBLOX Images can be at most 1024x1024px", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
						warnLargeShown = true;
					}
				} else if (val < 100) {
					if (!warnSmallShown) {
						MessageBox.Show("Fonts may not render correctly at low resolutions", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
						warnSmallShown = true;
					}
				}
				oldHeight = height.Text;
			} else {
				MessageBox.Show("Height must be a positive Integer!", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
				height.Text = oldHeight;
			}
		}
		
		private void charset_Leave(object sender, EventArgs e) {
			// TODO: Handle formatted input for bytecodes. (E.x: bytes(0-22, 25-255))
			charset.Text = (string) string.Concat(charset.Text.OrderBy(c => c).Distinct());
		}

		private void sizes_Leave(object sender, EventArgs e) {
			string[] strSizes = sizes.Text.Split(',');
			sizes.Text = string.Empty;

			sizeList.Clear();
			foreach (string str in strSizes) {
				int number;
				bool result = int.TryParse(str, out number);
				if (result && !sizeList.Contains(number) && number > 0) { sizeList.Add(number); }
			}

			if (sizeList.Count() > 0) {
				sizeList.Sort();
				sizeList.Reverse(); // Biggest first
				sizes.Text = string.Join(", ", sizeList);
			} else {
				sizeList = new List<int> { 96, 60, 48, 42, 36, 32, 28, 24, 18, 14, 12, 11, 10, 9, 8 };
				sizes.Text = string.Empty;
			}
		}

		// Output text clears on click.
		private void outputText_Click(object sender, EventArgs e) {
			outputText.Text = string.Empty;
		}

		private void InputGui_Load(object sender, EventArgs e) {}

		bool hasWarned = false;
		private void resolution_TextChanged(object sender, EventArgs e) {
			if (!hasWarned) {
				MessageBox.Show("It is suggested to leave height and width values at their defaults (1024)", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
				hasWarned = true;
			}
		}
	}
}

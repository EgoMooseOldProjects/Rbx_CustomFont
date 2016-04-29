namespace RbxFontBuilder {
	partial class InputGui {
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing) {
			if (disposing && (components != null)) {
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent() {
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(InputGui));
			this.chooseOutput = new System.Windows.Forms.Button();
			this.chooseFonts = new System.Windows.Forms.Button();
			this.label7 = new System.Windows.Forms.Label();
			this.label8 = new System.Windows.Forms.Label();
			this.sizes = new System.Windows.Forms.TextBox();
			this.label6 = new System.Windows.Forms.Label();
			this.label5 = new System.Windows.Forms.Label();
			this.charset = new System.Windows.Forms.TextBox();
			this.label4 = new System.Windows.Forms.Label();
			this.label3 = new System.Windows.Forms.Label();
			this.height = new System.Windows.Forms.TextBox();
			this.outFolderTextbox = new System.Windows.Forms.TextBox();
			this.label2 = new System.Windows.Forms.Label();
			this.selectedFonts = new System.Windows.Forms.TextBox();
			this.label1 = new System.Windows.Forms.Label();
			this.outputFolder = new System.Windows.Forms.FolderBrowserDialog();
			this.width = new System.Windows.Forms.TextBox();
			this.generate = new System.Windows.Forms.Button();
			this.outputText = new System.Windows.Forms.Label();
			this.fontSelection = new System.Windows.Forms.OpenFileDialog();
			this.SuspendLayout();
			// 
			// chooseOutput
			// 
			this.chooseOutput.Location = new System.Drawing.Point(347, 34);
			this.chooseOutput.Name = "chooseOutput";
			this.chooseOutput.Size = new System.Drawing.Size(75, 23);
			this.chooseOutput.TabIndex = 2;
			this.chooseOutput.Text = "Choose";
			this.chooseOutput.UseVisualStyleBackColor = true;
			this.chooseOutput.Click += new System.EventHandler(this.chooseOutput_Click);
			// 
			// chooseFonts
			// 
			this.chooseFonts.Location = new System.Drawing.Point(347, 8);
			this.chooseFonts.Name = "chooseFonts";
			this.chooseFonts.Size = new System.Drawing.Size(75, 23);
			this.chooseFonts.TabIndex = 1;
			this.chooseFonts.Text = "Choose";
			this.chooseFonts.UseVisualStyleBackColor = true;
			this.chooseFonts.Click += new System.EventHandler(this.chooseFonts_Click);
			// 
			// label7
			// 
			this.label7.AutoSize = true;
			this.label7.Location = new System.Drawing.Point(235, 180);
			this.label7.Name = "label7";
			this.label7.Size = new System.Drawing.Size(187, 13);
			this.label7.TabIndex = 31;
			this.label7.Text = "Leave blank for default: Studio Enums";
			// 
			// label8
			// 
			this.label8.AutoSize = true;
			this.label8.Location = new System.Drawing.Point(12, 160);
			this.label8.Name = "label8";
			this.label8.Size = new System.Drawing.Size(56, 13);
			this.label8.TabIndex = 30;
			this.label8.Text = "Font Sizes";
			// 
			// sizes
			// 
			this.sizes.Location = new System.Drawing.Point(111, 157);
			this.sizes.Name = "sizes";
			this.sizes.Size = new System.Drawing.Size(311, 20);
			this.sizes.TabIndex = 6;
			this.sizes.Leave += new System.EventHandler(this.sizes_Leave);
			// 
			// label6
			// 
			this.label6.AutoSize = true;
			this.label6.Location = new System.Drawing.Point(116, 131);
			this.label6.Name = "label6";
			this.label6.Size = new System.Drawing.Size(306, 13);
			this.label6.TabIndex = 28;
			this.label6.Text = "Leave blank for default: bytes 32-126 (standard printable ASCII)";
			// 
			// label5
			// 
			this.label5.AutoSize = true;
			this.label5.Location = new System.Drawing.Point(12, 111);
			this.label5.Name = "label5";
			this.label5.Size = new System.Drawing.Size(72, 13);
			this.label5.TabIndex = 27;
			this.label5.Text = "Character Set";
			// 
			// charset
			// 
			this.charset.Location = new System.Drawing.Point(111, 108);
			this.charset.Name = "charset";
			this.charset.Size = new System.Drawing.Size(311, 20);
			this.charset.TabIndex = 5;
			this.charset.Leave += new System.EventHandler(this.charset_Leave);
			// 
			// label4
			// 
			this.label4.AutoSize = true;
			this.label4.Location = new System.Drawing.Point(12, 75);
			this.label4.Name = "label4";
			this.label4.Size = new System.Drawing.Size(90, 13);
			this.label4.TabIndex = 25;
			this.label4.Text = "Max Image Width";
			// 
			// label3
			// 
			this.label3.AutoSize = true;
			this.label3.Location = new System.Drawing.Point(173, 75);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size(38, 13);
			this.label3.TabIndex = 24;
			this.label3.Text = "Height";
			// 
			// height
			// 
			this.height.Location = new System.Drawing.Point(220, 72);
			this.height.MaxLength = 10;
			this.height.Name = "height";
			this.height.Size = new System.Drawing.Size(51, 20);
			this.height.TabIndex = 4;
			this.height.Text = "1024";
			this.height.TextChanged += new System.EventHandler(this.resolution_TextChanged);
			this.height.Leave += new System.EventHandler(this.height_Leave);
			// 
			// outFolderTextbox
			// 
			this.outFolderTextbox.Enabled = false;
			this.outFolderTextbox.Location = new System.Drawing.Point(111, 36);
			this.outFolderTextbox.Name = "outFolderTextbox";
			this.outFolderTextbox.ReadOnly = true;
			this.outFolderTextbox.Size = new System.Drawing.Size(230, 20);
			this.outFolderTextbox.TabIndex = 21;
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Location = new System.Drawing.Point(12, 39);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(71, 13);
			this.label2.TabIndex = 20;
			this.label2.Text = "Output Folder";
			// 
			// selectedFonts
			// 
			this.selectedFonts.Enabled = false;
			this.selectedFonts.Location = new System.Drawing.Point(111, 10);
			this.selectedFonts.Name = "selectedFonts";
			this.selectedFonts.ReadOnly = true;
			this.selectedFonts.Size = new System.Drawing.Size(230, 20);
			this.selectedFonts.TabIndex = 19;
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Location = new System.Drawing.Point(12, 13);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(52, 13);
			this.label1.TabIndex = 18;
			this.label1.Text = "Font Files";
			// 
			// width
			// 
			this.width.Location = new System.Drawing.Point(111, 72);
			this.width.MaxLength = 10;
			this.width.Name = "width";
			this.width.Size = new System.Drawing.Size(56, 20);
			this.width.TabIndex = 3;
			this.width.Text = "1024";
			this.width.TextChanged += new System.EventHandler(this.resolution_TextChanged);
			this.width.Leave += new System.EventHandler(this.width_Leave);
			// 
			// generate
			// 
			this.generate.Location = new System.Drawing.Point(347, 206);
			this.generate.Name = "generate";
			this.generate.Size = new System.Drawing.Size(75, 23);
			this.generate.TabIndex = 7;
			this.generate.Text = "Generate";
			this.generate.UseVisualStyleBackColor = true;
			this.generate.Click += new System.EventHandler(this.generate_Click);
			// 
			// outputText
			// 
			this.outputText.AutoSize = true;
			this.outputText.Location = new System.Drawing.Point(12, 211);
			this.outputText.Name = "outputText";
			this.outputText.Size = new System.Drawing.Size(0, 13);
			this.outputText.TabIndex = 34;
			this.outputText.Click += new System.EventHandler(this.outputText_Click);
			// 
			// fontSelection
			// 
			this.fontSelection.FileName = "fontSelection";
			// 
			// InputGui
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(434, 237);
			this.Controls.Add(this.outputText);
			this.Controls.Add(this.chooseOutput);
			this.Controls.Add(this.chooseFonts);
			this.Controls.Add(this.label7);
			this.Controls.Add(this.label8);
			this.Controls.Add(this.sizes);
			this.Controls.Add(this.label6);
			this.Controls.Add(this.label5);
			this.Controls.Add(this.charset);
			this.Controls.Add(this.label4);
			this.Controls.Add(this.label3);
			this.Controls.Add(this.height);
			this.Controls.Add(this.outFolderTextbox);
			this.Controls.Add(this.label2);
			this.Controls.Add(this.selectedFonts);
			this.Controls.Add(this.label1);
			this.Controls.Add(this.width);
			this.Controls.Add(this.generate);
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.Name = "InputGui";
			this.Text = "RBX_CustomFont Font Generator";
			this.Load += new System.EventHandler(this.InputGui_Load);
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Button chooseOutput;
		private System.Windows.Forms.Button chooseFonts;
		private System.Windows.Forms.Label label7;
		private System.Windows.Forms.Label label8;
		private System.Windows.Forms.TextBox sizes;
		private System.Windows.Forms.Label label6;
		private System.Windows.Forms.Label label5;
		private System.Windows.Forms.TextBox charset;
		private System.Windows.Forms.Label label4;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.TextBox height;
		private System.Windows.Forms.TextBox outFolderTextbox;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.TextBox selectedFonts;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.FolderBrowserDialog outputFolder;
		private System.Windows.Forms.TextBox width;
		private System.Windows.Forms.Button generate;
		private System.Windows.Forms.Label outputText;
		private System.Windows.Forms.OpenFileDialog fontSelection;
	}
}
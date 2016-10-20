namespace CustomFontRenderingForm
{
	partial class InputGUI
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(InputGUI));
			this.label1 = new System.Windows.Forms.Label();
			this.fontBox = new System.Windows.Forms.TextBox();
			this.fontButton = new System.Windows.Forms.Button();
			this.outputButton = new System.Windows.Forms.Button();
			this.outputBox = new System.Windows.Forms.TextBox();
			this.label2 = new System.Windows.Forms.Label();
			this.label3 = new System.Windows.Forms.Label();
			this.widthBox = new System.Windows.Forms.TextBox();
			this.label4 = new System.Windows.Forms.Label();
			this.heightBox = new System.Windows.Forms.TextBox();
			this.label5 = new System.Windows.Forms.Label();
			this.characterBox = new System.Windows.Forms.TextBox();
			this.label6 = new System.Windows.Forms.Label();
			this.label7 = new System.Windows.Forms.Label();
			this.sizeBox = new System.Windows.Forms.TextBox();
			this.generateButton = new System.Windows.Forms.Button();
			this.JSONCheckBox = new System.Windows.Forms.CheckBox();
			this.RBXLuaCheckBox = new System.Windows.Forms.CheckBox();
			this.outputMessage = new System.Windows.Forms.Label();
			this.SuspendLayout();
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Location = new System.Drawing.Point(13, 13);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(52, 13);
			this.label1.TabIndex = 0;
			this.label1.Text = "Font Files";
			// 
			// fontBox
			// 
			this.fontBox.Enabled = false;
			this.fontBox.Location = new System.Drawing.Point(111, 10);
			this.fontBox.Name = "fontBox";
			this.fontBox.ReadOnly = true;
			this.fontBox.Size = new System.Drawing.Size(230, 20);
			this.fontBox.TabIndex = 1;
			// 
			// fontButton
			// 
			this.fontButton.Location = new System.Drawing.Point(347, 8);
			this.fontButton.Name = "fontButton";
			this.fontButton.Size = new System.Drawing.Size(75, 23);
			this.fontButton.TabIndex = 2;
			this.fontButton.Text = "Choose";
			this.fontButton.UseVisualStyleBackColor = true;
			this.fontButton.Click += new System.EventHandler(this.fontButton_Click);
			// 
			// outputButton
			// 
			this.outputButton.Location = new System.Drawing.Point(347, 38);
			this.outputButton.Name = "outputButton";
			this.outputButton.Size = new System.Drawing.Size(75, 23);
			this.outputButton.TabIndex = 3;
			this.outputButton.Text = "Choose";
			this.outputButton.UseVisualStyleBackColor = true;
			this.outputButton.Click += new System.EventHandler(this.outputButton_Click);
			// 
			// outputBox
			// 
			this.outputBox.Enabled = false;
			this.outputBox.Location = new System.Drawing.Point(111, 40);
			this.outputBox.Name = "outputBox";
			this.outputBox.ReadOnly = true;
			this.outputBox.Size = new System.Drawing.Size(230, 20);
			this.outputBox.TabIndex = 4;
			// 
			// label2
			// 
			this.label2.AutoSize = true;
			this.label2.Location = new System.Drawing.Point(13, 43);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(71, 13);
			this.label2.TabIndex = 5;
			this.label2.Text = "Output Folder";
			// 
			// label3
			// 
			this.label3.AutoSize = true;
			this.label3.Location = new System.Drawing.Point(12, 77);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size(90, 13);
			this.label3.TabIndex = 6;
			this.label3.Text = "Max Image Width";
			// 
			// widthBox
			// 
			this.widthBox.Location = new System.Drawing.Point(111, 74);
			this.widthBox.MaxLength = 10;
			this.widthBox.Name = "widthBox";
			this.widthBox.Size = new System.Drawing.Size(56, 20);
			this.widthBox.TabIndex = 7;
			this.widthBox.Text = "1024";
			this.widthBox.Leave += new System.EventHandler(this.widthBox_Leave);
			// 
			// label4
			// 
			this.label4.AutoSize = true;
			this.label4.Location = new System.Drawing.Point(173, 77);
			this.label4.Name = "label4";
			this.label4.Size = new System.Drawing.Size(38, 13);
			this.label4.TabIndex = 8;
			this.label4.Text = "Height";
			// 
			// heightBox
			// 
			this.heightBox.Location = new System.Drawing.Point(217, 74);
			this.heightBox.MaxLength = 10;
			this.heightBox.Name = "heightBox";
			this.heightBox.Size = new System.Drawing.Size(56, 20);
			this.heightBox.TabIndex = 9;
			this.heightBox.Text = "1024";
			this.heightBox.Leave += new System.EventHandler(this.heightBox_Leave);
			// 
			// label5
			// 
			this.label5.AutoSize = true;
			this.label5.Location = new System.Drawing.Point(12, 112);
			this.label5.Name = "label5";
			this.label5.Size = new System.Drawing.Size(72, 13);
			this.label5.TabIndex = 10;
			this.label5.Text = "Character Set";
			// 
			// characterBox
			// 
			this.characterBox.Location = new System.Drawing.Point(111, 109);
			this.characterBox.Name = "characterBox";
			this.characterBox.Size = new System.Drawing.Size(311, 20);
			this.characterBox.TabIndex = 37;
			this.characterBox.Leave += new System.EventHandler(this.characterBox_Leave);
			// 
			// label6
			// 
			this.label6.AutoSize = true;
			this.label6.Location = new System.Drawing.Point(116, 132);
			this.label6.Name = "label6";
			this.label6.Size = new System.Drawing.Size(306, 13);
			this.label6.TabIndex = 47;
			this.label6.Text = "Leave blank for default: bytes 32-126 (standard printable ASCII)";
			// 
			// label7
			// 
			this.label7.AutoSize = true;
			this.label7.Location = new System.Drawing.Point(12, 164);
			this.label7.Name = "label7";
			this.label7.Size = new System.Drawing.Size(56, 13);
			this.label7.TabIndex = 48;
			this.label7.Text = "Font Sizes";
			// 
			// sizeBox
			// 
			this.sizeBox.Location = new System.Drawing.Point(111, 161);
			this.sizeBox.Name = "sizeBox";
			this.sizeBox.Size = new System.Drawing.Size(311, 20);
			this.sizeBox.TabIndex = 49;
			this.sizeBox.Leave += new System.EventHandler(this.sizeBox_Leave);
			// 
			// generateButton
			// 
			this.generateButton.Location = new System.Drawing.Point(347, 191);
			this.generateButton.Name = "generateButton";
			this.generateButton.Size = new System.Drawing.Size(75, 23);
			this.generateButton.TabIndex = 50;
			this.generateButton.Text = "Generate";
			this.generateButton.UseVisualStyleBackColor = true;
			this.generateButton.Click += new System.EventHandler(this.generateButton_Click);
			// 
			// JSONCheckBox
			// 
			this.JSONCheckBox.AutoSize = true;
			this.JSONCheckBox.Checked = true;
			this.JSONCheckBox.CheckState = System.Windows.Forms.CheckState.Checked;
			this.JSONCheckBox.Location = new System.Drawing.Point(287, 195);
			this.JSONCheckBox.Name = "JSONCheckBox";
			this.JSONCheckBox.Size = new System.Drawing.Size(54, 17);
			this.JSONCheckBox.TabIndex = 51;
			this.JSONCheckBox.Text = "JSON";
			this.JSONCheckBox.UseVisualStyleBackColor = true;
			// 
			// RBXLuaCheckBox
			// 
			this.RBXLuaCheckBox.AutoSize = true;
			this.RBXLuaCheckBox.Location = new System.Drawing.Point(212, 195);
			this.RBXLuaCheckBox.Name = "RBXLuaCheckBox";
			this.RBXLuaCheckBox.Size = new System.Drawing.Size(69, 17);
			this.RBXLuaCheckBox.TabIndex = 52;
			this.RBXLuaCheckBox.Text = "RBX.Lua";
			this.RBXLuaCheckBox.UseVisualStyleBackColor = true;
			// 
			// outputMessage
			// 
			this.outputMessage.AutoSize = true;
			this.outputMessage.Location = new System.Drawing.Point(13, 196);
			this.outputMessage.Name = "outputMessage";
			this.outputMessage.Size = new System.Drawing.Size(0, 13);
			this.outputMessage.TabIndex = 53;
			this.outputMessage.Click += new System.EventHandler(this.outputMessage_Click);
			// 
			// InputGUI
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(434, 226);
			this.Controls.Add(this.outputMessage);
			this.Controls.Add(this.RBXLuaCheckBox);
			this.Controls.Add(this.JSONCheckBox);
			this.Controls.Add(this.generateButton);
			this.Controls.Add(this.sizeBox);
			this.Controls.Add(this.label7);
			this.Controls.Add(this.label6);
			this.Controls.Add(this.characterBox);
			this.Controls.Add(this.label5);
			this.Controls.Add(this.heightBox);
			this.Controls.Add(this.label4);
			this.Controls.Add(this.widthBox);
			this.Controls.Add(this.label3);
			this.Controls.Add(this.label2);
			this.Controls.Add(this.outputBox);
			this.Controls.Add(this.outputButton);
			this.Controls.Add(this.fontButton);
			this.Controls.Add(this.fontBox);
			this.Controls.Add(this.label1);
			this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
			this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
			this.Name = "InputGUI";
			this.Text = "Custom Font generator";
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.TextBox fontBox;
		private System.Windows.Forms.Button fontButton;
		private System.Windows.Forms.Button outputButton;
		private System.Windows.Forms.TextBox outputBox;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.TextBox widthBox;
		private System.Windows.Forms.Label label4;
		private System.Windows.Forms.TextBox heightBox;
		private System.Windows.Forms.Label label5;
		private System.Windows.Forms.TextBox characterBox;
		private System.Windows.Forms.Label label6;
		private System.Windows.Forms.Label label7;
		private System.Windows.Forms.TextBox sizeBox;
		private System.Windows.Forms.Button generateButton;
		private System.Windows.Forms.CheckBox JSONCheckBox;
		private System.Windows.Forms.CheckBox RBXLuaCheckBox;
		private System.Windows.Forms.Label outputMessage;
	}
}


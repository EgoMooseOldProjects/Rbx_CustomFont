local font = require(game:GetService("Workspace"):WaitForChild("Rbx_CustomFont"));

function posFrom(frame, pos, x, y)
	frame.Position = UDim2.new(
		pos.X.Scale - frame.Size.X.Scale * x,
		pos.X.Offset - frame.Size.X.Offset * x,
		pos.Y.Scale - frame.Size.Y.Scale * y,
		pos.Y.Offset - frame.Size.Y.Offset * y
	);
end;

local label = font.Label("Yellowtail");
label.Text = "Ego's the name, mediocre's the game.";
label.Size = UDim2.new(0.3, 0, 0.2, 0);
label.FontSize = Enum.FontSize.Size96;
label.TextColor3 = Color3.new();
posFrom(label, UDim2.new(0.5, 0, 0.5, 0), 0.5, 0.5);
label.Parent = script.Parent; -- Under a screengui
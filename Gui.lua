repeat task.wait() until game:IsLoaded()

local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Http = game:GetService("HttpService")

local Config = {
	Buttons = {},
	Toggles = {},
	Dropdowns = {},
}

makefolder = makefolder or function(e,v) --[[warn(e .. " : nil function; makefolder")]] end
writefile = writefile or function(e,v) --[[warn(e .. " - "..v.. " : nil function; writefile")]] end
readfile = readfile or function(e) --[[warn(e .. " : nil function; readfile")]] end
delfile = delfile or function(e) --[[warn(e .. " : nil function; delfile")]] end
isfile = isfile or function(e) --[[warn(e .. " : nil function; isfile")]] end

local save = function()
	if isfile("Tenacity/Configs/"..game.PlaceId..".json") then
		delfile("Tenacity/Configs/"..game.PlaceId..".json")
	end
	writefile("Tenacity/Configs/"..game.PlaceId..".json", Http:JSONEncode(Config))
end
local load = function()
	if isfile("Tenacity/Configs/"..game.PlaceId..".json") then
		Config = Http:JSONDecode(readfile("Tenacity/Configs/"..game.PlaceId..".json"))
	else
	warn("Failed to load ".."Tenacity/Configs/"..game.PlaceId..".json")
	end
end

load()

task.wait(.1)

local lplr = PlayerService.LocalPlayer

local assets = {
	["ModuleArrow"] = "rbxassetid://12974428978",
}

local getCoreGui = function()
	local s, p = pcall(function()
		Instance.new("ScreenGui", game:GetService("CoreGui"))
	end)
	if not s then
		return lplr.PlayerGui
	end
	return game:GetService("CoreGui")
end

local ScreenGui = Instance.new("ScreenGui", getCoreGui())
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = tostring(math.random())

local Theme = {
	Color1 = Color3.fromRGB(0, 145, 255),
	Color2 = Color3.fromRGB(255, 99, 242)
}

local GuiLibrary = {Windows = {}, ArrayList = {}}

GuiLibrary.ArrayList.Frame = Instance.new("Frame", ScreenGui)
GuiLibrary.ArrayList.Frame.Position = UDim2.fromScale(0.75, 0)
GuiLibrary.ArrayList.Frame.Size = UDim2.fromScale(0.2,1)
GuiLibrary.ArrayList.Frame.BackgroundTransparency = 1

local GuiLibrarySorter = Instance.new("UIListLayout", GuiLibrary.ArrayList.Frame)
GuiLibrarySorter.SortOrder = Enum.SortOrder.LayoutOrder
GuiLibrarySorter.HorizontalAlignment = Enum.HorizontalAlignment.Right

local ArrayListStrings = {}

GuiLibrary.ArrayList.Add = function(name)
	ArrayListStrings[name] = name:lower()
	local Item = Instance.new("TextLabel", GuiLibrary.ArrayList.Frame)
	Item.Text = name
	Item.BorderSizePixel = 0
	Item.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Item.BackgroundTransparency = 0.5
	Item.Name = name:lower()
	Item.TextColor3 = GuiLibrary.Theme.Color1
	Item.TextSize = 14
	Item.Size = UDim2.new(0.01, TextService:GetTextSize(Item.Text, Item.TextSize, Item.Font, Vector2.new(0, 0)).X, 0.03, 0)

	table.insert(ArrayListStrings, Item)

	table.sort(ArrayListStrings, function(A, B)
		return TextService:GetTextSize(A.Text, A.TextSize, A.Font, Vector2.new(0, 0)).X > TextService:GetTextSize(B.Text, B.TextSize, B.Font, Vector2.new(0, 0)).X
	end)

	for i, v in ipairs(ArrayListStrings) do
		v.LayoutOrder = i
	end
end

GuiLibrary.ArrayList.Remove = function(name)
	pcall(function()
		GuiLibrary.ArrayList.Frame[name:lower()]:Destroy()
		ArrayListStrings[name:lower()] = nil
	end)
end

GuiLibrary.WindowCount = 0
task.spawn(function()
	local Offset = 1

	repeat
		local sortedChildren = GuiLibrary.ArrayList.Frame:GetChildren()
		table.sort(sortedChildren, function(A, B)
			if A:IsA("UIListLayout") or B:IsA("UIListLayout") then
				return false
			end
			return A.LayoutOrder < B.LayoutOrder
		end)

		for i, v in ipairs(sortedChildren) do
			if v:IsA("TextLabel") then
				local waveFactor = math.sin((i + Offset) * 0.3) * 0.5 + 0.5
				v.TextColor3 = GuiLibrary.Theme.Color1:Lerp(GuiLibrary.Theme.Color2, waveFactor)
			end
		end

		Offset = Offset + 1
		task.wait(0.1)
	until false
end)
local Modules = {}
local ColorChangeEvent = Instance.new("BindableEvent")
GuiLibrary.Theme = Theme
GuiLibrary.ColorChangeEvent = ColorChangeEvent
function GuiLibrary:NewWindow(Name)

	local top = Instance.new("TextLabel", ScreenGui)
	top.Size = UDim2.fromScale(0.12,0.05)
	top.Position = UDim2.fromScale(0.02 + (0.14 * GuiLibrary.WindowCount), 0.15)
	top.BorderSizePixel = 0
	top.BackgroundColor3 = Color3.fromRGB(30,30,30)
	top.TextXAlignment = Enum.TextXAlignment.Left
	top.Text = "  <b>"..Name.."</b>"
	top.RichText = true
	top.TextColor3 = Color3.fromRGB(255,255,255)
	top.TextSize = 16

	local moduleFrame = Instance.new("ScrollingFrame", top)
	moduleFrame.Size = UDim2.fromScale(1,15)
	moduleFrame.Position = UDim2.fromScale(0,1)
	moduleFrame.BackgroundTransparency = 1

	UserInputService.InputBegan:Connect(function(k,g)
		if g then return end
		if k.KeyCode == Enum.KeyCode.RightShift then
			top.Visible = not top.Visible
		end
	end)

	Instance.new("UIListLayout", moduleFrame)

	Modules[Name] = {}
	GuiLibrary.Windows[Name] = {
		CreateOptionsButton = function(tab)
			if Config.Buttons[tab["Name"]] == nil then
				Config.Buttons[tab["Name"]] = {
					Keybind = "Enum.Keycode.F15",
					Enabled = false,
				}
			end
			
			local button = Instance.new("TextButton", moduleFrame)
			button.Size = UDim2.fromScale(1,0.06)
			button.BorderSizePixel = 0
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.TextColor3 = Color3.fromRGB(255,255,255)
			button.Text = "  "..tab.Name
			button.BackgroundColor3 = Color3.fromRGB(40,40,40)
			button.TextSize = 12

			--[[local dropdownArrow = Instance.new("ImageLabel", button)
			dropdownArrow.Size = UDim2.new(0,25,0.75,0)
			dropdownArrow.Position = UDim2.new(0.95,-dropdownArrow.Size.X.Offset,0.9 - dropdownArrow.Size.Y.Scale, 0)
			dropdownArrow.BackgroundTransparency = 1
			dropdownArrow.Image = assets.ModuleArrow--]]

			local panel = Instance.new("Frame", button)
			panel.BorderSizePixel = 0
			panel.BackgroundColor3 = Color3.fromRGB(35,35,35)
			panel.Size = UDim2.new(1,0,0,0)
			panel.Position = UDim2.fromScale(0,1)
			panel.ZIndex = 2
			panel.Visible = false
			panel.AutomaticSize = Enum.AutomaticSize.Y
			Instance.new("UIListLayout", panel)

			local keybindText = Instance.new("TextLabel", panel)
			keybindText.Size = UDim2.new(1,0,0,30)
			keybindText.RichText = true
			keybindText.TextColor3 = Color3.fromRGB(255,255,255)
			keybindText.Text = "  Bind"
			keybindText.TextXAlignment = Enum.TextXAlignment.Left
			keybindText.TextSize = 12
			keybindText.ZIndex = 3
			keybindText.BackgroundTransparency = 1

			local keybindButton = Instance.new("TextButton", keybindText)
			keybindButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
			keybindButton.Size = UDim2.new(0,20,0.7,0)
			keybindButton.Position = UDim2.fromScale(0.75,0.2)
			keybindButton.AutomaticSize = Enum.AutomaticSize.X
			keybindButton.Text = "<b>None</b>"
			keybindButton.TextColor3 = Color3.fromRGB(255,255,255)
			keybindButton.TextSize = 12
			keybindButton.RichText = true
			Instance.new("UICorner",keybindButton).CornerRadius = UDim.new(1,0)
			keybindButton.ZIndex = 4

			local keybind = Enum.KeyCode.F15
			local keybindSet = tick()

			local keybindConnection
			keybindButton.MouseButton1Down:Connect(function()
				if tick() - keybindSet < 0.5 then
					return
				end
				keybindConnection = UserInputService.InputBegan:Connect(function(key, gpe)
					if not gpe then
						task.spawn(0.05, function()
							keybindConnection:Disconnect()
						end)
						keybindButton.Text = "<b>"..key.KeyCode.Name.."</b>"
						task.delay(0.1,function()
							keybind = key.KeyCode
						end)

						if (keybindButton.Text:len() == 8) then
							keybindButton.Position = UDim2.fromScale(0.83,0.2)
						else
							keybindButton.Position = UDim2.fromScale(0.75 - (keybindButton.Text:len() / 100),0.2)
						end
						
						Config.Buttons[tab.Name].Keybind = tostring(key.KeyCode)
						
						task.delay(0.1, function()
							save()
						end)
						keybindSet = tick()
					end
				end)
			end)

			local buttonData
			buttonData = {
				Enabled = false,
				ToggleButton = function(state)
					if state == nil then state = not buttonData.Enabled end
					buttonData.Enabled = state
					task.delay(0.1,function() task.spawn(tab.Function, state) end)
					TweenService:Create(button, TweenInfo.new(0.3), {BackgroundColor3 = state and GuiLibrary.Theme.Color2 or Color3.fromRGB(40,40,40)}):Play()
					if state then GuiLibrary.ArrayList.Add(tab.Name) else GuiLibrary.ArrayList.Remove(tab.Name) end
					Config.Buttons[tab.Name].Enabled = buttonData.Enabled
					task.delay(0.1, function()
						save()
					end)
				end,
				CreateToggle = function(tab2)

					if Config.Toggles[tab2.Name.."_"..tab.Name] == nil then
						Config.Toggles[tab2.Name.."_"..tab.Name] = {
							Enabled = false
						}
					end

					local ToggleText = Instance.new("TextLabel", panel)
					ToggleText.Size = UDim2.new(1, 0, 0, 30)
					ToggleText.RichText = true
					ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
					ToggleText.Text = "  " .. tab2.Name
					ToggleText.TextXAlignment = Enum.TextXAlignment.Left
					ToggleText.TextSize = 12
					ToggleText.ZIndex = 3
					ToggleText.BackgroundTransparency = 1

					local ToggleFrame = Instance.new("Frame", ToggleText)
					ToggleFrame.Size = UDim2.new(0, 40, 0.7, 0)
					ToggleFrame.Position = UDim2.fromScale(0.75, 0.15)
					ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					ToggleFrame.ZIndex = 4
					local UICorner = Instance.new("UICorner", ToggleFrame)
					UICorner.CornerRadius = UDim.new(1, 0)

					local ToggleButton = Instance.new("Frame", ToggleFrame)
					ToggleButton.Size = UDim2.new(0.5, 0, 1, 0)
					ToggleButton.Position = UDim2.new(0, 0, 0, 0)
					ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					ToggleButton.ZIndex = 5
					local ButtonCorner = Instance.new("UICorner", ToggleButton)
					ButtonCorner.CornerRadius = UDim.new(1, 0)

					local toggleSettings
					toggleSettings = {
						Enabled = false,
						ToggleButton = function(state)
							if state == nil then state = not toggleSettings.Enabled end
							toggleSettings.Enabled = state
							ToggleFrame.BackgroundColor3 = state and GuiLibrary.Theme.Color1 or Color3.fromRGB(30, 30, 30)
							Config.Toggles[tab2.Name.."_"..tab.Name].Enabled = toggleSettings.Enabled
							if ToggleButton.Position == UDim2.new(0, 0, 0, 0) then
								ToggleButton:TweenPosition(UDim2.new(0.5, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
							else
								ToggleButton:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
							end
							
							task.delay(0.1, function()
								save()
							end)
						end,
					}

					ToggleFrame.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							toggleSettings.ToggleButton()
						end
					end)
					
					if Config.Toggles[tab2.Name.."_"..tab.Name].Enabled then
						toggleSettings.ToggleButton()
					end

					return toggleSettings
				end,

				CreateDropdown = function(tab2)
					if Config.Dropdowns[tab2.Name.."_"..tab.Name] == nil then
						Config.Dropdowns[tab2.Name.."_"..tab.Name] = {
							Option = tab2["Options"][1]
						}
					end

					local dropdownSettings = { Option = tab2.Options[1] }

					local DropdownText = Instance.new("TextLabel", panel)
					DropdownText.Size = UDim2.new(1, 0, 0, 80)
					DropdownText.RichText = true
					DropdownText.TextColor3 = Color3.fromRGB(255, 255, 255)
					DropdownText.Text = "" .. tab2.Name
					DropdownText.TextXAlignment = Enum.TextXAlignment.Center
					DropdownText.TextYAlignment = Enum.TextYAlignment.Top
					DropdownText.TextSize = 12
					DropdownText.ZIndex = 3
					DropdownText.BackgroundTransparency = 1
					DropdownText.BorderSizePixel = 0

					local DropdownButton = Instance.new("TextButton", DropdownText)
					DropdownButton.Size = UDim2.new(1, 0, 0, 30)
					DropdownButton.Position = UDim2.fromScale(0.5,0.5)
					DropdownButton.AnchorPoint = Vector2.new(0.5,0.5)
					DropdownButton.ZIndex = 4
					DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
					DropdownButton.Text = "  <b>" .. dropdownSettings.Option .. "</b>"
					DropdownButton.RichText = true
					DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
					DropdownButton.TextSize = 12
					DropdownButton.AutoButtonColor = false
					DropdownButton.BorderSizePixel = 0

					local dropdownList = Instance.new("ScrollingFrame", DropdownButton)
					dropdownList.ZIndex = 7
					dropdownList.BackgroundTransparency = 0
					dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					dropdownList.Size = UDim2.new(1, 0, 0, 0)
					dropdownList.Position = UDim2.fromScale(0,1)
					dropdownList.ScrollBarThickness = 0
					dropdownList.ClipsDescendants = true
					dropdownList.BorderSizePixel = 0
					local layout = Instance.new("UIListLayout", dropdownList)
					layout.SortOrder = Enum.SortOrder.LayoutOrder

					DropdownButton.MouseButton1Click:Connect(function()
						if dropdownList.Size.Y.Offset == 0 then
							dropdownList.Size = UDim2.new(1, 0, 0, #tab2.Options * 40)
						else
							dropdownList.Size = UDim2.new(1, 0, 0, 0)
						end
					end)

					for i, v in ipairs(tab2.Options) do
						local OptionButton = Instance.new("TextButton", dropdownList)
						OptionButton.Size = UDim2.new(1, 0, 0, 30)
						OptionButton.Text = v
						OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
						OptionButton.TextSize = 12
						OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
						OptionButton.ZIndex = 7
						OptionButton.BorderSizePixel = 0

						OptionButton.MouseButton1Click:Connect(function()
							dropdownSettings.Option = v
							DropdownButton.Text = "  <b>" .. v .. "</b>"
							dropdownList.Size = UDim2.new(1, 0, 0, 0)
							
							Config.Dropdowns[tab2.Name.."_"..tab.Name].Option = dropdownSettings.Option
							
							task.delay(0.1, function()
								save()
							end)
						end)
						
						if Config.Dropdowns[tab2.Name.."_"..tab.Name].Option == OptionButton.Text then
							dropdownSettings.Option = v
							DropdownButton.Text = "  <b>" .. v .. "</b>"
							dropdownList.Size = UDim2.new(1, 0, 0, 0)
						end
					end

					return dropdownSettings
				end
			}

			button.MouseButton1Down:Connect(function()
				buttonData.ToggleButton(not buttonData.Enabled)
			end)

			button.MouseButton2Down:Connect(function()
				panel.Visible = not panel.Visible

				for i,v in pairs(Modules[Name]) do
					if v.Instance == button then continue end
					v.Instance.Visible = not panel.Visible
				end
			end)

			Modules[Name][tab.Name] = {
				Instance = button,
				ButtonData = buttonData,
				Keybind = function()
					return keybind
				end,
			}

			ColorChangeEvent.Event:Connect(function(clr)
				if buttonData.Enabled then
					button.BackgroundColor3 = clr
				end
			end)
			
			if Config.Buttons[tab.Name].Enabled then
				buttonData.ToggleButton(true)
			end
			
			task.wait(0.1)
			
			keybind = Enum.KeyCode[Config.Buttons[tab.Name].Keybind:split(".")[3]]
			keybindButton.Text = Config.Buttons[tab.Name].Keybind:split(".")[3]
			if (keybindButton.Text:len() == 8) then
				keybindButton.Position = UDim2.fromScale(0.83,0.2)
			else
				keybindButton.Position = UDim2.fromScale(0.75 - (keybindButton.Text:len() / 100),0.2)
			end

			return buttonData
		end,
	}

	GuiLibrary.WindowCount += 1
end

UserInputService.InputBegan:Connect(function(key, gpe)
	if gpe then return end

	for i,v in pairs(Modules) do
		for i2,v2 in pairs(v) do
			if v2.Keybind() == key.KeyCode then
				v2.ButtonData.ToggleButton(not v2.ButtonData.Enabled)
			end
		end
	end
end)

return GuiLibrary

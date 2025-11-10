local inputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local guiInset = game:GetService("GuiService"):GetGuiInset()

local folderName = "KramFolder"


if not isfolder(folderName) then
    makefolder(folderName)
end


local gameConfigFolder = folderName .. "/" .. game.PlaceId


if not isfolder(gameConfigFolder) then
    makefolder(gameConfigFolder)
end
    
local utility = {}


function utility.create(class, properties)
    properties = properties or {}
    local obj = Instance.new(class)
    local forcedProperties = { AutoButtonColor = false }
    for prop, v in next, properties do
        obj[prop] = v
    end
    for prop, v in next, forcedProperties do
        pcall(function() obj[prop] = v end)
    end
    return obj
end


function utility.change_color(color, amount)
    local r = math.clamp(math.floor(color.r * 255) + amount, 0, 255)
    local g = math.clamp(math.floor(color.g * 255) + amount, 0, 255)
    local b = math.clamp(math.floor(color.b * 255) + amount, 0, 255)


    return Color3.fromRGB(r, g, b)
end


function utility.get_rgb(color)
    local r = math.floor(color.r * 255)
    local g = math.floor(color.g * 255)
    local b = math.floor(color.b * 255)


    return r, g, b
end


function utility.tween(obj, info, properties, callback)
    local anim = tweenService:Create(obj, TweenInfo.new(unpack(info)), properties)
    anim:Play()


    if callback then
        anim.Completed:Connect(callback)
    end
end


    
function utility.drag(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false		
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)

		inputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				tweenService:Create(Main, TweenInfo.new(0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
				}):Play()
			end
		end)
	end)
end


function utility.get_center(sizeX, sizeY)
    return UDim2.new(0.5, -(sizeX / 2), 0.5, -(sizeY / 2))
end


function utility.hex_to_rgb(hex)
    return Color3.fromRGB(tonumber("0x" .. hex:sub(2, 3)), tonumber("0x" .. hex:sub(4, 5)), tonumber("0x"..hex:sub(6, 7)))
end


function utility.rgb_to_hex(color)
    return string.format("#%02X%02X%02X", math.clamp(color.R * 255, 0, 255), math.clamp(color.G * 255, 0, 255), math.clamp(color.B * 255, 0, 255))
end


function utility.table(tbl)
    local oldtbl = tbl or {}
    local newtbl = {}
    local formattedtbl = {}


    for option, v in next, oldtbl do
        newtbl[option:lower()] = v
    end


    setmetatable(formattedtbl, {
        __newindex = function(t, k, v)
            rawset(newtbl, k:lower(), v)
        end,
        __index = function(t, k, v)
            return newtbl[k:lower()]
        end
    })


    return formattedtbl
end


local library = utility.table{
    flags = {}, 
    toggled = true,
    color = Color3.fromRGB(255, 0, 0),
    keybind = Enum.KeyCode.RightShift, 
    dragSpeed = 0.1
}    

local flags = {toggles = {}, boxes = {}, sliders = {}, dropdowns = {}, multidropdowns = {}, keybinds = {}, colorpickers = {}}


function library:LoadConfig(file)
    local str = readfile(gameConfigFolder .. "/" .. file .. ".cfg")
    local tbl = loadstring(str)()
    
    for flag, value in next, tbl.toggles do
        flags.toggles[flag](value)
    end


    for flag, value in next, tbl.boxes do
        flags.boxes[flag](value)
    end


    for flag, value in next, tbl.sliders do
        flags.sliders[flag](value)
    end


    for flag, value in next, tbl.dropdowns do
        flags.dropdowns[flag](value)
    end


    for flag, value in next, tbl.multidropdowns do
        flags.multidropdowns[flag](value)
    end


    for flag, value in next, tbl.keybinds do
        flags.keybinds[flag](value)
    end


    for flag, value in next, tbl.colorpickers do
        flags.colorpickers[flag](value)
    end
end


function library:SaveConfig(name)
    local configstr = "{toggles={"
    local count = 0


    for flag, _ in next, flags.toggles do
        count = count + 1
        configstr = configstr .. "['" .. flag .. "']=" .. tostring(library.flags[flag]) .. ","
    end


    configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},boxes={"


    count = 0
    for flag, _ in next, flags.boxes do
        count = count + 1
        configstr = configstr .. "['" .. flag .. "']='" .. tostring(library.flags[flag]) .. "',"
    end


    configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},sliders={"


    count = 0
    for flag, _ in next, flags.sliders do
        count = count + 1
        configstr = configstr .. "['" .. flag .. "']=" .. tostring(library.flags[flag]) .. ","
    end


    configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},dropdowns={"


    count = 0
    for flag, _ in next, flags.dropdowns do
        count = count + 1
        configstr = configstr .. "['" .. flag .. "']='" .. tostring(library.flags[flag]) .. "',"
    end


    configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},multidropdowns={"


    count = 0
    for flag, _ in next, flags.multidropdowns do
        count = count + 1
        configstr = configstr .. "['" .. flag .. "']={'" .. table.concat(library.flags[flag], "','") .. "'},"
    end


    configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},keybinds={"


    count = 0
    for flag, _ in next, flags.keybinds do
        count = count + 1
        configstr = configstr .. "['" .. flag .. "']=" .. tostring(library.flags[flag]) .. ","
    end


    configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "},colorpickers={"


    count = 0
    for flag, _ in next, flags.colorpickers do
        count = count + 1
        configstr = configstr .. "['" .. flag .. "']=Color3.new(" .. tostring(library.flags[flag]) .. "),"
    end


    configstr = (count > 0 and configstr:sub(1, -2) or configstr) .. "}}"


    writefile(gameConfigFolder .. "/" .. name .. ".cfg", "return " .. configstr)
end
    
local gui = Instance.new("ScreenGui")
gui.Name = "markk"
gui.Parent = game.CoreGui

--SUBSCRIBE TO M4rkk--


function library:Load(opts)
    local options = utility.table(opts)
    local name = options.name or "Kram Library"

	local main = utility.create("Frame", {
	    Name = "main",
	    Size = UDim2.new(0, 360, 0, 250),
	    Position = UDim2.new(0, 10, 0, 10),
	    BackgroundColor3 = Color3.fromRGB(17, 17, 17),
	    BorderColor3 = Color3.fromRGB(0, 0, 0),
	    BorderSizePixel = 1,
	    Active = true,
	    BackgroundTransparency = 0,
	    Parent = gui
	})
	
	utility.create("UICorner", {
	    Name = "uicorner",
	    CornerRadius = UDim.new(0, 10),
	    Parent = main
	})
	
	local topbar = utility.create("Frame", {
	    Name = "topbar",
	    Size = UDim2.new(1, 0, 0, 30),
	    Position = UDim2.new(0, 0, 0, 0),
	    BackgroundTransparency = 1,
	    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	    BorderColor3 = Color3.fromRGB(0, 0, 0),
	    BorderSizePixel = 1,
	    Active = true,
	    Parent = main
	})
	
	utility.drag(topbar, main)
	
	utility.create("TextLabel", {
	    Name = "title",
	    Size = UDim2.new(0, 0, 1, 0),
	    Position = UDim2.new(0, 10, 0, 0),
	    BackgroundTransparency = 1,
	    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	    BorderColor3 = Color3.fromRGB(0, 0, 0),
	    BorderSizePixel = 1,
	    Text = name,
	    TextColor3 = Color3.fromRGB(255, 255, 255),
	    Font = Enum.Font.GothamSemibold,
	    TextSize = 15,
	    AutomaticSize = Enum.AutomaticSize.X,
	    Parent = topbar
	})
	
	local tabs = utility.create("Frame", {
	    Name = "tabs",
	    Size = UDim2.new(1, 0, 0, 30),
	    Position = UDim2.new(0, 0, 0, 30),
	    BackgroundTransparency = 1,
	    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	    BorderColor3 = Color3.fromRGB(0, 0, 0),
	    BorderSizePixel = 1,
	    Active = true,
	    Parent = main
	})
	
	local themechanger = utility.create("ImageButton", {
	    Name = "themechanger",
	    Size = UDim2.new(0, 25, 0, 25),
	    Position = UDim2.new(0, 10, 0, 2.5),
	    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	    ImageColor3 = Color3.fromRGB(255, 255, 255),
	    Image = "rbxassetid://123456789",
	    ImageTransparency = 0,
	    ScaleType = Enum.ScaleType.Stretch,
	    BackgroundTransparency = 0,
	    Parent = tabs
	})
	
	utility.create("UICorner", {
	    Name = "corner2",
	    CornerRadius = UDim.new(0, 10),
	    Parent = themechanger
	})
	
	local tabsholder = utility.create("Frame", {
	    Name = "tabsholder",
	    Size = UDim2.new(1, -55, 0, 25),
	    Position = UDim2.new(0, 45, 0, 2.5),
	    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	    BorderColor3 = Color3.fromRGB(0, 0, 0),
	    BorderSizePixel = 1,
	    Active = true,
	    BackgroundTransparency = 0,
	    Parent = tabs
	})
	
	utility.create("UICorner", {
	    CornerRadius = UDim.new(0, 10),
	    Parent = tabsholder
	})
	
	utility.create("UIListLayout", {
	    Name = "list",
	    SortOrder = Enum.SortOrder.LayoutOrder,
	    Padding = UDim.new(0, 0),
	    HorizontalAlignment = Enum.HorizontalAlignment.Left,
	    VerticalAlignment = Enum.VerticalAlignment.Center,
	    FillDirection = Enum.FillDirection.Horizontal,
	    Parent = tabsholder
	})

    local windowTypes = utility.table({count = 0})


    function windowTypes:Show()
        gui.Enabled = true
    end


    function windowTypes:Hide()
        gui.Enabled = false
    end
    
    local tab = utility.create("Folder", {
	    Name = "tabs",
	    Parent = main
	})
	
	local popups = utility.create("Folder", {
	    Name = "popups",
	    Parent = main
	})

    function windowTypes:Tab(name)
        windowTypes.count = windowTypes.count + 1
        name = name or "Tab"


        local toggled = windowTypes.count == 1

		local tabToggle = utility.create("TextButton", {
		    Name = "tabToggle",
		    Text = name,
		    BackgroundTransparency = 1,
		    TextColor3 = Color3.fromRGB(255, 255, 255),
		    Font = toggled and Enum.Font.GothamSemibold or Enum.Font.Gotham,
		    TextSize = 14,
		    Parent = tabsholder
		})
		
		tabToggle.Size = UDim2.new(0, tabToggle.TextBounds.X + 12, 1, 0)
		
		local container = utility.create("Frame", {
		    Name = "container",
		    Size = UDim2.new(1, -20, 1, -75),
		    Position = UDim2.new(0, 10, 0, 65),
		    BackgroundTransparency = 1,
			Visible = toggled,
		    Parent = tab
		})
		
		local left = utility.create("ScrollingFrame", {
		    Name = "left",
		    Size = UDim2.new(0.5, 0, 1, 0),
		    Position = UDim2.new(0, 0, 0, 0),
            ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
		    BackgroundTransparency = 1,
		    Parent = container
		})
		
		local right = utility.create("ScrollingFrame", {
		    Name = "right",
		    Size = UDim2.new(0.5, 0, 1, 0),
		    Position = UDim2.new(0.5, 0, 0, 0),
            ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0),
            ScrollBarImageTransparency = 1,
            ScrollBarThickness = 0,
		    BackgroundTransparency = 1,
		    Parent = container
		})
		
		utility.create("UIListLayout", {
		    Name = "list1",
		    SortOrder = Enum.SortOrder.LayoutOrder,
		    Padding = UDim.new(0, 5),
		    HorizontalAlignment = Enum.HorizontalAlignment.Center,
		    VerticalAlignment = Enum.VerticalAlignment.Top,
		    Parent = left
		})
		
		left.list1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		    left.CanvasSize = UDim2.new(0, 0, 0, left.list1.AbsoluteContentSize.Y)
		end)
		
		utility.create("UIListLayout", {
		    Name = "list2",
		    SortOrder = Enum.SortOrder.LayoutOrder,
		    Padding = UDim.new(0, 0),
		    HorizontalAlignment = Enum.HorizontalAlignment.Center,
		    VerticalAlignment = Enum.VerticalAlignment.Top,
		    Parent = right
		})
		
		right.list2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		    right.CanvasSize = UDim2.new(0, 0, 0, right.list2.AbsoluteContentSize.Y)
		end)
		
		local function openTab()
                for _, obj in next, tabsholder:GetChildren() do
                    if obj:IsA("TextButton") then
                        obj.Font = Enum.Font.Gotham
                    end
                end


                tabToggle.Font = Enum.Font.GothamSemibold


                for _, obj in next, tab:GetChildren() do
                    obj.Visible = false
                end


                container.Visible = true
            end


            tabToggle.MouseButton1Click:Connect(openTab)


            local tabTypes = utility.table()


            function tabTypes:Open()
                openTab()
            end
            
			function tabTypes:Section(opts)
                local options = utility.table(opts)
                local name = options.name or "Section"
                local column = options.column or 1
                
                local columnFrame = column == 1 and left or column == 2 and right
		
		
				local sectionHolder = utility.create("Frame", {
				    Name = "sectorframe",
				    Size = UDim2.new(1, 0, 0, 26),
				    BackgroundColor3 = Color3.fromRGB(22,22,22),
				    Parent = columnFrame
				})
				
				utility.create("UICorner", {
				    Name = "corner2",
				    CornerRadius = UDim.new(0, 10),
				    Parent = sectionHolder
				})
				
				local section = utility.create("Frame", {
                    ZIndex = 2,
                    Size = UDim2.new(1, -2, 1, -2),
                    BorderColor3 = Color3.fromRGB(22, 22, 22),
                    Position = UDim2.new(0, 1, 0, 1),
                    BackgroundTransparency = 1,
                    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
                    Parent = sectionHolder
                })
                
                local sectionTopbar = utility.create("Frame", {
                    ZIndex = 3,
                    Size = UDim2.new(1, 0, 0, 20),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Parent = section
                })


                utility.create("TextLabel", {
                    ZIndex = 3,
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 13,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Text = name,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sectionTopbar
                })


                local sectionContent = utility.create("Frame", {
                    Size = UDim2.new(1, -12, 1, -36),
                    Position = UDim2.new(0, 6, 0, 30),
                    BackgroundTransparency = 1,
                    Parent = section
                })
                
                local sectionContentList = utility.create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 6),
                    Parent = sectionContent
                })


                sectionContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    sectionHolder.Size = UDim2.new(1, -6, 0, sectionContentList.AbsoluteContentSize.Y + 38)
                end)


                local sectionTypes = utility.table()


                function sectionTypes:Show()
                    sectionHolder.Visible = true
                end


                function sectionTypes:Hide()
                    sectionHolder.Visible = false
                end
                
                function sectionTypes:Button(opts)
                    local options = utility.table(opts)
                    local name = options.name
                    local callback = options.callback


                    local button = utility.create("ImageButton", {
                        ZIndex = 3,
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundColor3 = Color3.fromRGB(32,32,32),
                        Parent = sectionContent
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 4,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 8, 0, 0),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = button
                    })
                    
                    utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 5),
					    Parent = button
					})
                   
                    
                    local buttonTypes = utility.table()


                    button.MouseButton1Click:Connect(function()
                        callback(buttonTypes)
                    end)


                    function buttonTypes:Show()
                        button.Visible = true
                    end
                    
                    function buttonTypes:Hide()
                        button.Visible = false
                    end
                    
                    function buttonTypes:SetName(str)
                        title.Text = str
                    end
                    
                    function buttonTypes:SetColor(r,g,b)
                        button.BackgroundColor3 = Color3.fromRGB(r,g,b)            
                    end


                    function buttonTypes:SetCallback(func)
                        callback = func
                    end
                    
                    return buttonTypes
                end
                
                function sectionTypes:Toggle(opts)
                    local options = utility.table(opts)
                    local name = options.name or "Toggle"
                    local default = options.default or false
                    local flag = options.flag 
                    local callback = options.callback or function() end


                    local toggled = default


                    if flag then
                        library.flags[flag] = toggled
                    end


                    callback(toggled)


                    local toggle = utility.create("ImageButton", {
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        Parent = sectionContent
                    })
                    
                    local icon = utility.create("ImageLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 18, 1, -2),
                        BorderColor3 = Color3.fromRGB(37, 37, 37),
                        Position = UDim2.new(0, 0, 0, 1),
                        BackgroundTransparency = 0,
                        ImageTransparency = default and 0 or 1,
                        Image = "rbxassetid://14203226653",
                        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
                        Parent = toggle
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 7, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = icon
                    })
                    
                    utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 5),
					    Parent = icon
					})


                    local function toggleToggle()
                        toggled = not toggled

                        local textColor = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                        if toggled then
	                        utility.tween(icon, {0.2}, {ImageTransparency = 0})
                        else
                            utility.tween(icon, {0.2}, {ImageTransparency = 1})
                        end

                        title.TextColor3 = textColor


                        if flag then
                            library.flags[flag] = toggled
                        end


                        callback(toggled)
                    end


                    toggle.MouseButton1Click:Connect(toggleToggle)


                    local toggleTypes = utility.table()


                    function toggleTypes:Show()
                        toggle.Visible = true
                    end
                    
                    function toggleTypes:Hide()
                        toggle.Visible = false
                    end
                    
                    function toggleTypes:SetName(str)
                        title.Text = str
                    end


                    function toggleTypes:Toggle(bool)
                        if toggled ~= bool then
                            toggleToggle()
                        end
                    end


                    if flag then
                        flags.toggles[flag] = function(bool)
                            if toggled ~= bool then
                                toggleToggle()
                            end
                        end
                    end


                    return toggleTypes
                end
                
                
               function sectionTypes:Slider(opts)
                    local options = utility.table(opts)
                    local name = options.name or "Slider"
                    local min = options.min or 0
                    local max = options.max or 100
                    local default = options.default or math.clamp(0, min, max)
                    local decimals = options.decimals or 0.1
                    local flag = options.flag
                    local callback = options.callback or function() end


                    decimals = math.floor(10^decimals)


                    if flag then
                        library.flags[flag] = default
                    end


                    callback(default)


                    local value = default


                    local sliding = false


                    local sliderframe = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 0, 20),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 0, 1, -13),
                        BackgroundTransparency = 1,
                        Parent = sectionContent
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        AutomaticSize = Enum.AutomaticSize.X,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = sliderframe
                    })
                    
                    local slider = utility.create("Frame", {
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(1, -25, 0.5, 0),
                        AnchorPoint = Vector2.new(1,0.5),
                        BackgroundColor3 = Color3.fromRGB(32,32,32),
                        Parent = sliderframe
                    })
                    
                    utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 5),
					    Parent = slider
					})
                    
                    local fill = utility.create("Frame", {
                        ZIndex = 4,
                        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                        BorderSizePixel = 0,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = slider
                    })
                    
                    utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 5),
					    Parent = fill
					})
					
					local valuedisplay = utility.create("TextBox", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 20, 0, 16),
                        BackgroundTransparency = 0,
                        Position = UDim2.new(1, -20, 0.5, 0),
                        AnchorPoint = Vector2.new(0,0.5),
                        BackgroundColor3 = Color3.fromRGB(25,25,25),
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        Text = value,
                        Font = Enum.Font.Gotham,
                        Parent = sliderframe
                    })
                    
                    utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 5),
					    Parent = valuedisplay
					})
					
                    utility.tween(slider, {0.45}, {Size = UDim2.new(1, -(title.TextBounds.X + 30), 0, 5)})

                    local function slide(input)
                        local sizeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
 
                       
                        value = math.floor((((max - min) * sizeX) + min) * decimals) / decimals
                        fill:TweenSize(UDim2.new((value - min) / (max - min), 0, 1, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)


                        if flag then 
                            library.flags[flag] = value
                        end


                        callback(value)
                        
                        valuedisplay.Text = tostring(value)
                    end


                    slider.InputBegan:Connect(function(input)
					    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					        sliding = true
					        slide(input)
					    end
					end)
					
					slider.InputEnded:Connect(function(input)
					    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					        sliding = false
					    end
					end)
					
					inputService.InputChanged:Connect(function(input)
					    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and sliding then
					        slide(input)
					    end
					end)
					
					valuedisplay.FocusLost:Connect(function(enterPressed)
					    local inputValue = tonumber(valuedisplay.Text)
					    if inputValue then
					        inputValue = math.clamp(inputValue, min, max)
					        value = math.floor(inputValue * decimals) / decimals
					        
					        if flag then
					            library.flags[flag] = value
					        end
					
					        callback(value)
					
					        fill:TweenSize(UDim2.new((value - min) / (max - min), 0, 1, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
					
					        valuedisplay.Text = tostring(value)
					    else
					        valuedisplay.Text = tostring(value)
					    end
					end)


                    local sliderTypes = utility.table()


                    function sliderTypes:Show()
                        slider.Visible = true
                    end


                    function sliderTypes:Hide()
                        slider.Visible = false
                    end


                    function sliderTypes:SetValueText(str)
                        valueText = str
                    end


                    function sliderTypes:Set(num)
                        num = math.floor(math.clamp(num, min, max) * decimals) / decimals
                        value = num
                        fill:TweenSize(UDim2.new((value - min) / (max - min), 0, 1, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)
                        
                        if flag then 
                            library.flags[flag] = value
                        end


                        callback(value)
                    end


                    function sliderTypes:SetMin(num)
                        min = num
                        value = math.floor(math.clamp(value, min, max) * decimals) / decimals
                        fill:TweenSize(UDim2.new((value - min) / (max - min), 0, 1, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)


                        if flag then 
                            library.flags[flag] = value
                        end


                        callback(value)
                    end


                    function sliderTypes:SetMax(num)
                        max = num
                        value = math.floor(math.clamp(value, min, max) * decimals) / decimals
                        fill:TweenSize(UDim2.new((value - min) / (max - min), 0, 1, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true)


                        if flag then 
                            library.flags[flag] = value
                        end


                        callback(value)
                    end


                    if flag then
                        flags.sliders[flag] = function(num)
                            sliderTypes:Set(num)
                        end
                    end


                    return sliderTypes
                end
                
                
                function sectionTypes:Dropdown(opts)
                    local options = utility.table(opts)
                    local name = options.name or "Dropdown"
                    local content = options.content or {}
                    local multiChoice = options.multiChoice or false
					local default = options.default or (multiChoice and {} or nil)
                    local flag = options.flag
                    local callback = options.callback or function() end




                    if flag then
                        library.flags[flag] = default
                    end
                    callback(default)


                    local opened = false


                    local current = default
                    local chosen = {}


                    local dropdownHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 0, 40),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = sectionContent
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 0, 18),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = dropdownHolder
                    })
                    
                    local open = utility.create("TextButton", {
                        ZIndex = 3,
                        Size = UDim2.new(1, 0, 0, 18),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 0, 0, 20),
                        BackgroundColor3 = Color3.fromRGB(32,32,32),
                        Text = "",
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = dropdownHolder
                    })
                    
                    utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 5),
					    Parent = open
					})
                    
                    local value = utility.create("TextLabel", {
                        ZIndex = 4,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        FontSize = Enum.FontSize.Size12,
                        TextSize = 12,
                        TextColor3 = (multiChoice and (#default > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180))) or default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180),
                        Text = multiChoice and (#default > 0 and table.concat(default, ", ") or "none") or (default or "none"),
                        Font = Enum.Font.Gotham,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = open
                    })
                    
                    local icon = utility.create("ImageLabel", {
                        ZIndex = 4,
                        Size = UDim2.new(0, 14, 0, 14),
                        Rotation = 180,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -16, 0, 1),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Image = "http://www.roblox.com/asset/?id=8747047318",
                        Parent = open
                    })
                    
                    local contentFrame = utility.create("Frame", {
                        ZIndex = 10,
                        Visible = false,
                        Size = UDim2.new(0, 160, 0, 0),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(0, 0, 1, 3),
                        BackgroundColor3 = Color3.fromRGB(33, 33, 33),
                        Parent = popups
                    })
                    
                    utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 5),
					    Parent = contentFrame
					})
                    
                    local function updatePickerPosition()
					contentFrame.Position = UDim2.new(0, open.AbsolutePosition.X + (open.AbsoluteSize.X / 2) - (contentFrame.AbsoluteSize.X / 2) - 10, 0, open.AbsolutePosition.Y - contentFrame.AbsoluteSize.Y - 15)
					end
					updatePickerPosition() 
					
					open:GetPropertyChangedSignal("AbsolutePosition"):Connect(updatePickerPosition)
                    
                    local contentHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 1, -4),
                        Position = UDim2.new(0, 0, 0, 2),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = contentFrame
                    })


                    local contentList = utility.create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = contentHolder
                    })


                    contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        contentFrame.Size = UDim2.new(0, 150, 0, contentList.AbsoluteContentSize.Y + 4)
                    end)
                    
                    local function close()
						contentFrame.Visible = false
					end
					close()
					
					local function openDropdown()
					    opened = not opened
                        icon.Rotation = opened and 0 or 180
					
					    if opened then
					        if library.activeColorPicker and library.activeColorPicker ~= picker then
					            library.activeColorPicker.Visible = false
					        end
					
					        library.activeColorPicker = picker
					        contentFrame.Visible = true
					
					    else
					        close()
					        if library.activeColorPicker == contentFrame then
					            library.activeColorPicker = nil
					        end
					    end
					end
                    
                    inputService.InputBegan:Connect(function(input, gpe)
					    if gpe then return end
						if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and contentFrame.Visible then
							local mousePos = inputService:GetMouseLocation() - guiInset
							local pos = contentFrame.AbsolutePosition
							local size = contentFrame.AbsoluteSize
					
							if not (mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and
									mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y) then
								close()
							end
						end
					end)


                    local function selectObj(obj, bool)
					    for i, v in next, contentHolder:GetChildren() do
					        if v:IsA("Frame") and v:FindFirstChild("optText") then
					            v.optText.Font = Enum.Font.Gotham
					        end
					    end
					
					    if obj:IsA("TextLabel") then
					        obj.Font = bool and Enum.Font.GothamSemibold or Enum.Font.Gotham
					    elseif obj:FindFirstChild("optText") then
					        obj.optText.Font = bool and Enum.Font.GothamSemibold or Enum.Font.Gotham
					    end
					
					    value.TextColor3 = bool and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
					end


                    local function multiSelectObj(obj, bool)
					    if obj:FindFirstChild("optText") then
					        obj.optText.Font = bool and Enum.Font.GothamSemibold or Enum.Font.Gotham
					        obj.optText.Position = bool and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0)
					    end
					    
					    if obj:FindFirstChild("check") then
					        obj.check.Visible = bool
					    end
					end
					                    
                    open.MouseButton1Click:Connect(openDropdown)


                    for _, opt in next, content do
	                    local option = utility.create("ImageButton", {
							ZIndex = 11,
						    Name = opt,
						    Size = UDim2.new(1, 0, 0, 20),
						    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						    BorderColor3 = Color3.fromRGB(0, 0, 0),
						    BorderSizePixel = 1,
						    Active = true,
						    BackgroundTransparency = 1,
						    Parent = contentHolder
						})
						
						local check = utility.create("ImageLabel", {
						    Name = "check",
						ZIndex = 12,
						    Size = UDim2.new(0, 16, 1, -4),
							Position = UDim2.new(0, 2, 0, 2),
						    ImageColor3 = Color3.fromRGB(255, 255, 255),
						    Image = "rbxassetid://14203226653",
						    Visible = false,
						    ImageTransparency = 0,
						    ScaleType = Enum.ScaleType.Stretch,
						    BackgroundTransparency = 1,
						    Parent = option
						})
						
						local optText = utility.create("TextLabel", {
						    Name = "optText",
						ZIndex = 12,
						    Size = UDim2.new(1, -20, 1, 0),
						    Position = UDim2.new(0, 0, 0, 0),
						    BackgroundTransparency = 1,
						    TextSize = 12,
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            Text = tostring(opt),
                            Font = current == opt and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
						    Parent = option
						})


                        option.MouseButton1Click:Connect(function()
                            if not multiChoice then
                                if current ~= opt then
                                    current = opt
                                    selectObj(option, true)
                                    value.Text = opt
                                    
                                    if flag then
                                        library.flags[flag] = opt
                                    end


                                    callback(opt)
                                else
                                    current = nil
                                    selectObj(option, false)
                                    value.Text = "none"


                                    if flag then
                                        library.flags[flag] = nil
                                    end


                                    callback(nil)
                                end
                            else
                                if not table.find(chosen, opt) then
                                    table.insert(chosen, opt)


                                    multiSelectObj(option, true)
                                    value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    value.Text = table.concat(chosen, ", ")
                                    
                                    if flag then
                                        library.flags[flag] = chosen
                                    end


                                    callback(chosen)
                                else
                                    table.remove(chosen, table.find(chosen, opt))


                                    multiSelectObj(option, false)
                                    value.TextColor3 = #chosen > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                                    value.Text = #chosen > 0 and table.concat(chosen, ", ") or "none"


                                    if flag then
                                        library.flags[flag] = chosen
                                    end


                                    callback(chosen)
                                end
                            end
                        end)
                    end


                    local dropdownTypes = utility.table()


                    function dropdownTypes:Show()
                        dropdownHolder.Visible = true
                    end


                    function dropdownTypes:Hide()
                        dropdownHolder.Visible = false
                    end


                    function dropdownTypes:SetName(str)
                        title.Text = str
                    end


                    function dropdownTypes:Set(opt)
                        if opt then
                            if typeof(opt) == "string" then
                                if table.find(content, opt) then
                                    if not multiChoice then
                                        current = opt
                                        selectObj(contentHolder:FindFirstChild(opt), true)
                                        value.Text = opt
                                        
                                        if flag then
                                            library.flags[flag] = opt
                                        end


                                        callback(opt)
                                    else
                                        table.insert(chosen, opt)


                                        multiSelectObj(contentHolder:FindFirstChild(opt), true)
                                        value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        value.Text = table.concat(chosen, ", ")
                                        
                                        if flag then
                                            library.flags[flag] = chosen
                                        end


                                        callback(chosen)
                                    end
                                end
                            elseif multiChoice then
                                table.clear(chosen)
                                chosen = opt


                                for i, v in next, opt do
                                    if contentHolder:FindFirstChild(v) then
                                        multiSelectObj(contentHolder:FindFirstChild(v), true)


                                        value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        value.Text = table.concat(chosen, ", ")
                                    end
                                end
                            end
                        else
                            if not multiChoice then
                                current = nil


                                for i, v in next, contentHolder:GetChildren() do
                                    if v:IsA("Frame") then
                                        v.optText.Font = Enum.Font.Gotham
                                    end
                                end


                                value.Text = "none"
                                value.TextColor3 = Color3.fromRGB(180, 180, 180)


                                if flag then
                                    library.flags[flag] = nil
                                end


                                callback(nil)
                            elseif multiChoice then
                                table.clear(chosen)


                                for i, v in next, contentHolder:GetChildren() do
                                    if v:IsA("Frame") then
                                        v.optText.Font = Enum.Font.GothamSemiBold
                                    end
                                end


                                value.TextColor3 = Color3.fromRGB(180, 180, 180)
                                value.Text = "none"


                                if flag then
                                    library.flags[flag] = chosen
                                end


                                callback(chosen)
                            end
                        end
                    end


                    function dropdownTypes:Add(opt)
                        table.insert(content, opt)
                        
                        local option = utility.create("ImageButton", {
							ZIndex = 11,
						    Name = opt,
						    Size = UDim2.new(1, 0, 0, 20),
						    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						    BorderColor3 = Color3.fromRGB(0, 0, 0),
						    BorderSizePixel = 1,
						    Active = true,
						    BackgroundTransparency = 1,
						    Parent = contentHolder
						})
						
						local check = utility.create("ImageLabel", {
						    Name = "check",
						ZIndex = 12,
						    Size = UDim2.new(0, 16, 1, -4),
							Position = UDim2.new(0, 2, 0, 2),
						    ImageColor3 = Color3.fromRGB(255, 255, 255),
						    Image = "rbxassetid://14203226653",
						    Visible = false,
						    ImageTransparency = 0,
						    ScaleType = Enum.ScaleType.Stretch,
						    BackgroundTransparency = 1,
						    Parent = option
						})
						
						local optText = utility.create("TextLabel", {
						    Name = "optText",
						ZIndex = 12,
						    Size = UDim2.new(1, -20, 1, 0),
						    Position = UDim2.new(0, 0, 0, 0),
						    BackgroundTransparency = 1,
						    TextSize = 12,
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            Text = tostring(opt),
                            Font = current == opt and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                            TextXAlignment = Enum.TextXAlignment.Left,
						    Parent = option
						})
                        
                        
                        option.MouseButton1Click:Connect(function()
                            if not multiChoice then
                                if current ~= opt then
                                    current = opt
                                    selectObj(option, true)
                                    value.Text = opt
                                    
                                    if flag then
                                        library.flags[flag] = opt
                                    end


                                    callback(opt)
                                else
                                    current = nil
                                    selectObj(option, false)
                                    value.Text = "none"


                                    if flag then
                                        library.flags[flag] = nil
                                    end


                                    callback(nil)
                                end
                            else
                                if not table.find(chosen, opt) then
                                    table.insert(chosen, opt)


                                    multiSelectObj(option, true)
                                    value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                    value.Text = table.concat(chosen, ", ")
                                    
                                    if flag then
                                        library.flags[flag] = chosen
                                    end


                                    callback(chosen)
                                else
                                    table.remove(chosen, table.find(chosen, opt))


                                    multiSelectObj(option, false)
                                    value.TextColor3 = #chosen > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                                    value.Text = #chosen > 0 and table.concat(chosen, ", ") or "none"


                                    if flag then
                                        library.flags[flag] = chosen
                                    end


                                    callback(chosen)
                                end
                            end
                        end)
                    end


                    function dropdownTypes:Remove(opt)
                        if table.find(content, opt) then
                            if not multiChoice then
                                if current == opt then
                                    dropdownTypes:Set(nil)
                                end


                                if contentHolder:FindFirstChild(opt) then
                                    contentHolder:FindFirstChild(opt):Destroy()
                                end
                            else
                                if table.find(chosen, opt) then
                                    table.remove(chosen, table.find(chosen, opt))
                                    value.TextColor3 = #chosen > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                                    value.Text = #chosen > 0 and table.concat(chosen, ", ") or "none"
                                end


                                if contentHolder:FindFirstChild(opt) then
                                    contentHolder:FindFirstChild(opt):Destroy()
                                end
                            end
                        end
                    end


                    function dropdownTypes:Refresh(tbl)
                        content = tbl
                        for _, opt in next, contentHolder:GetChildren() do
                            if opt:IsA("Frame") then
                                opt:Destroy()
                            end
                        end


                        dropdownTypes:Set(nil)


                        for _, opt in next, content do
	                        local option = utility.create("ImageButton", {
								ZIndex = 11,
							    Name = opt,
							    Size = UDim2.new(1, 0, 0, 20),
							    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							    BorderColor3 = Color3.fromRGB(0, 0, 0),
							    BorderSizePixel = 1,
							    Active = true,
							    BackgroundTransparency = 1,
							    Parent = contentHolder
							})
							
							local check = utility.create("ImageLabel", {
							    Name = "check",
							ZIndex = 12,
							    Size = UDim2.new(0, 20, 1, 0),
							    ImageColor3 = Color3.fromRGB(255, 255, 255),
							    Image = "rbxassetid://14203226653",
							    Visible = false,
							    ImageTransparency = 0,
							    ScaleType = Enum.ScaleType.Stretch,
							    BackgroundTransparency = 1,
							    Parent = option
							})
							
							local optText = utility.create("TextLabel", {
							    Name = "optText",
							ZIndex = 12,
							    Size = UDim2.new(1, -20, 1, 0),
							    Position = UDim2.new(0, 0, 0, 0),
							    BackgroundTransparency = 1,
							    TextSize = 12,
	                            TextColor3 = Color3.fromRGB(255, 255, 255),
	                            Text = tostring(opt),
	                            Font = current == opt and Enum.Font.GothamSemibold or Enum.Font.Gotham,
	                            TextXAlignment = Enum.TextXAlignment.Left,
							    Parent = option
							})
                            
                            
                            option.MouseButton1Click:Connect(function()
                                if not multiChoice then
                                    if current ~= opt then
                                        current = opt
                                        selectObj(option, true)
                                        value.Text = opt
                                        
                                        if flag then
                                            library.flags[flag] = opt
                                        end
        
                                        callback(opt)
                                    else
                                        current = nil
                                        selectObj(option, false)
                                        value.Text = "none"
        
                                        if flag then
                                            library.flags[flag] = nil
                                        end
        
                                        callback(nil)
                                    end
                                else
                                    if not table.find(chosen, opt) then
                                        table.insert(chosen, opt)
        
                                        multiSelectObj(option, true)
                                        value.TextColor3 = Color3.fromRGB(255, 255, 255)
                                        value.Text = table.concat(chosen, ", ")
                                        
                                        if flag then
                                            library.flags[flag] = chosen
                                        end
        
                                        callback(chosen)
                                    else
                                        table.remove(chosen, table.find(chosen, opt))
        
                                        multiSelectObj(option, false)
                                        value.TextColor3 = #chosen > 0 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                                        value.Text = #chosen > 0 and table.concat(chosen, ", ") or "none"
        
                                        if flag then
                                            library.flags[flag] = chosen
                                        end
        
                                        callback(chosen)
                                    end
                                end
                            end)
                        end
                    end


                    if flag then
                        if not multiChoice then
                            flags.dropdowns[flag] = function(opt)
                                dropdownTypes:Set(opt)
                            end
                        else
                            flags.multidropdowns[flag] = function(opt)
                                dropdownTypes:Set(opt)
                            end
                        end
                    end


                    return dropdownTypes
                end
                
                function sectionTypes:ColorPicker(opts)
                    local options = utility.table(opts)
                    local name = options.name or "Color Picker"
                    local default = options.default or Color3.fromRGB(255, 255, 255)
                    local flag = options.flag
                    local callback = options.callback or function() end


                    local open = false
                    local hue, sat, val = default:ToHSV()


                    local slidingHue = false
                    local slidingSaturation = false


                    local hsv = Color3.fromHSV(hue, sat, val)


                    if flag then
                        library.flags[flag] = default
                    end


                    callback(default)


                    local colorPickerHolder = utility.create("Frame", {
                        Size = UDim2.new(1, 0, 0, 20),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        Parent = sectionContent
                    })


                    local colorPicker = utility.create("ImageButton", {
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Parent = colorPickerHolder
                    })
                    
                    local title = utility.create("TextLabel", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 0, 1, 0),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        FontSize = Enum.FontSize.Size14,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Text = name,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = colorPicker
                    })
                    
                    local icon = utility.create("Frame", {
                        ZIndex = 3,
                        Size = UDim2.new(0, 24, 0, 18),
                        BorderColor3 = Color3.fromRGB(22, 22, 22),
                        Position = UDim2.new(1, -24, 0, 1),
                        BackgroundColor3 = default,
                        Parent = colorPicker
                    })
                    
                    local iconGradient = utility.create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 105, 105))
                        },
                        Parent = icon
                    })
                    
                    local picker = utility.create("Frame", {
						ZIndex = 3,
					    Size = UDim2.new(0, 200, 0, 140),
					    Position = UDim2.new(0.5, 0, 0, -145),
					    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
					    BorderColor3 = Color3.fromRGB(0, 0, 0),
					    BorderSizePixel = 1,
					    Active = true,
					    Visible = false,
					    BackgroundTransparency = 0,
					    Parent = popups
					})
					local function updatePickerPosition()
					picker.Position = UDim2.new(0, icon.AbsolutePosition.X + (icon.AbsoluteSize.X / 2) - (picker.AbsoluteSize.X / 2) - 10, 0, icon.AbsolutePosition.Y - picker.AbsoluteSize.Y - 15)
					end
					updatePickerPosition()
					
					icon:GetPropertyChangedSignal("AbsolutePosition"):Connect(updatePickerPosition)
					
					utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 5),
					    Parent = picker
					})
					
					local saturationFrame = utility.create("ImageLabel", {
						ZIndex = 4,
					    Name = "saturationFrame",
					    Size = UDim2.new(1, -30, 0, 100),
					    Position = UDim2.new(0, 5, 0, 5),
				        BackgroundColor3 = Color3.fromRGB(255, 0, 4),
				        Image = "http://www.roblox.com/asset/?id=8630797271",
					    Parent = picker
					})
					
					local saturationPicker = utility.create("Frame", {
				        ZIndex = 5,
				        Size = UDim2.new(0, 4, 0, 4),
				        Position = UDim2.new(0, 5, 0, 5),
				        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				        BorderColor3 = Color3.fromRGB(0, 0, 0),
				        BorderSizePixel = 1,
				        Parent = saturationFrame
				    })
					
					local hueFrame = utility.create("ImageLabel", {
						ZIndex = 4,
					    Name = "hueFrame",
					    Size = UDim2.new(0, 15, 0, 100),
					    Position = UDim2.new(1, -20, 0, 5),
						ClipsDescendants = true,
				        BackgroundColor3 = Color3.fromRGB(255, 0, 4),
				        ScaleType = Enum.ScaleType.Crop,
				        Image = "http://www.roblox.com/asset/?id=8630799159",
					    BackgroundTransparency = 1,
					    Parent = picker
					})
					
					local huePicker = utility.create("Frame", {
				        ZIndex = 5,
				        Size = UDim2.new(1, 0, 0, 2),
				        Position = UDim2.new(0, 0, 0, 10),
				        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				        BorderColor3 = Color3.fromRGB(0, 0, 0),
				        BorderSizePixel = 1,
				        Parent = hueFrame
				    })
					
					local rgb = utility.create("TextBox", {
						ZIndex = 5,
					    Name = "rgb",
					    Size = UDim2.new(0, 115, 0, 20),
					    Position = UDim2.new(0, 5, 1, -28),
					    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
					    BackgroundTransparency = 0,
				        TextSize = 12,
				        TextColor3 = Color3.fromRGB(255, 255, 255),
				        Text = table.concat({utility.get_rgb(default)}, ", "),
				        ClearTextOnFocus = false,
				        Font = Enum.Font.Gotham,
				        PlaceholderText = "R,  G,  B",
					    Parent = picker
					})
					
					utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 2),
					    Parent = rgb
					})
					
					local hex = utility.create("TextBox", {
						ZIndex = 5,
					    Name = "hex",
					    Size = UDim2.new(0, 70, 0, 20),
					    Position = UDim2.new(1, -75, 1, -28),
					    BackgroundColor3 = Color3.fromRGB(26, 26, 26),
					    BackgroundTransparency = 0,
				        PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
				        FontSize = Enum.FontSize.Size12,
				        TextSize = 12,
				        TextColor3 = Color3.fromRGB(255, 255, 255),
				        Text = utility.rgb_to_hex(default),
				        ClearTextOnFocus = false,
				        Font = Enum.Font.Gotham,
				        PlaceholderText = utility.rgb_to_hex(default),
					    Parent = picker
					})
					
					utility.create("UICorner", {
					    CornerRadius = UDim.new(0, 2),
					    Parent = hex
					})
                    

                    local function close()
						for i, v in next, picker:GetDescendants() do
						    if v:IsA("TextBox") then
						        utility.tween(v, {0.2}, {TextTransparency = 1})
						        utility.tween(v, {0.2}, {BackgroundTransparency = 1})
						    end
						    if v:IsA("ImageLabel") then
						        utility.tween(v, {0.2}, {ImageTransparency = 1})
						        utility.tween(v, {0.2}, {BackgroundTransparency = 1})
						    end
						    if v:IsA("Frame") then
						        utility.tween(v, {0.2}, {BackgroundTransparency = 1})
						    end
						end
						task.wait(.5)
						picker.Visible = false
					end
					close()
					
					local function openPicker()
					    open = not open
					
					    if open then
					        if library.activeColorPicker and library.activeColorPicker ~= picker then
					            library.activeColorPicker.Visible = false
					        end
					
					        library.activeColorPicker = picker
					        picker.Visible = true
					
					        for _, v in next, picker:GetDescendants() do
					            if v:IsA("TextBox") then
					                utility.tween(v, {0.2}, {TextTransparency = 0})
					                utility.tween(v, {0.2}, {BackgroundTransparency = 0})
					            elseif v:IsA("ImageLabel") then
					                utility.tween(v, {0.2}, {ImageTransparency = 0})
					                utility.tween(v, {0.2}, {BackgroundTransparency = 0})
					            elseif v:IsA("Frame") then
					                utility.tween(v, {0.2}, {BackgroundTransparency = 0})
					            end
					        end
					
					    else
					        close()
					        if library.activeColorPicker == picker then
					            library.activeColorPicker = nil
					        end
					    end
					end


                    colorPicker.MouseButton1Click:connect(openPicker)

					inputService.InputBegan:Connect(function(input, gpe)
					    if gpe then return end
						if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and picker.Visible then
							local mousePos = inputService:GetMouseLocation() - guiInset
							local pos = picker.AbsolutePosition
							local size = picker.AbsoluteSize
					
							if not (mousePos.X >= pos.X and mousePos.X <= pos.X + size.X and
									mousePos.Y >= pos.Y and mousePos.Y <= pos.Y + size.Y) then
								close()
							end
						end
					end)

                    local function updateHue(input)
                        local sizeY = 1 - math.clamp((input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y, 0, 1)
                        local posY = math.clamp(((input.Position.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 2)
                        huePicker.Position = UDim2.new(0, 0, 0, posY)


                        hue = sizeY


                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))


                        hsv = Color3.fromHSV(hue, sat, val)
                        saturationFrame.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv


                        if flag then 
                            library.flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end


                        callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end


                    hueFrame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            slidingHue = true
                            updateHue(input)
                        end
                    end)


                    hueFrame.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            slidingHue = false
                        end
                    end)


                    inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            if slidingHue then
                                updateHue(input)
                            end
                        end
                    end)


                    local function updateSatVal(input)
                        local sizeX = math.clamp((input.Position.X - saturationFrame.AbsolutePosition.X) / saturationFrame.AbsoluteSize.X, 0, 1)
                        local sizeY = 1 - math.clamp((input.Position.Y - saturationFrame.AbsolutePosition.Y) / saturationFrame.AbsoluteSize.Y, 0, 1)
                        local posY = math.clamp(((input.Position.Y - saturationFrame.AbsolutePosition.Y) / saturationFrame.AbsoluteSize.Y) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)
                        local posX = math.clamp(((input.Position.X - saturationFrame.AbsolutePosition.X) / saturationFrame.AbsoluteSize.X) * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)


                        saturationPicker.Position = UDim2.new(0, posX, 0, posY)


                        sat = sizeX
                        val = sizeY


                        hsv = Color3.fromHSV(hue, sat, val)


                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))


                        saturationFrame.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv


                        if flag then 
                            library.flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end


                        callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end


                    saturationFrame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            slidingSaturation = true
                            updateSatVal(input)
                        end
                    end)


                    saturationFrame.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            slidingSaturation = false
                        end
                    end)


                    inputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            if slidingSaturation then
                                updateSatVal(input)
                            end
                        end
                    end)


                    local colorPickerTypes = utility.table()


                    function colorPickerTypes:Show()
                        colorPickerHolder.Visible = true
                    end
                    
                    function colorPickerTypes:Hide()
                        colorPickerHolder.Visible = false
                    end
                    
                    function colorPickerTypes:SetName(str)
                        title.Text = str
                    end


                    function colorPickerTypes:SetRGB(color)
                        hue, sat, val = color:ToHSV()
                        hsv = Color3.fromHSV(hue, sat, val)


                        saturationFrame.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv
                        saturationPicker.Position = UDim2.new(0, (math.clamp(sat * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)), 0, (math.clamp((1 - val) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)))
                        huePicker.Position = UDim2.new(0, 0, 0, math.clamp((1 - hue) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 4))


                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))


                        if flag then 
                            library.flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end


                        callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end


                    function colorPickerTypes:SetHex(hexValue)
                        color = utility.hex_to_rgb(hexValue)
                        
                        hue, sat, val = color:ToHSV()
                        hsv = Color3.fromHSV(hue, sat, val)


                        saturationFrame.BackgroundColor3 = hsv
                        icon.BackgroundColor3 = hsv
                        saturationPicker.Position = UDim2.new(0, (math.clamp(sat * saturationFrame.AbsoluteSize.X, 0, saturationFrame.AbsoluteSize.X - 4)), 0, (math.clamp((1 - val) * saturationFrame.AbsoluteSize.Y, 0, saturationFrame.AbsoluteSize.Y - 4)))
                        huePicker.Position = UDim2.new(0, 0, 0, math.clamp((1 - hue) * hueFrame.AbsoluteSize.Y, 0, hueFrame.AbsoluteSize.Y - 4))


                        rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))


                        if flag then 
                            library.flags[flag] = Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255)
                        end


                        callback(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                    end


                    rgb.FocusLost:Connect(function()
                        local _, amount = rgb.Text:gsub(", ", "")
                        if amount == 2 then
                            local values = rgb.Text:split(", ")
                            local r, g, b = math.clamp(values[1], 0, 255), math.clamp(values[2], 0, 255), math.clamp(values[3], 0, 255)
                            colorPickerTypes:SetRGB(Color3.fromRGB(r, g, b))
                        else
                            rgb.Text = math.floor((hsv.r * 255) + 0.5) .. ", " .. math.floor((hsv.g * 255) + 0.5) .. ", " .. math.floor((hsv.b * 255) + 0.5)
                        end
                    end)
                        
                    hex.FocusLost:Connect(function()
                        if hex.Text:find("#") and hex.Text:len() == 7 then
                            colorPickerTypes:SetHex(hex.Text)
                        else
                            hex.Text = utility.rgb_to_hex(Color3.fromRGB(hsv.r * 255, hsv.g * 255, hsv.b * 255))
                        end
                    end)


                    hex:GetPropertyChangedSignal("Text"):Connect(function()
                        if hex.Text == "" then
                            hex.Text = "#"
                        end
                    end)


                    if flag then
                        flags.colorpickers[flag] = function(color)
                            colorPickerTypes:SetRGB(color)
                        end
                    end


                    return colorPickerTypes
                end
                
                
                return sectionTypes
            end


            return tabTypes
        end


        return windowTypes
    end

return library

--[[
local window = library:Load({
    name = "My Custom Library"
})

local mainTab = window:Tab("Main")
local secondTab = window:Tab("Second")

local mainSection = mainTab:Section({
    name = "Main Section",
    column = 1 -- 1 for left, 2 for right
})

mainSection:Toggle {
    Name = "Enabled",
    callback = function(v)
	    print(v)
    end
}

mainSection:Button {
    name = "Click Me",
    callback = function(self)
        print("Button pressed!")
    end
}

local secondSection = mainTab:Section({
    name = "Main Section",
    column = 1 -- 1 for left, 2 for right
})

secondSection:Toggle {
    Name = "Enabled",
    Default = true,
    callback = function(v)
	    print(v)
    end
}

local thirdSection = mainTab:Section({
    name = "third Section",
    column = 2 -- 1 for left, 2 for right
})

thirdSection:Toggle {
    Name = "Enabled",
    callback = function(v)
	    print(v)
    end
}

thirdSection:Slider {
name = "walkspeed",
    default = 30,
    min = 30,
    max = 150,
    decimals = 0,
    callback = function(v)
        
    end
}

thirdSection:Slider {
name = "jumppower",
    default = 30,
    min = 30,
    max = 150,
    decimals = 0,
    callback = function(v)
        
    end
}

thirdSection:ColorPicker {
    name = "ESP Color", -- label shown in UI
    default = Color3.fromRGB(255, 0, 0), -- starting color
    flag = "espColor", -- saves in library.flags
    callback = function(color)
        print("New color:", color)
    end
}

mainSection:ColorPicker {
    name = "Shoes Color", -- label shown in UI
    default = Color3.fromRGB(255, 0, 0), -- starting color
    flag = "espColor", -- saves in library.flags
    callback = function(color)
        print("New color:", color)
    end
}

mainSection:dropdown {
    name = "Aim",
    content = {"Head", "Torso", "HumanoidRootPart", "Right Arm", "Left Arm"},
    multichoice = false, -- true is multi dropdown false is regular dropdown
    default = "Torso",
    callback = function(bool) --
print(bool)
    end
}
]]

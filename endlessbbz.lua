local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RimuruOnDiscord/Halcyon/refs/heads/main/test.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

-- Service Setup
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Sub-Service Setup
local player = game:GetService("Players").LocalPlayer

-- Variable Setup
local holding = false
local connBegan, connEnded, connRender

-- Function Setup
local function getTargetRim()
    local teamName = player.Team and player.Team.Name

    if teamName == "Visitor" then
        return nil
    end

    if teamName == "Home" then
        return workspace.Court.Rims.RimHome.Rim
    end

    if teamName == "Away" then
        return workspace.Court.Rims.RimAway.Rim
    end

    return nil
end

local function lookAtYaw(fromPos, toPos)
    local flatTarget = Vector3.new(toPos.X, fromPos.Y, toPos.Z)
    return CFrame.lookAt(fromPos, flatTarget, Vector3.new(0,1,0))
           * CFrame.Angles(0, 0, 0)
end

local function enableAutoAim(enable)
    if enable then
        if connRender then return end  -- already enabled

        -- start tracking MouseButton1 down/up
        connBegan = UserInputService.InputBegan:Connect(function(inp, gp)
            if not gp and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                holding = true
            end
        end)
        connEnded = UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                holding = false
            end
        end)

        -- every frame while holding, snap HRP to face the correct rim
        connRender = RunService.RenderStepped:Connect(function()
            if not holding then return end

            local rimPart = getTargetRim()
            if not rimPart then return end

            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            hrp.CFrame = lookAtYaw(hrp.Position, rimPart.Position)
        end)

    else
        -- disconnect everything
        if connBegan then connBegan:Disconnect()   connBegan   = nil end
        if connEnded then connEnded:Disconnect()   connEnded   = nil end
        if connRender then connRender:Disconnect() connRender  = nil end
        holding = false
    end
end

-- Window Setup
local Window = Library:Window{
    Logo = "rbxassetid://74593959334913",
    TabWidth = 160,
    Size = UDim2.fromOffset(750, 540),
    Resize = true,
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
}

-- Tab Setup
local Tabs = {
    Automation = Window:Tab{ Title = "Core", Icon = "phosphor-cpu-bold"},
    SettingsTab = Window:Tab{ Title = "Settings", Icon = "phosphor-gear-six-bold"},
}

-- Section Setup
local assistanceSec = Tabs.Automation:Section("Assistance")

aimassisttoggle = assistanceSec:Toggle("aimtoggle", {
    Title = "Aim Assist",
    Default = false,
})

task.spawn(function()
    while true do
        if aimassisttoggle.Value then
        enableAutoAim(true)
        else
        enableAutoAim(false)
        end
        task.wait(0.5)
    end
end)

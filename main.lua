--// ESP PRO v3 – FULL FIXED FINAL
--// STABLE + ARROW v2 + SKELETON SMART 350
--// INSTANT SKELETON OFF FIX

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================
local Settings = {
    ESP = true,
    MaxDistance = 850,
    SkeletonDistance = 350,

    Modules = {
        Box = true,
        Name = true,
        Distance = true,
        Health = true,
        Skeleton = true,
        Line = true,
        Arrow = true,
    },

    HideTeam = true,
    ShowFPS = true,
}

--==================================================
-- GUI
--==================================================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ESP_PRO_V3"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(190, 300)
frame.Position = UDim2.fromOffset(20, 200)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,26)
title.Text = "ESP PRO v3 (F3)"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15

local function Toggle(text, y, tbl, key)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-10,0,22)
    b.Position = UDim2.fromOffset(5,y)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSans
    b.TextSize = 14
    b.Text = text..": ON"
    b.MouseButton1Click:Connect(function()
        tbl[key] = not tbl[key]
        b.Text = text..": "..(tbl[key] and "ON" or "OFF")
    end)
end

local y = 30
Toggle("ESP",y,Settings,"ESP") y+=24
for k in pairs(Settings.Modules) do
    Toggle(k,y,Settings.Modules,k)
    y+=24
end
Toggle("FPS / Ping",y,Settings,"ShowFPS")

UserInputService.InputBegan:Connect(function(i,gp)
    if not gp and i.KeyCode == Enum.KeyCode.F3 then
        gui.Enabled = not gui.Enabled
    end
end)

--==================================================
-- UTILS
--==================================================
local function IsEnemy(p)
    if not Settings.HideTeam then return true end
    return not (p.Team and LP.Team and p.Team == LP.Team)
end

--==================================================
-- VISIBILITY CACHE
--==================================================
local VisCache = {}
local VIS_INTERVAL = 0.15

local function IsVisible(p, hrp, char)
    local t = tick()
    local c = VisCache[p]
    if c and t - c.t < VIS_INTERVAL then
        return c.v
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LP.Character, char}
    params.IgnoreWater = true

    local hit = workspace:Raycast(
        Camera.CFrame.Position,
        hrp.Position - Camera.CFrame.Position,
        params
    )

    local v = hit == nil
    VisCache[p] = {v=v,t=t}
    return v
end

--==================================================
-- ARROW v2
--==================================================
local function GetArrowData(worldPos)
    local camCF = Camera.CFrame
    local dir = (worldPos - camCF.Position).Unit

    local angle = math.atan2(
        camCF.RightVector:Dot(dir),
        camCF.LookVector:Dot(dir)
    )

    local vp = Camera.ViewportSize
    local radius = math.min(vp.X, vp.Y)/2 - 25
    local center = vp/2

    local pos = center + Vector2.new(
        math.sin(angle),
        -math.cos(angle)
    ) * radius

    return pos, angle
end

--==================================================
-- MODULES
--==================================================
local Modules = {}
local function New(o) o.Visible = false return o end

Modules.Box = {
    Create = function()
        local b = New(Drawing.new("Square"))
        b.Thickness = 1
        return b
    end,
    Update = function(b,d)
        if not d.onScreen then b.Visible=false return end
        b.Size = d.boxSize
        b.Position = d.boxPos
        b.Color = d.color
        b.Visible = true
    end
}

Modules.Name = {
    Create = function()
        local t = New(Drawing.new("Text"))
        t.Size = 14
        t.Center = true
        return t
    end,
    Update = function(t,d)
        if not d.onScreen then t.Visible=false return end
        t.Text = d.player.Name
        t.Position = d.namePos
        t.Color = d.color
        t.Visible = true
    end
}

Modules.Distance = {
    Create = function()
        local t = New(Drawing.new("Text"))
        t.Size = 13
        t.Center = true
        return t
    end,
    Update = function(t,d)
        if not d.onScreen then t.Visible=false return end
        t.Text = math.floor(d.dist).."m"
        t.Position = d.distPos
        t.Color = d.color
        t.Visible = true
    end
}

Modules.Line = {
    Create = function()
        local l = New(Drawing.new("Line"))
        l.Thickness = 1
        return l
    end,
    Update = function(l,d)
        if not d.onScreen then l.Visible=false return end
        l.From = d.screenBottom
        l.To = d.screenPos
        l.Color = d.color
        l.Visible = true
    end
}

Modules.Health = {
    Create = function()
        return {
            Back = New(Drawing.new("Square")),
            Bar = New(Drawing.new("Square")),
            Text = New(Drawing.new("Text")),
        }
    end,
    Update = function(h,d)
        if not d.onScreen then
            h.Back.Visible=false
            h.Bar.Visible=false
            h.Text.Visible=false
            return
        end

        local hp = d.hp
        h.Back.Filled = true
        h.Back.Color = Color3.fromRGB(30,30,30)
        h.Back.Size = Vector2.new(4,d.boxSize.Y)
        h.Back.Position = Vector2.new(d.boxPos.X-7,d.boxPos.Y)
        h.Back.Visible = true

        h.Bar.Filled = true
        h.Bar.Size = Vector2.new(4,d.boxSize.Y*hp)
        h.Bar.Position = Vector2.new(
            d.boxPos.X-7,
            d.boxPos.Y+(d.boxSize.Y-d.boxSize.Y*hp)
        )
        h.Bar.Color =
            hp>0.7 and Color3.fromRGB(0,255,0)
            or hp>0.3 and Color3.fromRGB(255,200,0)
            or Color3.fromRGB(255,0,0)
        h.Bar.Visible = true

        h.Text.Text = math.floor(hp*100).."%"
        h.Text.Size = 13
        h.Text.Center = true
        h.Text.Color = Color3.new(1,1,1)
        h.Text.Position = Vector2.new(d.screenPos.X,d.boxPos.Y+d.boxSize.Y+4)
        h.Text.Visible = true
    end
}

Modules.Arrow = {
    Create = function()
        local t = New(Drawing.new("Triangle"))
        t.Filled = true
        return t
    end,
    Update = function(t,d)
        if d.onScreen then t.Visible=false return end
        local pos, angle = GetArrowData(d.worldPos)
        local size = 10
        t.PointA = pos + Vector2.new(math.sin(angle), -math.cos(angle)) * size
        t.PointB = pos + Vector2.new(math.sin(angle+2.4), -math.cos(angle+2.4)) * size*0.8
        t.PointC = pos + Vector2.new(math.sin(angle-2.4), -math.cos(angle-2.4)) * size*0.8
        t.Color = d.color
        t.Visible = true
    end
}

Modules.Skeleton = {
    Create = function()
        local bones = {
            {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
            {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
            {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
            {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
            {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
        }
        local lines = {}
        for _ in ipairs(bones) do
            local l = Drawing.new("Line")
            l.Thickness = 1
            l.Visible = false
            table.insert(lines,l)
        end
        return {Lines=lines,Bones=bones}
    end,

    Update = function(s,d)
        if not d.onScreen or d.dist > Settings.SkeletonDistance then
            for _,l in ipairs(s.Lines) do l.Visible=false end
            return
        end

        local char = d.player.Character
        if not char then return end

        for i,b in ipairs(s.Bones) do
            local a = char:FindFirstChild(b[1])
            local c = char:FindFirstChild(b[2])
            local l = s.Lines[i]
            if a and c then
                local p1,v1 = Camera:WorldToViewportPoint(a.Position)
                local p2,v2 = Camera:WorldToViewportPoint(c.Position)
                if v1 and v2 then
                    l.From = Vector2.new(p1.X,p1.Y)
                    l.To = Vector2.new(p2.X,p2.Y)
                    l.Color = d.color
                    l.Visible = true
                else
                    l.Visible=false
                end
            else
                l.Visible=false
            end
        end
    end
}

--==================================================
-- ESP CORE
--==================================================
local ESPs = {}

local function CreateESP(p)
    ESPs[p] = {}
    for name,mod in pairs(Modules) do
        ESPs[p][name] = mod.Create()
    end
end

local function HideObject(o)
    if typeof(o)=="table" then
        for _,x in pairs(o) do
            if typeof(x)=="userdata" then
                x.Visible=false
            end
        end
    elseif typeof(o)=="userdata" then
        o.Visible=false
    end
end

local function HideSkeleton(s)
    if not s or not s.Lines then return end
    for _,l in ipairs(s.Lines) do
        l.Visible = false
    end
end

Players.PlayerRemoving:Connect(function(p)
    ESPs[p] = nil
    VisCache[p] = nil
end)

--==================================================
-- FPS
--==================================================
local fpsText = Drawing.new("Text")
fpsText.Size = 14
fpsText.Color = Color3.new(1,1,1)
fpsText.Position = Vector2.new(10,65)
local frames,last = 0,tick()

--==================================================
-- RENDER LOOP
--==================================================
RunService.RenderStepped:Connect(function()
    frames+=1
    if tick()-last>=1 then
        fpsText.Text = "FPS: "..frames.." | Ping: "..math.floor(
            Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        )
        frames,last=0,tick()
    end
    fpsText.Visible = Settings.ShowFPS

    if not Settings.ESP then
        for _,e in pairs(ESPs) do
            for name,o in pairs(e) do
                if name=="Skeleton" then
                    HideSkeleton(o)
                else
                    HideObject(o)
                end
            end
        end
        return
    end

    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and IsEnemy(p) then
            local c = p.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChild("Humanoid")
            if not hrp or not hum or hum.Health<=0 then
                if ESPs[p] then
                    for name,o in pairs(ESPs[p]) do
                        if name=="Skeleton" then
                            HideSkeleton(o)
                        else
                            HideObject(o)
                        end
                    end
                end
                continue
            end

            if not ESPs[p] then CreateESP(p) end

            local pos,screen = Camera:WorldToViewportPoint(hrp.Position)
            local dist = (hrp.Position-Camera.CFrame.Position).Magnitude
            local visible = IsVisible(p,hrp,c)

            local data = {
                player = p,
                worldPos = hrp.Position,
                onScreen = screen and dist<=Settings.MaxDistance,
                color = visible and Color3.fromRGB(0,255,0) or Color3.new(1,1,1),
                dist = dist,
                hp = math.clamp(hum.Health/hum.MaxHealth,0,1),
                screenPos = Vector2.new(pos.X,pos.Y),
                screenBottom = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y),
                boxSize = Vector2.new(2000/dist,3000/dist),
            }

            data.boxPos = Vector2.new(
                data.screenPos.X-data.boxSize.X/2,
                data.screenPos.Y-data.boxSize.Y/2
            )
            data.namePos = Vector2.new(data.screenPos.X,data.boxPos.Y-30)
            data.distPos = Vector2.new(data.screenPos.X,data.boxPos.Y-14)

            for name,mod in pairs(Modules) do
                if Settings.Modules[name] then
                    mod.Update(ESPs[p][name],data)
                else
                    if name=="Skeleton" then
                        HideSkeleton(ESPs[p][name])
                    else
                        HideObject(ESPs[p][name])
                    end
                end
            end
        end
    end
end)

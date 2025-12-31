-- [[ KAITUN SEA 1: FULL MELEE & SKILLS (REAL NPC TRAVEL) ]]
if _G.KaitunS1Started then return end
_G.KaitunS1Started = true

-- 1. CẤU HÌNH
getgenv().Config = {
    FastAttack = true,
    BringMob = true,
    AutoStats = "Melee",
    AutoBuyMelee = true, -- Tự bay đến NPC mua võ (Black Leg, Electro, Water Kung Fu)
    AutoBuySkill = true, -- Tự bay đến NPC mua Buso, Geppo, Soru
    AutoRandomFruit = true,
    AutoStoreFruit = true
}

-- 2. BIẾN HỆ THỐNG
local plr = game.Players.LocalPlayer
local Root = plr.Character:WaitForChild("HumanoidRootPart")
local remote = game:GetService("ReplicatedStorage").Remotes.CommF_
local VU = game:GetService("VirtualUser")

function _tp(cf)
    pcall(function() plr.Character.HumanoidRootPart.CFrame = cf end)
end

-- 3. HÀM MUA VÕ & KỸ NĂNG (BAY ĐẾN NPC)
function BuyAtNPC(name)
    local Locations = {
        -- Võ V1
        ["BlackLeg"] = CFrame.new(-12433, 11, 4242),    -- Sanji (Baratie)
        ["Electro"] = CFrame.new(1125, 5, -4524),       -- Mad Scientist (Skypiea)
        ["FishmanKarate"] = CFrame.new(-4565, 15, 412),  -- Water Kung Fu (Underwater)
        -- Kỹ năng
        ["AbilityTeacher"] = CFrame.new(-4607, 28, 872)  -- NPC Đảo Tuyết (Buso, Geppo, Soru)
    }

    local targetCF = Locations[name]
    if targetCF then
        _G.ActiveFarm = false
        print("Đang bay đến NPC: " .. name)
        _tp(targetCF)
        task.wait(2) -- Chờ bay tới nơi

        if name == "BlackLeg" then remote:InvokeServer("BuyBlackLeg")
        elseif name == "Electro" then remote:InvokeServer("BuyElectro")
        elseif name == "FishmanKarate" then remote:InvokeServer("BuyFishmanKarate")
        elseif name == "AbilityTeacher" then
            local beli = plr.Data.Beli.Value
            if beli >= 100000 then remote:InvokeServer("BuyHaki", "Soru") end
            if beli >= 25000 then remote:InvokeServer("BuyHaki", "Buso") end
            if beli >= 10000 then remote:InvokeServer("BuyHaki", "Geppo") end
        end
        
        task.wait(1)
        _G.ActiveFarm = true
    end
end

-- 4. LOGIC KIỂM TRA MUA ĐỒ
task.spawn(function()
    while task.wait(30) do
        if game.PlaceId == 2753915549 then
            local beli = plr.Data.Beli.Value
            
            -- Kiểm tra mua Kỹ năng (Buso, Geppo, Soru)
            if getgenv().Config.AutoBuySkill and beli >= 25000 then
                BuyAtNPC("AbilityTeacher")
            end

            -- Kiểm tra mua Võ (Ưu tiên Black Leg trước để farm)
            if getgenv().Config.AutoBuyMelee then
                if beli >= 150000 and remote:InvokeServer("BuyBlackLeg", "Check") ~= 1 then
                    BuyAtNPC("BlackLeg")
                elseif beli >= 750000 and remote:InvokeServer("BuyFishmanKarate", "Check") ~= 1 then
                    BuyAtNPC("FishmanKarate")
                elseif beli >= 500000 and remote:InvokeServer("BuyElectro", "Check") ~= 1 then
                    BuyAtNPC("Electro")
                end
            end
        end
    end
end)

-- 5. FAST ATTACK & GOM QUÁI
task.spawn(function()
    while task.wait() do
        if getgenv().Config.FastAttack and _G.ActiveFarm then
            pcall(function()
                local tool = plr.Character:FindFirstChildOfClass("Tool")
                if tool and tool.ToolTip == "Melee" then
                    game:GetService("ReplicatedStorage").Remotes.Validator:FireServer(math.huge)
                    remote:InvokeServer("Attack", { [1] = 0 })
                    VU:Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().Config.BringMob and _G.ActiveFarm then
            pcall(function()
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        if (v.HumanoidRootPart.Position - Root.Position).Magnitude <= 300 then
                            v.HumanoidRootPart.CFrame = Root.CFrame * CFrame.new(0, 0, -5)
                            v.HumanoidRootPart.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. DATA NHIỆM VỤ SEA 1
local Quests = {
    {Level = 0, NPC = CFrame.new(1060, 16, 1547), QName = "BanditQuest1", QID = 1, Enemy = "Bandit"},
    {Level = 10, NPC = CFrame.new(-1598, 37, 153), QName = "MonkeyQuest1", QID = 1, Enemy = "Monkey"},
    {Level = 30, NPC = CFrame.new(-1598, 37, 153), QName = "MonkeyQuest1", QID = 2, Enemy = "Gorilla"},
    {Level = 60, NPC = CFrame.new(-1140, 4, 3828), QName = "PirateQuest1", QID = 1, Enemy = "Pirate"},
    {Level = 90, NPC = CFrame.new(-1140, 4, 3828), QName = "PirateQuest1", QID = 2, Enemy = "Brute"},
    {Level = 120, NPC = CFrame.new(897, 6, 4389), QName = "DesertQuest", QID = 1, Enemy = "Desert Bandit"},
    {Level = 175, NPC = CFrame.new(-4722, 10, 843), QName = "SnowQuest", QID = 1, Enemy = "Snow Bandit"},
    {Level = 250, NPC = CFrame.new(485, 6, 743), QName = "PrisonQuest", QID = 1, Enemy = "Chief Petty Officer"},
    {Level = 350, NPC = CFrame.new(-290, 7, 5300), QName = "MagmaQuest", QID = 2, Enemy = "Military Spy"},
    {Level = 425, NPC = CFrame.new(-5300, 2, 450), QName = "FishmanQuest", QID = 1, Enemy = "Fishman Warrior"},
    {Level = 575, NPC = CFrame.new(-4500, 515, -4400), QName = "SkyQuest", QID = 1, Enemy = "God's Guard"},
}

-- 7. VÒNG LẶP CHÍNH
task.spawn(function()
    while task.wait(0.1) do
        local lv = plr.Data.Level.Value
        
        -- Chuyển Sea 2 khi lv 700
        if lv >= 700 and game.PlaceId == 2753915549 then
            _G.ActiveFarm = false
            _tp(CFrame.new(-1030, 12, 1318)) -- Đảo Trung Tâm
            remote:InvokeServer("TravelZou")
            continue
        end

        -- Random & Cất trái
        if getgenv().Config.AutoRandomFruit then remote:InvokeServer("Cousin", "BuyFruit") end
        for _, v in pairs(plr.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.Name:find("Fruit") then
                remote:InvokeServer("StoreFruit", v:GetAttribute("FruitName") or v.Name, v)
            end
        end

        -- Nhận Quest và Farm
        local target = nil
        for i = #Quests, 1, -1 do if lv >= Quests[i].Level then target = Quests[i] break end end

        if target then
            if not plr.PlayerGui.Main.Quest.Visible then
                _G.ActiveFarm = false
                _tp(target.NPC)
                remote:InvokeServer("StartQuest", target.QName, target.QID)
            else
                _G.ActiveFarm = true
                local enemy = workspace.Enemies:FindFirstChild(target.Enemy)
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    for _, t in pairs(plr.Backpack:GetChildren()) do
                        if t.ToolTip == "Melee" then plr.Character.Humanoid:EquipTool(t) end
                    end
                    _tp(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
                else
                    _tp(target.NPC * CFrame.new(0, 50, 0))
                end
            end
        end

        -- Auto Stats
        local p = plr.Data.StatsPoints.Value
        if p > 0 then remote:InvokeServer("AddStats", getgenv().Config.AutoStats, p) end
    end
end)

print("Kaitun Sea 1: Full Melee & NPC Travel Loaded!")

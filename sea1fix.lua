-- [[ KAITUN SEA 1: PIRATE + REDEEM CODES + UI TRACKER ]]
if _G.KaitunFullLoaded then return end
_G.KaitunFullLoaded = true

local replicated = game:GetService("ReplicatedStorage")
local remote = replicated.Remotes.CommF_
local plr = game.Players.LocalPlayer

-- 1. TẠO UI TRACKER (GIAO DIỆN THEO DÕI)
local ScreenGui = Instance.new("ScreenGui", plr.PlayerGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0

local function createLabel(text, pos)
    local label = Instance.new("TextLabel", MainFrame)
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Position = UDim2.new(0, 0, 0, pos)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Text = text
    return label
end

local lvLabel = createLabel("Level: 0", 10)
local beliLabel = createLabel("Beli: 0", 40)
local fragLabel = createLabel("Frag: 0", 70)
local masteryLabel = createLabel("Melee Mastery: 0", 100)

task.spawn(function()
    while task.wait(1) do
        lvLabel.Text = "Level: " .. plr.Data.Level.Value
        beliLabel.Text = "Beli: " .. plr.Data.Beli.Value
        fragLabel.Text = "Frag: " .. plr.Data.Fragments.Value
        local tool = plr.Backpack:FindFirstChildOfClass("Tool") or plr.Character:FindFirstChildOfClass("Tool")
        if tool and tool.ToolTip == "Melee" then
            masteryLabel.Text = "Melee Mastery: " .. (tool:FindFirstChild("Level") and tool.Level.Value or 0)
        end
    end
end)

-- 2. AUTO REDEEM CODES
task.spawn(function()
    local codes = {"KITT_RESET", "Sub2CaptainMaui", "DEVSCOOKING", "Sub2Fer999", "Enyu_is_Pro", "Magicbus", "JCWK", "Starcodeheo", "Bluxxy", "fudd10_v2", "FUDD10", "BIGNEWS", "SUB2GAMERROBOT_EXP1", "Sub2NoobMaster123", "Sub2UncleKizaru", "Sub2OfficialNoobie", "TheGreatAce", "Axiore", "Sub2Daigrock", "TantaiGaming", "STRAWHATMAINE"}
    for _, v in pairs(codes) do remote:InvokeServer("RedeemFreeCode", v) task.wait(0.1) end
end)

-- 3. CHỌN PHE HẢI TẶC
pcall(function()
    if plr.Team == nil or plr.Team.Name ~= "Pirates" then remote:InvokeServer("SetTeam", "Pirates") end
end)

-- 4. LOGIC FARM CHẮC CHẮN (FIX KẸT)
_G.ActiveFarm = true
function _tp(cf)
    pcall(function() plr.Character.HumanoidRootPart.CFrame = cf end)
end

function EquipMelee()
    for _, tool in pairs(plr.Backpack:GetChildren()) do
        if tool.ToolTip == "Melee" then plr.Character.Humanoid:EquipTool(tool) break end
    end
end

-- FAST ATTACK & GOM QUÁI
task.spawn(function()
    while task.wait() do
        if _G.ActiveFarm then
            pcall(function()
                local tool = plr.Character:FindFirstChildOfClass("Tool")
                if tool and tool.ToolTip == "Melee" then
                    replicated.Remotes.Validator:FireServer(math.huge)
                    remote:InvokeServer("Attack", { [1] = 0 })
                    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
                for _, v in pairs(workspace.Enemies:GetChildren()) do
                    if v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        if (v.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 300 then
                            v.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                            v.HumanoidRootPart.CanCollide = false
                        end
                    end
                end
            end)
        end
    end
end)

-- 5. DATA NHIỆM VỤ
local Quests = {
    {Level = 0, NPC = CFrame.new(1060, 16, 1547), QName = "BanditQuest1", QID = 1, Enemy = "Bandit"},
    {Level = 10, NPC = CFrame.new(-1598, 37, 153), QName = "MonkeyQuest1", QID = 1, Enemy = "Monkey"},
    {Level = 30, NPC = CFrame.new(-1598, 37, 153), QName = "MonkeyQuest1", QID = 2, Enemy = "Gorilla"},
    {Level = 60, NPC = CFrame.new(-1140, 4, 3828), QName = "PirateQuest1", QID = 1, Enemy = "Pirate"},
    {Level = 175, NPC = CFrame.new(-4722, 10, 843), QName = "SnowQuest", QID = 1, Enemy = "Snow Bandit"},
    {Level = 250, NPC = CFrame.new(485, 6, 743), QName = "PrisonQuest", QID = 1, Enemy = "Chief Petty Officer"},
    {Level = 425, NPC = CFrame.new(-5300, 2, 450), QName = "FishmanQuest", QID = 1, Enemy = "Fishman Warrior"},
    {Level = 575, NPC = CFrame.new(-4500, 515, -4400), QName = "SkyQuest", QID = 1, Enemy = "God's Guard"},
}

-- VÒNG LẶP THỰC THI CHÍNH
task.spawn(function()
    while task.wait(0.5) do
        local lv = plr.Data.Level.Value
        if not plr.PlayerGui.Main.Quest.Visible then
            local target = nil
            for i = #Quests, 1, -1 do if lv >= Quests[i].Level then target = Quests[i] break end end
            if target then
                _tp(target.NPC)
                wait(1)
                remote:InvokeServer("StartQuest", target.QName, target.QID)
            end
        else
            EquipMelee()
            local questLabel = plr.PlayerGui.Main.Quest.Container.QuestTarget.Text
            local enemyName = questLabel:gsub("Kill ", ""):gsub(" %d+/%d+", "")
            local targetEnemy = workspace.Enemies:FindFirstChild(enemyName)
            
            if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") then
                _tp(targetEnemy.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
            else
                -- Fix lỗi kẹt: Bay đến vị trí quái dự kiến nếu không thấy quái hiện diện
                for i = #Quests, 1, -1 do
                    if lv >= Quests[i].Level then _tp(Quests[i].NPC * CFrame.new(0, 50, 0)) break end
                end
            end
        end
        -- Auto Stats Melee
        local p = plr.Data.StatsPoints.Value
        if p > 0 then remote:InvokeServer("AddStats", "Melee", p) end
    end
end)

print("Kaitun Sea 1: UI Stats + Anti-Stuck Loaded!")

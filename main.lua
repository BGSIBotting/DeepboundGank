if game.PlaceId ~= 85896571713843 then return end
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
--local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
--local EggList = loadstring(game:HttpGet("https://raw.githubusercontent.com/BGSIBotting/DeepboundGank/refs/heads/main/extra/egglist.lua"))()
local RiftList = loadstring(game:HttpGet("https://raw.githubusercontent.com/BGSIBotting/DeepboundGank/refs/heads/main/extra/rifts.lua"))()

local Window = Fluent:CreateWindow({
    Title = "DEEPBOUND GANK",
    SubTitle = "Don't ever go to the depths alone...",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
})

local Tabs = {
    Farming = Window:AddTab({Title = "Farming", Icon = "tractor"}),
    Hatching = Window:AddTab({Title = "Hatching", Icon = "egg"}),
    Rifts = Window:AddTab({Title = "Rifts", Icon = "tree-palm"}),
    Teleports = Window:AddTab({Title = "Teleports", Icon = "audio-waveform"}),
    Config = Window:AddTab({Title = "Config", Icon = "settings"})
}

local Options = Fluent.Options

local Event = ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent

local Webhooks = {
    Underworld = "https://webhook.lewisakura.moe/api/webhooks/1371602689611534407/UV2446W6NDufLBNx6N27trxcodVPIH32f5w0C7anZfXUenHxh9Vj0o_e_mOaJwK-Emmj",
    Island = "https://webhook.lewisakura.moe/api/webhooks/1371603830378205386/7hWqS8XiI3mbBK8PezeMSO0Wj_U-5AMR579hEmsSJas2liPb3jhs86LSOalQa6Z7hiI9",
    Special = "https://discord.com/api/webhooks/1371604553295859774/gNWvBpTdqwwftw3B1l5Hep2DHbpp3-IjjN8YqtrMrbLCdqB3sVzFJBhjaWLndsaUrkhs",
    Misc = "https://webhook.lewisakura.moe/api/webhooks/1371604235380064299/GxlWZKtClN98n70IMdPIe5ws58NcvTlATVJ4DabNqm03oazSVV7TI2f5QT2Dm4hcaYW4",
}

local Tasks = {}

local function BlowBubble()
    while task.wait() do
        Event:FireServer("BlowBubble")
    end
end

local CachedRifts = {}

local AutoBlow = Tabs.Farming:AddToggle("BlowToggle", {Title = "Auto Blow", Default = false})
--local AutoSell = Tabs.Farming:AddToggle("SellToggle", {Title = "Auto Sell", Default = false})

--[[local EggDropdown = Tabs.Hatching:AddDropdown("Egg", {
    Title = "Egg",
    Values = EggList,
    Multi = false,
    Default = 1
})]]


local function Send(Data: {}, Webhook: string)
    print(Webhook)
    if Data and Webhook then
        request({
            Url = Webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(Data)
        })
    end    
end

local function RiftSend(Rift: Model, RiftData: string)
    local Multi = "---"

    if RiftData == "Island" or RiftData == "Underworld" then
       Multi = Rift:WaitForChild("Display"):WaitForChild("SurfaceGui"):WaitForChild("Icon"):WaitForChild("Luck").Text
    end

    local Time = Rift:WaitForChild("Display"):WaitForChild("SurfaceGui"):WaitForChild("Timer").Text
    local Deeplink = `roblox://experiences/start?placeId={game.PlaceId}&gameInstanceId={game.JobId}`

    local Webhook = Webhooks[RiftData] or Webhooks.Misc
    
    if RiftData == "Island" and Multi ~= "x25" then return end

    Send({
        embeds = {
            {
                title = "RIFT FOUND",
                            color = 5814783,
                            fields = {
                                {
                                    name = "Type",
                                    value = Rift.Name,
                                    inline = true
                                },
                                {
                                    name = "Multiplier",
                                    value = Multi,
                                    inline = true
                                },
                                {
                                    name = "Time Left",
                                    value = Time,
                                    inline = true
                                },
                                {
                                    name = "Players",
                                    value = `{#Players:GetPlayers()}/{Players.MaxPlayers}`,
                                    inline = true
                                },
                                {
                                    name = "Height",
                                    value = `Y {math.round(Rift.Display.Position.Y)}`,
                                    inline = true
                                },
                                {
                                    name = "Join Link",
                                    value = Deeplink,
                                    inline = false
                                },
                            }
            }                    
        }
    }, Webhook)
end

--local AutoHatch = Tabs.Hatching:AddToggle("HatchToggle", {Title = "Auto Hatch", Default = false})
local AnnounceRift = Tabs.Rifts:AddToggle("AnnounceRift", {Title = "Announce Rifts", Default = false})

AutoBlow:OnChanged(function()
    print(Options.BlowToggle.Value)
    if Options.BlowToggle.Value == true then
        Tasks.AutoBlow = task.spawn(BlowBubble)
    else
        if Tasks.AutoBlow then
           task.cancel(Tasks.AutoBlow)
           Tasks.AutoBlow = nil 
        end
    end
end)

AnnounceRift:OnChanged(function()
    if Options.AnnounceRift.Value == true then
        task.spawn(function()
            for _, Rift in pairs(workspace.Rendered.Rifts:GetChildren()) do
                local RiftData = RiftList[Rift.Name]
                if RiftData and (not CachedRifts[Rift]) then
                    CachedRifts[Rift] = true

                    RiftSend(Rift, RiftData)
                end
            end
        end)

        Tasks.AnnounceRift = workspace.Rendered.Rifts.ChildAdded:Connect(function(Rift: Model)
            local RiftData = RiftList[Rift.Name]
            if RiftData and (not CachedRifts[Rift]) then
                CachedRifts[Rift] = true

                task.spawn(RiftSend, Rift, RiftData)
            end
        end)
    end
end)

SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("BGSI")

SaveManager:BuildConfigSection(Tabs.Config)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()

if game.PlaceId ~= 85896571713843 then return end
repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local EggList = loadstring(game:HttpGet("https://raw.githubusercontent.com/BGSIBotting/DeepboundGank/refs/heads/main/extra/egglist.lua"))()
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

local Settings = {}
local Tasks = {}

local function BlowBubble()
    while Options.AutoBlow.Value == true do
        Event:FireServer("BlowBubble")
        task.wait()
    end
end

local function HatchEgg()
    
end

local CachedRifts = {}

local AutoBlow = Tabs.Farming:AddToggle("BlowToggle", {Title = "Auto Blow", Default = false})
local AutoSell = Tabs.Farming:AddToggle("SellToggle", {Title = "Auto Sell", Default = false})

local EggDropdown = Tabs.Hatching:AddDropdown("Egg", {
    Title = "Egg",
    Values = EggList,
    Multi = false,
    Default = 1
})

local function Send()

end

local AutoHatch = Tabs.Hatching:AddToggle("HatchToggle", {Title = "Auto Hatch", Default = false})

local AnnounceRift = Tabs.Rifts:AddToggle("AnnounceRift", {Title = "Announce Rifts", Default = false})

local AddWebhook = Tabs.Config:AddInput("Webhook", {
    Title = "Add Webhook",
    Default = "",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        Settings.Webhook = Value
    end
})

AutoBlow:OnChanged(function()
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
        for _, Rift in pairs(workspace.Rendered.Rifts:GetChildren()) do
            if RiftList[Rift.Name] and (not CachedRifts[Rift]) then
                CachedRifts[Rift] = true

                print("dealealeal")
            end
        end

        Tasks.AnnounceRift = workspace.Rendered.Rifts.ChildAdded:Connect(function(Child: Model)
            if RiftList[Child.Name] and (not CachedRifts[Child]) then
                CachedRifts[Child] = true

                print("dealealeal")
            end
        end)
    end
end)

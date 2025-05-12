if game.PlaceId ~= 85896571713843 then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local EggList = loadstring(game:HttpGet("https://raw.githubusercontent.com/BGSIBotting/DeepboundGank/refs/heads/main/extra/egglist.lua"))()

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

local AutoBlow = Tabs.Farming:AddToggle("BlowToggle", {Title = "Auto Blow", Default = false})
local AutoSell = Tabs.Farming:AddToggle("SellToggle", {Title = "Auto Sell", Default = false})

local EggDropdown = Tabs.Hatching:AddDropdown("Dropdown", {
    Title = "Egg",
    Values = EggList,
    Multi = false,
    Default = 1
})

task.spawn(function()
    local args = {
        "BlowBubble"
    }

    while Options.BlowToggle.Value == true do
        print("Blowing bubble")
        ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent:FireServer(unpack(args))
        task.wait()
    end
end)

task.spawn(function()
     local args = {
        "SellBubble"
    }

    while Options.SellToggle.Value == true do
        ReplicatedStorage.Shared.Framework.Network.Remote.RemoteEvent:FireServer(unpack(args))
        task.wait(5)
    end
end)

task.spawn(function()
    while task.wait(2) do
        print(Options.BlowToggle.Value, Options.SellToggle.Value)
    end
end)


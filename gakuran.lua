local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UIS = game:GetService("UserInputService")
local SelectedFolder = nil
local CycleKeybind = Enum.KeyCode.X

-- Caching functions for micro-optimization
local os_clock = os.clock
local math_max = math.max
local table_find = table.find

local URL = "https://raw.githubusercontent.com/artxficial/matchastuff/main/esp_utility.lua"
local ImportESP = loadstring(game:HttpGet(URL))()

local URL = "https://raw.githubusercontent.com/artxficial/matchastuff/main/animationtracker.lua"
local ImportAnimationTracker = loadstring(game:HttpGet(URL))()

local UI_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui

local AnimationsLoggedCache = {}
local AnimationsLoggedOrder = {}

local ESPUtility = ImportESP or ESP_Utility
local AnimationTrackerModule = ImportAnimationTracker or AnimationTracker

if not UI_Library or not ESPUtility or not AnimationTrackerModule then
    error("[AutoParry] A required dependency failed to initialize")
end

local Environment = (getgenv and getgenv()) or _G
if Environment.__GAKURAN_AUTO_PARRY_CLEANUP then
    pcall(Environment.__GAKURAN_AUTO_PARRY_CLEANUP)
end

local RuntimeConnections = {}

local function TrackConnection(runtimeConnection)
    if runtimeConnection then
        table.insert(RuntimeConnections, runtimeConnection)
    end
    return runtimeConnection
end

local Traceback = (debug and debug.traceback) or function(err)
    return tostring(err)
end

local ToggleDamageLogger


-- ==========================================
-- Game Configuration
-- ==========================================

local GameName = "Gakuran"

local GameConfig = {
    ["KarateAnims"] = {
        ["rbxassetid://137837926745158"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://100981571094705"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://130865087635587"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://86495068205420"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://120393553812903"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
    },

    ["BasicAnims"] = {
        ["rbxassetid://83491849294956"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://89420531853362"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://83730275893449"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://106980660082799"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://78888626472394"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["M1Time"] = 0.14,
    },
    ["WrestlingAnims"] = {
        ["rbxassetid://91485623489753"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://73748315742870"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://82903450925391"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://119685134442395"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://107464726433388"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
        },
        ["M1Time"] = 0.11,

    },
    ["MuayThaiAnims"] = {
        ["rbxassetid://137034747040618"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://74960202100098"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://104515319350296"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://139911027872047"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
            
        },
        ["rbxassetid://96726284968458"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
        },
        ["M1Time"] = 0.1,        
    },
    ["BoxingAnims"] = {
        ["rbxassetid://137980914350618"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.12,
        },
        ["rbxassetid://100408082509740"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.12,
        },
        ["rbxassetid://94803478352691"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
            
        },
        ["rbxassetid://78695517680318"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://132022052139564"] = {
            DisplayName = "M2",
            ParryFunction = function(data)
                if data.RegistryData.Processed == true then warn("no") return end 
                
                data.RegistryData.Processed = true
                task.spawn(function()
                    print("Boxing parry")
                    task.wait(.3)
                    Dodge()
                    task.wait(.35)
                    BlockStart(os_clock(), 0.6)
                end)
            end,
        },
    },
    ["HakariAnims"] = {
        ["rbxassetid://82855179231529"] = {
            DisplayName = "MomentumM2"
        },
        ["rbxassetid://76236532060812"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://74206130671324"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://71919935695307"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://122861547142657"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.21,
        },
        ["rbxassetid://92851992709496"] = {
            DisplayName = "M2",
            ReactionTime = 0.35,
        },
    },
    ["CapoeiraAnims"] = {
        ["rbxassetid://125976167173936"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://134945199381140"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://117877243065533"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://106965238908791"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://131071815103338"] = {
            DisplayName = "Whirlwind",
            ReactionTime = 0.32,
        }
    },
    ["SluggerAnims"] = {
        ["rbxassetid://134829666925953"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.24,
        },
        ["rbxassetid://104867156139010"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://112759168172605"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.22
        },
        ["rbxassetid://114647502301740"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.19,
        },
        ["rbxassetid://118943955490014"] = {
            DisplayName = "M2",
            ReactionTime = 0.65,
        }
    },
    ["StrikerAnims"] = {
        ["rbxassetid://127909081017342"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://79563637573277"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://118070233153900"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://77710266587706"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://114364673509520"] = {
            DisplayName = "M2"
        },
        ["rbxassetid://132840225082238"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://88761422474765"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://98462236639320"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://122451562066756"] = {
            DisplayName = "4thM1"
        }
    },
    ["KureAnims"] = {
        ["rbxassetid://71676634048602"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://102407060635393"] = {
            DisplayName = "M2",
            ["ReactionTime"] = 0.01,
        },
        ["rbxassetid://82904229252991"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://103732110215321"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://103964436023727"] = {
            DisplayName = "3rdM1"
        },
    },
    ["HakariOtherAnims"] = {
        ["rbxassetid://126612786608030"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://113719263885794"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://136305578634960"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://89039586375625"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://82855179231529"] = {
            DisplayName = "MomentumM2"
        },
        ["rbxassetid://101619248052969"] = {
            DisplayName = "M2"
        },
    },
}

local IgnoreIds = {
73766443218740,111699625251889,85823794654077,83600639547203,99661732639863,106268941365574,109816855387997,122561749929324,129805948180599,
90752347516770,135133599113049,132695091086148,137015026151472,114511731321756,122541287927198,80309578200579,100794890036133,109303037515668,117293898907979,74690341409113,73090768467054,72284079162560,92787945841620,89016181362524,
76945839486275,101161965631044,80135556847061,128307941333158,85931837451298,91352556581859, 104407197874289,77911299793653,129335968179665, 122384188141033,
132695766056641,113331696487725,124220338099067,99799500309776,108636808436488,90015977935891,87932588807124,132477488202815,102982320608759,109278619250401,79971841883936,97783129267001,72822821848529,79974955602012,77798715679680,85845666927963,108862846290180,108045962864902,93184693099565,120399899079666,99958962160522,
}


local ParriedAnimation = {"rbxassetid://100773926241456", "rbxassetid://102823909334302", "rbxassetid://96304721384743", "rbxassetid://82979105739696", "rbxassetid://96600699015093",
"rbxassetid://138519505081692",
}
-- 5645212799 blocking anim

local StunnedAnimation = {"rbxassetid://9598562590", "rbxassetid://9598537410", "rbxassetid://9598551746"}
local ParryingAnimation = {"rbxassetid://118147060185189"}
local ParryFailed = {"rbxassetid://4210597123"} -- BlockHit


local AutoParryRange = 10
local MaxCycleRange = 20
local ParryWindow = 0.06
local ProbabilityToParry = 100
local DefaultReactionTime = 0.1
local ParryOffset = 0
local BlockHoldTime = 0.4


-- ==========================================
local FlattenedConfig = {}

for styleName, assets in pairs(GameConfig) do

    for assetId, data in pairs(assets) do
        if assetId == "M1Time" then continue end
        if assets["M1Time"] then end 
        local flatData = table.clone(data) or {}  
        flatData.Style = styleName
        if data.DisplayName ~= "M2" and assets["M1Time"] then  
            flatData.ReactionTime = assets["M1Time"]
        elseif not data.ReactionTime then 
            flatData.DefaultReactionTime = DefaultReactionTime
        else 
            flatData.ReactionTime = data.ReactionTime
        end
        
        FlattenedConfig[assetId] = flatData
    end
end

GameConfig = FlattenedConfig

local AnimationIdSliders = {}

local function GetAllFoldersInWorkspace()
    local Folders = {}

    for _, Folder in game.Workspace:GetChildren() do  
        if Folder.ClassName == "Folder" then
            table.insert(Folders, Folder.Name)
        end
    end

    return Folders
end

local function GetAllCharactersInFolder()
    if not SelectedFolder or not game.Workspace:FindFirstChild(SelectedFolder) then UI_Library:Notify("ERROR", "Select a folder first") return end 
    

    local Characters = {}
    local SelectedFolder = game.Workspace[SelectedFolder]


    for _, Character in SelectedFolder:GetChildren() do  
        if Character.ClassName == "Model" and Character:FindFirstChildWhichIsA("Humanoid") then
            if not IncludeLocalCharacter then 
                if Character.Address == game.Players.LocalPlayer.Character.Address then continue end 
            end
            table.insert(Characters, Character)
        end
    end

    return Characters
end

local function SetClipboardLoggedCache()
    local totalItems = #AnimationsLoggedOrder
    if totalItems == 0 then
        print("[Clipboard] Nothing logged to copy.")
        return
    end

    local ids = {}
    for i = 1, totalItems do
        -- Extract only the numbers from the asset ID string
        local numericId = tostring(AnimationsLoggedOrder[i]):match("%d+")
        if numericId then
            table.insert(ids, numericId)
        end
    end

    local clipboardString = table.concat(ids, ",")
    
    setclipboard(clipboardString)
    print(string.format("[Clipboard] Successfully copied %d logged animation IDs!", #ids))
    UI_Library:Notify("Clipboard", string.format("Successfully copied %d logged animation IDs!", #ids))
end

local function SetClipboardIgnoreList()
    local totalItems = #AnimationsLoggedOrder
    if totalItems == 0 then
        print("[Clipboard] Nothing logged to copy.")
        return
    end
    
    local newlyAddedIds = {}

    for AnimationId, AnimData in pairs(AnimationsLoggedCache) do  
        local numericId = tonumber(string.match(tostring(AnimationId), "%d+"))
        
        if numericId then
            table.insert(IgnoreIds, numericId)
            
            table.insert(newlyAddedIds, tostring(numericId))
        end
    end

    local outputstring = table.concat(newlyAddedIds, ", ")
    setclipboard(outputstring)    

    print(string.format("[Clipboard] Copied %d NEW IDs! (Total historical ignored count is now: %d)", #newlyAddedIds, #IgnoreIds))
end

local function AnimationGrabber(Folder)
    local OutputLines = {"{"}
    
    for _, Style in Folder:GetChildren() do
        if not Style.Name:find("Anims") then continue end
        
        local styleAnimations = {}
        
        for _, Animation in Style:GetChildren() do              
            if Animation.Name:find("M1") or Animation.Name:find("M2") then 
                local AnimationIdPointer = memory_read("uintptr_t", Animation.Address + 192)
                local AnimationId = memory_read("string", AnimationIdPointer) or ""
                -- Format the individual animation entry
                local animString = string.format('      ["%s"] = {\n          DisplayName = "%s"\n      }', AnimationId, Animation.Name)
                table.insert(styleAnimations, animString)
            end 
        end
        
        if #styleAnimations > 0 then
            table.insert(OutputLines, string.format('   ["%s"] = {', Style.Name))
            table.insert(OutputLines, table.concat(styleAnimations, ",\n"))
            table.insert(OutputLines, '   },')
        end
    end
    
    table.insert(OutputLines, "}")
    
    local Output = table.concat(OutputLines, "\n")
    setclipboard(Output)
    print(Output)
end
--AnimationGrabber(game.ReplicatedStorage.Animations.Combat)

local function LiteGrabber(Folder)
    local OutputLines = {}
    for _, Animation in Folder:GetChildren() do              
        local AnimationIdPointer = memory_read("uintptr_t", Animation.Address + 192)
        local AnimationId = memory_read("string", AnimationIdPointer) or ""
        local String = `Name: {Animation.Name} | Id: {AnimationId}`
        table.insert(OutputLines, String)
    end

    local Output = table.concat(OutputLines, "\n")
    setclipboard(Output)
    print(Output)
end
--LiteGrabber(game.ReplicatedStorage.Assets.Anims.Weapon.Spear)

local function UpdateSliders(OldReactionTime)
    for animationId, Info in pairs(GameConfig) do 
        if AnimationIdSliders[animationId] then
            Info.DefaultReactionTime = DefaultReactionTime
            local ReactionTime = Info.M1Time or Info.ReactionTime or Info.DefaultReactionTime
            AnimationIdSliders[animationId]:Set(ReactionTime)            
        end
    end
end

local scheduler = {}
local pendingTasks = {}

function scheduler.delay(delayTime, callback)
    table.insert(pendingTasks, {
        executeAt = os_clock() + delayTime,
        callback = callback
    })
end

function scheduler.update()
    local now = os_clock()
    for i = #pendingTasks, 1, -1 do
        local task = pendingTasks[i]
        if now >= task.executeAt then
            table.remove(pendingTasks, i)

            task.spawn(function()
                local ok, callbackError = xpcall(task.callback, Traceback)
                if not ok then
                    warn("[Scheduler] " .. tostring(callbackError))
                end
            end)
        end
    end
end

-- ==========================================

-- ==========================================


local UI_Window = UI_Library:CreateWindow({ 
    title = "Auto Parry Builder", 
    size = Vector2.new(700, 580),
    configFolder = "auto_parry_builder",
 })

local AP_Tab = UI_Window:Tab("Auto Parry", "swords")
local Config_Tab = UI_Window:Tab("Style Configurations", "swords")

local Files_Section = AP_Tab:Section("Files", "Left")
local Config_Section = AP_Tab:Section("Global Configuration", "Left")
local AP_Section = AP_Tab:Section("Settings", "Right")
local Folders_Section = AP_Tab:Section("Folders", "Right")
local ClipboardSection = AP_Tab:Section("Logging", "Left")

local TargetPool_Text = Folders_Section:Label("NO TARGETS FOUND") 

local Hint = AP_Section:Label("You have to press X in order to target someone or turn on Auto Target Nearest")
local AutoParryToggle = AP_Section:Toggle("Auto Parry", true):AddKeybind("g", "Toggle")
local AutoDodgeToggle = AP_Section:Toggle("Auto Dodge", true)

local ParryDebugToggle = Config_Section:Toggle("Debug Parry", false)

local AutoTargetNearest = AP_Section:Toggle("Auto Target Nearest", false)
local MuliTarget = AP_Section:Toggle("Multiple Targets", true)

local TargetFacingYou = nil
local YouFacingTarget = nil

local LoggedText = ClipboardSection:Label("Logged Ids: ?")
local IgnoredText = ClipboardSection:Label("Ignored Ids: ?")

local function UpdateTargetPoolSection(Tab)
    local characters = GetAllCharactersInFolder() 
    local names = {}
    
    for i, character in ipairs(characters) do
        table.insert(names, character.Name)

        if i == 10 then table.insert(names, "... (too long)") break end 
    end

    local poolString = table.concat(names, ", ")
    TargetPool_Text:SetText("Target Pool: ".. poolString)
end

local function UpdateClipboardSection()
    local IgnoredIdsCount = #IgnoreIds
    local AnimationsLoggedCount = 0 

    for i, v in pairs(AnimationsLoggedCache) do  
        AnimationsLoggedCount += 1
    end

    LoggedText:SetText("Logged Ids: ".. AnimationsLoggedCount)
    IgnoredText:SetText("Ignored Ids: ".. #IgnoreIds)
end

local function CreateFoldersSection()
    local folders = GetAllFoldersInWorkspace()

    local Range = Folders_Section:Slider("Max Cycle Range", 10, 1, 7, 50, "", function(v)
        MaxCycleRange = v
    end)
    Range:Set(MaxCycleRange)


    local IncludeLocalCharacterToggle = Folders_Section:Toggle("Include Local Character", false, function(on)
        IncludeLocalCharacter = on
        UpdateTargetPoolSection()   
    end)

    local FolderCombo = Folders_Section:Dropdown("Live Folder", nil, folders, false, function(list)
        local Selected = list[1]
        SelectedFolder = Selected
        UpdateTargetPoolSection(Tab)
    end)

    if game.Workspace:FindFirstChild("Players") then  
        FolderCombo:Set({"Players"})
    elseif game.Workspace:FindFirstChild("Live") then 
        FolderCombo:Set({"Live"})
    end

    print("[UI] Folders Section Created")
end

local function CreateGroupSliders()
    local GroupedStyles = {}
    
    for animationId, Info in pairs(GameConfig) do  
        local StyleName = Info.Style
    --   if Info.DisplayName == "M2" or not StyleName or not Info.M1Time then continue end 

        if not GroupedStyles[StyleName] then
            GroupedStyles[StyleName] = {}
        end
        
        GroupedStyles[StyleName][animationId] = Info
    end

    local Number = 1
    for StyleName, Animations in pairs(GroupedStyles) do
        local Side = (Number % 2 == 1) and "Left" or "Right"
        local StyleSection = Config_Tab:Section(StyleName, Side)
        
        for animationId, Info in pairs(Animations) do
            local nameLabel = Info.DisplayName or tostring(animationId)
            if Info["ParryFunction"] then  
                StyleSection:Label("Slider not possible for ".. nameLabel .. " since it uses a function" )
                continue
            end
            
            
            AnimationIdSliders[animationId] = StyleSection:Slider("Reaction Time: " .. nameLabel, 0, 0.01, 0, 1, "", function(v)
                if v ~= DefaultReactionTime then
                    Info.ReactionTime = v                    
                end
            end)
            
            AnimationIdSliders[animationId]:Set(Info.M1Time or Info.ReactionTime or DefaultReactionTime)
        end
        
        Number += 1
    end
end

local function CreateAPSection()

    AP_Section:Divider("Conditions")

    TargetFacingYou = AP_Section:Toggle("Target facing you", false)
    YouFacingTarget = AP_Section:Toggle("You facing target", true)
    
    local Offset = Config_Section:Slider("Parry offset", 0, 0.01, -0.1, 0.1, "s",function(v)
        ParryOffset = v
    end)
    Offset:Set(ParryOffset)
    Config_Section:Label("Positive moves window forward making you parry later, Negative moves it backwards making you parry earlier")    
    
    local Range = Config_Section:Slider("Auto Parry Range", 40, 1, 7, 80, "", function(v)
        AutoParryRange = v
    end)
    Range:Set(AutoParryRange)

    local Probability = Config_Section:Slider("Probability To Parry", 100, 1, 1, 100, "%", function(v)
        ProbabilityToParry = v
    end)
    Probability:Set(ProbabilityToParry)

    local DefaultSection = Config_Tab:Section("Default Configuration", "left")
    
    local Time = DefaultSection:Slider("Default Reaction Time", 0.3, 0.01, 0, 1, "", function(v)
        DefaultReactionTime = v
        UpdateSliders()
    end)
    Time:Set(DefaultReactionTime)
    DefaultSection:Label("Reaction time is the time you press F from the moment the animation starts playing. It does not account for ping")

    DefaultSection:Divider("Window")
    
    local Window = DefaultSection:Slider("Default Parry Window", 0.3, 0.01, 0, 1, "", function(v)
        ParryWindow = v
        --ReleaseTime = ParryWindow/2
    end)
    Window:Set(ParryWindow)
    DefaultSection:Label("This is usually constant, don't change this.")
    
end

local function CreateClipboardSection()
    -- 1. Define the UI element configurations in a clean list
    local elements = {
        {
            Type = "Toggle",
            Name = "Damage Logs",
            Default = false,
            Callback = function(on)
                ToggleDamageLogger(on)
            end
        },
        {
            Type = "Toggle",
            Name = "Add unknowns to ignore and copy ignore list",
            Default = false,
            Keybind = "v", -- Just define the keybind right here!
            Callback = function(on, self) 
                SetClipboardIgnoreList()
                AnimationsLoggedCache = {}
                AnimationsLoggedOrder = {}
                UpdateClipboardSection()
            end
        },
        {
            Type = "Toggle",
            Name = "Copy to clipboard",
            Keybind = "c",
            Callback = function()
                SetClipboardLoggedCache()
            end
        },
        {
            Type = "Toggle",
            Name = "Clear animation cache",
            Keybind = "k",
            Callback = function()
                AnimationsLoggedCache = {}
                AnimationsLoggedOrder = {}
                UpdateClipboardSection()
            end
        }
    }

    -- 2. Loop through the list and dynamically construct the UI
    for _, config in ipairs(elements) do
        local instance

        if game.PlaceId == 128736949265057 then 
            config.Type = "Button"
        end

        if config.Type == "Toggle" then
            instance = ClipboardSection:Toggle(config.Name, config.Default, function(on)
                if on then  
                    config.Callback(on, instance)                    
                end
                instance:Set(false) 
            end)

            if config.Keybind then
                instance:AddKeybind(config.Keybind, "Toggle")
            end

        elseif config.Type == "Button" then
            instance = ClipboardSection:Button(config.Name, config.Callback)
        end
    end
end

local function CreateFilesSection()

    Files_Section:Info("Game: "..GameName)

    local Load = Files_Section:Button("Load Configuration", function()
        local configData = UI_Library:LoadConfig(GameName)
        UI_Library:Notify("Success", "Loaded configuration")
    end)

    local Save = Files_Section:Button("Save Configuration", function()
        UI_Library:SaveConfig(GameName)
        UI_Library:Notify("Success", "Saved configuration")
    end)
end

CreateFoldersSection()
CreateAPSection()
CreateGroupSliders()
CreateFilesSection()

UpdateClipboardSection()
CreateClipboardSection()

-- ==========================================
local PARRY_DISTANCE = 15
local ORB_TRIGGER_COOLDOWN = 0.10
local lastOrbParryAt = 0

local function GetLocalHRP()
    local localCharacter = LocalPlayer.Character
    return localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") or nil
end

function checkRange(studs, origin)
    local localRoot = GetLocalHRP()
    return localRoot ~= nil
        and origin ~= nil
        and (localRoot.Position - origin.Position).Magnitude < studs
end

local ActiveOrbs = {}

local function ListenForOrbs()
    print("[Orb] Optimized listener active")
    local thrownFolder = game.Workspace:WaitForChild("Thrown", 5)
    if not thrownFolder then return end

    -- Lọc vật thể khi chúng vừa sinh ra
    TrackConnection(thrownFolder.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") and (child.Name == "ArdourBall2" or child.Name == "ArdourBall") then
            ActiveOrbs[child] = true
        end
    end))

    TrackConnection(thrownFolder.ChildRemoved:Connect(function(child)
        if ActiveOrbs[child] then
            ActiveOrbs[child] = nil
        end
    end))

    return TrackConnection(RunService.Heartbeat:Connect(function()
        if not AutoParryToggle.Get() then
            return
        end

        local now = os_clock()
        if now - lastOrbParryAt < ORB_TRIGGER_COOLDOWN then
            return
        end

        local localRoot = GetLocalHRP()
        if not localRoot then return end

        local localPos = localRoot.Position
        for orb, _ in pairs(ActiveOrbs) do
            if orb.Parent and (localPos - orb.Position).Magnitude <= PARRY_DISTANCE then
                if BlockStart(now, 0.10) then
                    lastOrbParryAt = now
                end
                break
            end
        end
    end))
end

-- ==========================================
-- Configs 
-- ==========================================

local ParryKey = string.byte("F")
local DodgeKey = string.byte("Q")

local KeyHeld = false
local ReleaseDeadline = 0
local LastBlockInputAt = 0
local MIN_INPUT_INTERVAL = 0.04

local Stunned = false

local AnimationTracker = AnimationTrackerModule.new(IgnoreIds)
local LocalTracker = AnimationTrackerModule.new(IgnoreIds)

local IncludeLocalCharacter = false

local connection = nil
local previousHealth = 100
local lastCharacter = nil

local TargetCharacters = {}
local EspTrackers = {} 

local CurrentIndex = 1
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_RED = Color3.fromRGB(255, 50, 50)
local COLOR_GREEN = Color3.fromRGB(50, 255, 50)

-- Keep target selection and animation checks active, but render no ESP on bodies.
local SHOW_TARGET_ESP = false

local AnimationRegistry = {}
local LastPendingRegData = nil
local InputRegisteredTime = nil
local ParryRegisteredTime = nil
local InputLatency = 0 -- (Parry - Input)

local OnInputF


local ParryState = {
    IDLE = "idle",

    INPUT_PENDING = "input_pending",   -- F was pressed locally, waiting for animation to appear
    PARRYING = "parrying",             -- Animation just appeared
    PARRYINGFAILED = "parryingfailed",       -- Animation didn't appear (Happens when you're on parry cooldown)

    STUNNED = "stunned",
    WINDOW_EXCEEDED = "window_exceeded", -- If you exceed the window cuz ur not targeting or ur

    SUCCESS = "parrysuccess"       -- Parrying animation was detected so its parrying right now
}

local CurrentParryState = ParryState.IDLE
-- ==========================================
-- Helpers
-- ==========================================

ToggleDamageLogger = function(state)
    if not state then
        if connection then
            connection:Disconnect()
            connection = nil
        end
        print("[Logger] Heartbeat damage logger DISABLED.")
        return
    end

    if connection then
        return
    end

    print("[Logger] Heartbeat damage logger ACTIVE.")

    connection = TrackConnection(RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end

        if character ~= lastCharacter then
            lastCharacter = character
            previousHealth = humanoid.Health
            return
        end

        local currentHealth = humanoid.Health
        if currentHealth < previousHealth and #TargetCharacters > 0 then
            local damageTaken = previousHealth - currentHealth

            for _, targetCharacter in ipairs(TargetCharacters) do
                local activeAnimations = AnimationTracker:Update(targetCharacter) or {}

                for _, anim in ipairs(activeAnimations) do
                    local timePosition = anim.TimePosition or 0
                    if anim.AnimationId and timePosition >= 0.1 and timePosition <= 0.7 then
                        local assetId = tostring(anim.AnimationId)
                        local poolData = GameConfig[assetId]

                        warn(string.format(
                            "[HIT] %.1f DMG | Anim: %s (%s) %s | Frame Time: %.3f",
                            damageTaken,
                            poolData and poolData.DisplayName or anim.Name or "Unknown",
                            assetId,
                            poolData and poolData.Style or "",
                            timePosition
                        ))
                    end
                end
            end
        end

        previousHealth = currentHealth
    end))
end

-- ==========================================
-- Parry Core Logic
-- ==========================================


local function GetHeightMultiplierForCharacter(TargetCharacter)
    local succ, data = pcall(function()
        local stateFolder = TargetCharacter and TargetCharacter:FindFirstChild("PlayerData")    
        return stateFolder:GetAttribute("CurrentHeight")
    end)
    if succ then  
        return data
    else
     --   print("failed to get height")
        return 1
    end
end

local function ResetParryState()
    KeyHeld = false
    ReleaseDeadline = 0
    BlockEnd()
    InputRegisteredTime = nil
end

function Dodge()
    BlockEnd()

    task.spawn(function()
        keypress(DodgeKey)
        task.wait(0.035)
        keyrelease(DodgeKey)
    end)
end

function BlockStart(startTime, holdFor)
    local now = os_clock()
    startTime = startTime or now

    if not AutoParryToggle.Get() then
        return false
    end

    if CurrentParryState ~= ParryState.IDLE then
        return false
    end

    if now - LastBlockInputAt < MIN_INPUT_INTERVAL then
        return false
    end

    if not OnInputF or not OnInputF(now) then
        return false
    end

    LastBlockInputAt = now
    ReleaseDeadline = math_max(now, startTime) + (holdFor or BlockHoldTime)
    KeyHeld = true

    if ismouse1pressed and ismouse1pressed() and mouse2click then
        mouse2click()
    end

    keypress(ParryKey)
    return true
end

function BlockEnd()
    KeyHeld = false
    keyrelease(ParryKey)
end


-- ==========================================
-- STATE MACHINE
-- ==========================================

local function TransitionToState(newState)
    print(string.format("[Parry] %s -> %s", CurrentParryState, newState))
    CurrentParryState = newState
end

--                  ==[Input State]==
-- Local F keypress
OnInputF = function(inputTime)
    if CurrentParryState ~= ParryState.IDLE then
        return false
    end

    InputRegisteredTime = inputTime or os_clock()
    TransitionToState(ParryState.INPUT_PENDING)
    return true
end


local function DebugParry()
-- 1. Network Variables (These never rely on the parry window data, so we always calculate them)
    local WeActuallyBlockedAt = ParryRegisteredTime
    local WeWantedToBlockAt = InputRegisteredTime
    local TimeTheServerReceived = InputLatency / 2

    if LastPendingRegData then
        -- 2. Animation Variables (Only extracted if the data actually exists)
        local AnimationStartTime = LastPendingRegData.StartTime
        local BlockStart = LastPendingRegData.BlockStart
        local BlockExpire = LastPendingRegData.BlockExpire
        
        -- Relative Offsets (How far into the animation the window is)
        local RelativeBlockStart = BlockStart - AnimationStartTime   -- e.g., 0.300s
        local RelativeBlockExpire = BlockExpire - AnimationStartTime -- e.g., 0.650s
        
        -- Timeline Calculations
        local ClientReactionTime = WeWantedToBlockAt - AnimationStartTime -- Relative to Anim Start (0)
        local ServerRelativeTime = (WeActuallyBlockedAt - TimeTheServerReceived) - AnimationStartTime -- Relative to Anim Start (0)
        
        local IsSuccess = (ClientReactionTime >= RelativeBlockStart and ClientReactionTime <= RelativeBlockExpire)        
        ----------------------------------------------------------------------
        -- FULL DIAGNOSTICS LOG (Data Exists)
        ----------------------------------------------------------------------
        print(string.format(
            "\n================ PARRY DIAGNOSTICS ================\n" ..
            "[NETWORK STATE]\n" ..
            "Total Input Latency:  %.3fs\n" ..
            "One-Way Server Delay: %.3fs\n" ..
            "---------------------------------------------------\n" ..
            "[ANIMATION TIMELINE]\n" ..
            "Target Parry Window:  %.3fs to %.3fs\n" ..
            "Pressed F At:    %.3fs\n" ..
            "Parry Registered At:  %.3fs (ONE-WAY)\n" ..
            "---------------------------------------------------\n" ..
            "[VERDICT]\n" ..
            "Status:               %s\n" ..
            "===================================================",
            InputLatency,
            TimeTheServerReceived,
            RelativeBlockStart, 
            RelativeBlockExpire,
            ClientReactionTime,
            ServerRelativeTime,
            IsSuccess and "[SUCCESS]" or "[MISSED WINDOW]"
        ))
    else
        ----------------------------------------------------------------------
        -- LATENCY ONLY DIAGNOSTICS LOG (No Parry Data)
        ----------------------------------------------------------------------
        print(string.format(
            "\n============ LATENCY ONLY DIAGNOSTICS ============\n" ..
            "[NETWORK STATE]\n" ..
            "Total Input Latency:  %.3fs\n" ..
            "One-Way Server Delay: %.3fs\n" ..
            "---------------------------------------------------\n" ..
            "[ANIMATION TIMELINE]\n" ..
            "No active parry window / registration data found.\n" ..
            "===================================================",
            InputLatency,
            TimeTheServerReceived
        ))
    end
end

-- Parrying animation detected
local function OnParryingAnimationSuccess()
    if CurrentParryState == ParryState.INPUT_PENDING and InputRegisteredTime then
        ParryRegisteredTime = os_clock()
        InputLatency = ParryRegisteredTime - InputRegisteredTime

        if ParryDebugToggle:Get() then  
            DebugParry()
        end
        
        TransitionToState(ParryState.PARRYING)
    end
end

-- Parrying window passed without parrying
local function OnParryingAnimationFailed()
    if CurrentParryState ~= ParryState.INPUT_PENDING then
        return
    end

    TransitionToState(ParryState.PARRYINGFAILED)
    ResetParryState()
    TransitionToState(ParryState.IDLE)
end

--                  ==[Parrying State]==
-- We parried but we didn't get a parry success in the time frame

local StunToken = 0
local function OnStunned()
    Stunned = true

    if CurrentParryState ~= ParryState.STUNNED then
        TransitionToState(ParryState.STUNNED)
    end

    StunToken += 1
    local myToken = StunToken

    scheduler.delay(0.3, function()
        if myToken == StunToken then
            Stunned = false
            ResetParryState()
            TransitionToState(ParryState.IDLE)
        end
    end)
end


local function OnSuccessfulParry()
    if CurrentParryState ~= ParryState.PARRYING or not LastPendingRegData then
        return
    end

    local attackConfig = GameConfig[LastPendingRegData.AnimationId]
    if not attackConfig or not InputRegisteredTime then
        ResetParryState()
        TransitionToState(ParryState.IDLE)
        return
    end

    local parryPressTime = InputRegisteredTime - LastPendingRegData.StartTime
    if parryPressTime < 0 or parryPressTime > 1 then
        return
    end

    UI_Library:Notify(
        "Parry Success",
        string.format(
            "%.3fs - %s %s",
            parryPressTime,
            attackConfig.Style or "Unknown",
            attackConfig.DisplayName or "Unknown"
        )
    )

    LastPendingRegData.LearnedParryTime = parryPressTime
    LastPendingRegData.Success = true
    LastPendingRegData.Processed = true

    ResetParryState()
    TransitionToState(ParryState.IDLE)
end

local function OnWindowExceeded()
    if CurrentParryState ~= ParryState.PARRYING then
        return
    end

    if LastPendingRegData then
        LastPendingRegData.Success = false
        LastPendingRegData.Processed = true
    end

    TransitionToState(ParryState.WINDOW_EXCEEDED)
    ResetParryState()
    TransitionToState(ParryState.IDLE)
end

local function ParryTask()
    local now = os_clock()

    if KeyHeld and now >= ReleaseDeadline then
        BlockEnd()
    end

    if CurrentParryState == ParryState.INPUT_PENDING then
        local maxLatency = 0.5
        local timeSinceInput = InputRegisteredTime and (now - InputRegisteredTime) or math.huge
        local activeAnims = GetActiveAnimationsForCharacterAsDictionary(
            LocalPlayer.Character,
            LocalTracker
        )

        if activeAnims[ParryingAnimation[1]] then
            OnParryingAnimationSuccess()
        elseif timeSinceInput > maxLatency then
            warn(string.format(
                "Parrying animation did not appear (max %.2fs, waited %.2fs)",
                maxLatency,
                timeSinceInput
            ))
            OnParryingAnimationFailed()
        end

    elseif CurrentParryState == ParryState.PARRYING then
        if not LastPendingRegData then
            ResetParryState()
            TransitionToState(ParryState.IDLE)
            return
        end

        if now > LastPendingRegData.BlockExpire then
            OnWindowExceeded()
        end
    end
end

-- ==========================================


local ParryLearningLog = {}  -- {[animId] = {TriggerTime, Style, DisplayName, Count}}

local function onLocalAnimationAdded(anim)
    local animId = anim.AnimationId

    if table_find(ParriedAnimation, animId) then  
        OnSuccessfulParry()
    end

    if table_find(ParryingAnimation, animId) then
        if not InputRegisteredTime then return end 

        -- For someone reason it was running before UIS??
       --scheduler.delay(0.01, function()
          --  if InputRegisteredTime then
                --EvaluateParrySuccess()
                OnParryingAnimationSuccess()
          --  end
       -- end)
    end
    
    if table_find(StunnedAnimation, animId) then
        -- keypress(string.byte()) if u f in a stun u get a shaky block 
       OnStunned()
    end
end

local AnimationAdded = TrackConnection(LocalTracker.AnimationAdded:Connect(onLocalAnimationAdded))

local function LogAnimation(assetId, trackInfo)
    if not AnimationsLoggedCache[assetId] then
        AnimationsLoggedCache[assetId] = { Name = trackInfo.Name }
        table.insert(AnimationsLoggedOrder, assetId)
        UpdateClipboardSection()
    end
end

function GetActiveAnimationsForCharacterAsDictionary(character, tracker)
    local returnTable = {}
    if not character then
        return returnTable
    end

    tracker = tracker or AnimationTracker
    local activeAnimations = tracker:Update(character) or {}

    for _, anim in ipairs(activeAnimations) do
        if anim.AnimationId then
            returnTable[anim.AnimationId] = anim
        end
    end

    return returnTable
end

-- ==========================================
-- Parry Evaluation
-- ==========================================

local DodgeLockoutEnd = 0

local function ValidateLocalCharacter()
    local localCharacter = LocalPlayer and LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot or Stunned then return nil end
    return localCharacter, localRoot
end

local function ValidateTargetCharacter(character)
    local targetRoot = character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return nil end
    return targetRoot
end

local function CheckCharacterDistance(localRoot, targetRoot)
    return (targetRoot.Position - localRoot.Position).Magnitude
end


local function UpdateCharacterESP(character, Distance)
    -- Preserve the original targeting/range checks.
    if not AutoParryToggle.Get() then
        if SHOW_TARGET_ESP then
            local tracker = EspTrackers[character]
            if tracker and tracker.ChangeText then
                tracker:ChangeText("Name", "AUTO PARRY IS DISARMED", COLOR_RED)
            end
        end
        return true
    end

    if Distance > AutoParryRange then
        if SHOW_TARGET_ESP then
            local tracker = EspTrackers[character]
            if tracker and tracker.ChangeText then
                tracker:ChangeText("Name", character.Name .. " | OUT OF RANGE", COLOR_RED)
            end
        end
        return false
    end

    if SHOW_TARGET_ESP then
        local tracker = EspTrackers[character]
        if tracker and tracker.ChangeText then
            tracker:ChangeText("Name", character.Name .. " IN RANGE", COLOR_GREEN)
        end
    end

    return true
end

local function CalculateParryTiming(attackConfig, StartTime)
    
    local optimalReactionTime = (attackConfig.ReactionTime or DefaultReactionTime)
    local adjustedReactionTime = optimalReactionTime + ParryOffset -- - pingDelay
    
    local parryWindowStart = adjustedReactionTime
    local parryWindowEnd = adjustedReactionTime + ParryWindow

    local ClockStart = StartTime + parryWindowStart
    local ClockEnd = StartTime + parryWindowEnd
    
    return ClockStart, ClockEnd
end

local function UpdateAnimationRegistry(animKey, anim, now, currentTrackTime, attackConfig)

    if not AnimationRegistry[animKey] then
        local adjustedNow = now - currentTrackTime
        local BlockStart, BlockExpire = CalculateParryTiming(attackConfig, adjustedNow)

        AnimationRegistry[animKey] = {
            StartTime = adjustedNow,
            Processed = false,
            Attempted = false,
            CurrentClockTime = os_clock(),
            CurrentTrackTime = currentTrackTime,
            ReactionTime = attackConfig,
            Ignore = false,
            AnimationId = anim.AnimationId,
            DidALoop = false,
            BlockStart = BlockStart,
            BlockExpire = BlockExpire,
            RandomNum = math.random(1, 100),
        }
    end
    
    local regData = AnimationRegistry[animKey]
    
    if regData.CurrentTrackTime and (currentTrackTime < regData.CurrentTrackTime) then
        local BlockStart, BlockExpire = CalculateParryTiming(attackConfig, now - currentTrackTime)
        
        regData.Processed = false
        regData.Attempted = false
        regData.DidALoop = true
        warn("Loop detected")
        regData.BlockStart = BlockStart
        regData.BlockExpire = BlockExpire
        regData.StartTime = now - currentTrackTime
    end
    
    regData.CurrentClockTime = os_clock()
    regData.CurrentTrackTime = currentTrackTime

    if LastPendingRegData == regData then
        LastPendingRegData = regData
    end

    return regData
end

local function CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig)
    if character.Address == localCharacter.Address then return true end
    
    local direction = (targetRoot.Position - localRoot.Position).Unit
    local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy
    
    if not isHeavy then  
        if TargetFacingYou.Get() and targetRoot.CFrame.LookVector:Dot(-direction) < 0.25 then return false end
        if YouFacingTarget.Get() and localRoot.CFrame.LookVector:Dot(direction) < 0.25 then return false end
    end
    
    return true
end

local function ExecuteParry(regData, attackConfig)
    if regData.Processed or regData.Attempted then
        return
    end

    local now = os_clock()
    local isHeavy = attackConfig.DisplayName == "M2"
        or attackConfig.DisplayName == "Heavy"
        or attackConfig.Heavy

    if attackConfig.Jump then
        if now < DodgeLockoutEnd then
            return
        end

        regData.Attempted = true
        regData.Processed = true
        DodgeLockoutEnd = now + 0.25

        task.spawn(function()
            keypress(32)
            task.wait(0.06)
            keyrelease(32)
        end)
        return
    end

    if isHeavy and AutoDodgeToggle.Get() then
        if now < DodgeLockoutEnd then
            return
        end

        regData.Attempted = true
        regData.Processed = true
        DodgeLockoutEnd = now + 0.25
        Dodge()
        return
    end

    regData.Attempted = true
    LastPendingRegData = regData

    if not BlockStart(regData.BlockStart) then
        regData.Attempted = false
        if LastPendingRegData == regData then
            LastPendingRegData = nil
        end
    end
end

local function EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    -- ANIMATION VALIDATION
    if not anim.AnimationId then return end
    local attackConfig = GameConfig[tostring(anim.AnimationId)]
    if not attackConfig then return end
    
    local animKey = anim.Address or anim
    currentActiveIds[animKey] = true
    
    -- ANIMATION REGISTRY & STATE
    local now = os_clock()
    local regData = UpdateAnimationRegistry(animKey, anim, now, anim.TimePosition or 0, attackConfig)
    if regData.Processed then return end
    
    -- PARRY FUNCTION OVERRIDE
    if attackConfig.ParryFunction and (now - regData.StartTime) <= (attackConfig.ReactionTime or DefaultReactionTime) + ParryWindow/2 then
        attackConfig.ParryFunction({
            RegistryData = regData,
            Mob = character,
            AnimationData = anim,
            AnimationTracker = AnimationTracker,
        })
        return
    end
    
    -- DIRECTION CHECKS
    if not CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig) then return end
    
    if regData.RandomNum > ProbabilityToParry then
        regData.Processed = true
--        print("Skip b/c PTP", RandomNum, ProbabilityToParry)
        return
    end
    
    -- PARRY EXECUTION
    if now >= regData.BlockStart and now <= regData.BlockExpire then
    --    if not LastPendingRegData or LastPendingRegData.Proc then
            ExecuteParry(regData, attackConfig)
    --    end
    end
end

local function EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
    -- CHARACTER VALIDATION
    local targetRoot = ValidateTargetCharacter(character)
    if not targetRoot then return end
    
    -- CHARACTER DISTANCE & ESP
    local Distance = CheckCharacterDistance(localRoot, targetRoot)
    if not UpdateCharacterESP(character, Distance) then return end
    
    -- ANIMATION LOOP
    local activeAnimations = AnimationTracker:Update(character)
    if not activeAnimations or #activeAnimations == 0 then return end
    
    for _, anim in ipairs(activeAnimations) do
        EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    end
end

local ReusableActiveIds = {}

local function EvaluateParryTriggers()
    -- SETUP & VALIDATION
    local localCharacter, localRoot = ValidateLocalCharacter()
    if not localCharacter or not localRoot then return end
    
    table.clear(ReusableActiveIds)
    local currentActiveIds = ReusableActiveIds

    -- CHARACTER ITERATION
    for _, character in ipairs(TargetCharacters) do
        EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
    end

    -- CLEANUP
    for key, val in pairs(AnimationRegistry) do
        if not currentActiveIds[key] then
            AnimationRegistry[key] = nil
            if LastPendingRegData == val then
                LastPendingRegData = nil
            end
        end
    end
end

-- ==========================================
-- ==========================================


local function ProcessEspAndLogging()
    for i = #TargetCharacters, 1, -1 do
        local character = TargetCharacters[i]

        if not character or not character.Parent then
            EspTrackers[character] = nil
            table.remove(TargetCharacters, i)
            continue
        end

        -- Keep scanning animations and logging unknown IDs in the background.
        local activeAnimations = AnimationTracker:Update(character) or {}
        local tracker = EspTrackers[character]
        local lines = SHOW_TARGET_ESP and {} or nil

        for _, anim in ipairs(activeAnimations) do
            if not anim.AnimationId then
                continue
            end

            local assetId = anim.AnimationId
            local numericId = tonumber(string.match(tostring(assetId), "%d+"))

            if numericId and table_find(IgnoreIds, numericId) then
                continue
            end

            local poolData = GameConfig[tostring(assetId)]
            local resolvedName = poolData and poolData.DisplayName or anim.Name

            if not poolData then
                LogAnimation(assetId, {
                    Name = resolvedName,
                    AnimationId = assetId,
                })
            end

            if SHOW_TARGET_ESP then
                table.insert(lines, string.format(
                    "%s (%s) | ID: %s | Time: %.2f | Timing: %.2f %s | Speed: %.2f",
                    tostring(resolvedName),
                    poolData and poolData.Style or "???",
                    tostring(assetId),
                    anim.TimePosition or 0.00,
                    poolData and poolData.ReactionTime or DefaultReactionTime,
                    poolData and "[Logged]" or "[Unknown]",
                    anim.Speed or 1
                ))
            end
        end

        if SHOW_TARGET_ESP and tracker and tracker.ChangeText then
            tracker:ChangeText(
                "CurrentlyPlaying",
                #lines > 0 and table.concat(lines, "\n") or "None",
                COLOR_WHITE
            )
        end
    end
end

local function ClearAllEspTrackers()
    for char, tracker in pairs(EspTrackers) do
        if tracker and tracker.Destroy then            
            if ESP_Utility.TrackersToUpdate[tracker] then
                ESP_Utility.TrackersToUpdate[tracker] = nil
            end

            -- 2. Destroy the tracker object
            tracker:Destroy()
        end
    end
    table.clear(EspTrackers) -- Safer than re-assigning {} to preserve table memory references
end


local function UpdateTargetCharacters(charactersList)
    -- Preserve target selection/cycle behavior; only disable visual trackers.
    ClearAllEspTrackers()
    table.clear(TargetCharacters)

    for _, character in ipairs(charactersList) do
        table.insert(TargetCharacters, character)

        if SHOW_TARGET_ESP and character and character:FindFirstChild("HumanoidRootPart") then
            local tracker = ESP_Utility.NewTracker(
                character.HumanoidRootPart,
                character.Name,
                COLOR_RED
            )

            if tracker and tracker.Name then
                tracker:AddText("CurrentlyPlaying", nil, "???")
            end

            EspTrackers[character] = tracker
        end
    end
end

function CycleEvent()
    local allCharacters = GetAllCharactersInFolder()
    if not SelectedFolder or not allCharacters then 
        UpdateTargetCharacters({})
        return 
    end

    local localPlayer = game.Players.LocalPlayer
    local localCharacter = localPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end

    local validCharacters = {}

    for _, char in ipairs(allCharacters) do
        -- Prevent the script from targeting yourself
        if char == localCharacter then continue end 

        local targetRoot = char:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local distance = (localRoot.Position - targetRoot.Position).Magnitude
            if distance <= MaxCycleRange then
                table.insert(validCharacters, { Character = char, Distance = distance })
            end
        end
    end
    
    if #validCharacters == 0 then
        CurrentIndex = 1
        UpdateTargetCharacters({}) 
        if not AutoTargetNearest.Get() then  
            UI_Library:Notify("Cycle", "No targets found in range [".. MaxCycleRange.." studs]")            
        end
        return
    end

    table.sort(validCharacters, function(a, b)
        return a.Distance < b.Distance
    end)

    if MuliTarget.Get() then
        local Max = 3
        local finalTargets = {}
        
        for i = 1, math.min(Max, #validCharacters) do
            table.insert(finalTargets, validCharacters[i].Character)
        end
        
        UpdateTargetCharacters(finalTargets)
    else
        CurrentIndex = (CurrentIndex % #validCharacters) + 1
        
        local targetIndex = AutoTargetNearest.Get() and 1 or CurrentIndex
        local selectedCharacter = validCharacters[targetIndex].Character
        
        UpdateTargetCharacters({selectedCharacter})
    end
end

-- ==========================================
-- Input & Loop
-- ==========================================
TrackConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == CycleKeybind then
        CycleEvent()
        return
    end

    if input.KeyCode == Enum.KeyCode.F then
        local localCharacter = LocalPlayer.Character
        if localCharacter then
            LocalTracker:Update(localCharacter)
            OnInputF(os_clock())
        end
    end
end))


local STATE_MACHINE_TICK = 0.05
local UTILITY_TICK = 0.5 -- Run 2 times per second
local LastCycleCheck = 0 

local function MainLoop()
    local localCharacter = LocalPlayer.Character
    local humanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
    if not localCharacter or not humanoid or humanoid.Health <= 0 then
        return
    end

    LocalTracker:Update(localCharacter)
    
    if AutoParryToggle.Get() then
        EvaluateParryTriggers()
        ParryTask()
    end
    
    scheduler.update()

    local now = os_clock()
    if now - LastCycleCheck >= UTILITY_TICK then
        LastCycleCheck = now

        if AutoTargetNearest.Get() then
            CycleEvent()
        end

        ProcessEspAndLogging()
    end
end

if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then
    ListenForOrbs()
end

local lastLoopErrorAt = 0
TrackConnection(RunService.RenderStepped:Connect(function()
    local ok, loopError = xpcall(MainLoop, Traceback)
    if not ok and os_clock() - lastLoopErrorAt >= 1 then
        lastLoopErrorAt = os_clock()
        warn("[AutoParry MainLoop] " .. tostring(loopError))
    end
end))

Environment.__GAKURAN_AUTO_PARRY_CLEANUP = function()
    for _, runtimeConnection in ipairs(RuntimeConnections) do
        pcall(function()
            runtimeConnection:Disconnect()
        end)
    end
    table.clear(RuntimeConnections)

    if connection then
        pcall(function()
            connection:Disconnect()
        end)
        connection = nil
    end

    pcall(BlockEnd)
    pcall(ClearAllEspTrackers)
    table.clear(pendingTasks)
end

print("[AutoParry] Optimized core loaded successfully")

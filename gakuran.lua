local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UIS = game:GetService("UserInputService")
local SelectedFolder = nil
local CycleKeybind = Enum.KeyCode.X

local URL = "https://raw.githubusercontent.com/artxficial/matchastuff/main/esp_utility.lua"
local ImportESP = loadstring(game:HttpGet(URL))()

local URL = "https://raw.githubusercontent.com/artxficial/matchastuff/main/animationtracker.lua"
local ImportAnimationTracker = loadstring(game:HttpGet(URL))()

local UI_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui

local AnimationsLoggedCache = {}
local AnimationsLoggedOrder = {}


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
            ReactionTime = 0.15,
        },
        ["rbxassetid://86495068205420"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://120393553812903"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
            ForceParry = true,
        },
    },
    ["AliAnims"] = {
        ["rbxassetid://137247073345979"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
            ReactionTime = 0.12,
        },
        ["rbxassetid://102632933427597"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
            ReactionTime = 0.17,
        },
        ["rbxassetid://119814294807778"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
            ReactionTime = 0.21,
        },
        ["rbxassetid://74315946602284"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
            ReactionTime = 0.11,
        },
        ["rbxassetid://128315752013166"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
            ForceParry = true,
        },
        ["rbxassetid://70642098724811"] = {
            DisplayName = "M2Right",
            ReactionTime = 0.3,
            ForceParry = true,
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
            ForceParry = true,
        },
        ["M1Time"] = 0.14,
    },
    ["WrestlingAnims"] = {
        ["rbxassetid://91485623489753"] = {
            DisplayName = "4thM1",
        },
        ["rbxassetid://73748315742870"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
            ForceParry = true,
        },
        ["rbxassetid://82903450925391"] = {
            DisplayName = "1stM1",
        },
        ["rbxassetid://119685134442395"] = {
            DisplayName = "2ndM1",
        },
        ["rbxassetid://107464726433388"] = {
            DisplayName = "3rdM1",
        },
        ["M1Time"] = 0.15,

    },
    ["MuayThaiAnims"] = {
        ["rbxassetid://137034747040618"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
            ForceParry = true,
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
            ReactionTime = 0.17,
        },
        ["rbxassetid://100408082509740"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://94803478352691"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.17,
            
        },
        ["rbxassetid://78695517680318"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://132022052139564"] = {
            DisplayName = "M2",
            ForceParry = true,
            ParryFunction = function(data)
                if data.RegistryData.Processed == true then return end 
                
                data.RegistryData.Processed = true
                task.spawn(function()
                    local random = math.random(1,10)

                    task.wait(.4)
                    BlockStart(os.clock(), 0.5)
                    task.wait(.3)
                    Dodge()
                end)
            end,
        },
    },
    ["HakariAnims"] = {
        ["rbxassetid://82855179231529"] = {
            DisplayName = "MomentumM2",
            ParryTime = 0.08,
            ReactionTime = 0.15,
            ForceParry = true,
        },
        ["rbxassetid://92865171012109"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://103026596903060"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://86626533783115"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://103100834246116"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.21,
        },
        ["rbxassetid://103359839046574"] = {
            DisplayName = "M2",
            ParryTime = 0.08,
            ReactionTime = 0.22,
            ForceParry = true,
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
            ForceParry = true,
        }
    },
    ["StrikerAnims"] = {
        ["rbxassetid://116642061934550"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://115234849770695"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://85554794950365"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://73777821288331"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://99309341097380"] = {
            DisplayName = "M2",
            ReactionTime = 0.35,
            ForceParry = true,
        }

    },
    ["KureAnims"] = {
        ["rbxassetid://71676634048602"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
            ReactionTime = 0.16
        },
        ["rbxassetid://102407060635393"] = {
            DisplayName = "Ook",
            ["ReactionTime"] = 0.1,
        },
        ["rbxassetid://82904229252991"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
            ReactionTime = 0.16
        },
        ["rbxassetid://103732110215321"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
            ReactionTime = 0.16
        },
        ["rbxassetid://103964436023727"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
            ReactionTime = 0.16
        },
    },
    ["WingChun"] = {
        ["rbxassetid://81810173569294"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.52
        },
        ["rbxassetid://82196924299426"] = {
            DisplayName = "M2",
            ["ReactionTime"] = 0.06,
            ForceParry = true,
        },
        ["rbxassetid://71178147313608"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://117898175201201"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://121315597867666"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16
        },
    },
    ["HakariOtherAnims"] = {
        ["rbxassetid://126612786608030"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://113719263885794"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://136305578634960"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://89039586375625"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://82855179231529"] = {
            DisplayName = "MomentumM2",
            ParryTime = 0.08,
            ReactionTime = 0.15,
            ForceParry = true,
        },
        ["rbxassetid://101619248052969"] = {
            DisplayName = "M2",
            ParryTime = 0.08,
            ReactionTime = 0.15,
            ForceParry = true,
        },
    },
    ["Debug"] = {
        ["http://www.roblox.com/asset/?id=125750702"] = {
            DisplayName = "M1",
            ReactionTime = 0.3,
        },
    },
}

local IgnoreIds = {
73766443218740,111699625251889,85823794654077,99661732639863,106268941365574,109816855387997,122561749929324,129805948180599,
90752347516770,135133599113049,132695091086148,137015026151472,114511731321756,100794890036133,109303037515668,117293898907979,74690341409113,73090768467054,72284079162560,89016181362524,
76945839486275,101161965631044,128307941333158,85931837451298,91352556581859,77911299793653,129335968179665, 122384188141033,
132695766056641,113331696487725,124220338099067,99799500309776,108636808436488,90015977935891,87932588807124,132477488202815,102982320608759,109278619250401,79971841883936,97783129267001,72822821848529,79974955602012,77798715679680,85845666927963,108862846290180,108045962864902,93184693099565,120399899079666,99958962160522,
}

local ParriedAnimation = {"rbxassetid://100773926241456", "rbxassetid://102823909334302", "rbxassetid://96304721384743", "rbxassetid://82979105739696", "rbxassetid://96600699015093",
"rbxassetid://138519505081692",
}
local StunnedAnimation = {"rbxassetid://122541287927198", "rbxassetid://83600639547203", "rbxassetid://80309578200579", "rbxassetid://92787945841620", "rbxassetid://108045962864902", "rbxassetid://104407197874289"}
local ParryingAnimation = {"rbxassetid://118147060185189", "rbxassetid://80135556847061", "rbxassetid://88718564310179"}
local ParryFailed = {"rbxassetid://4210597123"}

local IgnoreIdLookup = {}
local ParriedAnimationLookup = {}
local StunnedAnimationLookup = {}
local ParryingAnimationLookup = {}

for _, id in ipairs(IgnoreIds) do
    IgnoreIdLookup[id] = true
end

for _, id in ipairs(ParriedAnimation) do
    ParriedAnimationLookup[id] = true
end

for _, id in ipairs(StunnedAnimation) do
    StunnedAnimationLookup[id] = true
end

for _, id in ipairs(ParryingAnimation) do
    ParryingAnimationLookup[id] = true
end

local AutoParryRange = 10
local MaxCycleRange = 20
local ParryWindow = 0.2
local ProbabilityToParry = 100
local DefaultReactionTime = 0.1
local ParryOffset = 0
local BlockHoldTime = 0.27


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
            IgnoreIdLookup[numericId] = true
            
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

local function UpdateSliders(OldReactionTime)
    for animationId, Info in (GameConfig) do 
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
    pendingTasks[#pendingTasks + 1] = {
        executeAt = os.clock() + delayTime,
        callback = callback
    }
end

function scheduler.update()
    local now = os.clock()
    for i = #pendingTasks, 1, -1 do
        local pendingTask = pendingTasks[i]
        if now >= pendingTask.executeAt then
            pendingTasks[i] = pendingTasks[#pendingTasks]
            pendingTasks[#pendingTasks] = nil
            task.spawn(pendingTask.callback)
        end
    end
end

-- ==========================================================
-- UI WINDOW & TAB INITIALIZATION
-- ==========================================================
local UI_Window = UI_Library:CreateWindow({ 
    title = "Auto Parry Builder", 
    size = Vector2.new(700, 580),
    configFolder = "auto_parry_builder",
})

local AP_Tab = UI_Window:Tab("Auto Parry", "swords")
local Config_Tab = UI_Window:Tab("Style Configurations", "swords")

local Files_Section     = AP_Tab:Section("Files", "Left")
local AutoplaySection     = AP_Tab:Section("Autoplay", "Left")
local Config_Section    = AP_Tab:Section("Global Configuration", "Left")
local ClipboardSection = AP_Tab:Section("Logging", "Left")

local AP_Section        = AP_Tab:Section("Settings", "Right")
local Folders_Section   = AP_Tab:Section("Folders", "Right")

-- ==========================================================
-- STATE & UI ELEMENT REFERENCES
-- ==========================================================
local TargetPool_Text
local LoggedText, IgnoredText

local AutoParryToggle, AutoDodgeToggle
local AutoTargetNearest, MultiTarget
local TargetFacingYou, YouFacingTarget
local ParryDebugToggle
local PingCompensateToggle
local AutoPlayToggle
local HeightToggle

-- ==========================================================
-- HELPER FUNCTIONS
-- ==========================================================
local function UpdateTargetPoolSection()
    local characters = GetAllCharactersInFolder() 
    local names = {}
    
    for i, character in ipairs(characters) do
        table.insert(names, character.Name)
        if i == 10 then 
            table.insert(names, "... (too long)") 
            break 
        end 
    end

    local poolString = #names > 0 and table.concat(names, ", ") or "NO TARGETS FOUND"
    TargetPool_Text:SetText("Target Pool: " .. poolString)
end

local function UpdateClipboardSection()
    local animationsLoggedCount = 0 
    for _ in pairs(AnimationsLoggedCache or {}) do  
        animationsLoggedCount += 1
    end

    LoggedText:SetText("Logged Ids: " .. animationsLoggedCount)
    IgnoredText:SetText("Ignored Ids: " .. #(IgnoreIds or {}))
end


-- ==========================================================
local Receptors = {
    ["Receptor1"] = "X",
    ["Receptor2"] = "C",
    ["Receptor3"] = "N",
    ["Receptor4"] = "M",
}

local HeldKeys = {}

local Threshold = 30
local LastCacheTime = 0
local ReceptorXMap = {}

local function AutoPlayTask()
    if not AutoPlayToggle.Get() then return end

    local RhythmServiceUI = game.Players.LocalPlayer.PlayerGui:FindFirstChild("RhythmServiceUI")
    if not RhythmServiceUI then return end

    local RhythmRoot = RhythmServiceUI.RhythmRoot

    local ReceptorLookup = RhythmRoot.Receptors
    local Receptor1Y = ReceptorLookup.Receptor1.AbsolutePosition.Y
    local ReceptorCount = 0 

    local now = os.clock()
    if now - LastCacheTime >= 1 then
        for ReceptorName, Key in Receptors do
            local Receptor = ReceptorLookup[ReceptorName]
            if not Receptor then continue end 
            ReceptorCount += 1
            local ReceptorX = math.floor(Receptor.AbsolutePosition.X + Receptor.AbsoluteSize.X / 2)
            ReceptorXMap[ReceptorX] = {ReceptorName = ReceptorName, Key = Key, Receptor = Receptor}
        end
        if ReceptorCount == 2 then  
            Receptors["Receptor1"] = "F"
            Receptors["Receptor2"] = "J"
        else
            Receptors["Receptor1"] = "X"
            Receptors["Receptor2"] = "C"
        end

        LastCacheTime = now
    end

   for _, FallingNote in RhythmRoot.Lanes:GetChildren() do 
    if FallingNote.Name ~= "NoteTemplate" then continue end 
    local NotePos = FallingNote.AbsolutePosition
    local NoteSize = FallingNote.AbsoluteSize
    local NoteX = math.floor(NotePos.X + NoteSize.X / 2)

    local Match
    for RX, Data in ReceptorXMap do
        if math.abs(NoteX - RX) <= 10 then
            Match = Data
            break
        end
    end

    if not Match then continue end 

    local Tail = FallingNote.Tail
    local TailSize = Tail and Tail.AbsoluteSize
    local HasTail = TailSize and TailSize.Y > 0

    local Receptor = Match.Receptor
    local ReceptorPos = Receptor.AbsolutePosition
    local ReceptorName = Match.ReceptorName
    local Key = Match.Key


    if HasTail then
        local WhenYouShouldHold = (Tail.AbsolutePosition.Y + Tail.AbsoluteSize.Y) - ReceptorPos.Y

        if WhenYouShouldHold + 15 > Threshold then
            if not HeldKeys[ReceptorName] then
                HeldKeys[ReceptorName] = FallingNote.Address
                keypress(string.byte(Key))
            elseif HeldKeys[ReceptorName] ~= FallingNote.Address then
                HeldKeys[ReceptorName] = FallingNote.Address
                keypress(string.byte(Key))
            end
        end

        if FallingNote.Address == HeldKeys[ReceptorName] then
            if (Tail.AbsolutePosition.Y - ReceptorPos.Y) > 0 then
                scheduler.delay(0.01, function()
                    HeldKeys[ReceptorName] = nil                    
                end)
                keyrelease(string.byte(Key))
            end
        end
    else
        if math.abs(NotePos.Y - ReceptorPos.Y) < Threshold then
            if HeldKeys[ReceptorName] then
                keyrelease(string.byte(Key))
                HeldKeys[ReceptorName] = nil
            end
            
            task.spawn(function()                
                keypress(string.byte(Key))
                task.wait(0.05)
                keyrelease(string.byte(Key))
            end)
        end
    end
end
end

-- ==========================================================
-- SECTION BUILDERS
-- ==========================================================

local function CreateAutoPlaySection()
    AutoPlayToggle = AutoplaySection:Toggle("Auto Play", true)
end

local function CreateAPSection()
    AP_Section:Label("You have to press X in order to target someone or turn on Auto Target Nearest")
    
    AutoParryToggle = AP_Section:Toggle("Auto Parry", true):AddKeybind("g", "Toggle")
    AutoDodgeToggle = AP_Section:Toggle("Auto Dodge", true)
    AutoTargetNearest = AP_Section:Toggle("Auto Target Nearest", false)
    MultiTarget = AP_Section:Toggle("Multiple Targets", true)
    HeightToggle = AP_Section:Toggle("Height Multiplier (May crash some users)", true)
    

    AP_Section:Divider("Conditions")

    TargetFacingYou = AP_Section:Toggle("Target facing you", false)
    YouFacingTarget = AP_Section:Toggle("You facing target", true)
end

local function CreateGlobalConfigSection()
    ParryDebugToggle = Config_Section:Toggle("Debug Parry", false)

    local Range = Config_Section:Slider("Auto Parry Range", 40, 1, 7, 80, "", function(v)
        AutoParryRange = v
    end)
    Range:Set(AutoParryRange)

    local Probability = Config_Section:Slider("Probability To Parry", 100, 1, 1, 100, "%", function(v)
        ProbabilityToParry = v
    end)
    Probability:Set(ProbabilityToParry)

    local DefaultSection = Config_Tab:Section("Default Configuration", "Left")
    
    local Offset = DefaultSection:Slider("Parry offset", 0, 0.01, -0.1, 0.1, "s", function(v)
        ParryOffset = v
    end)
    Offset:Set(ParryOffset)

    DefaultSection:Label("Positive moves window forward (parry later), Negative moves it backward (parry earlier)")    

    local Time = DefaultSection:Slider("Default Reaction Time", 0.3, 0.01, 0, 1, "", function(v)
        DefaultReactionTime = v
        UpdateSliders()
    end)
    Time:Set(DefaultReactionTime)
    DefaultSection:Label("Reaction time is the time you press F from the moment the animation starts playing. It does not account for ping")

    PingCompensateToggle = DefaultSection:Toggle("Ping Compensation", true)
    DefaultSection:Label("Subtracts half of your ping value from the start time of ur reaction time. May improve performance.")
    
    DefaultSection:Divider("Window")
    
    local Window = DefaultSection:Slider("Default Parry Window", 0.3, 0.01, 0, 1, "", function(v)
        ParryWindow = v
    end)
    Window:Set(ParryWindow)
    DefaultSection:Label("This is usually constant, don't change this.")
end

local function CreateFoldersSection()
    TargetPool_Text = Folders_Section:Label("Target Pool: NO TARGETS FOUND") 

    local folders = GetAllFoldersInWorkspace()

    local Range = Folders_Section:Slider("Max Cycle Range", 10, 1, 7, 50, "", function(v)
        MaxCycleRange = v
    end)
    Range:Set(MaxCycleRange)

    Folders_Section:Toggle("Include Local Character", false, function(on)
        IncludeLocalCharacter = on
        UpdateTargetPoolSection()   
    end)

    local FolderCombo = Folders_Section:Dropdown("Live Folder", nil, folders, false, function(list)
        SelectedFolder = list[1]
        UpdateTargetPoolSection()
    end)

    if game.Workspace:FindFirstChild("Players") then  
        FolderCombo:Set({"Players"})
    elseif game.Workspace:FindFirstChild("Live") then 
        FolderCombo:Set({"Live"})
    end

    print("[UI] Folders Section Created")
end

local function CreateClipboardSection()
    LoggedText = ClipboardSection:Label("Logged Ids: ?")
    IgnoredText = ClipboardSection:Label("Ignored Ids: ?")

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
            Keybind = "v",
            Callback = function(on, instance) 
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
    Files_Section:Info("Game: " .. tostring(GameName))

    Files_Section:Button("Load Configuration", function()
        UI_Library:LoadConfig(GameName)
        UI_Library:Notify("Success", "Loaded configuration")
    end)

    Files_Section:Button("Save Configuration", function()
        UI_Library:SaveConfig(GameName)
        UI_Library:Notify("Success", "Saved configuration")
    end)
end

local function CreateGroupSliders()
    local GroupedStyles = {}
    
    for animationId, Info in pairs(GameConfig or {}) do  
        local StyleName = Info.Style or "Unknown"

        if not GroupedStyles[StyleName] then
            GroupedStyles[StyleName] = {}
        end
        
        GroupedStyles[StyleName][animationId] = Info
    end

    local counter = 1
    for StyleName, Animations in pairs(GroupedStyles) do
        local Side = (counter % 2 == 1) and "Left" or "Right"
        local StyleSection = Config_Tab:Section(StyleName, Side)
        
        for animationId, Info in pairs(Animations) do
            local nameLabel = Info.DisplayName or tostring(animationId)
            
            if Info["ParryFunction"] then  
                StyleSection:Label("Slider not possible for " .. nameLabel .. " (uses function)")
                continue
            end
            
            AnimationIdSliders[animationId] = StyleSection:Slider("Reaction Time: " .. nameLabel, 0, 0.01, 0, 1, "", function(v)
                if v ~= DefaultReactionTime then
                    Info.ReactionTime = v                    
                end
            end)
            
            AnimationIdSliders[animationId]:Set(Info.M1Time or Info.ReactionTime or DefaultReactionTime)
        end
        
        counter += 1
    end
end

-- ==========================================================
-- UI INITIALIZATION
-- ==========================================================
local function InitializeUI()
    CreateAutoPlaySection()
    CreateAPSection()
    CreateGlobalConfigSection()
    CreateFoldersSection()
    CreateClipboardSection()
    CreateFilesSection()
    CreateGroupSliders()
end

InitializeUI()

UpdateClipboardSection()

-- ==========================================
local PARRY_DISTANCE = 15 
local PARRY_COOLDOWN = 0.1

local activeOrbs = {}
local lastParryAt = 0

local function GetLocalHRP()
    local localChar = LocalPlayer.Character
    local HRP = localChar:FindFirstChild("HumanoidRootPart")
    if not HRP then return nil end 
    return HRP
end

function checkRange(Studs, Origin : Part)
    local HRP = GetLocalHRP()

    if (HRP.Position - Origin.Position).Magnitude < Studs then  
        return true 
    else
        return false 
    end
end

local orbSpawnTimes = {} 

local function ListenForOrbs()
    print("Listening for orbs")

    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local myPosition = hrp.Position
        local ActiveOrbs = {}

        local thrownFolder = game.Workspace:FindFirstChild("Thrown")
        if thrownFolder then
            for _, v in ipairs(thrownFolder:GetChildren()) do  
                if (v.Name == "ArdourBall2" or v.Name == "ArdourBall") 
                    and v:IsA("BasePart") 
                    and v:IsDescendantOf(game.Workspace.Thrown) then
                    
                    table.insert(ActiveOrbs, v)
                end
            end
        end

        for i = #ActiveOrbs, 1, -1 do
            local orb = ActiveOrbs[i]

            if orb and orb.Parent then
                local distance = (myPosition - orb.Position).Magnitude

                if distance <= PARRY_DISTANCE and (tick() - lastParryAt >= 0.08) then
                    lastParryAt = tick()
                    
                    BlockStart(os.clock(), 0.08)
                    
                    break 
                end
            end
        end
    end)
    
    return connection
end

if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then  
    local orbListener = ListenForOrbs()    
end

-- ==========================================
-- Configs 
-- ==========================================

local ParryKey = string.byte("F")
local DodgeKey = string.byte("Q")

local KeyHeld = false
local ParryKeyPressed = false
local TriggerParry = false

local Stunned = false
local currentStunToken = 0

local AnimationTracker = AnimationTracker.new(IgnoreIds)
local LocalTracker = AnimationTracker.new(IgnoreIds)

local DamageLogs = false
local IncludeLocalCharacter = false

local lastAnimationCheck = 0
local connection = nil
local previousHealth = 100
local lastCharacter = nil

local SelectAllMode = true 
local TargetCharacters = {}
local EspTrackers = {} 

local PendingReactionTimestamp = nil 
local EspTracker = nil
local CurrentIndex = 1
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_RED = Color3.fromRGB(255, 50, 50)
local COLOR_GREEN = Color3.fromRGB(50, 255, 50)

local AnimationRegistry = {}
local LastPendingRegData = nil
local CurrentActiveAnimationIds = {}
local ActiveAnimationsThisFrame = {}
local EmptyAnimations = {}
local BestParryRegData = nil
local BestParryAttackConfig = nil
local BestParryExpire = math.huge

local CachedPingSeconds = 0
local LastPingSampleTime = -math.huge
local PingSampleInterval = 0.2
local PingSmoothingAlpha = 0.35
local SmoothedFrameDelta = 1 / 60
local FrameLeadCompensation = SmoothedFrameDelta * 0.5
local InputRegisteredTime = nil
local TimeBetweenPressingFandParrying = nil

local InputRegisteredTime = nil
local ParryRegisteredTime = nil
local InputLatency = 0 


local ParryState = {
    IDLE = "idle",

    INPUT_PENDING = "input_pending",   
    PARRYING = "parrying",             
    PARRYINGFAILED = "parryingfailed", 

    STUNNED = "stunned",
    WINDOW_EXCEEDED = "window_exceeded", 

    SUCCESS = "parrysuccess"       
}

local CurrentParryState = ParryState.IDLE

local function IsParryDebugEnabled()
    return ParryDebugToggle and ParryDebugToggle.Get()
end

local function UpdateTimingCache(now, deltaTime)
    if deltaTime and deltaTime > 0 and deltaTime < 0.1 then
        SmoothedFrameDelta += (deltaTime - SmoothedFrameDelta) * 0.15
        FrameLeadCompensation = math.min(SmoothedFrameDelta * 0.5, 0.012)
    end

    if now - LastPingSampleTime >= PingSampleInterval then
        LastPingSampleTime = now
        local pingSeconds = math.max((GetPingValue() or 0) / 1000, 0)

        if CachedPingSeconds == 0 then
            CachedPingSeconds = pingSeconds
        else
            CachedPingSeconds += (pingSeconds - CachedPingSeconds) * PingSmoothingAlpha
        end
    end
end

local function ResetParryState()
    KeyHeld = false
    ReleaseDeadline = 0
    TimeBetweenpressingFandParrying = nil
    BlockEnd()
end

local function TransitionToState(newState)
    if IsParryDebugEnabled() then
        print(string.format("[Parry] %s -> %s", CurrentParryState, newState))
    end
    CurrentParryState = newState
end

-- ==========================================
-- Helpers
-- ==========================================

local function ToggleDamageLogger(state)
    if not state then
        if connection then
            connection:Disconnect()
            connection = nil 
        end
        print("[Logger] Heartbeat damage logger DISABLED.")
        return
    end

    if connection then return end 
    print("[Logger] Heartbeat damage logger ACTIVE.")
    
    connection = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return end 

        if lastCharacter and (char.Address ~= lastCharacter.Address) then
            lastCharacter = char
            previousHealth = hum.Health
        end
        local currentHealth = hum.Health
        if currentHealth < previousHealth then
            local damageTaken = previousHealth - currentHealth
            
            if #TargetCharacters then
                local activeAnimations = AnimationTracker:Update(TargetCharacter) or {}
                
                for _, anim in activeAnimations do
                    if not anim.AnimationId or anim.TimePosition < 0.1 or anim.TimePosition > 0.7 then continue end 
                    local assetId = tostring(anim.AnimationId)
                    local poolData = GameConfig[assetId]
                    warn(string.format(
                        "[HIT] %d DMG | Anim: %s (%s) %s | Frame Time: %.3f", 
                        damageTaken, 
                        poolData and poolData.DisplayName or anim.Name or "Unknown",
                        assetId, 
                        poolData and poolData.Style or "",
                        anim.TimePosition or 0
                    ))
                end
            end
        end
        previousHealth = currentHealth
    end)
end

-- ==========================================
-- Parry Core Logic
-- ==========================================

local function GetHeightMultiplierForCharacter(TargetCharacter)
    local succ, data = pcall(function()
        local stateFolder = TargetCharacter and TargetCharacter:FindFirstChild("PlayerData")    
        return stateFolder:GetAttribute("CurrentHeight")
    end)
    if succ and type(data) == "number" then
        return data
    end

    return 1
end

function Dodge()
    BlockEnd()

    for i = 1, 12, 1 do  
        keypress(DodgeKey)
        keyrelease(DodgeKey) 
    end
end

function BlockStart(StartTime, HoldFor)
    if not StartTime then  
        warn("Lacking a start time")
        return
    end

    if ParryRegisteredTime then  
       local TimeBetweenLastParry = os.clock() - ParryRegisteredTime
         if TimeBetweenLastParry < 0.8 and IsParryDebugEnabled() then
             print("parry is gonna be on cooldown")
         end 
    end

    if CurrentParryState ~= ParryState.IDLE then  
        if IsParryDebugEnabled() then
            warn("tried to press in a non idle state bypass")
        end
        TransitionToState(ParryState.IDLE)
    end

    local HoldFor = HoldFor or BlockHoldTime
    ReleaseDeadline = math.max(StartTime, os.clock()) + HoldFor

    KeyHeld = true
    
    if AutoParryToggle.Get() == true then
        keypress(ParryKey)
        ParryKeyPressed = true
    end
end

function BlockEnd()
    KeyHeld = false
    
    if ParryKeyPressed then
        keyrelease(ParryKey)
        ParryKeyPressed = false
    end
end

-- ==========================================
-- STATE MACHINE
-- ==========================================

local function OnInputF()
    if CurrentParryState == ParryState.IDLE then
        InputRegisteredTime = os.clock()
        TransitionToState(ParryState.INPUT_PENDING)
    end
end

local function DebugParry()
    local WeActuallyBlockedAt = ParryRegisteredTime
    local WeWantedToBlockAt = InputRegisteredTime
    local TimeTheServerReceived = InputLatency / 2

    if LastPendingRegData then
        local AnimationStartTime = LastPendingRegData.StartTime
        local BlockStart = LastPendingRegData.BlockStart
        local BlockExpire = LastPendingRegData.BlockExpire
        
        local RelativeBlockStart = BlockStart - AnimationStartTime   
        local RelativeBlockExpire = BlockExpire - AnimationStartTime 
        
        local ClientReactionTime = WeWantedToBlockAt - AnimationStartTime 
        local ServerRelativeTime = (WeActuallyBlockedAt - TimeTheServerReceived) - AnimationStartTime 
        
        local IsSuccess = (ClientReactionTime >= RelativeBlockStart and ClientReactionTime <= RelativeBlockExpire)        

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

local function OnParryingAnimationSuccess()
    if CurrentParryState == ParryState.INPUT_PENDING then
        ParryRegisteredTime = os.clock()
        InputLatency = os.clock() - InputRegisteredTime

        if ParryDebugToggle:Get() then  
            DebugParry()
        end
        
        TransitionToState(ParryState.PARRYING)
    end
end

local function OnParryingAnimationFailed()
    if CurrentParryState == ParryState.INPUT_PENDING then
        TransitionToState(ParryState.PARRYINGFAILED)
        TransitionToState(ParryState.IDLE)
    end
end

local StunToken = 0
local function OnStunned()
    if CurrentParryState ~= ParryState.STUNNED then 
        TransitionToState(ParryState.STUNNED)
    end

    StunToken += 1
    local MyToken = StunToken
    
    scheduler.delay(0.4, function()
        if MyToken == StunToken then 
            BlockEnd()
            TransitionToState(ParryState.IDLE)            
        end
    end)
end

local function OnSuccessfulParry()
    if CurrentParryState == ParryState.PARRYING then  
        local AnimId = LastPendingRegData.AnimationId
        local AttackConfig = GameConfig[AnimId]
        local ParryPressTime = tonumber(InputRegisteredTime - LastPendingRegData.StartTime)
        local EstimatedParryWindow = os.clock() - LastPendingRegData.StartTime
        
        if ParryPressTime > 1 or ParryPressTime < 0 then
            return
        end
        
        UI_Library:Notify(
            "Parry Success", 
            string.format("%.3fs PT: %.3fs - %s %s", 
                ParryPressTime, 
                EstimatedParryWindow,
                AttackConfig.Style, 
                AttackConfig.DisplayName
            )
        )
        
        LastPendingRegData.LearnedParryTime = ParryPressTime
        LastPendingRegData.Success = true

        ResetParryState()
        TransitionToState(ParryState.SUCCESS)
        TransitionToState(ParryState.IDLE)
    else
        warn("Tried to evaluate outside of parrying")
        print(CurrentParryState)
    end
end

local function OnWindowExceeded()
    if CurrentParryState == ParryState.PARRYING then 
        TransitionToState(ParryState.WINDOW_EXCEEDED)
        TransitionToState(ParryState.IDLE)
    end
end

local function ParryTask(localAnimations)
    local now = os.clock()

    if KeyHeld and now > ReleaseDeadline then
        BlockEnd()
    end

    if CurrentParryState == ParryState.INPUT_PENDING then
        local MaxLatency = 0.5 
        local TimePassedSinceFWasPressed = now - InputRegisteredTime

        for _, v in localAnimations do
            if ParryingAnimationLookup[v.AnimationId] then
                OnParryingAnimationSuccess()
                break
            end
        end

        if not iskeypressed(ParryKey) then  
            warn("F key was released before parrying animation appeared")
            ResetParryState()
            TransitionToState(ParryState.IDLE)
        end

        if TimePassedSinceFWasPressed > MaxLatency then
            warn(string.format("Parrying animation didn't appear, probably on CD MAX: %.2f | TIME: %.2f", MaxLatency, TimePassedSinceFWasPressed))
            OnParryingAnimationFailed()
            TransitionToState(ParryState.IDLE)
        end
    
    elseif CurrentParryState == ParryState.PARRYING then
        local ParryWindowStart = ParryRegisteredTime
        local ParryWindowEnd = ParryRegisteredTime + ParryWindow + 0.3

        if now > ParryWindowEnd then
            OnWindowExceeded()
        end
    end
end

-- ==========================================

local ParryLearningLog = {}

local function onLocalAnimationAdded(anim)
    local animId = anim.AnimationId

    if ParriedAnimationLookup[animId] then
        OnSuccessfulParry()
    end

    if ParryingAnimationLookup[animId] then
        if not InputRegisteredTime then return end 
        OnParryingAnimationSuccess()
    end
    
    if StunnedAnimationLookup[animId] then
    end

    if GameConfig[animId] then  
        if IsParryDebugEnabled() then
            print("player is m1ing")
        end
        OnStunned()
    end
end

local AnimationAdded = LocalTracker.AnimationAdded:Connect(onLocalAnimationAdded)

local function LogAnimation(assetId, trackInfo)
    if not AnimationsLoggedCache[assetId] then
        AnimationsLoggedCache[assetId] = { Name = trackInfo.Name }
        table.insert(AnimationsLoggedOrder, assetId)
        UpdateClipboardSection()
    end
end

function GetActiveAnimationsForCharacterAsDictionary(character)
    local ReturnTable = {}
    local activeAnimations = AnimationTracker:Update(character)
    if not activeAnimations or #activeAnimations == 0 then return {} end
    for Index, Anim in activeAnimations do  
        if Anim.AnimationId then  
            ReturnTable[Anim.AnimationId] = Anim
        end
    end

    return ReturnTable
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
    if not AutoParryToggle.Get() then 
        return true
    elseif Distance > AutoParryRange then
        return false
    else
        return true
    end
end

local function CalculateParryTiming(attackConfig, StartTime, Target)
    local optimalReactionTime = (attackConfig.ReactionTime or DefaultReactionTime)
    local HeightMultiplier = 1 
    if HeightToggle.Get() then  
       HeightMultiplier = GetHeightMultiplierForCharacter(Target)
    end

    local CompValue = CachedPingSeconds * 0.5

    if PingCompensateToggle.Get() then  
        optimalReactionTime -= CompValue
    end

    local adjustedReactionTime = (optimalReactionTime * HeightMultiplier) + ParryOffset - FrameLeadCompensation
    adjustedReactionTime = math.max(adjustedReactionTime, 0)

    local parryWindowStart = adjustedReactionTime
    local parryWindowEnd = adjustedReactionTime + ParryWindow

    local ClockStart = StartTime + parryWindowStart
    local ClockEnd = StartTime + parryWindowEnd
    
    return ClockStart, ClockEnd
end

local EXECUTE_DEBOUNCE = 0.5

local function UpdateAnimationRegistry(animKey, anim, now, currentTrackTime, attackConfig, TargetCharacter)

    if not AnimationRegistry[animKey] then
        local observedTrackTime = math.max(tonumber(currentTrackTime) or 0, 0)
        local animationStartTime = now - observedTrackTime
        local BlockStart, BlockExpire = CalculateParryTiming(attackConfig, animationStartTime, TargetCharacter)

        AnimationRegistry[animKey] = {
            StartTime = animationStartTime,
            Processed = false,
            CurrentClockTime = os.clock(),
            CurrentTrackTime = currentTrackTime,
            ReactionTime = attackConfig,
            Ignore = false,
            AnimationId = anim.AnimationId,
            DidALoop = false,
            BlockStart = BlockStart,
            BlockExpire = BlockExpire,
            RandomNum = math.random(1, 100),
            LastExecuteTime = 0,
        }
    end
    
    local regData = AnimationRegistry[animKey]
    
    if regData.CurrentTrackTime and (currentTrackTime < regData.CurrentTrackTime) then
        local BlockStart, BlockExpire = CalculateParryTiming(attackConfig, now - currentTrackTime, TargetCharacter)
        
        regData.Processed = false
        regData.DidALoop = true
        if IsParryDebugEnabled() then
            warn("Loop detected")
        end
        regData.BlockStart = BlockStart
        regData.BlockExpire = BlockExpire
        regData.StartTime = now - math.max(tonumber(currentTrackTime) or 0, 0)
    end
    
    regData.CurrentClockTime = os.clock()
    regData.CurrentTrackTime = currentTrackTime

    if LastPendingRegData == regData then
        LastPendingRegData = regData
    end

    return regData
end

local function CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig)
    if character.Address == localCharacter.Address then return true end
    
    local direction = (targetRoot.Position - localRoot.Position).Unit
    local distance = (targetRoot.Position - localRoot.Position).Magnitude
    local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy
    
    if not isHeavy then 
        if TargetFacingYou.Get() and targetRoot.CFrame.LookVector:Dot(-direction) < 0.1 then return false end
        if YouFacingTarget.Get() and localRoot.CFrame.LookVector:Dot(direction) < 0.1 then return false end
    end
    
    return true
end

local function ExecuteParry(regData, attackConfig)
    local now = os.clock()
    if (now - regData.LastExecuteTime) < EXECUTE_DEBOUNCE then
        return
    end
    regData.LastExecuteTime = now

    local isHeavy = attackConfig.DisplayName == "M2" or attackConfig.DisplayName == "Heavy" or attackConfig.Heavy

    if attackConfig.Jump then 
        task.spawn(function()
            keypress(32)
            task.wait(.06)
            keyrelease(32)                      
        end)
        DodgeLockoutEnd = os.clock() + 0.2
    elseif isHeavy and AutoDodgeToggle.Get() then
        if AutoParryToggle.Get() then  
            Dodge()            
        end
    else 
        if LastPendingRegData ~= regData then
            LastPendingRegData = regData
            BlockStart(LastPendingRegData.BlockStart)
            if IsParryDebugEnabled() then
                print(string.format("Block triggered by [%s | %s] " ,
                    attackConfig.Style,
                    attackConfig.DisplayName
                    ))
            end
        elseif LastPendingRegData == regData then
            if regData.DidALoop then  
                if IsParryDebugEnabled() then
                    print(string.format("Block retriggered for [%s | %s] because its the same key but it looped",
                    attackConfig.Style,
                    attackConfig.DisplayName))
                end
                regData.DidALoop = false
                BlockStart(regData.BlockStart)
            end
        end
    end
end

local function EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    if not anim.AnimationId then return end
    local attackConfig = GameConfig[tostring(anim.AnimationId)]
    if not attackConfig then return end
    
    local animKey = anim.Address or anim
    currentActiveIds[animKey] = true
    
    local now = os.clock()
    local regData = UpdateAnimationRegistry(animKey, anim, now, anim.TimePosition or 0, attackConfig, character)
    if regData.Processed then return end

    if attackConfig.ParryFunction and (now - regData.StartTime) <= (attackConfig.ReactionTime or DefaultReactionTime) + ParryWindow/2 then
        if AutoParryToggle.Get() then  
           attackConfig.ParryFunction({
               RegistryData = regData,
               Mob = character,
               AnimationData = anim,
               AnimationTracker = AnimationTracker,
           }) 
        end
        return
    end
    
    if not CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig) then return end
    
    if regData.RandomNum > ProbabilityToParry then
        regData.Processed = true
        return
    end
    
    local BlockExpireTimer = regData.BlockExpire - now
    
    if now >= regData.BlockStart and BlockExpireTimer >= 0 then
        if regData.BlockExpire < BestParryExpire then
            BestParryRegData = regData
            BestParryAttackConfig = attackConfig
            BestParryExpire = regData.BlockExpire
        end
    end
end

local function EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
    local targetRoot = ValidateTargetCharacter(character)
    if not targetRoot then return end

    local activeAnimations = AnimationTracker:Update(character)
    ActiveAnimationsThisFrame[character] = activeAnimations or EmptyAnimations
    if not activeAnimations or #activeAnimations == 0 then return end

    local positionDelta = targetRoot.Position - localRoot.Position
    if positionDelta:Dot(positionDelta) > AutoParryRange * AutoParryRange then return end
    
    for _, anim in ipairs(activeAnimations) do
        EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    end
end

local function EvaluateParryTriggers()
    local localCharacter, localRoot = ValidateLocalCharacter()
    if not localCharacter or not localRoot then return end
    
    table.clear(CurrentActiveAnimationIds)
    local currentActiveIds = CurrentActiveAnimationIds
    BestParryRegData = nil
    BestParryAttackConfig = nil
    BestParryExpire = math.huge

    for _, character in ipairs(TargetCharacters) do
        EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
    end

    if BestParryRegData then
        ExecuteParry(BestParryRegData, BestParryAttackConfig)
    end

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
-- Process Logging
-- ==========================================

local function ProcessEspAndLogging()
    for i = #TargetCharacters, 1, -1 do
        local character = TargetCharacters[i]

        local activeAnimations = ActiveAnimationsThisFrame[character]
        if not activeAnimations then
            activeAnimations = AnimationTracker:Update(character) or EmptyAnimations
            ActiveAnimationsThisFrame[character] = activeAnimations
        end
        if #activeAnimations == 0 then continue end 

        for i = 1, #activeAnimations do
            local anim = activeAnimations[i]
            if not anim.AnimationId then continue end        
            
            local assetId = anim.AnimationId
            local numericId = tonumber(string.match(tostring(assetId), "%d+"))
            
            if numericId and IgnoreIdLookup[numericId] then continue end
            
            local poolData = GameConfig[tostring(assetId)]
            local resolvedName = poolData and poolData.DisplayName or anim.Name
            
            if not poolData then  
                LogAnimation(assetId, { Name = resolvedName, AnimationId = assetId })
            end
        end
    end
end

local function ClearAllEspTrackers()
    for char, tracker in pairs(EspTrackers) do
        if tracker and tracker.Destroy then            
            if ESP_Utility.TrackersToUpdate[tracker] then
                ESP_Utility.TrackersToUpdate[tracker] = nil
            end
            tracker:Destroy()
        end
    end
    table.clear(EspTrackers)
end

local function UpdateTargetCharacters(charactersList)
    if #TargetCharacters == #charactersList then
        local unchanged = true

        for i = 1, #charactersList do
            local currentTarget = TargetCharacters[i]
            local nextTarget = charactersList[i]
            local sameTarget = currentTarget == nextTarget

            if not sameTarget and currentTarget and nextTarget then
                sameTarget = currentTarget.Address == nextTarget.Address
            end

            if not sameTarget then
                unchanged = false
                break
            end
        end

        if unchanged then return end
    end

    ClearAllEspTrackers()
    table.clear(TargetCharacters)

    for _, character in charactersList do
        table.insert(TargetCharacters, character)
        -- ESP visual overlay disabled
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

    if MultiTarget.Get() then
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
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local RhythmServiceUI = game.Players.LocalPlayer.PlayerGui:FindFirstChild("RhythmServiceUI")
    if RhythmServiceUI then return end

    if input.KeyCode == string.byte("x") then
        CycleEvent()
    elseif input.KeyCode == string.byte("f") then 
        local localChar = LocalPlayer.Character
        LocalTracker:Update(localChar) 
        OnInputF()
    end
end)

local STATE_MACHINE_TICK = 0.05
local TARGET_REFRESH_TICK = 0.2
local LOGGING_TICK = 0.5
local LastTargetRefresh = 0
local LastLoggingCheck = 0

local function MainLoop(deltaTime)
    local now = os.clock()
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("Humanoid") then return end

    UpdateTimingCache(now, deltaTime)
    table.clear(ActiveAnimationsThisFrame)

    local localAnimations = LocalTracker:Update(localChar) or EmptyAnimations
    EvaluateParryTriggers()
    ParryTask(localAnimations)
    AutoPlayTask()
    
    scheduler.update()

    if AutoTargetNearest.Get() and now - LastTargetRefresh >= TARGET_REFRESH_TICK then
        LastTargetRefresh = now
        CycleEvent()
    end

    if now - LastLoggingCheck >= LOGGING_TICK then
        LastLoggingCheck = now
        ProcessEspAndLogging()
    end
end

-- Heartbeat observes the current animation step; RenderStepped can see the
-- previous animation state and add up to one frame of reaction delay.
RunService.Heartbeat:Connect(MainLoop)

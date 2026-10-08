pcall(function()
    if _G.__Lolbeans67APNoCrash and _G.__Lolbeans67APNoCrash.Cleanup then
        _G.__Lolbeans67APNoCrash:Cleanup()
    end
end)

local NoCrashState = {
    Alive = true,
    Connections = {},
    Drawings = {},
    HealthEntries = {},
    OpponentHpEnabled = false,
    PersonalHpEnabled = false,
    TargetMarkerEnabled = true,
    HpViewRange = 75,
    LastOverlayUpdate = 0,
}
_G.__Lolbeans67APNoCrash = NoCrashState

function NoCrashState:AddConnection(connection)
    if connection then
        table.insert(self.Connections, connection)
    end
    return connection
end

function NoCrashState:AddDrawing(kind)
    local ok, drawing = pcall(function()
        return Drawing.new(kind)
    end)
    if ok and drawing then
        table.insert(self.Drawings, drawing)
        return drawing
    end
end

function NoCrashState:Cleanup()
    self.Alive = false
    if self.ClearEspTrackers then
        pcall(self.ClearEspTrackers)
    end
    for _, connection in ipairs(self.Connections or {}) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(self.Connections or {})
    for _, drawing in ipairs(self.Drawings or {}) do
        pcall(function() drawing:Remove() end)
    end
    table.clear(self.Drawings or {})
end

local RunService = game:GetService("RunService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UIS = game:GetService("UserInputService")
local SelectedFolder = nil
local CycleKeybind = Enum.KeyCode.X

local CritServerRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("Remotes")
    :WaitForChild("Server")

local CLINCH_ATTACKER_ID = "123886678066843"
local CLINCH_VICTIM_ID = "121572551922964"
local CritMoveSpeed = 25
local CRIT_MOVE_DURATION = 1.35
local CRIT_MOVE_INTERVAL = 0.033
local CRIT_MOVE_TURN_RESPONSE = 14
local POST_CLINCH_MOVE_BLOCK = 2.5
local CLINCH_AUTO_CRIT_DELAY = 0.25
local CLINCH_AUTO_CRIT_MIN_DELAY = 0.10
local CLINCH_AUTO_CRIT_MAX_DELAY = 0.50
local CLINCH_END_GRACE = 0.18
local CLINCH_AUTO_CRIT_WINDOW_TIMEOUT = 3.0
local CLINCH_AUTO_CRIT_CONFIRM_TIMEOUT = 0.35
local CLINCH_AUTO_CRIT_RETRY_DELAY = 0.10
local CLINCH_AUTO_CRIT_MAX_ATTEMPTS = 3
local CRIT_PROMPT_DURATION = 0.65
local MANUAL_CRIT_WINDOW_TIMEOUT = 1.5
local MANUAL_CRIT_POLL_INTERVAL = 0.02

local CritHelperState = {
    InClinch = false,
    Role = nil,
    MissingFrames = 0,
    MissingSince = nil,
    AutoFiring = false,
    AutoFireStartedAt = 0,
    Moving = false,
    MoveToken = 0,
    MoveStopReason = nil,
    MoveBlockedUntil = 0,
    PromptUntil = 0,
    WinnerToken = 0,
}

local URL = "https://raw.githubusercontent.com/artxficial/matchastuff/main/animationtracker.lua"
local ImportAnimationTracker = loadstring(game:HttpGet(URL))()

local UI_Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/artxficial/INS-ui/main/uilib.min.lua"))() or INSui

local AnimationsLoggedCache = {}
local AnimationsLoggedOrder = {}


-- ==========================================
-- Game Configuration
-- ==========================================

local GameName = "Gakuran"

local GameConfig = {
    ["KarateAnims"] = {
        ["rbxassetid://136346659171696"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://137514920199894"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://72779501873271"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://127487637547915"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://96466099895892"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
    },
    ["AliAnims"] = {
        ["rbxassetid://103211517133243"] = {
            DisplayName = "1stM1",
            ["ReactionTime"] = 0.12,
        },
        ["rbxassetid://88548871262625"] = {
            DisplayName = "2ndM1",
            ["ReactionTime"] = 0.17,
        },
        ["rbxassetid://104356393941647"] = {
            DisplayName = "3rdM1",
            ["ReactionTime"] = 0.21,
        },
        ["rbxassetid://109925400698635"] = {
            DisplayName = "4thM1",
            ["ReactionTime"] = 0.11,
        },
        ["rbxassetid://92831721340116"] = {
            DisplayName = "M2",
            ReactionTime = 0.34,
        },
        ["rbxassetid://81488798354194"] = {
            DisplayName = "M2Right",
            ReactionTime = 0.34,
        },
    },
    ["BasicAnims"] = {
        ["rbxassetid://100661797632126"] = {
            DisplayName = "1stM1"
        },
        ["rbxassetid://117315538657801"] = {
            DisplayName = "2ndM1"
        },
        ["rbxassetid://83771012317903"] = {
            DisplayName = "3rdM1"
        },
        ["rbxassetid://129031831390386"] = {
            DisplayName = "4thM1"
        },
        ["rbxassetid://80331331149375"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["M1Time"] = 0.14,
    },
    ["WrestlingAnims"] = {
        ["rbxassetid://74020075116139"] = {
            DisplayName = "4thM1",
        },
        ["rbxassetid://91419261625463"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://124808151650835"] = {
            DisplayName = "1stM1",
        },
        ["rbxassetid://79996486219181"] = {
            DisplayName = "2ndM1",
        },
        ["rbxassetid://115207134396914"] = {
            DisplayName = "3rdM1",
        },
        ["M1Time"] = 0.15,

    },
    ["MuayThaiAnims"] = {
        ["rbxassetid://74462376752922"] = {
            DisplayName = "M2",
            ReactionTime = 0.3,
        },
        ["rbxassetid://90445272780399"] = {
            DisplayName = "4thM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://103717575086418"] = {
            DisplayName = "3rdM1",
            ParryTime = 0.08,
        },
        ["rbxassetid://136830198456192"] = {
            DisplayName = "2ndM1",
            ParryTime = 0.08,
            
        },
        ["rbxassetid://110917888708142"] = {
            DisplayName = "1stM1",
            ParryTime = 0.08,
        },
        ["M1Time"] = 0.1,        
    },
    ["BoxingAnims"] = {
        ["rbxassetid://132913269853139"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://76033376851583"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://126463147281440"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.17,
            
        },
        ["rbxassetid://75666664304014"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://128921678079615"] = {
            DisplayName = "M2",
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
        ["rbxassetid://137954350192006"] = {
            DisplayName = "MomentumM2"
        },
        ["rbxassetid://123215666398014"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://100249628136368"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.17,
        },
        ["rbxassetid://101160496635774"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://76458394174684"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.21,
        },
        ["rbxassetid://78127273702521"] = {
            DisplayName = "M2",
            ReactionTime = 0.19,
        },
    },
    ["CapoeiraAnims"] = {
        ["rbxassetid://91953931348325"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.15,
        },
        ["rbxassetid://127465095270110"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://79017113400162"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://98872276178039"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.16,
        },
        ["rbxassetid://101740002500802"] = {
            DisplayName = "M2",
            ReactionTime = 0.32,
        }
    },
    ["SluggerAnims"] = {
        ["rbxassetid://78852386182257"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.24,
        },
        ["rbxassetid://89706363973188"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.22,
        },
        ["rbxassetid://127941398150401"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.22
        },
        ["rbxassetid://97696355281722"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.19,
        },
        ["rbxassetid://86882821333237"] = {
            DisplayName = "M2",
            ReactionTime = 0.65,
        }
    },
    ["StrikerAnims"] = {
        ["rbxassetid://79224782278508"] = { DisplayName = "1stM1", ReactionTime = 0.20 },
        ["rbxassetid://74337052553355"] = { DisplayName = "2ndM1", ReactionTime = 0.18 },
        ["rbxassetid://121264916189386"] = { DisplayName = "3rdM1", ReactionTime = 0.05 },
        ["rbxassetid://125556631043249"] = { DisplayName = "4thM1", ReactionTime = 0.05 },
        ["rbxassetid://128600830397859"] = { DisplayName = "M2", ReactionTime = 0.30 },
    },
    ["KickboxingAnims"] = {
        ["rbxassetid://127679697578124"] = { DisplayName = "1stM1", ReactionTime = 0.17 },
        ["rbxassetid://111648334200984"] = { DisplayName = "2ndM1", ReactionTime = 0.18 },
        ["rbxassetid://109134308246065"] = { DisplayName = "3rdM1", ReactionTime = 0.19 },
        ["rbxassetid://123237866254734"] = { DisplayName = "4thM1", ReactionTime = 0.242 },
        ["rbxassetid://119415047601579"] = { DisplayName = "M2", ReactionTime = 0.287 },
    },
    ["KyokushinAnims"] = {
        ["rbxassetid://108157433609067"] = { DisplayName = "1stM1", ReactionTime = 0.10 },
        ["rbxassetid://139691512657916"] = { DisplayName = "2ndM1", ReactionTime = 0.10 },
        ["rbxassetid://94267870513016"] = { DisplayName = "3rdM1", ReactionTime = 0.14 },
        ["rbxassetid://107365196082362"] = { DisplayName = "4thM1", ReactionTime = 0.24 },
        ["rbxassetid://128363063231486"] = { DisplayName = "M2", ReactionTime = 0.25 },
    },
    ["CQCAnims"] = {
        ["rbxassetid://80051878176163"] = { DisplayName = "1stM1", ReactionTime = 0.20 },
        ["rbxassetid://112809686330315"] = { DisplayName = "2ndM1", ReactionTime = 0.20 },
        ["rbxassetid://96690751054332"] = { DisplayName = "3rdM1", ReactionTime = 0.10 },
        ["rbxassetid://75394567475187"] = { DisplayName = "4thM1", ReactionTime = 0.24 },
        ["rbxassetid://135110210666200"] = { DisplayName = "M2", ReactionTime = 0.30 },
        ["rbxassetid://72310116631906"] = { DisplayName = "M2", ReactionTime = 0.30 },
        ["rbxassetid://103319500580356"] = { DisplayName = "M2", ReactionTime = 0.30 },
    },
    ["KureAnims"] = {
        ["rbxassetid://89598700542051"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://84100769626105"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://75725487794798"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://103586798765773"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://128246407698779"] = {
            DisplayName = "M2",
            ["ReactionTime"] = 0.1,
        },
    },
    ["LethweiAnims"] = {
        ["rbxassetid://126845586831338"] = {
            DisplayName = "1stM1",
        },
        ["rbxassetid://111506889308405"] = {
            DisplayName = "2ndM1",
        },
        ["rbxassetid://93862547414782"] = {
            DisplayName = "3rdM1",
        },
        ["rbxassetid://81747456615347"] = {
            DisplayName = "4thM1",
        },
        ["rbxassetid://98256190530845"] = {
            DisplayName = "M2",
        },
    },
    ["MishimaAnims"] = {
        ["rbxassetid://122564675454774"] = {
            DisplayName = "1stM1",
        },
        ["rbxassetid://124288660244802"] = {
            DisplayName = "2ndM1",
        },
        ["rbxassetid://116344736444569"] = {
            DisplayName = "3rdM1",
        },
        ["rbxassetid://109354190051977"] = {
            DisplayName = "4thM1",
        },
        ["rbxassetid://113531813891302"] = {
            DisplayName = "M2",
        },
    },
    ["WingChun"] = {
        ["rbxassetid://135699957281468"] = {
            DisplayName = "4thM1",
            ReactionTime = 0.52
        },
        ["rbxassetid://82196924299426"] = {
            DisplayName = "M2",
            ["ReactionTime"] = 0.06,
        },
        ["rbxassetid://94976161225956"] = {
            DisplayName = "1stM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://130903067566077"] = {
            DisplayName = "2ndM1",
            ReactionTime = 0.16
        },
        ["rbxassetid://139503477666199"] = {
            DisplayName = "3rdM1",
            ReactionTime = 0.16
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
132695766056641,113331696487725,124220338099067,99799500309776,108636808436488,90015977935891,87932588807124,132477488202815,102982320608759,109278619250401,79971841883936,97783129267001,72822821848529,79974955602012,77798715679680,85845666927963,108862846290180,108045962864902,93184693099565,120399899079666,99958962160522,93221784050620,70767328707698,
}

local ParriedAnimation = {"rbxassetid://100773926241456", "rbxassetid://102823909334302", "rbxassetid://96304721384743", "rbxassetid://82979105739696", "rbxassetid://96600699015093",
"rbxassetid://138519505081692",
}
local StunnedAnimation = {"rbxassetid://122541287927198", "rbxassetid://83600639547203", "rbxassetid://80309578200579", "rbxassetid://92787945841620", "rbxassetid://108045962864902", "rbxassetid://104407197874289"}
local ParryingAnimation = {"rbxassetid://118147060185189", "rbxassetid://80135556847061", "rbxassetid://88718564310179"}
local ParryFailed = {"rbxassetid://4210597123"}

local AutoParryRange = 10
local MaxCycleRange = 20
local ParryWindow = 0.2
local ProbabilityToParry = 100
local DefaultReactionTime = 0.1
local ParryOffset = 0
local BlockHoldTime = 0.27

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
            table.insert(newlyAddedIds, tostring(numericId))
        end
    end

    local outputstring = table.concat(newlyAddedIds, ", ")
    setclipboard(outputstring)    

    print(string.format("[Clipboard] Copied %d NEW IDs! (Total historical ignored count is now: %d)", #newlyAddedIds, #IgnoreIds))
end

local scheduler = {}
local pendingTasks = {}

function scheduler.delay(delayTime, callback)
    table.insert(pendingTasks, {
        executeAt = os.clock() + delayTime,
        callback = callback
    })
end

function scheduler.update()
    local now = os.clock()
    for i = #pendingTasks, 1, -1 do
        local task = pendingTasks[i]
        if now >= task.executeAt then
            table.remove(pendingTasks, i)
            coroutine.wrap(task.callback)()
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
local AutoplaySection   = AP_Tab:Section("Autoplay", "Left")
local Config_Section    = AP_Tab:Section("Global Configuration", "Left")
local ClipboardSection = AP_Tab:Section("Logging", "Left")

local AP_Section        = AP_Tab:Section("Settings", "Right")
local Folders_Section   = AP_Tab:Section("Folders", "Right")
local Overlay_Section   = AP_Tab:Section("Target Overlay", "Right")
local CritHelper_Section = AP_Tab:Section("Crit Helpers", "Right")

local TargetPool_Text
local LoggedText, IgnoredText

local AutoParryToggle, AutoDodgeToggle, AutoDodgeM1Toggle
local AutoTargetNearest, MultiTarget
local TargetFacingYou, YouFacingTarget
local ParryDebugToggle
local PingCompensateToggle
local AutoPlayToggle
local HeightToggle
local ClinchCritToggle, MovingCritToggle
local TargetCharacters = {}
local DodgeDirectionMode = "Situational"
local DodgeCooldownDuration = 1.0
local DodgeCooldownEnd = 0
local PARRY_COOLDOWN_DURATION = 0.8

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

local function CreateAutoPlaySection()
    AutoPlayToggle = AutoplaySection:Toggle("Auto Play", true)
end

local function CreateAPSection()
    AP_Section:Label("You have to press X in order to target someone or turn on Auto Target Nearest")
    
    AutoParryToggle = AP_Section:Toggle("Auto Parry", true):AddKeybind("g", "Toggle")
    AutoDodgeToggle = AP_Section:Toggle("Auto Dodge", true)
    AutoDodgeM1Toggle = AP_Section:Toggle("Auto Dodge M1", false)
    AutoDodgeM1Toggle:AddKeybind("h", "Toggle")
    AP_Section:Label("Auto Dodge M1 toggle key: H (editable)")

    local DodgeDirection = AP_Section:Dropdown(
        "Dodge Direction",
        nil,
        {"Situational", "Front", "Back", "Side Left", "Side Right"},
        false,
        function(list)
            DodgeDirectionMode = list[1] or DodgeDirectionMode
            print("[Auto Dodge] Direction mode:", DodgeDirectionMode)
        end
    )
    DodgeDirection:Set({"Situational"})
    AP_Section:Label("Situational uses held WASD; no key = Back")

    local DodgeCooldown = AP_Section:Slider(
        "Dodge Cooldown Estimate",
        1.0,
        0.05,
        0.5,
        2.0,
        " sec",
        function(value)
            DodgeCooldownDuration = value
        end
    )
    DodgeCooldown:Set(DodgeCooldownDuration)
    AP_Section:Label("Dodge first; parry while dodge is cooling down")

    AutoTargetNearest = AP_Section:Toggle("Auto Target Nearest", false)
    MultiTarget = AP_Section:Toggle("Multiple Targets", true)
    HeightToggle = AP_Section:Toggle("Height Multiplier (May crash some users)", false)

    AP_Section:Divider("Conditions")

    TargetFacingYou = AP_Section:Toggle("Target facing you", false)
    YouFacingTarget = AP_Section:Toggle("You facing target", true)
end

local function CreateOverlaySection()
    Overlay_Section:Label("Press X to cycle targets. Multiple Targets keeps the nearest three.")

    Overlay_Section:Toggle("X Target Marker", true, function(on)
        NoCrashState.TargetMarkerEnabled = on
    end)
    Overlay_Section:Toggle("Opponent HP Bars", false, function(on)
        NoCrashState.OpponentHpEnabled = on
    end)
    Overlay_Section:Toggle("Personal HP Bar", false, function(on)
        NoCrashState.PersonalHpEnabled = on
    end)

    local range = Overlay_Section:Slider("HP View Range", 75, 5, 15, 200, " studs", function(value)
        NoCrashState.HpViewRange = value
    end)
    range:Set(NoCrashState.HpViewRange)
    Overlay_Section:Label("Shows compact names and HP only inside this range.")
end

local function CreateCritHelperSection()
    CritHelper_Section:Label("Green = ON, Red = OFF")

    ClinchCritToggle = CritHelper_Section:Toggle("Clinch Auto Crit", true)
    ClinchCritToggle:AddKeybind("b", "Toggle")
    CritHelper_Section:Label("Manual cue waits for combat locks to clear")
    CritHelper_Section:Label("Default toggle key: B")

    local AutoDelay = CritHelper_Section:Slider(
        "Auto Crit Delay",
        0.25,
        0.01,
        CLINCH_AUTO_CRIT_MIN_DELAY,
        CLINCH_AUTO_CRIT_MAX_DELAY,
        " sec",
        function(value)
            CLINCH_AUTO_CRIT_DELAY = math.clamp(
                value,
                CLINCH_AUTO_CRIT_MIN_DELAY,
                CLINCH_AUTO_CRIT_MAX_DELAY
            )
        end
    )
    AutoDelay:Set(CLINCH_AUTO_CRIT_DELAY)
    CritHelper_Section:Label("Reliable selectable range: 0.10s - 0.50s")

    MovingCritToggle = CritHelper_Section:Toggle("Moving Crit", false)
    MovingCritToggle:AddKeybind("rightshift", "Toggle")
    CritHelper_Section:Label("RightShift toggles it; press R to use it")

    local Speed = CritHelper_Section:Slider(
        "Moving Crit Speed",
        25,
        1,
        20,
        30,
        " speed",
        function(value)
            CritMoveSpeed = value
        end
    )
    Speed:Set(CritMoveSpeed)

    CritHelper_Section:Label("Moving Crit is blocked during/after clinch")
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

local function InitializeUI()
    CreateAutoPlaySection()
    CreateAPSection()
    CreateGlobalConfigSection()
    CreateFoldersSection()
    CreateOverlaySection()
    CreateCritHelperSection()
    CreateClipboardSection()
    CreateFilesSection()
    CreateGroupSliders()
end

InitializeUI()
UpdateClipboardSection()

local PARRY_DISTANCE = 15 
local PARRY_COOLDOWN = 0.1

local activeOrbs = {}
local lastParryAt = 0

local function GetLocalHRP()
    local localChar = LocalPlayer.Character
    local HRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
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
                    
                    BlockStart()
                    BlockEnd()
                    
                    break 
                end
            end
        end
    end)
    
    return connection
end

if game.PlaceId == 8668476218 or game.PlaceId == 134572803901609 then  
    NoCrashState:AddConnection(ListenForOrbs())
end

local ParryKey = string.byte("F")
local DodgeKey = string.byte("Q")

local KeyHeld = false
local TriggerParry = false

local Stunned = false
local currentStunToken = 0

local AnimationTracker = AnimationTracker.new(IgnoreIds)
local LocalTracker = AnimationTracker.new(IgnoreIds)

local CritPrompt = NoCrashState:AddDrawing("Text")
if CritPrompt then
    pcall(function()
        CritPrompt.Text = "PRESS R"
        CritPrompt.Color = Color3.fromRGB(80, 255, 120)
        CritPrompt.Transparency = 1
        CritPrompt.Size = 20
        CritPrompt.Center = true
        CritPrompt.Outline = true
        CritPrompt.Visible = false
    end)
end

local function ShowCritPrompt()
    if not CritPrompt then return end

    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize

    if viewport then
        CritPrompt.Position = Vector2.new(viewport.X / 2, viewport.Y * 0.42)
    end
    CritPrompt.Visible = true
    CritHelperState.PromptUntil = os.clock() + CRIT_PROMPT_DURATION
    print("[Crit Helpers] PRESS R now")
end

local function UpdateCritPrompt(now)
    if CritPrompt
        and CritHelperState.PromptUntil > 0
        and now >= CritHelperState.PromptUntil then

        CritPrompt.Visible = false
        CritHelperState.PromptUntil = 0
        print("[Crit Helpers] PRESS R cue hidden")
    end
end

local MANUAL_CRIT_BLOCK_ATTRIBUTES = {
    "Ragdoll",
    "Stunned",
    "CantAnything",
    "CombatAttacking",
    "M1",
    "PendingM2",
}

local function ManualCritWindowIsOpen(character)
    if not character then
        return false, "Character"
    end

    if character:GetAttribute("Equip") == false then
        return false, "Equip"
    end

    if character:GetAttribute("M2Cooldown") == true then
        return false, "M2Cooldown"
    end

    for _, attributeName in ipairs(MANUAL_CRIT_BLOCK_ATTRIBUTES) do
        if character:GetAttribute(attributeName) == true then
            return false, attributeName
        end
    end

    return true, nil
end

local function WaitForManualCritWindow()
    CritHelperState.WinnerToken += 1
    local token = CritHelperState.WinnerToken

    task.spawn(function()
        local started = os.clock()
        local lastBlock = "unknown"

        while NoCrashState.Alive
            and CritHelperState.WinnerToken == token
            and os.clock() - started < MANUAL_CRIT_WINDOW_TIMEOUT do

            local character = LocalPlayer.Character
            local ready, blockingAttribute = ManualCritWindowIsOpen(character)
            if ready then
                local elapsed = os.clock() - started
                print(string.format(
                    "[Crit Helpers] Manual crit window open after %.3fs",
                    elapsed
                ))
                ShowCritPrompt()
                return
            end

            lastBlock = blockingAttribute or lastBlock
            task.wait(MANUAL_CRIT_POLL_INTERVAL)
        end

        if NoCrashState.Alive and CritHelperState.WinnerToken == token then
            print(
                "[Crit Helpers] Manual window fallback; last lock:",
                lastBlock
            )
            ShowCritPrompt()
        end
    end)
end

local function NormalizeCritAnimationId(value)
    return tostring(value or ""):match("%d+")
end

local function FireCritRemote()
    CritServerRemote:FireServer({
        Type = "Combat",
        Action = "M2",
        Func = "ServerCheck",
    })
end

local function WaitForClinchCritWindow(deadline)
    local lastBlock = "unknown"

    while NoCrashState.Alive
        and ClinchCritToggle
        and ClinchCritToggle.Get() == true
        and os.clock() < deadline do

        local character = LocalPlayer.Character
        local ready, blockingAttribute = ManualCritWindowIsOpen(character)
        if ready then
            return character, nil
        end

        lastBlock = blockingAttribute or lastBlock
        task.wait(MANUAL_CRIT_POLL_INTERVAL)
    end

    return nil, lastBlock
end

local function WaitForCritConfirmation(character, timeout)
    local deadline = os.clock() + timeout

    while NoCrashState.Alive and os.clock() < deadline do
        character = LocalPlayer.Character or character
        if character and character:GetAttribute("M2Cooldown") == true then
            return true
        end

        task.wait(MANUAL_CRIT_POLL_INTERVAL)
    end

    return false
end

local function StartClinchAutoCrit()
    local now = os.clock()
    if CritHelperState.AutoFiring then
        local staleAfter = CLINCH_AUTO_CRIT_WINDOW_TIMEOUT + 2
        if CritHelperState.AutoFireStartedAt > 0
            and now - CritHelperState.AutoFireStartedAt > staleAfter then

            warn("[Crit Helpers] Clearing stale clinch autocrit latch")
            CritHelperState.AutoFiring = false
        else
            print("[Crit Helpers] Clinch autocrit already pending")
            return
        end
    end

    if not ClinchCritToggle or ClinchCritToggle.Get() ~= true then return end

    CritHelperState.AutoFiring = true
    CritHelperState.AutoFireStartedAt = now
    CritHelperState.MoveBlockedUntil = now + POST_CLINCH_MOVE_BLOCK

    task.spawn(function()
        local ok, err = xpcall(function()
            print(string.format(
                "[Crit Helpers] Winner recovery detected; waiting %.2fs before window check",
                CLINCH_AUTO_CRIT_DELAY
            ))
            task.wait(CLINCH_AUTO_CRIT_DELAY)

            local deadline = os.clock() + CLINCH_AUTO_CRIT_WINDOW_TIMEOUT
            local character, lastBlock = WaitForClinchCritWindow(deadline)
            if not character then
                print(
                    "[Crit Helpers] Clinch crit window timed out; last lock:",
                    lastBlock
                )
                return
            end

            for attempt = 1, CLINCH_AUTO_CRIT_MAX_ATTEMPTS do
                if not NoCrashState.Alive
                    or not ClinchCritToggle
                    or ClinchCritToggle.Get() ~= true then

                    return
                end

                local ready, blockingAttribute = ManualCritWindowIsOpen(character)
                if not ready then
                    character, lastBlock = WaitForClinchCritWindow(deadline)
                    if not character then
                        print(
                            "[Crit Helpers] Retry window timed out; last lock:",
                            blockingAttribute or lastBlock
                        )
                        return
                    end
                end

                local fired, fireError = pcall(FireCritRemote)
                if not fired then
                    error("FireCritRemote failed: " .. tostring(fireError))
                end

                if WaitForCritConfirmation(
                    character,
                    CLINCH_AUTO_CRIT_CONFIRM_TIMEOUT
                ) then
                    print(string.format(
                        "[Crit Helpers] Clinch crit confirmed on request %d",
                        attempt
                    ))
                    return
                end

                if attempt < CLINCH_AUTO_CRIT_MAX_ATTEMPTS then
                    task.wait(CLINCH_AUTO_CRIT_RETRY_DELAY)
                end
            end

            print(string.format(
                "[Crit Helpers] Clinch crit was not confirmed after %d requests",
                CLINCH_AUTO_CRIT_MAX_ATTEMPTS
            ))
        end, function(message)
            return debug.traceback(tostring(message), 2)
        end)

        if not ok then
            warn("[Crit Helpers] Clinch autocrit error:", err)
        end

        CritHelperState.MoveBlockedUntil = math.max(
            CritHelperState.MoveBlockedUntil,
            os.clock() + POST_CLINCH_MOVE_BLOCK
        )
        CritHelperState.AutoFiring = false
        CritHelperState.AutoFireStartedAt = 0
    end)
end

local function UpdateClinchCrit(activeAnimations)
    local attackerPlaying = false
    local victimPlaying = false

    for _, animation in ipairs(activeAnimations or {}) do
        local id = NormalizeCritAnimationId(animation.AnimationId)
        if id == CLINCH_ATTACKER_ID then
            attackerPlaying = true
        elseif id == CLINCH_VICTIM_ID then
            victimPlaying = true
        end
    end

    if not CritHelperState.InClinch then
        if attackerPlaying or victimPlaying then
            CritHelperState.InClinch = true
            CritHelperState.Role = attackerPlaying and "attacker" or "victim"
            CritHelperState.MissingFrames = 0
            CritHelperState.MissingSince = nil
            CritHelperState.MoveBlockedUntil = os.clock() + 10
            print("[Crit Helpers] Clinch started as", CritHelperState.Role)
        end
        return
    end

    local roleStillPlaying =
        CritHelperState.Role == "attacker" and attackerPlaying
        or CritHelperState.Role == "victim" and victimPlaying

    if roleStillPlaying then
        CritHelperState.MissingFrames = 0
        CritHelperState.MissingSince = nil
        return
    end

    local now = os.clock()
    if not CritHelperState.MissingSince then
        CritHelperState.MissingSince = now
        return
    end

    if now - CritHelperState.MissingSince < CLINCH_END_GRACE then return end

    local finishedRole = CritHelperState.Role
    CritHelperState.InClinch = false
    CritHelperState.Role = nil
    CritHelperState.MissingFrames = 0
    CritHelperState.MissingSince = nil
    CritHelperState.MoveBlockedUntil = now + POST_CLINCH_MOVE_BLOCK
    print("[Crit Helpers] Clinch animation ended as", finishedRole)

    if finishedRole == "attacker" then
        if ClinchCritToggle and ClinchCritToggle.Get() == true then
            StartClinchAutoCrit()
        else
            WaitForManualCritWindow()
        end
    end
end

local function IsCritMoveKeyDown(keyCode)
    return UIS:IsKeyDown(keyCode.Value)
end

local function GetCritMoveDirection(root)
    local camera = workspace.CurrentCamera
    local cameraFrame = camera and camera.CFrame or root.CFrame
    local look = cameraFrame.LookVector
    local forward = Vector3.new(look.X, 0, look.Z)

    if forward.Magnitude < 0.01 then
        forward = Vector3.new(0, 0, -1)
    else
        forward = forward.Unit
    end

    local right = Vector3.new(-forward.Z, 0, forward.X)
    local direction = Vector3.zero

    if IsCritMoveKeyDown(Enum.KeyCode.W) then direction += forward end
    if IsCritMoveKeyDown(Enum.KeyCode.S) then direction -= forward end
    if IsCritMoveKeyDown(Enum.KeyCode.D) then direction += right end
    if IsCritMoveKeyDown(Enum.KeyCode.A) then direction -= right end

    return direction
end

local function RestoreNormalMoveSpeed()
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    if not root or not humanoid then return end

    local velocity = root.AssemblyLinearVelocity
    local moveDirection = humanoid.MoveDirection
    local horizontal = Vector3.zero

    if moveDirection.Magnitude > 0.01 then
        horizontal = moveDirection.Unit * humanoid.WalkSpeed
    end

    root.AssemblyLinearVelocity = Vector3.new(
        horizontal.X,
        velocity.Y,
        horizontal.Z
    )
end

local function StopMovingCrit(reason)
    if not CritHelperState.Moving then return end

    CritHelperState.Moving = false
    CritHelperState.MoveToken += 1
    CritHelperState.MoveStopReason = reason or "stopped"
    RestoreNormalMoveSpeed()
    print("[Crit Helpers] Moving crit stopped:", CritHelperState.MoveStopReason)
end

local function WatchMovingCritTargets(connections)
    local characters = TargetCharacters
    if #characters == 0 then
        characters = GetAllCharactersInFolder() or {}
    end

    for _, character in ipairs(characters) do
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local startingHealth = humanoid.Health
            table.insert(connections, humanoid.HealthChanged:Connect(function(health)
                if CritHelperState.Moving and health < startingHealth then
                    StopMovingCrit("crit hit opponent")
                end
                startingHealth = health
            end))
        end
    end
end

local function WatchMovingCritParry(character, connections)
    for _, attributeName in ipairs({"Stunned", "Ragdoll"}) do
        table.insert(
            connections,
            character:GetAttributeChangedSignal(attributeName):Connect(function()
                if CritHelperState.Moving
                    and character:GetAttribute(attributeName) == true then

                    StopMovingCrit("crit was parried")
                end
            end)
        )
    end
end

local function StartMovingCrit()
    if not MovingCritToggle or MovingCritToggle.Get() ~= true then return end
    if CritHelperState.Moving or CritHelperState.AutoFiring then return end
    if CritHelperState.InClinch
        or os.clock() < CritHelperState.MoveBlockedUntil then
        print("[Crit Helpers] Moving crit blocked during/after clinch")
        return
    end

    CritHelperState.Moving = true
    CritHelperState.MoveToken += 1
    CritHelperState.MoveStopReason = nil
    local moveToken = CritHelperState.MoveToken

    task.spawn(function()
        task.wait(0.03)
        local started = os.clock()
        local lastUpdate = started
        local smoothDirection = nil
        local outcomeConnections = {}
        local character = LocalPlayer.Character

        if not character then
            StopMovingCrit("character unavailable")
            return
        end

        WatchMovingCritTargets(outcomeConnections)
        WatchMovingCritParry(character, outcomeConnections)
        print("[Crit Helpers] Moving crit started; speed", CritMoveSpeed)

        while NoCrashState.Alive
            and CritHelperState.Moving
            and CritHelperState.MoveToken == moveToken
            and MovingCritToggle.Get() == true
            and not CritHelperState.InClinch
            and not CritHelperState.AutoFiring
            and os.clock() >= CritHelperState.MoveBlockedUntil
            and os.clock() - started < CRIT_MOVE_DURATION do

            character = LocalPlayer.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then break end

            local now = os.clock()
            local deltaTime = math.max(0, now - lastUpdate)
            lastUpdate = now

            local requestedDirection = GetCritMoveDirection(root)
            if requestedDirection.Magnitude > 0.01 then
                requestedDirection = requestedDirection.Unit

                if smoothDirection then
                    local blend = math.clamp(
                        deltaTime * CRIT_MOVE_TURN_RESPONSE,
                        0,
                        1
                    )
                    smoothDirection = smoothDirection:Lerp(
                        requestedDirection,
                        blend
                    )
                    if smoothDirection.Magnitude > 0.01 then
                        smoothDirection = smoothDirection.Unit
                    else
                        smoothDirection = requestedDirection
                    end
                else
                    smoothDirection = requestedDirection
                end

                if not CritHelperState.Moving
                    or CritHelperState.MoveToken ~= moveToken then

                    break
                end

                local velocity = root.AssemblyLinearVelocity
                root.AssemblyLinearVelocity = Vector3.new(
                    smoothDirection.X * CritMoveSpeed,
                    velocity.Y,
                    smoothDirection.Z * CritMoveSpeed
                )
            else
                smoothDirection = nil
            end

            task.wait(CRIT_MOVE_INTERVAL)
        end

        for _, connection in ipairs(outcomeConnections) do
            pcall(function() connection:Disconnect() end)
        end

        if CritHelperState.MoveToken == moveToken then
            CritHelperState.Moving = false
            CritHelperState.MoveStopReason = "duration ended"
            RestoreNormalMoveSpeed()
            print("[Crit Helpers] Moving crit stopped: duration ended")
        end
    end)
end

local DamageLogs = false
local IncludeLocalCharacter = false

local lastAnimationCheck = 0
local connection = nil
local previousHealth = 100
local lastCharacter = nil

local SelectAllMode = true 

local PendingReactionTimestamp = nil 
local CurrentIndex = 1
local COLOR_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_RED = Color3.fromRGB(255, 50, 50)
local COLOR_GREEN = Color3.fromRGB(50, 255, 50)

local AnimationRegistry = {}
local LastPendingRegData = nil
local InputRegisteredTime = nil
local TimeBetweenPressingFandParrying = nil

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

local function ResetParryState()
    KeyHeld = false
    ReleaseDeadline = 0
    TimeBetweenpressingFandParrying = nil
    BlockEnd()
end

local function TransitionToState(newState)
    print(string.format("[Parry] %s -> %s", CurrentParryState, newState))
    CurrentParryState = newState
end

local function ToggleDamageLogger(state)
    if not state then
        if connection then
        connection:Disconnect()
        connection = nil end
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
    NoCrashState:AddConnection(connection)
end

local function GetHeightMultiplierForCharacter(TargetCharacter)
    local succ, data = pcall(function()
        local stateFolder = TargetCharacter and TargetCharacter:FindFirstChild("PlayerData")    
        return stateFolder:GetAttribute("CurrentHeight")
    end)
    if succ then  
        return data
    else
        return 1
    end
end

local DodgeInputBusy = false
local DodgeDirections = {
    ["Front"] = {EnumKey = Enum.KeyCode.W, VirtualKey = string.byte("W")},
    ["Back"] = {EnumKey = Enum.KeyCode.S, VirtualKey = string.byte("S")},
    ["Side Left"] = {EnumKey = Enum.KeyCode.A, VirtualKey = string.byte("A")},
    ["Side Right"] = {EnumKey = Enum.KeyCode.D, VirtualKey = string.byte("D")},
}

local function DirectionKeyIsHeld(directionData)
    return directionData
        and UIS:IsKeyDown(directionData.EnumKey.Value)
end

local function AnyMovementKeyHeld()
    return UIS:IsKeyDown(Enum.KeyCode.W.Value)
        or UIS:IsKeyDown(Enum.KeyCode.A.Value)
        or UIS:IsKeyDown(Enum.KeyCode.S.Value)
        or UIS:IsKeyDown(Enum.KeyCode.D.Value)
end

function Dodge()
    local now = os.clock()
    if DodgeInputBusy or now < DodgeCooldownEnd then
        return false
    end

    DodgeInputBusy = true
    DodgeCooldownEnd = now + DodgeCooldownDuration
    BlockEnd()

    task.spawn(function()
        local directionData = nil
        local simulatedDirection = false
        local effectiveMode = DodgeDirectionMode

        if DodgeDirectionMode == "Situational" then
            if not AnyMovementKeyHeld() then
                effectiveMode = "Back"
                directionData = DodgeDirections[effectiveMode]
            end
        else
            directionData = DodgeDirections[DodgeDirectionMode]
        end

        if directionData and not DirectionKeyIsHeld(directionData) then
            keypress(directionData.VirtualKey)
            simulatedDirection = true
            task.wait(0.025)
        end

        print("[Auto Dodge] Dodging:", effectiveMode)

        for _ = 1, 4 do
            keypress(DodgeKey)
            task.wait(0.006)
            keyrelease(DodgeKey)
            task.wait(0.006)
        end

        task.wait(0.04)
        if simulatedDirection then
            keyrelease(directionData.VirtualKey)
        end

        DodgeInputBusy = false
    end)

    return true
end

local function DodgeIsAvailable(now)
    return not DodgeInputBusy and now >= DodgeCooldownEnd
end

local function ParryIsAvailable(now)
    if KeyHeld or CurrentParryState ~= ParryState.IDLE then
        return false
    end

    return not ParryRegisteredTime
        or now - ParryRegisteredTime >= PARRY_COOLDOWN_DURATION
end

function BlockStart(StartTime, HoldFor)
    if not StartTime then  
        warn("Lacking a start time")
        return
    end

    if ParryRegisteredTime then  
       local TimeBetweenLastParry = os.clock() - ParryRegisteredTime
         if TimeBetweenLastParry < 0.8 then  
             print("parry is gonna be on cooldown")
         end 
    end

    if CurrentParryState ~= ParryState.IDLE then  
        warn("tried to press in a non idle state bypass")
        TransitionToState(ParryState.IDLE)
    end

    local HoldFor = HoldFor or BlockHoldTime
    ReleaseDeadline = StartTime + HoldFor   

    KeyHeld = true
    
    if AutoParryToggle.Get() == true then
        keypress(ParryKey)    
    end
end

function BlockEnd()
    KeyHeld = false
    
    if AutoParryToggle.Get() == true then 
        keyrelease(ParryKey) 
    end 
end

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

local function ParryTask()
    local now = os.clock()

    if KeyHeld and os.clock() > ReleaseDeadline then
        BlockEnd()
    end

    if CurrentParryState == ParryState.INPUT_PENDING then
        local MaxLatency = 0.5
        local TimePassedSinceFWasPressed = now - InputRegisteredTime

        local ActiveAnims = GetActiveAnimationsForCharacterAsDictionary(LocalPlayer.Character)
      
        for i, v in ActiveAnims do
            if table.find(ParryingAnimation, v.AnimationId) then
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

local ParryLearningLog = {}

local function onLocalAnimationAdded(anim)
    local animId = anim.AnimationId

    if CritHelperState.Moving and table.find(StunnedAnimation, animId) then
        StopMovingCrit("crit was parried")
    end

    if table.find(ParriedAnimation, animId) then  
        OnSuccessfulParry()
    end

    if table.find(ParryingAnimation, animId) then
        if not InputRegisteredTime then return end 
        OnParryingAnimationSuccess()
    end

    if GameConfig[animId] then  
        print("player is m1ing")
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

local function CalculateParryTiming(attackConfig, StartTime, Target)
    local optimalReactionTime = (attackConfig.ReactionTime or DefaultReactionTime)
    local HeightMultiplier = 1 
    if HeightToggle.Get() then  
       HeightMultiplier = GetHeightMultiplierForCharacter(Target)
    end

    local CompValue = (GetPingValue()/1000) * 0.5

    if PingCompensateToggle.Get() then  
        optimalReactionTime -= CompValue
    end

    local adjustedReactionTime = (optimalReactionTime * HeightMultiplier) + ParryOffset

    local parryWindowStart = adjustedReactionTime
    local parryWindowEnd = adjustedReactionTime + ParryWindow

    local ClockStart = StartTime + parryWindowStart
    local ClockEnd = StartTime + parryWindowEnd
    
    return ClockStart, ClockEnd
end

local ConstLatency = 0.018
local EXECUTE_DEBOUNCE = 0.5

local function UpdateAnimationRegistry(animKey, anim, now, currentTrackTime, attackConfig, TargetCharacter)
    if not AnimationRegistry[animKey] then
        local adjustedNow = now - ConstLatency
        local BlockStart, BlockExpire = CalculateParryTiming(attackConfig, adjustedNow, TargetCharacter)

        AnimationRegistry[animKey] = {
            StartTime = adjustedNow,
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
        warn("Loop detected")
        regData.BlockStart = BlockStart
        regData.BlockExpire = BlockExpire
        regData.StartTime = now - ConstLatency
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
    local displayName = tostring(attackConfig.DisplayName or "")
    local isM1 = string.find(displayName, "M1", 1, true) ~= nil
    local dodgeEnabled = isHeavy and AutoDodgeToggle.Get()
        or isM1 and AutoDodgeM1Toggle.Get()

    if attackConfig.Jump then 
        task.spawn(function()
            keypress(32)
            task.wait(.06)
            keyrelease(32)                      
        end)
        DodgeLockoutEnd = os.clock() + 0.2
        return
    end

    -- Dodge has first priority. If it is cooling down, fall through to parry.
    if dodgeEnabled and DodgeIsAvailable(now) and Dodge() then
        regData.Processed = true
        print(string.format(
            "[Defense] Dodge selected for [%s | %s]",
            tostring(attackConfig.Style),
            displayName
        ))
        return
    end

    if AutoParryToggle.Get() and ParryIsAvailable(now) then
        if LastPendingRegData ~= regData then
            LastPendingRegData = regData
            BlockStart(LastPendingRegData.BlockStart)
            print(string.format(
                "[Defense] Parry fallback for [%s | %s]",
                tostring(attackConfig.Style),
                displayName
            ))
        elseif LastPendingRegData == regData then
            if regData.DidALoop then  
                print(string.format(
                    "[Defense] Parry retriggered for [%s | %s]",
                    tostring(attackConfig.Style),
                    displayName
                ))
                regData.DidALoop = false
                BlockStart(regData.BlockStart)
            end
        end
        return
    end

    if dodgeEnabled then
        local dodgeRemaining = math.max(0, DodgeCooldownEnd - now)
        local parryRemaining = ParryRegisteredTime
            and math.max(
                0,
                PARRY_COOLDOWN_DURATION - (now - ParryRegisteredTime)
            )
            or 0

        print(string.format(
            "[Defense] Both unavailable | dodge %.2fs | parry %.2fs | state %s",
            dodgeRemaining,
            parryRemaining,
            tostring(CurrentParryState)
        ))
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

    if CheckCharacterDistance(localRoot, targetRoot) > AutoParryRange then return end
    
    if attackConfig.ParryFunction and (now - regData.StartTime) <= (attackConfig.ReactionTime or DefaultReactionTime) + ParryWindow/2 then
        -- When heavy auto-dodge is enabled, use the shared dodge-first
        -- selector below instead of the animation's custom parry routine.
        if AutoDodgeToggle.Get() then
            -- Continue into normal timing and defense selection.
        elseif AutoParryToggle.Get() then
           attackConfig.ParryFunction({
               RegistryData = regData,
               Mob = character,
               AnimationData = anim,
               AnimationTracker = AnimationTracker,
           }) 
            return
        else
            return
        end
    end
    
    if not CheckAnimationDirection(character, localCharacter, localRoot, targetRoot, attackConfig) then return end
    
    if regData.RandomNum > ProbabilityToParry then
        regData.Processed = true
        return
    end
    
    local BlockExpireTimer = regData.BlockExpire - now
    
    if now >= regData.BlockStart and BlockExpireTimer >= 0 then
        ExecuteParry(regData, attackConfig)
    end
end

local function EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
    local targetRoot = ValidateTargetCharacter(character)
    if not targetRoot then return end
    
    local Distance = CheckCharacterDistance(localRoot, targetRoot)
    
    local activeAnimations = AnimationTracker:Update(character)
    if not activeAnimations or #activeAnimations == 0 then return end
    
    for _, anim in ipairs(activeAnimations) do
        EvaluateAnimation(anim, character, localCharacter, localRoot, targetRoot, currentActiveIds)
    end
end

local function EvaluateParryTriggers()
    local localCharacter, localRoot = ValidateLocalCharacter()
    if not localCharacter or not localRoot then return end
    
    local currentActiveIds = {}

    for _, character in ipairs(TargetCharacters) do
        EvaluateCharacter(character, localCharacter, localRoot, currentActiveIds)
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

local function ProcessEspAndLogging()
    for i = #TargetCharacters, 1, -1 do
        local character = TargetCharacters[i]

        local activeAnimations = AnimationTracker:Update(character) or {}
        if #activeAnimations == 0 then continue end 

        for i = 1, #activeAnimations do
            local anim = activeAnimations[i]
            if not anim.AnimationId then continue end        
            
            local assetId = anim.AnimationId
            local numericId = tonumber(string.match(tostring(assetId), "%d+"))
            
            if numericId and table.find(IgnoreIds, numericId) then continue end 
            
            local poolData = GameConfig[tostring(assetId)]
            local resolvedName = poolData and poolData.DisplayName or anim.Name
            
            if not poolData then  
                LogAnimation(assetId, { Name = resolvedName, AnimationId = assetId })
            end
        end
    end
end

local function ClearAllEspTrackers()
    -- ESP Tracking elements removed for performance during combat
end

local function UpdateTargetCharacters(charactersList)
    table.clear(TargetCharacters)
    for _, character in charactersList do
        table.insert(TargetCharacters, character)
    end
end

function NoCrashState:SetVisible(drawing, visible)
    if drawing then
        pcall(function() drawing.Visible = visible end)
    end
end

function NoCrashState:Project(worldPosition)
    local ok, point, visible = pcall(function()
        if type(WorldToScreen) == "function" then
            return WorldToScreen(worldPosition)
        end

        local camera = workspace.CurrentCamera
        if camera then
            return camera:WorldToViewportPoint(worldPosition)
        end
    end)

    if not ok or not point or visible ~= true then
        return nil, false
    end
    if point.Z and point.Z <= 0 then
        return nil, false
    end
    return point, true
end

function NoCrashState:EnsureTargetMarker()
    if self.TargetMarker then return self.TargetMarker end

    local marker = {
        Outline = self:AddDrawing("Square"),
        Box = self:AddDrawing("Square"),
        Text = self:AddDrawing("Text"),
    }

    pcall(function()
        marker.Outline.Filled = false
        marker.Outline.Color = Color3.fromRGB(10, 10, 10)
        marker.Outline.Thickness = 3
        marker.Box.Filled = false
        marker.Box.Color = Color3.fromRGB(255, 65, 65)
        marker.Box.Thickness = 1
        marker.Text.Color = Color3.fromRGB(255, 235, 235)
        marker.Text.Size = 12
        marker.Text.Center = true
        marker.Text.Outline = true
    end)

    self.TargetMarker = marker
    return marker
end

function NoCrashState:HideTargetMarker()
    local marker = self.TargetMarker
    if marker then
        self:SetVisible(marker.Outline, false)
        self:SetVisible(marker.Box, false)
        self:SetVisible(marker.Text, false)
    end
end

function NoCrashState:UpdateTargetMarker()
    if not self.TargetMarkerEnabled then
        self:HideTargetMarker()
        return
    end

    local character = TargetCharacters[1]
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    if not root or not humanoid or humanoid.Health <= 0 then
        self:HideTargetMarker()
        return
    end

    local point, visible = self:Project(root.Position + Vector3.new(0, 3.2, 0))
    if not visible then
        self:HideTargetMarker()
        return
    end

    local marker = self:EnsureTargetMarker()
    local size = math.clamp(2200 / point.Z, 20, 48)
    local position = Vector2.new(point.X - size / 2, point.Y - size / 2)

    pcall(function()
        marker.Outline.Position = position
        marker.Outline.Size = Vector2.new(size, size)
        marker.Box.Position = position
        marker.Box.Size = Vector2.new(size, size)
        marker.Text.Text = "[X] " .. tostring(character.Name)
        marker.Text.Position = Vector2.new(point.X, point.Y - size / 2 - 15)
        marker.Outline.Visible = true
        marker.Box.Visible = true
        marker.Text.Visible = true
    end)
end

function NoCrashState:EnsureHealthEntry(index)
    local entry = self.HealthEntries[index]
    if entry then return entry end

    entry = {
        Name = self:AddDrawing("Text"),
        Background = self:AddDrawing("Square"),
        Fill = self:AddDrawing("Square"),
        Value = self:AddDrawing("Text"),
    }

    pcall(function()
        entry.Name.Color = Color3.fromRGB(240, 240, 240)
        entry.Name.Transparency = 1
        entry.Name.Size = 11
        entry.Name.Center = true
        entry.Name.Outline = true
        entry.Background.Color = Color3.fromRGB(42, 42, 42)
        entry.Background.Transparency = 1
        entry.Background.Filled = true
        entry.Background.Thickness = 1
        entry.Fill.Color = Color3.fromRGB(55, 230, 85)
        entry.Fill.Transparency = 1
        entry.Fill.Filled = true
        entry.Value.Color = Color3.fromRGB(240, 240, 240)
        entry.Value.Transparency = 1
        entry.Value.Size = 10
        entry.Value.Center = true
        entry.Value.Outline = true
    end)

    self.HealthEntries[index] = entry
    return entry
end

function NoCrashState:HideHealthEntry(entry)
    if entry then
        self:SetVisible(entry.Name, false)
        self:SetVisible(entry.Background, false)
        self:SetVisible(entry.Fill, false)
        self:SetVisible(entry.Value, false)
    end
end

function NoCrashState:UpdateOpponentHealth()
    if not self.OpponentHpEnabled then
        for _, entry in pairs(self.HealthEntries) do self:HideHealthEntry(entry) end
        return
    end

    local folder = SelectedFolder and workspace:FindFirstChild(SelectedFolder)
    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not folder or not localRoot then
        for _, entry in pairs(self.HealthEntries) do self:HideHealthEntry(entry) end
        return
    end

    local candidates = {}
    for _, character in ipairs(folder:GetChildren()) do
        local humanoid = character:IsA("Model") and character:FindFirstChildWhichIsA("Humanoid")
        local root = character:IsA("Model") and character:FindFirstChild("HumanoidRootPart")
        if character ~= localCharacter and humanoid and root and humanoid.Health > 0 then
            local distance = (localRoot.Position - root.Position).Magnitude
            if distance <= self.HpViewRange then
                table.insert(candidates, { Character = character, Humanoid = humanoid, Root = root, Distance = distance })
            end
        end
    end

    table.sort(candidates, function(a, b) return a.Distance < b.Distance end)
    local displayed = 0

    for _, candidate in ipairs(candidates) do
        if displayed >= 12 then break end
        local head = candidate.Character:FindFirstChild("Head") or candidate.Root
        local point, visible = self:Project(head.Position + Vector3.new(0, 1.15, 0))
        if visible then
            displayed += 1
            local entry = self:EnsureHealthEntry(displayed)
            local width, height = 52, 4
            local health = math.max(0, tonumber(candidate.Humanoid.Health) or 0)
            local maximum = math.max(1, tonumber(candidate.Humanoid.MaxHealth) or 1)
            local ratio = math.clamp(health / maximum, 0, 1)
            local left = point.X - width / 2
            local top = point.Y

            pcall(function()
                entry.Name.Text = tostring(candidate.Character.Name)
                entry.Name.Position = Vector2.new(point.X, top - 13)
                entry.Background.Position = Vector2.new(left, top)
                entry.Background.Size = Vector2.new(width, height)
                entry.Fill.Position = Vector2.new(left + 1, top + 1)
                entry.Fill.Size = Vector2.new(ratio > 0 and math.max(1, (width - 2) * ratio) or 0, height - 2)
                entry.Fill.Color = ratio >= 0.995 and Color3.fromRGB(55, 230, 85) or Color3.fromRGB(math.floor(235 * (1 - ratio)), math.floor(70 + 185 * ratio), 65)
                entry.Value.Text = string.format("%d / %d", math.floor(health + 0.5), math.floor(maximum + 0.5))
                entry.Value.Position = Vector2.new(point.X, top + 5)
                entry.Name.Visible = true
                entry.Background.Visible = true
                entry.Fill.Visible = true
                entry.Value.Visible = true
            end)
        end
    end

    for index = displayed + 1, #self.HealthEntries do
        self:HideHealthEntry(self.HealthEntries[index])
    end
end

function NoCrashState:EnsurePersonalHealth()
    if self.PersonalHealth then return self.PersonalHealth end

    self.PersonalHealth = {
        Background = self:AddDrawing("Square"),
        Fill = self:AddDrawing("Square"),
        Value = self:AddDrawing("Text"),
    }

    pcall(function()
        self.PersonalHealth.Background.Filled = true
        self.PersonalHealth.Background.Color = Color3.fromRGB(42, 42, 42)
        self.PersonalHealth.Background.Transparency = 1
        self.PersonalHealth.Fill.Filled = true
        self.PersonalHealth.Fill.Color = Color3.fromRGB(55, 230, 85)
        self.PersonalHealth.Fill.Transparency = 1
        self.PersonalHealth.Value.Color = Color3.fromRGB(245, 245, 245)
        self.PersonalHealth.Value.Transparency = 1
        self.PersonalHealth.Value.Size = 13
        self.PersonalHealth.Value.Center = true
        self.PersonalHealth.Value.Outline = true
    end)
    return self.PersonalHealth
end

function NoCrashState:UpdatePersonalHealth()
    if not self.PersonalHpEnabled then
        local entry = self.PersonalHealth
        if entry then
            self:SetVisible(entry.Background, false)
            self:SetVisible(entry.Fill, false)
            self:SetVisible(entry.Value, false)
        end
        return
    end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    local camera = workspace.CurrentCamera
    if not humanoid or humanoid.Health <= 0 or not camera then return end

    local entry = self:EnsurePersonalHealth()
    local width, height = 180, 6
    local health = math.max(0, tonumber(humanoid.Health) or 0)
    local maximum = math.max(1, tonumber(humanoid.MaxHealth) or 1)
    local ratio = math.clamp(health / maximum, 0, 1)
    local viewport = camera.ViewportSize
    if not self.PersonalViewport or self.PersonalViewport.X ~= viewport.X or self.PersonalViewport.Y ~= viewport.Y then
        self.PersonalViewport = viewport
        self.PersonalPosition = Vector2.new((viewport.X - width) / 2, viewport.Y - 64)
    end
    local position = self.PersonalPosition

    pcall(function()
        entry.Background.Position = position
        entry.Background.Size = Vector2.new(width, height)
        entry.Fill.Position = position + Vector2.new(1, 1)
        entry.Fill.Size = Vector2.new(ratio > 0 and math.max(1, (width - 2) * ratio) or 0, height - 2)
        entry.Fill.Color = ratio >= 0.995 and Color3.fromRGB(55, 230, 85) or Color3.fromRGB(math.floor(235 * (1 - ratio)), math.floor(70 + 185 * ratio), 65)
        entry.Value.Text = string.format("HP  %d / %d", math.floor(health + 0.5), math.floor(maximum + 0.5))
        entry.Value.Position = Vector2.new(viewport.X / 2, position.Y - 15)
        entry.Background.Visible = true
        entry.Fill.Visible = true
        entry.Value.Visible = true
    end)
end

function NoCrashState:UpdateOverlays()
    local now = os.clock()
    if not self.Alive or now - self.LastOverlayUpdate < 0.08 then return end
    self.LastOverlayUpdate = now
    pcall(function()
        self:UpdateTargetMarker()
        self:UpdateOpponentHealth()
        self:UpdatePersonalHealth()
    end)
end

NoCrashState.ClearEspTrackers = ClearAllEspTrackers

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

NoCrashState:AddConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local RhythmServiceUI = game.Players.LocalPlayer.PlayerGui:FindFirstChild("RhythmServiceUI")
    if RhythmServiceUI then return end

    if input.KeyCode == Enum.KeyCode.Q.Value
        or input.KeyCode == string.byte("q")
        or input.KeyCode == string.byte("Q") then

        DodgeCooldownEnd = math.max(
            DodgeCooldownEnd,
            os.clock() + DodgeCooldownDuration
        )
    elseif input.KeyCode == Enum.KeyCode.R.Value or input.KeyCode == string.byte("r") then
        StartMovingCrit()
    elseif input.KeyCode == CycleKeybind or input.KeyCode == string.byte("x") then
        CycleEvent()
    elseif input.KeyCode == string.byte("f") then 
        local localChar = LocalPlayer.Character
        LocalTracker:Update(localChar) 
        OnInputF()
    end
end))

local STATE_MACHINE_TICK = 0.05
local UTILITY_TICK = 0.5
local LastCycleCheck = 0 

local function MainLoop()
    local now = os.clock()
    UpdateCritPrompt(now)

    local localChar = LocalPlayer.Character
    local localHumanoid = localChar and localChar:FindFirstChildWhichIsA("Humanoid")
    if not localHumanoid or localHumanoid.Health <= 0 then return end

    local localAnimations = LocalTracker:Update(localChar) or {}
    UpdateClinchCrit(localAnimations)
    EvaluateParryTriggers()
    ParryTask()
    AutoPlayTask()
    
    scheduler.update()
    NoCrashState:UpdateOverlays()

    if (now - LastCycleCheck >= UTILITY_TICK) then
        LastCycleCheck = now
        if AutoTargetNearest.Get() then
            CycleEvent()
        end

        ProcessEspAndLogging()
    end
end

NoCrashState:AddConnection(RunService.RenderStepped:Connect(MainLoop))

print("[Crit Helpers] Loaded | Clinch Auto Crit: ON | Moving Crit: OFF")
print("[Crit Helpers] Change both keybinds directly in the Crit Helpers section")

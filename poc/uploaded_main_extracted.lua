 -- New Fresh 4.lua | compact selective build from V1-V6 references
-- Only the requested ESP, wallhack, throwable warning, welcome/expiry, and credit systems are included.
local MENU_NAME = "KALUA Menu" -- editable menu title
local FEATURE_CATEGORY_NAME = "KALUA Features" -- editable feature-category title
local ESP_NAME = "KALUA ESP"
local CREDIT_TEXT = "TG ~ @KALUAMOD"
local EXPIRY_DATE = "2026-10-07" -- editable: YYYY-MM-DD (V1 reference date)
local WELCOME_TITLE = "NOTIFICATION FROM @KALUAMOD" -- editable
local WELCOME_TEXT = [[
WELCOME TO LUA VIP

PLAY CAREFULLY AND ENJOY
ADMIN: @KALUAMOD
]] -- editable

_G.LexusConfig = _G.LexusConfig or {}
_G.LexusConfig.ThrowableWarning = _G.LexusConfig.ThrowableWarning or false
_G.LexusState = _G.LexusState or {}
_G.AK_Features = {
    { id = "WALLHACK", name = "Wallhack", val = 0, type = "toggle" },
    { id = "ESP_LINE", name = "ESP Line", val = 0, type = "toggle" },
    { id = "ESP_BOX", name = "ESP Box", val = 0, type = "toggle" },
    { id = "ESP_NAME", name = "ESP Name", val = 0, type = "toggle" },
    { id = "ESP_HEALTH", name = "ESP Health", val = 0, type = "toggle" },
    { id = "ESP_COUNTER", name = "ESP Counter", val = 0, type = "toggle" },
    { id = "THROWABLE_WARNING", name = "Throwable / Grenade Warning", val = 0, type = "toggle" },
}
function _G.AK_GetVal(id)
    if id == "ESP_V2" then
        return (_G.AK_GetVal("ESP_BOX") == 1 or _G.AK_GetVal("ESP_NAME") == 1 or _G.AK_GetVal("ESP_HEALTH") == 1 or _G.AK_GetVal("ESP_LINE") == 1 or _G.AK_GetVal("ESP_COUNTER") == 1) and 1 or 0
    end
    if id == "ESP9_Line" then return _G.AK_GetVal("ESP_LINE") end
    if id == "ESP9_Count" then return _G.AK_GetVal("ESP_COUNTER") end
    if id == "ESP9_Name" then return _G.AK_GetVal("ESP_NAME") end
    if id == "ESP9_HP" then return _G.AK_GetVal("ESP_HEALTH") end
    if id == "ESP9_Distance" then return _G.AK_GetVal("ESP_NAME") end
    if id == "ESP9_Team" then return 1 end
    for _, f in ipairs(_G.AK_Features) do if f.id == id then return f.val end end
    return 0
end
local ENetRole = import("ENetRole")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local C_WHITE = {R=255,G=255,B=255,A=255}
local C_RED = {R=255,G=0,B=0,A=255}
local C_CYAN = {R=0,G=255,B=255,A=255}
-- ========================================================================
-- V1 EXPIRY SYSTEM + WELCOME POPUP (selectively restored)
-- Editable expiry date is kept at the top of this file as EXPIRY_DATE.
-- ========================================================================
local function _NF4_ParseExpiryTimestamp()
    local y, m, d = EXPIRY_DATE:match("^(%d%d%d%d)%-(%d%d?)%-(%d%d?)$")
    return os.time({year=tonumber(y), month=tonumber(m), day=tonumber(d), hour=0, min=0, sec=0})
end
local EXPIRY_TIMESTAMP = _NF4_ParseExpiryTimestamp()

local function FormatTimeRemaining(sec)
    if sec <= 0 then return "0d 0h 0m 0s" end
    local days = math.floor(sec / 86400); sec = sec % 86400
    local hours = math.floor(sec / 3600); sec = sec % 3600
    local minutes = math.floor(sec / 60)
    local seconds = sec % 60
    return string.format("%dd %dh %dm %ds", days, hours, minutes, seconds)
end

function CheckExpiration()
    local remaining = EXPIRY_TIMESTAMP - os.time()
    if remaining <= 0 then
        _G._MOD_EXPIRED = true
        _G.MOD_EXPIRED = true
        return false
    end
    _G._MOD_EXPIRED = false
    _G.MOD_EXPIRED = false
    _G._MOD_REMAINING_SECONDS = remaining
    return true
end

local function ShowExpiryPopup(expired)
    pcall(function()
        local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
        if not Msg or not Msg.Show then return end
        local function onClick() end
        if expired then
            local expiresAt = os.date("!%Y-%m-%d %H:%M:%S UTC", EXPIRY_TIMESTAMP)
            Msg.Show(4, "MOD EXPIRED", "THIS MOD HAS EXPIRED.\n\nEXPIRED ON: " .. expiresAt .. "\n\nTEXT Me  OWNER KALUAMOD", onClick)
        else
            local remaining = _G._MOD_REMAINING_SECONDS or (EXPIRY_TIMESTAMP - os.time())
            local formatted = FormatTimeRemaining(remaining)
            local expiresAt = os.date("!%Y-%m-%d %H:%M:%S UTC", EXPIRY_TIMESTAMP)
            Msg.Show(4, "NOTIFICATION", "MOD VALIDITY: " .. formatted .. "\nEXPIRES AT: " .. expiresAt .. "\n\nOWNER DM @KALUAMOD", onClick)
        end
    end)
end

function _G.TryShowWelcome()
    if _G.WelcomeShown then return end
    if not CheckExpiration() then
        ShowExpiryPopup(true)
        return
    end
    ShowExpiryPopup(false)
    _G.WelcomeShown = true
end

-- V1 timing: perform an early check, then show the popup after player/UI startup.
local function _NF4_StartWelcomeBootstrap()
    pcall(function()
        local ticker = require("common.time_ticker")
        if ticker and ticker.AddTimerOnce then
            ticker.AddTimerOnce(3, function() CheckExpiration() end)
            ticker.AddTimerOnce(4, function()
                if not CheckExpiration() then ShowExpiryPopup(true) else _G.TryShowWelcome() end
            end)
            return
        end
        if _G.Game and _G.Game.AddGameTimer then
            _G.Game:AddGameTimer(3.0, false, function() CheckExpiration() end)
            _G.Game:AddGameTimer(4.0, false, function()
                if not CheckExpiration() then ShowExpiryPopup(true) else _G.TryShowWelcome() end
            end)
            return
        end
        _G.TryShowWelcome()
    end)
end
_NF4_StartWelcomeBootstrap()

local function UpdateThrowableWarnings(localPlayer)
        if _G.AK_GetVal("THROWABLE_WARNING") == 1 then
            pcall(function()
                local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
                local MyHUD = pc and pc.MyHUD or nil
                if MyHUD and slua.isValid(MyHUD) then
                    if not _G.CachedGameplayStatics then _G.CachedGameplayStatics = import("GameplayStatics") end
                    if not _G.CachedActorClass_ForBomb then _G.CachedActorClass_ForBomb = import("Actor") end 
                    if not _G.CachedProjArray then _G.CachedProjArray = slua.Array(UEnums.EPropertyClass.Object, _G.CachedActorClass_ForBomb) end
                    
                    -- Initialize the Cache using a Weak Table so the game garbage-collects it automatically, preventing RAM overflow
                    if not _G.ActorBombCacheInit then
                        _G.NonBombCache = setmetatable({}, { __mode = "k" })
                        _G.BombCache = setmetatable({}, { __mode = "k" })
                        _G.ActorBombCacheInit = true
                    end
                    
                    local ui_util = require("client.common.ui_util")
                    local gameInstance = ui_util and ui_util.GetGameInstance()
                    
                    if gameInstance and _G.CachedGameplayStatics then
                        local curTime = os.clock()
                        
                        -- HEAVY DATA SCAN THREAD: Runs every 0.5s instead of every frame
                        if not _G.LastBombScanTime or (curTime - _G.LastBombScanTime) > 0.5 then
                            _G.LastBombScanTime = curTime
                            local allActors = _G.CachedGameplayStatics.GetAllActorsOfClass(gameInstance, _G.CachedActorClass_ForBomb, _G.CachedProjArray)
                            
                            local activeBombs = {}
                            local itemBombs = {}
                            
                            if allActors then
                                for _, actor in pairs(allActors) do
                                    if slua.isValid(actor) and not actor.bHidden and not actor.bTearOff then
                                        
                                        -- 1. ULTRA-FAST CACHE CHECK
                                        -- If this actor has been scanned before and is NOT A BOMB -> Skip immediately (Reduces lag by 99%)
                                        if not _G.NonBombCache[actor] then
                                            local bType = 0
                                            local isItem = false
                                            local isKnownBomb = _G.BombCache[actor]
                                            
                                            if isKnownBomb then
                                                bType = isKnownBomb.type
                                                isItem = isKnownBomb.isItem
                                            else
                                                -- First time seeing this Actor, perform a name check (Very rare)
                                                local nameLower = nil
                                                pcall(function() nameLower = string.lower(type(actor.GetName) == "function" and actor:GetName() or tostring(actor)) end)
                                                
                                                if nameLower then
                                                    if string.find(nameLower, "m79") or string.find(nameLower, "launcher") then bType = 5
                                                    elseif string.find(nameLower, "smoke") then bType = 2
                                                    elseif string.find(nameLower, "burn") or string.find(nameLower, "molotov") then bType = 3
                                                    elseif string.find(nameLower, "flash") or string.find(nameLower, "stun") then bType = 4
                                                    elseif string.find(nameLower, "grenade") then bType = 1 end
                                                    
                                                    if bType > 0 then
                                                        if string.find(nameLower, "projectile") or string.find(nameLower, "thrown") then
                                                            isItem = false
                                                        else
                                                            isItem = true
                                                            local shouldAdd = true
                                                            if bType == 3 and not (string.find(nameLower, "pickup") or string.find(nameLower, "wrapper") or string.find(nameLower, "weapon")) then
                                                                shouldAdd = false
                                                            elseif bType == 5 then
                                                                local attachParent = nil
                                                                pcall(function() if type(actor.GetAttachParentActor) == "function" then attachParent = actor:GetAttachParentActor() end end)
                                                                if slua.isValid(attachParent) then
                                                                    local isHolding = false
                                                                    pcall(function()
                                                                        local curWeapon = type(attachParent.GetCurrentWeapon) == "function" and attachParent:GetCurrentWeapon() or attachParent.CurrentWeapon
                                                                        if curWeapon == actor then isHolding = true end
                                                                    end)
                                                                    if not isHolding then shouldAdd = false end
                                                                end
                                                            end
                                                            if not shouldAdd then bType = 0 end
                                                        end
                                                    end
                                                end
                                                
                                                -- Save the result into the Cache
                                                if bType > 0 then
                                                    _G.BombCache[actor] = { type = bType, isItem = isItem }
                                                else
                                                    _G.NonBombCache[actor] = true
                                                end
                                            end
                                            
                                            -- If it is a valid Bomb (from Cache or newly found)
                                            if bType > 0 then
                                                local isPendingKill = false
                                                pcall(function() if type(actor.IsPendingKill) == "function" then isPendingKill = actor:IsPendingKill() end end)
                                                
                                                if not isPendingKill then
                                                    if isItem then
                                                        table.insert(itemBombs, {act = actor, type = bType})
                                                    else
                                                        table.insert(activeBombs, {act = actor, type = bType})
                                                    end
                                                else
                                                    -- Remove from cache if the bomb has exploded/disappeared
                                                    _G.BombCache[actor] = nil
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            _G.CachedActiveBombs = activeBombs
                            _G.CachedItemBombs = itemBombs
                        end

                        local curGameTime = 0
                        pcall(function() curGameTime = _G.CachedGameplayStatics.GetTimeSeconds(gameInstance) end)

                        local function DrawBombs(bombList, isItem, maxDist)
                            if not bombList then return end
                            for _, item in ipairs(bombList) do
                                local bomb = item.act
                                local bType = item.type
                                
                                if slua.isValid(bomb) and not bomb.bHidden then
                                    local distM = 0
                                    pcall(function() distM = localPlayer:GetDistanceTo(bomb) / 100 end)
                                    
                                    if distM > 0 and distM <= maxDist then
                                        local displayName = ""
                                        local bombColor = C_WHITE
                                        local zOffset = isItem and 15 or 25
                                        
                                        if bType == 1 then displayName = "Boom"; bombColor = isItem and {R=255, G=100, B=100, A=255} or C_RED
                                        elseif bType == 2 then displayName = "KHÓI"; bombColor = isItem and {R=200, G=200, B=200, A=255} or C_WHITE
                                        elseif bType == 3 then displayName = "LỬA"; bombColor = isItem and {R=255, G=160, B=50, A=255} or {R=255, G=100, B=0, A=255}
                                        elseif bType == 4 then displayName = "MÙ"; bombColor = isItem and {R=150, G=255, B=255, A=255} or C_CYAN
                                        elseif bType == 5 then displayName = "SMOKE GRENADE"; bombColor = isItem and {R=150, G=255, B=150, A=255} or {R=100, G=255, B=100, A=255} end
                                        
                                        local text = string.format("%s [%dm]", displayName, math.floor(distM))
                                        local shouldTimerRun = not isItem 
                                        
                                        if isItem then pcall(function() if bomb.bIsPinPulled or bomb.bPinPulled or (type(bomb.IsPinPulled) == "function" and bomb:IsPinPulled()) then shouldTimerRun = true end end) end

                                        if shouldTimerRun and curGameTime > 0 then
                                            local timeLeft = -1
                                            pcall(function() if bomb.ExplosionTime then timeLeft = bomb.ExplosionTime - curGameTime elseif bomb.ExplodeTime then timeLeft = bomb.ExplodeTime - curGameTime end end)
                                            
                                            if timeLeft == -1 or timeLeft > 100 then
                                                _G.ActiveBombTimers = _G.ActiveBombTimers or {}
                                                local bombId = tostring(bomb)
                                                if not _G.ActiveBombTimers[bombId] then _G.ActiveBombTimers[bombId] = curGameTime end
                                                local elapsed = curGameTime - _G.ActiveBombTimers[bombId]
                                                local maxTime = (bType == 1 and 7.0) or (bType == 2 and 45.0) or (bType == 3 and 12.0) or (bType == 4 and 5.0) or 45.0
                                                timeLeft = maxTime - elapsed
                                            end
                                            
                                            if timeLeft < 0 then timeLeft = 0 end
                                            if timeLeft > 0.1 then text = string.format("%s (%.1fs)", text, timeLeft) end
                                        end
                                        
                                        local dynamicScale = math.max(0.6, 1.1 - (distM / maxDist))
                                        MyHUD:AddDebugText(text, bomb, 0.06, {X=0, Y=0, Z=zOffset}, {X=0, Y=0, Z=zOffset}, bombColor, true, false, true, nil, dynamicScale, true)
                                    end
                                end
                            end
                        end
                        
                        if not _G.LastClearTimer or (curTime - _G.LastClearTimer) > 1.0 then
                            _G.LastClearTimer = curTime
                            pcall(function() if _G.ActiveBombTimers then for k, v in pairs(_G.ActiveBombTimers) do if (curGameTime - v) > 60.0 then _G.ActiveBombTimers[k] = nil end end end end)
                        end

                        if true then DrawBombs(_G.CachedItemBombs, true, 50) end
                        if true then DrawBombs(_G.CachedActiveBombs, false, 150) end
                    end
                end
            end)
        end
end
-- ========================================================================
-- ⚡ ESP V2 SYSTEM (RedBoxOverlay + PlayerMapMarker) - FIXED
-- ========================================================================
local PlayerMapMarker = {}
local RedBoxOverlay = {
    bActive = false,
    MainContainer = nil,
    WidgetSlot = nil,
    TextBlock = nil,
    Width = 300,
    Height = 42,
    OffsetY = 46,
    PlayerCount = 0,
    BotCount = 0,
    NearestDistance = 0,
    Layers = {},
    FontSize = 15,
    TextScaleValue = 1.0,
    _CachedText = "",
    _CachedPosVec = nil
}

function RedBoxOverlay.Create()
    if RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then return true end

    local ParentCanvas = PlayerMapMarker.ESPCanvas
    if not ParentCanvas or not slua.isValid(ParentCanvas) then 
        if not PlayerMapMarker.InitESPCanvas() then return false end
        ParentCanvas = PlayerMapMarker.ESPCanvas
    end

    if not ParentCanvas or not slua.isValid(ParentCanvas) then return false end

    local Container = nil
    pcall(function() Container = CGame:NewObjectFromPath("/Script/UMG.CanvasPanel", ParentCanvas) end)
    if not Container or not slua.isValid(Container) then return false end

    local FLinearColor = import("LinearColor") or FLinearColor
    local FVector2D = import("Vector2D") or FVector2D
    
    -- Layered red banner from the V2 visual reference.
    local CounterLayers = {
        {width = 300, height = 42, r = 0.003, g = 0.003, b = 0.006, a = 0.62, z = 0},
        {width = 288, height = 40, r = 0.95, g = 0.75, b = 0.02, a = 0.12, z = 1},
        {width = 276, height = 38, r = 0.95, g = 0.68, b = 0.01, a = 0.24, z = 2},
        {width = 264, height = 36, r = 1.00, g = 0.78, b = 0.02, a = 0.42, z = 3},
        {width = 252, height = 34, r = 1.00, g = 0.85, b = 0.03, a = 0.64, z = 4},
        {width = 240, height = 32, r = 1.00, g = 0.92, b = 0.06, a = 0.86, z = 5},
        {width = 228, height = 30, r = 1.00, g = 0.98, b = 0.12, a = 1.00, z = 6}
    }
    RedBoxOverlay.Layers = {}
    for _, layerConfig in ipairs(CounterLayers) do
        local border = nil
        pcall(function() border = CGame:NewObjectFromPath("/Script/UMG.Border", Container) end)
        if border and slua.isValid(border) then
            pcall(function()
                border:SetBrushColor(FLinearColor(layerConfig.r, layerConfig.g, layerConfig.b, layerConfig.a))
                border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            end)
            local slot = Container:AddChildToCanvas(border)
            if slot then
                pcall(function()
                    slot:SetPosition(FVector2D((RedBoxOverlay.Width - layerConfig.width) * 0.5, (RedBoxOverlay.Height - layerConfig.height) * 0.5))
                    slot:SetSize(FVector2D(layerConfig.width, layerConfig.height))
                    slot:SetZOrder(layerConfig.z)
                end)
                table.insert(RedBoxOverlay.Layers, {Widget = border, Slot = slot})
            end
        end
    end

    local FSlateColor = import("SlateColor") or import("/Script/SlateCore.SlateColor")
    
    -- Text: Enemy: X | Bot: Y
    local txtBlock = nil
    pcall(function() txtBlock = CGame:NewObjectFromPath("/Script/UMG.TextBlock", Container) end)
    if txtBlock and slua.isValid(txtBlock) then
        pcall(function()
            local strText = string.format("Player: %d   Bot: %d", RedBoxOverlay.PlayerCount, RedBoxOverlay.BotCount)
            txtBlock:SetText(strText)
            RedBoxOverlay._CachedText = strText

            -- V2 reference uses white text on the red banner.
            local whiteTextColor = FLinearColor(0.01, 0.01, 0.01, 1.0)
            if FSlateColor then txtBlock:SetColorAndOpacity(FSlateColor(whiteTextColor)) else txtBlock:SetColorAndOpacity(whiteTextColor) end

            if txtBlock.Font then
                local font = txtBlock.Font
                font.Size = RedBoxOverlay.FontSize
                txtBlock.Font = font
            end
            txtBlock:SetRenderScale(FVector2D(RedBoxOverlay.TextScaleValue, RedBoxOverlay.TextScaleValue))
            txtBlock:SetRenderTransformPivot(FVector2D(0.5, 0.5))
            txtBlock:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end)
        local txtSlot = Container:AddChildToCanvas(txtBlock)
        if txtSlot then
            pcall(function()
                txtSlot:SetAutoSize(true)
                txtSlot:SetAlignment(FVector2D(0.5, 0.5))
                txtSlot:SetPosition(FVector2D(RedBoxOverlay.Width * 0.5, RedBoxOverlay.Height * 0.5))
                txtSlot:SetZOrder(1000)
            end)
        end
        RedBoxOverlay.TextBlock = txtBlock
    end

    local MainSlot = nil
    pcall(function() MainSlot = ParentCanvas:AddChildToCanvas(Container) end)
    if not MainSlot then return false end

    RedBoxOverlay.MainContainer = Container
    RedBoxOverlay.WidgetSlot = MainSlot
    
    pcall(function()
        MainSlot:SetAutoSize(false)
        MainSlot:SetZOrder(999)
        MainSlot:SetAlignment(FVector2D(0.5, 0.0))
        MainSlot:SetSize(FVector2D(RedBoxOverlay.Width, RedBoxOverlay.Height))
    end)

    RedBoxOverlay.UpdatePosition()
    return true
end

function RedBoxOverlay.SetCounts(players, bots)
    local nearestMeters = 0
    pcall(function()
        local nearest = nil
        for _, data in pairs(PlayerMapMarker.ESPWidgets or {}) do
            local dist = tonumber(data and data.LastDistance)
            if dist and dist >= 0 then
                local meters = math.floor(dist / 100)
                if nearest == nil or meters < nearest then nearest = meters end
            end
        end
        nearestMeters = nearest or 0
    end)
    if RedBoxOverlay.PlayerCount == players and RedBoxOverlay.BotCount == bots and RedBoxOverlay.NearestDistance == nearestMeters then return end
    RedBoxOverlay.PlayerCount = players or 0
    RedBoxOverlay.BotCount = bots or 0
    RedBoxOverlay.NearestDistance = nearestMeters
    
    if RedBoxOverlay.TextBlock and slua.isValid(RedBoxOverlay.TextBlock) then
        pcall(function()
            local str = string.format("Player: %d   Bot: %d   Dist: %dm", RedBoxOverlay.PlayerCount, RedBoxOverlay.BotCount, RedBoxOverlay.NearestDistance)
            if RedBoxOverlay._CachedText ~= str then
                RedBoxOverlay.TextBlock:SetText(str)
                RedBoxOverlay._CachedText = str
            end
        end)
    end
end

function RedBoxOverlay.UpdatePosition()
    local Slot = RedBoxOverlay.WidgetSlot
    if not Slot or not slua.isValid(Slot) then return end
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not slua.isValid(PC) then return end

    local fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC)
    local FVector2D = import("Vector2D") or FVector2D
    pcall(function()
        if not RedBoxOverlay._CachedPosVec then
            RedBoxOverlay._CachedPosVec = FVector2D(fromX, fromY)
        else
            RedBoxOverlay._CachedPosVec.X = fromX
            RedBoxOverlay._CachedPosVec.Y = fromY
        end
        local counterPos = FVector2D(fromX, fromY - 30)
        if RedBoxOverlay._CachedPosVec then
            RedBoxOverlay._CachedPosVec.X = counterPos.X
            RedBoxOverlay._CachedPosVec.Y = counterPos.Y
        else
            RedBoxOverlay._CachedPosVec = counterPos
        end
        Slot:SetPosition(RedBoxOverlay._CachedPosVec)
        pcall(function()
            Slot:SetAlignment(FVector2D(0.5, 0.0))
            Slot:SetSize(FVector2D(RedBoxOverlay.Width, RedBoxOverlay.Height))
        end)
    end)
end

function RedBoxOverlay.Start()
    if RedBoxOverlay.bActive and RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then return end
    if RedBoxOverlay.Create() then
        RedBoxOverlay.bActive = true
        pcall(function() RedBoxOverlay.MainContainer:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    end
end

function RedBoxOverlay.Stop()
    RedBoxOverlay.bActive = false
    if RedBoxOverlay.MainContainer and slua.isValid(RedBoxOverlay.MainContainer) then
        pcall(function()
            RedBoxOverlay.MainContainer:RemoveFromParent()
            RedBoxOverlay.MainContainer:ConditionalBeginDestroy()
        end)
    end
    RedBoxOverlay.MainContainer = nil
    RedBoxOverlay.WidgetSlot = nil
    RedBoxOverlay.TextBlock = nil
    RedBoxOverlay.Layers = {}
    RedBoxOverlay.NearestDistance = 0
    RedBoxOverlay._CachedPosVec = nil
end

_G.RedBoxOverlay = RedBoxOverlay

-- ========================================================================
-- ⚡ ESP V2 SYSTEM (Continued) - FIXED
-- ========================================================================
local SlateBlueprintLibrary = nil
local WidgetLayoutLibrary = nil
local KismetMathLibrary_ESP9 = nil
local KismetSystemLibrary_ESP9 = nil

pcall(function() SlateBlueprintLibrary = import("SlateBlueprintLibrary") or import("/Script/UMG.SlateBlueprintLibrary") end)
pcall(function() WidgetLayoutLibrary = import("WidgetLayoutLibrary") or import("/Script/UMG.WidgetLayoutLibrary") end)
pcall(function() KismetMathLibrary_ESP9 = import("KismetMathLibrary") end)
pcall(function() KismetSystemLibrary_ESP9 = import("KismetSystemLibrary") end)

local FVector2D_ESP9 = _G.FVector2D or import("Vector2D")
local FLinearColor_ESP9 = _G.FLinearColor or import("LinearColor")
local FVector_ESP9 = _G.FVector or import("Vector")

PlayerMapMarker.MarkTypeID = 1007
PlayerMapMarker.bUseScreenESP = true
PlayerMapMarker.bUseScreenMark = false
PlayerMapMarker.bUseQuickSign = false
PlayerMapMarker.bUseNavigator = false
PlayerMapMarker.bUseWidgetComponent = false
PlayerMapMarker.ESPBoneName = "head"
PlayerMapMarker.ESPWorldOffsetZ = 0
PlayerMapMarker.ESPAnchorOffsetX = 35
PlayerMapMarker.ESPAnchorOffsetY = 0
PlayerMapMarker.ESPTextOffsetX = 0
PlayerMapMarker.ESPTextOffsetY = 0
PlayerMapMarker.ESPWidgetAlignment = FVector2D_ESP9 and FVector2D_ESP9(0.5, 1.0) or {X=0.5, Y=1.0}
PlayerMapMarker.ESPWidgetSize = FVector2D_ESP9 and FVector2D_ESP9(70, 21) or {X=70, Y=21}
PlayerMapMarker.ESPWidgetAutoSize = true
PlayerMapMarker.ESPWidgetZOrder = 2
PlayerMapMarker.bShowDistance = true
PlayerMapMarker.DistanceUnit = "m"
PlayerMapMarker.HPWidgetSwitcherTypeIndex = 0
PlayerMapMarker.HPWidgetSwitcherType2Index = 0
PlayerMapMarker.bForceSwitcherIndexEveryUpdate = true
PlayerMapMarker.bUseSnapLines = true
PlayerMapMarker.SnapLineThickness = 1.0
PlayerMapMarker.SnapLineOriginY = 50
PlayerMapMarker.SnapLineOriginOffsetX = 0
PlayerMapMarker.SnapLineHeadOffsetX = 0
PlayerMapMarker.SnapLineHeadOffsetY = -14
PlayerMapMarker.SnapLineColor = FLinearColor_ESP9 and FLinearColor_ESP9(0.6, 0.0, 0.0, 1.0) or {R=150, G=0, B=0, A=255}
PlayerMapMarker.SnapLineOpacity = 0.7

PlayerMapMarker.nUpdateInterval = 0.5
PlayerMapMarker.bUseFrameTick = false
PlayerMapMarker.nHeavyScanFrameInterval = 15
PlayerMapMarker.nDistanceUpdateFrameInterval = 5
PlayerMapMarker.bIncludeMe = false
PlayerMapMarker.bIncludeAI = true
PlayerMapMarker.bActive = false
PlayerMapMarker.PlayerInfo = {}
PlayerMapMarker.ESPCanvas = nil
PlayerMapMarker.ESPWidgets = {}
PlayerMapMarker.ESPWidgetPtrs = {}
PlayerMapMarker.SnapLineWidgets = {}
PlayerMapMarker._cachedViewportW = 1920
PlayerMapMarker._cachedViewportH = 1080
PlayerMapMarker._FrameCount = 0
PlayerMapMarker._bTickRegistered = false
PlayerMapMarker._CachedAllChars = nil
PlayerMapMarker._CachedMyLoc = nil
PlayerMapMarker._CachedMyKey = nil
PlayerMapMarker.WidgetComps = {}
PlayerMapMarker._bAllPathsFailed = false
PlayerMapMarker._bLightUpdateScheduled = false
PlayerMapMarker._LightUpdateInterval = 0.02
PlayerMapMarker._bDistanceUpdateScheduled = false
PlayerMapMarker._DistanceUpdateInterval = 0.1

local function IsValid_ESP9(obj)
    if obj == nil then return false end
    if slua and slua.isValid then return slua.isValid(obj) end
    return obj ~= nil
end

function PlayerMapMarker.GetGameplayData()
    if PlayerMapMarker._CachedGameplayData then return PlayerMapMarker._CachedGameplayData end
    local ok, GDP = pcall(function() return require("GameLua.GameCore.Data.GameplayData") end)
    if ok and GDP then PlayerMapMarker._CachedGameplayData = GDP return GDP end
    return nil
end

function PlayerMapMarker.GetMyPlayerController()
    local PC = PlayerMapMarker._CachedPC
    if PC and IsValid_ESP9(PC) then return PC end
    local GDP = PlayerMapMarker.GetGameplayData()
    if not GDP then return nil end
    pcall(function() PC = GDP.GetPlayerController and GDP.GetPlayerController() end)
    if PC and IsValid_ESP9(PC) then PlayerMapMarker._CachedPC = PC return PC end
    return nil
end

function PlayerMapMarker.GetCGameState()
    if CGameState and IsValid_ESP9(CGameState) then return CGameState end
    if PlayerMapMarker._CachedCGameState and IsValid_ESP9(PlayerMapMarker._CachedCGameState) then return PlayerMapMarker._CachedCGameState end
    local ok, GS = pcall(function() return require("GameLua.GameCore.Data.CGameState") end)
    if ok and GS then PlayerMapMarker._CachedCGameState = GS return GS end
    return nil
end

function PlayerMapMarker.GetAllCharacters()
    local AllChars = {}
    pcall(function()
        local Pawns = Game:GetAllPlayerPawns()
        if Pawns then
            for _, Pawn in pairs(Pawns) do
                if Pawn and slua.isValid(Pawn) then
                    local pKey = nil
                    if Pawn.GetPlayerKey then pKey = Pawn:GetPlayerKey() end
                    if not pKey and Pawn.PlayerKey then pKey = Pawn.PlayerKey end
                    if not pKey and Pawn.PlayerState and Pawn.PlayerState.PlayerKey then pKey = Pawn.PlayerState.PlayerKey end
                    if pKey then AllChars[pKey] = Pawn end
                end
            end
        end
    end)
    if not next(AllChars) then
        local GS = PlayerMapMarker.GetCGameState()
        if GS and GS.GetAllCharacters then pcall(function() AllChars = GS:GetAllCharacters() end) end
    end
    return AllChars
end

function PlayerMapMarker.GetMyPlayerKey()
    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return nil end
    local MyKey = nil
    pcall(function()
        if PC.GetPlayerKey then MyKey = PC:GetPlayerKey()
        elseif PC.PlayerState and PC.PlayerState.PlayerKey then MyKey = PC.PlayerState.PlayerKey end
    end)
    return MyKey
end

function PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
    local bIsMe = false
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then
            local MyChar = GDP.GetLocalCharacter()
            if MyChar and Character == MyChar then bIsMe = true return end
        end
        local PC = PlayerMapMarker.GetMyPlayerController()
        if PC and PC.GetPawn then
            local Pawn = PC:GetPawn()
            if Pawn and Character == Pawn then bIsMe = true return end
        end
    end)
    if not bIsMe and MyKey ~= nil and PlayerKey ~= nil then bIsMe = (tostring(PlayerKey) == tostring(MyKey)) end
    return bIsMe
end

function PlayerMapMarker.GetCharacterLocation(Character)
    if not IsValid_ESP9(Character) then return nil end
    local Loc = nil
    pcall(function() if Character.K2_GetActorLocation then Loc = Character:K2_GetActorLocation() end end)
    if not Loc then pcall(function() if Game and Game.GetActorLocation then Loc = Game:GetActorLocation(Character) end end) end
    return Loc
end

function PlayerMapMarker.CalcDistance(Loc1, Loc2)
    if not Loc1 or not Loc2 then return nil end
    local Dist = nil
    pcall(function() if FVector_ESP9 and FVector_ESP9.Dist2D then Dist = FVector_ESP9.Dist2D(Loc1, Loc2) end end)
    if not Dist then
        pcall(function()
            local DX = (Loc1.X or 0) - (Loc2.X or 0)
            local DY = (Loc1.Y or 0) - (Loc2.Y or 0)
            Dist = math.sqrt(DX * DX + DY * DY)
        end)
    end
    return Dist
end

function PlayerMapMarker.GetDistanceString(MyLoc, TargetLoc)
    if not PlayerMapMarker.bShowDistance then return "" end
    if not MyLoc or not TargetLoc then return "" end
    local Dist = PlayerMapMarker.CalcDistance(MyLoc, TargetLoc)
    if not Dist then return "" end
    local Meters = Dist / 100
    if Meters < 1000 then return string.format("%dm", math.floor(Meters))
    else return string.format("%.1fkm", Meters / 1000) end
end

function PlayerMapMarker.GetMyLocation()
    local GDP = PlayerMapMarker.GetGameplayData()
    if not GDP then return nil end
    local MyChar = nil
    pcall(function() MyChar = GDP.GetLocalCharacter and GDP.GetLocalCharacter() end)
    if not IsValid_ESP9(MyChar) then return nil end
    return PlayerMapMarker.GetCharacterLocation(MyChar)
end

function PlayerMapMarker.GetPlayerName(Character)
    if not IsValid_ESP9(Character) then return "Unknown" end
    local Name = nil
    pcall(function() if Character.GetPlayerNameSafety then Name = Character:GetPlayerNameSafety() end end)
    if not Name then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety()
            elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if IsValid_ESP9(PS) and PS.GetPlayerName then Name = PS:GetPlayerName() end
        end)
    end
    return Name or "Unknown"
end

function PlayerMapMarker.IsAI(Character)
    local bAI = false
    pcall(function() if Game and Game.IsAI then bAI = Game:IsAI(Character) end end)
    return bAI
end

function PlayerMapMarker.IsAlive(Character)
    local bAlive = true
    pcall(function() if Character.IsAlive then bAlive = Character:IsAlive() end end)
    return bAlive
end

function PlayerMapMarker.GetTeamID(Character)
    if not IsValid_ESP9(Character) then return nil end
    local TeamID = nil
    pcall(function() if Character.GetTeamID then TeamID = Character:GetTeamID() end end)
    if not TeamID then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety()
            elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if IsValid_ESP9(PS) and PS.GetTeamID then TeamID = PS:GetTeamID()
            elseif IsValid_ESP9(PS) and PS.TeamID then TeamID = PS.TeamID end
        end)
    end
    if not TeamID then pcall(function() if Character.TeamID then TeamID = Character.TeamID end end) end
    return TeamID
end

function PlayerMapMarker.GetTeamColor(TeamID)
    if TeamID == nil or TeamID == 0 then
        return FLinearColor_ESP9 and FLinearColor_ESP9(0.2, 0.4, 1.0, 1.0) or {R=50,G=100,B=255,A=255}
    end
    local TeamColors = {
        [1]={R=255,G=50,B=50,A=255,fR=1.0,fG=0.2,fB=0.2},
        [2]={R=50,G=255,B=50,A=255,fR=0.2,fG=1.0,fB=0.2},
        [3]={R=50,G=100,B=255,A=255,fR=0.2,fG=0.4,fB=1.0},
        [4]={R=255,G=255,B=50,A=255,fR=1.0,fG=1.0,fB=0.2},
        [5]={R=255,G=50,B=255,A=255,fR=1.0,fG=0.2,fB=1.0},
        [6]={R=50,G=255,B=255,A=255,fR=0.2,fG=1.0,fB=1.0},
        [7]={R=255,G=150,B=50,A=255,fR=1.0,fG=0.6,fB=0.2},
        [8]={R=150,G=50,B=255,A=255,fR=0.6,fG=0.2,fB=1.0},
        [9]={R=200,G=255,B=50,A=255,fR=0.8,fG=1.0,fB=0.2},
        [10]={R=50,G=150,B=255,A=255,fR=0.2,fG=0.6,fB=1.0},
        [11]={R=255,G=100,B=150,A=255,fR=1.0,fG=0.4,fB=0.6},
        [12]={R=100,G=255,B=150,A=255,fR=0.4,fG=1.0,fB=0.6},
        [13]={R=150,G=150,B=50,A=255,fR=0.6,fG=0.6,fB=0.2},
        [14]={R=50,G=200,B=150,A=255,fR=0.2,fG=0.8,fB=0.6},
        [15]={R=255,G=200,B=50,A=255,fR=1.0,fG=0.8,fB=0.2}
    }
    local colorIndex = (TeamID % 15)
    if colorIndex == 0 then colorIndex = 15 end
    local c = TeamColors[colorIndex]
    return FLinearColor_ESP9 and FLinearColor_ESP9(c.fR, c.fG, c.fB, 1.0) or {R=c.R, G=c.G, B=c.B, A=c.A}
end

function PlayerMapMarker.InitESPCanvas()
    if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then return true end
    local InGameUITools = nil
    pcall(function() InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools") end)
    if not InGameUITools then return false end
    local MainControlBaseUI = nil
    pcall(function() MainControlBaseUI = InGameUITools.GetMainControlBaseUI() end)
    if not MainControlBaseUI or not Game:IsValid(MainControlBaseUI) then return false end
    local ParentCanvas = nil
    pcall(function()
        if MainControlBaseUI.CanvasPanel_0 and Game:IsValid(MainControlBaseUI.CanvasPanel_0) then ParentCanvas = MainControlBaseUI.CanvasPanel_0
        elseif MainControlBaseUI.CanvasPanel_42 and Game:IsValid(MainControlBaseUI.CanvasPanel_42) then ParentCanvas = MainControlBaseUI.CanvasPanel_42 end
    end)
    if not ParentCanvas then return false end
    PlayerMapMarker.ESPCanvas = ParentCanvas
    return true
end

function PlayerMapMarker.GetESPLocation(Character)
    if not IsValid_ESP9(Character) then return nil end
    local BoneLoc = PlayerMapMarker.GetCharacterLocation(Character)
    if BoneLoc then
        local heightOffset = 85
        pcall(function()
            if Character.bIsCrouched then heightOffset = 60 end
            if Character.IsProne and Character:IsProne() then heightOffset = 30 end
        end)
        pcall(function() BoneLoc.Z = BoneLoc.Z + heightOffset + (PlayerMapMarker.ESPWorldOffsetZ or 0) end)
    end
    return BoneLoc
end

function PlayerMapMarker.GetCharacterWeaponInfo(Character)
    if not IsValid_ESP9(Character) then return nil end
    local WeaponID, WeaponName, WeaponIconPath, WeaponIconTexture, CurrentWeapon = nil, nil, nil, nil, nil
    pcall(function() if Character.GetCurrentWeapon then CurrentWeapon = Character:GetCurrentWeapon() end end)
    if not CurrentWeapon then pcall(function() CurrentWeapon = Character.CurrentWeapon end) end
    if not CurrentWeapon then pcall(function() if Character.GetWeaponManager then local WM = Character:GetWeaponManager() if WM and WM.GetCurrentWeapon then CurrentWeapon = WM:GetCurrentWeapon() end end end) end
    if CurrentWeapon and IsValid_ESP9(CurrentWeapon) then
        pcall(function() if CurrentWeapon.GetWeaponID then WeaponID = CurrentWeapon:GetWeaponID() end end)
        if not WeaponID then pcall(function() WeaponID = CurrentWeapon.WeaponID end) end
        if not WeaponID then pcall(function() if CurrentWeapon.GetItemID then WeaponID = CurrentWeapon:GetItemID() end end) end
        pcall(function() if CurrentWeapon.GetWeaponName then WeaponName = CurrentWeapon:GetWeaponName() end end)
        pcall(function() if CurrentWeapon.GetWeaponIconPath then WeaponIconPath = CurrentWeapon:GetWeaponIconPath() end end)
        pcall(function() if CurrentWeapon.GetWeaponIcon then WeaponIconTexture = CurrentWeapon:GetWeaponIcon() end end)
    end
    if not WeaponID then
        pcall(function()
            local PS = nil
            if Character.GetPlayerStateSafety then PS = Character:GetPlayerStateSafety() elseif Character.GetPlayerState then PS = Character:GetPlayerState() end
            if PS and IsValid_ESP9(PS) then
                if PS.GetCurrentWeaponID then WeaponID = PS:GetCurrentWeaponID() end
                if not WeaponID and PS.CurWeaponID then WeaponID = PS.CurWeaponID end
            end
        end)
    end
    return { WeaponID = WeaponID, WeaponName = WeaponName, WeaponIconPath = WeaponIconPath, WeaponIconTexture = WeaponIconTexture, CurrentWeapon = CurrentWeapon }
end

PlayerMapMarker._OBHeadWidgetClass = nil
PlayerMapMarker._OBHeadWidgetLoadFailed = false

function PlayerMapMarker.CreateESPWidget()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end
    if PlayerMapMarker._OBHeadWidgetLoadFailed then return nil end

    if not PlayerMapMarker._OBHeadWidgetClass then
        pcall(function()
            local Path = "/Game/BluePrints/UI/OBUI/Item/OB_PlayerHeadHPItem_UIBP.OB_PlayerHeadHPItem_UIBP"
            local uClass = slua.loadClass(Path)
            if uClass then PlayerMapMarker._OBHeadWidgetClass = uClass end
        end)
        if not PlayerMapMarker._OBHeadWidgetClass then
            PlayerMapMarker._OBHeadWidgetLoadFailed = true
            return nil
        end
    end

    local Widget = nil
    pcall(function()
        local STExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local PC = PlayerMapMarker.GetMyPlayerController()
        local OuterObj = IsValid_ESP9(PC) and PC.Object or PlayerMapMarker.ESPCanvas
        Widget = STExtraBlueprintFunctionLibrary.CreateWidgetByClass(PlayerMapMarker._OBHeadWidgetClass, OuterObj)
    end)
    if not Widget then return nil end

    pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    pcall(function() Widget:SetRenderOpacity(1.0) end)

    local NameText = nil
    local HealthFill = nil
    pcall(function()
        NameText = Widget.TextBlock_TeamName
        if NameText and slua.isValid(NameText) then pcall(function() NameText:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) end
        if Widget.TextBlock_PlayerName and slua.isValid(Widget.TextBlock_PlayerName) then pcall(function() Widget.TextBlock_PlayerName:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end) end
        local SizeBox_HP = Widget.SizeBox_HP
        if SizeBox_HP and slua.isValid(SizeBox_HP) then
            pcall(function() SizeBox_HP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
            local ExistingChild = nil
            pcall(function() if SizeBox_HP.GetContent then ExistingChild = SizeBox_HP:GetContent() end end)
            if ExistingChild and slua.isValid(ExistingChild) then
                local FoundPB = PlayerMapMarker.FindProgressBarInWidget(ExistingChild, 0, 5)
                if FoundPB and slua.isValid(FoundPB) then HealthFill = FoundPB end
            end
        end
    end)

    local WidgetData = {
        Container = Widget,
        NameText = NameText,
        HealthFill = HealthFill,
        IsGameWidget = true,
        HasChildren = (NameText ~= nil)
    }
    return WidgetData
end

function PlayerMapMarker.FindProgressBarInWidget(WidgetObj, Depth, MaxDepth)
    if not WidgetObj or not slua.isValid(WidgetObj) then return nil end
    Depth = Depth or 0
    MaxDepth = MaxDepth or 5
    if Depth > MaxDepth then return nil end

    local bIsPB = false
    pcall(function() if WidgetObj.SetPercent and WidgetObj.SetFillColorAndOpacity then bIsPB = true end end)
    if bIsPB then return WidgetObj end

    local nChildren = 0
    pcall(function() if WidgetObj.GetChildrenCount then nChildren = WidgetObj:GetChildrenCount() end end)
    for i = 0, math.max(nChildren - 1, 0) do
        local child = nil
        pcall(function() child = WidgetObj:GetChildAt(i) end)
        if child and slua.isValid(child) then
            local result = PlayerMapMarker.FindProgressBarInWidget(child, Depth + 1, MaxDepth)
            if result then return result end
        end
    end
    return nil
end

function PlayerMapMarker.ApplyTeamColor(Widget, TeamID)
    if not Widget or not Widget.Container then return end
    if not _G.AK_GetVal("ESP9_Team") == 1 then return end
    local color = PlayerMapMarker.GetTeamColor(TeamID)
    if not color then return end
    pcall(function()
        local W = Widget.Container
        if not W or not slua.isValid(W) then return end
        if W.SetTeamColor then pcall(function() W:SetTeamColor(TeamID) end) end
    end)
end

function PlayerMapMarker.UpdateESPText(Widget, Text)
    if not Widget then return end
    if Widget._LastESPText == Text then return end
    Widget._LastESPText = Text

    local function applyText(w, txt)
        if not w or not slua.isValid(w) then return end
        if txt == "" then
            pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
            return
        else
            pcall(function() w:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
        end
        pcall(function() w:SetText(txt) end)
    end

    if Widget.NameText and slua.isValid(Widget.NameText) then applyText(Widget.NameText, Text) end
    if Widget.IsGameWidget and Widget.Container then
        pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) then
                applyText(W.TextBlock_TeamName, Text)
                applyText(W.TextBlock_PlayerName, Text)
            end
        end)
    end
end

function PlayerMapMarker.UpdateESPHealth(Widget, pct)
    if not Widget then return end
    Widget.LastPct = pct
    local bShowHP = _G.AK_GetVal("ESP9_HP") == 1
    if not bShowHP then
        pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) and W.SizeBox_HP and slua.isValid(W.SizeBox_HP) then
                W.SizeBox_HP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
            end
        end)
        return
    end
    pcall(function()
        local W = Widget.Container
        if W and slua.isValid(W) and W.SizeBox_HP and slua.isValid(W.SizeBox_HP) then
            W.SizeBox_HP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        end
    end)

    if PlayerMapMarker.bForceSwitcherIndexEveryUpdate and Widget.Container then
        pcall(function()
            local W = Widget.Container
            if W and slua.isValid(W) then
                if W.WidgetSwitcher_Type and slua.isValid(W.WidgetSwitcher_Type) then pcall(function() if W.WidgetSwitcher_Type.SetActiveWidgetIndex then W.WidgetSwitcher_Type:SetActiveWidgetIndex(PlayerMapMarker.HPWidgetSwitcherTypeIndex) end end) end
                if W.WidgetSwitcher_Type2 and slua.isValid(W.WidgetSwitcher_Type2) then pcall(function() if W.WidgetSwitcher_Type2.SetActiveWidgetIndex then W.WidgetSwitcher_Type2:SetActiveWidgetIndex(PlayerMapMarker.HPWidgetSwitcherType2Index) end end) end
            end
        end)
    end

    if Widget.HealthFill then
        local bValid = false
        pcall(function() bValid = slua.isValid(Widget.HealthFill) end)
        if bValid then
            pcall(function()
                if Widget.HealthFill.SetPercent then
                    Widget.HealthFill:SetPercent(pct)
                    local color
                    if pct > 0.5 then color = FLinearColor_ESP9 and FLinearColor_ESP9(0.0, 1.0, 0.0, 1.0) or {R=0,G=255,B=0,A=255}
                    elseif pct > 0.25 then color = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.5, 0.0, 1.0) or {R=255,G=128,B=0,A=255}
                    else color = FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 0.0, 0.0, 1.0) or {R=255,G=0,B=0,A=255} end
                    if Widget.HealthFill.SetFillColorAndOpacity then Widget.HealthFill:SetFillColorAndOpacity(color) end
                end
            end)
        end
    end
end

function PlayerMapMarker.UpdateESPPositionWithPC(Widget, WorldLoc, PC, CanvasPos)
    if not Widget or not IsValid_ESP9(PC) then return false end

    local Container = Widget.Container or Widget
    local bOnScreen = true

    if not CanvasPos then
        if not WorldLoc then return false end
        bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, WorldLoc)
    end

    if not bOnScreen then pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end) return false end

    pcall(function()
        local bShowAnyUI = _G.AK_GetVal("ESP9_Name") == 1 or _G.AK_GetVal("ESP9_Distance") == 1 or _G.AK_GetVal("ESP9_HP") == 1 or _G.AK_GetVal("ESP9_Team") == 1
        if bShowAnyUI then Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        else Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end

        if PlayerMapMarker.ESPCanvas and Game:IsValid(PlayerMapMarker.ESPCanvas) then
            local ptr = tostring(Container)
            local Slot = PlayerMapMarker.ESPWidgetPtrs[ptr]
            if not Slot or not slua.isValid(Slot) then
                local addedSlot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Container)
                if addedSlot and slua.isValid(addedSlot) then
                    Slot = addedSlot
                    PlayerMapMarker.ESPWidgetPtrs[ptr] = addedSlot
                    pcall(function() Slot:SetAutoSize(true) end)
                    pcall(function() Slot:SetAlignment(FVector2D_ESP9 and FVector2D_ESP9(0.5, 1.0) or {X=0.5, Y=1.0}) end)
                    pcall(function() Slot:SetZOrder(PlayerMapMarker.ESPWidgetZOrder or 20) end)
                end
            end
            if Slot and slua.isValid(Slot) then
                local finalX = CanvasPos.X + (PlayerMapMarker.ESPAnchorOffsetX or 0)
                local finalY = CanvasPos.Y + (PlayerMapMarker.ESPAnchorOffsetY or 0)
                if not Widget._CachedPosVec then Widget._CachedPosVec = FVector2D_ESP9 and FVector2D_ESP9(finalX, finalY) or {X=finalX, Y=finalY}
                else Widget._CachedPosVec.X = finalX; Widget._CachedPosVec.Y = finalY end
                pcall(function() Slot:SetPosition(Widget._CachedPosVec) end)
            end
        end
    end)
    return true
end

PlayerMapMarker._CanvasScaleX = 1.0
PlayerMapMarker._CanvasScaleY = 1.0
PlayerMapMarker._CanvasOffsetX = 0.0
PlayerMapMarker._CanvasOffsetY = 0.0

function PlayerMapMarker.UpdateCanvasTransform(PC)
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local success = false
    pcall(function()
        local SBL = SlateBlueprintLibrary
        if SBL and SBL.AbsoluteToLocal then
            local cg = PlayerMapMarker.ESPCanvas:GetCachedGeometry()
            if cg then
                local pt0 = SBL.AbsoluteToLocal(cg, FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0})
                local pt1 = SBL.AbsoluteToLocal(cg, FVector2D_ESP9 and FVector2D_ESP9(100, 100) or {X=100, Y=100})
                if pt0 and pt1 then
                    PlayerMapMarker._CanvasScaleX = (pt1.X - pt0.X) / 100
                    PlayerMapMarker._CanvasScaleY = (pt1.Y - pt0.Y) / 100
                    PlayerMapMarker._CanvasOffsetX = pt0.X
                    PlayerMapMarker._CanvasOffsetY = pt0.Y
                    success = true
                end
            end
        end
    end)

    if not success then
        local scale = 1.0
        if WidgetLayoutLibrary and WidgetLayoutLibrary.GetViewportScale then scale = WidgetLayoutLibrary.GetViewportScale(PC) or 1.0 end
        PlayerMapMarker._CanvasScaleX = 1.0 / scale
        PlayerMapMarker._CanvasScaleY = 1.0 / scale
        PlayerMapMarker._CanvasOffsetX = 0
        PlayerMapMarker._CanvasOffsetY = 0
    end
end

function PlayerMapMarker.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
    if not ScreenPixelPos then return FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0} end
    local scaleX = PlayerMapMarker._CanvasScaleX or 1.0
    local scaleY = PlayerMapMarker._CanvasScaleY or 1.0
    local offsetX = PlayerMapMarker._CanvasOffsetX or 0
    local offsetY = PlayerMapMarker._CanvasOffsetY or 0
    return (FVector2D_ESP9 and FVector2D_ESP9(ScreenPixelPos.X * scaleX + offsetX, ScreenPixelPos.Y * scaleY + offsetY)) or {X = ScreenPixelPos.X * scaleX + offsetX, Y = ScreenPixelPos.Y * scaleY + offsetY}
end

function PlayerMapMarker.ProjectWorldToCanvasLocal(PC, WorldLoc)
    if not IsValid_ESP9(PC) or not WorldLoc then return false, (FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}) end

    local ScreenPixelPos = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}
    local bOK = false
    pcall(function()
        local res = PC:ProjectWorldLocationToScreen(WorldLoc, ScreenPixelPos, true)
        if res == true or res == 1 or (ScreenPixelPos and (ScreenPixelPos.X ~= 0 or ScreenPixelPos.Y ~= 0)) then bOK = true end
    end)

    if not bOK or not ScreenPixelPos or (ScreenPixelPos.X == 0 and ScreenPixelPos.Y == 0) then return false, (FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}) end

    local CanvasLocalPos = PlayerMapMarker.ScreenPixelToCanvasLocal(PC, ScreenPixelPos)
    return true, CanvasLocalPos
end

function PlayerMapMarker.GetSnapLineStartPos(PC)
    local screenPixelW, screenPixelH = 0, 0
    local scale = 1.0

    pcall(function()
        if PC and PC.GetViewportSize then
            local vs = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0,Y=0}
            PC:GetViewportSize(vs)
            if vs and vs.X and vs.X > 200 then screenPixelW = vs.X screenPixelH = vs.Y end
        end
    end)

    if screenPixelW <= 200 then
        pcall(function()
            local WLL = WidgetLayoutLibrary
            if WLL and WLL.GetViewportSize then
                local vs = WLL.GetViewportSize(PC)
                if vs and vs.X and vs.X > 200 then screenPixelW = vs.X screenPixelH = vs.Y end
            end
        end)
    end

    pcall(function()
        local WLL = WidgetLayoutLibrary
        if WLL and WLL.GetViewportScale then
            local s = WLL.GetViewportScale(PC)
            if s and type(s) == "number" and s > 0 then scale = s end
        end
    end)

    if screenPixelW <= 200 then
        screenPixelW = (PlayerMapMarker._cachedViewportW or 1920) * scale
        screenPixelH = (PlayerMapMarker._cachedViewportH or 1080) * scale
    end

    if not PlayerMapMarker._CachedTopCenterPixel then PlayerMapMarker._CachedTopCenterPixel = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0,Y=0} end
    PlayerMapMarker._CachedTopCenterPixel.X = screenPixelW / 2.0
    PlayerMapMarker._CachedTopCenterPixel.Y = (PlayerMapMarker.SnapLineOriginY or 50) * scale

    local fromCanvasPos = PlayerMapMarker.ScreenPixelToCanvasLocal(PC, PlayerMapMarker._CachedTopCenterPixel)
    return fromCanvasPos.X + (PlayerMapMarker.SnapLineOriginOffsetX or 0), fromCanvasPos.Y
end

function PlayerMapMarker.CreateSnapLine()
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return nil end

    local Border = nil
    pcall(function() Border = CGame:NewObjectFromPath("/Script/UMG.Border", PlayerMapMarker.ESPCanvas) end)
    if not Border or not slua.isValid(Border) then return nil end

    local color = PlayerMapMarker.SnapLineColor or (FLinearColor_ESP9 and FLinearColor_ESP9(1.0, 1.0, 1.0, PlayerMapMarker.SnapLineOpacity or 0.7) or {R=1,G=1,B=1,A=PlayerMapMarker.SnapLineOpacity or 0.7})
    pcall(function() Border:SetBrushColor(color) end)
    pcall(function() Border:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
    pcall(function() Border.RenderTransformPivot = FVector2D_ESP9 and FVector2D_ESP9(0.0, 0.5) or {X=0,Y=0.5} end)
    pcall(function() Border:SetRenderTransformPivot(FVector2D_ESP9 and FVector2D_ESP9(0.0, 0.5) or {X=0,Y=0.5}) end)

    local Slot = nil
    pcall(function()
        Slot = PlayerMapMarker.ESPCanvas:AddChildToCanvas(Border)
        if Slot then Slot:SetAutoSize(false) Slot:SetZOrder(1) end
    end)
    return { Widget = Border, Slot = Slot }
end

function PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
    if not PlayerMapMarker.bUseSnapLines then return end
    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local LineData = PlayerMapMarker.SnapLineWidgets[KeyStr]
    if LineData and (not LineData.Widget or not slua.isValid(LineData.Widget) or not LineData.Slot) then
        PlayerMapMarker.RemoveSnapLine(KeyStr)
        LineData = nil
    end
    if not bOnScreen or not CanvasPos then
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            pcall(function() LineData.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
        end
        return
    end

    if not LineData then
        LineData = PlayerMapMarker.CreateSnapLine()
        if not LineData or not LineData.Widget or not LineData.Slot then return end
        PlayerMapMarker.SnapLineWidgets[KeyStr] = LineData
    end

    local Widget = LineData.Widget
    local Slot = LineData.Slot

    pcall(function() Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)

    local toX = CanvasPos.X + (PlayerMapMarker.SnapLineHeadOffsetX or 0)
    local toY = CanvasPos.Y + (PlayerMapMarker.SnapLineHeadOffsetY or 0)

    local dx = toX - fromX
    local dy = toY - fromY
    local length = math.sqrt(dx * dx + dy * dy)
    local thickness = PlayerMapMarker.SnapLineThickness or 1.5
    local angle_rad = 0
    if math.atan2 then angle_rad = math.atan2(dy, dx) else angle_rad = math.atan(dy, dx) end
    local angle = angle_rad * (180.0 / math.pi)

    if not LineData._CachedPosVec then
        LineData._CachedPosVec = FVector2D_ESP9 and FVector2D_ESP9(fromX, fromY - thickness / 2.0) or {X=fromX, Y=fromY - thickness / 2.0}
        LineData._CachedSizeVec = FVector2D_ESP9 and FVector2D_ESP9(length, thickness) or {X=length, Y=thickness}
    else
        LineData._CachedPosVec.X = fromX; LineData._CachedPosVec.Y = fromY - thickness / 2.0
        LineData._CachedSizeVec.X = length; LineData._CachedSizeVec.Y = thickness
    end

    pcall(function()
        Slot:SetPosition(LineData._CachedPosVec)
        Slot:SetSize(LineData._CachedSizeVec)
    end)
    pcall(function() Widget:SetRenderAngle(angle) end)
end

function PlayerMapMarker.RemoveSnapLine(KeyStr)
    local LineData = PlayerMapMarker.SnapLineWidgets[KeyStr]
    if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
        pcall(function() LineData.Widget:RemoveFromParent() LineData.Widget:ConditionalBeginDestroy() end)
    end
    -- Always clear the record, including invalid/stale widget handles.
    PlayerMapMarker.SnapLineWidgets[KeyStr] = nil
end

function PlayerMapMarker.RemoveESPWidget(Widget, KeyStr)
    if not Widget then return end
    local Container = Widget.Container or Widget
    pcall(function()
        local ptr = tostring(Container)
        PlayerMapMarker.ESPWidgetPtrs[ptr] = nil
        Container:RemoveFromParent()
        Container:ConditionalBeginDestroy()
    end)
    if KeyStr then
        PlayerMapMarker.RemoveSnapLine(KeyStr)
    end
end

function PlayerMapMarker.ClearAllSnapLines()
    for KeyStr, LineData in pairs(PlayerMapMarker.SnapLineWidgets) do
        if LineData and LineData.Widget and slua.isValid(LineData.Widget) then
            pcall(function() LineData.Widget:RemoveFromParent() LineData.Widget:ConditionalBeginDestroy() end)
        end
    end
    PlayerMapMarker.SnapLineWidgets = {}
end

function PlayerMapMarker.ScreenPixelToCanvasLocalRaw(PC, screenX, screenY)
    local scaleX = PlayerMapMarker._CanvasScaleX or 1.0
    local scaleY = PlayerMapMarker._CanvasScaleY or 1.0
    local offsetX = PlayerMapMarker._CanvasOffsetX or 0
    local offsetY = PlayerMapMarker._CanvasOffsetY or 0
    return screenX * scaleX + offsetX, screenY * scaleY + offsetY
end

function PlayerMapMarker.ProjectWorldToCanvasLocalRaw(PC, WorldLoc)
    if not IsValid_ESP9(PC) or not WorldLoc then return false, 0, 0 end

    if not PlayerMapMarker._tempScreenPixelPos then
        PlayerMapMarker._tempScreenPixelPos = FVector2D_ESP9 and FVector2D_ESP9(0, 0) or {X=0, Y=0}
    end
    local tempPos = PlayerMapMarker._tempScreenPixelPos

    local bOK = false
    pcall(function()
        local res = PC:ProjectWorldLocationToScreen(WorldLoc, tempPos, true)
        if res == true or res == 1 then bOK = true end
    end)

    if not bOK or (tempPos.X == 0 and tempPos.Y == 0) then return false, 0, 0 end

    local canvasX, canvasY = PlayerMapMarker.ScreenPixelToCanvasLocalRaw(PC, tempPos.X, tempPos.Y)
    return true, canvasX, canvasY
end

function PlayerMapMarker.ClearAllESP()
    RedBoxOverlay.Stop()
    for KeyStr, Data in pairs(PlayerMapMarker.ESPWidgets) do
        PlayerMapMarker.RemoveESPWidget(Data.Widget, KeyStr)
    end
    PlayerMapMarker.ESPWidgets = {}
    PlayerMapMarker.ESPWidgetPtrs = {}
    PlayerMapMarker.ClearAllSnapLines()
    PlayerMapMarker.ESPCanvas = nil
    PlayerMapMarker._OBHeadWidgetClass = nil
    PlayerMapMarker._OBHeadWidgetLoadFailed = false
    PlayerMapMarker._cachedViewportW = 1920
    PlayerMapMarker._cachedViewportH = 1080
end

function PlayerMapMarker.UpdateESP(AllPlayers, MyLoc)
    if not PlayerMapMarker.bUseScreenESP then return end

    PlayerMapMarker.bUseSnapLines = _G.AK_GetVal("ESP9_Line") == 1

    if not PlayerMapMarker.InitESPCanvas() then return end
    if PlayerMapMarker._OBHeadWidgetLoadFailed then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if IsValid_ESP9(PC) then PlayerMapMarker.UpdateCanvasTransform(PC) end

    local fromX, fromY = 0, 0
    if PlayerMapMarker.bUseSnapLines and IsValid_ESP9(PC) then
        fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC)
    end

    local MyKey = PlayerMapMarker.GetMyPlayerKey()
    local SeenKeys = {}
    local MyChar = nil
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
        else if PC and PC.GetPawn then MyChar = PC:GetPawn() end end
    end)

    local MyTeamID = PlayerMapMarker.GetTeamID(MyChar)

    for PlayerKey, Character in pairs(AllPlayers) do
        if IsValid_ESP9(Character) then
            local bIsMe = PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
            local bIsAI = PlayerMapMarker.IsAI(Character)
            local KeyStr = tostring(PlayerKey)
            local Name = PlayerMapMarker.GetPlayerName(Character)
            local Loc = PlayerMapMarker.GetESPLocation(Character)
            local DistStr = ""
            if MyLoc and Loc then DistStr = PlayerMapMarker.GetDistanceString(MyLoc, Loc) end

            local bSkip = false
            if bIsMe and not PlayerMapMarker.bIncludeMe then bSkip = true end
            if bIsAI and not PlayerMapMarker.bIncludeAI then bSkip = true end

            local TeamID = PlayerMapMarker.GetTeamID(Character)
            if MyTeamID ~= nil and TeamID == MyTeamID and not bIsMe then bSkip = true end

            local bIsAlive = PlayerMapMarker.IsAlive(Character)

            if not bSkip and Loc then
                SeenKeys[KeyStr] = true
                local ESPData = PlayerMapMarker.ESPWidgets[KeyStr]

                local Text = ""
                if _G.AK_GetVal("ESP9_Name") == 1 then Text = Name end
                if _G.AK_GetVal("ESP9_Distance") == 1 and DistStr ~= "" then
                    if Text ~= "" then Text = string.format("%s [%s]", Text, DistStr) else Text = string.format("[%s]", DistStr) end
                end

                local bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, Loc)

                if not ESPData then
                    local Widget = PlayerMapMarker.CreateESPWidget()
                    if Widget then
                        PlayerMapMarker.ESPWidgets[KeyStr] = { Widget = Widget, Character = Character, Name = Name, LastDistStr = DistStr, TeamID = TeamID }
                        PlayerMapMarker.UpdateESPText(Widget, Text)
                        if bIsAlive then
                            PlayerMapMarker.UpdateESPPositionWithPC(Widget, Loc, PC, CanvasPos)
                            PlayerMapMarker.ApplyTeamColor(Widget, TeamID)
                            local HP = Character.Health or 0
                            local MaxHP = Character.MaxHealth or 120
                            local pct = 0
                            if HP > 0 and MaxHP > 0 then pct = HP / MaxHP; if pct > 1 then pct = 1 end; if pct < 0 then pct = 0 end end
                            PlayerMapMarker.UpdateESPHealth(Widget, pct)
                                                    if PlayerMapMarker.bUseSnapLines then
                                PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                            else
                                PlayerMapMarker.RemoveSnapLine(KeyStr)
                            end
                        else
                            local Container = Widget.Container or Widget
                            pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                            PlayerMapMarker.UpdateESPHealth(Widget, 0)
                            PlayerMapMarker.RemoveSnapLine(KeyStr)
                        end
                    end
                else
                    ESPData.Character = Character
                    ESPData.Name = Name
                    ESPData.LastDistStr = DistStr
                    ESPData.TeamID = TeamID
                    PlayerMapMarker.ApplyTeamColor(ESPData.Widget, TeamID)
                    ESPData.Widget._LastESPText = nil
                    PlayerMapMarker.UpdateESPText(ESPData.Widget, Text)
                    PlayerMapMarker.UpdateESPPositionWithPC(ESPData.Widget, Loc, PC, CanvasPos)

                    local HP = Character.Health or 0
                    local MaxHP = Character.MaxHealth or 120
                    local pct = 0
                    if HP > 0 and MaxHP > 0 then pct = HP / MaxHP; if pct > 1 then pct = 1 end; if pct < 0 then pct = 0 end end
                    PlayerMapMarker.UpdateESPHealth(ESPData.Widget, pct)

                    if PlayerMapMarker.bUseSnapLines then
                        PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                    else
                        PlayerMapMarker.RemoveSnapLine(KeyStr)
                    end
                end
            end
        end
    end

    for KeyStr, Data in pairs(PlayerMapMarker.ESPWidgets) do
        if not SeenKeys[KeyStr] then
            PlayerMapMarker.RemoveESPWidget(Data.Widget, KeyStr)
            PlayerMapMarker.ESPWidgets[KeyStr] = nil
        end
    end
    -- Remove any line whose target record no longer exists; this prevents stale left-side flicker.
    for KeyStr in pairs(PlayerMapMarker.SnapLineWidgets) do
        if not PlayerMapMarker.ESPWidgets[KeyStr] then PlayerMapMarker.RemoveSnapLine(KeyStr) end
    end
end

function PlayerMapMarker.UpdateESPLight()
    if RedBoxOverlay and RedBoxOverlay.bActive then RedBoxOverlay.UpdatePosition() end
    if not PlayerMapMarker.bUseScreenESP then return end

    PlayerMapMarker.bUseSnapLines = _G.AK_GetVal("ESP9_Line") == 1

    if not PlayerMapMarker.ESPCanvas or not Game:IsValid(PlayerMapMarker.ESPCanvas) then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return end

    PlayerMapMarker.UpdateCanvasTransform(PC)

    local fromX, fromY = 0, 0
    if PlayerMapMarker.bUseSnapLines then fromX, fromY = PlayerMapMarker.GetSnapLineStartPos(PC) end

    for KeyStr, ESPData in pairs(PlayerMapMarker.ESPWidgets) do
        local Widget = ESPData.Widget
        local Character = ESPData.Character
        local Container = Widget and (Widget.Container or Widget)
        local bWidgetValid = false
        pcall(function() bWidgetValid = Container and slua.isValid(Container) end)

        if Widget and bWidgetValid and Character and IsValid_ESP9(Character) then
            local bIsAlive = PlayerMapMarker.IsAlive(Character)
            if not bIsAlive then
                pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                PlayerMapMarker.RemoveSnapLine(KeyStr)
            else
                local bShowAnyUI = _G.AK_GetVal("ESP9_Name") == 1 or _G.AK_GetVal("ESP9_Distance") == 1 or _G.AK_GetVal("ESP9_HP") == 1 or _G.AK_GetVal("ESP9_Team") == 1
                if bShowAnyUI then
                    pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible) end)
                else
                    pcall(function() Container:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed) end)
                end

                local Loc = PlayerMapMarker.GetESPLocation(Character)
                if Loc then
                    local bOnScreen, CanvasPos = PlayerMapMarker.ProjectWorldToCanvasLocal(PC, Loc)
                    PlayerMapMarker.UpdateESPPositionWithPC(Widget, Loc, PC, CanvasPos)

                    if PlayerMapMarker.bUseSnapLines then PlayerMapMarker.UpdateSnapLine(KeyStr, CanvasPos, bOnScreen, fromX, fromY)
                    else PlayerMapMarker.RemoveSnapLine(KeyStr) end

                else
                    PlayerMapMarker.RemoveSnapLine(KeyStr)
                end
            end
        end
    end
end

function PlayerMapMarker.UpdateESPDistances()
    if not PlayerMapMarker.bUseScreenESP then return end

    local MyLoc = PlayerMapMarker.GetMyLocation()
    if not MyLoc then return end

    local PC = PlayerMapMarker.GetMyPlayerController()
    if not IsValid_ESP9(PC) then return end

    PlayerMapMarker.UpdateCanvasTransform(PC)

    for KeyStr, ESPData in pairs(PlayerMapMarker.ESPWidgets) do
        local Character = ESPData.Character
        local Widget = ESPData.Widget
        local Container = Widget and (Widget.Container or Widget)
        local bWidgetValid = false
        pcall(function() bWidgetValid = Container and slua.isValid(Container) end)

        if Character and IsValid_ESP9(Character) and Widget and bWidgetValid then
            local Loc = PlayerMapMarker.GetESPLocation(Character)
            if Loc then
                local Dist = PlayerMapMarker.CalcDistance(MyLoc, Loc)
                ESPData.LastDistance = Dist

                if PlayerMapMarker.bShowDistance then
                    local DistStr = ""
                    local Meters = 0
                    if Dist then
                        Meters = Dist / 100
                        if Meters < 1000 then DistStr = string.format("%dm", math.floor(Meters))
                        else DistStr = string.format("%.1fkm", Meters / 1000) end
                    end

                    local Name = ESPData.Name or "Unknown"
                    local Text = ""
                    if _G.AK_GetVal("ESP9_Name") == 1 then Text = Name end
                    if _G.AK_GetVal("ESP9_Distance") == 1 and DistStr ~= "" then
                        if Text ~= "" then Text = string.format("%s [%s]", Text, DistStr) else Text = string.format("[%s]", DistStr) end
                    end

                    ESPData.LastDistStr = DistStr
                    Widget._LastESPText = nil
                    PlayerMapMarker.UpdateESPText(Widget, Text)
                end
            end
        end
    end
end


function PlayerMapMarker.ScanAndUpdate()
    local AllChars = PlayerMapMarker.GetAllCharacters()
    if not AllChars then RedBoxOverlay.SetCounts(0, 0) return 0 end

    local MyKey = PlayerMapMarker.GetMyPlayerKey()
    local MyLoc = PlayerMapMarker.GetMyLocation()
    local MyChar = nil
    pcall(function()
        local GDP = PlayerMapMarker.GetGameplayData()
        if GDP and GDP.GetLocalCharacter then MyChar = GDP.GetLocalCharacter()
        else local PC = PlayerMapMarker.GetMyPlayerController() if PC and PC.GetPawn then MyChar = PC:GetPawn() end end
    end)

    local MyTeamID = PlayerMapMarker.GetTeamID(MyChar)
    local realPlayers = 0
    local botPlayers = 0

    for PlayerKey, Character in pairs(AllChars) do
        if IsValid_ESP9(Character) then
            local bIsMe = PlayerMapMarker.IsMe(Character, PlayerKey, MyKey)
            local bIsAI = PlayerMapMarker.IsAI(Character)
            local bIsAlive = PlayerMapMarker.IsAlive(Character)

            if bIsAlive and not bIsMe then
                local bIsMyTeam = false
                if MyTeamID ~= nil then
                    local targetTeamID = PlayerMapMarker.GetTeamID(Character)
                    if targetTeamID == MyTeamID then bIsMyTeam = true end
                end
                if not bIsMyTeam then
                    if bIsAI then botPlayers = botPlayers + 1
                    else realPlayers = realPlayers + 1 end
                end
            end
        end
    end

    if _G.AK_GetVal("ESP9_Count") == 1 then
        if RedBoxOverlay.bActive then RedBoxOverlay.SetCounts(realPlayers, botPlayers)
        else RedBoxOverlay.Start() end
    else
        if RedBoxOverlay.bActive then RedBoxOverlay.Stop() end
    end

    if PlayerMapMarker.bUseScreenESP then
        PlayerMapMarker.UpdateESP(AllChars, MyLoc)
    end

    return 0
end

function PlayerMapMarker.AttachTimers()
    pcall(function()
        local pc = PlayerMapMarker.GetMyPlayerController()
        if not slua.isValid(pc) or not pc.AddGameTimer then return end

        pcall(function() pc:AddGameTimer(PlayerMapMarker.nUpdateInterval or 0.5, true, function() if PlayerMapMarker.bActive then pcall(function() PlayerMapMarker.ScanAndUpdate() end) end end) end)
        pcall(function() pc:AddGameTimer(PlayerMapMarker._LightUpdateInterval or 0.02, true, function() if PlayerMapMarker.bActive then pcall(function() PlayerMapMarker.UpdateESPLight() end) end end) end)
        pcall(function() pc:AddGameTimer(PlayerMapMarker._DistanceUpdateInterval or 0.1, true, function() if PlayerMapMarker.bActive and PlayerMapMarker.bUseScreenESP and PlayerMapMarker.bShowDistance then pcall(function() PlayerMapMarker.UpdateESPDistances() end) end end) end)
    end)
end

function PlayerMapMarker.Start()
    if PlayerMapMarker.bActive then return end
    PlayerMapMarker.bActive = true
    PlayerMapMarker._FrameCount = 0
    PlayerMapMarker.ScanAndUpdate()
    PlayerMapMarker.AttachTimers()
end

function PlayerMapMarker.Stop()
    PlayerMapMarker.bActive = false
    PlayerMapMarker._FrameCount = 0
    PlayerMapMarker.ClearAllESP()
end

_G.PlayerMapMarker = PlayerMapMarker
-- ========================================================================
-- V6 WALLHACK/CHAMS IMPLEMENTATION
-- ========================================================================
pcall(function()
    print("[10.lua] Chams loading...")
    
    local FLinearColor = import("LinearColor")
    local GameplayData = require("GameLua.GameCore.Data.GameplayData")
    local SecurityCommonUtils = require("GameLua.Mod.BaseMod.Common.Security.SecurityCommonUtils")
    
    local chamsTimer = nil
    local processedPawns = {}
    local tickCount = 0
    local chamsReady = false
    
    -- ===== SETTINGS =====
    local UPDATE_INTERVAL = 0.3        -- Har 0.3s update (naye spawn jaldi detect)
    local MAX_PER_TICK = 20            -- Ek frame mein max 20 players
    local CACHE_CLEAR_TICKS = 6        -- Har 6 tick (~1.8s) mein cache clear
    local AVATAR_SLOTS = {0, 1, 2, 3, 4, 5, 6, 7}  -- Full body slots
    
    local colors = nil
    
    -- ===== ENABLE CONSOLE COMMANDS =====
    local function EnableChamsConsole()
        if chamsReady then return end
        pcall(function()
            local KSL = import("KismetSystemLibrary")
            local world = slua.getWorld()
            if not KSL or not world then return end
            
            KSL.ExecuteConsoleCommand(world, "r.EnableDrawDyeingColor 1")
            KSL.ExecuteConsoleCommand(world, "r.CustomDepth 3")
            KSL.ExecuteConsoleCommand(world, "r.IdeaOutline.Enable 1")
            KSL.ExecuteConsoleCommand(world, "r.Highlight.Enable 1")
            
            chamsReady = true
            print("[10.lua] Console ready")
        end)
    end
    
    -- ===== SETUP COLORS =====
    if FLinearColor then
        colors = {
            vis = FLinearColor(1.5, 0.0, 0.0, 1.0),       -- Red (visible)
            occ = FLinearColor(0, 10, 0, 1),                -- Green (behind wall)
            bVis = FLinearColor(1.8, 0.3, 9.0, 1.0),        -- Blue (bot visible)
            bOcc = FLinearColor(1.5, 1.5, 1.5, 1.0)         -- White (bot hidden)
        }
    end
    
    -- ===== APPLY CHAMS TO MESH =====
    local function ApplyChamsToMesh(mesh, visColor, occColor)
        if not mesh or not slua.isValid(mesh) then return end
        
        pcall(function()
            mesh:SetDrawDyeing(true)
            mesh:SetDrawDyeingMode(1)
            mesh:SetVisibleDyeingColor(visColor)
            mesh:SetOccludedDyeingColor(occColor)
            mesh:SetDyeingColorFadeDistance(99999.0)
            mesh:SetDyeingColorMinMaxDistance(0.0, 99999.0)
        end)
        
        pcall(function()
            mesh:SetDrawHighlight(true)
            mesh:OverrideHighlightColor(visColor)
            mesh:SetHighlightCanBeOccluded(false)
        end)
        
        pcall(function()
            mesh:SetDrawIdeaOutline(true)
            mesh:SetIdeaOutlineNew(true)
            mesh:SetIdeaOutlineOcclusionHighlight(true)
            mesh:OverrideIdeaOutlineColor(visColor)
            mesh:SetIdeaOutlineOcclusionColor(occColor)
            mesh:OverrideIdeaOutlineThickness(3.0)
            mesh:SetIdeaOverrideOutlineAndOcclusion(true)
        end)
        
        pcall(function()
            mesh:SetRenderCustomDepth(true)
            mesh:SetCustomDepthStencilValue(255)
        end)
    end
    
    -- ===== CHECK IF ALIVE =====
    local function IsAlive(pawn)
        if not slua.isValid(pawn) then return false end
        
        -- Fast check
        local hp = pawn.Health
        if hp and hp > 0 then return true end
        
        -- Fallback
        local status = pawn.HealthStatus
        if status then
            return SecurityCommonUtils.IsHealthStatusAlive(status)
        end
        
        return false
    end
    
    -- ===== PROCESS SINGLE ENEMY =====
    local function ProcessEnemy(pawn, myTeamID)
        if not slua.isValid(pawn) then return false end
        if not IsAlive(pawn) then return false end
        
        local teamID = pawn.TeamID
        if not teamID or teamID <= 0 or teamID == myTeamID then return false end
        
        -- Bot check
        local isBot = false
        pcall(function() isBot = Game:IsAI(pawn) end)
        
        local visColor = isBot and colors.bVis or colors.vis
        local occColor = isBot and colors.bOcc or colors.occ
        
        -- Main body mesh
        pcall(function()
            if pawn.Mesh and slua.isValid(pawn.Mesh) then
                ApplyChamsToMesh(pawn.Mesh, visColor, occColor)
            end
        end)
        
        -- Avatar parts (full body)
        pcall(function()
            local avatarComp = pawn.CharacterAvatarComp2_BP or pawn:getAvatarComponent2()
            if avatarComp and slua.isValid(avatarComp) and avatarComp.GetMeshCompBySlot then
                for _, slot in ipairs(AVATAR_SLOTS) do
                    pcall(function()
                        local meshComp = avatarComp:GetMeshCompBySlot(slot)
                        if meshComp and slua.isValid(meshComp) then
                            ApplyChamsToMesh(meshComp, visColor, occColor)
                        end
                    end)
                end
            end
        end)
        
        -- Weapon mesh
        pcall(function()
            local weapon = pawn:GetCurrentWeapon()
            if weapon and slua.isValid(weapon) and weapon.Mesh then
                ApplyChamsToMesh(weapon.Mesh, visColor, occColor)
            end
        end)
        
        -- Cache mark
        local playerKey = pawn.PlayerKey
        if playerKey then
            processedPawns[playerKey] = true
        end
        
        return true
    end
    
    -- ===== MAIN UPDATE LOOP =====
    local function UpdateChams()
        pcall(function()
            local localPlayer = GameplayData.GetPlayerCharacter()
            if not slua.isValid(localPlayer) then return end
            
            EnableChamsConsole()
            if not colors then return end
            
            tickCount = tickCount + 1
            
            -- Clear cache periodically to catch NEW spawns
            if tickCount % CACHE_CLEAR_TICKS == 0 then
                processedPawns = {}
            end
            
            local myTeamID = localPlayer.TeamID
            local allChars = Game:GetAllPlayerPawns() or {}
            
            local count = 0
            for _, target in pairs(allChars) do
                if count >= MAX_PER_TICK then break end
                
                -- Skip if already processed in this cycle
                local playerKey = target.PlayerKey
                if playerKey and processedPawns[playerKey] then
                    goto continue
                end
                
                if ProcessEnemy(target, myTeamID) then
                    count = count + 1
                end
                
                ::continue::
            end
        end)
    end
    
    -- ===== START CHAMS =====
    local function StartChams()
        EnableChamsConsole()
        
        -- Game timer (survives player death/respawn)
        if _G.Game and _G.Game.AddGameTimer then
            if chamsTimer then
                pcall(function() _G.Game:RemoveGameTimer(chamsTimer) end)
            end
            chamsTimer = _G.Game:AddGameTimer(UPDATE_INTERVAL, true, UpdateChams)
            print("[10.lua] Chams Active - Green=Wall, Red=Visible, Blue=Bot Visible, White=Bot Hidden")
            return true
        end
        
        -- Fallback: PC timer
        local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) and pc.AddGameTimer then
            if chamsTimer then
                pcall(function() pc:RemoveGameTimer(chamsTimer) end)
            end
            chamsTimer = pc:AddGameTimer(UPDATE_INTERVAL, true, UpdateChams)
            print("[10.lua] ✅ Chams Active on PC!")
            return true
        end
        
        return false
    end
    
    -- ===== RETRY START =====
    local retryCount = 0
    local function Retry()
        if retryCount >= 30 then
            print("[10.lua] ❌ Failed to start!")
            return
        end
        retryCount = retryCount + 1
        
        if StartChams() then
            print("[10.lua] ✅ Module ready!")
        else
            if _G.Game and _G.Game.AddGameTimer then
                _G.Game:AddGameTimer(1.0, false, Retry)
            end
        end
    end
    
    -- Expose the V6 lifecycle to the single WALLHACK toggle.
    _G.StartV6Wallhack = function()
        if chamsTimer then return true end
        if not colors and FLinearColor then
            colors = {
                vis = FLinearColor(1.5, 0.0, 0.0, 1.0),
                occ = FLinearColor(0, 10, 0, 1),
                bVis = FLinearColor(1.8, 0.3, 9.0, 1.0),
                bOcc = FLinearColor(1.5, 1.5, 1.5, 1.0)
            }
        end
        retryCount = 0
        return StartChams()
    end
    _G.StopV6Wallhack = function()
        _chams_Cleanup()
    end

    -- ===== CLEANUP =====
    function _chams_Cleanup()
        if chamsTimer then
            pcall(function()
                if _G.Game then _G.Game:RemoveGameTimer(chamsTimer) end
            end)
            chamsTimer = nil
        end
        processedPawns = {}
        chamsReady = false
        colors = nil
        print("[10.lua] 🧹 Cleanup done")
    end
    
    print("[10.lua] ✅ Loaded successfully!")
end)
local NewFreshCreditOverlay = {Widget = nil, Slot = nil}
local function NewFreshCredit()
    pcall(function()
        if NewFreshCreditOverlay.Widget and slua.isValid(NewFreshCreditOverlay.Widget) then
            NewFreshCreditOverlay.Widget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
            return
        end
        local uiTools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
        local mainUI = uiTools and uiTools.GetMainControlBaseUI and uiTools.GetMainControlBaseUI()
        local parent = mainUI and (mainUI.CanvasPanel_0 or mainUI.CanvasPanel_42)
        if not parent or not slua.isValid(parent) then return end
        local txt = nil
        pcall(function() txt = CGame:NewObjectFromPath("/Script/UMG.TextBlock", parent) end)
        if not txt or not slua.isValid(txt) then return end
        local linear = import("LinearColor")
        local slate = import("SlateColor") or import("/Script/SlateCore.SlateColor")
        local yellow = linear and linear(1.0, 1.0, 0.0, 1.0) or {R=255, G=255, B=0, A=255}
        txt:SetText(CREDIT_TEXT)
        if slate then txt:SetColorAndOpacity(slate(yellow)) else txt:SetColorAndOpacity(yellow) end
        if txt.Font then local font = txt.Font; font.Size = 18; txt.Font = font end
        txt:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
        local slot = parent:AddChildToCanvas(txt)
        if not slot then return end
        local vec = import("Vector2D")
        if vec then
            slot:SetAnchors(FAnchors(1.0, 1.0, 1.0, 1.0))
            slot:SetAlignment(vec(1.0, 1.0))
            slot:SetPosition(vec(-18.0, -14.0))
        end
        slot:SetAutoSize(true)
        slot:SetZOrder(9999)
        NewFreshCreditOverlay.Widget = txt
        NewFreshCreditOverlay.Slot = slot
    end)
end

local function NewFreshCleanup()
    pcall(function()
        if NewFreshCreditOverlay.Widget and slua.isValid(NewFreshCreditOverlay.Widget) then
            NewFreshCreditOverlay.Widget:RemoveFromParent()
            NewFreshCreditOverlay.Widget:ConditionalBeginDestroy()
        end
        NewFreshCreditOverlay.Widget = nil
        NewFreshCreditOverlay.Slot = nil
    end)
    pcall(function()
        if _G.StopV6Wallhack then _G.StopV6Wallhack() end
        if _G.PlayerMapMarker then _G.PlayerMapMarker.Stop() end
        if _G.RedBoxOverlay then _G.RedBoxOverlay.Stop() end
    end)
end

function _G.NewFreshRuntimeTick()
    if not _G.MOD_EXPIRED then NewFreshCredit() end
    if _G.PlayerMapMarker then
        _G.PlayerMapMarker.bUseSnapLines = (_G.AK_GetVal("ESP9_Line") == 1)
        _G.PlayerMapMarker.SnapLineThickness = math.max(1, math.min(10, _G.NewFreshLineThickness or 1))
        if _G.AK_GetVal("ESP_V2") == 1 or _G.AK_GetVal("ESP9_Line") == 1 or _G.AK_GetVal("ESP9_Count") == 1 then
            if not _G.PlayerMapMarker.bActive then pcall(_G.PlayerMapMarker.Start) end
        elseif _G.PlayerMapMarker.bActive then
            pcall(_G.PlayerMapMarker.Stop)
        end
    end
end
-- ========================================================================
-- BRPlayerCharacterBase CLASS - FIXED
-- ========================================================================
local BRPlayerCharacterBase = {
    ServerRPC = {},
    ClientRPC = {},
    MulticastRPC = {}
}

BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue = { Reliable = true, Params = {} }
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox = { Reliable = true, Params = { UEnums.EPropertyClass.Object } }
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction = { Reliable = true, Params = { UEnums.EPropertyClass.Int } }
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall = { Reliable = true, Params = { UEnums.EPropertyClass.Bool } }
BRPlayerCharacterBase.ClientRPC.ClientRPC_TriggerHighlightMoment = { Reliable = true, Params = { UEnums.EPropertyClass.UInt32, UEnums.EPropertyClass.UInt32 } }

function BRPlayerCharacterBase:ctor()
    self.bHasShownDevNotice = false
    self.AK_NativeESP_Ready = false
    self._newWallhackStarted = false
end

function BRPlayerCharacterBase:_PostConstruct()
    BRPlayerCharacterBase.__super._PostConstruct(self)
    self:InitAddSpecialMoveInfo()
    self.bCanNearDeathGiveup = true
    self:StartAdvancedSystems()
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
    BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
    self:AddControlEvent(self, "MovementModeChangedDelegate", self.HandleOnMovementModeChangedNew, self)

    if self:HasAuthority() and self:CheckAddCheckFallingDistanceComponent() then
        local CheckFallingDistanceComponent_C = import("CheckFallingDistanceComponent")
        if slua.isValid(CheckFallingDistanceComponent_C) and not slua.isValid(self:GetComponentByClass(CheckFallingDistanceComponent_C)) then
            Game:AddComponent(CheckFallingDistanceComponent_C, self, "CheckFallingDistanceComponent")
        end
    end

    if slua.isValid(self.STCharacterMovement) then
        self.STCharacterMovement.bPositiveBlowUp = true
    end

    if self.Role == ENetRole.ROLE_AutonomousProxy then
        self:AddControlEvent(self, "OnPawnStateDisabled", self.OnPawnStateChange, self)
        self:AddControlEvent(self, "OnPawnStateEnabled", self.OnPawnStateChange, self)
        self:AddControlEventConditionOnly(self, "OnAttrChangeEventDelegate", { AttrName = { "bCanSelfRescue" } }, self.CharacterAttrChangeEvent, self)
    end

    if Client then
        GameplayData.AddCharacter(self.Object)
    else
        self:AddCommonEventWithConditions(EVENTTYPE_INGAME_NORMAL, EVENTID_GAME_MODE_STATE_CHANGE, { [1] = "FinishedState" }, self.HandleFinishedState, self)
    end

    EventSystem:postEvent(EVENTTYPE_SINGLETRAINING, EVENTID_CHARACTER_BEGINPLAY, self.Object)
end

function BRPlayerCharacterBase:ReceiveEndPlay(endPlayReason)
    if _G.NewFreshCleanup then _G.NewFreshCleanup() end
    BRPlayerCharacterBase.__super.ReceiveEndPlay(self, endPlayReason)
    if Client and GameplayData.RemoveCharacter then GameplayData.RemoveCharacter(self.Object) end
end

-- ========================================================================
-- STARTADVANCEDSYSTEMS - FIXED (ALL LOGIC IN TIMER)
-- ========================================================================
function BRPlayerCharacterBase:StartAdvancedSystems()
    if not Client then return end

    -- Main timer
    self:AddGameTimer(0.4, true, function()
        if not slua.isValid(self.Object) then return end
    
        local localPlayer = GameplayData.GetPlayerCharacter()
        if not slua.isValid(localPlayer) then return end

        if self.Object == localPlayer then
            -- ====== V6 WALLHACK CONTROL ======
            local wallhackEnabled = _G.AK_GetVal("WALLHACK") == 1
            if wallhackEnabled then
                if _G.StartV6Wallhack then _G.StartV6Wallhack() end
            else
                if _G.StopV6Wallhack then _G.StopV6Wallhack() end
            end

            -- ESP V2 and its independently controlled line/counter components
            if _G.AK_GetVal("ESP_V2") == 1 or _G.AK_GetVal("ESP9_Line") == 1 or _G.AK_GetVal("ESP9_Count") == 1 then
                if _G.PlayerMapMarker and not _G.PlayerMapMarker.bActive then
                    _G.PlayerMapMarker.Start()
                end
            else
                if _G.PlayerMapMarker and _G.PlayerMapMarker.bActive then
                    _G.PlayerMapMarker.Stop()
                end
            end

            -- Cleanup
            _G.AKModTickCount = (_G.AKModTickCount or 0) + 1

            -- Setup ESP config
            if not self.AK_NativeESP_Ready then
                pcall(function()
                    local gameplayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
                    local screenMarkConfig = gameplayTools.GetCurrentConfig("ScreenMarkConfig")
                    if screenMarkConfig then
                        if screenMarkConfig[1006] then
                            screenMarkConfig[1006].bBindBlocked = true
                            screenMarkConfig[1006].bBindOutScreen = true
                            screenMarkConfig[1006].MaxWidgetNum = 99
                            screenMarkConfig[1006].MaxShowDistance = 6000000
                        end
                    end
                end)
                self.AK_NativeESP_Ready = true
            end

            -- Process enemies
            local enemyCharacters = GameplayData.GetAllPlayerCharacters and GameplayData.GetAllPlayerCharacters() or {}
            local pc = slua_GameFrontendHUD and slua_GameFrontendHUD:GetPlayerController()

            for _, enemy in pairs(enemyCharacters) do
                if slua.isValid(enemy) and enemy ~= localPlayer and enemy.TeamID ~= localPlayer.TeamID then
                    local isDead = false
                    pcall(function()
                        if type(enemy.IsDead)=="function" then isDead = enemy:IsDead()
                        elseif enemy.bIsDead then isDead = true end
                        if enemy.bHidden or (enemy.Mesh and enemy.Mesh.bHidden) then isDead = true end
                    end)

                    if isDead then goto skip_enemy end

                    -- ESP Box
                    if _G.AK_GetVal("ESP_BOX") == 1 then
                        pcall(function()
                            if enemy.Replay_IsEnemyFrameUIExisted and not enemy:Replay_IsEnemyFrameUIExisted() then
                                enemy:Replay_CreateEnemyFrameUI(true, true)
                            end
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(true) end
                        end)
                    else
                        pcall(function()
                            if enemy.Replay_SetVisiableOfFrameUI then enemy:Replay_SetVisiableOfFrameUI(false) end
                        end)
                    end

                    ::skip_enemy::
                end
            end

            if not _G.MOD_EXPIRED then
                pcall(function() UpdateThrowableWarnings(localPlayer) end)
                pcall(_G.NewFreshRuntimeTick)
            end
        end
    end)
end
function _G.InitModMenuTab()
    if _G.ModMenuInitialized and _G._IsModMenuHooked then return true end
    local SettingPageDefine = require("client.logic.NewSetting.SettingPageDefine")
    local SettingCatalog = require("client.logic.NewSetting.SettingCatalog")
    local AliasMap = require("client.slua.umg.NewSetting.Item.AliasMap")
    local function setFeature(id, value)
        for _, f in ipairs(_G.AK_Features) do if f.id == id then f.val = value and 1 or 0 end end
        if id == "THROWABLE_WARNING" then _G.LexusConfig.ThrowableWarning = value and true or false end
    end
    local function sw(key, text, id)
        return {Key=key, UI=AliasMap.Switcher, Text=text, GetFunc=function() return _G.AK_GetVal(id)==1 end, SetFunc=function(_,v) setFeature(id,v); return true end}
    end
    local featureStack = {
        sw("NF6_Line", "ESP LINE", "ESP_LINE"),
        {Key="NF6_LineThickness", UI=AliasMap.Slider, Text="ESP LINE THICKNESS", MinValue=1, MaxValue=10, min=1, max=10, GetFunc=function() return _G.NewFreshLineThickness or 1 end, SetFunc=function(_,v) _G.NewFreshLineThickness=math.max(1,math.min(10,tonumber(v) or 1)); return true end},
        sw("NF6_Box", "ESP BOX", "ESP_BOX"),
        sw("NF6_Name", "ESP NAME", "ESP_NAME"),
        sw("NF6_Health", "ESP HEALTH", "ESP_HEALTH"),
        sw("NF6_Counter", "ESP COUNTER", "ESP_COUNTER"),
        sw("NF6_Wallhack", "WALLHACK", "WALLHACK"),
        sw("NF6_Nade", "THROWABLE / GRENADE WARNING", "THROWABLE_WARNING"),
    }
    local page = SettingPageDefine.AlexaLordMenu
    if not page then page={Key="MOD Menu", Text=MENU_NAME, UIKey="Setting_Page_Privacy", Category={{Key="Cat_ALEXA_FEATURES", Text=FEATURE_CATEGORY_NAME, Stack=featureStack}}}; table.insert(SettingCatalog,1,page); SettingPageDefine.AlexaLordMenu=page end
    local UIManager = _G.UIManager
    if UIManager and UIManager.ShowUI and not UIManager._IsModMenuHooked then
        local old = UIManager.ShowUI
        UIManager.ShowUI=function(config,...)
            local args={...}; local n=select('#',...)
            if config and config.keyName and string.find(string.lower(tostring(config.keyName)),"setting_main") and not string.find(string.lower(tostring(config.keyName)),"custom") then
                local catalog=args[1]; if type(catalog)=="table" then local found=false; for _,v in ipairs(catalog) do if type(v)=="table" and v.Key=="MOD Menu" then found=true end end; if not found then table.insert(catalog,1,page) end end
            end
            return old(config, table.unpack(args,1,n))
        end
        UIManager._IsModMenuHooked=true; _G.ModMenuInitialized=true; return true
    end
    return false
end
local function TryInitNewFresh4()
    local ok, ready=pcall(_G.InitModMenuTab); if ok and ready then return end
    pcall(function() local ticker=require("common.time_ticker"); if ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(2.0,TryInitNewFresh4) elseif _G.Game then _G.Game:AddGameTimer(2.0,false,TryInitNewFresh4) end end)
end
pcall(function() local ticker=require("common.time_ticker"); if ticker and ticker.AddTimerOnce then ticker.AddTimerOnce(2.0,TryInitNewFresh4) else TryInitNewFresh4() end end)
function _G.InitializeAllSystems()
    local gameplayData = package.loaded["GameLua.GameCore.Data.GameplayData"] or require("GameLua.GameCore.Data.GameplayData")
    if gameplayData then pcall(function() local pc=gameplayData.GetPlayerCharacter and gameplayData.GetPlayerCharacter(); if slua.isValid(pc) then pc.StartAdvancedSystems=BRPlayerCharacterBase.StartAdvancedSystems end end) end
end
_G.InitializeAllSystems()
local class = require("class")
local CharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local BRCharacterClass = class(CharacterBase, nil, BRPlayerCharacterBase)
return require("combine_class").DeclareFeature(BRCharacterClass, {})

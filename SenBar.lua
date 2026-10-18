local ADDON, NS = ...
NS = NS or {}

------------------------------------------------------------
-- Constants
------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8X8"
local FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local ACCENT = { 0.25, 0.75, 1.0 }

-- Default resource colors (modern, slightly desaturated palette)
local DEFAULT_POWER = {
    MANA = { r = 0.23, g = 0.51, b = 0.96 },
    RAGE = { r = 0.94, g = 0.27, b = 0.27 },
    ENERGY = { r = 0.98, g = 0.80, b = 0.08 },
    FOCUS = { r = 0.98, g = 0.57, b = 0.24 },
}
local TEXT_FORMATS = { "Current / Max", "Percent", "Current", "Current | Percent" }
local VISIBILITY = { "Always", "In combat", "Combat or target", "Hidden" }

local CERVO_FONT = "Interface\\AddOns\\SenBar\\Fonts\\CervoNeueBlack.ttf"

-- The game ships a single bold-less font family, so "Bold" is a thick outline.
local TEXT_STYLES = {
    { name = "Normal", font = FONT, flags = "OUTLINE" },
    { name = "Bold", font = FONT, flags = "THICKOUTLINE" },
    { name = "Condensed", font = "Fonts\\ARIALN.TTF", flags = "OUTLINE" },
    { name = "Condensed Bold", font = "Fonts\\ARIALN.TTF", flags = "THICKOUTLINE" },
    { name = "Cervo Neue", font = CERVO_FONT, flags = "OUTLINE" },
    { name = "Cervo Neue Clean", font = CERVO_FONT, flags = "" },
}
local TEXT_STYLE_NAMES = {}
for i, st in ipairs(TEXT_STYLES) do TEXT_STYLE_NAMES[i] = st.name end

-- g = health gradient (low, mid, high)   p = mana, rage, energy, focus
-- c = combo (filled, full)               bg / bd / tx = background, border, text
local PRESETS = {
    { name = "Neon Noir",     g = { "ff2e63", "ffb400", "08f7fe" }, p = { "7b61ff", "ff2e63", "f9f871", "ff9671" }, c = { "08f7fe", "ff2e63" }, bg = "0b0a14", bd = "08f7fe", tx = "ffffff" },
    { name = "Ember Forge",   g = { "7a0c0c", "ff5a1f", "ffd23f" }, p = { "5aa9e6", "ff3b1f", "ffd23f", "ff8a3d" }, c = { "ffd23f", "ff3b1f" }, bg = "120805", bd = "5a2410", tx = "fff2e0" },
    { name = "Frostbite",     g = { "3a86ff", "8ecae6", "e0fbfc" }, p = { "3a86ff", "9b5de5", "caf0f8", "90e0ef" }, c = { "90e0ef", "ffffff" }, bg = "07121c", bd = "1b3a52", tx = "eaf7ff" },
    { name = "Toxic Bloom",   g = { "ff006e", "ffbe0b", "8ac926" }, p = { "3a86ff", "ff006e", "ffbe0b", "8ac926" }, c = { "8ac926", "ff006e" }, bg = "0a0f08", bd = "2c4a1a", tx = "f4ffe0" },
    { name = "Royal Amethyst", g = { "5a189a", "9d4edd", "e0aaff" }, p = { "c77dff", "ff4d6d", "ffd166", "ff9e00" }, c = { "e0aaff", "ff4d6d" }, bg = "0d0716", bd = "3c1c5a", tx = "f6ecff" },
    { name = "Sunset Drive",  g = { "ff0054", "ff7b00", "ffd60a" }, p = { "6a4c93", "ff0054", "ffd60a", "ff7b00" }, c = { "ffd60a", "ff0054" }, bg = "140a1e", bd = "ff7b00", tx = "fff3d6" },
    { name = "Deep Ocean",    g = { "03045e", "0077b6", "00f5d4" }, p = { "0096c7", "e63946", "ffd166", "f4a261" }, c = { "00f5d4", "e63946" }, bg = "020f1a", bd = "0a3d5c", tx = "e6fffb" },
    { name = "Emerald Moss",  g = { "14532d", "2d9a5b", "b7f171" }, p = { "2a9d8f", "e76f51", "e9c46a", "f4a261" }, c = { "e9c46a", "e76f51" }, bg = "07110b", bd = "1a3a24", tx = "eaffe9" },
    { name = "Monolith",      g = { "4a4a4a", "9a9a9a", "ffffff" }, p = { "b0bec5", "8d8d8d", "e0e0e0", "c0c0c0" }, c = { "ffffff", "e53935" }, bg = "0a0a0a", bd = "2e2e2e", tx = "ffffff" },
    { name = "Blood Moon",    g = { "4a0404", "b30f1f", "ff6b6b" }, p = { "5c6bc0", "ff1f3d", "ffb703", "fb8500" }, c = { "ff6b6b", "ffffff" }, bg = "0d0405", bd = "5a0f1a", tx = "ffe3e3" },
    { name = "Gilded Age",    g = { "5c3d00", "d4a017", "fff1a8" }, p = { "4a90d9", "c0392b", "f5d76e", "e67e22" }, c = { "f5d76e", "ffffff" }, bg = "0c0a05", bd = "8a6d1a", tx = "fff6d6" },
    { name = "Candy Pop",     g = { "ff6b9d", "ffd93d", "6bcb77" }, p = { "4d96ff", "ff6b6b", "ffd93d", "ff9a76" }, c = { "ff9ff3", "ff6b9d" }, bg = "15121c", bd = "3a3050", tx = "ffffff" },
}

local defaults = {
    locked = true,
    scale = 1,
    width = 240,
    healthHeight = 22,
    powerHeight = 14,
    gap = 2,
    showHealth = true,
    showPower = true,
    smooth = true,
    showHealthText = true,
    showPowerText = true,
    textSize = 12,
    textFormat = 1,
    textStyle = 1,
    textPos = { health = { x = 0, y = 0 }, power = { x = 0, y = 0 } }, -- legacy, migrated into textCfg
    textMigrated = false,
    textCfg = {
        health = { size = 12, x = 0, y = 0 },
        power = { size = 12, x = 0, y = 0 },
        main = { size = 10, x = 0, y = 0 },
        off = { size = 10, x = 0, y = 0 },
        ranged = { size = 10, x = 0, y = 0 },
        castName = { size = 12, x = 0, y = 0 },
        castTime = { size = 12, x = 0, y = 0 },
    },
    moveFreely = false, -- off: all bars move together as one group; on: each bar moves on its own
    profiles = {},     -- saved named profiles (see the Profiles tab)
    tracker = { enabled = true, hideBlizzard = true, groups = {} }, -- custom cooldown / buff icon groups
    offsets = {}, -- per-bar offsets (from the bottom-left of the health/power group): combo, main, off, ranged, cast
    showCombo = true,
    comboHeight = 10,
    comboGap = 3,
    comboColor = { r = 1.0, g = 0.85, b = 0.20 },
    comboMaxColor = { r = 1.0, g = 0.30, b = 0.20 },
    showSwing = true,
    showSwingMain = true,
    showSwingOff = true,
    showSwingRanged = true,
    swingText = true,
    swingMainWidth = 0, swingMainHeight = 10,
    swingOffWidth = 0, swingOffHeight = 10,
    swingRangedWidth = 0, swingRangedHeight = 10,
    showCast = true,
    castShowName = true,
    castShowTime = true,
    castSpark = true,
    castWidth = 240,
    castHeight = 18,
    castColor = { r = 1.0, g = 0.70, b = 0.10 },
    channelColor = { r = 0.35, g = 0.75, b = 1.0 },
    swingSpark = true,
    swingMainColor = { r = 0.96, g = 0.60, b = 0.20 },
    swingOffColor = { r = 0.67, g = 0.47, b = 0.95 },
    swingRangedColor = { r = 0.25, g = 0.78, b = 0.80 },
    visibility = 1,
    classColor = false,
    healthGradient = true,
    healthColor = { r = 0.20, g = 0.83, b = 0.45 },
    gradLow = { r = 0.94, g = 0.27, b = 0.27 },
    gradMid = { r = 0.98, g = 0.80, b = 0.08 },
    gradHigh = { r = 0.20, g = 0.83, b = 0.45 },
    gradMax = { r = 0.30, g = 1.00, b = 0.55 },
    maxEnabled = true, -- use the max color when health is 100%
    dynHigh = 70, -- health at or above this %  -> high color
    dynLow = 30,  -- health at or below this %  -> low color (in between: medium)
    bgColor = { r = 0.05, g = 0.05, b = 0.07 },
    bgAlpha = 0.75,
    borderColor = { r = 0, g = 0, b = 0 },
    textColor = { r = 1, g = 1, b = 1 },
    showMinimap = true,
    minimapSquare = false,
    minimapAngle = 215,
    pos = { point = "CENTER", relPoint = "CENTER", x = 0, y = -180 },
}

-- Profiles every new user starts with. "Default" is built from the defaults above; "Yurri-Default"
-- is the author's own setup. Screen specific data (the bar position) is left out on purpose,
-- so loading one of them never moves your bars.
local BUILTIN_PROFILES = {
    ["Yurri-Default"] = {
            bgAlpha = 0.75,
            bgColor = {
                b = 0.07,
                g = 0.05,
                r = 0.05,
            },
            borderColor = {
                b = 0,
                g = 0,
                r = 0,
            },
            castColor = {
                b = 1,
                g = 0.5607843399,
                r = 0.007843137719,
            },
            castHeight = 6,
            castShowName = true,
            castShowTime = true,
            castSpark = true,
            castWidth = 238,
            channelColor = {
                b = 1,
                g = 0.75,
                r = 0.35,
            },
            classColor = false,
            comboColor = {
                b = 0.1764705926,
                g = 0.7529411912,
                r = 0.9843137264,
            },
            comboGap = 3,
            comboHeight = 10,
            comboMaxColor = {
                b = 0.2,
                g = 0.3,
                r = 1,
            },
            dynHigh = 70,
            dynLow = 30,
            gap = 2,
            gradHigh = {
                b = 0.45,
                g = 0.83,
                r = 0.2,
            },
            gradLow = {
                b = 0.27,
                g = 0.27,
                r = 0.94,
            },
            gradMax = {
                b = 0.3921568692,
                g = 1,
                r = 0.7058823705,
            },
            gradMid = {
                b = 0.08,
                g = 0.8,
                r = 0.98,
            },
            healthColor = {
                b = 0.45,
                g = 0.83,
                r = 0.2,
            },
            healthGradient = true,
            healthHeight = 16,
            maxEnabled = true,
            minimapSquare = false,
            moveFreely = false,
            offsets = {
                cast = {
                    x = 0.0001220703125,
                    y = -8.333418436,
                },
                combo = {
                    x = 0,
                    y = -18.66674805,
                },
                main = {
                    x = 0.8334684223,
                    y = 31.83331048,
                },
                off = {
                    x = 0.8335530646,
                    y = 12.33339556,
                },
                ranged = {
                    x = 0.8335457221,
                    y = 32.00022683,
                },
            },
            powerColors = {
                ENERGY = {
                    b = 0.4627451003,
                    g = 0.9450980425,
                    r = 1,
                },
                FOCUS = {
                    b = 0.24,
                    g = 0.57,
                    r = 0.98,
                },
                MANA = {
                    b = 0.96,
                    g = 0.51,
                    r = 0.23,
                },
                RAGE = {
                    b = 0.27,
                    g = 0.27,
                    r = 0.94,
                },
            },
            powerHeight = 14,
            scale = 1,
            showCast = true,
            showCombo = true,
            showHealth = true,
            showHealthText = false,
            showMinimap = true,
            showPower = true,
            showPowerText = false,
            showSwing = true,
            showSwingMain = true,
            showSwingOff = true,
            showSwingRanged = true,
            smooth = true,
            swingMainColor = {
                b = 0.2,
                g = 0.6,
                r = 0.96,
            },
            swingMainHeight = 5,
            swingMainWidth = 0,
            swingOffColor = {
                b = 0.95,
                g = 0.47,
                r = 0.67,
            },
            swingOffHeight = 5,
            swingOffWidth = 0,
            swingRangedColor = {
                b = 0.8,
                g = 0.78,
                r = 0.25,
            },
            swingRangedHeight = 5,
            swingRangedWidth = 0,
            swingSpark = true,
            swingText = true,
            textCfg = {
                castName = {
                    size = 8,
                    x = 0,
                    y = 0,
                },
                castTime = {
                    size = 10,
                    x = 10,
                    y = 0,
                },
                health = {
                    size = 12,
                    x = 82,
                    y = 0,
                },
                main = {
                    size = 10,
                    x = 110,
                    y = 7,
                },
                off = {
                    size = 8,
                    x = 110,
                    y = 1,
                },
                power = {
                    size = 12,
                    x = 0,
                    y = 0,
                },
                ranged = {
                    size = 10,
                    x = 110,
                    y = 7,
                },
            },
            textColor = {
                b = 1,
                g = 1,
                r = 1,
            },
            textFormat = 4,
            textMigrated = true,
            textSize = 12,
            textStyle = 5,
            visibility = 1,
            width = 240,
        },
}

local db
local container, health, power, combo, minimap
local swing, playerGUID
local comboShown, lastComboShown = false, nil
local playerClass
local drag, textDrag
local curPtype = 0
local healthCurve, curveDirty = nil, true
local options
local ToggleOptions, UpdateMinimapButton, StopDrag, TrackerApply, ToggleTracker -- assigned below
local StartTrackerDriver, CleanTracker, TrackerRefreshUI, TCheck, TrackerMaxGroups -- assigned by the tracker module

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local atan2 = math.atan2 or function(y, x) return math.atan(y, x) end

local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

local function DeepCopy(t)
    local n = {}
    for k, v in pairs(t) do n[k] = type(v) == "table" and DeepCopy(v) or v end
    return n
end

defaults.powerColors = DeepCopy(DEFAULT_POWER)

local function Lerp(a, b, t) return a + (b - a) * t end

local function Hex(h)
    return {
        r = tonumber(h:sub(1, 2), 16) / 255,
        g = tonumber(h:sub(3, 4), 16) / 255,
        b = tonumber(h:sub(5, 6), 16) / 255,
    }
end

local function Short(n)
    if n >= 1e6 then return string.format("%.1fM", n / 1e6) end
    if n >= 1e4 then return string.format("%.1fk", n / 1e3) end
    return tostring(math.floor(n + 0.5))
end

local function FormatText(cur, max, fmt)
    if max <= 0 then return "" end
    local pct = tostring(math.floor(cur / max * 100 + 0.5))
    if fmt == 1 then return Short(cur) .. " / " .. Short(max) end
    if fmt == 2 then return pct end
    if fmt == 3 then return Short(cur) end
    return Short(cur) .. "  |  " .. pct
end

local function DynamicColor(p)
    local pct = p * 100
    local c
    if db.maxEnabled and pct >= 99.99 then
        c = db.gradMax
    elseif pct >= db.dynHigh then
        c = db.gradHigh
    elseif pct <= db.dynLow then
        c = db.gradLow
    else
        c = db.gradMid
    end
    return c.r, c.g, c.b
end

local function IsSecret(v)
    return issecretvalue and issecretvalue(v) or false
end

local function SetGrad(tex, c1, c2)
    tex:SetTexture(WHITE)
    local ok = pcall(function()
        tex:SetGradient("HORIZONTAL", CreateColor(c1.r, c1.g, c1.b, 1), CreateColor(c2.r, c2.g, c2.b, 1))
    end)
    if not ok then
        ok = pcall(function()
            tex:SetGradient("HORIZONTAL", c1.r, c1.g, c1.b, c2.r, c2.g, c2.b)
        end)
    end
    if not ok then tex:SetVertexColor(c1.r, c1.g, c1.b, 1) end
end

------------------------------------------------------------
-- Bar widget
------------------------------------------------------------
local function PlaceText(bar)
    local tp = db.textCfg[bar.key]
    bar.text:ClearAllPoints()
    bar.text:SetPoint("CENTER", bar.bf, "CENTER", tp.x, tp.y)
end

-- font for a text: style is shared, size is per text (db.textCfg[key].size)
local function SetFontFor(fs, key, maxSize)
    local st = TEXT_STYLES[db.textStyle] or TEXT_STYLES[1]
    local size = db.textCfg[key].size
    if maxSize then size = math.min(size, maxSize) end
    size = math.max(size, 6)
    if not fs:SetFont(st.font, size, st.flags) then fs:SetFont(FONT, size, st.flags) end
end

local function ApplyFont(bar)
    SetFontFor(bar.text, bar.key)
end

local function CreateBar(parent, key)
    local f = CreateFrame("Frame", nil, parent)
    f.key = key

    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    f.bg:SetTexture(WHITE)

    f.sb = CreateFrame("StatusBar", nil, f)
    f.sb:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
    f.sb:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
    f.sb:SetStatusBarTexture(WHITE)
    f.sb:SetMinMaxValues(0, 1)
    f.sb:SetValue(1)

    -- subtle top gloss
    f.gloss = f.sb:CreateTexture(nil, "OVERLAY")
    f.gloss:SetTexture(WHITE)
    f.gloss:SetPoint("TOPLEFT", f.sb, "TOPLEFT")
    f.gloss:SetPoint("BOTTOMRIGHT", f.sb, "RIGHT")
    f.gloss:SetVertexColor(1, 1, 1, 0.07)

    local bf = CreateFrame("Frame", nil, f)
    bf:SetAllPoints()
    bf:SetFrameLevel(f.sb:GetFrameLevel() + 2)
    f.bf = bf

    f.edges = {}
    for i = 1, 4 do
        local t = bf:CreateTexture(nil, "OVERLAY")
        t:SetTexture(WHITE)
        f.edges[i] = t
    end
    f.edges[1]:SetPoint("TOPLEFT"); f.edges[1]:SetPoint("TOPRIGHT"); f.edges[1]:SetHeight(1)
    f.edges[2]:SetPoint("BOTTOMLEFT"); f.edges[2]:SetPoint("BOTTOMRIGHT"); f.edges[2]:SetHeight(1)
    f.edges[3]:SetPoint("TOPLEFT"); f.edges[3]:SetPoint("BOTTOMLEFT"); f.edges[3]:SetWidth(1)
    f.edges[4]:SetPoint("TOPRIGHT"); f.edges[4]:SetPoint("BOTTOMRIGHT"); f.edges[4]:SetWidth(1)

    f.text = bf:CreateFontString(nil, "OVERLAY")
    f.text:SetFont(FONT, 12, "OUTLINE")

    return f
end

local function SecretText(bar, cur, max, fmt, pctFn)
    local abbr = AbbreviateNumbers or function(v) return v end
    local pct = pctFn and pctFn()
    local ok = pcall(function()
        if fmt == 1 then
            bar.text:SetFormattedText("%s / %s", abbr(cur), abbr(max))
        elseif fmt == 3 then
            bar.text:SetFormattedText("%s", abbr(cur))
        elseif fmt == 2 then
            bar.text:SetFormattedText("%d", pct or 0)
        else
            bar.text:SetFormattedText("%s  |  %d", abbr(cur), pct or 0)
        end
    end)
    if not ok then bar.text:SetText("") end
end

local function SetBar(bar, cur, max, dt, textOn, pctFn)
    if IsSecret(cur) or IsSecret(max) then
        bar.sb:SetMinMaxValues(0, max)
        bar.sb:SetValue(cur)
        bar.lastCur = nil
        if textOn then SecretText(bar, cur, max, db.textFormat, pctFn) end
        return
    end

    if max <= 0 then max = 1 end
    bar.sb:SetMinMaxValues(0, max)

    if db.smooth then
        local d = bar.disp or cur
        if math.abs(cur - d) < max * 0.002 then
            d = cur
        else
            d = d + (cur - d) * math.min(1, dt * 10)
        end
        bar.disp = d
        bar.sb:SetValue(d)
    else
        bar.disp = cur
        bar.sb:SetValue(cur)
    end

    if textOn then
        if bar.lastCur ~= cur or bar.lastMax ~= max or bar.lastFmt ~= db.textFormat then
            bar.lastCur, bar.lastMax, bar.lastFmt = cur, max, db.textFormat
            bar.text:SetText(FormatText(cur, max, db.textFormat))
        end
    end
end

local function HealthPct()
    if UnitHealthPercent then
        return UnitHealthPercent("player", true, CurveConstants and CurveConstants.ScaleTo100)
    end
end

local function PowerPct()
    if UnitPowerPercent then
        return UnitPowerPercent("player", curPtype, true, CurveConstants and CurveConstants.ScaleTo100)
    end
end

local function GetCombo()
    local cp = 0
    local ok, v = pcall(UnitPower, "player", 4)
    if ok and type(v) == "number" and v > 0 then cp = v end
    if cp <= 0 and GetComboPoints then
        local ok2, v2 = pcall(GetComboPoints, "player", "target")
        if ok2 and type(v2) == "number" then cp = v2 end
    end
    return math.min(cp, 5)
end

------------------------------------------------------------
-- Colors
------------------------------------------------------------
local function HealthColor(pct)
    if db.classColor then
        local _, class = UnitClass("player")
        local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
        if c then return c.r, c.g, c.b end
    end
    if db.healthGradient then return DynamicColor(pct) end
    local c = db.healthColor
    return c.r, c.g, c.b
end

local function PowerColor(ptype, token)
    -- class color mode: power bars keep the default (modern) resource colors
    local c = token and (db.classColor and DEFAULT_POWER[token] or db.powerColors[token])
    if c then return c.r, c.g, c.b end
    local pc = PowerBarColor and ((token and PowerBarColor[token]) or PowerBarColor[ptype])
    if pc then return pc.r, pc.g, pc.b end
    return 0.6, 0.6, 0.6
end

-- When the client hides health values ("secret values") we cannot compare the
-- percentage ourselves, so the game evaluates a step color curve for us.
local function BuildHealthCurve()
    healthCurve = nil
    if not (C_CurveUtil and C_CurveUtil.CreateColorCurve and Enum.LuaCurveType and CreateColor) then return end
    local ok, curve = pcall(function()
        local c = C_CurveUtil.CreateColorCurve()
        c:SetType(Enum.LuaCurveType.Step)
        local lo, mid, hi, mx = db.gradLow, db.gradMid, db.gradHigh, db.gradMax
        c:AddPoint(0, CreateColor(lo.r, lo.g, lo.b, 1))
        c:AddPoint(db.dynLow / 100 + 0.0005, CreateColor(mid.r, mid.g, mid.b, 1))
        c:AddPoint(db.dynHigh / 100, CreateColor(hi.r, hi.g, hi.b, 1))
        if db.maxEnabled then c:AddPoint(1, CreateColor(mx.r, mx.g, mx.b, 1)) end
        return c
    end)
    if ok then healthCurve = curve end
end

------------------------------------------------------------
-- Layout
------------------------------------------------------------
------------------------------------------------------------
-- Swing timer (main hand, off hand, ranged)
------------------------------------------------------------
local SWING_ORDER = { "main", "off", "ranged" }
local SWING_COLOR_KEY = { main = "swingMainColor", off = "swingOffColor", ranged = "swingRangedColor" }
local SWING_PREVIEW_DUR = { main = 2.0, off = 2.4, ranged = 3.0 }
local AUTOSHOT_WINDUP = 0.52 -- Auto Shot is a 0.5s cast right before the shot fires

-- spells that replace the next melee swing (they reset the swing timer)
local NEXT_SWING_IDS = { 78, 845, 2973, 6807 } -- Heroic Strike, Cleave, Raptor Strike, Maul
-- ranged spells that restart the ranged timer
local RANGED_IDS = { [75] = true, [5019] = true, [2764] = true } -- Auto Shot, Shoot, Throw
local nextSwingNames = {}

local swingState = { main = {}, off = {}, ranged = {} }
local swingStats = { melee = 0, ranged = 0, api = false, events = 0 }
local meleeFlag = false -- set by PLAYER_ENTER_COMBAT / PLAYER_LEAVE_COMBAT

local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then
        local ok, n = pcall(C_Spell.GetSpellName, id)
        if ok and n then return n end
    end
    if GetSpellInfo then
        local ok, n = pcall(GetSpellInfo, id)
        if ok and type(n) == "string" then return n end
    end
end

local function SwingStart(slot, speed)
    if type(speed) ~= "number" or IsSecret(speed) or speed <= 0 then return end
    local st = swingState[slot]
    st.start, st.dur = GetTime(), speed
end

-- No combat log is available to addons on this client, so melee swings are ESTIMATED:
-- once auto-attack is on, the timer free-runs at your weapon speed, and ability swings
-- (Heroic Strike, Raptor Strike...) restart the main hand.
local function IsMeleeAttacking()
    if IsCurrentSpell then
        local ok, v = pcall(IsCurrentSpell, 6603) -- 6603 = Attack
        if ok and type(v) == "boolean" then return v end
    end
    return meleeFlag
end

local function EstimateMelee(now)
    if swingStats.api then return end -- real PLAYER_SWING events available: no estimating
    if not IsMeleeAttacking() then return end
    local main, offSpeed = UnitAttackSpeed("player")
    for _, slot in ipairs({ "main", "off" }) do
        local speed = (slot == "main") and main or offSpeed
        if type(speed) == "number" and not IsSecret(speed) and speed > 0 then
            local st = swingState[slot]
            if not st.start then
                SwingStart(slot, speed)
                swingStats.melee = swingStats.melee + 1
            elseif now - st.start >= st.dur then
                -- next swing begins exactly when the last one ended (no drift)
                st.start, st.dur = st.start + st.dur * math.floor((now - st.start) / st.dur), speed
                swingStats.melee = swingStats.melee + 1
            end
        end
    end
end

local SWING_PREFIX = { main = "swingMain", off = "swingOff", ranged = "swingRanged" }
local udrag -- drag of a single bar (combo / swing / cast) while "Move freely" is on

-- gold spark that rides the leading edge of a bar (soft glowing texture, additive blend)
local SPARK_TEXTURE = "Interface\\AddOns\\SenBar\\Textures\\Spark"
local function MakeSpark(sb)
    local spark = sb:CreateTexture(nil, "OVERLAY")
    spark:SetDrawLayer("OVERLAY", 2)
    spark:SetTexture(SPARK_TEXTURE)
    spark:SetBlendMode("ADD")
    spark:SetWidth(16)
    spark:Hide()
    return spark
end

local function MoveSpark(b, x, h)
    b.spark:SetHeight(h + 10)
    b.spark:ClearAllPoints()
    b.spark:SetPoint("CENTER", b.sb, "LEFT", x, 0)
    b.spark:Show()
end

local function HideSpark(b)
    b.spark:Hide()
end

local function SwingDims(key)
    local pre = SWING_PREFIX[key]
    local w = db[pre .. "Width"]
    if type(w) ~= "number" or w <= 0 then w = db.width end
    return w, math.max(db[pre .. "Height"] or 10, 2)
end

local function CreateSwingBar(parent, key)
    local b = CreateBar(parent, key)
    PlaceText(b)
    b.zone = b.sb:CreateTexture(nil, "OVERLAY")
    b.zone:SetTexture(WHITE)
    b.zone:SetVertexColor(1, 1, 1, 0.22)
    b.zone:SetPoint("TOPRIGHT", b.sb, "TOPRIGHT")
    b.zone:SetPoint("BOTTOMRIGHT", b.sb, "BOTTOMRIGHT")
    b.zone:Hide()
    b.spark = MakeSpark(b.sb)
    b.on = false
    return b
end

-- container -> swing frame: sits under the power bar, and under the combo row when that is shown
local function PlaceSwing()
    if not swing then return end
    local off = db.gap
    if comboShown then off = off + db.comboHeight + db.gap end
    swing:ClearAllPoints()
    swing:SetPoint("TOPLEFT", container, "BOTTOMLEFT", 0, -off)
    swing:SetSize(db.width, 1)
end

-- stack the visible swing bars, top to bottom; a bar that was moved sits at its own offset
local function LayoutSwing()
    if not swing then return end
    local y0 = 0
    for _, key in ipairs(SWING_ORDER) do
        local b = swing.bars[key]
        local w, h = SwingDims(key)
        local o = db.offsets[key]
        b.w, b.h = w, h
        b:EnableMouse(not db.locked)
        if b.on then
            b:ClearAllPoints()
            if o then
                b:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", o.x, o.y)
            else
                b:SetPoint("TOPLEFT", swing, "TOPLEFT", 0, -y0)
                y0 = y0 + h + db.gap
            end
            b:SetSize(w, h)
            b:Show()
        else
            b:Hide()
        end
    end
end

local function StyleSwing()
    if not swing then return end
    local st = TEXT_STYLES[db.textStyle] or TEXT_STYLES[1]
    local bg, bc, tc = db.bgColor, db.borderColor, db.textColor
    for _, key in ipairs(SWING_ORDER) do
        local b = swing.bars[key]
        local c = db[SWING_COLOR_KEY[key]]
        b.bg:SetVertexColor(bg.r, bg.g, bg.b, db.bgAlpha)
        for _, e in ipairs(b.edges) do e:SetVertexColor(bc.r, bc.g, bc.b, 1) end
        b.sb:SetStatusBarColor(c.r, c.g, c.b)
        SetFontFor(b.text, key)
        PlaceText(b)
        b.text:SetTextColor(tc.r, tc.g, tc.b, 1)
    end
    swing.mask = nil -- force a re-layout on the next update
end

local function UpdateSwing()
    if not swing then return end
    if comboShown ~= lastComboShown then
        lastComboShown = comboShown
        PlaceSwing()
    end

    local now = GetTime()
    EstimateMelee(now)
    local preview = not db.locked or (options and options:IsShown())
    local enabled = {
        main = db.showSwing and db.showSwingMain,
        off = db.showSwing and db.showSwingOff,
        ranged = db.showSwing and db.showSwingRanged,
    }

    local mask = ""
    local info = {}
    for _, key in ipairs(SWING_ORDER) do
        local st = swingState[key]
        local show, frac, remain, dur = false, 0, 0, st.dur
        if enabled[key] then
            if st.start and dur and (now - st.start) < dur + 0.15 then
                local el = now - st.start
                show, frac, remain = true, math.min(el / dur, 1), math.max(dur - el, 0)
            elseif preview then
                dur = SWING_PREVIEW_DUR[key]
                local el = now % dur
                show, frac, remain = true, el / dur, dur - el
            end
        end
        info[key] = { frac = frac, remain = remain, dur = dur }
        mask = mask .. (show and "1" or "0")
        swing.bars[key].on = show
    end

    if mask ~= swing.mask then
        swing.mask = mask
        LayoutSwing()
    end

    for _, key in ipairs(SWING_ORDER) do
        local b = swing.bars[key]
        if b.on then
            local i = info[key]
            b.sb:SetValue(i.frac)
            if db.swingSpark and i.frac > 0 and i.frac < 1 then
                MoveSpark(b, i.frac * ((b.w or db.width) - 2), b.h or 10)
            else
                HideSpark(b)
            end
            if db.swingText then
                b.text:SetFormattedText("%.1f", i.remain)
                b.text:Show()
            else
                b.text:Hide()
            end
            if key == "ranged" and i.dur and i.dur > 0 then
                local w = ((b.w or db.width) - 2) * math.min(AUTOSHOT_WINDUP / i.dur, 1)
                b.zone:SetWidth(math.max(w, 1))
                b.zone:Show()
            else
                b.zone:Hide()
            end
        end
    end
end

-- Blizzard's own swing event (as used by WeaponSwingTimer): PLAYER_SWING(duration, swingType)
local SWING_SLOT = {}
if Enum and Enum.PlayerSwingType then
    SWING_SLOT[Enum.PlayerSwingType.MainHand] = "main"
    SWING_SLOT[Enum.PlayerSwingType.OffHand] = "off"
    SWING_SLOT[Enum.PlayerSwingType.Ranged] = "ranged"
end

-- parry haste: a parried attack on you cuts the remaining main-hand swing by 40% of the
-- weapon speed, but never below 20% of it
local function ParryHaste()
    local st = swingState.main
    if not st.start or not st.dur then return end
    local now = GetTime()
    local remain = st.dur - (now - st.start)
    local floor = st.dur * 0.2
    if remain > floor then
        local newRemain = math.max(remain - st.dur * 0.4, floor)
        st.start = now - (st.dur - newRemain)
    end
end

local function SwingEvent(self, event, ...)
    if event == "PLAYER_SWING" then
        local duration, swingType = ...
        if IsSecret(swingType) then return end
        local slot = SWING_SLOT[swingType]
        if not slot then return end
        swingStats.events = swingStats.events + 1
        if slot == "ranged" then swingStats.ranged = swingStats.ranged + 1
        else swingStats.melee = swingStats.melee + 1 end
        SwingStart(slot, duration)
    elseif event == "UNIT_COMBAT" then
        local unit, action = ...
        if unit == "player" and not IsSecret(action) and action == "PARRY" then ParryHaste() end
    elseif event == "PLAYER_ENTER_COMBAT" then
        meleeFlag = true
    elseif event == "PLAYER_LEAVE_COMBAT" then
        meleeFlag = false
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        if swingStats.api then return end -- fallback path only
        local unit, _, spellID = ...
        if unit ~= "player" or IsSecret(spellID) or type(spellID) ~= "number" then return end
        if RANGED_IDS[spellID] then
            swingStats.ranged = swingStats.ranged + 1
            SwingStart("ranged", UnitRangedDamage and UnitRangedDamage("player"))
        else
            local name = SpellName(spellID)
            if name and nextSwingNames[name] then
                SwingStart("main", (UnitAttackSpeed("player")))
            end
        end
    end
end

------------------------------------------------------------
-- Cast bar (player spell casts and channels)
------------------------------------------------------------
local castFrame
local castState = {}
local CAST_FAIL_COLOR = { r = 0.85, g = 0.20, b = 0.20 }
local CAST_EVENTS = {
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
}

local function CreateCastBar()
    local b = CreateBar(UIParent, "cast")
    b:SetFrameStrata("LOW")
    b:SetClampedToScreen(true)
    b.text:SetJustifyH("RIGHT")
    b.name = b.bf:CreateFontString(nil, "OVERLAY")
    b.name:SetFont(FONT, 12, "OUTLINE")
    b.name:SetJustifyH("LEFT")
    b.spark = MakeSpark(b.sb)
    b:Hide()
    return b
end

local function PlaceCastText()
    local n, t = db.textCfg.castName, db.textCfg.castTime
    castFrame.text:ClearAllPoints()
    castFrame.text:SetPoint("RIGHT", castFrame.bf, "RIGHT", -5 + t.x, t.y)
    castFrame.name:ClearAllPoints()
    castFrame.name:SetPoint("LEFT", castFrame.bf, "LEFT", 5 + n.x, n.y)
    castFrame.name:SetWidth(math.max(db.castWidth - 60, 20))
end

local function StyleCast()
    if not castFrame then return end
    local bg, bc, tc = db.bgColor, db.borderColor, db.textColor
    castFrame:SetSize(db.castWidth, db.castHeight)
    castFrame:SetScale(db.scale) -- same scale as the bar group, so the two stay in proportion
    castFrame.bg:SetVertexColor(bg.r, bg.g, bg.b, db.bgAlpha)
    for _, e in ipairs(castFrame.edges) do e:SetVertexColor(bc.r, bc.g, bc.b, 1) end
    SetFontFor(castFrame.text, "castTime")
    SetFontFor(castFrame.name, "castName")
    for _, fs in ipairs({ castFrame.text, castFrame.name }) do fs:SetTextColor(tc.r, tc.g, tc.b, 1) end
    PlaceCastText()
    castFrame:EnableMouse(not db.locked)
end

-- read the player's current cast / channel (values can be unreadable on restricted clients)
local function CastRefresh()
    local st = castState
    local ok, name, _, _, s0, e0 = pcall(UnitCastingInfo, "player")
    local kind = "cast"
    if not ok or not name then
        ok, name, _, _, s0, e0 = pcall(UnitChannelInfo, "player")
        kind = "channel"
    end
    if ok and name and not IsSecret(name) and type(s0) == "number" and type(e0) == "number"
        and not IsSecret(s0) and not IsSecret(e0) then
        st.kind, st.name, st.start, st.finish = kind, name, s0 / 1000, e0 / 1000
        st.hold = nil
    else
        if st.kind then st.endedAt = GetTime() end
        st.kind = nil
    end
end

local function CastEvent(self, event, unit)
    if unit and unit ~= "player" then return end
    local st = castState
    local wasActive = st.kind ~= nil
    CastRefresh()
    if event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        local recent = st.endedAt and (GetTime() - st.endedAt) < 0.2
        if not st.kind and (wasActive or recent) then
            st.hold = GetTime() + 0.7
            st.holdText = (event == "UNIT_SPELLCAST_FAILED") and (FAILED or "Failed") or (INTERRUPTED or "Interrupted")
        end
    end
end

local function UpdateCast()
    if not castFrame then return end
    local st = castState
    local now = GetTime()
    local preview = not db.locked or (options and options:IsShown())
    local b = castFrame
    local show, frac, nameText, timeText, color = false, 0, "", "", db.castColor

    if db.showCast then
        if st.kind and now <= st.finish + 0.05 then
            local dur = math.max(st.finish - st.start, 0.001)
            if st.kind == "cast" then
                frac = (now - st.start) / dur
            else
                frac = (st.finish - now) / dur
                color = db.channelColor
            end
            frac = math.min(math.max(frac, 0), 1)
            show, nameText = true, st.name
            timeText = string.format("%.1f", math.max(st.finish - now, 0))
        elseif st.hold and now < st.hold then
            show, frac, color, nameText = true, 1, CAST_FAIL_COLOR, st.holdText or ""
        elseif preview then
            local dur = 3
            frac = (now % dur) / dur
            show, nameText = true, "Spell name"
            timeText = string.format("%.1f", dur - (now % dur))
        end
    end

    if not show then
        if b:IsShown() then b:Hide() end
        return
    end
    if not b:IsShown() then b:Show() end
    b.sb:SetValue(frac)
    b.sb:SetStatusBarColor(color.r, color.g, color.b)
    if db.castShowName then b.name:SetText(nameText); b.name:Show() else b.name:Hide() end
    if db.castShowTime then b.text:SetText(timeText); b.text:Show() else b.text:Hide() end
    if db.castSpark and frac > 0 and frac < 1 then
        MoveSpark(b, frac * (db.castWidth - 2), db.castHeight)
    else
        HideSpark(b)
    end
end

------------------------------------------------------------
-- Positions: health + power are one unit (the container). Combo, each swing bar and the cast
-- bar are placed by an offset from the container's bottom-left corner. "Move freely" only
-- changes what a drag moves: everything together (off) or one bar at a time (on).
------------------------------------------------------------
local UNIT_KEYS = { "combo", "main", "off", "ranged", "cast" }
local DEFAULT_CAST_OFFSET = { x = 0, y = -70 }

local function UnitFrame(key)
    if key == "combo" then return combo end
    if key == "cast" then return castFrame end
    return swing and swing.bars[key]
end

-- put a unit at its saved offset; returns false when it has none (it then uses the automatic layout)
local function PlaceUnit(key)
    local f = UnitFrame(key)
    local o = db.offsets[key]
    if key == "cast" and not o then o = DEFAULT_CAST_OFFSET end
    if not f or not o then return false end
    f:ClearAllPoints()
    f:SetPoint("BOTTOMLEFT", container, "BOTTOMLEFT", o.x, o.y)
    return true
end

local function PlaceCast() PlaceUnit("cast") end

-- freeze every visible unit where it is now, so it stops following the automatic layout
local function PinAll()
    local cl, cb = container:GetLeft(), container:GetBottom()
    if type(cl) ~= "number" or type(cb) ~= "number" then return end
    for _, key in ipairs(UNIT_KEYS) do
        if not db.offsets[key] then
            local f = UnitFrame(key)
            if f and f:IsShown() then
                local l, bt = f:GetLeft(), f:GetBottom()
                if type(l) == "number" and type(bt) == "number" then
                    db.offsets[key] = { x = l - cl, y = bt - cb }
                end
            end
        end
    end
end

local function BeginGroupDrag(cx, cy)
    local left, bottom = container:GetLeft(), container:GetBottom()
    if not left or not bottom then return end
    local sc = container:GetEffectiveScale()
    if db.moveFreely then PinAll() end
    drag = { dx = left * sc - cx, dy = bottom * sc - cy, lx = left, ly = bottom }
end

local function BeginUnitDrag(key, frame)
    if db.locked then return end
    local cx, cy = GetCursorPosition()
    if not db.moveFreely then
        BeginGroupDrag(cx, cy) -- everything moves together
        return
    end
    PinAll()
    local l, bt = frame:GetLeft(), frame:GetBottom()
    if not l or not bt then return end
    local sc = frame:GetEffectiveScale()
    udrag = { key = key, frame = frame, dx = l * sc - cx, dy = bt * sc - cy }
end

local function Apply()
    if not container then return end
    curveDirty = true

    container:SetScale(db.scale)

    local h = db.showHealth and db.healthHeight or 0
    local p = db.showPower and db.powerHeight or 0
    local gap = (db.showHealth and db.showPower) and db.gap or 0
    container:SetSize(db.width, math.max(h + gap + p, 14))

    health:ClearAllPoints()
    health:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    health:SetSize(db.width, math.max(db.healthHeight, 1))
    if db.showHealth then health:Show() else health:Hide() end

    power:ClearAllPoints()
    if db.showHealth then
        power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -gap)
    else
        power:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    end
    power:SetSize(db.width, math.max(db.powerHeight, 1))
    if db.showPower then power:Show() else power:Hide() end

    for _, bar in ipairs({ health, power }) do
        local bg, bc, tc = db.bgColor, db.borderColor, db.textColor
        bar.bg:SetVertexColor(bg.r, bg.g, bg.b, db.bgAlpha)
        for _, e in ipairs(bar.edges) do e:SetVertexColor(bc.r, bc.g, bc.b, 1) end
        ApplyFont(bar)
        bar.text:SetTextColor(tc.r, tc.g, tc.b, 1)
        PlaceText(bar)
        bar.lastCur = nil

        local textOn
        if bar == health then textOn = db.showHealthText else textOn = db.showPowerText end
        if textOn then bar.text:Show() else bar.text:Hide() end

    end

    -- combo point row
    if not PlaceUnit("combo") then
        combo:ClearAllPoints()
        local anchor = (db.showPower and power) or (db.showHealth and health) or container
        if anchor == container then
            combo:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        else
            combo:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -db.gap)
        end
    end
    combo:EnableMouse(not db.locked)
    combo:SetSize(db.width, db.comboHeight)
    local n, sg = #combo.segs, db.comboGap
    local w = math.max(2, (db.width - (n - 1) * sg) / n)
    for i, seg in ipairs(combo.segs) do
        seg:ClearAllPoints()
        seg:SetSize(w, db.comboHeight)
        seg:SetPoint("TOPLEFT", combo, "TOPLEFT", (i - 1) * (w + sg), 0)
        seg.bg:SetVertexColor(db.bgColor.r, db.bgColor.g, db.bgColor.b, db.bgAlpha)
        for _, e in ipairs(seg.edges) do e:SetVertexColor(db.borderColor.r, db.borderColor.g, db.borderColor.b, 1) end
    end

    container:ClearAllPoints()
    container:SetPoint(db.pos.point, UIParent, db.pos.relPoint, db.pos.x, db.pos.y)

    container:EnableMouse(not db.locked)
    if db.locked then
        if drag then StopDrag() end
        textDrag = nil
        container.unlockTex:Hide()
        container.unlockLabel:Hide()
    else
        container.unlockTex:Show()
        container.unlockLabel:Show()
    end

    StyleSwing()
    PlaceSwing()
    LayoutSwing()
    StyleCast()
    PlaceCast()

    if TrackerApply then TrackerApply() end
    if UpdateMinimapButton then UpdateMinimapButton() end
    if NS.profileSnapshotSync then NS.profileSnapshotSync() end
end

local function ShouldShow()
    if not db.locked or (options and options:IsShown()) then return true end
    local v = db.visibility
    if v == 1 then return true end
    if v == 2 then return UnitAffectingCombat("player") and true or false end
    if v == 3 then return (UnitAffectingCombat("player") or UnitExists("target")) and true or false end
    return false
end

------------------------------------------------------------
-- Main update loop
------------------------------------------------------------
StopDrag = function()
    if not drag then return end
    drag = nil
    local point, _, relPoint, x, y = container:GetPoint()
    if point then
        db.pos = { point = point, relPoint = relPoint or point, x = x, y = y }
    end
end

local function OnUpdate(self, dt)
    -- group drag (health + power; with "Move freely" off, every bar moves with it)
    if drag then
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
            StopDrag()
        else
            local cx, cy = GetCursorPosition()
            local sc = container:GetEffectiveScale()
            local nx, ny = (cx + drag.dx) / sc, (cy + drag.dy) / sc
            container:ClearAllPoints()
            container:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", nx, ny)
            if db.moveFreely and drag.lx then
                -- the other bars stay where they are: cancel the container's movement in their offsets
                local ddx, ddy = nx - drag.lx, ny - drag.ly
                for _, key in ipairs(UNIT_KEYS) do
                    local o = db.offsets[key]
                    if o then
                        o.x, o.y = o.x - ddx, o.y - ddy
                        PlaceUnit(key)
                    end
                end
                drag.lx, drag.ly = nx, ny
            end
        end
    end

    -- single bar drag ("Move freely" on)
    if udrag then
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
            udrag = nil
        else
            local cx, cy = GetCursorPosition()
            local sc = udrag.frame:GetEffectiveScale()
            local cl, cb = container:GetLeft(), container:GetBottom()
            if cl and cb then
                db.offsets[udrag.key] = { x = (cx + udrag.dx) / sc - cl, y = (cy + udrag.dy) / sc - cb }
                PlaceUnit(udrag.key)
            end
        end
    end

    local ptype, token = UnitPowerType("player")
    ptype = ptype or 0
    curPtype = ptype

    if curveDirty then
        curveDirty = false
        BuildHealthCurve()
    end

    if db.showHealth then
        local cur, max = UnitHealth("player"), UnitHealthMax("player")
        SetBar(health, cur, max, dt, db.showHealthText, HealthPct)
        if not IsSecret(cur) and not IsSecret(max) then
            local pct = (max and max > 0) and (cur / max) or 0
            health.sb:SetStatusBarColor(HealthColor(pct))
        else
            local r, g, b
            if db.healthGradient and not db.classColor and healthCurve and UnitHealthPercent then
                local ok, c = pcall(UnitHealthPercent, "player", true, healthCurve)
                if ok and c and c.GetRGB then r, g, b = c:GetRGB() end
            end
            if r then
                local tex = health.sb:GetStatusBarTexture()
                if tex then pcall(tex.SetVertexColor, tex, r, g, b, 1) end
            else
                health.sb:SetStatusBarColor(HealthColor(1))
            end
        end
    end

    if db.showPower then
        SetBar(power, UnitPower("player", ptype), UnitPowerMax("player", ptype), dt, db.showPowerText, PowerPct)
        power.sb:SetStatusBarColor(PowerColor(ptype, token))
    end

    -- combo points: Rogue, or Druid in Cat Form. Previewed while configuring.
    local preview = not db.locked or (options and options:IsShown())
    local showCombo, cp = false, 0
    if db.showCombo then
        if playerClass == "ROGUE" or (playerClass == "DRUID" and ptype == 3) then
            showCombo, cp = true, GetCombo()
        elseif preview then
            showCombo, cp = true, 3
        end
    end
    if showCombo then
        combo:Show()
        local c = (cp >= #combo.segs) and db.comboMaxColor or db.comboColor
        for i, seg in ipairs(combo.segs) do
            seg.fill:SetVertexColor(c.r, c.g, c.b, i <= cp and 1 or 0.12)
        end
    else
        combo:Hide()
    end
    comboShown = showCombo

    UpdateSwing()
    UpdateCast()

    local target = ShouldShow() and 1 or 0
    local a = container:GetAlpha() or 1
    if a ~= target then
        a = a + (target - a) * math.min(1, dt * 8)
        if math.abs(a - target) < 0.02 then a = target end
        container:SetAlpha(a)
    end
end

------------------------------------------------------------
-- Minimap button (icon drawn in code: health / power / combo bars)
------------------------------------------------------------
local function MinimapPosition()
    if not minimap then return end
    local a = math.rad(db.minimapAngle)
    local dx, dy = math.cos(a), math.sin(a)
    local w, h = Minimap:GetWidth() / 2 + 5, Minimap:GetHeight() / 2 + 5
    local shape = GetMinimapShape and GetMinimapShape()
    local square = db.minimapSquare or (shape and shape ~= "ROUND")
    local x, y
    if square then
        local m = math.max(math.abs(dx), math.abs(dy))
        if m == 0 then m = 1 end
        x, y = dx / m * w, dy / m * h
    else
        x, y = dx * w, dy * h
    end
    minimap:ClearAllPoints()
    minimap:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local mdrag
local function MinimapDragUpdate(self)
    if not mdrag then return end
    if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
        self:SetScript("OnUpdate", nil)
        return
    end
    local cx, cy = GetCursorPosition()
    if math.abs(cx - mdrag.cx) + math.abs(cy - mdrag.cy) > 6 then mdrag.moved = true end
    if mdrag.moved then
        local s = Minimap:GetEffectiveScale()
        local mx, my = Minimap:GetCenter()
        db.minimapAngle = math.deg(atan2(cy / s - my, cx / s - mx))
        MinimapPosition()
    end
end

local function CreateMinimapButton()
    local b = CreateFrame("Button", "SenBarMinimapButton", Minimap)
    b:SetSize(31, 31)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(8)

    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)

    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetPoint("TOPLEFT", b, "TOPLEFT", 7, -5)
    bg:SetVertexColor(0.05, 0.07, 0.12, 1)

    local art = CreateFrame("Frame", nil, b)
    art:SetSize(20, 20)
    art:SetPoint("TOPLEFT", b, "TOPLEFT", 7, -5)
    local function Px(w, h, x, y, r, g, bl)
        local t = art:CreateTexture(nil, "ARTWORK")
        t:SetTexture(WHITE)
        t:SetSize(w, h)
        t:SetPoint("CENTER", art, "CENTER", x, y)
        t:SetVertexColor(r, g, bl, 1)
    end
    Px(14, 4, 0, 4, 0.25, 0.90, 0.45)   -- health bar
    Px(14, 3, 0, -1, 0.30, 0.60, 1.00)  -- power bar
    for i = 0, 4 do                       -- combo points
        Px(2, 2, -6 + i * 3, -5, 1.0, 0.85, 0.20)
    end

    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("SenBar", 0.25, 0.75, 1)
        GameTooltip:AddLine("Left-click: open settings", 1, 1, 1)
        GameTooltip:AddLine("Right-click: lock / unlock bars", 1, 1, 1)
        GameTooltip:AddLine("Drag: move this icon", 0.6, 0.6, 0.6)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)

    b:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        local cx, cy = GetCursorPosition()
        mdrag = { cx = cx, cy = cy, moved = false }
        self:SetScript("OnUpdate", MinimapDragUpdate)
    end)
    b:SetScript("OnMouseUp", function(self, button)
        self:SetScript("OnUpdate", nil)
        local wasDrag = mdrag and mdrag.moved
        mdrag = nil
        if wasDrag then return end
        if button == "RightButton" then
            db.locked = not db.locked
            Apply()
            if options and options.Refresh then options.Refresh() end
        else
            ToggleOptions()
        end
    end)

    return b
end

UpdateMinimapButton = function()
    if not minimap then return end
    if db.showMinimap then
        minimap:Show()
        MinimapPosition()
    else
        minimap:Hide()
    end
end

------------------------------------------------------------
-- Settings UI toolkit (flat, dark, modern)
------------------------------------------------------------
local function Flat(frame, r, g, b, a, layer)
    local t = frame:CreateTexture(nil, layer or "BACKGROUND")
    t:SetAllPoints()
    t:SetTexture(WHITE)
    t:SetVertexColor(r, g, b, a or 1)
    return t
end

local function Outline(frame, r, g, b, a)
    local edges = {}
    for i = 1, 4 do
        local t = frame:CreateTexture(nil, "BORDER")
        t:SetTexture(WHITE)
        t:SetVertexColor(r, g, b, a or 1)
        edges[i] = t
    end
    edges[1]:SetPoint("TOPLEFT"); edges[1]:SetPoint("TOPRIGHT"); edges[1]:SetHeight(1)
    edges[2]:SetPoint("BOTTOMLEFT"); edges[2]:SetPoint("BOTTOMRIGHT"); edges[2]:SetHeight(1)
    edges[3]:SetPoint("TOPLEFT"); edges[3]:SetPoint("BOTTOMLEFT"); edges[3]:SetWidth(1)
    edges[4]:SetPoint("TOPRIGHT"); edges[4]:SetPoint("BOTTOMRIGHT"); edges[4]:SetWidth(1)
    return edges
end

local function Label(parent, text, size, r, g, b)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(FONT, size or 12, "")
    fs:SetTextColor(r or 0.85, g or 0.87, b or 0.92, 1)
    fs:SetText(text or "")
    return fs
end

-- makes every text inside a frame a bit bigger (used by the tracker editor, which opens at a compact scale)
function NS.BoostFonts(frame, add)
    if not frame then return end
    if frame.GetObjectType and frame:GetObjectType() == "EditBox" and not frame.sbBoost and frame.GetFont then
        local f, sz, fl = frame:GetFont()
        if f and sz then frame:SetFont(f, sz + add, fl); frame.sbBoost = true end
    end
    for _, r in ipairs({ frame:GetRegions() }) do
        if r.GetObjectType and r:GetObjectType() == "FontString" and not r.sbBoost then
            local f, sz, fl = r:GetFont()
            if f and sz then r:SetFont(f, sz + add, fl); r.sbBoost = true end
        end
    end
    for _, c in ipairs({ frame:GetChildren() }) do NS.BoostFonts(c, add) end
end

local function MakeButton(parent, text, w, h, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(w, h)
    b.bg = Flat(b, 0.16, 0.17, 0.21, 1)
    Outline(b, 0.28, 0.30, 0.36, 1)
    b.label = Label(b, text, 12)
    b.label:SetPoint("CENTER")
    b:SetScript("OnEnter", function(self) self.bg:SetVertexColor(0.22, 0.24, 0.30, 1) end)
    b:SetScript("OnLeave", function(self) self.bg:SetVertexColor(0.16, 0.17, 0.21, 1) end)
    b:SetScript("OnClick", function(self, button) if onClick then onClick(self, button) end end)
    return b
end

local controls = {}
local function Register(refresh) controls[#controls + 1] = refresh end
local function RefreshAll() for _, fn in ipairs(controls) do fn() end end

local function AddCheck(page, y, text, key, invert, onToggle)
    local row = CreateFrame("Button", nil, page)
    row:SetSize(316, 24)
    row:SetPoint("TOPLEFT", page, "TOPLEFT", 10, y)

    local box = CreateFrame("Frame", nil, row)
    box:SetSize(16, 16)
    box:SetPoint("LEFT", row, "LEFT", 0, 0)
    Flat(box, 0.12, 0.13, 0.16, 1)
    Outline(box, 0.30, 0.32, 0.38, 1)
    local fill = box:CreateTexture(nil, "OVERLAY")
    fill:SetPoint("TOPLEFT", 3, -3)
    fill:SetPoint("BOTTOMRIGHT", -3, 3)
    fill:SetTexture(WHITE)
    fill:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

    local fs = Label(row, text, 12)
    fs:SetPoint("LEFT", box, "RIGHT", 10, 0)

    local function checked()
        if invert then return not db[key] end
        return db[key] and true or false
    end
    local function refresh()
        if checked() then fill:Show() else fill:Hide() end
    end
    row:SetScript("OnClick", function()
        db[key] = not db[key]
        if onToggle then onToggle() end
        if key == "healthGradient" or key == "classColor" then db.preset = nil end
        RefreshAll()
        Apply()
    end)
    Register(refresh)
    return row
end

-- small type-in number box (percent thresholds)
local function AddNumBox(page, x, y, text, key, minV, maxV, limit)
    local fs = Label(page, text, 12)
    fs:SetPoint("TOPLEFT", page, "TOPLEFT", x, y - 3)

    local box = CreateFrame("EditBox", nil, page)
    box:SetSize(40, 18)
    box:SetPoint("TOPLEFT", page, "TOPLEFT", x + 74, y)
    box:SetAutoFocus(false)
    box:SetFont(FONT, 12, "")
    box:SetTextColor(0.6, 0.85, 1, 1)
    box:SetJustifyH("CENTER")
    box:SetMaxLetters(3)
    Flat(box, 0.11, 0.12, 0.15, 1)
    local edges = Outline(box, 0.26, 0.28, 0.34, 1)

    local pct = Label(page, "%", 12, 0.6, 0.85, 1)
    pct:SetPoint("LEFT", box, "RIGHT", 4, 0)

    local function show()
        if not box:HasFocus() then box:SetText(tostring(db[key])) end
    end
    local function commit()
        local n = tonumber(box:GetText())
        if n then
            n = math.floor(math.max(minV, math.min(maxV, n)) + 0.5)
            local lo, hi = limit(n)
            n = math.max(lo, math.min(hi, n))
            db[key] = n
            db.preset = nil
            Apply()
        end
    end
    box:SetScript("OnEnterPressed", function(self) commit(); self:ClearFocus() end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScript("OnEditFocusGained", function(self)
        for _, e in ipairs(edges) do e:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1) end
        self:HighlightText()
    end)
    box:SetScript("OnEditFocusLost", function(self)
        for _, e in ipairs(edges) do e:SetVertexColor(0.26, 0.28, 0.34, 1) end
        self:HighlightText(0, 0)
        show()
    end)
    Register(show)
end

local function AddSlider(page, y, text, key, minV, maxV, step, fmt, getter, setter)
    local function get() if getter then return getter() end return db[key] end
    local function set(v) if setter then setter(v) else db[key] = v end end
    local fs = Label(page, text, 12)
    fs:SetPoint("TOPLEFT", page, "TOPLEFT", 10, y - 4)

    local s = CreateFrame("Slider", nil, page)
    s:SetOrientation("HORIZONTAL")
    s:SetSize(130, 14)
    s:SetPoint("TOPLEFT", page, "TOPLEFT", 140, y - 2)
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end

    local track = s:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", s, "LEFT", 0, 0)
    track:SetPoint("RIGHT", s, "RIGHT", 0, 0)
    track:SetHeight(4)
    track:SetTexture(WHITE)
    track:SetVertexColor(0.18, 0.19, 0.24, 1)

    s:SetThumbTexture(WHITE)
    local thumb = s:GetThumbTexture()
    thumb:SetSize(8, 14)
    thumb:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

    -- the number on the right is editable: click it, type a value, press Enter
    local val = CreateFrame("EditBox", nil, page)
    val:SetSize(48, 18)
    val:SetPoint("LEFT", s, "RIGHT", 8, 0)
    val:SetAutoFocus(false)
    val:SetFont(FONT, 12, "")
    val:SetTextColor(0.6, 0.85, 1, 1)
    val:SetJustifyH("CENTER")
    val:SetMaxLetters(7)
    local vbg = Flat(val, 0.11, 0.12, 0.15, 1)
    local vedges = Outline(val, 0.26, 0.28, 0.34, 1)

    local function show(v)
        if not val:HasFocus() then val:SetText(string.format(fmt or "%d", v)) end
    end

    local function commit()
        local n = tonumber(val:GetText())
        if n then
            n = math.max(minV, math.min(maxV, n))
            n = math.floor(n / step + 0.5) * step
            set(n)
            s.updating = true
            s:SetValue(n)
            s.updating = false
            Apply()
        end
    end

    val:SetScript("OnEnterPressed", function(self) commit(); self:ClearFocus() end)
    val:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    val:SetScript("OnEditFocusGained", function(self)
        for _, e in ipairs(vedges) do e:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1) end
        self:HighlightText()
    end)
    val:SetScript("OnEditFocusLost", function(self)
        for _, e in ipairs(vedges) do e:SetVertexColor(0.26, 0.28, 0.34, 1) end
        self:HighlightText(0, 0)
        show(get())
    end)

    s:SetScript("OnValueChanged", function(self, v)
        if self.updating then return end
        v = math.floor(v / step + 0.5) * step
        set(v)
        show(v)
        Apply()
    end)

    Register(function()
        s.updating = true
        s:SetValue(get())
        s.updating = false
        show(get())
    end)
end

-- "<  value  >" selector: arrows on both sides, so it is obvious that it can be changed
local function ArrowSelect(page, x, y, width, onStep)
    local left = MakeButton(page, "<", 22, 22, function() onStep(-1) end)
    left:SetPoint("TOPLEFT", page, "TOPLEFT", x, y)

    local mid = CreateFrame("Button", nil, page)
    mid:SetSize(width - 48, 22)
    mid:SetPoint("LEFT", left, "RIGHT", 2, 0)
    Flat(mid, 0.11, 0.12, 0.15, 1)
    Outline(mid, 0.22, 0.24, 0.30, 1)
    mid.label = Label(mid, "", 12)
    mid.label:SetPoint("CENTER")
    mid:SetScript("OnClick", function() onStep(1) end)

    local right = MakeButton(page, ">", 22, 22, function() onStep(1) end)
    right:SetPoint("LEFT", mid, "RIGHT", 2, 0)

    return function(text) mid.label:SetText(text) end
end

local function AddCycle(page, y, text, key, list)
    local fs = Label(page, text, 12)
    fs:SetPoint("TOPLEFT", page, "TOPLEFT", 10, y - 4)

    local setText
    local function refresh() setText(list[db[key]] or "?") end
    setText = ArrowSelect(page, 140, y, 160, function(dir)
        local n = (db[key] or 1) + dir
        if n > #list then n = 1 elseif n < 1 then n = #list end
        db[key] = n
        refresh()
        Apply()
    end)
    Register(refresh)
end

local activeColorPicker
if ColorPickerFrame and ColorPickerFrame.EnableKeyboard then ColorPickerFrame:EnableKeyboard(true) end
if ColorPickerFrame and ColorPickerFrame.SetPropagateKeyboardInput then ColorPickerFrame:SetPropagateKeyboardInput(true) end
if ColorPickerFrame and ColorPickerFrame.HookScript then
    ColorPickerFrame:HookScript("OnKeyDown", function(_, key)
        if key == "ESCAPE" and activeColorPicker then activeColorPicker.cancel() end
    end)
end
local colorPickerWatcher = CreateFrame("Frame")
colorPickerWatcher:SetScript("OnUpdate", function()
    local state = activeColorPicker
    if not state or not ColorPickerFrame or not ColorPickerFrame:IsShown() then return end

    local mouseDown = (IsMouseButtonDown and (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton") or IsMouseButtonDown("MiddleButton"))) or false
    if mouseDown and not state.wasMouseDown then
        local focus = (GetMouseFocus and GetMouseFocus()) or nil
        local insidePicker = ColorPickerFrame.IsMouseOver and ColorPickerFrame:IsMouseOver() or false
        while not insidePicker and focus do
            if focus == ColorPickerFrame then insidePicker = true; break end
            focus = focus.GetParent and focus:GetParent() or nil
        end
        if not insidePicker then state.cancel() return end
    end
    state.wasMouseDown = mouseDown

    local escapeDown = (IsKeyDown and IsKeyDown("ESCAPE")) or false
    if escapeDown and not state.wasEscapeDown then state.cancel() return end
    state.wasEscapeDown = escapeDown
end)

local function OpenColorPicker(c, onChange)
    local prev = { r = c.r, g = c.g, b = c.b }
    local state = { wasMouseDown = false, wasEscapeDown = false }
    activeColorPicker = state
    local function changed()
        if activeColorPicker ~= state then return end
        local r, g, b = ColorPickerFrame:GetColorRGB()
        c.r, c.g, c.b = r, g, b
        onChange()
    end
    state.cancel = function()
        if activeColorPicker ~= state then return end
        activeColorPicker = nil
        c.r, c.g, c.b = prev.r, prev.g, prev.b
        onChange()
        if ColorPickerFrame and ColorPickerFrame:IsShown() then ColorPickerFrame:Hide() end
    end

    if type(UISpecialFrames) == "table" then
        local registered = false
        for _, frameName in ipairs(UISpecialFrames) do
            if frameName == "ColorPickerFrame" then registered = true; break end
        end
        if not registered then tinsert(UISpecialFrames, "ColorPickerFrame") end
    end
    local function cancelled() state.cancel() end

    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = c.r, g = c.g, b = c.b, hasOpacity = false,
            swatchFunc = changed, cancelFunc = cancelled,
        })
    else
        ColorPickerFrame.hasOpacity = false
        ColorPickerFrame.func = changed
        ColorPickerFrame.cancelFunc = cancelled
        ColorPickerFrame.previousValues = prev
        ColorPickerFrame:SetColorRGB(c.r, c.g, c.b)
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
    end
end

local function AddSwatch(page, y, text, getColor, lx, sx, onPick)
    lx, sx = lx or 10, sx or 140
    local fs = Label(page, text, 12)
    fs:SetPoint("TOPLEFT", page, "TOPLEFT", lx, y - 4)

    local b = CreateFrame("Button", nil, page)
    b:SetSize(44, 20)
    b:SetPoint("TOPLEFT", page, "TOPLEFT", sx, y)
    b:SetFrameLevel(page:GetFrameLevel() + 6) -- always above a checkbox row sharing the line
    Outline(b, 0.40, 0.42, 0.50, 1)
    local tex = b:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("TOPLEFT", 1, -1)
    tex:SetPoint("BOTTOMRIGHT", -1, 1)
    tex:SetTexture(WHITE)

    local function refresh()
        local c = getColor()
        tex:SetVertexColor(c.r, c.g, c.b, 1)
    end
    b:SetScript("OnClick", function()
        OpenColorPicker(getColor(), function()
            db.preset = nil -- manual edit: no preset is active anymore
            if onPick then onPick() end
            RefreshAll()
            Apply()
        end)
    end)
    b:SetScript("OnEnter", function() tex:SetAlpha(0.8) end)
    b:SetScript("OnLeave", function() tex:SetAlpha(1) end)
    Register(refresh)
    return b
end

local function ApplyPreset(pr)
    db.gradLow, db.gradMid, db.gradHigh = Hex(pr.g[1]), Hex(pr.g[2]), Hex(pr.g[3])
    do -- max-health color: the high color, lightened a bit
        local h = db.gradHigh
        db.gradMax = { r = h.r + (1 - h.r) * 0.3, g = h.g + (1 - h.g) * 0.3, b = h.b + (1 - h.b) * 0.3 }
    end
    db.classColor = false
    db.healthGradient = true
    db.healthColor = Hex(pr.g[3])
    db.powerColors = { MANA = Hex(pr.p[1]), RAGE = Hex(pr.p[2]), ENERGY = Hex(pr.p[3]), FOCUS = Hex(pr.p[4]) }
    db.comboColor, db.comboMaxColor = Hex(pr.c[1]), Hex(pr.c[2])
    db.castColor, db.channelColor = Hex(pr.c[1]), Hex(pr.p[1])
    db.bgColor, db.borderColor, db.textColor = Hex(pr.bg), Hex(pr.bd), Hex(pr.tx)
    db.preset = pr.name
    RefreshAll()
    Apply()
end

local function AddPresetGrid(page, y)
    local cols, bw, bh, gx, gy = 3, 108, 26, 6, 4
    for i, pr in ipairs(PRESETS) do
        local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
        local b = CreateFrame("Button", nil, page)
        b:SetSize(bw, bh)
        b:SetPoint("TOPLEFT", page, "TOPLEFT", col * (bw + gx), y - row * (bh + gy))

        local frameTex = Flat(b, 0, 0, 0, 1)
        local lo, mid, hi = Hex(pr.g[1]), Hex(pr.g[2]), Hex(pr.g[3])
        local half = (bw - 4) / 2
        local t1 = b:CreateTexture(nil, "ARTWORK")
        t1:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
        t1:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 2, 2)
        t1:SetWidth(half)
        SetGrad(t1, lo, mid)
        local t2 = b:CreateTexture(nil, "ARTWORK")
        t2:SetPoint("TOPRIGHT", b, "TOPRIGHT", -2, -2)
        t2:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
        t2:SetWidth(half)
        SetGrad(t2, mid, hi)

        local fs = b:CreateFontString(nil, "OVERLAY")
        fs:SetFont(FONT, 10, "OUTLINE")
        fs:SetTextColor(1, 1, 1, 1)
        fs:SetText(pr.name)
        fs:SetPoint("CENTER", b, "CENTER", 0, 0)

        b:SetScript("OnClick", function() ApplyPreset(pr) end)
        b:SetScript("OnEnter", function() t1:SetAlpha(0.85); t2:SetAlpha(0.85) end)
        b:SetScript("OnLeave", function() t1:SetAlpha(1); t2:SetAlpha(1) end)

        Register(function()
            if db.preset == pr.name then
                frameTex:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            else
                frameTex:SetVertexColor(0, 0, 0, 1)
            end
        end)
    end
    return y - math.ceil(#PRESETS / cols) * (bh + gy)
end

do -- tracker module (own scope: keeps the main chunk under Lua's 200 locals limit)
------------------------------------------------------------
-- Tracker: custom cooldown / buff / debuff / item icon groups.
-- Replaces the Blizzard Cooldown Manager (which can be hidden) with groups you design yourself.
-- Written for the "secret values" rules of the modern client: cooldowns and auras are handed
-- to the Cooldown widget as game-made duration objects, and only values that are never secret
-- (isActive, auraInstanceID, maxCharges...) are used to make decisions.
------------------------------------------------------------
local MAX_GROUPS, MAX_ENTRIES = 6, 24
TrackerMaxGroups = MAX_GROUPS
local KIND_INFO = {
    cooldown = { label = "Cooldown", color = { 0.25, 0.75, 1.00 } },
    buff     = { label = "Buff",     color = { 0.35, 0.90, 0.50 } },
    debuff   = { label = "Debuff",   color = { 0.95, 0.38, 0.38 } },
    item     = { label = "Item",     color = { 1.00, 0.76, 0.22 } },
    trinket  = { label = "Trinket",  color = { 1.00, 0.76, 0.22 } },
}
local KIND_ORDER = { "cooldown", "buff", "item" } -- kinds you can add by typing
local KIND_NAMES = { "Cooldown (spell)", "Buff", "Item" }
local GROW_NAMES = { "Right", "Left", "Centered" }
local GROW_ANCHOR = { "TOPLEFT", "TOPRIGHT", "TOP" }
local ROW_NAMES = { "Down", "Up" }
local CDMODE_NAMES = { "Always", "Only on cooldown", "Only when ready" }
local BUFFMODE_NAMES = { "Only when active", "Always (dimmed)" }
local QUESTION_MARK = 134400
local CDM_VIEWERS = { "EssentialCooldownViewer", "UtilityCooldownViewer", "BuffIconCooldownViewer", "BuffBarCooldownViewer" }

local function Num(v, lo, hi, dflt)
    if type(v) ~= "number" or v ~= v then return dflt end
    return math.max(lo, math.min(hi, v))
end

local function NewGroup(index, name)
    local sw = UIParent:GetWidth() or 1920
    local sh = UIParent:GetHeight() or 1080
    local groupName = (name or ""):lower()
    local isBuffGroup = groupName == "buff" or groupName == "buffs"
    local isEssential = groupName == "essential"
    return {
        name = name or ("Group " .. index), enabled = true, protected = false, userCreated = false,
        essentialMode = 1, formIndex = 1, essentialTrigger = "normal", -- normal or a named stance/form override
        size = 31, spacing = 2, perRow = isBuffGroup and 4 or 10, grow = 3,
        rowGrow = (isBuffGroup or isEssential) and 2 or 1, cdMode = 1, buffMode = 1,
        barWidth = 180, barHeight = 18,
        barBgColor = { r = 0.03, g = 0.03, b = 0.05 },
        showTimer = true, showStacks = true, desaturate = true, glow = true, combatOnly = false, rangeRed = true, pulseStyle = 1, pulseColorMode = "default",
        autoDebuffs = false, -- show every one of your own debuffs on the target as a timer bar
        x = sw / 2, y = sh / 2 - 120 - (index - 1) * 56,
        entries = {},
    }
end

-- validation used by share codes: only known fields, known types, safe ranges
local function CleanEntry(e)
    if type(e) == "table" and e.kind == "debuff" then
        local bar = e.bar
        if bar == nil then bar = true end
        e = { kind = "buff", id = e.id, name = e.name, bar = bar, color = e.color, showDuration = e.showDuration, durationSize = e.durationSize, pulseColorMode = e.pulseColorMode, pulseColor = e.pulseColor } -- harmful auras default to bars
    end
    if type(e) ~= "table" or not KIND_INFO[e.kind] then return nil end
    local out = { kind = e.kind }
    if type(e.id) == "number" and e.id >= 1 and e.id <= 99999999 then out.id = math.floor(e.id) end
    if e.proc == true and e.kind == "cooldown" then out.proc = true end
    if type(e.showDuration) == "boolean" then out.showDuration = e.showDuration end
    if type(e.durationSize) == "number" then out.durationSize = math.floor(Num(e.durationSize, 6, 32, 14)) end
    if e.pulseColorMode == "default" or e.pulseColorMode == "class" or e.pulseColorMode == "custom" then out.pulseColorMode = e.pulseColorMode end
    if type(e.pulseColor) == "table" then
        out.pulseColor = { r = Num(e.pulseColor.r, 0, 1, 1), g = Num(e.pulseColor.g, 0, 1, 209 / 255), b = Num(e.pulseColor.b, 0, 1, 51 / 255) }
    end
    if type(e.name) == "string" and e.name ~= "" then out.name = e.name:sub(1, 40) end
    if e.kind == "trinket" then
        out.slot = (e.slot == 14) and 14 or 13
        return out
    end
    if not out.id and not out.name then return nil end
    if (e.bar == true or e.bar == false) and (e.kind == "buff" or e.kind == "debuff") then out.bar = e.bar end -- shown as a bar, with an explicit icon override
    if out.bar and type(e.color) == "table" then
        out.color = { r = Num(e.color.r, 0, 1, 0), g = Num(e.color.g, 0, 1, 0), b = Num(e.color.b, 0, 1, 0) }
    end
    return out
end

local function CleanGroup(src, index)
    if type(src) ~= "table" then return nil end
    local g = NewGroup(index)
    g.name = (type(src.name) == "string" and src.name ~= "") and src.name:sub(1, 24) or g.name
    if type(src.importKey) == "string" then g.importKey = src.importKey end
    local normalizedName = (g.name or ""):lower()
    local builtInName = normalizedName == "essential" or normalizedName == "utility" or normalizedName == "buff" or normalizedName == "buffs"
    -- Older saved groups may predate the userCreated flag. Any unprotected
    -- custom group after the three built-ins should remain deletable.
    g.userCreated = src.userCreated == true or (index > 3 and src.protected ~= true and not builtInName and g.importKey == nil)
    g.protected = src.protected == true or (not g.userCreated and (index <= 3 or builtInName or g.importKey == "Essential" or g.importKey == "Utility" or g.importKey == "Buffs"))
    if type(src.essentialMode) == "number" then g.essentialMode = math.floor(Num(src.essentialMode, 1, 3, 1)) end
    if type(src.formIndex) == "number" then g.formIndex = math.floor(Num(src.formIndex, 1, 20, 1)) end
    local validTriggers = { normal=true, bear=true, cat=true, balance=true, defensive=true, berserker=true }
    if type(src.essentialTrigger) == "string" and validTriggers[src.essentialTrigger] then g.essentialTrigger = src.essentialTrigger end
    for _, k in ipairs({ "enabled", "showTimer", "showStacks", "desaturate", "glow", "combatOnly", "autoDebuffs", "rangeRed", "barsFree" }) do
        if type(src[k]) == "boolean" then g[k] = src[k] end
    end
    g.size = math.floor(Num(src.size, 20, 80, g.size))
    g.spacing = math.floor(Num(src.spacing, 0, 20, g.spacing))
    local buffGroup = normalizedName == "buff" or normalizedName == "buffs"
    local essentialGroup = normalizedName == "essential"
    g.perRow = math.floor(Num(src.perRow, 1, 24, buffGroup and 4 or 10))
    g.grow = math.floor(Num(src.grow, 1, 3, g.grow))
    g.rowGrow = math.floor(Num(src.rowGrow, 1, 2, (buffGroup or essentialGroup) and 2 or 1))
    g.cdMode = math.floor(Num(src.cdMode, 1, 3, g.cdMode))
    g.buffMode = math.floor(Num(src.buffMode, 1, 2, g.buffMode))
    g.pulseStyle = math.floor(Num(src.pulseStyle, 1, #NS.PULSE_NAMES, 1))
    if src.pulseColorMode == "default" or src.pulseColorMode == "class" or src.pulseColorMode == "custom" then g.pulseColorMode = src.pulseColorMode end
    for _, k in ipairs({ "barBgColor", "pulseColor" }) do
        local c = src[k]
        if type(c) == "table" then g[k] = { r = Num(c.r, 0, 1, 0), g = Num(c.g, 0, 1, 0), b = Num(c.b, 0, 1, 0) } end
    end
    if type(src.bx) == "number" and type(src.by) == "number" then
        g.bx, g.by = Num(src.bx, -2000, 10000, 0), Num(src.by, -2000, 10000, 0)
    else
        g.barsFree = false
    end
    if type(src.x) == "number" then g.x = Num(src.x, -2000, 10000, g.x) end
    if type(src.y) == "number" then g.y = Num(src.y, -2000, 10000, g.y) end
    g.barWidth = math.floor(Num(src.barWidth, 60, 400, g.barWidth))
    g.barHeight = math.floor(Num(src.barHeight, 8, 40, g.barHeight))
    if type(src.entries) == "table" then
        for i = 1, math.min(#src.entries, MAX_ENTRIES) do
            local e = CleanEntry(src.entries[i])
            if e then g.entries[#g.entries + 1] = e end
        end
    end
    if src.buffStyle == 2 then -- old share codes: the whole group showed buffs / debuffs as bars
        for _, e in ipairs(g.entries) do
            if e.kind == "buff" or e.kind == "debuff" then e.bar = true end
        end
    end
    return g
end

-- the color of a group's bars (created from the defaults when the group does not have one yet)
function NS.BarColor(g, key)
    local c = g[key]
    if type(c) ~= "table" then
        local d = (key == "pulseColor") and { 1, 209 / 255, 51 / 255 } or { 0.03, 0.03, 0.05 }
        c = { r = d[1], g = d[2], b = d[3] }
        g[key] = c
    end
    return c
end

-- groups saved with "Buffs / debuffs as Bars" become per-entry bars
function NS.MigrateGroup(g)
    if g.buffStyle == 2 then
        for _, e in ipairs(g.entries) do
            if e.kind == "buff" or e.kind == "debuff" then e.bar = true end
        end
    end
    g.buffStyle = nil
end

CleanTracker = function(src)
    if type(src) ~= "table" then return nil end
    local out = { enabled = src.enabled ~= false, hideBlizzard = src.hideBlizzard ~= false, groups = {}, starterInitialized = true }
    if type(src.ownerIdentity) == "string" and #src.ownerIdentity < 80 then out.ownerIdentity = src.ownerIdentity end
    if type(src.editorScale) == "number" then out.editorScale = Num(src.editorScale, 0.6, 1.5, 0.75) end
    if type(src.procSpells) == "table" then
        out.procSpells = {}
        for _, id in ipairs(src.procSpells) do
            if type(id) == "number" and id >= 1 and id <= 99999999 then out.procSpells[math.floor(id)] = true end
        end
    end
    if type(src.groups) == "table" then
        for i = 1, math.min(#src.groups, MAX_GROUPS) do
            local g = CleanGroup(src.groups[i], #out.groups + 1)
            if g then out.groups[#out.groups + 1] = g end
        end
    end
    return out
end

------------------------------------------------------------
-- Spell / item helpers (with fallbacks for older clients)
------------------------------------------------------------
local function SpellNameByID(id)
    if not id then return nil end
    if C_Spell and C_Spell.GetSpellName then
        local n = C_Spell.GetSpellName(id)
        if n then return n end
    end
    if GetSpellInfo then
        local n = GetSpellInfo(id)
        if type(n) == "string" then return n end
    end
    return nil
end

local function EntryName(e)
    if e.name then return e.name end
    if e.kind == "trinket" then return "Trinket " .. (e.slot == 14 and "2" or "1") end
    if e.kind == "item" then
        local n = e.id and ((C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(e.id)) or (GetItemInfo and GetItemInfo(e.id)))
        return n or ("Item " .. tostring(e.id))
    end
    return SpellNameByID(e.id) or ("Spell " .. tostring(e.id))
end

local function EntryTexture(e)
    if e.kind == "item" then
        local t = e.id and ((C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(e.id)) or (GetItemIcon and GetItemIcon(e.id)))
        return t or QUESTION_MARK
    elseif e.kind == "trinket" then
        return (GetInventoryItemTexture and GetInventoryItemTexture("player", e.slot)) or QUESTION_MARK
    end
    if e.id and C_Spell and C_Spell.GetSpellTexture then
        local t = C_Spell.GetSpellTexture(e.id)
        if t then return t end
    end
    if e.name and C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, e.name)
        if ok and type(info) == "table" and info.iconID then return info.iconID end
    end
    return QUESTION_MARK
end

local function IsSpellAvailable(id)
    if not id then return true end
    local known
    if IsPlayerSpell then known = IsPlayerSpell(id) end
    if not known and C_SpellBook and C_SpellBook.IsSpellKnown then known = C_SpellBook.IsSpellKnown(id) end
    if not known and IsSpellKnown then known = IsSpellKnown(id) end
    if known == nil then return true end
    return known and true or false
end

------------------------------------------------------------
-- Icon widget
------------------------------------------------------------
local cdFonts = {}
local function CountdownFont(size)
    local name = "SenBarTrackerFont" .. size
    if not cdFonts[name] then
        if not CreateFont then return nil end
        local f = CreateFont(name)
        f:SetFont(FONT, size, "OUTLINE")
        cdFonts[name] = true
    end
    return name
end

-- soft pulse around an icon or bar (spell ready / aura gained)
local function MakePulse(top, anchor)
    local glow = CreateFrame("Frame", nil, top)
    glow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -3, 3)
    glow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 3, -3)
    glow.edges = {}
    for i = 1, 4 do
        local t = glow:CreateTexture(nil, "OVERLAY")
        t:SetTexture(WHITE)
        glow.edges[i] = t
    end
    glow.edges[1]:SetPoint("TOPLEFT"); glow.edges[1]:SetPoint("TOPRIGHT"); glow.edges[1]:SetHeight(2)
    glow.edges[2]:SetPoint("BOTTOMLEFT"); glow.edges[2]:SetPoint("BOTTOMRIGHT"); glow.edges[2]:SetHeight(2)
    glow.edges[3]:SetPoint("TOPLEFT"); glow.edges[3]:SetPoint("BOTTOMLEFT"); glow.edges[3]:SetWidth(2)
    glow.edges[4]:SetPoint("TOPRIGHT"); glow.edges[4]:SetPoint("BOTTOMRIGHT"); glow.edges[4]:SetWidth(2)
    pcall(function()
        local ag = glow:CreateAnimationGroup()
        ag:SetLooping("BOUNCE")
        local a = ag:CreateAnimation("Alpha")
        a:SetFromAlpha(1)
        a:SetToAlpha(0.3)
        a:SetDuration(0.55)
        glow.anim = ag
    end)
    glow:Hide()
    return glow
end

local function MakeTrackerIcon(parent)
    local ic = CreateFrame("Frame", nil, parent)

    -- Clean, edge-to-edge spell art: no decorative frame or inset border.
    ic.bg = ic:CreateTexture(nil, "BACKGROUND")
    ic.bg:SetAllPoints()
    ic.bg:SetTexture(WHITE)
    ic.bg:SetVertexColor(0.025, 0.03, 0.045, 1)

    ic.icon = ic:CreateTexture(nil, "ARTWORK")
    ic.icon:SetAllPoints(ic)
    ic.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)

    local ok, cd = pcall(CreateFrame, "Cooldown", nil, ic, "CooldownFrameTemplate")
    if not ok or not cd then cd = CreateFrame("Cooldown", nil, ic) end
    cd:SetAllPoints(ic.icon)
    if cd.SetDrawEdge then pcall(cd.SetDrawEdge, cd, false) end
    if cd.SetSwipeColor then pcall(cd.SetSwipeColor, cd, 0, 0, 0, 0.72) end
    if cd.SetHideCountdownNumbers then pcall(cd.SetHideCountdownNumbers, cd, false) end
    ic.cd = cd

    local top = CreateFrame("Frame", nil, ic)
    top:SetAllPoints()
    top:SetFrameLevel(cd:GetFrameLevel() + 2)
    -- No permanent outline around spell icons.
    ic.edges = {}

    ic.count = top:CreateFontString(nil, "OVERLAY")
    ic.count:SetFont(FONT, 14, "OUTLINE")
    ic.count:SetPoint("BOTTOMRIGHT", top, "BOTTOMRIGHT", -2, 2)

    ic.glow = MakePulse(top, ic)
    return ic
end

local function StyleTrackerIcon(ic, g, e)
    ic:SetSize(g.size, g.size)
    local c = KIND_INFO[e.kind].color
    for _, t in ipairs(ic.edges) do t:SetVertexColor(c[1], c[2], c[3], 0.95) end
    for _, t in ipairs(ic.glow.edges) do t:SetVertexColor(c[1], c[2], c[3], 1) end
    ic.count:SetFont(FONT, math.max(9, math.floor(g.size * 0.36)), "OUTLINE")
    local cdFont = CountdownFont(e.durationSize or math.max(9, math.floor(g.size * 0.42)))
    if cdFont and ic.cd.SetCountdownFont then pcall(ic.cd.SetCountdownFont, ic.cd, cdFont) end
    if ic.cd.SetHideCountdownNumbers then pcall(ic.cd.SetHideCountdownNumbers, ic.cd, not g.showTimer) end
    -- spells: the dark sweep drains away. buffs / debuffs: the opposite, it fills the icon up as time runs out
    if ic.cd.SetReverse then pcall(ic.cd.SetReverse, ic.cd, e.kind == "buff" or e.kind == "debuff") end
    ic.tex = nil
end

-- a buff / debuff drawn as a bar: icon, draining fill, name, stacks and the countdown number
local function MakeTrackerBar(parent)
    local b = CreateFrame("Frame", nil, parent)
    b.isBar = true
    b.bg = b:CreateTexture(nil, "BACKGROUND")
    b.bg:SetAllPoints()
    b.bg:SetTexture(WHITE)
    b.bg:SetVertexColor(0.025, 0.03, 0.045, 1)

    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
    b.icon:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 0, 0)
    b.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)

    b.sb = CreateFrame("StatusBar", nil, b)
    -- Blizzard's shaded status-bar texture gives the timer fill more depth than a flat white strip.
    b.sb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    b.sb:SetMinMaxValues(0, 1)
    b.sb:SetValue(1)
    b.sb:SetPoint("TOPLEFT", b.icon, "TOPRIGHT", 1, 0)
    b.sb:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)

    b.sheen = b:CreateTexture(nil, "ARTWORK")
    b.sheen:SetTexture(WHITE)
    b.sheen:SetPoint("TOPLEFT", b.sb, "TOPLEFT", 0, 0)
    b.sheen:SetPoint("TOPRIGHT", b.sb, "TOPRIGHT", 0, 0)
    b.sheen:SetHeight(1)
    b.sheen:SetVertexColor(1, 1, 1, 0.10)
    b.shade = b:CreateTexture(nil, "ARTWORK")
    b.shade:SetTexture(WHITE)
    b.shade:SetPoint("BOTTOMLEFT", b.sb, "BOTTOMLEFT", 0, 0)
    b.shade:SetPoint("BOTTOMRIGHT", b.sb, "BOTTOMRIGHT", 0, 0)
    b.shade:SetHeight(2)
    b.shade:SetVertexColor(0, 0, 0, 0.18)

    -- the Cooldown widget draws no swirl here: it only receives the game-made timer and shows the number
    local ok, cd = pcall(CreateFrame, "Cooldown", nil, b.sb, "CooldownFrameTemplate")
    if not ok or not cd then cd = CreateFrame("Cooldown", nil, b.sb) end
    cd:SetPoint("TOPRIGHT", b.sb, "TOPRIGHT", -2, 0)
    cd:SetPoint("BOTTOMRIGHT", b.sb, "BOTTOMRIGHT", -2, 0)
    cd:SetWidth(46)
    if cd.SetDrawSwipe then pcall(cd.SetDrawSwipe, cd, false) end
    if cd.SetDrawEdge then pcall(cd.SetDrawEdge, cd, false) end
    if cd.SetDrawBling then pcall(cd.SetDrawBling, cd, false) end
    if cd.SetHideCountdownNumbers then pcall(cd.SetHideCountdownNumbers, cd, false) end
    b.cd = cd

    local top = CreateFrame("Frame", nil, b)
    top:SetAllPoints()
    top:SetFrameLevel(cd:GetFrameLevel() + 2)
    -- Keep the bar clean and borderless; contrast comes from the dark track and shaded fill.
    b.edges = {}
    b.count = top:CreateFontString(nil, "OVERLAY")
    b.count:SetFont(FONT, 12, "OUTLINE")
    b.count:SetPoint("RIGHT", cd, "LEFT", -2, 0)
    b.name = top:CreateFontString(nil, "OVERLAY")
    b.name:SetFont(FONT, 12, "OUTLINE")
    b.name:SetPoint("LEFT", b.sb, "LEFT", 5, 0)
    b.name:SetPoint("RIGHT", b.count, "LEFT", -4, 0)
    b.name:SetJustifyH("LEFT")
    if b.name.SetWordWrap then b.name:SetWordWrap(false) end
    b.glow = MakePulse(top, b)
    return b
end

local function StyleTrackerBar(b, g, e)
    local w, h = g.barWidth or 180, g.barHeight or 18
    b:SetSize(w, h)
    b.icon:SetWidth(math.max(h - 2, 4))
    local c = e.color
    if type(c) ~= "table" or type(c.r) ~= "number" then
        c = { r = 0.35, g = 0.90, b = 0.50 }
    end
    b.sb:SetStatusBarColor(c.r, c.g, c.b, 0.9)
    for _, t in ipairs(b.edges) do t:SetVertexColor(c.r, c.g, c.b, 0.95) end
    for _, t in ipairs(b.glow.edges) do t:SetVertexColor(c.r, c.g, c.b, 1) end
    local bg = NS.BarColor(g, "barBgColor")
    b.bg:SetVertexColor(bg.r, bg.g, bg.b, 1)
    local fs = math.max(9, math.floor(h * 0.55))
    b.name:SetFont(FONT, fs, "OUTLINE")
    b.count:SetFont(FONT, fs, "OUTLINE")
    b.name:SetText(EntryName(e))
    local cdFont = CountdownFont(e.durationSize or fs)
    if cdFont and b.cd.SetCountdownFont then pcall(b.cd.SetCountdownFont, b.cd, cdFont) end
    if b.cd.SetHideCountdownNumbers then pcall(b.cd.SetHideCountdownNumbers, b.cd, not g.showTimer) end
    b.tex = nil
end

-- fill of a buff bar: time left / total when the numbers are readable, the game's own timer otherwise
local function UpdateBarFill(b, present, now)
    local sb = b.sb
    if not present then sb:SetValue(0) return end
    if b.auraExp and b.auraDur and b.auraDur > 0 then
        sb:SetValue(math.max(0, math.min(1, (b.auraExp - now) / b.auraDur)))
    elseif b.auraObj and sb.SetTimerDuration then
        local interp = Enum and Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.Immediate
        local dir = Enum and Enum.StatusBarTimerDirection and Enum.StatusBarTimerDirection.RemainingTime
        if not pcall(sb.SetTimerDuration, sb, b.auraObj, interp, dir) then pcall(sb.SetTimerDuration, sb, b.auraObj) end
    else
        sb:SetValue(1) -- permanent aura, or no timer available: full bar
    end
end

------------------------------------------------------------
-- Reading the game state, one function per kind. Each returns:
--   present  : is there something to show right now (aura up, spell known...)
--   onCD     : "stable" cooldown flag (true only after 1.7s, so the global cooldown never counts)
------------------------------------------------------------
local function SetCountText(ic, g, value)
    if g.showStacks and value ~= nil then ic.count:SetText(value) else ic.count:SetText("") end
end

local function ReadCooldownSpell(ic, e, g, dt)
    local id = e.id
    local present = IsSpellAvailable(id)
    local info = C_Spell and C_Spell.GetSpellCooldown and C_Spell.GetSpellCooldown(id)
    if not info and GetSpellCooldown then
        local s, d = GetSpellCooldown(id)
        if s then info = { startTime = s, duration = d } end
    end

    local active = false
    local charges = C_Spell and C_Spell.GetSpellCharges and C_Spell.GetSpellCharges(id)
    local hasCharges = false
    if type(charges) == "table" and type(charges.maxCharges) == "number" and not IsSecret(charges.maxCharges) and charges.maxCharges > 1 then
        hasCharges = true
        SetCountText(ic, g, charges.currentCharges)
    else
        ic.count:SetText("")
    end

    if type(info) == "table" then
        local a = info.isActive
        if a ~= nil and not IsSecret(a) then
            active = a and true or false
        elseif not IsSecret(info.startTime) and not IsSecret(info.duration) and type(info.duration) == "number" then
            active = info.duration > 1.6 and (info.startTime or 0) > 0 and ((info.startTime + info.duration) - GetTime()) > 0
        end
        if info.isOnGCD == true then active = false end
        if not IsSecret(info.duration) and type(info.duration) == "number" and info.duration <= 1.6 then active = false end
    end

    local set = false
    if C_Spell and C_Spell.GetSpellCooldownDuration and ic.cd.SetCooldownFromDurationObject then
        local d
        if hasCharges and C_Spell.GetSpellChargeDuration then
            d = C_Spell.GetSpellChargeDuration(id)
        else
            d = C_Spell.GetSpellCooldownDuration(id, true)
        end
        if d then
            ic.cd:SetCooldownFromDurationObject(d, true)
            set = true
        end
    end
    if not set then
        if type(info) == "table" and not IsSecret(info.startTime) and not IsSecret(info.duration)
            and type(info.duration) == "number" and info.duration > 1.6 and (info.startTime or 0) > 0 then
            ic.cd:SetCooldown(info.startTime, info.duration)
        else
            ic.cd:Clear()
        end
    end
    return present, active, hasCharges
end

local function TryCall(fn, ...)
    local ok, a = pcall(fn, ...)
    if ok and type(a) == "table" then return a end
    return nil
end

-- several ways to find the aura, because a debuff's id is often not the id of the spell that cast it
local function FindAura(unit, e)
    local filter = (unit == "player") and "HELPFUL" or "HARMFUL|PLAYER"
    local name = e.name or SpellNameByID(e.id)
    local aura
    if C_UnitAuras then
        if e.id then
            if unit == "player" and C_UnitAuras.GetPlayerAuraBySpellID then
                aura = TryCall(C_UnitAuras.GetPlayerAuraBySpellID, e.id)
            elseif C_UnitAuras.GetUnitAuraBySpellID then
                aura = TryCall(C_UnitAuras.GetUnitAuraBySpellID, unit, e.id)
            end
        end
        if not aura and name and C_UnitAuras.GetAuraDataBySpellName then
            aura = TryCall(C_UnitAuras.GetAuraDataBySpellName, unit, name, filter)
            if not aura and unit ~= "player" then
                aura = TryCall(C_UnitAuras.GetAuraDataBySpellName, unit, name, "HARMFUL") -- owner is checked below
            end
        end
        if not aura and C_UnitAuras.GetAuraDataByIndex then
            for i = 1, 60 do
                local a = TryCall(C_UnitAuras.GetAuraDataByIndex, unit, i, filter)
                if not a then break end
                local sid, nm = a.spellId, a.name
                if (e.id and not IsSecret(sid) and sid == e.id) or (name and not IsSecret(nm) and nm == name) then
                    aura = a
                    break
                end
            end
        end
    end
    if not aura and name and AuraUtil and AuraUtil.FindAuraByName then
        pcall(function()
            local n, icon, count, _, dur, exp, _, _, _, sid = AuraUtil.FindAuraByName(name, unit, filter)
            if n then aura = { name = n, icon = icon, applications = count, duration = dur, expirationTime = exp, spellId = sid } end
        end)
    end
    if aura and unit ~= "player" then
        local mine = aura.isFromPlayerOrPlayerPet
        if mine ~= nil and not IsSecret(mine) and mine == false then aura = nil end -- only your own debuffs
    end
    return aura
end

------------------------------------------------------------
-- Estimated timers. In combat the game hides every aura from addons, so a buff on you or a debuff on the
-- target cannot be read. SenBar then counts the time itself: your cast of the spell starts a timer for its
-- duration. Out of combat the real aura is read as usual (and its duration is remembered for later).
--   buff on you      : starts when you cast the spell (not when you cast it on someone else)
--   debuff on target : starts when you cast it on an enemy, clears when you change target or it dies
-- Duration: typed with /sb dur > remembered from the real aura > guessed from the spell text.
-- Kept in the NS table (this chunk is at Lua's limit of 200 locals).
------------------------------------------------------------
NS.Est = { active = {}, parsed = {} }

function NS.Est.Plain(fn, ...)
    local ok, v = pcall(fn, ...)
    if not ok or v == nil or IsSecret(v) then return nil end
    return v
end

function NS.Est.SpellId(e)
    if e.id then return e.id end
    local name = e.name
    if name and C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, name)
        if ok and type(info) == "table" and type(info.spellID) == "number" then return info.spellID end
    end
    return nil
end

function NS.Est.Key(e)
    local id = NS.Est.SpellId(e)
    if id then return tostring(id) end
    return e.name and ("n:" .. e.name:lower()) or nil
end

-- true when the game refuses to give aura data to addons right now (in combat)
function NS.Est.Restricted(unit)
    -- on a hostile target the aura call may not raise an error in combat: it just returns hidden values
    if InCombatLockdown and InCombatLockdown() then return true end
    if UnitAffectingCombat and UnitAffectingCombat("player") then return true end
    if not (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then return false end
    local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, unit, 1, (unit == "player") and "HELPFUL" or "HARMFUL|PLAYER")
    if not ok then return true end
    if type(a) == "table" and (IsSecret(a.name) or IsSecret(a.spellId) or IsSecret(a.duration)) then return true end
    return false
end

-- last resort: read the duration out of the spell text ("... over 12 sec.", "for 1 hour")
function NS.Est.Parse(id)
    if not id then return nil end
    local cache = NS.Est.parsed
    if cache[id] ~= nil then return cache[id] or nil end
    local text
    if C_Spell and C_Spell.GetSpellDescription then
        local ok, t = pcall(C_Spell.GetSpellDescription, id)
        if ok and type(t) == "string" and not IsSecret(t) and t ~= "" then text = t:lower() end
    end
    if not text then return nil end -- text not loaded yet: try again later
    local d = false
    local n = text:match("over (%d+%.?%d*) sec") or text:match("for (%d+%.?%d*) sec") or text:match("lasts? (%d+%.?%d*) sec")
    if n then
        d = tonumber(n) or false
    else
        n = text:match("for (%d+%.?%d*) min") or text:match("over (%d+%.?%d*) min") or text:match("lasts? (%d+%.?%d*) min")
        if n then
            d = (tonumber(n) or 0) * 60
        else
            n = text:match("(%d+%.?%d*) |?4?hour") or text:match("(%d+%.?%d*) hr")
            if n then d = (tonumber(n) or 0) * 3600 end
        end
    end
    if d and d <= 0 then d = false end
    cache[id] = d
    return d or nil
end

function NS.Est.Duration(e)
    local key = NS.Est.Key(e)
    if not key then return nil end
    local m = db.durationsManual and db.durationsManual[key]
    if type(m) == "number" and m > 0 then return m end
    local l = db.durations and db.durations[key]
    if type(l) == "number" and l > 0 then return l end
    return NS.Est.Parse(NS.Est.SpellId(e))
end

-- remember the real duration when the game lets us read it
function NS.Est.Learn(e, dur)
    local key = NS.Est.Key(e)
    if not key or type(dur) ~= "number" or dur <= 0 then return end
    db.durations = db.durations or {}
    local old = db.durations[key]
    if old and dur > old * 1.25 then return end -- a refresh that added time is not the base duration
    if old ~= dur then db.durations[key] = dur end
end

function NS.Est.Matches(e, spellID, castName)
    if e.id and e.id == spellID then return true end
    local n = e.name or SpellNameByID(e.id)
    return n ~= nil and castName ~= nil and n == castName
end

function NS.Est.OnCast(spellID)
    if not (db and db.tracker and db.tracker.enabled) then return end
    if type(spellID) ~= "number" or IsSecret(spellID) then return end
    local castName = SpellNameByID(spellID)
    local now = GetTime()
    for _, g in ipairs(db.tracker.groups) do
        for _, e in ipairs(g.entries) do
            if (e.kind == "buff" or e.kind == "debuff") and NS.Est.Matches(e, spellID, castName) then
                local ok = true
                if e.kind == "debuff" then
                    if not UnitExists("target") then
                        ok = false
                    elseif NS.Est.Plain(UnitCanAttack, "player", "target") == false then
                        ok = false -- a friendly target: this was not a debuff on an enemy
                    end
                elseif UnitExists("target") then
                    -- a buff cast on another friendly player is not on you
                    if NS.Est.Plain(UnitIsUnit, "target", "player") == false and NS.Est.Plain(UnitCanAssist, "player", "target") == true then
                        ok = false
                    end
                end
                local key = ok and NS.Est.Key(e)
                local dur = key and NS.Est.Duration(e)
                if key and dur then
                    NS.Est.active[e.kind .. ":" .. key] = { exp = now + dur, dur = dur }
                end
            end
        end
    end
end

function NS.Est.Read(ic, e, unit)
    local kind = (unit == "player") and "buff" or "debuff"
    local key = NS.Est.Key(e)
    local id = key and (kind .. ":" .. key)
    local s = id and NS.Est.active[id]
    if not s then return false end
    if s.exp <= GetTime() or (kind == "debuff" and NS.Est.Plain(UnitIsDead, "target") == true) then
        NS.Est.active[id] = nil
        return false
    end
    ic.auraDur, ic.auraExp, ic.auraObj = s.dur, s.exp, nil
    ic.cd:SetCooldown(s.exp - s.dur, s.dur)
    ic.count:SetText("")
    return true
end

NS.Est.frame = CreateFrame("Frame")
NS.Est.frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
NS.Est.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
NS.Est.frame:RegisterEvent("PLAYER_DEAD")
NS.Est.frame:SetScript("OnEvent", function(_, event, _, _, spellID)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        NS.Est.OnCast(spellID)
    elseif event == "PLAYER_TARGET_CHANGED" then
        for k in pairs(NS.Est.active) do
            if k:sub(1, 7) == "debuff:" then NS.Est.active[k] = nil end
        end
    else
        wipe(NS.Est.active)
    end
end)

-- /sb dur                      : list known durations
-- /sb dur <spell name or id> <seconds>   : set one by hand    (… clear : forget the typed one)
function NS.Est.Command(args)
    local function say(...) print("|cff40bfffSenBar|r", ...) end
    local function label(key)
        local id = tonumber(key)
        return id and (SpellNameByID(id) or ("Spell " .. key)) or key:gsub("^n:", "")
    end
    args = (args or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if args == "" then
        local any = false
        for _, which in ipairs({ { "durationsManual", "typed" }, { "durations", "remembered" } }) do
            for key, v in pairs(db[which[1]] or {}) do
                any = true
                say(label(key), "-", v, "sec (" .. which[2] .. ")")
            end
        end
        if not any then say("no durations yet. Usage: /sb dur <spell name or id> <seconds>   or   /sb dur <spell> clear") end
        return
    end
    local spell, last = args:match("^(.-)%s+(%S+)$")
    if not spell then
        say("usage: /sb dur <spell name or id> <seconds>   or   /sb dur <spell> clear")
        return
    end
    local id = tonumber(spell)
    if not id and C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, spell)
        if ok and type(info) == "table" then id = info.spellID end
    end
    local key = id and tostring(id) or ("n:" .. spell)
    db.durationsManual = db.durationsManual or {}
    if last == "clear" then
        db.durationsManual[key] = nil
        say("typed duration removed for", label(key))
        return
    end
    local secs = tonumber(last)
    if not secs or secs <= 0 then
        say("the duration must be a number of seconds, for example: /sb dur moonfire 16")
        return
    end
    db.durationsManual[key] = secs
    say(label(key), "is now", secs, "sec")
end

local function ReadAura(ic, e, g, unit)
    ic.auraDur, ic.auraExp, ic.auraObj = nil, nil, nil
    if unit == "target" and not UnitExists("target") then
        ic.cd:Clear()
        ic.count:SetText("")
        return false, false
    end
    local aura = FindAura(unit, e)
    if not aura then
        -- in combat the game hides auras: show SenBar's own timer from your cast instead
        if NS.Est.Restricted(unit) and NS.Est.Read(ic, e, unit) then return true, false end
        ic.cd:Clear()
        ic.count:SetText("")
        return false, false
    end
    local iid = aura.auraInstanceID
    if aura.icon then pcall(ic.icon.SetTexture, ic.icon, aura.icon) end

    local set = false
    if iid and C_UnitAuras and C_UnitAuras.GetAuraDuration and ic.cd.SetCooldownFromDurationObject then
        local ok, d = pcall(C_UnitAuras.GetAuraDuration, unit, iid)
        if ok and d then
            set = pcall(ic.cd.SetCooldownFromDurationObject, ic.cd, d, true) and true or false
            if set then ic.auraObj = d end
        end
    end
    local dur, exp = aura.duration, aura.expirationTime
    local readable = type(dur) == "number" and type(exp) == "number" and not IsSecret(dur) and not IsSecret(exp)
    if readable and dur > 0 then
        ic.auraDur, ic.auraExp = dur, exp
        NS.Est.Learn(e, dur)
        if not set then
            ic.cd:SetCooldown(exp - dur, dur)
            set = true
        end
    end
    if not set and not readable and ic.cd.SetCooldownFromExpirationTime then
        -- hidden numbers and no timer object: the game accepts them in this call
        set = pcall(ic.cd.SetCooldownFromExpirationTime, ic.cd, exp, dur) and true or false
    end
    if not set then
        -- the aura is there but its time is hidden: use SenBar's own timer from your cast
        if NS.Est.Read(ic, e, unit) then return true, false end
        ic.cd:Clear()
    end

    if g.showStacks then
        if iid and C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
            local ok, txt = pcall(C_UnitAuras.GetAuraApplicationDisplayCount, unit, iid, 2)
            ic.count:SetText(ok and txt or "")
        else
            local n = aura.applications
            if type(n) == "number" and not IsSecret(n) and n > 1 then ic.count:SetText(n) else ic.count:SetText("") end
        end
    else
        ic.count:SetText("")
    end
    return true, false
end

local function ReadItem(ic, e, g)
    local start, dur
    local itemID = e.id
    if e.kind == "trinket" then
        itemID = GetInventoryItemID and GetInventoryItemID("player", e.slot)
        if not itemID then
            ic.cd:Clear()
            ic.count:SetText("")
            return false, false
        end
        if GetInventoryItemCooldown then start, dur = GetInventoryItemCooldown("player", e.slot) end
        ic.count:SetText("")
    else
        if C_Item and C_Item.GetItemCooldown then
            start, dur = C_Item.GetItemCooldown(itemID)
        elseif GetItemCooldown then
            start, dur = GetItemCooldown(itemID)
        end
        local n = C_Item and C_Item.GetItemCount and C_Item.GetItemCount(itemID)
        if g.showStacks and type(n) == "number" and n > 1 then ic.count:SetText(n) else ic.count:SetText("") end
        if C_Item and C_Item.GetItemCount and n == 0 then
            ic.cd:Clear()
            return false, false
        end
    end

    local active = false
    if not IsSecret(start) and not IsSecret(dur) then
        if type(start) == "number" and type(dur) == "number" and dur > 1.6 and start > 0 then
            ic.cd:SetCooldown(start, dur)
            active = true
        else
            ic.cd:Clear()
        end
    else
        pcall(ic.cd.SetCooldown, ic.cd, start, dur) -- the game accepts hidden numbers here
    end
    return true, active
end

------------------------------------------------------------
-- Update one icon; returns whether it should be shown
------------------------------------------------------------
-- red tint when the target is out of range of this spell (only spells that have a range)
function NS.SpellOutOfRange(id)
    if not id or not UnitExists("target") then return false end
    if C_Spell and C_Spell.SpellHasRange then
        local okH, has = pcall(C_Spell.SpellHasRange, id)
        if okH and not IsSecret(has) and has == false then return false end
    end
    if C_Spell and C_Spell.IsSpellInRange then
        local ok, r = pcall(C_Spell.IsSpellInRange, id, "target")
        if ok and not IsSecret(r) and r == false then return true end
        return false
    end
    if IsSpellInRange then
        local nm = SpellNameByID(id)
        if nm then
            local ok, r = pcall(IsSpellInRange, nm, "target")
            if ok and not IsSecret(r) and r == 0 then return true end
        end
    end
    return false
end

-- spell proc (the game's "spell activation overlay"); a spell seen procing once is remembered as a proc spell
function NS.SpellProcced(id)
    if not id then return false end
    if C_SpellActivationOverlay and C_SpellActivationOverlay.IsSpellOverlayed then
        local ok, r = pcall(C_SpellActivationOverlay.IsSpellOverlayed, id)
        if ok and not IsSecret(r) then return r and true or false end
    elseif IsSpellOverlayed then
        local ok, r = pcall(IsSpellOverlayed, id)
        if ok and not IsSecret(r) then return r and true or false end
    end
    return false
end

-- reactive spells (Mongoose Bite, Riposte, Overpower, Revenge...): not a glow overlay, the game just
-- makes them usable. "Usable" counts even when you lack the mana / energy, only the condition matters.
function NS.SpellConditionMet(id)
    local ok, u, np
    if C_Spell and C_Spell.IsSpellUsable then
        ok, u, np = pcall(C_Spell.IsSpellUsable, id)
    elseif IsUsableSpell then
        ok, u, np = pcall(IsUsableSpell, id)
    end
    if not ok or IsSecret(u) or IsSecret(np) then return nil end
    if u == nil and np == nil then return nil end
    return ((u or np) and true) or false
end

NS.PROC_GOLD = { 1, 0.82, 0.18 }
-- animated effects, drawn with plain textures (no files): a pulsing halo, a breathing border, sparks that
-- run around the icon edge, or a flash. Used by the proc glow and by the "pulse when ready / gained" styles.
NS.GLOW = { comets = 4, trail = 8, period = 1.6 }
NS.PULSE_NAMES = { "Border pulse", "Soft glow", "Running sparks", "Flash" }
-- pulses play once (dur seconds); the proc glow loops for as long as the proc lasts
NS.PULSE_OPTS = {
    { edges = true, dur = 1.0 },
    { halo = true, dur = 1.1 },
    { dots = true, edges = true, edgeStatic = true, dur = 1.2 },
    { flash = true, dur = 0.6 },
}
NS.PulsePreview = {} -- [group] = time until which the pulse is shown as a preview in the editor

function NS.NewFx(ic, opts)
    local G = NS.GLOW
    local fx = CreateFrame("Frame", nil, ic.glow:GetParent())
    fx:SetAllPoints(ic)
    fx.ic, fx.t = ic, 0
    if opts.halo then
        -- square icons: the game's glow ring texture. wide bars: a few soft outlines around the bar instead
        fx.halo = fx:CreateTexture(nil, "OVERLAY")
        fx.halo:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        fx.halo:SetBlendMode("ADD")
        fx.layers = {}
        for k = 1, 4 do
            local L = {}
            for i = 1, 4 do
                local t = fx:CreateTexture(nil, "OVERLAY")
                t:SetTexture(WHITE)
                t:SetBlendMode("ADD")
                L[i] = t
            end
            local o = k * 2
            L[1]:SetPoint("TOPLEFT", ic, "TOPLEFT", -o, o);        L[1]:SetPoint("TOPRIGHT", ic, "TOPRIGHT", o, o);        L[1]:SetHeight(2)
            L[2]:SetPoint("BOTTOMLEFT", ic, "BOTTOMLEFT", -o, -o); L[2]:SetPoint("BOTTOMRIGHT", ic, "BOTTOMRIGHT", o, -o); L[2]:SetHeight(2)
            L[3]:SetPoint("TOPLEFT", ic, "TOPLEFT", -o, o);        L[3]:SetPoint("BOTTOMLEFT", ic, "BOTTOMLEFT", -o, -o);  L[3]:SetWidth(2)
            L[4]:SetPoint("TOPRIGHT", ic, "TOPRIGHT", o, o);       L[4]:SetPoint("BOTTOMRIGHT", ic, "BOTTOMRIGHT", o, -o); L[4]:SetWidth(2)
            fx.layers[k] = L
        end
    end
    if opts.edges then
        fx.edges = {}
        for i = 1, 4 do
            local t = fx:CreateTexture(nil, "OVERLAY")
            t:SetTexture(WHITE)
            fx.edges[i] = t
        end
        fx.edges[1]:SetPoint("TOPLEFT"); fx.edges[1]:SetPoint("TOPRIGHT")
        fx.edges[2]:SetPoint("BOTTOMLEFT"); fx.edges[2]:SetPoint("BOTTOMRIGHT")
        fx.edges[3]:SetPoint("TOPLEFT"); fx.edges[3]:SetPoint("BOTTOMLEFT")
        fx.edges[4]:SetPoint("TOPRIGHT"); fx.edges[4]:SetPoint("BOTTOMRIGHT")
    end
    if opts.dots then
        fx.dots = {}
        for i = 1, G.comets * G.trail do
            local d = fx:CreateTexture(nil, "OVERLAY", nil, 2)
            d:SetTexture(WHITE)
            d:SetBlendMode("ADD")
            fx.dots[i] = d
        end
    end
    if opts.flash then
        fx.flash = fx:CreateTexture(nil, "OVERLAY")
        fx.flash:SetAllPoints()
        fx.flash:SetTexture(WHITE)
        fx.flash:SetBlendMode("ADD")
    end
    fx:SetScript("OnUpdate", function(self, dt)
        self.t = self.t + dt
        local loop = opts.loop
        local dur = opts.dur or 1
        if not loop and self.t >= dur then self:Hide() return end
        local pulse = 0.5 + 0.5 * math.sin(self.t * 5.5)
        local bell = loop and (0.45 + 0.55 * pulse) or math.sin(math.pi * self.t / dur) -- 0 -> 1 -> 0 once
        if self.dots then
            local w, h = self.w or 40, self.h or 40
            local P = 2 * (w + h)
            local phase = loop and ((self.t / G.period) % 1) or (self.t / dur)
            local fade = loop and 1 or math.max(0, math.min(1, (dur - self.t) / 0.35))
            local stepU = (self.dotSize or 4) * 0.7 / P
            for ci = 1, G.comets do
                local base = (phase + (ci - 1) / G.comets) % 1
                for di = 1, G.trail do
                    local u = (base - (di - 1) * stepU) % 1
                    local dist = u * P
                    local x, y
                    if dist < w then x, y = dist, 0
                    elseif dist < w + h then x, y = w, -(dist - w)
                    elseif dist < 2 * w + h then x, y = w - (dist - w - h), -h
                    else x, y = 0, -(h - (dist - 2 * w - h)) end
                    local d = self.dots[(ci - 1) * G.trail + di]
                    d:ClearAllPoints()
                    d:SetPoint("CENTER", self.ic, "TOPLEFT", x, y)
                    d:SetAlpha((1 - (di - 1) / G.trail) * fade)
                end
            end
        end
        if self.halo then
            if self.wide then
                local base = { 0.55, 0.35, 0.2, 0.1 }
                for k = 1, 4 do
                    for i = 1, 4 do self.layers[k][i]:SetAlpha(base[k] * bell) end
                end
            else
                self.halo:SetAlpha(bell)
            end
        end
        if self.edges then
            local a
            if opts.edgeStatic then a = loop and 0.6 or 0.6 * math.max(0, math.min(1, (dur - self.t) / 0.35))
            else a = loop and (0.55 + 0.45 * pulse) or bell end
            for i = 1, 4 do self.edges[i]:SetAlpha(a) end
        end
        if self.flash then
            self.flash:SetAlpha(loop and (0.7 * (1 - ((self.t % 0.55) / 0.55))) or (0.7 * (1 - self.t / dur)))
        end
    end)
    function fx:SetFxColor(r, g, b)
        self.cr, self.cg, self.cb = r, g, b
        if self.halo then
            self.halo:SetVertexColor(r, g, b, 1)
            for k = 1, 4 do for i = 1, 4 do self.layers[k][i]:SetVertexColor(r, g, b, 1) end end
        end
        if self.edges then
            for i = 1, 4 do self.edges[i]:SetVertexColor(r + (1 - r) * 0.2, g + (1 - g) * 0.2, b + (1 - b) * 0.2, 1) end
        end
        if self.dots then
            for _, d in ipairs(self.dots) do d:SetVertexColor(r + (1 - r) * 0.45, g + (1 - g) * 0.45, b + (1 - b) * 0.45, 1) end
        end
        if self.flash then self.flash:SetVertexColor(r, g, b, 1) end
    end
    -- sizes follow the shape: icons are square, bars are long and thin, so everything is based on the short side
    function fx:Resize(w, h)
        if self.w == w and self.h == h then return end
        self.w, self.h = w, h
        local m = math.min(w, h)
        self.wide = (w / h) > 1.6
        if self.halo then
            local pad = m * 0.34
            self.halo:ClearAllPoints()
            self.halo:SetPoint("TOPLEFT", self.ic, "TOPLEFT", -pad, pad)
            self.halo:SetPoint("BOTTOMRIGHT", self.ic, "BOTTOMRIGHT", pad, -pad)
            self.halo:SetShown(not self.wide)
            for k = 1, 4 do for i = 1, 4 do self.layers[k][i]:SetShown(self.wide) end end
        end
        if self.edges then
            local t = math.max(2, math.min(4, math.floor(m / 16 + 0.5)))
            self.edges[1]:SetHeight(t); self.edges[2]:SetHeight(t)
            self.edges[3]:SetWidth(t); self.edges[4]:SetWidth(t)
        end
        if self.dots then
            local ds = math.max(3, math.min(6, math.floor(m / 9 + 0.5)))
            self.dotSize = ds
            for _, d in ipairs(self.dots) do d:SetSize(ds, ds) end
        end
    end
    fx:SetFxColor(1, 0.82, 0.2)
    fx:Hide()
    return fx
end

function NS.EnsureProcGlow(ic)
    local fx = ic.procGlow
    if not fx then
        fx = NS.NewFx(ic, { halo = true, edges = true, dots = true, loop = true })
        fx:SetFxColor(NS.PROC_GOLD[1], NS.PROC_GOLD[2], NS.PROC_GOLD[3])
        ic.procGlow = fx
    end
    fx:Resize(ic:GetWidth() or 40, ic:GetHeight() or 40)
    return fx
end

-- the chosen "pulse when ready / gained" style, in the chosen colour
function NS.GetPulseFx(ic, style, r, g, b)
    ic.pulseFx = ic.pulseFx or {}
    local fx = ic.pulseFx[style]
    if not fx then
        fx = NS.NewFx(ic, NS.PULSE_OPTS[style] or NS.PULSE_OPTS[1])
        ic.pulseFx[style] = fx
    end
    fx:Resize(ic:GetWidth() or 40, ic:GetHeight() or 40)
    if fx.cr ~= r or fx.cg ~= g or fx.cb ~= b then fx:SetFxColor(r, g, b) end
    return fx
end

local function UpdateEntry(ic, e, g, dt, now, editing)
    if ic.cd and ic.cd.SetHideCountdownNumbers then
        pcall(ic.cd.SetHideCountdownNumbers, ic.cd, not (e.showDuration == nil and g.showTimer or e.showDuration == true))
    end
    local tex = EntryTexture(e)
    if ic.tex ~= tex then
        ic.tex = tex
        ic.icon:SetTexture(tex)
    end

    local present, onCD, hasCharges
    if e.kind == "cooldown" then
        present, onCD, hasCharges = ReadCooldownSpell(ic, e, g, dt)
    elseif e.kind == "buff" then
        present = ReadAura(ic, e, g, "player")
    elseif e.kind == "debuff" then
        present = ReadAura(ic, e, g, "target")
    else
        present, onCD = ReadItem(ic, e, g)
    end
    if ic.isBar then UpdateBarFill(ic, present, now) end

    -- stable cooldown flag: ignores the 1.5s global cooldown
    if onCD then ic.activeFor = (ic.activeFor or 0) + dt else ic.activeFor = 0 end
    local stable = (ic.activeFor or 0) >= 1.7

    -- pulse when a long cooldown ends, or when a buff / debuff appears
    local kind = e.kind
    if kind == "buff" or kind == "debuff" then
        if present and not ic.wasPresent and ic.seen then ic.glowUntil = now + 1.6 end
        ic.wasPresent = present
    else
        if ic.wasStable and not stable then ic.glowUntil = now + 1.6 end
        ic.wasStable = stable
    end
    ic.seen = true

    local visible = true
    local dim = false
    if kind == "buff" or kind == "debuff" then
        if not present then
            if g.buffMode == 1 then visible = false else dim = true end
        end
    else
        if not present then
            visible = false
        elseif g.cdMode == 2 then
            visible = stable
        elseif g.cdMode == 3 then
            visible = not stable
        end
    end

    if editing and not visible then visible = true; dim = true end

    -- procs: grey until the spell procs, then full colour with a gold outline
    local procOn, procKnown = false, false
    if kind == "cooldown" and e.id then
        db.tracker.procSpells = db.tracker.procSpells or {}
        procOn = NS.SpellProcced(e.id)
        if procOn then db.tracker.procSpells[e.id] = true end
        procKnown = (e.proc == true) or (db.tracker.procSpells[e.id] and true or false)
        if e.proc == true and not procOn and not stable and NS.SpellConditionMet(e.id) == true then
            procOn = true -- reactive spell: usable now
        end
    end
    local procGrey = procKnown and not procOn and not editing

    ic.icon:SetDesaturated((g.desaturate and kind ~= "buff" and kind ~= "debuff" and stable and not hasCharges) or (dim and not present) or procGrey)
    ic:SetAlpha(dim and 0.45 or 1)

    -- out of range: red tint
    if g.rangeRed ~= false and kind == "cooldown" and not procGrey and NS.SpellOutOfRange(e.id) then
        ic.icon:SetVertexColor(1, 0.25, 0.25, 1)
    else
        ic.icon:SetVertexColor(1, 1, 1, 1)
    end

    if procOn then
        local pg = NS.EnsureProcGlow(ic)
        if not pg:IsShown() then
            pg:Show()
        end
    elseif ic.procGlow and ic.procGlow:IsShown() then
        ic.procGlow:Hide()
    end

    local pv = NS.PulsePreview[g]
    local glowOn = g.glow and ((ic.glowUntil and now < ic.glowUntil) or (pv and now < pv))
    if glowOn then
        local style = g.pulseStyle or 1
        local pc = e.pulseColor or g.pulseColor
        local r, gg, b
        local mode = e.pulseColorMode or g.pulseColorMode or "default"
        if mode == "custom" and type(pc) == "table" then
            r, gg, b = pc.r, pc.g, pc.b
        elseif mode == "class" then
            local _, classToken = UnitClass("player")
            local cc = classToken and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
            if cc then r, gg, b = cc.r, cc.g, cc.b else local kc = KIND_INFO[e.kind].color; r, gg, b = kc[1], kc[2], kc[3] end
        else
            r, gg, b = 1, 209 / 255, 51 / 255
        end
        local fx = NS.GetPulseFx(ic, style, r, gg, b)
        if ic.activeFx and ic.activeFx ~= fx then ic.activeFx:Hide() end
        -- one trigger (a new ready / gained event, or a new preview) plays the effect exactly once
        local token = (pv and now < pv) and pv or ic.glowUntil
        if ic.fxToken ~= token or ic.fxStyle ~= style then
            ic.fxToken, ic.fxStyle = token, style
            fx.t = 0
            fx:Show()
        end
        ic.activeFx = fx
    elseif ic.activeFx then
        ic.activeFx:Hide()
        ic.activeFx = nil
    end
    return visible
end

------------------------------------------------------------
-- Groups: frames, layout, dragging
------------------------------------------------------------
local tgroups = {}
NS.TrackerGroups = tgroups -- read-only view, used by the tests
local tdrag
local trackerDriver, trackerEditor, trackerPicker
local hiddenViewers = {}
local TrackerSel = 1

local function TEditing()
    return (db and not db.locked) or (trackerEditor and trackerEditor:IsShown()) or false
end

local function PlaceBars(g, gf)
    local bf = gf.barFrame
    if not bf then return end
    bf:ClearAllPoints()
    if g.barsFree and g.bx and g.by then
        bf:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", g.bx, g.by)
    else
        local name = (g.importKey or g.name or ""):lower()
        local buff = name == "buff" or name == "buffs"
        local top = (buff or g.grow == 1) and "TOPLEFT" or ((g.grow == 2) and "TOPRIGHT" or "TOP")
        local bottom = (buff or g.grow == 1) and "BOTTOMLEFT" or ((g.grow == 2) and "BOTTOMRIGHT" or "BOTTOM")
        if buff then
            -- Screenshot layout: bars left of icons, one icon row lower.
            bf:SetPoint("TOPRIGHT", gf.frame, "TOPLEFT", -12, -((g.size or 31) + (g.spacing or 2)))
        elseif (gf.nIcons or 0) > 0 then
            bf:SetPoint(top, gf.frame, bottom, 0, -(g.spacing or 4))
        else
            bf:SetPoint(top, gf.frame, top, 0, 0)
        end
    end
end

local function PlaceGroup(g, gf)
    gf.frame:ClearAllPoints()
    gf.frame:SetPoint(GROW_ANCHOR[g.grow] or "TOP", UIParent, "BOTTOMLEFT", g.x, g.y)
    PlaceBars(g, gf)
end

local function EnsureGroupFrame(i)
    local gf = tgroups[i]
    if gf then return gf end
    gf = { icons = {}, bars = {} }
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetFrameStrata("LOW")
    f:SetClampedToScreen(true)
    gf.frame = f
    gf.overlay = f:CreateTexture(nil, "BACKGROUND")
    gf.overlay:SetAllPoints()
    gf.overlay:SetTexture(WHITE)
    gf.overlay:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.14)
    gf.label = Label(f, "", 11, 0.6, 0.85, 1)
    gf.label:SetPoint("BOTTOM", f, "TOP", 0, 3)
    f:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" or not TEditing() then return end
        local g = db.tracker.groups[i]
        if not g then return end
        local cx, cy = GetCursorPosition()
        tdrag = { i = i, cx = cx, cy = cy, ox = g.x, oy = g.y }
    end)
    f:SetScript("OnMouseUp", function() tdrag = nil end)
    f:Hide()

    -- the bars live in their own frame so they can be moved apart from the icons
    local bf = CreateFrame("Frame", nil, UIParent)
    bf:SetFrameStrata("LOW")
    bf:SetClampedToScreen(true)
    bf:SetSize(180, 18)
    gf.barFrame = bf
    gf.barOverlay = bf:CreateTexture(nil, "BACKGROUND")
    gf.barOverlay:SetAllPoints()
    gf.barOverlay:SetTexture(WHITE)
    gf.barOverlay:SetVertexColor(0.95, 0.75, 0.2, 0.14)
    gf.barLabel = Label(bf, "", 11, 1, 0.82, 0.3)
    gf.barLabel:SetPoint("BOTTOM", bf, "TOP", 0, 3)
    bf:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" or not TEditing() then return end
        local g = db.tracker.groups[i]
        if not g then return end
        if not (g.barsFree and g.bx and g.by) then
            local l, t = self:GetLeft(), self:GetTop()
            if not l or not t then return end
            g.bx, g.by, g.barsFree = l, t, true
        end
        local cx, cy = GetCursorPosition()
        tdrag = { i = i, bars = true, cx = cx, cy = cy, ox = g.bx, oy = g.by }
    end)
    bf:SetScript("OnMouseUp", function() tdrag = nil end)
    bf:Hide()
    tgroups[i] = gf
    return gf
end

local function LayoutGroup(g, gf, vis, bars)
    local n, nb = #vis, #bars
    local size, sp, per = g.size, g.spacing, math.max(1, g.perRow)
    local barW, barH = g.barWidth or 180, g.barHeight or 18
    gf.nIcons, gf.nBars = n, nb
    if nb > 0 then
        gf.barFrame:SetSize(barW, nb * (barH + sp) - sp)
        for idx, b in ipairs(bars) do
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", gf.barFrame, "TOPLEFT", 0, -((idx - 1) * (barH + sp)))
        end
    end
    if n == 0 then
        gf.frame:SetSize(150, size)
        return
    end
    local cols, rows, gridW, gridH = 0, 0, 0, 0
    if n > 0 then
        cols, rows = math.min(n, per), math.ceil(n / per)
        gridW = math.max(cols * (size + sp) - sp, 1)
        gridH = math.max(rows * (size + sp) - sp, 1)
    end
    local W = math.max(gridW, 1)
    local H = math.max(gridH, 1)
    gf.frame:SetSize(W, H)
    for idx, ic in ipairs(vis) do
        local row, col = math.floor((idx - 1) / per), (idx - 1) % per
        local rowCount = (row < rows - 1) and per or (n - per * (rows - 1))
        local x
        if g.grow == 1 then
            x = col * (size + sp)
        elseif g.grow == 2 then
            x = W - size - col * (size + sp)
        else
            x = (W - (rowCount * (size + sp) - sp)) / 2 + col * (size + sp)
        end
        local y = (g.rowGrow == 2) and -(gridH - size - row * (size + sp)) or -row * (size + sp)
        ic:ClearAllPoints()
        ic:SetPoint("TOPLEFT", gf.frame, "TOPLEFT", x, y)
    end
end

local function AsBar(g, e)
    return e.bar == true and (e.kind == "buff" or e.kind == "debuff")
end

------------------------------------------------------------
-- Auto debuff bars: every debuff YOU have on the target gets a timer bar, no spell list needed.
-- Nothing is matched by name or ID (those can be hidden in combat). The game filters the list
-- ("HARMFUL|PLAYER") and hands over a timer object per aura, which drives the bar and the number.
------------------------------------------------------------
-- (kept in the NS table instead of locals: this chunk is at Lua's limit of 200 locals)
NS.Auto = { max = 12, entry = { kind = "debuff", name = "" } }

function NS.Auto.Collect()
    local list = {}
    if not (UnitExists("target") and C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then return list end
    for i = 1, 40 do
        local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, "target", i, "HARMFUL|PLAYER")
        if not ok or type(a) ~= "table" then break end
        list[#list + 1] = a
        if #list >= NS.Auto.max then break end
    end
    return list
end

function NS.Auto.Fill(b, g, aura, now)
    local iid = aura.auraInstanceID
    b.auraDur, b.auraExp, b.auraObj = nil, nil, nil
    if aura.icon then pcall(b.icon.SetTexture, b.icon, aura.icon) end
    pcall(b.name.SetText, b.name, aura.name or "")

    local set = false
    if iid and C_UnitAuras.GetAuraDuration and b.cd.SetCooldownFromDurationObject then
        local ok, d = pcall(C_UnitAuras.GetAuraDuration, "target", iid)
        if ok and d then
            set = pcall(b.cd.SetCooldownFromDurationObject, b.cd, d, true) and true or false
            if set then b.auraObj = d end
        end
    end
    local dur, exp = aura.duration, aura.expirationTime
    local readable = type(dur) == "number" and type(exp) == "number" and not IsSecret(dur) and not IsSecret(exp)
    if readable and dur > 0 then
        b.auraDur, b.auraExp = dur, exp
        if not set then
            b.cd:SetCooldown(exp - dur, dur)
            set = true
        end
    end
    if not set then b.cd:Clear() end

    if g.showStacks and iid and C_UnitAuras.GetAuraApplicationDisplayCount then
        local ok, txt = pcall(C_UnitAuras.GetAuraApplicationDisplayCount, "target", iid, 2)
        b.count:SetText(ok and txt or "")
    else
        b.count:SetText("")
    end

    if readable and dur <= 0 then
        b.sb:SetValue(1) -- aura without an end: full bar
    else
        UpdateBarFill(b, true, now)
    end
end

-- fills `bars` / `parts` with the auto bars of this group; returns how many are shown
function NS.Auto.Update(g, gf, bars, parts, now, editing)
    gf.auto = gf.auto or {}
    local pool = gf.auto
    local shown = 0
    if g.autoDebuffs then
        local list = NS.Auto.Collect()
        local preview = (#list == 0 and editing)
        local count = preview and 1 or #list
        local styleKey = (g.barWidth or 180) .. "x" .. (g.barHeight or 18) .. (g.showTimer and "t" or "n")
        for k = 1, count do
            local b = pool[k]
            if not b then
                b = MakeTrackerBar(gf.barFrame)
                pool[k] = b
            end
            if b.styleKey ~= styleKey then
                b.styleKey = styleKey
                StyleTrackerBar(b, g, NS.Auto.entry)
            end
            if preview then
                b.icon:SetTexture(QUESTION_MARK)
                b.name:SetText("Your debuffs on target")
                b.count:SetText("")
                b.cd:Clear()
                b.sb:SetValue(0.6)
            else
                NS.Auto.Fill(b, g, list[k], now)
            end
            b:SetAlpha(preview and 0.5 or 1)
            b:Show()
            bars[#bars + 1] = b
            parts[#parts + 1] = "a" .. k
            shown = shown + 1
        end
    end
    for k = shown + 1, #pool do pool[k]:Hide() end
    return shown
end

-- /sb auradump: what the auto bars see (run it with an enemy targeted, your DoTs on it)
function NS.Auto.Dump()
    local function say(...) print("|cff40bfffSenBar dump|r", ...) end
    local function K(v)
        if v == nil then return "nil" end
        if IsSecret(v) then return "SECRET" end
        return type(v) == "number" and string.format("%.4g", v) or tostring(v)
    end
    local T = db.tracker
    local gl = {}
    for _, g in ipairs(T.groups) do gl[#gl + 1] = g.name .. (g.autoDebuffs and "=auto ON" or "=auto off") end
    say("auto-bars code loaded | tracker enabled:", tostring(T.enabled), "| groups:", #gl > 0 and table.concat(gl, ", ") or "none")
    say("in combat:", tostring(UnitAffectingCombat("player")), "| target:", tostring(UnitExists("target")),
        "| GetAuraDataByIndex:", tostring(C_UnitAuras and C_UnitAuras.GetAuraDataByIndex ~= nil))
    if not (UnitExists("target") and C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then return end
    local function try(label, fn)
        local ok, r = pcall(fn)
        say(label, ok and tostring(r) or ("ERROR: " .. tostring(r)))
    end
    local F = "HARMFUL|PLAYER"
    try("target name readable:", function() local nm = UnitName("target"); return IsSecret(nm) and "SECRET" or tostring(nm) end)
    if C_UnitAuras.GetUnitAuraInstanceIDs then
        try("GetUnitAuraInstanceIDs:", function()
            local t = C_UnitAuras.GetUnitAuraInstanceIDs("target", F)
            return type(t) == "table" and (#t .. " id(s)") or type(t)
        end)
    else
        say("GetUnitAuraInstanceIDs: missing")
    end
    if C_UnitAuras.GetUnitAuras then
        try("GetUnitAuras:", function()
            local t = C_UnitAuras.GetUnitAuras("target", F)
            return type(t) == "table" and (#t .. " aura(s)") or type(t)
        end)
    else
        say("GetUnitAuras: missing")
    end
    if AuraUtil and AuraUtil.ForEachAura then
        try("AuraUtil.ForEachAura:", function()
            local c = 0
            AuraUtil.ForEachAura("target", F, nil, function() c = c + 1 end, true)
            return c .. " aura(s)"
        end)
    else
        say("AuraUtil.ForEachAura: missing")
    end
    try("legacy UnitAura(target, 1, HARMFUL):", function() return UnitAura and (UnitAura("target", 1, "HARMFUL") ~= nil) or "missing" end)
    for _, filter in ipairs({ "HARMFUL|PLAYER", "HARMFUL" }) do
        local n, err = 0, nil
        for i = 1, 40 do
            local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, "target", i, filter)
            if not ok then
                err = a
                break
            end
            if type(a) ~= "table" then break end
            n = n + 1
            if filter == "HARMFUL|PLAYER" and n <= 8 then
                local hasObj = false
                if a.auraInstanceID and C_UnitAuras.GetAuraDuration then
                    local ok2, d = pcall(C_UnitAuras.GetAuraDuration, "target", a.auraInstanceID)
                    hasObj = ok2 and d ~= nil
                end
                say(n .. ")", "name:", K(a.name), "| spell id:", K(a.spellId), "| duration:", K(a.duration),
                    "| instance id:", K(a.auraInstanceID), "| timer object:", tostring(hasObj))
            end
        end
        say(filter, "by index:", n, "aura(s)", err and ("| ERROR: " .. tostring(err)) or "")
    end
end

-- rebuild frames / icons / styles after any setting change
local function RebuildTracker()
    if not db or not db.tracker then return end
    local T = db.tracker
    for i, g in ipairs(T.groups) do
        if g.buffStyle ~= nil then NS.MigrateGroup(g) end
        for _, e in ipairs(g.entries) do
            if e.kind == "debuff" then e.kind = "buff" end -- everything in the buff list is a buff now
        end
        local gf = EnsureGroupFrame(i)
        PlaceGroup(g, gf)
        for j, e in ipairs(g.entries) do
            if AsBar(g, e) then
                local b = gf.bars[j]
                if not b then
                    b = MakeTrackerBar(gf.barFrame)
                    gf.bars[j] = b
                end
                StyleTrackerBar(b, g, e)
                if gf.icons[j] then gf.icons[j]:Hide() end
            else
                local ic = gf.icons[j]
                if not ic then
                    ic = MakeTrackerIcon(gf.frame)
                    gf.icons[j] = ic
                end
                StyleTrackerIcon(ic, g, e)
                if gf.bars[j] then gf.bars[j]:Hide() end
            end
        end
        -- Icon/bar pools are sparse because entries can switch display type.
        for j, icon in pairs(gf.icons) do
            if not g.entries[j] or AsBar(g, g.entries[j]) then icon:Hide() end
        end
        for j, bar in pairs(gf.bars) do
            if not g.entries[j] or not AsBar(g, g.entries[j]) then bar:Hide() end
        end
        gf.sig = nil
    end
    for i = #T.groups + 1, #tgroups do tgroups[i].frame:Hide(); tgroups[i].barFrame:Hide() end
    if not T.enabled then
        for _, gf in pairs(tgroups) do gf.frame:Hide(); gf.barFrame:Hide() end
    end
end

local function UpdateGroups(dt)
    local T = db.tracker
    -- a debuff entry (saved earlier, or loaded from a profile) is a buff now
    local converted = false
    for _, g in ipairs(T.groups) do
        for _, e in ipairs(g.entries) do
            if e.kind == "debuff" then e.kind = "buff"; converted = true end
        end
    end
    if converted then RebuildTracker() end
    local editing = TEditing()
    local now = GetTime()
    local inCombat = UnitAffectingCombat("player")
    local activeForm = (GetShapeshiftForm and GetShapeshiftForm()) or 0
    local activeFormName = ""
    if activeForm > 0 and GetShapeshiftFormInfo then
        local ok, _, _, _, spellID = pcall(GetShapeshiftFormInfo, activeForm)
        if ok and type(spellID) == "number" then activeFormName = (SpellNameByID(spellID) or ""):lower() end
    end
    local activeTrigger = "normal"
    if activeFormName:find("bear", 1, true) then activeTrigger = "bear"
    elseif activeFormName:find("cat", 1, true) then activeTrigger = "cat"
    elseif activeFormName:find("moonkin", 1, true) or activeFormName:find("balance", 1, true) then activeTrigger = "balance"
    elseif activeFormName:find("defensive", 1, true) or activeFormName:find("def stance", 1, true) then activeTrigger = "defensive"
    elseif activeFormName:find("berserker", 1, true) then activeTrigger = "berserker" end
    local matchingEssentialOverride = false
    for gi, candidate in ipairs(T.groups) do
        local isCore = candidate.protected == true or (gi <= 3 and candidate.userCreated ~= true)
            or candidate.importKey == "Essential" or candidate.importKey == "Utility" or candidate.importKey == "Buffs"
            or candidate.name == "Essential" or candidate.name == "Utility" or candidate.name == "Buff" or candidate.name == "Buffs"
        if not isCore and candidate.enabled and candidate.essentialTrigger and candidate.essentialTrigger ~= "normal" and candidate.essentialTrigger == activeTrigger then
            matchingEssentialOverride = true
            break
        end
    end
    for i, g in ipairs(T.groups) do
        local gf = tgroups[i]
        if g.buffStyle ~= nil then NS.MigrateGroup(g) end
        if gf then
            local essentialVisible = true
            if not editing then
                local isCore = g.protected == true or (i <= 3 and g.userCreated ~= true)
                    or g.importKey == "Essential" or g.importKey == "Utility" or g.importKey == "Buffs"
                    or g.name == "Essential" or g.name == "Utility" or g.name == "Buff" or g.name == "Buffs"
                if isCore and (g.importKey == "Essential" or g.name == "Essential" or i == 1) then
                    essentialVisible = not matchingEssentialOverride
                elseif not isCore and g.essentialTrigger and g.essentialTrigger ~= "normal" then
                    essentialVisible = g.essentialTrigger == activeTrigger
                end
            end
            local show = T.enabled and g.enabled and essentialVisible and (editing or not g.combatOnly or inCombat)
            if not show then
                gf.frame:Hide()
                gf.barFrame:Hide()
            else
                gf.frame:Show()
                -- Also clear removed slots when entries changed between rebuilds.
                for j, icon in pairs(gf.icons) do
                    if not g.entries[j] or AsBar(g, g.entries[j]) then icon:Hide() end
                end
                for j, bar in pairs(gf.bars) do
                    if not g.entries[j] or not AsBar(g, g.entries[j]) then bar:Hide() end
                end
                local vis, bars, parts = {}, {}, {}
                for j, e in ipairs(g.entries) do
                    local asBar = AsBar(g, e)
                    local w = asBar and gf.bars[j] or gf.icons[j]
                    local other = asBar and gf.icons[j] or gf.bars[j]
                    if other then other:Hide() end
                    if g.autoDebuffs and e.kind == "debuff" then
                        -- the auto bars already show every debuff of yours: no duplicate
                        if w then w:Hide() end
                    elseif w then
                        if UpdateEntry(w, e, g, dt, now, editing) then
                            w:Show()
                            if asBar then
                                bars[#bars + 1] = w
                                parts[#parts + 1] = "b" .. j
                            else
                                vis[#vis + 1] = w
                                parts[#parts + 1] = j
                            end
                        else
                            w:Hide()
                        end
                    end
                end
                NS.Auto.Update(g, gf, bars, parts, now, editing)
                local sig = table.concat(parts, ",") .. "|" .. g.size .. "|" .. g.spacing .. "|" .. g.perRow .. "|" .. g.grow .. "|" .. g.rowGrow
                    .. "|" .. (g.barWidth or 180) .. "|" .. (g.barHeight or 18) .. "|" .. tostring(g.barsFree) .. "|" .. tostring(g.bx) .. "|" .. tostring(g.by)
                if gf.sig ~= sig then
                    gf.sig = sig
                    LayoutGroup(g, gf, vis, bars)
                    PlaceGroup(g, gf)
                end
                gf.frame:EnableMouse(editing and true or false)
                if editing then
                    gf.overlay:Show()
                    gf.label:SetText(g.name .. "  (drag to move)")
                    gf.label:Show()
                else
                    gf.overlay:Hide()
                    gf.label:Hide()
                end
                local hasBars = (gf.nBars or 0) > 0 and #bars > 0
                gf.barFrame:SetShown(hasBars)
                gf.barFrame:EnableMouse(editing and hasBars and true or false)
                if editing and hasBars then
                    gf.barOverlay:Show()
                    gf.barLabel:SetText(g.name .. " bars  (drag to move)")
                    gf.barLabel:Show()
                else
                    gf.barOverlay:Hide()
                    gf.barLabel:Hide()
                end
            end
        end
    end
end

local function ApplyBlizzardCDM()
    local hide = db.tracker and db.tracker.enabled and db.tracker.hideBlizzard
    for _, name in ipairs(CDM_VIEWERS) do
        local f = _G[name]
        if f and f.SetAlpha then
            local hideThis = hide
            if hideThis then
                if f:GetAlpha() > 0 then f:SetAlpha(0) end
                hiddenViewers[name] = true
            elseif hiddenViewers[name] then
                f:SetAlpha(1)
                hiddenViewers[name] = nil
            end
        end
    end
end

TrackerApply = function()
    if not db or not db.tracker then return end
    RebuildTracker()
    ApplyBlizzardCDM()
end

StartTrackerDriver = function()
    if trackerDriver then return end
    trackerDriver = CreateFrame("Frame")
    local acc, cdmAcc = 0, 0
    trackerDriver:SetScript("OnUpdate", function(self, dt)
        if tdrag then
            if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
                tdrag = nil
            else
                local g = db.tracker.groups[tdrag.i]
                if g then
                    local cx, cy = GetCursorPosition()
                    local s = UIParent:GetEffectiveScale()
                    if tdrag.bars then
                        g.bx = tdrag.ox + (cx - tdrag.cx) / s
                        g.by = tdrag.oy + (cy - tdrag.cy) / s
                        PlaceBars(g, tgroups[tdrag.i])
                    else
                        g.x = tdrag.ox + (cx - tdrag.cx) / s
                        g.y = tdrag.oy + (cy - tdrag.cy) / s
                        PlaceGroup(g, tgroups[tdrag.i])
                    end
                end
            end
        end
        cdmAcc = cdmAcc + dt
        if cdmAcc >= 0.5 then
            cdmAcc = 0
            ApplyBlizzardCDM()
        end
        acc = acc + dt
        if acc < 0.1 then return end
        local step = acc
        acc = 0
        if db and db.tracker and db.tracker.enabled then UpdateGroups(step) end
    end)
end

------------------------------------------------------------
-- Adding entries
------------------------------------------------------------
local function CurGroup()
    local gs = db.tracker.groups
    return gs[TrackerSel or 1]
end

NS.IsHarmfulSpellID = function(id)
    if not id or not C_Spell or not C_Spell.IsSpellHarmful then return false end
    local ok, harmful = pcall(C_Spell.IsSpellHarmful, id)
    return ok and harmful == true
end

local function AddEntry(g, e)
    if #g.entries >= MAX_ENTRIES then return false, "This group is full (" .. MAX_ENTRIES .. " icons)." end
    if e.kind == "buff" and e.bar == nil and NS.IsHarmfulSpellID(e.id) then e.bar = true end
    for _, o in ipairs(g.entries) do
        if o.kind == e.kind and ((e.id and o.id == e.id) or (e.slot and o.slot == e.slot) or (not e.id and not e.slot and o.name == e.name)) then
            return false, "Already tracked in this group."
        end
    end
    g.entries[#g.entries + 1] = e
    TrackerApply()
    if TrackerRefreshUI then TrackerRefreshUI() end
    return true
end

local function ResolveText(kind, text)
    text = (text or ""):match("^%s*(.-)%s*$")
    if text == "" then return nil, "Type a spell name or an ID first." end
    local n = tonumber(text)
    if kind == "item" then
        local id = n
        if not id then
            local r = (C_Item and C_Item.GetItemInfoInstant and C_Item.GetItemInfoInstant(text)) or (GetItemInfoInstant and GetItemInfoInstant(text))
            id = r
        end
        if not id then return nil, "Item not found (use its ID, or have it in your bags)." end
        return { kind = "item", id = id, name = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id)) or (GetItemInfo and GetItemInfo(id)) or nil }
    end
    local id, name
    if n then
        id, name = n, SpellNameByID(n)
        if not name then return nil, "No spell with that ID." end
    elseif C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, text)
        if ok and type(info) == "table" then id, name = info.spellID, info.name end
    end
    if not id then
        if kind == "cooldown" then return nil, "Spell not found. Check the name, or use its ID." end
        name = text -- aura tracked by its exact name
    end
    return { kind = kind, id = id, name = name }
end

------------------------------------------------------------
-- Sources for the picker windows
------------------------------------------------------------
local function CollectSpellbook()
    local list, seen = {}, {}
    local function add(id)
        if not id or seen[id] then return end
        seen[id] = true
        local name = SpellNameByID(id)
        if not name or name:lower() == "attack" then return end
        local passive = (C_Spell and C_Spell.IsSpellPassive and C_Spell.IsSpellPassive(id)) or (IsPassiveSpell and IsPassiveSpell(id))
        if passive then return end
        -- Include every learned active spell, not only spells with a base cooldown.
        -- Buff/aura spells and reactive abilities often have no base cooldown.
        local icon = C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(id) or QUESTION_MARK
        list[#list + 1] = { id = id, name = name, icon = icon, kind = "cooldown" }
    end

    local done = pcall(function()
        if not (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and Enum and Enum.SpellBookSpellBank) then error("old") end
        for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
            local li = C_SpellBook.GetSpellBookSkillLineInfo(line)
            if li then
                for i = li.itemIndexOffset + 1, li.itemIndexOffset + li.numSpellBookItems do
                    local info = C_SpellBook.GetSpellBookItemInfo(i, Enum.SpellBookSpellBank.Player)
                    if info and info.spellID and not info.isPassive then add(info.spellID) end
                end
            end
        end
    end)
    if not done or #list == 0 then
        pcall(function()
            for tab = 1, GetNumSpellTabs() do
                local _, _, offset, num = GetSpellTabInfo(tab)
                for i = offset + 1, offset + num do
                    local t, id = GetSpellBookItemInfo(i, "spell")
                    if t == "SPELL" then add(id) end
                end
            end
        end)
    end
    -- several ranks of one spell: keep only the highest rank
    local function RankOf(id)
        local sub
        if C_Spell and C_Spell.GetSpellSubtext then sub = C_Spell.GetSpellSubtext(id)
        elseif GetSpellSubtext then sub = GetSpellSubtext(id) end
        if type(sub) == "string" then
            local n = tonumber(sub:match("(%d+)"))
            if n then return n end
        end
        return 0
    end
    local best, order = {}, {}
    for _, sp in ipairs(list) do
        local key = sp.name:lower()
        local r = RankOf(sp.id)
        local cur = best[key]
        if not cur then
            best[key] = { sp = sp, rank = r }
            order[#order + 1] = key
        elseif r > cur.rank or (r == cur.rank and sp.id > cur.sp.id) then
            best[key] = { sp = sp, rank = r }
        end
    end
    list = {}
    for _, key in ipairs(order) do list[#list + 1] = best[key].sp end
    table.sort(list, function(a, b) return a.name:lower() < b.name:lower() end)
    return list
end

local function CollectBuffs()
    local list, seen = {}, {}
    if not (C_UnitAuras and C_UnitAuras.GetAuraDataByIndex) then return list end
    for i = 1, 40 do
        local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
        if not ok or not a then break end
        if not IsSecret(a.spellId) and not IsSecret(a.name) and a.spellId and not seen[a.spellId] then
            seen[a.spellId] = true
            list[#list + 1] = { id = a.spellId, name = a.name, icon = a.icon or QUESTION_MARK, kind = "buff" }
        end
    end
    table.sort(list, function(a, b) return a.name:lower() < b.name:lower() end)
    return list
end

-- copy the setup of the Blizzard Cooldown Manager into groups. The first time it creates the groups;
-- every later time it only adds the spells that are missing from those groups (no new groups).
-- Everything from Blizzard's "tracked buffs" is imported as a Buff (that list also holds debuffs you put on the target).
local function ImportFromBlizzard(automatic)
    if not (C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCategorySet and C_CooldownViewer.GetCooldownViewerCooldownInfo
        and Enum and Enum.CooldownViewerCategory) then
        return nil, "The Blizzard Cooldown Manager is not available on this client."
    end
    local cat = Enum.CooldownViewerCategory
    local sets = {
        { "Essential", cat.Essential, "cooldown" },
        { "Utility", cat.Utility, "cooldown" },
        { "Buffs", cat.TrackedBuff, "buff" },
    }
    local T = db.tracker
    local res = { created = 0, updated = 0, added = 0, fixed = 0, found = 0, blocked = false }

    -- the group an earlier import made (marked), or one with that name (imports from before the mark existed)
    local function FindImportGroup(label)
        for i, g in ipairs(T.groups) do
            if g.importKey == label then return g, i end
        end
        for i, g in ipairs(T.groups) do
            if g.name == label then return g, i end
        end
    end

    for _, s in ipairs(sets) do
        local ok, ids = pcall(C_CooldownViewer.GetCooldownViewerCategorySet, s[2], false)
        if ok and type(ids) == "table" and #ids > 0 then
            res.found = res.found + 1
            local g, gi = FindImportGroup(s[1])
            local isNew = false
            if not g then
                if #T.groups < MAX_GROUPS then
                    g = NewGroup(#T.groups + 1, s[1])
                    g.size = (s[1] == "Essential") and 44 or 36
                    isNew = true
                else
                    res.blocked = true
                end
            end
            if g then
                g.importKey = s[1]
                g.protected = true
                g.userCreated = false
                if s[1] == "Essential" and (g.essentialMode == nil or g.essentialMode == 1) then g.essentialMode = 2 end
                local have, auraById = {}, {}
                for _, o in ipairs(g.entries) do
                    if o.id then
                        have[o.kind .. ":" .. o.id] = true
                        if o.kind == "buff" or o.kind == "debuff" then auraById[o.id] = o end
                    end
                end
                local n, fixedN = 0, 0
                for _, cid in ipairs(ids) do
                    local ok2, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cid)
                    if ok2 and type(info) == "table" then
                        local sid = info.overrideSpellID or info.spellID
                        if sid then
                            local kind = s[3]
                            local spellName = SpellNameByID(sid)
                            if (not spellName or spellName:lower() ~= "attack") and not have[kind .. ":" .. sid] and #g.entries < MAX_ENTRIES then
                                local entry = { kind = kind, id = sid, name = spellName }
                                if kind == "buff" and NS.IsHarmfulSpellID(sid) then entry.bar = true end
                                g.entries[#g.entries + 1] = entry
                                have[kind .. ":" .. sid] = true
                                if kind ~= "cooldown" then auraById[sid] = entry end
                                n = n + 1
                            end
                        end
                    end
                end
                if isNew then
                    if n > 0 then
                        T.groups[#T.groups + 1] = g
                        res.created = res.created + 1
                        res.added = res.added + n
                        res.last = #T.groups
                    end
                elseif n > 0 or fixedN > 0 then
                    res.updated = res.updated + 1
                    res.added = res.added + n
                    res.fixed = res.fixed + fixedN
                    res.last = gi
                end
            end
        end
    end
    if res.found == 0 then
        return nil, "Nothing to import: the Blizzard Cooldown Manager has no tracked spells."
    end
    if res.added > 0 or res.fixed > 0 then
        if not automatic then T.enabled = true end
        TrackerApply()
        if TrackerRefreshUI then TrackerRefreshUI() end
    end
    return res
end

-- Tracker ownership includes race so racial abilities cannot leak between alts.
NS.TrackerIdentity = function()
    return tostring(select(2, UnitClass("player"))) .. ":" .. tostring(select(2, UnitRace("player")))
end
NS.BindTracker = function()
    db.trackerByIdentity = db.trackerByIdentity or {}
    db.tracker.ownerIdentity = NS.TrackerIdentity()
    db.trackerByIdentity[NS.TrackerIdentity()] = db.tracker
end
NS.ValidateLegacyTracker = function(T, learned)
    if T.ownerIdentity then return T.ownerIdentity == NS.TrackerIdentity() end
    -- Old saves have no reliable owner: require their spellbook baseline to
    -- match this character before adopting them. Names allow rank upgrades.
    local ids, names = {}, {}
    for _, sp in ipairs(learned) do ids[sp.id] = true; names[sp.name] = true end
    local checked = false
    for id in pairs(T.autoKnownSpells or {}) do
        checked = true
        if not ids[id] and not names[SpellNameByID(id)] then return false end
    end
    if not checked then
        for _, g in ipairs(T.groups or {}) do
            for _, e in ipairs(g.entries or {}) do
                if e.kind == "cooldown" then
                    checked = true
                    if not ids[e.id] and not names[SpellNameByID(e.id)] then return false end
                end
            end
        end
    end
    return checked or #(T.groups or {}) == 0
end

NS.AutoImportCooldowns = function()
    if not db or not db.tracker then return end
    local T = db.tracker
    local learned = CollectSpellbook()
    if #learned == 0 then return end -- spellbook may not be ready at login
    if not T.ownerIdentity then
        if not NS.ValidateLegacyTracker(T, learned) then
            -- Keep the old data in trackerByClass/profiles; never relabel a
            -- different class's spells as belonging to this character.
            db.tracker = DeepCopy(defaults.tracker)
            T = db.tracker
        end
        NS.BindTracker()
    end
    local known, byID = {}, {}
    for _, sp in ipairs(learned) do known[sp.id] = true; byID[sp.id] = sp end
    local existing = false
    for _, g in ipairs(T.groups) do if #g.entries > 0 then existing = true end end
    local fresh = not T.starterInitialized and not existing
    local groups = {}
    for i, label in ipairs({ "Essential", "Utility", "Buffs" }) do
        for _, g in ipairs(T.groups) do
            local name = (g.name or ""):lower()
            if g.importKey == label or name == label:lower() or (label == "Buffs" and name == "buff") then groups[label] = g; break end
        end
        if not groups[label] and #T.groups < MAX_GROUPS then
            local g = NewGroup(i, label)
            table.insert(T.groups, math.min(i, #T.groups + 1), g)
            groups[label] = g
        end
        if groups[label] then
            groups[label].importKey, groups[label].protected, groups[label].userCreated = label, true, false
        end
    end
    local candidates = { Essential = {}, Utility = {}, Buffs = {}, Harmful = {} }
    local category, seen = {}, {}
    local function candidate(label, id, name)
        if not id or seen[label .. ":" .. id] or (name or ""):lower() == "attack" then return end
        seen[label .. ":" .. id] = true
        candidates[label][#candidates[label] + 1] = { id = id, name = name or SpellNameByID(id) }
        if label == "Essential" or label == "Utility" then category[id] = label end
    end
    -- Prefer Blizzard's own main/utility and tracked-aura categories.
    if C_CooldownViewer and C_CooldownViewer.GetCooldownViewerCategorySet and C_CooldownViewer.GetCooldownViewerCooldownInfo
        and Enum and Enum.CooldownViewerCategory then
        local cat = Enum.CooldownViewerCategory
        for _, spec in ipairs({ {"Essential", cat.Essential}, {"Utility", cat.Utility}, {"Buffs", cat.TrackedBuff} }) do
            if spec[2] then
                local ok, ids = pcall(C_CooldownViewer.GetCooldownViewerCategorySet, spec[2], false)
                if ok and type(ids) == "table" then
                    for _, cid in ipairs(ids) do
                        local good, info = pcall(C_CooldownViewer.GetCooldownViewerCooldownInfo, cid)
                        if good and type(info) == "table" then
                            local id = info.overrideSpellID or info.spellID
                            if id and (spec[1] == "Buffs" or known[id]) then
                                local label = spec[1]
                                if label == "Buffs" and NS.IsHarmfulSpellID(id) then label = "Harmful" end
                                candidate(label, id, SpellNameByID(id))
                            end
                        end
                    end
                end
            end
        end
    end
    -- Spellbook fallback: attacks go to Essential, other active spells to Utility.
    for _, sp in ipairs(learned) do
        candidate(category[sp.id] or (NS.IsHarmfulSpellID(sp.id) and "Essential" or "Utility"), sp.id, sp.name)
    end
    -- Only actual auras are used for buff icons and harmful bars.
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for _, spec in ipairs({ {"player", "HELPFUL", "Buffs"}, {"target", "HARMFUL", "Harmful"} }) do
            for i = 1, 40 do
                local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, spec[1], i, spec[2])
                if not ok or not aura then break end
                if not IsSecret(aura.spellId) and not IsSecret(aura.name) and not IsSecret(aura.sourceUnit) and aura.spellId
                    and (aura.sourceUnit == "player" or aura.sourceUnit == "pet") then
                    candidate(spec[3], aura.spellId, aura.name)
                end
            end
        end
    end
    local changed = false
    local have = {}
    for _, g in ipairs(T.groups) do
        for _, e in ipairs(g.entries) do
            if e.id then have[e.kind .. ":" .. e.id] = true end
        end
    end
    local function add(group, sp, aura, bar)
        if not group or #group.entries >= MAX_ENTRIES then return false end
        local kind = aura and "buff" or "cooldown"
        if have[kind .. ":" .. sp.id] then return false end
        group.entries[#group.entries + 1] = { kind = kind, id = sp.id, name = sp.name, bar = aura and bar or nil }
        have[kind .. ":" .. sp.id] = true; changed = true
        return true
    end
    if fresh then
        for _, spec in ipairs({ {"Essential", 5}, {"Utility", 4}, {"Buffs", 3}, {"Harmful", 2} }) do
            local n = 0
            for _, sp in ipairs(candidates[spec[1]]) do
                if n >= spec[2] then break end
                if add(groups[spec[1] == "Harmful" and "Buffs" or spec[1]], sp,
                    spec[1] == "Buffs" or spec[1] == "Harmful", spec[1] == "Harmful") then n = n + 1 end
            end
        end
    elseif T.autoKnownSpells then
        -- Only genuinely newly learned spells are added after the initial sample.
        -- Omitted starter spells and manually removed spells are not re-added on login.
        for _, sp in ipairs(learned) do
            if not T.autoKnownSpells[sp.id] then
                add(groups[category[sp.id] or (NS.IsHarmfulSpellID(sp.id) and "Essential" or "Utility")], sp, false)
            end
        end
    end
    if fresh and #T.groups < MAX_GROUPS then
        local example = NewGroup(#T.groups + 1, "Custom group")
        example.userCreated, example.protected = true, false
        example.essentialTrigger, example.essentialMode = "normal", 1
        T.groups[#T.groups + 1] = example
        changed = true
    end
    if fresh and NS.ResetTrackerPositions then NS.ResetTrackerPositions() end
    T.starterInitialized = true
    T.autoKnownSpells = known
    if changed then TrackerApply(); if TrackerRefreshUI then TrackerRefreshUI() end end
end

------------------------------------------------------------
-- Editor helpers
------------------------------------------------------------

-- /sb auradebug: what the game returns for every buff / debuff you track in the selected group
NS.TrackerAuraDebug = function()
    local say = function(...) print("|cff40bfffSenBar aura|r", ...) end
    local g = CurGroup()
    if not g then say("no group selected: open /sbc and pick one") return end
    local function K(v)
        if v == nil then return "nil" end
        if IsSecret(v) then return "SECRET" end
        return type(v) == "number" and string.format("%.4g", v) or tostring(v)
    end
    say("in combat:", tostring(UnitAffectingCombat("player")), "| target:", tostring(UnitExists("target")),
        "| GetAuraDuration:", tostring(C_UnitAuras and C_UnitAuras.GetAuraDuration ~= nil),
        "| GetUnitAuraBySpellID:", tostring(C_UnitAuras and C_UnitAuras.GetUnitAuraBySpellID ~= nil),
        "| StatusBar timer:", tostring(CreateFrame("StatusBar").SetTimerDuration ~= nil))
    local any = false
    for _, e in ipairs(g.entries) do
        if e.kind == "buff" or e.kind == "debuff" then
            any = true
            local unit = (e.kind == "buff") and "player" or "target"
            local a = FindAura(unit, e)
            if a then
                say(EntryName(e), "(" .. e.kind .. ") FOUND | duration:", K(a.duration), "| expires:", K(a.expirationTime),
                    "| instance id:", K(a.auraInstanceID), "| mine:", K(a.isFromPlayerOrPlayerPet))
            else
                say(EntryName(e), "(" .. e.kind .. ") not found on", unit, "(name used:", tostring(e.name or SpellNameByID(e.id)) .. ")")
            end
        end
    end
    if not any then say("this group has no buff or debuff entries") end
end

local trackerRefresh = {}
local function TReg(fn) trackerRefresh[#trackerRefresh + 1] = fn end
TrackerRefreshUI = function() for _, fn in ipairs(trackerRefresh) do fn() end end

TCheck = function(parent, x, y, text, get, set)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(200, 22)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    local box = CreateFrame("Frame", nil, row)
    box:SetSize(16, 16)
    box:SetPoint("LEFT", row, "LEFT", 0, 0)
    Flat(box, 0.12, 0.13, 0.16, 1)
    Outline(box, 0.30, 0.32, 0.38, 1)
    local fill = box:CreateTexture(nil, "OVERLAY")
    fill:SetPoint("TOPLEFT", 3, -3)
    fill:SetPoint("BOTTOMRIGHT", -3, 3)
    fill:SetTexture(WHITE)
    fill:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    local fs = Label(row, text, 12)
    fs:SetPoint("LEFT", box, "RIGHT", 8, 0)
    row:SetWidth(26 + (fs:GetStringWidth() or 100) + 4)
    local function refresh()
        local v = get()
        if v then fill:Show() else fill:Hide() end
    end
    row:SetScript("OnClick", function()
        set(not get())
        TrackerApply()
        TrackerRefreshUI()
    end)
    TReg(refresh)
    return row
end

local function TSlider(parent, x, y, text, minV, maxV, step, get, set)
    local fs = Label(parent, text, 12)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 4)
    local s = CreateFrame("Slider", nil, parent)
    s:SetOrientation("HORIZONTAL")
    s:SetSize(130, 14)
    s:SetPoint("TOPLEFT", parent, "TOPLEFT", x + 150, y - 2)
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    if s.SetObeyStepOnDrag then s:SetObeyStepOnDrag(true) end
    local track = s:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", s, "LEFT", 0, 0)
    track:SetPoint("RIGHT", s, "RIGHT", 0, 0)
    track:SetHeight(4)
    track:SetTexture(WHITE)
    track:SetVertexColor(0.18, 0.19, 0.24, 1)
    s:SetThumbTexture(WHITE)
    local thumb = s:GetThumbTexture()
    thumb:SetSize(8, 14)
    thumb:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)

    local box = CreateFrame("EditBox", nil, parent)
    box:SetSize(44, 18)
    box:SetPoint("LEFT", s, "RIGHT", 8, 0)
    box:SetAutoFocus(false)
    box:SetFont(FONT, 12, "")
    box:SetTextColor(0.6, 0.85, 1, 1)
    box:SetJustifyH("CENTER")
    box:SetMaxLetters(4)
    Flat(box, 0.11, 0.12, 0.15, 1)
    local edges = Outline(box, 0.26, 0.28, 0.34, 1)

    local function show()
        if not box:HasFocus() then box:SetText(tostring(get() or minV)) end
    end
    s:SetScript("OnValueChanged", function(self, v)
        if self.updating then return end
        v = math.floor(v / step + 0.5) * step
        set(v)
        show()
        TrackerApply()
    end)
    local function commit()
        local n = tonumber(box:GetText())
        if n then
            n = math.floor(math.max(minV, math.min(maxV, n)) / step + 0.5) * step
            set(n)
            s.updating = true
            s:SetValue(n)
            s.updating = false
            TrackerApply()
        end
    end
    box:SetScript("OnEnterPressed", function(self) commit(); self:ClearFocus() end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScript("OnEditFocusGained", function(self)
        for _, e in ipairs(edges) do e:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1) end
        self:HighlightText()
    end)
    box:SetScript("OnEditFocusLost", function(self)
        for _, e in ipairs(edges) do e:SetVertexColor(0.26, 0.28, 0.34, 1) end
        self:HighlightText(0, 0)
        show()
    end)
    TReg(function()
        s.updating = true
        s:SetValue(get() or minV)
        s.updating = false
        show()
    end)
end

local function TArrow(parent, x, y, text, list, get, set)
    local fs = Label(parent, text, 12)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 4)
    local setText
    local function refresh() setText(list[get()] or "?") end
    setText = ArrowSelect(parent, x + 150, y, 210, function(dir)
        local n = (get() or 1) + dir
        if n > #list then n = 1 elseif n < 1 then n = #list end
        set(n)
        TrackerApply()
        TrackerRefreshUI()
    end)
    TReg(refresh)
end

local function TextBox(parent, x, y, w, maxLetters)
    local box = CreateFrame("EditBox", nil, parent)
    box:SetSize(w, 22)
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    box:SetAutoFocus(false)
    box:SetFont(FONT, 12, "")
    box:SetTextColor(1, 1, 1, 1)
    box:SetTextInsets(6, 6, 0, 0)
    box:SetMaxLetters(maxLetters or 60)
    Flat(box, 0.11, 0.12, 0.15, 1)
    local edges = Outline(box, 0.26, 0.28, 0.34, 1)
    box:SetScript("OnEditFocusGained", function()
        for _, e in ipairs(edges) do e:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1) end
    end)
    box:SetScript("OnEditFocusLost", function()
        for _, e in ipairs(edges) do e:SetVertexColor(0.26, 0.28, 0.34, 1) end
    end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    return box
end

local function SectionHeader(parent, text, y)
    local h = Label(parent, text, 13, ACCENT[1], ACCENT[2], ACCENT[3])
    h:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    local ln = parent:CreateTexture(nil, "ARTWORK")
    ln:SetTexture(WHITE)
    ln:SetVertexColor(0.22, 0.24, 0.30, 1)
    ln:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y - 18)
    ln:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y - 18)
    ln:SetHeight(1)
end

------------------------------------------------------------
-- Picker window (spellbook / active buffs): click to add, with search
------------------------------------------------------------
local function BuildPicker(pane)
    local P = CreateFrame("Frame", nil, pane)
    P:SetAllPoints(pane)
    P:SetFrameLevel(pane:GetFrameLevel() + 30)
    P:EnableMouse(true)
    Flat(P, 0.07, 0.07, 0.09, 0.99)
    Outline(P, 0.22, 0.24, 0.30, 1)
    P:Hide()

    P.title = Label(P, "", 14, 1, 1, 1)
    P.title:SetPoint("TOPLEFT", P, "TOPLEFT", 12, -12)
    local done = MakeButton(P, "Done", 64, 22, function() P:Hide() end)
    done:SetPoint("TOPRIGHT", P, "TOPRIGHT", -10, -10)
    local sLbl = Label(P, "Search", 12)
    sLbl:SetPoint("TOPLEFT", P, "TOPLEFT", 12, -46)
    local search = TextBox(P, 62, -42, 260, 30)
    P.status = Label(P, "", 11, 0.55, 0.9, 0.6)
    P.status:SetPoint("TOPLEFT", P, "TOPLEFT", 12, -72)

    local ROWS, rowH = 12, 28
    P.rows = {}
    P.offset = 0
    P.items = {}
    P.filtered = {}
    local function refreshRows()
        for i = 1, ROWS do
            local r = P.rows[i]
            local it = P.filtered[P.offset + i]
            if it then
                r.item = it
                r.icon:SetTexture(it.icon)
                r.name:SetText(it.name)
                r.tag:SetText(it.added and "added - click to remove" or "click to add")
                if it.added then r.tag:SetTextColor(0.55, 0.9, 0.6, 1) else r.tag:SetTextColor(0.55, 0.6, 0.7, 1) end
                r:Show()
            else
                r:Hide()
            end
        end
    end
    local function applyFilter()
        local q = (search:GetText() or ""):lower()
        P.filtered = {}
        for _, it in ipairs(P.items) do
            if q == "" or it.name:lower():find(q, 1, true) then P.filtered[#P.filtered + 1] = it end
        end
        P.offset = 0
        refreshRows()
    end
    search:SetScript("OnTextChanged", function() applyFilter() end)
    for i = 1, ROWS do
        local r = CreateFrame("Button", nil, P)
        r:SetSize(400, rowH - 2)
        r:SetPoint("TOPLEFT", P, "TOPLEFT", 12, -96 - (i - 1) * rowH)
        r.bg = Flat(r, 0.11, 0.12, 0.15, 1)
        r.icon = r:CreateTexture(nil, "ARTWORK")
        r.icon:SetSize(22, 22)
        r.icon:SetPoint("LEFT", r, "LEFT", 3, 0)
        r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        r.name = Label(r, "", 12, 1, 1, 1)
        r.name:SetPoint("LEFT", r.icon, "RIGHT", 8, 0)
        r.tag = Label(r, "", 11, 0.55, 0.6, 0.7)
        r.tag:SetPoint("RIGHT", r, "RIGHT", -8, 0)
        r:SetScript("OnEnter", function(self) self.bg:SetVertexColor(0.18, 0.2, 0.26, 1) end)
        r:SetScript("OnLeave", function(self) self.bg:SetVertexColor(0.11, 0.12, 0.15, 1) end)
        r:SetScript("OnClick", function(self)
            local it = self.item
            local g = CurGroup()
            if not it or not g then return end
            if it.added then
                -- already in this row: clicking removes it
                for idx, e in ipairs(g.entries) do
                    if e.kind == it.kind and e.id == it.id then table.remove(g.entries, idx) break end
                end
                it.added = false
                TrackerApply(); TrackerRefreshUI()
                P.status:SetText("Removed " .. it.name .. ".")
            else
                local ok, err = AddEntry(g, { kind = it.kind, id = it.id, name = it.name })
                if ok then it.added = true end
                P.status:SetText(ok and ("Added " .. it.name .. ".") or err)
            end
            refreshRows()
        end)
        P.rows[i] = r
    end
    P:EnableMouseWheel(true)
    P:SetScript("OnMouseWheel", function(_, delta)
        local maxOff = math.max(0, #P.filtered - ROWS)
        P.offset = math.max(0, math.min(maxOff, P.offset - delta * 3))
        refreshRows()
    end)
    P.hint = Label(P, "Mouse wheel to scroll. Click a spell to add it, click it again to remove it.", 11, 0.55, 0.6, 0.7)
    P.hint:SetPoint("BOTTOMLEFT", P, "BOTTOMLEFT", 12, 10)

    function P:Open(title, items, note)
        P.title:SetText(title)
        P.items = items
        local g = CurGroup()
        for _, it in ipairs(items) do
            it.added = false
            if g then
                for _, e in ipairs(g.entries) do
                    if e.kind == it.kind and e.id == it.id then it.added = true end
                end
            end
        end
        search:SetText("")
        P.status:SetText(note or (#items .. " found."))
        applyFilter()
        P:Show()
    end
    return P
end

------------------------------------------------------------
-- Editor window
------------------------------------------------------------
local function BuildTrackerEditor()
    local EDITOR_W = 1040
    local PANE_W = 840
    local E = CreateFrame("Frame", "SenBarTrackerEditor", UIParent)
    E:SetSize(EDITOR_W, 760)
    E:SetPoint("CENTER", UIParent, "CENTER", 40, 0)
    E:SetFrameStrata("DIALOG")
    E:SetToplevel(true)
    E:EnableMouse(true)
    E:SetClampedToScreen(true)
    Flat(E, 0.07, 0.07, 0.09, 0.97)
    Outline(E, 0.22, 0.24, 0.30, 1)

    local edrag
    E:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        self:Raise()
        local cx, cy = GetCursorPosition()
        local sc = self:GetEffectiveScale()
        edrag = { dx = self:GetLeft() * sc - cx, dy = self:GetBottom() * sc - cy }
    end)
    E:SetScript("OnMouseUp", function() edrag = nil end)
    E:SetScript("OnUpdate", function(self)
        if not edrag then return end
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then edrag = nil return end
        local cx, cy = GetCursorPosition()
        local sc = self:GetEffectiveScale()
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", (cx + edrag.dx) / sc, (cy + edrag.dy) / sc)
    end)
    E:SetScript("OnShow", function()
        E:SetFrameStrata("DIALOG"); E:SetToplevel(true); E:Raise()
        TrackerRefreshUI(); TrackerApply(); NS.BoostFonts(E, 2)
    end)
    E:SetScript("OnHide", function() edrag = nil; if trackerPicker then trackerPicker:Hide() end end)

    -- saved size (scale) of the editor
    local savedScale = db and db.tracker and db.tracker.editorScale
    E:SetScale((type(savedScale) == "number") and math.max(0.6, math.min(1.5, savedScale)) or 0.75)

    -- resize grip, bottom right: drag to make the whole editor smaller or bigger
    local grip = CreateFrame("Button", nil, E)
    grip:SetSize(18, 18)
    grip:SetPoint("BOTTOMRIGHT", E, "BOTTOMRIGHT", -3, 3)
    grip:SetFrameLevel(E:GetFrameLevel() + 30)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    local gdrag
    grip:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        local es = E:GetEffectiveScale()
        gdrag = { left = E:GetLeft() * es, top = E:GetTop() * es }
    end)
    grip:SetScript("OnMouseUp", function()
        if gdrag and db and db.tracker then db.tracker.editorScale = E:GetScale() end
        gdrag = nil
    end)
    grip:SetScript("OnUpdate", function()
        if not gdrag then return end
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
            if db and db.tracker then db.tracker.editorScale = E:GetScale() end
            gdrag = nil
            return
        end
        local cx = GetCursorPosition()
        local u = UIParent:GetEffectiveScale()
        local ns = (cx - gdrag.left) / (EDITOR_W * u)
        ns = math.max(0.6, math.min(1.5, ns))
        E:SetScale(ns)
        E:ClearAllPoints()
        E:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", gdrag.left / (ns * u), gdrag.top / (ns * u))
    end)

    local title = Label(E, "Tracker", 16, 1, 1, 1)
    title:SetPoint("TOPLEFT", E, "TOPLEFT", 14, -12)
    local sub = Label(E, "cooldowns, buffs and debuffs, your way", 11, 0.5, 0.55, 0.65)
    sub:SetPoint("LEFT", title, "RIGHT", 8, -1)
    local close = MakeButton(E, "x", 22, 22, function() E:Hide() end)
    close:SetPoint("TOPRIGHT", E, "TOPRIGHT", -10, -10)
    local line = E:CreateTexture(nil, "ARTWORK")
    line:SetTexture(WHITE)
    line:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    line:SetPoint("TOPLEFT", E, "TOPLEFT", 0, -38)
    line:SetPoint("TOPRIGHT", E, "TOPRIGHT", 0, -38)
    line:SetHeight(2)

    local T = function() return db.tracker end
    local function Sel()
        local gs = db.tracker.groups
        if #gs == 0 then TrackerSel = 1 return nil end
        if not TrackerSel or TrackerSel > #gs then TrackerSel = #gs end
        if TrackerSel < 1 then TrackerSel = 1 end
        return gs[TrackerSel]
    end

    -- ---------- sidebar: groups. Each button sits on the same line as its row in Class layout ----------
    local sideHdr = Label(E, "GROUPS", 11, 0.5, 0.55, 0.65)
    sideHdr:SetPoint("TOPLEFT", E, "TOPLEFT", 16, -140)
    NS.Side = { geom = {} } -- geom[i] = { y = top of the row, h = its height }, filled in by the Class layout board
    local sideScroll = CreateFrame("ScrollFrame", nil, E)
    sideScroll:SetPoint("TOPLEFT", E, "TOPLEFT", 12, -160)
    sideScroll:SetSize(158, 428)
    local sideChild = CreateFrame("Frame", nil, sideScroll)
    sideChild:SetSize(158, 700)
    sideScroll:SetScrollChild(sideChild)
    sideScroll:EnableMouseWheel(true)
    NS.Side.scroll, NS.Side.child = sideScroll, sideChild
    local gbtns = {}
    for i = 1, MAX_GROUPS do
        local b = CreateFrame("Button", nil, sideChild)
        b:SetSize(158, 62)
        b:SetPoint("TOPLEFT", sideChild, "TOPLEFT", 0, -(i - 1) * 74)
        b.bg = Flat(b, 0.11, 0.12, 0.15, 1)
        b.glow = b:CreateTexture(nil, "BORDER")
        b.glow:SetAllPoints()
        b.glow:SetTexture(WHITE)
        b.glow:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.14)
        b.glow:Hide()
        b.strip = b:CreateTexture(nil, "ARTWORK")
        b.strip:SetTexture(WHITE)
        b.strip:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
        b.strip:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 0, 0)
        b.strip:SetWidth(3)
        b.name = Label(b, "", 13, 1, 1, 1)
        b.name:SetPoint("TOPLEFT", b, "TOPLEFT", 12, -9)
        b.sub = Label(b, "", 11, 0.55, 0.6, 0.7)
        b.sub:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 12, 9)
        b:SetScript("OnClick", function() TrackerSel = i; TrackerRefreshUI() end)
        gbtns[i] = b
    end
    local newBtn = MakeButton(E, "+ New group", 150, 26, function()
        local gs = db.tracker.groups
        if #gs >= MAX_GROUPS then return end
        local created = NewGroup(#gs + 1)
        created.userCreated = true
        gs[#gs + 1] = created
        TrackerSel = #gs
        db.tracker.enabled = true
        TrackerApply()
        TrackerRefreshUI()
    end)
    newBtn:SetPoint("BOTTOMLEFT", E, "BOTTOMLEFT", 16, 52)
    local status = Label(E, "", 11, 0.55, 0.9, 0.6)
    status:SetPoint("BOTTOMLEFT", E, "BOTTOMLEFT", 16, 14)
    local function Say(msg, bad)
        status:SetText(msg or "")
        if bad then status:SetTextColor(1, 0.45, 0.45, 1) else status:SetTextColor(0.55, 0.9, 0.6, 1) end
    end
    local impBtn = MakeButton(E, "Import from Blizzard", 150, 26, function()
        local r, err = ImportFromBlizzard()
        if not r then Say(err, true) return end
        if r.last then TrackerSel = r.last end
        if r.added == 0 and r.fixed == 0 then
            if r.blocked then
                Say("No room for new groups (maximum " .. MAX_GROUPS .. ").", true)
            else
                Say("Already up to date: every Blizzard Cooldown Manager spell is in your groups.")
            end
        else
            local parts = {}
            if r.created > 0 then parts[#parts + 1] = "new group(s): " .. r.created end
            if r.updated > 0 then parts[#parts + 1] = "existing group(s): " .. r.updated end
            local msg = "Added " .. r.added .. " missing icon(s) (" .. table.concat(parts, ", ") .. ")."
            if r.fixed > 0 then msg = msg .. " Corrected the type of " .. r.fixed .. " debuff(s)." end
            Say(msg)
        end
        TrackerRefreshUI()
    end)
    impBtn:SetPoint("BOTTOMLEFT", E, "BOTTOMLEFT", 16, 84)

    -- ---------- bottom strip: global switches ----------
    TCheck(E, 14, -716, "Enable tracker", function() return db.tracker.enabled end, function(v) db.tracker.enabled = v end)
    TCheck(E, 150, -716, "Hide the Blizzard Cooldown Manager", function() return db.tracker.hideBlizzard end,
        function(v) db.tracker.hideBlizzard = v end)
    status:ClearAllPoints()
    status:SetPoint("BOTTOMRIGHT", E, "BOTTOMRIGHT", -14, 12)

    -- ---------- right pane ----------
    local pane = CreateFrame("Frame", nil, E)
    pane:SetPoint("TOPLEFT", E, "TOPLEFT", 184, -50)
    pane:SetSize(PANE_W, 650)

    local nameLbl = Label(pane, "Name", 12)
    nameLbl:SetPoint("TOPLEFT", pane, "TOPLEFT", 0, -4)
    local nameBox = TextBox(pane, 44, 0, 150, 24)
    local function commitName()
        local g = Sel()
        if not g then return end
        local nm = (nameBox:GetText() or ""):match("^%s*(.-)%s*$")
        if nm ~= "" then g.name = nm:sub(1, 24) end
        TrackerRefreshUI()
    end
    nameBox:SetScript("OnEnterPressed", function(self) commitName(); self:ClearFocus() end)
    nameBox:HookScript("OnEditFocusLost", commitName)
    TCheck(pane, 206, -1, "Show group", function() local g = Sel(); return g and g.enabled end,
        function(v) local g = Sel(); if g then g.enabled = v end end)

    local pendingDel
    local delBtn
    delBtn = MakeButton(pane, "Delete group", 96, 22, function()
        local g = Sel()
        if not g or not g.userCreated or g.protected then return end
        if pendingDel == TrackerSel then
            table.remove(db.tracker.groups, TrackerSel)
            pendingDel = nil
            delBtn.label:SetText("Delete group")
            TrackerApply()
            TrackerRefreshUI()
        else
            pendingDel = TrackerSel
            delBtn.label:SetText("Confirm?")
            if C_Timer and C_Timer.After then
                C_Timer.After(3, function() pendingDel = nil; delBtn.label:SetText("Delete group") end)
            end
        end
    end)
    delBtn:SetPoint("TOPRIGHT", pane, "TOPRIGHT", 0, 0)

    -- sub tabs
    local pages, tabs = {}, {}
    local function SelectSub(i)
        for n, pg in ipairs(pages) do
            if n == i then pg:Show(); tabs[n].bar:Show() else pg:Hide(); tabs[n].bar:Hide() end
            tabs[n].label:SetTextColor(n == i and 1 or 0.55, n == i and 1 or 0.58, n == i and 1 or 0.65, 1)
        end
    end
    local function SubTab(i, text)
        local t = CreateFrame("Button", nil, pane)
        t:SetSize(96, 24)
        t:SetPoint("TOPLEFT", pane, "TOPLEFT", (i - 1) * 100, -34)
        t.label = Label(t, text, 13)
        t.label:SetPoint("CENTER")
        t.bar = t:CreateTexture(nil, "ARTWORK")
        t.bar:SetTexture(WHITE)
        t.bar:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
        t.bar:SetPoint("BOTTOMLEFT")
        t.bar:SetPoint("BOTTOMRIGHT")
        t.bar:SetHeight(2)
        t:SetScript("OnClick", function() SelectSub(i) end)
        tabs[i] = t
    end
    SubTab(1, "Class layout")
    SubTab(2, "Adjust")
    local function SubPage()
        local pg = CreateFrame("Frame", nil, pane)
        pg:SetPoint("TOPLEFT", pane, "TOPLEFT", 0, -70)
        pg:SetSize(424, 470)
        pg:Hide()
        pages[#pages + 1] = pg
        return pg
    end

    -- Shared add-source shortcuts remain in the same place on both tabs.
    local function NeedGroup()
        local g = Sel()
        if not g then Say("Create a group first.", true) end
        return g
    end
    local shortcutW, shortcutGap = 136, 8
    local shortcutX = PANE_W - (shortcutW * 3 + shortcutGap * 2)
    local b1 = MakeButton(pane, "From spellbook...", shortcutW, 24, function()
        if not NeedGroup() then return end
        local items = CollectSpellbook()
        if #items == 0 then Say("Could not read the spellbook. Type the spell name or ID instead.", true) return end
        trackerPicker:Open("Spellbook cooldowns", items, #items .. " learned spells. Click to add or remove.")
    end)
    b1:SetPoint("TOPLEFT", pane, "TOPLEFT", shortcutX, -34)
    local b2 = MakeButton(pane, "My active buffs...", shortcutW, 24, function()
        if not NeedGroup() then return end
        if InCombatLockdown() then Say("Buff names can only be read out of combat.", true) return end
        local items = CollectBuffs()
        if #items == 0 then Say("No readable buffs on you right now.", true) return end
        trackerPicker:Open("Buffs on you right now", items, "Buffs are read out of combat. Click to add or remove.")
    end)
    b2:SetPoint("TOPLEFT", pane, "TOPLEFT", shortcutX + shortcutW + shortcutGap, -34)
    local b3 = MakeButton(pane, "Both trinkets", shortcutW, 24, function()
        local g = NeedGroup()
        if not g then return end
        local a = AddEntry(g, { kind = "trinket", slot = 13 })
        local b = AddEntry(g, { kind = "trinket", slot = 14 })
        if a or b then Say("Trinkets added.") else Say("Trinkets are already tracked.", true) end
    end)
    b3:SetPoint("TOPLEFT", pane, "TOPLEFT", shortcutX + (shortcutW + shortcutGap) * 2, -34)

    -- ----- Style page: icons, then the look of the bars -----
    local SP = SubPage()
    local function G(key, dflt)
        return function() local g = Sel(); if g and g[key] ~= nil then return g[key] end return dflt end
    end
    local function S(key)
        return function(v) local g = Sel(); if g then g[key] = v end end
    end
    local sy = 0
    local function Row() local v = sy; sy = sy - 26; return v end
    -- Essential group switching is configured per additional group in Class Layout.

    SectionHeader(SP, "Look of this group", Row())
    sy = sy - 4
    TSlider(SP, 0, Row(), "Icon size", 20, 80, 1, G("size", 40), S("size"))
    TSlider(SP, 0, Row(), "Spacing", 0, 20, 1, G("spacing", 4), S("spacing"))
    TSlider(SP, 0, Row(), "Icons per row", 1, 24, 1, G("perRow", 8), S("perRow"))
    TArrow(SP, 0, Row(), "Fill direction", GROW_NAMES, G("grow", 3), S("grow"))
    TArrow(SP, 0, Row(), "New rows go", ROW_NAMES, G("rowGrow", 1), S("rowGrow"))
    TArrow(SP, 0, Row(), "Cooldown icons", CDMODE_NAMES, G("cdMode", 1), S("cdMode"))
    TArrow(SP, 0, Row(), "Buff visibility", BUFFMODE_NAMES, G("buffMode", 1), S("buffMode"))
    sy = sy - 4
    local cy1, cy2, cy3 = Row(), Row(), Row()
    TCheck(SP, 0, cy1, "Timer numbers", G("showTimer", true), S("showTimer"))
    TCheck(SP, 212, cy1, "Stack / charge count", G("showStacks", true), S("showStacks"))
    TCheck(SP, 0, cy2, "Grey out on cooldown", G("desaturate", true), S("desaturate"))
    TCheck(SP, 212, cy2, "Pulse when ready / gained", G("glow", true), S("glow"))
    TCheck(SP, 0, cy3, "Only show in combat", G("combatOnly", false), S("combatOnly"))
    TCheck(SP, 212, cy3, "Red when out of range", G("rangeRed", true), S("rangeRed"))
    local pulseY = Row()
    local cy4 = Row()
    TCheck(SP, 0, cy4, "Move bars separately from icons", G("barsFree", false), function(v)
        local g = Sel()
        if not g then return end
        g.barsFree = v and true or false
        if v and not (g.bx and g.by) then
            local gf = tgroups[TrackerSel or 1]
            local l, t = gf and gf.barFrame:GetLeft(), gf and gf.barFrame:GetTop()
            if l and t then g.bx, g.by = l, t else g.bx, g.by = g.x, g.y - 60 end
        end
    end)
    sy = sy - 4

    -- bars (the entries in "Tracked bars")
    local function GSwatch(x, y, text, key)
        local lbl = Label(SP, text, 12)
        lbl:SetPoint("TOPLEFT", SP, "TOPLEFT", x, y - 4)
        local b = CreateFrame("Button", nil, SP)
        b:SetSize(44, 20)
        b:SetPoint("TOPLEFT", SP, "TOPLEFT", x + 66, y)
        Outline(b, 0.40, 0.42, 0.50, 1)
        local tex = b:CreateTexture(nil, "ARTWORK")
        tex:SetPoint("TOPLEFT", 1, -1)
        tex:SetPoint("BOTTOMRIGHT", -1, 1)
        tex:SetTexture(WHITE)
        b:SetScript("OnClick", function()
            local g = Sel()
            if not g then return end
            OpenColorPicker(NS.BarColor(g, key), function()
                if key == "pulseColor" then NS.PulsePreview[g] = GetTime() + 2.5 end
                TrackerApply(); TrackerRefreshUI()
            end)
        end)
        TReg(function()
            local g = Sel()
            if g then
                local c = NS.BarColor(g, key)
                tex:SetVertexColor(c.r, c.g, c.b, 1)
            end
        end)
    end
    -- pulse style (several choices) with its colour to the right
    TArrow(SP, 0, pulseY, "Pulse style", NS.PULSE_NAMES, G("pulseStyle", 1), function(v)
        local g = Sel()
        if g then g.pulseStyle = v; NS.PulsePreview[g] = GetTime() + 2.5 end
    end)
    GSwatch(300, pulseY, "", "pulseColor")
    local colY = Row()
    local barAdjust = CreateFrame("Frame", nil, SP)
    barAdjust:SetPoint("TOPLEFT", SP, "TOPLEFT", 0, colY)
    barAdjust:SetSize(420, 72)
    SectionHeader(barAdjust, "Adjust buff bars", 0)
    TSlider(barAdjust, 0, -24, "Bar width", 60, 400, 2, G("barWidth", 180), S("barWidth"))
    TSlider(barAdjust, 0, -50, "Bar height", 8, 40, 1, G("barHeight", 18), S("barHeight"))
    local barAdjustHint = Label(SP, "Bar adjustment is available for the Buff group.", 11, 0.55, 0.6, 0.7)
    barAdjustHint:SetPoint("TOPLEFT", SP, "TOPLEFT", 0, colY - 6)
    local sNote = Label(SP, "Drag a group on screen to place it while this window is open.", 11, 0.55, 0.6, 0.7)
    sNote:SetPoint("TOPLEFT", SP, "TOPLEFT", 0, colY - 88)
    TReg(function()
        local g = Sel()
        local n = g and ((g.importKey or g.name or ""):lower()) or ""
        local isBuff = n:find("buff", 1, true) ~= nil
        barAdjust:SetShown(isBuff)
        barAdjustHint:SetShown(not isBuff)
    end)

    -- ----- Class layout: one drag-and-drop board for Essential, Utility and Buffs -----
    local LP = SubPage()
    LP:SetSize(PANE_W, 590)
    local layoutNote = Label(LP, "Click a group on the left to select it. Drag icons between groups. The Buff group has icon slots on the left and bar slots on the right; use + on either side to add. Click a bar's colour square to change its fill; right-click for entry options.", 11, 0.62, 0.68, 0.75)
    layoutNote:SetPoint("TOPLEFT", LP, "TOPLEFT", 0, 0)
    layoutNote:SetWidth(PANE_W - 8)
    layoutNote:SetJustifyH("LEFT")

    -- ----- Add section (bottom of Class layout): type a spell, or pick from the spellbook / buffs / trinkets -----
    local AP = CreateFrame("Frame", nil, LP)
    AP:SetPoint("BOTTOMLEFT", LP, "BOTTOMLEFT", 0, 0)
    AP:SetSize(PANE_W, 100)
    SectionHeader(AP, "Add to the selected group", 0)
    local kindSel = 1
    local kSet = ArrowSelect(AP, 0, -26, 222, function(dir)
        kindSel = kindSel + dir
        if kindSel > #KIND_ORDER then kindSel = 1 elseif kindSel < 1 then kindSel = #KIND_ORDER end
        TrackerRefreshUI()
    end)
    TReg(function() kSet(KIND_NAMES[kindSel]) end)
    local input = TextBox(AP, 228, -26, 220, 40)
    local function DoAdd()
        local g = Sel()
        if not g then Say("Create a group first.", true) return end
        local e, err = ResolveText(KIND_ORDER[kindSel], input:GetText())
        if not e then Say(err, true) return end
        local ok, err2 = AddEntry(g, e)
        if ok then
            Say("Added " .. EntryName(e) .. " to " .. g.name .. ".")
            input:SetText("")
        else
            Say(err2, true)
        end
        input:ClearFocus()
    end
    input:SetScript("OnEnterPressed", function() DoAdd() end)
    local addBtn = MakeButton(AP, "Add", 50, 22, DoAdd)
    addBtn:SetPoint("TOPLEFT", AP, "TOPLEFT", 454, -26)
    local aHint = Label(AP, "", 11, 0.55, 0.6, 0.7)
    aHint:SetPoint("TOPLEFT", AP, "TOPLEFT", 0, -54)
    aHint:SetJustifyH("LEFT")
    aHint:SetText("Enter a spell or item name or ID. Buffs can also be added with the shared shortcuts above.")

    do -- icon board: one row per group (up to MAX_GROUPS). Spells are added with the + button
        local ICON, GAP, PERROW = 38, 4, 19
        local STEP = ICON + GAP
        local BOX_W = PERROW * STEP - GAP
        local BOARD_W = 830
        local HDR_H, SEC_GAP = 24, 12
        local BUFF_HDR_H, BUFF_COL_GAP = 40, 12
        local BUFF_LANE_W = math.floor((BOX_W - BUFF_COL_GAP) / 2)
        local BUFF_ICON_COLS = math.max(1, math.floor((BUFF_LANE_W + GAP) / STEP))
        local BAR_SLOTS_PER_ROW, BAR_SLOT_H, BAR_SLOT_GAP = 3, 32, 6
        local BAR_SLOT_W = math.floor((BUFF_LANE_W - (BAR_SLOTS_PER_ROW - 1) * BAR_SLOT_GAP) / BAR_SLOTS_PER_ROW)
        local boardCols = {}
        local boardDrag, bghost

        -- the board scrolls with the mouse wheel when the groups need more room than the page has
        local scroll = CreateFrame("ScrollFrame", nil, LP)
        scroll:SetPoint("TOPLEFT", LP, "TOPLEFT", 0, -40)
        scroll:SetPoint("BOTTOMRIGHT", LP, "BOTTOMRIGHT", 0, 106) -- the Add section sits below the board
        local BC = CreateFrame("Frame", nil, scroll)
        BC:SetSize(BOARD_W, 700)
        scroll:SetScrollChild(BC)
        scroll:EnableMouseWheel(true)
        local function ScrollBoard(delta)
            local maxV = math.max(0, BC:GetHeight() - scroll:GetHeight())
            local v = math.max(0, math.min(maxV, scroll:GetVerticalScroll() - delta * 44))
            scroll:SetVerticalScroll(v)
            NS.Side.scroll:SetVerticalScroll(v) -- the group buttons on the left follow the rows
        end
        scroll:SetScript("OnMouseWheel", function(_, delta) ScrollBoard(delta) end)
        NS.Side.scroll:SetScript("OnMouseWheel", function(_, delta) ScrollBoard(delta) end)

        local function BoardOver(f)
            if not f or not f:IsVisible() then return false end
            if not scroll:IsMouseOver() then return false end
            return f:IsMouseOver()
        end

        -- a group counts as a buff row when it is named like one
        local function KindOfGroup(g)
            local nm = ((g.importKey or g.name or "")):lower()
            if nm:find("buff", 1, true) then return "buff" end
            return "cooldown"
        end

        local function BoardMoveTracked(d, spec, beforeEntry)
            local sourceGroup, entry = d.group, d.entry
            local targetGroup = db.tracker.groups[spec.index]
            if not sourceGroup or not entry or not targetGroup then return end
            local sourceIndex
            for i, e in ipairs(sourceGroup.entries) do if e == entry then sourceIndex = i break end end
            if not sourceIndex then return end
            table.remove(sourceGroup.entries, sourceIndex)
            if sourceGroup ~= targetGroup and #targetGroup.entries >= MAX_ENTRIES then
                table.insert(sourceGroup.entries, math.min(sourceIndex, #sourceGroup.entries + 1), entry)
                Say("That row is full (" .. MAX_ENTRIES .. " spells).", true)
                return
            end
            if sourceGroup ~= targetGroup then
                entry.bar = false
                if entry.kind == "cooldown" or entry.kind == "buff" or entry.kind == "debuff" then
                    entry.kind = spec.kind
                end
            end
            if spec.kind == "buff" then
                if spec.lane == "bar" then entry.bar = true
                elseif spec.lane == "icon" then entry.bar = false
                else entry.bar = NS.IsHarmfulSpellID(entry.id) end
            end
            local at = #targetGroup.entries + 1
            if beforeEntry and beforeEntry ~= entry then
                for i, e in ipairs(targetGroup.entries) do if e == beforeEntry then at = i break end end
            elseif beforeEntry == entry then
                at = math.min(sourceIndex, #targetGroup.entries + 1)
            end
            table.insert(targetGroup.entries, at, entry)
            TrackerApply(); TrackerRefreshUI()
        end

        local function ClearHighlights()
            for _, c in ipairs(boardCols) do
                c.hl:Hide()
                for _, s in ipairs(c.slots) do s.hlf:Hide() end
            end
        end

        local function BoardDrop()
            local d = boardDrag
            boardDrag = nil
            bghost:Hide()
            ClearHighlights()
            if not d then return end
            if not d.group then return end
            for _, c in ipairs(boardCols) do
                if c.spec and (BoardOver(c.box) or (c.isBuff and BoardOver(c.barBox))) then
                    local before
                    local targetSpec = { index = c.spec.index, kind = c.spec.kind, lane = "icon" }
                    if c.isBuff and c.barBox:IsMouseOver() then targetSpec.lane = "bar" end
                    local laneSlots = targetSpec.lane == "bar" and c.barSlots or c.iconSlots
                    for _, s in ipairs(laneSlots) do
                        if s:IsShown() and s:IsMouseOver() then before = s.ref and s.ref.entry or nil; break end
                    end
                    BoardMoveTracked(d, targetSpec, before)
                    return
                end
            end
        end

        local function StartDrag(payload, tex)
            boardDrag = payload
            bghost.icon:SetTexture(tex or QUESTION_MARK)
            bghost:Show()
            GameTooltip:Hide()
        end

        -- "+" opens the picker for that row: spellbook cooldowns, or the buffs you have right now
        local function BoardOpenPicker(spec)
            local g = db.tracker.groups[spec.index]
            if not g then return end
            TrackerSel = spec.index
            TrackerRefreshUI()
            local items = CollectSpellbook()
            if #items == 0 then Say("Could not read the spellbook. You can still type a spell name or ID in the Add tab.", true) return end
            -- Every + button offers the complete learned spell list. For a Buff-named row,
            -- add selected spells as aura trackers; other rows track their cooldowns.
            for _, item in ipairs(items) do
                item.kind = spec.kind
                if spec.kind == "buff" then
                    if spec.lane == "bar" then item.bar = true
                    elseif spec.lane == "icon" then item.bar = false
                    else item.bar = NS.IsHarmfulSpellID(item.id) end
                end
            end
            trackerPicker:Open("Add to " .. g.name, items, #items .. " learned active spells. Search and click to add.")
        end

        local function SlotTooltip(self)
            local e = (self.ref and self.ref.entry) or self.spell
            if not e or boardDrag then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local ok = false
            if e.kind == "item" and e.id and GameTooltip.SetItemByID then
                ok = pcall(GameTooltip.SetItemByID, GameTooltip, e.id)
            elseif e.id and GameTooltip.SetSpellByID then
                ok = pcall(GameTooltip.SetSpellByID, GameTooltip, e.id)
            end
            if not ok then GameTooltip:SetText(EntryName(e)) end
            if self.ref and e.kind == "cooldown" then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(e.proc and "Proc spell: grey until it procs. Right-click to turn off." or "Right-click: mark as proc spell (grey until it procs, gold glow when it does).", 1, 0.82, 0.18, true)
            end
            GameTooltip:Show()
        end

        local activeTrackerContextMenu
        local contextDismiss = CreateFrame("Frame", nil, UIParent)
        contextDismiss:SetAllPoints(UIParent)
        contextDismiss:SetFrameStrata("TOOLTIP")
        contextDismiss:SetFrameLevel(499)
        contextDismiss:EnableMouse(true)
        contextDismiss:SetScript("OnMouseDown", function(_, button)
            if activeTrackerContextMenu then
                local menu = activeTrackerContextMenu
                local overMenu = menu:IsMouseOver()
                    or (menu.colorSubmenu and menu.colorSubmenu:IsShown() and menu.colorSubmenu:IsMouseOver())
                    or (menu.durationSubmenu and menu.durationSubmenu:IsShown() and menu.durationSubmenu:IsMouseOver())
                if not overMenu then
                    menu:Hide()
                    if button == "RightButton" then
                        for _, groupCol in ipairs(boardCols) do
                            for _, slot in ipairs(groupCol.slots) do
                                if slot:IsShown() and slot.ref and slot:IsMouseOver() then
                                    local handler = slot:GetScript("OnClick")
                                    if handler then handler(slot, "RightButton") end
                                    return
                                end
                            end
                            for _, slot in ipairs(groupCol.barSlots) do
                                if slot:IsShown() and slot.ref and slot:IsMouseOver() then
                                    local handler = slot:GetScript("OnClick")
                                    if handler then handler(slot, "RightButton") end
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end)
        contextDismiss:Hide()
        local function ShowTrackerMenu(menu)
            if activeTrackerContextMenu and activeTrackerContextMenu ~= menu then activeTrackerContextMenu:Hide() end
            activeTrackerContextMenu = menu
            menu:SetFrameStrata("TOOLTIP")
            menu:SetFrameLevel(700)
            menu:SetToplevel(true)
            contextDismiss:Show()
            menu:Raise()
            menu:Show()
        end

        local function MakeSlot(parent)
            local s = CreateFrame("Button", nil, parent)
            s:SetSize(ICON, ICON)
            Flat(s, 0.07, 0.075, 0.095, 1)
            Outline(s, 0.20, 0.21, 0.26, 1)
            s.icon = s:CreateTexture(nil, "ARTWORK")
            s.icon:SetAllPoints()
            s.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
            s.plus = Label(s, "+", 24, 0.85, 0.72, 0.25)
            s.plus:SetPoint("CENTER", s, "CENTER", 0, 1)
            s.hlf = CreateFrame("Frame", nil, s)
            s.hlf:SetAllPoints()
            s.hlf:SetFrameLevel(s:GetFrameLevel() + 3)
            Outline(s.hlf, ACCENT[1], ACCENT[2], ACCENT[3], 1)
            s.hlf:Hide()
            s.procMark = s:CreateTexture(nil, "OVERLAY")
            s.procMark:SetSize(10, 10)
            s.procMark:SetPoint("TOPRIGHT", s, "TOPRIGHT", -1, -1)
            s.procMark:SetTexture(WHITE)
            s.procMark:SetVertexColor(1, 0.82, 0.18, 1)
            s.procMark:Hide()
            s.barMark = s:CreateTexture(nil, "OVERLAY")
            s.barMark:SetSize(ICON - 6, 4)
            s.barMark:SetPoint("BOTTOM", s, "BOTTOM", 0, 2)
            s.barMark:SetTexture(WHITE)
            s.barMark:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            s.barMark:Hide()
            s:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            s:RegisterForDrag("LeftButton")
            s:SetScript("OnEnter", SlotTooltip)
            s:SetScript("OnLeave", function() GameTooltip:Hide() end)
            s:SetScript("OnDragStop", BoardDrop)
            s:EnableMouseWheel(true)
            s:SetScript("OnMouseWheel", function(_, delta) ScrollBoard(delta) end)
            return s
        end

        local function MakeBarSlot(parent, ci)
            local s = CreateFrame("Button", nil, parent)
            s:SetSize(BAR_SLOT_W, BAR_SLOT_H)
            s.bg = Flat(s, 0.035, 0.04, 0.05, 1)
            Outline(s, 0.20, 0.22, 0.27, 1)
            s.icon = s:CreateTexture(nil, "ARTWORK")
            s.icon:SetPoint("TOPLEFT", 2, -2)
            s.icon:SetSize(BAR_SLOT_H - 4, BAR_SLOT_H - 4)
            s.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
            s.track = s:CreateTexture(nil, "BACKGROUND")
            s.track:SetPoint("LEFT", s.icon, "RIGHT", 2, 0)
            s.track:SetPoint("RIGHT", s, "RIGHT", -2, 0)
            s.track:SetHeight(18)
            s.track:SetTexture(WHITE)
            s.track:SetVertexColor(0.025, 0.03, 0.04, 1)
            s.fill = s:CreateTexture(nil, "ARTWORK")
            s.fill:SetPoint("TOPLEFT", s.track, "TOPLEFT")
            s.fill:SetPoint("BOTTOMLEFT", s.track, "BOTTOMLEFT")
            s.fill:SetWidth((BAR_SLOT_W - BAR_SLOT_H - 7) * 0.62)
            s.fill:SetTexture(WHITE)
            s.name = s:CreateFontString(nil, "OVERLAY")
            s.name:SetFont(FONT, 9, "OUTLINE")
            s.name:SetPoint("LEFT", s.track, "LEFT", 4, 0)
            s.name:SetPoint("RIGHT", s.track, "RIGHT", -18, 0)
            s.name:SetJustifyH("LEFT")
            s.colorBtn = CreateFrame("Button", nil, s)
            s.colorBtn:SetSize(13, 13)
            s.colorBtn:SetPoint("TOPRIGHT", s, "TOPRIGHT", -3, -3)
            s.colorBtn:SetFrameLevel(s:GetFrameLevel() + 4)
            s.colorBtn:RegisterForClicks("LeftButtonUp")
            Outline(s.colorBtn, 0.78, 0.81, 0.88, 1)
            s.colorSwatch = s.colorBtn:CreateTexture(nil, "ARTWORK")
            s.colorSwatch:SetPoint("TOPLEFT", 1, -1)
            s.colorSwatch:SetPoint("BOTTOMRIGHT", -1, 1)
            s.colorSwatch:SetTexture(WHITE)
            s.colorBtn:SetScript("OnClick", function(_, button)
                if button ~= "LeftButton" then return end
                local e = s.ref and s.ref.entry
                if not e then return end
                if type(e.color) ~= "table" then e.color = { r = 0.35, g = 0.90, b = 0.50 } end
                OpenColorPicker(e.color, function() TrackerApply(); TrackerRefreshUI() end)
            end)
            s.colorBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Choose this buff bar's colour")
                GameTooltip:Show()
            end)
            s.colorBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            s.plus = Label(s, "+", 22, 0.85, 0.72, 0.25)
            s.plus:SetPoint("CENTER", s, "CENTER", 0, 1)
            s:SetScript("OnDragStart", function(self)
                if self.ref then StartDrag({ group = self.ref.group, entry = self.ref.entry }, EntryTexture(self.ref.entry)) end
            end)
            s:SetScript("OnDragStop", BoardDrop)
            s:RegisterForDrag("LeftButton")
            s:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            s:SetScript("OnClick", function(self, button)
                if self.isPlus and button == "LeftButton" then
                    local spec = { index = ci, kind = "buff", lane = "bar" }
                    BoardOpenPicker(spec)
                elseif self.ref and button == "RightButton" then
                    for groupIndex, group in ipairs(db.tracker.groups) do
                        if group == self.ref.group then
                            if TrackerSel ~= groupIndex then TrackerSel = groupIndex; TrackerRefreshUI() end
                            for entryIndex, entry in ipairs(group.entries) do
                                if entry == self.ref.entry then
                                    local iconSlot = boardCols[groupIndex] and boardCols[groupIndex].slots[entryIndex]
                                    local clickHandler = iconSlot and iconSlot:GetScript("OnClick")
                                    if iconSlot and clickHandler then
                                        local oldRef, oldPlus, oldSelection = iconSlot.ref, iconSlot.isPlus, TrackerSel
                                        iconSlot.ref = self.ref
                                        iconSlot.isPlus = false
                                        clickHandler(iconSlot, "RightButton")
                                        if TrackerSel == oldSelection then
                                            iconSlot.ref, iconSlot.isPlus = oldRef, oldPlus
                                        end
                                        if iconSlot.contextMenu then
                                            iconSlot.contextMenu:ClearAllPoints()
                                            iconSlot.contextMenu:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 2, -2)
                                        end
                                    end
                                    return
                                end
                            end
                        end
                    end
                end
            end)
            s:SetScript("OnEnter", function(self)
                if self.ref then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(EntryName(self.ref.entry))
                    GameTooltip:AddLine("Click the colour square to customize this bar. Right-click for entry options.", 0.8, 0.82, 0.86, true)
                    GameTooltip:Show()
                end
            end)
            s:SetScript("OnLeave", function() GameTooltip:Hide() end)
            s:EnableMouse(true)
            return s
        end

        -- the icon that follows the mouse while dragging
        bghost = CreateFrame("Frame", nil, UIParent)
        bghost:SetSize(ICON, ICON)
        bghost:SetFrameStrata("TOOLTIP")
        bghost.icon = bghost:CreateTexture(nil, "ARTWORK")
        bghost.icon:SetAllPoints()
        bghost.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
        bghost:SetAlpha(0.9)
        bghost:Hide()
        bghost:SetScript("OnUpdate", function(self)
            local x, y = GetCursorPosition()
            local sc = UIParent:GetEffectiveScale()
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x / sc, y / sc)
            for _, c in ipairs(boardCols) do
                local over = c.spec and BoardOver(c.box)
                c.hl:SetShown(over and true or false)
                for _, s in ipairs(c.slots) do s.hlf:SetShown((over and s:IsShown() and s:IsMouseOver()) and true or false) end
            end
        end)
        LP:SetScript("OnHide", function()
            boardDrag = nil
            bghost:Hide()
            ClearHighlights()
        end)

        -- one strip per possible group; only the ones that exist are shown
        for ci = 1, MAX_GROUPS do
            local groupIndex = ci
            local c = { slots = {} }
            boardCols[ci] = c
            -- highlight behind the selected group's row
            c.panel = BC:CreateTexture(nil, "BACKGROUND")
            c.panel:SetTexture(WHITE)
            c.panel:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.09)
            c.panel:Hide()
            c.panelStrip = BC:CreateTexture(nil, "BACKGROUND")
            c.panelStrip:SetTexture(WHITE)
            c.panelStrip:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
            c.panelStrip:Hide()
            c.hdr = CreateFrame("Button", nil, BC) -- click the header of a row to select that group
            c.hdr:SetSize(BOX_W, HDR_H)
            c.hdr:SetScript("OnClick", function() TrackerSel = groupIndex; TrackerRefreshUI() end)
            c.title = Label(BC, "", 13, ACCENT[1], ACCENT[2], ACCENT[3])
            -- show / hide this group on screen, without leaving the layout board
            c.showButton = MakeButton(BC, "Shown", 66, 18, function()
                local g = db.tracker.groups[groupIndex]
                if not g then return end
                g.enabled = not g.enabled
                TrackerApply(); TrackerRefreshUI()
            end)
            c.roleButton = CreateFrame("Button", nil, BC, "UIPanelButtonTemplate")
            c.roleButton:SetSize(124, 20)
            c.roleButton:RegisterForClicks("LeftButtonUp")
            c.roleButton:SetFrameLevel(c.hdr:GetFrameLevel() + 2)
            c.roleButton:SetToplevel(true)
            c.roleButton:EnableMouse(true)
            c.roleButton:SetText("Normal group")
            c.roleButton.menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
            local menu = c.roleButton.menu
            menu:SetFrameStrata("TOOLTIP"); menu:SetFrameLevel(500); menu:SetSize(150, 132)
            menu:EnableMouse(true)
            menu:SetClampedToScreen(true)
            menu:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
            menu:SetBackdropColor(0.055, 0.06, 0.08, 0.98); menu:SetBackdropBorderColor(0.28, 0.31, 0.38, 1)
            menu:Hide(); menu.buttons = {}
            menu:SetScript("OnHide", function()
                if activeTrackerContextMenu == menu then activeTrackerContextMenu = nil; contextDismiss:Hide() end
            end)
            local roleOptions = { {"Normal group", "normal"}, {"Bear Form", "bear"}, {"Cat Form", "cat"}, {"Balance Form", "balance"}, {"Def Stance", "defensive"}, {"Berserker Stance", "berserker"} }
            menu:SetHeight(#roleOptions * 23 + 8)
            for ri, opt in ipairs(roleOptions) do
                local roleKey = opt[2]
                local rb = CreateFrame("Button", nil, menu)
                rb:SetHeight(22); rb:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -4-(ri-1)*23); rb:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -4, -4-(ri-1)*23)
                rb:RegisterForClicks("LeftButtonUp")
                rb:EnableMouse(true)
                rb.text = rb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); rb.text:SetPoint("LEFT", 5, 0); rb.text:SetText(opt[1]); rb.text:SetJustifyH("LEFT")
                rb:SetScript("OnEnter", function(self) self.text:SetTextColor(1, 0.82, 0.25) end)
                rb:SetScript("OnLeave", function(self) self.text:SetTextColor(1, 1, 1) end)
                rb:SetScript("OnClick", function()
                    local g = db.tracker.groups[groupIndex]
                    if g then g.essentialTrigger = roleKey; TrackerApply(); TrackerRefreshUI() end
                    menu:Hide()
                end)
                menu.buttons[ri] = rb
            end
            c.roleButton:SetScript("OnClick", function(self)
                local g = db.tracker.groups[groupIndex]
                if not g then return end
                if g.protected == true or (groupIndex <= 3 and g.userCreated ~= true)
                    or g.importKey == "Essential" or g.importKey == "Utility" or g.importKey == "Buffs"
                    or g.name == "Essential" or g.name == "Utility" or g.name == "Buff" or g.name == "Buffs" then return end
                for _, other in ipairs(boardCols) do if other.roleButton and other.roleButton.menu then other.roleButton.menu:Hide() end end
                menu:ClearAllPoints(); menu:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -2); ShowTrackerMenu(menu)
            end)
            c.line = BC:CreateTexture(nil, "ARTWORK")
            c.line:SetTexture(WHITE)
            c.line:SetVertexColor(0.22, 0.24, 0.30, 1)
            c.line:SetHeight(1)
            c.box = CreateFrame("Frame", nil, BC)
            c.box:SetSize(BOX_W, ICON)
            Flat(c.box, 0.055, 0.06, 0.075, 1)
            c.barBox = CreateFrame("Frame", nil, BC)
            c.barBox:SetSize(BUFF_LANE_W, BAR_SLOT_H)
            Flat(c.barBox, 0.055, 0.06, 0.075, 1)
            c.barBox:Hide()
            c.iconLaneLabel = Label(BC, "BUFF ICONS", 10, 0.62, 0.68, 0.75)
            c.barLaneLabel = Label(BC, "BUFF BARS", 10, 0.62, 0.68, 0.75)
            c.iconLaneLabel:Hide(); c.barLaneLabel:Hide()
            c.hl = c.box:CreateTexture(nil, "BACKGROUND")
            c.hl:SetAllPoints()
            c.hl:SetTexture(WHITE)
            c.hl:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.2)
            c.hl:Hide()
            c.count = Label(BC, "", 10, 0.58, 0.62, 0.7)
            c.box:EnableMouseWheel(true)
            c.box:SetScript("OnMouseWheel", function(_, delta) ScrollBoard(delta) end)
            c.box:EnableMouse(true)
            c.box:SetScript("OnMouseDown", function() if TrackerSel ~= groupIndex then TrackerSel = groupIndex; TrackerRefreshUI() end end)
            c.barBox:EnableMouse(true)
            c.barBox:SetScript("OnMouseDown", function() if TrackerSel ~= groupIndex then TrackerSel = groupIndex; TrackerRefreshUI() end end)
            for i = 1, MAX_ENTRIES do
                local s = MakeSlot(c.box)
                local col, row = (i - 1) % PERROW, math.floor((i - 1) / PERROW)
                s:SetPoint("TOPLEFT", c.box, "TOPLEFT", col * STEP, -row * STEP)
                s:SetScript("OnDragStart", function(self)
                    if self.ref then TrackerSel = groupIndex end
                    if self.ref then StartDrag({ group = self.ref.group, entry = self.ref.entry }, EntryTexture(self.ref.entry)) end
                end)
            s:SetScript("OnClick", function(self, button)
                    if TrackerSel ~= groupIndex then TrackerSel = groupIndex; TrackerRefreshUI() end
                    if self.isPlus and button == "LeftButton" and c.spec then
                        BoardOpenPicker(c.spec)
                        return
                    end
                    if button == "RightButton" and self.ref and self.ref.entry then
                        local entry, group = self.ref.entry, self.ref.group
                        if not group then return end
                        -- A single active menu keeps the editor responsive when switching icons.
                        if activeTrackerContextMenu then activeTrackerContextMenu:Hide() end
                        if not self.contextMenu then
                            local menu = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
                            menu:SetFrameStrata("DIALOG")
                            menu:SetFrameLevel(100)
                            menu:EnableMouse(true)
                            menu:SetClampedToScreen(true)
                            menu:SetSize(190, 140)
                            menu:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
                            menu:SetBackdropColor(0.055, 0.06, 0.08, 0.98)
                            menu:SetBackdropBorderColor(0.28, 0.31, 0.38, 1)
                            menu.buttons = {}
                            for n = 1, 5 do
                                local b = CreateFrame("Button", nil, menu)
                                b:SetHeight(26)
                                b:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -3 - (n - 1) * 27)
                                b:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -4, -3 - (n - 1) * 27)
                                b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                                b.text:SetPoint("LEFT", 6, 0)
                                b:SetScript("OnEnter", function(btn) btn.text:SetTextColor(1, 0.82, 0.25) end)
                                b:SetScript("OnLeave", function(btn) btn.text:SetTextColor(1, 1, 1) end)
                                menu.buttons[n] = b
                            end
                            menu.colorSubmenu = CreateFrame("Frame", nil, menu, "BackdropTemplate")
                            menu.colorSubmenu:SetFrameStrata("TOOLTIP")
                            menu.colorSubmenu:SetFrameLevel(menu:GetFrameLevel() + 4)
                            menu.colorSubmenu:SetSize(142, 88)
                            menu.colorSubmenu:SetClampedToScreen(true)
                            menu.colorSubmenu:EnableMouse(true)
                            menu.colorSubmenu:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
                            menu.colorSubmenu:SetBackdropColor(0.055, 0.06, 0.08, 0.98)
                            menu.colorSubmenu:SetBackdropBorderColor(0.28, 0.31, 0.38, 1)
                            menu.colorSubmenu:Hide()
                            for n, mode in ipairs({ "default", "class", "custom" }) do
                                local choice = CreateFrame("Button", nil, menu.colorSubmenu)
                                choice.mode = mode
                                choice:SetHeight(24)
                                choice:SetPoint("TOPLEFT", menu.colorSubmenu, "TOPLEFT", 4, -4 - (n - 1) * 27)
                                choice:SetPoint("TOPRIGHT", menu.colorSubmenu, "TOPRIGHT", -4, -4 - (n - 1) * 27)
                                choice:RegisterForClicks("LeftButtonUp")
                                choice.text = choice:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                                choice.text:SetPoint("LEFT", 6, 0)
                                choice.text:SetText(mode == "default" and "Default" or mode == "class" and "Class color" or "Custom")
                                choice:SetScript("OnEnter", function(btn) btn.text:SetTextColor(1, 0.82, 0.25) end)
                                choice:SetScript("OnLeave", function(btn) btn.text:SetTextColor(1, 1, 1) end)
                                choice:SetScript("OnClick", function(btn)
                                    local targetGroup, targetEntry = menu.group, menu.entry
                                    if not targetGroup or not targetEntry then return end
                                    targetEntry.pulseColorMode = btn.mode
                                    NS.PulsePreview[targetGroup] = GetTime() + 2.5
                                    menu.colorSubmenu:Hide()
                                    local selectedName = btn.mode == "class" and "Class Color" or btn.mode == "custom" and "Custom" or "Default"
                                    menu.buttons[3].text:SetText("Glow/pulse color: " .. selectedName .. "  >")
                                    if btn.mode == "custom" then
                                        if type(targetEntry.pulseColor) ~= "table" then
                                            targetEntry.pulseColor = { r = 1, g = 209 / 255, b = 51 / 255 }
                                        end
                                        menu:Hide()
                                        OpenColorPicker(targetEntry.pulseColor, function()
                                            TrackerApply(); TrackerRefreshUI()
                                        end)
                                    else
                                        TrackerApply(); TrackerRefreshUI()
                                    end
                                end)
                                menu.colorSubmenu.buttons = menu.colorSubmenu.buttons or {}
                                menu.colorSubmenu.buttons[n] = choice
                            end
                            menu.durationSubmenu = CreateFrame("Frame", nil, menu, "BackdropTemplate")
                            menu.durationSubmenu:SetFrameStrata("TOOLTIP")
                            menu.durationSubmenu:SetFrameLevel(menu:GetFrameLevel() + 4)
                            menu.durationSubmenu:SetSize(178, 100)
                            menu.durationSubmenu:SetClampedToScreen(true)
                            menu.durationSubmenu:EnableMouse(true)
                            menu.durationSubmenu:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1 })
                            menu.durationSubmenu:SetBackdropColor(0.055, 0.06, 0.08, 0.98)
                            menu.durationSubmenu:SetBackdropBorderColor(0.28, 0.31, 0.38, 1)
                            menu.durationSubmenu:Hide()
                            menu.durationToggle = CreateFrame("Button", nil, menu.durationSubmenu, "UIPanelButtonTemplate")
                            menu.durationToggle:SetSize(160, 22)
                            menu.durationToggle:SetPoint("TOP", menu.durationSubmenu, "TOP", 0, -5)
                            menu.durationToggle:RegisterForClicks("LeftButtonUp")
                            menu.durationToggle:SetScript("OnClick", function()
                                local targetEntry, targetGroup = menu.entry, menu.group
                                if not targetEntry or not targetGroup then return end
                                local isOn = targetEntry.showDuration == nil and targetGroup.showTimer or targetEntry.showDuration
                                targetEntry.showDuration = not isOn
                                menu.durationToggle:SetText("Cooldown text: " .. (targetEntry.showDuration and "On" or "Off"))
                                TrackerApply()
                            end)
                            menu.durationSizeLabel = Label(menu.durationSubmenu, "Cooldown text size: 14", 10, 0.86, 0.88, 0.92)
                            menu.durationSizeLabel:SetPoint("TOPLEFT", menu.durationSubmenu, "TOPLEFT", 9, -35)
                            menu.durationSlider = CreateFrame("Slider", nil, menu.durationSubmenu)
                            menu.durationSlider:SetPoint("TOPLEFT", menu.durationSubmenu, "TOPLEFT", 10, -61)
                            menu.durationSlider:SetSize(158, 14)
                            menu.durationSlider:SetOrientation("HORIZONTAL")
                            menu.durationSlider:SetMinMaxValues(6, 32)
                            menu.durationSlider:SetValueStep(1)
                            menu.durationSlider:SetObeyStepOnDrag(true)
                            menu.durationSlider.track = menu.durationSlider:CreateTexture(nil, "BACKGROUND")
                            menu.durationSlider.track:SetPoint("LEFT", menu.durationSlider, "LEFT", 0, 0)
                            menu.durationSlider.track:SetPoint("RIGHT", menu.durationSlider, "RIGHT", 0, 0)
                            menu.durationSlider.track:SetHeight(4)
                            menu.durationSlider.track:SetTexture(WHITE)
                            menu.durationSlider.track:SetVertexColor(0.28, 0.31, 0.38, 1)
                            menu.durationSlider:SetThumbTexture(WHITE)
                            menu.durationSlider.thumb = menu.durationSlider:GetThumbTexture()
                            if menu.durationSlider.thumb then
                                menu.durationSlider.thumb:SetSize(12, 12)
                                menu.durationSlider.thumb:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
                            end
                            menu.durationSlider:SetScript("OnValueChanged", function(slider, value)
                                local targetEntry = menu.entry
                                value = math.floor(value + 0.5)
                                menu.durationSizeLabel:SetText("Cooldown text size: " .. value)
                                if not menu.loadingDuration and targetEntry then targetEntry.durationSize = value end
                            end)
                            menu.durationSlider:SetScript("OnMouseUp", function()
                                if menu.entry and menu.entry.durationSize then TrackerApply() end
                            end)
                            menu:SetScript("OnHide", function() if activeTrackerContextMenu == menu then activeTrackerContextMenu = nil; contextDismiss:Hide() end end)
                            self.contextMenu = menu
                        end
                        local menu = self.contextMenu
                        activeTrackerContextMenu = menu
                        menu.entry, menu.group = entry, group
                        menu.colorSubmenu:Hide()
                        menu.durationSubmenu:Hide()
                        menu:ClearAllPoints()
                        menu:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 2, -2)
                        local procButton, durationButton, colorButton, barButton, removeButton = unpack(menu.buttons)
                        procButton.text:SetText(entry.proc and "Unmark as proc" or "Mark as proc")
                        procButton:SetScript("OnClick", function()
                            if entry.kind == "cooldown" then entry.proc = (not entry.proc) or nil end
                            menu:Hide(); TrackerApply(); TrackerRefreshUI()
                        end)
                        durationButton.text:SetText("Cooldown text  >")
                        durationButton:SetScript("OnClick", function()
                            local currentEntry, currentGroup = menu.entry, menu.group
                            if not currentEntry or not currentGroup then return end
                            menu.colorSubmenu:Hide()
                            menu.durationSubmenu:ClearAllPoints()
                            menu.durationSubmenu:SetPoint("TOPLEFT", menu, "TOPRIGHT", -2, -28)
                            menu.durationSubmenu:SetFrameLevel(menu:GetFrameLevel() + 4)
                            menu.durationSubmenu:Raise()
                            local isOn = currentEntry.showDuration == nil and currentGroup.showTimer or currentEntry.showDuration
                            menu.durationToggle:SetText("Cooldown text: " .. (isOn and "On" or "Off"))
                            menu.loadingDuration = true
                            local durationSize = currentEntry.durationSize or math.max(9, math.floor(currentGroup.size * 0.42))
                            menu.durationSlider:SetValue(durationSize)
                            menu.durationSizeLabel:SetText("Cooldown text size: " .. durationSize)
                            menu.loadingDuration = false
                            menu.durationSubmenu:Show()
                        end)
                        local mode = entry.pulseColorMode or group.pulseColorMode or "default"
                        local modeName = mode == "class" and "Class Color" or mode == "custom" and "Custom" or "Default"
                        colorButton.text:SetText("Glow/pulse color: " .. modeName .. "  >")
                        colorButton:SetScript("OnClick", function()
                            menu.durationSubmenu:Hide()
                            menu.colorSubmenu:ClearAllPoints()
                            menu.colorSubmenu:SetPoint("TOPLEFT", menu, "TOPRIGHT", -2, -54)
                            menu.colorSubmenu:SetFrameLevel(menu:GetFrameLevel() + 4)
                            menu.colorSubmenu:Raise()
                            menu.colorSubmenu:Show()
                        end)
                        local canBar = entry.kind == "buff" or entry.kind == "debuff"
                        barButton.text:SetText("Show as: " .. (entry.bar and "Bar" or "Icon"))
                        barButton:SetScript("OnClick", function()
                            entry.bar = not entry.bar
                            menu:Hide(); TrackerApply(); TrackerRefreshUI()
                        end)
                        removeButton.text:SetText("Remove from this row")
                        removeButton:SetScript("OnClick", function()
                            for idx, existing in ipairs(group.entries) do
                                if existing == entry then
                                    table.remove(group.entries, idx)
                                    break
                                end
                            end
                            menu:Hide(); TrackerApply(); TrackerRefreshUI()
                        end)
                        local list = {}
                        if entry.kind == "cooldown" then list[#list + 1] = procButton else procButton:Hide() end
                        list[#list + 1] = removeButton
                        list[#list + 1] = colorButton
                        list[#list + 1] = durationButton
                        if canBar then list[#list + 1] = barButton else barButton:Hide() end
                        for k, btn in ipairs(list) do
                            btn:ClearAllPoints()
                            btn:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -3 - (k - 1) * 27)
                            btn:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -4, -3 - (k - 1) * 27)
                            btn:SetScript("OnEnter", function(row)
                                row.text:SetTextColor(1, 0.82, 0.25)
                                if row == colorButton then
                                    menu.durationSubmenu:Hide()
                                    menu.colorSubmenu:ClearAllPoints()
                                    menu.colorSubmenu:SetPoint("TOPLEFT", menu, "TOPRIGHT", 0, -54)
                                    menu.colorSubmenu:SetFrameLevel(menu:GetFrameLevel() + 4)
                                    menu.colorSubmenu:Raise()
                                    menu.colorSubmenu:Show()
                                elseif row == durationButton then
                                    local currentEntry, currentGroup = menu.entry, menu.group
                                    if not currentEntry or not currentGroup then return end
                                    menu.colorSubmenu:Hide()
                                    menu.durationSubmenu:ClearAllPoints()
                                    menu.durationSubmenu:SetPoint("TOPLEFT", menu, "TOPRIGHT", 0, -81)
                                    menu.durationSubmenu:SetFrameLevel(menu:GetFrameLevel() + 4)
                                    menu.durationSubmenu:Raise()
                                    local isOn = currentEntry.showDuration == nil and currentGroup.showTimer or currentEntry.showDuration
                                    menu.durationToggle:SetText("Cooldown text: " .. (isOn and "On" or "Off"))
                                    menu.loadingDuration = true
                                    local durationSize = currentEntry.durationSize or math.max(9, math.floor(currentGroup.size * 0.42))
                                    menu.durationSlider:SetValue(durationSize)
                                    menu.durationSizeLabel:SetText("Cooldown text size: " .. durationSize)
                                    menu.loadingDuration = false
                                    menu.durationSubmenu:Show()
                                else
                                    menu.colorSubmenu:Hide()
                                    menu.durationSubmenu:Hide()
                                end
                            end)
                            btn:SetScript("OnLeave", function(row) row.text:SetTextColor(1, 1, 1) end)
                            btn:Show()
                        end
                        menu:SetHeight(#list * 27 + 6)
                        ShowTrackerMenu(menu)
                        return
                    end
                end)
                c.slots[i] = s
            end
            c.iconSlots = {}
            for i = 1, MAX_ENTRIES do c.iconSlots[i] = c.slots[i] end
            c.barSlots = {}
            for i = 1, MAX_ENTRIES do c.barSlots[i] = MakeBarSlot(c.barBox, ci) end
        end

        TReg(function()
            local groups = db.tracker.groups
            local yCur = 0
            local selIdx = math.max(1, math.min(TrackerSel or 1, #groups))
            for ci, c in ipairs(boardCols) do
                local g = groups[ci]
                if not g then
                    c.spec = nil
                    NS.Side.geom[ci] = nil
                    c.panel:Hide(); c.panelStrip:Hide(); c.hdr:Hide()
                    c.title:Hide(); c.showButton:Hide(); c.roleButton:Hide(); c.roleButton.menu:Hide(); c.line:Hide(); c.box:Hide(); c.barBox:Hide(); c.count:Hide()
                    c.iconLaneLabel:Hide(); c.barLaneLabel:Hide()
                else
                    local entries = g.entries
                    local n = #entries
                    local groupKind = KindOfGroup(g)
                    c.isBuff = groupKind == "buff"
                    c.spec = { index = ci, kind = groupKind, lane = "icon" }
                    local iconEntries, barEntries = {}, {}
                    if c.isBuff then
                        for _, entry in ipairs(entries) do
                            if entry.bar then barEntries[#barEntries + 1] = entry else iconEntries[#iconEntries + 1] = entry end
                        end
                    end
                    local rows, boxH, rowHeader
                    if c.isBuff then
                        local iconRows = math.max(1, math.ceil((#iconEntries + (#entries < MAX_ENTRIES and 1 or 0)) / BUFF_ICON_COLS))
                        local barRows = math.max(1, math.ceil((#barEntries + (#entries < MAX_ENTRIES and 1 or 0)) / BAR_SLOTS_PER_ROW))
                        rows = math.max(iconRows, barRows)
                        boxH, rowHeader = rows * STEP - GAP, BUFF_HDR_H
                    else
                        rows = ((n < MAX_ENTRIES and n + 1 or n) > PERROW) and 2 or 1
                        boxH, rowHeader = rows * STEP - GAP, HDR_H
                    end
                    c.title:SetText(string.upper(g.name or ("Group " .. ci)))
                    c.title:ClearAllPoints(); c.title:SetPoint("TOPLEFT", BC, "TOPLEFT", 6, yCur - 4)
                    c.hdr:ClearAllPoints(); c.hdr:SetPoint("TOPLEFT", BC, "TOPLEFT", 6, yCur); c.hdr:Show()
                    NS.Side.geom[ci] = { y = yCur, h = 62 }
                    local isCore = g.protected == true or (ci <= 3 and g.userCreated ~= true)
                        or g.importKey == "Essential" or g.importKey == "Utility" or g.importKey == "Buffs"
                        or g.name == "Essential" or g.name == "Utility" or g.name == "Buff" or g.name == "Buffs"
                    if not isCore then
                        local roleLabels = { normal="Normal group", bear="Bear Form", cat="Cat Form", balance="Balance Form", defensive="Def Stance", berserker="Berserker Stance" }
                        c.roleButton:SetText(roleLabels[g.essentialTrigger or "normal"] or "Normal group")
                        c.roleButton:ClearAllPoints(); c.roleButton:SetPoint("LEFT", c.title, "RIGHT", 10, 0); c.roleButton:Show()
                    else c.roleButton:Hide(); c.roleButton.menu:Hide() end
                    c.line:ClearAllPoints()
                    local lineY = c.isBuff and (yCur - 36) or (yCur - 22)
                    c.line:SetPoint("TOPLEFT", BC, "TOPLEFT", 6, lineY)
                    c.line:SetPoint("TOPRIGHT", BC, "TOPLEFT", 6 + BOX_W, lineY)
                    c.box:ClearAllPoints()
                    if c.isBuff then
                        c.box:SetPoint("TOPLEFT", BC, "TOPLEFT", 6, yCur - rowHeader - 4)
                        c.box:SetWidth(BUFF_LANE_W)
                        c.barBox:ClearAllPoints(); c.barBox:SetPoint("TOPLEFT", BC, "TOPLEFT", 6 + BUFF_LANE_W + BUFF_COL_GAP, yCur - rowHeader - 4)
                        c.barBox:SetWidth(BUFF_LANE_W)
                        c.barBox:SetHeight(boxH)
                        c.barBox:Show()
                        c.iconLaneLabel:ClearAllPoints(); c.iconLaneLabel:SetPoint("TOPLEFT", BC, "TOPLEFT", 10, yCur - 25)
                        c.barLaneLabel:ClearAllPoints(); c.barLaneLabel:SetPoint("TOPLEFT", BC, "TOPLEFT", 6 + BUFF_LANE_W + BUFF_COL_GAP + 4, yCur - 25)
                        c.iconLaneLabel:Show(); c.barLaneLabel:Show()
                    else
                        c.box:SetPoint("TOPLEFT", BC, "TOPLEFT", 6, yCur - rowHeader - 4)
                        c.box:SetWidth(BOX_W)
                        c.barBox:Hide(); c.iconLaneLabel:Hide(); c.barLaneLabel:Hide()
                    end
                    c.box:SetHeight(boxH)
                    c.count:SetText(n .. "/" .. MAX_ENTRIES)
                    c.count:ClearAllPoints(); c.count:SetPoint("BOTTOMRIGHT", c.box, "TOPRIGHT", 0, 4)
                    c.showButton:ClearAllPoints(); c.showButton:SetPoint("TOPRIGHT", BC, "TOPLEFT", 6 + BOX_W, yCur + 1)
                    c.showButton:SetSize(82, 26)
                    c.showButton:SetFrameLevel(BC:GetFrameLevel() + 5)
                    if g.enabled then
                        c.showButton.label:SetText("Shown")
                        c.showButton.label:SetTextColor(0.55, 0.95, 0.6, 1)
                        c.title:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
                    else
                        c.showButton.label:SetText("Hidden")
                        c.showButton.label:SetTextColor(1, 0.55, 0.45, 1)
                        c.title:SetTextColor(0.45, 0.48, 0.55, 1)
                    end
                    -- the selected group is lit, the others fade a little
                    local isSel = (ci == selIdx)
                    local a = (isSel and 1 or 0.5) * (g.enabled and 1 or 0.7)
                    for _, w in ipairs({ c.box, c.barBox, c.title, c.line, c.count, c.roleButton }) do w:SetAlpha(a) end
                    c.showButton:SetAlpha(1)
                    c.panel:ClearAllPoints()
                    c.panel:SetPoint("TOPLEFT", BC, "TOPLEFT", 0, yCur + 2)
                    c.panel:SetPoint("BOTTOMRIGHT", c.isBuff and c.barBox or c.box, "BOTTOMRIGHT", 6, -6)
                    c.panelStrip:ClearAllPoints()
                    c.panelStrip:SetPoint("TOPLEFT", c.panel, "TOPLEFT", 0, 0)
                    c.panelStrip:SetPoint("BOTTOMLEFT", c.panel, "BOTTOMLEFT", 0, 0)
                    c.panelStrip:SetWidth(3)
                    c.panel:SetShown(isSel); c.panelStrip:SetShown(isSel)
                    c.showButton:Show()
                    c.title:Show(); c.line:Show(); c.box:Show(); c.count:Show()
                    if c.isBuff then
                        local slotIndex = 0
                        for i, entry in ipairs(iconEntries) do
                            slotIndex = i
                            local s = c.iconSlots[i]
                            local col, row = (i - 1) % BUFF_ICON_COLS, math.floor((i - 1) / BUFF_ICON_COLS)
                            s:ClearAllPoints(); s:SetPoint("TOPLEFT", c.box, "TOPLEFT", col * STEP, -row * STEP)
                            s.ref, s.isPlus = { group = g, entry = entry }, false
                            s.icon:SetTexture(EntryTexture(entry)); s.icon:Show(); s.plus:Hide(); s:Show()
                            s.procMark:SetShown(entry.proc == true); s.barMark:Hide()
                        end
                        if #entries < MAX_ENTRIES then
                            local i = #iconEntries + 1
                            local s = c.iconSlots[i]
                            local col, row = (i - 1) % BUFF_ICON_COLS, math.floor((i - 1) / BUFF_ICON_COLS)
                            s:ClearAllPoints(); s:SetPoint("TOPLEFT", c.box, "TOPLEFT", col * STEP, -row * STEP)
                            s.ref, s.isPlus = nil, true; s.icon:Hide(); s.plus:Show(); s.procMark:Hide(); s.barMark:Hide(); s:Show()
                        end
                        for i = #iconEntries + (#entries < MAX_ENTRIES and 1 or 0) + 1, #c.iconSlots do
                            local s = c.iconSlots[i]; s.ref, s.isPlus = nil, false; s:Hide()
                        end
                        for i, entry in ipairs(barEntries) do
                            local s = c.barSlots[i]
                            local col, row = (i - 1) % BAR_SLOTS_PER_ROW, math.floor((i - 1) / BAR_SLOTS_PER_ROW)
                            s:ClearAllPoints(); s:SetPoint("TOPLEFT", c.barBox, "TOPLEFT", col * (BAR_SLOT_W + BAR_SLOT_GAP), -row * STEP)
                            s.ref, s.isPlus = { group = g, entry = entry }, false
                            s.icon:SetTexture(EntryTexture(entry)); s.icon:Show(); s.plus:Hide()
                            s.name:SetText(EntryName(entry))
                            local color = type(entry.color) == "table" and entry.color or { r = 0.35, g = 0.90, b = 0.50 }
                            s.fill:SetVertexColor(color.r or 0.35, color.g or 0.90, color.b or 0.50, 0.95)
                            s.colorSwatch:SetVertexColor(color.r or 0.35, color.g or 0.90, color.b or 0.50, 1)
                            s.colorBtn:Show()
                            s.track:Show(); s.fill:Show(); s.name:Show(); s:Show()
                        end
                        if #entries < MAX_ENTRIES then
                            local i = #barEntries + 1
                            local s = c.barSlots[i]
                            local col, row = (i - 1) % BAR_SLOTS_PER_ROW, math.floor((i - 1) / BAR_SLOTS_PER_ROW)
                            s:ClearAllPoints(); s:SetPoint("TOPLEFT", c.barBox, "TOPLEFT", col * (BAR_SLOT_W + BAR_SLOT_GAP), -row * STEP)
                            s.ref, s.isPlus = nil, true; s.icon:Hide(); s.name:Hide(); s.track:Hide(); s.fill:Hide(); s.colorBtn:Hide(); s.plus:Show(); s:Show()
                        end
                        for i = #barEntries + (#entries < MAX_ENTRIES and 1 or 0) + 1, #c.barSlots do
                            local s = c.barSlots[i]; s.ref, s.isPlus = nil, false; s:Hide()
                        end
                        for i = MAX_ENTRIES + 1, #c.slots do c.slots[i]:Hide() end
                    else
                        for i, s in ipairs(c.slots) do
                            local e = entries[i]
                            s:ClearAllPoints()
                            local col, row = (i - 1) % PERROW, math.floor((i - 1) / PERROW)
                            s:SetPoint("TOPLEFT", c.box, "TOPLEFT", col * STEP, -row * STEP)
                            if i > rows * PERROW then
                                s.ref, s.isPlus = nil, false; s.procMark:Hide(); s.barMark:Hide(); s:Hide()
                            elseif e then
                                s.ref, s.isPlus = { group = g, entry = e }, false
                                s.icon:SetTexture(EntryTexture(e)); s.icon:Show(); s.plus:Hide(); s:Show()
                                s.procMark:SetShown(e.proc == true); s.barMark:SetShown(e.bar == true and (e.kind == "buff" or e.kind == "debuff"))
                            elseif i == n + 1 and n < MAX_ENTRIES then
                                s.ref, s.isPlus = nil, true; s.icon:Hide(); s.plus:Show(); s.procMark:Hide(); s.barMark:Hide(); s:Show()
                            else
                                s.ref, s.isPlus = nil, false; s.procMark:Hide(); s.barMark:Hide(); s:Hide()
                            end
                        end
                        for _, s in ipairs(c.barSlots) do s:Hide() end
                    end
                    yCur = yCur - rowHeader - boxH - SEC_GAP - 4
                end
            end

            BC:SetHeight(math.max(scroll:GetHeight() or 0, -yCur + 30))
            local maxV = math.max(0, BC:GetHeight() - (scroll:GetHeight() or 0))
            if scroll:GetVerticalScroll() > maxV then scroll:SetVerticalScroll(maxV) end
            NS.Side.child:SetHeight(BC:GetHeight())
            NS.Side.scroll:SetVerticalScroll(scroll:GetVerticalScroll())
        end)
    end

    -- The pages were authored in code order (Adjust, then Class layout); map them
    -- to the visible tabs in the requested order (Class layout, then Adjust).
    pages[1], pages[2] = LP, SP
    trackerPicker = BuildPicker(pane)

    -- ---------- refresh ----------
    TReg(function()
        local gs = db.tracker.groups
        Sel()
        for i = 1, MAX_GROUPS do
            local b, g = gbtns[i], gs[i]
            if g then
                local geo = NS.Side.geom[i]
                b:ClearAllPoints()
                b:SetPoint("TOPLEFT", sideChild, "TOPLEFT", 0, geo and geo.y or -(i - 1) * 74)
                b:SetHeight(geo and geo.h or 62)
                b:Show()
                b.name:SetText(g.name)
                b.sub:SetText(#g.entries .. " icon" .. (#g.entries == 1 and "" or "s") .. (g.enabled and "" or "  (hidden)"))
                local sel = (i == TrackerSel)
                b.bg:SetVertexColor(sel and 0.14 or 0.09, sel and 0.18 or 0.10, sel and 0.25 or 0.12, 1)
                b.glow:SetShown(sel)
                b.strip:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], sel and 1 or 0.25)
                b:SetAlpha(sel and 1 or 0.55)
            else
                b:Hide()
            end
        end
        if #gs >= MAX_GROUPS then newBtn:Hide() else newBtn:Show() end
        local g = Sel()
        if g then
            if not nameBox:HasFocus() then nameBox:SetText(g.name) end
            delBtn:SetShown(g.userCreated == true and g.protected ~= true)
            if g.userCreated ~= true or g.protected then
                pendingDel = nil
                delBtn.label:SetText("Delete group")
            end
            pane:Show()
        else
            pane:Hide()
        end
    end)

    SelectSub(1)
    NS.BoostFonts(E, 2)
    tinsert(UISpecialFrames, "SenBarTrackerEditor")
    E:Hide()
    return E
end

ToggleTracker = function()
    if not trackerEditor then trackerEditor = BuildTrackerEditor() end
    if trackerEditor:IsShown() then
        trackerEditor:Hide()
    else
        -- open to the left of the main SenBar settings panel (shrinks to fit if there is no room)
        local o = _G.SenBarOptions
        if o and o:IsShown() and o:GetLeft() and o:GetTop() then
            local E = trackerEditor
            local u = UIParent:GetEffectiveScale()
            local s = E:GetScale()
            local oLeft = o:GetLeft() * o:GetEffectiveScale()
            local oTop = o:GetTop() * o:GetEffectiveScale()
            if not (db and db.tracker and db.tracker.editorScale) then
                local fit = (oLeft - 10) / (1040 * u)
                if fit < s then s = math.max(0.6, fit); E:SetScale(s) end
            end
            local left = math.max(0, oLeft - 8 - 1040 * s * u)
            E:ClearAllPoints()
            E:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left / (s * u), oTop / (s * u))
        end
        trackerEditor:Show()
    end
end
NS.ProfileTrackerChanged = function()
    tdrag = nil
    TrackerSel = 1
    if trackerPicker then trackerPicker:Hide() end
    if trackerEditor then trackerEditor:SetScale(db.tracker.editorScale or 0.75) end
end
NS.StopTrackerPositionDrag = function()
    tdrag = nil
end
end -- tracker module

-- Position defaults are calculated from the current bar dimensions and scale.
-- Only coordinates change; each group's spells and appearance are preserved.
NS.ResetTrackerPositions = function()
    if not (db and db.tracker and container) then return end
    local unit = UIParent:GetEffectiveScale()
    local scale = container:GetEffectiveScale() / unit
    local left = (container:GetLeft() or 0) * scale
    local top = (container:GetTop() or 0) * scale
    local center = left + container:GetWidth() * scale / 2
    local castBottom = (container:GetBottom() or 0) * scale + DEFAULT_CAST_OFFSET.y * scale
    if castFrame and castFrame:GetBottom() then
        castBottom = castFrame:GetBottom() * castFrame:GetEffectiveScale() / unit
    end
    local customBottom = top + 16
    local function dimensions(g)
        local n, bars = 0, 0
        for _, e in ipairs(g.entries or {}) do
            if e.bar == true and (e.kind == "buff" or e.kind == "debuff") then bars = bars + 1 else n = n + 1 end
        end
        local size, spacing, per = g.size or 31, g.spacing or 2, math.max(1, g.perRow or 10)
        if n == 0 then return 150, size, bars end
        return math.min(n, per) * (size + spacing) - spacing,
            math.ceil(n / per) * (size + spacing) - spacing, bars
    end
    local function place(g, x, y, w, h)
        g.x = x + (g.grow == 1 and 0 or (g.grow == 2 and w or w / 2))
        g.y = y
        -- Saved independent bar positions must also be reset, even if linking is off.
        g.bx, g.by = x, y - h - (g.spacing or 2)
    end
    -- Utility always starts below the cast bar, regardless of group ordering.
    for _, g in ipairs(db.tracker.groups) do
        local name = (g.importKey or g.name or ""):lower()
        local w, h, bars = dimensions(g)
        if name == "essential" then
            place(g, center - w / 2, top + 16 + h, w, h)
            customBottom = math.max(customBottom, top + 32 + h)
        elseif name == "utility" then
            place(g, center - w / 2, castBottom - 16, w, h)
        elseif name == "buff" or name == "buffs" then
            -- Raised icon block, with buff bars to its left as in the reference.
            local x, y = left - 16 - w, top + 80
            place(g, x, y, w, h)
            g.bx = x - 12 - (g.barWidth or 180)
            g.by = y - (g.size or 31) - (g.spacing or 2)
        end
    end
    for _, g in ipairs(db.tracker.groups) do
        local name = (g.importKey or g.name or ""):lower()
        if name ~= "essential" and name ~= "utility" and name ~= "buff" and name ~= "buffs" then
            local w, h, bars = dimensions(g)
            local barSpace = bars > 0 and bars * ((g.barHeight or 18) + (g.spacing or 2)) or 0
            local customTop = customBottom + h + barSpace
            place(g, center - w / 2, customTop, w, h)
            customBottom = customTop + 16
        end
    end
end

NS.ResetPositions = function()
    drag, textDrag, udrag = nil, nil, nil
    db.pos = DeepCopy(defaults.pos)
    db.offsets = DeepCopy(defaults.offsets)
    db.textPos = DeepCopy(defaults.textPos)
    db.minimapAngle = defaults.minimapAngle
    for key, cfg in pairs(db.textCfg or {}) do
        local original = defaults.textCfg[key]
        cfg.x, cfg.y = original and original.x or 0, original and original.y or 0
    end
    Apply() -- settle the bars first so tracker coordinates match their actual size
    NS.ResetTrackerPositions()
    if NS.StopTrackerPositionDrag then NS.StopTrackerPositionDrag() end
    RefreshAll()
    Apply()
end



------------------------------------------------------------
-- Profiles: named copies of every setting (bar positions included)
------------------------------------------------------------
-- not part of a profile: the profile list itself, which one is active, the minimap icon
-- angle and the lock state
local PROFILE_SKIP = {
    profiles = true, currentProfile = true, minimapAngle = true, locked = true, builtinSeeded = true,
    trackerByClass = true, trackerByIdentity = true, profileTrackers = true, panelScale = true,
}

local function ProfileNames()
    local t = {}
    for name in pairs(db.profiles or {}) do t[#t + 1] = name end
    table.sort(t, function(a, b) return a:lower() < b:lower() end)
    return t
end

local function SnapshotSettings()
    local t = {}
    for k, v in pairs(db) do
        if not PROFILE_SKIP[k] then t[k] = (type(v) == "table") and DeepCopy(v) or v end
    end
    return t
end

NS.profileSnapshotSync = function()
    if db and db.currentProfile and db.profiles and db.profiles[db.currentProfile] then
        db.profileTrackers = db.profileTrackers or {}
        db.profileTrackers[db.currentProfile] = db.profileTrackers[db.currentProfile] or {}
        db.profileTrackers[db.currentProfile][NS.TrackerIdentity()] = DeepCopy(db.tracker)
        db.profiles[db.currentProfile] = SnapshotSettings()
    end
end

local function LoadProfile(name)
    local src = db.profiles and db.profiles[name]
    if not src then return false end
    if db.currentProfile ~= name then NS.profileSnapshotSync() end
    local scoped = db.profileTrackers and db.profileTrackers[name]
    local selectedTracker = scoped and scoped[NS.TrackerIdentity()]
    if not selectedTracker and src.tracker and src.tracker.ownerIdentity
        and src.tracker.ownerIdentity ~= NS.TrackerIdentity() then
        selectedTracker = (db.trackerByIdentity or {})[NS.TrackerIdentity()] or defaults.tracker
    end
    local keepPos = (src.pos == nil) and db.pos or nil -- built-in / imported profiles do not move the bars
    local keepTracker = (src.tracker == nil) and db.tracker or nil -- ... and keep your tracker groups
    for k in pairs(db) do
        if not PROFILE_SKIP[k] then db[k] = nil end
    end
    for k, v in pairs(src) do
        if not PROFILE_SKIP[k] then
            db[k] = (type(v) == "table") and DeepCopy(v) or v
        end
    end
    if keepPos then db.pos = keepPos end
    if keepTracker then db.tracker = keepTracker end
    if selectedTracker then db.tracker = DeepCopy(selectedTracker) end
    CopyDefaults(defaults, db) -- profiles saved by an older version miss newer settings
    db.textMigrated = true -- the old text-size migration must never run on a loaded profile
    db.locked = not (options and options:IsShown())
    db.currentProfile = name
    db.trackerByClass = db.trackerByClass or {}
    if db.tracker.ownerIdentity then NS.BindTracker() end
    if NS.AutoImportCooldowns then NS.AutoImportCooldowns() end
    if NS.ProfileTrackerChanged then NS.ProfileTrackerChanged() end
    if swing then swing.mask = nil end
    RefreshAll()
    Apply()
    return true
end

-- Starting profiles: created once per saved-variables file, never overwritten, never recreated
-- after you delete them. A brand new install starts on "Default".
local function SeedProfiles(fresh)
    db.profiles = db.profiles or {}
    if not db.builtinSeeded then
        if not db.profiles["Default"] then
            local d = {}
            for k, v in pairs(defaults) do
                if not PROFILE_SKIP[k] and k ~= "pos" and k ~= "tracker" then d[k] = (type(v) == "table") and DeepCopy(v) or v end
            end
            d.textMigrated = true
            db.profiles["Default"] = d
        end
        for name, data in pairs(BUILTIN_PROFILES) do
            if not db.profiles[name] then db.profiles[name] = DeepCopy(data) end
        end
        db.builtinSeeded = true
    end
    if fresh and db.profiles["Default"] then db.currentProfile = "Default" end
    if not db.currentProfile or not db.profiles[db.currentProfile] then
        if not db.profiles["Default"] then
            local d = {}
            for k, v in pairs(defaults) do
                if not PROFILE_SKIP[k] and k ~= "pos" and k ~= "tracker" then d[k] = (type(v) == "table") and DeepCopy(v) or v end
            end
            d.textMigrated = true
            db.profiles["Default"] = d
        end
        db.currentProfile = "Default"
    end
end

NS.profileSaveFrame = CreateFrame("Frame")
do
    local elapsed = 0
    NS.profileSaveFrame:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + (dt or 0)
        if elapsed >= 1 then
            elapsed = 0
            if NS.profileSnapshotSync then NS.profileSnapshotSync() end
        end
    end)
end

------------------------------------------------------------
-- Share codes: export / import a profile as one line of text
-- format:  SB1!<checksum>!<base64 of a small table with only the settings that differ from the defaults>
------------------------------------------------------------
local EXPORT_SKIP = {
    profiles = true, currentProfile = true, minimapAngle = true, locked = true, builtinSeeded = true,
    pos = true, textPos = true, textMigrated = true, dynMax = true, tracker = true,
    trackerByClass = true, trackerByIdentity = true, profileTrackers = true, panelScale = true,
}
-- limits applied to imported numbers, so a hand-edited code can not break the layout
local CLAMPS = {
    width = { 100, 600 }, healthHeight = { 8, 60 }, powerHeight = { 4, 40 }, gap = { 0, 12 }, scale = { 0.5, 2 },
    comboHeight = { 4, 30 }, comboGap = { 0, 12 }, castWidth = { 80, 700 }, castHeight = { 6, 60 },
    bgAlpha = { 0, 1 }, dynHigh = { 2, 99 }, dynLow = { 0, 98 }, textSize = { 6, 32 },
    swingMainWidth = { 0, 600 }, swingOffWidth = { 0, 600 }, swingRangedWidth = { 0, 600 },
    swingMainHeight = { 4, 40 }, swingOffHeight = { 4, 40 }, swingRangedHeight = { 4, 40 },
    textFormat = { 1, 4 }, textStyle = { 1, #TEXT_STYLES }, visibility = { 1, #VISIBILITY },
}

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64REV = {}
for i = 1, #B64 do B64REV[B64:sub(i, i)] = i - 1 end

local function B64Encode(data)
    local out = {}
    for i = 1, #data, 3 do
        local a, b, c = data:byte(i, i + 2)
        local n = a * 65536 + (b or 0) * 256 + (c or 0)
        local c1, c2 = math.floor(n / 262144) % 64, math.floor(n / 4096) % 64
        local c3, c4 = math.floor(n / 64) % 64, n % 64
        out[#out + 1] = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1)
            .. (b and B64:sub(c3 + 1, c3 + 1) or "=") .. (c and B64:sub(c4 + 1, c4 + 1) or "=")
    end
    return table.concat(out)
end

local function B64Decode(str)
    str = str:gsub("=+$", "")
    local out, n, bits = {}, 0, 0
    for i = 1, #str do
        local v = B64REV[str:sub(i, i)]
        if not v then return nil end
        n, bits = n * 64 + v, bits + 6
        if bits >= 8 then
            bits = bits - 8
            local byte = math.floor(n / 2 ^ bits)
            n = n - byte * 2 ^ bits
            out[#out + 1] = string.char(byte)
        end
    end
    return table.concat(out)
end

local function Hash(s)
    local h = 5381
    for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end
    return string.format("%04x%04x", math.floor(h / 65536), h % 65536)
end

-- tiny serializer / parser for tables of numbers, booleans and strings (never runs code)
local function SerValue(v, out)
    local t = type(v)
    if t == "number" then
        out[#out + 1] = (v ~= v or v == math.huge or v == -math.huge) and "0" or string.format("%.5g", v)
    elseif t == "boolean" then
        out[#out + 1] = v and "true" or "false"
    elseif t == "string" then
        out[#out + 1] = '"' .. (v:gsub('[\\"]', "\\%0")) .. '"'
    elseif t == "table" and #v > 0 then
        out[#out + 1] = "["
        for i = 1, #v do
            if i > 1 then out[#out + 1] = "," end
            SerValue(v[i], out)
        end
        out[#out + 1] = "]"
    elseif t == "table" then
        local keys = {}
        for k in pairs(v) do
            if type(k) == "string" and k:match("^[%a_][%w_]*$") then keys[#keys + 1] = k end
        end
        table.sort(keys)
        out[#out + 1] = "{"
        for i, k in ipairs(keys) do
            if i > 1 then out[#out + 1] = "," end
            out[#out + 1] = k .. "="
            SerValue(v[k], out)
        end
        out[#out + 1] = "}"
    else
        out[#out + 1] = "0"
    end
end

local function ParseValue(s, i, depth)
    if depth > 8 then error("too deep") end
    local c = s:sub(i, i)
    if c == "[" then
        local t = {}
        i = i + 1
        while true do
            local v
            v, i = ParseValue(s, i, depth + 1)
            t[#t + 1] = v
            local d = s:sub(i, i)
            if d == "," then
                i = i + 1
            elseif d == "]" then
                return t, i + 1
            else
                error("expected , or ]")
            end
        end
    elseif c == "{" then
        local t = {}
        i = i + 1
        if s:sub(i, i) == "}" then return t, i + 1 end
        while true do
            local key, e = s:match("^([%a_][%w_]*)=()", i)
            if not key then error("bad key") end
            local v
            v, i = ParseValue(s, e, depth + 1)
            t[key] = v
            local d = s:sub(i, i)
            if d == "," then
                i = i + 1
                if s:sub(i, i) == "}" then return t, i + 1 end
            elseif d == "}" then
                return t, i + 1
            else
                error("expected , or }")
            end
        end
    elseif c == '"' then
        local buf = {}
        i = i + 1
        while true do
            local ch = s:sub(i, i)
            if ch == "" then error("unterminated string") end
            if ch == "\\" then
                buf[#buf + 1] = s:sub(i + 1, i + 1)
                i = i + 2
            elseif ch == '"' then
                return table.concat(buf), i + 1
            else
                buf[#buf + 1] = ch
                i = i + 1
            end
        end
    elseif s:sub(i, i + 3) == "true" then
        return true, i + 4
    elseif s:sub(i, i + 4) == "false" then
        return false, i + 5
    end
    local num, e = s:match("^(-?%d+%.?%d*[eE][%+%-]?%d+)()", i)
    if not num then num, e = s:match("^(-?%d+%.?%d*)()", i) end
    local n = num and tonumber(num)
    if not n then error("bad value") end
    return n, e
end

-- keep only what differs from the defaults (shorter codes, and older codes keep working)
local function Diff(val, def)
    if type(val) == "table" then
        local d, any = {}, false
        local dd = type(def) == "table" and def or {}
        for k, v in pairs(val) do
            local sub = Diff(v, dd[k])
            if sub ~= nil then d[k] = sub; any = true end
        end
        return any and d or nil
    end
    if type(val) == "number" and type(def) == "number" and math.abs(val - def) < 0.00005 then return nil end
    if val == def then return nil end
    return val
end

local function MakeCode(name, data)
    local clean = {}
    for k, v in pairs(data) do
        if not EXPORT_SKIP[k] then clean[k] = v end
    end
    local out = {}
    local payloadTable = { n = tostring(name or ""), v = 1, d = Diff(clean, defaults) or {} }
    local tr = data.tracker
    if type(tr) == "table" then
        local c = DeepCopy(tr)
        -- Numeric spell keys are encoded as a list for the share-code serializer.
        c.autoKnownSpells = nil -- local spellbook baseline, rebuilt on the receiving character
        c.procSpells = {}
        for id, enabled in pairs(tr.procSpells or {}) do
            if enabled and type(id) == "number" then c.procSpells[#c.procSpells + 1] = id end
        end
        table.sort(c.procSpells)
        payloadTable.t = c
    end
    SerValue(payloadTable, out)
    local payload = table.concat(out)
    return "SB1!" .. Hash(payload) .. "!" .. B64Encode(payload)
end

local function SanitizeFree(src, depth)
    local out = {}
    if depth > 4 then return out end
    for k, v in pairs(src) do
        if type(v) == "number" and math.abs(v) <= 5000 then out[k] = v
        elseif type(v) == "table" then out[k] = SanitizeFree(v, depth + 1) end
    end
    return out
end

-- accept only keys and value types that exist in the defaults
local function Sanitize(src, def, root)
    local out = {}
    for k, v in pairs(src) do
        if not (root and EXPORT_SKIP[k]) then
            local dv = def[k]
            if dv ~= nil then
                if type(dv) == type(v) then
                    if type(v) == "table" then
                        out[k] = Sanitize(v, dv, false)
                    elseif type(v) == "number" then
                        if math.abs(v) <= 100000 then out[k] = v end
                    else
                        out[k] = v
                    end
                end
            elseif next(def) == nil and type(v) == "table" then
                out[k] = SanitizeFree(v, 1) -- free-form tables such as the bar offsets
            end
        end
    end
    return out
end

-- returns name, settings   or   nil, error message
local function ParseCode(code)
    code = ((code or ""):gsub("%s+", ""))
    local hash, b64 = code:match("^SB1!(%x+)!(.+)$")
    if not hash then return nil, "That is not a SenBar code." end
    local payload = B64Decode(b64)
    if not payload or Hash(payload) ~= hash then return nil, "The code is damaged or incomplete." end
    local ok, tbl, last = pcall(ParseValue, payload, 1, 0)
    if not ok or type(tbl) ~= "table" or last ~= #payload + 1 or type(tbl.d) ~= "table" then
        return nil, "The code could not be read."
    end
    local data = Sanitize(tbl.d, defaults, true)
    CopyDefaults(defaults, data)
    for k in pairs(EXPORT_SKIP) do data[k] = nil end
    data.tracker = CleanTracker(tbl.t) -- nil when the code has no tracker: loading it keeps yours
    data.textMigrated = true
    for k, lim in pairs(CLAMPS) do
        if type(data[k]) == "number" then
            data[k] = math.max(lim[1], math.min(lim[2], data[k]))
            if lim[1] == 1 and lim[2] <= 20 then data[k] = math.floor(data[k] + 0.5) end
        end
    end
    for _, t in pairs(data.textCfg) do
        if type(t) == "table" then
            t.size = math.max(6, math.min(32, t.size or 12))
            t.x = math.max(-400, math.min(400, t.x or 0))
            t.y = math.max(-200, math.min(200, t.y or 0))
        end
    end
    local name = type(tbl.n) == "string" and tbl.n:sub(1, 24) or ""
    return name, data
end

NS.Share = { MakeCode = MakeCode, ParseCode = ParseCode, Diff = Diff, Hash = Hash }

------------------------------------------------------------
-- Settings panel
------------------------------------------------------------
NS.BuildProfilesUI = function(p, R)
    local function ProfileHeader(text, yy)
        local h = Label(R, text, 13, ACCENT[1], ACCENT[2], ACCENT[3])
        h:SetPoint("TOPLEFT", R, "TOPLEFT", 2, yy)
        local line = R:CreateTexture(nil, "ARTWORK")
        line:SetTexture(WHITE); line:SetVertexColor(0.22, 0.24, 0.30, 1)
        line:SetPoint("TOPLEFT", R, "TOPLEFT", 0, yy - 18)
        line:SetPoint("TOPRIGHT", R, "TOPRIGHT", 0, yy - 18)
        line:SetHeight(1)
    end
    local function Divider(yy)
        local line = R:CreateTexture(nil, "ARTWORK")
        line:SetTexture(WHITE); line:SetVertexColor(0.22, 0.24, 0.30, 1)
        line:SetPoint("TOPLEFT", R, "TOPLEFT", 0, yy)
        line:SetPoint("TOPRIGHT", R, "TOPRIGHT", 0, yy)
        line:SetHeight(1)
    end
    local function Say(msg, bad)
        if R.status then
            R.status:SetText(msg or "")
            if bad then R.status:SetTextColor(1, 0.45, 0.45, 1) else R.status:SetTextColor(0.55, 0.9, 0.72, 1) end
        end
    end
    local modal
    local function ShowModal(titleText, promptText, fieldHeight, initialText, onAccept, acceptText, configure)
        if modal then modal:Hide(); modal = nil end
        local overlay = CreateFrame("Button", nil, p)
        modal = overlay
        overlay:SetAllPoints(p); overlay:SetFrameStrata("DIALOG"); overlay:SetFrameLevel(p:GetFrameLevel() + 80)
        overlay:EnableKeyboard(true); Flat(overlay, 0, 0, 0, 0.58)
        overlay:SetScript("OnClick", function() overlay:Hide(); modal = nil end)
        local box = CreateFrame("Frame", nil, overlay)
        box:SetSize(300, fieldHeight and (fieldHeight + 118) or 164); box:SetPoint("CENTER")
        box:SetFrameLevel(overlay:GetFrameLevel() + 2); Flat(box, 0.075, 0.085, 0.11, 1); Outline(box, 0.32, 0.38, 0.48, 1)
        box:EnableMouse(true)
        local title = Label(box, titleText, 14, 0.58, 0.82, 1); title:SetPoint("TOPLEFT", box, "TOPLEFT", 14, -14)
        local prompt = Label(box, promptText, 11, 0.78, 0.8, 0.86)
        prompt:SetPoint("TOPLEFT", box, "TOPLEFT", 14, -38); prompt:SetWidth(272); prompt:SetJustifyH("LEFT"); prompt:SetWordWrap(true)
        local edit
        if fieldHeight then
            local scroll = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT", box, "TOPLEFT", 14, -62); scroll:SetPoint("TOPRIGHT", box, "TOPRIGHT", -30, -62)
            scroll:SetHeight(fieldHeight)
            edit = CreateFrame("EditBox", nil, scroll); edit:SetMultiLine(true); edit:SetAutoFocus(false)
            edit:SetFont(FONT, 12, ""); edit:SetTextColor(1, 1, 1, 1); edit:SetTextInsets(7, 7, 7, 7)
            edit:SetWidth(250); edit:SetHeight(math.max(fieldHeight, 130)); edit:SetMaxLetters(0); edit:SetText(initialText or "")
            Flat(edit, 0.11, 0.12, 0.15, 1); Outline(edit, 0.26, 0.28, 0.34, 1); scroll:SetScrollChild(edit)
            edit:SetScript("OnEscapePressed", function() edit:ClearFocus(); overlay:Hide(); modal = nil end)
        end
        local errorText = Label(box, "", 10, 1, 0.45, 0.45)
        errorText:SetPoint("BOTTOMLEFT", box, "BOTTOMLEFT", 14, 44)
        errorText:SetWidth(272); errorText:SetJustifyH("LEFT")
        local cancel = MakeButton(box, "Cancel", 86, 26, function() overlay:Hide(); modal = nil end)
        cancel:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -14, 12)
        local accept = MakeButton(box, acceptText or "Confirm", 86, 26, function()
            local result = onAccept and onAccept(edit and edit:GetText() or nil)
            if type(result) == "string" then errorText:SetText(result); return end
            if result == false then return end
            if edit then edit:ClearFocus() end
            overlay:Hide()
            if modal == overlay then modal = nil end
        end)
        accept:SetPoint("RIGHT", cancel, "LEFT", -8, 0)
        overlay:SetScript("OnKeyDown", function(self, key) if key == "ESCAPE" then self:Hide(); modal = nil end end)
        overlay:SetPropagateKeyboardInput(true)
        if configure then configure(box) end
        if edit then edit:SetFocus(); edit:HighlightText() end
    end

    local y = -2
    local profSel = db.currentProfile or "Default"
    local codeValue = ""
    ProfileHeader("Saved profiles", y); Divider(y - 22); y = y - 38
    local picker = MakeButton(R, "", 172, 28, function() end)
    picker:SetPoint("TOPLEFT", R, "TOPLEFT", 6, y)
    picker.label:ClearAllPoints(); picker.label:SetPoint("LEFT", picker, "LEFT", 10, 0); picker.label:SetWidth(142)
    picker.label:SetJustifyH("LEFT"); picker.label:SetText(profSel)
    local caret = Label(picker, "v", 12, 0.65, 0.8, 1); caret:SetPoint("RIGHT", picker, "RIGHT", -9, 0)

    local menu = CreateFrame("Frame", nil, R)
    menu:SetPoint("TOPLEFT", picker, "BOTTOMLEFT", 0, -3); menu:SetWidth(172)
    menu:SetFrameStrata("DIALOG"); menu:SetFrameLevel(p:GetFrameLevel() + 40)
    Flat(menu, 0.07, 0.08, 0.11, 1); Outline(menu, 0.3, 0.35, 0.43, 1); menu:Hide()
    local menuOpen = false
    local function RebuildMenu()
        for _, child in ipairs({ menu:GetChildren() }) do child:Hide(); child:SetParent(nil) end
        local names = ProfileNames(); menu:SetHeight(math.max(28, #names * 26 + 8))
        for i, name in ipairs(names) do
            local item = MakeButton(menu, name, 162, 24, function()
                if db.currentProfile and db.profiles[db.currentProfile] then db.profiles[db.currentProfile] = SnapshotSettings() end
                profSel = name; LoadProfile(name); menu:Hide(); menuOpen = false
                Say("Loaded profile: " .. name)
            end)
            item:SetPoint("TOPLEFT", menu, "TOPLEFT", 5, -4 - (i - 1) * 26)
            item.label:ClearAllPoints(); item.label:SetPoint("LEFT", item, "LEFT", 8, 0); item.label:SetJustifyH("LEFT")
        end
    end
    picker:SetScript("OnClick", function()
        if menuOpen then menu:Hide(); menuOpen = false else RebuildMenu(); menu:Show(); menuOpen = true end
    end)
    local createBtn = MakeButton(R, "Create", 64, 28, function()
        ShowModal("Create profile", "Enter a name for the new profile.", 28, "", function(value)
            local name = (value or ""):match("^%s*(.-)%s*$")
            if name == "" then Say("Enter a profile name.", true); return false end
            name = name:sub(1, 24)
            if db.profiles[name] then Say("A profile with that name already exists.", true); return false end
            if db.currentProfile and db.profiles[db.currentProfile] then db.profiles[db.currentProfile] = SnapshotSettings() end
            db.profiles[name] = SnapshotSettings(); db.currentProfile, profSel = name, name
            Say("Created profile: " .. name); RefreshAll()
        end, "Save")
    end)
    createBtn:SetPoint("LEFT", picker, "RIGHT", 8, 0)
    local deleteBtn = MakeButton(R, "Delete", 64, 28, function()
        if not profSel or not db.profiles[profSel] then Say("Select a profile first.", true); return end
        local deleting = profSel
        ShowModal("Delete profile?", "Delete " .. deleting .. "? This cannot be undone.", nil, nil, function()
            db.profiles[deleting] = nil
            if db.profileTrackers then db.profileTrackers[deleting] = nil end
            local names = ProfileNames()
            if deleting == db.currentProfile then
                local fallback = db.profiles["Default"] and "Default" or names[1]
                if fallback then LoadProfile(fallback) else db.currentProfile = nil end
            end
            if not db.profiles["Default"] then
                local d = {}
                for k, v in pairs(defaults) do if not PROFILE_SKIP[k] and k ~= "pos" and k ~= "tracker" then d[k] = type(v) == "table" and DeepCopy(v) or v end end
                db.profiles["Default"] = d
            end
            profSel = db.currentProfile or "Default"; Say("Deleted profile: " .. deleting); RefreshAll()
        end, "Delete")
    end)
    deleteBtn:SetPoint("LEFT", createBtn, "RIGHT", 6, 0)
    Divider(y - 44); y = y - 60
    local active = Label(R, "", 11, 0.6, 0.85, 1); active:SetPoint("TOPLEFT", R, "TOPLEFT", 8, y); active:SetWidth(300)
    R.status = Label(R, "", 11, 0.55, 0.9, 0.72); R.status:SetPoint("TOPLEFT", R, "TOPLEFT", 8, y - 21); R.status:SetWidth(300)

    y = y - 58; ProfileHeader("Share profiles", y); Divider(y - 22); y = y - 38
    local codePanelText, copyHint
    local exportBtn = MakeButton(R, "Export", 92, 28, function()
        local name = db.currentProfile or profSel or "Default"
        NS.profileSnapshotSync()
        codeValue = MakeCode(name, db.profiles[name] or SnapshotSettings())
        codePanelText:SetText(codeValue)
        codePanelText:SetFocus(); codePanelText:HighlightText()
        if copyHint then copyHint:SetText("") end
        Say("Code ready: press Ctrl+C to copy.")
    end)
    exportBtn:SetPoint("TOPLEFT", R, "TOPLEFT", 8, y)
    local importBtn = MakeButton(R, "Import", 92, 28, function()
        ShowModal("Import profile", "Paste a code, then choose which settings to import.", 132, "", function(value)
            local name, data = ParseCode(value)
            if not name then return data or "Invalid profile code." end
            local useBars, useTracker = true, data.tracker ~= nil
            ShowModal("Choose settings", "Select the settings to import from this profile.", nil, nil, function()
                if not useBars and not useTracker then return "Select at least one category." end
                NS.profileSnapshotSync()
                -- Preserve the current category wherever its checkbox is off.
                local merged = SnapshotSettings()
                if useBars then
                    for k, v in pairs(data) do
                        if k ~= "tracker" and not PROFILE_SKIP[k] then merged[k] = type(v) == "table" and DeepCopy(v) or v end
                    end
                end
                if useTracker then merged.tracker = DeepCopy(data.tracker) end
                local base = (name ~= "" and name or "Imported"):sub(1, 24)
                local target, n = base, 1
                while db.profiles[target] do n = n + 1; target = base:sub(1, 18) .. " (" .. n .. ")" end
                db.profiles[target] = merged
                profSel = target; LoadProfile(target)
                Say("Imported and loaded: " .. target)
                RefreshAll()
            end, "Import", function(box)
                box:SetHeight(220)
                local function Choice(text, yy, get, set, available)
                    local row = CreateFrame("Button", nil, box)
                    row:SetSize(272, 30); row:SetPoint("TOPLEFT", box, "TOPLEFT", 14, yy)
                    local square = CreateFrame("Frame", nil, row)
                    square:SetSize(20, 20); square:SetPoint("LEFT", row, "LEFT", 0, 0)
                    Flat(square, 0.12, 0.14, 0.18, 1); Outline(square, 0.3, 0.45, 0.6, 1)
                    local mark = square:CreateTexture(nil, "OVERLAY")
                    mark:SetAllPoints(); mark:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                    mark:SetShown(get())
                    local label = Label(row, text, 11)
                    label:SetPoint("LEFT", square, "RIGHT", 8, 0)
                    if not available then row:SetAlpha(0.4); row:Disable() end
                    row:SetScript("OnClick", function() set(not get()); mark:SetShown(get()) end)
                end
                Choice("Bars", -72, function() return useBars end, function(v) useBars = v end, true)
                Choice("Cooldown manager icons (tracker)", -108, function() return useTracker end, function(v) useTracker = v end, data.tracker ~= nil)
                if not data.tracker then
                    local note = Label(box, "This older code has no tracker settings.", 10, 0.7, 0.72, 0.8)
                    note:SetPoint("TOPLEFT", box, "TOPLEFT", 14, -145)
                end
            end)
        end, "Import")
    end)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 8, 0)
    local codePanel = CreateFrame("Frame", nil, R); codePanel:SetSize(292, 92)
    codePanel:SetPoint("TOPLEFT", R, "TOPLEFT", 8, y - 40); Flat(codePanel, 0.11, 0.12, 0.15, 1); Outline(codePanel, 0.26, 0.28, 0.34, 1)
    local codeScroll = CreateFrame("ScrollFrame", nil, codePanel, "UIPanelScrollFrameTemplate")
    codeScroll:SetPoint("TOPLEFT", codePanel, "TOPLEFT", 6, -6)
    codeScroll:SetPoint("BOTTOMRIGHT", codePanel, "BOTTOMRIGHT", -26, 6)
    if codeScroll.SetClipsChildren then codeScroll:SetClipsChildren(true) end
    codePanelText = CreateFrame("EditBox", nil, codeScroll)
    codePanelText:SetMultiLine(true); codePanelText:SetAutoFocus(false); codePanelText:SetFont(FONT, 10, "")
    codePanelText:SetTextColor(0.65, 0.86, 1, 1); codePanelText:SetTextInsets(7, 7, 7, 7)
    codePanelText:SetWidth(260); codePanelText:SetHeight(80)
    codeScroll:SetScrollChild(codePanelText)
    codePanelText:SetScript("OnTextChanged", function(self)
        self:SetHeight(math.max(80, self:GetNumLines() * 14 + 20))
        codeScroll:UpdateScrollChildRect()
    end)
    codeScroll:EnableMouseWheel(true)
    codeScroll:SetScript("OnMouseWheel", function(self, delta)
        self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScrollRange(), self:GetVerticalScroll() - delta * 28)))
    end)
    codePanelText:SetMaxLetters(0); codePanelText:SetText("Exported profile code appears here.")
    codePanelText:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local function SelectCode()
        if codeValue == "" then Say("Generate a code with Export first.", true); return false end
        codePanelText:SetText(codeValue); codePanelText:SetFocus(); codePanelText:HighlightText()
        return true
    end
    local selectBtn = MakeButton(R, "Select code", 92, 24, function()
        if SelectCode() then copyHint:SetText("") end
    end)
    selectBtn:SetPoint("TOPLEFT", R, "TOPLEFT", 8, y - 142)
    local copyBtn = MakeButton(R, "Copy code", 92, 24, function()
        if SelectCode() then
            copyHint:SetText("Press Ctrl+C to copy")
            copyHint:SetTextColor(0.65, 0.86, 1, 1)
        end
    end)
    copyBtn:SetPoint("LEFT", selectBtn, "RIGHT", 8, 0)
    copyHint = Label(R, "", 11, 0.55, 0.9, 0.6)
    copyHint:SetPoint("TOPLEFT", R, "TOPLEFT", 8, y - 176)
    -- WoW only permits copying from an EditBox with the user's keyboard shortcut.
    codePanelText:SetScript("OnKeyDown", function(self, key)
        if key == "C" and IsControlKeyDown and IsControlKeyDown() and codeValue ~= "" then
            self:HighlightText()
            copyHint:SetText("Copied")
            copyHint:SetTextColor(0.35, 1, 0.45, 1)
        end
    end)
    Register(function()
        local names = ProfileNames()
        if not profSel or not db.profiles[profSel] then profSel = db.currentProfile or names[1] or "Default" end
        profSel = db.currentProfile or profSel
        picker.label:SetText(profSel); active:SetText("Current profile: " .. (db.currentProfile or "Default"))
        if codeValue ~= "" and not codePanelText:HasFocus() then codePanelText:SetText(codeValue) end
    end)
    return function(onConfirm)
        ShowModal("Reset all settings?", "Restore bar and tracker defaults and reload learned spells? Other saved profiles are kept.", nil, nil, onConfirm, "Reset")
    end
end

local function BuildOptions()
    local p = CreateFrame("Frame", "SenBarOptions", UIParent)
    p:SetSize(360, 720)
    p:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    p:SetFrameStrata("DIALOG")
    p:SetToplevel(true)
    p:EnableMouse(true)
    p:SetClampedToScreen(true)

    -- manual drag: the cursor can never get stuck, it ends with the mouse button
    local pdrag
    p:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        self:Raise()
        local cx, cy = GetCursorPosition()
        local sc = self:GetEffectiveScale()
        pdrag = { dx = self:GetLeft() * sc - cx, dy = self:GetBottom() * sc - cy }
    end)
    p:SetScript("OnMouseUp", function() pdrag = nil end)
    p:SetScript("OnHide", function()
        pdrag = nil
        -- dragging is always locked again when this panel closes
        if db then
            db.locked = true
            Apply()
        end
    end)
    p:SetScript("OnUpdate", function(self)
        if not pdrag then return end
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
            pdrag = nil
            return
        end
        local cx, cy = GetCursorPosition()
        local sc = self:GetEffectiveScale()
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", (cx + pdrag.dx) / sc, (cy + pdrag.dy) / sc)
    end)

    Flat(p, 0.07, 0.07, 0.09, 0.97)
    Outline(p, 0.22, 0.24, 0.30, 1)

    -- header
    local title = Label(p, "SenBar", 16, 1, 1, 1)
    title:SetPoint("TOPLEFT", p, "TOPLEFT", 14, -12)
    local sub = Label(p, "v0.2.1", 11, 0.5, 0.55, 0.65)
    sub:SetPoint("LEFT", title, "RIGHT", 8, -1)

    local close = MakeButton(p, "x", 22, 22, function() p:Hide() end)
    close:SetPoint("TOPRIGHT", p, "TOPRIGHT", -10, -10)

    -- lock / unlock moving the bars (the bars are unlocked whenever this panel opens)
    local lockBtn = MakeButton(p, "", 112, 22, function()
        db.locked = not db.locked
        Apply()
        RefreshAll()
    end)
    lockBtn:SetPoint("TOPRIGHT", p, "TOPRIGHT", -40, -10)
    Register(function()
        if db.locked then
            lockBtn.label:SetText("Bars locked")
            lockBtn.label:SetTextColor(1, 0.55, 0.45, 1)
        else
            lockBtn.label:SetText("Bars unlocked")
            lockBtn.label:SetTextColor(0.55, 0.95, 0.6, 1)
        end
    end)

    local line = p:CreateTexture(nil, "ARTWORK")
    line:SetTexture(WHITE)
    line:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
    line:SetPoint("TOPLEFT", p, "TOPLEFT", 0, -38)
    line:SetPoint("TOPRIGHT", p, "TOPRIGHT", 0, -38)
    line:SetHeight(2)

    -- tabs & pages
    local pages, tabs = {}, {}
    local function CreatePage()
        local pg = CreateFrame("Frame", nil, p)
        pg:SetPoint("TOPLEFT", p, "TOPLEFT", 12, -82)
        pg:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", -12, 56)
        pg:Hide()
        pages[#pages + 1] = pg
        return pg
    end

    local function SelectTab(i)
        for n, pg in ipairs(pages) do
            if n == i then pg:Show() else pg:Hide() end
            local t = tabs[n]
            if t then
                if n == i then t.bar:Show() else t.bar:Hide() end
                t.label:SetTextColor(n == i and 1 or 0.55, n == i and 1 or 0.58, n == i and 1 or 0.65, 1)
            end
        end
    end

    local function AddTab(i, text, x, w)
        local t = CreateFrame("Button", nil, p)
        t:SetSize(w, 26)
        t:SetPoint("TOPLEFT", p, "TOPLEFT", x, -46)
        t.label = Label(t, text, 11)
        t.label:SetPoint("CENTER")
        t.bar = t:CreateTexture(nil, "ARTWORK")
        t.bar:SetTexture(WHITE)
        t.bar:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 1)
        t.bar:SetPoint("BOTTOMLEFT")
        t.bar:SetPoint("BOTTOMRIGHT")
        t.bar:SetHeight(2)
        t:SetScript("OnClick", function() SelectTab(i) end)
        tabs[i] = t
    end
    AddTab(1, "Layout", 12, 58)
    AddTab(2, "Colors", 72, 58)
    AddTab(3, "Text", 132, 48)
    AddTab(4, "Cast / Swing", 182, 92)
    AddTab(5, "Tracker", 276, 62)
    -- Profiles has no tab: it opens from the button at the bottom of the panel

    local y
    local function Row() local v = y; y = y - 30; return v end

    local function Header(page, text, yy)
        local h = Label(page, text, 13, ACCENT[1], ACCENT[2], ACCENT[3])
        h:SetPoint("TOPLEFT", page, "TOPLEFT", 2, yy)
        local ln = page:CreateTexture(nil, "ARTWORK")
        ln:SetTexture(WHITE)
        ln:SetVertexColor(0.22, 0.24, 0.30, 1)
        ln:SetPoint("TOPLEFT", page, "TOPLEFT", 0, yy - 18)
        ln:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, yy - 18)
        ln:SetHeight(1)
    end

    -- 1. Layout (bars + combo row)
    y = -2
    local L = CreatePage()
    AddCheck(L, Row(), "Move freely (each bar on its own)", "moveFreely", false,
        function() if db.moveFreely then PinAll() end end)
    AddCheck(L, Row(), "Show health bar", "showHealth")
    AddCheck(L, Row(), "Show power bar", "showPower")
    AddCheck(L, Row(), "Smooth animation", "smooth")
    AddCheck(L, Row(), "Show minimap icon", "showMinimap")
    AddCheck(L, Row(), "Square minimap (icon follows edge)", "minimapSquare")
    AddSlider(L, Row(), "Width", "width", 100, 600, 2)
    AddSlider(L, Row(), "Health height", "healthHeight", 8, 60, 1)
    AddSlider(L, Row(), "Power height", "powerHeight", 4, 40, 1)
    AddSlider(L, Row(), "Gap", "gap", 0, 12, 1)
    AddSlider(L, Row(), "Scale", "scale", 0.5, 2, 0.05, "%.2f")
    AddCycle(L, Row(), "Visibility", "visibility", VISIBILITY)
    AddCheck(L, Row(), "Show combo points (Rogue / Cat Druid)", "showCombo")
    AddSlider(L, Row(), "Combo height", "comboHeight", 4, 30, 1)
    AddSlider(L, Row(), "Combo spacing", "comboGap", 0, 12, 1)
    local resetBars = MakeButton(L, "Reset bar positions", 170, 24, function()
        db.offsets = {}
        if swing then swing.mask = nil end
        Apply()
    end)
    resetBars:SetPoint("TOPLEFT", L, "TOPLEFT", 10, Row())

    -- 2. Colors
    y = -2
    local K = CreatePage()
    AddCheck(K, Row(), "Class color health (default power colors)", "classColor", false,
        function() if db.classColor then db.healthGradient = false end end)
    Header(K, "Presets", y)
    y = y - 24
    y = AddPresetGrid(K, y) - 2
    Header(K, "Fine tune", y)
    y = y - 24
    local function Pair(l1, g1, l2, g2, p1, p2)
        AddSwatch(K, y, l1, g1, 10, 108, p1)
        if l2 then AddSwatch(K, y, l2, g2, 178, 276, p2) end
        y = y - 28
    end
    -- picking a health color switches to a solid color (gradient off), class color off too
    local function SolidHealth() db.healthGradient = false; db.classColor = false end
    Pair("Health", function() return db.healthColor end, "Mana", function() return db.powerColors.MANA end, SolidHealth)
    Pair("Rage", function() return db.powerColors.RAGE end, "Energy", function() return db.powerColors.ENERGY end)
    Pair("Focus", function() return db.powerColors.FOCUS end, "Combo points", function() return db.comboColor end)
    Pair("Combo (full)", function() return db.comboMaxColor end, "Border", function() return db.borderColor end)
    Pair("Background", function() return db.bgColor end)
    AddSlider(K, y, "Background opacity", "bgAlpha", 0, 1, 0.05, "%.2f")
    y = y - 32

    -- dynamic health color: high / medium / low with adjustable thresholds, optional max color
    local dynRow = AddCheck(K, y, "Dynamic health color (high / medium / low)", "healthGradient", false,
        function() if db.healthGradient then db.classColor = false end end)
    local dyn = CreateFrame("Frame", nil, K)
    dyn:SetPoint("TOPLEFT", dynRow, "BOTTOMLEFT", -10, -4)
    dyn:SetSize(336, 92)
    AddSwatch(dyn, 0, "High", function() return db.gradHigh end, 10, 46)
    AddSwatch(dyn, 0, "Medium", function() return db.gradMid end, 108, 160)
    AddSwatch(dyn, 0, "Low", function() return db.gradLow end, 218, 244)
    -- max color: its own checkbox, the color swatch sits right of the text
    AddCheck(dyn, -28, "Max color (full health)", "maxEnabled")
    local maxSw = AddSwatch(dyn, -28, "", function() return db.gradMax end, 10, 196)
    Register(function() maxSw:SetAlpha(db.maxEnabled and 1 or 0.35) end)
    AddNumBox(dyn, 10, -62, "High from", "dynHigh", 2, 99, function() return db.dynLow + 1, 99 end)
    AddNumBox(dyn, 168, -62, "Low up to", "dynLow", 0, 98, function() return 0, db.dynHigh - 1 end)

    -- swing bar colors, right after the dynamic color block
    local sw = CreateFrame("Frame", nil, K)
    sw:SetSize(336, 52)
    Header(sw, "Swing bars", 0)
    AddSwatch(sw, -26, "Main", function() return db.swingMainColor end, 10, 48)
    AddSwatch(sw, -26, "Off hand", function() return db.swingOffColor end, 108, 164)
    AddSwatch(sw, -26, "Range", function() return db.swingRangedColor end, 226, 272)
    Register(function()
        sw:ClearAllPoints()
        if db.healthGradient then
            dyn:Show()
            sw:SetPoint("TOPLEFT", dyn, "BOTTOMLEFT", 0, -8)
        else
            dyn:Hide()
            sw:SetPoint("TOPLEFT", dynRow, "BOTTOMLEFT", -10, -8)
        end
    end)

    -- 3. Text
    y = -2
    local T = CreatePage()
    AddCycle(T, Row(), "Text format", "textFormat", TEXT_FORMATS)
    AddCycle(T, Row(), "Text style", "textStyle", TEXT_STYLE_NAMES)
    AddCheck(T, Row(), "Show health text", "showHealthText")
    AddCheck(T, Row(), "Show power text", "showPowerText")
    AddCheck(T, Row(), "Show cast text time", "castShowTime")
    AddCheck(T, Row(), "Show cast spell name", "castShowName")
    AddCheck(T, Row(), "Show swing time text", "swingText")

    Header(T, "Size and position of each text", y)
    y = y - 26
    local TEXT_KEYS = { "health", "power", "main", "off", "ranged", "castName", "castTime" }
    local TEXT_NAMES = {
        health = "Health", power = "Power", main = "Main-hand swing", off = "Off-hand swing",
        ranged = "Ranged swing", castName = "Cast spell name", castTime = "Cast time",
    }
    local textSel = 1
    local selFs = Label(T, "Edit text", 12)
    selFs:SetPoint("TOPLEFT", T, "TOPLEFT", 10, y - 4)
    local selSet = ArrowSelect(T, 140, y, 180, function(dir)
        textSel = textSel + dir
        if textSel > #TEXT_KEYS then textSel = 1 elseif textSel < 1 then textSel = #TEXT_KEYS end
        RefreshAll()
    end)
    Register(function() selSet(TEXT_NAMES[TEXT_KEYS[textSel]]) end)
    y = y - 30
    local function TC() return db.textCfg[TEXT_KEYS[textSel]] end
    AddSlider(T, Row(), "Font size", nil, 6, 32, 1, nil, function() return TC().size end, function(v) TC().size = v end)
    AddSlider(T, Row(), "X", nil, -150, 150, 1, nil, function() return TC().x end, function(v) TC().x = v end)
    AddSlider(T, Row(), "Y", nil, -60, 60, 1, nil, function() return TC().y end, function(v) TC().y = v end)
    AddSwatch(T, Row(), "Text color", function() return db.textColor end)
    local resetText = MakeButton(T, "Reset text size and position", 200, 24, function()
        db.textCfg = DeepCopy(defaults.textCfg)
        RefreshAll()
        Apply()
    end)
    resetText:SetPoint("TOPLEFT", T, "TOPLEFT", 10, Row())

    -- 4. Swing timer
    y = -2
    local Wholder = CreatePage()
    local Wscroll = CreateFrame("ScrollFrame", nil, Wholder)
    Wscroll:SetAllPoints()
    local W = CreateFrame("Frame", nil, Wscroll)
    W:SetSize(336, 800)
    Wscroll:SetScrollChild(W)
    Wscroll:EnableMouseWheel(true)
    Wscroll:SetScript("OnMouseWheel", function(self, delta)
        local maxV = math.max(0, W:GetHeight() - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(maxV, self:GetVerticalScroll() - delta * 40)))
    end)
    AddCheck(W, Row(), "Show swing timer", "showSwing")
    AddCheck(W, Row(), "Show main-hand bar", "showSwingMain")
    AddCheck(W, Row(), "Show off-hand bar (dual wield)", "showSwingOff")
    AddCheck(W, Row(), "Show ranged bar (Auto Shot / Shoot)", "showSwingRanged")
    AddCheck(W, Row(), "Show spark on the bar edge", "swingSpark")
    local function SwingGroup(title, pre)
        Header(W, title, y)
        y = y - 24
        AddSlider(W, Row(), "Width (0 = same)", pre .. "Width", 0, 600, 2)
        AddSlider(W, Row(), "Height", pre .. "Height", 4, 40, 1)
    end
    SwingGroup("Main hand", "swingMain")
    SwingGroup("Off hand", "swingOff")
    SwingGroup("Ranged", "swingRanged")
    local swHint = Label(W, "", 11, 0.55, 0.6, 0.7)
    swHint:SetPoint("TOPLEFT", W, "TOPLEFT", 10, y - 2)
    swHint:SetJustifyH("LEFT")
    swHint:SetText("Colors are in the Colors tab, text options in the Text tab.\nDrag a bar with the mouse to place it.")

    -- the cast bar shares the page with the swing timers (mouse wheel scrolls)
    y = y - 52
    Header(W, "Cast bar", y)
    y = y - 26
    local C = W
    AddCheck(C, Row(), "Show cast bar", "showCast")
    AddCheck(C, Row(), "Show spark on the bar edge", "castSpark")
    AddSlider(C, Row(), "Width", "castWidth", 80, 700, 2)
    AddSlider(C, Row(), "Height", "castHeight", 6, 60, 1)
    AddSwatch(C, Row(), "Cast color", function() return db.castColor end)
    AddSwatch(C, Row(), "Channel color", function() return db.channelColor end)
    local cHint = Label(C, "", 11, 0.55, 0.6, 0.7)
    cHint:SetPoint("TOPLEFT", C, "TOPLEFT", 10, y - 4)
    cHint:SetJustifyH("LEFT")
    cHint:SetText("A preview plays while this panel is open. Spell name and time\ntext are in the Text tab. Drag the bar to place it.\nBlizzard's cast bar is not touched.")

    W:SetHeight(math.abs(y) + 70)

    -- 6. Tracker (the full editor is its own window)
    y = -2
    local TK = CreatePage()
    Header(TK, "Cooldown tracker", y)
    y = y - 30
    TCheck(TK, 10, y, "Enable tracker", function() return db.tracker.enabled end, function(v) db.tracker.enabled = v end)
    y = y - 28
    TCheck(TK, 10, y, "Hide the Blizzard Cooldown Manager", function() return db.tracker.hideBlizzard end,
        function(v) db.tracker.hideBlizzard = v end)
    y = y - 40
    local openBtn = MakeButton(TK, "Open the tracker editor", 220, 30, function() ToggleTracker() end)
    openBtn:SetPoint("TOPLEFT", TK, "TOPLEFT", 10, y)
    y = y - 46
    local tInfo = Label(TK, "", 11, 0.55, 0.6, 0.7)
    tInfo:SetPoint("TOPLEFT", TK, "TOPLEFT", 10, y)
    tInfo:SetJustifyH("LEFT")
    tInfo:SetText("Build your own icon groups for class spells, buffs, debuffs\nand items, with timers, stacks and a pulse when ready.\n\nThe tracker hides Blizzard's Cooldown Manager by default. It\nautomatically adds learned active spells and updates when your\nspellbook changes. You can also import manually in the editor.")
    local tCount = Label(TK, "", 12, 0.6, 0.85, 1)
    tCount:SetPoint("TOPLEFT", TK, "TOPLEFT", 10, y - 96)
    Register(function()
        TrackerRefreshUI()
        local n = #db.tracker.groups
        tCount:SetText("Groups: " .. n .. " / " .. TrackerMaxGroups)
    end)

    -- 7. Profiles
    local R = CreatePage()
    local profilesPageIndex = #pages
    local showProfileResetModal = NS.BuildProfilesUI(p, R)

    -- footer
    local resetPos = MakeButton(p, "Reset position", 96, 26, function()
        NS.ResetPositions()
    end)
    resetPos:SetPoint("BOTTOMLEFT", p, "BOTTOMLEFT", 12, 16)

    local profilesBtn = MakeButton(p, "Profiles", 86, 26, function() SelectTab(profilesPageIndex) end)
    profilesBtn.bg:SetVertexColor(0.12, 0.45, 0.72, 1)
    profilesBtn:SetScript("OnEnter", function(self) self.bg:SetVertexColor(0.18, 0.58, 0.88, 1) end)
    profilesBtn:SetScript("OnLeave", function(self) self.bg:SetVertexColor(0.12, 0.45, 0.72, 1) end)
    profilesBtn:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", -12, 16)

    local resetAll = MakeButton(p, "Reset all settings", 112, 26, function()
        showProfileResetModal(function()
            NS.profileSnapshotSync()
            local keep = db.profiles
            for k in pairs(db) do db[k] = nil end
            CopyDefaults(defaults, db)
            db.profiles = keep or {}
            db.builtinSeeded = true
            db.currentProfile = "Default"
            db.profiles["Default"] = SnapshotSettings()
            db.tracker = DeepCopy(defaults.tracker)
            db.trackerByClass = {}
            NS.BindTracker()
            db.locked = false
            p:SetScale(1)
            if NS.ProfileTrackerChanged then NS.ProfileTrackerChanged() end
            if NS.AutoImportCooldowns then NS.AutoImportCooldowns() end
            if swing then swing.mask = nil end
            NS.ResetPositions()
        end)
    end)
    resetAll:SetPoint("BOTTOMLEFT", resetPos, "BOTTOMRIGHT", 6, 0)

    -- resize grip, bottom right: drag to make the whole panel smaller or bigger
    if type(db.panelScale) == "number" then p:SetScale(math.max(0.6, math.min(1.5, db.panelScale))) end
    local pgrip = CreateFrame("Button", nil, p)
    pgrip:SetSize(18, 18)
    pgrip:SetPoint("BOTTOMRIGHT", p, "BOTTOMRIGHT", -2, 2)
    pgrip:SetFrameLevel(p:GetFrameLevel() + 30)
    pgrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    pgrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    pgrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    local pgdrag
    pgrip:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" then return end
        local es = p:GetEffectiveScale()
        pgdrag = { left = p:GetLeft() * es, top = p:GetTop() * es }
    end)
    pgrip:SetScript("OnMouseUp", function()
        if pgdrag then db.panelScale = p:GetScale() end
        pgdrag = nil
    end)
    pgrip:SetScript("OnUpdate", function()
        if not pgdrag then return end
        if IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
            db.panelScale = p:GetScale()
            pgdrag = nil
            return
        end
        local cx = GetCursorPosition()
        local u = UIParent:GetEffectiveScale()
        local ns = math.max(0.6, math.min(1.5, (cx - pgdrag.left) / (360 * u)))
        p:SetScale(ns)
        p:ClearAllPoints()
        p:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", pgdrag.left / (ns * u), pgdrag.top / (ns * u))
    end)

    p.Refresh = RefreshAll
    p:SetScript("OnShow", function()
        p:SetFrameStrata("DIALOG"); p:SetToplevel(true); p:Raise()
        -- bars can be dragged while this panel is open (locked again when it closes)
        db.locked = false
        Apply()
        RefreshAll()
    end)
    tinsert(UISpecialFrames, "SenBarOptions")
    SelectTab(1)
    p:Hide()
    return p
end

ToggleOptions = function()
    if not options then options = BuildOptions() end
    if options:IsShown() then options:Hide() else options:Show() end
end

------------------------------------------------------------
-- Init
------------------------------------------------------------
local function Init()
    local fresh = (SenBarDB == nil and YurriBarsDB == nil and ForeverBarsDB == nil)
    if not SenBarDB then
        -- one-time migration from the previous names of this addon
        local old = YurriBarsDB or ForeverBarsDB
        SenBarDB = old and DeepCopy(old) or {}
    end
    db = SenBarDB
    if db.classColor == nil and db.healthMode == 1 then db.classColor = true end
    CopyDefaults(defaults, db)
    db.locked = true
    if not db.textMigrated then
        -- older versions had one text size and drag offsets for health / power only
        local old, sz = db.textPos, db.textSize or 12
        for _, k in ipairs({ "health", "power" }) do
            db.textCfg[k].size = sz
            local tp = old and old[k]
            if tp then db.textCfg[k].x, db.textCfg[k].y = tp.x or 0, tp.y or 0 end
        end
        db.textMigrated = true
    end

    SeedProfiles(fresh)

    playerClass = select(2, UnitClass("player"))

    -- Never adopt the last character's active tracker for a new class.
    db.trackerByClass = db.trackerByClass or {}
    db.trackerByIdentity = db.trackerByIdentity or {}
    local identity = NS.TrackerIdentity()
    local legacy = db.trackerByClass[playerClass]
    for key in pairs(db.trackerByIdentity) do
        if key:match("^([^:]+):") == playerClass then legacy = nil; break end
    end
    if not legacy and not next(db.trackerByClass) then legacy = db.tracker end
    db.tracker = db.trackerByIdentity[identity]
        or (legacy and DeepCopy(legacy)) or DeepCopy(defaults.tracker)
    if db.tracker.ownerIdentity and db.tracker.ownerIdentity ~= identity then
        db.tracker = DeepCopy(defaults.tracker)
    end
    -- Legacy ownership is checked only after the spellbook is ready.
    CopyDefaults(defaults.tracker, db.tracker)

    container = CreateFrame("Frame", "SenBarFrame", UIParent)
    container:SetFrameStrata("LOW")
    container:SetClampedToScreen(true)

    health = CreateBar(container, "health")
    power = CreateBar(container, "power")

    combo = CreateFrame("Frame", nil, container)
    combo.segs = {}
    for i = 1, 5 do
        local seg = CreateFrame("Frame", nil, combo)
        seg.bg = seg:CreateTexture(nil, "BACKGROUND")
        seg.bg:SetAllPoints()
        seg.bg:SetTexture(WHITE)
        seg.fill = seg:CreateTexture(nil, "ARTWORK")
        seg.fill:SetPoint("TOPLEFT", seg, "TOPLEFT", 1, -1)
        seg.fill:SetPoint("BOTTOMRIGHT", seg, "BOTTOMRIGHT", -1, 1)
        seg.fill:SetTexture(WHITE)
        seg.edges = Outline(seg, 0, 0, 0, 1)
        combo.segs[i] = seg
    end

    playerGUID = UnitGUID("player")
    for _, id in ipairs(NEXT_SWING_IDS) do
        local n = SpellName(id)
        if n then nextSwingNames[n] = true end
    end
    swing = CreateFrame("Frame", nil, container)
    swing:SetSize(1, 1)
    swing.bars = {}
    for _, key in ipairs(SWING_ORDER) do
        swing.bars[key] = CreateSwingBar(swing, key)
        swing.bars[key]:Hide()
    end
    for key, bar in pairs(swing.bars) do
        bar:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then BeginUnitDrag(key, self) end
        end)
        bar:SetScript("OnMouseUp", function() udrag = nil; StopDrag() end)
    end

    combo:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then BeginUnitDrag("combo", self) end
    end)
    combo:SetScript("OnMouseUp", function() udrag = nil; StopDrag() end)

    castFrame = CreateCastBar()
    castFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then BeginUnitDrag("cast", self) end
    end)
    castFrame:SetScript("OnMouseUp", function() udrag = nil; StopDrag() end)
    local cev = CreateFrame("Frame")
    for _, e in ipairs(CAST_EVENTS) do
        if not pcall(cev.RegisterUnitEvent, cev, e, "player") then pcall(cev.RegisterEvent, cev, e) end
    end
    cev:SetScript("OnEvent", CastEvent)

    local sev = CreateFrame("Frame")
    sev:RegisterEvent("PLAYER_ENTER_COMBAT")
    sev:RegisterEvent("PLAYER_LEAVE_COMBAT")
    pcall(sev.RegisterEvent, sev, "UNIT_COMBAT")
    -- real swing events when the client has them (no combat log needed)
    if Enum and Enum.PlayerSwingType then
        swingStats.api = pcall(sev.RegisterEvent, sev, "PLAYER_SWING") and true or false
    end
    sev:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    sev:SetScript("OnEvent", SwingEvent)

    container.unlockTex = container:CreateTexture(nil, "OVERLAY")
    container.unlockTex:SetAllPoints()
    container.unlockTex:SetTexture(WHITE)
    container.unlockTex:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.18)
    container.unlockLabel = Label(container, "SenBar - drag bars to move", 11, 0.6, 0.85, 1)
    container.unlockLabel:SetPoint("BOTTOM", container, "TOP", 0, 4)

    container:SetScript("OnMouseDown", function(self, button)
        if db.locked or button ~= "LeftButton" then return end
        local cx, cy = GetCursorPosition()
        BeginGroupDrag(cx, cy)
    end)
    container:SetScript("OnMouseUp", function() StopDrag() end)
    container:SetScript("OnHide", function() StopDrag() end)

    minimap = CreateMinimapButton()

    container:SetScript("OnUpdate", OnUpdate)
    StartTrackerDriver()
    Apply()
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("PLAYER_LOGIN")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:RegisterEvent("SPELLS_CHANGED")
ev:RegisterEvent("PLAYER_LEVEL_UP")
ev:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then Init() end
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" or event == "PLAYER_LEVEL_UP" then
        if C_Timer and C_Timer.After then
            C_Timer.After(2, function()
                if db and NS.AutoImportCooldowns then NS.AutoImportCooldowns() end
            end)
        elseif db and NS.AutoImportCooldowns then
            NS.AutoImportCooldowns()
        end
    end
end)

SLASH_SENBAR1 = "/sb"
SLASH_SENBAR2 = "/senbar"
SlashCmdList["SENBAR"] = function(msg)
    if not db then return end
    msg = (msg or ""):lower()
    if msg == "lock" then
        db.locked = true
        Apply()
        RefreshAll()
    elseif msg == "unlock" then
        db.locked = false
        Apply()
        RefreshAll()
    elseif msg == "minimap" then
        db.showMinimap = not db.showMinimap
        Apply()
        RefreshAll()
    elseif msg == "debug" then
        local cur, max = UnitHealth("player"), UnitHealthMax("player")
        print("|cff40bfffSenBar|r health secret:", tostring(IsSecret(cur) or IsSecret(max)),
            "| text shown:", tostring(db.showHealthText), "| text:", tostring(health.text:GetText()),
            "| combo:", tostring(GetCombo()), "| class:", tostring(playerClass),
            "| color curve:", tostring(healthCurve ~= nil), "| UnitHealthPercent:", tostring(UnitHealthPercent ~= nil))
        print("|cff40bfffSenBar|r swing: PLAYER_SWING api:", tostring(swingStats.api), "| events:", tostring(swingStats.events),
            "| melee attacking:", tostring(IsMeleeAttacking()),
            "| melee swings timed:", tostring(swingStats.melee), "| ranged shots seen:", tostring(swingStats.ranged),
            "| attack speed secret:", tostring(IsSecret((UnitAttackSpeed("player")))))
    elseif msg == "reset" then
        db.pos = DeepCopy(defaults.pos)
        Apply()
    elseif msg == "auradebug" then
        NS.TrackerAuraDebug()
    elseif msg == "dur" or msg:match("^dur%s") then
        NS.Est.Command(msg:match("^dur%s*(.*)$"))
    elseif msg == "auradump" then
        NS.Auto.Dump()
    elseif msg == "profiles" then
        local names = ProfileNames()
        print("|cff40bfffSenBar|r profiles:", #names > 0 and table.concat(names, ", ") or "none",
            "| active:", tostring(db.currentProfile))
    elseif msg:match("^profile%s+%S") then
        local want = msg:match("^profile%s+(.-)%s*$")
        local found
        for _, nm in ipairs(ProfileNames()) do
            if nm:lower() == want then found = nm end
        end
        if found and LoadProfile(found) then
            print("|cff40bfffSenBar|r loaded profile \"" .. found .. "\"")
        else
            print("|cff40bfffSenBar|r no profile named \"" .. want .. "\" (see /sb profiles)")
        end
    else
        ToggleOptions()
    end
end

-- Dedicated cooldown tracker command.
SLASH_SENBARCOOLDOWNS1 = "/sbc"
SlashCmdList["SENBARCOOLDOWNS"] = function(msg)
    if not db then return end
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "on" or msg == "off" then
        db.tracker.enabled = msg == "on"
        TrackerApply()
        RefreshAll()
        if NS.profileSnapshotSync then NS.profileSnapshotSync() end
        print("|cff40bfffSenBar|r tracker " .. (db.tracker.enabled and "enabled" or "disabled"))
    else
        ToggleTracker()
    end
end

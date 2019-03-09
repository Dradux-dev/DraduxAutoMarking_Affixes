local Reaping = DraduxAutoMarking:NewModule("Reaping", "AceEvent-3.0")

function Reaping:OnInitialize()
    Reaping.tracking = false
    Reaping.affixID = 117
    Reaping:Disable()
end

function Reaping:OnEnable()
    local Affixes = DraduxAutoMarking:GetModule("Affixes")
    Affixes:AddDefaultConfigurations(Reaping:GetName(), Reaping.enemies)

    DraduxAutoMarking:AddMenuEntry("Reaping", "Interface\\Addons\\DraduxAutoMarking_Affixes\\media\\reaping", Reaping, Affixes)

    Reaping:RegisterEvent("PLAYER_ENTERING_WORLD")
    Reaping:RegisterEvent("CHALLENGE_MODE_START")
    Reaping:RegisterEvent("CHALLENGE_MODE_RESET")
    Reaping:RegisterEvent("CHALLENGE_MODE_COMPLETED")
end

function Reaping:IsMarking()
    return Reaping.tracking
end

function Reaping:CheckAffix()
    local affixFound = false
    local cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();
    for i, affixID in ipairs(affixes) do
        local affixName = C_ChallengeMode.GetAffixInfo(affixID)
        print(string.format("Checking affixes: Actual=%d (%s), Expected=%d", affixID, affixName, Reaping.affixID))
        if affixID == Reaping.affixID then
            print("Affix Found")
            affixFound = true
        end

        local affixName, affixDesc, affixNum = C_ChallengeMode.GetAffixInfo(affixID)
        print(string.format("%d - %s (%d)", affixNum, affixName, affixID))
    end

    if affixFound then
        Reaping.tracking = true
        Reaping:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(Reaping:GetName())
        DraduxAutoMarking:TrackCombatLog()
    else
        Reaping.tracking = false
        Reaping:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(Reaping:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function Reaping:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(Reaping.enemies, function(id, name, hideInfo, extraConfiguration)
        Reaping:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function Reaping:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not Reaping.configurationFrames then
        Reaping.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = Reaping.mdtDungeon
    }

    if not Reaping.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local Affixes = DraduxAutoMarking:GetModule("Affixes")
            return Affixes:GetDB(Reaping:GetName())
        end)

        Reaping.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(Reaping.configurationFrames[id])
    end

    Reaping.configurationFrames[id]:Load()
end

function Reaping:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), Reaping:GetName(), specialName))
    return false
end

function Reaping:NAME_PLATE_UNIT_ADDED(event, unit)
    local Affixes = DraduxAutoMarking:GetModule("Affixes")
    Affixes:NameplateUnitAdded(Reaping:GetName(), unit)
end

function Reaping:PLAYER_ENTERING_WORLD()
    Reaping:CheckAffix()
end

function Reaping:CHALLENGE_MODE_START()
    print("Challenge Mode started")
    Reaping:CheckAffix()
end

function Reaping:CHALLENGE_MODE_RESET()
    print("Challenge Mode resetted")
    Reaping.tracking = false
    Reaping:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    DraduxAutoMarking:StopScanner(Reaping:GetName())
    DraduxAutoMarking:UntrackCombatLog()
end

function Reaping:CHALLENGE_MODE_COMPLETED()
    print("Challenge Mode completed")
    Reaping.tracking = false
    Reaping:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    DraduxAutoMarking:StopScanner(Reaping:GetName())
    DraduxAutoMarking:UntrackCombatLog()
end
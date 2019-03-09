local Explosive = DraduxAutoMarking:NewModule("Explosive", "AceEvent-3.0")

function Explosive:OnInitialize()
    Explosive.tracking = false
    Explosive.affixID = 13
    Explosive:Disable()
end

function Explosive:OnEnable()
    local Affixes = DraduxAutoMarking:GetModule("Affixes")
    Affixes:AddDefaultConfigurations(Explosive:GetName(), Explosive.enemies)

    DraduxAutoMarking:AddMenuEntry("Explosive", "Interface\\Addons\\DraduxAutoMarking_Affixes\\media\\explosive", Explosive, Affixes)

    Explosive:RegisterEvent("PLAYER_ENTERING_WORLD")
    Explosive:RegisterEvent("CHALLENGE_MODE_START")
    Explosive:RegisterEvent("CHALLENGE_MODE_RESET")
    Explosive:RegisterEvent("CHALLENGE_MODE_COMPLETED")
end

function Explosive:IsMarking()
    return Explosive.tracking
end

function Explosive:CheckAffix()
    local affixFound = false
    local cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();
    for i, affixID in ipairs(affixes) do
        if affixID == Explosive.affixID then
            affixFound = true
        end

        local affixName, affixDesc, affixNum = C_ChallengeMode.GetAffixInfo(affixID)
        print(string.format("%d - %s (%d)", affixNum, affixName, affixID))
    end

    if affixFound then
        Explosive.tracking = true
        Explosive:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StartScanner(Explosive:GetName())
        DraduxAutoMarking:TrackCombatLog()
    else
        Explosive.tracking = false
        Explosive:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        DraduxAutoMarking:StopScanner(Explosive:GetName())
        DraduxAutoMarking:UntrackCombatLog()
    end
end

function Explosive:ShowConfiguration()
    DraduxAutoMarking:ShowConfiguration(Explosive.enemies, function(id, name, hideInfo, extraConfiguration)
        Explosive:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    end)
end

function Explosive:AddEnemyConfiguration(id, name, hideInfo, extraConfiguration)
    if not Explosive.configurationFrames then
        Explosive.configurationFrames = {}
    end

    local info = {
        hide = hideInfo,
        mdtDungeon = Explosive.mdtDungeon
    }

    if not Explosive.configurationFrames[id] then
        local frame = DraduxAutoMarking:AddEnemyConfiguration(id, name, info, extraConfiguration, function()
            local Affixes = DraduxAutoMarking:GetModule("Affixes")
            return Affixes:GetDB(Explosive:GetName())
        end)

        Explosive.configurationFrames[id] = frame
    else
        DraduxAutoMarking:AddContentFrame(Explosive.configurationFrames[id])
    end

    Explosive.configurationFrames[id]:Load()
end

function Explosive:HandleSpecial(unit, npc, specialName)
    print(string.format("%s - %s: Unknown special name \"%s\"", DraduxAutoMarking:GetName(), Explosive:GetName(), specialName))
    return false
end

function Explosive:NAME_PLATE_UNIT_ADDED(event, unit)
    local Affixes = DraduxAutoMarking:GetModule("Affixes")
    Affixes:NameplateUnitAdded(Explosive:GetName(), unit)
end

function Explosive:PLAYER_ENTERING_WORLD()
    Explosive:CheckAffix()
end

function Explosive:CHALLENGE_MODE_START()
    Explosive:CheckAffix()
end

function Explosive:CHALLENGE_MODE_RESET()
    Explosive.tracking = false
    Explosive:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    DraduxAutoMarking:StopScanner(Explosive:GetName())
    DraduxAutoMarking:UntrackCombatLog()
end

function Explosive:CHALLENGE_MODE_COMPLETED()
    Explosive.tracking = false
    Explosive:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    DraduxAutoMarking:StopScanner(Explosive:GetName())
    DraduxAutoMarking:UntrackCombatLog()
end
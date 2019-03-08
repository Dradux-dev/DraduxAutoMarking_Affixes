local Affixes = DraduxAutoMarking:NewModule("Affixes")

local defaultSavedVars = {
    profile = {}
}

function Affixes:OnEnable()
    Affixes.db = LibStub("AceDB-3.0"):New("DraduxAutoMarkingAffixesDB", defaultSavedVars)

    DraduxAutoMarking:EnableModule("Explosive")
    DraduxAutoMarking:EnableModule("Reaping")
end

function Affixes:GetDB(moduleName)
    if not Affixes.db then
        Affixes.db = LibStub("AceDB-3.0"):New("DraduxAutoMarkingAffixesDB", defaultSavedVars)
    end

    if not Affixes.db.profile[moduleName] then
        Affixes.db.profile[moduleName] = {}
    end

    return Affixes.db.profile[moduleName]
end

function Affixes:SetDB(moduleName, db)
    if not Affixes.db then
        Affixes.db = LibStub("AceDB-3.0"):New("DraduxAutoMarkingAffixesDB", defaultSavedVars)
    end

    if not db then
        db = defaultSavedVars.profile[moduleName]
    end

    Affixes.db.profile[moduleName] =  db
end

function Affixes:GetNpcConfiguration(moduleName, npc_id)
    local db = Affixes:GetDB(moduleName)
    return db[npc_id]
end

function Affixes:AddDefaultConfiguration(moduleName, npc_id, data)
    if not defaultSavedVars.profile[moduleName] then
        defaultSavedVars.profile[moduleName] = {}
    end

    defaultSavedVars.profile[moduleName][npc_id] = data
end

function Affixes:AddDefaultConfigurations(moduleName, enemies)
    for id, entry in pairs(enemies) do
        local configuration = {
            markers = entry.markers
        }

        if entry.specials then
            configuration.specials = {}

            for specialName, data in pairs(entry.specials) do
                configuration.specials[specialName] = data.defaultVars
            end
        end

        Affixes:AddDefaultConfiguration(moduleName, id, configuration)
    end
end

function Affixes:NameplateUnitAdded(moduleName, unit)
    local guid = UnitGUID(unit)
    local npc_id = DraduxAutoMarking:GetNpcID(guid)

    local Affixes = DraduxAutoMarking:GetModule("Affixes")
    local npc = Affixes:GetNpcConfiguration(moduleName, npc_id)
    if npc then
        local markers = npc.markers

        if npc.specials then
            for index, special in ipairs(npc.specials) do
                if AtalDazar:HandleSpecial(unit, npc, special.name) then
                    markers = npc.special.markers
                end
            end
        end

        if markers then
            DraduxAutoMarking:RequestMarker(unit, true, markers, {
                onMarkerSet = "NONE",
                onMarkerIsMissing = "RELEASE",
                onDamageTaken = "LOCK",
                onNoDamageTaken = "UNLOCK",
                onUnitDied = "RELEASE",
                onUnitDoesNotExists = "NONE"
            })
        end
    end
end

function Affixes:Dump()
    for id=1, 200 do
        local name, desc, num = C_ChallengeMode.GetAffixInfo(id)
        if name then
            print(string.format("%d - %s", id, name))
        end
    end

    --[[local id = 1
    --    local name
    --    while id == 1 or name do
    --        name = C_ChallengeMode.GetAffixInfo(id)
    --        if name then
    --            print(string.format("%d - %s", id, name))
    --        end
    --
    --        id = id + 1
    --    end]]
end
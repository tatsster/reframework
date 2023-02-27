local error = ""

local augments = {}


local Glyph_ranges = {
    0x0020, 0x00FF, -- Basic Latin + Latin Supplement
    0x2000, 0x206F, -- General Punctuation
    0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
    0x31F0, 0x31FF, -- Katakana Phonetic Extensions
    0x4e00, 0x9FFF, -- CJK Ideograms
    0xFF00, 0xFFEF, -- Half-width characters
    0,
}

local language_font = {}
language_font[0] = "NotoSansJP-Regular.otf"
language_font[11] = "NotoSansKR-Regular.otf"
language_font[12] = "NotoSansTC-Regular.otf"
language_font[13] = "NotoSansSC-Regular.otf"

for i,v in pairs(language_font) do
    language_font[i] = imgui.load_font(v, 19, Glyph_ranges)
end

for i = 58, 149 do
    augments[i] = {}
end

local Color = {
    White   = 0xFFFFFFFF,
    Black   = 0xFF000000,
    Gray    = 0xFFAEAEAE,
    Pink    = 0xFFB973EF,
    Yellow  = 0xFF71FFFF,
    Amber   = 0xFF55B3FF,
    Orange  = 0xFF1673FF,
    Red     = 0xFF0D4BFF,
    Green   = 0xFF96E126,
    Purple  = 0xFFE140A5,
    Blue    = 0xFFFF6E47,
    Cyan    = 0xFFFFAA5A,
    Skyblue = 0xFFFFCDA0,
    Brown   = 0xFF4F789B,
    Rare8   = 0xFFFFDE67,
    Rare9   = 0xffFF314E,
    Rare10  = 0xff0A54F4
}

local rarityColors = {}
rarityColors[7] = Color.Rare8
rarityColors[8] = Color.Rare9
rarityColors[9] = Color.Rare10

local CustomColorTypes = {}
CustomColorTypes[0] = Color.Red
CustomColorTypes[1] = Color.Yellow
CustomColorTypes[2] = Color.Orange
CustomColorTypes[3] = Color.Green
CustomColorTypes[4] = Color.Cyan
CustomColorTypes[5] = Color.Cyan
CustomColorTypes[6] = Color.Blue
CustomColorTypes[7] = Color.Purple
CustomColorTypes[8] = Color.Purple
CustomColorTypes[9] = Color.White

local defenseBonuses = {}
defenseBonuses[1] = {3,4,6,7,9,10,11,18,19,20,27,29,31,36,38,40}
defenseBonuses[2] = {2,3,4,6,6,7,8,14,15,16,20,22,24,28,30,32}
defenseBonuses[3] = {2,3,4,6,7,8,9,11,12,13,18,19,20,22,24,26}
defenseBonuses[4] = {1,3,4,5,5,6,7,8,9,10,12,13,14,16,18,20}
defenseBonuses[5] = {1,2,3,4,4,5,6,6,7,8,10,11,12,12,14,16}
defenseBonuses[6] = {1,1,2,2,2,3,4,4,5,6,6,7,8,8,10,12}
defenseBonuses[13] = {1,1,2,2,2,3,4,4,5,6,6,7,8,8,10,12}

local weaponCombo = {}
weaponCombo[1] = "None"
weaponCombo[2] = "Attack Boost Lv 1"
weaponCombo[3] = "Attack Boost Lv 2"
weaponCombo[4] = "Attack Boost Lv 3"
weaponCombo[5] = "Affinity Boost Lv 1"
weaponCombo[6] = "Element Boost Lv 1"
weaponCombo[7] = "Element Boost Lv 2"
weaponCombo[8] = "Element Boost Lv 3"
weaponCombo[9] = "Element Boost Lv 4"
weaponCombo[10] = "Element Boost Lv 5"
weaponCombo[11] = "Status Effect Boost Lv 1" 
weaponCombo[12] = "Status Effect Boost Lv 2" 
weaponCombo[13] = "Sharpness Boost Lv 1"     
weaponCombo[14] = "Rampage Slot Upgrade Lv 1"

local sortedWeaponCombo = {}
sortedWeaponCombo["None"] =                        {"000_0", 1,  0, ""}
sortedWeaponCombo["Attack Boost Lv 1"] =           {"001_0", 2,  2, "Attack Boost"}
sortedWeaponCombo["Attack Boost Lv 2"] =           {"002_0", 3,  4, "Attack Boost"}
sortedWeaponCombo["Attack Boost Lv 3"] =           {"003_0", 4,  6, "Attack Boost"}
sortedWeaponCombo["Affinity Boost Lv 1"] =         {"011_0", 5,  3, "Affinity Boost"}
sortedWeaponCombo["Element Boost Lv 1"] =          {"021_0", 6,  1, "Elemental Boost"}
sortedWeaponCombo["Element Boost Lv 2"] =          {"022_0", 7,  2, "Elemental Boost"}
sortedWeaponCombo["Element Boost Lv 3"] =          {"023_0", 8,  3, "Elemental Boost"}
sortedWeaponCombo["Element Boost Lv 4"] =          {"024_0", 9,  4, "Elemental Boost"}
sortedWeaponCombo["Element Boost Lv 5"] =          {"025_0", 10, 5, "Elemental Boost"}
sortedWeaponCombo["Status Effect Boost Lv 1"] =    {"031_0", 11, 2, "Status Effect Boost"}
sortedWeaponCombo["Status Effect Boost Lv 2"] =    {"032_0", 12, 4, "Status Effect Boost"}
sortedWeaponCombo["Sharpness Boost Lv 1"] =        {"041_0", 13, 3, "Sharpness Boost"}
sortedWeaponCombo["Rampage Slot Upgrade Lv 1"] =   {"046_0", 14, 4, "Rampage Slot Upgrade"}


local augmentCombo = {}
augmentCombo[1]  = "None"
augmentCombo[2]  = "Defense -6"
augmentCombo[3]  = "Defense -12"
augmentCombo[4]  = "Defense +2"
augmentCombo[5]  = "Defense +3"
augmentCombo[6]  = "Defense +4"
augmentCombo[7]  = "Defense +6"
augmentCombo[8]  = "Defense +7"
augmentCombo[9]  = "Defense +8"
augmentCombo[10] = "Defense +9"
augmentCombo[11] = "Defense +11"
augmentCombo[12] = "Defense +12"
augmentCombo[13] = "Defense +13"
augmentCombo[14] = "Defense +18"
augmentCombo[15] = "Defense +19"
augmentCombo[16] = "Defense +20"
augmentCombo[17] = "Defense +22"
augmentCombo[18] = "Defense +24"
augmentCombo[19] = "Defense +26"
augmentCombo[20] = "Fire Res -1"
augmentCombo[21] = "Fire Res -2"
augmentCombo[22] = "Fire Res -3"
augmentCombo[23] = "Fire Res +1"
augmentCombo[24] = "Fire Res +2"
augmentCombo[25] = "Water Res -1"
augmentCombo[26] = "Water Res -2"
augmentCombo[27] = "Water Res -3"
augmentCombo[28] = "Water Res +1"
augmentCombo[29] = "Water Res +2"
augmentCombo[30] = "Thunder Res -1"
augmentCombo[31] = "Thunder Res -2"
augmentCombo[32] = "Thunder Res -3"
augmentCombo[33] = "Thunder Res +1"
augmentCombo[34] = "Thunder Res +2"
augmentCombo[35] = "Ice Res -1"
augmentCombo[36] = "Ice Res -2"
augmentCombo[37] = "Ice Res -3"
augmentCombo[38] = "Ice Res +1"
augmentCombo[39] = "Ice Res +2"
augmentCombo[40] = "Dragon Res -1"
augmentCombo[41] = "Dragon Res -2"
augmentCombo[42] = "Dragon Res -3"
augmentCombo[43] = "Dragon Res +1"
augmentCombo[44] = "Dragon Res +2"
augmentCombo[45] = "Slot +1"
augmentCombo[46] = "Slot +2"
augmentCombo[47] = "Slot +3"
augmentCombo[48] = "D-Tier Skill"
augmentCombo[49] = "C-Tier Skill"
augmentCombo[50] = "B-Tier Skill"
augmentCombo[51] = "A-Tier Skill"
augmentCombo[52] = "S-Tier Skill"
augmentCombo[53] = "Skill Removal"
augmentCombo[54] = "Fire Res -7"
augmentCombo[55] = "Water Res -7"
augmentCombo[56] = "Thunder Res -7"
augmentCombo[57] = "Ice Res -7"
augmentCombo[58] = "Dragon Res -7"

local sortedAugmentCombo = {}
sortedAugmentCombo["None"] =                {"000_0", 1}
sortedAugmentCombo["Defense -6"] =          {"059_0", 2}
sortedAugmentCombo["Defense -12"] =         {"060_0", 3}
sortedAugmentCombo["Defense +2"] =          {"069_0", 4}
sortedAugmentCombo["Defense +3"] =          {"070_0", 5}
sortedAugmentCombo["Defense +4"] =          {"071_0", 6}
sortedAugmentCombo["Defense +6"] =          {"072_0", 7}
sortedAugmentCombo["Defense +7"] =          {"073_0", 8}
sortedAugmentCombo["Defense +8"] =          {"073_1", 9}
sortedAugmentCombo["Defense +9"] =          {"073_2", 10}
sortedAugmentCombo["Defense +11"] =         {"074_0", 11}
sortedAugmentCombo["Defense +12"] =         {"074_1", 12}
sortedAugmentCombo["Defense +13"] =         {"074_2", 13}
sortedAugmentCombo["Defense +18"] =         {"075_0", 14}
sortedAugmentCombo["Defense +19"] =         {"075_1", 15}
sortedAugmentCombo["Defense +20"] =         {"075_2", 16}
sortedAugmentCombo["Defense +22"] =         {"076_0", 17}
sortedAugmentCombo["Defense +24"] =         {"076_1", 18}
sortedAugmentCombo["Defense +26"] =         {"076_2", 19}
sortedAugmentCombo["Fire Res -1"] =         {"089_0", 20}
sortedAugmentCombo["Fire Res -2"] =         {"089_1", 21}
sortedAugmentCombo["Fire Res -3"] =         {"090_0", 22}
sortedAugmentCombo["Fire Res -7"] =         {"091_0", 54}
sortedAugmentCombo["Fire Res +1"] =         {"094_0", 23}
sortedAugmentCombo["Fire Res +2"] =         {"094_1", 24}
sortedAugmentCombo["Water Res -1"] =        {"099_0", 25}
sortedAugmentCombo["Water Res -2"] =        {"099_1", 26}
sortedAugmentCombo["Water Res -3"] =        {"100_0", 27}
sortedAugmentCombo["Water Res -7"] =        {"101_0", 55}
sortedAugmentCombo["Water Res +1"] =        {"104_0", 28}
sortedAugmentCombo["Water Res +2"] =        {"104_1", 29}
sortedAugmentCombo["Thunder Res -1"] =      {"109_0", 30}
sortedAugmentCombo["Thunder Res -2"] =      {"109_1", 31}
sortedAugmentCombo["Thunder Res -3"] =      {"110_0", 32}
sortedAugmentCombo["Thunder Res -7"] =      {"111_0", 56}
sortedAugmentCombo["Thunder Res +1"] =      {"114_0", 33}
sortedAugmentCombo["Thunder Res +2"] =      {"114_1", 34}
sortedAugmentCombo["Ice Res -1"] =          {"119_0", 35}
sortedAugmentCombo["Ice Res -2"] =          {"119_1", 36}
sortedAugmentCombo["Ice Res -3"] =          {"120_0", 37}
sortedAugmentCombo["Ice Res -7"] =          {"121_0", 57}
sortedAugmentCombo["Ice Res +1"] =          {"124_0", 38}
sortedAugmentCombo["Ice Res +2"] =          {"124_1", 39}
sortedAugmentCombo["Dragon Res -1"] =       {"129_0", 40}
sortedAugmentCombo["Dragon Res -2"] =       {"129_1", 41}
sortedAugmentCombo["Dragon Res -3"] =       {"130_0", 42}
sortedAugmentCombo["Dragon Res -7"] =       {"131_0", 58}
sortedAugmentCombo["Dragon Res +1"] =       {"134_0", 43}
sortedAugmentCombo["Dragon Res +2"] =       {"134_1", 44}
sortedAugmentCombo["Slot +1"] =             {"139_0", 45}
sortedAugmentCombo["Slot +2"] =             {"140_0", 46}
sortedAugmentCombo["Slot +3"] =             {"141_0", 47}
sortedAugmentCombo["D-Tier Skill"] =        {"144_0", 48}
sortedAugmentCombo["C-Tier Skill"] =        {"145_0", 49}
sortedAugmentCombo["B-Tier Skill"] =        {"146_0", 50}
sortedAugmentCombo["A-Tier Skill"] =        {"147_0", 51}
sortedAugmentCombo["S-Tier Skill"] =        {"148_0", 52}
sortedAugmentCombo["Skill Removal"] =       {"149_0", 53}

local skill = {}

local skillInitTranslation = {}
skillInitTranslation[3] = 144
skillInitTranslation[6] = 145
skillInitTranslation[9] = 146
skillInitTranslation[12] = 147
skillInitTranslation[15] = 148
local function initSkills()
    local customBuildupModule = sdk.get_managed_singleton("snow.data.CustomBuildupModule")
    if not customBuildupModule then return false end

    skill = {}

    for i = 1,255 do
        local skillType = customBuildupModule:getBuilduptSkillCost(i)
        if skillInitTranslation[skillType] ~= nil then
            if not skill[skillInitTranslation[skillType]] then
                skill[skillInitTranslation[skillType]] = {}
            end
            table.insert(skill[skillInitTranslation[skillType]], i)
        end
    end

    for i,v in pairs(skill) do
        log.debug(i .. ": " .. table.concat(v, ", "))
    end

    log.debug("Qurious Cheating initialized")

    return true
end

local initializing = true
local initStep = 0
re.on_frame(function()
    if initializing then
        initStep = initStep + 1
        if initStep > 60 then
            initStep = 0
            initializing = not initSkills()
        end
    end
end)

local getName = sdk.find_type_definition("snow.data.DataShortcut"):get_method("getName(snow.data.DataDef.PlEquipSkillId)")

re.on_draw_ui(
    function()
        if imgui.tree_node("Qurious Cheating") then
            if error ~= "" then imgui.text(error) end

            local optionManager = sdk.get_managed_singleton("snow.gui.OptionManager")
            if not optionManager then error = "Game has not loaded properly yet" imgui.tree_pop() return end
            local language = optionManager:call("getDisplayLanguage()")
            
            local smithyGui = sdk.get_managed_singleton("snow.gui.fsm.smithy.GuiSmithyFsmManager")
            if not smithyGui then error = "Speak to smithy to use" imgui.tree_pop() return end
            
            local selected = smithyGui:call("get_CustomBuildupInventoryData")
            if not selected then error = "Open the Qurious Armor Crafting menu\nand select a piece to edit" imgui.tree_pop() return end
            if selected:get_field("_IdType") == 2 then
                
                _, allowCheat = imgui.checkbox("Allow skill cheating", allowCheat)
                
                local isBuildup = selected:get_field("_CustomEnable")
                _, isBuildup = imgui.checkbox("Enable Augmentation", isBuildup)
                selected:set_field("_CustomEnable", isBuildup)
                
                if not isBuildup then error = "Enable augmentation to edit this piece" imgui.tree_pop() return end
                
                if language_font[language] then
                    imgui.push_font(language_font[language])
                end

                error = ""
                local armorData = selected:call("getArmorData")

                local name = armorData:call("getName")
                local rarity = armorData:call("getRare")
                local cost = armorData:call("get_CustomCost")
                local point = armorData:call("getCustomSpendCost(snow.data.DataDef.CustomBuildupCategoryId)",0)

                local pool = armorData:call("get_CustomTableNo")
                
                imgui.text_colored(name, 0xff71FFFF)
                imgui.text_colored("Rarity " .. rarity+1, rarityColors[rarity])
                imgui.text("Armor tier: " .. pool)
                imgui.text("Spent " .. point .. " out of " .. cost .. " available points")
                imgui.text("Legal:")
                imgui.same_line()
                imgui.text_colored((point > cost and "No" or "Yes"), (point > cost and 0xff0D4BFF or 0xff96E126))

                local buildUpData = selected:get_field("_CustomBuildup")
                local BUC = {}
                local BUTI = {}
                local BUID = {}
                local BUVa = {}
                local BUSk = {}


                for i = 0, buildUpData:call("get_Count") - 1 do
                    local data = buildUpData:call("get_Item", i)
                    imgui.new_line()
                    BUID[i] = data:get_field("_Id")
                    BUVa[i] = data:get_field("_ValueIndex")

                    local tableIndex = string.format("%03d", BUID[i]) .. "_" .. BUVa[i]

                    BUTI[i] = -1
                    for x,v in pairs(sortedAugmentCombo) do
                        if v[1] == tableIndex then 
                            BUTI[i] = v[2]
                        end
                    end

                    BUSk[i] = data:get_field("_SkillId")


                    local tempCombo = {}
                    for i,v in pairs(augmentCombo) do
                        local newV = v
                        if string.find(v, "Defense") and i > 3 then
                            newV = "Defense +" .. defenseBonuses
                            [pool]
                            [i-3]
                        end
                        tempCombo[i] = newV
                    end

                    BUC[i], BUTI[i] = imgui.combo("Augmentation " .. i, BUTI[i], tempCombo)

                    local newTableIndex = sortedAugmentCombo[augmentCombo[BUTI[i]]][1]
                    local newId = tonumber(string.sub(newTableIndex, 1,3))
                    local newVa = tonumber(string.sub(newTableIndex, 5))

                    if newId > 143 and newId < 150 then
                        local skillTable = {}
                        if allowCheat then
                            for i = 0,200 do
                                local name = getName:call(nil, i)
                                if name ~= "" then
                                    skillTable[i] = i .. ": " .. name
                                end
                            end
                        elseif newId == 149 then
                            local armorBaseData = selected:call("getArmorBaseData")
                            local skillData = armorBaseData:call("get_AllSkillDataList")
                            for i = 0, skillData:call("get_Count") -1 do
                                local skill = skillData:call("get_Item", i)
                                if skill:call("get_EquipSkillId") > 0 then
                                    skillTable[skill:call("get_EquipSkillId")] = skill:call("get_EquipSkillId") .. ": " .. skill:call("get_Name")
                                end
                            end
                        else
                            for i,v in pairs(skill[newId]) do
                                skillTable[v] = v .. ": " .. getName:call(nil, v)
                            end
                        end
                        BUC[i+200], BUSk[i] = imgui.combo("Augmentation Skill " .. i, BUSk[i], skillTable)
                    elseif newId == 149 then
                        local skillTable = {}
                        for i = 0,200 do
                            local name = getName:call(nil, i)
                            if name ~= "" then
                                skillTable[i] = i .. ": " .. name
                            end
                        end
                        BUC[i+200], BUSk[i] = imgui.combo("Augmentation Skill " .. i, BUSk[i], skillTable)
                    end

                    data:set_field("_Id", newId)
                    data:set_field("_ValueIndex", newVa)
                    data:set_field("_SkillId", BUSk[i])
                end
            elseif selected:get_field("_IdType") == 1 then
                local isBuildup = selected:get_field("_CustomEnable")
                _, isBuildup = imgui.checkbox("Enable Augmentation", isBuildup)
                selected:set_field("_CustomEnable", isBuildup)
                
                if not isBuildup then error = "Enable augmentation to edit this piece" imgui.tree_pop() return end
                
                if language_font[language] then
                    imgui.push_font(language_font[language])
                end

                error = ""

                local weaponData = selected:call("getWeaponData")

                local name = weaponData:call("getName")
                local rarity = weaponData:call("getRarity")
                local cost = 3 + weaponData:call("get_CustomAddCost")
                local point = weaponData:call("getCustomSpendCost(snow.data.DataDef.CustomBuildupCategoryId)", 0)
                local costColors = weaponData:call("get_CustomBuildupCostIconColorArray()")
                
                imgui.text_colored(name, 0xff71FFFF)
                imgui.text_colored("Rarity " .. rarity+1, rarityColors[rarity])
                imgui.text("Spent " .. point .. " out of " .. cost .. " available slots")
                for i = 0, costColors:get_Count()-1 do
                    v = costColors:get_Item(i)
                    local slotType = i > 5 and "!" or (i >= cost and "X" or "O")
                    imgui.text_colored(slotType, CustomColorTypes[v])
                    imgui.same_line()
                end
                if costColors:get_Count() < 6 then
                    for i = costColors:get_Count(),5 do
                        local slotType = i >= cost and "X" or "O"
                        imgui.text_colored(slotType, Color.Black)
                        imgui.same_line()
                    end
                end

                imgui.text("Legal:")
                imgui.same_line()
                imgui.text_colored((point > cost and (point < 7 and "No, but won't be erased" or "No") or "Yes"), (point > cost and (point < 7 and Color.Yellow or Color.Red) or Color.Green))

                local table = weaponData:get_CustomTableNo()
                local bcModule = sdk.get_managed_singleton("snow.data.CustomBuildupModule")
                local wpcbdat = bcModule:getWeaponData(table)
                local groupList = wpcbdat._GroupList
                local groups = {}
                for i = 0, groupList:get_Count()-1 do
                    groups[groupList:get_Item(i):get_CategoryName()] = true
                end

                local buildUpData = selected:get_field("_CustomBuildup")
                local BUC = {}
                local BUTI = {}
                local BUID = {}
                local BUVa = {}
                local BUSk = {}


                for i = 0, buildUpData:call("get_Count") - 3 do
                    local data = buildUpData:call("get_Item", i)
                    imgui.new_line()
                    BUID[i] = data:get_field("_Id")
                    BUVa[i] = data:get_field("_ValueIndex")

                    local tableIndex = string.format("%03d", BUID[i]) .. "_" .. BUVa[i]

                    BUTI[i] = -1
                    for x,v in pairs(sortedWeaponCombo) do
                        if v[1] == tableIndex then 
                            BUTI[i] = v[2]
                        end
                    end

                    local tempCombo = {}
                    for s,x in pairs(sortedWeaponCombo) do
                        local i = x[2]
                        local v = weaponCombo[x[2]]
                        if groups[x[4]] or x[4] == "" then
                            local newV = v .. " (" .. sortedWeaponCombo[v][3] .. " slots)"
                            tempCombo[i] = newV
                        end
                    end

                    BUC[i], BUTI[i] = imgui.combo("Augmentation " .. i, BUTI[i], tempCombo)

                    local newTableIndex = sortedWeaponCombo[weaponCombo[BUTI[i]]][1]
                    local newId = tonumber(string.sub(newTableIndex, 1,3))

                    data:set_field("_Id", newId)
                end
            end

            if language_font[language] then
                imgui.pop_font()
            end

            imgui.tree_pop();
        end
    end
)
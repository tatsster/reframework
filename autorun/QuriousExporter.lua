local function export()
    local getName = sdk.find_type_definition("snow.data.DataShortcut"):get_method("getName(snow.data.DataDef.PlEquipSkillId)")

    local saveManager = sdk.get_managed_singleton("snow.SnowSaveService")
    local slot = saveManager._CurrentHunterSlotNo
    if slot == -1 or slot == nil then return end
    
    local data = sdk.get_managed_singleton("snow.data.DataManager")
    local box = data._PlEquipBox
    local list = box:get_field("_WeaponArmorInventoryList")--box:call("getInventoryDataList(snow.data.EquipBox.InventoryType)", 0)
    
    local exportString = ""

    for i = 0, list:call("get_Count") - 1 do
        local v = list:call("get_Item", i)
        if v._IdType == 2 and v._CustomEnable then
            local singleString = ""

            
            local armorData = v:getArmorData()
            local armorName = armorData:getName()
            
            local def = armorData:get_CustomAddDef()
            local orgDecos = armorData:getOriginalSlotLvTable()
            local DecosObj = armorData:get_DecorationSlotNumList()
            local Decos = {}

            for i = DecosObj:get_Count() - 1, 0, -1 do
                local Deco = DecosObj:get_Item(i)
                if Deco ~= 0 then
                    for x = 1, Deco do
                        table.insert(Decos, i+1)
                    end
                end
            end
            
            while #Decos < 3 do
                table.insert(Decos, 0)
            end

            local decoString = ""
            for i = 0, orgDecos:get_Count() - 1 do
                decoString = decoString .. (Decos[i+1] - orgDecos:get_Item(i)) .. "," 
            end

            local elemRes = ""
            for i = 0,4 do
                elemRes = elemRes .. armorData:getCustomAddReg(i) .. ","
            end

            local skillUps = armorData:getCustomSkillUpList()
            local skillDwns = armorData:getCustomSkillDownList()

            local skillCount = 0
            local skillString = ""
            for i = 0, skillUps:get_Count() -1 do
                local v = skillUps:get_Item(i)
                skillCount = skillCount + 1
                skillString = skillString .. v:get_Name() .. "," .. v:get_TotalLv() .. ","
            end
            for i = 0, skillDwns:get_Count() -1 do
                local v = skillDwns:get_Item(i)
                skillCount = skillCount + 1
                skillString = skillString .. v:get_Name() .. "," .. v:get_TotalLv() .. ","
            end
            while skillCount < 4 do
                skillCount = skillCount + 1
                skillString = skillString .. ",,"
            end

            singleString = string.sub(string.format("%s,%d,%s%s%s", armorName, def, elemRes,decoString,skillString),0, -2)
            exportString = exportString .. singleString ..  "\n"
        end
    end
    fs.write("QuriousExporter/Save00".. slot .. "_ExportedQuriousArmors.txt", exportString)
end

re.on_draw_ui(
    function()
        if imgui.tree_node("Qurious Exporter") then
            if imgui.button("Export") then
                export()
            end
            imgui.tree_pop();
        end
    end
)
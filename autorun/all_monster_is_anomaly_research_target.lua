-- all_monster_is_anomaly_research_target.lua : written by archwizard1204

local settings = {
	enable = true;
}

local function checkAnomalyQuest(args)
    if settings.enable then
        local QuestData = sdk.to_managed_object(args[3]) -- snow.quest.RandomMysteryQuestData
        
        if QuestData then
            local targetEm = QuestData:getMainTargetEmType()
            if targetEm then
                local mysteryLabo = sdk.get_managed_singleton("snow.data.FacilityDataManager"):getMysteryLaboFacility()
                local laboTarget = mysteryLabo:get_LaboTarget()
                laboTarget:set_field("_MainTargetEnemyType", targetEm)
                laboTarget:set_field("_QuestCondition", 3)
            end
        end
    end
    return sdk.PreHookResult.CALL_ORIGINAL
end

local function SaveSettings()
	json.dump_file("All_monster_is_anomaly_research_target.json", settings)
end

local function LoadSettings()
	local loadedSettings = json.load_file("All_monster_is_anomaly_research_target.json");
	if loadedSettings then
		settings = loadedSettings;
	end
end

re.on_draw_ui(function()
	local changed = false;

    if imgui.tree_node("All Monster Is Anomaly Research Target") then
		changed, settings.enable = imgui.checkbox("Enabled", settings.enable);
		imgui.tree_pop()
    end
end)

re.on_config_save(function()
	SaveSettings()
end)

LoadSettings()

sdk.hook(sdk.find_type_definition("snow.QuestManager"):get_method("setRandomMysteryQuestSupplyData"),
    checkAnomalyQuest,
    nil)
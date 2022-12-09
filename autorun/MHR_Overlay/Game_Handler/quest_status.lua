local quest_status = {};
local singletons;
local customization_menu;
local player;
local small_monster;
local large_monster;
local damage_meter_UI;
local time;
local env_creature;

quest_status.index = 0;
quest_status.is_online = false;
quest_status.is_host = false;
quest_status.is_training_area = false;
quest_status.is_result_screen = false;
quest_status.is_quest_clear = false;

local quest_manager_type_definition = sdk.find_type_definition("snow.QuestManager");
local on_changed_game_status = quest_manager_type_definition:get_method("onChangedGameStatus");
local get_status_method = quest_manager_type_definition:get_method("getStatus");
local is_result_demo_play_start_method = quest_manager_type_definition:get_method("isResultDemoPlayStart");

local set_quest_clear_method = quest_manager_type_definition:get_method("setQuestClear");
local set_quest_clear_sub_method = quest_manager_type_definition:get_method("setQuestClearSub");
local set_quest_clear_sub_hyakurui_method = quest_manager_type_definition:get_method("setQuestClearSubHyakuryu");

local village_area_manager_type_def = sdk.find_type_definition("snow.VillageAreaManager");
local check_current_area_training_area_method = village_area_manager_type_def:get_method("checkCurrentArea_TrainingArea");

local lobby_manager_type_definition = sdk.find_type_definition("snow.LobbyManager");
local is_quest_online_method = lobby_manager_type_definition:get_method("IsQuestOnline");
local is_quest_host_method = lobby_manager_type_definition:get_method("isQuestHost");



function quest_status.on_changed_game_status(new_quest_status)
	if (quest_status.index < 2 and new_quest_status == 2)
		or new_quest_status < 2 then

		player.init();
		small_monster.init_list();
		large_monster.init_list();
		env_creature.init_list();

		quest_status.is_quest_clear = false;
		damage_meter_UI.freeze_displayed_players = false;
		damage_meter_UI.last_displayed_players = {};
	end

	quest_status.index = new_quest_status;
end

function quest_status.on_set_quest_clear()
	quest_status.is_quest_clear = true;
end

function quest_status.init()
	if singletons.quest_manager == nil then
		return;
	end

	local new_quest_status = get_status_method:call(singletons.quest_manager);
	if new_quest_status == nil then
		customization_menu.status = "No quest status";
		return;
	end

	quest_status.index = new_quest_status;
	quest_status.update_is_online();
	quest_status.update_is_training_area();
	quest_status.update_is_result_screen();
end

function quest_status.update_is_online()
	if singletons.lobby_manager == nil then
		return;
	end

	local is_quest_online = is_quest_online_method:call(singletons.lobby_manager);
	if is_quest_online == nil then
		return;
	end

	if quest_status.is_online and not is_quest_online then
		damage_meter_UI.freeze_displayed_players = true;
	end

	quest_status.is_online = is_quest_online;
end

function quest_status.update_is_host()
	if singletons.lobby_manager == nil then
		return;
	end

	local is_host = is_quest_host_method:call(singletons.lobby_manager, true);
	if is_host == nil then
		return;
	end

	quest_status.is_host = is_host;
end

function quest_status.update_is_training_area()
	if singletons.village_area_manager == nil then
		customization_menu.status = "No village area manager";
		return;
	end

	local _is_training_area = check_current_area_training_area_method:call(singletons.village_area_manager);
	if _is_training_area == nil then
		return;
	end

	if quest_status.is_training_area == true and _is_training_area == false then
		player.init();
	end

	quest_status.is_training_area = _is_training_area;
end

function quest_status.update_is_result_screen()
	if singletons.quest_manager == nil then
		customization_menu.status = "No quest manager";
		return;
	end

	local is_result_demo_play_start = is_result_demo_play_start_method:call(singletons.quest_manager);
	if is_result_demo_play_start == nil then
		return;
	end

	quest_status.is_result_screen = is_result_demo_play_start;
end

function quest_status.init_module()
	singletons = require("MHR_Overlay.Game_Handler.singletons");
	customization_menu = require("MHR_Overlay.UI.customization_menu");
	player = require("MHR_Overlay.Damage_Meter.player");
	small_monster = require("MHR_Overlay.Monsters.small_monster");
	large_monster = require("MHR_Overlay.Monsters.large_monster");
	damage_meter_UI = require("MHR_Overlay.UI.Modules.damage_meter_UI");
	time = require("MHR_Overlay.Game_Handler.time");
	env_creature = require("MHR_Overlay.Endemic_Life.env_creature");

	quest_status.init();

	sdk.hook(on_changed_game_status, function(args)
		quest_status.on_changed_game_status(sdk.to_int64(args[3]));
	end, function(retval) return retval; end);

	sdk.hook(set_quest_clear_method, function(args)
		quest_status.on_set_quest_clear();
	end, function(retval) return retval; end);

	sdk.hook(set_quest_clear_sub_method, function(args)
		quest_status.on_set_quest_clear();
	end, function(retval) return retval; end);

	sdk.hook(set_quest_clear_sub_hyakurui_method, function(args)
		quest_status.on_set_quest_clear();
	end, function(retval) return retval; end);
end

return quest_status;

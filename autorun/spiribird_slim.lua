--------------------USER EDIT--------------------
local MenuCanShow = true;  -- put false if not want to show menu
--------------------------------------------------

local app_type = sdk.find_type_definition("via.Application")
local get_elapsed_second = app_type:get_method("get_UpTimeSecond")
local Player_Obj;
local envCreature;
local Quest_Obj;
-- MENU
local menu_open = true;
local menu_showning = 0.0;
local auto_summon = true;
-- SUMMON
local ecIndex = 15
-- States
local state_check_in = 0;
local canSpwan = false
local wait = 0;
local sec_status = "actived?";
-- Quest type dont work
local quest_type_block = {256, 64, 128};
-- counts 
local birds_list = {};

local function get_time()
    return get_elapsed_second:call(nil)
end
local function has_type(val)
    for index, value in ipairs(quest_type_block) do
        if value == val then
            return true
        end
    end
    return false
end
local function get_player_obj()
    Player_Obj = sdk.get_managed_singleton("snow.player.PlayerManager"):call("findMasterPlayer")
    if (Player_Obj) then
        Player_Obj = Player_Obj:call("get_GameObject");
    end
    return Player_Obj;
end
local function get_Player_location()
    get_player_obj()
    local p_location = Player_Obj:call("get_Transform"):call("get_Position")
    if not p_location then
        scState = "no locate"
        return
    end
    return p_location;
end
local function get_Quest_obj()
    Quest_Obj = sdk.get_managed_singleton("snow.QuestManager")
    if not Quest_Obj then
        return nil
    end
    return Quest_Obj
end
local function get_envCreature()
    envCreature = sdk.get_managed_singleton("snow.envCreature.EnvironmentCreatureManager")
    if not envCreature then
        scState = "no ecm"
        return nil
    end
end
local function get_Quest_State()
    local quest_obj = get_Quest_obj();
    if (quest_obj) then
        return quest_obj:get_field("_QuestStatus")
    end
end
local function get_Type_Quest()
    local quest_obj = get_Quest_obj();
    if (quest_obj) then
        return quest_obj:get_field("_QuestType")
    end
end

local function check_map_birds(ty)
    if has_type(ty) then
        state_check_in = 5;
        return false
    end
    return true
end
local function state_check()
    local state_quest = get_Quest_State();

    if not state_quest then
        return
    end

    local type_quest = get_Type_Quest();

    if not type_quest then
        return
    end

    if (not check_map_birds(type_quest)) then
        return
    end
    if (state_quest == 2) then
        state_check_in = 0;
    else
        state_check_in = 1;
    end

end
local function invok_bird(index)
    get_envCreature()
    local pLoc = get_Player_location()
    local ecList = envCreature:get_field("_EcPrefabList"):get_field("mItems"):get_elements()
    if not ecList then
        state_check_in = 10;
        return nil
    end
    local ecPrefab = ecList[index]
    if not ecPrefab then
        state_check_in = 11;
        return nil
    end
    if not ecPrefab:call("get_Standby") then
        ecPrefab:call("set_Standby", true)
        state_check_in = 12;
        return nil
    end
    local ecInst = ecPrefab:call("instantiate(via.vec3)", pLoc)
    if not ecInst then
        state_check_in = 13;
        return nil
    end
    return ecInst;
end

re.on_pre_application_entry("UpdateBehavior", function()
    state_check();

    if state_check_in == 0 then

        if (wait == 0) then
            wait = get_time() + 3.0;
            menu_showning = get_time() + 10;
        end

        if (wait > get_time()) then
            return
        end

        local size = 0
        for _ in pairs(birds_list) do
            size = size + 1;
        end

        if (auto_summon) and (size < 1) then
            canSpwan = true;
            sec_status = "Wait to invok";
        end

        if canSpwan then
            local bird = invok_bird(ecIndex)
            if (sdk.is_managed_object(bird)) then
                table.insert(birds_list, bird);
                canSpwan = false;
                sec_status = "Done";
            end
        end
    else
        wait = 0;
        sec_status = "wait";
        for i, v in ipairs(birds_list) do
            v:call("destroy", v)
        end
        for item in pairs(birds_list) do
            birds_list[item] = nil;
            sec_status = "Cleaning..."
        end
    end

end)

re.on_frame(function()
    menu_open = (menu_showning > get_time());
    if (menu_open and MenuCanShow) then
        if imgui.begin_window('Bird Summoner SLIM MOD', nil, ImGuiWindowFlags_AlwaysAutoResize) then
            imgui.text(sec_status);
            imgui.text("VER: 0.1.0");
            imgui.end_window()
        end
    end
end)


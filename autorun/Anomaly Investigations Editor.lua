local data = require('Anomaly Investigations Editor/data')
local config = require('Anomaly Investigations Editor/config')
local editor = require('Anomaly Investigations Editor/editor')
local config_menu = require('Anomaly Investigations Editor/config_menu')
local filter = require('Anomaly Investigations Editor/filter')

data.init()

if not data.monsters then return end

config.init()
filter.init()
editor.init()
config_menu.init()


sdk.hook(
    sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('checkRandomMysteryQuestOrderBan'),
    function()
    end,
    function(retval)
        if config.user_input.force_pass and data.aie.quest_counter_open and not data.authorization.force_check then
            return sdk.to_ptr(0)
        else
            return retval
        end
    end
)

sdk.hook(
    sdk.find_type_definition('snow.SnowSingletonBehaviorRoot`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('awake'),
    function()
        data.aie.quest_counter_open = true
    end
)

sdk.hook(
    sdk.find_type_definition('snow.gui.fsm.GuiFsmBaseManager`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('onDestroy'),
    function()
        data.reset_mystery_data()
        data.aie.quest_counter_open = false
    end
)


if sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager') then data.aie.quest_counter_open = true end


re.on_frame(
    function()
        if not reframework:is_drawing_ui() then
            config_menu.is_opened = false
        end
    end
)

re.on_draw_ui(
    function()
        if imgui.button(string.format("%s %s", config.name, config.version)) then
            config_menu.is_opened = true
        end

        if config_menu.is_opened then
            config_menu.draw()
        end
    end
)

local config = {}

local misc
local data

config.name = 'Anomaly Investigations Editor'
config.version = '1.4.1'
config.user_input = {
    map=1,
    quest_lvl=1,
    quest_life=3,
    time_limit=50,
    hunter_num=4,
    tod=1,
    target_num=1,
    rand=0,
    quest_pick=1,
    filter='',
    filter_mode=1,
    amount_to_generate=1,
    monster0={
        pick=1,
        id=nil
    },
    monster1={
        pick=2,
        id=nil
    },
    monster2={
        pick=3,
        id=nil
    },
    monster3={
        pick=4,
        id=nil
    },
    monster5={
        pick=5,
        id=nil
    },
    edit_quest_lvl=false,
    edit_target_num=false,
    keep_valid=false,
    edit_quest_life=false,
    edit_time_limit=false,
    edit_hunter_num=false,
    edit_tod=false,
    show=1,
    selection={},
    selection_count=0,
    force_pass=false
}

function config.reset_input()
    config.user_input.map = misc.index_of(data.maps.array, data.maps.id_table[ data.quest_pick.quest._MapNo ])
    data.get_arrays()

    config.user_input.tod = data.quest_pick.quest._StartTime + 1
    config.user_input.quest_lvl = data.quest_pick.quest._QuestLv
    config.user_input.target_num = data.quest_pick.quest._HuntTargetNum
    config.user_input.quest_life = data.quest_pick.quest._QuestLife
    config.user_input.time_limit = data.quest_pick.quest._TimeLimit
    config.user_input.hunter_num = data.quest_pick.quest._QuestOrderNum
    config.user_input.special_open = data.quest_pick.quest._isSpecialQuestOpen and 2 or 1

    config.user_input.monster0.pick = data.get_monster_pick(data.monster_arrays.main.current, data.quest_pick.quest.monster0)
    config.user_input.monster1.pick = data.get_monster_pick(data.monster_arrays.extra.current, data.quest_pick.quest.monster1)
    config.user_input.monster2.pick = data.get_monster_pick(data.monster_arrays.extra.current, data.quest_pick.quest.monster2)
    config.user_input.monster3.pick = data.get_monster_pick(data.monster_arrays.extra.current, data.quest_pick.quest.monster3)
    config.user_input.monster5.pick = data.get_monster_pick(data.monster_arrays.extra.current, data.quest_pick.quest.monster5)

    data.aie.reload = false
end

function config.mass_edit_option_count()
    local t = {
        config.user_input.edit_quest_lvl,
        config.user_input.edit_quest_life,
        config.user_input.edit_time_limit,
        config.user_input.edit_hunter_num,
        config.user_input.edit_target_num
    }
    local c = 0
    for _, v in pairs(t) do
        if v then
            c = c + 1
        end
    end

    return c
end

function config.init()
    data = require('Anomaly Investigations Editor/data')
    misc = require('Anomaly Investigations Editor/misc')
end

return config

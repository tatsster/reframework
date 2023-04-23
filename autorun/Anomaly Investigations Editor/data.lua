local data = {}
local singletons = {}

local config
local filter
local misc

local random_mystery_quest_auth = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('checkRandomMysteryQuestOrderBan')


data.monsters = {
    table=monsters,
    id_table={}
}
data.monster_arrays = {
    main={
        map_valid={},
        current={}
    },
    extra={
        map_valid={},
        current={}
    }
}
data.maps = {
    table={
        Citadel=13,
        ["Flooded Forest"]=3,
        ["Frost Islands"]=4,
        Jungle=12,
        ["Lava Caverns"]=5,
        ["Sandy Plains"]=2,
        ["Shrine Ruins"]=1,
        ["Infernal Springs"]=9,
        ["Arena"]=10,
        ["Forlorn Arena"]=14
    },
    extra={
        ["Infernal Springs"]=9,
        ["Arena"]=10,
        ["Forlorn Arena"]=14
    },
    array={},
    id_table={}
}
data.mystery_quests = {
    table={},
    names={},
    names_filtered={},
    dumped=false,
    count=1
}
data.rand_rank = {
    table={
        ['1']=-1,
        ['1-4']=0,
        ['1-5']=1,
        ['2-6']=2,
        ['3-7']=3,
        ['4-8']=4,
        ['5-9']=5,
        ['6-9']=6,
        ['7-9']=7,
        ['8-9']=8
    },
    array={}
}
data.mystery_rank_to_mon_array = {[-1]={0}}
data.tod = {
    table={
        Default=0,
        Day=1,
        Night=2
    },
    array={
        'Default',
        'Day',
        'Night'
    }
}
data.game_state = {
    current=0,
    previous=0
}
data.quest_pick = {
    quest=nil,
    name=nil,
    sort=nil
}
data.authorization = {
    table={
        [0]='Pass',
        [1]='Fail',
        [2]='Quest Level Too High',
        [3]='Research Level Too Low',
        [4]='Invalid Monsters',
        [5]='Quest Level Too Low',
        [6]='Invalid Quest Conditions',
        [7]='Invalid Map'
    },
    status=0,
    force_check=false
}
data.aie = {
    quest_counter_open=false,
    target_num_cap=4,
    max_quest_count=120,
    max_quest_level=300,
    max_quest_life=9,
    max_quest_time_limit=50,
    max_quest_hunter_num=4,
    filter_modes={
        'OR',
        'AND'
    },
}
data.probabilties = {
    {'Stars', '1', '1-4', '1-5', '2-6', '3-7', '4-8', '5-9', '6-9', '7-9', '8-9'},
    {'1', 100, 25, 10, 0, 0, 0, 0, 0, 0, 0},
    {'2', 0, 43, 25, 10, 0, 0, 0, 0, 0, 0},
    {'3', 0, 27, 37, 25, 15, 0, 0, 0, 0, 0},
    {'4', 0, 5, 23, 37, 30, 15, 0, 0, 0, 0},
    {'5', 0, 0, 5, 23, 37, 30, 20, 0, 0, 0},
    {'6', 0, 0, 0, 5, 15, 37, 35, 20, 0, 0},
    {'7', 0, 0, 0, 0, 3, 15, 32, 35, 25, 0},
    {'8', 0, 0, 0, 0, 0, 3, 11, 32, 35, 30},
    {'9', 0, 0, 0, 0, 0, 0, 2, 13, 40, 70},
}
data.valid_combinations = {
    {'Quest Level', 'Main Target Mystery Rank', 'Sub Target Normal Rank', 'Target Num', 'Quest Life', 'Time Limit', 'Hunter Num'},
    {'1 - 10', '0', '0 - 1', '1', '3 - 5, 9', '50', '4'},
    {'11 - 20', '0 - 1', '0 - 2', '1', '3 - 5, 9', '50', '4'},
    {'21 - 30', '0 - 2', '0 - 3', '1 - 2', '3 - 5', '30, 35, 50', '4'},
    {'31 - 40', '0 - 3', '0 - 5', '1 - 2', '3 - 5', '30, 35, 50', '4'},
    {'41 - 50', '0 - 3', '0 - 5', '1 - 3', '2 - 5', '25, 30, 35, 50', '4'},
    {'51 - 60', '0 - 4', '0 - 5', '1 - 3', '2 - 5', '25, 30, 35, 50', '4'},
    {'61 - 70', '0 - 4', '0 - 6', '1 - 3', '2 - 5', '25, 30, 35, 50', '4'},
    {'71 - 90', '0 - 5', '0 - 6', '1 - 3', '2 - 5', '25, 30, 35, 50', '2, 4'},
    {'91 - 110', '0 - 6', '0 - 7', '1 - 3', '1 - 4', '25, 30, 35, 50', '2, 4'},
    {'111 - 130', '0 - 7', '0 - 7', '1 - 3', '1 - 4', '25, 30, 35, 50', '2, 4'},
    {'131 - 300', '0 - 8', '0 - 7', '1 - 3', '1 - 4', '25, 30, 35, 50', '2, 4'}
}
data.valid_time_limit = {
    {'Target Num','Time Limit'},
    {'1', '25, 30, 35, 50'},
    {'2', '30, 35, 50'},
    {'3, 4', '50'}
}
data.normal_rank_11_rules = {
    {'Monster','Min Level'},
    {'Apex Arzuros', 21},
    {'Apex Rathian', 21},
    {'Apex Mizutsune', 121},
    {'Apex Rathalos', 161},
    {'Apex Diablos', 201},
    {'Apex Zinogre', 241}
}


local function get_quest_count()
    data.mystery_quests.count = data.aie.max_quest_count - data.get_questman():getFreeMysteryQuestDataIndexList(data.aie.max_quest_count):get_Count()
end

local function get_mystery_quest_data_table()
    local mystery_quest_data = data.get_questman()._RandomMysteryQuestData
    data.mystery_quests.names = {}
    data.mystery_quests.table = {}

    for i=0, mystery_quest_data:get_Count()-1 do
        local quest = {}
        quest.data = mystery_quest_data:get_Item(i)
        quest.no = quest.data._QuestNo

        if quest.no ~= -1 then
            quest.map = quest.data._MapNo

            if not data.maps.id_table[quest.map] then goto continue end

            quest.monsters = quest.data._BossEmType

            for _, idx in pairs({0, 1, 2, 3, 5}) do

                quest['monster' .. idx] = quest.monsters:get_Item(idx)

                if not data.monsters.table[ tostring(quest['monster'..idx]) ] then goto continue end
            end

            quest.lvl = quest.data._QuestLv
            quest.key = data.monsters.table[ tostring(quest.monster0) ].name .. '  -  '.. quest.lvl .. '  -  ' .. data.maps.id_table[quest.map] .. '  -  ' .. quest.no

            table.insert(data.mystery_quests.names, quest.key)

            data.mystery_quests.table[ quest.key ] = {
                _QuestNo=quest.no,
                sort=quest.data._Idx,
                name=quest.key,
                index=i,
                _QuestLv=quest.lvl,
                _IsLock=quest.data._IsLock,
                _QuestType=quest.data._QuestType,
                _MapNo=quest.map,
                _BaseTime=quest.data._BaseTime,
                _HuntTargetNum=quest.data._HuntTargetNum,
                monster0=quest.monster0,
                monster1=quest.monster1,
                monster2=quest.monster2,
                monster3=quest.monster3,
                monster5=quest.monster5,
                _TimeLimit=quest.data._TimeLimit,
                _QuestLife=quest.data._QuestLife,
                _StartTime=quest.data._StartTime,
                _QuestOrderNum=quest.data._QuestOrderNum,
                _isSpecialQuestOpen=quest.data._isSpecialQuestOpen,
                data=quest.data,
                selected=config.user_input.selection[quest.no],
                auth=data.quest_check(quest.data)
            }

            ::continue::
        end
    end

    config.user_input.selection = {}
    for k, v in pairs(data.mystery_quests.table) do
        if v.selected then
            config.user_input.selection[v._QuestNo] = k
        end
    end

    table.sort(data.mystery_quests.names, function(x, y) return data.mystery_quests.table[x].sort > data.mystery_quests.table[y].sort end)
    data.mystery_quests.dumped = true
end

function data.dump_monsters()
    local questman = sdk.get_managed_singleton('snow.QuestManager')
    local guiman = sdk.get_managed_singleton('snow.gui.GuiManager')
    local messageman = sdk.get_managed_singleton("snow.gui.MessageManager")

    local monster_list = guiman:get_refMonsterList()
    local monster_table = sdk.find_type_definition('snow.enemy.EnemyDef.EmTypes'):get_fields()
    local monsters = {}

    for _,monster in pairs(monster_table) do
        if monster then
            local monster_data = {}
            local maps = {}
            monster_data.id = tostring(monster:get_data())
            monster_data.maps = questman:getStageLotTable(tonumber(monster_data.id), true)

            if not monster_data.maps then goto continue end

            monster_data.maps = monster_data.maps.mItems:get_elements()
            monsters[monster_data.id] = {}

            for _,map in pairs(monster_data.maps) do
                maps[tostring(map.value__)] = true
            end

            local enemy_data = questman:getEnemyData(tonumber(monster_data.id))
            monsters[monster_data.id].maps = maps
            monsters[monster_data.id].capture = monster_list:isEnableCaptureMonster(tonumber(monster_data.id))
            monsters[monster_data.id].mystery_rank = questman:getEnemyMysteryRank(tonumber(monster_data.id))
            monsters[monster_data.id].normal_rank = questman:getEnemyNormalRank(tonumber(monster_data.id))
            monsters[monster_data.id].name = messageman:getEnemyNameMessage(tonumber(monster_data.id))
            monsters[monster_data.id].main = enemy_data:get_IsMystery()
        end

        ::continue::
    end

    monsters["0"] = {
        capture=false,
        main=false,
        maps={
            ['0']=false,
            ['1']=false,
            ['12']=false,
            ['13']=false,
            ['2']=false,
            ['3']=false,
            ['4']=false,
            ['5']=false
        },
        mystery_rank=0,
        normal_rank=0,
        name='None'
    }

    json.dump_file('Anomaly Investigations Editor/monsters.json', monsters)
end

function data.get_monster_pick(array, monster_id)
    local mon = {
        name=data.monsters.table[ tostring(monster_id) ].name,
        m_rank=data.monsters.table[ tostring(monster_id) ].mystery_rank,
        n_rank=data.monsters.table[ tostring(monster_id) ].normal_rank

    }

    return misc.index_of(array, string.format("%s - %i - %i", mon.name, mon.m_rank, mon.n_rank))
end

function data.quest_check(mystery_data)
    data.authorization.force_check = true
    data.authorization.status = random_mystery_quest_auth:call(data.get_questman(), mystery_data, false)
    data.authorization.force_check = false

    return data.authorization.status
end

function data.get_arrays()
    local map_id = tostring( data.maps.table[ data.maps.array[ config.user_input.map ] ] )

    data.monster_arrays.main.current = {}
    data.monster_arrays.extra.current = {}
    data.monster_arrays.main.map_valid = {}
    data.monster_arrays.extra.map_valid = {}

    config.user_input.monster0.pick = 1
    config.user_input.monster1.pick = 2
    config.user_input.monster2.pick = 3
    config.user_input.monster3.pick = 4
    config.user_input.monster5.pick = 5

    for name, id in pairs(data.monsters.id_table) do
        if data.monsters.table[id].maps[map_id] then
            if data.monsters.table[id].main then
                table.insert(data.monster_arrays.main.map_valid, name)
            end
            table.insert(data.monster_arrays.extra.map_valid, name)
        end
    end

    table.insert(data.monster_arrays.extra.map_valid, 'None - 0 - 0')
    table.sort(data.monster_arrays.main.map_valid)
    table.sort(data.monster_arrays.extra.map_valid)

    data.monster_arrays.main.current = data.monster_arrays.main.map_valid
    data.monster_arrays.extra.current = data.monster_arrays.extra.map_valid
end

function data.get_questman()
    if not singletons.questman then
        singletons.questman = sdk.get_managed_singleton('snow.QuestManager')
    end
    return singletons.questman
end

function data.get_spacewatcher()
    if not singletons.spacewatcher then
        singletons.spacewatcher = sdk.get_managed_singleton('snow.wwise.WwiseChangeSpaceWatcher')
    end
    return singletons.spacewatcher
end

function data.get_progman()
    if not singletons.progman then
        singletons.progman = sdk.get_managed_singleton('snow.progress.ProgressManager')
    end
    return singletons.progman
end

function data.reset_mystery_data(reset_quest_pick)
    if not reset_quest_pick then
        data.quest_pick.name = data.mystery_quests.names[ config.user_input.quest_pick ]
    else
        data.quest_pick.name = nil
        data.quest_pick.quest = nil
    end

    if data.quest_pick.name then data.quest_pick.sort = data.mystery_quests.table[ data.quest_pick.name ].sort end

    get_mystery_quest_data_table()
    get_quest_count()
    filter.filter_names()
    if data.quest_pick.quest and not data.quest_pick.name then config.reset_input() end
    config.user_input.selection_count = 0
    aie_autoquest_reload = true
end

function data.init()
    config = require('Anomaly Investigations Editor/config')
    filter = require('Anomaly Investigations Editor/filter')
    misc = require('Anomaly Investigations Editor/misc')

    data.monsters.table = json.load_file('Anomaly Investigations Editor/monsters.json')
    if not data.monsters.table then return end

    for id, mon in pairs(data.monsters.table) do
        if id ~= "0" then
            for _, map_id in pairs(data.maps.extra) do
                data.monsters.table[id].maps[tostring(map_id)] = true
            end

            if not data.mystery_rank_to_mon_array[mon.mystery_rank] then
                data.mystery_rank_to_mon_array[mon.mystery_rank] = {}
            end

            table.insert(data.mystery_rank_to_mon_array[mon.mystery_rank], tonumber(id))
        end

        data.monsters.id_table[ string.format("%s - %i - %i", mon.name, mon.mystery_rank, mon.normal_rank) ] = id
    end

    for name, id in pairs(data.maps.table) do
        data.maps.id_table[id] = name
        table.insert(data.maps.array, name)
    end
    table.sort(data.maps.array)

    for name, _ in pairs(data.rand_rank.table) do
        table.insert(data.rand_rank.array, name)
    end
    table.sort(data.rand_rank.array)
end

return data

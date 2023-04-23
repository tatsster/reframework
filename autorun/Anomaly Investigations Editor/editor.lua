local editor = {}

local data
local config
local misc

local create_random_mystery_quest = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('CreateRandomMysteryQuest')
local setup_boss_set_cond = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('setupBossSetCondition(snow.enemy.EnemyDef.EmTypes[], System.Int32, snow.QuestMapManager.MapNoType)')


local function get_free_quest_no()
    local mystery_quest_data = data.get_questman()._RandomMysteryQuestData
    local mystery_quest_no = data.get_questman():getFreeMysteryQuestNo()
    local quest_idx_list = data.get_questman():getFreeSpaceMysteryQuestIDXList(mystery_quest_data, mystery_quest_no, 1, true)
    local free_mystery_idx_list = data.get_questman():getFreeMysteryQuestDataIdx2IndexList(quest_idx_list)
    local mystery_idx = free_mystery_idx_list:get_Item(0)
    return mystery_quest_no + 700000, mystery_idx
end

local function get_valid_target_num(current, mystery_data)
    local level = mystery_data._QuestLv
    local em_types = mystery_data._BossEmType
    local time_limit = mystery_data._TimeLimit
    local apexes = {
        1793,
        1794,
        1852,
        1874,
        1799,
        1849
    }
    local valid_target_num_t = {
        [25] = {1},
        [30] = {1, 2},
        [35] = {1, 2},
        [50] = {1, 2, 3, 4}
    }
    local valid_target_num = {}
    local valid_target_num_l

    if misc.table_contains(apexes, em_types:get_Item(2)) then
        return 3
    end

    valid_target_num_t = valid_target_num_t[time_limit]

    if level > 50 then
        valid_target_num_l = {1, 2, 3, 4}
    elseif level > 20 then
        valid_target_num_l = {1, 2, 4}
    else
        valid_target_num_l = {1, 4}
    end

    if misc.table_contains(apexes, em_types:get_Item(1)) then
        table.remove(valid_target_num_l, 1)
    end

    for _, v in ipairs(valid_target_num_l) do
        if misc.table_contains(valid_target_num_t, v) then
            table.insert(valid_target_num, v)
        end
    end

    if not misc.table_contains(valid_target_num, current) then
        if current == 1 then
            return valid_target_num[1]
        else
            return valid_target_num[ #valid_target_num ]
        end
    else
        return current
    end
end

local function get_valid_quest_life(current, mystery_data)
    local level = mystery_data._QuestLv
    local valid_quest_life

    if level <= 20 then
        valid_quest_life = {3, 4, 5, 9}
    elseif level <= 40 then
        valid_quest_life = {3, 4, 5}
    elseif level <= 90 then
        valid_quest_life = {2, 3, 4, 5}
    else
        valid_quest_life = {1, 2, 3, 4}
    end

    if misc.table_contains(valid_quest_life, current) then
        return current
    else
        local dif_array = {}
        local dif_table = {}
        for _, v in pairs(valid_quest_life) do
            local dif = math.abs(v - current)
            table.insert(dif_array, dif)
            dif_table[dif] = v
        end

        table.sort(dif_array)

        return dif_table[dif_array[1]]
    end
end

local function get_valid_hunter_num(current, mystery_data)
    local level = mystery_data._QuestLv

    if level <= 70 then
        return 4
    else
        if current ~= 2 and current ~= 4 then
            return 4
        else
            return current
        end
    end
end

local function get_valid_time_limit(current, mystery_data)
    local valid_time_limit_target_num = {
        [1]={25, 30, 35, 50},
        [2]={30, 35, 50},
        [3]={50},
        [4]={50}
    }
    local target_num = mystery_data._HuntTargetNum
    local level = mystery_data._QuestLv

    local valid_times_t = valid_time_limit_target_num[target_num]
    local valid_times_l

    if level > 41 then
        valid_times_l = {25, 30, 35, 50}
    elseif level > 21 then
        valid_times_l = {30, 35, 50}
    else
        valid_times_l = {50}
    end

    local valid_times = {}
    for _, v in pairs(valid_times_l) do
        if misc.table_contains(valid_times_t, v) then
            table.insert(valid_times, v)
        end
    end

    if misc.table_contains(valid_times, current) then
        return current
    else
        local dif_array = {}
        local dif_table = {}
        for _, v in pairs(valid_times) do
            local dif = math.abs(v - current)
            table.insert(dif_array, dif)
            dif_table[dif] = v
        end

        table.sort(dif_array)

        return dif_table[dif_array[1]]
    end
end

local function get_valid_level(r_max, current, mystery_data)
    local em_types = mystery_data._BossEmType
    local mons = {}
    local min = 1
    local max = r_max
    local target_num = mystery_data._HuntTargetNum
    local extra_map = data.maps.extra[ data.maps.id_table[ mystery_data._MapNo] ]

    local custom_level = {
        [1793]=21,
        [1794]=161,
        [1852]=21,
        [1874]=121,
        [1849]=241,
        [1799]=201,
    }
    local valid_time_limit = {
        [25]={41, data.aie.max_quest_level},
        [30]={21, data.aie.max_quest_level},
        [35]={21, data.aie.max_quest_level},
        [50]={1, data.aie.max_quest_level},
    }
    local valid_target_num = {
        [4]={1, data.aie.max_quest_level},
        [3]={41, data.aie.max_quest_level},
        [2]={21, data.aie.max_quest_level},
        [1]={1, data.aie.max_quest_level},
    }
    local valid_quest_life = {
        [9]={1, 20},
        [5]={1, 90},
        [4]={1, data.aie.max_quest_level},
        [3]={1, data.aie.max_quest_level},
        [2]={41, data.aie.max_quest_level},
        [1]={91, data.aie.max_quest_level},
    }
    local valid_hunter_num = {
        [4]={1, data.aie.max_quest_level},
        [2]={71, data.aie.max_quest_level}
    }
    local valid_time_limit_target_num = {
        [1]={
            [25]=true,
            [30]=true,
            [35]=true,
            [50]=true,
        },
        [2]={
            [30]=true,
            [35]=true,
            [50]=true,
        },
        [3]={
            [50]=true,
        },
        [4]={
            [50]=true,
        }
    }

    local v1 = valid_time_limit[mystery_data._TimeLimit]
    local v2 = valid_target_num[target_num]
    local v3 = valid_quest_life[mystery_data._QuestLife]
    local v4 = valid_hunter_num[mystery_data._QuestOrderNum]
    local v5 = valid_time_limit_target_num[target_num][mystery_data._TimeLimit]
    local v6 = not extra_map and {0, data.aie.max_quest_level} or {181, data.aie.max_quest_level}

    if v1 and v2 and v3 and v4 and v5 then
        local vals = {v1, v2, v3, v4, v6}

        for i, val in pairs(vals) do
            if val[1] > min then
                min = val[1]
            end
            if val[2] < max then
                max = val[2]
            end
        end
    else
        return current
    end

    table.insert(mons, data.get_questman():getRandomMysteryAppearanceMainEmLevel(em_types:get_Item(0)))
    if target_num > 1 then
        for i=1, target_num-1 do
            local mon = em_types:get_Item(i)
            if mon > 0 then
                if custom_level[mon] then
                    table.insert(mons, custom_level[mon])
                else
                    table.insert(mons, data.get_questman():getRandomMysteryAppearanceSubEmLevel(mon))
                end
            end
        end
    end

    local mon_min = math.max(table.unpack(mons))
    if mon_min > min then
        min = mon_min
    end

    if min > max then
        return current
    elseif current < min then
        return min
    elseif current > max then
        return max
    else
        return current
    end
end

local function edit_single(mystery, is_special_open)
    if (
        config.user_input.target_num == 2
        and data.monsters.table[config.user_input.monster1.id].capture
        or (
            config.user_input.target_num == 3
            and (
                 data.monsters.table[config.user_input.monster1.id].capture
                 or data.monsters.table[config.user_input.monster2.id].capture
            )
        ) or (
            config.user_input.target_num == 4
            and (
                 data.monsters.table[config.user_input.monster1.id].capture
                 or data.monsters.table[config.user_input.monster2.id].capture
                 or data.monsters.table[config.user_input.monster3.id].capture
            )
          )
    ) then
        mystery.quest_type = 1
    end

    mystery.em_types = mystery.data._BossEmType
    mystery.em_types:set_Item(0, tonumber(config.user_input.monster0.id))
    mystery.em_types:set_Item(1, tonumber(config.user_input.monster1.id))
    mystery.em_types:set_Item(2, tonumber(config.user_input.monster2.id))
    mystery.em_types:set_Item(3, tonumber(config.user_input.monster3.id))
    mystery.em_types:set_Item(5, tonumber(config.user_input.monster5.id))

    mystery.data._BossSetCondition = setup_boss_set_cond(data.get_questman(), mystery.em_types, config.user_input.target_num, data.maps.table[ data.maps.array[ config.user_input.map ] ])
    mystery.swap_cond = mystery.data._SwapSetCondition
    mystery.swap_param = mystery.data._SwapSetParam

    if config.user_input.monster5.id == 0 then
        mystery.swap_cond:set_Item(0, 0)
        mystery.swap_param:set_Item(0, 0)
        mystery.data._SwapStopType = 0
        mystery.data._SwapExecType = 0
    else
        mystery.swap_cond:set_Item(0, 1)
        mystery.swap_param:set_Item(0, 12)
        mystery.data._SwapStopType = 1
        mystery.data._SwapExecType = 1
    end

    mystery.data._MainTargetMysteryRank = data.monsters.table[config.user_input.monster0.id].mystery_rank
    mystery.seed:setEnemyTypes(mystery.em_types)

    mystery.data._MapNo = data.maps.table[ data.maps.array[ config.user_input.map ] ]
    mystery.seed._MapNo = data.maps.table[ data.maps.array[ config.user_input.map ] ]
    mystery.data._QuestType = mystery.quest_type
    mystery.seed._QuestType = mystery.quest_type
    mystery.data._HuntTargetNum = config.user_input.target_num
    mystery.seed._HuntTargetNum = config.user_input.target_num
    mystery.data._TimeLimit = config.user_input.time_limit
    mystery.seed._TimeLimit = config.user_input.time_limit
    mystery.data._QuestLife = config.user_input.quest_life
    mystery.seed._QuestLife = config.user_input.quest_life
    mystery.data._QuestOrderNum = config.user_input.hunter_num
    mystery.seed._QuestOrderNum = config.user_input.hunter_num
    mystery.data._StartTime = data.tod.table[ data.tod.array[ config.user_input.tod ] ]
    mystery.seed._StartTime = data.tod.table[ data.tod.array[ config.user_input.tod ] ]
    mystery.data._QuestLv = config.user_input.quest_lvl
    mystery.seed._QuestLv = config.user_input.quest_lvl


    mystery.data._isSpecialQuestOpen = config.user_input.quest_lvl == data.aie.max_quest_level and is_special_open and config.user_input.special_open == 2
    mystery.seed._isSpecialQuestOpen = mystery.data._isSpecialQuestOpen
    mystery.data._IsSpecialNewFlag = mystery.data._isSpecialQuestOpen
end

local function edit_mass(mystery, keep_valid, max_level, is_special_open)
    local level = mystery.data._QuestLv

    if config.user_input.edit_target_num then
        local target_num = config.user_input.target_num

        if keep_valid then
            target_num = get_valid_target_num(target_num, mystery.data)
        end

        mystery.em_types = mystery.data._BossEmType

        local mon1 = tostring(mystery.em_types:get_Item(1))
        local mon2 = tostring(mystery.em_types:get_Item(2))
        local mon3 = tostring(mystery.em_types:get_Item(3))

        if (
            target_num == 2
            and data.monsters.table[mon1].capture
            or (
                target_num == 3
                and (
                     data.monsters.table[mon1].capture
                     or data.monsters.table[mon2].capture
                )
            ) or (
                target_num == 4
                and (
                     data.monsters.table[mon1].capture
                     or data.monsters.table[mon2].capture
                     or data.monsters.table[mon3].capture
                )
              )
        ) then
            mystery.quest_type = 1
        end

        if target_num > 2 then
            mystery.swap_cond = mystery.data._SwapSetCondition
            mystery.swap_param = mystery.data._SwapSetParam
            mystery.em_types:set_Item(5, 0)
            mystery.swap_cond:set_Item(0, 0)
            mystery.swap_param:set_Item(0, 0)
            mystery.data._SwapStopType = 0
            mystery.data._SwapExecType = 0
        end

        if target_num < 4 then
            mystery.em_types:set_Item(3, 0)
        end

        if data.maps.extra[ data.maps.id_table[mystery.data._MapNo] ] then
            if target_num < 3 then
                mystery.em_types:set_Item(2, 0)
            end

            if target_num < 2 then
                mystery.em_types:set_Item(1, 0)
            end
        end

        mystery.data._BossSetCondition = setup_boss_set_cond(data.get_questman(), mystery.em_types, target_num, mystery.data._MapNo)
        mystery.data._HuntTargetNum = target_num
        mystery.seed._HuntTargetNum = target_num
        mystery.data._QuestType = mystery.quest_type
        mystery.seed._QuestType = mystery.quest_type
    end

    if config.user_input.edit_time_limit then
        local time_limit = config.user_input.time_limit
        if keep_valid then
            time_limit = get_valid_time_limit(time_limit, mystery.data)
        end
        mystery.data._TimeLimit = time_limit
        mystery.seed._TimeLimit = time_limit
    end

    if config.user_input.edit_quest_life then
        local quest_life = config.user_input.quest_life
        if keep_valid then
            quest_life = get_valid_quest_life(quest_life, mystery.data)
        end
        mystery.data._QuestLife = quest_life
        mystery.seed._QuestLife = quest_life
    end

    if config.user_input.edit_hunter_num then
        local hunter_num = config.user_input.hunter_num
        if keep_valid then
            hunter_num = get_valid_hunter_num(hunter_num, mystery.data)
        end
        mystery.data._QuestOrderNum = hunter_num
        mystery.seed._QuestOrderNum = hunter_num
    end

    if config.user_input.edit_tod then
        mystery.data._StartTime = data.tod.table[ data.tod.array[ config.user_input.tod ] ]
        mystery.seed._StartTime = data.tod.table[ data.tod.array[ config.user_input.tod ] ]
    end

    if config.user_input.edit_quest_lvl then
        level = config.user_input.quest_lvl
        if keep_valid then
            level = get_valid_level(max_level, level, mystery.data)
        end
        mystery.data._QuestLv = level
        mystery.seed._QuestLv = level
    end

    mystery.data._isSpecialQuestOpen = level == data.aie.max_quest_level and is_special_open and config.user_input.special_open == 2
    mystery.seed._isSpecialQuestOpen = mystery.data._isSpecialQuestOpen
    mystery.data._IsSpecialNewFlag = mystery.data._isSpecialQuestOpen
end

function editor.edit_quest()
    if data.mystery_quests.count == 1 then return end

    local mystery_data_array = {}
    if config.user_input.mode == 1 then
        if data.quest_pick.quest.data._IsLock then return end
        mystery_data_array = {data.quest_pick.quest.data}
    else
        for _, quest in pairs(data.mystery_quests.table) do
            if quest.selected and not quest._IsLock then
                table.insert(mystery_data_array, quest.data)
            end
        end
    end

    local quest_save_data = data.get_questman():get_field('<SaveData>k__BackingField')
    local mystery_seeds = quest_save_data._RandomMysteryQuestSeed
    local max_level = data.get_progman():get_MysteryResearchLevel()
    local keep_valid = config.mass_edit_option_count() == 1 and config.user_input.keep_valid
    local is_special_open = data.get_questman():isOpenSpecialRandomMysteryQuest()

    for _, mystery_data in pairs(mystery_data_array) do
        if not mystery_data then
            data.reset_mystery_data()
            return
        end

        local mystery = {
            data=mystery_data,
            quest_type=2
        }

        mystery.seed = data.get_questman():getRandomQuestSeedFromQuestNo(mystery.data._QuestNo)
        mystery.seed_index = mystery_seeds:IndexOf(mystery.seed)

        if not mystery.seed or not mystery.seed_index then return end

        if config.user_input.mode == 1 then
            edit_single(mystery, is_special_open)
        else
            edit_mass(mystery, keep_valid, max_level, is_special_open)
        end

        mystery.data._IsNewFlag = true
        mystery.data._OriginQuestLv = 0
        mystery.seed._MysteryLv = data.aie.max_quest_level
        mystery.seed._OriginQuestLv = 0
        mystery_seeds:set_Item(mystery.seed_index, mystery.seed)
    end

    data.reset_mystery_data()
end

function editor.generate_random(mystery_rank, amount)
    if data.mystery_quests.count == data.aie.max_quest_count then return end

    if data.mystery_quests.count + amount > data.aie.max_quest_count then
        amount = data.aie.max_quest_count - data.mystery_quests.count
    end

    local mon_array = data.mystery_rank_to_mon_array[mystery_rank]
    for i=1, amount do
        local mystery_data = sdk.create_instance('snow.quest.RandomMysteryQuestData')
        local mystery_quest_no, mystery_index = get_free_quest_no()
        local id = mon_array[math.random(#mon_array)]

        if not mystery_quest_no then
            data.reset_mystery_data()
            return
        end

        mystery_data._QuestLv = data.aie.max_quest_level + 1
        mystery_data._BossEmType:set_Item(0, id)

        create_random_mystery_quest:call(data.get_questman(), mystery_data, 1, mystery_index, mystery_quest_no, true)
    end

    config.user_input.quest_pick = 1
    data.reset_mystery_data(true)
end

function editor.wipe()
    local mystery_quest_data = data.get_questman()._RandomMysteryQuestData:get_elements()
    local quest_save_data = data.get_questman():get_field('<SaveData>k__BackingField')
    local mystery_seeds = quest_save_data._RandomMysteryQuestSeed
    local newest_quest_no = data.mystery_quests.table[ data.mystery_quests.names[1] ]._QuestNo

    for _, quest in pairs(mystery_quest_data) do

        local quest = {
            data=quest
        }
        quest.no = quest.data._QuestNo

        if not quest.data._IsLock and quest.no ~= -1 and quest.no ~= newest_quest_no then
            quest.seed = data.get_questman():getRandomQuestSeedFromQuestNo(quest.no)
            quest.seed_index = mystery_seeds:IndexOf(quest.seed)
            quest.data:clear()
            quest.seed:clear()
            mystery_seeds:set_Item(quest.seed_index, quest.seed)
        end
    end
    data.reset_mystery_data(true)
end

function editor.lock_unlock_quest()
    local quest_save_data = data.get_questman():get_field('<SaveData>k__BackingField')
    local mystery_seeds = quest_save_data._RandomMysteryQuestSeed
    local mystery_data_array = {}

    if config.user_input.mode == 1 then
        mystery_data_array = {data.quest_pick.quest}
    else
        mystery_data_array = {}
        for _, v in pairs(data.mystery_quests.table) do
            if v.selected then
                table.insert(mystery_data_array, v)
            end
        end
    end

    local lock = not mystery_data_array[1].data._IsLock
    for _, quest in pairs(mystery_data_array) do

        local seed = data.get_questman():getRandomQuestSeedFromQuestNo(quest.data._QuestNo)
        local seed_index = mystery_seeds:IndexOf(seed)
        quest.data._IsLock = lock
        quest._IsLock = lock
        seed._IsLock = lock
        mystery_seeds:set_Item(seed_index, seed)
    end
end

function editor.init()
    data = require('Anomaly Investigations Editor/data')
    config = require('Anomaly Investigations Editor/config')
    misc = require('Anomaly Investigations Editor/misc')
end

return editor

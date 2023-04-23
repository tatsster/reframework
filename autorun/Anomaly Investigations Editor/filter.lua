local filter = {}

local data
local config
local misc


local function split_str(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^/"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local function starts_with(str, pattern)
   return string.sub(str, 1, string.len(pattern)) == pattern
end

local function get_operator(str)
    local ops = {
        ['!=']=function(x, y) return x ~= y end,
        ['>=']=function(x, y) return x >= y end,
        ['<=']=function(x, y) return x <= y end,
        ['<']=function(x, y) return x < y end,
        ['>']=function(x, y) return x > y end,
        ['=']=function(x, y) return x == y end
    }

    for op, func in pairs(ops) do
        if starts_with(str, op) then
            local t = split_str(str, op)
            if t and #t == 1 then
                local number = tonumber(t[1])
                if number then
                    return ops[op], number
                end
            end
        end
    end
end

function filter.filter_names()
    data.mystery_quests.names_filtered = {}
    config.user_input.quest_pick = nil
    local query = split_str(config.user_input.filter, ';')

    for _, name in ipairs(data.mystery_quests.names) do
        if #query > 0 then
            for _, q in pairs(query) do

                if q == '(' or starts_with(q,'[') then goto next end

                local func, number = get_operator(q)

                if (
                    func
                    and func(data.mystery_quests.table[name]._QuestLv, number)
                    or (
                        not func
                        and string.find(name:lower(), q:lower())
                    )
                ) then
                    if config.user_input.filter_mode == 1 then
                        table.insert(data.mystery_quests.names_filtered, name)
                        goto continue
                    end
                else
                    if config.user_input.filter_mode == 2 then goto continue end
                end

                ::next::
            end

            if config.user_input.filter_mode == 2 then
                table.insert(data.mystery_quests.names_filtered, name)
            end
        else
            table.insert(data.mystery_quests.names_filtered, name)
        end

        ::continue::
    end

    if #data.mystery_quests.names_filtered > 0 and data.quest_pick.name then
        config.user_input.quest_pick = misc.index_of(data.mystery_quests.names_filtered, data.quest_pick.name)

        if not config.user_input.quest_pick then
            for _, quest in pairs(data.mystery_quests.table) do
                if quest.sort == data.quest_pick.sort then
                    config.user_input.quest_pick = misc.index_of(data.mystery_quests.names_filtered, quest.name)
                    break
                end
            end
        end
    end

    if not config.user_input.quest_pick then
        config.user_input.quest_pick = 1
        data.quest_pick.quest = data.mystery_quests.table[ data.mystery_quests.names_filtered[config.user_input.quest_pick] ]
    end
end

function filter.init()
    data = require('Anomaly Investigations Editor/data')
    config = require('Anomaly Investigations Editor/config')
    misc = require('Anomaly Investigations Editor/misc')
end

return filter

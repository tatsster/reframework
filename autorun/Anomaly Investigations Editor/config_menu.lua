local config_menu = {}

local config
local data
local editor
local filter
local misc

config_menu.is_opened = false

local table_flags = 1 << 9|1 << 8|1 << 7|1 << 0|1 << 10
local main_window = {
    flags=0,
    pos=Vector2f.new(50, 50),
    pivot=Vector2f.new(0, 0),
    size=Vector2f.new(560, 890),
    condition=1 << 3
}
local sub_window = {
    flags=32,
    pos=nil,
    pivot=Vector2f.new(0, 0),
    size=Vector2f.new(1000, 480),
    condition=1 << 3,
    is_opened=false
}
local mass_window = {
    flags=1,
    pos=nil,
    pivot=Vector2f.new(0, 0),
    size=Vector2f.new(560, 890),
    condition=1 << 3,
    is_opened=false
}
local table_probabilities = {
    name='1',
    flags=table_flags,
    col_count=11,
    row_count=10,
    data={}
}
local table_valid_combination = {
    name='2',
    flags=table_flags,
    col_count=7,
    row_count=12,
    data={}
}
local table_valid_time_limit = {
    name='3',
    flags=table_flags,
    col_count=2,
    row_count=4,
    data={}
}
local table_valid_time_limit = {
    name='3',
    flags=table_flags,
    col_count=2,
    row_count=4,
    data={}
}
local table_normal_rank_11_rules = {
    name='3',
    flags=table_flags,
    col_count=2,
    row_count=7,
    data={}
}
local colors = {
    bad=0xff1947ff,
    good=0xff47ff59,
    info=0xff27f3f5,
    info_warn=0xff2787FF,
}
local changed = {
    filter=true,
    map=false,
    quest=false,
    -- target_num=false
}


local function create_table(tbl)
    if imgui.begin_table(tbl.name, tbl.col_count, tbl.flags) then
        for row=0, tbl.row_count-1 do

            if row == 0 then
                imgui.table_next_row(1)
            else
                imgui.table_next_row()
            end

            for col=0, tbl.col_count-1 do
                imgui.table_set_column_index(col)
                imgui.text(tbl.data[row+1][col+1])
            end

        end
        imgui.end_table()
    end
end

local function get_sub_window_pos()
    local main_window_pos = imgui.get_window_pos()
    local main_window_size = imgui.get_window_size()
    return Vector2f.new(main_window_pos.x + main_window_size.x, main_window_pos.y)
end

local function spaced(str, x)
    return string.rep(" ", x) .. str .. string.rep(" ", x)
end

local function set_tooltip(str, add_q)
    if add_q then
        imgui.same_line()
        imgui.text('(?)')
    end
    if imgui.is_item_hovered() then
        imgui.set_tooltip(str)
    end
end

local function filter_button()
    imgui.same_line()
    if imgui.button(spaced(data.aie.filter_modes[config.user_input.filter_mode], 3)) then
        config.user_input.filter_mode = config.user_input.filter_mode + 1
        if config.user_input.filter_mode > #data.aie.filter_modes then
            config.user_input.filter_mode = 1
        end
        filter.filter_names()
    end
    local str =
        'Delimiter:   ;\n\n' ..
        'e.g.\n' ..
        'Lagombi - 105 - Citadel - 700001\n' ..
        'Volvidon - 150 - Lava Caverns - 700002\n' ..
        'Lagombi - 200 - Frost Islands - 700003\n\n' ..
        'OR\n'..
        'Query: lagombi;volvidon\n' ..
        'Result:\n' ..
        'Lagombi - 105 - Citadel - 700001\n' ..
        'Volvidon - 150 - Lava Caverns - 700002\n\n' ..
        'AND\n'..
        'Query: lagombi;citadel\n' ..
        'Result:\n' ..
        'Lagombi - 105 - Citadel - 700001\n\n' ..
        'Searching by level is also supported\n' ..
        'Operators: !=, >=, <=, <, >, =\n\n' ..
        'Query: >=150\n' ..
        'Result:\n' ..
        'Volvidon - 150 - Lava Caverns - 700002\n' ..
        'Lagombi - 200 - Frost Islands - 700003'

    set_tooltip(str, true)
end

local function popup_yesno(str,key)
    local bool = false
    if imgui.begin_popup(key) then
        imgui.spacing()
        imgui.text('   '..str..'   ')
        imgui.spacing()
        if imgui.button(spaced('Yes', 3)) then
            imgui.close_current_popup()
            bool = true
        end
        imgui.same_line()
        if imgui.button(spaced('No', 3)) then
            imgui.close_current_popup()
        end
        imgui.spacing()
        imgui.end_popup()
    end
    return bool
end

local function select_unselect_all(select)
    for _, name in pairs(data.mystery_quests.names_filtered) do
        local item = data.mystery_quests.table[name]

        if (
            config.user_input.show == 2
            and item.selected
            or (
                config.user_input.show == 3
                and not item.selected
            ) or (
                  config.user_input.show == 4
                  and item.auth == 0
              ) or (
                    config.user_input.show == 5
                    and item.auth ~= 0
                ) or config.user_input.show == 1
        ) then
            if select then
                item.selected = true
                config.user_input.selection[item._QuestNo] = name
            else
                item.selected = false
                config.user_input.selection[item._QuestNo] = nil
            end
        end
    end
end

function mass_window.draw()
    mass_window.pos = get_sub_window_pos()
    imgui.set_next_window_pos(mass_window.pos, mass_window.condition, mass_window.pivot)
    imgui.set_next_window_size(mass_window.size, mass_window.condition)

    if imgui.begin_window("Quest Selection And Settings", mass_window.is_opened, mass_window.flags) then
        imgui.spacing()
        if imgui.collapsing_header('Settings') then
            imgui.indent(10)

            _, config.user_input.edit_quest_lvl = imgui.checkbox('Edit Level', config.user_input.edit_quest_lvl)
            _, config.user_input.edit_special_open = imgui.checkbox('Edit Special Open', config.user_input.edit_special_open)
            _, config.user_input.edit_target_num = imgui.checkbox('Edit Target Num', config.user_input.edit_target_num)
            _, config.user_input.edit_quest_life = imgui.checkbox('Edit Quest Life', config.user_input.edit_quest_life)
            _, config.user_input.edit_time_limit = imgui.checkbox('Edit Time Limit', config.user_input.edit_time_limit)
            _, config.user_input.edit_hunter_num = imgui.checkbox('Edit Hunter Num', config.user_input.edit_hunter_num)
            _, config.user_input.edit_tod = imgui.checkbox('Edit Time of Day', config.user_input.edit_tod)

            local mass_edit_option_count = config.mass_edit_option_count()
            if mass_edit_option_count > 1 then
                imgui.push_style_var(0,0.4)
            end
            _, config.user_input.keep_valid = imgui.checkbox('Keep Valid', config.user_input.keep_valid)
            set_tooltip('Keeps edited setting within valid range if possible\nWorks ONLY when editing SINGLE setting', true)
            if mass_edit_option_count > 1 then
                imgui.pop_style_var()
            end

            imgui.unindent(10)
            imgui.separator()
            imgui.spacing()
        end

        if imgui.collapsing_header('Quest Selection') then
            imgui.indent(10)
            _, config.user_input.show = imgui.combo('Show', config.user_input.show, {'All', 'Selected', 'Not Selected', 'Valid', 'Invalid'})
            changed.filter, config.user_input.filter = imgui.input_text('Filter', config.user_input.filter)
            filter_button()
            imgui.spacing()

            if imgui.button(spaced('Select All', 3)) then
                select_unselect_all(true)
            end
            imgui.same_line()

            if imgui.button(spaced('Unselect All', 3)) then
                select_unselect_all(false)
            end
            imgui.separator()

            for i, name in pairs(data.mystery_quests.names_filtered) do
                local item = data.mystery_quests.table[name]

                if (
                    config.user_input.show == 2
                    and item.selected
                    or (
                        config.user_input.show == 3
                        and not item.selected
                    ) or (
                          config.user_input.show == 4
                          and item.auth == 0
                      ) or (
                            config.user_input.show == 5
                            and item.auth ~= 0
                        ) or config.user_input.show == 1
                ) then
                    item.changed, item.selected = imgui.checkbox(item.name, item.selected)

                    local str =
                        'Monster2: ' .. data.monsters.table[tostring(item.monster1)].name ..
                        '\nMonster3: ' .. data.monsters.table[tostring(item.monster2)].name ..
                        '\nMonster4: ' .. data.monsters.table[tostring(item.monster3)].name ..
                        '\nIntruder: ' .. data.monsters.table[tostring(item.monster5)].name ..
                        '\nTarget Num: ' .. item._HuntTargetNum ..
                        '\nTime Limit: ' .. item._TimeLimit ..
                        '\nQuest Life: ' .. item._QuestLife ..
                        '\nTime of Day: ' .. data.tod.array[item._StartTime + 1] ..
                        '\nHunter Num: ' .. item._QuestOrderNum ..
                        '\nSpecial Open: ' .. (item._isSpecialQuestOpen and "Yes" or "No")
                    set_tooltip(str, true)

                    if item.auth ~= 0 then
                        imgui.same_line()
                        imgui.text_colored(data.authorization.table[item.auth], config.user_input.force_pass and colors.good or colors.bad)
                    end

                    if item._IsLock then
                        imgui.same_line()
                        imgui.text_colored('Locked - Editing Disabled', colors.info_warn)
                    end

                    if item.changed then
                        if item.selected then
                            config.user_input.selection[item._QuestNo] = item.name
                        else
                            config.user_input.selection[item._QuestNo] = nil
                        end
                    end
                end
            end

            imgui.unindent(10)
            imgui.separator()
            imgui.spacing()
        end
        imgui.end_window()
    else
        if mass_window.is_opened then imgui.end_window() end
        mass_window.is_opened = false
    end
end

function sub_window.draw()
    sub_window.pos = get_sub_window_pos()
    imgui.set_next_window_pos(sub_window.pos, sub_window.condition, sub_window.pivot)
    imgui.set_next_window_size(sub_window.size, sub_window.condition)

    if imgui.begin_window("Valid Combinations", sub_window.is_opened, sub_window.flags) then
        imgui.text('All combinations here pass Authorization but that doesnt mean that the game can actually generate those')
        imgui.new_line()
        imgui.text('Main target follows MYSTERY rank')
        imgui.text('Sub target follows NORMAL rank')
        imgui.text('Authorization doesnt check Extra targets and Intruders at all')
        imgui.text('4 Target Num works from level 1')
        create_table(table_valid_combination)
        imgui.new_line()
        create_table(table_valid_time_limit)
        imgui.new_line()
        imgui.text('Normal Rank 11 Rules')
        create_table(table_normal_rank_11_rules)
        imgui.new_line()
        imgui.text("Extra maps available from level 181(Not for all monsters): Infernal Springs, Arena, Forlorn Arena")
        imgui.text('Quest cant have duplicate monsters.')
        imgui.text('Quest cant have two Apex monsters.')
        imgui.text('Apex monsters cant be intruders or extra targets.')
        imgui.text('Risen EDs can appear only as a main target.')
        imgui.end_window()
    else
        if sub_window.is_opened then imgui.end_window() end
        sub_window.is_opened = false
    end
end

function config_menu.draw()
    imgui.push_style_var(11, 5.0) -- Rounded elements
    imgui.push_style_var(2, 10.0) -- Window Padding
    imgui.set_next_window_pos(main_window.pos, main_window.condition, main_window.pivot)
    imgui.set_next_window_size(main_window.size, main_window.condition)

    if imgui.begin_window(string.format("%s %s", config.name, config.version), config_menu.is_opened, main_window.flags) then

        if data.get_spacewatcher() then
            data.game_state.current = data.get_spacewatcher()._GameState
        end

        if data.aie.quest_counter_open or data.game_state.current ~= 4 or data.get_questman():isActiveQuest() then
            imgui.text_colored('Mod works only in the lobby with quest counter closed.', colors.bad)
        else

            if (
                data.get_questman()
                and not data.mystery_quests.dumped
                and data.game_state.current == 4
                or (
                    data.game_state.current == 4
                    and data.game_state.previous ~= 4
                )
            ) then
                data.reset_mystery_data(true)
            end

            imgui.spacing()
            imgui.indent(10)

            imgui.text('Quest Count: ')
            imgui.same_line()
            imgui.text_colored(data.mystery_quests.count, data.mystery_quests.count > 1 and data.mystery_quests.count < data.aie.max_quest_count and colors.info or colors.info_warn)
            imgui.same_line()
            imgui.text('/  ' .. data.aie.max_quest_count)

            _, config.user_input.force_pass = imgui.checkbox('Force Authorization Pass', config.user_input.force_pass)

            imgui.separator()
            imgui.spacing()
            imgui.unindent(10)

            if imgui.collapsing_header('Editor') then
                imgui.indent(10)

                if changed.filter then
                    filter.filter_names()
                    if data.quest_pick.quest then config.reset_input() end
                end
                if changed.quest then config.reset_input() end

                changed.mode, config.user_input.mode = imgui.combo('Mode', config.user_input.mode, {'Single Quest', 'Multiple Quests'})
                if changed.mode then
                    config.user_input.quest_pick = 1
                    data.quest_pick.quest = data.mystery_quests.table[ data.mystery_quests.names_filtered[ config.user_input.quest_pick ] ]
                    config.reset_input()
                end

                if config.user_input.mode == 1 then
                    changed.filter, config.user_input.filter = imgui.input_text('Filter', config.user_input.filter)
                    filter_button()
                    changed.quest, config.user_input.quest_pick = imgui.combo('Quest', config.user_input.quest_pick, data.mystery_quests.names_filtered)
                    data.quest_pick.quest = data.mystery_quests.table[ data.mystery_quests.names_filtered[ config.user_input.quest_pick ] ]
                    mass_window.is_opened = false
                else
                    mass_window.is_opened = true
                    imgui.text('Quests Selected: ')
                    imgui.same_line()
                    config.user_input.selection_count = 0
                    data.quest_pick.quest = nil

                    for _, v in pairs(config.user_input.selection) do
                        if v then
                            config.user_input.selection_count = config.user_input.selection_count + 1
                            if not data.quest_pick.quest then
                                data.quest_pick.quest = data.mystery_quests.table[v]
                            end
                        end
                    end
                    imgui.text_colored(config.user_input.selection_count, colors.info)
                end

                if data.quest_pick.quest then
                    if changed.map then
                        data.get_arrays()
                    end

                    if config.user_input.target_num < 4 then
                        config.user_input.monster3.pick = misc.index_of(data.monster_arrays.extra.current, 'None - 0 - 0')
                    end

                    if config.user_input.target_num > 2 then
                        config.user_input.monster5.pick = misc.index_of(data.monster_arrays.extra.current, 'None - 0 - 0')
                    end

                    if data.maps.extra[ data.maps.array[config.user_input.map] ] then
                        if config.user_input.target_num < 3 then
                            config.user_input.monster2.pick = misc.index_of(data.monster_arrays.extra.current, 'None - 0 - 0')
                        end

                        if config.user_input.target_num < 2 then
                            config.user_input.monster1.pick = misc.index_of(data.monster_arrays.extra.current, 'None - 0 - 0')
                        end

                        config.user_input.monster5.pick = misc.index_of(data.monster_arrays.extra.current, 'None - 0 - 0')
                    end

                    if config.user_input.mode == 1 then
                        imgui.separator()

                        imgui.text('Quest Level: ')
                        imgui.same_line()
                        imgui.text_colored(data.quest_pick.quest._QuestLv, colors.info)

                        imgui.text('Map: ')
                        imgui.same_line()
                        imgui.text_colored(data.maps.id_table[ data.quest_pick.quest._MapNo ], colors.info)

                        imgui.text('Monster 1: ')
                        imgui.same_line()
                        imgui.text_colored(data.monsters.table[ tostring(data.quest_pick.quest.monster0) ].name, colors.info)

                        imgui.text('Monster 2: ')
                        imgui.same_line()
                        imgui.text_colored(data.monsters.table[ tostring(data.quest_pick.quest.monster1) ].name, colors.info)

                        imgui.text('Monster 3: ')
                        imgui.same_line()
                        imgui.text_colored(data.monsters.table[ tostring(data.quest_pick.quest.monster2) ].name, colors.info)

                        imgui.text('Monster 4: ')
                        imgui.same_line()
                        imgui.text_colored(data.monsters.table[ tostring(data.quest_pick.quest.monster3) ].name, colors.info)

                        imgui.text('Intruder: ')
                        imgui.same_line()
                        imgui.text_colored(data.monsters.table[ tostring(data.quest_pick.quest.monster5) ].name, colors.info)

                        imgui.text('Target Num: ')
                        imgui.same_line()
                        imgui.text_colored(data.quest_pick.quest._HuntTargetNum, colors.info)

                        imgui.text('Time Limit: ')
                        imgui.same_line()
                        imgui.text_colored(data.quest_pick.quest._TimeLimit, colors.info)

                        imgui.text('Quest Life: ')
                        imgui.same_line()
                        imgui.text_colored(data.quest_pick.quest._QuestLife, colors.info)

                        imgui.text('Time of Day: ')
                        imgui.same_line()
                        imgui.text_colored(data.tod.array[ data.quest_pick.quest._StartTime + 1], colors.info)

                        imgui.text('Hunter Num: ')
                        imgui.same_line()
                        imgui.text_colored(data.quest_pick.quest._QuestOrderNum, colors.info)

                        imgui.text('Lock: ')
                        imgui.same_line()
                        imgui.text_colored(data.quest_pick.quest._IsLock and 'Yes - Editing Disabled' or 'No', data.quest_pick.quest._IsLock and colors.info_warn or colors.info)

                        imgui.text('Special Open: ')
                        imgui.same_line()
                        imgui.text_colored(data.quest_pick.quest._isSpecialQuestOpen and "Yes" or "No", colors.info)

                        imgui.text('Auth Status: ')
                        imgui.same_line()
                        imgui.text_colored((data.quest_pick.quest.auth == 0 and "Pass" or data.authorization.table[data.quest_pick.quest.auth]), (config.user_input.force_pass and colors.good or data.quest_pick.quest.auth == 0 and colors.good or colors.bad))

                        imgui.separator()
                    end

                    if config.user_input.mode == 1 then
                        changed.map, config.user_input.map = imgui.combo('Map', config.user_input.map, data.maps.array)
                    end

                    if config.user_input.mode == 1 then
                        imgui.new_line()
                        imgui.text('Name - Mystery Rank - Normal Rank')
                        _, config.user_input.monster0.pick = imgui.combo('Monster 1', config.user_input.monster0.pick, data.monster_arrays.main.current)
                        _, config.user_input.monster1.pick = imgui.combo('Monster 2', config.user_input.monster1.pick, data.monster_arrays.extra.current)
                        set_tooltip('Always None below 2 Target Num on Extra Maps', true)
                        _, config.user_input.monster2.pick = imgui.combo('Monster 3', config.user_input.monster2.pick, data.monster_arrays.extra.current)
                        set_tooltip('Always None below 3 Target Num on Extra Maps', true)
                        _, config.user_input.monster3.pick = imgui.combo('Monster 4', config.user_input.monster3.pick, data.monster_arrays.extra.current)
                        set_tooltip('Always None below 4 Target Num', true)
                        _, config.user_input.monster5.pick = imgui.combo('Intruder', config.user_input.monster5.pick, data.monster_arrays.extra.current)
                        set_tooltip('Always None above 2 Target Num', true)
                    end

                    if config.user_input.mode == 1 then
                        imgui.new_line()
                    end

                    if config.user_input.mode == 1 or config.user_input.mode == 2 and config.user_input.edit_tod then
                        _, config.user_input.tod = imgui.combo('Time of Day', config.user_input.tod, data.tod.array)
                    end

                    if config.user_input.mode == 1 or config.user_input.mode == 2 and config.user_input.edit_special_open then
                        _, config.user_input.special_open = imgui.combo('Special Open', config.user_input.special_open, {"No", "Yes"})
                        set_tooltip('You can open Special Quest only if Quest Level is at 300 and you already unlocked them', true)
                    end

                    if config.user_input.mode == 1 or config.user_input.mode == 2 and config.user_input.edit_quest_lvl then
                        _, config.user_input.quest_lvl = imgui.slider_int('Quest Level', config.user_input.quest_lvl, 1, data.aie.max_quest_level)
                    end

                    if config.user_input.mode == 1 or config.user_input.mode == 2 and config.user_input.edit_target_num then
                        _, config.user_input.target_num = imgui.slider_int('Target Num', config.user_input.target_num, 1, data.aie.target_num_cap)
                    end

                    if config.user_input.mode == 1 or config.user_input.mode == 2 and config.user_input.edit_quest_life then
                        _, config.user_input.quest_life = imgui.slider_int('Quest Life', config.user_input.quest_life, 1, data.aie.max_quest_life)
                    end

                    if config.user_input.mode == 1 or config.user_input.mode == 2 and config.user_input.edit_time_limit then
                        _, config.user_input.time_limit = imgui.slider_int('Time Limit', config.user_input.time_limit, 1, data.aie.max_quest_time_limit)
                    end

                    if config.user_input.mode == 1 or config.user_input.mode == 2 and config.user_input.edit_hunter_num then
                        _, config.user_input.hunter_num = imgui.slider_int('Hunter Num', config.user_input.hunter_num, 1, data.aie.max_quest_hunter_num)
                    end

                    config.user_input.monster0.id = data.monsters.id_table[ data.monster_arrays.main.current[ config.user_input.monster0.pick ] ]
                    config.user_input.monster1.id = data.monsters.id_table[ data.monster_arrays.extra.current[ config.user_input.monster1.pick ] ]
                    config.user_input.monster2.id = data.monsters.id_table[ data.monster_arrays.extra.current[ config.user_input.monster2.pick ] ]
                    config.user_input.monster3.id = data.monsters.id_table[ data.monster_arrays.extra.current[ config.user_input.monster3.pick ] ]
                    config.user_input.monster5.id = data.monsters.id_table[ data.monster_arrays.extra.current[ config.user_input.monster5.pick ] ]
                end

                if sub_window.is_opened then
                    sub_window.draw()
                end

                if mass_window.is_opened then
                    mass_window.draw()
                end

                imgui.spacing()
                if (
                    data.quest_pick.quest
                    and (
                        config.user_input.mode == 1
                        or (
                            config.user_input.mode == 2
                            and (
                                 config.user_input.edit_tod
                                 or config.user_input.edit_special_open
                                 or config.user_input.edit_quest_lvl
                                 or config.user_input.edit_target_num
                                 or config.user_input.edit_quest_life
                                 or config.user_input.edit_time_limit
                                 or config.user_input.edit_hunter_num
                            )
                        )
                    )
                ) then
                    if imgui.button(spaced('Edit Quest', 3)) then
                        if config.user_input.mode == 1 then
                            editor.edit_quest()
                        elseif config.user_input.mode == 2 and config.user_input.selection_count > 0 then
                            imgui.open_popup('edit')
                        end
                    end
                    if popup_yesno('Are you sure?','edit') then
                        editor.edit_quest()
                    end
                    imgui.same_line()
                end

                if data.quest_pick.quest then
                    if imgui.button(spaced('Lock/Unlock', 3)) then editor.lock_unlock_quest() end
                    imgui.same_line()
                end
                if imgui.button(spaced('Valid Combinations', 3)) then sub_window.is_opened = true end
                -- imgui.same_line()
                -- if imgui.button(spaced('Dump Monsters', 3)) then data.dump_monsters() end

                imgui.unindent(10)
                imgui.separator()
                imgui.spacing()
            else
                sub_window.is_opened = false
            end

            if imgui.collapsing_header('Generator') then
                imgui.indent(10)

                _, config.user_input.rand = imgui.combo('Random Quest Rank', config.user_input.rand, data.rand_rank.array)
                _, config.user_input.amount_to_generate = imgui.slider_int('Amount', config.user_input.amount_to_generate, 1, data.aie.max_quest_count - 1)
                imgui.spacing()

                if imgui.button(spaced('Generate Random Quest', 3)) then
                    editor.generate_random(data.rand_rank.table[ data.rand_rank.array[config.user_input.rand] ], config.user_input.amount_to_generate)
                end

                imgui.same_line()
                if imgui.button(spaced('Delete Quests', 3)) then
                    imgui.open_popup('delete')
                end
                set_tooltip('Deletes all quests except newest one and locked ones')

                if popup_yesno('Are you sure?','delete') then
                    editor.wipe()
                end

                if imgui.tree_node('Probabilities at ' .. data.aie.max_quest_level .. ' Research Level') then
                    create_table(table_probabilities)
                    imgui.tree_pop()
                end

                imgui.unindent(10)
                imgui.separator()
                imgui.spacing()
            end
        end
        data.game_state.previous = data.game_state.current
        imgui.pop_style_var(2)
        imgui.end_window()
    else
        if config_menu.is_opened then
            imgui.pop_style_var(2)
            imgui.end_window()
        end
        config_menu.is_opened = false
        sub_window.is_opened = false
        mass_window.is_opened = false
    end
end


function config_menu.init()
    data = require('Anomaly Investigations Editor/data')
    config = require('Anomaly Investigations Editor/config')
    editor = require('Anomaly Investigations Editor/editor')
    filter = require('Anomaly Investigations Editor/filter')
    misc = require('Anomaly Investigations Editor/misc')

    table_valid_combination.data = data.valid_combinations
    table_probabilities.data = data.probabilties
    table_valid_time_limit.data = data.valid_time_limit
    table_normal_rank_11_rules.data = data.normal_rank_11_rules
end

return config_menu

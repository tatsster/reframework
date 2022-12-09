local monsters = json.load_file('Anomaly Investigations Editor/monsters.json')

if not monsters then return end

local version = '1.3.1'

local create_random_mystery_quest = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('CreateRandomMysteryQuest')
local random_mystery_quest_auth = sdk.find_type_definition('snow.quest.nRandomMysteryQuest'):get_method('checkRandomMysteryQuestOrderBan')

local singletons = {}
local main_window = {
	flags=0x10120,
	pos=Vector2f.new(50, 50),
	pivot=Vector2f.new(0, 0),
	size=Vector2f.new(560, 890),
	condition=1 << 3,
	is_opened=false
}
local sub_window = {
	flags=0x10120,
	pos=nil,
	pivot=Vector2f.new(0, 0),
	size=Vector2f.new(850, 350),
	condition=1 << 3,
	is_opened=false
}
local table_1 = {
	name='1',
	flags=0x12780,
	row_flags=0x1,
	col_count=9,
	row_count=8,
	data={
		{'','1    ','1-4','1-5','2-6','3-7','4-7','5-7','6-7'},
		{'1',100,25,10,0,0,0,0,0},
		{'2',0,43,25,10,0,0,0,0},
		{'3',0,27,37,25,15,0,0,0},
		{'4',0,5,23,37,30,15,0,0},
		{'5',0,0,5,23,37,32,23,0},
		{'6',0,0,0,5,15,38,40,37},
		{'7',0,0,0,0,3,15,37,63},
	}
}
local table_2 = {
	name='2',
	flags=0x1278016384,
	row_flags=0x1,
	col_count=10,
	row_count=8,
	data={
		{'Quest Level','1-10','11-20','21-30','31-40','41-50','51-60','61-70','71-90','91-200'},
		{'Main Target Mystery Rank','0','0-1','0-2','0-3','0-3','0-4','0-4','0-5','0-6'},
		{'Sub Target Mystery Rank','-','-','0-3,11(Apex)','0-5,11(Apex)','0-5,11','0-5,11','0-6,11','0-6,11','0-6,11'},
		{'Extra Target Mystery Rank','0-1','0-2','0-3','0-5','0-5,11(ED)','0-5,11(ED)','0-6,11(ED)','0-6,11(ED)','0-6,11(ED)'},
		{'Target Num','1','1','1-2','1-2','1-3','1-3','1-3','1-3','1-3'},
		{'Quest Life','3-5,9','3-5,9','3-5','3-5','2-5','2-5','2-5','2-5','1-4'},
		{'Time Limit','50','50','30,35,50','30,35,50','25,30,35,50','25,30,35,50','25,30,35,50','25,30,35,50','25,30,35,50'},
		{'Hunter Num','4','4','4','4','4','4','4','2,4','2,4'}
	}
}
local table_3 = {
	name='3',
	flags=0x780,
	row_flags=0x1,
	col_count=4,
	row_count=2,
	data={
		{'Target Num','1','2','3'},
		{'Time Limit','25,30,35,50','30,35,50','50'}
	}
}
local monsters = {
	data=monsters,
	id_table={}
}
local monster_arrays = {
	main={
		map_valid={},
		current={}
	},
	extra={
		map_valid={},
		current={}
	},
	intruder={
		map_valid={},
		current={}
	}
}
local maps = {
	data={
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
	invalid={
		["Infernal Springs"]=9,
		["Arena"]=10,
		["Forlorn Arena"]=14
	},
	array={},
	id_table={}
}
local mystery_quests = {
	data={},
	names={},
	names_filtered={},
	dumped=false,
	count=1
}
local rand_rank = {
	data={
		['1']=0,
		['1-4']=107,
		['1-5']=19,
		['2-6']=1,
		['3-7']=349,
		['4-7']=351,
		['5-7']=350,
		['6-7']=1303
	},
	array={}
}
local tod = {
	data={
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
local user_input = {
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
	monster5={
		pick=1,
		id=nil
	}
}
local game_state = {
	current=0,
	previous=0
}
local changed = {
	filter=true,
	map=false,
	quest=false,
	target_num=false
}
local quest_pick = {
	quest=nil,
	name=nil,
	sort=nil
}
local authorization = {
	data={
		[0]='Pass',
		[1]='Fail',
		[2]='Quest Level Too High',
		[3]='Research Level Too Low',
		[4]='Invalid Monsters',
		[5]='Quest Level Too Low',
		[6]='Invalid Quest Conditions',
		[-1]='Invalid Map'
	},
	status=0,
	force_pass=false,
	force_check=false,
	check=true
}
local colors = {
	bad=0xff1947ff,
	good=0xff47ff59,
	info=0xff27f3f5,
	info_warn=0xff2787FF,
}
local aie = {
	reload=true,
	quest_counter_open=false,
	target_num_cap=3,
	max_quest_count=120,
	max_quest_level=200,
	max_quest_life=9,
	max_quest_time_limit=50,
	max_quest_hunter_num=4,
}


for id,data in pairs(monsters.data) do
	if id ~= "0" then
		for _,map_id in pairs(maps.invalid) do
			monsters.data[id].maps[tostring(map_id)] = true
		end
	end
	monsters.id_table[ data.name..' - '..data.mystery_rank ] = id
end

for name,id in pairs(maps.data) do
	maps.id_table[id] = name
	table.insert(maps.array,name)
end
table.sort(maps.array)

for name,_ in pairs(rand_rank.data) do
	table.insert(rand_rank.array,name)
end
table.sort(rand_rank.array)


local function get_questman()
    if not singletons.questman then
        singletons.questman = sdk.get_managed_singleton('snow.QuestManager')
    end
    return singletons.questman
end

local function get_spacewatcher()
    if not singletons.spacewatcher then
        singletons.spacewatcher = sdk.get_managed_singleton('snow.wwise.WwiseChangeSpaceWatcher')
    end
    return singletons.spacewatcher
end

local function index_of(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

local function get_free_quest_no()
	local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData')
	local mystery_quest_no = get_questman():call('getFreeMysteryQuestNo')
	local quest_idx_list = get_questman():call('getFreeSpaceMysteryQuestIDXList',mystery_quest_data,mystery_quest_no,1,true)
	local free_mystery_idx_list = get_questman():call('getFreeMysteryQuestDataIdx2IndexList',quest_idx_list)
	local mystery_idx = free_mystery_idx_list:call('get_Item',0)
	return mystery_quest_no + 700000,mystery_idx
end

local function get_quest_count()
	return 120 - get_questman():call('getFreeMysteryQuestDataIndexList',120):call('get_Count')
end

local function get_mystery_quest_data_table()
    local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData')
    mystery_quests.names = {}
    mystery_quests.data = {}
    for i=0,mystery_quest_data:call('get_Count')-1 do
    	local quest = {}
    	quest.data = mystery_quest_data:call('get_Item',i)
    	quest.no = quest.data:get_field('_QuestNo')
        if quest.no ~= -1 then
        	quest.map = quest.data:get_field('_MapNo')

        	if not maps.id_table[quest.map] then goto continue end

        	quest.monsters = quest.data:get_field('_BossEmType')

        	for _,idx in pairs({0,1,2,5}) do

        		quest['monster'..idx] = quest.monsters:call('get_Item',idx)

        		if not monsters.data[ tostring(quest['monster'..idx]) ] then goto continue end
        	end

        	quest.lvl = quest.data:get_field('_QuestLv')
            quest.key = monsters.data[ tostring(quest.monster0) ].name .. '  -  '.. quest.lvl .. '  -  ' .. maps.id_table[quest.map] .. '  -  ' .. quest.no

            table.insert(mystery_quests.names,quest.key)

            mystery_quests.data[ quest.key ] = {
            						_QuestNo=quest.no,
            						sort=quest.data:get_field('_Idx'),
            						name=quest.key,
            						index=i,
                                    _QuestLv=quest.lvl,
                                    _IsLock=quest.data:get_field('_IsLock'),
                                    _QuestType=quest.data:get_field('_QuestType'),
                                    _MapNo=quest.map,
                                    _BaseTime=quest.data:get_field('_BaseTime'),
                                    _HuntTargetNum=quest.data:get_field('_HuntTargetNum'),
                                    monster0=quest.monster0,
                                    monster1=quest.monster1,
                                    monster2=quest.monster2,
                                    monster5=quest.monster5,
                                    _TimeLimit=quest.data:get_field('_TimeLimit'),
                                    _QuestLife=quest.data:get_field('_QuestLife'),
                                    _StartTime=quest.data:get_field('_StartTime'),
                                    _QuestOrderNum=quest.data:get_field('_QuestOrderNum'),
                                    data=quest.data
			}

			::continue::
        end
    end

    table.sort(mystery_quests.names,function(x,y) return mystery_quests.data[x].sort > mystery_quests.data[y].sort end)
    mystery_quests.dumped = true
end

local function reset_data(reset_quest_pick)
	if not reset_quest_pick then
		quest_pick.name = mystery_quests.names[ user_input.quest_pick ]
	else
		quest_pick.name = nil
	end

	if quest_pick.name then quest_pick.sort = mystery_quests.data[ quest_pick.name ].sort end

	get_mystery_quest_data_table()
	mystery_quests.count = get_quest_count()
	changed.filter = true
	authorization.check = true
end

local function generate_random(id)
	if mystery_quests.count == 120 then return end

	local mystery_data = sdk.create_instance('snow.quest.RandomMysteryQuestData')
	local mystery_quest_no,mystery_index = get_free_quest_no()

	if not mystery_quest_no then
		reset_data()
	 	return
	end

	mystery_data:set_field('_QuestLv',201)
	mystery_data:get_field('_BossEmType'):call('set_Item',0,id)

	create_random_mystery_quest:call(get_questman(),mystery_data,1,mystery_index,mystery_quest_no,true)

	user_input.quest_pick = 1
	reset_data(true)
end

local function edit_quest(mystery_data)
	if mystery_quests.count == 1 or mystery_data:get_field('_IsLock') then return end

	local quest_save_data = get_questman():get_field('<SaveData>k__BackingField')
	local mystery_seeds = quest_save_data:get_field('_RandomMysteryQuestSeed')
	local data = {}
	local default = {
		[1]={
			mon0_cond=1,
			mon1_cond=14,
			mon2_cond=14,
			mon5_cond=15,
		},
		[2]={
			mon0_cond=1,
			mon1_cond=1,
			mon2_cond=14,
			mon5_cond=15,
		},
		[3]={
			mon0_cond=3,
			mon1_cond=1,
			mon2_cond=1,
			mon5_cond=0,
		},
		quest_type=2,
	}

	if not mystery_data then
		reset_data()
		return
	end

	if user_input.target_num == 2 and monsters.data[user_input.monster1.id].capture
	or user_input.target_num == 3 and (monsters.data[user_input.monster1.id].capture or monsters.data[user_input.monster2.id].capture) then
		default.quest_type = 1
	end

	mystery_data:set_field('_MapNo',maps.data[ maps.array[ user_input.map ] ])
	mystery_data:set_field('_HuntTargetNum',user_input.target_num)
	mystery_data:set_field('_TimeLimit',user_input.time_limit)
	mystery_data:set_field('_QuestLife',user_input.quest_life)
	mystery_data:set_field('_QuestOrderNum',user_input.hunter_num)
	mystery_data:set_field('_StartTime',tod.data[ tod.array[ user_input.tod ] ])
	mystery_data:set_field('_QuestLv',user_input.quest_lvl)
	mystery_data:set_field('_QuestType',default.quest_type)
	mystery_data:set_field('_IsNewFlag',true)
	mystery_data:set_field('_OriginQuestLv',0)


	data.em_types = mystery_data:get_field('_BossEmType')
	data.em_types:call('set_Item',0,tonumber(user_input.monster0.id))
	data.em_types:call('set_Item',1,tonumber(user_input.monster1.id))
	data.em_types:call('set_Item',2,tonumber(user_input.monster2.id))
	data.em_types:call('set_Item',5,tonumber(user_input.monster5.id))

	if user_input.monster1.id == 0 then default[user_input.target_num].mon1_cond = 0 end
	if user_input.monster2.id == 0 then default[user_input.target_num].mon2_cond = 0 end
	if user_input.monster5.id == 0 then default[user_input.target_num].mon5_cond = 0 end

	data.em_cond = mystery_data:get_field('_BossSetCondition')
	data.em_cond:call('set_Item',0,default[user_input.target_num].mon0_cond)
	data.em_cond:call('set_Item',1,default[user_input.target_num].mon1_cond)
	data.em_cond:call('set_Item',2,default[user_input.target_num].mon2_cond)
	data.em_cond:call('set_Item',5,default[user_input.target_num].mon5_cond)

	data.swap_cond = mystery_data:get_field('_SwapSetCondition')
	data.swap_param = mystery_data:get_field('_SwapSetParam')

	if user_input.monster5.id == 0 then
		data.swap_cond:call('set_Item',0,0)
		data.swap_param:call('set_Item',0,0)
		mystery_data:set_field('_SwapStopType',0)
		mystery_data:set_field('_SwapExecType',0)
	else
		data.swap_cond:call('set_Item',0,1)
		data.swap_param:call('set_Item',0,12)
		mystery_data:set_field('_SwapStopType',1)
		mystery_data:set_field('_SwapExecType',1)
	end

	mystery_data:set_field('_MainTargetMysteryRank',monsters.data[user_input.monster0.id].mystery_rank)

	data.seed = get_questman():call('getRandomQuestSeedFromQuestNo',mystery_data:get_field('_QuestNo'))
	data.seed_index = mystery_seeds:call('IndexOf',data.seed)

	if not data.seed or not data.seed_index then return end

	data.seed:set_field('_QuestLv',user_input.quest_lvl)
	data.seed:set_field('_HuntTargetNum',user_input.target_num)
	data.seed:set_field('_MapNo',maps.data[ maps.array[ user_input.map ] ])
	data.seed:set_field('_TimeLimit',user_input.time_limit)
	data.seed:set_field('_QuestLife',user_input.quest_life)
	data.seed:set_field('_QuestOrderNum',user_input.hunter_num)
	data.seed:set_field('_StartTime',tod.data[ tod.array[ user_input.tod ] ])
	data.seed:set_field('_MysteryLv',aie.max_quest_level)
	data.seed:set_field('_QuestType',default.quest_type)
	data.seed:set_field('_OriginQuestLv',0)
	data.seed:call('setEnemyTypes',data.em_types)
	mystery_seeds:call('set_Item',data.seed_index,data.seed)

	reset_data()
end

local function get_arrays()
	local map_id = tostring( maps.data[ maps.array[ user_input.map ] ] )

	monster_arrays.main.current = {}
	monster_arrays.extra.current = {}
	monster_arrays.intruder.current = {}
	monster_arrays.main.map_valid = {}
	monster_arrays.extra.map_valid = {}
	monster_arrays.intruder.map_valid = {}

	user_input.monster0.pick = 1
	user_input.monster1.pick = 2
	user_input.monster2.pick = 3
	user_input.monster5.pick = 1

	for name,id in pairs(monsters.id_table) do
		if monsters.data[id].maps[map_id] then
			if monsters.data[id].main then
				table.insert(monster_arrays.main.map_valid,name)
			end
			table.insert(monster_arrays.extra.map_valid,name)
			table.insert(monster_arrays.intruder.map_valid,name)
		end
	end

	table.insert(monster_arrays.intruder.map_valid,'None - 0')
	table.insert(monster_arrays.extra.map_valid,'None - 0')

	table.sort(monster_arrays.main.map_valid)
	table.sort(monster_arrays.extra.map_valid)
	table.sort(monster_arrays.intruder.map_valid)

	monster_arrays.main.current = monster_arrays.main.map_valid
	monster_arrays.extra.current = monster_arrays.extra.map_valid
	monster_arrays.intruder.current = monster_arrays.intruder.map_valid

end

local function filter_names()
	mystery_quests.names_filtered = {}
	user_input.quest_pick = nil

	for _,name in ipairs(mystery_quests.names) do
		if string.find(name:lower(),user_input.filter:lower()) then
			table.insert(mystery_quests.names_filtered,name)
		end
	end

	if #mystery_quests.names_filtered > 0 and quest_pick.name then
		user_input.quest_pick = index_of(mystery_quests.names_filtered,quest_pick.name)
		if not user_input.quest_pick then
			for _,quest in pairs(mystery_quests.data) do
				if quest.sort == quest_pick.sort then
					user_input.quest_pick = index_of(mystery_quests.names_filtered,quest.name)
					break
				end
			end
		end
	end

	if not user_input.quest_pick then
		user_input.quest_pick = 1
		aie.reload = true
		authorization.check = true
	end
end

local function get_monster_pick(array,monster_id)
	local monster = {
		name=monsters.data[ tostring(monster_id) ].name,
		rank=monsters.data[ tostring(monster_id) ].mystery_rank
	}
	return index_of(array,monster.name..' - '..monster.rank)
end

local function reset_input()
	user_input.map = index_of(maps.array,maps.id_table[ quest_pick.quest._MapNo ])
	get_arrays()

	user_input.tod = quest_pick.quest._StartTime + 1
	user_input.quest_lvl = quest_pick.quest._QuestLv
	user_input.target_num = quest_pick.quest._HuntTargetNum
	user_input.quest_life = quest_pick.quest._QuestLife
	user_input.time_limit = quest_pick.quest._TimeLimit
	user_input.hunter_num = quest_pick.quest._QuestOrderNum
	aie.target_num_cap = 3

	if maps.invalid[ maps.id_table[ quest_pick.quest._MapNo ] ] then
		monster_arrays.extra.current = {'None - 0'}
		monster_arrays.intruder.current = {'None - 0'}
		aie.target_num_cap = 1
	elseif user_input.target_num == 3 then
		monster_arrays.intruder.current = {'None - 0'}
	end

	user_input.monster0.pick = get_monster_pick(monster_arrays.main.current,quest_pick.quest.monster0)
	user_input.monster1.pick = get_monster_pick(monster_arrays.extra.current,quest_pick.quest.monster1)
	user_input.monster2.pick = get_monster_pick(monster_arrays.extra.current,quest_pick.quest.monster2)
	user_input.monster5.pick = get_monster_pick(monster_arrays.intruder.current,quest_pick.quest.monster5)

	aie.reload = false
end

local function quest_check(mystery_data)
	authorization.force_check = true
	authorization.status = random_mystery_quest_auth:call(get_questman(),mystery_data,false)

	if authorization.status == 4 and maps.invalid[ maps.id_table[ mystery_data:get_field('_MapNo') ] ] then
		authorization.status = -1
	end

	authorization.force_check = false
	authorization.check = false
end

local function wipe()
	local mystery_quest_data = get_questman():get_field('_RandomMysteryQuestData'):get_elements()
	local quest_save_data = get_questman():get_field('<SaveData>k__BackingField')
	local mystery_seeds = quest_save_data:get_field('_RandomMysteryQuestSeed')
	local data = {}

	data.newest_quest_no = mystery_quests.data[ mystery_quests.names[1] ]._QuestNo

	for _,quest in ipairs(mystery_quest_data) do
		data.no = quest:get_field('_QuestNo')
		if not quest:get_field('_IsLock') and data.no ~= -1 and data.no ~= data.newest_quest_no then
			data.seed = get_questman():call('getRandomQuestSeedFromQuestNo',data.no)
			data.seed_index = mystery_seeds:call('IndexOf',data.seed)
			quest:call('clear')
			data.seed:call('clear')
			mystery_seeds:call('set_Item',data.seed_index,data.seed)
		end
	end
	reset_data(true)
end

local function lock_unlock_quest(quest)
	local quest_save_data = get_questman():get_field('<SaveData>k__BackingField')
	local mystery_seeds = quest_save_data:get_field('_RandomMysteryQuestSeed')
	local seed = get_questman():call('getRandomQuestSeedFromQuestNo',quest.data._QuestNo)
	local seed_index = mystery_seeds:call('IndexOf',seed)
	quest.data._IsLock = not quest.data._IsLock
	quest._IsLock = not quest._IsLock
	seed:set_field('_IsLock',quest._IsLock)
	mystery_seeds:call('set_Item',seed_index,seed)
end

local function create_table(tbl)
	if imgui.begin_table(tbl.name,tbl.col_count, tbl.flags) then
		for row=0,tbl.row_count-1 do

			if (row % 2 == 0) then
				imgui.table_next_row()
			else
				imgui.table_next_row(tbl.row_flags)
			end

			for col=0,tbl.col_count-1 do
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
	sub_window.pos = Vector2f.new(main_window_pos.x + main_window_size.x, main_window_pos.y)
end


sdk.hook(
	random_mystery_quest_auth,
	function(args)
		end,
	function(retval)
		if authorization.force_pass and aie.quest_counter_open and not authorization.force_check then
			return sdk.to_ptr(0)
		else
			return retval
		end
	end
)


sdk.hook(
	sdk.find_type_definition('snow.SnowSingletonBehaviorRoot`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('awake'),
    function(args)
    	aie.quest_counter_open = true
    end
)

sdk.hook(
	sdk.find_type_definition('snow.gui.fsm.GuiFsmBaseManager`1<snow.gui.fsm.questcounter.GuiQuestCounterFsmManager>'):get_method('onDestroy'),
    function(args)
    	reset_data()
    	aie.quest_counter_open = false
    end
)


if sdk.get_managed_singleton('snow.gui.fsm.questcounter.GuiQuestCounterFsmManager') then aie.quest_counter_open = true end


re.on_frame(function()
	if not reframework:is_drawing_ui() then
	    main_window.is_opened = false
	    sub_window.is_opened= false
	end
end
)

re.on_draw_ui(function()
    if imgui.button("Anomaly Investigations Editor "..version) then
        main_window.is_opened = true
    end

    if main_window.is_opened then

	    imgui.set_next_window_pos(main_window.pos, main_window.condition, main_window.pivot)
	    imgui.set_next_window_size(main_window.size, main_window.condition)

        if imgui.begin_window("Anomaly Investigations Editor "..version, main_window.is_opened, main_window.flags) then

			if get_spacewatcher() then
				game_state.current = get_spacewatcher():get_field('_GameState')
			end

			if aie.quest_counter_open or game_state.current ~= 4 or get_questman():call('isActiveQuest') then
				imgui.text_colored('Mod works only in the lobby with quest counter closed.', colors.bad)
			else

				if get_questman() and not mystery_quests.dumped and game_state.current == 4
				or game_state.current == 4 and game_state.previous ~= 4 then
					reset_data(true)
				end

				if changed.filter then filter_names() end

				_,authorization.force_pass = imgui.checkbox('Force Authorization Pass', authorization.force_pass)
				changed.filter,user_input.filter = imgui.input_text('Filter',user_input.filter)
				changed.quest,user_input.quest_pick = imgui.combo('Quest',user_input.quest_pick,mystery_quests.names_filtered)
		        quest_pick.quest = mystery_quests.data[ mystery_quests.names_filtered[ user_input.quest_pick ] ]

		        if quest_pick.quest then

					if changed.map then
						get_arrays()
						if maps.invalid[ maps.array[user_input.map] ] then
							aie.target_num_cap = 1
							user_input.target_num = 1
						else
							aie.target_num_cap = 3
						end
						changed.target_num = true
					end

					if changed.target_num then
						if maps.invalid[ maps.array[user_input.map] ] then
							monster_arrays.extra.current = {'None - 0'}
							monster_arrays.intruder.current = {'None - 0'}
						else
							if user_input.target_num < 3 then
								monster_arrays.intruder.current = monster_arrays.intruder.map_valid
								user_input.monster5.pick = get_monster_pick(monster_arrays.intruder.current,quest_pick.quest.monster5)
							else
								monster_arrays.intruder.current = {'None - 0'}
							end
						end
					end

					if changed.quest then aie.reload = true end

					if changed.quest or authorization.check then quest_check(quest_pick.quest.data) end

					if aie.reload and mystery_quests.dumped then reset_input() end

			        imgui.text('Quest Level: ')
			        imgui.same_line()
			        imgui.text_colored(quest_pick.quest._QuestLv, colors.info)
			        imgui.text('Map: ')
			        imgui.same_line()
			        imgui.text_colored(maps.id_table[ quest_pick.quest._MapNo ], colors.info)
			        imgui.text('Monster 1: ')
					imgui.same_line()
			        imgui.text_colored(monsters.data[ tostring(quest_pick.quest.monster0) ].name, colors.info)
			        imgui.text('Monster 2: ')
			        imgui.same_line()
			        imgui.text_colored(monsters.data[ tostring(quest_pick.quest.monster1) ].name, colors.info)
			        imgui.text('Monster 3: ')
			        imgui.same_line()
			        imgui.text_colored(monsters.data[ tostring(quest_pick.quest.monster2) ].name, colors.info)
			        imgui.text('Intruder: ')
			        imgui.same_line()
			        imgui.text_colored(monsters.data[ tostring(quest_pick.quest.monster5) ].name, colors.info)
			        imgui.text('Target Num: ')
			        imgui.same_line()
			        imgui.text_colored(quest_pick.quest._HuntTargetNum, colors.info)
			        imgui.text('Time Limit: ')
			        imgui.same_line()
			        imgui.text_colored(quest_pick.quest._TimeLimit, colors.info)
			        imgui.text('Quest Life: ')
			        imgui.same_line()
			        imgui.text_colored(quest_pick.quest._QuestLife, colors.info)
			        imgui.text('Time of Day: ')
			        imgui.same_line()
			        imgui.text_colored(tod.array[ quest_pick.quest._StartTime +1], colors.info)
			        imgui.text('Hunter Num: ')
			        imgui.same_line()
			        imgui.text_colored(quest_pick.quest._QuestOrderNum, colors.info)
			        imgui.text('Lock: ')
			        imgui.same_line()
			        imgui.text_colored(quest_pick.quest._IsLock and 'Yes - Editing Disabled' or 'No', quest_pick.quest._IsLock and colors.info_warn or colors.info)
			    	imgui.text('Auth Status: ')
			    	imgui.same_line()
			    	imgui.text_colored((authorization.status == 0 and "Pass" or authorization.data[authorization.status]), (authorization.force_pass and colors.good or authorization.status == 0 and colors.good or colors.bad))
			        imgui.text('Quest Count: ')
			        imgui.same_line()
			        imgui.text_colored(mystery_quests.count, mystery_quests.count > 1 and mystery_quests.count < 120 and colors.info or colors.info_warn)
			        imgui.same_line()
			        imgui.text('/  '..aie.max_quest_count)

					changed.map,user_input.map = imgui.combo('Map',user_input.map,maps.array)
					imgui.new_line()

					imgui.text('Name - Mystery Rank')
					_,user_input.monster0.pick = imgui.combo('Monster 1',user_input.monster0.pick,monster_arrays.main.current)
					_,user_input.monster1.pick = imgui.combo('Monster 2',user_input.monster1.pick,monster_arrays.extra.current)
					_,user_input.monster2.pick = imgui.combo('Monster 3',user_input.monster2.pick,monster_arrays.extra.current)
					_,user_input.monster5.pick = imgui.combo('Intruder',user_input.monster5.pick,monster_arrays.intruder.current)

					imgui.new_line()
					_,user_input.tod = imgui.combo('Time of Day',user_input.tod,tod.array)
					_,user_input.quest_lvl = imgui.slider_int('Quest Level', user_input.quest_lvl, 1, aie.max_quest_level)
					changed.target_num,user_input.target_num = imgui.slider_int('Target Num', user_input.target_num, 1, aie.target_num_cap)
					_,user_input.quest_life = imgui.slider_int('Quest Life', user_input.quest_life, 1, aie.max_quest_life)
					_,user_input.time_limit = imgui.slider_int('Time Limit', user_input.time_limit, 1, aie.max_quest_time_limit)
					_,user_input.hunter_num = imgui.slider_int('Hunter Num', user_input.hunter_num, 1, aie.max_quest_hunter_num)

					user_input.monster0.id = monsters.id_table[ monster_arrays.main.current[ user_input.monster0.pick ] ]
					user_input.monster1.id = monsters.id_table[ monster_arrays.extra.current[ user_input.monster1.pick ] ]
					user_input.monster2.id = monsters.id_table[ monster_arrays.extra.current[ user_input.monster2.pick ] ]
					user_input.monster5.id = monsters.id_table[ monster_arrays.intruder.current[ user_input.monster5.pick ] ]

					if imgui.button('Edit Quest') then edit_quest(quest_pick.quest.data) end
					imgui.same_line()
					if imgui.button('Lock/Unlock') then lock_unlock_quest(quest_pick.quest) end
					imgui.same_line()
					if imgui.button('Valid Combinations') then sub_window.is_opened = true end

					imgui.new_line()

					_,user_input.rand = imgui.combo('Random Quest Rank',user_input.rand,rand_rank.array)
					_,user_input.amount_to_generate = imgui.slider_int('Amount', user_input.amount_to_generate, 1, aie.max_quest_count - 1)

					if imgui.tree_node('Probabilities at 200 Research Level') then
						create_table(table_1)
						imgui.tree_pop()
					end

					if imgui.button('Generate Random Quest') then
						local amount = user_input.amount_to_generate
						if mystery_quests.count + amount > aie.max_quest_count then
							amount = aie.max_quest_count - mystery_quests.count
						end
						for i=1,amount do
							generate_random(rand_rank.data[ rand_rank.array[user_input.rand] ])
						end
					end

					imgui.same_line()
					if imgui.button('Delete Quests') then wipe() end

					if sub_window.is_opened then

						get_sub_window_pos()
					    imgui.set_next_window_pos(sub_window.pos, sub_window.condition, sub_window.pivot)
	    				imgui.set_next_window_size(sub_window.size, sub_window.condition)

						if imgui.begin_window("Valid Combinations", sub_window.is_opened, sub_window.flags) then
							create_table(table_2)
							imgui.new_line()
							create_table(table_3)
							imgui.new_line()
							imgui.text("Invalid maps: Infernal Springs, Arena, Forlorn Arena")
							imgui.text('Quest cant have duplicate monsters.')
							imgui.text('Quest cant have two Apex monsters.')
							imgui.text('Apex monsters cant be intruders.')
							imgui.end_window()
						else
							if sub_window.is_opened then imgui.end_window() end
							sub_window.is_opened = false
						end
					end
				end
			end
			game_state.previous = game_state.current
        	imgui.end_window()
        else
        	if main_window.is_opened then imgui.end_window() end
        	main_window.is_opened = false
        	sub_window.is_opened = false
        end
    end
end)


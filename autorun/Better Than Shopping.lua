local DataShortcut = sdk.find_type_definition("snow.data.DataShortcut")
local getName = DataShortcut:get_method("getName(snow.data.ContentsIdSystem.ItemId)")

local dataCache = {}
for i = 0x04100000, 0x04100F00 do
    if not string.find(getName:call(nil, i), "<COLOR FF0000>#Rejected#</COLOR>") then
        dataCache[i] = getName:call(nil, i)
    end
end

local filteredList = {}
local filteredIndex = {}
local prevSearch = ""
local debug = ""
re.on_draw_ui(
    function()
        if imgui.tree_node("Better Than Shopping") then
            _, search = imgui.input_text("Search", search)
            if search ~= "" and search ~= prevSearch then
                prevSearch = search
                filteredList = {}
                for i,v in pairs(dataCache) do
                    if string.find(string.lower(v), string.lower(search)) then
                        filteredList[i] = v
                        id = i
                    end
                end
            end
            _, id = imgui.combo("Item", id, filteredList)
            _, num = imgui.drag_int("Amount", num, 1, 1, 100)
            imgui.text(id)
            --_, id = imgui.drag_int("ID", id, 1, 67108864, 68160314, getName:call(nil, id))
            if imgui.button("Add item") then
                local dataManager = sdk.get_managed_singleton("snow.data.DataManager")
                if not dataManager then debug = "No datamanager" return end
                local box = dataManager:get_field("_PlItemBox")
                if not box then debug = "No item box" return end
                local inventoryData = box:call("findInventoryData", id)
                if not inventoryData then
                    inventoryData = box:call("findEmptyInventory", id)
                end
                box:call("tryAddGameItem(snow.data.ItemInventoryData, snow.data.ContentsIdSystem.ItemId, System.Int32)", inventoryData, id, num)
            end
            imgui.text(debug)
            imgui.tree_pop();
        end
    end
)
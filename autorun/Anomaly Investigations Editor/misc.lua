local misc = {}

function misc.table_deep_copy(original, copies)
    copies = copies or {};
    local original_type = type(original);
    local copy;
    if original_type == "table" then
        if copies[original] then
            copy = copies[original];
        else
            copy = {};
            copies[original] = copy;
            for original_key, original_value in next, original, nil do
                copy[misc.table_deep_copy(original_key, copies)] = misc.table_deep_copy(original_value
                    ,
                    copies);
            end
            setmetatable(copy,
                misc.table_deep_copy(getmetatable(original)
                    , copies));
        end
    else -- number, string, boolean, etc
        copy = original;
    end
    return copy;
end

function misc.index_of(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function misc.table_contains(list, x)
    for _, v in pairs(list) do
        if v == x then
            return true
        end
    end
    return false
end

return misc

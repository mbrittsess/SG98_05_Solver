--Implements various random-selection and random-number generation algorithms.
local random = math.random
local remove, unpack = table.remove, table.unpack

local export = {}

function export.uniform_random_choice( list )
    return list[ random( #list ) ]
end

--TODO: Needs much more efficient implementation
function export.mutation_index_selection ( np, own_i, n, best_i )
    local set = {}
    local ret = {}
    
    best_i = best_i or -1 -- -1 will never come up
    for i = 1, np do
        if (i ~= own_i) and (i ~= best_i) then
            set[ #set+1 ] = i
        end
    end
    for i = 1, n do
        local pick_i = random( #set )
        ret[ #ret+1 ] = set[ pick_i ]
        remove( set, pick_i )
    end
    return unpack( ret )
end

return export
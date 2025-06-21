local variables = require "neveix_piston_mod:variables"
local moving_block_speed = variables.moving_block_speed

local block_push_limit = variables.block_push_limit

-- Вычисляет сколько блоков впереди поршня будет сдвинуты
local function calc_max_go(atx, aty, atz, sx, sy, sz)
    local max_go
    local leave = false
    for i = 0, block_push_limit + 1 do
        max_go = i
        if block.is_replaceable_at(atx, aty, atz) then leave = true end
        atx, aty, atz = atx+sx, aty+sy, atz+sz
        if leave then break end
    end
    return max_go, atx, aty, atz
end

local function move_entities(atx, aty, atz, sx, sy, sz)
    local ents = entities.get_all_in_box({atx, aty, atz}, {1, 1, 1})
    for i = 1, #ents do
        local entity = entities.get(ents[i])
        local tsf = entity.transform
        local oldpos = tsf:get_pos()
        tsf:set_pos({oldpos[1]+sx, oldpos[2]+sy, oldpos[3]+sz})
    end
end

local function move_block(atx, aty, atz, sx, sy, sz)
    local prevx, prevy, prevz = atx-sx, aty-sy, atz-sz
    local prev_block_id = block.get(prevx, prevy, prevz)
    local prev_block_name = block.name(prev_block_id)
    local prev_block_states = block.get_states(prevx, prevy, prevz)
    block.set(prevx, prevy, prevz, 0, 0)

    local entity = entities.spawn(
        "neveix_piston_mod:moving_block", 
        {prevx+0.5, prevy+0.5, prevz+0.5}, 
        {neveix_piston_mod__moving_block={
            block=prev_block_name,
            states=prev_block_states,
            end_at={atx, aty, atz}
        }}
    )
    local body = entity.rigidbody
    body:set_vel({
            sx*moving_block_speed, 
            sy*moving_block_speed, 
            sz*moving_block_speed
        })
end

function on_interact(x, y, z)
    local sx, sy, sz = block.get_Y(x, y, z)
    local atx, aty, atz = x, y, z

    local max_go, atx, aty, atz = calc_max_go(atx, aty, atz, sx, sy, sz)
    if max_go == block_push_limit + 1 then return true end

    for i = max_go, 2, -1 do
        atx, aty, atz = atx-sx, aty-sy, atz-sz
        move_block(atx, aty, atz, sx, sy, sz)
    end

    local ext_piston_id = block.index('neveix_piston_mod:extended_piston');
    local block_states = block.get_states(x,y,z)
    block.place(x, y, z, ext_piston_id, block_states)
    return true
end

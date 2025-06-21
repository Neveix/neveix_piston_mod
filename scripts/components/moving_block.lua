local variables = require "neveix_piston_mod:variables"
local moving_block_speed = variables.moving_block_speed

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

local blockid = ARGS.block
local blockstates = ARGS.states or 0
local end_at = ARGS.end_at or {0,0,0}
local lifetime = 0
if SAVED_DATA.block then
    blockid = SAVED_DATA.block
    blockstates = SAVED_DATA.states or 0
    end_at = SAVED_DATA.end_at or {0,0,0}
    lifetime = SAVED_DATA.lifetime or 0
else
    SAVED_DATA.block = blockid
    SAVED_DATA.states = blockstates
    SAVED_DATA.end_at = end_at
    SAVED_DATA.lifetime = lifetime
end

do
    local id = block.index(blockid)
    local rotation = block.decompose_state(blockstates)[1]
    local textures = block.get_textures(id)
    for i,t in ipairs(textures) do
        rig:set_texture("$"..tostring(i-1), "blocks:"..textures[i])
    end
    local axisX = {block.get_X(id, rotation)}
    local axisY = {block.get_Y(id, rotation)}
    local axisZ = {block.get_Z(id, rotation)}
    local matrix = {
        axisX[1], axisX[2], axisX[3], 0,
        axisY[1], axisY[2], axisY[3], 0,
        axisZ[1], axisZ[2], axisZ[3], 0,
        0, 0, 0, 1
    }
    rig:set_matrix(0, matrix)

    local body = entity.rigidbody
    body:set_gravity_scale({0, 0, 0})
    body:set_body_type("kinematic")
end

local lifetime_max = 20 / moving_block_speed

function on_update(tps)
    lifetime = lifetime + 1
    if lifetime > lifetime_max then
        local x, y, z = end_at[1], end_at[2], end_at[3]

        block.place(x, y, z, block.index(blockid), blockstates)
        entity:despawn()
    end
    
end

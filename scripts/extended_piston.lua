function on_interact(x, y, z)
    x,y,z = block.seek_origin(x,y,z)
    local piston_id = block.index('neveix_piston_mod:piston');
    local block_states = block.get_states(x,y,z)
    block.place(x, y, z, piston_id, block_states)
    return true
end

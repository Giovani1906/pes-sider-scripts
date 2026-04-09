local function teams_selected(ctx, home)
	--fix broken Hole Player Second Striker in PES 2021 1.01.00 (0x1301 --> 0x1303)
	memory.write(0x142613D3C, memory.pack("u32", 787))    
end

function init(ctx)
	ctx.register("set_teams", teams_selected)
end

return {init = init}
function boot_kit_swap(ctx, filename)
	if ctx.home_team or ctx.away_team then
		local boot_id = tonumber((string.match(filename, "Asset\\model\\character\\boots\\k(%d+)\\#Win\\boots.fpk")))
		if boot_id then
			if 100 > boot_id or boot_id > 9900 then
				return
			end

			local home_range = ((ctx.home_team - 700) * 25) + 76
			if boot_id >= home_range and boot_id <= (home_range + 24) then
				return string.gsub(filename, "\\#Win\\", string.format("p%s\\#Win\\", (ctx.kits.get_current_kit_id(0) + 1)))
			end

			local away_range = ((ctx.away_team - 700) * 25) + 76
			if boot_id >= away_range and boot_id <= (away_range + 24) then
				return string.gsub(filename, "\\#Win\\", string.format("p%s\\#Win\\", (ctx.kits.get_current_kit_id(1) + 1)))
			end
		end
	end
end

function init(ctx)
	ctx.register('livecpk_rewrite', boot_kit_swap)
end

return {init = init}

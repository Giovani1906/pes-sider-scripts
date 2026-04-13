function boot_kit_swap(ctx, filename)
	if ctx.home_team or ctx.away_team then
		local boot_id = tonumber((string.match(filename, "Asset\\model\\character\\boots\\k(%d+)\\#Win\\boots.fpk")))
		if boot_id then
			if boot_id > 100 and boot_id < 9900 then
				local home_kit = ctx.kits.get_current_kit_id(0) + 1
				if home_kit ~= 1 then
					local home_boot = ((ctx.home_team - 700) * 25) + 76
					if boot_id >= home_boot and boot_id <= (home_boot + 24) then
						return string.gsub(filename, "\\#Win\\", string.format("p%s\\#Win\\", home_kit))
					end
				end

				local away_kit = ctx.kits.get_current_kit_id(1) + 1
				if away_kit ~= 1 then
					local away_boot = ((ctx.away_team - 700) * 25) + 76
					if boot_id >= away_boot and boot_id <= (away_boot + 24) then
						return string.gsub(filename, "\\#Win\\", string.format("p%s\\#Win\\", away_kit))
					end
				end
			end
		end
	end
end

function init(ctx)
	ctx.register('livecpk_rewrite', boot_kit_swap)
end

return {init = init}

local function kit_file_rewriter(ctx, filename, team_id, is_team_away)
	kit_main = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit.ftex", team_id))
	kit_back = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_back.ftex", team_id))
	kit_chest = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_chest.ftex", team_id))
	kit_leg = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_leg.ftex", team_id))
	kit_name = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_name.ftex", team_id))
	kit_specular = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_srm.ftex", team_id))
	
	if kit_main or kit_back or kit_chest or kit_leg or kit_name or kit_specular then
		kit_config = ctx.kits.get(team_id, ctx.kits.get_current_kit_id(is_team_away))
	end
	
	if kit_main then
		return string.gsub(filename, kit_main, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_config.KitFile))
	elseif kit_back and kit_config.BackNumbersFile then
		return string.gsub(filename, kit_back, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_config.BackNumbersFile))
	elseif kit_chest and kit_config.ChestNumbersFile then
		return string.gsub(filename, kit_chest, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_config.ChestNumbersFile))
	elseif kit_leg and kit_config.LegNumbersFile then
		return string.gsub(filename, kit_leg, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_config.LegNumbersFile))
	elseif kit_name and kit_config.NameFontFile then
		return string.gsub(filename, kit_name, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_config.NameFontFile))
	elseif kit_specular then
		return string.gsub(filename, kit_specular, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s_srm.ftex", kit_config.KitFile))
	end
end

local function kit_gk_file_rewriter(ctx, filename, team_id)
	kit_gk_main = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_gk.ftex", team_id))
	kit_gk_back = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_gk_back.ftex", team_id))
	kit_gk_chest = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_gk_chest.ftex", team_id))
	kit_gk_leg = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_gk_leg.ftex", team_id))
	kit_gk_name = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_gk_name.ftex", team_id))
	kit_gk_specular = string.match(filename, string.format("Asset\\model\\character\\common\\%d\\sourceimages\\#windx11\\dummy_kit_gk_srm.ftex", team_id))
	
	if kit_gk_main or kit_gk_back or kit_gk_chest or kit_gk_leg or kit_gk_name or kit_gk_specular then
		kit_gk_config = ctx.kits.get_gk(team_id)
	end
	
	if kit_gk_main then
		return string.gsub(filename, kit_gk_main, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_gk_config.KitFile))
	elseif kit_gk_back and kit_gk_config.BackNumbersFile then
		return string.gsub(filename, kit_gk_back, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_gk_config.BackNumbersFile))
	elseif kit_gk_chest and kit_gk_config.ChestNumbersFile then
		return string.gsub(filename, kit_gk_chest, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_gk_config.ChestNumbersFile))
	elseif kit_gk_leg and kit_gk_config.LegNumbersFile then
		return string.gsub(filename, kit_gk_leg, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_gk_config.LegNumbersFile))
	elseif kit_gk_name and kit_gk_config.NameFontFile then
		return string.gsub(filename, kit_gk_name, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s.ftex", kit_gk_config.NameFontFile))
	elseif kit_gk_specular then
		return string.gsub(filename, kit_gk_specular, string.format("Asset\\model\\character\\uniform\\texture\\#windx11\\%s_srm.ftex", kit_gk_config.KitFile))
	end
end

function fbm_kit_rewrite(ctx, filename)
	if ctx.home_team or ctx.away_team then
		local team_id = tonumber((string.match(filename, "Asset\\model\\character\\common\\(%d+)\\sourceimages\\#windx11\\dummy_kit(.-).ftex")))
		local is_gk = string.match(filename, "Asset\\model\\character\\common\\(%d+)\\sourceimages\\#windx11\\dummy_kit_gk(.-).ftex")
		if team_id == ctx.home_team then
			if is_gk then
				return kit_gk_file_rewriter(ctx, filename, team_id)
			else
				return kit_file_rewriter(ctx, filename, team_id, 0)
			end
		elseif team_id == ctx.away_team then
			if is_gk then
				return kit_gk_file_rewriter(ctx, filename, team_id)
			else
				return kit_file_rewriter(ctx, filename, team_id, 1)
			end
		end
	end
end

function init(ctx)
	ctx.register('livecpk_rewrite', fbm_kit_rewrite)
end

return {init = init}

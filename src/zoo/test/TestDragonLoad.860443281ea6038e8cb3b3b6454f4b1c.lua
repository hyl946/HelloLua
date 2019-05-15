
local anims = {






	
	-- 'share_10_animation',
	-- 'share_20_1_animation',
	-- 'share_20_2_animation',
	-- 'share_20_3_animation',
	'share_30_animation',
	-- 'share_40_animation',
	-- 'share_50_animation',
	-- 'share_70_animation',
	-- 'share_90_animation',
	-- 'share_120_animation',
	-- 'share_150_animation',
	-- 'share_160_animation',
	-- 'share_170_animation',
	-- 'share_200_animation',
	-- 'share_220_animation',
	-- 'share_230_animation',
	-- 'share_240_animation',
	-- 'share_280_animation',
	-- 'share_290_animation',
	-- 'skip_level_animation',
	-- 'BuffInitFlyInAnimation001',
	-- 'BuffInitFlyInAnimation002',
	-- 'friend_ranking_panel_animation',
	-- 'RankRaceDan',
	-- 'update_version_47',

}


local function loadAll( ... )
  local t1 = _utilsLib.mstime()
  print('loaddragon =======================')

	for _, file in ipairs(anims) do
		local t3 = _utilsLib.mstime()

		local _add_cost = 0
  		for i = 1, 10 do
			local cost = FrameLoader:loadArmature( 'skeleton/' .. file , file, file )
			FrameLoader:unloadArmature( 'skeleton/' .. file, true )
			_add_cost = _add_cost + cost
  		end

		local _new_cost = 0
  		for i = 1, 100 do
			local t5 = _utilsLib.mstime()
			ArmatureNode:create('cdsadfsa896c9dhs7a5f76ds45a5764fd76s5af67dsafds/gu')		
  			local t6 = _utilsLib.mstime()
			_new_cost = _new_cost + t6 - t5
		end

		local t4 = _utilsLib.mstime()
		print('loaddragon:#' .. tostring(_) .. '\tl=' .. tostring(_add_cost) .. '\tc=' .. tostring(_new_cost))

	end

  local t2 = _utilsLib.mstime()
  print('loaddragon total cost = ' .. tostring(t2-t1))
end

local function unloadAll( ... )
	for _, file in ipairs(anims) do
		for i = 1, times_per_anim do
			FrameLoader:unloadArmature( 'skeleton/' .. file, true )
		end
	end
end

return {
	loadAll = loadAll,
	unloadAll = unloadAll,
}

-- local default = SCENE.kAll

local SCENE = {
	kHOME = 'HomeScene',
	kGAMEPLAY = 'GamePlaySceneUI',
}

local blist = {
--		'home_icon',
--		'flower_effects',
--		'quick_select_level',
--		'homeScene',
--		'head_images',
--		'weekly_main_ui',
		-- '/world_scene_animation/',
		-- 'quick_select_level',
		}


local __fntReplaced = {
	'fnt/tutorial_white'
}

local __TextureSceneConfig = {	
	'trunk',
	'/activity/',
	'/RankRace/MainPanel',
	'/RankRace/mainPanelBg',
	'weeklyPanelBg',
	'trunkRootBackCloud',
	'solar',
	'lunar',
	'wdj_remove',
	'trunkRoot',
	'home',
	'/world_scene_animation/',
	'constellations',
	'trunk',
	'branch_mask',
	'branch',
	'/region_cloud_animation/',
	'lockedCloud',
	'quick_select_level',
	'home_icon',
	'home_scene_icon',
	'flower_effects',
	'homeScene',
	'/HiddenBranchAnim/',
	'xf_homescene_icon',
	'rank_race_lock',
	'/area_task_flower/',
	'achi_icons',
	'/spring/firework',
}

_G.TextureSceneConfig = {}

function TextureSceneConfig:isReplaced( res )
	return table.find(_G.homescene_last_freetexture_list or {}, function ( item )
		return string.find(res, item) ~= nil
	end) ~= nil
end

function TextureSceneConfig:setNotReplaced( res )
	_G.homescene_last_freetexture_list = table.filter(_G.homescene_last_freetexture_list or {}, function ( item )
		return string.find(res, item) == nil
	end) or {}
end

function TextureSceneConfig:rollbackByKey( key )
	if _textureLib and _textureLib.rollbackByKeys then
		_textureLib.rollbackByKeys({CCFileUtils:sharedFileUtils():fullPathForFilename(key)})
	end
end

function TextureSceneConfig:getResGrpNeedBeReplaced( targetScene )

	if not targetScene then return {} end
	local sceneName = targetScene.name or 'no name'

	-- if not table.exist(SCENE, sceneName) then
	-- 	return {}
	-- end

	local blist = {}
	blist = table.union(blist, __TextureSceneConfig)
	blist = table.union(blist, __fntReplaced)

	-- for resName, scenes in pairs(__TextureSceneConfig) do
	-- 	local useful = false
	-- 	if type(scenes) == 'table' then
	-- 		useful = useful or table.includes(scenes, sceneName)
	-- 		useful = useful or table.includes(scenes, SCENE.kAll)
	-- 	end

	-- 	if type(scenes) == 'string' then
	-- 		useful = useful or (scenes == sceneName)
	-- 		useful = useful or (scenes == SCENE.kAll)
	-- 	end

	-- 	-- printx(61, resName, sceneName, useful)

	-- 	if not useful then
	-- 		table.insert(blist, resName)
	-- 	end
	-- end



	if sceneName == SCENE.kGAMEPLAY then
		require "zoo.gamePlay.GamePlaySceneSkinManager"

		if targetScene.levelType then
			local config = GamePlaySceneSkinManager:getConfig(targetScene.levelType)
			if config.gameBG and config.gameBG ~= 'game_bg.png' then
				table.insert(blist, 'materials/game_bg')
			end

			if GameLevelType.kMainLevel == targetScene.levelType or GameLevelType.kHiddenLevel == targetScene.levelType then
				table.insert(blist, 'game_guide_panels_act')
			end


			if GameLevelType.kMoleWeekly ~= targetScene.levelType then
				table.insert(blist, 'mole_weeklyRace_seed')
				table.insert(blist, 'weekly_others')
				table.insert(blist, '/week_bossSkill/')
			end

			if (GameLevelType.kMainLevel ~= targetScene.levelType and GameLevelType.kHiddenLevel ~= targetScene.levelType) then
				table.insert(blist, '/tempFunctionRes/')
				-- table.insert(blist, 'head_frames')
				-- table.insert(blist, 'head_images')
				-- table.insert(blist, 'myqcloud.com/')
				-- table.insert(blist, '.cn/')
			end
		end

	end

	return blist
end
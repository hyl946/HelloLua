---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-24 17:05:03
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-24 17:11:18
---------------------------------------------------------------------------------------

--EditorModeGameResource.lua

local kFilePathMapping = {
	["skeleton/olympic_animal_animation"] = "editorRes/skeleton/olympic_animal_animation",
	["skeleton/olympic_banana"] = "editorRes/skeleton/olympic_banana",
	["skeleton/olympic_medals"] = "editorRes/skeleton/olympic_medals",

	["flash/olympic/olympic_ingame.json"] = "editorRes/flash/olympic/olympic_ingame.json",
	["flash/olympic/olympic_ingame.png"] = "editorRes/flash/olympic/olympic_ingame.png",
	["flash/olympic/olympic_ingame_animations.plist"] = "editorRes/flash/olympic/olympic_ingame_animations.plist",
	["flash/olympic/olympic_ingame_animations.png"] = "editorRes/flash/olympic/olympic_ingame_animations.png",
	["flash/olympic/game_bg_olympic.plist"] = "editorRes/flash/olympic/game_bg_olympic.plist",
	["flash/olympic/game_bg_olympic.png"] = "editorRes/flash/olympic/game_bg_olympic.png",
	["flash/olympic/olympic_resource.plist"] = "editorRes/flash/olympic/olympic_resource.plist",
	["flash/olympic/olympic_resource.png"] = "editorRes/flash/olympic/olympic_resource.png",
	
	-- ["flash/autumn2018/mid_autumn_res.plist"] = "editorRes/flash/autumn2018/mid_autumn_res.plist",
	-- ["flash/autumn2018/mid_autumn_res.png"] = "editorRes/flash/autumn2018/mid_autumn_res.png",
	-- ["flash/autumn2018/mid_autumn_bg.plist"] = "editorRes/flash/autumn2018/mid_autumn_bg.plist",
	-- ["flash/autumn2018/mid_autumn_bg.png"] = "editorRes/flash/autumn2018/mid_autumn_bg.png",


	["flash/spring2017/chicken.png"] = "editorRes/flash/spring2017/chicken.png",
	["flash/spring2017/chicken.plist"] = "editorRes/flash/spring2017/chicken.plist",
	["flash/spring2017/tang_chicken.png"] = "editorRes/flash/spring2017/tang_chicken.png",
	["flash/spring2017/tang_chicken.plist"] = "editorRes/flash/spring2017/tang_chicken.plist",
	["flash/spring2017/spring_explore_effect.png"] = "editorRes/flash/spring2017/spring_explore_effect.png",
	["flash/spring2017/spring_explore_effect.plist"] = "editorRes/flash/spring2017/spring_explore_effect.plist",
	["flash/spring2017/board_view_effects.png"] = "editorRes/flash/spring2017/board_view_effects.png",
	["flash/spring2017/board_view_effects.plist"] = "editorRes/flash/spring2017/board_view_effects.plist",
	

	["skeleton/bear_cry"] = "editorRes/skeleton/olympic/bear_cry",
	["skeleton/chicken_cry"] = "editorRes/skeleton/olympic/chicken_cry",
	["skeleton/fox_cry"] = "editorRes/skeleton/olympic/fox_cry",
	["skeleton/frog_cry"] = "editorRes/skeleton/olympic/frog_cry",
	["skeleton/hippo_cry"] = "editorRes/skeleton/olympic/hippo_cry",
	["skeleton/owl_cry"] = "editorRes/skeleton/olympic/owl_cry",

	["skeleton/SZN_Animation"] = "editorRes/skeleton/SZN_Animation",
}

for k, v in pairs(kFilePathMapping) do
	ResourceManager:sharedInstance():addFileMapping(k, v)
end
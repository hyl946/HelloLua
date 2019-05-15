GamePlaySceneSkinManager = {}

GamePlaySceneSkinConfig = {
	[GameLevelType.kMoleWeekly] = {
		gameBG = "MoleWeekly_bg.png",
        gameupBG = "MoleWeekly_bg_up.png",
        gameDownBG = "MoleWeekly_bg_down.png",
		topLeftLeaves = "newWeekLeftLeaves",
		topRightLeaves = "newWeekRightLeves",
		ladybugAnimation = "ladybug",
		propsListView = "props_animations_weekly",
		moveOrTimeCounter = "moveOrTimeCounter",
		levelTargets = "ingame_level_targets",
        weeklyItemContainer = "weekly_item_container_winter",
        levelFnt = "fnt/guanqiatitle.fnt",
	},
	[GameLevelType.kMayDay] = {
		gameBG = "game_bg.png",
		topLeftLeaves = "leftLeaves",
		topRightLeaves = "rightLeaves",
		ladybugAnimation = "ladybug",
		propsListView = "props_animations",
		moveOrTimeCounter = "moveOrTimeCounter",
		levelTargets = "ingame_level_targets",
	},
	[GameLevelType.kSummerWeekly] = {
		gameBG = "game_bg.png",
		topLeftLeaves = "leftLeaves_weekly",
		topRightLeaves = "rightLeaves",
		ladybugAnimation = "ladybug_weekly",
		propsListView = "props_animations_weekly",
		moveOrTimeCounter = "moveOrTimeCounter_weekly",
		levelTargets = "ingame_level_targets_weekly",
		weeklyItemContainer = "weekly_item_container_winter",
	},
	[GameLevelType.kOlympicEndless] = {
		gameBG = "game_bg.png",
		topLeftLeaves = "leftLeaves",
		topRightLeaves = "rightLeaves",
		ladybugAnimation = "ladybug_weekly",
		propsListView = "props_animations",
		moveOrTimeCounter = "moveOrTimeCounter",
		levelTargets = "ingame_level_targets",
	},
	[GameLevelType.kMidAutumn2018] = {
		gameBG = "game_bg.png",
		topLeftLeaves = "leftLeaves_nationday2017",
		topRightLeaves = "rightLeaves",
		ladybugAnimation = "ladybug_weekly",
		propsListView = "dark_theme/props_animations",
		moveOrTimeCounter = "moveOrTimeCounter",
		levelTargets = "ingame_level_targets",
	},
	[GameLevelType.kSpring2017] = {
		gameBG = "nationday2017_game_bg.png",
		topLeftLeaves = "leftLeaves",
		topRightLeaves = "rightLeaves",
		ladybugAnimation = "ladybug",
		propsListView = "props_animations",
		moveOrTimeCounter = "moveOrTimeCounter",
		levelTargets = "ingame_level_targets",
	},
	[GameLevelType.kSpring2018] = {
		gameBG = "game_bg.png",
		topLeftLeaves = "spring2018.level/leftLeaves",
		topRightLeaves = "spring2018.level/rightLeaves",
		ladybugAnimation = "spring2018.level/ladybug",
		propsListView = "sp2018.ladybug/props_animations",
		moveOrTimeCounter = "moveOrTimeCounter",
		levelTargets = "ingame_level_targets",
	},
	[GameLevelType.kSummerFish] = {
		gameBG = "game_bg.png",
	    topLeftLeaves = "leftLeaves",
	    topRightLeaves = "rightLeaves",
	    ladybugAnimation = "lady_bug_summerfish",
	    propsListView = "props_animations",
	    moveOrTimeCounter = "moveOrTimeCounter",
	    levelTargets = "ingame_level_targets",
	},
--    [GameLevelType.kJamSperadLevel] = {
--		gameBG = "game_bg.png",
--	    topLeftLeaves = "leftLeaves",
--	    topRightLeaves = "rightLeaves",
--	    ladybugAnimation = "ladybug",
--	    propsListView = "props_animations",
--	    moveOrTimeCounter = "moveOrTimeCounter",
--	    levelTargets = "ingame_level_targets",
--	}
}

local defaultConfig = {
	gameBG = "game_bg.png",
	topLeftLeaves = "leftLeaves",
	topRightLeaves = "rightLeaves",
	ladybugAnimation = "ladybug",
	propsListView = "props_animations",
	moveOrTimeCounter = "moveOrTimeCounter",
	levelTargets = "ingame_level_targets",
	levelFnt = "fnt/guanqiatitle.fnt",
}

local defaultConfig_spring_day = {
	gameBG = "game_bg.png",
	topLeftLeaves = "dark_theme/leftLeaves",
	topRightLeaves = "dark_theme/rightLeaves",
	ladybugAnimation = "dark_theme/ladybug",
	propsListView = "dark_theme/props_animations",
	moveOrTimeCounter = "moveOrTimeCounterSnow",
	levelTargets = "ingame_level_targets",
	levelFnt = "fnt/spring/chunjiechuangguan.fnt",
	levelFntScale = 1,
}

local defaultConfig_spring_night = {
	gameBG = "game_bg_night.png",
	topLeftLeaves = "dark_theme/leftLeaves",
	topRightLeaves = "dark_theme/rightLeaves",
	ladybugAnimation = "dark_theme/ladybug",
	propsListView = "dark_theme/props_animations",
	moveOrTimeCounter = "moveOrTimeCounterSnow",
	levelTargets = "ingame_level_targets",
	levelFnt = "fnt/spring/chunjiechuangguan.fnt",
	levelFntScale = 1,
}

local anniversaryTwoYearsConfig = {
	gameBG = "game_bg_AnniversaryTwoYears.png",
	topLeftLeaves = "leftLeaves",
	topRightLeaves = "rightLeaves",
	ladybugAnimation = "ladybug",
	propsListView = "props_animations",
	moveOrTimeCounter = "moveOrTimeCounter",
	levelTargets = "ingame_level_targets",
}
--[[
GameLevelType = {
	kQixi 			= 1,
	kMainLevel 		= 2,
	kHiddenLevel 	= 3,
	kDigWeekly		= 4,
	kMayDay			= 5,
	kRabbitWeekly	= 6,
	kTaskForRecall  = 8,
	kTaskForUnlockArea = 9,
	kSummerWeekly 	= 10,
}
]]

local function copyTab(st)  
    local tab = {}  
    for k, v in pairs(st or {}) do  
        if type(v) ~= "table" then  
            tab[k] = v  
        else  
            tab[k] = copyTab(v)  
        end  
    end  
    return tab  
end  

function GamePlaySceneSkinManager:initCurrLevel(levelType)
	self.levelType = levelType
end

function GamePlaySceneSkinManager:getCurrLevelType()
	return self.levelType
end

function GamePlaySceneSkinManager:isHalloweenLevel()
	if self.levelType == GameLevelType.kMayDay then
		return true
	end
	return false
end

function GamePlaySceneSkinManager:getConfig(levelType)
	local config = GamePlaySceneSkinConfig[levelType]

	if not config then
		if WorldSceneShowManager:hasInited() and WorldSceneShowManager:getInstance():isInAcitivtyTime() then 
			local showType = WorldSceneShowManager:getInstance():getShowType()

			if showType == 1 then 
				local plistPath = "flash/scenes/flowers/spring/game_bg_day.plist"
				CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plistPath)
				CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
				CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistPath)
				CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
				config = defaultConfig_spring_day
			else
				local plistPath = "flash/scenes/flowers/spring/game_bg_night.plist"
				CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plistPath)
				CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
				CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistPath)
				CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
				config = defaultConfig_spring_night
			end
		else
			config = defaultConfig
			--config = anniversaryTwoYearsConfig

			if UserManager:getInstance().user:getTopLevelId() < 20 or not MaintenanceManager:getInstance():isEnabled("Background") then
				config.gameBG = "game_bg.png"
			end
		end
	end

	local tab = copyTab(config)

	return tab
end
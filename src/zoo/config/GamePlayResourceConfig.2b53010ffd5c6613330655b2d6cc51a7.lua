---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-11-03 18:44:27
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-03-07 14:32:50
---------------------------------------------------------------------------------------
kTileCharacterAnimation = {
	kNormal = 1, kUp = 2, kDown = 3, kLeft = 4, kRight = 5, 
	kLineColumn = 6, kLineRow = 7, kWrap = 8,
	kSelect = 9, kDestroy = 10
}

local Style1 = {
	plistRes = {
		"flash/bear.plist", 	
		"flash/fox.plist", 		
		"flash/horse.plist", 	
		"flash/frog.plist", 	
		"flash/cat.plist", 		
		"flash/chicken.plist", 	
		"flash/bird.plist", 	
		"flash/destroy_effect.plist",
	},
	staticItemPattern="StaticItem%02d.png",
	spriteSheet = {
		cat 	= "flash/cat.png",
		fox 	= "flash/fox.png",
		horse 	= "flash/horse.png",
		chicken = "flash/chicken.png",
		bear 	= "flash/bear.png",
		frog 	= "flash/frog.png",	
	},
	characterAnimationConfig = {
		[kTileCharacterAnimation.kSelect] = {
			cat 	= {pattern = "cat_click_%d.png", frame = 30, adjustPos = {x = 0.5, y = -3.5}},
			fox 	= {pattern = "fox_click_%d.png", frame = 30, adjustPos = {x = 0.5, y = -1.5}},
			horse 	= {pattern = "horse_click_%d.png", frame = 30, adjustPos = {x = 1, y = -0.8}},
			chicken = {pattern = "chicken_click_%d.png", frame = 30, adjustPos = {x = 0.8, y = -0.7}},
			bear 	= {pattern = "bear_click_%d.png", frame = 30, adjustPos = {x = 1, y = 0}},
			frog 	= {pattern = "frog_click_%d.png", frame = 30, adjustPos = {x = 0, y = -0.5}},
		},
		[kTileCharacterAnimation.kLineRow] = {
			cat 	= {pattern = "cat_line_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			fox 	= {pattern = "fox_line_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			horse 	= {pattern = "horse_line_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			chicken = {pattern = "chicken_line_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			bear 	= {pattern = "bear_line_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			frog 	= {pattern = "frog_line_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
		},
		[kTileCharacterAnimation.kLineColumn] = {
			cat 	= {pattern = "cat_column_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			fox 	= {pattern = "fox_column_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			horse 	= {pattern = "horse_column_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			chicken = {pattern = "chicken_column_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			bear 	= {pattern = "bear_column_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
			frog 	= {pattern = "frog_column_%d.png", frame = 29, adjustPos = {x = 0, y = 0}},
		},
		[kTileCharacterAnimation.kWrap] = {
			cat 	= {pattern = "cat_wrap_%d.png", frame = 49, adjustPos = {x = 0, y = 0}},
			fox 	= {pattern = "fox_wrap_%d.png", frame = 49, adjustPos = {x = 0, y = 0}},
			horse 	= {pattern = "horse_wrap_%d.png", frame = 49, adjustPos = {x = 0, y = 0}},
			chicken = {pattern = "chicken_wrap_%d.png", frame = 49, adjustPos = {x = 0, y = 0}},
			bear 	= {pattern = "bear_wrap_%d.png", frame = 49, adjustPos = {x = 0, y = 0}},
			frog 	= {pattern = "frog_wrap_%d.png", frame = 49, adjustPos = {x = 0, y = 0}},
		},
	},
}

local Style2 = {
	plistRes = {
		"flash/bear.plist", 
		"flash/fox.plist", 
		"flash/horse.plist", 
		"flash/frog.plist", 
		"flash/cat.plist", 
		"flash/chicken.plist", 
		"flash/bird.plist", 
		"flash/board_effects.plist",
		"flash/spring2017/chicken.plist",
	},
	spriteSheet = {
		cat 	= "flash/cat.png",
		fox 	= "flash/fox.png",
		horse 	= "flash/horse.png",
		chicken = "flash/chicken.png",
		bear 	= "flash/bear.png",
		frog 	= "flash/frog.png",	
		["spring2017/chicken"] = "flash/spring2017/chicken.png",
	},
	staticItemPattern="StaticItem%02d.png",
	-- staticItemHDPattern="StaticItem%02d_h.png",
	staticItemHDPattern="StaticItem%02d.png",
	characterAnimationConfig = {
		[kTileCharacterAnimation.kSelect] = {
			cat 	= {pattern = "cat_selected_%04d", frame = 35, adjustPos = {x = 0.3, y = -0.3}},
			fox 	= {pattern = "fox_selected_%04d", frame = 35, adjustPos = {x = 0.25, y = -0.8}},
			horse 	= {pattern = "horse_selected_%04d", frame = 35, adjustPos = {x = 0.3, y = -0.7}},
			chicken = {pattern = "chicken_selected_%04d", frame = 35, adjustPos = {x = -0.3, y = -2.5}},
			bear 	= {pattern = "bear_selected_%04d", frame = 35, adjustPos = {x = 1.1, y = -3.8}},
			frog 	= {pattern = "frog_selected_%04d", frame = 35, adjustPos = {x = 0.3, y = -0.2}},
			["spring2017/chicken"] = {pattern = "spring2017/chicken_click_%d.png", frame = 35, adjustPos = {x = 0.6, y = -0.5}},
		},
		[kTileCharacterAnimation.kLineRow] = {
			cat 	= {pattern = "cat_line_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			fox 	= {pattern = "fox_line_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			horse 	= {pattern = "horse_line_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			chicken = {pattern = "chicken_line_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			bear 	= {pattern = "bear_line_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			frog 	= {pattern = "frog_line_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			["spring2017/chicken"] = {pattern = "spring2017/chicken_line_%d.png", frame = 23, adjustPos = {x = 0, y = 0}},
		},
		[kTileCharacterAnimation.kLineColumn] = {
			cat 	= {pattern = "cat_column_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			fox 	= {pattern = "fox_column_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			horse 	= {pattern = "horse_column_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			chicken = {pattern = "chicken_column_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			bear 	= {pattern = "bear_column_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			frog 	= {pattern = "frog_column_%04d", frame = 23, adjustPos = {x = 0, y = 0}},
			["spring2017/chicken"] = {pattern = "spring2017/chicken_column_%d.png", frame = 23, adjustPos = {x = 0, y = 0}},
		},
		[kTileCharacterAnimation.kWrap] = {
			cat 	= {pattern = "cat_wrap_%04d", frame = 34, adjustPos = {x = 0, y = 0}},
			fox 	= {pattern = "fox_wrap_%04d", frame = 34, adjustPos = {x = 0, y = 0}},
			horse 	= {pattern = "horse_wrap_%04d", frame = 34, adjustPos = {x = 0, y = 0}},
			chicken = {pattern = "chicken_wrap_%04d", frame = 34, adjustPos = {x = 0, y = 0}},
			bear 	= {pattern = "bear_wrap_%04d", frame = 34, adjustPos = {x = 0, y = 0}},
			frog 	= {pattern = "frog_wrap_%04d", frame = 34, adjustPos = {x = 0, y = 0}},
			["spring2017/chicken"] = {pattern = "spring2017/chicken_wrap_%d.png", frame = 34, adjustPos = {x = 0, y = 0}},
		},
	},
}

_G.kStaticAnimalUseHDRes = false

GamePlayResourceConfig = {}

GamePlayResourceConfig.styleConfig = Style2

function GamePlayResourceConfig:getStaticItemSpriteName(colorIdx)
	return string.format(self.styleConfig.staticItemPattern, colorIdx)
end

function GamePlayResourceConfig:getStaticItemHDSpriteName(colorIdx)
	local pattern = self.styleConfig.staticItemHDPattern or self.styleConfig.staticItemPattern
	return string.format(pattern, colorIdx)
end

function GamePlayResourceConfig:getCharacterAnimationConfig(character, animationType)
	if animationType then 
		local config = self.styleConfig.characterAnimationConfig[animationType]
		if type(config) == "table" then
			return config[character]
		end
	end
	return nil
end

function GamePlayResourceConfig:getCharacterSpriteSheetName(character)
	return self.styleConfig.spriteSheet[character]
end
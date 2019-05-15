
local animalType = {["horse"] = 1, ["frog"] = 2, ["bear"] = 3, ["cat"] = 4, ["fox"] = 5, ["chicken"] = 6, ["color"] = 7}
local specialType = {["normal"] = 1, ["line"] = 7, ["column"] = 6, ["wrap"] = 8}

local npc_type = {
	['guide_dialogue_npc_full_body_looking_left'] = {name = 'tutorial_normal', scale = 1},
	['guide_dialogue_npc_full_body_looking_right'] = {name = 'tutorial_normal', scale = -1},
	['guide_dialogue_npc_full_body_looking_left_2'] = {name = 'movein_tutorial_4', scale = 1},
	['guide_dialogue_npc_full_body_looking_right_2'] = {name = 'movein_tutorial_4', scale = -1},
	['guide_dialogue_npc_half_body_pointing_left'] = {name = 'movein_tutorial_2', scale = 1},
	['guide_dialogue_npc_half_body_pointing_right_animated'] = {name = 'movein_tutorial_2', scale = -1},
	['guide_dialogue_npc_half_body_looking_left'] = {name = 'movein_tutorial', scale = 1},
	['guide_dialogue_npc_half_body_looking_right'] = {name = 'movein_tutorial', scale = -1},
	['guide_dialogue_panel_common_ui/guide_dialogue_npc_animation_2_left'] = {name = 'movein_tutorial_3', scale = 1},
	['guide_dialogue_panel_common_ui/guide_dialogue_npc_animation_2_right'] = {name = 'movein_tutorial_3', scale = -1},
}
local hasLoadTutorialAnimation = false

GameGuideUI = class()

function GameGuideUI:dialogue(playUI, action, skipText)
	local panel = BasePanel.new()

	local panelName = action.panelName
	local ui = ResourceManager:sharedInstance():buildGroup(panelName)

	local npc = nil
	local anim = {}


	local npc_replace_list = {}
	local animal_replace_list = {}
	local prop_gudie_animation_list = {}
	local prop_icon_list = {}
	local close_button_list = {}
	local buy_pre_prop_button_list = {}

	for k, v in pairs(ui.list) do
		--
		-- 文案是从flash文件中读取的
		-- 自动读取文案填上
		if v.name and string.starts(v.name,'guide_dialogue_text_dynamic') then -- 图子
			local key = panelName..'.'..v.name
			v:setRichText(localize(key, {n = '\n', s = ' '}), v.fntColor or '000000')
			if _G.__use_small_res then
				local vp = v:getPosition()
				v:setPosition( ccp( vp.x + 3 , vp.y - 7 ) )
			end
		elseif v.name and string.starts(v.name, 'guide_dialogue_text_static') then -- 系统字体
			local key = panelName..'.'..v.name
			v:setString(localize(key, {n = '\n', s = ' '}))
		elseif v.name and v.name == 'skiptext' then
			local key = panelName..'.'..v.name
			v:setString(localize(key, {n = '\n', s = ' '}))
		--
		-- 自动创建相应的小浣熊动画
		elseif v.name and string.starts(v.name, 'guide_dialogue_npc_full_body') and npc_type[v.name] then
			table.insert(npc_replace_list, v.name)
		elseif v.name and string.starts(v.name, 'guide_dialogue_npc_half_body_pointing_right_animated') and npc_type[v.name] then
			table.insert(npc_replace_list, v.name)
		elseif v.name and string.starts(v.name, 'guide_dialogue_panel_common_ui/guide_dialogue_npc_animation_') then
			table.insert(npc_replace_list, v.name)
		elseif v.name and string.starts(v.name, 'guide_dialogue_animal_') then
			table.insert(animal_replace_list, v.name)
		elseif v.name and string.starts(v.name, 'guide_dialogue_panel_common_ui/guide_dialogue_prop_gudie_animation_') then
			table.insert(prop_gudie_animation_list, v.name)
		elseif v.name and string.starts(v.name, 'guide_dialogue_panel_common_ui/guide_dialogue_prop_icon_sprite_') then
			table.insert(prop_icon_list, v.name)
		elseif v.name and string.starts(v.name, 'guide_dialogue_panel_common_ui/guide_dialogue_close_button') then
			table.insert(close_button_list, v.name)
		elseif v.name and string.starts(v.name, 'keepname_buyBtn') then
			table.insert(buy_pre_prop_button_list, v.name)
		end
	end


	for k, npcName in pairs(npc_replace_list) do
		local ph = ui:getChildByName(npcName)

		local parent = ph:getParent()
		local baseScale = ph:getScale()
		local zorder = ph:getZOrder()
		local pos = ccp(ph:getPositionX(), ph:getPositionY())
		--printx( 1 , "   ++++++++++++++++++++++++++   npc_type[npcName].name = " , npc_type[npcName].name)
		local npc = ArmatureNode:create(npc_type[npcName].name)
		npc:setScaleX(npc_type[npcName].scale * baseScale * 0.8)
		npc:setScaleY(baseScale * 0.8)
		ph:removeFromParentAndCleanup(true)
		parent:addChildAt(npc, zorder)
		npc:setPosition(pos)
		npc:playByIndex(0, 0)
		npc:setAnimationScale(1.25)
		table.insert(anim, npc)
	end

	for k, animalName in pairs(animal_replace_list) do
		local ph = ui:getChildByName(animalName)
		local parts = string.split(animalName, '_')
		if #parts > 0 then
			local zorder = ph:getZOrder()
			local width, height = ph:getGroupBounds().size.width, ph:getGroupBounds().size.height
			local pos = ccp(ph:getPositionX()+width/2, ph:getPositionY()-height/2)
			local parent = ph:getParent()
			local animal = parts[4]
			local special = parts[5]
			local sprite
			if animal == 'color' then
				sprite = TileBird:create()
  				sprite:play(1)
  				table.insert(anim, sprite)
  			elseif special ~= 'normal' then
  				sprite = TileCharacter:create(animal)
  				sprite:play(specialType[special])
  				table.insert(anim, sprite)
  			else
  				local key = GamePlayResourceConfig:getStaticItemSpriteName(animalType[animal])
				sprite = Sprite:createWithSpriteFrameName(key)
  			end
  			if sprite then
  				sprite:setScale(height / sprite:getGroupBounds().size.height)
  				sprite:setPosition(pos)
  				ph:removeFromParentAndCleanup(true)
  				parent:addChildAt(sprite, zorder)
  			end
		end
	end

	if #prop_gudie_animation_list > 0 and not hasLoadTutorialAnimation then
		FrameLoader:loadArmature( "skeleton/tutorial_animation" )
		hasLoadTutorialAnimation = true
	end

	for k, animationName in pairs(prop_gudie_animation_list) do
		local ph = ui:getChildByName(animationName)
		local parent = ph:getParent()
		local baseScale = ph:getScale()
		local zorder = ph:getZOrder()
		local pos = ccp(ph:getPositionX(), ph:getPositionY())
		local rs , re = string.find( animationName , "guide_dialogue_panel_common_ui/guide_dialogue_prop_gudie_animation_" )
		local propId = tonumber( string.sub( animationName , re + 1 ) )
		--printx( 1 , "   +++++++++++++++++++++++++++++++++++++++++++++   propId " , propId)
		local guideAnime = CommonSkeletonAnimation:creatTutorialAnimation( propId )
		guideAnime:setScaleX(baseScale)
		guideAnime:setScaleY(baseScale)
		ph:removeFromParentAndCleanup(true)
		parent:addChildAt(guideAnime, zorder)
		guideAnime:setPosition(pos)

		setTimeOut( function () 
				if guideAnime and not guideAnime.isDisposed then
					guideAnime:playAnimation()
				end
			end , 1 )
		
		table.insert(anim, guideAnime)
	end

	for k, buttonName in pairs(close_button_list) do
		local ph = ui:getChildByName(buttonName)
		local parent = ph:getParent()
		local baseScale = ph:getScale()
		local size = ph:getGroupBounds().size
		local zorder = ph:getZOrder()
		local pos = ccp(ph:getPositionX(), ph:getPositionY())

		local touchRect = LayerColor:create()
		touchRect:changeWidthAndHeight(size.width, size.height)
		touchRect:setTouchEnabled(true, 0, true)
		touchRect:setOpacity(0)
		touchRect:setPosition(ccp( pos.x , pos.y - size.height ) )
		parent:addChild(touchRect)
		touchRect.ignoreFade = true
		touchRect:ad(DisplayEvents.kTouchTap, function () 
				if panel.onCloseButtonTapped then
					panel.onCloseButtonTapped()
				end
			end)
	end

	for k, buttonName in pairs(buy_pre_prop_button_list) do
		local ph = ui:getChildByName(buttonName)
		local parent = ph:getParent()
		local baseScale = ph:getScale()
		local size = ph:getGroupBounds().size
		local zorder = ph:getZOrder()
		local pos = ccp(ph:getPositionX(), ph:getPositionY())

		local touchRect = LayerColor:create()
		touchRect:changeWidthAndHeight(size.width, size.height)
		touchRect:setTouchEnabled(true, 0, true)
		touchRect:setOpacity(0)
		touchRect.ignoreFade = true
		touchRect:setPosition(ccp( pos.x - size.width/2 , pos.y - size.height/2 ) )
		parent:addChild(touchRect)

		touchRect:ad(DisplayEvents.kTouchTap, function () 
				if panel.onBuyButtonTapped then
					panel.onBuyButtonTapped()
				end
			end)
	end
	
	--onBuyButtonTapped


	for __, v in ipairs(ui.list) do
		local list = nil
		if v.name == "TileBird" then
			list = v:getChildrenList()
		elseif v:getChildByName('tileEffect') then
			list = v:getChildByName("tileEffect"):getChildrenList()
			table.insert(list, v.mainSprite)
		else
			list = {}
			table.insert(list, v)
		end
		for __, v2 in pairs(list) do
			if not v2.ignoreFade then
				-- print(v2.refCocosObj, v2.refCocosObj.setOpacity) debug.debug()
				if v2.refCocosObj and v2.refCocosObj.setOpacity then
					v2:setOpacity(0)
					v2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCFadeIn:create(action.panFade)))
				end
			end
		end
	end

	if not skipText then
		if ui:getChildByName('skiptext') then
			ui:getChildByName("skiptext"):setVisible(false)
		end

		if ui:getChildByName('skipicon') then
			ui:getChildByName("skipicon"):setVisible(false)
		end
	end

	if ui:getChildByName('violation_text') then
		ui.violation_text = ui:getChildByName('violation_text')
		ui.violation_text:setRichText(localize(panelName..'.violation_text'), ui:getChildByName('violation_text').fntColor)
		ui.violation_text:setVisible(false)
	end

	
	BasePanel.init(panel, ui, "GameGuideUI")
	panel.panelName = panelName
	panel.onEnterHandler = function(self) end -- 覆盖原方法
	return panel
end


function GameGuideUI:panelS(playUI, action, skipText)


	local panel

	if not action.panelName then
		if action.panFlip then
			if action.panType == "down" then
				panel = GameGuideUI:panelSDR(action.text, skipText, action.prefHeight)
			else
				panel = GameGuideUI:panelSUR(action.text, skipText, action.prefHeight)
			end

			

		else
			if action.panType == "down" then
				panel = GameGuideUI:panelSD(action.text, skipText, action.prefHeight)
			else
				panel = GameGuideUI:panelSU(action.text, skipText, action.prefHeight)
			end
		end

		

		panel.onEnterHandler = function(self) end -- 覆盖原方法

		if action.panImage then
			for __, v in ipairs(action.panImage) do
				local sprite = Sprite:createWithSpriteFrameName(v.image)
				v.scale = v.scale or ccp(1, 1)
				sprite:setScaleX(v.scale.x)
				sprite:setScaleY(v.scale.y)
				v.x = v.x or 0
				v.y = v.y or 0
				sprite:setPosition(ccp(v.x, v.y))
				if v.rotation then
					sprite:setRotation(v.rotation)
				end
				panel:addChild(sprite)
			end
		end



		local anim = {}
		if action.panAnimal then
			for __, v in ipairs(action.panAnimal) do
				local sprite = nil
				if v.animal == "color" then
					sprite = TileBird:create()
	  				sprite:play(1)
	  				table.insert(anim, sprite)
	  			elseif specialType[v.special] > 1 then
	  				sprite = TileCharacter:create(v.animal)
	  				sprite:play(specialType[v.special])
	  				table.insert(anim, sprite)
	  			else
	  				local key = GamePlayResourceConfig:getStaticItemSpriteName(animalType[v.animal])
					sprite = Sprite:createWithSpriteFrameName(key);
	  			end
	  			v.scale = v.scale or ccp(1, 1)
				sprite:setScaleX(v.scale.x)
				sprite:setScaleY(v.scale.y)
				v.x = v.x or 0
				v.y = v.y or 0
				sprite:setPosition(ccp(v.x, v.y))
				panel:addChild(sprite)
			end
		end

		for __, v in ipairs(anim) do
			local list = nil
			if v.name == "TileBird" then
				list = v:getChildrenList()
			else
				list = v:getChildByName("tileEffect"):getChildrenList()
				table.insert(list, v.mainSprite)
			end
			for __, v2 in pairs(list) do
				v2:setOpacity(0)
				v2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCFadeIn:create(action.panFade)))
			end
		end

		if action.ignoreCharacter then
			local child = panel:getChildByName("animation")
			if child then
				child:removeFromParentAndCleanup(true)
			end
		else
			local target = panel:getChildByName("animation")
			if action.panFlip then
				target = target:getChildByName("animation")
			end
			target:setOpacity(0)
			target:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCFadeIn:create(action.panFade)))
		end


	else
		panel = GameGuideUI:dialogue(palyUI, action, skipText)
	end
	
	if action.panAlign == "matrixU" and playUI then
		local pos = playUI:getRowPosY(action.panPosY)
		panel:setPosition(ccp(panel:getPosition().x, pos + panel.ui:getGroupBounds().size.height))
	elseif action.panAlign == "matrixD" and playUI then
		local pos = playUI:getRowPosY(action.panPosY)
		panel:setPosition(ccp(panel:getPosition().x, pos))
	elseif action.panAlign == "winY" then
		panel:setPosition(ccp(panel:getPosition().x, action.panPosY))
	elseif action.panAlign == "winYU" then
		local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		--printx( 1 , "    visibleSize.height = " , visibleSize.height)
		panel:setPosition(ccp(panel:getPosition().x, visibleSize.height - action.panPosY))
	elseif action.panAlign == "viewY" then
		panel:setPosition(ccp(panel:getPosition().x, action.panPosY + Director:sharedDirector():getVisibleOrigin().y))
	end


	if action.panHorizonAlign == "matrixU" and playUI then
		local pos = playUI:getRowPosX(action.panPosX)
		panel:setPosition(ccp( pos + panel.ui:getGroupBounds().size.width , panel:getPosition().y))
	elseif action.panHorizonAlign == "matrixD" and playUI then
		local pos = playUI:getRowPosX(action.panPosX)
		panel:setPosition(ccp( pos , panel:getPosition().y))
	elseif action.panHorizonAlign == "winX" then
		panel:setPosition(ccp(action.panPosX , panel:getPosition().y))
	elseif action.panHorizonAlign == "viewX" then
		panel:setPosition(ccp( action.panPosX + Director:sharedDirector():getVisibleOrigin().x , panel:getPosition().y ))
	end


	action.panDelay = action.panDelay or 0.8
	action.panFade = action.panFade or 0.2
	local childrenList = {}
	panel:getVisibleChildrenList(childrenList)
	for __, v in pairs(childrenList) do
		v:setOpacity(0)
		v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCFadeIn:create(action.panFade)))
	end

	return panel
end

function GameGuideUI:panelSD(text, skipText, prefHeight)
	local wSize = Director:sharedDirector():getWinSize()
	local panel = BasePanel.new()
	panel.ui = ResourceManager:sharedInstance():buildGroup("guide_info_panelS")
	BasePanel.init(panel, panel.ui)
	panel.text = panel.ui:getChildByName("text")
	prefHeight = prefHeight or 0
	if prefHeight ~= 0 then
		local background = panel.ui:getChildByName("bg")
		
	end
	local str = Localization:getInstance():getText(text, {n = "\n", s = " "})
	panel.text:setRichText(str, "000000")
	if skipText then
		panel.ui:getChildByName("skiptext"):setString(Localization:getInstance():getText("game.guide.panel.skip.text"))
	else
		panel.ui:getChildByName("skiptext"):setVisible(false)
		panel.ui:getChildByName("skipicon"):setVisible(false)
	end
	local size = panel:getGroupBounds().size
	-- panel:setPosition(ccp((wSize.width - size.width) / 2, wSize.height / 2))
	panel:setPosition(ccp(panel:getHCenterInScreenX(), panel:getVCenterInScreenY()))
	local animation = CommonSkeletonAnimation:createTutorialDown()
	animation.name = "animation"
	animation:setPosition(ccp(390, 36))
	panel:addChild(animation)
	return panel
end

function GameGuideUI:panelSU(text, skipText)
	local wSize = Director:sharedDirector():getWinSize()
	local panel = BasePanel.new()
	panel.ui = ResourceManager:sharedInstance():buildGroup("guide_info_panelS")
	BasePanel.init(panel, panel.ui)
	panel.text = panel.ui:getChildByName("text")
	local str = Localization:getInstance():getText(text, {n = "\n", s = " "})
	panel.text:setRichText(str, "000000")
	if skipText then
		panel.ui:getChildByName("skiptext"):setString(Localization:getInstance():getText("game.guide.panel.skip.text"))
	else
		panel.ui:getChildByName("skiptext"):setVisible(false)
		panel.ui:getChildByName("skipicon"):setVisible(false)
	end
	local size = panel:getGroupBounds().size
	-- panel:setPosition(ccp((wSize.width - size.width) / 2, wSize.height / 2))
	panel:setPosition(ccp(panel:getHCenterInScreenX(), panel:getVCenterInScreenY()))
	local animation = CommonSkeletonAnimation:createTutorialUp()
	animation.name = "animation"
	animation:setPosition(ccp(433, 27))
	panel:addChild(animation)
	return panel
end

function GameGuideUI:panelSDR(text, skipText)
	local wSize = Director:sharedDirector():getWinSize()
	local panel = BasePanel.new()
	panel.ui = ResourceManager:sharedInstance():buildGroup("guide_info_panelSR")
	BasePanel.init(panel, panel.ui)
	panel.text = panel.ui:getChildByName("text")
	local str = Localization:getInstance():getText(text, {n = "\n", s = " "})
	panel.text:setRichText(str, "000000")
	if skipText then
		panel.ui:getChildByName("skiptext"):setString(Localization:getInstance():getText("game.guide.panel.skip.text"))
	else
		panel.ui:getChildByName("skiptext"):setVisible(false)
		panel.ui:getChildByName("skipicon"):setVisible(false)
	end
	local size = panel:getGroupBounds().size
	-- panel:setPosition(ccp((wSize.width - size.width) / 2, wSize.height / 2))
	panel:setPosition(ccp(panel:getHCenterInScreenX() + 20, panel:getVCenterInScreenY()))
	local animation = CommonSkeletonAnimation:createTutorialDown()
	animation.name = "animation"
	local sprite = CocosObject:create()
	sprite:addChild(animation)
	sprite:setScaleX(-1)
	sprite:setPosition(ccp(270, 38))
	sprite.name = "animation"
	panel:addChild(sprite)
	return panel
end

function GameGuideUI:panelSUR(text, skipText)
	local wSize = Director:sharedDirector():getWinSize()
	local panel = BasePanel.new()
	panel.ui = ResourceManager:sharedInstance():buildGroup("guide_info_panelSR")
	BasePanel.init(panel, panel.ui)
	panel.text = panel.ui:getChildByName("text")
	local str = Localization:getInstance():getText(text, {n = "\n", s = " "})
	panel.text:setRichText(str, "000000")
	if skipText then
		panel.ui:getChildByName("skiptext"):setString(Localization:getInstance():getText("game.guide.panel.skip.text"))
	else
		panel.ui:getChildByName("skiptext"):setVisible(false)
		panel.ui:getChildByName("skipicon"):setVisible(false)
	end
	local size = panel:getGroupBounds().size
	-- panel:setPosition(ccp((wSize.width - size.width) / 2, wSize.height / 2))
	panel:setPosition(ccp(panel:getHCenterInScreenX() + 20, panel:getVCenterInScreenY()))
	local animation = CommonSkeletonAnimation:createTutorialUp()
	animation.name = "animation"
	local sprite = CocosObject:create()
	sprite:addChild(animation)
	sprite:setScaleX(-1)
	sprite:setPosition(ccp(230, 27))
	sprite.name = "animation"
	panel:addChild(sprite)
	return panel
end

function GameGuideUI:panelL(text, skipText, action)
	local wSize = Director:sharedDirector():getWinSize()
	local panel
	if not action.panelName then 
		panel = BasePanel.new()
		panel.ui = ResourceManager:sharedInstance():buildGroup("guide_info_panelL")
		BasePanel.init(panel, panel.ui)
		panel.text = panel.ui:getChildByName("text")
		local str = Localization:getInstance():getText(text, {n = "\n", s = " "})
		panel.text:setRichText(str, "000000")
		if action.panImage then
			for __, v in ipairs(action.panImage) do
				local sprite = Sprite:createWithSpriteFrameName(v.image)
				sprite:setScaleX(v.scale.x)
				sprite:setScaleY(v.scale.y)
				sprite:setPosition(ccp(v.x, v.y))
				if v.rotation then
					sprite:setRotation(v.rotation)
				end
				panel:addChild(sprite)
			end
		end

		local anim = {}
		if action.panAnimal then
			for __, v in ipairs(action.panAnimal) do
				local sprite = nil
				if v.animal == "color" then
					sprite = TileBird:create()
	  				sprite:play(1)
	  				table.insert(anim, sprite)
	  			elseif specialType[v.special] > 1 then
	  				sprite = TileCharacter:create(v.animal)
	  				sprite:play(specialType[v.special], action.panDelay)
	  				table.insert(anim, sprite)
	  			else
	  				local key = GamePlayResourceConfig:getStaticItemSpriteName(animalType[v.animal])
					sprite = Sprite:createWithSpriteFrameName(key);
	  			end
	  			v.scale = v.scale or ccp(1, 1)
				sprite:setScaleX(v.scale.x)
				sprite:setScaleY(v.scale.y)
				v.x = v.x or 0
				v.y = v.y or 0
				sprite:setPosition(ccp(v.x, v.y))
				panel:addChild(sprite)
			end
		end

		local animation = CommonSkeletonAnimation:createTutorialNormal()
		animation.name = "animation"
		animation:setPosition(ccp(450, -530))
		for __, v in ipairs(anim) do
			local list = nil
			if v.name == "TileBird" then
				list = v:getChildrenList()
			else
				list = v:getChildByName("tileEffect"):getChildrenList()
				table.insert(list, v.mainSprite)
			end
			for __, v2 in pairs(list) do
				v2:setOpacity(0)
				v2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCFadeIn:create(action.panFade)))
			end
		end
		panel:addChild(animation)
	else
		panel = GameGuideUI:dialogue(nil, action, skipText)

	end

	if skipText then
		if panel.ui:getChildByName("skiptext") then
			panel.ui:getChildByName("skiptext"):setString(Localization:getInstance():getText("game.guide.panel.skip.text"))
		end
	else
		if panel.ui:getChildByName("skiptext") then
			panel.ui:getChildByName("skiptext"):setVisible(false)
		end
		
		if panel.ui:getChildByName("skipicon") then
			panel.ui:getChildByName("skipicon"):setVisible(false)
		end
	end

	-- panel:setPosition(ccp((wSize.width - size.width) / 2, wSize.height / 2))
	panel:setPosition(ccp(panel:getHCenterInScreenX(), panel:getVCenterInScreenY()))


	action.panDelay = action.panDelay or 0.3
	action.panFade = action.panFade or 0.2


	local childrenList = {}
	panel:getVisibleChildrenList(childrenList)
	for __, v in pairs(childrenList) do
		v:setOpacity(0)
		v:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.panDelay), CCFadeIn:create(action.panFade)))
	end
	panel.onEnterHandler = function(self) end -- 覆盖原方法
	return panel
end

function GameGuideUI:panelMini(text)
	local panel = BasePanel.new()
	panel.ui = ResourceManager:sharedInstance():buildGroup("guide_info_panelM")
	BasePanel.init(panel, panel.ui)
	panel.text = panel.ui:getChildByName("text")
	local str = Localization:getInstance():getText(text, {n = "\n", s = " "})
	panel.text:setRichText(str, "000000")
	panel.onEnterHandler = function(self) end -- 覆盖原方法
	return panel
end

function GameGuideUI:mask(opacity, touchDelay, position, radius, square, width, height, oval, skipClick)
	touchDelay = touchDelay or 0
	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(opacity)
	mask:setPosition(ccp(0, 0))


	local playFocusEffect = true
	-- 判断mask是否有挖洞
	-- 如果没有挖洞就不需要focus动画效果
	if (square or oval) and (not width or not height or width <= 0 or height<= 0) then
		playFocusEffect = false
	elseif (not square and not oval) and radius <= 0 then
		playFocusEffect = false
	end


	local node
	if square then
		node = LayerColor:create()
		width = width or 50
		height = height or 40
		node:changeWidthAndHeight(width, height)
	elseif oval then
		node = Sprite:createWithSpriteFrameName("circle0000")
		width, height = width or 1, height or 1
		node:setScaleX(width)
		node:setScaleY(height)
	else
		node = Sprite:createWithSpriteFrameName("circle0000")
		radius = radius or 1
		node:setScale(radius)
	end
	node:setPosition(ccp(position.x, position.y))
	local blend = ccBlendFunc()
	blend.src = GL_ZERO
	blend.dst = GL_ONE_MINUS_SRC_ALPHA
	node:setBlendFunc(blend)
	mask:addChild(node)

	local layer = CCRenderTexture:create(wSize.width, wSize.height)
	layer:setPosition(ccp(wSize.width / 2, wSize.height / 2))
	layer:begin()
	mask:visit()
	layer:endToLua()
	if __WP8 then layer:saveToCache() end

	mask:dispose()

	local layerSprite = layer:getSprite()
	local obj = CocosObject.new(layer)
	local trueMaskLayer = Layer:create()
	trueMaskLayer:addChild(obj)
	trueMaskLayer:setTouchEnabled(true, 0, true)
	local function onTouch() GameGuide:sharedInstance():onGuideComplete() end
	local function beginSetTouch() trueMaskLayer:ad(DisplayEvents.kTouchBegin, onTouch) end
	local arr = CCArray:create()
	if not skipClick then
		trueMaskLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(touchDelay), CCCallFunc:create(beginSetTouch)))
	end
	trueMaskLayer.setFadeIn = function(maskDelay, maskFade)

		if playFocusEffect then

			local anchor = layerSprite:getAnchorPoint()
			local anchorPos = ccp(anchor.x*layerSprite:getContentSize().width, anchor.y*layerSprite:getContentSize().height)

			local scaleTime = 0.3
			local oScaleX, oScaleY = layerSprite:getScaleX(), layerSprite:getScaleY()
			layerSprite:setScaleX(oScaleX*10)
			layerSprite:setScaleY(oScaleY*10)

			-- 保持在当前anchor下缩放，目标坐标保持静止的补偿向量
			local function getCompensateDir(oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				return ccp(d_to_a.x*(oScaleX-dScaleX), d_to_a.y*(oScaleY-dScaleY))
			end

			local function getCompensateMove(time, oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				local dir = getCompensateDir(oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				return CCMoveBy:create(time, dir)
			end

			-------------------------------------------------------
			---- 计算补偿位移需要的向量
			local d_to_o = ccp(position.x, position.y)
			local a_to_o = anchorPos
			local d_to_a = ccp(d_to_o.x - a_to_o.x, d_to_o.y - a_to_o.y)
			local action = getCompensateMove(scaleTime, layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY, d_to_a)
			-- if _G.isLocalDevelopMode then printx(0, d_to_o.x, d_to_o.y, d_to_a.x, d_to_a.y, layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY) debug.debug() end
			local compensateDir = getCompensateDir(layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY, d_to_a)
			-------------------------------------------------------

			-- anchor不变的情况下，将缩放中心放到目标位置
			layerSprite:setPositionX(layerSprite:getPositionX()-compensateDir.x)
			layerSprite:setPositionY(layerSprite:getPositionY()-compensateDir.y)

			local focusAction = CCSpawn:createWithTwoActions(CCScaleTo:create(scaleTime, oScaleX, oScaleY), action)
			local focusFadeIn = CCSpawn:createWithTwoActions(CCFadeIn:create(maskFade), focusAction)

			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), focusFadeIn))
		else
			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), CCFadeIn:create(maskFade)))
		end

	end	
	trueMaskLayer.layerSprite = layerSprite
	return trueMaskLayer
end

function GameGuideUI:mask2(nodes, callback, opacity, touchDelay, skipClick)
	-- body
	touchDelay = touchDelay or 0
	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(opacity or 200)
	mask:setPosition(ccp(0, 0))

	local UIHelper = require 'zoo.panel.UIHelper'


	for _, node in ipairs(nodes) do
		local sp = UIHelper:renderNode2Sprite(node)
		local blend = ccBlendFunc()
		blend.src = GL_ZERO
		blend.dst = GL_ONE_MINUS_SRC_ALPHA
		sp:getSprite():setBlendFunc(blend)
		mask:addChild(sp)
	end

	local layer = CCRenderTexture:create(wSize.width, wSize.height)
	layer:setPosition(ccp(wSize.width / 2, wSize.height / 2))
	layer:begin()
	mask:visit()
	layer:endToLua()
	layer:saveToFile(HeResPathUtils:getResCachePath() .. "/share_image.png")
	if __WP8 then layer:saveToCache() end
	mask:dispose()

	local layerSprite = layer:getSprite()
	local obj = CocosObject.new(layer)
	local trueMaskLayer = Layer:create()
	trueMaskLayer:addChild(obj)
	trueMaskLayer:setTouchEnabled(true, 0, true)
	local function onTouch()  
		if callback then callback() end
	end
	local function beginSetTouch() trueMaskLayer:ad(DisplayEvents.kTouchBegin, onTouch) end
	local arr = CCArray:create()
	if not skipClick then
		trueMaskLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(touchDelay), CCCallFunc:create(beginSetTouch)))
	end
	trueMaskLayer.layerSprite = layerSprite
	return trueMaskLayer
end

function GameGuideUI:skipButton(skipText, action, notSkipLevel, callback)
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local layer = LayerColor:create()
	layer:setOpacity(0)
	layer:changeWidthAndHeight(200, 80)
	layer:setPosition(ccp(0, vOrigin.y + vSize.height - 50))
	local function onTouch()
		if callback then callback() end
		GameGuide:sharedInstance():onGuideComplete(not notSkipLevel)
	end
	layer:setTouchEnabled(true, 0, true)
	layer:ad(DisplayEvents.kTouchTap, onTouch)
	layer:setOpacity(0)

	local text = TextField:create(skipText, nil, 32)
	text:setPosition(ccp(50, 25))
	text:setColor(ccc3(136, 255, 136))
	text:setOpacity(0)
	text:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(action.maskDelay), CCFadeIn:create(action.maskFade)))
	layer:addChild(text)

	return layer
end
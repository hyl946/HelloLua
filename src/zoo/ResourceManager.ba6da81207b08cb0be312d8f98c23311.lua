
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年08月29日 10:27:57
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.ui.LayoutBuilder"
---------------------------------------------------
-------------- ResourceManager
---------------------------------------------------

assert(not ResourceManager)
ResourceManager = class()

function ResourceManager:init(...)
	assert(#{...} == 0)

	-- --------------------------
	-- ------ Used For Parse Json File
	-- -------------------------

	-- Key : Full File Name
	-- Value: LayoutBuilder
	self.layoutBuilderByFileName	= {}

	-- Key: Group Name
	-- Value: LayoutBuilder
	self.layoutBuilderByGroupName	= {}

	self.filePathMapping = {}

	------------------------------------
	---- Set Font
	---------------------------------
	---- Used For Time/Move Counter
	--LayoutBuilder:addGlobalFontFace("Berlin Sans FB Demi", "flash/scenes/gamePlayScene/NormalButton.fnt")
	LayoutBuilder:addGlobalFontFace("Berlin Sans FB Demi", "Helvetica")
	LayoutBuilder:addGlobalFontFace("BerlinSansFBDemi-Bold", "Helvetica")
	LayoutBuilder:addGlobalFontFace("BerlinSansFBDemi", "Helvetica")

	-- Used For Target Progress Counter
	--LayoutBuilder:addGlobalFontFace("微软雅黑", "flash/scenes/gamePlayScene/NormalButton.fnt")

	--------------------------
	-- Used In Panel's Title
	-- -----------------------
	--LayoutBuilder:addGlobalFontFace("WenQuanYiMicroHei", "fnt/titles.fnt")
	local filename = "fnt/titles.fnt"
	if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/titles.fnt" end
	addGlobalDynamicFontMap("WenQuanYiMicroHei", filename)
	addGlobalDynamicFontMap("文泉驿微米黑", filename)

	filename = "fnt/titles_red.fnt"
	addGlobalDynamicFontMap("Rosewood Std", filename)
	addGlobalDynamicFontMap("Rosewood Std Regular", filename)

	filename = "fnt/caption.fnt"
	if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/caption.fnt" end
	addGlobalDynamicFontMap("Lucida Bright", filename)
	addGlobalDynamicFontMap("LucidaBright", filename) -- for Flash on OS X

	filename = "fnt/share.fnt"
	--if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/caption.fnt" end
	addGlobalDynamicFontMap("Lucida Fax", filename)
	--------------------------
	-- Used In Panel Button
	-- -----------------------
	--LayoutBuilder:addGlobalFontFace("微软雅黑", "Helvetica")
	filename = "fnt/green_button.fnt"
	if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/green_button.fnt" end
	addGlobalDynamicFontMap("微软雅黑", filename)
	addGlobalDynamicFontMap("Microsoft YaHei Bold", filename)
	addGlobalDynamicFontMap("MicrosoftYaHei", filename)
	addGlobalDynamicFontMap("MicrosoftYaHei-Bold", filename)
	addGlobalDynamicFontMap("Microsoft YaHei", filename)
	
	addGlobalDynamicFontMap("EucrosiaUPC", "fnt/blue_button.fnt")
	addGlobalDynamicFontMap("LetterGothicStd", "fnt/target_amount.fnt")
	addGlobalDynamicFontMap("Letter Gothic Std", "fnt/target_amount.fnt")
	addGlobalDynamicFontMap("LetterGothicStd-Bold", "fnt/target_amount.fnt")
	addGlobalDynamicFontMap("Letter Gothic Std Bold", "fnt/target_amount.fnt")

	filename = "fnt/objectives.fnt"
	if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/objectives.fnt" end
	addGlobalDynamicFontMap("Tahoma", filename)
	addGlobalDynamicFontMap("Prestige Elite Std", "fnt/prop_amount.fnt")
	addGlobalDynamicFontMap("Prestige Elite Std Bold", "fnt/prop_amount.fnt")
	addGlobalDynamicFontMap("PrestigeEliteStd-Bd", "fnt/prop_amount.fnt")
	
	addGlobalDynamicFontMap("SchoolHouse Cursive B", "fnt/score_objectives.fnt")
	addGlobalDynamicFontMap("SchoolHouseCursiveB", "fnt/score_objectives.fnt")
	-- addGlobalDynamicFontMap("Segoe UI", "fnt/score_objectives.fnt")	 
	addGlobalDynamicFontMap("Segoe UI", "fnt/target_amount.fnt")	 
	addGlobalDynamicFontMap("Berlin Sans FB Demi", "fnt/steps_cd.fnt")
	addGlobalDynamicFontMap("Berlin Sans FB Demi Bold", "fnt/steps_cd.fnt")
	addGlobalDynamicFontMap("BerlinSansFBDemi-Bold", "fnt/steps_cd.fnt")
	addGlobalDynamicFontMap("BerlinSansFBDemi", "fnt/steps_cd.fnt")



	-- Used In Level Success Top Panel
	addGlobalDynamicFontMap("Arial", "fnt/target_amount.fnt")
	addGlobalDynamicFontMap("ArialMT", "fnt/target_amount.fnt")
	addGlobalDynamicFontMap("Arial Bold", "fnt/target_amount.fnt")

	addGlobalDynamicFontMap("Book Antiqua", "fnt/friends_list.fnt")
	-- Add Energy Panel
	addGlobalDynamicFontMap("Algerian", "fnt/5_more_cd.fnt")

	addGlobalDynamicFontMap("Aparajita", "fnt/discount.fnt")
	addGlobalDynamicFontMap("Verdana", "fnt/discount_icon.fnt")

	-- Used In HomeScene Energy Button
	filename = "fnt/energy_cd.fnt"
	if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/energy_cd.fnt" end
	addGlobalDynamicFontMap("BrowalliaUPC", filename)
	addGlobalDynamicFontMap("BrowalliaUPC-Bold", filename)
	addGlobalDynamicFontMap("Charcoal CY", filename)
	
	filename = "fnt/hud.fnt"
	if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/hud.fnt" end
	addGlobalDynamicFontMap("Cooper Black", filename)
	addGlobalDynamicFontMap("CooperBlack", filename)
	-- Used In HomeScene User Picture
	addGlobalDynamicFontMap("David", "fnt/nametag.fnt")
	-- Used In Buy Gold Panel
	addGlobalDynamicFontMap("Vivaldii", "fnt/cashshop.fnt")
	addGlobalDynamicFontMap("Vivaldi", "fnt/cashshop.fnt")

	-- Market Panel
	addGlobalDynamicFontMap("Agency FB", "fnt/store_title.fnt") 
	addGlobalDynamicFontMap("AgencyFB", "fnt/store_title.fnt") 
	addGlobalDynamicFontMap("AgencyFB-Reg", "fnt/store_title.fnt") 
	
	--新手引导用
	-- filename = "fnt/tutorial.fnt"
	filename = "fnt/tutorial_white.fnt"
	if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/tutorial.fnt" end
	addGlobalDynamicFontMap("Broadway",filename)

	filename = "fnt/addfriend4.fnt"
	addGlobalDynamicFontMap("Leelawadee", filename)

	-- fruit tree scene
	filename = "fnt/level_seq_n_energy_cd.fnt"
	addGlobalDynamicFontMap("Georgia", filename)
	addGlobalDynamicFontMap("Georgia Bold", filename)

	-- White item number font
	filename = "fnt/event_default_digits.fnt"
	addGlobalDynamicFontMap("Segoe UI Symbol", filename)

	filename = "fnt/update.fnt"
	addGlobalDynamicFontMap("Myriad Pro", filename)
	addGlobalDynamicFontMap("MyriadPro-Regular",filename)

	filename = "fnt/race_rank.fnt"
	addGlobalDynamicFontMap("Lithos Pro", filename)
	addGlobalDynamicFontMap("Lithos Pro Regular", filename)
	addGlobalDynamicFontMap("LithosPro-Regular", filename)
	
	filename = "fnt/mission_1.fnt"
	addGlobalDynamicFontMap("Wide Latin", filename)

	filename = "fnt/mission_2.fnt"
	addGlobalDynamicFontMap("Bradley Hand ITC", filename)

	filename = 'fnt/skip_level.fnt'
	addGlobalDynamicFontMap('SkipLevel', filename) -- SkipLevel字体不存在，在此占位而已
	addGlobalDynamicFontMap('Consolas', filename)
	
	filename = 'fnt/skip_level_word.fnt'
	addGlobalDynamicFontMap('Tunga', filename)

	filename = 'fnt/star_reward.fnt'
	addGlobalDynamicFontMap('Tempus Sans ITC', filename)
	
	filename = 'fnt/pay.fnt'
	addGlobalDynamicFontMap('Gadugi', filename)
	
	addGlobalDynamicFontMap("LCD AT&T Phone Time/Date", "fnt/lcd_digital.fnt")

	addGlobalDynamicFontMap('LilyUPC', 'fnt/star_entrance.fnt')
	addGlobalDynamicFontMap('LilyUPCBold', 'fnt/star_entrance.fnt')

	addGlobalDynamicFontMap('Raavi', "fnt/pay_discount.fnt")

	addGlobalDynamicFontMap('Corbel', "fnt/discount_limited_time.fnt")
	
	--addGlobalDynamicFontMap('Calisto MT', "fnt/yellow_yahei.fnt")
	addGlobalDynamicFontMap('Calisto MT', "fnt/yellow_yahei.fnt")
	addGlobalDynamicFontMap("CalisMTBol", "fnt/yellow_yahei.fnt")

	addGlobalDynamicFontMap("Centaur","fnt/prop_name.fnt")


	addGlobalDynamicFontMap("Angsana New","fnt/prop_store.fnt")
	addGlobalDynamicFontMap("AngsanaNew","fnt/prop_store.fnt")

	-- 占位
	addGlobalDynamicFontMap("DFHaiBaoW12","fnt/yellow_yahei.fnt")
	addGlobalDynamicFontMap("Microsoft Yi Baiti", "fnt/video.fnt")

	addGlobalDynamicFontMap("Gautami", "fnt/share_new.fnt")
	
	addGlobalDynamicFontMap("Shruti", "fnt/target_remain.fnt")
	addGlobalDynamicFontMap("Sylfaen", "fnt/target_remain2.fnt")
	addGlobalDynamicFontMap("Nyala", "fnt/register2.fnt")
	addGlobalDynamicFontMap("Nyala-Regular", "fnt/register2.fnt")
	addGlobalDynamicFontMap("Trebuchet MS", "fnt/countdown.fnt")
	addGlobalDynamicFontMap("TrebuchetMS", "fnt/countdown.fnt")
	
	addGlobalDynamicFontMap("华康方圆体W7", "fnt/titles.fnt")
	addGlobalDynamicFontMap("DFFangYuanW7", "fnt/titles.fnt")
	--addGlobalDynamicFontMap("华康方圆体W7", "fnt/titles.fnt")

	addGlobalDynamicFontMap("Impact", "fnt/tutorial_white.fnt")
	addGlobalDynamicFontMap("Kristen ITC", "fnt/piggybank.fnt")
	addGlobalDynamicFontMap("Lao UI", "fnt/piggybank_1.fnt")
	addGlobalDynamicFontMap("Latha", "fnt/piggybank_2.fnt")

	addGlobalDynamicFontMap("Ebrima", "fnt/newzhousai_rubynum.fnt")
end

function ResourceManager:sharedInstance(...)
	assert(#{...} == 0)

	if not resourceManagerSharedInstance then

		resourceManagerSharedInstance = ResourceManager.new()
		resourceManagerSharedInstance:init()
	end

	return resourceManagerSharedInstance
end

function ResourceManager:createTimeLimitFlag( itemId, bigFlag )

	local style

	if bigFlag then
		style = 1
	end

	local suffix = ''
	if style then
		suffix = suffix .. '_' .. style
	end
	local prefix = 'time_limit_flag.2018/'
	local key = ''
	local bIsTimeProp, limitType = ItemType:isTimeProp(itemId)
	if bIsTimeProp then
		if limitType == TimeLimitPropType.k48Hour then
			key = '48'
		else
			key = '24'
		end
		local spriteFrame = prefix .. key .. suffix .. '0000'
		if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrame) then
			return Sprite:createWithSpriteFrameName(spriteFrame)
		end
	end
end

--------------------------------------
----- Parse Json File
----------------------------------------------

function ResourceManager:addJsonFile(jasonFile, ...)
	assert(jasonFile)
	assert(#{...} == 0)

	local fullFilePath	= CCFileUtils:sharedFileUtils():fullPathForFilename(jasonFile)

	-- --------------------
	-- Check If Allready Added
	-- ----------------------
	if self.layoutBuilderByFileName[fullFilePath] then
		return
	end

	-- -----------
	-- Add It
	-- -----------
	he_log_info("ADD Json File : " .. jasonFile)
	local layoutBuilder = LayoutBuilder:createWithContentsOfFile(jasonFile)
	assert(layoutBuilder, "Add Jason File: " .. jasonFile .. " Failed !")

	self.layoutBuilderByFileName[fullFilePath] = layoutBuilder
	
	-- --------------------------------------------------
	-- Add Groups 
	-- Check All Groups Whether Conflict With Previous Added
	-- -------------------------------------------------
	local groups = layoutBuilder:getGroups()
	assert(groups)

	for k,v in pairs(groups) do
		if self.layoutBuilderByGroupName[k] then 

			local assertFalseMsg = "ResourceManager:addJsonFile Duplicated Groups Name (" .. k ..")! \n"
			assertFalseMsg = assertFalseMsg .. "In File " .. layoutBuilder:getJsonFilePath() .. " and " .. self.layoutBuilderByGroupName[k]:getJsonFilePath()

			--assert(false, assertFalseMsg)
		else
			--he_log_info("ADD Groups Name : " .. k)
			self.layoutBuilderByGroupName[k] = layoutBuilder
		end
	end
end

function ResourceManager:buildGroup(groupName, imageSuffix)
	assert(groupName)

	local layoutBuilder = self.layoutBuilderByGroupName[groupName]
	assert(layoutBuilder, "ResourceManager:build Has No Group Name (" .. groupName .. ") !")

	return layoutBuilder:build(groupName, imageSuffix)
end

function ResourceManager:buildGroupWithCustomProperty(groupName, imageSuffix, customPropertyFunc, ...)
	assert(groupName)
	assert(#{...} == 0)

	local layoutBuilder = self.layoutBuilderByGroupName[groupName]
	assert(layoutBuilder, "ResourceManager:buildGroupWithCustomProperty Has No Group Name (" .. groupName .. " ) !")

	return layoutBuilder:buildWithCustomeProperty(groupName, imageSuffix, customPropertyFunc)
end

function ResourceManager:buildBatchGroup(batchMode, groupName, imageSuffix, ...)
	assert(batchMode)
	assert(groupName)
	assert(#{...} == 0)

	local layoutBuilder = self.layoutBuilderByGroupName[groupName]
	assert(layoutBuilder, "ResourceManager:build Has No Group Name (" .. groupName .. ") !")

	return layoutBuilder:buildBatchGroup(batchMode, groupName, imageSuffix)
end

function ResourceManager:getSpriteTexture(groupName, imageSuffix, ...)
	assert(#{...} == 0)

	local sprite = self:buildSprite(groupName, imageSuffix)
	local texture = sprite:getTexture()
	sprite:dispose()

	assert(texture)
	return texture
end

function ResourceManager:buildSprite(groupName, imageSuffix, ...)
	assert(#{...} == 0)

	local group = self:buildGroup(groupName, imageSuffix)

	-- Get The Sprite
	local sprite = group:getChildByName("sprite")
	assert(sprite, "group name \"" .. groupName .. "\" 's sprite layer not found !")

	--he_log_warning("Will Leak Parent !")
	sprite:removeFromParentAndCleanup(false)
	group:dispose()

	return sprite
end

------------------------------------------------------
---- Function About Get The Item Resource
---------------------------------------------------

function ResourceManager:getItemResNameFromType(itemType, ...)
	assert(type(itemType) == "number")
	assert(#{...} == 0)

	if itemType == 2 or itemType == 4 then
		return "itemIcon" .. itemType
	else
		return "Prop_" .. itemType
	end
end

function ResourceManager:buildItemGroup(itemType, ...)
	assert(type(itemType) == "number")
	assert(#{...} == 0)

	if ItemType:isHeadFrame(itemType) then
		local headFrameUI = HeadFrameType:buildUI(ItemType:convertToHeadFrameId(itemType), 1, '')
		headFrameUI:getChildByName('head'):removeFromParentAndCleanup(true)
		return headFrameUI
	end

	itemType = ItemType:getRealIdByTimePropId( itemType )

	local resName = self:getItemResNameFromType(itemType)
	if _isQixiLevel and itemType == ItemType.GEM then -- qixi
		resName = "Prop_10_qixi"
	end
	return self:buildGroup(resName)
end

function ResourceManager:buildItemSprite(itemType, ...)
	assert(type(itemType) == "number")
	assert(#{...} == 0)


	if ItemType:isHeadFrame(itemType) then
		local headFrameUI = HeadFrameType:buildUI(ItemType:convertToHeadFrameId(itemType), 1, '')
		local sp = headFrameUI:getChildByName('headFrame')
		sp:removeFromParentAndCleanup(false)
		headFrameUI:dispose()
		return sp
	end

	if ItemType:isTimeProp(itemType) then
		itemType = ItemType:getRealIdByTimePropId(itemType)
	end

	local resName = self:getItemResNameFromType(itemType)

	return self:buildSprite(resName)
end

local function buildItemDecorate( itemType, itemNum )
	if itemType == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
		local btNum = BitmapText:create(tonumber(itemNum) or 0, 'fnt/prop_amount.fnt', -1, kCCTextAlignmentLeft)
		btNum:setTag(HeDisplayUtil.kIgnoreGroupBounds)
		btNum:setAnchorPoint(ccp(0.5, 0.5))
		btNum:setPosition(ccp(53, 24))
		btNum:setScale(0.7)
		return btNum
	end

end

function ResourceManager:buildItemGroupWithDecorate( itemType, itemNum )
	local ugItem = self:buildItemSprite(itemType)
	local ugDecorate = buildItemDecorate(itemType, itemNum)
	if ugDecorate then
		ugItem:addChild(ugDecorate)
	end
	return ugItem
end

function ResourceManager:buildItemSpriteWithDecorate(itemType, itemNum)
	local spItem = self:buildItemSprite(itemType)
	local ugDecorate = buildItemDecorate(itemType, itemNum)
	if ugDecorate then
		spItem:addChild(ugDecorate)
	end
	return spItem
end


function ResourceManager:getItemSize(itemType, ...)
	assert(#{...} == 0)

	local resName	= self:getItemResNameFromType(itemType)
	local res	= self:buildItemGroup(resName)
	assert(res)

	local bounds = res:getGroupBounds()
	return bounds.size
end

function ResourceManager:getItemResNameFromGoodsId(goodsId, ...)
	assert(type(goodsId) == "number")
	assert(#{...} == 0)

	return self:buildSprite("Goods_" .. goodsId)
end

---------------------------------------------------------

function ResourceManager:getGroupWidth(groupName, ...)
	assert(groupName)
	assert(#{...} == 0)

	return self:getGroupSize(groupName).width
end

function ResourceManager:getGroupHeight(groupName, ...)
	assert(groupName)
	assert(#{...} == 0)

	return self:getGroupSize(groupName).height
end

function ResourceManager:getGroupSize(groupName, ...)
	assert(groupName)
	assert(#{...} == 0)

	--he_log_warning("Will Leak Memory !")
	local resource	= self:buildGroup(groupName)
	assert(resource)
	local bounds	= resource:getGroupBounds()
	
	resource:dispose()
	return bounds.size
end

-------------------------------------------
------	Parse Plist File
-----------------------------------------------

function ResourceManager:addPlistFile(plistFile, ...)
	assert(plistFile)
	assert(#{...} == 0)
	SpriteUtil:addSpriteFramesWithFile(plistFile, imageFile)
end

function ResourceManager:buildAnimatedSprite(timePerFrame, pattern, begin, length, isReversed)
	return SpriteUtil:buildAnimatedSprite(timePerFrame, pattern, begin, length, isReversed)
end

function ResourceManager:loadNeededJsonFiles(...)
	assert(#{...} == 0)

	for i,v in ipairs(ResourceConfig.json) do
    	self:addJsonFile(v)
    end
end

function ResourceManager:getMappingFilePath(filePath)
	if not __WIN32 then return filePath end
	if self.filePathMapping and self.filePathMapping[filePath] then
		-- if _G.isLocalDevelopMode then printx(0, "mapping--->", filePath, self.filePathMapping[filePath]) end
		filePath = self.filePathMapping[filePath]
	end
	if _G.isLocalDevelopMode and _G.editorMode and EditorGameScene and filePath then
		local mappingPath = EditorGameScene:getMappingFilePath(filePath)
		if mappingPath then
			filePath = mappingPath
		end
	end
	return filePath
end

function ResourceManager:addFileMapping(srcPath, realPath)
	self.filePathMapping = self.filePathMapping or {}
	self.filePathMapping[srcPath] = realPath
end

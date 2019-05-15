---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-09-02 14:31:14
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-09-05 11:06:00
---------------------------------------------------------------------------------------
RequestMessagePageBackground = class()

function RequestMessagePageBackground:addPageBackground(page, bgType, width, height)
	bgType = bgType or RequestMessagePageBackgroundType.kNone
	if bgType == RequestMessagePageBackgroundType.kClover_AddFriend then
		self:addCloverAddFriendPageBg(page, width, height)
	end
end

function RequestMessagePageBackground:addCloverAddFriendPageBg(page, width, height)
	local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.request_message_panel)
	local bgUi = builder:buildGroup("animal2_addFriend_message_bg")
	if type(width) == "number" and type(height) == "number" then
		bgUi:getChildByName("bg"):setPreferredSize(CCSizeMake(width-30, height-15))
	end
	bgUi:setPosition(ccp(14, 0))
	page:addChildAt(bgUi, -1)
end

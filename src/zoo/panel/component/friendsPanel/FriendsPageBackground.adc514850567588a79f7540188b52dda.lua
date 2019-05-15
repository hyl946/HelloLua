FriendsPageBackground = class()

function FriendsPageBackground:addPageBackground(page, bgType, width, height)
	bgType = bgType or FriendsPageBackgroundType.kNone
	if bgType == FriendsPageBackgroundType.kClover_AddFriend then
		self:addCloverAddFriendPageBg(page, width, height)
	end
end

function FriendsPageBackground:addCloverAddFriendPageBg(page, width, height)
	local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.friends_panel)
	local bgUi = builder:buildGroup("animal2_addFriend_message_bg")
	if type(width) == "number" and type(height) == "number" then
		bgUi:getChildByName("bg"):setPreferredSize(CCSizeMake(width-30, height-15))
	end
	bgUi:setPosition(ccp(14, 0))
	page:addChildAt(bgUi, -1)
end

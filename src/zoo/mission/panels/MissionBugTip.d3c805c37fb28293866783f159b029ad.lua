MissionBugTip = class(BasePanel)

function MissionBugTip:create()
	local instance = MissionBugTip.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_bugtips)
	instance:init()
	return instance
end

function MissionBugTip:init()
	local ui = self:buildInterfaceGroup("missionPanel_bugTip")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)

	self.ui:setAnchorPoint(ccp(1,0))
	--self.ui:setPosition( ccp( 0,0 ) )
	self.ui:setPosition( ccp( self.ui:getGroupBounds().size.width * -1 , self.ui:getGroupBounds().size.height ) )

	self.item_1 = ui:getChildByName("item_1")
	self.item_pos = ccp( self.item_1:getPosition().x , self.item_1:getPosition().y)
	local rectSize = self.item_1:getGroupBounds().size
	self.item_size = {width = rectSize.width, height = rectSize.height}
	self.item_1:removeFromParentAndCleanup(true)
	self.item_1 = nil

	self.text_1 = ui:getChildByName("text_1")
	self.text_2 = ui:getChildByName("text_2")
	self.text_3 = ui:getChildByName("text_3")
	self.text_4 = ui:getChildByName("text_4")
	self.bg = ui:getChildByName("bg")

	self:clearTips()

end

function MissionBugTip:showTips(tipType , propId , callback , data)

	if self.isPlaying or self.isShow then
		return
	end

	self.isPlaying = true

	self:setVisible(true)

	if self.itemIcon then
		self.itemIcon:removeFromParentAndCleanup(true)
	end

	local tarScale = 1

	if tipType == 1 then
		self.text_1:setVisible(true)
		self.text_2:setVisible(false)
		self.text_3:setVisible(false)
		self.text_4:setVisible(false)
	elseif tipType == 2 then
		self.text_1:setVisible(false)
		self.text_2:setVisible(true)
		self.text_3:setVisible(false)
		self.text_4:setVisible(false)

		local icon = ResourceManager:sharedInstance():buildItemGroup(propId)
		self.itemIcon = icon
		
		self.itemIcon:setAnchorPoint( ccp(0,1) )
		self.itemIcon:setScale(0.7)
		self.itemIcon:setPosition(ccp( self.item_pos.x - 5 , self.item_pos.y + 10 ) )
		self.ui:addChild(self.itemIcon)
	elseif tipType == 3 then
		self.text_1:setVisible(false)
		self.text_2:setVisible(false)
		self.text_3:setVisible(true)
		self.text_4:setVisible(false)
	elseif tipType == 4 then
		self.text_1:setVisible(false)
		self.text_2:setVisible(false)
		self.text_3:setVisible(false)
		self.text_4:setVisible(true)
		self.text_4:setString("")
		--printx( 1 , "  BUGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG   1")
		local levelId = data
		local missionId = MissionManager:getInstance():getMissionIdOnLevel(levelId)[1]

		if missionId then
			--printx( 1 , "  BUGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG   2")
			local missionPosition = math.floor( missionId / 100000 )
			local missionData = MissionPanelLogic:createMissionDataByMissionLogicData(missionPosition)
			--printx( 1 , "  BUGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG   3")
			if missionData then
				--printx( 1 , "  BUGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG   4")
				self.text_4:setString( missionData.des .. "可完成任务" )
			end

		else
		end
		tarScale = 0.7
	end

	local spawn = CCSpawn:createWithTwoActions( 
		CCEaseSineOut:create( CCScaleTo:create( 0.3 , tarScale , tarScale) ) ,
		CCEaseSineOut:create( CCFadeTo:create( 0.3, 255) ) 
		)

	local actArr = CCArray:create()
	actArr:addObject( spawn )
	actArr:addObject( CCCallFunc:create( function ()
		if callback and type(callback) == "function" then callback() end
		self.isPlaying = false
		self.isShow = true
		end ) )

	self:runAction( CCSequence:create(actArr) )
end

function MissionBugTip:hideTips(callback)

	if self.isPlaying or not self.isShow then
		return
	end

	self.isPlaying = true

	local spawn = CCSpawn:createWithTwoActions( 
		CCEaseSineIn:create( CCScaleTo:create( 0.3 , 0.1 , 0.1) ) ,
		CCEaseSineIn:create( CCFadeTo:create( 0.3, 0) ) 
		)

	local actArr = CCArray:create()
	actArr:addObject( spawn )
	actArr:addObject( CCCallFunc:create( function () 
		self:setVisible(false) 
		if callback and type(callback) == "function" then callback() end
		self.isPlaying = false
		self.isShow = false
		end ) )

	self:runAction( CCSequence:create(actArr) )
end

function MissionBugTip:clearTips()
	self.text_1:setVisible(false)
	self.text_3:setVisible(false)
	self.text_2:setVisible(false)
	self:setVisible(false)

	self.isShow = false
	self.isPlaying = false

	self:setOpacity(0)
	self:setScale(0.1)

	self:stopAllActions()
end

function MissionBugTip:getTipIconGlobalPosition()

	if self.itemIcon then
		return self.ui:convertToWorldSpace( ccp( self.itemIcon:getPosition().x , self.itemIcon:getPosition().y) )
	end

	return ccp(0,0)
end
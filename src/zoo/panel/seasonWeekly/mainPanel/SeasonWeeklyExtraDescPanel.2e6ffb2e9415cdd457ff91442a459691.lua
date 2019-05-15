local SeasonWeeklyExtraDescPanel = class(BasePanel)
function SeasonWeeklyExtraDescPanel:create(resJson, rootGroupName, extraNum, extraPiecesNum)
    local panel = SeasonWeeklyExtraDescPanel.new()
    panel.resJson = resJson
    panel:loadRequiredResource(resJson)
    panel:init(rootGroupName, resBG, extraNum, extraPiecesNum) 
    return panel
end

function SeasonWeeklyExtraDescPanel:init(rootGroupName, resBG, extraNum, extraPiecesNum)

	self.ui = self:buildInterfaceGroup( rootGroupName )
	BasePanel.init(self, self.ui)

	self:initCloseButton()
	self.closeBtn:setTouchEnabled(true)
	--self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:closePanel() end)

	self.labels = {}
	for i = 1, 3 do
		self.labels[i] = self.ui:getChildByName('lbInfo'..i)
		self.labels[i]:setDimensions(CCSizeMake(self.labels[i]:getDimensions().width, 0))
		self.labels[i]:setString(Localization:getInstance():getText("2017_weeklyrace.summer.extraNum.detail"..i, {num = 20}))
	end

	local function setNum( nodeName, num )
		
		local n99Stub = self.ui:getChildByName(nodeName)
		local pos = ccp(n99Stub:getPositionX(), n99Stub:getPositionY())
		n99Stub:removeFromParentAndCleanup()

	    local n99 = BitmapText:create("x" ..tostring(num or 0), "fnt/profile2018.fnt")
	    n99:setAnchorPoint(ccp(0, 1))
	    n99:setPosition(pos)
	    n99:setScale(1.5)
	    self.ui:addChild(n99)

	end

	


    setNum('num_1', extraNum)
    -- setNum('num_2', extraPiecesNum)

end

function SeasonWeeklyExtraDescPanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("closeBtn")
end

function SeasonWeeklyExtraDescPanel:popout()
	self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self , true)
	self.allowBackKeyTap = true
	self:setPositionX(self:getPositionX()+2)
end

function SeasonWeeklyExtraDescPanel:closePanel()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function SeasonWeeklyExtraDescPanel:onCloseBtnTapped( ... )
    self:closePanel()
end

function SeasonWeeklyExtraDescPanel:unloadRequiredResource()
end

return SeasonWeeklyExtraDescPanel
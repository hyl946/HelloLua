FourStarGuideLevelNode = class(BaseUI)
function FourStarGuideLevelNode:create( ui, levelId, starNum , parentPanel)
	-- body
	local s = FourStarGuideLevelNode.new()
	s:init(ui, levelId, starNum, parentPanel)
	return s
end

function FourStarGuideLevelNode:init( ui, levelId, starNum , parentPanel)
	-- body
	BaseUI.init(self, ui)
	self.levelId = levelId
	self.starNum = starNum
	self.parentPanel = parentPanel
	self.ui:getChildByName("bg"):setVisible(false)
	for k = 1, 3 do 
		local star_sprite = self.ui:getChildByName("star"..k)
		if k ~= starNum then
			star_sprite:setVisible(false)
		end
	end

	if starNum > 1 then
		self.ui:getChildByName("flower1"):setVisible(false)
	else
		self.ui:getChildByName("flower2"):setVisible(false)
	end

	local level = self.ui:getChildByName("level")
	level:setText(levelId)
	local boundingBox = self.ui:getChildByName('levelPos')
    boundingBox:setVisible(false)
    local groupBounds = boundingBox:getGroupBounds()
    local rect = {x = boundingBox:getPositionX(), y = boundingBox:getPositionY(), width = groupBounds.size.width, height = groupBounds.size.height}
    InterfaceBuilder:centerInterfaceInbox(level, rect)
    local function onTapped( evt )
    	-- body
    	self:onTapped(evt)
    end
    self.ui:setTouchEnabled(true, 0, true)
    self.ui:ad(DisplayEvents.kTouchTap, onTapped)
end

function FourStarGuideLevelNode:onTapped( evt )
	-- body
	local pos = evt.globalPosition
	if self.scrollable and self.scrollable.touchLayer:hitTestPoint(pos) then
		local levelId = self.levelId
		if levelId <= UserManager.getInstance().user:getTopLevelId() then
			if self.parentPanel then
				self.parentPanel:onShowLevelStartPanel()
			end
			local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
		    startGamePanel:popout(false)
		else
			CommonTip:showTip(Localization:getInstance():getText("fourstar_tips"), 1)
		end
	else
		-- if _G.isLocalDevelopMode then printx(0, "-------------------") end
	end

	
end
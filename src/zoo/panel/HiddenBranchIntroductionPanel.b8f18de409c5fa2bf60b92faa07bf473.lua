
HiddenBranchIntroductionPanel = class(BasePanel)

function HiddenBranchIntroductionPanel:init(tip, branchId, closeCallBack)

	tip = tip or "hide.area.infor.panel.desc.1"

	BasePanel.init(self,CocosObject:create())

	self.branchId = branchId
	self:buildGuideBg()

	local action = {}
	local posX = 0
	local posY = 0
	if tip == "hide.area.infor.panel.desc.1" then
		action.panelName = 'guide_dialogue_hiddenLevelIntro'
		posX = 0
		posY = -480
	else
		action.panelName = 'guide_dialogue_hiddenBranchGuide'
		posX = 0
		posY = -520
	end
	-- old code
	-- local panel = GameGuideUI:panelSD(tip,true)
	-- panel:setPositionY(-80)
	-- end old code

	local panel = GameGuideUI:panelS(nil, action, true)
	panel:setPositionX(posX)
	panel:setPositionY(posY)
	self:addChild(panel)

	panel.ui:setTouchEnabled(true)
	panel.ui.hitTestPoint = function( ... )
		return true
	end
	self.closeCallBack = closeCallBack
	panel.ui:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:onConfirmTapped()
	end)
end

function HiddenBranchIntroductionPanel:buildGuideBg( ... )
	if not self.branchId then
		return
	end

	local worldScene = HomeScene:sharedInstance().worldScene
	if not worldScene.hiddenBranchArray[self.branchId] then
		return
	end

	local branchData = MetaModel:sharedInstance():getHiddenBranchDataList()[self.branchId]

	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleSize =  Director:sharedDirector():getVisibleSize()

	local function setPosition( selfNode,worldNode )
		local pos = worldNode:getParent():convertToWorldSpace(
			worldNode:getPosition()
		) 
		selfNode:setPositionX(pos.x - visibleOrigin.x)
		selfNode:setPositionY(-(visibleSize.height-pos.y) - visibleOrigin.y)
	end


	local function buildBranch( ... )

		local branchTexture = worldScene.hiddenBranchLayer.refCocosObj:getTexture()

		local hiddenBranchLayer = SpriteBatchNode:createWithTexture(branchTexture)
		local branch = HiddenBranch:create(self.branchId, true, branchTexture)
		hiddenBranchLayer:addChild(branch)
		setPosition(hiddenBranchLayer,worldScene.hiddenBranchLayer)
		self:addChild(hiddenBranchLayer)

		-- flower
		local flowerTexture = worldScene.treeNodeLayer.refCocosObj:getTexture()
		
		local flowerLevelNumberBatchLayer = BMFontLabelBatch:create("fnt/level_seq_n_energy_cd.png", "fnt/level_seq_n_energy_cd.fnt", 100)
		
		local playAnimLayer = CocosObject:create()
		self:addChild(playAnimLayer)

		for levelId=branchData.startHiddenLevel,branchData.endHiddenLevel do
			local nodeView = WorldMapNodeView:create(false,levelId,playAnimLayer,flowerLevelNumberBatchLayer,flowerTexture)
			setPosition(nodeView,worldScene.levelToNode[levelId])
			self:addChild(nodeView)

			local star = worldScene.levelToNode[levelId].star

			nodeView:setStar(star, 0, false, false, false)
			nodeView:updateView(false, false)
		end
		self:addChild(flowerLevelNumberBatchLayer)

		--cloud 
		if worldScene.hiddenBranchArray[self.branchId].cloud then
			local cloudBathNode = SpriteBatchNode:createWithTexture(
				worldScene.lockedCloudLayer:getBatchNode().refCocosObj:getTexture()
			)
			local textBatchNode = BMFontLabelBatch:create(
				"fnt/tutorial_white.png",
				"fnt/tutorial_white.fnt",
				10
			)
			local numberBathNode = BMFontLabelBatch:create(
				"fnt/event_default_digits.png",
				"fnt/event_default_digits.fnt",
				10
			)

			setPosition(cloudBathNode,worldScene.lockedCloudLayer:getBatchNode())
			setPosition(textBatchNode,worldScene.lockedCloudLayer:getHiddenBranchTextBatchNode())
			setPosition(numberBathNode,worldScene.lockedCloudLayer:getHiddenBranchNumberBatchNode())

			self:addChild(cloudBathNode)
			self:addChild(textBatchNode)
			self:addChild(numberBathNode)

			branch:showCloud(cloudBathNode, textBatchNode, numberBathNode, nil, true)
		end
	end

	local function buildTrunk( parent )
		if not parent then
			parent = self
		end

		for i=1,2 do
			if worldScene.trunks.trees[self.branchId + i] then
				local trunk = Sprite:createWithSpriteFrameName("trunk.png")
				trunk:setAnchorPoint(ccp(0,1))
				setPosition(trunk,worldScene.trunks.trees[self.branchId + i])
				parent:addChild(trunk)
			end
		end

		-- flower
		local flowerTexture = worldScene.treeNodeLayer.refCocosObj:getTexture()
		local treeNodeLayer = SpriteBatchNode:createWithTexture(flowerTexture)--关卡点所在的层

		local flowerLevelNumberBatchLayer = BMFontLabelBatch:create("fnt/level_seq_n_energy_cd.png", "fnt/level_seq_n_energy_cd.fnt", 100)

		-- 遮罩的时候数字addchild的花的前面，原因 WorldMapNodeView 会调用 removeFromParentAndCleanup
		if parent ~= self then
			parent:addChild(flowerLevelNumberBatchLayer)
			parent:addChild(treeNodeLayer)
		else
			parent:addChild(treeNodeLayer)
			parent:addChild(flowerLevelNumberBatchLayer)
		end
		
		
		local playAnimLayer = CocosObject:create()
		parent:addChild(playAnimLayer)
		
		local endNormalLevel = branchData.endNormalLevel + 15

		for levelId=branchData.startNormalLevel,endNormalLevel do
			if worldScene.levelToNode[levelId] then
				local nodeView = WorldMapNodeView:create(true,levelId,playAnimLayer,flowerLevelNumberBatchLayer,flowerTexture)
				setPosition(nodeView,worldScene.levelToNode[levelId])
				treeNodeLayer:addChild(nodeView)

				local star = worldScene.levelToNode[levelId].star
				-- local isJumpLevel = worldScene.levelToNode[levelId].isJumpLevel
				local ingredientCount = JumpLevelManager:getInstance():getLevelPawnNum(levelId)

				nodeView:setStar(star, ingredientCount, false, false, false)
				nodeView:updateView(false, false)
			end
		end

	end

	local function buildDrakLayer( isInvert )
		local stencil = CocosObject:create()

		buildTrunk(stencil)

		local clippingNode = ClippingNode.new(CCClippingNode:create(stencil.refCocosObj))
		self:addChild(clippingNode)

		stencil:dispose()

		clippingNode:setInverted(isInvert)
		clippingNode:setAlphaThreshold(0)

		local darkLayer = LayerColor:create()
		darkLayer:setOpacity(150)
		darkLayer:setContentSize(visibleSize)
		darkLayer:setAnchorPoint(ccp(0,1))
		darkLayer:ignoreAnchorPointForPosition(false)
		clippingNode:addChild(darkLayer)
	end

	buildDrakLayer(true)

	buildBranch()

	buildTrunk()

	buildDrakLayer(false)

end


function HiddenBranchIntroductionPanel:onConfirmTapped()
	self:markAutoPopoutFlag()
	PopoutManager:sharedInstance():remove(self, true)
	if self.closeCallBack ~= nil then
		self.closeCallBack()
	end
end

function HiddenBranchIntroductionPanel:markAutoPopoutFlag()
	Cookie.getInstance():write(CookieKey.kHiddenAreaIntroduction, "true")
	
	UserLocalLogic:setBAFlag(kBAFlagsIdx.kHiddenBranchIntroduction)
end

function HiddenBranchIntroductionPanel:create(tip,branchId)
	local v = HiddenBranchIntroductionPanel.new()
	-- v:loadRequiredResource(PanelConfigFiles.unlock_hidden_area_panel)
	v:init(tip,branchId)
	return v
end
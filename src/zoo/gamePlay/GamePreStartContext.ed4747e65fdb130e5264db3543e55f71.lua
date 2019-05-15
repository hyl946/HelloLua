GamePreStartContext = class{}

local _instance = nil

local __CostMoneyType = {
	
	kInBag = 0 ,
	kCoin = 1 ,
	kGold = 2 ,
	kRMB = 3 ,
	kPlayVideo = 4 ,
}

local function __createPlayId()
	local function getCurrUid()
		return UserManager:getInstance():getUID() or "12345"
	end

	local function getCurrUdid()
		return MetaInfo:getInstance():getUdid() or "hasNoUdid"
	end

	local function nowTime()
		return os.time() + (__g_utcDiffSeconds or 0)
	end

	local str = tostring(getCurrUid()) .. tostring(getCurrUdid()) .. tostring(nowTime())

	return str
end

function GamePreStartContext_reInstance()
	_instance = GamePreStartContext.new()
	_instance:init()
end

function GamePreStartContext:getCostMoneyTypeConfig()
	return __CostMoneyType
end

function GamePreStartContext:getInstance()

	if not _instance then
		_instance = GamePreStartContext.new()
		_instance:init()
	end

	return _instance
end

function GamePreStartContext:init()
	self.inited = true
	self:reset()
end

function GamePreStartContext:reset()
	self.playId = nil
	self.levelInfo = {}
	self.bagSnapshot = {}
	self.baseInfoSnapshot = {}
	self.startLevelCostInfo = {}
	self.prePropCostInfo = {}

	self.isDefaultDataState = true
	self.isActive = false

	self.playIdCreateTime = nil
end

function GamePreStartContext:getPlayId()
	if self.playId then
		return self.playId
	else
		self.playIdCreateTime = HeTimeUtil:getCurrentTimeMillis()
		return __createPlayId()
	end
end

function GamePreStartContext:closeStartPanel()
	self:reset()
end

function GamePreStartContext:setActive(active)
	self.isActive = active
end

--点击开始闯关按钮，主线的关卡花，周赛主面板的开始按钮，或者其它可能弹出开始游戏面板的按钮
function GamePreStartContext:clickButton( levelId , levelType , startLevelType , source)
	--目前暂时没有地方用到
	self.isDefaultDataState = false
	self:reset()
	self.playId = self:getPlayId()
end

--构建开始游戏面板，这一步在某些情况下可能没有，也是合法的
function GamePreStartContext:buildStartPanel( levelId , levelType , startLevelType , source)
	if self.isDefaultDataState then
		self:reset()
		self.playId = self:getPlayId()
		self.isDefaultDataState = false
	end
	self.isActive = true

	self.levelInfo.level = levelId
	self.levelInfo.metaLevelId = LevelMapManager.getInstance():getMetaLevelId(levelId)
	self.levelInfo.levelType = levelType
	self.levelInfo.startLevelType = startLevelType
	self.levelInfo.startLevelSource = source

	local userRef = UserManager:getInstance():getUserRef()
	local userSocre = UserManager:getInstance():getUserScore( levelId )
	if not userSocre then
		 userSocre = {star = 0 , score = 0}
	end
	
	self.levelInfo.star = userSocre.star
	self.levelInfo.totalStar = userRef:getStar() + userRef:getHideStar()

	self.levelInfo.score = userSocre.score

	self.baseInfoSnapshot.coinWhenStart = userRef:getCoin()
	self.baseInfoSnapshot.cashWhenStart = userRef:getCash()

	local _a , _b , maxEnergy , isInfiniteEnergy = UserManager:getInstance():refreshEnergy()

	self.baseInfoSnapshot.energyWhenStart = userRef:getEnergy()

	if isInfiniteEnergy then
		self.baseInfoSnapshot.energyWhenStart = -1
		self.baseInfoSnapshot.maxEnergyWhenStart = -1
	else
		self.baseInfoSnapshot.maxEnergyWhenStart = maxEnergy
	end

	self:initBagInfo()
end

--弹出开始游戏面板，这一步在某些情况下可能没有，也是合法的
function GamePreStartContext:popStartPanel( levelId , levelType , startLevelType , source)

end

function GamePreStartContext:initBagInfo()
	local bagData = BagManager:getInstance():getUserBagData()

	local props = UserManager:getInstance().props or {}
	local timeProps = UserManager:getInstance():getAndUpdateTimeProps() or {}

	for k1, v1 in pairs( props ) do
		local obj = {}
		obj.itemId = v1.itemId
		obj.num = v1.num

		table.insert( self.bagSnapshot , obj )
	end

	for k2, v2 in pairs( timeProps ) do
		local obj = {}
		obj.itemId = v2.itemId
		obj.num = v2.num
		obj.expireTime = v2.expireTime

		table.insert( self.bagSnapshot , obj )
	end
end

function GamePreStartContext:initPreProps( preItemViews , propDatas )
	if preItemViews then
		for k,v in ipairs(preItemViews) do
			if v:isSelected() and not v:isLocked() then
				-- LevelInfoPanel:initPreGameTools 时处理了自动勾选，所以这时preGameTools选中的都是有剩余数量，且会自动带进关卡里的道具
				
				local obj = {}
				obj.propId = v:getItemId()
				obj.costMoney = 0 -- v:getRealPrice()
				obj.costMoneyType = __CostMoneyType.kInBag
				obj.result = true

				self.prePropCostInfo[obj.propId] = obj
			end
		end
	end
end

function GamePreStartContext:selectPreProps( selected , preItemView , costMoney , costMoneyType , result )
	if selected then
		local obj = {}
		obj.propId = preItemView:getItemId()
		obj.costMoney = costMoney
		obj.costMoneyType = costMoneyType
		obj.result = result

		self.prePropCostInfo[obj.propId] = obj
	else
		self.prePropCostInfo[ preItemView:getItemId() ] = nil
	end
end

function GamePreStartContext:endLevel()

end
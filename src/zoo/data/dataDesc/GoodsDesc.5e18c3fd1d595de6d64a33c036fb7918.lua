
require "zoo.data.MetaManager"
require "zoo.ui.InterfaceBuilder"
require "zoo.data.UserManager"

GoodsDesc = class()

kGoodsList = {
	kBomb_PreGame = 6,
	kAddStep_PreGame = 8,
}

local goodsIcon = {
	1, 2, 3, 4, 5, 6, 7, 8, 12, 18,
}

-- return a table of infos
-- icon can be used directly
-- use icon:diable and icon:enable function to grayout and recover icon
function GoodsDesc:create(goodsId)
	if not goodsId then return nil end
	local desc = GoodsDesc.new()
	if desc:_init(goodsId) then return desc
	else desc = nil return nil end
end

function GoodsDesc:dispose()
	self.icon:dispose()
end

function GoodsDesc:_init(goodsId)
	local meta = MetaManager:getInstance():getGoodMeta(goodsId)
	if not meta then return false end
	
	self.id = meta.id
	if meta.coin ~= 0 then self.coin = meta.coin end

	if __IOS_FB then -- facebook平台使用fCash的值
		if meta.fCash and meta.fCash ~= 0 then
			self.qCash = meta.fCash
			if meta.discountFCash and meta.discountFCash ~= 0 then
				self.discountQCash = meta.discountFCash
				self.qDiscount = math.ceil(meta.discountFCash / meta.fCash * 10) / 10
			end
		end
	else
		if meta.qCash and meta.qCash ~= 0 then
			self.qCash = meta.qCash
			if meta.discountQCash and meta.discountQCash ~= 0 then
				self.discountQCash = meta.discountQCash
				self.qDiscount = math.ceil(meta.discountQCash / meta.qCash * 10) / 10
			end
		end
	end
	
	if meta.rmb and meta.rmb ~= 0 then
		self.rmb = meta.rmb
		if meta.discountRmb and meta.discountRmb ~= 0 then
			self.discountRmb = meta.discountRmb
			self.rmbDiscount = math.ceil(meta.discountRmb / meta.rmb * 10) / 10
		end
	end
	self.name = Localization:getInstance():getText("goods.name.text"..tostring(goodsId))
	local builder = InterfaceBuilder:create(PanelConfigFiles.properties)
	for k, v in ipairs(goodsIcon) do
		if v == goodsId then
			self.icon = builder:buildGroup('Goods_'..goodsId)
			break
		end
	end
	self.icon = self.icon or builder:buildGroup('Prop_wenhao')
	self.icon.disable = function(self)	-- gray out
		local sprite = self:getChildByName("sprite")
		sprite:applyAdjustColorShader()
		sprite:adjustColor(0, -1, 0, 0)
	end
	self.icon.enable = function(self)  -- return colorful
		local sprite = self:getChildByName("sprite")
		sprite:clearAdjustColorShader()
	end
	self.level = meta.level -- level to unlock
	self.limit = meta.limit -- limit per day
	self.items = meta.items -- content
	self.onSale = meta.on
	self.sort = meta.sort
	self.tag = meta.tag -- TODO: fix this
	self.beginDate = self:_parseDateTime(meta.beginDate)
	self.endDate = self:_parseDateTime(meta.endDate)

	return true
end

-- return number of goods can buy for today
-- CAUTION: -1 for not limited
function GoodsDesc:getRestDailyGoods()
	if self.limit == 0 then return -1 end
	local bought = UserManager:getInstance():getDailyBoughtGoodsNumById(self.id)
	return self.limit - bought
end

function GoodsDesc:_parseDateTime(str)
	if not str or string.len(str) <= 0 then return end
	local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
	local function get(index, num, ...) return {...} end
	res = get(string.find(str, pattern))
	if not res or #res < 6 then return end
	return os.time({year = tonumber(res[1]), month = tonumber(res[2]),
		day = tonumber(res[3]), hour = tonumber(res[4]),
		min = tonumber(res[5]), sec = tonumber(res[6])})
end
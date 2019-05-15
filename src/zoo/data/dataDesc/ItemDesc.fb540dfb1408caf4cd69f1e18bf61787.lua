
require "zoo.data.MetaManager"
require "zoo.ResourceManager"

ItemDesc = class()

-- what the item does effect
kItemDescType = {
	kNothing = 0, -- changes nothing
	kStep = 1, -- add steps
	kCoin = 2, -- add coin
	kEnergy = 3, -- add energy
	kBeanPod = 4, -- add bean-pod
	kTree = 5, -- charges tree
	kEnergyLimit = 6, -- energy limit up
	kInifiniteEnergy = 7, -- infinite energy
	kRevive = 8, -- not used for now
	kWeeklyGameChance = 9, -- not used for now
}

-- types of items
kItemType = {
	kSpecial = 0, -- for specific uses (including coin)
	kNormal = 1, -- into bag
	kDecorator = 2, -- decorators
	kLevelArea = 4, -- unlock locked clouds
	kBag = 10, -- bag space
	kTree = 11, -- tree upgrade

}

function ItemDesc:create(itemId)
	if not itemId then return nil end
	local desc = ItemDesc.new()
	if desc:init() then return desc
	else desc = nil return nil end
end

function ItemDesc:_init(itemId)
	local meta = MetaManager:getInstance():getPropMeta(itemId)
	if not meta then return false end

	self.itemId = meta.id
	self.type = math.floor(meta.id / 10000) -- kItemType
	self.name = Localization:getInstance():getText("prop.name."..tostring(itemId))
	self.tip = Localization:getInstance():getText("level.prop.tip."..tostring(itemId))
	if self.type == kItemType.kNormal then self.icon = ResourceManager:sharedInstance():buildItemSprite(itemId) end
	self.maxUseTime = meta.maxUsetime -- max times used in gameplay
	self.sell = meta.sell -- price for sale
	self.unlock = meta.unlock -- level to unlock
	self.useInBag = meta.usable
	if self.useInBag then self.value = meta.value end -- different meanings
	self.reward = meta.reward -- kItemDescType
	self.intoBag = meta.type
	
	return true
end
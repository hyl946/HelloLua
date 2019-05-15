local UIHelper = require 'zoo.panel.UIHelper'

local RewardItemView = class(Layer)

function RewardItemView:create( rewardItem, size )
	-- body
	local v = RewardItemView.new()
	v:initLayer()
	v:initWithData(rewardItem, size)

	return v
end

function RewardItemView:initWithData(rewardItem, size)
	local sp 
	local numForDisplay = rewardItem.num
	if ItemType:isMergableItem(rewardItem.itemId) then
		numForDisplay = 1
	end

	local numTxt = 'x' .. tostring(numForDisplay)
	local numTxt2 = ''

	if rewardItem.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
		numForDisplay = rewardItem.num
		numTxt = '' .. numForDisplay
		numTxt2 = '分钟'

		if numForDisplay % 60 == 0 then
			numForDisplay = math.floor(numForDisplay / 60)
			numTxt = '' .. numForDisplay
			numTxt2 = '小时'
		end

		sp = UIHelper:createSpriteFrame('ui/store.json', 'com.niu2x.store/item-sp-10098-0000')
	else
		sp = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(rewardItem.itemId, rewardItem.num)
	end

	self:addChild(sp)

	local numLabel = BitmapText:create(numTxt, 'fnt/skip_level_word_1.fnt')
	local numLabel2
	if #numTxt2 > 0 then
		numLabel2 = BitmapText:create(numTxt2, 'fnt/skip_level_word_1.fnt')
	end


	numLabel:setScale(1.2)	
	self:addChild(numLabel)

	if numLabel2 then
		numLabel2:setScale(1)
		self:addChild(numLabel2)
	end



	sp:setAnchorPoint(ccp(0.5, 1))
	sp:setPositionXY(size.height/2, 0)

	-- local scale = size.height / sp:getContentSize().height
	local scale = 0.5
	sp:setScale(scale)

	numLabel:setAnchorPoint(ccp(0, 0.5))
	numLabel:setPositionY(-size.height/2)
	numLabel:setPositionX(size.height + 3)

	if numLabel2 then
		numLabel2:setAnchorPoint(ccp(0, 0.5))
		numLabel2:setPositionY(-size.height/2)
		numLabel2:setPositionX(size.height + 3 + numLabel:getContentSize().width * numLabel:getScaleX())
	end


	local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(rewardItem.itemId, false)
	if time_prop_flag then
		self:addChild(time_prop_flag)
		time_prop_flag:setAnchorPoint(ccp(0.5, 1))
		time_prop_flag:setPositionY(-size.height/2)
		time_prop_flag:setPositionX(size.height/2)
	end


	local hit_area = Layer:create()
	hit_area:changeWidthAndHeight(size.width, size.height)
	hit_area.name = 'hit_area'
	hit_area:setAnchorPoint(ccp(0, 1))

	self:addChild(hit_area)

	

end

return RewardItemView
TileSuperBlocker = class(CocosObject)

function TileSuperBlocker:create(gamePlayType)
    local instance = TileSuperBlocker.new(CCNode:create())
    instance:init(gamePlayType)
    instance.name = "SuperBlocker"
    return instance
end

function TileSuperBlocker:init(gamePlayType)
	if gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
	    self.sprite = Sprite:createWithSpriteFrameName("super_blocker_0000")
	else
	    self.sprite = Sprite:createWithSpriteFrameName("super_blocker_0000")
	end
    self:addChild(self.sprite)
end

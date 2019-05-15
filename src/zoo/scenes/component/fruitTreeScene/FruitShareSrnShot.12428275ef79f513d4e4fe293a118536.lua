

FruitShareSrnShot = class(CocosObject)

function FruitShareSrnShot:create( bgPath, completeCallback )
	local srnShot = FruitShareSrnShot.new(CCNode:create())
	srnShot:init(bgPath,completeCallback)
	return srnShot
end

function FruitShareSrnShot:init(bgPath, completeCallback )
	local background = Sprite:create(bgPath)
	background:setAnchorPoint(ccp(0,0))
	self:addChild(background)
	self:setContentSize(background:getContentSize())

	CCTextureCache:sharedTextureCache():removeTextureForKey(
		CCFileUtils:sharedFileUtils():fullPathForFilename(bgPath)
	)

	local width = background:getContentSize().width
	local height = background:getContentSize().height

	if _G.__use_small_res == true then
		background:setScale(0.625)
		width = width * 0.625
		height = height * 0.625
	end

	function onImageLoadFinishCallback( ... )
		completeCallback()
	end

	local uid = UserManager:getInstance().uid
    local headUrl = UserManager:getInstance().profile.headUrl
    local head = HeadImageLoader:create(userId, headUrl, onImageLoadFinishCallback)
    head:setPositionX(90 + 109.25/2)
    head:setPositionY(height - 195 - 109.45/2)
    self:addChild(head)

	local username = UserManager.getInstance().profile:getDisplayName()
	local username = TextField:create(username, "微软雅黑", 24, CCSizeMake(24*6, 24), kCCTextAlignmentCenter)
	username:setAnchorPoint(ccp(0.5, 0))
	username:setPositionXY(head:getPositionX() + 2, head:getPositionY() - 88)
	self:addChild(username)
end
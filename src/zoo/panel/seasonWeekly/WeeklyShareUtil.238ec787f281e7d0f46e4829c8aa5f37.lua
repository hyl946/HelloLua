WeeklyShareUtil = {}

function WeeklyShareUtil.buildShareImage(group)
	assert(group, "group must not be nil")
	local imagePath = nil
	if group then 
		local bg_2d = Sprite:create("share/weekly_share_bg_1.jpg")
		bg_2d:setAnchorPoint(ccp(0, 1))
		local bg = group:getChildByName("bg")
		bg:setVisible(false)
		local size = bg:getGroupBounds().size
		local bSize = bg_2d:getGroupBounds().size
		bg_2d:setScaleX(size.width / bSize.width)
		bg_2d:setScaleY(size.height / bSize.height)
		group:addChildAt(bg_2d, group:getChildIndex(bg))

		local qr = Sprite:create(ShareUtil:getQRCodePath())
		qr:setAnchorPoint(ccp(1, 1))
		qr:setPositionXY(size.width - 10, -10)
		group:addChildAt(qr, group:getChildIndex(bg))

		group:setPositionY(size.height)

		local filePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
		-- if _G.isLocalDevelopMode then printx(0, filePath) end
		local renderTexture = CCRenderTexture:create(size.width, size.height)
		renderTexture:begin()
		group:visit()
		renderTexture:endToLua()
		renderTexture:saveToFile(filePath)
		imagePath = filePath
	end
	return imagePath
end

function WeeklyShareUtil.buildShareImageWinter(group)
	assert(group, "group must not be nil")
	local imagePath = nil
	if group then 
		local bg_2d = Sprite:create("share/weekly_share_bg_2.png")
		bg_2d:setAnchorPoint(ccp(0, 1))
		local bg = group:getChildByName("bg")
		bg:setVisible(false)
		local size = bg:getGroupBounds().size
		local bSize = bg_2d:getGroupBounds().size
		bg_2d:setScaleX(size.width / bSize.width)
		bg_2d:setScaleY(size.height / bSize.height)
		group:addChildAt(bg_2d, group:getChildIndex(bg))

		local qr = Sprite:create(ShareUtil:getQRCodePath())
		qr:setAnchorPoint(ccp(0.5, 0.5))
		local qrBg = group:getChildByName("2d_bg")
		qrBg:setVisible(false)

		local rotation = qrBg:getRotation()

		local qrBGsize = qrBg:getContentSize()
		local qrPos = qrBg:convertToWorldSpace(ccp(qrBGsize.width/2, qrBGsize.height/2))
		qrPos = group:convertToNodeSpace(qrPos)

		qr:setScale(1.07)
		qr:setPositionXY(qrPos.x, qrPos.y)
		qr:setRotation(rotation)
		group:addChildAt(qr, group:getChildIndex(bg))

		group:setPositionY(size.height)

		local filePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
		-- if _G.isLocalDevelopMode then printx(0, filePath) end
		local renderTexture = CCRenderTexture:create(size.width, size.height)
		renderTexture:begin()
		group:visit()
		renderTexture:endToLua()
		renderTexture:saveToFile(filePath)
		imagePath = filePath
	end
	return imagePath
end
AnimationNumberText = class(Layer)

function AnimationNumberText:ctor()
	self.nodeType = kCocosObjectType.kLayer;
	self.isLayerInitialized = false;
	self.refCocosObj = nil;
    self.touchEnabled = false
    self.buttomMode = false

    self.className = "AnimationNumberText"
end

function AnimationNumberText:create(num , animeType)
  local layer = AnimationNumberText.new()
  layer:initLayer()
  layer:initByNumber(num , animeType)
  return layer
end

function AnimationNumberText:initLayer()

	Layer.initLayer(self)
    self.className = "AnimationNumberText"
end

function AnimationNumberText:initByNumber(num , animeType)

	self.currNum = num
	local currNumText = BitmapText:create( tostring(num) , "fnt/friends_list.fnt")
    self:addChild(currNumText)

    self.currNumText = currNumText


    local tarNumText = BitmapText:create( tostring(0) , "fnt/friends_list.fnt")
    self:addChild(tarNumText)

    self.tarNumText = tarNumText
    self.tarNumText:setOpacity(0)
end

function AnimationNumberText:setNumber(num)

	if self.isfadeOut then return end

	self.currNumText:stopAllActions()
	self.tarNumText:stopAllActions()
	self.currNumText:setText(tostring(self.currNum))
	self.tarNumText:setText(tostring(self.currNum))
	self.currNumText:setOpacity(255)
	self.tarNumText:setOpacity(0)

	if num ~= self.currNum then
		self.currNum = num

		local actArr1 = CCArray:create()
		actArr1:addObject( CCScaleTo:create( 0.1 , 1.2 ) )
		actArr1:addObject( CCSequence:createWithTwoActions(  CCFadeTo:create( 0.1 , 0 ) , CCScaleTo:create( 0.1 , 1 ) )   )

		--self.currNumText:runAction( CCFadeTo:create( 0.2 , 0 ) )
		self.currNumText:runAction( CCSequence:create(actArr1) )

		self.tarNumText:setText(tostring(self.currNum))
		self.tarNumText:setScale(0.8)

		local actArr2 = CCArray:create()
		actArr2:addObject( CCSequence:createWithTwoActions( CCFadeTo:create( 0.15 , 255 ) , CCScaleTo:create( 0.15 , 1 ) )  )
		actArr2:addObject( CCCallFunc:create( function ()  

				self.currNumText:stopAllActions()
				self.currNumText:setText(tostring(self.currNum))
				self.currNumText:setOpacity(255)

				self.tarNumText:stopAllActions()
				self.tarNumText:setText(tostring(self.currNum))
				self.tarNumText:setOpacity(0)

			end ) )

		self.tarNumText:runAction( CCSequence:create(actArr2) )
	else
		self.currNum = num
		self.currNumText:setText(tostring(self.currNum))
		self.tarNumText:setText(tostring(self.currNum))
		self.currNumText:setOpacity(255)
		self.tarNumText:setOpacity(0)
	end
	
end

function AnimationNumberText:getNumber(num)
	return self.currNum
end

function AnimationNumberText:fadeOut()
	self.currNumText:stopAllActions()
	self.tarNumText:stopAllActions()
	self.currNumText:runAction(CCFadeOut:create(0.35))
	self.tarNumText:runAction(CCFadeOut:create(0.35))
	self.isfadeOut = true
end
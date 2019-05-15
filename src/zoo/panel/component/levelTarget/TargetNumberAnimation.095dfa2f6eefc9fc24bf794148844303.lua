require "zoo.gamePlay.GameItemOrderData"
local UIHelper = require 'zoo.panel.UIHelper'

TargetNumberAnimation = {}

TargetNumberAnimation["order5"] = {}
TargetNumberAnimation["order5"][GameItemOrderType_Others.kBiscuit] = function ( ... )
	local anim = UIHelper:createArmature2('skeleton/biscuit-sk', 'biscuit-sk/apper')

	function anim:playAppearAnim( callback )
		if callback then
			anim:ad(ArmatureEvents.COMPLETE, callback)
		end
		anim:playByIndex(0, 1)
	end

	function anim:playScaleAnim( callback )
		anim:runAction(CCScaleTo:create(0.5, 0.4, 0.4))
	end

	function anim:getStandardScale( ... )
		return 0.4
	end

	

	return anim
end
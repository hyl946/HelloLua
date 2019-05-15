
local UIHelper = require 'zoo.panel.UIHelper'
local CacheIO = require 'zoo.localActivity.FindingTheWay.CacheIO'

local AliQuickPushLogic = class(BasePanel)

function AliQuickPushLogic:reset()
    
end

function AliQuickPushLogic:resetCD( ... )
	CacheIO.new('ali.quick.push'):set('last-popout-ts', Localhost:time())
end

function AliQuickPushLogic:tryPopout( ... )
	if (not __ANDROID) and (not __WIN32) then return end

	if UserManager:getInstance():isAliSigned() then
		return
	end

	local now = Localhost:time()
	local last = CacheIO.new('ali.quick.push'):get('last-popout-ts') or 0
	now = tonumber(now)
	last = tonumber(last)

	now = time2day(now/1000)
	last = time2day(last/1000)

	if now - last >= 14 or __WIN32 then
		_G.StoreTip:popAliQuickPush{
			onConfirm = function ( ... )
				local function onSignCallback(ret, data)
					local scene = Director:sharedDirector():run()
					if scene then
						scene:runAction(CCCallFunc:create(function ( ... )
		                	if ret == AlipaySignRet.Success then
		                		CommonTip:showTip(localize('ali.quick.sign.success'), 'positive')
			                elseif ret == AlipaySignRet.Cancel then
		                		CommonTip:showTip(localize'ali.quick.sign.cancel')
			                elseif ret == AlipaySignRet.Fail then
		                		CommonTip:showTip(localize'ali.quick.sign.fail')
			                end
						end))
					end
	            end
            	AlipaySignLogic.getInstance():startSign(AliQuickSignEntranceEnum.MARKET_PANEL, onSignCallback)
            	DcUtil:UserTrack({category='new_store', sub_category='easy_pay_recommend', type = 1})
			end,
			onCancel = function ( ... )
            	DcUtil:UserTrack({category='new_store', sub_category='easy_pay_recommend', type = 2})
			end
		}	


		self:resetCD()
	end
end

return AliQuickPushLogic

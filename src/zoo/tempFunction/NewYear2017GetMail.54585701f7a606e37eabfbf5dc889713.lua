local NewYear2017GetMail = class()
local NewYear2017Cfg = require "zoo.tempFunction.NewYear2017Config"
			
function NewYear2017GetMail:create()
	local obj = NewYear2017GetMail.new()
	obj:resetData()
	return obj
end

function NewYear2017GetMail:resetData()
	self.getMailInfo = nil
	self.playEndCallBack = nil
end

function NewYear2017GetMail:checkGetMail()
	if not NewYear2017Cfg.isOpen() then return end
	
	local function onSuccess(evt)
		if evt ~= nil and evt.data ~= nil and evt.data.cardId ~= nil and evt.data.cardId > 0 and NewYear2017Cfg.isOpen() then
			local GetMailAnim = require "zoo.tempFunction.NewYear2017GetMailAnim"
			GetMailAnim:create()
			local dcData = {game_type="share", game_name="newyear_2017", category="get", sub_category="newyear_get_card"}
			dcData["t" .. (evt.data.cardId % 10)] = 1
			DcUtil:activity(dcData)
			-- if _G.isLocalDevelopMode then printx(0, "aaa-----------------------", table.tostring(dcData)) end
		end
	end

	local function onFail()
	end

	local function onCancel()
	end

	local http = GetNewYear2017CardHttp.new(false)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:setCancelCallback(onCancel)
	http:syncLoad()
end

return NewYear2017GetMail
local AskForHelpSNS = class()

function AskForHelpSNS:onWXFriend()
	CommonTip:showTip("onWXFriend:请选择至少一名好友", "negative")
end

function AskForHelpSNS:onWXCircle()
	CommonTip:showTip("onWXCircle:请选择至少一名好友", "negative")
end

return AskForHelpSNS
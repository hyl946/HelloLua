local OpenWeekMainPanel = {}


function OpenWeekMainPanel.canPop(pasteStr, cb )
	
	if cb then
		cb(string.starts(pasteStr, '打开周赛'))
	end
end

function OpenWeekMainPanel.popout(pasteStr, closeCallback )
	RankRaceMgr:getInstance():openMainPanel(false, nil, closeCallback, closeCallback)
end

return OpenWeekMainPanel
require "zoo.common.FAQ"
require "zoo.panel.CommonTip"
require "zoo.panel.AnnouncementPanel"

AnnouncementPopoutAction = class(HomeScenePopoutAction)

function AnnouncementPopoutAction:ctor(url)
	self.name = "AnnouncementPopoutAction"
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function AnnouncementPopoutAction:checkCanPop()
	local userTopLevel = UserManager:getInstance().user:getTopLevelId()
	
	if userTopLevel > 1 then
		AnnoucementMgr.getInstance():loadAnnouncement(AnnouncementPosType.kHome,function( xml )
	        if not xml then
	     		self:onCheckPopResult(false)
	            return 
	        end
	        local announcements = AnnoucementMgr.getInstance():parseAnnouncement(xml)
	        if table.size(announcements) <= 0 then 
	            self:onCheckPopResult(false)
	            return
	        end
	        self.announcements = announcements
	        self:onCheckPopResult(true)
	    end)
	else
		self:onCheckPopResult(false)
	end
end

function AnnouncementPopoutAction:popout( next_action )
	if self.announcements then
    	AnnouncementPanel:create(AnnouncementPosType.kHome, self.announcements):popout(next_action)
    else
    	next_action()
    end
end
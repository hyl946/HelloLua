local ActivityCenterItemLoadingPanel = class(ActivityCenterItemPanel)

function ActivityCenterItemLoadingPanel:create( itemData )
	local panel = ActivityCenterItemLoadingPanel.new()
	panel:initLayer()
	panel:init(itemData)
	return panel
end

function ActivityCenterItemLoadingPanel:init( itemData )
	ActivityCenterItemPanel.init(self, itemData)

	local clock = gAnimatedObject:createWithFilename("gaf/act_center_clock/act_center_clock.gaf")
	clock:setPosition(ccp(40, -100))
	clock:setLooped(true)
	self.ui:addChild(clock)

	clock:start()

 	local text = BitmapText:create("正在加载中", "fnt/actioncenter.fnt")
    text:setPreferredSize(159, 80)
    text:setAnchorPoint(ccp(0,0.5))
    text:setPositionXY(190, -442)

    self.progress = text
    self.ui:addChild(text)

    self:setProgress(0)
end

function ActivityCenterItemLoadingPanel:setProgress( progress )
	local p = progress or 0
	if p <= 0.01 then p = 0.01 end
	if p >= 1.0 then p = 0.99 end

	self.progress:setText(string.format("加载中%d%%", p * 100))
end

return ActivityCenterItemLoadingPanel
local AnimationPlayer = class(CocosObject)

function AnimationPlayer:create( ... )
	local instance = AnimationPlayer.new()
	return instance
end

function AnimationPlayer:ctor( ... )
	self.target = nil
	self.tracks_grp = {}
	self.tracks_num = 0
	self.clock = 0
	self.updateEntryId = nil
	self.fps = 30 
	self.loop = false
	self:setRefCocosObj(CCNode:create())
end

function AnimationPlayer:setTarget( p_target )
	self.target = p_target
end

function AnimationPlayer:getTarget( ... )
	return self.target
end

function AnimationPlayer:addTrack( p_track )
	local track_name = p_track:getName()
	if not self.tracks_grp[track_name] then
		self.tracks_grp[track_name] = p_track
		self.tracks_num = self.tracks_num + 1
		return true
	else
		return false
	end
end

function AnimationPlayer:removeTrack( p_track )
	self:removeTrackByName(p_track:getName())
end

function AnimationPlayer:removeTrackByName( p_track_name )
	if self.tracks_grp[p_track_name] then 
		self.tracks_grp[p_track_name] = nil
		self.tracks_num = self.tracks_num - 1
	end
end

function AnimationPlayer:reset( ... )
	self.clock = 0

	for _, track in pairs(self.tracks_grp) do
		track:setTarget(self.target:getChildByPath(track:getTargetPath()))
	end
end

function AnimationPlayer:preStart( dt )
	self:reset()
	self:update(dt)
end

function AnimationPlayer:start( ... )
	self:reset()
	self:resume()
end

function AnimationPlayer:setLoop( p_loop )
	self.loop = p_loop
end

function AnimationPlayer:stop( ... )
	self:pause()
	-- self:reset()
end

function AnimationPlayer:pause( ... )
	self:unregisterUpdate()
end

function AnimationPlayer:resume( ... )
	self:registerUpdate()
end

function AnimationPlayer:update( dt )
	self.clock = self.clock + math.min(dt, 1/self.fps)
	local finish_counter = 0
	local frameIndex = math.floor(self.clock * self.fps + 0.5)
	for _, track in pairs(self.tracks_grp) do
		if track:update(frameIndex) then
			finish_counter = finish_counter + 1
		end
	end

	if finish_counter >= self.tracks_num and self.loop then
		self:stop()
		self:start()
	end
end

function AnimationPlayer:registerUpdate( ... )
	if not self.updateEntryId then
		self.updateEntryId = Director:sharedDirector():getScheduler():scheduleScriptFunc(function ( dt )
			self:update(dt)
		end, false)
	end
end

function AnimationPlayer:unregisterUpdate( ... )
	if self.updateEntryId then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateEntryId)
		self.updateEntryId = nil
	end
end

function AnimationPlayer:dispose( ... )
	self:stop()
	CocosObject.dispose(self, ...)
end

return AnimationPlayer
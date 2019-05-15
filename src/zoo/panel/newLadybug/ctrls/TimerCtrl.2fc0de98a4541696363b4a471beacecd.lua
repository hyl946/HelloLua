local TimerCtrl = class()

function TimerCtrl:ctor( text )
	self.text = text
	self.text:changeFntFile('fnt/level_seq_n_energy_cd.fnt')
	self.text:setScale(1.3)

end

function TimerCtrl:setTime(time)
	if (not self.text) or self.text.isDisposed then return end
	
	self.text:setText(os.date('%H:%M:%S', math.floor(time/1000) + 16*3600))
end

function TimerCtrl:hide( ... )
	self.text:setText('')
end

return TimerCtrl
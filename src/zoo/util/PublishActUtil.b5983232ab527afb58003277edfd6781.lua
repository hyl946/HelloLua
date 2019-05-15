PublishActUtil = {}

function PublishActUtil:isGroundPublish()
	return false
end

function PublishActUtil:getTempPropTable()
	return {{proId = 10015},{proId = 10016},{proId = 10017},{proId = 10019},{proId = 10024},{proId = 10007}}
end

function PublishActUtil:getTempSelectedPropTable()
	return {{id=10015},{id=10016},{id=10017},{id=10024},{id=10019},{id=10007}}
end

function PublishActUtil:getTempPropNum()
	return 5
end

function PublishActUtil:getLevelId()
	return 9999
end
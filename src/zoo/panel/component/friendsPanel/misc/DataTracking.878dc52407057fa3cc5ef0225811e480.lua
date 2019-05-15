
local DataTracking = {}

function DataTracking:sendEnergy(isSuccess)
    local dcData = {}
    dcData.category = "add_friend"
    dcData.sub_category = "send_energy"
    dcData.t1 = 0
    if isSuccess then
        dcData.t1 = 1
    end
    DcUtil:log(AcType.kUserTrack, dcData, true)
end

function DataTracking:delFriend(isSuccess)
    local dcData = {}
    dcData.category = "add_friend"
    dcData.sub_category = "delete"
    dcData.t1 = 0
    if isSuccess then
        dcData.t1 = 1
    end
    DcUtil:log(AcType.kUserTrack, dcData, true)
end

function DataTracking:copyId()
    local dcData = {}
    dcData.category = "add_friend"
    dcData.sub_category = "copyID"
    DcUtil:log(AcType.kUserTrack, dcData, true)
end

function DataTracking:addFriendByXXLId()
    local dcData = {}
    dcData.category = "add_friend"
    dcData.sub_category = "addID"
    DcUtil:log(AcType.kUserTrack, dcData, true)
end

function DataTracking:sendRequest2PhoneFriends()
    local dcData = {}
    dcData.category = "add_friend"
    dcData.sub_category = "add_phone_send"
    DcUtil:log(AcType.kUserTrack, dcData, true)
end

function DataTracking:refreshRecommend()
    local dcData = {}
    dcData.category = "add_friend"
    dcData.sub_category = "add_recommand_re"
    DcUtil:log(AcType.kUserTrack, dcData, true)
end

function DataTracking:requestByRecommend(num)
    local dcData = {}
    dcData.category = "add_friend"
    dcData.sub_category = "add_recommand_send"
    dcData.t1 = num or 0
    DcUtil:log(AcType.kUserTrack, dcData, true)
end

return DataTracking
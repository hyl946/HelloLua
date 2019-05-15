return {
	canPop = function ( pasteS, cb )
		require "zoo.PersonalCenter.AutoAddFriendManager"
		return AutoAddFriendManager:canPop( pasteS, cb)
	end,

	popout = function ( pasteSZ, closeCallback )
		return AutoAddFriendManager.getInstance():autoAddCheck(pasteSZ, closeCallback)
	end,
}
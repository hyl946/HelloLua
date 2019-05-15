--[[
	
####################################################################################################
#####################################################LLLLjj#########################################
##################################################iiiiLLLLLLj#######################################
################################################ft  ttLLLLLLLj######################################
###############################################LttttGGGGLLLLLff#####################################
###############################################jjjjGGGGGGGGGGff#####################################
##############################################DjjjDDDGGGGGGGfff#####################################
##############################################GffDDDDDDDDDDLLL######################################
##############################################EGGEEEDDDDDLLL########################################
##############################################EGGEEEEEEGG###########################################
############################################,.:DDEEEEDG::,##########################################
#########################################,.:::::EEEED.::::::########################################
#######################################:.::::::::EEE.:::::::::######################################
#####################################.::::::::::::;:::::::::::::####################################
###################################.:::::::. ::::::::::::::::::::,##################################
#################################:::,:::     ::::::::::::::::::::::#################################
###############################:::,,,,      :::::::::::::::::::,,,,::###############################
#############################,.:,,,,       ::::::::::::::::,,,,,,,,,::,#############################
############################.::,,,       :::::::::::::::::::,,,,,,,,,,::############################
##########################,::,,,,       :::::::::::::::::::::,,,,,,,,,,::###########################
#########################.:,,,,....   :::::::::::::::::::::::::,,,,,,,,,::,#########################
#######################,::,,,........:::::::::::::::::::::::::::,,,,,,,,,,::########################
######################.:,;,,::::...::::::::::::::::::::::::::::::,,,,,,,,,,,:#######################
####################,:,;;;:::::...:::::::::::::::::::::::::::::::::,,,,,,,;;,:,#####################
###################.,,;;;,,,,:::iiiii:::::::::::::::::::::::::iiii,:;;;;;;;;;,,,####################
##################:,,;;,,,,,,::::::::::::::::::::::::::::::::::::::::;;;;;;;;;,,,###################
################,,,;;;;;;,,,:,,:::::::::::::::::::::::::::::::::::::::;;;;;;;;;,,,##################
###############:,,;;;;;;;;;:ffEDDDff::::::::::::::::::::::::::::ffEEDDff;;;;;;;;,,,#################
##############:;,;;;;;;;;;ff   ###GGf,,,,,:::::::ii::::::::::,,f   ###GGff;;;;;;;;,,,###############
#############:;;ii;i;;;;;,fED######GLf,,,,,,,,,i;;,ii,,,,,,,,,fED######GLf;;;;;;;;;,,,##############
############,;;iiiiiiiii,,fDD#####jLLf,,,,,,,t;;,,,tttt,,,,,,,fDD#####KLLf;;;;;;ii;;;;,#############
##########,;;;iiiiiiiii;;;;fGGG##LLLf,,,,,,j;,,,,..ttttt,,,,,,,fGGG##LLLf;,iiiiiiiii;;;;############
#########,;;;iiiiiiiiii;;;;;fffLLfff,,,,,,jjj,,,,  jjjjjji,,,,,,ffLLLLff;;;;iiiiiiiii;;;;###########
########,;;;iiiiiiiitiiiiii;;;;;,,,,,,,,,,;ffDDDDDDDDDLjj,,,,,,,;;;;;;;;;;;;;iiiiiiiii;;;;##########
########,i;iiiiiiiiitiiiiiii;;;;;;;;;;,,,,,fftttttttttfff,,,,,;;;;;iiiiiiiii;iiiiiiiii;;;;,#########
#######:iiiiiiiiiiiiiiiiii;;;;;;;;;;;;;;;;;;ffftiiiiffff;;;;;;;;;;;iiiiiiiii;;iiiiiiiii;;;i#########
#######;iiiiiiiiiiiii;;;;;;;;;;;;;;;;;;;;;;;;tttttttttt;;;;;;;;;;;;;;;iiiii;;;;iiiiiiii;;;,i########
######,iiiiiiiiiiiii;;;;;;;;;;;;;;;;;;;;;;;;;;iiiiiiii;;;;;;;;;;;;;;;;;;;;;;;;;iiiiiiii;;;,i########
######,iiiiiiiiiiiiiiii;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;iiiiiiii;;;,,########
#######iiiiiiiiiiiiiiiiiiiii;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;iiiiiiiiiiiii;;;,,########
#######iiittiiiiiiiiiiiiiiiiiiiiiiii;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;iiiiiiiiiiiiiiiiiii;;;,,,########
########iiittttttttiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii;;;,,,,########
#########iiittttttttttttiiittttiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii;;;,,,,#########
###########iiitttttttttttttttttttttttttttiiiiiittttiiiiiiiiiiiiiiiittttttttttiiiiii;;;,,,###########
#############,tiiittttttttttttttttttttttttttttttttiittttttttttttttttttttttiiiiii;;;;;,;#############
##################;tiiiiittttttttttttttttttttttttttttttttttttttttttttiiiiiiii;;;;;;#################
##########################,,;itttttiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii;,,#########################
####################################################################################################
####################################################################################################

]]

GameInitDiffChangeLogicPatternConfig = {
	
	mode1 = { -- 4 直线
		[1] = {
			--[[
				B
				AB
				B
				B
			]]

			[1] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=5 , ct=2 , itemB=true },
		} ,

		[2] = {
			--[[
				B
				B
				AB
				B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=5 , ct=2 , itemB=true },
		} ,

		[3] = {
			--[[
				 A
				AB
				 A
				 A
			]]

			[1] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[2] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[3] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[4] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,

		[4] = {
			--[[
				 A
				 A
				AB
				 A
			]]

			[1] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[2] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[4] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[5] = {
			--[[
				  A
				 ABAA
			]]

			[1] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[3] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[4] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[6] = {
			--[[
				   A
				 AABA
			]]

			[1] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[4] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[7] = {
			--[[
				 BABB
				  B
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=true },
		} ,

		[8] = {
			--[[
				 BBAB
				   B
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=true },
		} ,
	} ,

	mode2 = { -- 4 爆炸

		[1] = {
			--[[
				 A
				ABA
				 A
				 A
			]]

			[1] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[3] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[4] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[2] = {
			--[[
				 B
				 B
				BAB
				 B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
		} ,

		[3] = {
			--[[
				A
				BAA
				A
				A
			]]

			[1] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[2] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[3] = { dr=5 , dc=6 , ct=1 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[5] = { dr=7 , dc=4 , ct=1 , itemB=false },
		} ,

		[4] = {
			--[[
				  A
				AAB
				  A
				  A
			]]

			[1] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[4] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[5] = { dr=7 , dc=4 , ct=1 , itemB=false },
		} ,

		[5] = {
			--[[
				ABAA
				 A
				 A
			]]

			[1] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[2] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=7 , ct=1 , itemB=false },
			[4] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,

		[6] = {
			--[[
				BBAB
				  B
				  B
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[5] = { dr=6 , dc=4 , ct=2 , itemB=false },
		} ,

		[7] = {
			--[[
				  B
				  B
				BBA
				  B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
		} ,

		[8] = {
			--[[
				B
				B
				ABB
				B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
		} ,

		[9] = {
			--[[
				  B
				  B
				BBAB
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=true },
		} ,

		[10] = {
			--[[
				 A
				 A
				ABAA
			]]

			[1] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[2] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[4] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[5] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[11] = {
			--[[
				 A
				ABAA
				 A
			]]

			[1] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[2] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[3] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[4] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[5] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[12] = {
			--[[
				  B
				BBAB
				  B
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=true },
		} ,
	} ,

	mode3 = { -- 4+4 直线+直线
		[1] = {
			--[[
				BA
				BA
				AB
				BA
			]]
			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[2] = {
			--[[
				BABB
				ABAA
			]]
			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[3] = {
			--[[
				B
				BA
				AB
				BA
				 A
			]]
			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,
		
		[4] = {
			--[[
				 A
				BA
				AB
				BA
				B
			]]

			[1] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[5] = {
			--[[
				 BBAB
				  ABAA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[6] = {
			--[[
				  BABB
				 AABA
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[6] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,
	} ,

	mode4 = { -- 4+4 直线+爆炸

		[1] = {
			--[[
				B
				BA
				ABAA
				BA
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,
		
		[2] = {
			--[[
				BA
				ABAA
				BA
				B
			]]

			[1] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[3] = {
			--[[
				  BA
				BBAB
				  BA
				   A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,

		[4] = {
			--[[
				   A
				  BA
				BBAB
				  BA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[5] = {
			--[[
				BA
				BA
				ABAA
				B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[6] = {
			--[[
				B
				B
				ABAA
				BA
				 A
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[5] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=6 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[7] = {
			--[[
				 A
				BA
				ABAA
				B
				B
			]]

			[1] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[8] = {
			--[[
				B
				ABAA
				BA
				BA
			]]

			[1] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[5] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=6 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[9] = {
			--[[
				   A
				BBAB
				  BA
				  BA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,

		[10] = {
			--[[
				  B
				  BA
				BBAB
				   A
				   A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,

		[11] = {
			--[[
				  BA
				  BA
				BBAB
				   A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[12] = {
			--[[
				   A
				   A
				BBAB
				  BA
				  B
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[13] = {
			--[[
				BBAB
				 ABA
				  A
				  A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[5] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[6] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[14] = {
			--[[
				BABB
				ABA
				 A
				 A
			]]

			[1] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[5] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[6] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[15] = {
			--[[
				 B
				 B
				BAB
				ABAA
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[16] = {
			--[[
				  B
				  B
				 BAB
				AABA
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=2 , ct=1 , itemB=false },
		} ,

		[17] = {
			--[[
				BBAB
				AAB
				  A
				  A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=5 , ct=2 , itemB=false },
		} ,

		[18] = {
			--[[
				BBAB
				  BAA
				  A
				  A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[4] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[5] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[19] = {
			--[[
				BABB
				 BAA
				 A
				 A
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[3] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[4] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[8] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[20] = {
			--[[
				 BABB
				AAB
				  A
				  A
			]]

			[1] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[5] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[6] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=2 , itemB=false },
		} ,

		[21] = {
			--[[
				 B
				 B
				 ABB
				ABAA
			]]

			[1] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[2] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[8] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[22] = {
			--[[
				  B
				  B
				BBA
				 ABAA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[4] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[6] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[23] = {
			--[[
				  B
				  B
				BBA
				AABA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[4] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[6] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=2 , ct=1 , itemB=false },
		} ,

		[24] = {
			--[[
				  B
				  B
				  ABB
				AABA
			]]

			[1] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=2 , itemB=false },
		} ,
	} ,


	mode5 = { -- 5 魔力鸟

		[1] = {
			--[[
				BBABB
				  B
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[4] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[5] = { dr=4 , dc=6 , ct=2 , itemB=false },
		} ,

		[2] = {
			--[[
				  A
				AABAA
			]]

			[1] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[4] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,
		
		[3] = {
			--[[
				B
				B
				AB
				B
				B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=6 , dc=4 , ct=2 , itemB=false },
		} ,

		[4] = {
			--[[
				 A
				 A
				AB
				 A
				 A
			]]

			[1] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[2] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[4] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,
	} ,

	mode6 = { -- 4+4 爆炸+爆炸

		[1] = {
			--[[
				 B
				 B
				BAB
				ABA
				 A
				 A
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[9] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[2] = {
			--[[
				 B
				 B
				 ABB
				ABA
				 A
				 A
			]]

			[1] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[9] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[3] = {
			--[[
				  B
				  B
				BBA
				 ABA
				  A
				  A
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[9] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[4] = {
			--[[
				 B
				 B
				BAB
				 BAA
				 A
				 A
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=6 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[9] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[5] = {
			--[[
				  B
				  B
				 BAB
				AAB
				  A
				  A 
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[9] = { dr=5 , dc=2 , ct=1 , itemB=false },
		} ,

		[6] = {
			--[[
				  B
				  B
				BBA
				AAB
				  A
				  A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[5] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[6] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[7] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[8] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[9] = { dr=7 , dc=4 , ct=1 , itemB=false },
		} ,

		[7] = {
			--[[
				B
				B
				ABB
				BAA
				A
				A
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[4] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[5] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[9] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[8] = {
			--[[
				  B
				  B
				BBA
				  BAA
				  A
				  A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[9] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[9] = {
			--[[
			      B
				  B
				  ABB
				AAB
				  A
				  A
			]]

			[1] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[2] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[9] = { dr=4 , dc=6 , ct=2 , itemB=false },
		} ,

		[10] = {
			--[[
			      BA
			    BBABAA
			      BA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[11] = {
			--[[
				  B
			      BA
			    BBABAA
			       A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[12] = {
			--[[
			       A
			    BBABAA
			      BA
			      B
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[13] = {
			--[[
				   A
			      BA
			    BBABAA
			      B
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[14] = {
			--[[
			      B
			    BBABAA
			      BA
			       A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=6 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[15] = {
			--[[
			      BA
			      BA
			    BBABAA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[16] = {
			--[[
			    BBABAA
			      BA
			      BA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=6 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[17] = {
			--[[
			      B
			      B
			    BBABAA
			       A
			       A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[6] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=6 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[18] = {
			--[[
			       A
			       A
			    BBABAA
			      B
			      B
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

	} ,

	mode7 = { -- 5+4 魔力鸟+直线
		[1] = {
			--[[
			    BBABB
			    AABA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[6] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[7] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[2] = {
			--[[
			    BBABB
			     ABAA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[6] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[3] = {
			--[[
				BBAB
				AABAA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[6] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,
		
		[4] = {
			--[[
				 BABB
				AABAA
			]]

			[1] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[6] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[5] = {
			--[[
				B
				BA
				AB
				BA
				BA
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,
		
		[6] = {
			--[[
				BA
				BA
				AB
				BA
				B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
		} ,

		[7] = {
			--[[
				 A
				BA
				AB
				BA
				BA
			]]

			[1] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,
		
		[8] = {
			--[[
				BA
				BA
				AB
				BA
				 A
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,
	} ,

	mode8 = { -- 5+4 魔力鸟+爆炸
		[1] = {
			--[[
				BBABB
				 ABA
				  A
				  A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[6] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[9] = { dr=7 , dc=4 , ct=1 , itemB=false },
		} ,

		[2] = {
			--[[
				  B
				  B
				 BAB
				AABAA
			]]

			[1] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[4] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[6] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[9] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[3] = {
			--[[
				BBABB
				AAB
				  A
				  A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[9] = { dr=4 , dc=6 , ct=2 , itemB=false },
		} ,

		[4] = {
			--[[
				BBABB
				  BAA
				  A
				  A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=6 , ct=1 , itemB=false },
			[5] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[6] = { dr=6 , dc=4 , ct=1 , itemB=false },
			[7] = { dr=7 , dc=4 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[9] = { dr=4 , dc=6 , ct=2 , itemB=false },
		} ,

		[5] = {
			--[[
				  B
				  B
				BBA
				AABAA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[5] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[6] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[7] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[9] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[6] = {
			--[[
				  B
				  B
				  ABB
				AABAA
			]]

			[1] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[2] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[3] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[4] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[5] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[6] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[7] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[9] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,

		[7] = {
			--[[
				B
				BA
				ABAA
				BA
				B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[8] = {
			--[[
				   A
				  BA
				BBAB
				  BA
				   A
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=3 , dc=3 , ct=1 , itemB=false },
			[6] = { dr=4 , dc=3 , ct=2 , itemB=true },
			[7] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[8] = { dr=4 , dc=2 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=1 , ct=1 , itemB=false },
		} ,

		[9] = {
			--[[
				BA
				BA
				ABAA
				B
				B
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[10] = {
			--[[
				B
				B
				ABAA
				BA
				BA
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=6 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=4 , dc=6 , ct=1 , itemB=false },
			[9] = { dr=4 , dc=7 , ct=1 , itemB=false },
		} ,

		[11] = {
			--[[
				  BA
				  BA
				BBAB
				   A
				   A
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[9] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,

		[12] = {
			--[[
				   A
				   A
				BBAB
				  BA
				  BA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[9] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,
	} ,
	
	mode9 = { -- 5+5 魔力鸟+魔力鸟

		[1] = {
			--[[
				BBABB
				AABAA
			]]

			[1] = { dr=4 , dc=2 , ct=2 , itemB=false },
			[2] = { dr=4 , dc=3 , ct=2 , itemB=false },
			[3] = { dr=4 , dc=5 , ct=2 , itemB=false },
			[4] = { dr=4 , dc=6 , ct=2 , itemB=false },
			[5] = { dr=5 , dc=2 , ct=1 , itemB=false },
			[6] = { dr=5 , dc=3 , ct=1 , itemB=false },
			[7] = { dr=5 , dc=4 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[9] = { dr=5 , dc=6 , ct=1 , itemB=false },
		} ,
		[2] = {
			--[[
				BA
				BA
				AB
				BA
				BA
			]]

			[1] = { dr=2 , dc=4 , ct=2 , itemB=false },
			[2] = { dr=3 , dc=4 , ct=2 , itemB=false },
			[3] = { dr=5 , dc=4 , ct=2 , itemB=false },
			[4] = { dr=6 , dc=4 , ct=2 , itemB=false },
			[5] = { dr=2 , dc=5 , ct=1 , itemB=false },
			[6] = { dr=3 , dc=5 , ct=1 , itemB=false },
			[7] = { dr=4 , dc=5 , ct=2 , itemB=true },
			[8] = { dr=5 , dc=5 , ct=1 , itemB=false },
			[9] = { dr=6 , dc=5 , ct=1 , itemB=false },
		} ,
	
	} ,

}
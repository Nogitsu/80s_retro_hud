local to_hide = {
	["CHudHealth"] = true,
}

HUD80s.CreateFonts( { 30, 40 } )

--	> Override murder's fonts
surface.CreateFont( "MersText1" , {
	font = "Lazer84",
	size = 16,
	weight = 1000,
	antialias = true,
	italic = false
})

surface.CreateFont( "MersHead1" , {
	font = "VCR OSD Mono",
	size = 24,
	weight = 500,
	antialias = true,
	italic = false
})

local baseSize = ScrH() / 23
surface.CreateFont( "MersRadial" , {
	font = "VCR OSD Mono",
	size = math.ceil(baseSize),
	weight = 500,
	antialias = true,
	italic = false
})

surface.CreateFont( "MersRadialBig" , {
	font = "VCR OSD Mono",
	size = math.ceil(baseSize * 1.41),
	weight = 500,
	antialias = true,
	italic = false
})

surface.CreateFont( "MersRadialSmall" , {
	font = "VCR OSD Mono",
	size = math.ceil(baseSize * .56),
	weight = 100,
	antialias = true,
	italic = false
})

surface.CreateFont( "MersDeathBig" , {
	font = "VCR OSD Mono",
	size = math.ceil(baseSize * 1.5),
	weight = 500,
	antialias = true,
	italic = false
})

local gm = gmod.GetGamemode()

local tex = surface.GetTextureID( "SGM/playercircle" )
local gradR = surface.GetTextureID( "gui/gradient" )

local function colorDif(col1, col2)
	local x = col1.x - col2.x
	local y = col1.y - col2.y
	local z = col1.z - col2.z
	x = x > 0 and x or -x
	y = y > 0 and y or -y
	z = z > 0 and z or -z
	return x + y + z
end

--  > Main HUD draw function
function gm:HUDPaint()
    local w, h = ScrW(), ScrH()
	local round = self:GetRound()
	local ply = LocalPlayer()

    if round == 0 then
        HUD80s.DrawText( translate.minimumPlayers, "MersRadial", w / 2, h - 10, HUD80s.Pink, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	elseif round == 5 then
		if self.StartNewRoundTime then
			local seconds = math.ceil( self.StartNewRoundTime - CurTime() )
			if seconds <= 0 then 
				seconds = 0
			end
            HUD80s.DrawText( Translator:QuickVar( translate.roundStartsInTime, "seconds", tostring( seconds ) ), "MersRadial", w / 2, h - 10, HUD80s.Pink,TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		else
            HUD80s.DrawText( translate.waitingToStart, "MersRadial", w / 2, h - 10, HUD80s.Pink,TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
		end
	end

	if ply:Team() == 2 then
		if not ply:Alive() then
			self:RenderRespawnText()
		else

			if round == 1 then
				if self.RoundStart and self.RoundStart + 10 > CurTime() then
					self:DrawStartRoundInformation()
				else
					self:DrawGameHUD( LocalPlayer() )
				end
			elseif round == 2 then
				self:DrawGameHUD( LocalPlayer() )
			end
		end
	else
		self:RenderSpectate()
	end

	self:DrawRadialMenu()
	self:DrawSpawnsVisualise()
end

--  > Spectating
function gm:RenderSpectate() -- based on the murder's code
    local w, h = ScrW(), ScrH()
    local font_h = draw.GetFontHeight( "MersRadial" )

    if not self:IsCSpectating() then return end
    
    HUD80s.DrawText( translate.spectating, "MersRadial", w / 2, h - 30 - font_h, HUD80s.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 2 )

	if not ( IsValid( self:GetCSpectatee() ) and self:GetCSpectatee():IsPlayer() ) then return end
	

	if IsValid( LocalPlayer() ) and LocalPlayer():IsAdmin() then
        HUD80s.DrawText( self:GetCSpectatee():Nick(), "MersRadial", w / 2, h - 10, HUD80s.Pink, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	end

    if self.DrawGameHUD and GAMEMODE.RoundSettings.ShowSpectateInfo then
        self:DrawGameHUD( self:GetCSpectatee() )
    end
end

local health = 0
function gm:DrawGameHUD( ply )
	local w, h = ScrW(), ScrH()

	if not IsValid( ply ) then return end
	health = Lerp( FrameTime(), health, ply:Health() )

	local shouldDraw = hook.Run( "HUDShouldDraw", "MurderMurdererFog")
	if shouldDraw then
		if LocalPlayer() == ply and ply:GetNWBool( "MurdererFog" ) and self:GetAmMurderer() then
			surface.SetDrawColor( 10, 10, 10,50 )
			surface.DrawRect( -1, -1, ScrW() + 2, ScrH() + 2 )
		
			HUD80s.DrawText( translate.murdererFog, "MersRadial", w / 2, h - 80, HUD80s.Pink, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 2 )
			HUD80s.DrawText( translate.murdererFogSub, "MersRadialSmall", w / 2, h - 40, HUD80s.Pink, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 2 )
		end
	end

	local tr = ply:GetEyeTraceNoCursor()
	
	local shouldDraw = hook.Run( "HUDShouldDraw", "MurderTraitorButton" )
	if shouldDraw then
		if self:GetAmMurderer() then
			local dis, dot, but
			for k, lbut in pairs( ents.FindByClass( "ttt_traitor_button" ) ) do
				local vec = lbut:GetPos() - ply:GetShootPos()
				local ldis, ldot = vec:Length(), vec:GetNormal():Dot(ply:GetAimVector())
				if ( ldis < lbut:GetUsableRange() and ldot > 0.95 ) and ( not but or ldot > dot ) then
					dis = ldis
					dot = ldot
					but = lbut
				end
			end
			
			if but then
				local sp = but:GetPos():ToScreen()
				if sp.visible then
					local sz = 16
					local col = Color( 190, 20, 20 ) -- TODO: Use own colors
					if but:GetNextUseTime() > CurTime() then
						col = Color( 150, 150, 150 )
					end
					local ft, fh = draw.GetFontHeight( "LazerF30" ), draw.GetFontHeight( "LazerF40" )
					HUD80s.DrawText( but:GetDescription(), "LazerF40", sp.x, sp.y, HUD80s.Pink, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

					local text
					if but:GetNextUseTime() > CurTime() then
						text = Translator:VarTranslate( translate.ttt_tbut_waittime, { timesec = math.ceil( but:GetNextUseTime() - CurTime() ) .. "s" } )
					elseif but:GetDelay() < 0 then
						text = translate.ttt_tbut_single
					elseif but:GetDelay() == 0 then
						text = translate.ttt_tbut_reuse
					else
						text = Translator:VarTranslate( translate.ttt_tbut_retime, { num = but:GetDelay() } )
					end
					HUD80s.DrawText( text, "LazerF30", sp.x, sp.y + fh, HUD80s.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					
					local key = input.LookupBinding("use")
					if key and but:GetNextUseTime() <= CurTime() then
						text = Translator:VarTranslate(translate.ttt_tbut_help, {key = key:upper()})
						HUD80s.DrawText( text, "LazerF30", sp.x, sp.y + ft + fh, HUD80s.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
				end
			end
		end
	end

	local shouldDraw = hook.Run("HUDShouldDraw", "MurderPlayerNames")
	if shouldDraw then
		-- draw names
		if IsValid( tr.Entity ) and ( tr.Entity:IsPlayer() or tr.Entity:GetClass() == "prop_ragdoll" ) and tr.HitPos:Distance(tr.StartPos) < 500 then
			self.LastLooked = tr.Entity
			self.LookedFade = CurTime()
		end
		if IsValid( self.LastLooked ) and self.LookedFade + 2 > CurTime() then
			local name = self.LastLooked:GetBystanderName() or "error"
			local col = self.LastLooked:GetPlayerColor() or Vector()
			col = Color(col.x * 255, col.y * 255, col.z * 255)
			col.a = ( 1 - ( CurTime() - self.LookedFade ) / 2 ) * 255
			HUD80s.DrawText( name, "LazerF30", w / 2, h / 2 + 10, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, 2 )
		end
	end

	local shouldDraw = hook.Run("HUDShouldDraw", "MurderDisguise")
	if shouldDraw then
		if self:GetAmMurderer() and self.LootCollected and self.LootCollected >= 1 then
			if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" and tr.HitPos:Distance(tr.StartPos) < 80 then
				if tr.Entity:GetBystanderName() ~= ply:GetBystanderName() or colorDif(tr.Entity:GetPlayerColor(), ply:GetPlayerColor()) > 0.1 then 
					local fh = draw.GetFontHeight( "LazerF30" )
					HUD80s.DrawText( translate.pressEToDisguiseFor1Loot, "MersRadialSmall", w / 2, h / 2 + fh * 2, HUD80s.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 2 )
				end
			end
		end
	end
	
	local shouldDraw = hook.Run("HUDShouldDraw", "MurderHealthBall")
	if shouldDraw then
		-- setup size
		local size = ScrW() * 0.08

		local col = ply:GetPlayerColor()
		col = Color( col.x * 255, col.y * 255, col.z * 255 )

		draw.RoundedBox( size * 0.2, size * 0.1 + 5, h - size * 1.1 + 5, size, size, ColorAlpha( color_black, 150 ) )

		local hsize = math.Clamp( health, 0, 100 ) / 100 * size
		draw.RoundedBox( size * 0.2, size * 0.1 + ( size - hsize ) / 2, ScrH() - size * 1.1 + ( size - hsize ) / 2, hsize, hsize, col )

		if LocalPlayer() == ply then
			HUD80s.DrawText( self.LootCollected or "error", "LazerF40", size * 0.6, h - size * 0.6, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		surface.SetFont( "LazerF30" )
		local tw, th = surface.GetTextSize( ply:GetBystanderName() )
		local x = math.max( size * 0.6 + w / -2, size * 0.1 )
		HUD80s.DrawText( ply:GetBystanderName(), "LazerF30", size * 0.6, h - size * 1.25, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, 2 )
	end

	local shouldDraw = hook.Run("HUDShouldDraw", "MurderFlashlightCharge")
	if shouldDraw then
		if LocalPlayer() == ply and ( ply:FlashlightIsOn() or self:GetFlashlightCharge() < 1 ) then
			local size = ScrW() * 0.08
			local x = size * 1.2

			local w = ScrW() * 0.08
			local h = ScrH() * 0.03

			local bord = math.Round( ScrW() * 0.08 * 0.03 )
			if ply:FlashlightIsOn() then
				surface.SetDrawColor( 0, 0, 0, 240 )
			else
				surface.SetDrawColor( 5, 5, 5, 180 )
			end
			surface.DrawRect( x, ScrH() - h - size * 0.2, w, h )

			local charge = self:GetFlashlightCharge()

			if ply:FlashlightIsOn() then
				surface.SetDrawColor( ColorAlpha( HUD80s.Blue, 240 ) )
			else
				surface.SetDrawColor( ColorAlpha( HUD80s.Blue, 180 ) )
			end
			surface.DrawRect( x + bord, ScrH() - h - size * 0.2 + bord, ( w - bord * 2 ) * charge, h - bord * 2 )

			surface.SetTexture( gradR )
			surface.SetDrawColor( 255, 255, 255, 50 )
			surface.DrawTexturedRect( x + bord, ScrH() - h - size * 0.2 + bord, ( w - bord * 2 ) * charge, h - bord * 2 )
		end
	end
	
	local shouldDraw = hook.Run( "HUDShouldDraw", "MurderPlayerType" )
	if shouldDraw then
		local name = translate.bystander
		local color = HUD80s.Blue

		if LocalPlayer() == ply and self:GetAmMurderer() then
			name = translate.murderer
			color = HUD80s.Pink
		end

		HUD80s.DrawText( name, "LazerF30", w - 20, h - 10, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	end
end
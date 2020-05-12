HUD80s.CreateFonts( { 25 } )

hook.Add( "HUDShouldDraw", "80s:HideWeaponSelector", function( name )
    if name == "CHudWeaponSelection" then return false end
end )

local last_selected, selected, open_time, wait = nil, 1, 0, 3

hook.Add( "PlayerBindPress", "80s:WeaponSelectorNavigation", function( ply, bind, pressed )
    if ply:InVehicle() then return end

    local sweps = ply:GetWeapons()
    if #sweps == 0 then return end

    if not ( input.IsButtonDown( MOUSE_LEFT ) or input.IsButtonDown( MOUSE_RIGHT ) ) then
        if bind == "invprev" then
            selected = selected - 1
            if selected < 1 then selected = #sweps end

            surface.PlaySound( "friends/friend_join.wav" )

            open_time = CurTime()
        elseif bind == "invnext" then
            selected = selected + 1
            if selected > #sweps then selected = 1 end

            surface.PlaySound( "friends/friend_join.wav" )

            open_time = CurTime()
        elseif bind == "lastinv" then
            if not last_selected or not IsValid( last_selected ) then return end
            local last = LocalPlayer():GetActiveWeapon()

            input.SelectWeapon( last_selected )
            surface.PlaySound( "player/suit_sprint.wav" )

            last_selected = last
        end
    end

    if bind == "+attack" and not ( open_time + wait < CurTime() ) then
        surface.PlaySound( "friends/friend_online.wav" )

        last_selected = ply:GetActiveWeapon()
        input.SelectWeapon( ply:GetWeapons()[ selected ] )

        open_time = 0

        return true
    end
end )

local alpha = 0
hook.Add( "HUDPaint", "80s:WeaponSelector", function()
    local w, h = ScrW(), ScrH()
    local ply = LocalPlayer()

    if not LocalPlayer():Alive() then return end

    if open_time + wait < CurTime() then
        alpha = Lerp( FrameTime() * 10, alpha, 0 )
    else
        alpha = Lerp( FrameTime() * 5, alpha, 1 )
    end

    if alpha < 0.01 then return end

    local sweps = ply:GetWeapons()
    local swep = sweps[ selected ]

    if not swep then return end
    if not IsValid( swep ) then return end

    local font = "LazerF25"
    local font_h = draw.GetFontHeight( font )
    surface.SetFont( font )

    local delta = 5

    HUD80s.DrawText( swep:GetPrintName(), font, w / 2, font_h + 10, ColorAlpha( HUD80s.Pink, alpha * 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, 2 )

    local last_x = w / 2 - surface.GetTextSize( swep:GetPrintName() ) / 2 - 50
    for i = 1, delta do
        if not sweps[ selected - i ] then continue end

        local color = ColorAlpha( HUD80s.Blue, ( 1 - i / ( delta + 1 ) ) * 200 * alpha )
        HUD80s.DrawText( sweps[ selected - i ]:GetPrintName(), font, last_x, font_h + 10, color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, 2 )

        last_x = last_x - surface.GetTextSize( sweps[ selected - i ]:GetPrintName() ) - 50
    end

    local last_x = w / 2 + surface.GetTextSize( swep:GetPrintName() ) / 2 + 50
    for i = 1, delta do
        if not sweps[ selected + i ] then continue end

        local color = ColorAlpha( HUD80s.Blue, ( 1 - i / ( delta + 1 ) ) * 200 * alpha )
        HUD80s.DrawText( sweps[ selected + i ]:GetPrintName(), font, last_x, font_h + 10, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, 2 )

        last_x = last_x + surface.GetTextSize( sweps[ selected + i ]:GetPrintName() ) + 50
    end
end )

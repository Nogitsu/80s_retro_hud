local to_hide = {
	["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["CHudSecondaryAmmo"] = true
}

HUD80s.CreateFonts( { 20, 25, 30, 35, 40, 50 } )

hook.Add( "HUDShouldDraw", "80s:HideDefaults", function( name )
    if to_hide[ name ] then return false end
end )

local function draw_ammo( w, h, ply )
    local swep = ply:GetActiveWeapon()
    if not IsValid( swep ) then return end

    local bottom_space = 0

    --  > Clip 2
    if swep:GetSecondaryAmmoType() ~= -1 then
        --  > Remaining
        surface.SetFont( "LazerF30" )
        local ammo2 = ply:GetAmmoCount( swep:GetSecondaryAmmoType() )
        local ammo2_w, ammo2_h = surface.GetTextSize( ammo2 )
        HUD80s.DrawText( ammo2, "LazerF30", w - ammo2_w - 40, h - ammo2_h - 10, HUD80s.DarkPurple, nil, nil, 2, 2 )

        bottom_space = ammo2_h
    end

    --  > Clip 1
    if swep:GetPrimaryAmmoType() ~= -1 then
        --  > Remaining
        surface.SetFont( "LazerF30" )
        local ammo1 = ply:GetAmmoCount( swep:GetPrimaryAmmoType() )
        local ammo1_w, ammo1_h = surface.GetTextSize( ammo1 )
        HUD80s.DrawText( ammo1, "LazerF30", w - ammo1_w - 40, h - ammo1_h - 10 - bottom_space, HUD80s.Purple, nil, nil, 2, 2 )

        --  > In clip
        surface.SetFont( "LazerF50" )
        local clip1 = swep:Clip1()
        local clip1_w, clip1_h = surface.GetTextSize( clip1 )
        HUD80s.DrawText( clip1, "LazerF50", w - clip1_w - 20 - ammo1_w - 40, h - clip1_h - 10 - bottom_space, HUD80s.Purple )
    end
end

local health, armor = 0, 0
hook.Add( "HUDPaint", "80s:Paint", function()
    local w, h = ScrW(), ScrH()
    local ply = LocalPlayer()

    --  > Health
    health = Lerp( FrameTime() * 10, health, math.max( 0, ply:Health() ) )

    surface.SetFont( "LazerF50" )
    local health_w = surface.GetTextSize( math.Round( health ) )
    HUD80s.DrawText( math.Round( health ), "LazerF50", 20, h - 15, HUD80s.Pink, nil, TEXT_ALIGN_BOTTOM )

    surface.SetFont( "LazerF25" )
    local hp_w = surface.GetTextSize( "HP" )
    HUD80s.DrawText( "HP", "LazerF25", 20 + health_w + 10, h - 20, HUD80s.Pink, nil, TEXT_ALIGN_BOTTOM )

    --  > Armor
    armor = Lerp( FrameTime() * 5, armor, ply:Armor() )

    if armor > 0.1 then
        surface.SetFont( "LazerF35" )
        local armor_w = surface.GetTextSize( math.Round( armor ) )
        HUD80s.DrawText( math.Round( armor ), "LazerF35", 20 + health_w + 10 + hp_w + 20, h - 15, HUD80s.Blue, nil, TEXT_ALIGN_BOTTOM )

        HUD80s.DrawText( "%", "LazerF25", 20 + health_w + 10 + hp_w + 20 + armor_w + 10, h - 15, HUD80s.Blue, nil, TEXT_ALIGN_BOTTOM, 2, 2 )
    end

    draw_ammo( w, h, ply )
end )

hook.Add( "HUDDrawTargetID", "80s:DrawTarget", function()
    local ply = LocalPlayer():GetEyeTrace().Entity
    if not IsValid( ply ) then return end
    if not ply:IsPlayer() then return end

    local w, h = ScrW(), ScrH()

    HUD80s.DrawText( ply:Name(), "LazerF35", w / 2, h / 2, HUD80s.Blue, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, 2 )

    surface.SetFont( "LazerF30" )
    local _, health_h = surface.GetTextSize( ply:Health() )
    HUD80s.DrawText( ply:Health(), "LazerF30", w / 2 - 3, h / 2, HUD80s.Pink, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, 2 )
    HUD80s.DrawText( "HP", "LazerF20", w / 2 + 3, h / 2 + health_h * 0.9, HUD80s.Pink, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, 2 )

    return false
end )
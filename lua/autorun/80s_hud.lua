HUD80s = {
    Blue = Color( 60, 248, 250 ),
    Pink = Color( 253, 82, 244 ),
    Purple = Color( 155, 0, 255 ),
    DarkPurple = Color( 115, 0, 255 ),
    Black = Color( 24, 14, 33 )
}

--[[
    TODO Gamemodes:
        - murder
        - prophunt
        - deathrun
]]

local version = engine.ActiveGamemode()
local compatible = {
    murder = true
}

if not compatible[ version ] then version = "base" end

if SERVER then
    resource.AddFile( "resource/fonts/Lazer84.ttf" )
    resource.AddFile( "resource/fonts/vcr_osd.ttf" )
end

hook.Add( "PostGamemodeLoaded", "BypassGamemode", function()
    if SERVER then
        AddCSLuaFile( "80s_hud/needed/utils.lua")
        AddCSLuaFile( "80s_hud/needed/weapon_selector.lua")
        AddCSLuaFile( "80s_hud/" .. version .. ".lua")
    else
        include( "80s_hud/needed/utils.lua")
        include( "80s_hud/needed/weapon_selector.lua")
        include( "80s_hud/" .. version .. ".lua")
    end
end )
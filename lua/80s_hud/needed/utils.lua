function HUD80s.DrawText( text, font, x, y, color, align_x, align_y, shadow_x, shadow_y )
    x = x or 0
    y = y or 0
    --  > Shadow
    draw.SimpleText( text, font or "Trebuchet24", x + ( shadow_x or 4 ), y + ( shadow_y or 4 ), color or Color( 0, 0, 0 ), align_x or TEXT_ALIGN_LEFT, align_y or TEXT_ALIGN_TOP )

    --  > Text
    color_white.a = color.a or 255
    draw.SimpleText( text, font or "Trebuchet24", x, y, color_white, align_x or TEXT_ALIGN_LEFT, align_y or TEXT_ALIGN_TOP )
    color_white.a = 255
end

function HUD80s.CreateFonts( sizes )
    if not sizes or not istable( sizes ) then return end

    for _, size in ipairs( sizes ) do
        surface.CreateFont( "LazerF" .. size, {
            font = "Lazer84",
            size = size
        } )
    end
end
local atan2, pi, cos, sin, sqrt, max, deg, abs = math.atan2, math.pi, math.cos, math.sin, math.sqrt, math.max, math.deg, math.abs
local function hypot( x, y ) return sqrt( x^2 + y^2 ) end

local unpack = table.unpack or unpack

local function vec( x, y ) return {x=x, y=y} end
local origin = vec( 0.0, 0.0 )

return function ( cnv, values, geom, constraints )
    local x1, x2, x3, x4, x5, x6, x7, x8, x9 = unpack( values )
    local    S1,      S2,      S3,      S4,      S5,      S6,      S7 =
        geom.S1, geom.S2, geom.S3, geom.S4, geom.S5, geom.S6, geom.S7
    local    C5,      C6,      C7 =
        geom.C5, geom.C6, geom.C7
    
    cnv:Transform( nil )
    cnv:Clear()
    
    --cnv:wLineWidth( 0.6 )
    cnv:LineJoin( cd.ROUND )
    cnv:LineCap( cd.CAPROUND )
    
    local Edge = C7.x + x5
    local Bottom = C6.y - x9
    
    local cnv_width, cnv_height = cnv:GetSize()
    local orig_width = 420
    --local scale = cnv_width / orig_width
    local scale = cnv_width / cnv:MM2Pixel( orig_width, orig_width )
    
    --Perform transformations
    cnv:TransformTranslate( 40, cnv_height-40 )
    cnv:TransformScale( scale, scale )
    cnv:LineWidth( 0.6 / scale )
    
    --Draw the line segments
    for _, line in ipairs{ S1, S2, S3, S4 } do
        cnv:wLine( line.a.x, line.a.y, line.b.x, line.b.y )
    end
    
    --Draw the arc segments
    for _, arc in ipairs{ S5, S6, S7 } do
        cnv:wArc( arc.c.x, arc.c.y, arc.r*2, arc.r*2, deg( arc.a1 ), deg( arc.a2 ) )
    end
    
    --Draw constraint lines
    do 
        local default_width = 2.0 / scale
        local origWidth = cnv:LineWidth( default_width )
        local origCap = cnv:LineCap( cd.CAPFLAT )
        for _, constraint in pairs( constraints ) do
            if constraint.lines then
                local origForeground = cnv:Foreground( cd.QUERY )
                for _, line in ipairs( constraint.lines ) do
                    cnv:LineWidth( (line.relative_width or 1.0) * default_width )
                    cnv:LineStyle( line.dash_style and cd[ line.dash_style ] or cd.CONTINUOUS )
                    cnv:SetForeground( cd[ line.color ] )
                    cnv:wLine( line.a.x, line.a.y, line.b.x, line.b.y )
                end
                cnv:SetForeground( origForeground)
            end
        end
        cnv:LineStyle( cd.CONTINUOUS )
        cnv:LineCap( origCap )
        cnv:LineWidth( origWidth )
    end
    
    --Draw segment endpoints
    local origMarkType = cnv:MarkType( cd.HOLLOW_CIRCLE )
    local origForeground = cnv:Foreground( cd.DARK_GRAY )
    local tip1 = vec( S7.c.x + S7.r*cos(S7.a1), S7.c.y + S7.r*sin(S7.a1) )
    local tip2 = vec( S7.c.x + S7.r*cos(S7.a2), S7.c.y + S7.r*sin(S7.a2) )
    for _, point in ipairs{ origin, S1.b, S2.b, S3.b, S4.b, tip1, tip2 } do
        cnv:wMark( point.x, point.y )
    end
    cnv:SetForeground( origForeground )
    cnv:MarkType( origMarkType )
end
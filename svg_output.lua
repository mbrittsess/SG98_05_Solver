cd = require "cdlua"
local atan2, pi, cos, sin, sqrt, max, deg, abs = math.atan2, math.pi, math.cos, math.sin, math.sqrt, math.max, math.deg, math.abs
local function hypot( x, y ) return sqrt( x^2 + y^2 ) end

local width, height = 500, 100
cnv = cd.CreateCanvas( cd.SVG, string.format( [[SG98_05.svg %ix%i]], width, height ) )

local GetNextColor
do  local H = 0.0
    local H_inc = 360.0/10
    local S = 1.0
    local L = 0.5
   
    function GetNextColor ( )
        C = (1 - math.abs( 2*L - 1 ))*S
        H_ = H / 60.0
        X = C * (1-abs( H_%2 - 1 ))
        
        local tbl = {
        [0]={ C, X, 0 },
            { C, X, 0 },
            { X, C, 0 },
            { 0, C, X },
            { 0, X, C },
            { X, 0, C },
            { C, 0, X }
        }
        
        local vals = tbl[ math.ceil( H_ ) ]
        H = H + H_inc
        return cd.EncodeColor( vals[1]*255.0, vals[2]*255.0, vals[3]*255.0 )
    end
end

local x = { --Variables
    ( 34.8+ 35.0)/2; --Saw offset from hilt
    (262.9+263.9)/2; --Saw horizontal length
    (  1.0+  6.0)/2; --Saw vertical drop
    (216.0+264.0)/2; --Top blade radius
    (  0.4+  8.0)/2; --Tip radius
    ( 25.7+ 26.0)/2; --Hilt height
    (269.0+328.8)/2; --Bottom horizontal length
    ( 30.6+ 37.4)/2; --Bottom vertical drop from saw vertical drop
    (156.6+191.4)/2; --Bottom blade radius
}
for i = 1, #x do _G[ "x" .. tostring(i) ] = x[i] end
--for i = 1, #x do print( string.format( [[x%i = %.1fmm]], i, x[i] ) ) end

cnv:wLineWidth( 0.6 ) --As with ANSI drawing standards
cnv:LineJoin( cd.ROUND )
cnv:LineCap( cd.CAPROUND )

local function vec( x, y ) return {x=x, y=y} end

local origin = vec( 0.0, 0.0 )

local S1 = { --Top edge
    a = origin,
    b = vec( x1, 0.0 )
}

local S2 = { --Saw edge
    a = S1.b,
    b = vec( S1.b.x + x2, S1.b.y - x3 )
}

local S3 = { --Hilt edge
    a = origin,
    b = vec( 0.0, -x6 )
}

local S4 = { --Bottom edge
    a = S3.b,
    b = vec( S3.b.x + x7, S3.b.y - x8 )
}

local C5 --Top arc center
do
    local S2_ang = atan2( S2.b.y - S2.a.y, S2.b.x - S2.a.x )
    local ang = S2_ang - (pi/2)
    --print( string.format( "S2_ang = %.1f\248\nC5_ang = %.1f\248", deg(S2_ang), deg(ang) ) )
    C5 = vec(
        S2.b.x + x4*cos(ang),
        S2.b.y + x4*sin(ang)
    )
end

local C6 --Bottom arc center
do
    local S4_ang = atan2( S4.b.y - S4.a.y, S4.b.x - S4.a.x )
    local ang = S4_ang + (pi/2)
    C6 = vec(
        S4.b.x + x9*cos(ang),
        S4.b.y + x9*sin(ang)
    )
end

local C7 --Tip arc center
do
    --print( x4, x5, x9 )
    local A, B, M = C6.x, C6.y, x9-x5
    local C, D, N = C5.x, C5.y, x4-x5
    local E = ( A^2 + B^2 + -C^2 + -D^2 + -M^2 + N^2 )/( 2*(B-D) )
    local F = (A-C)/(B-D)
    
    local X = 1+F^2
    local Y = 2*( -A + -E*F + B*F )
    local Z = A^2 + E^2 + -2*B*E + B^2 + -M^2
    
    local sln1 = ( -Y + sqrt( Y^2 - 4*X*Z ) )/( 2*X )
    local sln2 = ( -Y - sqrt( Y^2 - 4*X*Z ) )/( 2*X )
    
    local x = max( sln1, sln2 )
    local y = sqrt( (x4-x5)^2 - (x-C5.x)^2 )
    
    --[=[print( string.format( [[

A = %8.3f    B = %8.3f    M = %8.3f
C = %8.3f    D = %8.3f    N = %8.3f

E = %8.4f    F = %.8f

X = %.6f
Y = %.3f
Z = %.1f

Solutions: %.3f, %.3f
x, y = %.1f, %.1f
]],
    A, B, M, C, D, N, E, F, X, Y, Z, sln1, sln2, x, y ) ) ]=]
    
    C7 = vec( x, C5.y + y )
end

local S5 = { --Top blade arc
    c  = C5,
    r  = x4,
    a1 = atan2( C7.y - C5.y, C7.x - C5.x ),
    a2 = atan2( S2.b.y - C5.y, S2.b.x - C5.x )
}

local S6 = { --Bottom blade arc
    c  = C6,
    r  = x9,
    a1 = atan2( S4.b.y - C6.y, S4.b.x - C6.x ),
    a2 = atan2( C7.y - C6.y, C7.x - C6.x )
}

local S7 = { --Tip arc
    c  = C7,
    r  = x5,
    a1 = atan2( C7.y - C6.y, C7.x - C6.x ),
    a2 = atan2( C7.y - C5.y, C7.x - C5.x )
}

--Transform things so the output will be centered
do
    local Edge = C7.x + x5
    local Bottom = C6.y - x9
    
    local x_ofs = (width - Edge)/2
    local y_ofs = height - (Bottom + height)/2
    
    cnv:TransformTranslate( cnv:MM2Pixel( x_ofs, y_ofs)  )
end

--Draw the line segments
for _, line in ipairs{ S1, S2, S3, S4 } do
    print( string.format( "Line: (%.1f,%.1f)mm --> (%.1f,%.1f)mm", line.a.x, line.a.y, line.b.x, line.b.y ) )
    cnv:SetForeground( GetNextColor() )
    cnv:wLine( line.a.x, line.a.y, line.b.x, line.b.y )
end

---[=[
--Draw the arc segments
for _, arc in ipairs{ S5, S6, S7 } do
    print( string.format( "Arc:  (%.1f,%.1f)mm, R%.1fmm, %.1f\248 --> %.1f\248", arc.c.x, arc.c.y, arc.r, deg( arc.a1 ), deg( arc.a2 ) ) )
    cnv:SetForeground( GetNextColor() )
    cnv:wArc( arc.c.x, arc.c.y, arc.r*2, arc.r*2, deg( arc.a1 ), deg( arc.a2 ) )
end
--]=]

--[=[
--Draw circles, debug stuff
for _, arc in ipairs{ S5, S6, S7 } do
    print( string.format( "Circ: (%.1f,%.1f)mm, R%.1fmm", arc.c.x, arc.c.y, arc.r ) )
    cnv:SetForeground( GetNextColor() )
    cnv:wArc( arc.c.x, arc.c.y, arc.r*2, arc.r*2, 0.0, 360.0 )
end
--]=]

cnv:Flush()
cd.KillCanvas( cnv )
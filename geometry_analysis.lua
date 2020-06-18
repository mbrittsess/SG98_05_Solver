local atan2, pi, cos, sin, sqrt, max, deg, abs = math.atan2, math.pi, math.cos, math.sin, math.sqrt, math.max, math.deg, math.abs
local function hypot( x, y ) return sqrt( x^2 + y^2 ) end

local unpack = table.unpack or unpack

local function vec( x, y ) return {x=x, y=y} end
local origin = vec( 0.0, 0.0 )

return function ( variables )
    local x1, x2, x3, x4, x5, x6, x7, x8, x9 = unpack( variables )
    
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
        b = vec( S3.b.x + x7, -(x3 + x8) )
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
    
    --Add informative endpoints for arcs
    for _, arc in pairs{ S5, S6, S7 } do
        arc.p1 = vec( arc.c.x + arc.r*cos(arc.a1), arc.c.y + arc.r*sin(arc.a1) )
        arc.p2 = vec( arc.c.x + arc.r*cos(arc.a2), arc.c.y + arc.r*sin(arc.a2) )
    end
    
    return {
        S1 = S1, S2 = S2, S3 = S3, S4 = S4, C5 = C5, S5 = S5, C6 = C6, S6 = S6, C7 = C7, S7 = S7
    }
end
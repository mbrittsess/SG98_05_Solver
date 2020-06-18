local    atan2,      pi,      cos,      sin,      sqrt,      min,      max,      deg,      abs = 
    math.atan2, math.pi, math.cos, math.sin, math.sqrt, math.min, math.max, math.deg, math.abs
local unpack = table.unpack or unpack
local function vec( x, y ) return {x=x, y=y} end

local function isnan( x ) return x ~= x end

return function ( variables, geom, var_defs )
    local x1, x2, x3, x4, x5, x6, x7, x8, x9 = unpack( variables )
    local    S1,      S2,      S3,      S4,      S5,      S6,      S7 =
        geom.S1, geom.S2, geom.S3, geom.S4, geom.S5, geom.S6, geom.S7
    local    C5,      C6,      C7 =
        geom.C5, geom.C6, geom.C7
    
    local line_eqns = {}
    for i = 1, 4 do
        local key = "S" .. tostring(i)
        local line = geom[ key ]
        local slope = (line.b.y - line.a.y)/(line.b.x - line.a.x)
        local intercept = line.a.y - (line.a.x * slope)
        line_eqns[ key ] = { m = slope, b = intercept }
    end
    
    local ret = {}
    
    --Constraint 1 Evaluation
    do
        local top_eq = line_eqns.S2
        local bot_eq = line_eqns.S4
        
        local top = top_eq.m*35.0 + top_eq.b
        local bot = bot_eq.m*35.0 + bot_eq.b
        
        local dist = top-bot
        local satisfied = ((26.7-0.3) <= dist) and (dist <= 26.7)
        
        local spread = abs( dist - (26.7 - 0.3/2) )
        
        local draw_line = { a = vec( 35.0, top - (26.7-0.3) ), b = vec( 35.0, top - 26.7 ), color = satisfied and "GREEN" or "RED" }
        local draw_line2= { a = vec( 35.0, bot + (26.7-0.3) ), b = vec( 35.0, bot + 26.7 ), color = satisfied and "GREEN" or "RED" }
        
        ret[1] = {
            description = [[Vertical separation at 35mm from hilt must be within 26.7-0.3]];
            range = [[26.7-0.3]];
            numeric_status = string.format( "%.3fmm", dist );
            spread = string.format( "%.3fmm", spread );
            spread_n = spread;
            satisfied = satisfied;
            lines = { draw_line, draw_line2 };
        }
    end
    
    --Constraint 2 Evaluation
    do
        local sep = abs( line_eqns.S4.m*7.0 + line_eqns.S4.b )
        local spread = abs( (26.0 - (0.3/2)) - sep )
        local satisfied = ((26.0-0.3) <= sep) and (sep <= 26.0)
        
        local top, bot = 0.0, -sep
        
        local draw_line = { a = vec( 7.0, top - (26.0-0.3) ), b = vec( 7.0, top - 26.0 ), color = satisfied and "GREEN" or "RED" }
        local draw_line2 ={ a = vec( 7.0, bot + (26.0-0.3) ), b = vec( 7.0, bot + 26.0 ), color = satisfied and "GREEN" or "RED" }
        
        ret[2] = { 
            description = [[Vertical separation at 7mm from hilt must be within 26.0-0.3]],
            range = [[26.0-0.3]];
            numeric_status = string.format( "%.3fmm", sep );
            spread = string.format( "%.3fmm", spread );
            spread_n = spread;
            satisfied = satisfied;
            lines = { draw_line, draw_line2 };
        }
    end
    
    --Constraint 3 Evaluation
    do
        local con_x = (C7.x + S7.r) - 76.1
        
        local st, sb
        
        --Find top coordinate
        local top_y
        if S2.b.x < con_x then --That point lies under top blade arc
            top_y = C5.y + sqrt( S5.r^2 - (con_x - C5.x)^2 )
            st = "a"
        else --That point lies under saw
            top_y = line_eqns.S2.m*con_x + line_eqns.S2.b
            st = "b"
        end
        
        --Find bottom coordinate
        local bot_y
        if S4.b.x < con_x then
            bot_y = C6.y - sqrt( S6.r^2 - (con_x - C6.x)^2 )
            sb = "a"
        else
            bot_y = line_eqns.S4.m*con_x + line_eqns.S4.b
            sb = "b"
        end
        
        local dist = top_y - bot_y
        local satisfied = ((34.0-0.3) <= dist) and (dist <= 34.0)
        local spread = abs( dist - (34.0 - 0.3/2) )
        
        local color = satisfied and "GREEN" or "RED"
        local draw_line = { a = vec( con_x, top_y - 34.0 ), b = vec( con_x, top_y - (34.0-0.3) ), color = color }
        local draw_line2= { a = vec( con_x, bot_y + 34.0 ), b = vec( con_x, bot_y + (34.0-0.3) ), color = color }
        
        local t = math.min( draw_line.a.y, draw_line.b.y )
        local b = math.min( draw_line2.a.y, draw_line2.b.y )
        
        ret[3] = { 
            description = [[Vertical separation at 76.1mm from tip must be within 34.0-0.3mm]];
            range = [[34.0-0.3]];
            numeric_status = string.format( "%.3fmm", dist ) --[[.. st .. sb]];
            spread = string.format( "%.3fmm", spread );
            spread_n = spread;
            satisfied = satisfied;
            lines = { draw_line, draw_line2 };
        }
    end
    
    --Constraint 4 Evaluation
    do
        local con_x = (C7.x + S7.r) - 40.0
        
        --assert( (S5.c.x + S5.r*cos(S5.a2)) < con_x, string.format( "%.3f + %.3f*cos(%.3f)) < %.3f; (%s)", S5.c.x, S5.r, S5.a2, con_x, variables:tostring("%.3f") ) )
        --assert( (S6.c.x + S6.r*cos(S6.a1)) < con_x, string.format( "%.3f + %.3f*cos(%.3f)) < %.3f; (%s)", S6.c.x, S6.r, S6.a1, con_x, variables:tostring("%.3f") ) )
        
        local top_y
        if (S5.c.x + S5.r*cos(S5.a2)) < con_x then --40mm offset line crosses top blade
            top_y = S5.c.y + sqrt( S5.r^2 - (con_x - C5.x)^2 )
        else --40mm offset line crosses saw edge
            top_y = line_eqns.S2.m*con_x + line_eqns.S2.b
        end
        
        local bot_y
        if (S6.c.x + S6.r*cos(S6.a1)) < con_x then --40mm offset line crosses bottom blade
            bot_y = S6.c.y - sqrt( S6.r^2 - (con_x - C6.x)^2 )
        else --40mm offset line crosses bottom edge
            bot_y = line_eqns.S4.m*con_x + line_eqns.S4.b
        end
        
        local dist = top_y - bot_y
        local satisfied = ((26.0-0.3) <= dist) and (dist <= 26.0)
        
        local spread = abs( dist - (26.0 - 0.3/2) )
        
        local draw_line = { a = vec( con_x, top_y - 26.0 ), b = vec( con_x, top_y - (26.0-0.3) ), color = satisfied and "GREEN" or "RED" }
        local draw_line2= { a = vec( con_x, bot_y + 26.0 ), b = vec( con_x, bot_y + (26.0-0.3) ), color = satisfied and "GREEN" or "RED" }
        
        ret[4] = {
            description = [[Vertical separation at 40mm from tip must be within 26.0-0.3mm]];
            range = [[26.0-0.3]];
            numeric_status = string.format( "%.3fmm", dist );
            spread = string.format( "%.3fmm", spread );
            spread_n = spread;
            satisfied = satisfied;
            lines = { draw_line, draw_line2 };
        }
    end
    
    --Constraint 5 Evaluation
    do
        local dist = abs( C7.y )
        local satisfied = ((18.0-0.2) <= dist) and (dist <= 18.0)
        local spread = abs( dist - (18.0 - 0.2/2) )
        
        ret[5] = {
            description = [[Drop of tip center from top must be within 18.0-0.2]];
            range = [[18.0-0.2]];
            numeric_status = string.format( "%.3fmm", dist );
            spread = string.format( "%.3fmm", spread );
            spread_n = spread;
            satisfied = satisfied;
        }
    end
    
    --Constraint 6 Evaluation
    do
        local top = C7.y + S7.r*sin(S7.a1)
        local bot = C7.y + S7.r*sin(S7.a2)
        local dist = abs( top - bot )
        local satisfied = ((1.0-0.2) <= dist) and (dist <= 1.0)
        local spread = abs( dist - (1.0 - 0.2/2) )
        
        ret[6] = {
            description = [[Tip vertical thickness must be within 1.0-0.2]];
            range = [[1.0-0.2]];
            numeric_status = string.format( "%.3fmm", dist );
            spread = string.format( "%.3fmm", spread );
            spread_n = spread;
            satisfied = satisfied;
        }
    end
    
    --Constraint 7 Evaluation
    do
        --[[We'll be analyzing the blade's thickness from left to right, trying to find the greatest thicknesses and any portions that are
        exactly 33mm thick. We'll be doing some redundant calculations, but we'll make sense of them all at the end.]]
        local leftmost_x = min( S2.b.x, S4.b.x )
        local sep33 = {}
        local lines = {}
        
        --print"---Constraint 7"
        
        --First section, the vertical separation between S2, the saw edge, and S4, the bottom edge. Both are straight lines, so this is pretty trivial.
        local sec1_thickest
        do
            local et, eb = line_eqns.S2, line_eqns.S4
            local top_y = et.m*leftmost_x + et.b
            local bot_y = eb.m*leftmost_x + eb.b
            sec1_thickest = top_y - bot_y
            
            if sec1_thickest > 33 then
                local x33 = (33+eb.b - et.b)/(et.m - eb.m)
                local top_y33 = et.m*x33 + et.b
                local bot_y33 = eb.m*x33 + eb.b
                sep33[#sep33+1] = {
                    a = vec( x33, top_y33 ),
                    b = vec( x33, bot_y33 )
                }
                --print( string.format( "#1.1: x=%.2f, %f", x33, math.abs(sep33[#sep33].a.y - sep33[#sep33].b.y) ) )
            elseif sec1_thickest == 33 then
                sep33[#sep33+1] = {
                    a = vec( leftmost_x, top_y ),
                    b = vec( leftmost_x, bot_y )
                }
                --print( string.format( "#1.2: x=%.2f, %f", leftmost_x, math.abs(sep33[#sep33].a.y - sep33[#sep33].b.y) ) )
            end
            
            --lines[#lines+1] = { a = vec( leftmost_x, top_y ), b = vec( leftmost_x, bot_y ), color = "DARK_CYAN" }
        end
        
        --Second section, optional, exists if S5 has any overhang over S4
        local sec2_thickest
        if S2.b.x < S4.b.x then
            local function eval_S5 ( x )
                return C5.y + sqrt( S5.r^2 - (x - C5.x)^2 )
            end
            
            local function eval_S4 ( x )
                return line_eqns.S4.m*x + line_eqns.S4.b
            end
            
            local function eval_len ( x )
                return eval_S5( x ) - eval_S4( x )
            end
            
            local eb = line_eqns.S4
            
            local lx, rx = S2.b.x, S4.b.x
            local top_ly, top_ry = eval_S5( lx ), eval_S5( rx )
            local bot_ly, bot_ry = eval_S4( lx ), eval_S4( rx )
            local len_l, len_r = eval_len( lx ), eval_len( rx )
            
            --lines[ #lines+1 ] = { a = vec( rx, top_ry ), b = vec( rx, bot_ry ), color = "DARK_CYAN" }
            
            local thickest_x = C5.x + sqrt( ( eb.m^2 * S5.r^2 ) / ( eb.m^2 + 1 ) )
            if not isnan( x ) and (lx <= thickest_x) and (thickest_x <= rx) then
                lines[ #lines+1 ] = { 
                    a = vec( thickest_x, eval_S5( thickest_x ) ),
                    b = vec( thickest_x, eval_S4( thickest_x ) ),
                    color = "DARK_YELLOW"
                }
            end
            
            local extrema_x = isnan(x) and { lx, rx } or { lx, thickest_x, rx }
            local extrema_len = {}; for i,x in ipairs(extrema_x) do extrema_len[i] = eval_len(x) end
            
            for i,len in ipairs( extrema_len ) do
                if len == 33 then
                    sep33[ #sep33+1 ] = {
                        a = vec( extrema_x[i], eval_S5( extrema_x[i] ) ),
                        b = vec( extrema_x[i], eval_S4( extreme_x[i] ) ),
                        color = "BLUE"
                    }
                    --print( string.format( "#2.1: x=%.2f, %f", extrema_x[i], math.abs(sep33[#sep33].a.y - sep33[#sep33].b.y) ) )
                end
            end
            
            if (min( unpack( extrema_len ) ) < 33) and (33 < max( unpack( extrema_len ) )) then
                --An exact-33 exists in the range
                local a = eb.m^2 + 1
                local b = 2*eb.m*(33 + eb.b - C5.y) - 2*C5.x
                local c = (33 + eb.b - C5.y)^2 - S5.r^2 + C5.x^2
                
                local p1 = -b
                local p2 = sqrt( b^2 - 4*a*c )
                local p3 = 2*a
                
                for _, sign in ipairs{ 1, -1 } do
                    local sln_x = ( p1 + sign*p2 ) / p3
                    if (not isnan(sln_x)) and (lx < sln_x) and (sln_x < rx) then
                        sep33[ #sep33+1 ] = {
                            a = vec( sln_x, eval_S5( sln_x ) ),
                            b = vec( sln_x, eval_S4( sln_x ) ),
                            color = "BLUE"
                        }
                        --print( string.format( "#2.2: x=%.2f, %f", sln_x, math.abs(sep33[#sep33].a.y - sep33[#sep33].b.y) ) )
                    end
                end
            end
        end
        
        --Third section, optional, exists if S2 has any overhang over S6
        if S2.b.x > S4.b.x then
            local function eval_S2 ( x )
                return line_eqns.S2.m*x + line_eqns.S2.b
            end
            
            local function eval_S6 ( x )
                return C6.y - sqrt( S6.r^2 - (x - C6.x)^2 )
            end
            
            local function eval_len ( x )
                return eval_S2(x) - eval_S6(x)
            end
            
            local et = line_eqns.S2
            
            local lx, rx = S4.b.x, S2.b.x
            local top_ly, top_ry = eval_S2( lx ), eval_S2( rx )
            local bot_ly, bot_ry = eval_S6( lx ), eval_S6( rx )
            local len_l, len_r = eval_len( lx ), eval_len( rx )
            
            --lines[ #lines+1 ] = { a = vec( rx, top_ry ), b = vec( rx, bot_ry ), color = "DARK_CYAN" }
            
            local thickest_x = C6.x - sqrt((et.m^2 * S6.r^2)/(et.m^2 + 1))
            if not isnan( x ) and (lx <= thickest_x) and (thickest_x <= rx) then
                lines[ #lines+1 ] = {
                    a = vec( thickest_x, eval_S2( thickest_x ) ),
                    b = vec( thickest_x, eval_S6( thickest_x ) ),
                    color = "DARK_YELLOW"
                }
            end
            
            local extrema_x = isnan(x) and { lx, rx } or {lx, thickest_x, rx }
            local extrema_len = {}; for i,x in ipairs(extrema_x) do extrema_len[i] = eval_len(x) end
            
            for i,len in ipairs( extrema_len ) do
                if len == 33 then
                    sep33[ #sep33+1 ] = {
                        a = vec( extrema_x[i], eval_S2( thickest_x ) ),
                        b = vec( extrema_x[i], eval_S6( thickest_x ) ),
                        color = "BLUE"
                    }
                end
            end
            
            if (min( unpack( extrema_len ) ) < 33) and (33 < max( unpack( extrema_len ) )) then
                --An exact-33 exists in the range
                local a = et.m^2 + 1
                local b = -2*et.m*(33 + C6.y - et.b) - 2*C6.x
                local c = (33 + C6.y - et.b)^2 + C6.x^2 - S6.r^2
                
                local p1 = -b
                local p2 = sqrt( b^2 + -4*a*c )
                local p3 = 2*a
                
                for _, sign in ipairs{ 1, -1 } do
                    local sln_x = ( p1 + sign*p2 ) / p3
                    if (not isnan(sln_x)) and (lx < sln_x) and (sln_x < rx) then
                        sep33[ #sep33+1 ] = {
                            a = vec( sln_x, eval_S2( sln_x ) ),
                            b = vec( sln_x, eval_S6( sln_x ) ),
                            color = "BLUE"
                        }
                        --print( string.format( "#3: x=%.2f, %f", sln_x, math.abs(sep33[#sep33].a.y - sep33[#sep33].b.y) ) )
                    end
                end
            end
        end
        
        --Fourth section, area between S5 and S6
        do
            local lx = max( S2.b.x, S4.b.x )
            local rx = min( C7.x + S7.r*cos(S7.a1), C7.x + S7.r*cos(S7.a2) )
            --local A, B, C = C5.x, C5.y, S5.r
            --local D, E, F = C6.x, C6.y, S6.r
            
            local C = S5.r
            local D = (C6.x - C5.x)
            local E = (C6.y - C5.y)
            local F = S6.r
            
            --WolframAlpha consulted for this. The algebra is straightforward but very long and error-prone, so I haven't attempted it manually.
            local a = -4356 - 4*D^2 - 264*E - 4*E^2
            local b = 4356*D + 4*C^2*D + 4*D^3 - 4*D*F^2 + 264*D*E + 4*D*E^2
            local c = -1185921 + 2178*C^2 - C^4 - 2178*D^2 - 2*C^2*D^2 - D^4 + 2178*F^2 + 2*C^2*F^2 + 2*D^2*F^2 - F^4 - 143748*E + 132*C^2*E - 132*D^2*E + 132*F^2*E - 6534*E^2 + 2*C^2*E^2 - 2*D^2*E^2 + 2*F^2*E^2 - 132*E^3 - E^4
            
            local p1 = -b
            local p2 = sqrt( b^2 - 4*a*c )
            local p3 = 2*a
            
            for _, sign in ipairs{ 1, -1 } do
                local sln_x = C5.x + ( ( p1 + sign*p2 ) / p3 )
                if (not isnan(sln_x)) and (lx < sln_x) and (sln_x < rx) then
                    sep33[ #sep33+1 ] = {
                        a = vec( sln_x, C5.y + sqrt( S5.r^2 - (sln_x - C5.x)^2 ) ),
                        b = vec( sln_x, C6.y - sqrt( S6.r^2 - (sln_x - C6.x)^2 ) ),
                        color = "BLUE"
                    }
                    --print( string.format( "#4:   x=%.2f, %f", sln_x, math.abs(sep33[#sep33].a.y - sep33[#sep33].b.y) ) )
                end
            end
            
            local thickest_x = C5.x + ((C*D)/(C+F))
            if (lx < thickest_x) and (thickest_x < rx) then
                lines[ #lines+1 ] = {
                    a = vec( thickest_x, C5.y + sqrt( S5.r^2 - (thickest_x - C5.x)^2 ) ),
                    b = vec( thickest_x, C6.y - sqrt( S6.r^2 - (thickest_x - C6.x)^2 ) ),
                    color = "DARK_YELLOW"
                }
            end
        end
        
        local right_edge = C7.x + S7.r
        local min_range = right_edge - (68+2)
        local max_range = right_edge - (68-2)
        
        local within_range = false
        local target_x = 0.0
        local mid = right_edge - 68
        if #sep33 > 0 then
            for _,line in ipairs( sep33 ) do
                local x = line.a.x
                if (min_range <= x) and (x <= max_range) and (abs(x-mid) < abs(target_x-mid)) then
                    within_range = true
                    target_x = x
                end
            end
        else
            --This is pretty fragile, but at the moment, lines[] contains only lines denoting the "thickest" area.
            for _,line in ipairs( lines ) do
                local x = line.a.x
                if (min_range <= x) and (x <= max_range) and (abs(x-mid) < abs(target_x-mid)) then
                    within_range = true
                    target_x = x
                end
            end
        end
        
        local rightmost_x = 0.0
        local max_x = 0.0
        local thickest = 0.0
        if #sep33 > 0 then
            local used_i = 0
            for i, line in ipairs( sep33 ) do
                if line.a.x > rightmost_x then
                    rightmost_x = line.a.x
                    used_i = i
                end
                line.color = "GRAY"
            end
            max_x = 33.0
            sep33[ used_i ].color = "GREEN"
            for _, line in ipairs( lines ) do
                local thickness = abs( line.a.y - line.b.y )
                if thickest < thickness then
                    thickest = thickness
                end
                line.color = "GRAY"
            end
        else
            local thickest_x, thickest_i, max_thickness = 0.0, 0, 0.0
            for i, line in ipairs( lines ) do
                local thickness = abs( line.a.y - line.b.y )
                if thickness > max_thickness then
                    thickest_x = line.a.x
                    max_thickness = thickness
                    thickest_i = i
                end
                line.color = "GRAY"
            end
            thickest = max_thickness
            max_x = thickest_x
            rightmost_x = thickest_x
            lines[ thickest_i ].color = "RED"
        end
        
        for _,l in ipairs( lines ) do
            --l.color = "GRAY"
            l.relative_thickness = 0.75
            l.dash_style = "DASHED"
        end
        
        lines[ #lines+1 ] = {
            a = vec( right_edge - (68+2), C7.y ),
            b = vec( right_edge - (68-2), C7.y ),
            color = within_range and "GREEN" or "RED"
        }
        
        for _, v in ipairs( sep33 ) do
            --v.color = "GRAY"
            v.relative_thickness = 0.75
            v.dash_style = "DOTTED"
            lines[ #lines+1 ] = v
        end
        
        local numeric_value7 = right_edge - rightmost_x
        local spread7 = abs( numeric_value7 - 68.0 )
        
        local numeric_value71 = (#sep33 > 0) and 33.0 or thickest
        local spread71 = (#sep33 == 0) and (33.0-thickest) or 0.0
        
        ret[7] = {
            description = [[Rightmost point with 33mm vertical thickness, or vertically-thickest point, must be within 68±2mm from tip]];
            numeric_status = string.format( "%.3fmm", numeric_value7 );
            satisfied = ((68.0-2.0) <= numeric_value7) and (numeric_value7 <= (68.0+2.0));
            spread = string.format( "%.3fmm", spread7 );
            spread_n = spread7;
            range = [[68±2]];
            lines = lines;
        }
        
        ret[7.1] = {
            description = [[Must exist a point with 33mm vertical thickness]];
            numeric_status = string.format( "%.3fmm", numeric_value71 );
            satisfied = #sep33 > 0;
            spread = string.format( "%.3fmm", spread71 );
            spread_n = spread71;
            range = [[≥33]];
        }
    end
    
    --Constraint 8 Evaluation
    do
        local length = C7.x + S7.r
        local satisfied = ((375-1) <= length) and (length <= 375)
        local spread = abs( length - (375 - 1/2) )
        
        local draw_line = { a = vec( 375-1, C7.y ), b = vec( 375, C7.y ), color = satisfied and "GREEN" or "RED" }
        
        ret[8] = {
            description = [[Overall blade length must be within 375-1]];
            range = [[375-1]];
            numeric_status = string.format( "%.3fmm", length );
            spread = string.format( "%.3fmm", spread );
            spread_n = spread;
            satisfied = satisfied;
            lines = { draw_line };
        }
    end
    
    --TODO: Need to re-arrange how values are returned and keys are used
    for key, val in pairs( ret ) do val.key = key end
    
    return ret
end
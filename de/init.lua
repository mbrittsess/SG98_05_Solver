print [[loading de\init.lua]]

local rand, max = math.random, math.max
local unpack = table.unpack or unpack

local PopulationSize = 128
local GenerationLimit = 25000

local ElementBounds = {
    { 35.0-0.2, 35.0 },
    { (263.9-1.0)*0.7, 263.9 },
    { (1.0)*0.7, 6.0 },
    { 240.0*0.4, 240.0*1.6 },
    { ((1.0-0.2)/2)*0.7, 6.0 },
    { 24.0, 27.0 },
    { (375.0-76.1)*0.9, (375-76.1)*1.1 },
    { 34.0*0.9, 34.0*1.1 },
    { 174.0*0.4, 174.0*1.6 }
}

local CrossoverConstant = 0.4
local ScalingFactor = 0.7
local VecSize = 9
local Vec = require( "vector" )( VecSize )

local function rand_draw ( low, up, numtodraw, ... )
    local exclusions = {}
    for _, ex in ipairs{ ... } do
        exclusions[ ex ] = true
    end
    
    local pool = {}
    for n = low, up do
        if not exclusions[n] then
            pool[ #pool+1 ] = n
        end
    end
    
    for i = 1, numtodraw do
        local j = rand( i+1, #pool )
        pool[i], pool[j] = pool[j], pool[i]
    end
    
    return unpack( pool, 1, numtodraw )
end

local function rand_1 ( PrevPopulation, Pop_i )
    local Pop = PrevPopulation.CurrentVectors
    local r1, r2, r3 = rand_draw( 1, #Pop, 3, Pop_i )
    return Pop[r1] + ScalingFactor*( Pop[r2] - Pop[r3] )
end

local function best_1( PrevPopulation, Pop_i )
    local Pop = PrevPopulation.CurrentVectors
    local Best_i = PrevPopulation.Best_i
    local r1, r2 = rand_draw( 1, #Pop, 2, Pop_i, Best_i )
    return Pop[ Best_i ] + ScalingFactor*( Pop[r1] - Pop[r2] )
end

local function current_to_best_1 ( PrevPopulation, Pop_i )
    local Pop = PrevPopulation.CurrentVectors
    local Best_i = PrevPopulation.Best_i
    local r1, r2 = rand_draw( 1, #Pop, 2, Pop_i, Best_i )
    return Pop[ Pop_i ] + ScalingFactor*( Pop[ Best_i ] - Pop[ Pop_i ] ) + ScalingFactor*( Pop[r1] - Pop[r2] )
end

local function best_2 ( PrevPopulation, Pop_i )
    local Pop = PrevPopulation.CurrentVectors
    local Best_i = PrevPopulation.Best_i
    local r1, r2, r3, r4 = rand_draw( 1, #Pop, 4, Pop_i, Best_i )
    return Pop[ Best_i ] + ScalingFactor*( Pop[r1] - Pop[r2] ) + ScalingFactor*( Pop[r3] - Pop[r4] )
end

local function rand_2 ( PrevPopulation, Pop_i )
    local Pop = PrevPopulation.CurrentVectors
    local r1, r2, r3, r4, r5 = rand_draw( 1, #Pop, 5, Pop_i )
    return Pop[r1] + ScalingFactor*( Pop[r2] - Pop[r3] ) + ScalingFactor*( Pop[r4] - Pop[r5] )
end

local MutationStrategies = {
    rand_1,
    best_1,
    current_to_best_1,
    best_2,
    rand_2
}

--[[ Returns the fitness value, and whether the solution is valid in terms of the constraints. A pretty ugly function, trying to re-use
as much pre-written code as I can. ]]
local EvaluateFitness
do
    local geom_analysis_func = dofile "geometry_analysis.lua"
    local constrain_analysis_func = dofile "constraint_analysis.lua"
    
    local NumConstraints = 9 --Hardcoded
    local MaxConstraintViolation = {} ; for i = 1, NumConstraints do MaxConstraintViolation[i] = 0.0 end
    local ConstraintNumbers = { 1, 2, 3, 4, 5, 6, 7, 7.1, 8 }
    
    -- Returns the fitness value, and whether all constraints are satisfied
    function EvaluateFitness ( TrialVector )
        local Geometry = geom_analysis_func( TrialVector )
        local Constraints = constrain_analysis_func( TrialVector, Geometry, nil ) --Third parameter isn't actually used
        
        local Spreads = {}
        local Valid = true
        for lin_i, i in ipairs( ConstraintNumbers ) do
            local Constraint = Constraints[i]
            local Spread = Constraint.spread_n
            Spreads[lin_i] = Spread
            Valid = Valid and Constraint.satisfied
            MaxConstraintViolation[lin_i] = max( MaxConstraintViolation[lin_i], Spread )
        end
        local Num, Denom = 0.0, 0.0
        for i, Constrain in ipairs( Spreads ) do
            if Constrain ~= 0 then
                local w = 1 / MaxConstraintViolation[i]
                Num = Num + w*Spreads[i]
                Denom = Denom + w
            end
        end
        local Fitness = Num / Denom
        
        local Valids = {}
        for lin_i, i in ipairs( ConstraintNumbers ) do
            Valids[i] = Constraints[i].satisfied and "T" or "F"
        end
        TrialVector.Valids = table.concat( Valids )
        
        return Fitness, Valid
    end
end

local function Step ( PrevPopulation )
    local PrevGeneration = PrevPopulation.CurrentVectors
    
    local MutatedVectors = {}
    local TrialVectors   = {}
    local NewVectors     = {}
    
    local Best_i = 1
    local AnyValid = false
    
    for Pop_i = 1, #PrevGeneration do
        local OldVector = PrevGeneration[ Pop_i ]
        -- Select a mutation function, get mutated vector
        local MutationFunction = MutationStrategies[ rand( 1, #MutationStrategies ) ]
        local MutatedVector = MutationFunction( PrevPopulation, Pop_i )
        MutatedVectors[ Pop_i ] = MutatedVector
        
        --[[ Next we need to generate the trial vector. It's a crossover of the original vector
        and the mutated vector, with any out-of-bounds elements reinitialized randomly. ]]
        local TrialVector = {}
        local j_rand = rand( 1, VecSize )
        for j = 1, VecSize do
            if (j == j_rand) or (rand() <= CrossoverConstant) then
                local val = MutatedVector[j]
                local low, up = ElementBounds[j][1], ElementBounds[j][2]
                if not ( low <= val and val <= up ) then
                    val = low + rand()*(up-low)
                end
                TrialVector[j] = val
            else
                TrialVector[j] = OldVector[j]
            end
        end
        TrialVector = Vec( unpack( TrialVector ) )
        TrialVectors[ Pop_i ] = TrialVector
        
        -- Evaluate fitnesses and select the most-fit one to propagate to the next generation. Ties go to the new one.
        TrialVector.Fitness, TrialVector.Valid = EvaluateFitness( TrialVector )
        local NewVector
        NewVector = (TrialVector.Fitness <= OldVector.Fitness) and TrialVector or OldVector
        if     ((TrialVector.Valid == OldVector.Valid) and (TrialVector.Fitness < OldVector.Fitness))
            or (TrialVector.Valid and not OldVector.Valid)
        then
            NewVector = TrialVector
        else
            NewVector = OldVector
        end
        NewVectors[ Pop_i ] = NewVector
        
        AnyValid = AnyValid or NewVector.Valid
        if     ((NewVector.Valid == NewVectors[ Best_i ].Valid) and (NewVector.Fitness < NewVectors[ Best_i ].Fitness))
            or (NewVector.Valid and not NewVectors[ Best_i ].Valid)
        then
            Best_i = Pop_i
        end
    end
    
    return {
        GenerationNumber = PrevPopulation.GenerationNumber + 1;
        
        OldVectors = PrevGeneration;
        MutatedVectors = MutatedVectors;
        TrialVectors = TrialVectors;
        CurrentVectors = NewVectors;
        
        Best_i = Best_i;
        AnyValid = AnyValid;
        BestFitness = NewVectors[ Best_i ].Fitness;
    }
end

local function main ( )
    local PopulationSeeds = {}
    for Element_i = 1, VecSize do
        --Element seeds are uniformly distributed across the element bounds
        local ElementSeeds = {}
        local Low, Up = ElementBounds[ Element_i ][1], ElementBounds[ Element_i ][2]
        for Seed_i = 1, PopulationSize do
            ElementSeeds[ Seed_i ] = Low + (Seed_i-1)*((Up-Low)/(PopulationSize-1))
        end
        
        --Then we shuffle them
        for Seed_i = 1, PopulationSize-1 do
            local Seed_k = rand( Seed_i+1, PopulationSize )
            ElementSeeds[ Seed_i ], ElementSeeds[ Seed_k ] = ElementSeeds[ Seed_k ], ElementSeeds[ Seed_i ]
        end
        
        PopulationSeeds[ Element_i ] = ElementSeeds
    end
    
    local InitialVectors = {}
    local Best_i = 1
    local AnyValid = false
    for Pop_i = 1, PopulationSize do
        local Elements = {}
        for Element_i = 1, VecSize do
            Elements[ Element_i ] = PopulationSeeds[ Element_i ][ Pop_i ]
        end
        local InitVector = Vec( unpack( Elements ) )
        local Fitness, Valid, Num, Denom = EvaluateFitness( InitVector )
        InitVector.Fitness, InitVector.Valid = Fitness, Valid
        InitialVectors[ Pop_i ] = InitVector
        if InitVector.Fitness < InitialVectors[ Best_i ].Fitness then
            Best_i = Pop_i
        end
        AnyValid = AnyValid or InitVector.Valid
    end
    
    local InitialPopulation = {
        GenerationNumber = 1;
        
        CurrentVectors = InitialVectors;
        
        Best_i = Best_i;
        AnyValid = AnyValid;
        BestFitness = InitialVectors[ Best_i ].Fitness;
    }
    
    local Population = InitialPopulation
    PrintPopulationState( Population )
    for GenNumber = 2, GenerationLimit do
        Population = Step( Population )
        PrintPopulationState( Population )
    end
    
    PrintFinalPopulationState( Population )
end

function PrintPopulationState ( Pop )
    print( string.format( "Generation #%i: Best Fitness %.6f (%s), Any Valid? %s %s", Pop.GenerationNumber, Pop.BestFitness, Pop.CurrentVectors[ Pop.Best_i ].Valids, Pop.AnyValid and "Yes" or "No", Pop.CurrentVectors[ Pop.Best_i ]:tostring( "%.3f" ) ) )
end

function PrintFinalPopulationState ( Pop )
    local BestCandidate = Pop.CurrentVectors[ Pop.Best_i ]
    print( string.format( "Best candidate: fitness %.6f, %svalid,\n    %s", BestCandidate.Fitness, BestCandidate.Valid and "" or "not ", BestCandidate:tostring( "%.3f" ) ) )
end

return main
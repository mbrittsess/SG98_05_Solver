--[[Implements the conventional Differential Evolution algorithm.]]
local de_random = require "de.random"
local random = math.random
local _ = require "moses"

local Step

--[[Options list:
    * Dimensionality = integer, 1 .. +inf
    * PopulationSize = integer, 6 .. +inf
    * Bounds = array with 'Dimensionality' elements, each is a table containing keys 'Upper' and 'Lower' which are finite real numbers, where 'Lower' < 'Upper'
    * ScalingFactor = positive finite number (0.0 < ScalingFactor < +inf)
    * CrossoverConstant = number, 0.0 <= CrossoverConstant < 1.0
    * FitnessFunction = function, takes in single vector, returns finite real number
    * Stopping =
        * positive finite number (0.0 < Stopping < +inf), stops when span of all elements of all vectors are less than 'Stopping'
        * function, takes state table as parameter, returns boolean, stops when returns true]]
local function CreateMinimizationProblem ( options )
    --Validate options.
    
    
    local state = setmetatable( {}, {
        __index = _G
    } )
end

--TODO: Implement vector operations

--Mutation Strategies
local function DE_rand_1 ( _ENV, i )
    local r1, r2, r3 = de_random.mutation_index_selection( PopulationSize, i, 3 )
    local X, F = Population, ScalingFactor
    return X[r1] + F*( X[r2] - X[r3] )
end
local function DE_best_1 ( _ENV, i )
    local best_i = BestVectorIndex
    local r1, r2 = de_random.mutation_index_selection( PopulationSize, i, 2, best_i )
    local X, F = Population, ScalingFactor
    return X[best_i] + F*( X[r1] - X[r2] )
end
local function DE_currenttobest_1 ( _ENV, i )
    local best_i = BestVectorIndex
    local r1, r2 = de_random.mutation_index_selection( PopulationSize, i, 2, best_i )
    local X, F = Population, ScalingFactor
    return X[i] + F*( X[best_i] - X[i] ) + F*( X[r1] - X[r2] )
end
local function DE_best_2 ( _ENV, i )
    local best_i = BestVectorIndex
    local r1, r2, r3, r4 = de_random.mutation_index_selection( PopulationSize, i, 4, best_i )
    local X, F = Population, ScalingFactor
    return X[best_i] + F*( X[r1] - X[r2] ) + F*( X[r3] - X[r4] )
end
local function DE_rand_2 ( _ENV, i )
    local r1, r2, r3, r4, r5 = de_random.mutation_index_selection( PopulationSize, i, 5 )
    local X, F = Population, ScalingFactor
    return X[r1] + F*( X[r2] - X[r3] ) + F*( X[r4] - X[r5] )
end

local mutation_strategies = { DE_rand_1, DE_best_1, DE_currenttobest_1, DE_best_2, DE_rand_2 }
local select_random_strategy = _.bind( de_random.uniform_random_choice, mutation_strategies )

function Step ( _ENV )
    local PreviousGeneration = Population
    local PreviousGenerationNumber = GenerationNumber
    
    local MutantVectors = {}
    for i = 1, PopulationSize do
        local MutationStrategy = select_random_strategy()
        local MutantVector = MutationStrategy( _ENV, i )
        MutantVectors[i] = MutantVector
    end
    
    local TrialVectors = {}
    for i = 1, PopulationSize do
        local j_rand = random( Dimensionality )
        local TrialVector = {}
        local MutantVector = MutantVectors[i]
        local OrigVector = Population[i]
        for j = 1, Dimensionality do
            local ElementValue
            if (random() <= CrossoverConstant) or (j == j_rand) then
                TrialVector[j] = MutantVector[j]
            else
                TrialVector[j] = OrigVector[j]
            end
            if not ((Bounds[j].Lower <= TrialVector[j]) and (TrialVector[j] <= Bounds[j].Upper)) then
                TrialVector[j] = Bounds[j].Lower + random()*(Bounds[j].Upper-Bounds[j].Lower)
            end
        end
        TrialVectors[i] = TrialVector
    end
    
    local NewPopulation, NewPopulationFitnesses, Evolved = {}, {}, {}
    for i = 1, PopulationSize do
        local TrialFitness, OrigFitness = FitnessFunction( TrialVectors[i] ), PopulationFitnesses[i]
        if TrialFitness <= OrigFitness then
            NewPopulation[i] = TrialVectors[i]
            Evolved[i] = true
        else
            NewPopulation[i] = Population[i]
            Evolved[i] = false
        end
    end
    
    local BestNewIndex, BestNewFitness = 1, NewPopulationFitnesses[i]
    for i = 2, PopulationSize do
        if NewPopulationFitnesses[i] < BestNewFitness then
            BestNewIndex = i
            BestNewFitness = Fitness
        end
    end
    
    Population = NewPopulation
    PopulationFitnesses = NewPopulationFitnesses
    BestVectorIndex = BestNewIndex
    GenerationNumber = GenerationNumber + 1
    
    return StoppingFunction( _ENV )
end
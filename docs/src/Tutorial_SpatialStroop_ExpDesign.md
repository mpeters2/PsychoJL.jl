# makeExperimentalDesign()


`makeExperimentalDesign()` algorithmically makes the control variables for the experiment.

```julia
function makeExperimentalDesign(sides::Vector{String}, congru::Int64, Reps::Int64)
 
    numTrials = length(sides) * congru * Reps      # algorithmically calculate the number of trials in our experiment
    trialSides = []                                # We'll append strings for leftSide or rightSide to this array
    trialCongru = zeros(Int64, numTrials)          # this will holder the target congruencey control variable that we will fill below

    trial = 1
    for r in 1:repetitions                         # we do this outer because it makes block randomization easier
        for sides in sides      # stimulus sides
            for c in 1:congru      # response congruency
                push!(trialSides, sides)      # sides is a string
                trialCongru[trial] = (c*2)-3      # -1 = incongruent, +1 = congruent
                trial += 1
            end 
        end
    end
        
    # Next, create the random order for the trials.  This is not fancy block randomization.
    order = collect(1:numTrials)      # Fill an array with all possible trial numbers
    shuffleOrder = shuffle(order)      # Shuffle the array
    #--------------
    # Below we fill the struct with info about the experimental design and return it.
    # Information is added to fields in the order that the fields are defined in the struct.
    designInfo = ExperimentDesign(numTrials, trialSides, trialCongru, shuffleOrder)
    return designInfo
end

```
\

Let's take a look at the function definition.
```julia
function makeExperimentalDesign(sides::Vector{String}, congru::Int64, Reps::Int64)
 
    numTrials = length(sides) * congru * Reps      # algorithmically calculate the number of trials in our experiment
    trialSides = []                                # We'll append strings for leftSide or rightSide to this array
    trialCongru = zeros(Int64, numTrials)  
```

`function makeExperimentalDesign(sides::Vector{String}, congru::Int64, Reps::Int64)`
* Takes three parameters:
  - `sides::Vector{String}` is a vector of strings (left or right). Since there are two entries in our constant vector `const screenSides = ["leftSide", "rightSide"]`, which is passed to `makeExperimentalDesign`, this implies that there are two levels of this variable.  Of course, we could have more levels ("upSide", "downSide"), but if we had decided to do that, we would have to make sure that the drawing functions could deal with *up* and *down*, and likewise, we would need four responses instead of 2.  I could have done this with an integer (see trialCongru below) instead of a list of strings, but I wanted to show you the different ways this could have been implemented.
  - `congru::Int64` is an integer enumerating the number of congruencies.  It was originally defined as one of our constants (`const congruencies = 2`)
  - `Reps::Int64` is the number of repetitions of each cell of our design. See [Constants](@ref) for a discussion of how reptitions affects the number of trials in the experiment.\

!!! note "Typing function parameters"
    I did not need to [type](@ref variableTyping) the variables (e.g. indicate that *sides* was a Vector{String}) in the function definition.  However, it is good practice, and indicates to the reader the type of variable the function is expecting, without have to sleuth through the code (I could have also put it in the comments).
---
Let's take a look at the next few lines of code.
```julia
    numTrials = length(sides) * congru * Reps      # algorithmically calculate the number of trials in our experiment
    trialSides = []                                # We'll append strings for leftSide or rightSide to this array
    trialCongru = zeros(Int64, numTrials)  
```
`numTrials = length(sides) * congru * Reps`
* This calculates the number of trials in our experiment. Its basically the level of each control variable times the number of repetitions. numTrials is used later for things such as determining the length of the vector `trialCongru` (and indirectly `trialSides`) and controling how many trials to present.  By doing it algorithmically, we can change one constant, such as `repetition`s (which is pased to the parameter `Reps`), it it will automatically the number of trials throughout your code.
\
The next two variables will have an entry for each trial of the experiment:\
`trialSides = []`
* Is an empty vector that will hold the side the stimulus will appear for each trial. 

`trialCongru = zeros(Int64, numTrials)`
 * This will hold the congruency for each trial.  I'm initially filling it with zeros, which will later be replaced with +1s and -1s, indicating whether the trial is congruent or incongruent.
 ---
Let's take a look a the series of `for` loops that is used to fill the control variables. The importance of this structure is that you can easily change a variable such as *repetitions*, and it will automatically fill in the correct values (and correct number of values!)

```julia
    trial = 1
    for r in 1:repetitions                         # we do this outer because it makes block randomization easier
        for sides in sides      # stimulus sides
            for c in 1:congru      # response congruency
                push!(trialSides, sides)      # sides is a string
                trialCongru[trial] = (c*2)-3      # -1 = incongruent, +1 = congruent
                trial += 1
            end 
        end
    end
```
\
`trial = 1` 
* We will use the variable `trial` to update the index of the vectors as we loop through the *for* loops. Keep in mind that in Julia, indexing starts at 1, and not 0.\
`for r in 1:repetitions` 
* ...encloses the remaining *for* loops, repeating them for as many repetitions as there are.  I put this in the outer loop as it allows for easier block randomization (randomize blocks of conditions), which I chose not to do for this simple example.
`for sides in sides` 
* ...iterates over the vector *sides*, which was passed the constant *screenSides* (`const screenSides = ["leftSide", "rightSide"]`). I did this so that you can see that there is more than one way to iterate through a *for* loop.
`for c in 1:congru` 
* ...iterates from 1 to congru (which was passed the constant `const congruencies = 2`. Keep in mind that Julia indexes start at 1 and not 0.

```julia
                push!(trialSides, sides)      # sides is a string
                trialCongru[trial] = (c*2)-3      # -1 = incongruent, +1 = congruent
                trial += 1
```
* `push!(trialSides, sides)` appends (in place) sides to the vector trialSides.  Normally in Julia, you wants to shy away from growing vectors and array for performance reasons, but it does not matter in this situation, as this computationally trivial.
* `trialCongru[trial] = (c*2)-3` assigns the value of -1 or +1 to the vector *trialCongru* at index *trial*. In performance situations (this is not one of them), you ideally want to premake your vectors and change their values (as we've done here), rather than growing them by using *push!()*.
* `trial += 1` increments the index variables *trial*.
---
This next section randomizes the order of the trials:
```julia
    # Next, create the random order for the trials.  This is not fancy block randomization.
    order = collect(1:numTrials)      # Fill an array with all possible trial numbers
    shuffleOrder = shuffle(order)      # Shuffle the array
```
* `order = collect(1:numTrials)` returns a list of numbers starting at 1 and stopping at *numTrials*. `1:numTrials` is an iterator, and *collect* turns that iterator into a collection, in this case a Vector{Int64}.
  - `collect(start:[step]:stop)` is equivalent to Python's `list(range([start], stop, [step]))` or `numpy.arange([start, ]stop, [step, ])`
* `shuffleOrder = shuffle(order)` uses Julia's *shuffle* function to randomly shuffle the order of the trials.
---
Finally, we make an instance of the ExperimentDesign struct and fill its four fields with our variables.  We then return it, where it is assigned to the variable *exp* in `main()`:
```julia
    #--------------
    # Below we fill the struct with info about the experimental design and return it.
    # Information is added to fields in the order that the fields are defined in the struct.
    designInfo = ExperimentDesign(numTrials, trialSides, trialCongru, shuffleOrder)
    return designInfo
end

```


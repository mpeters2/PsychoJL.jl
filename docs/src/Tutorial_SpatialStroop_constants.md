# Constants

Although global variables are frowned-upon, global constants do not count as global variables because they are not
*variables*, meaning that they can not vary.\

I like to place my constants at the top of the file.  Part of the reason is consistency (I always know where to find them).
The other reason is that Julia compiles files from the top down, and must know something about these constants before they
are used in a function.\

```julia
using PsychExpAPIs
using Random
using Printf

#------------
# Experiment design/control variables
const screenSides = ["leftSide", "rightSide"]    # global constants are kosher in Julia,  but not global variables.
const congruencies = 2
const repetitions = 15
#------
const leftX = -0.05                           # x values for left side
const rightX = +0.05                          # x values for right side

#------------
# Experiment design/control variables
mutable struct ExperimentDesign           # We'll pass this around instead of globals
	numTrials::Int64                      # Total number of trials
	trialSide::Vector{String}             # Determines which side the stimulus will appear.
	trialCongruency::Vector{Int64}        # Is the word is congruent with the side it appears?
	randomOrder::Vector{Int64}            # The order in which the trials will be presented.
end

```
\
This first group of constants is used to help make the experimental design and control variables:

`const screenSides = ["leftSide", "rightSide"]`
* This is vector containing a list of the sides of the screen the target can appear. Because the list has two entries,
it implies that the screen side variable will have two levels (but it does not need to be the case).
`const congruencies = 2`
 * This constant will be used to control the number of levels of our future congruency variable.
`const repetitions = 15`
* Is the number of times each cell in our design will be repeated.  At first glance, it might appear that we have a 2x2 design (congruency x sides), which implies that we have 4 cells to our design.  When performing the data analsyis, you will probably collapse across the side variables, so its really a design with 2 levels (congruent and incongruent). This means that, in effect, you will have 30 data points per cell [since you are combining sides], which should yield 60 total trials.  This also illustrates the differenc between control (sides) and indpendent (but also control) variables [congruency].
* 2 (sides) x 2 (congruency) = 4 cells. 4 (cells) x 15 (repetitions) = 60 trials.
\
Our second group of constants is used to help make the experimental design and control variables:

`const leftX = -0.05`
* This is the left offset from the center of the screen. We'll be using PsychoPy coordinates, where the X and Y values are a percentage of the screen height and the origin is in the center of the screen.
`const rightX = +0.05`
 * This constant is the right offset for when the word appears to the right of fixation.


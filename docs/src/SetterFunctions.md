## Setter functions

Setter function are used to set the values of the various/struct objects, and should be
used instead of accessing the fields directly. The reason for not accessing them directly is that 
often the data you send to the objects needs to be translated to a different representation.\
\
For example:
 * "Red" needs to be translated to [255,0,0,255]
 * If you are using PsychoPy coordinatse, the coordinate [-0.6, +0.5] might need to be translated to [100, 0].

### Color setting functions
 see [Color spaces in PsychoJL](@ref) and [Colors in PsychoJL](@ref)

`setColor(someObject::stimulusType, color::Union{String, Vector{Int64}, Vector{Float64})`\
 * where the stimulusType is textStim or Line

`setLineColor(someObject::stimulusType, color::Union{String, Vector{Int64}, Vector{Float64})`\
 * where the stimulusType is Rect, Ellipse, or Circle

 `setFillColor(someObject::stimulusType, color::Union{String, Vector{Int64}, Vector{Float64})`\
 * where the stimulusType is Rect, Ellipse, or Circle

### Position setting functions
 see [Coordinate systems](@ref) and [`setPos()`](@ref manualSetPosHeader)

 Because coordinates may need to be translated to another coordinate system, you should use the `setPos()` function
 to update your stimulus' position.  The example code below draws a circle, and updates its position periodically.

 Example:
```julia

using PsychExpAPIs
# Moving Ball Exampile
#-=============================
function main()
    InitPsychoJL()
    # make a new floating window using the PsychoPy coordinate space and and color space
    win = Window( [1280, 720], false; colorSpace = "PsychoPy", coordinateSpace = "PsychoPy", timeScale = "seconds")			#	2560, 1440			[1000,1000]
	
    myCirc = Circle(win,
                    [ 0.0, 0.0],                            # screen center
                    0.1,                                    # radius is 20% of the screen height
                    fillColor = [+1.0,-1.0,-1.0, +1.0],     # r,g,b, alpha
                    lineColor = "yellow",                   # has color names
                    fill = true)
  
    draw(myCirc)                           # everything draws into memory
    flip(win)                              # copies to screen
    waitTime(win, 0.5)                     # wait one second

    for i in 0:10
        x = -.5 + (i*0.1)                  # move circle to the right by 10% of the height
        setPos(myCirc, [x, 0])             # Use setPos() to convert PsychoPy to SDL coordinates
        draw(myCirc)                       # everything draws into memory

        flip(win)                          # copies to screen
        waitTime(win, 0.1)
    end

    closeWinOnly(win)
end
#-===============================================================


main()

```
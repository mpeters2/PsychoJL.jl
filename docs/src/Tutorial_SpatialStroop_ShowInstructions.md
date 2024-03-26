# showInstructions()

After `getSubjectInfo()`, the next function that is called in `main()` is `showInstructions()`:


```julia
function main()

    exp = makeExperimentalDesign(screenSides, congruencies, repetitions)        # returns an ExperimentDesign struct

    InitPsychoJL()                                # Do this before calling any PsychoJL functions
    subjID = getSubjectInfo()                    # put up a dialog asking for subject's information
    subjFile = openDataFile(subjID)
    
    win = Window( [2560,1440], false, coordinateSpace = "PsychoPy")            # 5120 × 2880, or 2560 x 1440    [1000,1000]
    mouseVisible(false)                            # hide mouse cursor

>>> showInstructions(win)                  
    ...
end
```

`showInstructions()` uses a graphics window to present the instructions to the subject. This is the prefered way, as dialog boxes may render behind the main window while in fullscreen mode.

```julia
function showInstructions(win::Window)
    
    message1 = "Press the '/' key if you see the word 'Left'."
    TextStim1 = TextStim(win, message1, [0.0,  +0.05 ])                    # PsychoPy coordinates are floats, so need 0.0 instead of 0.
    setColor(TextStim1, [255, 255, 255])
    TextStim1.scale = 2.0
    TextStim1.horizAlignment = 0                    # center aligned
    draw(TextStim1)

    message2 = "Press the 'z' key if you see the word 'Right'."
    TextStim2 = TextStim(win, message2, [0.0, -0.05 ])
    setColor(TextStim2, "white")
    TextStim2.scale = 2.0
    TextStim2.horizAlignment = 0                    # center aligned
    draw(TextStim2)

    message3 = "Press the space bar when you are ready to continue."
    TextStim3 = TextStim(win, message3, [0.0, -0.15 ])
    setColor(TextStim3, "yellow")
    TextStim3.scale = 1.5
    TextStim3.horizAlignment = 0                    # center aligned
    draw(TextStim3)
   
    flip(win)
    getKey(win)
end
```
\

Let's take a look at the first three lines of code.
```julia
function getSubjectInfo()    
    done = false
    subjID = ""                                    # ensures that subjID is not local to the while loop
```

`done = false`
* This is our flag for the following *while* loop.
`subjID = ""`
* This is defines our SubjID variable (a blank string at this point). To make it available outside of the `while` loop, we need to define it at the function-level.  Otherwise, the `while` loop would run just fine (it would make a new variable called *subjID* and assign values to it), but once we exited the `while` loop, the program would crash at the last line `return subjID`, as *subjID* does not exist at that scope.\



!!! note "Variable scope in Julia"
    Like Python, you can define and assign variables on-the-fly in Julia, but scoping is different. Variables defined in a loop or in an *if* statement, live only within that loop or if statement. If you wish for them to be available outside the loop or *if* statement, they must be initially defined at a higher scope (e.g. function-level). Initializing it at the function level prevents that from happening.

---

```julia
    while done == false
        subjInfo= Dict("Particpant" => "")
        dictDlg = DlgFromDict(subjInfo)
        ...
    end
```    

The first two lines of the *while* statment are used to open a dialog using the DlgFromDict() function.

`subjInfo= Dict("Particpant" => "")`
* Makes a dictionary with one key ("Participant") and one value ("").  When using `DlgFromDict`,the key is the label in the dialog, and the value determines the type of input.  In this case, the value is a [empty] string, which signals `DlgFromDict` to make an input box.
`dictDlg = DlgFromDict(subjInfo)`
* Makes the dialog window and returns a vector containing the button that was clicked as well as a dictionary of repsonses. 
* For example, if you were to put `println(dictDlg)` after after the DlgFromDict line and click the "Cancel" button, it would print `Any["Cancel", Dict("Particpant" => " ")]`, with "Cancel" being the button that was clicked, and `Dict("Particpant" => " ")` being the dictionary of responeses.\

see [`DlgFromDict(dlgDict::Dict)`](@ref)\

!["picture of the dialog box"](assets/subjectDialog_small.png)
---
Let's take a look at the following statements:
```julia
        if dictDlg[1] == "OK"
            println(subjInfo)
        else
            print("User Cancelled")
            displayMessage("User Cancelled")
            waitTimeMsec(3000)
            exit()
        end
        subjID =  dictDlg[2]["Particpant"]
        subjID = String(strip(subjID, ' '))            # sometimes returns an extra space
```
The `if` statement checks to see if the "OK" button was pressed, and if so, it prints the value of `subjInfo` into the terminal. Otherwise (*else*), a displayMessage dialog tells the experimenter that the user canceled, waits 3 seconds, and closes the program.\
\
The second entry [2] of the returned `dictDlg` vector is a dictionary, and we are accessing the value tied to the ["Participant"] key. The following line stripes out any inadvertent white space (e.g. `" 25"` or `"25 "`). 

---

The next bit of code makes the full filename (`*` appends strings in Julia, much like `+` in Python),then checks to see if the file already exists, skipping subject "999" (my debugging subject ID).  If the file already exists, it displays an error message.  If file does not exist, we break out of the *while* loop by setting `done` to `true`.

```julia
        # check if the filename is valid (length <= 8 & no special char)
        fileName = "subj" * subjID * ".txt"
        if isfile(fileName) == true && subjID != "999"            # 999 is my demo subject
            message = fileName * " already exists!"
            errorMessage( message)
        else
            done = true
        end
```
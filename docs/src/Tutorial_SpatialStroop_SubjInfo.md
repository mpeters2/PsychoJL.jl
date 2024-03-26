# getSubjectInfo()

After `makeExperimentalDesign()`, the next function that is called in `main()` is `getSubjectInfo()`:


```julia
function main()

    exp = makeExperimentalDesign(screenSides, congruencies, repetitions)        # returns an ExperimentDesign struct

    InitPsychoJL()                                # Do this before calling any PsychoJL functions
>>> subjID = getSubjectInfo()                    # put up a dialog asking for subject's information
    subjFile = openDataFile(subjID)    
    ...
end
```

`getSubjectInfo()` puts up a dialog box, asks for the subject's ID, and confirms that the file does not already exit.

```julia
function getSubjectInfo()    
    done = false
    subjID = ""                                    # ensures that subjID is not local to the while loop
    
    while done == false
        subjInfo= Dict("Particpant" => "")
        dictDlg = DlgFromDict(subjInfo)
        if dictDlg[1] == "OK"
            println(subjInfo)
        else
            print("User Cancelled")
            displayMessage("User Cancelled")
            waitTimeMsec(3000)
            exit()
        end
        subjID =  dictDlg[2]["Particpant"]
        subjID = String(strip(subjID, ' '))                        # sometimes returns an extra space

        println("subjID = ", subjID,"\n")
    
        # check if the filename is valid (length <= 8 & no special char)
        fileName = "subj" * subjID * ".txt"
        if isfile(fileName) == true && subjID != "999"            # 999 is my demo subject
            message = fileName * " already exists!"
            errorMessage( message)
        else
            done = true
        end
    end
    return subjID
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
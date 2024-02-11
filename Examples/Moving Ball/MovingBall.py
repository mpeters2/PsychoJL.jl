#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 22 11:23:28 2021

@author: MattPetersonsAccount
"""
from psychopy import visual, core, event
import sys

# make a new floating window that is filled with black
win = visual.Window( fullscr = False, color=(-1, -1, -1), units="height")
#=============================
def main():
	myCirc = visual.Circle(win,
             	units="height",
				radius = 0.1,               # 20% of the screen height
				edges = 32,
                	pos=( -1, 1),	# screen center
                	fillColor = [+1,-1,-1],	# r,g,b
                	lineColor = "yellow",       	# has color names
                	interpolate=True)
	myCirc.draw()                           # everything draws into memory
	win.flip()                              # copies to screen
	core.wait(2)                            # wait one second


	for i in range(10):
		x = -.5 + (i*0.1)
		myCirc.pos = (x, 0)
		myCirc.draw()                           # everything draws into memory
		#print(x)
		win.flip()                              # copies to screen
		core.wait(0.1)


	win.close()
	core.quit()
	sys.exit(0)
	#exit()

#===============================================================



if __name__ == "__main__":
	main()
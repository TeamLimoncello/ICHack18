set x to 30

set y to 5

set l to 50 -- click same location 50 times

do shell script "

/usr/bin/python <<END

import sys

import time

from Quartz.CoreGraphics import *

def mouseEvent(type, posx, posy):

    theEvent = CGEventCreateMouseEvent(None, type, (posx,posy), kCGMouseButtonLeft)

    CGEventPost(kCGHIDEventTap, theEvent)

def mousemove(posx,posy):

    mouseEvent(kCGEventMouseMoved, posx,posy);

def mouseclick(posx,posy):

    mouseEvent(kCGEventLeftMouseDown, posx,posy);

    mouseEvent(kCGEventLeftMouseUp, posx,posy);

    ourEvent = CGEventCreate(None);

    currentpos = CGEventGetLocation(ourEvent);             # Save current mouse position

    for x in range(0, " & l & "):

        mouseclick(" & x & "," & y & ");

        mousemove(int(currentpos.x),int(currentpos.y));      # Restore mouse position

END"

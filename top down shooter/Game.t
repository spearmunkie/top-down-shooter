%by saurabh
include "declarations.t"
fcn GameWin : boolean
    loop
	Input.KeyDown (key)
	mousewhere (mx, my, mb)
	if key ('w') and player (human).Move (1, mx, my, shiftX, shiftY, false) then
	    if ((py + 4) >= (maxy div 2)) and tileSystem (myMap).MoveMap (0, -4) then
		shiftY += 4
	    else
		py += 4
	    end if
	end if
	if key ('s') and player (human).Move (2, mx, my, shiftX, shiftY, false) then
	    if ((py - 4) <= (maxy div 2)) and tileSystem (myMap).MoveMap (0, 4) then
		shiftY -= 4
	    else
		py -= 4
	    end if
	end if
	if key ('d') and player (human).Move (3, mx, my, shiftX, shiftY, false) then
	    if ((px + 4) >= (maxx div 2)) and tileSystem (myMap).MoveMap (-4, 0) then
		shiftX += 4
	    else
		px += 4
	    end if
	end if
	if key ('a') and player (human).Move (4, mx, my, shiftX, shiftY, false) then
	    if ((px - 4) <= (maxx div 2)) and tileSystem (myMap).MoveMap (4, 0) then
		shiftX -= 4
	    else
		px -= 4
	    end if
	end if

	if key ('1') then
	    player (human).changeWeapon (1)
	    equip := 1
	elsif key ('2') then
	    player (human).changeWeapon (2)
	    equip := 2
	elsif key ('3') then
	    player (human).changeWeapon (3)
	    equip := 3
	end if
	if player (human).Move (0, mx + shiftX, my + shiftY, shiftX, shiftY, false) then
	end if
	tileSystem (myMap).reDraw

	if mb > 0 and weapon (equip) > 0 then
	    if player (human).shoot (player (human).Angle) then
		weapon (equip) -= 1
	    end if
	end if
	Pic.Draw (playerPic (round (player (human).Angle / 10)), px - 3, py, picMerge)
	enemyReact
	if player (human).Move (0, mx + shiftX, my + shiftY, shiftX, shiftY, true) then
	end if
	playerWarp (player (human).currentX, player (human).currentY)
	triggers
	exit when tileSystem (myMap).currentType (round (player (human).currentX), round (player (human).currentY)) = 27 or player (human).currentHealth <= 0
	locate (1, 1)
	colour (yellow)
	put "Health:", player (human).currentHealth / 600 * 100 : 0 : 2, "%" ..
	locate (2, 1)
	put "Ammo:", weapon (equip) ..
	View.Update
	Time.DelaySinceLast (round (1000 / 12))
    end loop
    result player (human).currentHealth > 0
end GameWin


View.Set ("graphics:610;250,nobuttonbar,noecho,nocursor")
fade
var PicID : int := Pic.FileNew ("tiles/instruct.bmp")
Pic.Draw (PicID, 0, 0, picCopy)
var useless : string (1)
getch (useless)

View.Set ("graphics:250;240,offscreenonly,nobuttonbar")
colour (yellow)
colourback (black)
cls
put "Level 1"
View.Update
delay (2000)
proc resetPlayer
    player (human).Health (600)
    if weapon (1) < 1 then
	weapon (1) := 1
    end if
    
    if weapon (2) < 15 then
	weapon (2) := 15
    end if
    
    if weapon (3) < 30 then
	weapon (3) := 30
    end if
    
    rKey := false
    bKey := false
    gKey := false
end resetPlayer

var level : string := "level"
var num : int := 1
var Won : boolean
loop
    exit when not File.Exists (level + intstr (num) + "/map2.txt")
    if num > 1 then
	put "On to level ", num
	View.Update
	delay (2000)
    end if
    resetPlayer
    load (level + intstr (num) + "/map2", 1, 1)
    Won := GameWin
    if Won = false then
	exit
    else
	fade
	put "You win!!!" ..
	View.Update
    end if
    num += 1
end loop
if Won = true then
    put "More lvls coming soon"
else
    fade
    put "HAHAHAHA!! You suck!!!"
end if
View.Update

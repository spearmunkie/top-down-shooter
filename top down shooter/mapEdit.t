var dx, dy : int
var answer : string
var tiles : flexible array 0 .. 0 of int
var enemy : flexible array 0 .. 0 of
    record
	sX, sY : int
	eX, eY : int
	done : boolean
    end record
var TilePic : array 0 .. 26 of int
for x : 0 .. 17
    TilePic (x) := Pic.FileNew ("tiles/" + intstr (x) + ".bmp")
end for
TilePic (18) := Pic.FileNew ("tiles/rKey.bmp")
TilePic (19) := Pic.FileNew ("tiles/bKey.bmp")
TilePic (20) := Pic.FileNew ("tiles/gKey.bmp")
TilePic (21) := Pic.FileNew ("tiles/w1.bmp")
TilePic (22) := Pic.FileNew ("enemy.bmp")
TilePic (23) := Pic.FileNew ("tiles/18.bmp")
TilePic (24) := Pic.FileNew ("tiles/20.bmp")
TilePic (25) := Pic.FileNew ("tiles/21.bmp")
TilePic (26) := Pic.FileNew ("tiles/22.bmp")
var cx, cy : int := 0
fcn Array (x, y : int) : int
    result dy * x + y
end Array
proc reDraw
    for x : 0 .. dx - 1
	for y : 0 .. dy - 1
	    Pic.Draw (TilePic (tiles (Array (x, y))), 16 * x + cx, y * 16 + cy, picCopy)
	end for
    end for
end reDraw
var warp : flexible array 0 .. 0 of
    record
	atX, atY, destinationX, destinationY : int
	map : string
    end record

proc setWarpPoints (map : string)
    var atX, atY, destinationX, destinationY, Wpoints : int
    var warpMap : string
    var fileName : string := map
    var fileNo : int
    new warp, 0

    if File.Exists (map) then
	open : fileNo, fileName, get
	get : fileNo, Wpoints
	new warp, Wpoints
	for x : 1 .. Wpoints
	    get : fileNo, warp (x).atX
	    get : fileNo, warp (x).atY
	    get : fileNo, warp (x).destinationX
	    get : fileNo, warp (x).destinationY
	    get : fileNo, warp (x).map
	end for
	close : fileNo
    end if
end setWarpPoints

proc newWarp (x, y : int)
    new warp, upper (warp) + 1
    warp (upper (warp)).atX := x
    warp (upper (warp)).atY := y
    var newWin : int
    newWin := Window.Open ("graphics:400;400,title:MapInfo,position:200;200")
    Window.Select (newWin)
    put "Please enter the destination"
    get warp (upper (warp)).destinationX
    get warp (upper (warp)).destinationY
    put "Please enter the map"
    get warp (upper (warp)).map
    Window.Close (newWin)
end newWarp

put "Welcome to Saurabh's level editor"
put "Would you like to load a map, or create a new map?(new/load)"
get answer
if answer = "new" then
    put "how many tiles going down?"
    get dy
    put "And accross?"
    get dx
    new tiles, dx * dy - 1
    for x : 0 .. dx * dy - 1
	tiles (x) := 0
    end for
elsif answer = "load" then
    put "please select the map, and remember to include it's adress(eg. level1/map2)"
    get answer
    var fileNo : int
    var enemyNum : int
    var kAnswer : string := answer + ".txt"
    if File.Exists (kAnswer) then
	open : fileNo, kAnswer, get
	get : fileNo, dx
	get : fileNo, dy
	new tiles, dx * dy - 1
	for decreasing y : dy - 1 .. 0
	    for x : 0 .. dx - 1
		get : fileNo, tiles (Array (x, y))
		if tiles (Array (x, y)) = 25 then
		    tiles (Array (x, y)) := 23
		elsif tiles (Array (x, y)) = 27 then
		    tiles (Array (x, y)) := 24
		elsif tiles (Array (x, y)) = 28 then
		    tiles (Array (x, y)) := 25
		elsif tiles (Array (x, y)) = 29 then
		    tiles (Array (x, y)) := 26
		end if
	    end for
	end for
	close : fileNo
	fileNo := 0
	kAnswer := answer + "enemy.txt"
	if File.Exists (kAnswer) then
	    open : fileNo, kAnswer, get
	    get : fileNo, enemyNum
	    new enemy, enemyNum
	    for x : 1 .. enemyNum
		put enemyNum
		get : fileNo, enemy (x).sX
		get : fileNo, enemy (x).sY
		get : fileNo, enemy (x).eX
		get : fileNo, enemy (x).eY
		enemy (x).done := true
	    end for
	    close : fileNo
	    fileNo := 0
	end if
	setWarpPoints (answer + "warps.txt")
    else
	put "file not foun, now crashing"
	delay (1000)
	quit
    end if
else
    put "invalid input, now crashing"
    delay (1000)
    quit
end if
var windowTile, editorWindow : int
editorWindow := Window.Open ("graphics:800;640,noecho,nocursor,title:Editor,position:30;30,offscreenonly")
windowTile := Window.Open ("graphics:130;565,noecho,nocursor,title:Tiles,position:850;175")
var mx, my, mb : int
var currentTile : int := 0
var key : array char of boolean
Window.Select (windowTile)
for x : 0 .. upper (TilePic)
    Pic.Draw (TilePic (x), 10, x * 21, picCopy)
end for
fcn MoveMap (x, y : int) : boolean
    var tmp : boolean := true

    if (cx + x + dx * 16) < maxx then
	tmp := false
    elsif (cx + x + 0 * 16) > 0 then
	tmp := false
    else
	cx += x
    end if
    if (cy + y + dy * 16) < maxy then
	tmp := false
    elsif (cy + y + 0 * 16) > 0 then
	tmp := false
    else
	cy += y
    end if
    result tmp
end MoveMap
var haveEnemy : boolean := false
var mousePressed : boolean := false
loop

    Input.KeyDown (key)
    if key ('w') and MoveMap (0, -16) then
	cy -= 16
    end if
    if key ('s') and MoveMap (0, 16) then
	cy += 16
    end if
    if key ('a') and MoveMap (16, 0) then
	cx += 16
    end if
    if key ('d') and MoveMap (-16, 0) then
	cx -= 16
    end if

    Window.Select (windowTile)
    mousewhere (mx, my, mb)
    for x : 0 .. upper (TilePic)
	if mx >= 10 and my >= x * 21 and mx <= 10 + 16 and my <= x * 21 + 16 and mb > 0 then
	    currentTile := x
	    if x = 22 then
		if not haveEnemy then
		    new enemy, (upper (enemy)) + 1
		    enemy (upper (enemy)).done := false
		    haveEnemy := true
		    mousePressed := false
		end if
	    end if
	end if
    end for
    Window.Select (editorWindow)
    mousewhere (mx, my, mb)
    reDraw
    if (mx - cx >= 0 and mx - cx <= 16 * (dx) and my - cy >= 0 and my - cy <= 16 * (dy)) and (mx >= 0 and mx <= maxx and my > 0 and my <= maxy) then
	Draw.Box (mx div 16 * 16, my div 16 * 16, mx div 16 * 16 + 16, my div 16 * 16 + 16, red)
	if key ('x') and mb > 0 then
	    newWarp ((mx - cx) div 16, (my - cy) div 16)
	else
	    if mb > 0 and currentTile not= 22 then
		tiles (Array ((mx - cx) div 16, (my - cy) div 16)) := currentTile
	    end if
	    if currentTile = 22 then
		if mb > 0 then
		    mousePressed := true
		end if
		if mb = 0 and mousePressed then
		    if not enemy (upper (enemy)).done then
			enemy (upper (enemy)).sX := (mx - cx) div 16
			enemy (upper (enemy)).sY := (my - cy) div 16
			enemy (upper (enemy)).done := true
			haveEnemy := false
			mousePressed := false
		    else
			currentTile := 0
		    end if
		else
		    enemy (upper (enemy)).eX := (mx - cx) div 16
		    enemy (upper (enemy)).eY := (my - cy) div 16
		end if
	    end if
	end if
    end if
    locate (1, 1)
    put currentTile ..
    locate (20, 1)
    put (mx - cx) div 16, " ", (my - cy) div 16 ..
    for x : 1 .. upper (enemy)
	if enemy (x).done then
	    Draw.Line (enemy (x).sX * 16 + cx, enemy (x).sY * 16 + cy, enemy (x).eX * 16 + cx, enemy (x).eY * 16 + cy, black)
	end if
    end for
    for x : 1 .. upper (enemy)
	if not enemy (x).done then
	    Pic.Draw (TilePic (22), mx, my, picMerge)
	else
	    Pic.Draw (TilePic (22), enemy (x).sX * 16 + cx, enemy (x).sY * 16 + cy, picMerge)
	end if
    end for
    exit when key ('q')
    View.Update
end loop
Window.Close (editorWindow)
Window.Close (windowTile)
cls
var file : string
put "What file should it be saved in?"
get file
if not File.Exists (file) then
    Dir.Create (file)
end if
put "What would you like to save the level as?(don't include the .txt extension)"
get answer
var fileNo : int
fileNo := 0
open : fileNo, file + "/" + answer + ".txt", put
put : fileNo, dx
put : fileNo, dy
for decreasing y : dy - 1 .. 0
    for x : 0 .. dx - 1
	if tiles (Array (x, y)) = 23 then
	    put : fileNo, 25
	elsif tiles (Array (x, y)) = 24 then
	    put : fileNo, 27
	elsif tiles (Array (x, y)) = 25 then
	    put : fileNo, 28
	elsif tiles (Array (x, y)) = 26 then
	    put : fileNo, 29
	else
	    put : fileNo, tiles (Array (x, y))
	end if
    end for
end for
fileNo := 0
open : fileNo, file + "/" + answer + "enemy.txt", put
put : fileNo, upper (enemy)
for x : 1 .. upper (enemy)
    put : fileNo, enemy (x).sX
    put : fileNo, enemy (x).sY
    put : fileNo, enemy (x).eX
    put : fileNo, enemy (x).eY
end for
fileNo := 0
open : fileNo, file + "/" + answer + "warps.txt", put
put : fileNo, upper (warp)
for x : 1 .. upper (warp)
    put : fileNo, warp (x).atX
    put : fileNo, warp (x).atY
    put : fileNo, warp (x).destinationX
    put : fileNo, warp (x).destinationY
    put : fileNo, warp (x).map
end for
close : fileNo

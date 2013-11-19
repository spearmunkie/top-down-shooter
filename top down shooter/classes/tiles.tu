unit
class tileSystem
    export reDraw, InitiateMap, InitiateTile, clearTiles, currentTileY, currentTileX, currentType, MoveMap, changeTile, SetAnimate, Cx, Cy, changeCurrentTile

    var Tile : flexible array 0 .. 0 of int
    var TilePic : flexible array 0 .. 0 of int
    var cx, cy, dx, dy, maxX, maxY, minX, minY : int := 0
    var moveX, moveY : int := 0
    var warpPoints : flexible array 0 .. 0 of int
    var animateID : flexible array 0 .. 0 of int
    var frame : flexible array 0 .. 0 of int
    var dTime : flexible array 0 .. 0 of int
    var tTime, tTime2 : int := Time.Elapsed
    var size :
	record
	    x, y : int
	end record
    size.x := 16
    size.y := 16

    proc InitiateTile (tileName : string)
	TilePic (upper (TilePic)) := Pic.FileNew (tileName)
	new TilePic, upper (TilePic) + 1
    end InitiateTile

    fcn Array (x, y : int) : int
	result dx * y + x %dy * x + y
    end Array

    procedure InitiateMap (MapName : string)
	var fileName : string := MapName
	var fileNo : int := 0
	open : fileNo, fileName, get
	get : fileNo, dx
	get : fileNo, dy
	new Tile, dx * dy - 1
	cx := 0
	cy := 0
	for decreasing y : dy - 1 .. 0
	    for x : 0 .. dx - 1
		get : fileNo, Tile (Array (x, y))
	    end for
	end for
	close : fileNo
    end InitiateMap

    fcn changeTile (oldTile, newTile : int) : boolean
	var tmp : boolean := false
	for x : 0 .. upper (Tile)
	    if oldTile = Tile (x) then
		Tile (x) := newTile
		tmp := true
	    end if
	end for
	result tmp
    end changeTile

    proc SetAnimate (tileToAnimate, newFrame, delayTime : int)
	new animateID, upper (animateID) + 1
	new frame, upper (frame) + 1
	new dTime, upper (dTime) + 1
	animateID (upper (animateID)) := tileToAnimate
	frame (upper (frame)) := newFrame
	dTime (upper (dTime)) := delayTime
    end SetAnimate

    proc Animate
	for x : 1 .. 4
	    if tTime + dTime (x) < Time.Elapsed then
		if changeTile (animateID (x), frame (x)) then
		    tTime := Time.Elapsed
		end if
	    end if
	end for
	for x : 5 .. 6
	    if tTime2 + dTime (x) < Time.Elapsed then
		if changeTile (animateID (x), frame (x)) then
		    tTime2 := Time.Elapsed
		end if
	    end if
	end for
    end Animate

    proc changeCurrentTile (x, y, tile : int)
	Tile (Array (x, y)) := tile
    end changeCurrentTile

    proc inScope
	for x : 0 .. dx - 1
	    minX := x
	    exit when x * size.x + size.x + cx >= 0
	end for
	for x : minX .. dx - 1
	    maxX := x
	    exit when x * size.x + cx >= maxx
	end for
	for x : 0 .. dy - 1
	    minY := x
	    exit when x * size.y + size.y + cy >= 0
	end for
	for x : minY .. dy - 1
	    maxY := x
	    exit when x * size.y + cy >= maxy
	end for
    end inScope

    proc reDraw
	Animate
	inScope
	for x : minX .. maxX
	    for y : minY .. maxY
		Pic.Draw (TilePic (Tile (Array (x, y))), size.x * x + cx, y * size.y + cy, picCopy)
	    end for
	end for
    end reDraw

    proc clearTiles
	new Tile, 0
    end clearTiles

    fcn MoveMap (x, y : int) : boolean
	var tmp : boolean := true
	cx += x
	cy += y
	if (cx + dx * size.x) < maxx then
	    cx := maxx - dx * size.x
	    tmp := false
	elsif (cx + 0 * size.x) > 0 then
	    cx := 0 - 0 * size.x
	    tmp := false
	end if
	if (cy + dy * size.y) < maxy then
	    cy := maxy - dy * size.y
	    tmp := false
	elsif (cy + 0 * size.y) > 0 then
	    cy := 0 - 0 * size.y
	    tmp := false
	end if
	result tmp
    end MoveMap

    function currentTileX (x : real) : int
	result x div size.x
    end currentTileX

    function currentTileY (y : real) : int
	result y div size.y
    end currentTileY

    function currentType (x, y : int) : int
	if Array (x, y) < 0 or Array (x, y) > upper (Tile) then
	    result - 1
	end if
	result Tile (Array (x, y))
    end currentType

    fcn Cx : int
	result cx
    end Cx

    fcn Cy : int
	result cy
    end Cy
end tileSystem









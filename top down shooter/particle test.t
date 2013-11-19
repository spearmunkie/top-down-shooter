import "classes/particleClass.tu"
setscreen ("graphics:max;max")
View.Set ("offscreenonly")
var myParticle : ^particleSystem
var x, y, b, clr : int
new particleSystem, myParticle
colourback (black)

loop
    Mouse.Where (x, y, b)
    if b > 0 then
	%flame thrower, got removed from main game
	particleSystem (myParticle).atributes ((maxx div 2 - x) / 10, (maxy div 2 - y) / 10, Rand.Int (32, 45), 50, 50, 10000)

	%gunfire sparks
	%particleSystem (myParticle).atributes (0, -.5, yellow, 2500, 10, 8000)

	%blood
	%particleSystem (myParticle).atributes (0, -.5, red, 13, 60, 350) %112

	particleSystem (myParticle).execute (1, x, y)
    end if
    particleSystem (myParticle).RunParticle
    View.Update
    Time.DelaySinceLast (round (1000 / 35))
    clr := Rand.Int (35, 40)
    for lp : 1 .. 200
	drawline (Rand.Int (1, 800) * 2 - 400, Rand.Int (1, 600) * 2 - 300,
	    Rand.Int (1, maxx) * 2 - 400,
	    Rand.Int (1, maxy) * 2 - 300, black)
    end for

end loop

import violet.backend.objects.play.StageProp;

function onLoaded() {
    for (i in 0...5) {
        var dancer = new StageProp(100 + (300 * i), 100, Paths.image('$directory/henchmen'));
        dancer.addAnim('danceLeft', 'hench dancing', [for (i in 0...15) i]);
        dancer.addAnim('danceRight', 'hench dancing', [for (i in 15...30) i]);
        dancer.playAnim('danceLeft', true);
        dancer.scrollFactor.set(0.4, 0.4);
        insert(members.indexOf(limoSunset)+1, dancer);
    }
    trace(fastCar);
}

function update(elapsed:Float) {
    // limoSunset.x += elapsed * 10;
}
package backend.objects.play;

class Judgement {

    public static function getRating(percent:Float):String {
        if (percent <= 25) {
            return "shit";
        } else if (percent <= 50) {
            return "bad";
        } else if (percent <= 75) {
            return "good";
        } else {
            return "sick";
        }
    }

    public static function getAccuracy(percent:Float) {
        if (percent <= 25) {
            return 25;
        } else if (percent <= 50) {
            return 50;
        } else if (percent <= 75) {
            return 75;
        } else {
            return 100;
        }
    }

    public static function getScore(percent:Float):Int {
        switch (getRating(percent)) {
            case "sick":
                return 350;
            case "good":
                return 200;
            case "bad":
                return 100;
            case "shit":
                return 50;
            default:
                return -10;
        }
    }
}
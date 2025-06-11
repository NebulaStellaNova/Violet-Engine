package backend.objects.play;

class Judgement {

    public static function getRating(percent:Float) {
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
}
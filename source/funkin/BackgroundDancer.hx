package funkin;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class BackgroundDancer extends FlxSprite
{
	public function new(x:Float, y:Float, path:String, prefix:String)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas(path);
		animation.addByIndices('danceLeft', prefix, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('danceRight', prefix, [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.play('danceLeft');
		antialiasing = true;
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		var danceAnim = (danceDir = !danceDir) ? "danceLeft" : "danceRight";
		animation.play(danceAnim, true);
	}
}
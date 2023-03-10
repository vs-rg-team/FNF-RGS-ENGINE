package settings;

import openfl.Lib;
import flixel.FlxG;

import base.Main;

class KadeEngineData {
	//Lua's weird with `FlxG.save.data`.
	public static function getOption(string:String):Any {
		return Reflect.field(FlxG.save.data, string);
	}

    public static function initSave() {
		var defaults:Map<String, Dynamic> = [
			"newInput" => true,
			"ghost" => true,
			"downscroll" => false,
			"dfjk" => false,
			"accuracyDisplay" => true,
			"offset" => 0,
			"songPosition" => false,
			"fps" => true,
			"fpsRain" => false,
			"fpsCap" => 120,
			"scrollSpeed" => 1,
			"npsDisplay" => false,
			"frames" => 10,
			"accuracyMod" => 1,
			"watermark" => true,
			"distractions" => true,
			"flashing" => true,
			"resetButton" => false,
			"botplay" => false,
			"cpuStrums" => false,
			"strumline" => false,
			"customStrumLine" => 0,
			"ratingX" => FlxG.width * 0.55 - 125,
			"ratingY" => FlxG.height * 0.5 - 50,
			"camzoom" => true,
			"scoreScreen" => true,
			"psychui" => false,
			"ogfreeplay" => false
		];

		for (setting in defaults.keys()) {
			if (Reflect.field(FlxG.save.data, setting) == null)
				Reflect.setField(FlxG.save.data, setting, defaults[setting]);
		}

		if (FlxG.save.data.fpsCap > 500 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine

		base.Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.watermarks = FlxG.save.data.watermark;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}
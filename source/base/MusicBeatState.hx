package base;

import scripts.BaseScript;
#if windows
import Discord.DiscordClient;
#end
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;
import base.Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var autoUpdateSongPos:Bool = true;
	private var floatStep:Float = 0;
	private var curStep:Int = 0;
	private var floatBeat:Float = 0;
	private var curBeat:Int = 0;

	private var controls(get, never):settings.Controls;
	inline function get_controls():settings.Controls
		return settings.PlayerSettings.player1.controls;

	var script:BaseScript;
	var scriptName:String;
	@:unreflective var overridden:Bool = false;

	public function new(?script_name:String) {
		super();
		
		//fuck i accidentialy made this look similar to codename
		//Trust me, I didn't copy-paste. I didn't even look at codename while typing this.
		if (script_name == null) {
			var classPath = Type.getClassName(Type.getClass(this));
			script_name = classPath.substr(classPath.lastIndexOf(".") + 1, classPath.length);
		}
		scriptName = script_name;
	}

	public function tryCreate() {
		script = BaseScript.makeScript('assets/data/states/$scriptName');
		script.parent = this;
		script.setVar("parent", this);
		script.execute();

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		var toOverride:Null<Bool> = script.callFunc("overrideState");
		if (toOverride != null)
			overridden = toOverride;

		script.callFunc('create');
		if (!overridden)
			create();
		script.callFunc("createPost");
	}


	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0 , 0)
	];

	public static var currentColor = 0;

	var skippedFrames = 0;

	override public function tryUpdate(elapsed:Float) {
		var main:Main = cast (Lib.current.getChildAt(0), Main);

		if (FlxG.save.data.fpsRain && skippedFrames >= 6) {
			if (currentColor >= array.length)
				currentColor = 0;
			main.changeFPSColor(array[currentColor]);
			currentColor++;
			skippedFrames = 0;
		} else
			skippedFrames++;

		if (main.getFPSCap() != FlxG.save.data.fpsCap && FlxG.save.data.fpsCap <= 290)
			main.setFPSCap(FlxG.save.data.fpsCap);
		
		if (persistentUpdate || subState == null) {
			script.callFunc("update", [elapsed]);

			if (autoUpdateSongPos) {
				Conductor.songPosition += elapsed * 1000;

				var oldStep:Int = curStep;

				updateCurStep();
				updateBeat();
		
				if (oldStep != curStep && curStep > 0)
					tryStepHit();
			}
			if (!overridden)
				update(elapsed);

			script.callFunc("updatePost", [elapsed]);
		}

		if (_requestSubStateReset) {
			_requestSubStateReset = false;
			resetSubState();
		}
		if (subState != null)
			subState.tryUpdate(elapsed);
	}

	private function updateBeat():Void
	{
		lastBeat = curStep;
		floatBeat = floatStep / 4;
		curBeat = Math.floor(floatBeat);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		floatStep = lastChange.stepTime + (Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet;
		curStep = Math.floor(floatStep);
	}

	public function tryStepHit():Void {
		if (curStep % 4 == 0)
			tryBeatHit();

		if (!overridden)
			stepHit();
		script.callFunc("stepHit", [curStep]);
	}

	public function tryBeatHit():Void {
		if (!overridden)
			beatHit();
		script.callFunc("beatHit", [curBeat]);
	}

	public function stepHit():Void {}

	public function beatHit():Void {}
	
	public function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}
}

package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var theEnd:FlxSprite;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var camGamOvr:FlxCamera;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'GameOver';
	public static var endSoundName:String = 'GameOverEnd';

	public static function resetVariables() {
		characterName = 'bf';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'GameOver';
		endSoundName = 'GameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;

		camGamOvr = new FlxCamera();
		if (characterName == 'bf')
			camGamOvr.bgColor.alpha = 1;
		else
			camGamOvr.bgColor.alpha = 0;
		FlxG.cameras.add(camGamOvr);

		bf = new Boyfriend(x, y, characterName);
		add(bf);
		if (characterName == 'bf')
			bf.visible = false;

		theEnd = new FlxSprite(200, -720);
		theEnd.frames = Paths.getSparrowAtlas('Gameover');
		theEnd.animation.addByPrefix('firstDeath', 'Gameover', 24, false);
		theEnd.animation.addByPrefix('deathConfirm', 'Continue', 24, false);
		theEnd.animation.play('firstDeath');
		theEnd.setGraphicSize(Std.int(FlxG.width * 1.2));
		if (characterName == 'bf')
			add(theEnd);

		theEnd.cameras = [camGamOvr];

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		var randomTaunt:FlxRandom = new FlxRandom();

		if (deathSoundName == 'taunt') {
			FlxG.sound.play(Paths.sound('slash'));
			FlxG.sound.play(Paths.sound('bentaunt/taunt' + randomTaunt.int(1, 17)));
		}
		else
			FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

                #if android
	        addVirtualPad(NONE, A_B);
                addPadCamera();
                #end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			lePlayState.callOnLuas('onGameOverConfirm', [false]);
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if(bf.animation.curAnim.curFrame == 12)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (bf.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (characterName == 'bf')
			{
				theEnd.y = -10;
				theEnd.animation.play('deathConfirm');
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						FlxG.sound.music.stop();
						FlxG.sound.play(Paths.music(endSoundName));
						theEnd.animation.finish();
						FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
						{
							MusicBeatState.resetState();
						});
					});
			}
			else
			{
				bf.playAnim('deathConfirm', true);
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.music(endSoundName));
				new FlxTimer().start(0.7, function(tmr:FlxTimer)
				{
					camGamOvr.fade(FlxColor.BLACK, 2, false, function()
					{
						MusicBeatState.resetState();
					});
				});
			}
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}

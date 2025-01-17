package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.*;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import editors.SecretMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['Story', 'Freeplay', 'Options'];

	var magenta:FlxSprite;
	var leftHand:FlxSprite;
	var rightHand:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var lostThing:FlxSprite;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		/*
		magenta = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		*/
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 128 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.frames = Paths.getSparrowAtlas('Main_menu');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " off", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " selected", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.55));
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		


		leftHand = new FlxSprite(-50, 150).loadGraphic(Paths.image('menuHand1'));
		leftHand.antialiasing = ClientPrefs.globalAntialiasing;
		leftHand.setGraphicSize(Std.int(leftHand.width * 0.65));
		leftHand.scrollFactor.set();
		add(leftHand);
		rightHand = new FlxSprite(800, -100).loadGraphic(Paths.image('menuHand2'));
		rightHand.antialiasing = ClientPrefs.globalAntialiasing;
		rightHand.setGraphicSize(Std.int(rightHand.width * 0.65));
		rightHand.scrollFactor.set();
		add(rightHand);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		trace(FlxG.save.data.lostAvailable);

		if (FlxG.save.data.lostAvailable == 1) {
			FlxG.mouse.visible = true;
			lostThing = new FlxSprite(950, FlxG.height - 200).loadGraphic(Paths.image('lost'));
			lostThing.scale.set(0.7, 0.7);
			lostThing.scrollFactor.set();
			add(lostThing);
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

                #if android
	        addVirtualPad(UP_DOWN, A_B);
                #end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (FlxG.save.data.lostAvailable == 1) {
			if (FlxG.mouse.overlaps(lostThing)) {
				if (FlxG.mouse.justPressed) {
					FlxG.mouse.visible = false;
					MusicBeatState.switchState(new SecretMenu());
				}
			}
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.mouse.visible = false;

				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{	
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					var daChoice:String = optionShit[curSelected];
					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
					
					FlxTween.tween(rightHand, { x: 500, y: 0}, 0.4, {ease: FlxEase.expoIn});
					FlxTween.tween(leftHand, { x: 250, y: 50}, 0.4, {
						ease: FlxEase.expoIn, 
						onComplete: function(twn:FlxTween)
							{
								FlxTween.tween(leftHand, {x: 300, y: 0}, 0.15);
								FlxTween.tween(leftHand.scale, { x: 0.2, y: 0.2}, 0.15, {onComplete: function(twn:FlxTween) { leftHand.kill(); } });
								FlxTween.tween(rightHand, {x: 450, y: 0}, 0.15);
								FlxTween.tween(rightHand.scale, { x: 0.2, y: 0.2}, 0.15, {onComplete: function(twn:FlxTween) { rightHand.kill(); } });
								menuItems.forEach(function(spr:FlxSprite)
								{
									FlxTween.tween(spr, {y: 210 + (spr.ID * 50)}, 0.15);
									FlxTween.tween(spr.scale, { x: 0.2, y: 0.2}, 0.15, {onComplete: function(twn:FlxTween) { spr.kill(); } });
								});
								
								switch (daChoice)
								{
									case 'Story':
										MusicBeatState.switchState(new StoryMenuState());
									case 'Freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'Options':
										MusicBeatState.switchState(new OptionsState());
								}
							}});

					/*
					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'Story':
										MusicBeatState.switchState(new StoryMenuState());
									case 'Freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'Options':
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
					*/
				}
			}
			#if debug
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				//spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				//spr.offset.y = 0.15 * spr.frameHeight;
				spr.offset.x = 0.23 * spr.frameWidth;
				spr.offset.y = 0.23 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}

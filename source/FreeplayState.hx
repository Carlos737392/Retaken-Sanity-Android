package;

import flixel.ui.FlxButton.FlxTypedButton;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var songsTargetY:Array<Int> = [0];
	var theTweens:Array<FlxTween> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<FlxSprite>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bgs:FlxTypedGroup<FlxSprite>;

	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var bg3:FlxSprite;
	var bg4:FlxSprite;
	var bg5:FlxSprite;
	var bg6:FlxSprite;

	var blackthing:FlxSprite;
	var bar:FlxSprite;
	var hand:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var checkWeeks:Int;

	

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.save.data.lostAvailable == 3)
			checkWeeks = WeekData.weeksList.length;
		else 
			checkWeeks = WeekData.weeksList.length - 1;

		for (i in 0...checkWeeks) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length) {
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3) {
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.setDirectoryFromWeek();

		var initSonglist = CoolUtil.coolTextFile(SUtil.getPath() + Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}

		// LOAD MUSIC

		// LOAD CHARACTERS

		bgs = new FlxTypedGroup<FlxSprite>();
		add(bgs);

		bg1 = new FlxSprite(-300, -200);
		bg1.frames = Paths.getSparrowAtlas('freeplaybgs/wakeup');
		bg1.animation.addByPrefix('idle', 'Stage2', 24, true);
		bg1.animation.play('idle');
		bg1.setGraphicSize(Std.int(FlxG.width * 1.3));
		//bg1.screenCenter(Y);
		bg1.antialiasing = ClientPrefs.globalAntialiasing;
		bg1.alpha = 0;
		bg1.ID = 1;
		bgs.add(bg1);

		bg2 = new FlxSprite(-215, 0);
		bg2.frames = Paths.getSparrowAtlas('freeplaybgs/unwind');
		bg2.animation.addByPrefix('idle', 'Stage3', 24, true);
		bg2.animation.play('idle');
		bg2.setGraphicSize(Std.int(FlxG.width * 1.3));
		//bg2.screenCenter(Y);
		bg2.antialiasing = ClientPrefs.globalAntialiasing;
		bg2.alpha = 0;
		bg2.ID = 2;
		bgs.add(bg2);

		bg3 = new FlxSprite(-220, 60);
		bg3.frames = Paths.getSparrowAtlas('freeplaybgs/happyend');
		bg3.animation.addByPrefix('idle', 'Stage4', 24, true);
		bg3.animation.play('idle');
		bg3.setGraphicSize(Std.int(FlxG.width * 1.6));
		bg3.antialiasing = ClientPrefs.globalAntialiasing;
		//bg3.screenCenter(Y);
		bg3.alpha = 0;
		bg3.ID = 3;
		bgs.add(bg3);

		bg4 = new FlxSprite(-2000, -1050).loadGraphic(Paths.image('freeplaybgs/silenthills'));
		bg4.setGraphicSize(FlxG.width);
		bg4.antialiasing = ClientPrefs.globalAntialiasing;
		//bg4.screenCenter(Y);
		bg4.alpha = 0;
		bg4.ID = 4;
		bgs.add(bg4);

		bg5 = new FlxSprite(-2000, -1050).loadGraphic(Paths.image('freeplaybgs/lovetodeath'));
		bg5.setGraphicSize(FlxG.width);
		bg5.antialiasing = ClientPrefs.globalAntialiasing;
		//bg5.screenCenter(Y);
		bg5.alpha = 0;
		bg5.ID = 5;
		bgs.add(bg5);

		bg6 = new FlxSprite(-800, -380);
		bg6.frames = Paths.getSparrowAtlas('freeplaybgs/grey');
		bg6.animation.addByPrefix('idle', 'Therealistichands', 24, true);
		bg6.animation.play('idle');
		bg6.setGraphicSize(Std.int(FlxG.width * 1.3));
		//bg6.screenCenter(Y);
		bg6.antialiasing = ClientPrefs.globalAntialiasing;
		bg6.alpha = 0;
		bg6.ID = 6;
		bgs.add(bg6);

		blackthing = new FlxSprite(0, 0).loadGraphic(Paths.image('freeplayblack'));
		//blackthing.scale.set(FlxG.width, FlxG.height);
		//blackthing.antialiasing = ClientPrefs.globalAntialiasing;
		add(blackthing);

		bar = new FlxSprite(0, -400);
		bar.frames = Paths.getSparrowAtlas('menu_line');
		bar.animation.addByPrefix('idle', 'menu_Line1');
		bar.animation.play('idle');
		bar.scale.set(0.6, 0.6);
		bar.antialiasing = ClientPrefs.globalAntialiasing;
		add(bar);

		hand = new FlxSprite(20, 0);
		hand.frames = Paths.getSparrowAtlas('Inharmony_coverart');
		hand.animation.addByIndices('open', 'Coverart_INHARMONY', [0, 1, 2, 3, 4, 5, 6, 7, 8], "", 24, false);
		hand.animation.addByIndices('idle', 'Coverart_INHARMONY', [8], "", 24, true);
		hand.animation.addByIndices('close', 'Coverart_INHARMONY', [8, 7, 6, 5, 4, 3, 2, 1, 0], "", 24, false);
		hand.animation.play('open');
		hand.scale.set(0.6, 0.6);
		hand.antialiasing = ClientPrefs.globalAntialiasing;
		hand.visible = true;
		add(hand);

		var selectedBar:FlxSprite = new FlxSprite(638, 408).makeGraphic(460, 55, FlxColor.WHITE);
		add(selectedBar);
		grpSongs = new FlxTypedGroup<FlxSprite>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			//var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			//songText.isMenuItem = true;
			songsTargetY[i] = i;
			var songText:FlxSprite = new FlxSprite(0, (70 * i) + 30);
			songText.frames = Paths.getSparrowAtlas('Freeplay');
			songText.animation.addByPrefix('idle', songs[i].songName.toLowerCase(), 24, true);
			songText.animation.play('idle');
			songText.scale.set(0.6, 0.6);
			songText.updateHitbox();
			songText.antialiasing = true;
			grpSongs.add(songText);

			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			//add(icon);
			theTweens[i] = FlxTween.tween(songText, {x: songText.x}, 0, {});
			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			songText.screenCenter(X);
			songText.x += 233;	
			var scaledY = FlxMath.remapToRange(songsTargetY[i], 0, 1, 0, 1.3);
			songText.y = (scaledY * 120) + (FlxG.height * 0.48) + 43;
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		trace('susususus');
		changeSelection();
		trace('susususus');
		changeDiff();
		trace('susususus');

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to this Song / Press RESET to Reset your Score and Accuracy.";
		#else
		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		for (i in 0...grpSongs.members.length) {
			grpSongs.members[i].screenCenter(X);
			grpSongs.members[i].x += 233;
			var scaledY = FlxMath.remapToRange(songsTargetY[i], 0, 1, 0, 1.3);
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);
			grpSongs.members[i].y = FlxMath.lerp(grpSongs.members[i].y, (scaledY * 120) + (FlxG.height * 0.48) + 43, lerpVal);
		}
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (upP)
		{
			changeSelection(-shiftMult);
		}
		if (downP)
		{
			changeSelection(shiftMult);
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		#if PRELOAD_ALL
		if(space && instPlaying != curSelected)
		{
			destroyFreeplayVocals();
			Paths.currentModDirectory = songs[curSelected].folder;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			if (PlayState.SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(vocals);
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			vocals.play();
			vocals.persist = true;
			vocals.looped = true;
			vocals.volume = 0.7;
			instPlaying = curSelected;
		}
		else #end if (accepted)
		{
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0, set:Int = null)
	{
		curDifficulty += change;

		if (set != null)
			curDifficulty = set;

		if (curSelected == 6)
			curDifficulty = 2;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		var prevSelected:Int = curSelected;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		if (curSelected == 0) {
			hand.visible = true;
			hand.animation.play('open', true);
			bgs.forEach(function(spr:FlxSprite) { 
				if (spr.ID == prevSelected) {
					function tweenFunction(spr2:FlxSprite, v:Float) { spr2.alpha = v; }
					FlxTween.num(1, 0, 0.3, {}, tweenFunction.bind(spr)); 
				}
			});
		}
		else {
			bgs.forEach(function(spr:FlxSprite) {
				if (spr.ID == curSelected) {
					function tweenFunction(spr2:FlxSprite, v:Float) { spr2.alpha = v; }
					FlxTween.num(0, 1, 0.3, {}, tweenFunction.bind(spr));
				}
				else if (spr.ID == prevSelected) {
					function tweenFunction(spr2:FlxSprite, v:Float) { spr2.alpha = v; }
					FlxTween.num(1, 0, 0.3, {}, tweenFunction.bind(spr));
				}
			});
			hand.visible = false;
		}

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (i in 0...grpSongs.members.length)
		{
			songsTargetY[i] = bullShit - curSelected;
			bullShit++;
			theTweens[i].cancel();
			//item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));
			theTweens[i] = FlxTween.num(grpSongs.members[i].scale.x, 0.4, 0.2, {}, function (v:Float) {
				grpSongs.members[i].scale.set(v, v);
				grpSongs.members[i].updateHitbox();
			});
			if (songsTargetY[i] == 0)
			{
				theTweens[i].cancel();
				theTweens[i] = FlxTween.num(grpSongs.members[i].scale.x, 0.6, 0.2, {}, function (v:Float) {
					grpSongs.members[i].scale.set(v, v);
					grpSongs.members[i].updateHitbox();
				});
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		if (curSelected == 6)
			changeDiff(0, 2);
		else
			changeDiff();
		Paths.currentModDirectory = songs[curSelected].folder;
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}

package;

import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
#if desktop
import Discord.DiscordClient;
#end
import Song.SwagSong;

import editors.ChartingState;
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
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var songLocked:Array<Bool> = [];

	public static var SONG:SwagSong = null;

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var grpSongs:FlxTypedGroup<FlxSprite>;

	private var curPlaying:Bool = false;

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var bgSprite:FlxSprite;

	var songCard:FlxSprite;

	var songText:Alphabet;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
			
		}
		WeekData.setDirectoryFromWeek();

		addSong('test', 1, 'bf', FlxColor.BLUE); // Sure why not
		addSong('test', 1, 'bf', FlxColor.BLUE);
		addSong('test', 1, 'bf', FlxColor.BLUE); 
		addSong('test', 1, 'bf', FlxColor.BLUE); 
		addSong('test', 1, 'bf', FlxColor.BLUE); 
		addSong('test', 1, 'bf', FlxColor.BLUE);
		addSong('test', 1, 'bf', FlxColor.BLUE); 


		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var bgSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('ammnomicons/freeplay'));
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		bgSprite.screenCenter();
		add(bgSprite);

		grpSongs = new FlxTypedGroup<FlxSprite>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var squareThing:FlxSprite = new FlxSprite(0, 0);
			//var squareThing:Alphabet = new Alphabet(0, (30 * i) + 30, songs[i].songName, true, false);
			if (Paths.fileExists('images/freeplay/icons/' + songs[i].songName.toLowerCase() + '.png', IMAGE))
			{
				squareThing.loadGraphic(Paths.image('freeplay/icons/' + songs[i].songName.toLowerCase()));
				songLocked[i] = false;
			}
			else
			{
				squareThing.loadGraphic(Paths.image('freeplay/icons/locked'));
				songLocked[i] = true;
			}
			//squareThing.isMenuItem = true;
			//squareThing.targetY = i;
			squareThing.ID = i; 
			
			squareThing.updateHitbox();
			switch(i) {
				case 0 | 1 | 2 | 3 : //Remember to find a better way to do this
					squareThing.x = 220; 
				case _:
					squareThing.x = 400; 
			}
			switch(i) { 
				case 0 | 4:
					squareThing.y = 50;
				case 1 | 5:
					squareThing.y = 200;
				case 2 | 6:
					squareThing.y = 350;
				case 3 | 7:
					squareThing.y = 500;
			}
			if (i > 7) squareThing.visible = false; //
			grpSongs.add(squareThing);
			Paths.currentModDirectory = songs[i].folder;


			// using a FlxGroup is too much fuss!


			// squareThing.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// squareThing.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		

		songCard = new FlxSprite(690, 80); //haha funny x value
		songCard.loadGraphic(Paths.image('freeplay/reload'));
		songCard.updateHitbox();
		add(songCard);


		scoreText = new FlxText(songCard.x, songCard.y + songCard.height + 10, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT);

		scoreBG = new FlxSprite(scoreText.x - 6, scoreText.y - 5).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.4;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		songText = new Alphabet(0,scoreBG.y + scoreBG.height + 10,"god damn it its bugged",true,false);
		add(songText);

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);
		
		leftArrow = new FlxSprite(songCard.x, (songText.y + songText.height) + 5);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(0, leftArrow.y);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = 'Hard';
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

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
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
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

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		if (!songLocked[curSelected]) {
		scoreText.text = 'PERSONAL BEST: ' + lerpScore;
		diffText.text = '(' + ratingSplit.join('.') + '%)';
		} 
		else {
		scoreText.text = 'PERSONAL BEST: N/A';
		diffText.text = '(N/A)';
		}
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (upP)
		{
			MainMenuState.usingMouse = false;
			changeSelection(-shiftMult);
		}
		if (downP)
		{
			MainMenuState.usingMouse = false;
			changeSelection(shiftMult);
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			//if (instPlaying != -1)
				//vocals.volume = 0;
		}

		if(ctrl)
		{
			openSubState(new GameplayChangersSubstate());
		}
		else if(space)
		{
			//if(instPlaying != curSelected)
			//{
				#if PRELOAD_ALL
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
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
				FlxG.autoPause = false;
				SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

				if (SONG != null)
				{
					Conductor.changeBPM(SONG.bpm);
				}
				
				#end
			//}
		}
		else if (accepted)
		{
			if (songLocked[curSelected] == false)
				selectSong();
			else
				FlxG.sound.play(Paths.sound('cancelMenu'));
		}
		else if(controls.RESET)
		{
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		grpSongs.forEach(function(spr:FlxSprite) //For mouse input
		{
			if (MainMenuState.usingMouse == true) 
			{ 
				spr.alpha = 0.6;
				if (FlxG.mouse.overlaps(spr))
				{
					spr.alpha = 1;
					if (curSelected != spr.ID)	
					{
						curSelected = spr.ID;
						changeSelection(0,false);
					}
					if(FlxG.mouse.justPressed) selectSong();
				}
			}
		});
		
		if (FlxG.mouse.justPressed) MainMenuState.usingMouse = true;
		FlxG.mouse.visible = MainMenuState.usingMouse;
	
		super.update(elapsed);
	}

	function selectSong() {
		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
		/*#if MODS_ALLOWED
		if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
		#else
		if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
		#end
			poop = songLowercase;
			curDifficulty = 1;
			trace('Couldnt find file');
		}*/
			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
		if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
		}else{
				LoadingState.loadAndSwitchState(new PlayState());
		}

		FlxG.sound.music.volume = 0;
					
		destroyFreeplayVocals();
	}
	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	var tweenDifficulty:FlxTween;
	function changeDiff(change:Int = 0) //Litterally just took this from story menu state
		{
			curDifficulty += change;
	
			if (curDifficulty < 0)
				curDifficulty = CoolUtil.difficulties.length-1;
			if (curDifficulty >= CoolUtil.difficulties.length)
				curDifficulty = 0;
	
			var image:Dynamic = Paths.image('menudifficulties/' + Paths.formatToSongPath(CoolUtil.difficulties[curDifficulty]));
	
			sprDifficulty.loadGraphic(image);
			sprDifficulty.x = leftArrow.x + 60;
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.alpha = 0;
			sprDifficulty.y = leftArrow.y - 15;
	
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
			
			lastDifficultyName = CoolUtil.difficulties[curDifficulty];
	
			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
			#end
			positionHighscore();
		}
	/*{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}*/

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		if (Paths.fileExists('images/freeplay/' + songs[curSelected].songName.toLowerCase() + '.png', IMAGE)) 
		{
			songCard.visible = true;
			songCard.loadGraphic(Paths.image('freeplay/' + songs[curSelected].songName.toLowerCase() ));
			songText.changeText(songs[curSelected].songName);
		}
		else 
			{
			songCard.visible = false;
			songText.changeText('LOCKED');
		}

		
		songText.screenCenter(X);
		songText.x = songText.x + 260;
		songText.alpha = 0;
		songText.y = (scoreBG.y + scoreBG.height) - 20 ;
		FlxTween.tween(songText, {y: scoreBG.y + scoreBG.height + 10, alpha: 1}, 0.07, {ease: FlxEase.linear});


		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		grpSongs.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
				spr.alpha = 1;
			else
				spr.alpha = 0.6;
		});
		//Paths.currentModDirectory = songs[curSelected].folder;
		//PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

	}

	private function positionHighscore() {
		scoreText.x = (songCard.x + (songCard.width * 0.5)) - (scoreText.width * 0.5);

		scoreBG.scale.x = (songCard.x + songCard.width) - scoreText.x + 8;
		scoreBG.x = scoreText.x + (scoreText.width * 0.5);

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
package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import WeekData;

using StringTools;

// I'm so sorry to any programmer reading this
class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	private static var lastDifficultyName:String = '';

	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	//	var grpWeekText:FlxTypedGroup<MenuItem>;
	var weekThing:FlxSprite;

	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var bgSprite:FlxSprite;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var charText:Alphabet;
	var icon:HealthIcon;

	private var iconArray:Array<HealthIcon> = [];

	var chars:Array<String> = // I already know this is gonna be a nightmare to add
		['bf']; // add extra chars here

	var charSelected:Int = 0;

	var menuOptions:Array<FlxSprite>;

	var optionSelected:Int = 0;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);
		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 4, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 4, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 4);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		var bgYellow:FlxSprite = new FlxSprite(0, 0);
		bgYellow.loadGraphic(Paths.image('menuBG'));
		add(bgYellow);

		bgSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('ammnomicons/story'));
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		bgSprite.screenCenter();
		bgSprite.y += 20;
		bgSprite.x -= 38;
		add(bgSprite);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 40, FlxColor.BLACK);
		blackBarThingie.alpha = 0.6;
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
			weekThing = new FlxSprite(0, 0);
			add(weekThing);

			weekThing.antialiasing = ClientPrefs.globalAntialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (weekIsLocked(i))
			{
				var lock:FlxSprite = new FlxSprite((weekThing.width * 0.5) + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.globalAntialiasing;
				grpLocks.add(lock);
			}
		}

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));
		var charArray:String = 'bf';

		var weekCharacterThing:MenuCharacter = new MenuCharacter(bgSprite.x + 750, charArray);
		weekCharacterThing.y += 80;
		grpWeekCharacters.add(weekCharacterThing);

		leftArrow = new FlxSprite(bgSprite.x + 85, bgSprite.y + 105);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		leftArrow.setGraphicSize(50, 70);
		add(leftArrow);

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		if (lastDifficultyName == '')
		{
			lastDifficultyName = 'Hard';
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		sprDifficulty = new FlxSprite(0, 0);
		sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
		changeDifficulty();

		add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 470, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		rightArrow.setGraphicSize(50, 70);
		add(rightArrow);

		add(grpWeekCharacters);

		charText = new Alphabet(0, bgSprite.y + 560, chars[0], true, false);
		add(charText);

		icon = new HealthIcon(chars[0]);
		icon.sprTracker = charText;
		add(icon);
		changeChar();

		var tracksSprite:FlxSprite = new FlxSprite(0, 500).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		tracksSprite.screenCenter(X);
		tracksSprite.x += FlxG.width * 0.2;
		add(tracksSprite);

		txtTracklist = new FlxText(tracksSprite.x, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		changeWeek();

		menuOptions = [weekThing, sprDifficulty, charText];

		super.create();
	}

	override function closeSubState()
	{
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if (Math.abs(intendedScore - lerpScore) < 10)
			lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);
		sprDifficulty.visible = !weekIsLocked(curWeek);

		if (!movedBack && !selectedWeek)
		{
			var upP = controls.UI_UP_P;
			var downP = controls.UI_DOWN_P;
			if (upP)
			{
				changeOption(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (downP)
			{
				changeOption(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press')
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');

			if (controls.UI_RIGHT_P)
			{
				if (optionSelected == 0)
					changeWeek(1);
				else if (optionSelected == 1)
					changeDifficulty(1);
				else
					changeChar(1);
			}
			else if (controls.UI_LEFT_P)
			{
				if (optionSelected == 0)
					changeWeek(-1);
				else if (optionSelected == 1)
					changeDifficulty(-1);
				else
					changeChar(-1);
			}
			else if (upP || downP)
				changeDifficulty();

			if (FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if (controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				// FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		for (i in 0...menuOptions.length)
			menuOptions[i].alpha = 0.4;

		icon.alpha = charText.alpha;
		menuOptions[optionSelected].alpha = 1;

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = weekThing.y;
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				// grpWeekText.members[curWeek].startFlashing();
				if (grpWeekCharacters.members[0].character != '')
					grpWeekCharacters.members[0].animation.play('confirm');
				stopspamming = true;
			}

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length)
			{
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = CoolUtil.getDifficultyFilePath(curDifficulty);
			if (diffic == null)
				diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			PlayState.storyChar = chars[charSelected];
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}
	}

	function changeSelection()
	{
	}

	var tweenDifficulty:FlxTween;
	var lastImagePath:String;

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		var image:Dynamic = Paths.image('menudifficulties/' + Paths.formatToSongPath(CoolUtil.difficulties[curDifficulty]));
		var newImagePath:String = '';
		if (Std.isOfType(image, FlxGraphic))
		{
			var graphic:FlxGraphic = image;
			newImagePath = graphic.assetsKey;
		}
		else
			newImagePath = image;

		if (newImagePath != lastImagePath)
		{
			sprDifficulty.loadGraphic(image);
			sprDifficulty.x = bgSprite.x + 157;
			sprDifficulty.x += (380 - sprDifficulty.width) / 2; // First number here is how big the area the difficulty can be in is
			sprDifficulty.alpha = 0;
			sprDifficulty.y = bgSprite.y + 316;

			if (tweenDifficulty != null)
				tweenDifficulty.cancel();
			tweenDifficulty = FlxTween.tween(sprDifficulty, {y: bgSprite.y + 336, alpha: 1}, 0.07, {
				onComplete: function(twn:FlxTween)
				{
					tweenDifficulty = null;
				}
			});
		}
		lastImagePath = newImagePath;
		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void // I know theres a better way to do this, but it works and I'm tired so I'm going to leave it for now
	{
		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// var bullShit:Int = 0;

		PlayState.storyWeek = curWeek;

		var image:Dynamic = Paths.image('storymenu/' + WeekData.getWeekFileName());
		var newImagePath:String = '';

		weekThing.loadGraphic(image);
		weekThing.updateHitbox();
		weekThing.x = bgSprite.x + 157;
		weekThing.x += (380 - weekThing.width) / 2;
		weekThing.alpha = 0;
		weekThing.y = bgSprite.y + 85;
		FlxTween.tween(weekThing, {y: bgSprite.y + 105, alpha: 1}, 0.07, {ease: FlxEase.linear});

		/*for (item in grpWeekText.members)
			{
				item.x = bgSprite.x + 135;
				item.x += (405 - item.width) / 2;
				item.alpha = 0;
				item.targetY = bullShit - curWeek;
				if (item.targetY == Std.int(0) && !weekIsLocked(curWeek))
				{
					grpWeekText.members[curWeek].y = bgSprite.y + 80;
					FlxTween.tween(grpWeekText.members[curWeek], {y: bgSprite.y + 100, alpha: 1}, 0.07, {ease: FlxEase.linear});
				}
				bullShit++;
		}*/

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // Fuck you HTML5

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		// trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
		updateText();
	}

	function changeChar(change:Int = 0):Void
	{
		charSelected += change;

		if (change != 0)
		{
			var demoText:FlxText = new FlxText(0, 0, 1280, 'More characters coming soon', 32); // Remove this when the demo is finished
			demoText.alignment = CENTER;
			demoText.screenCenter();
			add(demoText);
			FlxTween.tween(demoText, {alpha: 0}, 2, {ease: FlxEase.quadIn});
		}

		if (charSelected >= chars.length)
			charSelected = 0;
		if (charSelected < 0)
			charSelected = chars.length - 1;

		charText.changeText(chars[charSelected]);
		charText.screenCenter(X);
		charText.x -= (160 + icon.width);
		charText.alpha = 0;
		icon.changeIcon(chars[charSelected]);
		charText.y = bgSprite.y + 533;
		FlxTween.tween(charText, {y: bgSprite.y + 553, alpha: 1}, 0.07, {ease: FlxEase.linear});
		grpWeekCharacters.members[0].changeCharacter(chars[charSelected]);
	}

	function changeOption(change:Int = 0):Void
	{
		optionSelected += change;

		if (optionSelected >= menuOptions.length)
			optionSelected = 0;
		if (optionSelected < 0)
			optionSelected = menuOptions.length - 1;

		leftArrow.y = menuOptions[optionSelected].y;
		if (optionSelected == 0)
			leftArrow.y += 4;
		else
			leftArrow.y -= 8;

		rightArrow.y = leftArrow.y;
	}

	function weekIsLocked(weekNum:Int)
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText()
	{
		var weekArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).weekCharacters;
		/*for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}*/

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length)
		{
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x += FlxG.width * 0.2;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}
}

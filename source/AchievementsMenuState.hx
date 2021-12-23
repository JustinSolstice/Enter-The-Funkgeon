package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import Achievements;

using StringTools;

class AchievementsMenuState extends MusicBeatState
{
	var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	private var achievementArray:Array<AttachedAchievement> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;
	private var bigText:Alphabet;
	private var achieveName:String;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		var bgSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('ammnomicons/acheivements'));
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		bgSprite.screenCenter();
		add(bgSprite);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...Achievements.achievementsStuff.length) {
			if(!Achievements.achievementsStuff[i][3] || Achievements.achievementsMap.exists(Achievements.achievementsStuff[i][2])) {
				options.push(Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length) {
			achieveName = Achievements.achievementsStuff[achievementIndex[i]][2];

			bigText = new Alphabet(640, 20, '', true, false, 0, 1);
			add(bigText);
			/*var optionText:Alphabet = new Alphabet(0, (100 * i) + 210, Achievements.isAchievementUnlocked(achieveName) ? Achievements.achievementsStuff[achievementIndex[i]][0] : '?', false, false);
			optionText.isMenuItem = true;
			optionText.x += 280;
			optionText.xAdd = 200;
			optionText.targetY = i;
			grpOptions.add(optionText);*/

			var icon:AttachedAchievement = new AttachedAchievement(0, 0, achieveName);
			//icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);

			switch(i) {
				case 0 | 1 | 2 : //Find better way to do this Justin I'm tired of manually adding this in
					icon.x = 150; 
				case 3 | 4 | 5 :
					icon.x = 300; 
				case 6 | 7 | 8 :
					icon.x = 450;
			}
			switch(i) { 
				case 0 | 3 | 6 :
					icon.y = 50;
				case 1 | 4 | 7 :
					icon.y = 200;
				case 2 | 5 | 8 :
					icon.y = 350;
				case _:
					icon.y = 500;
			}
		}
		descText = new FlxText(640, 400, 530, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2.4;
		add(descText);
		changeSelection();

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
			MainMenuState.usingMouse = false;
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
			MainMenuState.usingMouse = false;
		}
		if (controls.UI_LEFT_P) {
			changeSelection(-3);
			MainMenuState.usingMouse = false;
		}
		if (controls.UI_RIGHT_P) {
			changeSelection(3);
			MainMenuState.usingMouse = false;
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		for (i in 0...achievementArray.length)
		{
			if (MainMenuState.usingMouse == true)  
			{ 
				achievementArray[i].alpha = 0.6;
				if (FlxG.mouse.overlaps(achievementArray[i]))
				{
					achievementArray[curSelected].alpha = 1;
					if (curSelected != i)	
					{
						curSelected = i;
						changeSelection();
					}
				}
			}
		}
			
			if (FlxG.mouse.justPressed) MainMenuState.usingMouse = true;
			FlxG.mouse.visible = MainMenuState.usingMouse;
	}
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		
		for (i in 0...achievementArray.length) {
			achievementArray[i].alpha = 0.6;
			if(i == curSelected) {
				achievementArray[i].alpha = 1;
			}
		}
		
		achieveName = Achievements.achievementsStuff[achievementIndex[curSelected]][2];

		bigText.changeText(Achievements.isAchievementUnlocked(achieveName) ? Achievements.achievementsStuff[achievementIndex[curSelected]][0] : '?');
		bigText.screenCenter(X);
		bigText.x += 265;
		bigText.alpha = 0;
		bigText.y = 230;

		descText.text = Achievements.achievementsStuff[achievementIndex[curSelected]][1];
		descText.screenCenter(X);
		descText.x += 265;



	}
}

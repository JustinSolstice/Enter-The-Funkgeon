package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<FlxSprite>;
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var squareThing:FlxSprite;

	var creditsName:Alphabet;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		var bgSprite:FlxSprite = new FlxSprite(0, 0);
		bgSprite.loadGraphic(Paths.image('ammnomicons/credits'));
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		//bgSprite.scale.x = 0.9;
		//bgSprite.scale.y = 0.9; Why did I even add these in the first place
		bgSprite.screenCenter();
		add(bgSprite);

		grpOptions = new FlxTypedGroup<FlxSprite>();
		add(grpOptions);

		#if MODS_ALLOWED
		//trace("finding mod shit");
		for (folder in Paths.getModDirectories())
		{
			var creditsFile:String = Paths.mods(folder + '/data/credits.txt');
			if (FileSystem.exists(creditsFile))
			{
				var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
				for(i in firstarray)
				{
					var arr:Array<String> = i.replace('\\n', '\n').split("::");
					if(arr.length >= 5) arr.push(folder);
					creditsStuff.push(arr);
				}
				creditsStuff.push(['']);
			}
		}
		#end

		var pisspoop:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			//['Enter The Funkgeon Team'],
			['Solstice',			'solstice',			'Menu and Mechanic Programmer (Hey thats me!)',			'https://twitter.com/JustinSolstice',	'BA55D3'],
			['Neutron',				'neutron',			'BG and Character Artist/Animator',						'',										'00B200'],
			['Rocky',				'rocky',			'Music Composer',										'',										'EBA476'],
			['fakeburritos',		'fakeburritos',		'Charted for Hard Difficulty',							'',										'BAA98D'],
			['Dool',				'dool',				'Voice Actor and Modified fakeburritos charts for other difficulties',	'',						'FFB334'],
			
			//['Psych Engine Team'],
			['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',						'https://twitter.com/Shadow_Mario_',	'FFDD33'],
			['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',					'https://twitter.com/river_oaken',		'C30085'],
			['bb-panzu',			'bb-panzu',			'Additional Programmer of Psych Engine',				'https://twitter.com/bbsub3',			'389A58'],
			
			/*['Engine Contributors'],
			['shubs',				'shubs',			'New Input System Programmer',							'https://twitter.com/yoshubs',			'4494E6'],
			['SqirraRNG',			'gedehari',			'Chart Editor\'s Sound Waveform base',					'https://twitter.com/gedehari',			'FF9300'],
			['iFlicky',				'iflicky',			'Delay/Combo Menu Song Composer\nand Dialogue Sounds',	'https://twitter.com/flicky_i',			'C549DB'],
			['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',							'https://twitter.com/polybiusproxy',	'FFEAA6'],
			['Keoiki',				'keoiki',			'Note Splash Animations',								'https://twitter.com/Keoiki_',			'FFFFFF'],
			
			["Funkin' Crew"],
			['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",					'https://twitter.com/ninja_muffin99',	'F73838'],
			['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",						'https://twitter.com/PhantomArcade3K',	'FFBB1B'],
			['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",						'https://twitter.com/evilsk8r',			'53E52C'],
			['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",						'https://twitter.com/kawaisprite',		'6475F3']*/ // Nothing personal theres just not enough space for extra credits
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			creditsName = new Alphabet(640, 20, '', true, false, 0, 1);
			add(creditsName);
			squareThing = new FlxSprite(0,0);
			/*var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.yAdd -= 70;
			if(isSelectable) {
				optionText.x = 100;
			}
			optionText.forceX = optionText.x;
			optionText.yMult = 90;
			optionText.targetY = i; */
			squareThing.loadGraphic(Paths.image('credits/' + creditsStuff[i][1]));
			squareThing.ID = i;
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
			grpOptions.add(squareThing);
		}

		descText = new FlxText(640, 400, 530, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2.4;
		add(descText);
		changeSelection();
		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		grpOptions.forEach(function(spr:FlxSprite) //For mouse input
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
						changeSelection(0);
					}
					if(FlxG.mouse.justPressed) selectSomething();
				}
			}
		});
	
		FlxG.mouse.visible = MainMenuState.usingMouse;

		if (FlxG.mouse.justPressed) MainMenuState.usingMouse = true;

		if (upP)
		{
			MainMenuState.usingMouse = false;
			changeSelection(-1);
		}
		if (downP)
		{
			MainMenuState.usingMouse = false;
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(controls.ACCEPT) 
		{
			selectSomething();
		}

		super.update(elapsed);
	}

	function selectSomething() {
		if (creditsStuff[curSelected][3] != null)
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		else
			FlxG.sound.play(Paths.sound('cancelMenu'));
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		 //while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
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
		
		creditsName.changeText(creditsStuff[curSelected][1]);

		if (creditsName.width > 530)
			creditsName.textSize = 0.9;
		else
			creditsName.textSize = 1;

		creditsName.changeText(creditsStuff[curSelected][1]);
		creditsName.screenCenter(X);
		creditsName.x += 265;
		creditsName.alpha = 0;
		creditsName.y = 230;
		FlxTween.tween(creditsName, {y: 250, alpha: 1}, 0.07);

		descText.text = creditsStuff[curSelected][2];
		descText.screenCenter(X);
		descText.x += 265;

		grpOptions.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
				spr.alpha = 1;
			else
				spr.alpha = 0.6;
		});
	}

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
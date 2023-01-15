setFreeze (true);
print ("enabled");

local statusPlay = false;
local standartPositionDiceY = 3000;

local soundDice = array (2);
soundDice [0] = Sound ("SKE_DIE01.WAV");
soundDice [1] = Sound ("SKE_DIE02.WAV");

//dice
local diceList = array (6);
local dice = array (2);

local diceLast = array (2);
diceLast [0] = 0; diceLast [1] = 0;
local diceFinalySumm = 0;
local diceTimer = 0;



local backgroundGame = GUI.Window(1700, 1500, 5000, 5000, "GAME_BONES_TABLE.TGA", null, false);
local refreshMoveWindow = GUI.Window(3750,6600, 600, 600, "MENU_INGAME.TGA", null, false)
local restartGameWindow = GUI.Window(3500,3000,1500, 1900, "MENU_INGAME.TGA", null, false)

backgroundGame.setScaling (true);
local cupGame = GUI.Window (1100,1500, 1500,1500, "GAME_BONES_CUP.TGA", null ,statusPlay)

//dice
diceList[0] = "GAME_BONES_DICE_ONE.TGA"; diceList[1] = "GAME_BONES_DICE_TWO.TGA";
diceList[2] = "GAME_BONES_DICE_THREE.TGA";diceList[3] = "GAME_BONES_DICE_FOUR.TGA";
diceList[4] = "GAME_BONES_DICE_FIVE.TGA";diceList[5] = "GAME_BONES_DICE_SIX.TGA";



dice[0] = GUI.Window(1100, 1500, 500, 500, "GAME_BONES_TABLE.TGA", null, false);
dice[1] = GUI.Window(1100, 1500, 500, 500, "GAME_BONES_TABLE.TGA", null, false);


//button
local stopButton = GUI.Button(0, 0, 600, 600, "INV_SLOT_FOCUS.TGA", "STOP", refreshMoveWindow)
local restartGame = GUI.Button(100, 100, 1000, 800, "INV_SLOT_FOCUS.TGA", "RESTART", restartGameWindow)
local exitGame = GUI.Button(100, 1100, 1000, 600, "INV_SLOT_FOCUS.TGA", "EXIT", restartGameWindow)


// Игроки
local bonesPlayers = 0;
local acceptPlayers = 0;
local timeCheck = 0;
local timerKill = false;
local turnPos = -1;


local dicePlayerPoint = array (4); // point
local dicePlayer = array (4); // text
local paramsPlayer = array (4);

for (local i = 0; i<4; i++)
{
	paramsPlayer[i] = {id = -1, check = false, nickname = "null", point = -1, posplay = -1}
}



local function installStarterParamsPlayer ()  // установка стандартных параметров
{
	for (local i = 0; i<bonesPlayers; i++)
	{
		paramsPlayer[i] = {id = -1, check = false, nickname = "", point = -1, posplay = -1}
	}

		bonesPlayers = 0;
		acceptPlayers = 0;
		timeCheck = 0;
		timerKill = false;
		turnPos = -1;
		diceLast [0] = 0; diceLast [1] = 0;
		diceFinalySumm = 0;
		statusPlay = false;
}

local function restartStarterParamsPlayer ()
{
	for (local i = 0; i<4; i++)
	{	
		if (paramsPlayer[i].nickname != "")
		{
			dicePlayer [i].setText(paramsPlayer[i].nickname + "\n" + 0);	
		}	
	}	
	diceFinalySumm = 0;
	diceLast [0] = 0; diceLast [1] = 0;
}


local function bonesSendInfo (func, params)
{
	print ("bonesSendInfo")
	// paramsPlayer [0].id
	callServerFunc("bonesAcceptInfo", heroId, func, params)
}

local function bonesAnimationInfo (func, params, params1)
{
	print ("bonesAnimationInfo")
	callServerFunc("bonesAnimationInfo", func, heroId, params, params1);
}

local function getDrawText () // установка текста
{
	for (local i = 0; i<dicePlayerPoint.len (); i++)
	{
		dicePlayerPoint [i] = -1;
		standartPositionDiceY += 500;
		dicePlayer [i] = GUI.Draw (6800, standartPositionDiceY, "");
	}
	standartPositionDiceY = 3000;
}
addEventHandler ("onInit", getDrawText)



local function clearStatsAndText ()
{
	for (local i = 0; i<dicePlayerPoint.len (); i++)
	{
		dicePlayerPoint [i] = -1;
		dicePlayer [i].setText ("");
	}
}


local function checkConnectPlayers (length)
{
	timeCheck++; 
	print ("timer check" + timeCheck) 
	if  (length == acceptPlayers) // не обновляется кол-во игроков
	{
		paramsPlayer[0].id = heroId;
		callServerFunc ("acceptedBonesGame", heroId)
		timerKill = true;
		return;
	}
	else if (timeCheck >= 30)
	{
		for (local i = 1; i<bonesPlayers; i++)
		{
			if (paramsPlayer[i].id != -1)
			{
				callServerFunc ("cancelBonesGame", paramsPlayer[i].id)
			}
		}
		callServerFunc ("cancelBonesGame", heroId)
	}
}

local function bonesActiveGame (a)
{
	bonesSendInfo ("REFRESH_TEXT", null)
	print ("Activate")
	for (local i = 0; i<dicePlayer.len (); i++)
	{
		dicePlayer [i].setVisible (true);
	}
	backgroundGame.setVisible(true);
	cupGame.setVisible (true);
	setCursorVisible(true);
	turnPos = a;
	print ("bonesActiveGame" + turnPos);
}

local function bonesCloseGame ()
{
	for (local i = 0; i<dicePlayer.len (); i++)
	{
		dicePlayer [i].setVisible (false);
	}
	backgroundGame.setVisible(false);
	dice [0].setVisible (false); dice[1].setVisible(false);
	cupGame.setVisible (false);
	setCursorVisible(false);
	acceptPlayers = 0;
	clearStatsAndText ();
	refreshMoveWindow.setVisible (false);
	restartGameWindow.setVisible (false);
}

local function bonesGameOver ()
{

}

local function setPosDice (pos)
{
	local posDice = 2500 + rand () % 3300
	return posDice;
}

local function bonesStatrMove ()
{
	statusPlay = true;
	cupGame.setDisabled (false);
	refreshMoveWindow.setVisible (true);
	cupGame.setVisible (true);

}


local function bonesEndMove ()
{
	cupGame.setVisible (false);
	statusPlay = false;
	cupGame.setPosition (1100,1500);
	cupGame.setDisabled (true);
	refreshMoveWindow.setVisible (false);
	bonesSendInfo ("END_MOVE", turnPos);
	bonesSendInfo ("REFRESH_POINT", turnPos)
}

local function finalyAnimationDice ()
{
	/*
	dice [0].destroy ();
	dice [1].destroy ();
	dice [0] = GUI.Window(cupPos.x + x, cupPos.y + y, 500, 500, diceList [rand], null, false);
	dice [1] = GUI.Window(cupPos.x + x, cupPos.y + y, 500, 500, diceList [rand], null, false);
	dice [0].setVisible (true);
	dice [1].setVisible (true);
	*/

}

local function respawnTimer ()
{
	return timer
}

local function bonesCastDice (btn) 
{
	if (btn == MOUSE_LMB)
	{
		
		local fonPos = backgroundGame.getPosition ();
		local cupPos = cupGame.getPosition ();

		if (cupPos.x>fonPos.x && cupPos.y>fonPos.y && cupPos.x <fonPos.x*4 && cupPos.y<fonPos.y*4)
		{
			local checkDicePos = array (2);
			checkDicePos[0] = {x = setPosDice (cupPos.x), y = setPosDice (cupPos.y)}; 
			checkDicePos[1] = {x = setPosDice (cupPos.x), y = setPosDice (cupPos.y)};
			setTimer (function (){
				diceTimer++;
				refreshMoveWindow.setVisible (false);
				for (local i = 0; i<2; i++)
				{
					local randNumb = rand () % 6;
					dice [i].destroy ();
					dice [i] = GUI.Window(cupPos.x + checkDicePos[i].x, cupPos.y + checkDicePos[i].y, 500, 500, diceList [randNumb], null, false);
					dice [i].setVisible (true);
					diceLast [i] = randNumb+1;
					print (randNumb);
				}
				if (diceTimer == 7)
				{
					if (statusPlay == true)
					{
						bonesAnimationInfo ("BONES_ANIM", diceLast[0], diceLast[1]);
						refreshMoveWindow.setVisible (true);
						diceFinalySumm += diceLast[0] + diceLast[1];
						if (diceFinalySumm >= 21)
						{
						print ("cupGameFALSE" + diceFinalySumm)	
						cupGame.setVisible (false);
						}			 
					}
					else
					{
						for (local d = 0; d<2; d++)
						{
						dice [d].destroy ();
						dice [d] = GUI.Window(cupPos.x + checkDicePos[d].x, cupPos.y + checkDicePos[d].y, 500, 500, diceList [diceLast [d]-1], null, false);
						dice [d].setVisible (true);
						}
					}
				diceTimer = 0;	
				}

			}150, 7);
			soundDice [rand () % 2].play ();
			cupGame.setPosition (1100,1500);
			
		}
		
	}
}

//TEST Command 
addEventHandler ("onCommand", function (cmd, params)
{
	switch (cmd)
	{
		case "go":
		bonesActiveGame (0);
		break;
		case "test":
		bonesStatrMove ();
		break;
	}
	
})

//ACTIVE EVENT

addEventHandler("GUI.onMouseDown", function(self, btn)
{
	if (self != cupGame)
		return

	else if (statusPlay == true)
		{
			cupGame.setColor(255, 255, 255);
		}
})

addEventHandler("GUI.onMouseIn", function(self)
{
	if (self != cupGame)
		return
		else if (statusPlay == true)
		{
			cupGame.setColor(255, 255, 0);	
		}
		
	
})

addEventHandler("GUI.onMouseOut", function(self)
{
	if (self != cupGame)
		return
	cupGame.setColor(255, 255, 255);

})

addEventHandler("onMouseRelease", bonesCastDice);


registerClientFunc ("bonesTimerWait", function (length)
{
	if (timerKill == true)
	{
		timeCheck = 0;
		timerKill = false;	
	}
	local checkAcceptTimer;
	bonesPlayers = length;
	checkAcceptTimer = setTimer (function (){if (timerKill == true){killTimer(checkAcceptTimer)};checkConnectPlayers(length)}, 1000, 30);
}) 

registerClientFunc ("bonesRegPlayer", function (id)
{
	acceptPlayers ++;
	for (local i=1; i<bonesPlayers+1; i++)
	{
		if (paramsPlayer[i].check == false)
		{
			paramsPlayer[i].id = id;
			paramsPlayer[i].check = true; 
			return
		}
		
	}
})

registerClientFunc ("startBonesGame", function (a)
{
	bonesActiveGame (a);
});
registerClientFunc("closeBonesGame" function ()
{
	bonesCloseGame ();
	installStarterParamsPlayer ();
})

registerClientFunc("REFRESH_TEXT", function (a,b,c,d)
{
	paramsPlayer[0].nickname = a;
	paramsPlayer[1].nickname = b;
	paramsPlayer[2].nickname = c;
	paramsPlayer[3].nickname = d;
	for (local i=0; i<4; i++)
	{
		if (paramsPlayer[i].nickname != "")
		{
			dicePlayerPoint [i] = 0;
			paramsPlayer[i].posplay = i;
			dicePlayer [i].setText(paramsPlayer[i].nickname + "\n" + dicePlayerPoint [i]);
		}	
	}
})


registerClientFunc ("END_MOVE", function (status)
{
	if (status == true)
	{
		bonesStatrMove ();
	}
	
})

registerClientFunc ("START_GAME", function ()
{
	bonesStatrMove ()
})

registerClientFunc ("GAME_OVER", function ()
{
	print ("GAME_OVER")
	if (paramsPlayer [0].id == heroId)
	{
		restartGameWindow.setVisible (true);	
	}
})

registerClientFunc ("BONES_ANIM", function (d1,d2,d3)
{
	diceLast [0] = d1; diceLast [1] = d2;
	cupGame.setPosition (5000, 5000);
	bonesCastDice (MOUSE_LMB);

})

registerClientFunc ("REFRESH_POINT", function (i,p)
{
	for (local a = 0; a<4; a++)
	{
		if (a == i)
		{
			dicePlayer [i].setText(paramsPlayer[i].nickname + "\n" + p);
		}
	}
})



registerClientFunc ("END_GAME", function ()
{
	print ("ENDGAME")
	installStarterParamsPlayer ();
})

registerClientFunc ("RESTART_GAME", function ()
{
	restartStarterParamsPlayer ()
	if (paramsPlayer[0].id == heroId)
	{
		bonesStatrMove ();
	}
})

addEventHandler("GUI.onClick", function(self)
{
	switch (self)
	{
		case stopButton:
			bonesEndMove ();
			break;

		case restartGame:
			bonesSendInfo ("RESTART_GAME", null);
			restartGameWindow.setVisible (false);
			break;

		case exitGame:
			bonesSendInfo ("END_GAME", null);
			break; 	
	}		
})


local playerIG = array (getMaxSlots ());
local bonesPlayerPoint = array (getMaxSlots());

for (local i = 0; i<playerIG.len (); i++)
{
	playerIG [i] = {status = false, length = -1, a = -1, b = -1, c = -1, d = -1};
	bonesPlayerPoint [i] = {id = -1, hostId = -1, stauts = false, point  = 0};
}

local function transformToInt (usersArray)
{
	for (local i = 0; i<usersArray.len (); i++)
	{
		usersArray [i] = usersArray[i].tointeger ();
	}
	return usersArray;
}

local function gameClearStats (pid)
{
	playerIG [pid] = {status = false, length = -1, a = -1, b = -1, c = -1, d = -1};
	bonesPlayerPoint [pid] = {id = -1, hostId = -1, stauts = false, point  = 0};	
}


local function bonesStartGame (pid)
{
	print ("bonesStartGame")
	try 
	{
		if (playerIG[pid].a != -1)
		{
			callClientFunc(playerIG[pid].a, "startBonesGame", 0);
		}
		if (playerIG[pid].b != -1)
		{
			callClientFunc(playerIG[pid].b, "startBonesGame", 1);
		}
		if (playerIG[pid].c != -1)
		{
			callClientFunc(playerIG[pid].c, "startBonesGame", 2);
		}
		if (playerIG[pid].d != -1)
		{
			callClientFunc(playerIG[pid].d, "startBonesGame", 3);
		}
	}
	catch (msg)
	{
		print (msg);
	}
}

local function bonesCloseGame (pid)
{
	print ("bonesCloseGame");
	local abcd = array (3);
	abcd [0] = playerIG[pid].b; abcd [1] =playerIG[pid].c; abcd [2] =playerIG[pid].d;
	try
	{
		if (playerIG[pid].a != -1)
		{
			callClientFunc (playerIG[pid].a,"closeBonesGame")
		}
		if (playerIG[pid].b != -1)
		{
			callClientFunc (playerIG[pid].b,"closeBonesGame")
		}
		if (playerIG[pid].c != -1)
		{
			callClientFunc (playerIG[pid].c,"closeBonesGame")
		}
		if (playerIG[pid].d != -1)
		{
			callClientFunc (playerIG[pid].d,"closeBonesGame")
		}
		gameClearStats (playerIG[pid].a);
		gameClearStats (abcd[0]);
		gameClearStats (abcd[1]);
		gameClearStats (abcd[2]);
	}
	catch (msg)
	{
		print (msg + " bcg"); // the index '-1' does not exist (1 id)
	};
}

local function bonesAcceptInfo (host, func, params)
{
	print ("bonesAcceptInfo");
	local playerArray = array (4);
	playerArray [0] = playerIG[host].a; playerArray [1] =playerIG[host].b; playerArray [2] = playerIG[host].c; playerArray [3] = playerIG[host].d;
	for (local i = 0; i<4; i++)
	{
		if (playerArray [i] != -1)
		{
			switch (func)
			{
				case "REFRESH_TEXT":
				local textArray = array (4);
				for (local d = 0; d<4; d++)
				{
					if (playerArray [d] != -1)
					{
						textArray [d] = getPlayerName (playerArray [d]);
					}
					else
					{
						textArray [d] = "";
					}
				}
				callClientFunc (playerArray[i], func, textArray[0], textArray[1], textArray[2], textArray[3]);
				if (i == 0)
				{	
					callClientFunc (playerArray[i], "START_GAME");
				}
				break;

				case "REFRESH_POINT":
					callClientFunc (playerArray[i], func, params, bonesPlayerPoint[playerArray[params]].point);
				break;

				case "END_MOVE":
				print (playerArray[params+1])
				if (playerArray[params+1] != -1)
				{
					if (params+1 == i)
					{
						callClientFunc (playerArray[i], func, true)
					}
					else 
					{
						callClientFunc (playerArray[i], func, false)
					}
				}
				else 
				{
					callClientFunc (playerArray[i], "GAME_OVER")
				}
				break;

				case "END_GAME":
					bonesCloseGame (playerArray[i]);
					callClientFunc (playerArray[i], func);
				break;

				case "RESTART_GAME":
					bonesPlayerPoint [playerArray[i]].point = 0;
					callClientFunc (playerArray[i], func);
				break;
			}		
		}
	}
}


local function bonesSetPlayer (pid, id)
{
	print ("bonesSetPlayer")
	try
	{
		if (playerIG[pid].b == -1)
		{
			playerIG [pid].b = id;
		}
		else if (playerIG[pid].c == -1)
		{
			playerIG [pid].c = id;
		}
		else if (playerIG[pid].d == -1)
		{
			playerIG [pid].d = id;
		}
	}
	catch (msg){};
}

local function checkLenPlayer (users)
{
	if (users.len () <= 0)
	{
		return -1;
	}
	return users.len ();
}


//3
local function bonesInvitePlayer (pid, usersArray)
{
	print ("bonesInvitePlayer")
	for (local i = 0; i<usersArray.len () ;i++)	
	{
		try 
		{
			if (isPlayerConnected (usersArray[i]) == false)
			{
				sendMessageToPlayer (pid, 255,255,255, "Player ID (" + usersArray[i] +  ") not on the network.");
				return				
			}	

			else if (playerIG [i].status == true)	
			{
				sendMessageToPlayer (pid, 255,255,255, "Player ID (" + usersArray[i] +  ") invited or already in the game");
				return
			}
			else if (usersArray [i] == pid)
			{
				sendMessageToPlayer (pid, 255,255,255, "You can't invite yourself");
				return
			}
			
		}
		catch (msg)
		{	
			print (msg);
			sendMessageToPlayer (pid, 255,255,255, "Player is not ready or offline.")
			return
		}
	}

	for (local i = 0; i<usersArray.len (); i++)
	{	
		playerIG [usersArray[i]].status = true;
		sendMessageToPlayer (usersArray[i], 255, 255, 255, "Invite game dice " + getPlayerName (pid) + " (press command chat /acceptbones " + pid  + ")");
		bonesPlayerPoint [usersArray[i]].hostId = pid;
	}
	bonesPlayerPoint [pid].hostId = pid;
	playerIG[pid].a = pid;
	callClientFunc (pid, "bonesTimerWait", usersArray.len ());

}


//2
local function bonesAddPlayer (pid, params)
{
	print ("bonesAddPlayer")
	local usersArray = array (3);
	usersArray = split (params, " ");
	usersArray = transformToInt(usersArray);

	playerIG [pid].length = checkLenPlayer (usersArray);
		if (playerIG [pid].length <=0)
		{
			sendMessageToPlayer (pid, 255,255,255, "ERROR")
			return
		}
	//3	
	bonesInvitePlayer (pid, usersArray);

}


//1
local function gameInvite (pid,cmd,params)
{
	switch (cmd)
	{
		case "bones":
		if (playerIG [pid].status == false && bonesPlayerPoint [pid].hostId == -1)
		{
			bonesAddPlayer (pid, params);

		}
		else 
		{
			sendMessageToPlayer (pid, 255,255,255, "You are waiting for game confirmation")
		}
		break;

		case "acceptbones":
			if (bonesPlayerPoint [pid].hostId == params.tointeger ())
			{
				sendMessageToPlayer (pid, 255,255,255, "You accept invite.")
				bonesPlayerPoint[pid].id = pid;
				bonesSetPlayer (bonesPlayerPoint[pid].hostId, pid)
				callClientFunc (bonesPlayerPoint[pid].hostId, "bonesRegPlayer", pid)
			}
			else 
			{
				sendMessageToPlayer (pid, 255,255,255, "Данный игрок не приглашал вас.")
			}
		break;
	}
}
addEventHandler ("onPlayerCommand", gameInvite);

addEventHandler("onPlayerDisconnect", function(pid, reason){
		if (bonesPlayerPoint [pid].hostId != -1 || playerIG [pid].a != -1)
		{
			bonesCloseGame (bonesPlayerPoint[pid].hostId);
		}
});

registerServerFunc ("acceptedBonesGame", function (pid)
{
	playerIG [pid].a = pid;
	bonesStartGame(pid)
});

registerServerFunc ("bonesAcceptInfo", function (id,func,params)
{
	print ("REGISTRATION BONES ACCEPT INFO" + id)
	if (id != -1)
	{
		bonesAcceptInfo (bonesPlayerPoint [id].hostId,func,params);
	}
})

registerServerFunc ("bonesAnimationInfo", function (func, id, d1, d2)	
{
	print ("bonesAnimationInfo" + id)
	local host = bonesPlayerPoint [id].hostId;
	local playerArray = array (4);
	playerArray [0] = playerIG[host].a; playerArray [1] =playerIG[host].b; playerArray [2] = playerIG[host].c; playerArray [3] = playerIG[host].d;
	bonesPlayerPoint [id].point += d1+d2;
	print (bonesPlayerPoint [id].point)
	for (local i = 0; i<4; i++)
	{
		if (playerArray [i] != -1)
		{
			if (id!= playerArray [i])
			{
			callClientFunc (playerArray [i], func, d1,d2, bonesPlayerPoint [id].point)
			}
		}
	}		
})




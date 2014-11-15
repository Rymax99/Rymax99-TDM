//Primarily developed by Ryan, Wolf, and Mean
//Script by Rymax99 on the SA-MP forums (http://forum.sa-mp.com/member.php?u=173600)

#include <a_samp>
#undef  MAX_PLAYERS
#define MAX_PLAYERS GetMaxPlayers()
#include <zcmd>
#include <sscanf2>
#include <mysql>
#include <foreach>
#include <streamer>
#include <YSI\y_timers>
#include <AntiCleo>
#include <geolocation>

native WP_Hash(buffer[], len, const str[]);

#define mysql_fetch_int(%0,%1) mysql_fetch_field(%0,field); \
	%1=strval(field)
#define mysql_fetch_float(%0,%1) mysql_fetch_field(%0,field); \
	%1=floatstr(field)
#define mysql_fetch_string(%0,%1) mysql_fetch_field(%0,%1)
#define String( format(string,sizeof(string),
new ssstring[140];
#define ssstring( format(ssstring,sizeof(ssstring),
#define Query( format(query,sizeof(query),
#define PUB:%0(%1)	forward %0(%1); \
					public %0(%1)
#define ALTCOMMAND:%1->%2;  COMMAND:%1(playerid, params[]) \
							return cmd_%2(playerid, params);
					
#define MAX_TEAMS               9
#define MAX_CLASSES             7
#define MAX_SPAWNS              45 
#define MAX_CAPZONES            16
#define MAX_RANKS               7
#define MAX_BRIEFCASES          8
#define MAX_MONEYSPOTS          4

#define TEAM_UNITEDSTATES       1
#define TEAM_EUROPE		        2
#define TEAM_ASIA               3
#define TEAM_AUSTRALIA          4
#define TEAM_SOVIET             5
#define TEAM_ARAB               6
#define TEAM_LATINO             7
#define TEAM_ALQAEDA	        8

#define TEAM_UNITEDSTATES_C     "~b~"
#define TEAM_EUROPE_C           "~g~"
#define TEAM_ASIA_C             "~y~~h~"
#define TEAM_AUSTRALIA_C        "~p~"
#define TEAM_SOVIET_C           "~r~~h~"
#define TEAM_ARAB_C             "~y~"
#define TEAM_LATINO_C           "~b~~h~~h~"

#define CLASS_ASSAULT			0
#define CLASS_SNIPER			1
#define CLASS_MEDIC				2
#define CLASS_SUPPORTER         3
#define CLASS_ENGINEER			4
#define CLASS_PILOT				5
#define CLASS_JETTROOPER		6
#define FREEZE_SECONDS          4

//MySQL
#define db 						""
#define host 					""
#define user 					""
#define pass 					""
#define MAX_FIELD               256
new MySQL:mysql;
#define DS 						10000

#define COLOR_WHITE 			0xFFFFFFAA
#define COLOR_GRAY 				0xAFAFAFAA
#define COLOR_LIGHTGRAY         0xD3D3D3FF
#define COLOR_PURPLE            0xF7F00FF
#define COLOR_RED 				0xFF0000AA
#define COLOR_GREEN 			0x33FF33AA
#define COLOR_DARKLIGHTGREEN	0x00BF00FF
#define COLOR_LIMEGREEN 		0x00FF00FF
#define COLOR_BLUE 				0x2894FFFF
#define COLOR_CYAN 				0x00F4F4FF
#define COLOR_LIGHTBLUE 		0x00D0F6AA
#define COLOR_YELLOW			0xFFFF00AA
#define COLOR_ORANGE 			0xFF9900AA
#define COLOR_DARKORANGE       	0xFF8C00AA
#define COLOR_FUCHSIA 	  	    0xD65CFFFF
#define COLOR_PINK 				0xFF66FFFF
#define COLOR_TEAL 				0x099EA6FF
#define COLOR_PINKRED			0xF45F66FF
#define COLOR_AZURE 			0x007FFFAA
#define COLOR_TAN	 			0xD2B48CAA
#define COLOR_AQUA	 			0x00FFFFAA

//config
#define SERVER_MAX_ADMIN_LEVEL  6
#define SERVER_MIN_ADMIN_LEVEL  0
#define SERVER_MAX_DONOR_LEVEL  3
#define SERVER_MIN_DONOR_LEVEL  0
new MAX_PING = 1000; 
new disableantiAB=0;			
#define BOT_NAME 				"SERVER"
#define MAX_CONNECTIONS_FROM_IP 5
new ForbiddenNames[][] = {"Admin","Administrator","SERVER","Unknown","root"}; 
#define DYS 30
new motd[128];
#define MOTDCOLOR COLOR_YELLOW

#define PROTECTED 0
#define PROTECTED_IP ""
#define PROTECTED_SITE ""
#define PROTECTED_PORT 7777

new gRankScore[MAX_RANKS]={0,150,300,750,2000,4500,10000};
new gRankName[MAX_RANKS][20]={{"Rookie"},{"Private"},{"Corporal"},{"Sergeant"},{"Captain"},{"Brigadier"},{"General"}};
new Float:gRankHealth[MAX_RANKS]={94.9,94.9,99.0,99.0,99.0,99.0,99.0};
new Float:gRankArmor[MAX_RANKS]={0.0,4.9,14.9,29.9,49.9,74.9,99.9}; //when setting, use the number -1 and with a decimal of .99 because of /rank - so it shows an even number due to the 99.0 health for the anti cheat
new gClassName[MAX_CLASSES][20]={{"Assault"},{"Sniper"},{"Medic"},{"Supporter"},{"Engineer"},{"Pilot"},{"Jet Trooper"}};
#define classdialog ShowPlayerDialog(playerid, DIALOG_CLASSPICK, DIALOG_STYLE_LIST, "Choose your class",\
"Assault\nSniper {F02E2E}(rank 1){FFFFFF}\nMedic {F02E2E}(rank 1){FFFFFF}\nSupporter {F02E2E}(rank 2){FFFFFF}\nEngineer {F02E2E}(rank 3){FFFFFF}\nPilot {F02E2E}(rank 3){FFFFFF}\nJet Trooper {F02E2E}(rank 5){FFFFFF}", "Choose", "")

//when adding/removing, be sure to modify the task as well
#define Pmessage0 "Need help? Use /helpme [question] | Spot a cheater/hacker? Report them with /report [ID] [reason]."
#define Pmessage1 "To earn score you need to capture zones & kill people!"
#define Pmessage2 "New here? Read the rules - /rules."
#define Pmessage3 "You can visit Sector 7 Gaming's website/forums at www.sector7gaming.com."
#define Pmessage4 "Want to drive heavy vehicles but are not sure about the rules? Read /hvrules for the heavy vehicle rules!"

#define invalidplayer 0xD3D3D3FF, "[ERROR] Invalid player name/ID."
#define invalidweapon 0xD3D3D3FF, "[ERROR] Invalid weapon."
#define enterhvehicle 0xFF0000AA, "[WARNING] You have entered a 'heavy vehicle' - when using the heavy weapons, please keep the guidlines in /hvrules in mind!"
#define muted 0xFF0000AA, "[ERROR] You cannot send messages while you are muted."
#define spam 0xFF0000AA, "[ERROR] Don't spam - wait a second before sending something else!"
#define accessdenied(%0); SendClientMessage(%0,COLOR_GRAY,"[ERROR] You are not authorized to use this command.");
#define SendUsage(%0,%1); SendClientMessage(%0,COLOR_GRAY,%1);
#define donordeny1 COLOR_DARKORANGE, "You must have a donor rank of 1 or above to use this command."
#define donordeny2 COLOR_DARKORANGE, "You must have a donor rank of 2 or above to use this command."

#define DIALOG_REGISTER 	1
#define DIALOG_LOGIN 		2
#define DIALOG_CHANGEPASS 	3
#define DIALOG_CLASSPICK	4
#define DIALOG_DUEL 		5
#define DIALOG_RULES 		6
#define DIALOG_CREDITS 		7
#define DIALOG_SHOP 		8
#define DIALOG_SHOP2 		9

new justspawnedtimer[MAX_PLAYERS];
new firstconnected[MAX_PLAYERS];
new firstspawn[MAX_PLAYERS];
new Jailed[MAX_PLAYERS];
new Blocked[MAX_PLAYERS];
new Muted[MAX_PLAYERS];
new unmutetime;
new ReconnectPIP[MAX_PLAYERS][16];
new bool:IsReconnecting[MAX_PLAYERS];
new LastPMessage = 0;
new WeaponPickups[9];
new shotTime[MAX_PLAYERS];
new shot[MAX_PLAYERS];
enum pInfo
{
	pSpamMessage,
	pPickupAble,
	pShopDelay
};
new PlayerInfo[MAX_PLAYERS][pInfo];
enum PLAYER_INFO
{
	pName[MAX_PLAYER_NAME+1],
	pIp[16],
	pDBID,
	pTeam,
	pPlayingTeam,
	pClass,
	pScore,
	pKills,
	pDeaths,
	pMoney,
	pRank,
	joinenabled,
	joined,
	pOp,
	pAlevel,
	pDonor,
	pOldlevel,
	pTemplevel,
	pLogged,
	pReggedAcc,
	pContime,
	adminhide,
	wontteleport,
	clanwarstarted,
	pVeh,
	pSpawned,
	pHacker,
	pChangeClass,
	Text3D:p3DText,
	pMapIcons
};
new bool:paused[MAX_PLAYERS];

enum TEAM_INFO
{
	tName[30],
	tColor,
	tHex[64],
	tGZ,
	tGZColor,
	tSkin,
	tPlayers,
	Text:tClassText,
	Float:tBaseXmin,
	Float:tBaseYmin,
	Float:tBaseXmax,
	Float:tBaseYmax,
	Float:tWeapTruckCPX,
	Float:tWeapTruckCPY,
	Float:tWeapTruckCPZ
};
	
enum CZ_INFO {
	czName[50],czTeam,czPUID,czGZ,czCP,
	Float:czMinX,Float:czMinY,Float:czMaxX,Float:czMaxY,
	Float:czCapX,Float:czCapY,Float:czCapZ,
	czCapping,czCappingTeam,czTimeLeft
};
enum SPAWN_INFO{Float:spX,Float:spY,Float:spZ,Float:spA,spTeam};
enum MONEYSPOT_INFO{msPUID,Float:msX,Float:msY,Float:msZ,msPlayer};

new gPlayerInfo[MAX_PLAYERS][PLAYER_INFO];
new gTeam[MAX_TEAMS][TEAM_INFO];
new gSpawn[MAX_SPAWNS][SPAWN_INFO],gSpawns;
new gMoneySpot[MAX_MONEYSPOTS][MONEYSPOT_INFO],gMoneySpots;
new gCapZone[MAX_CAPZONES][CZ_INFO],gCapZones;
new gVehs;

new gLimitVehicles=1;
new gSwitchteam=0;

new shop[MAX_BRIEFCASES];
new bool:Weapon[MAX_PLAYERS][47];

new WeaponName[47][32]={"Fists","Brass Knuckles","Golf Club","Nightstick","Knife","Baseball Bat","Shovel",
"Pool Cue","Katana","Chainsaw","Purple Dildo","White Dildo","Long White Dildo","Silver Dildo","Flowers","Cane",
"Grenades","Teargas","Molotovs","","","","Colt 45","Silenced 9mm","Desert Eagle","Shotgun","Sawn off","Combat Shotgun",
"UZI","MP5","AK47","M4","Tec9","Rifle","Sniper Rifle","Rocket Launcher","Heat Seaker","Flamethrower",
"Minigun","Satchel Charges","Detonator","Spraycan","Fire Extinguisher","Camera","Nightvision","Thermal Goggles","Parachute"};

new Text:Site;
new Text:txtStats[MAX_PLAYERS];
new Text:ConnectTD[9];
new Text:tw;

new Undercover[MAX_PLAYERS], namechange[MAX_PLAYERS];
new PlayerText:TeamClassTD[MAX_PLAYERS];
new pDrunkLevelLast[MAX_PLAYERS];
new pFPS[MAX_PLAYERS];
new lastpmed[MAX_PLAYERS];
enum duelinfo{playa,weapon};
new DuelInfo[MAX_PLAYERS][duelinfo];
new KillingSpree[MAX_PLAYERS];
new SessionKills[MAX_PLAYERS];
new CaptureSpree[MAX_PLAYERS];
new dueling[MAX_PLAYERS];
new iAFKp[MAX_PLAYERS];
new SpamCount[MAX_PLAYERS];
new inbriefcase[MAX_PLAYERS];
new Kicked[MAX_PLAYERS];
new pTJ[MAX_PLAYERS];

#define RUSTLER_BOMBS   3
#define NEVADA_BOMBS    6
new bombs[MAX_VEHICLES];

enum syncinfo {
	bool:sync,
	Float:shealth,
	Float:sarmour,
	sint,
	svw,
	Float:sx,
	Float:sy,
	Float:sz
};

new gSyncInfo[MAX_PLAYERS][syncinfo];
new syncwep[13][2];

new bomb[MAX_PLAYERS],bombable[MAX_PLAYERS];
static armedbody_pTick[MAX_PLAYERS];

new VehicleNames[212][] = {
	"Landstalker","Bravura","Buffalo","Linerunner","Pereniel","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana","Infernus",
	"Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat","Mr Whoopee","BF Injection",
	"Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie",
	"Stallion","Rumpo","RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder",
	"Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
	"Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR3 50","Walton","Regina",
	"Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher","Virgo","Greenwood",
	"Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa","RC Goblin","Hotring Racer A","Hotring Racer B",
	"Bloodring Banger","Rancher","Super GT","Elegant","Journey","Bike","Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain",
	"Nebula","Majestic","Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
	"Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover",
	"Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A",
	"Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight","Trailer",
	"Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer A","Emperor",
	"Wayfarer","Euros","Hotdog","Club","Trailer B","Trailer C","Andromada","Dodo","RC Cam","Launch","Police Car (LSPD)","Police Car (SFPD)",
	"Police Car (LVPD)","Police Ranger","Picador","S.W.A.T. Van","Alpha","Phoenix","Glendale","Sadler","Luggage Trailer A","Luggage Trailer B",
	"Stair Trailer","Boxville","Farm Plow","Utility Trailer"
};

forward AntiSpawnKill(playerid);
forward strike(playerid,Float:cX,Float:cY,Float:cZ);

new Aircrafts[]=
{
    413,417,425,447,460,469,476,487,488,497,511,512,513,519,520,548,553,563,577,592,593
};
stock IsAircraft(modelid)
{
    for(new i = 0; i < sizeof(Aircrafts); i++)
        if(modelid == Aircrafts[i])
            return true;
    return false;
}

stock IsVehicleEmpty(vehicleid)
{
	for(new i=0; i<MAX_PLAYERS; i++)
	{
		if(IsPlayerInVehicle(i, vehicleid)) return 0;
	}
	return 1;
}

stock ADutyFunctions(playerid)
{
	//GivePlayerWeaponEx(playerid, WEAPON_MINIGUN, 25000);
	SetPlayerHealth(playerid, 50000);
	SetPlayerColor(playerid, COLOR_PINK);
	SetPlayerSkin(playerid, 217);
	Update3DTextLabelText(gPlayerInfo[playerid][p3DText],COLOR_PINK,"Admin on duty!\nDon't attack!");
    SetPlayerTeam(playerid, NO_TEAM);
}

new BombPlanes[]=
{
	476, 553 //rustler, nevada
};
stock IsBombPlane(modelid)
{
	for(new i = 0; i < sizeof(BombPlanes); i++)
		if(modelid == BombPlanes[i])
			return true;
	return false;
}

stock GetNumberOfPlayersOnIP(test_ip[])
{
	new ip_count;
	foreach(Player,i) if(!strcmp(gPlayerInfo[i][pIp],test_ip)) ip_count++;
	return ip_count;
}

stock HexToInt(string[]) 
{
	if (string[0]==0) return 0;
	new i;
	new cur=1;
	new res=0;
	for (i=strlen(string);i>0;i--) {
		if (string[i-1]<58) res=res+cur*(string[i-1]-48); else res=res+cur*(string[i-1]-65+10);
		cur=cur*16;
	}
	return res;
}

Float:GetDistance(playerid,Float:x2,Float:y2,Float:z2) {
    new Float:x1, Float:y1, Float:z1;
    GetPlayerPos(playerid, x1, y1, z1);
	return Float:floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
}

IsInteger(string[])
{
    new i;
	while (string[i]!='\0')
	{
		if (string[i]<'0' || string[i]>'9') return false;
		i++;
	}
	return true;
}

stock IsPlayerInBase(playerid)
{
	if (!IsPlayerConnected(playerid)) return 0;
	if (gPlayerInfo[playerid][pSpawned]==0) return 0;
	new Float:pX,Float:pY,Float:pZ;
	GetPlayerPos(playerid,pX,pY,pZ);
	new team=gPlayerInfo[playerid][pTeam];
	if (pX<gTeam[team][tBaseXmin]) return 0;
	if (pY<gTeam[team][tBaseYmin]) return 0;
	if (pX>gTeam[team][tBaseXmax]) return 0;
	if (pY>gTeam[team][tBaseYmax]) return 0;
	return 1;
}

stock GetWeaponIDFromName(name[])
{
	for(new i=0;i<=46;i++)
	{
	    if (strfind(WeaponName[i],name,true)==-1) continue;
		return i;
	}
	return -1;
}

stock IsValidSkin(SkinID) {
	if(SkinID < 0 || SkinID > 299) return false;
	else return true;
}

stock ReplaceUnderscores(string[])
{
	new length=strlen(string);
	for (new i=0;i<length;i++)
	{
	    if (string[i]=='_') string[i]=' ';
	}
}

filestrtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ','))
	{
		index++;
	}
	new offset = index;
	new result[512];
	while ((index < length) && (string[index] > ',') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

UpdateScoreDisplay(playerid)
{
    new string[180];
	String("Rank: [%i]%s ~n~Score: %i ~n~Money: %i ~n~Kills: %i ~n~Deaths: %i",
 	gPlayerInfo[playerid][pRank],gRankName[gPlayerInfo[playerid][pRank]], gPlayerInfo[playerid][pScore], gPlayerInfo[playerid][pMoney], gPlayerInfo[playerid][pKills], gPlayerInfo[playerid][pDeaths]);
	TextDrawSetString(txtStats[playerid],string);
	TextDrawShowForPlayer(playerid,txtStats[playerid]);
}

SetPlayerScoreSync(playerid,score,update=1)
{
    gPlayerInfo[playerid][pScore]=score;
    SetPlayerScore(playerid,score);
	if (update) 
	{
		UpdateScoreDisplay(playerid);
	}
}

GivePlayerScoreSync(playerid,score,update=1)
{
    gPlayerInfo[playerid][pScore]+=score;
    SetPlayerScore(playerid,gPlayerInfo[playerid][pScore]);
    if (update) 
	{
		UpdateScoreDisplay(playerid);
	}
}

SetPlayerMoneySync(playerid,money,update=1)
{
    gPlayerInfo[playerid][pMoney]=money;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid,money);
    if (update) UpdateScoreDisplay(playerid);
}

GivePlayerMoneySync(playerid,money,update=1)
{
    gPlayerInfo[playerid][pMoney]+=money;
    GivePlayerMoney(playerid,money);
    if (update) UpdateScoreDisplay(playerid);
}

SyncMoney(playerid)
{
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid,gPlayerInfo[playerid][pMoney]);
}

SaveStats(playerid)
{
    if (!gPlayerInfo[playerid][pLogged]) return 1; //critical to prevent stats loss!
    new query[300];
    Query("UPDATE `playerinfo` SET `score`='%d',`money`='%d',`kills`='%d',`deaths`='%d',`level`='%d',`operator`='%d',`donor`='%d' WHERE `id`='%i'",
	gPlayerInfo[playerid][pScore],gPlayerInfo[playerid][pMoney],gPlayerInfo[playerid][pKills],gPlayerInfo[playerid][pDeaths],
	gPlayerInfo[playerid][pAlevel],gPlayerInfo[playerid][pOp],gPlayerInfo[playerid][pDonor],
	gPlayerInfo[playerid][pDBID]);
    mysql_query(query); 
    return 1;
}

ShowStats(playerid,watcherid,admin=0)
{
	new string[128];
	String("Stats of %s (id %i)",gPlayerInfo[playerid][pName],playerid);
	SendClientMessage(watcherid,COLOR_GREEN,string);
	String("Team: %s | Class: %s | Rank %d (%s) ",
		gTeam[gPlayerInfo[playerid][pTeam]][tName],gClassName[gPlayerInfo[playerid][pClass]],gPlayerInfo[playerid][pRank],gRankName[gPlayerInfo[playerid][pRank]]);
	SendClientMessage(watcherid,COLOR_WHITE,string);
	String("Score: %d | Money: %d | Kills: %d | Deaths: %d | Ratio: %0.2f",
		gPlayerInfo[playerid][pScore],gPlayerInfo[playerid][pMoney],
		gPlayerInfo[playerid][pKills],gPlayerInfo[playerid][pDeaths], Float:gPlayerInfo[playerid][pKills]/Float:gPlayerInfo[playerid][pDeaths]);
	SendClientMessage(watcherid,COLOR_WHITE,string);
	String("Admin level: %d | Operator: %d | Donator rank: %d | Database ID: %d",
		gPlayerInfo[playerid][pAlevel],gPlayerInfo[playerid][pOp],gPlayerInfo[playerid][pDonor], gPlayerInfo[playerid][pDBID]);
	SendClientMessage(watcherid,COLOR_WHITE,string);
	if(admin)
	{
	    new Float:hp,Float:ap,Float:x,Float:y,Float:z;
	    GetPlayerPos(playerid,x,y,z);
	    GetPlayerHealth(playerid,hp);
		GetPlayerArmour(playerid,ap);
		SendClientMessage(watcherid,COLOR_GRAY,"Admin related info:");
		String("Health: %.1f | Armor: %.1f | Cash: %d (Server side: %i) | Skin: %d | Ping: %d | IP: %s",
		hp,ap,GetPlayerMoney(playerid),gPlayerInfo[playerid][pMoney],GetPlayerSkin(playerid),GetPlayerPing(playerid),gPlayerInfo[playerid][pIp]);
		SendClientMessage(watcherid,COLOR_GRAY,string);
		String("Interior: %d | World: %d | Xpos: %0.1f | Ypos: %0.1f | Zpos: %0.1f",
		GetPlayerInterior(playerid),GetPlayerVirtualWorld(playerid),x,y,z);
		SendClientMessage(watcherid,COLOR_GRAY,string);
	}
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
    if(gPlayerInfo[playerid][pAlevel] > 0)
		ShowStats(clickedplayerid, playerid, 1);
	else
	    ShowStats(clickedplayerid, playerid);
    return 1;
}

stock Float: GetPointZPos(const Float: fX, const Float: fY, &Float: fZ = 0.0) {
	if(!((-3000.0 < fX < 3000.0) && (-3000.0 < fY < 3000.0))) {
		return 0.0;
	}
	static File: s_hMap;
	if(!s_hMap) {
		s_hMap = fopen("SAfull.hmap", io_read);

		if(!s_hMap) {
			return 0.0;
		}
	}
	new afZ[1];
	fseek(s_hMap, ((6000 * (-floatround(fY, floatround_tozero) + 3000) + (floatround(fX, floatround_tozero) + 3000)) << 1));
	fblockread(s_hMap, afZ);
	return (fZ = ((afZ[0] >>> 16) * 0.01));
}

stock ReturnTeamId(playerid,testedname[])
{
	new teamid=strval(testedname);
	if (IsInteger(testedname))
	{
	    if (teamid<0 || teamid>=MAX_TEAMS)
	    {
	        SendClientMessage(playerid,COLOR_ORANGE,"Enter a valid team ID/name.");
	        return -1;
	    }
	    return teamid;
	}
	for (new i=0;i<MAX_TEAMS;i++)
	{
		if(strfind("US",testedname,true)!=-1) return 1;
	    else if(strfind(gTeam[i][tName],testedname,true)!=-1) return i;
	}
 	SendClientMessage(playerid,COLOR_ORANGE,"Enter a valid team ID/name.");
	return -1;
}

AddPlayerMapIcon(playerid,Float:X,Float:Y,Float:Z,markertype,color,style)
{
	SetPlayerMapIcon(playerid,gPlayerInfo[playerid][pMapIcons],X,Y,Z,markertype,color,style);
	gPlayerInfo[playerid][pMapIcons]++;
}

#define CP_CAPZONE 0

SetPlayerCheckpointEx(playerid,Float:X,Float:Y,Float:Z,Float:radius,cptype)
{
	if (GetPVarType(playerid,"CurrCP")!=PLAYER_VARTYPE_NONE) return;
	SetPlayerCheckpoint(playerid,X,Y,Z,radius);
	SetPVarInt(playerid,"CurrCP",cptype);
}

DisablePlayerCheckpointEx(playerid,cptype)
{
    if (GetPVarType(playerid,"CurrCP")==PLAYER_VARTYPE_NONE) return;
    if (GetPVarInt(playerid,"CurrCP")!=cptype) return;
    DisablePlayerCheckpoint(playerid);
    DeletePVar(playerid,"CurrCP");
}

CheckCoolDown(playerid,cooldownname[],seconds,display=1)
{
	new ctime=gettime();
	if (GetPVarType(playerid,cooldownname)==PLAYER_VARTYPE_NONE)
	{
	    SetPVarInt(playerid,cooldownname,ctime);
		return 1;
	}
	if (ctime<GetPVarInt(playerid,cooldownname)+seconds)
	{
	    if (!display) return 0;
	    new string[65];
	    String("This command has a cooldown time of %d seconds - please wait.",seconds);
		return !SendClientMessage(playerid,COLOR_GRAY,string);
	}
	SetPVarInt(playerid,cooldownname,ctime);
	return 1;
}

SetVehHealth(vehicleid)
{
	new model=GetVehicleModel(vehicleid);
	if (!model) return;
	switch (model)
	{
	    case 425: SetVehicleHealth(vehicleid,750.0); //hunter
	    case 520: SetVehicleHealth(vehicleid,500.0); //hydra
	    case 447: SetVehicleHealth(vehicleid,500.0); //seasparrow
	    case 548: SetVehicleHealth(vehicleid,1500.0); //cargobob
	    case 433: SetVehicleHealth(vehicleid,1500.0); //barracks
	    case 601: SetVehicleHealth(vehicleid,1500.0); //S.W.A.T. van
	    case 427: SetVehicleHealth(vehicleid,1500.0); //enforcer
	    case 528: SetVehicleHealth(vehicleid,1500.0); //FBI truck
	    case 563: SetVehicleHealth(vehicleid,1500.0); //raindance
	    case 476: SetVehicleHealth(vehicleid,500.0); //rustler
	    case 470: SetVehicleHealth(vehicleid,1500.0); //patriot
	}
}

#define ShowPlayerMarkerForPlayer(%0,%1) SetPlayerMarkerForPlayer(%0,%1,(GetPlayerColor(%1) | 0x00000099))
#define HidePlayerMarkerForPlayer(%0,%1) SetPlayerMarkerForPlayer(%0,%1,(GetPlayerColor(%1) & 0xFFFFFF00))

PUB:UpdateRadar(playerid)
{
	if (GetPVarInt(playerid,"AdminDuty")==1) //show admin to everyone and everyone to admin if he's on admin duty
	{
	    foreach(Player,i)
		{
		    if (i==playerid) continue;
			ShowPlayerMarkerForPlayer(i,playerid);
			ShowPlayerMarkerForPlayer(playerid,i);
		}
		return;
	}
	foreach(Player,i)
	{
	    if (i==playerid) continue;
	    if (GetPVarInt(i,"AdminDuty")==1)
		{
			ShowPlayerMarkerForPlayer(i,playerid);
			ShowPlayerMarkerForPlayer(playerid,i);
			continue;
		}
	    if (gPlayerInfo[playerid][pClass]==CLASS_SNIPER) HidePlayerMarkerForPlayer(i,playerid);
		else ShowPlayerMarkerForPlayer(i,playerid);
		if (gPlayerInfo[i][pClass]==CLASS_SNIPER) HidePlayerMarkerForPlayer(playerid,i);
		else ShowPlayerMarkerForPlayer(playerid,i);
	}
}

main()
{
	print("Loading S7 Desert Warfare");
}

//timers
PUB:unjail(target)
{
	if(Jailed[ target ] == 1)
	{
		SetPlayerInterior(target, 0);
		SetPVarInt(target, "NoAB", 4);
		SpawnPlayer(target);
    	SendClientMessage(target, 0xFF0000AA, "Released from jail.");
    	Jailed[ target ] = 0;
	}
	return 1;
}

ptask TwoMinute[120000](playerid)
{
    SaveStats(playerid);
	SpamCount[playerid] = 0;
}

task SecondTimer[1000]()
{
	new string[128],vehid,zoneplayers[MAX_CAPZONES];
	foreach(Player,i)
	{
		iAFKp[i]++;
        if(iAFKp[i] > 3)
        {
            paused[i] = true;
            OnPlayerPause(i);
        }
        else
        {
            paused[i] = false;
		}
	}
	foreach(Player, i) {
	    if (GetPVarType(i,"CappingZone")==PLAYER_VARTYPE_NONE) continue;
	    if (IsPlayerInAnyVehicle(i))
		{
			GameTextForPlayer(i,"~r~Leave your vehicle to resume the capture!",1000,5);
			continue;
		}
	    zoneplayers[GetPVarInt(i,"CappingZone")]++;
	    if (gPlayerInfo[i][pDonor]>2) zoneplayers[GetPVarInt(i,"CappingZone")]++;
	    if (GetPVarType(i,"CappingZone")==PLAYER_VARTYPE_NONE) continue;
	    if (IsPlayerInAnyVehicle(i)) continue;
	    String("~w~Time left until end of capture: ~r~%d~w~sec.",gCapZone[GetPVarInt(i,"CappingZone")][czTimeLeft]);
		GameTextForPlayer(i,string,1000,5);
	}
	foreach(Player, i)
	{
	    if(GetPlayerState(i) != PLAYER_STATE_WASTED || GetPlayerState(i) != PLAYER_STATE_SPECTATING)
	    {
	        if (GetPVarInt(i,"AdminDuty")==1) String("Admin on duty");
	        else String("%s - %s",gTeam[gPlayerInfo[i][pTeam]][tName], gClassName[gPlayerInfo[i][pClass]]);
			PlayerTextDrawSetString(i, TeamClassTD[i], string);
			PlayerTextDrawColor(i, TeamClassTD[i], GetPlayerColor(i));
			PlayerTextDrawShow(i, TeamClassTD[i]);
		}
		if (!gPlayerInfo[i][pAlevel] && !gPlayerInfo[i][pOp] && !gPlayerInfo[i][pDonor])
		{
			if(GetPlayerPing(i) > MAX_PING && GetPlayerPing(i) < 65535)
			{
				String("[AUTOKICK] %s has been kicked from the server for high ping. [%d/%d]",gPlayerInfo[i][pName],GetPlayerPing(i), MAX_PING);
				SendClientMessageToAll(COLOR_YELLOW, string);
				KickWithMessage(i, "You have automatically been kicked for exceeding the ping limit.");
			}
		}
		
		if(GetPlayerMoney(i) > gPlayerInfo[i][pMoney])
			SetPlayerMoneySync(i,gPlayerInfo[i][pMoney]);
		
		if(gPlayerInfo[i][pAlevel] < 1)
		{
		    new str[128], ip[16];
		    GetPlayerIp(i, ip, 16);
			if(gPlayerInfo[i][pSpawned] && GetPlayerState( i ) == PLAYER_STATE_ONFOOT )
   			{
				if(GetPlayerSpecialAction(i) == SPECIAL_ACTION_USEJETPACK && gPlayerInfo[i][pClass] != CLASS_JETTROOPER)
				{
					String("[AUTOBAN] %s has been auto banned for jetpack hacks.",gPlayerInfo[i][pName]);
					SendClientMessageToAll(COLOR_YELLOW, string);
					new query[256];
					new year, month, day;
					getdate(year, month, day);
					new hour, minute, second;
					gettime(hour, minute, second);
					new escname[24];
					mysql_real_escape_string(gPlayerInfo[i][pName], escname);
					new timestring[20];
					format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
					format( query, sizeof query, "INSERT INTO bans (nick, time, reason, bannedby, IP) VALUES ('%s', '%s', 'Jetpack Hacks', '%s', '%s')", escname, timestring, BOT_NAME, ip );
					mysql_query(query);
					KickWithMessage(i, "You have been banned for jetpack hacks. If you think this is a mistake, you may appeal at www.sector7gaming.com/forums.");
					return 1;
				}
				new Float:iar;
				GetPlayerArmour( i, iar );
				if( iar == 100.0 )
				{
					String("[AUTOBAN] %s has been banned for armor hacks.",gPlayerInfo[i][pName]);
					SendClientMessageToAll( COLOR_YELLOW, string );
					new query[256];
					new year, month, day;
					getdate( year, month, day );
					new hour, minute, second;
					gettime(hour, minute, second);
					new escname[24];
					mysql_real_escape_string(gPlayerInfo[i][pName], escname);
					new timestring[20];
					format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
					format( query, sizeof query, "INSERT INTO bans (nick, time, reason, bannedby, IP) VALUES ('%s', '%s', 'armour hacks', '%s', '%s')", escname, timestring, BOT_NAME, ip );
					mysql_query(query);
					KickWithMessage(i, "You have been banned for armor hacks. If you think this is a mistake, you may appeal at www.sector7gaming.com/forums.");
					return 1;
				}
				new weap = GetPlayerWeapon(i);
				if(weap > 0 && Weapon[i][weap] == false && weap != 46 && weap != 40)
				{
				    if(GetPlayerState(i) == 1 || GetPlayerState(i) == 2 || GetPlayerState(i) == 3) {
				    	new weapname[40];
						GetWeaponName(weap, weapname, sizeof(weapname));
						format(str, sizeof str, "[AUTOBAN] %s been banned for %s hacks.",gPlayerInfo[i][pName],weapname);
						SendClientMessageToAll(COLOR_YELLOW, str);
						new query[256];
						new year, month, day;
						getdate( year, month, day );
						new hour, minute, second;
						gettime(hour, minute, second);
						new timestring[20];
						format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
						format( query, sizeof query, "INSERT INTO bans (nick, time, reason, bannedby, IP) VALUES ('%s', '%s', '%s hacks', '%s', '%s')",gPlayerInfo[i][pName], timestring ,weapname, BOT_NAME, ip );
						mysql_query(query);
						KickWithMessage(i, "You have been banned for weapon hacks. If you think this is a mistake, you may appeal at www.sector7gaming.com/forums.");
					}
				}
			}
			if(disableantiAB==0) AntiAirbreak(i); 
 		}

		if(GetPlayerState(i)==PLAYER_STATE_DRIVER && GetPVarInt(i, "AdminDuty") > 0)
		{
			SetPlayerHealth(i,50000);
			vehid=GetPlayerVehicleID(i);
			if(vehid) {	RepairVehicle(vehid); SetVehicleHealth(vehid,10000.0); }
		}

		if(GetPVarInt(i, "Jailed") == 1)
		{
		    if(GetTickCount() - GetPVarInt(i, "jailtime") > 0)
			{
		        SetPVarInt(i,"Jailed",0);
		    	TogglePlayerControllable(i,true);
		    	SetPlayerInterior(i,0);
		    	SetPVarInt(i, "NoAB", 4);
				SpawnPlayer(i);
				SendClientMessage(i, COLOR_LIMEGREEN, "Time's up! You have been unjailed.");
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
			}
		}
	}
	
	for (new i=0;i<gCapZones;i++)
	{
	    if (!gCapZone[i][czCapping]) continue; //skip zones that aren't being captured
	    gCapZone[i][czTimeLeft]-=zoneplayers[i];
	    //EO capture
	    if (gCapZone[i][czTimeLeft]<=0)
	    {
	        new cl, cla[64];
	        gCapZone[i][czTimeLeft]=0;
	        gCapZone[i][czCapping]=0;
	        gCapZone[i][czTeam]=gCapZone[i][czCappingTeam];
	        foreach(Player,j)
			{
			    if (GetPVarType(j,"CappingZone")==PLAYER_VARTYPE_NONE) continue;
			    if (GetPVarInt(j,"CappingZone")!=i) continue;
				CaptureSpree[j]++;
			    String("You successfully captured \"%s\", 3 score and $5000 earned!",gCapZone[i][czName]);
			    SendClientMessage(j,-1,string);
				printf("[CAPTURE] %s(%d) captured %s. Spree: %d", gPlayerInfo[j][pName], j, gCapZone[j][czName], CaptureSpree[j]);
				DeletePVar(j,"CappingZone");
				DisablePlayerCheckpointEx(j,CP_CAPZONE);
				GivePlayerScoreSync(j,3);
				GivePlayerMoneySync(j, 5000);
				cl = GetPlayerColor(j);
				if(CaptureSpree[j] == 10)
				{
					String("[SPREE] %s(%d) is on a capture spree of 10 zones!", gPlayerInfo[j][pName], j);
					GivePlayerScoreSync(j, 3);
					SendClientMessage(j, COLOR_TEAL, "Good job on your zone capture spree of 10! You have been rewarded 3 score.");
					SendClientMessageToAll(COLOR_ORANGE, string);
				}
				switch(gPlayerInfo[j][pTeam])
				{
				    case TEAM_UNITEDSTATES: format(cla, sizeof(cla), "%s", TEAM_UNITEDSTATES_C);
					case TEAM_EUROPE: format(cla, sizeof(cla), "%s", TEAM_EUROPE_C);
					case TEAM_ASIA: format(cla, sizeof(cla), "%s", TEAM_ASIA_C);
					case TEAM_AUSTRALIA: format(cla, sizeof(cla), "%s", TEAM_AUSTRALIA_C);
					case TEAM_SOVIET: format(cla, sizeof(cla), "%s", TEAM_SOVIET_C);
					case TEAM_ARAB: format(cla, sizeof(cla), "%s", TEAM_ARAB_C);
					case TEAM_LATINO: format(cla, sizeof(cla), "%s", TEAM_LATINO_C);
				}
			}
			GangZoneStopFlashForAll(gCapZone[i][czGZ]);
			GangZoneShowForAll(gCapZone[i][czGZ],gTeam[gCapZone[i][czTeam]][tGZColor]);
			new Ns3wsBox[128];
    		format(Ns3wsBox, sizeof Ns3wsBox, "%s%s ~w~captured ~r~%s!",cla, gTeam[gCapZone[i][czTeam]][tName],gCapZone[i][czName]);
    		AppendNewsBox(Ns3wsBox, cl);
	    }
	}
	return 1;
}

PUB:OnPlayerPause(playerid)
{
    if(iAFKp[playerid] > 5)
    {
		new str[128];
		format(str, sizeof(str), "{2E9AFE}AFK for {FFFFFF}%d seconds", iAFKp[playerid]);
		SetPlayerChatBubble(playerid, str, -1, 70.0, 1000);
	}
}

CMD:pausers(playerid, params[])
{
    new str[128], count = 0;
	if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
	foreach(Player, i)
	{
		  if(paused[i] == true && iAFKp[i] > 3)
		  {
	      		count ++;
	      		format(str, sizeof(str), "{2E9AFE}%s[%d] has been AFK for {FFFFFF}%d {2E9AFE}seconds!", gPlayerInfo[i][pName], i, iAFKp[i]);
	      		SendClientMessage(playerid, -1, str);
		  }
	}
	if(count==0) return SendClientMessage(playerid, -1, "Nobody is pausing.");
	return 1;
}

new
	Text:NewsBox[10] = {Text:INVALID_TEXT_DRAW, ...},
	NewsBoxString[9][64],
	NewsBoxTemp[64];

stock AppendNewsBox(message[], color)
{
	for(new i = 8; i > 0; i--)
	    NewsBoxString[i] = NewsBoxString[i - 1];
	//new -> 8 | 8 -> 7 | 7 -> 6 | 6 -> 5 |5 -> 4 | 4 -> 3 | 3 -> 2 | 2 -> 1
	format(NewsBoxString[0], sizeof NewsBoxString[], "%s", message);
	TextDrawSetString(NewsBox[8], NewsBoxString[0]);
	TextDrawColor(NewsBox[8], color);
	TextDrawSetString(NewsBox[7], NewsBoxString[1]);
	TextDrawSetString(NewsBox[6], NewsBoxString[2]);
	TextDrawSetString(NewsBox[5], NewsBoxString[3]);
	TextDrawSetString(NewsBox[4], NewsBoxString[4]);
	TextDrawSetString(NewsBox[3], NewsBoxString[5]);
	TextDrawSetString(NewsBox[2], NewsBoxString[6]);
	TextDrawSetString(NewsBox[1], NewsBoxString[7]);
	for(new i = 0; i < sizeof NewsBox; i++) TextDrawShowForAll(NewsBox[i]);
}

public OnGameModeInit()
{
	#if PROTECTED == 1
		{
			new ServerIP[20];
			new WebURL[25];
			GetServerVarAsString("bind", ServerIP, sizeof(ServerIP));
			GetServerVarAsString("weburl", WebURL, sizeof(WebURL));
			new ServerPort = GetServerVarAsInt("port");
			if(strcmp(ServerIP, PROTECTED_IP, false) != 0 || !strlen(ServerIP)) 
			{
				SendRconCommand("exit");
				print("IP");
				return 0;
			}
			else if(ServerPort != PROTECTED_PORT)
			{
				SendRconCommand("exit");
				print("port");
				return 0;
			}
			else if(strcmp(WebURL, PROTECTED_SITE, false) !=  0 || !strlen(WebURL))
			{
				SendRconCommand("exit");
				print("site");
				return 0;
			}
		}
    #endif
	ConnectTD[0] = TextDrawCreate(641.599975, 1.500000, "usebox");
	TextDrawLetterSize(ConnectTD[0], 0.000000, 49.405799);
	TextDrawTextSize(ConnectTD[0], -2.000000, 0.000000);
	TextDrawAlignment(ConnectTD[0], 1);
	TextDrawColor(ConnectTD[0], 0);
	TextDrawUseBox(ConnectTD[0], true);
	TextDrawBoxColor(ConnectTD[0], 255);
	TextDrawSetShadow(ConnectTD[0], 0);
	TextDrawSetOutline(ConnectTD[0], 0);
	TextDrawFont(ConnectTD[0], 0);
	
	ConnectTD[8] = TextDrawCreate(35.599998, 298.168823, "Rules:");
	TextDrawLetterSize(ConnectTD[8], 0.272796, 1.231642);
	TextDrawAlignment(ConnectTD[8], 1);
	TextDrawColor(ConnectTD[8], 16711935);
	TextDrawSetShadow(ConnectTD[8], 0);
	TextDrawSetOutline(ConnectTD[8], 1);
	TextDrawBackgroundColor(ConnectTD[8], 51);
	TextDrawFont(ConnectTD[8], 2);
	TextDrawSetProportional(ConnectTD[8], 1);

	ConnectTD[1] = TextDrawCreate(35.600002, 308.622161, "Don't use cheats/hacks.");
	TextDrawLetterSize(ConnectTD[1], 0.227996, 1.097241);
	TextDrawAlignment(ConnectTD[1], 1);
	TextDrawColor(ConnectTD[1], -1);
	TextDrawSetShadow(ConnectTD[1], 0);
	TextDrawSetOutline(ConnectTD[1], 1);
	TextDrawBackgroundColor(ConnectTD[1], 51);
	TextDrawFont(ConnectTD[1], 2);
	TextDrawSetProportional(ConnectTD[1], 1);

	ConnectTD[2] = TextDrawCreate(35.200004, 318.079925, "Don't park your vehicle on players.");
	TextDrawLetterSize(ConnectTD[2], 0.227996, 1.097241);
	TextDrawAlignment(ConnectTD[2], 1);
	TextDrawColor(ConnectTD[2], -1);
	TextDrawSetShadow(ConnectTD[2], 0);
	TextDrawSetOutline(ConnectTD[2], 1);
	TextDrawBackgroundColor(ConnectTD[2], 51);
	TextDrawFont(ConnectTD[2], 2);
	TextDrawSetProportional(ConnectTD[2], 1);

	ConnectTD[3] = TextDrawCreate(35.600002, 328.035430, "Don't steal team vehicles.");
	TextDrawLetterSize(ConnectTD[3], 0.227996, 1.097241);
	TextDrawAlignment(ConnectTD[3], 1);
	TextDrawColor(ConnectTD[3], -1);
	TextDrawSetShadow(ConnectTD[3], 0);
	TextDrawSetOutline(ConnectTD[3], 1);
	TextDrawBackgroundColor(ConnectTD[3], 51);
	TextDrawFont(ConnectTD[3], 2);
	TextDrawSetProportional(ConnectTD[3], 1);

	ConnectTD[4] = TextDrawCreate(35.599990, 337.991149, "Don't insult other players.");
	TextDrawLetterSize(ConnectTD[4], 0.227996, 1.097241);
	TextDrawAlignment(ConnectTD[4], 1);
	TextDrawColor(ConnectTD[4], -1);
	TextDrawSetShadow(ConnectTD[4], 0);
	TextDrawSetOutline(ConnectTD[4], 1);
	TextDrawBackgroundColor(ConnectTD[4], 51);
	TextDrawFont(ConnectTD[4], 2);
	TextDrawSetProportional(ConnectTD[4], 1);

	ConnectTD[5] = TextDrawCreate(35.200000, 347.448852, "Only use English in the main chat.");
	TextDrawLetterSize(ConnectTD[5], 0.227996, 1.097241);
	TextDrawAlignment(ConnectTD[5], 1);
	TextDrawColor(ConnectTD[5], -1);
	TextDrawSetShadow(ConnectTD[5], 0);
	TextDrawSetOutline(ConnectTD[5], 1);
	TextDrawBackgroundColor(ConnectTD[5], 51);
	TextDrawFont(ConnectTD[5], 2);
	TextDrawSetProportional(ConnectTD[5], 1);

	ConnectTD[6] = TextDrawCreate(35.600006, 357.404541, "Respect all players and staff members.");
	TextDrawLetterSize(ConnectTD[6], 0.227996, 1.097241);
	TextDrawAlignment(ConnectTD[6], 1);
	TextDrawColor(ConnectTD[6], -1);
	TextDrawSetShadow(ConnectTD[6], 0);
	TextDrawSetOutline(ConnectTD[6], 1);
	TextDrawBackgroundColor(ConnectTD[6], 51);
	TextDrawFont(ConnectTD[6], 2);
	TextDrawSetProportional(ConnectTD[6], 1);

	ConnectTD[7] = TextDrawCreate(35.200004, 377.813110, "Have fun!");
	TextDrawLetterSize(ConnectTD[7], 0.285996, 1.629864);
	TextDrawAlignment(ConnectTD[7], 1);
	TextDrawColor(ConnectTD[7], 16777215);
	TextDrawSetShadow(ConnectTD[7], 0);
	TextDrawSetOutline(ConnectTD[7], 1);
	TextDrawBackgroundColor(ConnectTD[7], 51);
	TextDrawFont(ConnectTD[7], 2);
	TextDrawSetProportional(ConnectTD[7], 1);

	Site = TextDrawCreate(503.500000,1.500000, "www.sector7gaming.com");
	TextDrawLetterSize(Site,0.299999,1.100000);
	TextDrawAlignment(Site,0);
	TextDrawColor(Site, 0x247EBDFF);
	TextDrawSetShadow(Site, 0);
	TextDrawSetOutline(Site, 1);
	TextDrawBackgroundColor(Site,0x000000ff);
	TextDrawFont(Site, 1);
	TextDrawSetProportional(Site, 1);
	
	EnableStuntBonusForAll(0);
	
	NewsBox[0] = TextDrawCreate(641.599975, 363.384429, "usebox");
	TextDrawLetterSize(NewsBox[0], 0.000000, 9.196422);
	TextDrawTextSize(NewsBox[0], 420.799987, 0.000000);
	TextDrawAlignment(NewsBox[0], 1);
	TextDrawColor(NewsBox[0], 0);
	TextDrawUseBox(NewsBox[0], true);
	TextDrawBoxColor(NewsBox[0], 102);
	TextDrawSetShadow(NewsBox[0], 0);
	TextDrawSetOutline(NewsBox[0], 0);
	TextDrawFont(NewsBox[0], 0);
	
	new Float:LocationY = 366.364501;
	for(new i = 1; i < 9; i++)
	{
		NewsBox[i] = TextDrawCreate(427.599914, LocationY, "_");
		TextDrawLetterSize(NewsBox[i], 0.219597, 0.863286);
		TextDrawAlignment(NewsBox[i], 1);
		TextDrawColor(NewsBox[i], 0xFFFFFFFF);
		TextDrawSetShadow(NewsBox[i], 0);
		TextDrawSetOutline(NewsBox[i], 1);
		TextDrawBackgroundColor(NewsBox[i], 51);
		TextDrawFont(NewsBox[i], 1);
		TextDrawSetProportional(NewsBox[i], 1);
		LocationY += 9.884434286;
	}

    EnableVehicleFriendlyFire();
    DisableInteriorEnterExits();
	UsePlayerPedAnims();
	AllowInteriorWeapons(1);
	SetWeather(1);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(1);
	SetTeamCount(9);

	if(GetMaxPlayers( ) != MAX_PLAYERS)
	{
		print("ERROR: MAX_PLAYERS define isn't defined right. Server shutting down.");
		return SendRconCommand("exit");
	}
	
	//mysql = mysql_init(LOG_ONLY_ERRORS);
	mysql = mysql_init(LOG_ALL);
    mysql_connect(host, user, pass, db, mysql, 1);

	for(new i=0;i<MAX_PLAYERS;i++)
	{
		txtStats[i] = TextDrawCreate(142.500000,362.500000," ");
		TextDrawAlignment(txtStats[i],0);
		TextDrawBackgroundColor(txtStats[i],0x000000FF);
		TextDrawFont(txtStats[i],1);
		TextDrawLetterSize(txtStats[i],0.199999,1.000000);
		TextDrawColor(txtStats[i],0xffffffFF);
		TextDrawSetOutline(txtStats[i],1);
		TextDrawSetProportional(txtStats[i],1);
		TextDrawSetShadow(txtStats[i],1);
	}

	shop[0] = CreatePickup(1210, 1, -249.5393,2595.5779,62.8582, 0); //USA
	shop[1] = CreatePickup(1210, 1, -109.3562,1133.3083,22.3094, 0); //Europe
	shop[2] = CreatePickup(1210, 1, -2260.0059,2338.0579,4.8208, 0); //Asia
	shop[3] = CreatePickup(1210, 1, -1339.9724,500.1256,18.2344, 0); //Aus
	shop[4] = CreatePickup(1210, 1, 1425.6503,274.7412,19.5547, 0); //Soviet
	shop[5] = CreatePickup(1210, 1, -790.7833,1613.4938,27.1172, 0); //Arab
	shop[6] = CreatePickup(1210, 1, 1066.5613,1883.7975,10.8203, 0); //Latino
	shop[7] = CreatePickup(1210, 1, -1316.3888,2509.8765,87.0420, 0); //ALQAEDA

	WeaponPickups[0] = AddStaticPickup(356, 1, -318.1208,2658.6724,63.8692, 0); //USA
	WeaponPickups[1] = AddStaticPickup(356, 1, -207.3262,1119.1735,20.4297, 0); //Europe
	WeaponPickups[2] = AddStaticPickup(356, 1, -2281.4319,2288.4163,4.9672, 0); //Asia
	WeaponPickups[3] = AddStaticPickup(356, 1, -1324.6207,435.0271,7.1809, 0); //Aus
	WeaponPickups[4] = AddStaticPickup(356, 1, 1366.5533,194.3507,19.5547, 0); //Soviet
	WeaponPickups[5] = AddStaticPickup(356, 1, -795.8169,1557.0166,27.1244, 0); //Arab
	WeaponPickups[6] = AddStaticPickup(356, 1, 1066.5728,1865.9879,10.8203, 0); //Latino
	WeaponPickups[7] = AddStaticPickup(356, 1, -1683.3702,1209.8413,21.1563, 0); //Otto's MP5
	WeaponPickups[8] = AddStaticPickup(346, 1, 142.1068,1875.4884,17.8434, 0); //Area 51 deagle
	
	new Query[256];
	format(Query, sizeof(Query), "SELECT * FROM `teams`");
    mysql_query(Query);
    mysql_store_result();
    if(mysql_num_rows() > 0)
	{
	    new tCount, tgz[32], field[256];
	    while(mysql_fetch_row(Query))
	    {
	    	if (tCount>=MAX_TEAMS)
		    {
		        print("ERROR: Not enough memory to load all the teams. Increase the value of \"MAX_TEAMS\" in the source code");
		        break;
		    }
		    new id;
		    mysql_fetch_int("id", id);
			mysql_fetch_string("name", gTeam[id][tName]);
			mysql_fetch_string("color", gTeam[id][tHex]);
			mysql_fetch_string("gangzonecolor", tgz);
			mysql_fetch_int("skin", gTeam[id][tSkin]);
			mysql_fetch_float("minx", gTeam[id][tBaseXmin]);
			mysql_fetch_float("miny", gTeam[id][tBaseYmin]);
			mysql_fetch_float("maxx", gTeam[id][tBaseXmax]);
			mysql_fetch_float("maxy", gTeam[id][tBaseYmax]);
			mysql_fetch_float("truckx", gTeam[id][tWeapTruckCPX]);
			mysql_fetch_float("trucky", gTeam[id][tWeapTruckCPY]);
			mysql_fetch_float("truckz", gTeam[id][tWeapTruckCPZ]);
 			gTeam[id][tColor]=HexToInt(gTeam[id][tHex]);
	  		gTeam[id][tGZColor]=HexToInt(tgz);
			
	  		//selection text
	  		gTeam[id][tClassText]=TextDrawCreate(320.000000,200.000000,gTeam[id][tName]);
			TextDrawBackgroundColor(gTeam[id][tClassText],255);
			TextDrawFont(gTeam[id][tClassText],1);
			TextDrawLetterSize(gTeam[id][tClassText],1.040000,4.100000);
			TextDrawColor(gTeam[id][tClassText],gTeam[id][tColor]);
			TextDrawSetOutline(gTeam[id][tClassText],0);
			TextDrawSetProportional(gTeam[id][tClassText],1);
			TextDrawSetShadow(gTeam[id][tClassText],1);
			TextDrawAlignment(gTeam[id][tClassText],2);
			
			//gangzone
			gTeam[id][tGZ]=GangZoneCreate(gTeam[id][tBaseXmin],gTeam[id][tBaseYmin],gTeam[id][tBaseXmax],gTeam[id][tBaseYmax]);
			GangZoneShowForAll(gTeam[id][tGZ],gTeam[id][tGZColor]);
			
			//player class
			if(id > 0) AddPlayerClass(gTeam[id][tSkin],0.0,0.0,0.0,0.0,0,0,0,0,0,0);
			
	  		tCount++;
		}
		printf("Loaded %i teams from MySQL",tCount);
	}
	mysql_free_result();
	
	//motd
    format(Query, sizeof(Query), "SELECT `motd` FROM `servercfg`");
    mysql_query(Query);
	mysql_store_result();
	mysql_fetch_string("motd", motd);
	mysql_free_result();
	print(motd);
		
	new File:ReadFile,readline[256],idx;
    print("--> Loading the spawns");
	if (!fexist("Spawns.txt")) print("ERROR: \"Spawns.txt\" can't be found. Skipping the spawns loading.");
	else
	{
	    ReadFile=fopen("Spawns.txt",io_read);
		while (fread(ReadFile,readline))
		{
		    if (strcmp(readline,"AddSpawn(",false,9)) continue; //skip lines that don't start with CreateDynamicObject
		    if (gSpawns>=MAX_SPAWNS)
		    {
		        print("ERROR: Not enough memory to load all the spawns. Increase the value of \"MAX_SPAWNS\" in the source code");
		        break;
		    }
	  		idx=8;
	  		gSpawn[gSpawns][spX]=floatstr(filestrtok(readline,idx));
			gSpawn[gSpawns][spY]=floatstr(filestrtok(readline,idx));
			gSpawn[gSpawns][spZ]=floatstr(filestrtok(readline,idx));
			gSpawn[gSpawns][spA]=floatstr(filestrtok(readline,idx));
			gSpawn[gSpawns][spTeam]=strval(filestrtok(readline,idx));
	  		gSpawns++;
		}
		fclose(ReadFile);
		printf("Loaded %i spawns",gSpawns);
	}

    print("--> Loading the map objects");
	if (!fexist("Objects.txt")) print("ERROR: \"Objects.txt\" can't be found. Skipping the map loading.");
	else
	{
	    new oModel,Float:oX,Float:oY,Float:oZ,Float:oRX,Float:oRY,Float:oRZ,oCount;
	    ReadFile=fopen("Objects.txt",io_read);
		while (fread(ReadFile,readline))
		{
		    if (strcmp(readline,"CreateDynamicObject(",false,20)) continue; //skip lines that don't start with CreateDynamicObject
	  		idx=19;
	  		oModel=strval(filestrtok(readline,idx));
			oX=floatstr(filestrtok(readline,idx));
			oY=floatstr(filestrtok(readline,idx));
			oZ=floatstr(filestrtok(readline,idx));
	  		oRX=floatstr(filestrtok(readline,idx));
	  		oRY=floatstr(filestrtok(readline,idx));
	  		oRZ=floatstr(filestrtok(readline,idx));
	  		CreateDynamicObject(oModel,oX,oY,oZ,oRX,oRY,oRZ, -1, -1, -1, 300.0, 300.0);
	  		oCount++;
		}
		fclose(ReadFile);
		printf("Loaded %i objects",oCount);
	}

    print("--> Loading the map vehicles (CreateVehicle)");
	if (!fexist("Vehicles.txt")) print("ERROR: \"Vehicles.txt\" can't be found. Skipping the vehicles loading.");
	else
	{
	    new vModel,Float:vX,Float:vY,Float:vZ,Float:vA,vColor1,vColor2,vRespawn;
	    ReadFile=fopen("Vehicles.txt",io_read);
		while (fread(ReadFile,readline))
		{
		    if (strcmp(readline,"CreateVehicle(",false,14)) continue; //skip lines that don't start with CreateVehicle
	  		idx=13;
	  		vModel=strval(filestrtok(readline,idx));
			vX=floatstr(filestrtok(readline,idx));
			vY=floatstr(filestrtok(readline,idx));
			vZ=floatstr(filestrtok(readline,idx));
	  		vA=floatstr(filestrtok(readline,idx));
	  		vColor1=strval(filestrtok(readline,idx));
	  		vColor2=strval(filestrtok(readline,idx));
	  		vRespawn=strval(filestrtok(readline,idx));
	  		SetVehHealth(CreateVehicle(vModel,vX,vY,vZ,vA,vColor1,vColor2,vRespawn));
	  		gVehs++;
		}
		fclose(ReadFile);
		printf("Loaded %i vehicles",gVehs);
	}

    print("--> Loading the capturable zones");
	if (!fexist("Zones.txt")) print("ERROR: \"Zones.txt\" can't be found. Skipping the zones loading.");
	else
	{
	    ReadFile=fopen("Zones.txt",io_read);
		while (fread(ReadFile,readline))
		{
		    if (strcmp(readline,"AddZone(",false,8)) continue; //skip lines that don't start with AddZone
		    if (gCapZones>=MAX_CAPZONES)
		    {
		        print("ERROR: Not enough memory to load all the zones. Increase the value of \"MAX_CAPZONES\" in the source code");
		        break;
		    }
	  		idx=7;
	  		format(gCapZone[gCapZones][czName],50,"%s",filestrtok(readline,idx));
	  		ReplaceUnderscores(gCapZone[gCapZones][czName]);
			gCapZone[gCapZones][czMinX]=floatstr(filestrtok(readline,idx));
			gCapZone[gCapZones][czMinY]=floatstr(filestrtok(readline,idx));
			gCapZone[gCapZones][czMaxX]=floatstr(filestrtok(readline,idx));
			gCapZone[gCapZones][czMaxY]=floatstr(filestrtok(readline,idx));
			gCapZone[gCapZones][czCapX]=floatstr(filestrtok(readline,idx));
			gCapZone[gCapZones][czCapY]=floatstr(filestrtok(readline,idx));
			gCapZone[gCapZones][czCapZ]=floatstr(filestrtok(readline,idx));
			gCapZone[gCapZones][czGZ]=GangZoneCreate(gCapZone[gCapZones][czMinX],gCapZone[gCapZones][czMinY],gCapZone[gCapZones][czMaxX],gCapZone[gCapZones][czMaxY]);
	  		gCapZone[gCapZones][czPUID]=CreatePickup(2914,1,gCapZone[gCapZones][czCapX],gCapZone[gCapZones][czCapY],gCapZone[gCapZones][czCapZ],0);
	  		new string[50];
			String("%s",gCapZone[gCapZones][czName]);
			Create3DTextLabel(string,COLOR_WHITE,gCapZone[gCapZones][czCapX],gCapZone[gCapZones][czCapY],gCapZone[gCapZones][czCapZ],65.0,0);
			GangZoneShowForAll(gCapZone[gCapZones][czGZ],HexToInt("0xFFFFFF55"));
	  		gCapZones++;
		}
		fclose(ReadFile);
		printf("Loaded %i capturable zones",gCapZones);
	}

    print("--> Loading the money spots");
	if (!fexist("MoneySpots.txt")) print("ERROR: \"MoneySpots.txt\" can't be found. Skipping the zones loading.");
	else
	{
	    ReadFile=fopen("MoneySpots.txt",io_read);
		while (fread(ReadFile,readline))
		{
		   
		    if (strcmp(readline,"AddMoneySpot(",false,13)) continue; 
		    if (gMoneySpots>=MAX_MONEYSPOTS)
		    {
		        print("ERROR: Not enough memory to load all the money spots. Increase the value of \"MAX_MONEYSPOTS\" in the source code");
		        break;
		    }
	  		idx=12;
			gMoneySpot[gMoneySpots][msX]=floatstr(filestrtok(readline,idx));
			gMoneySpot[gMoneySpots][msY]=floatstr(filestrtok(readline,idx));
			gMoneySpot[gMoneySpots][msZ]=floatstr(filestrtok(readline,idx));
			gMoneySpot[gMoneySpots][msPUID]=CreatePickup(1274,23,gMoneySpot[gMoneySpots][msX],gMoneySpot[gMoneySpots][msY],gMoneySpot[gMoneySpots][msZ],0);//oil
	  		gMoneySpots++;
		}
		fclose(ReadFile);
		printf("Loaded %i money spots",gMoneySpots);
	}
	for (new i=0;i<MAX_MONEYSPOTS;i++) gMoneySpot[i][msPlayer]=-1;

	tw = TextDrawCreate(154.000000, 275.168823, "Welcome to Sector 7 - Desert Warfare.");
	TextDrawBackgroundColor(tw, 255);
	TextDrawFont(tw, 2);
	TextDrawLetterSize(tw, 0.479999, 2.200000);
	TextDrawColor(tw, 16711935);
	TextDrawSetOutline(tw, 0);
	TextDrawSetProportional(tw, 1);
	TextDrawSetShadow(tw, 1);
	
	for(new i=0; i<MAX_VEHICLES; ++i) {
		new model = GetVehicleModel(i);
		if(model == 476) bombs[i] = RUSTLER_BOMBS;
		else if(model == 553) bombs[i] = NEVADA_BOMBS;
	}
    RemoveTBans();
	AppendNewsBox("Server started", 0xFFFFFFFF);
	print("S7:DW loaded");
	return 1;
}

timer ShopDelay[5000](playerid)
{
	PlayerInfo[playerid][pShopDelay] = 0;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	//briefcase pickups
	for (new i=0;i<MAX_BRIEFCASES;i++)
	{
	    if (pickupid!=shop[i]) continue;
		if (!inbriefcase[playerid] && !PlayerInfo[playerid][pShopDelay])
		{
			ShowPlayerDialog(playerid,DIALOG_SHOP,DIALOG_STYLE_LIST,"Shop","Health - $10000\nKevlar Vest - $15000\nBuy Weapons","Select","Close");
			inbriefcase[playerid] = 1;
		}
		return 1;
	}
	//money spots pickups
	for (new i=0;i<gMoneySpots;i++)
	{
		if(iAFKp[playerid] > 2) return 0;
		if (GetPVarInt(playerid,"AdminDuty")) return 1;
		if (pickupid!=gMoneySpot[i][msPUID]) continue;
		else if (gMoneySpot[i][msPlayer]==playerid)
	    {
	        GameTextForPlayer(playerid,"~n~ ~n~ ~n~ ~n~ ~n~~y~You are holding a ~g~$money spot$ ~n~~w~+100~g~$ ~w~per second.",3000,3);
			GivePlayerMoneySync(playerid,100);
		}
	    else
	    {
	        if (IsPlayerInRangeOfPoint(gMoneySpot[i][msPlayer],5.0,gMoneySpot[i][msX],gMoneySpot[i][msY],gMoneySpot[i][msZ]))
	        {
		        new string[100];
		        String("* [%i]%s is already holding this money spot, kill him to be able to hold it!",gMoneySpot[i][msPlayer],gPlayerInfo[gMoneySpot[i][msPlayer]][pName]);
				SendClientMessage(playerid, COLOR_GREEN,string);
				return 1;
			}
			else gMoneySpot[i][msPlayer]=playerid;
     	}
		return 1;
	}
	//cap zones
	for (new i=0;i<gCapZones;i++)
	{
	    if (gCapZone[i][czPUID]!=pickupid) continue;
	    if (GetPVarInt(playerid,"AdminDuty")==1) return 1;
	    if (GetPlayerState(playerid)==PLAYER_STATE_WASTED) return 1;
	    if (GetPVarType(playerid,"CappingZone")!=PLAYER_VARTYPE_NONE) return 1;
	    if (gPlayerInfo[playerid][pTeam]==TEAM_ALQAEDA)
			return SendClientMessage(playerid,COLOR_RED,"Sorry, but Al-Qaeda can't capture!");
	    if (gCapZone[i][czTeam]==gPlayerInfo[playerid][pTeam]) return 1;
	    //assisting capture
	    if (gCapZone[i][czCapping])
	    {
	        if (gCapZone[i][czCappingTeam]!=gPlayerInfo[playerid][pTeam]) return 1;
	        SetPVarInt(playerid,"CappingZone",i);
			SetPlayerCheckpointEx(playerid,gCapZone[i][czCapX],gCapZone[i][czCapY],gCapZone[i][czCapZ],6.0,CP_CAPZONE);
			SendClientMessage(playerid,COLOR_TEAL ,"Capturing, stay in this checkpoint for 30 seconds.");
	    }
	    //starting capture
		else
		{
	        gCapZone[i][czCapping]=1;
	        gCapZone[i][czCappingTeam]=gPlayerInfo[playerid][pTeam];
	        gCapZone[i][czTimeLeft]=30;
			SetPVarInt(playerid,"CappingZone",i);
			SetPlayerCheckpointEx(playerid,gCapZone[i][czCapX],gCapZone[i][czCapY],gCapZone[i][czCapZ],6.0,CP_CAPZONE);
			SendClientMessage(playerid,COLOR_TEAL ,"Capturing, stay in this checkpoint for 30 seconds.");
			GangZoneFlashForAll(gCapZone[i][czGZ],gTeam[gPlayerInfo[playerid][pTeam]][tGZColor]);
		}
	    return 1;
    }
    for(new i = 0; i < 9; i++)
    {
        if(PlayerInfo[playerid][pPickupAble] == 0)
        {
            GivePlayerWeaponEx(playerid, 31, 75);
			PlayerInfo[playerid][pPickupAble] = 1;
		}
    }
	return 1;
}

InterruptCap(playerid)
{
    new zone=GetPVarInt(playerid,"CappingZone");
    DeletePVar(playerid,"CappingZone");
    DisablePlayerCheckpointEx(playerid,CP_CAPZONE);
    new count;
    foreach(Player,i)
    {
        if (GetPVarType(i,"CappingZone")==PLAYER_VARTYPE_NONE) continue;
        if (GetPVarInt(i,"CappingZone")!=zone) continue;
        count++;
    }
    //if all players left that cap zone, reset it
    if (!count)
    {
        gCapZone[zone][czCapping]=0;
    	gCapZone[zone][czCappingTeam]=-1;
		GangZoneStopFlashForAll(gCapZone[zone][czGZ]);
	}
}

public OnPlayerLeaveCheckpoint(playerid)
{
	if (GetPlayerState(playerid)==PLAYER_STATE_SPECTATING) return 1;
	if(GetDistance(playerid, 949.78149414063, 3858.2075195313, 20.012523651123) <= 7.0) return 1;
	if (GetPVarType(playerid,"CappingZone")!=PLAYER_VARTYPE_NONE)
	{
	    SendClientMessage(playerid,COLOR_RED,"Failed to capture, get back in the checkpoint!");
	    InterruptCap(playerid);
	    return 1;
	}
	return 1;
}

public OnGameModeExit()
{
	print("S7:DW unloaded");
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(classid > MAX_CLASSES) //crash protection
	{
		Kick(playerid);
		return 0;
	}
	SetPVarInt(playerid, "NoAB", 4);
	if (gPlayerInfo[playerid][pPlayingTeam])
	{
		gTeam[gPlayerInfo[playerid][pPlayingTeam]][tPlayers]-=1;
		gPlayerInfo[playerid][pPlayingTeam]=0;
	}
	gPlayerInfo[playerid][pChangeClass] = 1;
	
	SetPlayerVirtualWorld(playerid, playerid+2);
	SetPlayerInterior(playerid,0);
    SetPlayerPos(playerid,220.3261,1822.9734,7.5368);
   	SetPlayerFacingAngle(playerid, 270.0);
	SetPlayerCameraPos(playerid,226.7491,1823.0441,7.4141);
	SetPlayerCameraLookAt(playerid,220.3261,1822.9734,7.5368);
 	ApplyAnimation(playerid,"PED","fucku",4.0,0,0,0,0,0);
	
   	for (new i=1;i<MAX_TEAMS;i++) TextDrawHideForPlayer(playerid,gTeam[i][tClassText]);
   	gPlayerInfo[playerid][pTeam]=classid+1;
   	TextDrawShowForPlayer(playerid,gTeam[gPlayerInfo[playerid][pTeam]][tClassText]);
   	SetPlayerTeam(playerid,gPlayerInfo[playerid][pTeam]);
	gPlayerInfo[playerid][pSpawned]=0;
	TextDrawHideForPlayer(playerid, tw);
	UpdateRank(playerid);
	UpdateScoreDisplay(playerid);
	PlayerTextDrawHide(playerid, TeamClassTD[playerid]);
	TextDrawHideForPlayer(playerid, Text:TeamClassTD[playerid]);
	return 1;
}

public OnPlayerConnect(playerid)
{	
	new country[40];
	for(new i; i < 9; i++) TextDrawShowForPlayer(playerid, ConnectTD[i]);
    PlayerInfo[playerid][pSpamMessage] = 0;
    PlayerInfo[playerid][pPickupAble] = 0;
    PlayerInfo[playerid][pShopDelay] = 0;
    Kicked[playerid] = 0;
	gPlayerInfo[playerid][adminhide] = 0;
    gPlayerInfo[playerid][wontteleport] = 0;
	paused[playerid] = false;
    Blocked[playerid] = 0;
	GetPlayerName(playerid, NewsBoxTemp, MAX_PLAYER_NAME);
	GetPlayerCountry(playerid, country, sizeof(country));
    format(NewsBoxTemp, sizeof NewsBoxTemp, "(%i)%s has ~b~joined ~w~the server. (%s)", playerid, NewsBoxTemp, country);
    AppendNewsBox(NewsBoxTemp, 0xFFFFFFFF);
    for(new i = 0; i < 9; i++) TextDrawShowForPlayer(playerid, NewsBox[i]);
	firstconnected[playerid] = 1;
	if(IsPlayerNPC(playerid)) return 1;
	
    //player data initialization
    GetPlayerName(playerid,gPlayerInfo[playerid][pName],MAX_PLAYER_NAME);
    GetPlayerIp(playerid,gPlayerInfo[playerid][pIp],16);
    gPlayerInfo[playerid][pDBID]=-1;
    gPlayerInfo[playerid][pTeam]=0;
    gPlayerInfo[playerid][pPlayingTeam]=0;
    gPlayerInfo[playerid][pClass]=0;
    gPlayerInfo[playerid][pScore]=0;
    SetPlayerScore(playerid,0);
    gPlayerInfo[playerid][pKills]=0;
    gPlayerInfo[playerid][pDeaths]=0;
    gPlayerInfo[playerid][pMoney]=0;
    ResetPlayerMoney(playerid);
    gPlayerInfo[playerid][pRank]=0;
    gPlayerInfo[playerid][pOp]=0;
    gPlayerInfo[playerid][pAlevel]=0;
    gPlayerInfo[playerid][pDonor]=0;
    gPlayerInfo[playerid][pOldlevel]=0;
    gPlayerInfo[playerid][pTemplevel]=0;
    gPlayerInfo[playerid][pLogged]=0;
    gPlayerInfo[playerid][pReggedAcc]=0;

    gPlayerInfo[playerid][pVeh]=-1;
    gPlayerInfo[playerid][pSpawned]=0;
    gPlayerInfo[playerid][pHacker]=0;
    gPlayerInfo[playerid][pChangeClass]=1;
    gPlayerInfo[playerid][pMapIcons]=0;
	
	shotTime[playerid] = 0;
 	shot[playerid] = 0;
	inbriefcase[playerid] = 0;
	pDrunkLevelLast[playerid]  = 0;
    pFPS[playerid] = 0;
	bombable[playerid] = 1;
	KillingSpree[playerid] = 0;
	SessionKills[playerid] = 0;
	CaptureSpree[playerid] = 0;
	Undercover[playerid] = 0;
	lastpmed[playerid] = -1;
	namechange[playerid] = 0;
	IsReconnecting[playerid] = false;
	
	TeamClassTD[playerid] = CreatePlayerTextDraw(playerid, 61.200016, 432.071105, "_");
	PlayerTextDrawLetterSize(playerid, TeamClassTD[playerid], 0.199197, 1.385954);
	PlayerTextDrawAlignment(playerid, TeamClassTD[playerid], 2);
	PlayerTextDrawSetShadow(playerid, TeamClassTD[playerid], 0);
	PlayerTextDrawSetOutline(playerid, TeamClassTD[playerid], 1);
	PlayerTextDrawColor(playerid, TeamClassTD[playerid], -1378294017);
	PlayerTextDrawBackgroundColor(playerid, TeamClassTD[playerid], 51);
	PlayerTextDrawFont(playerid, TeamClassTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TeamClassTD[playerid], 1);
	
    TextDrawShowForPlayer(playerid, Site);
    PlayerTextDrawShow(playerid, TeamClassTD[playerid]);
	
    for(new i=0;i<47;i++) Weapon[playerid][i] = false;
    new count = GetTickCount();
	
	CreateDynamicMapIcon(-249.5393,2595.5779,62.8582, 6, 0, -1, -1, -1, 450.0, MAPICON_LOCAL); //USA
	CreateDynamicMapIcon(-109.3562,1133.3083,22.3094, 6, 0, -1, -1, -1, 450.0, MAPICON_LOCAL); //Europe
	CreateDynamicMapIcon(-2260.0059,2338.0579,4.8208, 6, 0, -1, -1, -1, 450.0, MAPICON_LOCAL); //Asia
	CreateDynamicMapIcon(-1339.9724,500.1256,18.2344, 6, 0, -1, -1, -1, 450.0, MAPICON_LOCAL); //Aus
	CreateDynamicMapIcon(1425.6503,274.7412,19.5547, 6, 0, -1, -1, -1, 450.0, MAPICON_LOCAL); //Sov
	CreateDynamicMapIcon(-790.7833,1613.4938,27.1172, 6, 0, -1, -1, -1, 450.0, MAPICON_LOCAL); //arab
	CreateDynamicMapIcon(1066.5613,1883.7975,10.8203, 6, 0, -1, -1, -1, 450.0, MAPICON_LOCAL); //latino
	CreateDynamicMapIcon(-1316.3888,2509.8765,87.0420, 6, 0, -1, -1, -1, 450.0, MAPICON_LOCAL); //alque
	
	for (new i=0;i<gMoneySpots;i++) AddPlayerMapIcon(playerid,gMoneySpot[i][msX],gMoneySpot[i][msY],gMoneySpot[i][msZ],52,0,0);
	for (new i=0;i<gCapZones;i++)  CreateDynamicMapIcon(gCapZone[i][czCapX], gCapZone[i][czCapY], gCapZone[i][czCapZ], 53, 0, -1, -1, -1, 1000.0, MAPICON_GLOBAL_CHECKPOINT);
	//CreateDynamicMapIcon(Float:x, Float:y, Float:z, type, 0, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 800.0, style = MAPICON_LOCAL);

    ResetPlayerMoney(playerid);
 	SetPlayerInterior(playerid,0);

	gPlayerInfo[playerid][p3DText]=Create3DTextLabel("Just connected...",COLOR_RED,30.0,40.0,50.0,40.0,1);
	Attach3DTextLabelToPlayer(gPlayerInfo[playerid][p3DText],playerid,0.0,0.0,0.7);

	new query[200]; 
	Query("SELECT `IP`,`nick`,`unban` FROM `bans` WHERE `IP`='%s' OR `nick`='%s' ORDER BY `id`",
	gPlayerInfo[playerid][pIp],gPlayerInfo[playerid][pName]);
	mysql_query(query);
	mysql_store_result( );
	if( mysql_num_rows( ) > 0 )
	{
        KickWithMessage(playerid, "You are banned from this server. If you think that this is a mistake, please appeal at www.sector7gaming.com/forums.");
		Kicked[playerid] = 1;
		return 1;
	}
	mysql_free_result( );
	for(new i = 0; i < sizeof(ForbiddenNames); i ++ ) 
	{ 
		if(!strcmp(gPlayerInfo[playerid][pName], ForbiddenNames[i], false)) 
		{ 
			Kicked[playerid] = 1;
			KickWithMessage(playerid, "You have connected with a forbidden name, please reconnect with a different name.");
			return 1;
		} 
	}
	Query("SELECT `user` FROM `playerinfo` WHERE `user`='%s'",gPlayerInfo[playerid][pName]); //selects the line where the playername is the player
	mysql_query(query); //querys the string
    mysql_store_result(); //stores the result
    if(mysql_num_rows() != 0)
	{
     	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD , "Login", "This account is registered, please login.", "OK", "Cancel");
     	gPlayerInfo[playerid][pReggedAcc]=1;
    }
    else {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD , "Register", "This account is not registered, please register.", "OK", "Cancel");
    }
    mysql_free_result();
    //bot check
	new num_players_on_ip = GetNumberOfPlayersOnIP(gPlayerInfo[playerid][pIp]);
	if(num_players_on_ip > MAX_CONNECTIONS_FROM_IP) {
		new year, month, day;
		getdate( year, month, day );
		new hour, minute, second;
		gettime(hour, minute, second);
		new escname[24];
		mysql_real_escape_string(gPlayerInfo[playerid][pName], escname);
		new timestring[20];
		format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
		Query("INSERT INTO bans (nick,time,reason,bannedby,IP) VALUES ('%s','%s','bot attack','%s','%s')",
		escname,timestring,BOT_NAME,gPlayerInfo[playerid][pIp]);
		mysql_query(query);
		KickWithMessage(playerid, "You have automatically been banned for bot attacks. If you think this is an error, appeal at www.sector7gaming.com/forums.");
	    return 1;
	}
    TextDrawShowForPlayer(playerid,tw);
	RemoveBuildingForPlayer(playerid, 1223, -2207.7266, 2293.8906, 3.9688, 0.25);
	RemoveBuildingForPlayer(playerid, 3474, 1124.6797, 1963.3672, 16.7422, 0.25);
	RemoveBuildingForPlayer(playerid, 11437, -775.5938, 1555.6797, 26.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 16413, -174.2109, 1120.4531, 24.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 16443, -161.1719, 1179.5313, 22.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 16447, -219.3750, 1176.6563, 22.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 16476, -98.1953, 1180.0703, 18.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 3369, 269.2656, 2411.3828, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3367, 296.1406, 2438.2500, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 16617, -122.7422, 1122.7500, 18.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 16618, -117.7656, 1079.4609, 22.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 16762, -327.6094, 2678.5469, 61.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 16765, -227.4531, 2716.3516, 62.1719, 0.25);
	RemoveBuildingForPlayer(playerid, 16061, -193.3750, 1055.2891, 18.3203, 0.25);
	RemoveBuildingForPlayer(playerid, 774, -82.9688, 1022.7813, 18.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 669, -164.3750, 1078.3906, 17.7656, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, -166.7500, 1107.9688, 18.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 16070, -174.2109, 1120.4531, 24.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1692, -161.7656, 1115.8516, 27.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 16760, -178.2031, 1122.3203, 28.8594, 0.25);
	RemoveBuildingForPlayer(playerid, 16740, -152.3203, 1144.0703, 30.3047, 0.25);
	RemoveBuildingForPlayer(playerid, 16060, -192.0469, 1147.3906, 17.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1345, -170.1719, 1169.0547, 19.5391, 0.25);
	RemoveBuildingForPlayer(playerid, 16064, -161.1719, 1179.5313, 22.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 16065, -219.3750, 1176.6563, 22.1641, 0.25);
	RemoveBuildingForPlayer(playerid, 1692, -174.2422, 1177.8984, 22.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 16386, -117.7656, 1079.4609, 22.2188, 0.25);
	RemoveBuildingForPlayer(playerid, 1308, -86.8438, 1088.4141, 19.4844, 0.25);
	RemoveBuildingForPlayer(playerid, 1294, -90.7891, 1093.6953, 23.2031, 0.25);
	RemoveBuildingForPlayer(playerid, 16385, -122.7422, 1122.7500, 18.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 16475, -98.1953, 1180.0703, 18.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 3269, 269.2656, 2411.3828, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 3271, 296.1406, 2438.2500, 15.4766, 0.25);
	RemoveBuildingForPlayer(playerid, 16402, -318.2891, 2650.2422, 69.0156, 0.25);
	RemoveBuildingForPlayer(playerid, 16776, -237.0234, 2662.8359, 62.6094, 0.25);
	RemoveBuildingForPlayer(playerid, 1340, -197.4922, 2659.9141, 62.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 669, -206.6328, 2672.2422, 61.8438, 0.25);
	RemoveBuildingForPlayer(playerid, 16400, -327.6094, 2678.5469, 61.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 672, -243.0313, 2688.3047, 62.4844, 0.25);
	RemoveBuildingForPlayer(playerid, 669, -202.5703, 2687.9688, 61.8438, 0.25);
	RemoveBuildingForPlayer(playerid, 16011, -227.4531, 2716.3516, 62.1719, 0.25);
	SetPlayerColor(playerid, COLOR_LIGHTGRAY);
	for (new i=0;i<=20;i++) SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, -1, "Welcome to Sector 7 Desert Warfare | Community website/forums: www.sector7gaming.com | Be sure to read /help and /rules!");
	SendClientMessage(playerid, MOTDCOLOR, motd);
	printf("Time to execute connect for '%s'(%d): %dms.",gPlayerInfo[playerid][pName], playerid, GetTickCount() - count);
	return 1;
}

new dreasons[3][] = {"~y~timeout", "~y~quit", "~y~kicked/banned"};

public OnPlayerDisconnect(playerid,reason)
{
    PlayerInfo[playerid][pShopDelay] = 0;
	//newsbox
    GetPlayerName(playerid, NewsBoxTemp, MAX_PLAYER_NAME);
    format(NewsBoxTemp, sizeof NewsBoxTemp, "(%i)%s has ~r~left ~w~the server (%s~w~).", playerid, NewsBoxTemp, dreasons[reason]);
    AppendNewsBox(NewsBoxTemp, 0xFFFFFFFF);
    //EO newsbox
    gPlayerInfo[playerid][wontteleport] = 0;
	Muted[playerid] = 0;
	Jailed[playerid] = 0;
	Blocked[playerid] = 0;
	firstspawn[playerid] = 0;
	gPlayerInfo[playerid][adminhide] = 0;
    Kicked[playerid] = 0;
	SpamCount[playerid] = 0;
	namechange[playerid] = 0;
	DestroyVehicle(GetPVarInt(playerid, "RCc"));
	DeletePVar(playerid, "RCc");
	if(IsReconnecting[playerid])
	{	
		UnBlockIpAddress("ReconnectPIP[playerid]");
		IsReconnecting[playerid] = false;
	}
	if(gPlayerInfo[playerid][pTemplevel] == 1) gPlayerInfo[playerid][pAlevel] = gPlayerInfo[playerid][pOldlevel];
	if (gPlayerInfo[playerid][pPlayingTeam])
	{
		gTeam[gPlayerInfo[playerid][pPlayingTeam]][tPlayers]-=1;
		gPlayerInfo[playerid][pPlayingTeam]=0;
	}
	if (gPlayerInfo[playerid][pLogged] == 1)
	{
		new query[128];
		Query("UPDATE `playerinfo` SET `online` = '0', `laston` = '%d' WHERE `user` = '%s'", gettime(), gPlayerInfo[playerid][pName]);
		mysql_query(query);
	}
	SaveStats(playerid);
	if (GetPVarType(playerid,"CappingZone")!=PLAYER_VARTYPE_NONE) InterruptCap(playerid);
    Delete3DTextLabel(gPlayerInfo[playerid][p3DText]);
    ResetPlayerMoney(playerid);
	KillTimer(justspawnedtimer[playerid]); justspawnedtimer[playerid] = -1;
	if(gPlayerInfo[playerid][pVeh] != -1)
	{
		DestroyVehicle(gPlayerInfo[playerid][pVeh]);
		gPlayerInfo[playerid][pVeh]=-1;
	}
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(gPlayerInfo[playerid][pAlevel] >= 1 && GetPVarInt( playerid, "AdminDuty") == 1)
	{
	    if(IsPlayerInAnyVehicle(playerid))
		{
		    SetPVarInt(playerid, "NoAB", 4);
		    new vehid =GetPlayerVehicleID(playerid);
		    SetVehiclePos(vehid, fX, fY, fZ);
		    SetPlayerPosFindZ(playerid, fX, fY, fZ);
		    PutPlayerInVehicle(playerid, vehid, 0);
		}
		else
		{
		    SetPVarInt(playerid, "NoAB", 4);
			SetPlayerPosFindZ(playerid, fX, fY, fZ);
		}
		AdminCommand(playerid, "MAPTELEPORT");
	}
	if (gPlayerInfo[playerid][pAlevel]>=6) printf("[DEVEL] Level 6+ clicked cords %.3f %.3f %.3f.",fX,fY,fZ);
 	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(issuerid != INVALID_PLAYER_ID)
    {
		if(GetPVarInt(playerid, "aFly") == 1) return 1;
		PlayerPlaySound(issuerid, 17802, 0, 0, 0);
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
	if(GetPVarInt(damagedid, "AdminDuty" ) == 1 && gPlayerInfo[playerid][pAlevel] < 1)
	    GameTextForPlayer(playerid, "~r~DON'T SHOOT ADMINS ON DUTY!", 10000, 6);
	if(gPlayerInfo[playerid][pTeam] == gPlayerInfo[damagedid][pTeam] && !IsPlayerInAnyVehicle(playerid) && gPlayerInfo[playerid][pAlevel]< 1)
		GameTextForPlayer(playerid, "~r~Don't shoot your team mates!", 900, 6);
    return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    if(weaponid != 38 && weaponid != 30 && weaponid != 31 && weaponid != 28 && weaponid != 32)
	{
		if((gettime() - shotTime[playerid]) < 1)
		{
		    shot[playerid]+=1;
		}
		else
		{
		    shot[playerid]=0;
		}
		if(shot[playerid] > 10 && !Kicked[playerid] && !gPlayerInfo[playerid][pAlevel])
		{
			shot[playerid] = 0;
  			new string[128], ip[16];
		    GetPlayerIp(playerid, ip, 16);
			String("[AUTOBAN] %s has been banned for rapidfire hacks.",gPlayerInfo[playerid][pName]);
			SendClientMessageToAll(COLOR_RED, string);
			new query[256];
			new year, month, day;
			getdate(year, month, day);
			new hour, minute, second;
			gettime(hour, minute, second);
			new escname[24];
			mysql_real_escape_string(gPlayerInfo[playerid][pName], escname);
			new timestring[20];
			format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
			format(query, sizeof query, "INSERT INTO bans (nick, time, reason, bannedby, IP) VALUES ('%s', '%s', 'rapidfire hacks', '%s', '%s')", escname, timestring, BOT_NAME, ip);
			mysql_query(query);
			KickWithMessage(playerid, "You have been banned for rapidfire hacks. If you think this is a mistake, you may appeal at www.sector7gaming.com/forums.");
			Kicked[playerid] = 1;
			return 1;
		}
		shotTime[playerid] = gettime();
	}
    return 1;
}

public OnPlayerSpawn(playerid)
{
    AntiDeAMX();
    SetPVarInt(playerid, "NoAB", 4);
    SetCameraBehindPlayer(playerid);
	if(Jailed[ playerid ] == 1) return SetPlayerHealth(playerid, 100000);
	if(firstspawn[playerid] == 0)
	{
	    firstspawn[playerid] = 1;
	}
	if(gPlayerInfo[playerid][joined] == 0)
	{
		TogglePlayerControllable(playerid, 1);
	}
	firstconnected[playerid] = 0;
    KillTimer(justspawnedtimer[playerid]);
    justspawnedtimer[playerid] = SetTimerEx("JustSpawned",15000, false, "d", playerid);
    if(GetPVarInt(playerid, "AdminDuty") < 1)
    {
    	Update3DTextLabelText(gPlayerInfo[playerid][p3DText],COLOR_RED,"Anti spawn kill");
    	SetPlayerHealth(playerid, 50000);
	}
	if(gSyncInfo[playerid][sync] == true) {
	    gSyncInfo[playerid][sync] = false;
	    SetPVarInt(playerid, "NoAB", 4);
	    SetPlayerPos(playerid, gSyncInfo[playerid][sx], gSyncInfo[playerid][sy], gSyncInfo[playerid][sz]);
	    SetPlayerHealth(playerid, gSyncInfo[playerid][shealth]);
	    SetPlayerArmour(playerid, gSyncInfo[playerid][sarmour]);
	    SetPlayerInterior(playerid, gSyncInfo[playerid][sint]);
	    SetPlayerVirtualWorld(playerid, gSyncInfo[playerid][svw]);
	    for(new i = 0; i < 13; i++) GivePlayerWeaponEx(playerid, syncwep[i][0], syncwep[i][1]);
	    return 1;
	}
	SyncMoney(playerid);
	SetPlayerVirtualWorld(playerid, 0);
	/*if(gPlayerInfo[playerid][pDonor] > 0)
	{
		foreach(Player, i)
		{
	    	SetPlayerMarkerForPlayer(i, playerid, (GetPlayerColor(1) & 0xFFFFFF00));
		}
	}*/
    SetPlayerTeam(playerid, gPlayerInfo[playerid][pTeam]);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN, 1);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI, 1);
    if (!GetPVarInt(playerid, "color")) SetPVarInt(playerid, "color", 18643);
	dueling[playerid] = 0;
   	if(gPlayerInfo[playerid][pTeam] != TEAM_ALQAEDA && gPlayerInfo[playerid][pChangeClass] == 1) {
		classdialog;
	}
	if (gPlayerInfo[playerid][pTeam] == TEAM_ALQAEDA)
	{
		gPlayerInfo[playerid][pClass] = CLASS_ASSAULT;
	    GivePlayerWeaponEx(playerid, 35, 2);
        GivePlayerWeaponEx(playerid, 16, 2);
    	GivePlayerWeaponEx(playerid, 30, 400);
		GivePlayerWeaponEx(playerid, 16, 2);
	}
	if(!GetPVarInt(playerid, "hackchecked"))
	{
		if(gPlayerInfo[playerid][pChangeClass] == 0 || gPlayerInfo[playerid][pTeam] == TEAM_ALQAEDA) {
			TogglePlayerControllable(playerid, 0);
			SetTimerEx("HackCheck", FREEZE_SECONDS * 1000, 0, "i", playerid);
			SendClientMessage(playerid, COLOR_AQUA, "You are currently being processed... please wait...");
			SetPVarInt(playerid, "hackchecked", 1);
		}
	}
	DeletePVar(playerid, "aFly");
	if(gPlayerInfo[playerid][pChangeClass] == 0)
	{
 		SetPlayerSkin(playerid, gTeam[gPlayerInfo[playerid][pTeam]][tSkin]);
	    SetPlayerTeam(playerid, gPlayerInfo[playerid][pTeam]);
	    switch(gPlayerInfo[playerid][pClass])
	    {
	        case CLASS_ASSAULT:
	        {
     	 		GivePlayerWeaponEx(playerid, 29, 400);
				GivePlayerWeaponEx(playerid, 31, 500);
				GivePlayerWeaponEx(playerid, 24, 150);
	        }
	        case CLASS_ENGINEER:
	        {
     	 		GivePlayerWeaponEx(playerid, 25, 200);
	 			GivePlayerWeaponEx(playerid, 24, 150);
	 			GivePlayerWeaponEx(playerid, 16, 2);
	 			GivePlayerWeaponEx(playerid, 30, 400);
	 			GivePlayerWeaponEx(playerid, 35, 3);
	        }
	        case CLASS_SNIPER:
	        {
      			GivePlayerWeaponEx(playerid, 23, 100);
				GivePlayerWeaponEx(playerid, 16, 2);
				GivePlayerWeaponEx(playerid, 34, 100);
				GivePlayerWeaponEx(playerid, 4, 1);
	        }
	        case CLASS_MEDIC:
	        {
      			GivePlayerWeaponEx(playerid, 29, 500);
				GivePlayerWeaponEx(playerid, 24, 150);
				GivePlayerWeaponEx(playerid, 30, 400);
	        }
	        case CLASS_SUPPORTER:
	        {
      			GivePlayerWeaponEx(playerid, 29, 500);
				GivePlayerWeaponEx(playerid, 24, 150);
				GivePlayerWeaponEx(playerid, 27, 110);
	        }
			case CLASS_JETTROOPER:
	        {
				GivePlayerWeaponEx(playerid, 24, 150);
				GivePlayerWeaponEx(playerid, 26, 100);
				GivePlayerWeaponEx(playerid, 28, 150);
	        }
			case CLASS_PILOT:
	        {
      			GivePlayerWeaponEx(playerid, 29, 500);
				GivePlayerWeaponEx(playerid, 23, 150);
				GivePlayerWeaponEx(playerid, 25, 300);
				GivePlayerWeaponEx(playerid, 46, 1);
	        }
	    }
	}
	if(GetPVarInt(playerid, "Spec") == 1)
	{
	    GameTextForPlayer(playerid, "a",1,5);
	}
	if(GetPVarInt(playerid, "Jailed") == 1)
	{
	    SetPVarInt(playerid, "NoAB", 4);
       	TogglePlayerControllable(playerid,true);
		SetPlayerPos(playerid,197.6661,173.8179,1003.0234);
		SetPlayerInterior(playerid,3);
	}
    new spawnid;
    {
		SetPVarInt(playerid, "NoAB", 4);
		//player position
		do spawnid=random(gSpawns);
		while (gSpawn[spawnid][spTeam]!=gPlayerInfo[playerid][pTeam]);
		SetPlayerPos(playerid,gSpawn[spawnid][spX],gSpawn[spawnid][spY],gSpawn[spawnid][spZ]);
		SetPlayerFacingAngle(playerid,gSpawn[spawnid][spA]);
		SetPlayerInterior(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
		SetPlayerColor(playerid,gTeam[gPlayerInfo[playerid][pTeam]][tColor]);
	}
	if(GetPVarInt( playerid, "Frozen" ) == 1) TogglePlayerControllable(playerid, 0);
	gPlayerInfo[playerid][pSpawned]=1;
	SetPlayerMoneySync(playerid,gPlayerInfo[playerid][pMoney]);
	//gangzones
	for (new i=1;i<MAX_TEAMS;i++)
	{
		GangZoneShowForPlayer(playerid,gTeam[i][tGZ],gTeam[i][tGZColor]);
		TextDrawHideForPlayer(playerid,gTeam[i][tClassText]);
	}
	for (new i=0;i<gCapZones;i++) GangZoneShowForPlayer(playerid,gCapZone[i][czGZ],gTeam[gCapZone[i][czTeam]][tGZColor]);
	if(GetPVarInt(playerid, "AdminDuty") == 1)
	{
		ADutyFunctions(playerid);
	}
	bombable[playerid] = 1;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	new string[128];
	PlayerInfo[playerid][pPickupAble] = 0;
    KillTimer(justspawnedtimer[playerid]);
	DestroyVehicle(GetPVarInt(playerid, "RCc"));
    DeletePVar(playerid, "RCc");
    SetPVarInt(playerid, "NoAB", 4);
	for (new i=0;i<gMoneySpots;i++) if(gMoneySpot[i][msPlayer]==playerid) gMoneySpot[i][msPlayer]=-1;
	KillingSpree[playerid] = 0;
	CaptureSpree[playerid] = 0;
    if (killerid != INVALID_PLAYER_ID)
	{
		if(dueling[playerid])
		{
			SetPlayerHealth(playerid, 0);
			GameTextForPlayer(killerid,"~g~YOU WON THE DUEL!",3000,5);
			dueling[playerid]=0;
			dueling[killerid]=0;
			SetPVarInt(killerid, "NoAB", 4);
			SpawnPlayer(killerid);
			return 1;
		}
		else
		{
			String("~r~~h~You killed %s", gPlayerInfo[playerid][pName]);
			GameTextForPlayer(killerid, string, 1450, 6);
		}
		new weaponname[32], pname[30];
		GetPlayerName(killerid, pname, 24);
	    if(IsPlayerInAnyVehicle(killerid) && GetPlayerState(killerid) == PLAYER_STATE_DRIVER)
		{
		    new vehicleid = GetPlayerVehicleID(killerid);
		    new modelid = GetVehicleModel(vehicleid);
   			format(string, sizeof string, "You have been killed by %s with a %s.",pname,VehicleNames[modelid-400]);
			SendClientMessage(playerid, COLOR_LIMEGREEN, string);
		}
		else
		{
			GetWeaponName(reason,weaponname,sizeof(weaponname));
			if(reason == 51 && !IsPlayerInAnyVehicle(killerid)) weaponname="explosive device";
			if(reason == 0) weaponname="fist";
			format(string, sizeof string, "You have been killed by %s with a %s.", pname, weaponname);
			SendClientMessage(playerid, COLOR_LIMEGREEN, string);
		}
        if (gPlayerInfo[killerid][pTeam]==gPlayerInfo[playerid][pTeam])
		{
            GivePlayerScoreSync(killerid,-1);
            SendClientMessage(killerid, COLOR_RED, "You lost 1 score for killing your own team mate!");
        }
        else
		{
		    gPlayerInfo[killerid][pKills]++;
 			KillingSpree[killerid]++;
			SessionKills[killerid]++;
			new vehid=GetPlayerVehicleID(killerid);
			//cut the rewards if he was in a powerful vehicle
			new money,score;
			if (!vehid)
			{
				money = random(3000)+2000;
				score=1;
			}
			else
			{
			    new model=GetVehicleModel(vehid);
			    switch (model)
			    {
			        case 425: money = random(500)+500; //hunter
			        case 520: money = random(1500)+500; //hydra
			        case 447: money = random(1500)+500; //seasparrow
			        case 432: { money = random(1500)+500; score=1; } //rhino
			        case 476: { money=random(10000); score=1; } //rustler
			        default: { money=random(3000)+2000; score=1; }
			    }
			}
			new wep=GetPlayerWeapon(killerid);
			switch(wep)
			{
			    case 16: GivePlayerWeaponEx(killerid,16,1);
				case 18: GivePlayerWeaponEx(killerid,18,1);
				case 26: GivePlayerWeaponEx(killerid,26,50);
				case 28: GivePlayerWeaponEx(killerid,28,200);
				case 32: GivePlayerWeaponEx(killerid,32,200);
				case 34: GivePlayerWeaponEx(killerid,34,30);
				case 35: GivePlayerWeaponEx(killerid,35,1);
				case 36: GivePlayerWeaponEx(killerid,36,1);
				case 39: GivePlayerWeaponEx(killerid,39,1);
				default: GivePlayerWeaponEx(killerid,wep,100);
			}
			if (score) String("You gained %d score, $%d and some ammo for killing enemy %s(%d)!",score,money,gPlayerInfo[playerid][pName],playerid);
			else String("You gained $%d and some ammo for killing enemy %s(%d)!",money,gPlayerInfo[playerid][pName],playerid);
			SendClientMessage(killerid, COLOR_LIMEGREEN, string);
			string = "\0";
			GivePlayerScoreSync(killerid,score);
 	   		GivePlayerMoneySync(killerid,money);
			switch(KillingSpree[killerid])
			{
				case 3: {
					String("[SPREE] %s(%d) is getting into the game with a killing spree of 3!",gPlayerInfo[killerid][pName],killerid);
					SendClientMessageToAll(COLOR_ORANGE, string);
				}
				case 5: {
					String("[SPREE] %s(%d) is on a killing spree! (made 5 kills without dying).",gPlayerInfo[killerid][pName],killerid);
					SendClientMessageToAll(COLOR_ORANGE, string);
					SendClientMessage(killerid, COLOR_YELLOW, "For the spree of 5 kills, you got 2 score and $2000 as a bonus!");
					GivePlayerMoneySync(killerid, 2000);
					GivePlayerScoreSync(killerid, 2);
				}
				case 10: {
					String("[SPREE] %s(%d) is on a rampage! (made 10 kills without dying).",gPlayerInfo[killerid][pName], killerid);
					SendClientMessageToAll(COLOR_ORANGE, string);
					SendClientMessage(killerid, COLOR_YELLOW, "For the spree of 10 kills, you got 5 score and $5000 as a bonus!");
					GivePlayerMoneySync(killerid, 5000);
					GivePlayerScoreSync(killerid, 5);
				}
				case 15: {
					String("[SPREE] %s(%d) is PWNING! (made 15 kills without dying).",gPlayerInfo[killerid][pName],killerid);
					SendClientMessageToAll(COLOR_ORANGE, string );
					SendClientMessage(killerid, COLOR_YELLOW, "For the spree of 15 kills, you got 7 score and $7000 as a bonus!");
					GivePlayerMoneySync(killerid, 7000);
					GivePlayerScoreSync(killerid,7);
				}
				case 25: {
					String("[SPREE] %s(%d) is DESTROYING! (made 20+ kills without dying).",gPlayerInfo[killerid][pName], killerid);
					SendClientMessageToAll(COLOR_ORANGE, string);
					SendClientMessage(killerid, COLOR_YELLOW, "You got +1 score and $5000 for the 20+ kills spree as a bonus!");
					SendClientMessage(killerid, COLOR_YELLOW, "Press C to get an RC-XD");
					GivePlayerScoreSync(killerid,1);
					GivePlayerMoneySync(killerid, 5000);
					SetPVarInt(killerid, "RC",1);
				}
				case 100: {
				    String("[SPREE] %s(%d) is GODLIKE! (made 100 kills without dying).",gPlayerInfo[killerid][pName], killerid);
				    SendClientMessageToAll(COLOR_ORANGE, string);
					SendClientMessage(killerid, COLOR_YELLOW, "You got +10 score,$10000 and a Nuclear Missle for the 100 kills spree as a bonus!");
					SendClientMessage(killerid, COLOR_YELLOW, "Press Y to activate your Nuclear Weaponary!");
					GivePlayerScoreSync(killerid, 10);
					GivePlayerMoneySync(killerid, 10000);
				}
			}
			if(KillingSpree[killerid] > 20)
			{
				SendClientMessage(killerid, COLOR_YELLOW, "You got +1 score and $5000 for the 20+ kills spree as a bonus!");
				GivePlayerScoreSync(killerid, 1);
				GivePlayerMoneySync(killerid, 5000);
			}
			if(SessionKills[killerid] == 50)
			{
				String("[SPREE] %s(%d) is OWNING - they have made 50 session kills!",gPlayerInfo[killerid][pName], killerid); 
				SendClientMessageToAll(COLOR_ORANGE, string);
				SendClientMessage(killerid, COLOR_TEAL, "You got 5 score and $10000 as a bonus for 50 session kills!"); 
				GivePlayerMoneySync(killerid, 10000);
				GivePlayerScoreSync(killerid, 5);
			}
		}
		if (gPlayerInfo[playerid][pTeam]!=gPlayerInfo[killerid][pTeam] && IsPlayerInBase(playerid))
		{
			new KillerVeh=GetVehicleModel(GetPlayerVehicleID(killerid));
			if(IsPlayerInAnyVehicle(killerid) && KillerVeh == 425 || KillerVeh == 447 || KillerVeh == 520 || KillerVeh == 432)
			{
				DestroyVehicle(GetPlayerVehicleID(killerid));
				SendClientMessage(killerid, COLOR_RED, "Do NOT attack players in their home base with heavy vehicles! Read /hvrules!");
				SendClientMessage(killerid, COLOR_RED, "You have been automatically killed and deducted 2 kills and 2 score!");
				SetPlayerHealth(killerid, 0.0);
				GivePlayerScoreSync(killerid,-2);
				gPlayerInfo[playerid][pKills]++;
				String("%s has violated the heavy vehicle rules on you(/hvrules) by killing you in your base.",gPlayerInfo[killerid][pName]);
				SendClientMessage(playerid, COLOR_ORANGE, string);
				SendClientMessage(playerid, COLOR_ORANGE, "You have been deducted 1 death and given 1 kill for the violation.");
				gPlayerInfo[killerid][pKills]--;
				AutoWarn(killerid, "violating heavy vehicle rules(/hvrules) - base raping");
				print(string);
			}
		}
	} //EO invalid killerid check
	new vehid=GetPlayerVehicleID(playerid);
	//cut the rewards if he was in a powerful vehicle
	if (vehid && GetPVarInt(playerid, "AdminDuty") == 0)
	{
		new moneyloss,extra,mextra;
		new model=GetVehicleModel(vehid);
		switch (model)
		{
			case 425: { moneyloss = 1000; extra=2; mextra=8000; } //hunter
			case 520: { moneyloss = 1500; extra=2; mextra=8000; } //hydra
			case 447: { moneyloss = 500; extra=1; mextra=2000; } //seasparrow
			case 432: { moneyloss = 1000; extra=2; mextra=5000; } //rhino
		}
		if (moneyloss)
		{
			String("You have completely destroyed an expensive vehicle. $%d has been taken from your pay!", moneyloss);
			SendClientMessage(playerid, COLOR_RED, string);
			GivePlayerMoneySync(playerid, -moneyloss);
		}
		if (killerid!=INVALID_PLAYER_ID)
		{
			if (extra)
			{
				String("You received %d score and $%d for killing an enemy who was using a powerful vehicle.", extra,mextra);
				SendClientMessage(killerid, COLOR_LIMEGREEN, string);
				GivePlayerScoreSync(killerid, extra);
				GivePlayerMoneySync(killerid, mextra);
			}
		}
	}
	if (GetPVarType(playerid,"CappingZone")!=PLAYER_VARTYPE_NONE)
	{
	    SendClientMessage(playerid,COLOR_RED,"Failed to capture, you died!");
	    InterruptCap(playerid);
	}
	SendDeathMessage(killerid, playerid, reason);
	Update3DTextLabelText(gPlayerInfo[playerid][p3DText], COLOR_RED, "Died...");
 	RemovePlayerAttachedObject(playerid,0);
	UpdateRank(playerid);
    gPlayerInfo[playerid][pSpawned]=0;
    gPlayerInfo[playerid][pDeaths]++;
	if(GetPVarInt(playerid, "RCDeath") == 1) return 0;
	DeletePVar(playerid, "RC");
	DeletePVar(playerid, "ERC");
	SetPlayerColor(playerid, COLOR_LIGHTGRAY);
    return 1;
}

PUB:ShowVehicle(vehicleid) SetVehicleVirtualWorld(vehicleid,0);

HideVehicle(vehicleid,modelid,time)
{
	if (GetVehicleModel(vehicleid)!=modelid) return;
	SetVehicleVirtualWorld(vehicleid,1);
	SetTimerEx("ShowVehicle",time*1000,0,"i",vehicleid);
}

public OnVehicleSpawn(vehicleid)
{
	foreach(Player,i)
	{
		if (gPlayerInfo[i][pVeh]==-1) continue;
		if (gPlayerInfo[i][pVeh]!=vehicleid) continue;
		DestroyVehicle(gPlayerInfo[i][pVeh]);
		gPlayerInfo[i][pVeh]=-1;
	}
	new model = GetVehicleModel(vehicleid);
	if(model == 476) bombs[vehicleid] = RUSTLER_BOMBS;
	if(model == 553) bombs[vehicleid] = NEVADA_BOMBS;
	SetVehHealth(vehicleid);
	//the following vehicles don't "respawn" immediately, to prevent excessive noobing
	HideVehicle(vehicleid,425,60); //hunter
	HideVehicle(vehicleid,520,60); //hydra
	HideVehicle(vehicleid,447,30); //seasparrow
	HideVehicle(vehicleid,432,30); //rhino
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	foreach(Player, i)
	{
	    if(GetPVarInt(i, "RCc") == vehicleid)
	    {
	    	DestroyVehicle(GetPVarInt(i, "RCc"));
 			DeletePVar(i, "RCc");
	    }
	}
    new model = GetVehicleModel(vehicleid);
	if(model == 476) bombs[vehicleid] = RUSTLER_BOMBS;
	if(model == 553) bombs[vehicleid] = NEVADA_BOMBS;
	return 1;
}

timer AntiSpam[750](playerid)
{
	PlayerInfo[playerid][pSpamMessage] = 0;
}

stock SpamAction(playerid)
{
	if(PlayerInfo[playerid][pSpamMessage] == 1 && gPlayerInfo[playerid][pAlevel] < 1)
	{
		SendClientMessage(playerid, spam);
		SpamCount[playerid]++;
		if(SpamCount[playerid] > 5 && !Kicked[playerid])
		{
			new string[90];
			String("[AUTOKICK] %s has been kicked from the server for spamming.",gPlayerInfo[playerid][pName]);
			SendClientMessageToAll(COLOR_YELLOW, string);
			Kicked[playerid]=1;
			KickWithMessage(playerid, "You have automatically been kicked for spamming.");
		}
		return 0;
	}
	PlayerInfo[playerid][pSpamMessage] = 1;
	defer AntiSpam(playerid);
	return 0;
}

public OnPlayerText(playerid, text[] )
{
	if (gPlayerInfo[playerid][pLogged] != 1)
	    return SendClientMessage(playerid, COLOR_RED, "You need to log in before speaking!"), 0;
		
	if(PlayerInfo[playerid][pSpamMessage] == 1 && gPlayerInfo[playerid][pAlevel] < 1)
	{
		SendClientMessage(playerid, spam);
		SpamCount[playerid]++;
		if(SpamCount[playerid] > 5 && !Kicked[playerid])
		{
			new string[90];
			String("[AUTOKICK] %s has been kicked from the server for spamming.",gPlayerInfo[playerid][pName]);
			SendClientMessageToAll(COLOR_YELLOW, string);
			Kicked[playerid]=1;
			KickWithMessage(playerid, "You have automatically been kicked for spamming.");
		}
		return 0;
	}
	PlayerInfo[playerid][pSpamMessage] = 1;
	defer AntiSpam(playerid);
	
	new hour, minute, second, year, month, day;
	gettime(hour, minute, second);
	getdate(year, month, day);
	if(Muted[playerid] == 1)
	{
	    SendClientMessage(playerid, muted);
	    return 0;
	}
	new string[128];
	String("[%d]%s: {FFFFFF}%s",playerid,gPlayerInfo[playerid][pName],text);
	SendClientMessageToAll(GetPlayerColor(playerid), string);
	return 0;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
    if(gPlayerInfo[playerid][pLogged] != 1)
    {
        SendClientMessage(playerid, COLOR_RED, "You need to login to use commands.");
        return 0;
    }
	
	if(PlayerInfo[playerid][pSpamMessage] == 1 && gPlayerInfo[playerid][pAlevel] < 1)
	{
		SendClientMessage(playerid, spam);
		SpamCount[playerid]++;
		if(SpamCount[playerid] > 5 && !Kicked[playerid])
		{
			new string[90];
			String("[AUTOKICK] %s has been kicked from the server for command spamming.",gPlayerInfo[playerid][pName]);
			SendClientMessageToAll(COLOR_YELLOW, string);
			Kicked[playerid]=1;
			KickWithMessage(playerid, "You have automatically been kicked for command spamming.");
		}
		return 0;
	}
	PlayerInfo[playerid][pSpamMessage] = 1;
	defer AntiSpam(playerid);

	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	printf("CMD: '%s'(%d): '%s'(%d)",gPlayerInfo[playerid][pName], playerid, cmdtext, success);
	new string[128];
	String("CMD: (%d)%s: %s",playerid,gPlayerInfo[playerid][pName],cmdtext);
	foreach(Player, i) 
	{
		if (GetPVarInt(i,"cmdLogs")==1 && gPlayerInfo[i][pAlevel] >= 6 && i!=playerid)		
		SendClientMessage(i, COLOR_GRAY, string);
	}
    if(!success) return SendClientMessage(playerid,-1, "SERVER: Unknown command. Use /cmds to view all available commands.");
    return 1;
}

//settings for the weapons in the briefcase
#define MAX_BRIEF_WEAPONS       12
new gBriefWeap[MAX_BRIEF_WEAPONS]={22,18,23,25,29,31,28,34,27,37,35,36};
new gBriefAmmo[MAX_BRIEF_WEAPONS]={100,2,100,100,300,400,500,100,300,300,2,3};
new gBriefPrice[MAX_BRIEF_WEAPONS]={2000,10000,3000,3000,10000,15000,15000,20000,10000,18000,20000,30000};

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_REGISTER)
    {
	   if(response)
       {
			if(strlen(inputtext) < 3 || strlen(inputtext) > 25) 
            {
				return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD , "Register", "This account is not registered, please register.\n{DECC45}ERROR: Password must be 3-25 characters!", "OK", "Cancel");
            }
            new query[300];
            new escpname[24], escpass[129], buf[129];
            WP_Hash(buf, sizeof(buf), inputtext);
            mysql_real_escape_string(buf, escpass);
            mysql_real_escape_string(gPlayerInfo[playerid][pName], escpname); //escapes the string so you cant MySQL inject
            Query("INSERT INTO `playerinfo` (`user`,`password`,`IP`,`date`, `laston`) VALUES ('%s','%s','%s',%d, %d)",
			escpname,escpass,gPlayerInfo[playerid][pIp],gettime(), gettime()); //insert string
            mysql_query(query); //queries
            //fetch his DBID now
            new field[256];
            Query("SELECT `id` FROM `playerinfo` WHERE `user`='%s' LIMIT 1",escpname);
            mysql_query(query);
            mysql_store_result();
			mysql_fetch_int("id",gPlayerInfo[playerid][pDBID]);
		    mysql_free_result( );
            GameTextForPlayer(playerid,"~g~Registered",2000,3);
            SendClientMessage(playerid,COLOR_GREEN,"Registered and logged into your account!");
			printf("%s(%d) has registered!", gPlayerInfo[playerid][pName], playerid);
            gPlayerInfo[playerid][pLogged]=1;
     		gPlayerInfo[playerid][pReggedAcc]=1;
			SendClientMessage(playerid, -1, "Welcome! Since you have just registered, you have been shown our rules(/rules), please read them carefully.");
			cmd_rules(playerid, ""); 
			for(new i; i < 9; i++) TextDrawHideForPlayer(playerid, ConnectTD[i]);
        }
        else Kick(playerid);
    }
	
	if(dialogid == DIALOG_CHANGEPASS)
    {
	   if(response)
       {
			if(strlen(inputtext) < 3 || strlen(inputtext) > 25)
            {
				return ShowPlayerDialog(playerid, DIALOG_CHANGEPASS, DIALOG_STYLE_PASSWORD , "Change password", "Please enter your desired NEW password.\n{DECC45}ERROR: Password must be 3-25 characters!", "OK", "Cancel");
            }
			new query[256], buf[129];
			WP_Hash(buf, sizeof(buf), inputtext);
			mysql_real_escape_string(buf, buf);
			Query("UPDATE `playerinfo` SET `password`='%s' WHERE `id`='%i'",buf,gPlayerInfo[playerid][pDBID]);
			mysql_query(query);
			SendClientMessage(playerid, COLOR_YELLOW, "You have successfully changed your password. Please remember to never give out your password.");
			printf("[CHANGEPASS] %s(%d) has changed their password.", gPlayerInfo[playerid][pName], playerid);
		}
    }
	
	if(dialogid == DIALOG_LOGIN)
	{
	    if(!response)
	    {
	        SendClientMessage(playerid, -1, "You must login to play!");
		 	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "This account is registered, please login.", "OK", "Cancel");
			SetPVarInt(playerid, "WrongPass", GetPVarInt(playerid, "WrongPass") + 1);
			if(GetPVarInt(playerid, "WrongPass") > 5)
			{
				printf("%s was kicked for escaping the login dialog. (5 wrong password attempts/escapes)", gPlayerInfo[playerid][pName]);
				Kick(playerid);
			}
	    }
		if(response)
		{
			new query[256];
			new escpname[24];
			new buf[129];
			WP_Hash(buf, sizeof(buf), inputtext);
			mysql_real_escape_string(gPlayerInfo[playerid][pName],escpname);
			Query("SELECT * FROM `playerinfo` WHERE `user`='%s' AND `password`='%s'",
			escpname,buf);
			mysql_query(query);
			mysql_store_result();
			if(!mysql_num_rows())
			{
				SetPVarInt(playerid, "WrongPass", GetPVarInt(playerid, "WrongPass") + 1);
				printf("%s(%d) has entered an invalid password!", gPlayerInfo[playerid][pName], playerid);
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD , "Login", "This account is registered, please login.\n{DECC45}ERROR: Incorrect password!", "OK", "Cancel");
				if(GetPVarInt(playerid, "WrongPass") > 5)
				{
					new string[90];
					String("[AUTOKICK] %s has been kicked for 5 failed login attempts.", gPlayerInfo[playerid][pName]);
					print(string);
					SendClientMessageToAll(COLOR_RED, string);
					KickWithMessage(playerid, "Max password tries exceeded. If you have forgotten your password, please open an administrative request at www.sector7gaming.com/forums.");
				}
			}
			else
			{
				new field[256];
				gPlayerInfo[playerid][pLogged]=1;
				GameTextForPlayer(playerid,"~g~Logged in!",2000,3);
				printf("%s(%d) has logged in.", gPlayerInfo[playerid][pName], playerid);
				mysql_fetch_int("id",gPlayerInfo[playerid][pDBID]);
				mysql_fetch_int("kills",gPlayerInfo[playerid][pKills]);
				mysql_fetch_int("deaths",gPlayerInfo[playerid][pDeaths]);
				mysql_fetch_int("level",gPlayerInfo[playerid][pAlevel]);
				mysql_fetch_int("score",gPlayerInfo[playerid][pScore]);
				SetPlayerScoreSync(playerid,gPlayerInfo[playerid][pScore]);
				mysql_fetch_int("money",gPlayerInfo[playerid][pMoney]);
				mysql_fetch_int("operator",gPlayerInfo[playerid][pOp]);
				mysql_fetch_int("donor",gPlayerInfo[playerid][pDonor]);
				gPlayerInfo[playerid][pContime] = gettime();
				Query("UPDATE `playerinfo` SET `online` = '1', `laston` = '%d' WHERE `user` = '%s'", gettime(), gPlayerInfo[playerid][pName]);
				mysql_query(query);
				for(new i; i < 9; i++) TextDrawHideForPlayer(playerid, ConnectTD[i]);
			}
			mysql_free_result( );
	   }
    }
	
	if (dialogid==DIALOG_SHOP)
	{
	    inbriefcase[playerid] = 0;
 		if (!response)
 		{
 			PlayerInfo[playerid][pShopDelay] = 1;
 			defer ShopDelay(playerid);
 			return 1;
 		}
	    if (listitem==0)
     	{
      		if (gPlayerInfo[playerid][pMoney]<10000) return SendClientMessage(playerid,COLOR_ORANGE,"Not enough money to buy this item.");
          	SetPlayerHealth(playerid,99.0);
           	SendClientMessage(playerid,-1,"Health replenished for $10000.");
           	GivePlayerMoneySync(playerid,-10000);
		}
		if (listitem==1)
		{
			if (gPlayerInfo[playerid][pMoney]<15000) return SendClientMessage(playerid,COLOR_ORANGE,"Not enough money to buy this item.");
       		SetPlayerArmour(playerid,99.0);
         	SendClientMessage(playerid,-1,"Kevlar Vest purchased for $15000.");
          	GivePlayerMoneySync(playerid,-15000);
		}
		if (listitem==2)
		{
		    inbriefcase[playerid]=1;
			ShowPlayerDialog(playerid,DIALOG_SHOP2,DIALOG_STYLE_LIST,"Weapon List","9mm - $2000\nMolotov Cocktail - $10000\nSilenced 9mm - $3000\nShotgun - $3000\nMP5 - $10000\nM4A1 - $15000\nUZI -$15000\nSniper Rifle - $20000\nSPAS-12 - $10000\nFlamethrower -$18000 \nRocket Launcher - $20000","Buy","Back");
		}
	}
	if (dialogid==DIALOG_SHOP2)
	{
	    inbriefcase[playerid] = 0;
 		if(!response)
 		{
 		    inbriefcase[playerid] = 1;
   			return ShowPlayerDialog(playerid,DIALOG_SHOP,DIALOG_STYLE_LIST,"Shop","Health - $10000\nKevlar Vest - $15000\nBuy Weapons","Select","Close");
		}
		if (listitem>=MAX_BRIEF_WEAPONS) return 1;
		if(gPlayerInfo[playerid][pMoney]< gBriefPrice[listitem] ) return SendClientMessage(playerid, COLOR_ORANGE, "You don't have enough money to purchase this weapon.");
		GivePlayerWeaponEx(playerid, gBriefWeap[listitem], gBriefAmmo[listitem]);
		GivePlayerMoneySync(playerid, -gBriefPrice[listitem]);
	}

	if(dialogid == DIALOG_CLASSPICK) {
		if(!response)
			return classdialog;
		if(listitem == 0) {
    		gPlayerInfo[playerid][pClass] = CLASS_ASSAULT;
    		SendClientMessage(playerid, -1, "You have chosen 'Assault' as your class.");
    		SendClientMessage(playerid, -1, "With this class, you have no extra features.");
		}
		if(listitem == 1) {
		    if(gPlayerInfo[playerid][pRank]<2) {
		        SendClientMessage(playerid, COLOR_RED, "You need to be rank 1 or above to use this class!");
		        return classdialog;
			}
			gPlayerInfo[playerid][pClass] = CLASS_SNIPER;
			SendClientMessage(playerid, -1, "You have chosen 'Sniper' as your class.");
    		SendClientMessage(playerid, -1, "With this class, you get a sniper rifle on spawn and are invincible on the radar.");
		}
		if(listitem == 2) {
		    if(gPlayerInfo[playerid][pRank]<1) {
		        SendClientMessage(playerid, COLOR_RED, "You need to be rank 1 or above to use this class!");
		        return classdialog;
			}
			gPlayerInfo[playerid][pClass] = CLASS_MEDIC;
			SendClientMessage(playerid, -1, "You have chosen 'Medic' as your class.");
    		SendClientMessage(playerid, -1, "With this class, you can heal your team and get score for it.");
    		SendClientMessage(playerid, -1, "Use /heal [ID]");
		}
		if(listitem == 3) {
		    if(gPlayerInfo[playerid][pRank]<2) {
		    	SendClientMessage(playerid, COLOR_RED, "You need to be rank 2 or above to use this class!");
		    	return classdialog;
			}
			gPlayerInfo[playerid][pClass] = CLASS_SUPPORTER;
			SendClientMessage(playerid, -1, "You have chosen 'Supporter' as your class.");
			SendClientMessage(playerid, -1, "With this class, you can restore the armour of your team mates and get score for it.");
			SendClientMessage(playerid, -1, "Use /armour [ID]"); 
		}
		if(listitem == 4) {
		    if(gPlayerInfo[playerid][pRank]<3) {
		        SendClientMessage(playerid, COLOR_RED, "You need to be rank 3 or above to use this class!");
		        return classdialog;
			}
		    gPlayerInfo[playerid][pClass] = CLASS_ENGINEER;
		    SendClientMessage(playerid, -1, "You have chosen 'Engineer' as your class");
    		SendClientMessage(playerid, -1, "With this class, you can fix your, or your team mates vehicles.");
    		SendClientMessage(playerid, -1, "You have anti-vehicle weapons and you can use Rhinos.");
    		SendClientMessage(playerid, -1, "*Use /fix to fix your own vehicle | use /repair [ID] to repair a team mates vehicle.");
		}
		if(listitem == 5) {
		    if(gPlayerInfo[playerid][pRank]<3) {
		    	SendClientMessage(playerid, COLOR_RED, "You need to be rank 3 or above to use this class!");
		    	return classdialog;
			}
			gPlayerInfo[playerid][pClass] = CLASS_PILOT;
			SendClientMessage(playerid, -1, "You have chosen 'Pilot' as your class.");
			SendClientMessage(playerid, -1, "With this class, you have the potential to fly armed air vehicles.");
		}
		if(listitem == 6) {
		    if(gPlayerInfo[playerid][pRank]<5) {
		    	SendClientMessage(playerid, COLOR_RED, "You need to be rank 5 or above to use this class!");
		    	return classdialog;
			}
			gPlayerInfo[playerid][pClass] = CLASS_JETTROOPER;
			SendClientMessage(playerid, -1, "You have chosen 'Jet Trooper' as your class.");
			SendClientMessage(playerid, -1, "With this class, you can use jetpacks.");
			SendClientMessage(playerid, -1, "Use /jp to spawn a jetpack."); 
		}
		gPlayerInfo[playerid][pChangeClass] = 0;
        SetPVarInt(playerid, "NoAB", 4);
		SpawnPlayer(playerid);
	}
	
	if(dialogid == DIALOG_DUEL) {
		if(!response)
		    return 1;
        SetPVarInt(playerid, "NoAB", 5);
        SetPVarInt(playa, "NoAB", 5);
        ResetPlayerWeaponsEx(playerid);
		ResetPlayerWeaponsEx(DuelInfo[playerid][playa]);
		SetPlayerPos(DuelInfo[playerid][playa], -1400.8800,1225.4309,1039.8672);
		SetPlayerPos(playerid, -1391.1001,1266.2266,1039.8672);
        EndSKDuel(playerid);
        EndSKDuel(DuelInfo[playerid][playa]);
	    GivePlayerWeaponEx(playerid, DuelInfo[playerid][weapon], 9999);
	    GivePlayerWeaponEx(DuelInfo[playerid][playa], DuelInfo[playerid][weapon], 9999);
		SetPlayerInterior(playerid, 16);
		SetPlayerInterior(DuelInfo[playerid][playa], 16);
		SetPlayerVirtualWorld(playerid, playerid+1);
		SetPlayerVirtualWorld(DuelInfo[playerid][playa], playerid+1);
		SetPlayerHealth(DuelInfo[playerid][playa], 99.0);
		SetPlayerArmour(DuelInfo[playerid][playa], 99.0);
		SetPlayerHealth(playerid, 99.0);
		SetPlayerArmour(playerid, 99.0);
		dueling[DuelInfo[playerid][playa]] = 1;
		dueling[playerid] = 1;
		SetPlayerTeam(playerid, NO_TEAM);
		SetPlayerTeam(DuelInfo[playerid][playa], NO_TEAM);
		SetPlayerSkin(playerid, 296);
		SetPlayerSkin(DuelInfo[playerid][playa], 296);
		gPlayerInfo[playerid][pTeam] = playerid + 1;
		gPlayerInfo[DuelInfo[playerid][playa]][pTeam] = DuelInfo[playerid][playa] + 1;
	}
	return 1;
}

stock AdminCommand(playerid,command[], id = -1)
{
	new string[128], year, month, day, hour, minute, second;
	getdate(year, month, day);
	gettime(hour, minute, second);
	if(id == -1)
		String("[ADMIN CMD] %s || Level: %d || Command used: %s",gPlayerInfo[playerid][pName],gPlayerInfo[playerid][pAlevel],command);
	else
	    String("[ADMIN CMD] %s || Level: %d || Command used: %s || Target: %s[%d]",gPlayerInfo[playerid][pName],gPlayerInfo[playerid][pAlevel],command,gPlayerInfo[id][pName],id);
	foreach(Player, i) if( IsPlayerConnected( i ) )
	{
		if(gPlayerInfo[i][pAlevel] >= 1 || Undercover[i] == 1) 
		{
			SendClientMessage(i, COLOR_BLUE, string);
		}
	}
}
stock DonorCommand(playerid,command[])
{
	new string[100];
	String("[DONOR CMD] %s || Level: %d || Command used: %s",gPlayerInfo[playerid][pName],gPlayerInfo[playerid][pDonor],command);
	foreach(Player, i) if( IsPlayerConnected( i ) )
	{
		if(gPlayerInfo[i][pAlevel] >= 1 || Undercover[i] == 1) 
		{
			SendClientMessage(i, COLOR_WHITE, string);
		}
	}
}
CMD:astream(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel]< 4) return accessdenied(playerid);
	{
		if(isnull(params))
			return SendUsage(playerid, "USAGE: /astream [URL]");
		foreach(Player, i)
		{
		    StopAudioStreamForPlayer(i);
			PlayAudioStreamForPlayer(i, params);
		}
		ssstring("Administrator %s has started streaming. Use /stopstream to stop the stream.", gPlayerInfo[playerid][pName]);
		SendClientMessageToAll(-1, ssstring);
	}
	return 1;
}

CMD:streamstopall(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel]< 4) return accessdenied(playerid);
	foreach(Player, i)
	{
	    StopAudioStreamForPlayer(i);
	}
	ssstring("Administrator %s has stopped the audio stream for all everyone.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, ssstring);
	return 1;
}

CMD:stopstream(playerid, params[])
{
	StopAudioStreamForPlayer(playerid);
	return 1;
}

CMD:ahide(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
	if(gPlayerInfo[playerid][adminhide] == 0)
	{
	    gPlayerInfo[playerid][adminhide] = 1;
	    SendClientMessage(playerid, COLOR_GRAY, "You are not seen in the admins list any more.");
	}
	else
	{
		gPlayerInfo[playerid][adminhide] = 0;
		SendClientMessage(playerid, COLOR_GRAY, "You are now seen in the admins list.");
	}
	AdminCommand(playerid, "AHIDE");
	return 1;
}

CMD:reconnect(playerid, params[]) //doesn't work any better than banip/unbanip but has less code
{
    if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
	new target, reason[40], string[80];
	if(sscanf(params, "us[40]", target, reason)) return SendUsage(playerid, "USAGE: /reconnect [ID/name] [reason]");
	if(target == INVALID_PLAYER_ID) return SendClientMessage(playerid, invalidplayer);
	if(strlen(reason) > 40)
		return SendClientMessage(playerid, COLOR_RED, "Reason must be below 40 characters.");
	ssstring("[RECONNECT] %s was forced to reconnect by %s. [reason: %s]", gPlayerInfo[target][pName], gPlayerInfo[playerid][pName], reason);
	SendClientMessageToAll(COLOR_RED, ssstring);
	for (new i=0;i<=20;i++) SendClientMessage(target, -1, " ");
	String("Administrator %s has forced you to reconnect. [reason: %s]", gPlayerInfo[playerid][pName], reason); 
	GameTextForPlayer(target, "~w~please wait...~n~~r~reconnecting to server", 5000, 3);
	SendClientMessage(target, COLOR_RED, string);
	SaveStats(target);
	GetPlayerIp(target, ReconnectPIP[target], 16);
	BlockIpAddress(ReconnectPIP[target], 10000);
	IsReconnecting[target] = true;
	return 1;
}

CMD:time(playerid, params[])
{
	new string[100];
	new y, m, d;
	new h,mi,s;
	getdate(y,m,d);
	gettime(h,mi,s);
	String("Server time: %d/%d/%d - %02d:%02d:%02d",d,m,y,h,mi,s);
	SendClientMessage(playerid, COLOR_CYAN, string);
	return 1;
}

CMD:order(playerid, params[])
{
	if(gPlayerInfo[playerid][pRank]<5)
	    return SendClientMessage(playerid,COLOR_RED,"You need to be Brigadier (rank 5) to use order!");
    if (isnull(params))
		return SendUsage(playerid, "USAGE: /order [your order]");
	new string[128];
	String("[RADIO] %s(%d) ordered: %s, now!",gPlayerInfo[playerid][pName],playerid,params);
	foreach(Player,i)
	{
	    if (gPlayerInfo[playerid][pTeam]!=gPlayerInfo[i][pTeam]) continue;
		SendClientMessage(i,COLOR_DARKLIGHTGREEN,string);
	}
	return true;
}

CMD:heal(playerid, params[])
{
	if(gPlayerInfo[playerid][pClass] == CLASS_MEDIC || gPlayerInfo[playerid][pDonor] > 0) {
		new id;
		if(sscanf(params, "u", id))
		    return SendUsage(playerid, "USAGE: /heal [ID]");
		if(!IsPlayerConnected(id))
		    return SendClientMessage(playerid, invalidplayer);
		if(gPlayerInfo[id][pTeam]!=gPlayerInfo[playerid][pTeam])
	    	return SendClientMessage(playerid, COLOR_RED, "You can't heal enemies.");
		if(id == playerid)
		    return SendClientMessage(playerid, COLOR_RED, "You can't heal yourself.");
		new Float:idhp;
		GetPlayerHealth(id, idhp);
		if(idhp > 80)
		    return SendClientMessage(playerid, COLOR_RED, "This person doesn't need healing!");
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		if(!IsPlayerInRangeOfPoint(id, 7.5, x, y, z))
		    return SendClientMessage(playerid, COLOR_RED, "Player must be in range in order to get healed!");
	    if (!CheckCoolDown(playerid,"UsedHeal",60)) return 1;
		SetPlayerHealth(id, 99.0);
		new string[90];
		GivePlayerScoreSync(playerid,1);
		GivePlayerMoneySync(playerid,800);
		String("*You have healed %s. You got 1 score and $800 for it.",gPlayerInfo[id][pName]);
		SendClientMessage(playerid,-1,string);
		SendClientMessage(playerid, -1, "Healing successful.");
		if(gPlayerInfo[playerid][pClass] == CLASS_MEDIC) String("*Medic %s has healed you.",gPlayerInfo[playerid][pName]);
		else String("*Donor %s has healed you.",gPlayerInfo[playerid][pName]);
		SendClientMessage(id,-1,string);
		if(gPlayerInfo[playerid][pDonor] > 0)
			DonorCommand(playerid, "HEAL");
	}
	else SendClientMessage(playerid, COLOR_RED, "You need to be a medic or donor to use this.");
	return 1;
}

CMD:darmour(playerid, params[])
{
	if(gPlayerInfo[playerid][pDonor]< 2)
	    return SendClientMessage(playerid, donordeny2);
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /darmour [ID]");
	if(!IsPlayerConnected(id))
     return SendClientMessage(playerid, invalidplayer);
	if(gPlayerInfo[id][pTeam]!=gPlayerInfo[playerid][pTeam])
	    return SendClientMessage(playerid, COLOR_RED, "You can't armour enemies");
	if(id == playerid)
	    return SendClientMessage(playerid, COLOR_RED, "You can't armour yourself!");
	new Float:idhp;
	GetPlayerArmour(id, idhp);
	if(idhp > 89)
		return SendClientMessage(playerid, COLOR_RED, "The armour of this player is in a good state!");
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(!IsPlayerInRangeOfPoint(id, 7.5, x, y, z))
	    return SendClientMessage(playerid, COLOR_RED, "Target player is to far away from you, get him in your range!");
	if(!CheckCoolDown(playerid,"UsedHeal",240)) return 1;
	SetPlayerArmour(id, 99.0);
	new string[100];
	GivePlayerScoreSync(playerid, 1);
	GivePlayerMoneySync(playerid, 5000);
	String("*You have restored %s's armour. You got 1 score and $5000 for it!",gPlayerInfo[id][pName]);
	SendClientMessage(playerid,-1,string);
	SendClientMessage(playerid,-1,"Armour restored!");
	String("*Donor %s has restored your armour!",gPlayerInfo[playerid][pName]);
	SendClientMessage(id, -1,string);
	DonorCommand(playerid, "DARMOUR");
	return 1;
}
CMD:darmor(playerid, params[]) { return cmd_darmour(playerid,params); }

CMD:boost(playerid, params[])
{
	if(gPlayerInfo[playerid][pDonor]< 2)
	    return SendClientMessage(playerid, donordeny2);
	if (!CheckCoolDown(playerid,"Usedboost",600)) return 1;
	new wep = GetPlayerWeapon(playerid);
	switch(wep)
	{
 		case 16: GivePlayerWeaponEx(playerid,16,1);
		case 18: GivePlayerWeaponEx(playerid,18,1);
		case 26: GivePlayerWeaponEx(playerid,26,50);
		case 28: GivePlayerWeaponEx(playerid,28,200);
		case 32: GivePlayerWeaponEx(playerid,32,200);
		case 34: GivePlayerWeaponEx(playerid,34,30);
		case 35: GivePlayerWeaponEx(playerid,35,1);
		case 36: GivePlayerWeaponEx(playerid,36,1);
		case 39: GivePlayerWeaponEx(playerid,39,1);
		default: GivePlayerWeaponEx(playerid,wep,100);
	}
	SendClientMessage(playerid, COLOR_LIMEGREEN, "*Boost applied, you have received ammo for all your weapons! (cooldown 10 minutes)");
	DonorCommand(playerid, "BOOST");
	return 1;
}

CMD:armour(playerid, params[])
{
	if(gPlayerInfo[playerid][pClass] != CLASS_SUPPORTER)
	    return SendClientMessage(playerid, COLOR_RED, "You need to be a supporter to use this!");
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /armour [ID]");
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, invalidplayer);
	if(gPlayerInfo[id][pTeam]!=gPlayerInfo[playerid][pTeam])
	    return SendClientMessage(playerid, COLOR_RED, "You can't armour enemies");
	if(id == playerid)
	    return SendClientMessage(playerid, COLOR_RED, "You can't restore your own armour!");
	new Float:idhp;
	GetPlayerArmour(id, idhp);
	if(idhp > 89)
	    return SendClientMessage(playerid, COLOR_RED, "The armour of this player is in a good state!");
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(!IsPlayerInRangeOfPoint(id, 7.5, x, y, z))
	    return SendClientMessage(playerid, COLOR_RED, "Target player is to far away from you, get him in your range!");
    if (!CheckCoolDown(playerid,"UsedHeal",180)) return 1;
	SetPlayerArmour(id, 99.0);
	new string[100];
	GivePlayerScoreSync(playerid,1);
	GivePlayerMoneySync(playerid,5000);
	String("* You have restored %s's armour. You got 1 score and $5000 for it!",gPlayerInfo[id][pName]);
	SendClientMessage(playerid,-1,string);
	SendClientMessage(playerid, -1, "Armour restored!");
	String("* Supporter %s has restored your armour!",gPlayerInfo[playerid][pName]);
	SendClientMessage(id,-1,string);
	return 1;
}
CMD:armor(playerid, params[]) { return cmd_armour(playerid,params); }


CMD:jp(playerid, params[])
{
	if(gPlayerInfo[playerid][pClass] != CLASS_JETTROOPER)
	    return SendClientMessage(playerid, COLOR_RED, "You need to be a Jet Trooper to use this!");
	SetPlayerSpecialAction(playerid, 2);
	return 1;
}

CMD:repair(playerid, params[])
{
	if(gPlayerInfo[playerid][pClass] != CLASS_ENGINEER)
	    return SendClientMessage(playerid, COLOR_RED, "You need to be an engineer to use this command.");
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /repair [ID]");
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, invalidplayer);
	if(gPlayerInfo[id][pTeam]!=gPlayerInfo[playerid][pTeam])
	    return SendClientMessage(playerid, COLOR_RED, "You can't repair the enemies vehicle!");
	if(id == playerid)
	    return SendClientMessage(playerid, COLOR_RED, "Use /fix to repair your own vehicle");
	new Float:vhp;
	GetVehicleHealth(GetPlayerVehicleID(id), vhp);
	if(vhp > 800)
	    return SendClientMessage(playerid, COLOR_RED, "The vehicle is in a good state!");
	new vehid=GetPlayerVehicleID(id);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(!IsPlayerInRangeOfPoint(id, 7.5, x, y, z))
	    return SendClientMessage(playerid, COLOR_RED, "No vehicles in range!");
	if (!CheckCoolDown(playerid,"UsedFix",120)) return 1;
	SetVehHealth(vehid);
	SendClientMessage(playerid, -1, "*Vehicle fixed!");
	RepairVehicle(vehid);
	return 1;
}

CMD:fix(playerid, params[])
{
	if(gPlayerInfo[playerid][pClass] != CLASS_ENGINEER)
	    return SendClientMessage(playerid, COLOR_RED, "You need to be an engineer to use this.");
	new Float:vhp;
	GetVehicleHealth(GetPlayerVehicleID(playerid), vhp);
	if(vhp > 500)
	    return SendClientMessage(playerid, COLOR_RED, "Your vehicle doesn't need to be fixed.");
	new vehid=GetPlayerVehicleID(playerid);
	if (!vehid)
		return SendClientMessage(playerid, COLOR_RED, "You don't have a vehicle.");
    if (!CheckCoolDown(playerid,"UsedFix",120)) return 1;
	SetVehHealth(vehid);
	SendClientMessage(playerid, -1, "*Vehicle fixed!");
	RepairVehicle(vehid);
	return 1;
}

CMD:fps(playerid, params[])
{
	new id;
	if(sscanf(params, "u", id))
	    id=playerid;
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, invalidplayer);
	if(pFPS[id] == 0)
	    return SendClientMessage(playerid, COLOR_RED, "The server was unable to get that player's FPS. Please try again.");
	new string[40];
	String("%s's FPS: %d.",gPlayerInfo[id][pName],pFPS[id]);
	SendClientMessage(playerid,-1,string);
	return 1;
}

CMD:netstats(playerid, params[])
{
	new id;
	if(sscanf(params, "u", id)) 
		id=playerid;
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, invalidplayer);
	new string[90];
	String("%s's network statistics: ping: %dms | packets lost: %.2f%s.",gPlayerInfo[id][pName], GetPlayerPing(id), NetStats_PacketLossPercent(id), "%%");
	SendClientMessage(playerid,-1,string);
	return 1;
}
CMD:netstat(playerid, params[]) { return cmd_netstats(playerid,params); }

CMD:onlinetime(playerid, params[])
{
	new id;
	if(sscanf(params, "u", id)) 
		id=playerid;
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, invalidplayer);
	new string[130], second, minute, hour;
	msToTime(NetStats_GetConnectedTime(id), second, minute, hour);
	String("%s has been connected for {F7F7F7}%i {099EA6}hours {F7F7F7}%i {099EA6}minutes {F7F7F7}%i {099EA6}seconds.",gPlayerInfo[id][pName],hour,minute,second);
	SendClientMessage(playerid, COLOR_TEAL, string);
	return 1;
}
CMD:connectedtime(playerid, params[]) { return cmd_onlinetime(playerid,params); }

stock msToTime(millisecond, &second, &minute, &hour)
{
    while(millisecond > 1000)
    {
        millisecond = millisecond-1000;
        second++;
    }
    while(second > 59)
    {
        second = second-60;
        minute++;
    }
    while(minute > 59)
    {
        minute = minute-60;
        hour++;
    }
}

CMD:duel(playerid, params[])
{
	new id, wep[30];
	if(sscanf(params, "us[30]", id, wep))
	    return SendUsage(playerid, "USAGE: /duel [ID] [weapon]");
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, invalidplayer);
	else if(GetPVarInt(playerid, "AdminDuty") == 1)
		return SendClientMessage(playerid, COLOR_RED, "You must go off duty to duel!");
	else if(GetPVarInt(id, "AdminDuty") == 1)
		return SendClientMessage(playerid, COLOR_RED, "Player is on admin duty.");
	else if (gPlayerInfo[playerid][pSpawned] == 0)
	    return SendClientMessage(playerid, COLOR_RED, "You must be spawned to duel!");
    else if (gPlayerInfo[id][pSpawned] == 0)
	    return SendClientMessage(playerid, COLOR_RED, "Player is not yet spawned.");
	else if(GetPVarInt(id, "DND") == 1)
	    return SendClientMessage(playerid, COLOR_RED, "Player is in DND mode.");
    else if(Blocked[playerid] == 1)
	  	return SendClientMessage(playerid, COLOR_RED, "This user has blocked you, therefore you cannot duel him.");
	else if(playerid == id)
	    return SendClientMessage(playerid, COLOR_RED, "You cannot duel yourself!");
	else if(dueling[id] == 1)
	    return SendClientMessage(playerid, COLOR_RED, "Player is already dueling!");
	new wepid = GetWeaponIDFromName(wep);
	if(wepid < 1 || wepid > 38) return SendClientMessage(playerid, invalidweapon);
	DuelInfo[id][playa] = playerid;
	DuelInfo[id][weapon] = wepid;
	new string[90];
	String("%s has requested to duel %s. Weapon: %s.",gPlayerInfo[playerid][pName],gPlayerInfo[id][pName],wep);
	SendClientMessage(playerid,-1,string);
	SendClientMessage(id,-1,string);
	ShowPlayerDialog(id,DIALOG_DUEL,DIALOG_STYLE_MSGBOX,"Duel",string,"Accept","Ignore");
	return 1;
}

CMD:hackers(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel] < 1)
		return accessdenied(playerid);
	SendClientMessage(playerid, -1, "Possible online hackers(detected with s0beit):");
	new string[31];
	foreach(Player,i)
	{
	    if (!gPlayerInfo[i][pHacker]) continue;
        String("[%d]%s",i,gPlayerInfo[i][pName]);
        SendClientMessage(playerid,-1, string);
	}
	return 1;
}

CMD:update(playerid, params[])
{
	UpdateRank(playerid);
	UpdateScoreDisplay(playerid);
	SendClientMessage(playerid,COLOR_LIMEGREEN,"Rank & score successfully updated!");
	return 1;
}

CMD:acmds(playerid, params[]) 
{
    if(gPlayerInfo[playerid][pAlevel] >=1)
    {
		SendClientMessage(playerid, -1, "Administrator commands:");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 1: /warn, /kick, /clearchat (/cc), /pausers, /reconnect");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 1: /apm, /jetpack, /getinfo, /get, /goto, /eget, /nos");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 1: /slap, /hslap, /asay, /write, /setinterior , /setworld, /ahide");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 1: /forcehvrules, /flip, /tune, /carcolor, /adminarea, /adminduty");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 1: /hackers, /weaps, /fixteams, /searchban, /afix, /acar");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 1: /freeze, /unfreeze, /sv, /disarm, /spawn, /asite, /afly");
	}
	if(gPlayerInfo[playerid][pAlevel] >=2)
	{
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 2: /ban, /tban, /v, /setskin, /(un)jail, /(un)mute, /syncmoney");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 2: /explode, /vgoto, /force, /rangecheck, /gotopos");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 2: /vh, /burn, /eject");
	}
	if(gPlayerInfo[playerid][pAlevel] >=3)
	{
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 3: /sethealth, /setarmour /announce(/ann), /screen, /carhealth(/vh)");
	    SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 3: /giveweapon, /giveallmoney /spawnucars, /akill, /setmoney, /agivemoney");
	}
	if(gPlayerInfo[playerid][pAlevel] >=4)
	{
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /astream, /streamstopall, /giveallscore, /sban, /healall, /armourall");
	    SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /setscore, /givescore, /crash, /killall, /setweather, /settime, /(un)freezeall");
	    SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /ejectall, /spawnall, /(un)muteall, /joinenabled, /joindisabled, /joinget");
	    SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /spawnjoined, /freezeteam, /getteam, /spawnteam, /giveteamscore, /healteam");
	    SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /giveteamweapon, /destroyallcars, /clanwar, /(un)wonttele");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /giveallweapon, /respawnallcars, /setping, /togglest, /togglevehlimit");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /armourteam, /giveteammoney, /unfreezejoin, /slapall");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /areagiveweapon, /areaheal, /areaarmour, /areafreeze, /areaunfreeze, /areadisarm");
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 4: /givefreenamechange, /resetnamechange, /hackcheck");
	}
	if(gPlayerInfo[playerid][pAlevel] >=5)
	{
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 5: /saveallstats, /setadmin, /settemplevel, /setoperator");
	    SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 5: /setdeaths, /setkills, /setdonor, /getall, /togvehlimit");
	    SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 5: /fakechat, /fakekill, /setstreak, /setallskin, /restartmsg, /disableantiab");
	}
	if(gPlayerInfo[playerid][pAlevel] >=6)
	{
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Level 6: /sspec, /ssay, /lockserver, /unlockserver, /stopserver, /kickall, /cmdlogs, /setmotd");
	}
 	if(gPlayerInfo[playerid][pAlevel]< 1) return accessdenied(playerid);
	return 1;
}

CMD:ahelp(playerid, params[])
{
	if(gPlayerInfo[ playerid ][ pAlevel ] < 1) return accessdenied(playerid);
	SendClientMessage(playerid, -1, "Administrator help:");
	SendClientMessage(playerid, COLOR_LIGHTGRAY, "Use /acmds to view the administrator commands (only shows up to your level).");
 	SendClientMessage(playerid, COLOR_LIGHTGRAY, "Use /a [text] to talk in the admin chat.");
	return 1;
}
CMD:ah(playerid, params[]) return cmd_ahelp(playerid,params);
CMD:adminhelp(playerid, params[]) return cmd_ahelp(playerid,params);

CMD:saveallstats(playerid, params[])
{
    if (gPlayerInfo[playerid][pAlevel]< 5)
		return accessdenied(playerid);
	foreach(Player,i) SaveStats(i);
	new string[90];
	String("Administrator %s has saved the stats of all players.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, string);
	return 1;
}
CMD:saveall(playerid, params[]) return cmd_saveallstats(playerid,params);

CMD:afly(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 1)
		return accessdenied(playerid);
	if(GetPVarInt(playerid,"AdminDuty") == 0) return SendClientMessage(playerid, COLOR_ORANGE, "You need to be on duty to use this.");
	if(GetPVarInt(playerid, "aFly") == 1)
	{
		DeletePVar(playerid, "aFly");
		return SendClientMessage(playerid, COLOR_LIMEGREEN, "Admin fly disabled.");
	}
	else
	{
		SetPVarInt(playerid, "aFly", 1);
		AdminCommand(playerid, "AFLY");
		RemovePlayerWeapon(playerid, WEAPON_PARACHUTE);
		return SendClientMessage(playerid, COLOR_LIMEGREEN, "Admin fly enabled.");
	}
}

CMD:cmdlogs(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 6)
		return accessdenied(playerid);
	new string[90];
	if(GetPVarInt(playerid, "cmdLogs") == 1)
	{
		DeletePVar(playerid, "cmdLogs");
		String("[ADMIN(6+)] %s has disabled command logs for their self.",gPlayerInfo[playerid][pName]);
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Command logs disabled.");
	}
	else
	{
		SetPVarInt(playerid, "cmdLogs", 1);
		String("[ADMIN(6+)] %s has enabled command logs for their self.",gPlayerInfo[playerid][pName]);
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Command logs enabled.");
	}
	foreach(Player, i) 
	if (gPlayerInfo[i][pAlevel] >= 6 && i!=playerid)		
		SendClientMessage(i, COLOR_GRAY, string);
	print(string);
	return 1;
}

stock RemovePlayerWeapon(playerid, pweaponid)
{
	new plyWeapons[12];
	new plyAmmo[12];
	for(new slot = 0; slot != 12; slot++)
	{
		new pwep, pammo;
		GetPlayerWeaponData(playerid, slot, pwep, pammo);
		if(pwep != pweaponid)
		{
			GetPlayerWeaponData(playerid, slot, plyWeapons[slot], plyAmmo[slot]);
		}
	}
	ResetPlayerWeapons(playerid);
	for(new slot = 0; slot != 12; slot++)
	{
		GivePlayerWeaponEx(playerid, plyWeapons[slot], plyAmmo[slot]);
	}
}

CMD:mark(playerid, params[])
{
	if (gPlayerInfo[playerid][pRank]<1)
	    return SendClientMessage(playerid, COLOR_RED, "You need to be private to mark yourself!");
	new string[128];
	String("[RADIO] %s[%d] has marked his location! A white marker has been set on the radar!",gPlayerInfo[playerid][pName],playerid);
	foreach(Player,i)
	{
	    if(gPlayerInfo[i][pTeam]!=gPlayerInfo[playerid][pTeam]) continue;
	    SendClientMessage(i,COLOR_DARKLIGHTGREEN,string);
	    SetPlayerMarkerForPlayer(i,playerid,COLOR_WHITE);
	}
	return 1;
}
CMD:mk(playerid, params[]) return cmd_mark(playerid,params);

CMD:backup(playerid, params[])
{
	if (gPlayerInfo[playerid][pRank]<2)
	    return SendClientMessage(playerid,COLOR_RED,"You need to be rank Corporal(rank 2) to request backup!");
	new string[128];
	String("[RADIO] %s[%d] has requested backup! A green marker has been set!",gPlayerInfo[playerid][pName], playerid);
	foreach(Player,i)
	{
	    if (gPlayerInfo[i][pTeam]!=gPlayerInfo[playerid][pTeam]) continue;
  		SendClientMessage(i,COLOR_DARKLIGHTGREEN,string);
	 	SetPlayerMarkerForPlayer(i,playerid,COLOR_PURPLE);
	}
	return 1;
}
CMD:bk(playerid, params[]) return cmd_backup(playerid,params);

CMD:vgoto(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
	new vid, Float:vx, Float:vy, Float:vz, vw;
	if(sscanf(params,"i", vid)) return SendUsage(playerid, "USAGE: /vgoto [vehicle ID]");
	GetVehiclePos(vid, vx, vy, vz);
	vw = GetVehicleVirtualWorld(vid);
	SetPVarInt(playerid, "NoAB", 4);
	SetPlayerPos(playerid, vx, vy, vz);
	SetPlayerVirtualWorld(playerid, vw);
	AdminCommand(playerid, "VGOTO");
	return 1;
}

CMD:airstrike(playerid, params[])
{
    if (gPlayerInfo[playerid][pRank]< 4)
        return SendClientMessage(playerid, COLOR_RED, "You need to be rank 4 to request a air strike!");
    if (gPlayerInfo[playerid][pMoney]<50000)
        return SendClientMessage(playerid, COLOR_RED, "You need $50000 to request a air strike!");
   	new Float:idhp;
	GetPlayerHealth(playerid,idhp);
	if(idhp < 20)
	    return SendClientMessage(playerid, COLOR_RED, "You can't call in an air strike with less than 20hp!");
	if (!CheckCoolDown(playerid,"UsedAStrike",180)) return 1;
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	SetTimerEx("strike", 7000, false, "ifff", playerid,X,Y,Z);
	SendClientMessage(playerid, COLOR_LIMEGREEN, "Air strike on your position in 7 seconds!");
	GivePlayerMoneySync(playerid,-50000);
	new string[128];
	format(string, sizeof string, "[RADAR WARNING] %s called in for a air strike! Take cover!", gPlayerInfo[playerid][pName]);
	SendMessageInArea(20.0, string, X, Y, Z, COLOR_RED);
	return 1;
}

CMD:switchteam(playerid, params[])
{
	if(Jailed[playerid] == 1) return SendClientMessage(playerid, COLOR_ORANGE, "You can't switch teams when you're jailed.");
	if(gSwitchteam ==1)
	    return SendClientMessage(playerid, COLOR_RED, "You can't switch teams, an event is running!");
   	gPlayerInfo[playerid][pChangeClass] = 1;
    ForceClassSelection(playerid);
	SetPlayerHealth(playerid, 0.00);
	return 1;
}
CMD:st(playerid, params[]) return cmd_switchteam(playerid,params);

CMD:switchclass(playerid, params[])
{
	if(gPlayerInfo[playerid][pTeam]==TEAM_ALQAEDA) 
		return SendClientMessage(playerid, COLOR_GRAY, "Team Al-Qaeda does not have classes!");
	SendClientMessage(playerid, -1, "Switching class after next death...");
	gPlayerInfo[playerid][pChangeClass] = 1;
	return 1;
}
CMD:sc(playerid, params[]) return cmd_switchclass(playerid,params);

CMD:clearanims(playerid, params[])
{
	SendClientMessage(playerid, -1, "Animations cleared. Please remember to not abuse this command, doing so will result in a ban.");
	ClearAnimations(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	return 1;
}
CMD:clearanim(playerid, params[]) return cmd_clearanims(playerid, params);
CMD:stopanim(playerid, params[]) return cmd_clearanims(playerid, params);

CMD:help(playerid, params[])
{
	SendClientMessage(playerid, COLOR_TEAL, "[HELP] The goal is to kill enemies, capture zones, and to support your team.");
	return SendClientMessage(playerid, COLOR_TEAL, "[HELP] View /rules for the server rules | View /cmds for a list of server commands."), 1;
}

CMD:goal(playerid, params[])
{
	return SendClientMessage(playerid, COLOR_TEAL, "The goal is to kill enemies, capture zones, to support your team, and to have a good time!"), 1;
}
	
CMD:ranks(playerid, params[])
{
	SendClientMessage(playerid, COLOR_TEAL,"[RANK] 0 Rookie:    0 Score");
	SendClientMessage(playerid, COLOR_TEAL,"[RANK] 1 Private:   150 Score");
	SendClientMessage(playerid, COLOR_TEAL,"[RANK] 2 Corporal:  300 Score");
	SendClientMessage(playerid, COLOR_TEAL,"[RANK] 3 Sergeant:  750 Score");
	SendClientMessage(playerid, COLOR_TEAL,"[RANK] 4 Captain:   2000 Score");
	SendClientMessage(playerid, COLOR_TEAL,"[RANK] 5 Brigadier: 4500 Score");
	return SendClientMessage(playerid, COLOR_TEAL,"[RANK] 6 General:   10000 Score"), 1;
}

CMD:rank(playerid, params[])
{
	UpdateRank(playerid);
    new string[90];
	format(string, 128, "You're rank %d - %s with %d score. BONUS: %.0f HP | %.0f armor",
	gPlayerInfo[playerid][pRank],gRankName[gPlayerInfo[playerid][pRank]],gPlayerInfo[playerid][pScore],gRankHealth[gPlayerInfo[playerid][pRank]]+1, gRankArmor[gPlayerInfo[playerid][pRank]]+1);
	return SendClientMessage(playerid,COLOR_TEAL,string),1;
}

CMD:commands(playerid, params[])
{
	SendClientMessage(playerid, COLOR_PINKRED, "Server/account commands: {FFFFFF}/help, /rules, /hvrules, /update, /report, /helpme, /credits, /stats");
	SendClientMessage(playerid, COLOR_PINKRED, "Server/account commands: {FFFFFF}/motd, /changename, /changepassword, /savestats");
	SendClientMessage(playerid, COLOR_PINKRED, "Player/communication commands: {FFFFFF}/admins, /donors, /getid(/id), /teams, /r, /pm, /rpm, /local, /duel");
	SendClientMessage(playerid, COLOR_PINKRED, "Player/communication commands: {FFFFFF}/block, /unblock, /dnd, /kill, /rank, /ranks, /givemoney(/gm)");
	SendClientMessage(playerid, COLOR_PINKRED, "General commands: {FFFFFF}/anims, /stopanim, /stopstream, /sync, /spree, /ep");
	SendClientMessage(playerid, COLOR_PINKRED, "General commands: {FFFFFF}/airstrike, /fps, /netstats, /onlinetime"); 
    SendClientMessage(playerid, COLOR_PINKRED, "Class/team commands: {FFFFFF}/switchteam(/st), /switchclass(/sc), /fix, /heal, /repair, /heal, /armour, /jp");
	SendClientMessage(playerid, COLOR_PINKRED, "Class/team commands: {FFFFFF}/backup(/bk), /order, /mark(/mk)");
	return 1;
}
CMD:cmds(playerid, params[]) return cmd_commands(playerid, params);

CMD:helpme(playerid, params[])
{
	new help[128];
	if(sscanf(params, "s[128]", help)) SendUsage(playerid, "USAGE: /helpme [question]");
	else
	{
		new string[128];
		format(string, 128, "Help request from %s(%d): %s", gPlayerInfo[playerid][pName], playerid, help);
		foreach(Player, i)
		{
			if(gPlayerInfo[playerid][pAlevel] > 0 || gPlayerInfo[playerid][pOp] > 0)
			SendClientMessage(i, COLOR_BLUE, string);
		}
		SendClientMessage(playerid, COLOR_BLUE, "Your help request has been sent to all online staff!");
	}
	return 1;
}

CMD:rules(playerid, params[])
{
	new dialog[1050];
	strcat(dialog,"{FFFFFF}In order to provide a quality gaming environment, there must be rules that have to be followed.\n\
	While we do not list every rule, we expect players to exercise common sense.\n\n");
	strcat(dialog,"{FFFFFF}1) {E0E0E0}Show common courtesy for everyone on the server - do not provoke or insult anyone.\n\n");
	strcat(dialog,"{FFFFFF}2) {E0E0E0}Hacking, cheating, or bug abusing to gain advantage to other players is prohibited.\n\
	-If you find a server bug, report it on our forums (sector7gaming.com/forums).\n\n");
	strcat(dialog,"{FFFFFF}3) {E0E0E0}Do not park your car on players or repeatedly ram them.\n\n");
	strcat(dialog,"{FFFFFF}4) {E0E0E0}Do not spam commands, flood the chat box, advertise, etc.\n\n");
	strcat(dialog,"{FFFFFF}5) {E0E0E0}Do not spawn kill/base rape.\n\
	-Do not wait at a player spawn point for players to spawn and repeatedly kill them.\n\
	-Do not attack enemy bases with heavy vehicles! Read more in /hvrules.");
	strcat(dialog,"\n\n{FFFFFF}Read our full list of rules on our forums: www.sector7gaming.com/forums.\
	\n\n{DE0000}Failure to abide by our rules will result in administrative punishments.");
	ShowPlayerDialog(playerid, DIALOG_RULES, DIALOG_STYLE_MSGBOX, "{5E8ECC}Sector 7 Gaming Desert Warfare rules", dialog, "Close", "");
	return 1;
}

CMD:credits(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_CREDITS, DIALOG_STYLE_MSGBOX, "Credits", "\
	Original development:\n\
	{AABDBF}Ryan(rymax99@hotmail.com), Mean, Wolf\
	\n \nA special thanks to SA-MP(sa-mp.com) for developing and maintaing SA-MP.", "Close", "");
	return 1;
}

CMD:r(playerid, params[])
{
	if (isnull(params))
 	   return SendUsage(playerid, "USAGE: /r [text]");
    if(Muted[playerid])
	    return SendClientMessage(playerid, muted);
	new string[128];
	ssstring("[R]%s(%d): %s",gPlayerInfo[playerid][pName],playerid, params);
	SendMessageToAdminsOnD(COLOR_GRAY, ssstring);
	String("[RADIO] %s(%d): %s",gPlayerInfo[playerid][pName],playerid,params);
	foreach(Player,i)
	{
	    if (gPlayerInfo[i][pTeam]!=gPlayerInfo[playerid][pTeam]) continue;
		SendClientMessage(i,COLOR_TAN,string);
	}
	return 1;
}

stock SendMessageToAdmins(color, const msg[])
{
	for( new i=0; i<MAX_PLAYERS;i++)
	{
	    if(IsPlayerConnected(i) && gPlayerInfo[i][pLogged] == 1 && gPlayerInfo[i][pAlevel]>=1) SendClientMessage(i,color,msg);
	}
}

stock SendMessageToAdminsOnD(color,const msg[])
{
   for (new i=0; i<MAX_PLAYERS; i++)
   {
      if (IsPlayerConnected(i) && GetPVarInt(i, "AdminDuty") && gPlayerInfo[i][pLogged] == 1) SendClientMessage(i,color,msg);
   }
}

CMD:block(playerid, params[])
{
	new blockedid;
	if(sscanf(params, "u", blockedid)) return SendUsage(playerid, "USAGE: /block [ID]");
	if(Blocked[ blockedid ] == 1) return SendClientMessage(playerid, COLOR_GRAY, "This player is already in your block list.");
	if(playerid == blockedid) return SendClientMessage(playerid, COLOR_GRAY, "You can't block yourself.");
	if(!IsPlayerConnected(blockedid)) return SendClientMessage(playerid, invalidplayer);
	Blocked[ blockedid ] = 1;
	ssstring("You've blocked %s[%d]. He will not be able to private message(PM) you, or send you duel requests.", gPlayerInfo[ blockedid ][pName], blockedid);
	SendClientMessage(playerid, COLOR_GRAY, ssstring);
	return 1;
}

CMD:unblock(playerid, params[])
{
	new blockedid;
	if( sscanf( params, "u", blockedid)) return SendUsage(playerid, "USAGE: /unblock [ID]");
	if(Blocked[ blockedid ] == 0) return SendClientMessage(playerid, COLOR_GRAY, "This user is not in your blocked list.");
	if(!IsPlayerConnected(blockedid)) return SendClientMessage(playerid, invalidplayer);
	Blocked[ blockedid ] = 0;
	ssstring("You've unblocked %s[%d]. He will now be able to private message(PM) you, and send you duel requests.", gPlayerInfo[ blockedid ][pName], blockedid);
	SendClientMessage(playerid, COLOR_GRAY, ssstring);
	return 1;
}

timer killtimer[4000](playerid)
{
	SetPlayerHealth(playerid, 0.0);
}
	
CMD:kill(playerid, params[])
{
	if(Jailed[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "You are jailed, you can't kill yourself.");
	if(GetPlayerState(playerid)!=PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, COLOR_RED, "You must be on foot to kill yourself!");
	if (!CheckCoolDown(playerid,"UsedKill",60)) return 1;
	SendClientMessage(playerid, -1, "You will be killed momentarily...");
	defer killtimer(playerid);
	return 1;
}

/*CMD:irbeundercover!(playerid, params[])
{
	if(gPlayerInfo[playerid][pLogged] == 1)
	{
	    if(!strlen(params)) return SendUsage(playerid, "USAGE: /1izunderc0ver [password]");
	    new File:file = fopen("undercoverpass.txt",io_read), string[80];
		fread(file, string);
		fclose(file);
		if(strcmp(params, string, true) == 0)
		{
	    	Undercover[playerid] = 1;
	    	SendClientMessage(playerid, COLOR_ORANGE, "Welcome undercover admin.");
		}
	}
	return 1;
}*/

CMD:setadmin(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
	{
		if (gPlayerInfo[playerid][pAlevel]< 5)
			return accessdenied(playerid);
	}
	new id,level;
	if (sscanf(params,"ud",id,level))
		return SendUsage(playerid, "USAGE: /setadmin [ID] [level]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if(!IsPlayerAdmin(playerid))
	{
		if (level>SERVER_MAX_ADMIN_LEVEL || level<SERVER_MIN_ADMIN_LEVEL)
			return SendClientMessage(playerid,COLOR_ORANGE,"Admin level must be between 1 and 6.");
		if(level > (gPlayerInfo[playerid][pAlevel]))
			return SendClientMessage(playerid, COLOR_ORANGE, "You can't give someone a higher admin level than your admin level.");
		if (gPlayerInfo[id][pAlevel] > gPlayerInfo[playerid][pAlevel])
			return SendClientMessage(playerid, COLOR_ORANGE, "You can't edit the level of a higher level administrator.");
		if (gPlayerInfo[id][pAlevel] == level)
			return SendClientMessage(playerid, COLOR_ORANGE, "They already have that level!");
	}
	if(level > gPlayerInfo[id][pAlevel])
	{
		GameTextForPlayer(id, "~g~Promoted", 3000, 4);
		PlayerPlaySound(id,1057,0.0,0.0,0.0);
	}
	else
		GameTextForPlayer(id, "~r~Demoted", 3000, 4);
	gPlayerInfo[id][pAlevel]=level;
	new string[115];
	String("Administrator %s has set your level to %d.",gPlayerInfo[playerid][pName],level);
	SendClientMessage(id,COLOR_YELLOW,string);
	if(level == 0)
	{
		if(GetPVarInt(id, "AdminDuty") == 1) {
			SendClientMessage(playerid, COLOR_RED, "You were fired from your administrator position while being on duty, you have been forced off duty and killed.");
			SetPVarInt(id, "AdminDuty", 0);
			SetPlayerHealth(id, 0);
		}
		SendClientMessage(id, COLOR_RED, "You have been removed from your administrator position.");
	}
	if(level > 0)
	    SendClientMessage(id, COLOR_YELLOW, "Use /ahelp to view the administrator help. Use /acmds to view your available commands.");
	String("You have set %s's level to %d! ",gPlayerInfo[id][pName],level);
	SendClientMessage(playerid,COLOR_YELLOW,string);
	AdminCommand(playerid,"SETADMIN",id);
	SendClientMessage(playerid, COLOR_RED, "Be sure to adjust the users administrative level on the forums/TeamSpeak accordingly!");
	return 1;
}

CMD:setkills(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 5)
		return accessdenied(playerid);
	new id,kills2;
	if (sscanf(params,"ud",id,kills2))
		return SendUsage(playerid, "USAGE: /setkills [ID] [kills]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (kills2<0)
		return SendClientMessage(playerid,COLOR_ORANGE,"Kills cannot be negative!");
	gPlayerInfo[id][pKills]=kills2;
	new string[70];
	String("Administrator %s has set your kills to %d!",gPlayerInfo[playerid][pName],kills2);
	SendClientMessage(id,COLOR_YELLOW,string);
	String("You have set %s's kills to %d!",gPlayerInfo[id][pName],kills2);
	SendClientMessage(playerid,COLOR_YELLOW,string);
	UpdateScoreDisplay(id);
	AdminCommand(playerid,"SETKILLS",id);
	return 1;
}

CMD:setdeaths(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 5)
		return accessdenied(playerid);
	new id,kills2;
	if (sscanf(params,"ud",id,kills2))
		return SendUsage(playerid, "USAGE: /setdeaths [ID] [deaths]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (kills2<0)
		return SendClientMessage(playerid,COLOR_ORANGE,"Deaths cannot be negative!");
	gPlayerInfo[id][pDeaths]=kills2;
	new string[80];
	String("Administrator %s has set your deaths to %d!",gPlayerInfo[playerid][pName],kills2);
	SendClientMessage(id,COLOR_YELLOW,string);
	String("You have set %s's deaths to %d!",gPlayerInfo[id][pName],kills2);
	SendClientMessage(playerid,COLOR_YELLOW,string);
	UpdateScoreDisplay(id);
	AdminCommand(playerid,"SETDEATHS",id);
	return 1;
}

CMD:setoperator(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 5)
		return accessdenied(playerid);
	new id;
	if (sscanf(params,"u",id))
	    return SendUsage(playerid, "USAGE: /setoperator [ID]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (!gPlayerInfo[id][pLogged])
	    return SendClientMessage(playerid,COLOR_GRAY,"Player needs to be logged in.");
	if (gPlayerInfo[id][pOp])
	{
	    new string[95];
		String("Administrator %s has fired you as operator.",gPlayerInfo[playerid][pName]);
		SendClientMessage(id,COLOR_YELLOW,string);
		String("You have fired %s as operator.",gPlayerInfo[id][pName]);
		SendClientMessage(playerid,COLOR_YELLOW,string);
		gPlayerInfo[id][pOp]=0;
		AdminCommand(playerid, "UNSETOPERATOR", id);
	}
	else
	{
		new string[128];
		String("Administrator %s has promoted you to operator. Use /ohelp to view your available commands.",gPlayerInfo[playerid][pName]);
		SendClientMessage(id,COLOR_YELLOW,string);
		String("You have promoted %s to operator.",gPlayerInfo[id][pName]);
		SendClientMessage(playerid,COLOR_YELLOW,string);
		gPlayerInfo[id][pOp]=1;
		AdminCommand(playerid, "SETOPERATOR", id);
	}
	SendClientMessage(playerid, COLOR_RED, "Be sure to adjust the users administrative level on the forums/TeamSpeak accordingly!");
	return 1;
}

CMD:kick(playerid, params[])
{
	if (!gPlayerInfo[playerid][pAlevel] && !gPlayerInfo[playerid][pOp])
	    return accessdenied(playerid);
	new id,reason[128];
	if (sscanf(params,"us[128]",id,reason))
		return SendUsage(playerid, "USAGE: /kick [ID] [reason]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (strlen(reason) > 40) 
		return SendClientMessage(playerid, COLOR_RED, "Reason must be below 40 characters.");
	if (gPlayerInfo[playerid][pAlevel]< 6 && gPlayerInfo[id][pAlevel] > 0)
	    return SendClientMessage(playerid, COLOR_RED, "You cannot kick an administrator.");
	new string[128];
	if (!gPlayerInfo[playerid][pOp])
		String("[KICK] Administrator %s has kicked %s. [reason: %s]",gPlayerInfo[playerid][pName],gPlayerInfo[id][pName],reason);
	else
		String("Operator %s has kicked %s. [reason: %s]",gPlayerInfo[playerid][pName],gPlayerInfo[id][pName],reason);
	SendClientMessageToAll(COLOR_RED,string);
    KickWithMessage(id, "You have been kicked.");
	return 1;
}

CMD:warn(playerid, params[])
{
	if (!gPlayerInfo[playerid][pAlevel] && !gPlayerInfo[playerid][pOp])
	    return accessdenied(playerid);
    new id,reason[128];
	if( sscanf( params, "us[128]", id, reason ) )
		return SendUsage(playerid, "USAGE: /warn [ID] [reason]");
	if(strlen(reason) > 40)
		return SendClientMessage(playerid, COLOR_RED, "Reason must be below 40 characters.");
    if (gPlayerInfo[playerid][pAlevel]< 6 && gPlayerInfo[id][pAlevel] > 0)
	    return SendClientMessage(playerid, COLOR_RED, "You cannot warn an administrator.");
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, invalidplayer);
	if( GetPVarInt(id, "Warned" ) == 1)
	    return SendClientMessage( playerid, COLOR_ORANGE, "This player was just warned.");
    new string[128];
	SetPVarInt(id, "Warns", GetPVarInt(id, "Warns") + 1);
	SetPVarInt(id, "Warned", 1);
	SetTimerEx("warncool", 5000, 0, "i", id);
	String("~w~Warned ~w~for: ~r~%s",reason);
	GameTextForPlayer(id,string,7500,6);
	PlayerPlaySound(id,3200,0.0,0.0,0.0);
	if(GetPVarInt(id, "Warns" ) == 3)
	{
	    String("[WARNKICK] Administrator %s has kicked %s. (3/3 warnings) [reason: %s]", gPlayerInfo[playerid][pName],gPlayerInfo[id][pName],reason);
	    SendClientMessageToAll(COLOR_YELLOW, string);
        defer KickPublic(id);
        return 1;
	}
	String("[WARN] Administrator %s has warned %s. [reason: %s] (%d/3)", gPlayerInfo[playerid][pName],gPlayerInfo[id][pName], reason, GetPVarInt(id, "Warns"));
	SendClientMessageToAll(COLOR_YELLOW, string);
	return 1;
}

stock AutoWarn(playerid,const reason[])
{
    new string[128];
	SetPVarInt(playerid, "Warns", GetPVarInt(playerid, "Warns") + 1);
	SetPVarInt(playerid, "Warned", 1);
	SetTimerEx("warncool", 5000, 0, "i", playerid);
	String("~w~Warned ~w~for: ~r~%s",reason);
	GameTextForPlayer(playerid,string,7500,6);
	PlayerPlaySound(playerid,3200,0.0,0.0,0.0);
	if(GetPVarInt(playerid, "Warns") == 3)
	{
	    String("[AUTOWARNKICK] %s has kicked for %s. (3/3 warnings)",gPlayerInfo[playerid][pName],reason);
	    SendClientMessageToAll(COLOR_YELLOW, string);
		print(string);
        defer KickPublic(playerid);
        return 1;
	}
	String("[AUTOWARN] %s has been warned for %s. (%d/3)",gPlayerInfo[playerid][pName],reason,GetPVarInt(playerid, "Warns"));
	SendClientMessageToAll(COLOR_YELLOW, string);
	print(string);
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	if(componentid == 1086 && GetPlayerInterior(playerid) == 0) //crash attempts
	{
	    new string[80];
	    String("[AUTOBAN] %s has been banned for invalid car modding(crash attempt).",gPlayerInfo[playerid][pName]);
		SendClientMessageToAll(COLOR_YELLOW, string);
       	new query[256];
		new year, month, day;
		getdate(year, month, day);
		new hour, minute, second;
		gettime(hour, minute, second);
		new timestring[20];
		format(timestring,sizeof timestring,"%i-%i-%i %i:%i:%i",year,month,day,hour,minute,second);
		Query("INSERT INTO bans (nick,time,reason,bannedby,IP) VALUES ('%s','%s','crash attempt','%s','%s')",
		gPlayerInfo[playerid][pName],timestring,BOT_NAME,gPlayerInfo[playerid][pIp]);
		mysql_query(query);
		KickWithMessage(playerid, "You've been banned for invalid car modding(crash attempt). If you think this is a mistake, appeal at www.sector7gaming.com.");
	}
	return 1;
}

PUB:warncool(id) SetPVarInt(id, "Warned", 0);

CMD:giveallscore(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 4)
	    return accessdenied(playerid);
	new score;
	if( sscanf(params, "d", score))
	    return SendUsage(playerid, "USAGE: /giveallscore [score]");
	new string[100];
	String("Administrator %s has given everyone %d score.", gPlayerInfo[playerid][pName], score);
	SendClientMessageToAll( COLOR_YELLOW, string );
	foreach(Player, i)
	{
	    if( IsPlayerConnected(i))
		{
		    GivePlayerScoreSync(i,score);
		    PlayerPlaySound(i,1057,0.0,0.0,0.0);
		}
	}
	return 1;
}

CMD:giveallmoney(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 3)
	    return accessdenied(playerid);
	new cash;
	if(sscanf(params, "d", cash))
	    return SendUsage(playerid, "USAGE: /giveallmoney [money]");
	new string[100];
	String("Administrator %s has given everyone $%d money.", gPlayerInfo[playerid][pName], cash );
	SendClientMessageToAll( COLOR_YELLOW, string );
	foreach(Player, i)
	{
	    if(IsPlayerConnected(i))
		{
		    GivePlayerMoneySync(i, cash);
		    PlayerPlaySound(i,1057,0.0,0.0,0.0);
		}
	}
	return 1;
}

CMD:ban(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 2)
		return accessdenied(playerid);
	new id, reason[128];
	if( sscanf( params, "us[128]", id, reason))
		return SendUsage(playerid, "USAGE: /ban [ID] [reason]");
	if( !IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (strlen(reason) > 40) 
		return SendClientMessage(playerid, COLOR_RED, "Reason must be below 40 characters.");
    if (gPlayerInfo[playerid][pAlevel]< 6 && gPlayerInfo[id][pAlevel] > 0)
	    return SendClientMessage(playerid, COLOR_RED, "You cannot ban an administrator.");
	new string[128];
	String("[BAN] Administrator %s has banned %s. [reason: %s]", gPlayerInfo[playerid][pName],gPlayerInfo[id][pName],reason);
	SendClientMessageToAll( COLOR_RED, string);
	new query[256];
	new year, month, day;
	getdate(year, month, day);
	new hour, minute, second;
	gettime(hour, minute, second);
	new timestring[20];
	format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
	Query("INSERT INTO bans (nick,time,reason,bannedby,IP) VALUES ('%s','%s','%s','%s','%s')",gPlayerInfo[id][pName],timestring,reason,gPlayerInfo[playerid][pName],gPlayerInfo[id][pIp]);
	mysql_query(query);
    String("You have been banned by %s, for: %s. You were banned on %i/%i/%i at %i:%i:%i.",gPlayerInfo[playerid][pName],reason,year,month,day,hour,minute,second);
	KickWithMessage(id,string);
	return 1;
}

CMD:sban(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 2)
		return accessdenied(playerid);
	new id, reason[128];
	if(sscanf( params, "us[128]", id, reason))
		return SendUsage(playerid, "USAGE: /sban (silent ban) [ID] [reason]");
	if( !IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (strlen(reason) > 40) 
		return SendClientMessage(playerid, COLOR_RED, "Reason must be below 40 characters.");
    if (gPlayerInfo[playerid][pAlevel]< 6 && gPlayerInfo[id][pAlevel] > 0)
	    return SendClientMessage(playerid, COLOR_RED, "You cannot ban an administrator.");
	new string[128];
	String("[ADMIN] [SBAN] %s has silent banned %s. [reason: %s]", gPlayerInfo[playerid][pName],gPlayerInfo[id][pName],reason);
	SendMessageToAdmins(COLOR_RED, string);
	new query[256];
	new year, month, day;
	getdate(year, month, day);
	new hour, minute, second;
	gettime(hour, minute, second);
	new timestring[20];
	format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
	Query("INSERT INTO bans (nick,time,reason,bannedby,IP) VALUES ('%s','%s','%s','%s','%s')",gPlayerInfo[id][pName],timestring,reason,gPlayerInfo[playerid][pName],gPlayerInfo[id][pIp]);
	mysql_query(query);
	Kick(id);
	return 1;
}

CMD:tban(playerid, params[])
{
    if( gPlayerInfo[playerid][pAlevel] < 2 )
		return accessdenied(playerid);
	new id, reason[128], time;
	if(sscanf(params, "us[128]i", id, reason,time))
		return SendUsage(playerid, "USAGE: /tban [ID] [reason] [hours]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (time < 1)
		return SendClientMessage(playerid, COLOR_RED, "Time must be above 0.");
	if (strlen(reason) > 40) 
		return SendClientMessage(playerid, COLOR_RED, "Reason must be below 40 characters.");
	if (gPlayerInfo[playerid][pAlevel]< 6 && gPlayerInfo[id][pAlevel] > 0)
	    return SendClientMessage(playerid, COLOR_RED, "You cannot ban an administrator.");
	new string[128];
	String("[TBAN] Administrator %s has temporarily banned %s for %i hours. [reason: %s]", gPlayerInfo[playerid][pName],gPlayerInfo[id][pName], time, reason);
	SendClientMessageToAll( COLOR_RED, string );
	new query[256];
	new year, month, day;
	getdate( year, month, day );
	new hour, minute, second;
	gettime(hour, minute, second);
	new timestring[20];
	format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
	Query("INSERT INTO bans (nick,time,reason,bannedby,IP,unban) VALUES ('%s','%s','%s','%s','%s','%i')",gPlayerInfo[id][pName],timestring,reason,gPlayerInfo[playerid][pName],gPlayerInfo[id][pIp],(time * 3600) + gettime() );
	mysql_query(query);
	KickWithMessage(id, "You have been temporarily banned.");
	return 1;
}

CMD:jetpack(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
	SetPlayerSpecialAction(playerid, 2);
	AdminCommand(playerid, "JETPACK");
	return 1;
}

CMD:getinfo(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	new targetid;
	if(sscanf(params, "u", targetid)) 
		targetid=playerid;
	if (!IsPlayerConnected(targetid) || targetid==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (!gPlayerInfo[targetid][pLogged]) 
		return SendClientMessage(playerid, COLOR_GRAY, "Player is not logged in.");
	ShowStats(targetid,playerid,1);
	return 1;
}

CMD:healall(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 4)
		return accessdenied(playerid);
	new string[70];
	String("Administrator %s has healed all players.", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll( COLOR_YELLOW, string);
	foreach(Player, i)
	{
		SetPlayerHealth(i, 99.0);
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	return 1;
}

CMD:armourall(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 4 )
		return accessdenied(playerid);
	new string[70];
	String("Administrator %s has armoured all players.", gPlayerInfo[playerid][pName] );
	SendClientMessageToAll( COLOR_YELLOW, string );
	foreach(Player, i)
	{
		SetPlayerArmour(i, 99.0);
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	return 1;
}
CMD:armorall(playerid, params[]) { return cmd_armourall(playerid,params); }

CMD:setscore(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 4)
		return accessdenied(playerid);
	new id, score;
	if( sscanf( params, "ud", id, score ) )
		return SendUsage(playerid, "USAGE: /setscore [ID] [score]");
	if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID )
		return SendClientMessage(playerid, invalidplayer);
	new string[70];
	String("You have set %s's score to %d!",gPlayerInfo[id][pName], score );
	SendClientMessage( playerid, COLOR_YELLOW, string );
	String("Administrator %s has set your score to %d!", gPlayerInfo[playerid][pName], score );
	SendClientMessage( id, COLOR_YELLOW, string );
	SetPlayerScoreSync(id,score);
	AdminCommand(playerid, "SETSCORE",id);
	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	return 1;
}

CMD:setmoney(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 3 )
		return accessdenied(playerid);
	new id, money;
	if( sscanf( params, "ud", id, money ) )
		return SendUsage(playerid, "USAGE: /setmoney [ID] [money]");
	if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID )
		return SendClientMessage(playerid, invalidplayer);
	new string[60];
	String("You have set %s's money to %d!",gPlayerInfo[id][pName], money );
	SendClientMessage( playerid, COLOR_YELLOW, string );
	String("Administrator %s has set money to %d!", gPlayerInfo[playerid][pName], money);
	SendClientMessage( id, COLOR_YELLOW, string );
	SetPlayerMoneySync(id,money);
	AdminCommand( playerid, "SETMONEY",id );
	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	return 1;
}

CMD:syncmoney(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel] < 2)
		return accessdenied(playerid);
	new id;
	if (sscanf(params,"d",id))
		return SendUsage(playerid, "USAGE: /syncmney [ID]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	new string[60];
	String("You have forced %s's player side money to %d!",gPlayerInfo[id][pName],gPlayerInfo[id][pMoney]);
	SendClientMessage(playerid,COLOR_YELLOW,string);
	SyncMoney(id);
	AdminCommand(playerid,"SYNCMONEY",id);
	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	return 1;
}

CMD:richlist(playerid, params[])
{
	#pragma unused params
	new string[71],richid[10],richmoney[10],richgamemoney[10],pmoney;
	for (new i=0;i<10;i++)
	{
	    richid[i]=-1;
	    richmoney[i]=-1000000;
	    richgamemoney[i]=-1000000;
	}
	SendClientMessage(playerid,COLOR_GREEN,"Top 10 richest players online:");
	foreach(Player,i)
	{
	    pmoney=GetPlayerMoney(i);
	    for (new j=0;j<10;j++)
	    {
	        if (pmoney>richgamemoney[j])
	        {
	            if (j!=9)
	            {
	            	for (new k=8;k>=j;k--)
	            	{
	            	    richgamemoney[k+1]=richgamemoney[k];
	            	    richmoney[k+1]=richmoney[k];
	            	    richid[k+1]=richid[k];
	            	}
	            }
	            richgamemoney[j]=pmoney;
	            richmoney[j]=gPlayerInfo[i][pMoney];
	            richid[j]=i;
	            break;
	        }
	    }
	}
	for (new i=0;i<10;i++)
	{
	    if (richid[i]<0) break;
	    String( "%d) [%d] %s - $%d ($%d)",i+1,richid[i],gPlayerInfo[richid[i]][pName],richgamemoney[i],richmoney[i]);
		SendClientMessage(playerid,COLOR_WHITE,string);
	}
	return 1;
}

CMD:stats(playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) 
		targetid=playerid;
	if (!IsPlayerConnected(targetid) || targetid==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (!gPlayerInfo[targetid][pLogged]) 
		return SendClientMessage(playerid, COLOR_GRAY, "Player is not logged in.");
	ShowStats(targetid,playerid);
	return 1;
}

CMD:a(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
	if(isnull(params))
		return SendUsage(playerid, "USAGE: /a [text]");
	else {
		new string[128];
		String("[A.chat][%d]%s: %s", playerid,gPlayerInfo[playerid][pName], params);
		foreach(Player, i) if( gPlayerInfo[i][pAlevel] > 0 || Undercover[i] == 1 ) SendClientMessage( i, COLOR_FUCHSIA, string);
		return 1;
	}
}

CMD:o(playerid, params[])
{
	if (!gPlayerInfo[playerid][pAlevel] && !gPlayerInfo[playerid][pOp])
	  return accessdenied(playerid);
	if(isnull(params))
		return SendUsage(playerid, "USAGE: /o [text]");
	else {
		new string[128];
		String("[O.chat][%d]%s: %s", playerid,gPlayerInfo[playerid][pName], params);
		foreach(Player, i) if( gPlayerInfo[i][pAlevel] > 0 || gPlayerInfo[i][pOp] == 1 || Undercover[i] == 1 ) SendClientMessage( i, COLOR_FUCHSIA, string);
		return 1;
	}
}

CMD:admins(playerid, params[])
{
	new count,string[128],title[60],duty[20];
	SendClientMessage(playerid,-1,"Current admins online:");
	foreach(Player, i)
	{
	    if(gPlayerInfo[i][pAlevel] > 0)
	    {
		    switch(gPlayerInfo[i][pAlevel])
		    {
				case 1: format(title, sizeof(title), "Server Moderator");
				case 2: format(title, sizeof(title), "Senior Administrator");
				case 3: format(title, sizeof(title), "General Administrator");
				case 4: format(title, sizeof(title), "Senior Administrator");
				case 5: format(title, sizeof(title), "Head Administrator");
				case 6: format(title, sizeof(title), "Server Owner");
		    }
			switch(gPlayerInfo[i][pDBID])
			{
			    case 1: strcat(title, " - Systems Administrator");
			    case 2: strcat(title, " - Scripter");
			}
			if (GetPVarInt(i,"AdminDuty")==1) format(duty, sizeof(duty), "| {E964ED}ON DUTY");
			else format(duty, sizeof(duty), "| Off Duty");
			if (gPlayerInfo[i][pAlevel]> 0 && gPlayerInfo[i][adminhide] == 0)
			{
				String("%s | Level: %d - %s | ID: %d %s",gPlayerInfo[i][pName],gPlayerInfo[i][pAlevel], title, i, duty);
				SendClientMessage(playerid,COLOR_AZURE,string);
				count++;
			}
			else if(gPlayerInfo[playerid][pAlevel]> 4 && gPlayerInfo[i][adminhide] == 1)
			{
			    String("%s | Level: %d - %s | ID: %d | HIDING %s", gPlayerInfo[i][pName],gPlayerInfo[i][pAlevel], title, i, duty);
			    SendClientMessage(playerid, COLOR_AZURE, string);
			    count++;
			}
		}
	}
	if (!count) SendClientMessage(playerid,COLOR_WHITE,"No admins are online right now! Contact them at www.sector7gaming.com/forums.");
	return 1;
}

CMD:get(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 1)
		return accessdenied(playerid);
	new id, inte, vw;
	if(sscanf(params, "u", id))
		return SendUsage(playerid, "USAGE: /get [ID]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	new Float:x, Float:y, Float:z;
	GetPlayerPos( playerid, x, y, z );
	inte = GetPlayerInterior(playerid);
	vw = GetPlayerVirtualWorld(playerid);
	SetPlayerInterior(id, inte);
	SetPlayerVirtualWorld(id, vw);
	SetPVarInt(id, "NoAB", 4);
	SetPlayerPos( id, x, y + 2, z );
	new string[95];
	String("Administrator %s has teleported you to their position.", gPlayerInfo[playerid][pName]);
	SendClientMessage( id, COLOR_YELLOW, string);
	AdminCommand(playerid, "GET",id);
	return 1;
}

CMD:eget(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1)
		return accessdenied(playerid);
	new id, inte, vw;
	if(sscanf(params, "u", id))
		return SendUsage(playerid, "USAGE: /get [ID]");
	if(!IsPlayerConnected( id ) || id == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	inte = GetPlayerInterior(playerid);
	vw = GetPlayerVirtualWorld(playerid);
	SetPlayerInterior(id, inte);
	SetPlayerVirtualWorld(id, vw);
	SetPVarInt(id, "NoAB", 4);
	SetPlayerPos(id, x, y + 2, z);
	RemovePlayerFromVehicle(id);
	ResetPlayerWeaponsEx(id);
	TogglePlayerControllable(id, 0);
	new string[128];
	String("Administrator %s has teleported you to his position.", gPlayerInfo[playerid][pName]);
	SendClientMessage(id, COLOR_YELLOW, string);
	AdminCommand( playerid, "EGET",id );
	return 1;
}

CMD:nos(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GRAY, "ERROR: You are not in a vehicle!");
    {
   		new vehicleid = GetPlayerVehicleID(playerid);
		AddVehicleComponent(vehicleid, 1010);
		AdminCommand(playerid, "NOS");
	}
	return 1;
}

CMD:goto(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 1)
		return accessdenied(playerid);
	new id,inte,vw;
	if(sscanf(params, "u", id))
		return SendUsage(playerid, "USAGE: /goto [ID]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(id, x, y, z);
	inte = GetPlayerInterior(id);
	vw = GetPlayerVirtualWorld(id);
	SetPlayerInterior(playerid, inte);
	SetPlayerVirtualWorld(playerid, vw);
	SetPVarInt(playerid, "NoAB", 3);
	SetPlayerPos(playerid, x, y + 2, z);
	AdminCommand(playerid, "GOTO",id);
	return 1;
}

CMD:explode(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 2)
	    return accessdenied(playerid);
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /explode [ID]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	new	Float:x, Float:y, Float:z;
	GetPlayerPos(id, x, y, z);
	CreateExplosion(x, y, z, 11, 10.0);
	AdminCommand(playerid, "EXPLODE",id);
	return 1;
}

CMD:burn(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 2)
	    return accessdenied(playerid);
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /burn [ID]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	new Float:x, Float:y, Float:z;
	GetPlayerPos(id, x, y, z);
	CreateExplosion(x, y, z, 9, 10.0);
	AdminCommand(playerid, "BURN",id);
	return 1;
}

CMD:slap(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /slap [ID]");
	if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	new Float:x,Float:y,Float:z;
	GetPlayerPos(id,x,y,z);
	SetPVarInt(id, "NoAB", 4);
	SetPlayerPos(id,x,y,z+8);
	PlayerPlaySound(playerid,1190,0.0,0.0,0.0);
	PlayerPlaySound(id,1190,0.0,0.0,0.0);
	AdminCommand(playerid,"SLAP",id);
	return 1;
}

CMD:hslap(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /hslap [ID]");
	if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	new Float:x,Float:y,Float:z;
	GetPlayerPos(id,x,y,z);
	SetPVarInt(id, "NoAB", 4);
	SetPlayerPos(id,x,y,z+7);
	PlayerPlaySound(playerid,1190,0.0,0.0,0.0);
	PlayerPlaySound(id,1190,0.0,0.0,0.0);
	new Float:health;
	GetPlayerHealth(id,health);
	SetPlayerHealth(id,health-15);
	AdminCommand(playerid,"HSLAP",id);
	return 1;
}

CMD:givescore(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel]< 4)
	    return accessdenied(playerid);
	new id, score;
	if(sscanf(params, "ud", id, score))
	    return SendUsage(playerid, "USAGE: /givescore [ID] [score]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	GivePlayerScoreSync(id,score);
	new string[100];
	String("Administrator %s has gave you %d score.", gPlayerInfo[playerid][pName], score);
	SendClientMessage( id, COLOR_YELLOW, string );
	String("You gave %d score to %s.", score,gPlayerInfo[id][pName]);
	SendClientMessage( playerid, COLOR_YELLOW, string);
	AdminCommand( playerid, "GIVESCORE",id);
	return 1;
}

CMD:rangecheck(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel] < 2)
		return accessdenied(playerid);
	new rip[32],count;
	if (sscanf(params,"s[32]",rip)) return SendUsage(playerid, "USAGE: /rangecheck [IP range]");
	new string[128];
	String("Players with \"%s\" in their IP:",params);
	SendClientMessage(playerid, -1, string);
	foreach(Player,i)
	{
		if (strfind(gPlayerInfo[i][pIp],rip,true,0)!=-1)
		{
			String("[%i]%s - %s",i,gPlayerInfo[i][pName],gPlayerInfo[i][pIp]);
			SendClientMessage(playerid,COLOR_ORANGE,string);
			count++;
		}
	}
	if (!count) SendClientMessage(playerid,COLOR_ORANGE,"(no one found under this IP range)");
	AdminCommand(playerid,"RANGECHECK");
	return 1;
}

CMD:setskin(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 2)
	    return accessdenied(playerid);
	new id, skin;
 	if(sscanf(params, "ud", id, skin))
		return SendUsage(playerid, "USAGE: /setskin [ID] [skin]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID )
	    return SendClientMessage(playerid, invalidplayer);
	if(!IsValidSkin(skin))
	    return SendClientMessage( playerid, COLOR_GRAY, "Invalid skin ID!");
	SetPlayerSkin(id, skin);
	new string[100];
 	String("You have set %s's skin to %d.",gPlayerInfo[id][pName], skin);
 	SendClientMessage( playerid, COLOR_YELLOW, string );
 	String("Administrator %s has set your skin to %d.", gPlayerInfo[playerid][pName], skin);
 	SendClientMessage( id, COLOR_YELLOW, string );
	AdminCommand( playerid, "SETSKIN",id );
	return 1;
}

CMD:report(playerid, params[])
{
	new id,reason[128];
	if (sscanf(params,"us[128]",id,reason))
		return SendUsage(playerid, "USAGE: /report [ID] [reason]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	if (!CheckCoolDown(playerid,"UsedReport",10)) return 1;
	new string[128];
	String("[REP] %s[%d] reported %s[%d] | reason: %s",gPlayerInfo[playerid][pName],playerid,gPlayerInfo[id][pName],id,reason);
	SendClientMessage(playerid,COLOR_YELLOW,"Report has been sent, an admin will look into it as soon as possible.");
	return 1;
}

CMD:asay(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	new text[128];
	if (sscanf(params,"s[128]",text))
	    return SendUsage(playerid, "USAGE: /asay [text]");
	new string[128];
	String("Admin %s: %s",gPlayerInfo[playerid][pName],text);
	SendClientMessageToAll(COLOR_PINK,string);
	return 1;
}

CMD:write(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	new text[128];
	if (sscanf(params,"s[128]",text))
	    return SendUsage(playerid, "USAGE: /write [text]");
	new string[128];
	String("* %s",text);
	SendClientMessageToAll(COLOR_LIMEGREEN,string);
	AdminCommand(playerid, "WRITE");
	return 1;
}

CMD:ssay(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 6)
	    return accessdenied(playerid);
	new text[128];
	if (sscanf(params,"s[128]",text))
	    return SendUsage(playerid, "USAGE: /ssay [text]");
	new string[128];
	String(BOT_NAME": %s", text);
	SendClientMessageToAll(COLOR_PINK,string);
	AdminCommand(playerid, "SSAY");
	return 1;
}

CMD:kickall(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 6) return accessdenied(playerid);
	new string[75];
	String("Administrator %s has kicked all players.", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_RED, string);
	foreach(Player, i) if(gPlayerInfo[i][pAlevel] < 6) Kick(i);
	return 1;
}

CMD:lockserver(playerid, params[])
{
    if( gPlayerInfo[playerid][pAlevel] < 6)
        return accessdenied(playerid);
	SendRconCommand("password slock42");
	new string[75];
	String("Administrator %s has locked the server.", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_RED, string);
	SendClientMessage(playerid, COLOR_RED, "Server password added(slock42). If needed, edit the server.cfg to maintain a password.");
	return 1;
}

CMD:unlockserver(playerid, params[])
{
    if( gPlayerInfo[playerid][pAlevel] < 6)
        return accessdenied(playerid);
	SendRconCommand("password 0");
	new string[75];
	String("Administrator %s has unlocked the server.", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_GREEN, string);
	SendClientMessage(playerid, COLOR_RED, "Server password removed. If set from server.cfg, make sure to edit the configuration.");
 	return 1;
}

CMD:stopserver(playerid, params[])
{
    if( gPlayerInfo[playerid][pAlevel] < 6)
        return accessdenied(playerid);
	SendRconCommand("exit");
 	return 1;
}

CMD:crash(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new id;
 	if(sscanf(params,"u",id)) return SendUsage(playerid, "USAGE: /crash [ID]");
 	if(id == INVALID_PLAYER_ID) SendClientMessage(playerid, invalidplayer);
 	else
	{
 		SetPlayerVelocity(id, 999, 999, 999);
   		new string[49];
      	String("Attempted to crash %s's game.",gPlayerInfo[id][pName]);
		SendClientMessage(playerid,COLOR_WHITE,string);
		AdminCommand(playerid,"CRASH",id);
	}
	return 1;
}

CMD:getall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 5) return accessdenied(playerid);
	new Float:x,Float:y,Float:z,string[100];
	GetPlayerPos(playerid,x,y,z);
	foreach(Player, i)
	{
 		if (gPlayerInfo[i][pAlevel]>=5) continue;
 		SetPVarInt(i, "NoAB", 4);
		SetPlayerPos(i,x,y,z);
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Admin %s has teleported all players to their current location.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_WHITE,string);
	AdminCommand(playerid,"GETALL");
    return 1;
}

CMD:setallskin(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 5) return accessdenied(playerid);
    new skin,string[70];
    if(sscanf(params,"i",skin)) return SendUsage(playerid, "USAGE: /setallskin [skin]");
    if(!IsValidSkin(skin)) return SendClientMessage(playerid, COLOR_ORANGE, "Invalid skin ID!");
    foreach(Player, i)
	{
 		SetPlayerSkin(i,skin);
 		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Admin %s has set all player's skin to %i.",gPlayerInfo[playerid][pName],skin);
 	SendClientMessageToAll(COLOR_WHITE,string);
	return 1;
}

CMD:killall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new string[70];
	foreach(Player,i)
 	{
		if(GetPVarInt(i, "AdminDuty") == 0)
		{
			SetPlayerHealth(i,0);
			PlayerPlaySound(i,1057,0.0,0.0,0.0);
		}
	}
	String("Admin %s has killed all players.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_WHITE,string);
	return 1;
}

CMD:setweather(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new Weatherid,string[70];
    if(sscanf(params,"i",Weatherid)) return SendUsage(playerid, "USAGE: /setweather [ID] (19 = sandstorm | 8 = stormy | 20 = green fog | 0-7 = clear sky | 44-45 = dark sky)");
    SetWeather(Weatherid);
    String("Admin %s has changed the weather to %i",gPlayerInfo[playerid][pName],Weatherid);
    SendClientMessageToAll(COLOR_WHITE,string);
    foreach(Player,i) PlayerPlaySound(i,1057,0.0,0.0,0.0);
	return 1;
}

CMD:dweather(playerid, params[])
{
    if(gPlayerInfo[playerid][pDonor]< 1) return SendClientMessage(playerid, donordeny1);
    new Weatherid,string[70];
    if(sscanf(params,"i",Weatherid)) return SendUsage(playerid, "USAGE: /setweather [ID] (19 = sandstorm | 8 = stormy | 20 = green fog | 0-7 = clear sky | 44-45 = dark sky)");
    SetPlayerWeather(playerid,Weatherid);
    String("You have changed your weather to weather ID %i.",Weatherid);
    SendClientMessageToAll(COLOR_WHITE,string);
	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	DonorCommand(playerid, "DWEATHER");
	return 1;
}

CMD:getid(playerid, params[])
{
	if(isnull(params))
	    return SendUsage(playerid, "USAGE: /getid [part of player name]");
	new string[64],count;
	String("Players with \"%s\" in their name:",params);
	SendClientMessage(playerid,COLOR_WHITE,string);
	foreach(Player, i)
	{
	    if (strfind(gPlayerInfo[i][pName],params,true)==-1) continue;
	    count++;
		String("- %d. %s (ID %d)",count,gPlayerInfo[i][pName],i);
		SendClientMessage(playerid, COLOR_WHITE ,string);
	}
	if (!count) return SendClientMessage(playerid,COLOR_ORANGE,"(no players found)");
	return 1;
}
CMD:id(playerid, params[]) { return cmd_getid(playerid,params); }

CMD:settime(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new id,string[64];
    if(sscanf(params,"i",id)) return SendUsage(playerid, "USAGE: /settime [time]");
    SetWorldTime(id);
    String("Admin %s has changed the time to %i",gPlayerInfo[playerid][pName],id);
    SendClientMessageToAll(COLOR_WHITE,string);
    foreach(Player,i) PlayerPlaySound(i,1057,0.0,0.0,0.0);
	return 1;
}

CMD:cc(playerid, params[]) { return cmd_clearchat(playerid,params); }
//Idk wtf the point of this was when there's a much better clearchat cmd already made -Billy
/*{
    if(gPlayerInfo[playerid][pAlevel] > 0)
	{
		for (new i=0;i<=20;i++) SendClientMessage(playerid, -1, " ");
    	AdminCommand(playerid,"CLEARCHAT(CC)");
	}
	else
	{
 		return accessdenied(playerid);
	}
	return 1;
}*/

CMD:jail(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 2) return accessdenied(playerid);
    new id,string[128],time,reason[30];
	if(sscanf(params,"udS[30]",id, time, reason)) return SendUsage(playerid, "USAGE: /jail [ID] [seconds] [reason]");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, invalidplayer);
	if (time < 1) 
		return SendClientMessage(playerid, COLOR_RED, "Time must be above 0.");
	if (strlen(reason) > 40) 
		return SendClientMessage(playerid, COLOR_RED, "Reason must be below 40 characters.");
	if (gPlayerInfo[playerid][pAlevel]< 6 && gPlayerInfo[id][pAlevel] > 0)
	    return SendClientMessage(playerid, COLOR_RED, "You cannot jail an administrator.");
	if(GetPVarInt(id, "Jailed") == 0)
	{
		SetPVarInt(id,"Jailed",1);
       	TogglePlayerControllable(id,false);
       	SetPVarInt(id, "NoAB", 4);
		SetPlayerPos(id,197.6661,173.8179,1003.0234);
		SetPlayerInterior(id,3);
		SetPlayerVirtualWorld(id, id+3);
		String("[JAIL] Administrator %s has jailed %s for %d seconds. [reason: %s]",gPlayerInfo[playerid][pName],gPlayerInfo[id][pName],time,reason);
		SendClientMessageToAll(COLOR_WHITE,string);
		String("[JAIL] Administrator %s has jailed you for %d seconds. [reason: %s]",gPlayerInfo[playerid][pName],time,reason);
		SendClientMessage(id,COLOR_WHITE,string);
		PlayerPlaySound(id,1057,0.0,0.0,0.0);
		SetPVarInt(playerid, "jailtime", GetTickCount() + time * 1000);
	}
	else return SendClientMessage(playerid,COLOR_ORANGE,"Player is already in jail");
	return 1;
}

CMD:mute(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 2) return accessdenied(playerid);
    new id,reason[40],string[128], time;
	if(sscanf(params,"us[40]d",id,reason, time)) return SendUsage(playerid, "USAGE: /mute [name/ID] [reason] [minutes]");
	if (strlen(reason) > 40) 
		return SendClientMessage(playerid, COLOR_RED, "Reason must be below 40 characters.");
	if (gPlayerInfo[playerid][pAlevel]< 6 && gPlayerInfo[id][pAlevel] > 0)
	    return SendClientMessage(playerid, COLOR_RED, "You cannot mute an administrator.");
	if(Muted[ playerid ] == 1) return SendClientMessage(playerid, COLOR_ORANGE, "Player is already muted.");
	if(!strlen(reason))
	    format(reason,sizeof reason, "No reason given");
	String("[MUTE] Administrator %s has muted %s for %d minute(s). [reason: %s]",gPlayerInfo[playerid][pName],gPlayerInfo[id][pName], time, reason);
    unmutetime = SetTimerEx("unmute",time*1000*60,0,"i",id);
	SendClientMessageToAll(COLOR_WHITE, string);
	SendClientMessage(id, COLOR_RED, "You have been muted!");
	Muted[id] = 1;
	PlayerPlaySound(id,1057,0.0,0.0,0.0);
	return 1;
}

PUB:unmute(id)
{
	if(Muted[id] == 1)
	{
		Muted[id] = 0;
		SendClientMessage(id, COLOR_RED, "Time's up, you have been unmuted.");
		KillTimer(unmutetime);
	}
	return 1;
}

CMD:unmute(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 2) return accessdenied(playerid);
    new id;
	if(sscanf(params,"u",id)) return SendUsage(playerid, "USAGE: /unmute [name/ID]");
	if(Muted[ id ] == 0) return SendClientMessage(playerid, COLOR_ORANGE, "Player is not muted!");
	Muted[id] = 0;
	SendClientMessage(id,COLOR_WHITE,"You have been unmuted!");
    AdminCommand(playerid,"UNMUTE",id);
    PlayerPlaySound(id,1057,0.0,0.0,0.0);
	return 1;
}

CMD:unjail(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 2) return accessdenied(playerid);
    new id,string[68];
    if(sscanf(params,"u",id)) return SendUsage(playerid, "USAGE: /unjail [ID]");
    if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, invalidplayer);
    if(GetPVarInt(id,"Jailed") == 1)
	{
    	SetPVarInt(id,"Jailed",0);
    	TogglePlayerControllable(id,true);
    	SetPlayerInterior(id,0);
    	SetPVarInt(id, "NoAB", 4);
		SpawnPlayer(id);
  		String("You have unjailed %s",gPlayerInfo[id][pName]);
		SendClientMessage(playerid,COLOR_WHITE,string);
		String("[JAIL] Admin %s has unjailed you.",gPlayerInfo[playerid][pName]);
		SendClientMessage(id,COLOR_WHITE,string);
		String("[JAIL] Admin %s has unjailed %s.",gPlayerInfo[playerid][pName],gPlayerInfo[id][pName]);
		SendClientMessageToAll(COLOR_WHITE,string);
		PlayerPlaySound(id,1057,0.0,0.0,0.0);
	}
 	else return SendClientMessage(playerid,COLOR_ORANGE,"Player is not in jail.");
	return 1;
}

CMD:setinterior(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
    new id,interior,string[75];
   	if(sscanf(params,"ui",id, interior)) return SendUsage(playerid, "USAGE: /setinterior [name/ID] [interior ID]");
   	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, invalidplayer);
	String("You have set %s's interior to %d.",gPlayerInfo[id][pName], interior);
	SendClientMessage(playerid,COLOR_WHITE,string);
	String("Administrator %s has set your interior to %d.", gPlayerInfo[playerid][pName], interior);
	SendClientMessage(id,COLOR_WHITE,string);
	SetPlayerInterior(id, interior);
	AdminCommand(playerid, "SETINTERIOR",id);
	PlayerPlaySound(id,1057,0.0,0.0,0.0);
    return 1;
}

CMD:setworld(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
    new id,world,string[75];
   	if(sscanf(params,"ui",id, world)) return SendUsage(playerid, "USAGE: /setworld [name/ID] [world ID]");
   	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, invalidplayer);
	String("You have set %s's world to %d.",gPlayerInfo[id][pName], world);
	SendClientMessage(playerid,COLOR_WHITE,string);
	String("Administrator %s has set your world to %d.", gPlayerInfo[playerid][pName], world);
	SendClientMessage(id,COLOR_WHITE,string);
	SetPlayerVirtualWorld(playerid, world);
	AdminCommand(playerid, "SETWORLD",id);
	PlayerPlaySound(id,1057,0.0,0.0,0.0);
    return 1;
}

CMD:sethealth(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 3) return accessdenied(playerid);
   	new id,Float:health,string[64];
    if(sscanf(params,"uf",id, health)) return SendUsage(playerid, "USAGE: /sethealth [name/ID] [health (max 99)]");
   	else if(id == INVALID_PLAYER_ID) SendClientMessage(playerid, invalidplayer);
   	else
   	{
		if((health > 99)) health = 99;
    	AdminCommand(playerid, "SETHEALTH",id);
	    SetPlayerHealth(id,health);
	    String("You have set %s's health to %.2f.",gPlayerInfo[id][pName],health);
	    SendClientMessage(playerid,COLOR_WHITE,string);
	}
	return 1;
}
CMD:sethp(playerid, params[]) { return cmd_sethealth(playerid,params); }

#define hvrules1 COLOR_PINKRED, "Heavy vehicle rules"
#define hvrules2 -1, "A 'heavy vehicle' is a vehicle with heavy weapons: hydras, hunters, rhinos, seasparrows, and rustlers."
#define hvrules3 -1, "You CAN NOT kill players inside of their base with ANY heavy vehicle."
#define hvrules4 -1, "You CAN kill players anywhere OUTSIDE of their home base with heavy vehicles."
CMD:forcehvrules(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /forcehvrules [ID]");
	if(!IsPlayerConnected(id))
	    return SendClientMessage(playerid, invalidplayer);
	SendClientMessage(id, COLOR_RED, "An administrator has forced you to read the heavy vehicle rules. Please read them carefully to avoid punishment.");
	SendClientMessage(id, hvrules1);
    SendClientMessage(id, hvrules2);
    SendClientMessage(id, hvrules3);
	SendClientMessage(id, hvrules4);
	AdminCommand(playerid, "FORCEHVRULES",id);
	return 1;
}
CMD:hvrules(playerid, params[])
{
	SendClientMessage(playerid, hvrules1);
	SendClientMessage(playerid, hvrules2);
	SendClientMessage(playerid, hvrules3);
	SendClientMessage(playerid, hvrules4);
	return 1;
}

CMD:setarmour(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 3) return accessdenied(playerid);
   	new id,Float:armour,string[64];
    if(sscanf(params,"uf",id, armour)) return SendUsage(playerid, "USAGE: /setarmour [name/ID] [armour (max 99)]");
   	else if(id == INVALID_PLAYER_ID) SendClientMessage(playerid, invalidplayer);
   	else
   	{
		if(armour > 99) armour = 99;
    	AdminCommand(playerid, "SETARMOUR",id);
	    SetPlayerArmour(id,armour);
	    String("You have set %s's armour to %.2f.",gPlayerInfo[id][pName], armour);
	    SendClientMessage(playerid,COLOR_WHITE,string);
	}
	return 1;
}
CMD:setarmor(playerid, params[]) { return cmd_setarmour(playerid,params); }

CMD:akill(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 3) return accessdenied(playerid);
	new id;
	if(sscanf(params,"u",id)) return SendUsage(playerid, "USAGE: /akill [name/ID]");
	if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, invalidplayer);
	AdminCommand(playerid, "AKILL",id);
	SetPlayerHealth(id,0.0);
	return 1;
}

CMD:force(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 2)
	    return accessdenied(playerid);
	new id;
	if(sscanf(params, "u",id))
	    return SendUsage(playerid, "USAGE: /force [ID]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	ForceClassSelection(id);
	SetPlayerHealth(id, 0.00);
	new string[128];
	String("You have force killed/forced class selection on %s.",gPlayerInfo[id][pName]);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	AdminCommand(playerid, "FORCE",id);
	return 1;
}

CMD:carhealth(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 3) return accessdenied(playerid);
    new id,vehicleid,Float:vhealth,string[66];
	if(sscanf(params,"uf",id,vhealth)) return SendUsage(playerid, "USAGE: /carhealth [name/ID] [vehicle HP]");
	vehicleid = GetPlayerVehicleID(id);
	SetVehicleHealth(vehicleid,vhealth);
	String("You have set %s's vehicle's health to %.2f.",gPlayerInfo[id][pName],vhealth);
	SendClientMessage(playerid,COLOR_WHITE,string);
	AdminCommand(playerid,"CARHEALTH",id);
	return 1;
}
CMD:vh(playerid, params[]) { return cmd_carhealth(playerid, params); }

CMD:gotopos(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 2) return accessdenied(playerid);
    new Float:x, Float:y, Float:z, string[50];
	if(sscanf(params,"fff",x,y,z)) return SendUsage(playerid, "USAGE: /gotopos [X pos] [Y pos] [Z pos]");
	SetPVarInt(playerid, "NoAB", 4);
	SetPlayerPos(playerid,x,y,z);
	String("You have teleported to X:%f Y:%f Z:%f",x,y,z);
	SendClientMessage(playerid,COLOR_WHITE,string);
	AdminCommand(playerid, "GOTOPOS");
	return 1;
}

CMD:freezeall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new string[55];
    foreach(Player, i)
    {
        SetPVarInt(i, "Frozen", 1);
        TogglePlayerControllable(i,false);
        PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Admin %s has frozen all players.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_WHITE, string);
	return 1;
}

CMD:unfreezeall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new string[56];
    foreach(Player, i)
    {
        SetPVarInt(i, "Frozen", 0);
        TogglePlayerControllable(i,true);
        PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Admin %s has unfrozen all players.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_WHITE, string);
	return 1;
}

CMD:slapall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new string[55],Float:x,Float:y,Float:z;
	foreach(Player, i)
	{
	    SetPVarInt(i, "NoAB", 4);
		GetPlayerPos(i, x, y, z);
	    SetPlayerPos(i, x,y,z+5);
	    PlayerPlaySound(i,1190,0.0,0.0,0.0);
	}
	String("Admin %s has slapped all players.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_WHITE,string);
	return 1;
}

CMD:ejectall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[75];
	foreach(Player, i)
	{
	    if (!IsPlayerInAnyVehicle(playerid)) continue;
        RemovePlayerFromVehicle(playerid);
        PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Admin %s has ejected all players from their vehicles.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_ORANGE,string);
	return 1;
}

CMD:eject(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 2)
	    return accessdenied(playerid);
	new id;
	if(sscanf(params, "u",id))
	    return SendUsage(playerid, "USAGE: /eject [ID]");
	if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	if (!IsPlayerInAnyVehicle(id))
		return SendClientMessage(playerid, COLOR_RED, "Player is not in any vehicle.");
	RemovePlayerFromVehicle(id);
	new string[75];
	String("You have force ejected %s from their vehicle.",gPlayerInfo[id][pName]);
	SendClientMessage(playerid, -1, string);
	AdminCommand(playerid, "EJECT",id);
	return 1;
}

CMD:spawnall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new string[70];
	foreach(Player, i)
	{
	    SetPVarInt(i, "NoAB", 4);
	    SpawnPlayer(i);
	    PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Admin %s has spawned all players.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_ORANGE,string);
	return 1;
}

CMD:muteall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new string[70];
    foreach(Player, i)
	{
	    Muted[i] = 1;
	    PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Admin %s has muted all players.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_WHITE,string);
	return 1;
}

CMD:unmuteall(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
    new string[60];
	foreach(Player, i)
	{
	    Muted[i] = 0;
	    PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Admin %s has unmuted all players.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_WHITE,string);
	return 1;
}

CMD:afk(playerid, params[])
{
    if (!gPlayerInfo[playerid][pAlevel] && !gPlayerInfo[playerid][pOp])
        return accessdenied(playerid);
    new string[60],id;
	if(sscanf(params,"u",id)) return SendUsage(playerid, "USAGE: /afk [name/ID]");
	if(gPlayerInfo[id][pAlevel] < 5 && iAFKp[id] < 180)
		return SendClientMessage(playerid, COLOR_RED, "You can only disconnect players who have been AFK for more than 180 seconds (3 minutes).");
	String("%s has been disconnected for being AFK.",gPlayerInfo[id][pName]);
	SendClientMessageToAll(COLOR_ORANGE,string);
	KickWithMessage(id, "You have been disconnected for being AFK.");
	AdminCommand(playerid, "AFK",id);
	return 1;
}

CMD:joinenabled(playerid, params[])
{
	if(gPlayerInfo[ playerid ][ pAlevel ] < 4) return accessdenied(playerid);
	ssstring("Administrator %s has started an event! - /join | /joincancel", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, ssstring);
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		gPlayerInfo[i][joinenabled] = 1;
	}
	return 1;
}

CMD:joindisabled(playerid, params[])
{
    if(gPlayerInfo[ playerid ][ pAlevel ] < 4) return accessdenied(playerid);
	ssstring("Administrator %s has disabled the /join command.", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, ssstring);
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		gPlayerInfo[ i ][ joinenabled ] = 0;
	}
	return 1;
}

/*CMD:joinlist(playerid, params[])
{
	if(gPlayerInfo[ playerid ][ pAlevel ] < 4) return SendClientMessage(playerid, COLOR_ORANGE, "You need to be a level 4+ admin");
	SendClientMessage(playerid, COLOR_YELLOW, "- CURRENT PLAYERS THAT USED /JOIN -");
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    if(gPlayerInfo[ i ][ joined ] == 1)
	    {
	        ssstring("{66e268}USER{FFFFFF}: {66e268}%s{FFFFFF}[{66e268}%d{FFFFFF}]", gPlayerInfo[ i ][ pName ], i);
	        SendClientMessage(playerid, -1,ssstring);
		}
		if(!Countjoin) return SendClientMessage(playerid, COLOR_ORANGE, "- Nobody has joined the event yet.");
	}
	return 1;
}*/

CMD:join(playerid, params[])
{
	if(gPlayerInfo[ playerid ][ joinenabled ] == 0) return SendClientMessage(playerid, COLOR_ORANGE, "This is currently disabled.");
	if(gPlayerInfo[ playerid ][ joined ] == 1) return SendClientMessage(playerid, COLOR_ORANGE, "You are already in the list awaiting to join the event.");
	if(GetPVarInt(playerid, "AdminDuty") == 1) return SendClientMessage(playerid, COLOR_ORANGE, "You must go off duty to join the event!");
	gPlayerInfo[playerid][joined] = 1;
	SendClientMessage(playerid, COLOR_ORANGE, "You are now in the awaiting event, wait for instructions!");
	return 1;
}

CMD:joincancel(playerid, params[])
{
	if(gPlayerInfo[playerid][joinenabled] == 0) return SendClientMessage(playerid, COLOR_ORANGE, "This is currently disabled.");
	if(gPlayerInfo[playerid][joined] == 0) return SendClientMessage(playerid, COLOR_ORANGE, "You're not set to join the event.");
	gPlayerInfo[playerid][joined] = 0;
	SendClientMessage(playerid, COLOR_ORANGE, "You won't be in the upcoming event any more!");
	return 1;
}

CMD:joinget(playerid, params[])
{
	if(gPlayerInfo[ playerid ][ pAlevel ] < 4) return accessdenied(playerid);
	ssstring("Administrator %s has teleported the players who joined the event!", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, ssstring);
	for( new i=0;i<MAX_PLAYERS;i++)
	{
	    if(gPlayerInfo[i][joined] == 1)
	    {
	        new Float:Pos[3];
	        SetPVarInt(i, "Frozen", 1);
        	TogglePlayerControllable(i,false);
	        GetPlayerPos(playerid, Pos[0],Pos[1],Pos[2]);
	        SetPVarInt(i, "NoAB", 4);
	        SetPlayerPos(i, Pos[0] +random(5), Pos[1]+random(5), Pos[2]);
	        SetPlayerHealth(i, 99);
	        SetPlayerArmour(i, 99);
	        SetPlayerVirtualWorld(i, GetPlayerVirtualWorld(playerid));
	        SetPlayerInterior(i, GetPlayerInterior(playerid));
	        SetPlayerTeam(i, NO_TEAM);
	        ResetPlayerWeaponsEx(i);
		}
	}
	return 1;
}

CMD:unfreezejoin(playerid, params[])
{
	if(gPlayerInfo[ playerid ][ pAlevel ] < 4) return accessdenied(playerid);
	ssstring("Administrator %s has unfrozen the players who joined the event!", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, ssstring);
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    if(gPlayerInfo[i][joined] == 1)
	    {
			TogglePlayerControllable(i, 1);
			SendClientMessage(i, -1, "- UNFROZEN");
		}
	}
	return 1;
}

CMD:spawnjoined(playerid, params[])
{
	new string[97];
    if(gPlayerInfo[ playerid ][ pAlevel ] < 4) return accessdenied(playerid);
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    if(gPlayerInfo[i][joined]==1)
	    {
	        gPlayerInfo[i][joined]=0;
	        SetPVarInt(i, "NoAB", 4);
			SpawnPlayer(i);
		}
	}
	String("Adminstrator %s has spawned all players who were in the event.", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, string);
	return 1;
}

CMD:freezeteam(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[55],tn[10],team;
	if(sscanf(params,"s[10]",tn)) return SendUsage(playerid, "USAGE: /freezeteam [team name]");
	team=ReturnTeamId(playerid,tn);
    if (team==-1) return 1;
	foreach(Player, i)
	{
	    if (gPlayerInfo[i][pTeam]==team)
	    {
	        SetPVarInt(i,"Frozen",1);
	        TogglePlayerControllable(i, false);
		}
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Administrator %s has frozen team %s.",gPlayerInfo[playerid][pName],gTeam[team]);
	SendClientMessageToAll(COLOR_CYAN, string);
	return 1;
}

CMD:teams(playerid, params[])
{
	new string[128];
	for (new i=1;i<MAX_TEAMS;i++)
	{
	    String("%s: %i players",gTeam[i][tName],gTeam[i][tPlayers]);
	    SendClientMessage(playerid,gTeam[i][tColor],string);
	}
	return 1;
}

CMD:getteam(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[90],tn[20],team,Float:x,Float:y,Float:z,interior,world;
	if(sscanf(params,"s[10]",tn)) return SendUsage(playerid, "USAGE: /getteam [team name]");
	interior = GetPlayerInterior(playerid);
	world = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, x,y,z);
	team=ReturnTeamId(playerid,tn);
    if (team==-1) return 1;
	foreach(Player, i)
	{
	    if (gPlayerInfo[i][pTeam]==team)
	    {
	        SetPlayerInterior(i, interior);
	        SetPlayerVirtualWorld(i, world);
	        SetPVarInt(i, "NoAB", 4);
	        SetPlayerPos(i,x+1,y,z);
	        ResetPlayerWeaponsEx(i);
		}
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Administrator %s has teleported team %s to their self.",gPlayerInfo[playerid][pName],gTeam[team]);
	SendClientMessageToAll(COLOR_CYAN, string);
	return 1;
}

CMD:spawnteam(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[100],tn[20],team;
	if(sscanf(params,"s[20]",tn)) return SendUsage(playerid, "USAGE: /spawnteam [team name]");
	team=ReturnTeamId(playerid,tn);
    if (team==-1) return 1;
	foreach(Player, i)
	{
	    if (gPlayerInfo[i][pTeam]==team)
	    {
	    	SetPVarInt(i, "NoAB", 4);
	        SpawnPlayer(i);
		}
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Administrator %s has spawned team %s.",gPlayerInfo[playerid][pName], gTeam[team]);
	SendClientMessageToAll(COLOR_CYAN, string);
	return 1;
}

CMD:giveteamscore(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[100],tn[20],team,amount;
	if(sscanf(params,"s[20]i",tn,amount)) return SendUsage(playerid, "USAGE: /giveteamscore [team name] [amount]");
	team=ReturnTeamId(playerid,tn);
    if (team==-1) return 1;
	foreach(Player, i)
	{
	    if (gPlayerInfo[i][pTeam]==team)
	    {
	        GivePlayerScoreSync(i,amount);
		}
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Administrator %s has given team %s %i score.",gPlayerInfo[playerid][pName], gTeam[team], amount);
	SendClientMessageToAll(COLOR_CYAN, string);
	return 1;
}

CMD:healteam(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[100],tn[20],team;
	if(sscanf(params,"s[20]",tn)) return SendUsage(playerid, "USAGE: /healteam [team name]");
	team=ReturnTeamId(playerid,tn);
    if (team==-1) return 1;
	foreach(Player, i)
	{
	    if (gPlayerInfo[i][pTeam]==team)
	    {
	        SetPlayerHealth(i, 99);
		}
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Administrator %s has healed team %s.",gPlayerInfo[playerid][pName], gTeam[team]);
	SendClientMessageToAll(COLOR_CYAN, string);
	return 1;
}

CMD:armourteam(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[100],tn[20],team;
	if(sscanf(params,"s[20]",tn)) return SendUsage(playerid, "USAGE: /armourteam [team name]");
	team=ReturnTeamId(playerid,tn);
    if (team==-1) return 1;
	foreach(Player, i)
	{
	    if (gPlayerInfo[i][pTeam]==team)
	    {
	        SetPlayerArmour(i, 99);
		}
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Administrator %s has armoured team %s.",gPlayerInfo[playerid][pName], gTeam[team]);
	SendClientMessageToAll(COLOR_CYAN, string);
	return 1;

}
CMD:armorteam(playerid, params[]) { return cmd_armourteam(playerid,params); }

CMD:giveteammoney(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[100],tn[20],team,amount;
	if(sscanf(params,"s[20]i",tn,amount)) return SendUsage(playerid, "USAGE: /giveteammoney [team name] [amount]");
	team=ReturnTeamId(playerid,tn);
    if (team==-1) return 1;
	foreach(Player, i)
	{
	    if (gPlayerInfo[i][pTeam]==team)
	    {
	        GivePlayerMoneySync(i,amount);
		}
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Administrator %s has given team %s $%i.",gPlayerInfo[playerid][pName],gTeam[team],amount);
	SendClientMessageToAll(COLOR_CYAN, string);
	return 1;
}

CMD:giveteamweapon(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[120],tn[20],team,weap[15],ammo;
	if(sscanf(params,"s[20]s[10]i",tn,weap,ammo)) return SendUsage(playerid, "USAGE: /giveteamweapon [team name] [weapon name] [ammo]");
	team=ReturnTeamId(playerid,tn);
    if (team==-1) return 1;
	new weapid=GetWeaponIDFromName(weap);
	if (weapid==-1) return SendClientMessage(playerid, invalidweapon);
	if (weapid==WEAPON_MINIGUN) return SendClientMessage(playerid,COLOR_ORANGE, "You can't give miniguns!");
	new curweap;
	foreach(Player, i)
	{
	    if (gPlayerInfo[i][pTeam]==team)
		{
		    if (IsPlayerInAnyVehicle(i))
		    {
			    curweap=GetPlayerWeapon(i);
			    GivePlayerWeaponEx(i,weapid,ammo);
			    if (weapid==WEAPON_DEAGLE || weapid==WEAPON_SHOTGSPA || weapid==WEAPON_SNIPER) SetPlayerArmedWeapon(i,curweap);
			}
			else GivePlayerWeaponEx(i,weapid,ammo);
		}
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	String("Administrator %s has given team %s a %s with %d ammo.",gPlayerInfo[playerid][pName],gTeam[team],WeaponName[weapid],ammo);
	SendClientMessageToAll(COLOR_CYAN, string);
	return 1;
}

CMD:vl(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel]< 5) return accessdenied(playerid);
	if(GetPVarInt(playerid,"AdminDuty") == 0) return SendClientMessage(playerid, COLOR_ORANGE, "You need to be on duty to use this.");
	new Float:vx, Float:vy, Float:vz;
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ORANGE, "You're not in any vehicle!");
	if( sscanf( params, "fff", vx, vy, vz)) return SendUsage(playerid, "USAGE: /vl [X Y Z]");
	{
	    SetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);
	}
	return 1;
}

CMD:searchban(playerid, params[])
{
	if(!gPlayerInfo[playerid][pAlevel]) return accessdenied(playerid);
	new banned[26], Query[256];
	if(sscanf(params, "s[26]", banned)) return SendUsage(playerid, "USAGE: /searchban [name/IP]");
	mysql_real_escape_string(banned, banned);
    format(Query, 256, "SELECT * FROM `bans` WHERE `nick` LIKE '%s' OR `IP` LIKE '%s' ORDER BY `id` DESC LIMIT 5", banned, banned);
    mysql_query(Query);
    mysql_store_result();
    if(mysql_num_rows() > 0)
	{
	    new tmpreason[64], tmpbannedby[24], tmpnick[24], tmpip[18];
	    while(mysql_fetch_row(Query))
	    {
				mysql_fetch_string("nick", tmpnick);
				mysql_fetch_string("reason", tmpreason);
				mysql_fetch_string("bannedby", tmpbannedby);
				mysql_fetch_string("IP", tmpip);
				ssstring("- Name: %s || IP: %s || Banned by: %s || Reason: %s ", tmpnick, tmpip, tmpbannedby,tmpreason);
				SendClientMessage(playerid, COLOR_RED, ssstring);
		}
		AdminCommand(playerid, "SEARCHBAN");
	}
	else {
	    SendClientMessage(playerid, COLOR_RED, "No ban found under that IP/nick.");
	}
    mysql_free_result();
	return 1;
}

CMD:ep(playerid, params[])
{
	GivePlayerWeaponEx(playerid, 46,1);
	SendClientMessage(playerid, COLOR_YELLOW,"Emergency parachute spawned!");
	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	return 1;
}

CMD:flip(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
    if(GetPVarInt(playerid,"AdminDuty") == 0) return SendClientMessage(playerid, COLOR_ORANGE, "You need to be on duty to use this.");
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ORANGE, "You need to be in a car to use this.");
    new Float:z, vehicleid;
	vehicleid = GetPlayerVehicleID(playerid);
	GetVehicleZAngle(vehicleid,z);
	SetVehicleZAngle(vehicleid,z);
	RepairVehicle(vehicleid);
	SendClientMessage(playerid,COLOR_WHITE,"Vehicle flipped and repaired.");
	AdminCommand(playerid, "FLIP");
	return 1;
}

CMD:givecar(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 2) return accessdenied(playerid);
	new id, car[15], carid;
	if(sscanf(params,"us[15]",id,car)) return SendUsage(playerid, "USAGE: /givecar [ID] [model ID/name]");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, invalidplayer);
	if(IsNumeric(car))
	{
		if(strval(car) < 400 || strval(car) > 611) return SendClientMessage(playerid, COLOR_GRAY, "Invalid model.");
		carid = strval(car);
	}
	else
	{
        carid = GetVehicleModelIDFromName(car);
	}
	new Float:x, Float:y, Float:z, Float:angle, vw;
	new vehid;
	GetPlayerPos(id, x, y, z );
	GetPlayerFacingAngle(id, angle );
	vehid = CreateVehicle(carid, x, y + 3, z, angle, 0, 0, 200 );
	vw=GetPlayerVirtualWorld(id);
	SetVehicleVirtualWorld(vehid, vw);
	PutPlayerInVehicle(id,vehid,0);
	AdminCommand(playerid,"GIVECAR",id);
	return 1;
}

CMD:destroyallcars(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new string[90];
    for(new i = 0; i < 2000; i++)
	{
	    if(i>gVehs)
			DestroyVehicle(i);
	}
	String("Administrator %s has destroyed all spawned cars.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_WHITE, string);
	return 1;
}

CMD:setstreak(playerid, params[])
{
    if( gPlayerInfo[playerid][pAlevel] < 5 ) return accessdenied(playerid);
    new i, id;
    if(sscanf(params,"ud",id,i)) return SendUsage(playerid, "USAGE: /setstreak [ID] [streak]");
    KillingSpree[id] = i;
    if(i >= 20) {
        SetPVarInt(id, "RC",1);
        SendClientMessage(id, COLOR_YELLOW, "Press C to get an RC-XD.");
	}
	new string[100];
	String("Administrator %s set your kill streak to %i.",gPlayerInfo[playerid][pName],i);
	SendClientMessage(id,COLOR_YELLOW,string);
	AdminCommand(playerid, "SETSTREAK",id);
	return 1;
}
CMD:setspree(playerid, params[]) { return cmd_setstreak(playerid, params); }

CMD:dnd(playerid, params[])
{
	if(GetPVarInt(playerid, "DND") == 0)
	{
		SetPVarInt(playerid, "DND",1);
		SendClientMessage(playerid, COLOR_WHITE, "DND mode: enabled!");
	}
	else
	{
	    SetPVarInt(playerid, "DND", 0);
	    SendClientMessage(playerid, COLOR_WHITE, "DND mode: disabled!");
	}
	return 1;
}

CMD:settemplevel(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 5) return accessdenied(playerid);
    new id, level, string[80];
    if(sscanf(params,"ui",id,level)) return SendUsage(playerid, "USAGE: /settemplevel [ID] [level]");
    if(level > 4) return SendClientMessage(playerid, COLOR_ORANGE, "ERROR: Maximum temporary level is 4!");
    if(level > (gPlayerInfo[playerid][pAlevel])) return 0;
    if (gPlayerInfo[id][pAlevel] == level)
		return SendClientMessage(playerid, COLOR_ORANGE, "They already have that level!");
    gPlayerInfo[id][pTemplevel] = 1;
	gPlayerInfo[id][pOldlevel] = gPlayerInfo[id][pAlevel];
    gPlayerInfo[id][pAlevel] = level;
    String("Admin %s has set you as temporary admin level %i.",gPlayerInfo[playerid][pName],level);
    SendClientMessage(id, COLOR_CYAN, string);
    String("You set %s as temp level %i",gPlayerInfo[id][pName],level);
    SendClientMessage(playerid, COLOR_CYAN, string);
    AdminCommand(playerid, "SETTEMPLEVEL",id);
	return 1;
}

CMD:tune(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ORANGE, "You need to be in a tunable vehicle to use this.");
    new vehicleid = GetPlayerVehicleID(playerid), model = GetVehicleModel(vehicleid);
    switch(model)
	{
		case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
		return SendClientMessage(playerid,COLOR_ORANGE,"You can't tune this vehicle!");
	}
	AdminCommand(playerid, "TUNE");
	AddVehicleComponent(vehicleid, 1010);
	AddVehicleComponent(vehicleid, 1087);
	return 1;
}

CMD:carcolor(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
    new id, color1, color2, string[80];
    if(sscanf(params,"uii",id,color1,color2)) return SendUsage(playerid, "USAGE: /carcolor [player name/ID] [color1] [color2]");
	if(!IsPlayerInAnyVehicle(id)) return SendClientMessage(playerid, COLOR_ORANGE, "Player is not in any vehicle.");
	ChangeVehicleColor(GetPlayerVehicleID(id),color1,color2);
	String("You set %s's car's color to [%i] [%i]",gPlayerInfo[id][pName],color1,color2);
	SendClientMessage(playerid, COLOR_CYAN, string);
	AdminCommand(playerid, "CARCOLOR",id);
	return 1;
}

CMD:dcc(playerid, params[])
{
    if (!gPlayerInfo[playerid][pDonor]) return SendClientMessage(playerid, donordeny1);
    new color1, color2;
    if(sscanf(params,"ii",color1,color2)) return SendUsage(playerid, "USAGE: /dcc [color1] [color2]");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ORANGE, "You're not in a vehicle.");
	ChangeVehicleColor(GetPlayerVehicleID(playerid),color1,color2);
	DonorCommand(playerid, "CARCOLOR");
	return 1;
}

CMD:dcmds(playerid, params[])
{
	SendClientMessage(playerid, -1, "{FFFFFF}=> {D7DF01}Donator commands: {FFFFFF}<=");
	SendClientMessage(playerid, -1, "Donor rank 1 commands: /d /dcc, /heal(as any rank), /dhy, /dnos, /dsay, /dtune, /dweather");
	SendClientMessage(playerid, -1, "Donor rank 2 commands: /darmour, /dbike, /dplane, /dheli, /dskin, /boost");
	SendClientMessage(playerid, -1, "NOTICE: Please keep in mind that you have to be fair when using donor commands. Do not use donor commands to avoid death.");
	return 1;
}

CMD:dbike(playerid, params[])
{
    if(gPlayerInfo[playerid][pDonor] < 2) return SendClientMessage(playerid, donordeny2);
	if (gPlayerInfo[playerid][pSpawned] == 0)
		return SendClientMessage(playerid, COLOR_RED, "You must be spawned to spawn a vehicle.");
	new Float:x, Float:y, Float:z, Float:angle, interior = GetPlayerInterior(playerid), vw = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle( playerid, angle );
	if( gPlayerInfo[playerid][pVeh] != -1 ) DestroyVehicle(gPlayerInfo[playerid][pVeh]);
	gPlayerInfo[playerid][pVeh] = CreateVehicle(522, x, y + 3, z, angle, -1, -1, 200 );
	LinkVehicleToInterior(gPlayerInfo[playerid][pVeh], interior);
	SetVehicleVirtualWorld(gPlayerInfo[playerid][pVeh], vw);
	PutPlayerInVehicle(playerid,gPlayerInfo[playerid][pVeh],0);
	DonorCommand(playerid, "DBIKE");
	return 1;
}

CMD:dplane(playerid, params[])
{
    if(gPlayerInfo[playerid][pDonor]< 2) return SendClientMessage(playerid, donordeny2);
	if (gPlayerInfo[playerid][pSpawned] == 0)
		return SendClientMessage(playerid, COLOR_RED, "You must be spawned to spawn a vehicle.");
	new Float:x, Float:y, Float:z, Float:angle, interior = GetPlayerInterior(playerid), vw = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle( playerid, angle);
	if(gPlayerInfo[playerid][pVeh] != -1) DestroyVehicle(gPlayerInfo[playerid][pVeh]);
	gPlayerInfo[playerid][pVeh] = CreateVehicle(513, x, y + 3, z, angle, -1, -1, 200);
	LinkVehicleToInterior(gPlayerInfo[playerid][pVeh], interior);
	SetVehicleVirtualWorld(gPlayerInfo[playerid][pVeh], vw);
	PutPlayerInVehicle(playerid,gPlayerInfo[playerid][pVeh],0);
	DonorCommand(playerid, "DPLANE");
	return 1;
}

CMD:dheli(playerid, params[])
{
    if( gPlayerInfo[playerid][pDonor]< 2) return SendClientMessage(playerid, donordeny2);
	if (gPlayerInfo[playerid][pSpawned] == 0)
		return SendClientMessage(playerid, COLOR_RED, "You must be spawned to spawn a vehicle.");
	new Float:x, Float:y, Float:z, Float:angle, interior = GetPlayerInterior(playerid), vw = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle( playerid, angle);
	if( gPlayerInfo[playerid][pVeh] != -1 ) DestroyVehicle(gPlayerInfo[playerid][pVeh]);
	gPlayerInfo[playerid][pVeh] = CreateVehicle(487, x, y + 3, z, angle, -1, -1, 200);
	LinkVehicleToInterior(gPlayerInfo[playerid][pVeh], interior);
	SetVehicleVirtualWorld(gPlayerInfo[playerid][pVeh], vw);
	PutPlayerInVehicle(playerid,gPlayerInfo[playerid][pVeh],0);
	DonorCommand(playerid, "DHELI");
	return 1;
}

CMD:dcar(playerid, params[])
{
    if(gPlayerInfo[playerid][pDonor] < 2 ) return SendClientMessage(playerid, donordeny2);
	if (gPlayerInfo[playerid][pSpawned] == 0)
		return SendClientMessage(playerid, COLOR_RED, "You must be spawned to spawn a vehicle.");
	new Float:x, Float:y, Float:z, Float:angle, interior = GetPlayerInterior(playerid), vw = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle( playerid, angle);
	if(gPlayerInfo[playerid][pVeh] != -1) DestroyVehicle(gPlayerInfo[playerid][pVeh]);
	gPlayerInfo[playerid][pVeh] = CreateVehicle(541, x, y + 3, z, angle, -1, -1, 200);
	LinkVehicleToInterior(gPlayerInfo[playerid][pVeh], interior);
	SetVehicleVirtualWorld(gPlayerInfo[playerid][pVeh], vw);
	PutPlayerInVehicle(playerid,gPlayerInfo[playerid][pVeh],0);
	DonorCommand( playerid, "DCAR");
	return 1;
}

GetVehicleModelIDFromName(vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if ( strfind(VehicleNames[i], vname, true) != -1 )
			return i + 400;
	}
	return -1;
}

stock IsNumeric(string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

CMD:adminarea(playerid, params[])
{
    if( gPlayerInfo[playerid][pAlevel] < 1 ) return accessdenied(playerid);
	SetPlayerPos(playerid, -1465.268676,1557.868286,1052.531250);
	SetPlayerInterior(playerid, 14);
	AdminCommand(playerid, "AdminArea");
	return 1;
}

CMD:v(playerid, params[])
{
    if( gPlayerInfo[playerid][pAlevel] < 2) return accessdenied(playerid);
	new model[50];
	if(sscanf(params, "s[50]", model)) return SendUsage(playerid, "USAGE: /v [model name/ID]" );
	new veh = GetVehicleModelIDFromName(model);
	new Float:x, Float:y, Float:z, Float:angle, interior = GetPlayerInterior(playerid), vw = GetPlayerVirtualWorld(playerid);
	if(veh < 400 || veh > 611) return SendClientMessage(playerid, COLOR_RED, "Invalid vehicle name!");
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, angle);
	if(gPlayerInfo[playerid][pVeh] != -1) DestroyVehicle(gPlayerInfo[playerid][pVeh]);
	gPlayerInfo[playerid][pVeh] = CreateVehicle(veh, x, y + 3, z, angle, -1, -1, 200);
	SetVehHealth(gPlayerInfo[playerid][pVeh]);
	LinkVehicleToInterior(gPlayerInfo[playerid][pVeh], interior);
	SetVehicleVirtualWorld(gPlayerInfo[playerid][pVeh], vw);
	PutPlayerInVehicle(playerid,gPlayerInfo[playerid][pVeh],0);
	AdminCommand(playerid, "V");
	return 1;
}

CMD:restartmsg(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 5 ) return accessdenied(playerid);
	GameTextForAll("~g~Message from developers:~n~~r~Server Restart!",3000,1);
	SendClientMessageToAll(COLOR_RED, "Server restarting within a minute!");
	SendClientMessageToAll(COLOR_RED, "Please totally exit your client before rejoining to ensure that you properly are able to join back.");
	return 1;
}

CMD:spec(playerid, params[])
{
	if (!gPlayerInfo[playerid][pOp] && !gPlayerInfo[playerid][pAlevel])
	    return accessdenied(playerid);
    new id;
    if( sscanf( params, "u", id ) )
		return SendUsage(playerid, "USAGE: /spec [ID]");
	if( !IsPlayerConnected( id ) )
		return SendClientMessage(playerid, invalidplayer);
    if (GetPVarType(playerid,"CappingZone")!=PLAYER_VARTYPE_NONE) InterruptCap(playerid);
    TogglePlayerSpectating(playerid, 1);
	if( !IsPlayerInAnyVehicle(id))
		PlayerSpectatePlayer( playerid, id, SPECTATE_MODE_NORMAL);
	else
		PlayerSpectateVehicle( playerid, GetPlayerVehicleID(id));
	TextDrawHideForPlayer(playerid, txtStats[playerid]);
	new string[140],PlayerStats[150],Float:ar,Float:hp;
	GetPlayerHealth(id,hp);
	GetPlayerArmour(id,ar);
	new inte,ww;
	inte = GetPlayerInterior( id );
	ww = GetPlayerVirtualWorld( id );
	SetPlayerInterior( playerid, inte );
	SetPlayerVirtualWorld( playerid, ww );
	SetPVarInt( playerid, "Spec", 1 );
	SetPVarInt( playerid, "CurrentID", id );
	format(PlayerStats,sizeof(string),"~n~~n~~n~ ~w~%s - id:%d~n~hp:%0.1f ar:%0.1f~n~$%d ($%d) score:%i",
	gPlayerInfo[id][pName],id,hp,ar,gPlayerInfo[id][pMoney],GetPlayerMoney(id),gPlayerInfo[id][pScore]);
	GameTextForPlayer(playerid,PlayerStats,25000,4);
	String("[INFO] %s used SPEC on %s[%d]. ", gPlayerInfo[playerid][pName],gPlayerInfo[id][pName], id );
	foreach(Player, i)
	{
		if( gPlayerInfo[i][pAlevel] >= 1)
		    SendClientMessage(i, COLOR_BLUE, string);
		else if(gPlayerInfo[i][pOp] == 1)
			SendClientMessage(i, COLOR_BLUE, string);
	}
	return 1;
}
CMD:sp(playerid, params[]) return cmd_spec( playerid, params );
CMD:lsp(playerid, params[]) return cmd_spec( playerid, params );

CMD:sspec(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]<6)
	    return SendClientMessage(playerid,-1,"SERVER: Unknown command. Use /cmds to view all available commands.");
    new id;
    if(sscanf(params, "u", id))
		return SendUsage(playerid, "USAGE: /sspec [ID]");
	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, invalidplayer);
    if (GetPVarType(playerid,"CappingZone")!=PLAYER_VARTYPE_NONE) InterruptCap(playerid);
    TogglePlayerSpectating( playerid, 1 );
	if(!IsPlayerInAnyVehicle(id))
		PlayerSpectatePlayer(playerid, id, SPECTATE_MODE_NORMAL);
	else
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(id) );
	TextDrawHideForPlayer(playerid, txtStats[playerid]);
	new PlayerStats[150],Float:ar,Float:hp;
	GetPlayerHealth(id,hp);
	GetPlayerArmour(id,ar);
	new inte,ww;
	inte = GetPlayerInterior(id);
	ww = GetPlayerVirtualWorld(id);
	SetPlayerInterior(playerid, inte);
	SetPlayerVirtualWorld(playerid, ww);
	SetPVarInt(playerid, "Spec", 1);
	SetPVarInt(playerid, "CurrentID", id );
	format(PlayerStats,sizeof(PlayerStats),"~n~~n~~n~ ~w~%s - id:%d~n~hp:%0.1f ar:%0.1f~n~$%d ($%d) score:%i",
	gPlayerInfo[id][pName],id,hp,ar,gPlayerInfo[id][pMoney],GetPlayerMoney(id),gPlayerInfo[id][pScore]);
	GameTextForPlayer(playerid,PlayerStats,25000,4);
	return 1;
}

CMD:specoff(playerid, params[])
{
	if(gPlayerInfo[playerid][pOp] == 1 || gPlayerInfo[playerid][pAlevel]> 0)
	{
	    TogglePlayerSpectating( playerid, 0 );
	    SetPVarInt( playerid, "Spec", 0 );
	    SetPVarInt( playerid, "CurrentID", -1 );
	    GameTextForPlayer(playerid, "a",1,3);
	    return 1;
	}
	else return accessdenied(playerid);
}
CMD:ss(playerid, params[]) return cmd_specoff(playerid,params);
CMD:stopspec(playerid, params[]) return cmd_specoff(playerid,params);

CMD:givemoney(playerid, params[])
{
	new id,ammount, string[128];
    if(sscanf( params, "ud", id, ammount ) ) return SendUsage(playerid, "USAGE: /gm [ID] [amount]" );
	if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID )return SendClientMessage(playerid, invalidplayer);
	if( playerid == id ) return SendClientMessage(playerid,COLOR_GRAY,"You cannot send money to yourself!");
	if(ammount <= 0) return SendClientMessage(playerid, COLOR_GRAY, "Invalid ammount!");
	if(ammount > 100000) return SendClientMessage(playerid, COLOR_GRAY, "You can only send max $100,000 at once!");
	if(ammount > gPlayerInfo[playerid][pMoney]) return SendClientMessage(playerid, COLOR_GRAY, "You cannot send more then you have!");
	GivePlayerMoneySync(playerid, -ammount);
	GivePlayerMoneySync(id, ammount);
	String("You have sent $%d to %s(%d)",ammount,gPlayerInfo[id][pName],id);
	SendClientMessage(playerid,COLOR_GREEN, string);
	String("%s(%d) has sent you $%d!",gPlayerInfo[playerid][pName],playerid,ammount);
	SendClientMessage( id,COLOR_GREEN, string );
	PlayerPlaySound(id,1085,0.0,0.0,0.0);
	if(ammount > 5000)
	{
		foreach(Player, i)
		{
			if( gPlayerInfo[i][pAlevel] > 0 )
			{
				String("%s(%d) has sent $%d to %s(%d).",gPlayerInfo[playerid][pName],playerid,ammount,gPlayerInfo[id][pName],id);
				SendClientMessage(i, COLOR_GRAY, string);
				print(string);
			}
		}
	}
	return 1;
}
CMD:gm(playerid, params[]) { return cmd_givemoney(playerid,params); }

CMD:agivemoney(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel]< 3) return accessdenied(playerid);
	new id,ammount, string[128];
    if(sscanf(params, "ud", id, ammount)) return SendUsage(playerid, "USAGE: /givemoney [ID] [amount]" );
	if(!IsPlayerConnected( id ) || id == INVALID_PLAYER_ID )return SendClientMessage(playerid, invalidplayer);
	if(ammount <= 0) return SendClientMessage(playerid, COLOR_GRAY, "Invalid amount!");
	if(ammount > 100000 && gPlayerInfo[playerid][pAlevel]< 6) return SendClientMessage(playerid, COLOR_GRAY, "You can only send max $100,000 at once!");
	GivePlayerMoneySync(id, ammount);
	String("You have sent $%d to %s(%d)",ammount,gPlayerInfo[id][pName],id);
	SendClientMessage( playerid,COLOR_GREEN, string );
	String("Administrator %s(%d) has sent you $%d!",gPlayerInfo[playerid][pName],playerid,ammount);
	SendClientMessage( id,COLOR_GREEN, string );
	PlayerPlaySound(id,1085,0.0,0.0,0.0);
	if(ammount > 10000)
	{
		foreach(Player, i)
		{
			if(gPlayerInfo[i][pAlevel] > 1)
			{
				String("Administrator %s(%d) has given $%d to %s(%d).",gPlayerInfo[playerid][pName],playerid,ammount,gPlayerInfo[id][pName],id);
				SendClientMessage(i, COLOR_GRAY, string);
			}
		}
	}
	AdminCommand(playerid,"AGIVEMONEY",id);
	return 1;
}

CMD:pm(playerid, params[])
{
	new id, msg[128];
    if(sscanf( params, "us[128]", id, msg ) )
	    return SendUsage(playerid, "USAGE: /pm [ID] [message]");
	if(!IsPlayerConnected( id ) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	if(Muted [playerid])
	    return SendClientMessage(playerid, muted);
	if( playerid == id)
		return SendClientMessage(playerid,COLOR_GRAY,"You cannot PM yourself.");
    if(Blocked[ playerid ] == 1)
	  	return SendClientMessage(playerid, COLOR_RED, "The player you are trying to private message has blocked you.");
	if(GetPVarInt(id,"DND") == 1) {
	    SendClientMessage(playerid, COLOR_GRAY, "This user is in do not disturb mode!");
		return 1;
 }
 	new string[128];
	String("PM to %s[%d]: %s",gPlayerInfo[id][pName], id, msg);
	SendClientMessage(playerid,COLOR_YELLOW, string);
	String("PM from %s[%d]: %s",gPlayerInfo[playerid][pName], playerid, msg);
	SendClientMessage( id,COLOR_YELLOW, string );
	PlayerPlaySound(id,1085,0.0,0.0,0.0);
	lastpmed[id] = playerid;
	String("PM from %s[%d] to %s[%d]: %s",gPlayerInfo[playerid][pName],playerid,gPlayerInfo[id][pName],id,msg);
	print(string);
	if(gPlayerInfo[id][pAlevel] == 0 && gPlayerInfo[playerid][pAlevel] == 0 || Undercover[playerid] == 1)
		foreach(Player, i) if(gPlayerInfo[i][pAlevel] > 0) SendClientMessage(i, COLOR_GRAY, string);
	if(gPlayerInfo[id][pAlevel] > 1 || gPlayerInfo[playerid][pAlevel] > 1)
		foreach(Player, i) if(gPlayerInfo[i][pAlevel] >= 6 && id!=i && playerid!=i) SendClientMessage(i, COLOR_GRAY, string);
	return 1;
}

CMD:apm(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] < 1) return accessdenied(playerid);
	new id, msg[128];
    if( sscanf(params, "us[128]", id, msg))
	    return SendUsage(playerid, "USAGE: /apm [ID] [message]");
	if( !IsPlayerConnected(id) || id == INVALID_PLAYER_ID )
	    return SendClientMessage(playerid, invalidplayer);
	if(playerid == id)
		return SendClientMessage(playerid, COLOR_GRAY, "You cannot PM yourself.");
 	new sendername[24], receivername[24], string[128];
	GetPlayerName(playerid, sendername, 24);
	GetPlayerName(id, receivername, 24);
	format(string, sizeof string, "PM to %s[%d]: %s", receivername, id, msg);
	SendClientMessage(playerid,COLOR_YELLOW, string );
	format(string, sizeof string, "PM from Admin %s[%d]: %s", sendername, playerid, msg);
	SendClientMessage(id,COLOR_RED, string );
	PlayerPlaySound(id,1085,0.0,0.0,0.0);
	lastpmed[id] = playerid;
	printf("APM from %s[%d] to %s[%d]: %s", sendername, playerid, receivername, id, msg);
	String("APM from %s[%d] to %s[%d]: %s", sendername, playerid, receivername, id, msg);
	foreach(Player, i) if(gPlayerInfo[i][pAlevel] > 6 && id!=i && playerid!=i) SendClientMessage(i, COLOR_GRAY, string);
	return 1;
}

CMD:rpm(playerid, params[])
{
	new msg[128], pm[128];
	if(sscanf(params, "s[128]", msg))
	    return SendUsage(playerid, "USAGE: /rpm [message]");
	if(Muted [playerid ])
	    return SendClientMessage(playerid, muted);
	if(Blocked[playerid] == 1)
	  	return SendClientMessage(playerid, COLOR_RED, "The player you are trying to private message has blocked you.");
	if(lastpmed[playerid] == -1)
		return SendClientMessage(playerid, COLOR_RED, "You have not received any private messages yet!");
	lastpmed[lastpmed[playerid]] = playerid;
	format(pm, sizeof pm, "PM to %s[%d]: %s",gPlayerInfo[lastpmed[playerid]][pName],lastpmed[playerid],msg);
	SendClientMessage( playerid,COLOR_YELLOW, pm);
	format(pm, sizeof pm, "PM from %s[%d]: %s",gPlayerInfo[playerid][pName],playerid,msg);
	SendClientMessage(lastpmed[playerid], COLOR_YELLOW, pm);
	format(pm, sizeof pm, "PM from %s[%d] to %s[%d]: %s",gPlayerInfo[playerid][pName],playerid,gPlayerInfo[lastpmed[playerid]][pName],lastpmed[playerid],msg);
	if(gPlayerInfo[lastpmed[playerid]][pAlevel] == 0 && gPlayerInfo[playerid][pAlevel] == 0)
		foreach(Player, i) if(gPlayerInfo[i][pAlevel] > 1) SendClientMessage(i, COLOR_GRAY, pm);
	if(gPlayerInfo[lastpmed[playerid]][pAlevel] > 1 || gPlayerInfo[playerid][pAlevel] > 1)
		foreach(Player, i) if(gPlayerInfo[i][pAlevel] >= 6 && lastpmed[playerid]!=i && playerid!=i) SendClientMessage(i, COLOR_GRAY, pm);
	return 1;
}

stock SendMessageInArea(Float:radi, string[], Float:PosX, Float:PosY, Float:PosZ, color)
{
	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, radi, PosX, PosY, PosZ))
		{
		    SendClientMessage(i, color, string);
		}
	}
	return 1;
}

COMMAND:l(playerid, params[])
{
    new message[128], string[128];
    if(sscanf(params, "s[128]", message))
	    return SendUsage(playerid, "USAGE: /l [message]");
	if(Muted[playerid])
		return SendClientMessage(playerid, muted);
	else
	{
	    String("(LOCAL (%d)%s: %s)",playerid,gPlayerInfo[playerid][pName],message);
	    new Float:x, Float:y, Float:z;
	    GetPlayerPos(playerid, x, y, z);
	    SendMessageInArea(15.0, string, x, y, z, COLOR_LIGHTGRAY);
	}
	String("[ADMIN] local chat: %s[%d]: %s",gPlayerInfo[playerid][pName],playerid,message);
	SendMessageToAdminsOnD(COLOR_GRAY, string);
	return 1;
}
CMD:local(playerid, params[]) { return cmd_l(playerid,params); }

CMD:changepassword(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_CHANGEPASS, DIALOG_STYLE_PASSWORD , "Change password", "Please enter your desired NEW password.", "OK", "Cancel");
	return 1;
}
CMD:changepass(playerid, params[]) { return cmd_changepassword(playerid,params); }

CMD:weaps(playerid, params[])
{
    if (!gPlayerInfo[playerid][pAlevel] && !gPlayerInfo[playerid][pOp])
        return accessdenied(playerid);
    if(isnull(params)) return SendUsage(playerid, "USAGE: /weaps [name/ID]");
	new id,string[128],slot,weap,ammo,count;
	id=strval(params);
 	if (!IsPlayerConnected(id))  return SendClientMessage(playerid, invalidplayer);
	String("%s's[%d] weapons:",gPlayerInfo[id][pName],id);
	SendClientMessage(playerid,COLOR_YELLOW,string);
    string[0]='\0';
	for (slot=0;slot<14;slot++)
	{
		GetPlayerWeaponData(id,slot,weap,ammo);
		if (!weap) continue;
		count++;
		if (strlen(string)+strlen(WeaponName[weap])+10>128)
		{
		    SendClientMessage(playerid,COLOR_YELLOW,string);
		    string[0]='\0';
		}
		if (string[0]=='\0') String("%s(%i)",WeaponName[weap],ammo);
 	    else String("%s, %s(%i)",string,WeaponName[weap],ammo);
	}
	if (string[0]!='\0') SendClientMessage(playerid,COLOR_YELLOW,string);
	if (!count) SendClientMessage(playerid,COLOR_YELLOW,"(player has no weapons)");
	return 1;
}

CMD:clearchat(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1 )
	    return accessdenied(playerid);
	new lines;
	for(new i = 0; i < 20; i++ )
	if(sscanf(params, "d", lines))
	    return SendClientMessageToAll(COLOR_WHITE, " ");
	if(lines > 50)
	    return SendClientMessage(playerid, COLOR_GRAY, "You can clear up to 50 lines!");
	for(new i = 0; i < lines; i++ ) SendClientMessageToAll(COLOR_WHITE, " ");
	AdminCommand(playerid, "CLEARCHAT");
	return 1;
}

CMD:adminduty(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	new string[128];
	if(GetPVarInt(playerid, "AdminDuty") == 1)
	{
		SetPVarInt(playerid, "AdminDuty", 0);
        gPlayerInfo[playerid][pDeaths]--;
        String("Administrator %s is now off admin duty.",gPlayerInfo[playerid][pName]);
        SendClientMessageToAll( COLOR_PINK, string );
		return SetPlayerHealth(playerid, 0.0);
	}
	else if(GetPVarInt(playerid, "AdminDuty") == 0)
	{
	    String("Administrator %s is now on admin duty.",gPlayerInfo[playerid][pName]);
	    SendClientMessageToAll(COLOR_PINK, string);
		SetPVarInt(playerid, "AdminDuty", 1);
		ADutyFunctions(playerid);
		return 1;
	}
	return 1;
}
CMD:aduty(playerid, params[]) { return cmd_adminduty(playerid,params); }

CMD:giveweapon(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 3)
	    return accessdenied(playerid);
	new id,weap[28],weapammo;
	if (sscanf(params,"us[28]d",id,weap,weapammo))
	    return SendUsage(playerid, "USAGE: /giveweapon [ID] [weapon name] [ammo]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (weapammo>10000 || weapammo<1 && gPlayerInfo[playerid][pAlevel]< 6) return SendClientMessage(playerid, COLOR_RED, "Ammo amount must be between 0 and 10000.");
	new weapid=GetWeaponIDFromName(weap);
	if (weapid==-1) return SendClientMessage(playerid, invalidweapon);
	if (weapid==WEAPON_MINIGUN) return SendClientMessage(playerid,COLOR_ORANGE,"You cannot give players miniguns!");
	new curweap;
    if (IsPlayerInAnyVehicle(id))
    {
	    curweap=GetPlayerWeapon(id);
	    GivePlayerWeaponEx(id,weapid,weapammo);
	    if (weapid==WEAPON_DEAGLE || weapid==WEAPON_SHOTGSPA || weapid==WEAPON_SNIPER) SetPlayerArmedWeapon(id,curweap);
	}
	else GivePlayerWeaponEx(id,weapid,weapammo);
	new string[128];
	String("Administrator %s gave you a %s with %d ammo!",gPlayerInfo[playerid][pName],WeaponName[weapid],weapammo);
	SendClientMessage(id,COLOR_YELLOW,string);
	String("You gave %s a %s with %d ammo!",gPlayerInfo[id][pName],WeaponName[weapid],weapammo);
	SendClientMessage(playerid, COLOR_YELLOW, string);
	AdminCommand(playerid, "GIVEWEAPON",id);
	return 1;
}

CMD:clanwar(playerid, params[])
{
	if(gPlayerInfo[ playerid ][pAlevel ] < 4) return accessdenied(playerid);
    new clan[8], clan2[8], wid;
	if(sscanf( params, "s[8]s[8]d", clan, clan2, wid)) return SendUsage(playerid, "USAGE: /clanwar [clan 1] [clan 2] [world ID]");
	foreach(Player, j)
	{
	    if(gPlayerInfo[j][wontteleport] == 0)
	    {
			if(strfind(gPlayerInfo[j][pName], clan, true) != -1)
			{
			    if(gPlayerInfo[j][pClass]==CLASS_SNIPER)
			    {
			        gPlayerInfo[j][pClass] = CLASS_ASSAULT;
				}
				SetPlayerSkin(j, 53);
				SetPlayerColor(j, 0x556b2fFF);
				SetPlayerTeam(j, 32);
			    SetPlayerInterior(j, 10);
			    SetPVarInt(j, "NoAB", 4);
			    SetPlayerPos(j,-1131.6139,1057.8584,1346.4156);
				SetPlayerVirtualWorld(j, wid);
				TogglePlayerControllable(j, 0);
				ResetPlayerWeaponsEx(j);
				SetPlayerHealth(j, 99);
				SetPlayerArmour(j, 99);
				GivePlayerWeaponEx(j, 24, 9999);
				GivePlayerWeaponEx(j, 27, 9999);
				GivePlayerWeaponEx(j, 31, 9999);
				gPlayerInfo[j][clanwarstarted] = 1;
				SendClientMessage(j, COLOR_GRAY, "An administrator has teleported your clan for a clan war/TCW");
			}
			if(strfind(gPlayerInfo[j][pName], clan2, true) != -1)
			{
			    if(gPlayerInfo[j][pClass]==CLASS_SNIPER)
			    {
			        gPlayerInfo[j][pClass] = CLASS_ASSAULT;
				}
				SetPlayerColor(j, 0x009ec5FF);
				SetPlayerTeam(j, 35);
				SetPlayerSkin(j, 210);
			    SetPlayerInterior(j, 10);
			    SetPVarInt(j, "NoAB", 4);
				SetPlayerPos(j,-974.8134,1061.3942,1345.6757);
				SetPlayerVirtualWorld(j, wid);
				TogglePlayerControllable(j, 0);
				ResetPlayerWeaponsEx(j);
				SetPlayerHealth(j, 99);
				SetPlayerArmour(j, 99);
				GivePlayerWeaponEx(j, 24, 9999);
				GivePlayerWeaponEx(j, 27, 9999);
				GivePlayerWeaponEx(j, 31, 9999);
				gPlayerInfo[j][clanwarstarted] = 1;
				SendClientMessage(j, COLOR_GRAY, "An administrator has teleported your clan for a clan war/TCW.");
			}
		}
	}
	ssstring("Administrator %s has teleported %s and %s for a clan war/TCW.", gPlayerInfo[playerid][pName], clan, clan2);
	SendClientMessageToAll(COLOR_YELLOW, ssstring);
	AdminCommand(playerid, "CLANWAR");
	return 1;
}

CMD:wonttele(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new target;
	if( sscanf( params, "u", target)) return SendUsage(playerid, "USAGE: /wonttele [ID]");
    gPlayerInfo[ target ][wontteleport] = 1;
    ssstring("ID [%d]%s. will not play in the upcoming TCW.", target, gPlayerInfo[target][pName]);
	SendClientMessage( playerid, COLOR_ORANGE, ssstring);
	SendClientMessage(target, COLOR_ORANGE, "You won't play in your clan's upcoming TCW/clanwar.");
	AdminCommand(playerid, "WONTTELE", target);
	return 1;
}

CMD:unwonttele(playerid, params[])
{
    if(gPlayerInfo[ playerid ][pAlevel ] < 4) return accessdenied(playerid);
	new target;
	if( sscanf( params, "u", target)) return SendUsage(playerid, "USAGE: /unwonttele [ID]");
    gPlayerInfo[ target ][wontteleport] = 0;
    ssstring("ID [%d]%s. has been removed from the non-teleport list and is now able to play a TCW with his clan!", target, gPlayerInfo[target][pName]);
	SendClientMessage( playerid, COLOR_ORANGE, ssstring);
	SendClientMessage(target, COLOR_ORANGE, "You are now able to play in your clans TCW.");
	AdminCommand(playerid, "UNWONTTELE", target);
	return 1;
}

CMD:areafreeze(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, 30.0, Pos[0], Pos[1], Pos[2]))
		{
		    SetPVarInt(i,"Frozen",1);
	        TogglePlayerControllable(i, false);
			ssstring("Administrator %s has frozen everyone within their vicinity.", gPlayerInfo[playerid][pName]);
			SendClientMessage(i, COLOR_YELLOW, ssstring);
		}
	}
	AdminCommand(playerid, "AREAFREEZE");
	return 1;
}

CMD:areaunfreeze(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, 30.0, Pos[0], Pos[1], Pos[2]))
		{
		    SetPVarInt(i,"Frozen",0);
	        TogglePlayerControllable(i, true);
			ssstring("Administrator %s has unfrozen everyone within their vicinity.", gPlayerInfo[playerid][pName]);
			SendClientMessage(i, COLOR_YELLOW, ssstring);
		}
	}
	AdminCommand(playerid, "AREAUNFREEZE");
	return 1;
}

CMD:areadisarm(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, 30.0, Pos[0], Pos[1], Pos[2]))
		{
		    ResetPlayerWeaponsEx(i);
			ssstring("Administrator %s has disarmed everyone within their vicinity.", gPlayerInfo[playerid][pName]);
			SendClientMessage(i, COLOR_YELLOW, ssstring);
		}
	}
	AdminCommand(playerid, "AREADISARM");
	return 1;
}

CMD:areaheal(playerid, params[])
{
	if(gPlayerInfo[ playerid][ pAlevel] < 4) return accessdenied(playerid);
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	foreach(Player, i)
	{
		if(IsPlayerInRangeOfPoint(i, 30.0, Pos[0], Pos[1], Pos[2]))
		{
		    SetPlayerHealth(i, 99);
			ssstring("Administrator %s has healed everyone within their vicinity.", gPlayerInfo[playerid][pName]);
			SendClientMessage(i, COLOR_YELLOW, ssstring);
		}
	}
	AdminCommand(playerid, "AREAHEAL");
	return 1;
}

CMD:areaarmour(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4) return accessdenied(playerid);
	new Float:Pos[3];
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	foreach(Player, i)
	if(IsPlayerInRangeOfPoint(i, 30.0, Pos[0], Pos[1], Pos[2]))
	{
	    SetPlayerArmour(i, 99);
		ssstring("Administrator %s has armoured everyone within their vicinity.", gPlayerInfo[ playerid ][pName]);
		SendClientMessage(i, COLOR_YELLOW, ssstring);
	}
	AdminCommand(playerid, "AREAARMOUR");
	return 1;
}
CMD:areaarmor(playerid, params[]) { return cmd_areaarmour(playerid,params); }

CMD:areagiveweapon(playerid, params[])
{
	if (gPlayerInfo[ playerid ][ pAlevel ] < 4) return accessdenied(playerid);
	new weap[25], weapammo, weapid, Float:Pos[3];
	if( sscanf(params,"s[25]d",weap, weapammo)) return SendClientMessage(playerid, COLOR_GRAY, "USAEG: /areagiveweapon [weapon name] [ammo]");
	weapid = GetWeaponIDFromName(weap);
	if(weapid==-1) return SendClientMessage(playerid, invalidweapon);
	if(weapid==WEAPON_MINIGUN) return SendClientMessage(playerid, COLOR_ORANGE, "You cannot give players miniguns!");
	if (weapammo>10000 || weapammo<1 && gPlayerInfo[playerid][pAlevel]< 6) return SendClientMessage(playerid, COLOR_RED, "Ammo amount must be between 0 and 10000.");
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
	foreach(Player, i)
	{
	   	if(IsPlayerConnected(i) && IsPlayerInRangeOfPoint(i, 30.0, Pos[0], Pos[1], Pos[2]))
		{
	    	new string[128];
			String("Administrator %s has given everyone in his radious a %s with %d ammo! ",gPlayerInfo[playerid][pName],WeaponName[weapid],weapammo );
			SendClientMessage(i, COLOR_YELLOW,string);
	   		GivePlayerWeaponEx(i, weapid, weapammo);
			PlayerPlaySound(i,1057,0.0,0.0,0.0);
		}
	}
	AdminCommand(playerid,"AREAGIVEWEAPON");
	return 1;
}
		
CMD:giveallweapon(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 4)
	    return accessdenied(playerid);
	new weap[25],weapammo,weapid;
	if (sscanf(params,"s[25]d",weap,weapammo))
	    return SendUsage(playerid, "USAGE: /giveallweapon [weapon name] [ammo]");
	weapid=GetWeaponIDFromName(weap);
	if (weapid==-1) return SendClientMessage(playerid, invalidweapon);
	if (weapid==WEAPON_MINIGUN) return SendClientMessage(playerid, COLOR_ORANGE, "You cannot give players miniguns!");
	if (weapammo>10000 || weapammo<1 && gPlayerInfo[playerid][pAlevel]< 6) return SendClientMessage(playerid, COLOR_RED, "Ammo amount must be between 0 and 10000.");
	new curweap;
	foreach(Player, i)
	{
	    if (IsPlayerInAnyVehicle(i))
	    {
		    curweap=GetPlayerWeapon(i);
		    GivePlayerWeaponEx(i,weapid,weapammo);
		    if (weapid==WEAPON_DEAGLE || weapid==WEAPON_SHOTGSPA || weapid==WEAPON_SNIPER) SetPlayerArmedWeapon(i,curweap);
		}
		else GivePlayerWeaponEx(i,weapid,weapammo);
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
	}
	new string[128];
	String("Administrator %s has given everyone a %s with %d ammo! ",gPlayerInfo[playerid][pName],WeaponName[weapid],weapammo );
	SendClientMessageToAll(COLOR_YELLOW,string);
	return 1;
}

CMD:async(playerid, params[])
{
	if(gPlayerInfo[ playerid ][ pAlevel ] < 3) return accessdenied(playerid);
	new syncedid;
	if( sscanf( params, "u", syncedid)) return SendClientMessage(playerid, COLOR_GRAY, "/async [ID]");
	if(!IsPlayerConnected(syncedid)) return SendClientMessage(playerid, invalidplayer);
	if(GetPVarInt( syncedid, "Frozen" ) == 1 ) return SendClientMessage(playerid, COLOR_ORANGE, "You can't sync a frozen player.");
    gSyncInfo[syncedid][sync] = true;
	GetPlayerPos(syncedid, gSyncInfo[syncedid][sx], gSyncInfo[syncedid][sy], gSyncInfo[syncedid][sz]);
	GetPlayerHealth(syncedid, gSyncInfo[syncedid][shealth]);
	GetPlayerArmour(syncedid, gSyncInfo[syncedid][shealth]);
	gSyncInfo[syncedid][sint] = GetPlayerInterior(syncedid);
	gSyncInfo[playerid][svw] = GetPlayerVirtualWorld(syncedid);
	new sskin = GetPlayerSkin(syncedid);
	SetPlayerSkin(syncedid, sskin);
	for (new i = 0; i < 13; i++) GetPlayerWeaponData(playerid, i, syncwep[i][0], syncwep[i][1]);
	SetPVarInt(syncedid, "NoAB", 4);
	SpawnPlayer(syncedid);
	ssstring("Administrator %s has synced you.", gPlayerInfo[ playerid ][pName]);
	SendClientMessage(syncedid, COLOR_GREEN, ssstring);
	AdminCommand(playerid, "ASYNC", syncedid);
	return 1;
}

CMD:sync(playerid, params[])
{
	if(GetPVarInt(playerid, "Spec") == 1) return SendClientMessage(playerid,COLOR_ORANGE,"You can't sync yourself while in spec mode!");
	if(GetTickCount() - GetPVarInt(playerid, "synccount") < (60 * 1000)) return SendClientMessage(playerid, COLOR_RED, "You can sync yourself once per minute!");
    if(GetPVarInt( playerid, "Frozen" ) == 1 ) return SendClientMessage(playerid, -1, "You can't sync yourself while you're frozen.");
	gSyncInfo[playerid][sync] = true;
	SetPVarInt(playerid, "synccount", GetTickCount());
	GetPlayerPos(playerid, gSyncInfo[playerid][sx], gSyncInfo[playerid][sy], gSyncInfo[playerid][sz]);
	GetPlayerHealth(playerid, gSyncInfo[playerid][shealth]);
	GetPlayerArmour(playerid, gSyncInfo[playerid][sarmour]);
	gSyncInfo[playerid][sint] = GetPlayerInterior(playerid);
	gSyncInfo[playerid][svw] = GetPlayerVirtualWorld(playerid);
	new sskin = GetPlayerSkin(playerid);
	SetPlayerSkin(playerid, sskin);
    for (new i = 0; i < 13; i++) GetPlayerWeaponData(playerid, i, syncwep[i][0], syncwep[i][1]);
    SetPVarInt(playerid, "NoAB", 3);
	SpawnPlayer(playerid);
	return 1;
}

CMD:sv(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1 )
	    return accessdenied(playerid);
	new vid,destroy;
	if( sscanf( params, "dd", vid, destroy ) )
	    return SendUsage(playerid, "USAGE: /spawnvehicle [vehicle ID] [destroy(1/0)]" );
	if( destroy > 1 || destroy < 0 )
	    return SendClientMessage( playerid, COLOR_GRAY, "Destroy can only be 1 and 0. (1 true, 0 false).");
    if (vid<=gVehs && destroy==1)
	    return SendClientMessage(playerid,COLOR_GRAY,"You are not allowed to destroy the gamemode vehicles.");
	if (!destroy) SetVehicleToRespawn(vid);
	else DestroyVehicle(vid);
	AdminCommand( playerid, "SPAWNVEHICLE" );
	return 1;
}
CMD:spawnvehicle(playerid, params[]) return cmd_sv( playerid, params );

CMD:respawnallcars(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 4 )
	    return accessdenied(playerid);
	for(new i; i < 2000; i++)
	{
	    SetVehicleToRespawn(i);
	}
	new string[90];
	String("Administrator %s has respawned all vehicles.", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, string);
	AdminCommand(playerid, "RESPAWNALLCARS");
	return 1;
}

CMD:spawnucars(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 3 )
	    return accessdenied(playerid);
	for( new i; i < 2000; i++)
	{
	    if(IsVehicleEmpty(i)) SetVehicleToRespawn(i);
	}
	new string[90];
	String("Administrator %s has respawned all unused vehicles.", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(-1, string);
	return 1;
}
CMD:respawnunusedcars(playerid, params[]) return cmd_spawnucars(playerid,params);

CMD:ip(playerid, params[])
{
	if( gPlayerInfo[playerid][pOp] == 1 || gPlayerInfo[playerid][pAlevel] > 0 ) 
	{
		new id;
		if( sscanf( params, "u", id ) )
		    return SendUsage(playerid, "USAGE: /ip [ID]");
		if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID )
		    return SendClientMessage(playerid, invalidplayer);
		new string[128];
		if(Undercover[id] == 1) {
		    String("%s[%d]'s IP: 225.225.225.225",gPlayerInfo[id][pName], id);
		    SendClientMessage( playerid, COLOR_YELLOW, string );
		}
		else {
			String("%s[%d]'s IP: %s",gPlayerInfo[id][pName],id,gPlayerInfo[id][pIp]);
			SendClientMessage( playerid, COLOR_YELLOW, string );
		}
		AdminCommand(playerid, "IP",id);
		return 1;
	}
	else return accessdenied(playerid);
}
CMD:getip(playerid, params[]) return cmd_ip(playerid,params);

CMD:spawn(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1 )
	    return accessdenied(playerid);
	new id;
	if( sscanf( params, "u", id ) )
	    return SendUsage(playerid, "USAGE: /spawn [ID]");
	if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID )
	    return SendClientMessage(playerid, invalidplayer);
    SetPVarInt(id, "NoAB", 4);
	SetPlayerPos(id, 0.0, 0.0, 0.0);
	SpawnPlayer(id);
	AdminCommand(playerid, "SPAWN",id);
	return 1;
}

CMD:osay(playerid, params[])
{
	if (!gPlayerInfo[playerid][pOp])
	    return accessdenied(playerid);
	new string[128];
	String("Operator %s: %s",gPlayerInfo[playerid][pName],params);
	SendClientMessageToAll(COLOR_PINK,string);
	return 1;
}

CMD:freeze(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel]< 1)
	    return accessdenied(playerid);
	new id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /freeze [ID]");
	if(!IsPlayerConnected( id ) || id == INVALID_PLAYER_ID)
	    return SendClientMessage(playerid, invalidplayer);
	if(GetPVarInt(id, "Frozen") == 1)
	    return SendClientMessage( playerid, COLOR_GRAY, "Player is already frozen.");
	new string[90];
	if(GetPVarInt(id, "Frozen") == 0)
	{
		String("Administrator %s has frozen you.", gPlayerInfo[playerid][pName]);
		SendClientMessage(id, COLOR_YELLOW, string);
		TogglePlayerControllable(id, 0);
		SetPVarInt(id, "Frozen", 1);
	}
	AdminCommand(playerid, "FREEZE",id);
	return 1;
}

CMD:unfreeze(playerid, params[])
{
	if( gPlayerInfo[ playerid ][ pAlevel] < 1)
	    return accessdenied(playerid);
	new id;
    if(sscanf(params, "u", id)) return SendUsage(playerid, "USAGE: /unfreeze [ID]");
	if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID )
	   	return SendClientMessage(playerid, invalidplayer);
	ssstring("Administrator %s has unfrozen you.", gPlayerInfo[playerid][pName]);
	SendClientMessage(id, COLOR_YELLOW, ssstring);
	TogglePlayerControllable(id, 1);
	SetPVarInt( id, "Frozen", 0);
	AdminCommand(playerid, "UNFREEZE", id);
	return 1;
}

CMD:disarm(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	new id;
	if( sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /disarm [ID]");
	if( !IsPlayerConnected( id ) || id == INVALID_PLAYER_ID )
	    return SendClientMessage(playerid, invalidplayer);
	new string[80];
	SendClientMessage(playerid, COLOR_YELLOW, string);
	ResetPlayerWeaponsEx(id);
	AdminCommand(playerid, "DISARM", id);
	return 1;
}

CMD:announce(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 3 )
	    return accessdenied(playerid);
	new text[128];
	if( sscanf( params, "s[128]", text ) )
	    return SendUsage(playerid, "USAGE: /announce [text]" );
	GameTextForAll( text, 4000, 3 );
	AdminCommand(playerid, "ANNOUNCE");
	return 1;
}
CMD:ann(playerid, params[]) return cmd_announce(playerid,params);

CMD:screen(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 3 )
	    return accessdenied(playerid);
	new text[128], id;
	if( sscanf( params, "us[128]", id,text ) )
	    return SendUsage(playerid, "USAGE: /screen [ID] [text]");
	GameTextForPlayer(id, text, 4000, 3);
	AdminCommand(playerid, "SCREEN", id);
	return 1;
}

CMD:givefreenamechange(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4)
	    return accessdenied(playerid);
	new string[100], id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /givefreenamechange [ID]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if (gPlayerInfo[id][pDonor]) return SendClientMessage(playerid, COLOR_RED, "That player is a donor - they already gets free name changes!");
	if(GetPVarInt(id, "freenamechange") == 1)
	{
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Player already had a free name change - removed!");
		DeletePVar(id, "freenamechange");
		String("Administrator %s has removed your free name change.",gPlayerInfo[playerid][pName]);
	}
	else
	{
		SetPVarInt(id, "freenamechange", 1);
		namechange[id]=0;
		String("Administrator %s has granted you a free name change - use /changename to change your name.",gPlayerInfo[playerid][pName]);
		AdminCommand(playerid, "GIVEFREENAMECHANGE", id);
	}
	SendClientMessage(id, COLOR_YELLOW, string);
	return 1;
}

CMD:resetnamechange(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4)
	    return accessdenied(playerid);
	new string[100], id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /givefreenamechange [ID]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if(namechange[id] == 1)
	{
		namechange[id]=0;
		String("Administrator %s has allowed you another name change during this session.",gPlayerInfo[playerid][pName]);
		AdminCommand(playerid, "RESETNAMECHANGE", id);
	}
	else
	{
		namechange[id]=1;
		SendClientMessage(playerid, COLOR_LIGHTGRAY, "Player can now not change their name during this session.");
		String("Administrator %s has removed the ability for you to change your name during this session.", gPlayerInfo[playerid][pName]);
	}
	SendClientMessage(id, COLOR_YELLOW, string);
	return 1;
}

CMD:hackcheck(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 4)
	    return accessdenied(playerid);
	new string[100], id;
	if(sscanf(params, "u", id))
	    return SendUsage(playerid, "USAGE: /hackcheck [ID]");
	if (!IsPlayerConnected(id) || id==INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	String("You are checking %s for s0beit - please wait...", gPlayerInfo[id][pName]);
	SendClientMessage(playerid, -1, string);
	TogglePlayerControllable(id, 0);
	SetTimerEx("HackCheck", FREEZE_SECONDS * 1000, 0, "i", id);
	AdminCommand(playerid, "HACKCHECK", id);
	return 1;
}

CMD:ohelp(playerid,params[])
{
	if (!gPlayerInfo[playerid][pAlevel] && !gPlayerInfo[playerid][pOp])
	    return accessdenied(playerid);
    if(gPlayerInfo[playerid][pAlevel] > 1)
    {
		SendClientMessage(playerid, -1, "You are an administrator, some operator commands may not be available to you.");
	}
	SendClientMessage(playerid, -1, "Operator commands: /spec(/lsp), /specoff(/ss), /kick, /warn, /osay");
	return 1;
}
CMD:ocmds(playerid, params[]) return cmd_ohelp(playerid,params);

CMD:setdonor(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 5 )
	    return accessdenied(playerid);
	new id, rank;
	if(sscanf(params, "ud", id, rank ) )
	    return SendUsage(playerid, "USAGE: /setdonor [ID] [rank]");
	if(!IsPlayerConnected( id ) || id == INVALID_PLAYER_ID)
		return SendClientMessage(playerid, invalidplayer);
	if(rank>SERVER_MAX_DONOR_LEVEL || rank<SERVER_MIN_DONOR_LEVEL)
		return SendClientMessage(playerid,COLOR_ORANGE,"Donor rank must be between 1 and 3.");
	new string[128];
	String("Administrator %s has set your donor rank to %d! Use /dcmds to view the donor commands.", gPlayerInfo[playerid][pName], rank );
	SendClientMessage( id, COLOR_YELLOW, string );
	String("You have set %s to donor rank %d!",gPlayerInfo[id][pName], rank);
	SendClientMessage( playerid, COLOR_YELLOW, string );
	gPlayerInfo[id][pDonor]=rank;
	AdminCommand(playerid, "SETDONOR",id );
	return 1;
}

CMD:dskin(playerid, params[])
{
	if (gPlayerInfo[playerid][pDonor] < 2) return SendClientMessage(playerid, donordeny2);
	new skin;
 	if(sscanf( params, "d", skin))
		return SendUsage(playerid, "USAGE: /dskin [skin ID]");
	if(!IsValidSkin(skin))
	    return SendClientMessage( playerid, COLOR_GRAY, "Invalid skin ID!");
	if(skin == 217)
	    return SendClientMessage(playerid, COLOR_GRAY, "You can't use the staff skin.");
	SetPlayerSkin(playerid, skin);
	new string[40];
 	String("You have set your skin to %d.", skin);
 	SendClientMessage( playerid, COLOR_YELLOW, string);
	DonorCommand(playerid, "DSKIN");
	return 1;
}

CMD:dnos(playerid, params[])
{
    if(gPlayerInfo[playerid][pDonor] < 1) return SendClientMessage(playerid, donordeny1);
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GRAY, "ERROR: You are not in a vehicle!");
	else
	{
	   	new vehicleid = GetPlayerVehicleID(playerid);
		AddVehicleComponent(vehicleid, 1010);
		SendClientMessage(playerid, -1, "NOS added!");
		DonorCommand(playerid, "DNOS");
	}
	return 1;
}

CMD:dhy(playerid, params[])
{
    if(gPlayerInfo[playerid][pDonor] < 1) return SendClientMessage(playerid, donordeny1);
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GRAY, "ERROR: You are not in a vehicle!");
	else
	{
		new vehicleid = GetPlayerVehicleID(playerid);
		AddVehicleComponent(vehicleid, 1087);
		SendClientMessage(playerid, -1, "Hydraulics added!");
		DonorCommand(playerid, "DHY");
	}
	return 1;
}

CMD:d(playerid, params[])
{
    if(gPlayerInfo[playerid][pDonor] < 1) return SendClientMessage(playerid, COLOR_DARKORANGE, "You must have a donor rank of 1 or above to use this command.");
    if(Muted[playerid])
	    return SendClientMessage(playerid, muted);
	if(isnull(params))
		return SendUsage(playerid, "USAGE: /d [text]");
	else {
		if( gPlayerInfo[playerid][pDonor] > 0  || gPlayerInfo[playerid][pAlevel] > 0 || Undercover[playerid] == 1)
		{
			new string[128];
			format( string, sizeof string, "[D.chat][%d]%s: %s", playerid, gPlayerInfo[playerid][pName], params);
			foreach(Player, i)
			{
			 	if( gPlayerInfo[ i ][ pAlevel ] > 0 || Undercover[i] == 1 || gPlayerInfo[i][pDonor] > 0)
			 	{
				  	SendClientMessage( i, COLOR_PINK, string );
				}
			}
		}
	}
	return 1;
}

CMD:dsay(playerid, params[])
{
	if(gPlayerInfo[playerid][pDonor] < 1) return SendClientMessage(playerid, donordeny1);
	if(isnull(params))
		return SendUsage(playerid, "USAGE: /dsay [text]");
    if(Muted[playerid])
	    return SendClientMessage(playerid, muted);
	new text[128];
	if (sscanf(params,"s[128]",text))
	    return SendUsage(playerid, "USAGE: /dsay [text]");
	new string[128];
	String("Donor %s: %s",gPlayerInfo[playerid][pName],text);
	SendClientMessageToAll(COLOR_WHITE, string);
	return 1;
}

CMD:dtune(playerid, params[])
{
    if(gPlayerInfo[playerid][pDonor] < 1) return SendClientMessage(playerid, donordeny1);
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_ORANGE, "You need to be in a tunable vehicle to use this.");
    new vehicleid = GetPlayerVehicleID(playerid), model = GetVehicleModel(vehicleid);
    switch(model)
	{
		case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
		return SendClientMessage(playerid,COLOR_ORANGE,"You can't tune this vehicle!");
	}
	DonorCommand(playerid, "DTUNE");
	AddVehicleComponent(vehicleid, 1010);
	AddVehicleComponent(vehicleid, 1087);
	return 1;
}

CMD:spree(playerid, params[])
{
	new targetid;
	if(sscanf(params, "u", targetid)) 
		targetid=playerid;
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid, invalidplayer);
	ssstring("%s[%d] is currently on a killing spree of %d kills. | Session kills: %d | Capture spree: %d", gPlayerInfo[targetid][pName],targetid, KillingSpree[targetid],SessionKills[targetid],CaptureSpree[targetid]);
	return SendClientMessage(playerid, COLOR_YELLOW, ssstring), 1;
}
CMD:streak(playerid, params[]) return cmd_spree( playerid, params );

CMD:site(playerid, params[])
{
	SendClientMessage(playerid, -1, "Server website: www.sector7gaming.com");
	return SendClientMessage(playerid, -1, "Server forums: www.sector7gaming.com/forums");
}

CMD:asite(playerid,params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 1 ) return accessdenied(playerid);
	GameTextForAll("~n~Server website~n~~r~sector7gaming.com", 5500, 5);
	AdminCommand(playerid, "ASITE");
	return 1;
}

CMD:operators(playerid, params[])
{
	SendClientMessage( playerid, COLOR_WHITE, "Current operators online:");
	new string[50], count = 0;
	foreach(Player, i) if(gPlayerInfo[i][pOp] == 1)
	{
		String("%s | ID: %d",gPlayerInfo[i][pName],i);
		SendClientMessage( playerid, COLOR_WHITE, string );
		count++;
	}
	if(count == 0)
		SendClientMessage(playerid, COLOR_WHITE, "No operators online!");
	return 1;
}
CMD:ops(playerid, params[]) return cmd_operators(playerid, params);

CMD:donors(playerid, params[])
{
	SendClientMessage(playerid, COLOR_WHITE, "Current donators online:");
	new string[128],count;
	foreach(Player,i)
	{
		if (!gPlayerInfo[i][pDonor]) continue;
		String("%s | ID: %d | Level: %d",gPlayerInfo[i][pName],i,gPlayerInfo[i][pDonor]);
		SendClientMessage(playerid, COLOR_WHITE, string);
		count++;
	}
	if(count == 0)
		SendClientMessage(playerid, COLOR_WHITE, "No donators online!");
	return 1;
}

CMD:setping(playerid, params[])
{
	if( gPlayerInfo[playerid][pAlevel] < 4)
	{
	    accessdenied(playerid);
		return 1;
	}
	new ping, string[128];
	if(sscanf(params, "d", ping))
	{
		SendUsage(playerid, "USAGE: /setping [ping]");
		return 1;
	}
	MAX_PING = ping;
	String("Administrator %s has set the maximum ping to %d.",gPlayerInfo[playerid][pName],ping);
	SendClientMessageToAll(COLOR_YELLOW,string);
	return 1;
}

CMD:disableantiab(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 5)
		return accessdenied(playerid);
	new string[70];
	if(disableantiAB==0)
	{
		disableantiAB=1;
		String("[ADMIN] %s has disabled anti airbreak warnings!", gPlayerInfo[playerid][pName]);
		SendMessageToAdmins(COLOR_BLUE, string);
	}
	else
	{
		disableantiAB=0;
		String("[ADMIN] %s has enabled anti airbreak warnings!", gPlayerInfo[playerid][pName]);
		SendMessageToAdmins(COLOR_BLUE, string);
	}
	print(string);
	return 1;
}

CMD:fakechat(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] >=5)
	{
		new id, text[256];
		if(sscanf(params, "us[256]", id, text)) return SendUsage(playerid, "USAGE: /fakechat [ID/name] [text]");
		else if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, invalidplayer);
		new pCol = GetPlayerColor(id);
		ssstring("[%d]%s: {FFFFFF}%s", id, gPlayerInfo[id][pName], text);
		SendClientMessageToAll(pCol, ssstring);
	}
	else return accessdenied(playerid);
	return 1;
}

CMD:fakekill(playerid, params[])
{
    if(gPlayerInfo[playerid][pAlevel] >=5)
    {
    	new target, player1, reason;
    	if(sscanf(params, "uud", target, player1, reason)) return SendUsage(playerid, "USAGE: /fakekill [killer] [death player] [death]");
    	else if(target == INVALID_PLAYER_ID) return SendClientMessage(playerid, invalidplayer);
    	else if(reason < 0 || reason > 54) return SendClientMessage(playerid, COLOR_ORANGE, "That's not a valid death reason.");
    	SendDeathMessage(target, player1, reason);
	}
	else return accessdenied(playerid);
	return 1;
}

CMD:changename(playerid, params[])
{
    if (gPlayerInfo[playerid][pLogged] == 0) return SendClientMessage(playerid, COLOR_RED, "You must be logged in to change your name!");
	if(isnull(params)) return SendUsage(playerid, "USAGE: /changename [new name]");
	if(!strlen(params)) return SendClientMessage(playerid, COLOR_RED, "Invalid name!");
	if(strlen(params) < 3 || strlen(params) > 20) return SendClientMessage(playerid, COLOR_RED, "[ERROR] Name must be between 3-20 characters.");
	if(namechange[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "You can only change your name once per session.");
	if(strfind(params, " ", true) != -1) return SendClientMessage(playerid, COLOR_RED, "Cannot have spaces in your name!");
	new string[128], escname[24];
	mysql_real_escape_string(gPlayerInfo[playerid][pName], escname);
	new query[200];
	new escname2[24];
	mysql_real_escape_string(params, escname2);
	Query("SELECT `user` FROM `playerinfo` WHERE `user`='%s'",escname2);
	mysql_query(query);
	mysql_store_result();
	if(mysql_num_rows() > 0) return SendClientMessage(playerid, COLOR_RED, "That name is taken. Please pick another one.");
	mysql_free_result();
	switch(SetPlayerName(playerid, params))
	{
	    case -1: SendClientMessage(playerid, 0xFFFF00FF, "Invalid name!");
	    case 0: SendClientMessage(playerid, 0xFFFF00FF, "You already have that name!");
	    case 1:
		{
		    Query("UPDATE `playerinfo` SET `user`='%s' WHERE `id`='%d' LIMIT 1",escname2,gPlayerInfo[playerid][pDBID]);
		    mysql_query(query);
		    Query("INSERT INTO `logs` (`nick`,`time`,`action`,`info`) VALUES ('%s',UNIX_TIMESTAMP(),'[PLAYER] CHANGED NAME','Changed to: %s')",escname,escname2);
		    mysql_query(query);
			if (gPlayerInfo[playerid][pDonor]) SendClientMessage(playerid, COLOR_YELLOW, "You get free name changes because you are a donor!");
			else if (!gPlayerInfo[playerid][pDonor] && GetPVarInt(playerid, "freenamechange")==0)
			{
				if(GetPlayerMoney(playerid) < 100000)
					return SendClientMessage(playerid, 0xFFFF00FF, "Not enough money - name changes cost 100k.");
				GivePlayerMoneySync(playerid, -100000);
				SendClientMessage(playerid, 0xFFFF00FF, "Donors get free name changes!");
			}
			else if (GetPVarInt(playerid, "freenamechange")==1)
			{
				SendClientMessage(playerid, COLOR_YELLOW, "You have used your free name change!");
				DeletePVar(playerid, "freenamechange");
			}
			String("[ADMIN] %s[%i] changed their name to %s!",gPlayerInfo[playerid][pName],playerid,params);
			SendMessageToAdmins(COLOR_YELLOW, string);
			print(string);
			SendClientMessage(playerid, 0xFFFF00FF, "Name successfully changed!");
			GetPlayerName(playerid,gPlayerInfo[playerid][pName],MAX_PLAYER_NAME);
			namechange[playerid] = 1;
		}
	}
	return 1;
}

CMD:motd(playerid, params[])
{
	return SendClientMessage(playerid, MOTDCOLOR, motd), 1;
}

CMD:setmotd(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel] < 6) 
		return accessdenied(playerid);
	if(isnull(params))
		return SendUsage(playerid, "USAGE: /setmotd [message of the day]");
	if(strlen(params) > 120)
		return SendClientMessage(playerid, COLOR_RED, "Message of the day must be 120 characters or below");
	new query[160], string[128];
	format(string, sizeof(string), "MOTD: %s", params);
	motd=string;
	mysql_real_escape_string(string, string);
	Query("UPDATE `servercfg` SET `motd`='%s'", string);
	mysql_query(query);
	format(string, sizeof(string), "[MOTD] Administrator %s updated the message of the day(/motd)!", gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_YELLOW, string);
	print(string);
	return 1;
}

CMD:togglest(playerid, params[])
{
	if(gPlayerInfo[playerid][pAlevel]< 4)
	    return accessdenied(playerid);
	new string[128];
	if (gSwitchteam)
	{
	    gSwitchteam=0;
	    String("Administrator %s has enabled the switch team function, event ended!",gPlayerInfo[playerid][pName]);
	}
	else
	{
	    gSwitchteam=1;
	    String("Administrator %s has disabled the switch team function for an event.",gPlayerInfo[playerid][pName]);
	}
	SendClientMessageToAll(COLOR_LIMEGREEN,string);
	foreach(Player,i) PlayerPlaySound(i,1057,0.0,0.0,0.0);
	return 1;
}

CMD:togvehlimit(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 5)
	    return accessdenied(playerid);
	new string[90];
	if (gLimitVehicles)
	{
	    gLimitVehicles=0;
	    String("Administrator %s has disabled the heavy vehicle limitations.",gPlayerInfo[playerid][pName]);
	}
	else
	{
	    gLimitVehicles=1;
	    String("Administrator %s has enabled the heavy vehicle limitations.",gPlayerInfo[playerid][pName]);
	}
	SendClientMessageToAll(COLOR_LIMEGREEN,string);
	return 1;
}

CMD:fixteams(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel]< 1)
	    return accessdenied(playerid);
	new string[128];
	for (new i=1;i<MAX_TEAMS;i++) gTeam[i][tPlayers]=0;
	foreach(Player,i) if (gPlayerInfo[i][pPlayingTeam]) gTeam[gPlayerInfo[i][pPlayingTeam]][tPlayers]++;
	String("Administrator %s has fixed the count in /teams.",gPlayerInfo[playerid][pName]);
	SendClientMessageToAll(COLOR_LIMEGREEN,string);
	return 1;
}

CMD:afix(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	{
	    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,COLOR_RED, "ERROR: You are not in a vehicle!");
		else
		{
			RepairVehicle(GetPlayerVehicleID(playerid));
		}
		AdminCommand(playerid, "AFIX");
	}
	return 1;
}

CMD:acar(playerid, params[])
{
	if (gPlayerInfo[playerid][pAlevel] < 1)
	    return accessdenied(playerid);
	new Float:x, Float:y, Float:z, Float:angle, interior = GetPlayerInterior(playerid), vw = GetPlayerVirtualWorld(playerid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, angle);
	if(gPlayerInfo[playerid][pVeh] != -1 ) DestroyVehicle(gPlayerInfo[playerid][pVeh]);
	gPlayerInfo[playerid][pVeh] = CreateVehicle(411, x, y + 3, z, angle, 0, 0, 200);
	LinkVehicleToInterior(gPlayerInfo[playerid][pVeh], interior);
	SetVehicleVirtualWorld(gPlayerInfo[playerid][pVeh], vw);
	PutPlayerInVehicle(playerid,gPlayerInfo[playerid][pVeh],0);
	AddVehicleComponent(gPlayerInfo[playerid][pVeh], 1010);
	AdminCommand(playerid, "ACAR");
	return 1;
}

CMD:savestats(playerid, params[])
{
	if (!CheckCoolDown(playerid,"savestats",60)) return 1;
	SaveStats(playerid);
	SendClientMessage(playerid, COLOR_LIMEGREEN, "You have saved your stats!");
    return 1;
}

#define SPECIAL_ACTION_PISSING 68
	CMD:anims(playerid, params[])
	{
		SendClientMessage(playerid, COLOR_BLUE, "/relax, /sick, /wave, /spank, /taichi, /wank, /kiss, /talk, /fucku, /sit");
        SendClientMessage(playerid, COLOR_BLUE, "/beach, /lookout, /circle, /medic, /chat, /die, /slapa, /rofl, /robman, /injured");
        SendClientMessage(playerid, COLOR_BLUE, "/handsup, /piss, /getin, /vomit, /drunk, /slapass, /laydown, /laugh, /strip");
        return 1;
	}
	CMD:relax(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
	    return 1;
	}
	CMD:handsup(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
	    return 1;
	}
	CMD:robman(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0);
	    return 1;
	}
	CMD:wank(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"PAULNMAC", "wank_loop", 1.800001, 1, 0, 0, 1, 600);
	    return 1;
	}
	CMD:taichi(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
	    return 1;
	}
	CMD:spank(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0);
	    return 1;
	}
	CMD:wave(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0);
	    return 1;
	}
	CMD:sick(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);
	    return 1;
	}
	CMD:talk(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"PED","IDLE_CHAT",1.800001, 1, 1, 1, 1, 13000);
	    return 1;
	}
	CMD:kiss(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"KISSING", "Grlfrd_Kiss_02", 1.800001, 1, 0, 0, 1, 600);
	    return 1;
	}
	CMD:sit(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"INT_OFFICE", "OFF_Sit_Bored_Loop", 1.800001, 1, 0, 0, 1, 600);
	    return 1;
	}
	CMD:fucku(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"ped", "fucku", 4.1, 0, 1, 1, 1, 1 );
	    return 1;
	}
	CMD:crack(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"CRACK", "crckdeth2", 1.800001, 1, 0, 0, 1, 600);
	    return 1;
	}
	CMD:beach(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"BEACH","SitnWait_loop_W",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:lookout(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"ON_LOOKERS","lkup_in",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:circle(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"CHAINSAW","CSAW_Hit_2",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:medic(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"MEDIC","CPR",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:chat(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"PED","IDLE_CHAT",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:die(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"PED","BIKE_fallR",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:slapa(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"PED","BIKE_elbowL",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:rofl(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"PED","Crouch_Roll_L",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:vomit(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0);
        return 1;
	}
	CMD:drunk(playerid, params[]) 
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"PED","WALK_DRUNK",4.1,0,1,1,1,1);
		return 1;
	}
	CMD:getin(playerid, params[])
	{
		if (GetPlayerState(playerid)== 1) ApplyAnimation(playerid,"NEVADA","NEVADA_getin",4.1,0,1,1,1,1);
        return 1;
    }
    CMD:piss(playerid, params[])
	{
	    if (GetPlayerState(playerid)== 1) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_PISSING);
		return 1;
	}
	CMD:laugh(playerid, params[])
	{
		ApplyAnimation(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0);
		return 1;
	}
	CMD:injured(playerid, params[])
	{
		ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0);
		return 1;
    }
	CMD:slapass(playerid, params[])
	{
		ApplyAnimation(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0);
		return 1;
	}
	CMD:laydown(playerid, params[])
	{
		ApplyAnimation(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
		return 1;
	}
    CMD:strip(playerid, params[])
	{
		ApplyAnimation(playerid,"STRIP","strip_A",4.0,0,1,1,1,0);
  		return 1;
    }

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    SetPVarInt(playerid, "NoAB", 2);
    if (ispassenger) return 1;
	foreach(Player, i)
	{
 		if(IsPlayerInVehicle(i,vehicleid) && GetPlayerState(i) == PLAYER_STATE_DRIVER && gPlayerInfo[i][pTeam]==gPlayerInfo[playerid][pTeam])
        {
        	new string[128];
			pTJ[playerid] ++;
			String("DO NOT TEAM JACK! Warning: %d/10.", pTJ[playerid]);
			SendClientMessage(playerid, COLOR_RED, string);
			GameTextForPlayer(playerid, "Do not team car jack!", 4500, 4);
			new Float:Pos[3];
			GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			SetPVarInt(playerid, "NoAB", 4);
			SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
			if(pTJ[playerid] == 10)
			{
			    String("[AUTOKICK] %s(%d) has been kicked for 10 team car jacks!",gPlayerInfo[playerid][pName],playerid);
			    SendClientMessageToAll(COLOR_RED, string);
			    pTJ[playerid] = 0;
			    KickWithMessage(playerid, "You have been kicked for 10 team jacks.");
            }
        }
    }
   	LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
   	SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	if (GetPlayerState(playerid)==PLAYER_STATE_DRIVER && GetPVarInt(playerid,"AdminDuty")==1)
	{
		defer AResetVHealth(vehicleid);
	}
	SetPVarInt(playerid, "NoAB", 2);
	return 1;
}

public OnPlayerStateChange(playerid,newstate,oldstate)
{
	if (newstate == PLAYER_STATE_DRIVER)
    {
        SetPlayerArmedWeapon(playerid,0);
	    new vehicleid = GetPlayerVehicleID(playerid);
    	new cartype = GetVehicleModel(vehicleid);
	    new string[20];
	    String( "~w~%s", VehicleNames[GetVehicleModel(vehicleid)-400]);
    	GameTextForPlayer(playerid, string, 3000, 1);
		if (GetPVarInt(playerid, "AdminDuty") == 0) //duty check for restricted vehicles
		{
			if(IsBombPlane(GetVehicleModel(vehicleid)))
			{
				SendClientMessage(playerid, COLOR_RED, "Press the ~k~~VEHICLE_FIREWEAPON~ to drop a bomb!");
				bombable[playerid] = 1;
			}
			
			if(cartype == 432) //rhino
			{
				if (gPlayerInfo[playerid][pClass]!=CLASS_ENGINEER)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "You must be using the 'Engineer' class to use a Rhino!");
				}
				else if (gPlayerInfo[playerid][pRank]< 2 && gPlayerInfo[playerid][pAlevel]< 1)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "You need to be rank 2 to use a rhino!");
					SendClientMessage(playerid, COLOR_RED, "To rank up, get more score by killing enemies or take territories!");
				}
				else if (gPlayerInfo[playerid][pClass]==CLASS_SNIPER)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "Snipers are not allowed to drive rhinos!");
				}
				else 
				{
					if (gLimitVehicles)
					{
						new count; //not more than 2 tanks at a time in the same team
						foreach(Player,i)
						{
							if (gPlayerInfo[i][pTeam]!=gPlayerInfo[playerid][pTeam] && GetPVarInt(i, "AdminDuty") == 0) continue;
							if (GetVehicleModel(GetPlayerVehicleID(i))==432) count++;
						}
						if (count>2)
						{
							RemovePlayerFromVehicle(playerid);
							return SendClientMessage(playerid,COLOR_RED,"Sorry, there are already 2 rhinos being used by your team mates.");
						}
					}
					SendClientMessage(playerid, enterhvehicle);
				}
			}
			
			if(cartype == 520) //hydra
			{
				if (gPlayerInfo[playerid][pClass]!=CLASS_PILOT)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "You must be using the 'Pilot' class to fly a hydra!");
				}
				else if (gPlayerInfo[playerid][pRank]< 3)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "You need to be rank 3 or above to fly a hydra");
					SendClientMessage(playerid, COLOR_RED, "To rank up, get more score by killing enemies or take territories!");
				}
				else 
				{
					if (gLimitVehicles)
					{
						new count; //not more than 1 hydra at a time in the same team
						foreach(Player,i)
						{
							if (gPlayerInfo[i][pTeam]!=gPlayerInfo[playerid][pTeam] && GetPVarInt(i, "AdminDuty") == 0) continue;
							if (GetVehicleModel(GetPlayerVehicleID(i))==520) count++;
						}
						if (count> 1)
						{
							RemovePlayerFromVehicle(playerid);
							return SendClientMessage(playerid,COLOR_RED,"Sorry, there is already 1 hydra being used by a team mate.");
						}
					}
					SendClientMessage(playerid, enterhvehicle);
				}
			}
			
			if(cartype == 425) //hunter
			{
				if(gPlayerInfo[playerid][pClass]!=CLASS_PILOT)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "You must be using the 'Pilot' class to fly a hunter!");
				}
				else if(gPlayerInfo[playerid][pRank] < 4)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "You need to be rank 4 or above to fly a hunter!");
					SendClientMessage(playerid, COLOR_RED, "To rank up, get more score by killing enemies or take territories!");
				}
				else
				{
					if (gLimitVehicles)
					{
						new count; //not more than 1 hunter at a time in the same team
						foreach(Player,i)
						{
							if (gPlayerInfo[i][pTeam]!=gPlayerInfo[playerid][pTeam] && GetPVarInt(i, "AdminDuty") == 0) continue;
							if (GetVehicleModel(GetPlayerVehicleID(i))==425) count++;
						}
						if (count>1)
						{
							RemovePlayerFromVehicle(playerid);
							return SendClientMessage(playerid,COLOR_RED,"Sorry, there is already 1 hunter being used by a team mate.");
						}
					}
					SendClientMessage(playerid, enterhvehicle);
				}
			}
			
			if(cartype == 447) //seasparrow
			{
				if(gPlayerInfo[playerid][pClass]!=CLASS_PILOT)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "You must be using the 'Pilot' class to fly a seasparrow!");
				}
				else if(gPlayerInfo[playerid][pRank] < 2)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "You need to be rank 2 or above to fly a seasparrow!");
					SendClientMessage(playerid, COLOR_RED, "To rank up, get more score by killing enemies or take territories!");
				}
				else 
				{
					if (gLimitVehicles) 
					{
						new count; //not more than 1 hydra at a time in the same team
						foreach(Player,i)
						{
							if (gPlayerInfo[i][pTeam]!=gPlayerInfo[playerid][pTeam] && GetPVarInt(i, "AdminDuty") == 0) continue;
							if (GetVehicleModel(GetPlayerVehicleID(i))==447) count++;
						}
						if (count>1)
						{
							RemovePlayerFromVehicle(playerid);
							return SendClientMessage(playerid,COLOR_RED,"Sorry, there is already 1 seasparrow being used by a team mate.");
						}
					}
					SendClientMessage(playerid, enterhvehicle);
				}
			}
			
			if(IsBombPlane(GetVehicleModel(vehicleid))) //bombing planes(nevada/rustler)
			{
				if(gPlayerInfo[playerid][pClass] == CLASS_SNIPER)
				{
					RemovePlayerFromVehicle(playerid);
					SendClientMessage(playerid, COLOR_RED, "Snipers can't fly airplanes with bombs!");
				}
			}
			
			if(cartype == 416 && gPlayerInfo[playerid][pClass] != CLASS_MEDIC) //ambulance
			{
				RemovePlayerFromVehicle(playerid);
				SendClientMessage(playerid, COLOR_RED, "You must be a medic to drive an ambulance.");
			}	
		} //EO aduty check == 0 for restricted vehicles
	}
	else if (newstate == PLAYER_STATE_PASSENGER)
	{
	    new weap=GetPlayerWeapon(playerid);
	    //no passenger drive by with eagle, spaz, or sniper
	    if (weap==WEAPON_DEAGLE) SetPlayerArmedWeapon(playerid,0);
	    else if (weap==WEAPON_SHOTGSPA) SetPlayerArmedWeapon(playerid,0);
	    else if (weap==WEAPON_SNIPER) SetPlayerArmedWeapon(playerid,0);
	}
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
    SetPVarInt(playerid, "NoAB", 4);
	if (gPlayerInfo[playerid][pTeam]<1) return 0; //to prevent people from trying to spawn right after a server restart
	if(!gPlayerInfo[playerid][pReggedAcc]) 
	{
		return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD , "Register", "You must register before spawning!\nThis account is not registered, please register!", "OK", "Cancel");
	}
    if (!gPlayerInfo[playerid][pLogged] && gPlayerInfo[playerid][pReggedAcc]) //give the login dialog again if a player tries to spawn without login
    {
		ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Login","This account is registered, please login.","OK", "Cancel"); //If the user is not found it will show the login dialog
		return 0;
    }
    if(gSwitchteam ==1 && firstconnected[playerid] == 0)  //switchteam disabler
	{
		SendClientMessage(playerid, COLOR_RED, "You can not select a team while an event is running! Please wait until the event is over!");
		return  0;
	}
	//team balancer
    new team1=-1,team1p=-1,team2p=-1;
    //determining the team with most players
    for (new i=1;i<MAX_TEAMS;i++)
    {
        if (gTeam[i][tPlayers]<=team1p) continue;
    	team1=i;
    	team1p=gTeam[i][tPlayers];
    }
    //second team with most players
    for (new i=1;i<MAX_TEAMS;i++)
    {
        if (i==team1) continue;
        if (gTeam[i][tPlayers]<=team2p) continue;
        team2p=gTeam[i][tPlayers];
    }
    //if one team has at least 5 players more than any another team, we deny the spawn
    if (gPlayerInfo[playerid][pTeam]==team1)
    {
        if (team1p>floatround(float(team2p)*1.6,floatround_floor))
        {
            SendClientMessage(playerid,COLOR_RED,"Sorry, there are too many players in this team, please choose another. (/teams)");
            return 0;
        }
    }
	gPlayerInfo[playerid][pPlayingTeam]=gPlayerInfo[playerid][pTeam];
	gTeam[gPlayerInfo[playerid][pTeam]][tPlayers]+=1;
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) return 1;
	return 1;
}

public AntiSpawnKill(playerid)
{
	SetPlayerHealth(playerid,gRankHealth[gPlayerInfo[playerid][pRank]]);
	SetPlayerArmour(playerid,gRankArmor[gPlayerInfo[playerid][pRank]]);
	UpdateRadar(playerid);
	return 1;
}

PUB:JustSpawned(playerid)
{
	if(dueling[playerid]==0)
	{
		if(GetPVarInt(playerid, "AdminDuty")==1) 
		{
			SetPlayerHealth(playerid, 50000);
			Update3DTextLabelText(gPlayerInfo[playerid][p3DText],COLOR_PINK,"Admin on duty!\nDon't attack!");
		}
		else
		{
			new string[128];
			String("%s %s",gRankName[gPlayerInfo[playerid][pRank]],gClassName[gPlayerInfo[playerid][pClass]]);
			SetPlayerHealth(playerid,gRankHealth[gPlayerInfo[playerid][pRank]]);
			SetPlayerArmour(playerid,gRankArmor[gPlayerInfo[playerid][pRank]]);
			SendClientMessage(playerid,COLOR_PINKRED,"Spawn protection is over!");
			Update3DTextLabelText(gPlayerInfo[playerid][p3DText],gTeam[gPlayerInfo[playerid][pTeam]][tColor],string);
		}
	}
}

PUB:EndSKDuel(playerid)
{
	new string[128];
	String("%s %s",gRankName[gPlayerInfo[playerid][pRank]],gClassName[gPlayerInfo[playerid][pClass]]);
	SetPlayerHealth(playerid,99);
	SetPlayerArmour(playerid,99);
	Update3DTextLabelText(gPlayerInfo[playerid][p3DText],gTeam[gPlayerInfo[playerid][pTeam]][tColor],string);
}

public strike(playerid,Float:cX,Float:cY,Float:cZ)
{
	CreateExplosion(cX, cY, cZ, 7, 100);
	CreateExplosion(cX+5, cY, cZ, 7, 100);
	CreateExplosion(cX, cY+5, cZ, 7, 100);
	CreateExplosion(cX-5, cY, cZ, 7, 100);
	CreateExplosion(cX, cY-5, cZ, 7, 100);
	CreateExplosion(cX+10, cY, cZ, 7, 100);
	CreateExplosion(cX, cY+10, cZ, 7, 100);
	GameTextForPlayer(playerid,"~r~~h~Area exploded~n~~g~Air strike successful!", 1500, 3);
}

public OnRconLoginAttempt(ip[], password[], success)
{
    if(!success)
    {
        new string[128];
    	foreach(Player, i)
        {
            if(strcmp(ip,gPlayerInfo[i][pIp])) continue;
            String("[AUTOBAN] %s was banned for a failed RCON attempt",gPlayerInfo[i][pName]);
			SendClientMessageToAll(COLOR_YELLOW,string);
			new query[256];
			new year, month, day;
			getdate(year, month, day);
			new hour, minute, second;
			gettime(hour, minute, second);
			new escname[24];
			mysql_real_escape_string(gPlayerInfo[i][pName],escname);
			new timestring[20];
			format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
			Query("INSERT INTO bans (nick,time,reason,bannedby,IP) VALUES ('%s','%s','RCON fail','%s','%s')",escname,timestring,BOT_NAME,ip);
			mysql_query(query);
			printf("FAILED RCON LOGIN! name: %s | IP: %s| pass: %s",gPlayerInfo[i][pName],ip,password);
			Kick(i);
        }
    }
    return 1;
}

UpdateRank(playerid)
{
	new rank;
	for (rank=MAX_RANKS-1;rank>=0;rank--) if (gPlayerInfo[playerid][pScore]>=gRankScore[rank]) break;
	gPlayerInfo[playerid][pRank]=rank;
	SetPlayerWantedLevel(playerid,rank);
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPVarInt(playerid, "Frozen") == 1) TogglePlayerControllable(playerid, false);

	/*
		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && GetPVarInt(playerid, "CurrentID") != INVALID_PLAYER_ID )
		{
			if(newkeys & KEY_JUMP) AdvanceSpectate(playerid);
			else if(newkeys & KEY_SPRINT) ReverseSpectate(playerid);
			else if(newkeys & KEY_FIRE) AdvanceSpectate(playerid);
			else if(newkeys & KEY_HANDBRAKE) ReverseSpectate(playerid);
			else if(newkeys & KEY_CROUCH) StopSpectate(playerid);
			if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && GetPVarInt(playerid, "CurrentiD") == INVALID_PLAYER_ID ) return AdvanceSpectate(playerid);
		}
	*/
	
	if(newkeys & KEY_CROUCH && GetPlayerState(playerid)==PLAYER_STATE_SPECTATING) StopSpectate(playerid);
	if(GetPVarInt(playerid, "aFly") == 1)
	{
		new Float:X, Float:Y, Float:Z,Float:VX, Float:VY, Float:VZ,Float:pAng, animlib[32], animname[32];
	    GetPlayerCameraFrontVector(playerid, VX, VY, VZ);
	    GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, 32, animname, 32);
	    if(strlen(animlib) && !strcmp(animlib, "ped", true, 3))
	    {
        	if (newkeys & KEY_SPRINT)
            {
                SetPVarInt(playerid, "NoAB", 3);
                GetPlayerFacingAngle(playerid, pAng);
                GetPlayerVelocity(playerid, X, Y, Z);
                SetPlayerVelocity(playerid, floatsin(-pAng, degrees) * 1.6, floatcos(pAng, degrees) * 1.6 , (Z*2)+0.03);
            }
	    }
	}
	
	if(newkeys & KEY_CROUCH) {
	    if(GetPVarInt(playerid, "RC") == 1) {
            if(!IsPlayerInAnyVehicle(playerid)) {
                new Float:OrgX, Float:OrgY, Float:OrgZ;
    			GetPlayerPos(playerid, OrgX,OrgY,OrgZ);
                SetPVarInt(playerid, "RCc",CreateVehicle(441,OrgX,OrgY,OrgZ,0,0,0,0));
                SetVehicleHealth(GetPVarInt(playerid, "RCc"),250);
                PutPlayerInVehicle(playerid,GetPVarInt(playerid, "RCc"),0);
                LinkVehicleToInterior(GetPVarInt(playerid, "RCc"),0);
                SetPVarInt(playerid,"ERC",1);
                DeletePVar(playerid, "RC");
                SetPVarFloat(playerid,"OrgX",OrgX);
            	SetPVarFloat(playerid,"OrgY",OrgY);
            	SetPVarFloat(playerid,"OrgZ",OrgZ);
                SendClientMessage(playerid,COLOR_LIMEGREEN,"RCXD Spawned! Press 2 to explode the RC-XD!");
            } else return SendClientMessage(playerid,COLOR_RED,"You cannot be in a vehicle and have an RC-XD!");
		}
	}
	
	if(newkeys & KEY_SUBMISSION) {
	    if(GetPVarInt(playerid,"ERC") == 1) {
            SetPVarInt(playerid, "ERC", 0);
            new Float:x,Float:y,Float:z;
            GetPlayerPos(playerid,x,y,z);
            RemovePlayerFromVehicle(playerid);
            DestroyVehicle(GetPVarInt(playerid, "RCc"));
            DeletePVar(playerid, "RCc");
            SetPVarFloat(playerid,"X",x);
            SetPVarFloat(playerid,"Y",y);
            SetPVarFloat(playerid,"Z",z);
            SetPVarInt(playerid, "NoAB", 4);
			SetPlayerPos(playerid, x, y, z+5 );
            SetPlayerPos(playerid,GetPVarFloat(playerid,"OrgX"),GetPVarFloat(playerid,"OrgY"),GetPVarFloat(playerid,"OrgZ"));
            defer RCexplode(playerid);
        }
	}
	
    if(newkeys & KEY_SECONDARY_ATTACK) {
        new vid = GetPlayerVehicleID(playerid);
        new Float:hp;
        GetVehicleHealth(vid, hp);
        if(IsAircraft( GetVehicleModel(vid) )  && hp < 251)
        {
  	    	new Float:X, Float:Y, Float:Z;
	    	GetPlayerPos(playerid, X, Y, Z);
	    	SetPVarInt(playerid, "NoAB", 4);
	    	SetPlayerPos(playerid, X, Y , Z + 40);
			GivePlayerWeaponEx(playerid, 46, 1);
	    	SendClientMessage(playerid, COLOR_RED, "Emergency ejected!");
		}
	}
	
	if(newkeys & KEY_FIRE && IsBombPlane(GetVehicleModel(GetPlayerVehicleID(playerid))) && GetPVarInt(playerid, "AdminDuty") == 0 )
	{
		new vid = GetPlayerVehicleID(playerid);
		if(bombs[vid] < 1) return SendClientMessage(playerid, COLOR_ORANGE, "There are no bombs remaining in this plane.");
		
		//code included in the event you want to limit the players able to use bombs
		//if(GetPlayerScore(playerid) >= 750) return SendClientMessage(playerid, COLOR_RED, "You can't use these bombs!");
		
		if(bombable[playerid] == 1) {
			new Float:x, Float:y, Float:z, Float:ground;
			GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
			ground = GetPointZPos(x, y);
			bomb[playerid] = CreateObject(1636, x, y + 10, z, 0, 0, 0);
			new time = MoveObject(bomb[playerid], x, y + 1, ground, 40);
			SetTimerEx("Detonate", time, 0, "ii", playerid, bomb[playerid]);
			bombable[playerid] = 0;
			bombs[vid]--;
			new string[128];
			String("Bomb away, bomb away! remaining bombs: %d.", bombs[vid]);
			SendClientMessage(playerid, -1, string);
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "Wait for your bomb to detonate!");
		}
	}
	return 1;
}

timer RCexplode[300](playerid)
{
	CreateExplosion(GetPVarFloat(playerid, "X"),GetPVarFloat(playerid, "Y"),GetPVarFloat(playerid, "Z"), 7, 30.0);
	foreach(Player, i) //loop
 	{
    	if(IsPlayerInRangeOfPoint(i,15,GetPVarFloat(playerid, "X"),GetPVarFloat(playerid, "Y"),GetPVarFloat(playerid, "Z"))) 
		{ 
     		if(i != playerid && GetPVarInt(i, "AdminDuty") == 0) {
        		new string[100];
        		SetPlayerHealth(i,0); //sets their health
        		SendDeathMessage(playerid,i,53); //sends an explosion death message.
        		SetPVarInt(playerid,"RCDeath",1);
        		String("You have killed %s(%d) with your RC-XD. You got +1 score.",gPlayerInfo[i][pName], i);
        		SendClientMessage(playerid,COLOR_LIMEGREEN,string);
        		GivePlayerScoreSync(playerid,1);
			}
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(GetTickCount() - armedbody_pTick[playerid] > 113){
		new weaponid[13],weaponammo[13],pArmedWeapon;
		pArmedWeapon = GetPlayerWeapon(playerid);
		GetPlayerWeaponData(playerid,1,weaponid[1],weaponammo[1]);
		GetPlayerWeaponData(playerid,2,weaponid[2],weaponammo[2]);
		GetPlayerWeaponData(playerid,4,weaponid[4],weaponammo[4]);
		GetPlayerWeaponData(playerid,5,weaponid[5],weaponammo[5]);
		if(weaponid[1] && weaponammo[1] > 0){
			if(pArmedWeapon != weaponid[1]){
				if(!IsPlayerAttachedObjectSlotUsed(playerid,0)){
					SetPlayerAttachedObject(playerid,0,GetWeaponModel(weaponid[1]),1, 0.199999, -0.139999, 0.030000, 0.500007, -115.000000, 0.000000, 1.000000, 1.000000, 1.000000);
				}
			}
			else {
				if(IsPlayerAttachedObjectSlotUsed(playerid,0)){
					RemovePlayerAttachedObject(playerid,0);
				}
			}
		}
		else if(IsPlayerAttachedObjectSlotUsed(playerid,0)){
			RemovePlayerAttachedObject(playerid,0);
		}
		if(weaponid[2] && weaponammo[2] > 0){
			if(pArmedWeapon != weaponid[2]){
				if(!IsPlayerAttachedObjectSlotUsed(playerid,1)){
					SetPlayerAttachedObject(playerid,1,GetWeaponModel(weaponid[2]),8, -0.079999, -0.039999, 0.109999, -90.100006, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
				}
			}
			else {
				if(IsPlayerAttachedObjectSlotUsed(playerid,1)){
					RemovePlayerAttachedObject(playerid,1);
				}
			}
		}
		else if(IsPlayerAttachedObjectSlotUsed(playerid,1)){
			RemovePlayerAttachedObject(playerid,1);
		}
		if(weaponid[4] && weaponammo[4] > 0){
			if(pArmedWeapon != weaponid[4]){
				if(!IsPlayerAttachedObjectSlotUsed(playerid,2)){
					SetPlayerAttachedObject(playerid,2,GetWeaponModel(weaponid[4]),7, 0.000000, -0.100000, -0.080000, -95.000000, -10.000000, 0.000000, 1.000000, 1.000000, 1.000000);
				}
			}
			else {
				if(IsPlayerAttachedObjectSlotUsed(playerid,2)){
					RemovePlayerAttachedObject(playerid,2);
				}
			}
		}
		else if(IsPlayerAttachedObjectSlotUsed(playerid,2)){
			RemovePlayerAttachedObject(playerid,2);
		}
		if(weaponid[5] && weaponammo[5] > 0){
			if(pArmedWeapon != weaponid[5]){
				if(!IsPlayerAttachedObjectSlotUsed(playerid,3)){
					SetPlayerAttachedObject(playerid,3,GetWeaponModel(weaponid[5]),1, 0.200000, -0.119999, -0.059999, 0.000000, 206.000000, 0.000000, 1.000000, 1.000000, 1.000000);
				}
			}
			else {
				if(IsPlayerAttachedObjectSlotUsed(playerid,3)){
					RemovePlayerAttachedObject(playerid,3);
				}
			}
		}
		else if(IsPlayerAttachedObjectSlotUsed(playerid,3)){
			RemovePlayerAttachedObject(playerid,3);
		}
		armedbody_pTick[playerid] = GetTickCount();
	}
	
	//FPS
	new drunknew;
    drunknew = GetPlayerDrunkLevel(playerid);
    if (drunknew < 100) { // go back up, keep cycling.
        SetPlayerDrunkLevel(playerid, 2000);
    } else {
        
        if (pDrunkLevelLast[playerid] != drunknew) {
            
            new wfps = pDrunkLevelLast[playerid] - drunknew;
            
            if ((wfps > 0) && (wfps < 200))
                pFPS[playerid] = wfps;
            
            pDrunkLevelLast[playerid] = drunknew;
        }
        
    }
	//EO FPS
	
	iAFKp[playerid] = 0;
	return true;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	//update the marker on the radar
    if (GetPVarInt(playerid,"AdminDuty")==1) ShowPlayerMarkerForPlayer(forplayerid,playerid);
    else if (gPlayerInfo[playerid][pClass]==CLASS_SNIPER) HidePlayerMarkerForPlayer(forplayerid,playerid);
	else ShowPlayerMarkerForPlayer(forplayerid,playerid);
    return 1;
}

/*

stock AdvanceSpectate(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && GetPVarInt(playerid, "CurrentID") != INVALID_PLAYER_ID)
	{
	    for(new x=GetPVarInt(playerid, "CurrentID")+1; x<=MAX_PLAYERS; x++)
		{
	    	if(x == MAX_PLAYERS) x = 0;
	        if(  x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && GetPVarInt(playerid, "CurrentID") != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}
				else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}

stock ReverseSpectate(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && GetPVarInt(playerid, "CurrentID") != INVALID_PLAYER_ID)
	{
	    for(new x=GetPVarInt(playerid, "CurrentID")-1; x>=0; x--)
		{
	    	if(x == 0) x = MAX_PLAYERS;
	        if(  x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && GetPVarInt(playerid, "CurrentID") != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}
				else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}

stock StartSpectate(playerid, id)
{
	if (!gPlayerInfo[playerid][pOp] && !gPlayerInfo[playerid][pAlevel])
	    return accessdenied(playerid);
	if (gPlayerInfo[playerid][pSpawned] == 0)
		return SendClientMessage(playerid, COLOR_RED, "You must be spawned to start spectating.");
    TogglePlayerSpectating( playerid, 1 );
	if (!IsPlayerInAnyVehicle(id)) PlayerSpectatePlayer(playerid,id,SPECTATE_MODE_NORMAL);
	else PlayerSpectateVehicle(playerid,GetPlayerVehicleID(id));
	new string[150],Float:ar,Float:hp;
	GetPlayerHealth(id,hp);
	GetPlayerArmour(id,ar);
	SetPlayerInterior(playerid,GetPlayerInterior(id));
	SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(id));
	SetPVarInt( playerid, "Spec", 1 );
	SetPVarInt( playerid, "CurrentID", id );
	String("~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~w~%s - id:%d~n~hp:%0.1f ar:%0.1f~n~$%d ($%d) score:%i",gPlayerInfo[id][pName],id,hp,ar,gPlayerInfo[id][pMoney],GetPlayerMoney(id),GetPlayerScore(id) );
	GameTextForPlayer(playerid,string,25000,4);
	return 1;
}
*/

stock StopSpectate(playerid)
{
    TextDrawShowForPlayer(playerid, txtStats[playerid]);
	TogglePlayerSpectating(playerid, 0);
	GameTextForPlayer(playerid, "a",1,5);
	SetPVarInt(playerid, "Spec", 0);
	if(GetPVarInt(playerid, "AdminDuty") == 1)
		ADutyFunctions(playerid);
	return 1;
}

stock AddLog(playerid,action[],info[])
{
	new einfo[24],ename[24],query[300];
	mysql_real_escape_string(gPlayerInfo[playerid][pName],ename);
	mysql_real_escape_string(info,einfo);
	Query("INSERT INTO `logs` (`nick,`time,`action,`info`) VALUES ('%s','UNIX_TIMESTAMP()','%s','%s')",ename,action,ename2);
	mysql_query(Query);
	return 1;
}

task RemoveTBans[3600000]()
{
	new query[250];
	Query("DELETE FROM `bans` WHERE `unban` BETWEEN '10000' AND '%i'",gettime());
	mysql_query(query);
	return 1;
}

stock GivePlayerWeaponEx(playerid,weaponid,ammo)
{
    Weapon[playerid][weaponid] = true;
    GivePlayerWeapon(playerid,weaponid,ammo);
}

stock ResetPlayerWeaponsEx(playerid)
{
    for(new i=0;i<47;i++) Weapon[playerid][i] = false;
	ResetPlayerWeapons(playerid);
}

stock GetWeaponModel(weaponid)
{
	switch(weaponid)
	{
	    case 1:
	        return 331;
		case 2..8:
		    return weaponid+331;
        case 9:
		    return 341;
		case 10..15:
			return weaponid+311;
		case 16..18:
		    return weaponid+326;
		case 22..29:
		    return weaponid+324;
		case 30,31:
		    return weaponid+325;
		case 32:
		    return 372;
		case 33..45:
		    return weaponid+324;
		case 46:
		    return 371;
	}
	return 0;
}

PUB:HackCheck(playerid) {
	new Float:x, Float:y, Float:z;
	GetPlayerCameraFrontVector(playerid, x, y, z);
	#pragma unused x
	#pragma unused y
	if(z < -0.8) {
	    SendClientMessage(playerid, -1, "Processed successfully.");
	    gPlayerInfo[playerid][pHacker] = 1;
	    new string[100];
     	String("[ANTICHEAT] Player %s[%d] has possibly connected with s0beit!",gPlayerInfo[playerid][pName], playerid);
		print(string);
		foreach(Player, i) {
		    if(gPlayerInfo[i][pAlevel] > 0) {
		        SendClientMessage(i, COLOR_RED, string);
			}
		}
	}
	else {
	    SendClientMessage(playerid, -1, "Processed successfully.");
	}
 	TogglePlayerControllable(playerid, 1);
	return 1;
}

task PMessage[300000]()
{
    new string[128];
    switch(LastPMessage)
    {
        case 0: format(string,sizeof(string),"[%s]: %s",BOT_NAME, Pmessage0);
        case 1: format(string,sizeof(string),"[%s]: %s",BOT_NAME, Pmessage1);
        case 2: format(string,sizeof(string),"[%s]: %s",BOT_NAME, Pmessage2);
        case 3: format(string,sizeof(string),"[%s]: %s",BOT_NAME, Pmessage3);
        case 4: format(string,sizeof(string),"[%s]: %s",BOT_NAME, Pmessage4);
    }
    SendClientMessageToAll(COLOR_PINK,string);
    LastPMessage++;
    if(LastPMessage > 4) LastPMessage = 0;
}

timer AResetVHealth[1350](vehicleid) {
	SetVehicleHealth(vehicleid, 1000);
}

timer KickPublic[50](playerid) { 
	Kick(playerid); 
}

KickWithMessage(playerid, message[])
{
	SendClientMessage(playerid, COLOR_RED, message);
	defer KickPublic(playerid);
}

AntiAirbreak(playerid)
{
	new Float:pos[3], i = playerid, str[128];
	GetPlayerPos(i, pos[0], pos[1], pos[2]);
 	if(GetPlayerSurfingVehicleID(i) == INVALID_VEHICLE_ID && !IsPlayerInAnyVehicle(i) && GetPlayerState(i) == PLAYER_STATE_ONFOOT && GetPlayerSpecialAction(i) != 2 && GetPlayerState(i) != PLAYER_STATE_SPAWNED)
  	{
   		if(GetPVarInt(i, "NoAB") == 0)
     	{
    		switch(GetPlayerAnimationIndex(i))
			{
				case 958, 959, 961, 962, 965, 971, 1126, 1130, 1132, 1134, 1156, 1208:
				{
					SetPVarInt(playerid, "NoAB", 3);
					return 0;
				}
			}
			if(pos[2] < GetPVarFloat(playerid, "OldPosZ")) return 0;
			if
			(
				(floatabs(pos[0] - GetPVarFloat(playerid, "OldPosX"))) > DYS || (floatabs(GetPVarFloat(playerid, "OldPosX") - pos[0])) > DYS ||
				(floatabs(pos[1] - GetPVarFloat(playerid, "OldPosY"))) > DYS || (floatabs(GetPVarFloat(playerid, "OldPosY") - pos[1])) > DYS ||
				(floatabs(pos[2] - GetPVarFloat(playerid, "OldPosZ"))) > DYS/2 || (floatabs(GetPVarFloat(playerid, "OldPosZ") - pos[2])) > DYS/2
			)
			{
				format(str, sizeof str, "[ANTICHEAT] [%i]%s is possibly teleporting/airbreaking! (%i)",i,gPlayerInfo[i][pName]), GetPlayerAnimationIndex(i); //GetPlayerAnimationIndex(i)
			    foreach(Player,j) if (gPlayerInfo[j][pAlevel]>0 || Undercover[j]==1) SendClientMessage(j,COLOR_RED,str);
				print(str);
			}
			DeletePVar(playerid, "NoAB");
		}
		else
		{
		    SetPVarInt(playerid, "NoAB", GetPVarInt(playerid, "NoAB")-1);
		}
		SetPVarFloat(playerid, "OldPosX", pos[0]);
		SetPVarFloat(playerid, "OldPosY", pos[1]);
		SetPVarFloat(playerid, "OldPosZ", pos[2]);
	}
	return 1;
}

public OnPlayerCleoDetected(playerid, cleoid)
{
	if(!gPlayerInfo[playerid][pAlevel] && !Kicked[playerid])
	{
		new query[256], string[128], ip[16], i = playerid;
		new year, month, day;
		getdate(year, month, day);
		new hour, minute, second;
		gettime(hour, minute, second);
		new escname[24];
		mysql_real_escape_string(gPlayerInfo[playerid][pName], escname);
		new timestring[20];
		format(timestring, sizeof timestring, "%i-%i-%i %i:%i:%i", year, month, day, hour, minute, second);
	    GetPlayerIp(playerid, ip, sizeof(ip));
	    switch(cleoid)
	    {
	        case CLEO_FAKEKILL:
	        {
				String("[AUTOBAN] %s has been banned for fake killing.",gPlayerInfo[i][pName]);
				SendClientMessageToAll(COLOR_YELLOW, string);
				format( query, sizeof query, "INSERT INTO bans (nick, time, reason, bannedby, IP) VALUES ('%s', '%s', 'fake kill', '%s', '%s')", escname, timestring, BOT_NAME, ip );
				mysql_query(query);
				Kick(i);
				return 1;
	        }
	        case CLEO_CARWARP:
	        {
				String("[AUTOBAN] %s has been banned for car warping.",gPlayerInfo[i][pName]);
				SendClientMessageToAll( COLOR_YELLOW, string );
				format( query, sizeof query, "INSERT INTO bans (nick, time, reason, bannedby, IP) VALUES ('%s', '%s', 'car warping', '%s', '%s')", escname, timestring, BOT_NAME, ip );
				mysql_query(query);
				Kick(i);
				return 1;
	        }
	        case CLEO_CARSWING:
	        {
				String("[AUTOBAN] %s has been banned for car swinging.",gPlayerInfo[i][pName]);
				SendClientMessageToAll(COLOR_YELLOW, string);
				format( query, sizeof query, "INSERT INTO bans (nick, time, reason, bannedby, IP) VALUES ('%s', '%s', 'car swinging', '%s', '%s')", escname, timestring, BOT_NAME, ip );
				mysql_query(query);
				KickWithMessage(i, "You have been banned for car swinging. If you think this is a mistake, you may appeal at www.sector7gaming.com/forums.");
				return 1;
	        }
	        case CLEO_CAR_PARTICLE_SPAM:
	        {
				String("[AUTOBAN] %s has been banned for particle spamming.",gPlayerInfo[i][pName]);
				SendClientMessageToAll(COLOR_YELLOW, string);
				format( query, sizeof query, "INSERT INTO bans (nick, time, reason, bannedby, IP) VALUES ('%s', '%s', 'particle spamming', '%s', '%s')", escname, timestring, BOT_NAME, ip );
				mysql_query(query);
				KickWithMessage(i, "You have been banned for particle spamming. If you think this is a mistake, you may appeal at www.sector7gaming.com/forums.");
				return 1;
	        }
	    }
	    Kicked[playerid] = 1;
	}
    return 1;
}

AntiDeAMX()
{
    new a[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused a
}

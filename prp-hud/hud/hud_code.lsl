key owner; // We get the owner UUID
integer channelDialog; // The Channel that all Menus Communicate on
integer CommandChannel;
integer listenId; integer listenId_b; integer listenId_c; integer listenId_d;integer listenId_e;integer listenId_f; integer listenId_g;
integer chatListen;


integer channelDialog_newCharacter;
integer channelDialog_Dice;
integer channelDialog_newAnimation; 
integer channelDialog_Follow; 
integer channelDialog_removeCharacter;
integer titlerDialog;
integer channelDialog_Title;
integer channelDialog_Titler;
list integers = ["-","0","1","2","3","4","5","6","7","8","9"];

// Http API Calls
string apiPath = "https://prp-hud.herokuapp.com/api/";
key httprequest;

// Hud Starting Locations
list HudLoc = [];
list HudParts = [2,4,5,6,7,8,9,10,11];
integer HudButton = 3;
vector ButtonLoc = <0,0,0>;
vector vOffset = <0.0,1.0,0.0>;  
integer hidden = 1;
list lAllPositions = [
<0.000815, 0.053479, -0.111059>,
<3.50000, 0.05258, 0.00086>,
<0.000000, 0.043062, -0.228129>,
<0.000000, 0.063837, -0.228129>,
<0.000000, 0.053523, -0.199657>,
<0.000000, 0.053523, -0.156232>,
<0.000000, 0.053523, -0.112986>,
<0.000000, 0.053523, -0.070315>,
<0.000000, 0.053523, -0.027759>,
<0.000000, 0.041391, 0.000000>
];

// Functionality Vars
integer CombatOn = FALSE; // Combat Outfit Tracking
list CombatAnimations; // Animation Lists
list SocialAnimations; // Animation Lists
list RPAnimations; // Animation Lists
list Characters; // The Characters available.
string CharacterData;
list Titlers;
list TitlerNames;
string Titler;
string CharacterName;

// Animation Vars
list currentAO;
string animation2start;
float animRun = 0.20;
string currentAnimation = "";
integer perms = 0;
integer cycles = 0;         // Cycles to run in the current iteration;
integer passes = 0;         // Number of passes that have been made

//Follow
integer following = 0;
list targets;

// Titler Vars
string activeTitler = "";
integer titlerOn = 0;

// System Functions
init()
{
    // Set Data and prep
    owner = llGetOwner();
    channelDialog  = (integer)("0xF" + llGetSubString(llGetOwner(),0,6));
    channelDialog_newCharacter  = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 1;
    channelDialog_Dice = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 2;
    channelDialog_newAnimation = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 3;
    channelDialog_Follow = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 4;
    channelDialog_removeCharacter = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 5;
    channelDialog_Title =(integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 6;
    channelDialog_Titler = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 7;
    CombatAnimations = [];
    titlerDialog = (integer)("0xF" + llGetSubString( owner, 0, 6) ) + 10;
    SocialAnimations = [];
    RPAnimations = [];
    httprequest = NULL_KEY;
                
    setDefaultHud();
    
    getHudLoc();
    getHudButton();
    llSetLinkPrimitiveParamsFast(HudButton, [PRIM_POS_LOCAL,ButtonLoc - vOffset]);
    getHudButton();
    
    createHud();
    CharacterName = llGetObjectDesc();        
    if(CharacterName != "(No Description)" && CharacterName != "")
    {
        // If a Character is set we load the characters data.
        getCharacterData();  
        hideHud();           
    } else {
        getHudData();   
    }
}

// Set the Default Hud Positioning
setDefaultHud()
{
        llSetLinkPrimitiveParamsFast(LINK_SET, [ 
        PRIM_LINK_TARGET, 2, PRIM_POS_LOCAL, llList2Vector(lAllPositions,0),
        PRIM_LINK_TARGET, 3, PRIM_POS_LOCAL, llList2Vector(lAllPositions,1), 
        PRIM_LINK_TARGET, 4, PRIM_POS_LOCAL, llList2Vector(lAllPositions,2),   
        PRIM_LINK_TARGET, 5, PRIM_POS_LOCAL, llList2Vector(lAllPositions,3),  
        PRIM_LINK_TARGET, 6, PRIM_POS_LOCAL, llList2Vector(lAllPositions,4),  
        PRIM_LINK_TARGET, 7, PRIM_POS_LOCAL, llList2Vector(lAllPositions,5),
        PRIM_LINK_TARGET, 8, PRIM_POS_LOCAL, llList2Vector(lAllPositions,6),
        PRIM_LINK_TARGET, 9, PRIM_POS_LOCAL, llList2Vector(lAllPositions,7),
        PRIM_LINK_TARGET, 10, PRIM_POS_LOCAL, llList2Vector(lAllPositions,8),
        PRIM_LINK_TARGET, 11, PRIM_POS_LOCAL, llList2Vector(lAllPositions,9)
        ]);  
}

hideHud()
{
    if(hidden == 1)
    {
        list newpositions = [];
        integer i = 0;
        while(i < llGetListLength(HudParts)) {
            newpositions += [34, llList2Integer(HudParts,i), PRIM_POS_LOCAL, llList2Vector(HudLoc,i) - vOffset];
            i++;
        }
        llSetLinkPrimitiveParamsFast(LINK_SET, newpositions);
        llSetLinkPrimitiveParamsFast(LINK_SET, [34,HudButton, PRIM_POS_LOCAL, ButtonLoc + vOffset]);
        hidden = 0;
    }
}

showHud()
{  
    if(hidden == 0)
    {
        list newpositions = [];
        integer i = 0;
        while(i < llGetListLength(HudParts)) {
            newpositions += [34, llList2Integer(HudParts,i), PRIM_POS_LOCAL, llList2Vector(HudLoc,i)];
            i++;
        }
        llSetLinkPrimitiveParamsFast(LINK_SET, newpositions);
        llSetLinkPrimitiveParamsFast(LINK_SET, [34,HudButton, PRIM_POS_LOCAL, ButtonLoc - vOffset]);
        hidden = 1;            
    }           
} 

getHudLoc()
{        
    integer i = 0;
    while(i < llGetListLength(HudParts)) {
        HudLoc += [ llList2Vector( llGetLinkPrimitiveParams( llList2Integer(HudParts,i), [ PRIM_POS_LOCAL ] ), 0) ];
        i++;
    }
}

getHudButton()
{
    ButtonLoc = llList2Vector(llGetLinkPrimitiveParams( HudButton, [ PRIM_POS_LOCAL ] ),0);
}

HandleError(integer status, string body, string source)
{
    if(status > 500 && status < 600) // when 4XX or 5XX
    {
        string errorStr = llJsonGetValue(body, ["error"]);
        string errorCode = llJsonGetValue(errorStr, ["code"]);
        string errorMessage = llJsonGetValue(errorStr, ["message"]);

        llOwnerSay("ERROR CONTACT TO THE OWNER [" + "HTTPStatus: " + 
            (string)status + ", code: " + errorCode + ", message: " + errorMessage + ", source:" + source + "]");

    }
    // else: continue
}

// Dynamic Menus
showCharacterChoices() {  
   llDialog(owner, "Choose A Character:", Characters , channelDialog);
   listenId = llListen(channelDialog, "", owner, "");  
}
removeCharacter() {
   list tempChars = [];
   integer index = 0;
   for (index = 0;index < llGetListLength(Characters);index++)
   {
       if(llList2String(Characters, index) != CharacterName)
       {
            tempChars += [llList2String(Characters, index)]; 
       }
   }
    
   llDialog(owner, "Choose A Character to remove, this can not be undone:", tempChars, channelDialog_removeCharacter);
   listenId_f = llListen(channelDialog_removeCharacter, "", owner, "");      
   tempChars = [];
}

// API Functions
createHud() {
    llOwnerSay("Initializing Hud");
    list requestvars = ["id",(string)owner,"account",llGetUsername(owner),"active",1];
    httprequest = llHTTPRequest(apiPath + "hud", [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],llList2Json(JSON_OBJECT,requestvars)); 
}
fetchCharacterList() {
    httprequest = llHTTPRequest(apiPath + "character/" + (string)owner, [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");         
}
getCharacterData()  {
    httprequest = llHTTPRequest(apiPath + "character/" + (string)owner + "/" + CharacterName, [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");    
}
getHudData() {
    httprequest = llHTTPRequest(apiPath + "hud/" + (string)owner, [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");     
}
addCharacter(string name) {
    list requestvars = ["hudid",(string)owner,"name",name,"commandchannel",2,"combatanimations","","socialanimations","","rpanimations",""];
    httprequest = llHTTPRequest(apiPath + "character", [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],llList2Json(JSON_OBJECT,requestvars));         
}
deleteCharacter(string name) {
    httprequest = llHTTPRequest(apiPath + "character/" + (string)owner + "/" + name, [HTTP_METHOD, "DELETE", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");
    fetchCharacterList();    
}
setupCharacter() {
    llTextBox(owner, "Enter Name for Character", channelDialog_newCharacter);  
    listenId_b = llListen(channelDialog_newCharacter, "", owner, ""); 
}
setAnimations() {
    llTextBox(owner, "Enter animations in the following format combat|social|rp:animation1,animation2,etc", channelDialog_newAnimation);  
    listenId_b = llListen(channelDialog_newAnimation, "", owner, "");       
}
disableHud() {
    httprequest = llHTTPRequest(apiPath + "titler/"+llJsonGetValue(CharacterData,["id"])+"/disable", [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");
}
enableHud() {
    httprequest = llHTTPRequest(apiPath + "titler/"+llJsonGetValue(CharacterData,["id"])+"/enable", [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");
}
addAnimationString(string animations) {    
    list elemts = llParseString2List(animations, ["|"],[]);
    string class = llList2String(elemts, 0);
    string csvList = llList2String(elemts, 1);    
    if(class == "combat" || class == "social" || class == "rp") 
    {
        list requestvars = [class+"animations",csvList];
        httprequest = llHTTPRequest(apiPath + "character/" + (string)owner + "/" + CharacterName, [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],llList2Json(JSON_OBJECT,requestvars));         
    }
}

// Animation Code
StopAnimations(){
    integer list_pos = 0;
    integer list_length = llGetListLength(currentAO);
    if(list_length > 0){
        while(list_pos < list_length){
            llStopAnimation(llList2String(currentAO, list_pos));
            list_pos++;
        }
    }
}

StopAnimation()
{
   if(currentAnimation != "") 
   {       
       perms = llGetPermissions();
       if(perms & PERMISSION_TRIGGER_ANIMATION)
       { 
           llStopAnimation(currentAnimation);           
           llResetAnimationOverride("ALL");
           llStartAnimation(animation2start);
           currentAnimation = "";
        }
   }
}

StartAnimation() 
{
    perms = llGetPermissions();
    if(perms & PERMISSION_TRIGGER_ANIMATION)
    {      
        llStartAnimation(currentAnimation);
    }

} 

list GetCurrentAnimation() {
    animation2start = llGetAnimationOverride(llGetAnimation(owner));
    return llGetAnimationList(owner);
}
   
// Dice Functions
RollDice()
{
    listenId = llListen(channelDialog_Dice, "", "", "");     
    llTextBox(owner, "Roll a 1d100, leave blank or enter a number to modify (max 20)", channelDialog_Dice);       
} 
    
ProcessDice(string bonus)
{    
    integer calc_bonus = 0;
    integer Flag = TRUE;        
    integer i;        
    for (i=0;i<llStringLength(bonus);++i)        {            
        if (llGetSubString(bonus,i,i) == llUnescapeURL("%0A"))            
        {                
            if (i == llStringLength(bonus) -1)                
            {                    
                bonus = llGetSubString(bonus, 0,-2);                                
            }                
            else                
            {                    
                llOwnerSay("The bonus must contain positive and negative numbers only.");                    
                Flag = FALSE;                
            }            
        }            
        else if (( !~llListFindList(integers,[llGetSubString(bonus,i,i)] )) || ((~llListFindList(["+","-"],[llGetSubString(bonus,i,i)])) && (i != 0)))            
        {                
            llOwnerSay("The bonus must contain positive and negative numbers only.");                 
            Flag = FALSE;            
        }                    
    }        
    if (Flag)        
    {            
        if(bonus != "") {
            calc_bonus = (integer)bonus;      
        }
        integer roll = (integer) llFrand(100.0) + calc_bonus;
        if(CharacterName != "") {
            llSay(0,"Roll Made by "+CharacterName+": " + (string) roll + "("+(string)calc_bonus+")");  
        } else {
            llSay(0,"Roll Made by "+llKey2Name(owner)+": " + (string) roll + "("+(string)calc_bonus+")");  
        }
        
    }   
}

// Chat Relay
Relay_Chat(string message)
{
    // save the old name of the object for later use
    string oldname = llGetObjectName();
    // get the words (split by spaces) in the message
    list messageParts = llParseString2List(message, [" "], []);
    if(llList2String(messageParts,0) == "/me")
    {
        if(llSubStringIndex(message, "%n") != -1)
        {                
            // Replace %n with character name                
            messageParts = llDeleteSubList(messageParts,0,0);
            message = llDumpList2String(messageParts, " ");
            message = strReplace(message, "\%n", CharacterName);
            mySay("", message); 
            
        } else {
            //  Just a Me Statement
            messageParts = llDeleteSubList(messageParts,0,0);
            mySay(CharacterName, llDumpList2String(messageParts, " "));                
        }
    }
    else
    {
        mySay(CharacterName, " says \"" + llDumpList2String(messageParts, " ") + "\"");  
    }      
}

string strReplace(string source, string pattern, string replace) {
    while (llSubStringIndex(source, pattern) > -1) {
        integer len = llStringLength(pattern);
        integer pos = llSubStringIndex(source, pattern);
        if (llStringLength(source) == len) { source = replace; }
        else if (pos == 0) { source = replace+llGetSubString(source, pos+len, -1); }
        else if (pos == llStringLength(source)-len) { source = llGetSubString(source, 0, pos-1)+replace; }
        else { source = llGetSubString(source, 0, pos-1)+replace+llGetSubString(source, pos+len, -1); }
    }
    return source;
}

mySay(string objectName, string msg)
{
    string nameBeforeChange = llGetObjectName();

    llSetObjectName(objectName);
    llSay(PUBLIC_CHANNEL, "/me " + msg);

    llSetObjectName(nameBeforeChange);
}

// Follow Code
triggerFollow(key id)
{    
    string ownername = llKey2Name(owner);
    if(following == 1) 
    {
        llSay(-105,"off");
        following = 0;
    }
} 

processConfiguration(string data)
{
    CombatAnimations = llCSV2List(llJsonGetValue(data,["combatanimations"]));
    SocialAnimations = llCSV2List(llJsonGetValue(data,["socialanimations"]));
    RPAnimations = llCSV2List(llJsonGetValue(data,["rpanimations"]));
    CommandChannel =  (integer)llJsonGetValue(data,["commandchannel"]);
    CharacterData = data;
    Titlers = llJson2List(llJsonGetValue(data,["titlers"]));
    activeTitler = llJsonGetValue(data,["titler"]);
    titlerOn = (integer)llJsonGetValue(data,["titler_active"]);

    //TitlerNames
    integer titlerLength = llGetListLength(Titlers);
    if(titlerLength > 0) {
        integer i = 0;
        while(i < titlerLength) {
            TitlerNames += [llJsonGetValue(llList2String(Titlers, i),["title"])];
            i++;
        }          
    }

    llOwnerSay("Chat Command Channel set to: " + (string)CommandChannel);
    llListen(CommandChannel,"",owner,""); 
}


setDefaultCharacter(string data)
{
    llOwnerSay("No Character set, Checking for last.");
    string cdata = llJsonGetValue(data,["characterdata"]);    
    llOwnerSay(llJsonGetValue(cdata,["name"]));
    if(llJsonGetValue(cdata,["name"]) != "") {
        llOwnerSay("Default set to: " + llJsonGetValue(cdata,["name"]));
        llSetObjectDesc(llJsonGetValue(cdata,["name"]));
        CharacterName = llJsonGetValue(cdata,["name"]);  
        processConfiguration(cdata);
        hideHud();
    } else {
        llOwnerSay("No Character selected.");
    }
}

addTitler(string message)
{
    list dataElements = llParseString2List(message, ["|"],[""]);
    list requestvars = ["character",(integer)llJsonGetValue(CharacterData,["id"]),"title",llList2String(dataElements,0),"text",llList2String(dataElements,1),"active",0];    
    httprequest = llHTTPRequest(apiPath + "titler", [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],llList2Json(JSON_OBJECT,requestvars));    
}

setHudEnable(integer process) 
{
    if(process == 0) {
        titlerOn = 1;
        enableHud();
    } else {
        titlerOn = 0;
        disableHud();
    }
}

default
{
    state_entry()
    {   
        init();   

        llRequestPermissions (owner, PERMISSION_TRIGGER_ANIMATION|PERMISSION_OVERRIDE_ANIMATIONS);     
        fetchCharacterList();
        state main;
    } 
     
    on_rez(integer start_param)
    {
        llResetScript();  
    }
    
    changed (integer change)
    {
        if (change & CHANGED_OWNER) 
        {
            llResetScript();
        }
    }

    http_response(key id, integer status, list metadata, string body)
    {
        //if (id != httprequest) return;  
        string keyValue = llJsonGetValue(body, ["key"]);      
        
        HandleError(status, body, keyValue);
        
        if(keyValue != "") {
            if(keyValue == "getcharacters") { 
                if(status == 201) {
                    Characters = llJson2List(llJsonGetValue(body, ["name"]));
                } else {
                    llOwnerSay("Trouble Loading Character List.");
                }            
            }        
            
            if(keyValue == "getcharacter") {            
                if(status == 201) {
                    processConfiguration(body);
                } else {
                    llOwnerSay("Trouble Loading Character Data.");
                }
            }
            
            if(keyValue == "gethud") {
                if(status == 201) {
                    setDefaultCharacter(body);   
                }   
            }      
        }
    }     
}

state main
{
    state_entry() {
        llOwnerSay("Hud Ready");    
    }   

    on_rez(integer start_param)
    {
        llResetScript();  
    }     
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(msg == "stopanimations") 
        {
            llSetTimerEvent(0.0);  
            StopAnimation();        
        }
        else if(msg == "followscript")
        {
            if(following == 1) 
            {
                llSay(-105,"off");
                following = 0;
            }
            targets = [];
            string ownername = llKey2Name(owner);
            list keys = llGetAgentList(AGENT_LIST_REGION, []);        
            integer numberOfKeys = llGetListLength(keys);
     
            vector currentPos = llGetPos();
            list newkeys;
            key thisAvKey;
     
            integer i;
            for (i = 0; i < numberOfKeys; ++i) {
                thisAvKey = llList2Key(keys,i);
                newkeys += [llRound(llVecDist(currentPos,llList2Vector(llGetObjectDetails(thisAvKey, [OBJECT_POS]), 0))),thisAvKey];
            }
     
            newkeys = llListSort(newkeys, 2, FALSE);     //  sort strided list by descending distance
     
            for (i = 0; i < (numberOfKeys * 2); i += 2) {
                if(llList2Integer(newkeys, i) < 11)
                {
                    string displayName = llKey2Name(llList2Key(newkeys, i+1));
                    if(displayName != ownername) 
                    {
                        targets += displayName;
                    }                    
                }
            }
            llDialog(owner,  "Choose Target to Follow:", targets, channelDialog_Follow); 
            listenId = llListen(channelDialog_Follow, "", owner, "");       
        }
        else if(msg == "triggerdice")        
        {
            RollDice();
        }
        else if(msg == "hidehud")
        {
            hideHud();
        }
        else if(msg == "showhud")
        {
            showHud();
        }
        else if(msg == "rpanimations")
        {  
           llSetTimerEvent(0.0);
           // StopAnimation();  
           if(llGetListLength(RPAnimations) > 0 && llList2String(RPAnimations, 0) != "") {  
               llDialog(owner, "Role-Playing Animations", RPAnimations, channelDialog);
               listenId = llListen(channelDialog, "", owner, "");   
           } else {
                llOwnerSay("No Role-Play Animations set.");    
           }
        }
        else if(msg == "socialanimations")
        { 
           llSetTimerEvent(0.0);     
           // StopAnimation(); 
           if(llGetListLength(SocialAnimations) > 0 && llList2String(SocialAnimations, 0) != "") {                  
               llDialog(owner, "Social Animations", SocialAnimations, channelDialog);
               listenId = llListen(channelDialog, "", owner, "");  
           } else {
                llOwnerSay("No Social Animations set.");    
           } 
        }
        else if(msg == "combatanimations")
        {
           llSetTimerEvent(0.0);  
           // StopAnimation();
           if(llGetListLength(CombatAnimations) > 0 && llList2String(CombatAnimations, 0) != "") {                      
               llDialog(owner, "Combat Animations", CombatAnimations, channelDialog);
               listenId = llListen(channelDialog, "", owner, "");  
           } else {
                llOwnerSay("No Combat Animations set.");    
           } 
        }
        else if(msg == "operations")
        {
           list Operations = [];
           Operations += ["Character"];
           Operations += ["+ Character"];  
           if(CharacterName != "") { 
               Operations += ["- Character"]; 
               Operations += ["Titlers"];            
               Operations += ["+ Animation"];
               Operations += ["Chat Chanel"];   
               Operations += ["Reload"];  
               llDialog(owner, "Choose Operation for : " + CharacterName, Operations, channelDialog);       
            } else {
                llDialog(owner, "Choose Character or Add" + CharacterName, Operations, channelDialog);
            }
           
           listenId = llListen(channelDialog, "", owner, "");            
        }                     

    }    
    
    listen(integer channel, string name, key id, string message)
    {   
        if(id == owner) {
            //llListenRemove(listenId); 
            if(message == "OK") return;
            
            if(channel == channelDialog_newCharacter) {
                addCharacter(message);
                fetchCharacterList();            
                llListenRemove(listenId_b);
            }
            
            if(channel == channelDialog_Dice) {
                ProcessDice(message);
                llListenRemove(listenId_c);
            }
            
            if(channel == channelDialog_newAnimation) {
                addAnimationString(message);
                llListenRemove(listenId_d);
            }
            
            if(channel == channelDialog_Follow) {
                llOwnerSay(message);
                llSay(-105, message);        
                following = 1;
            }        
            
            if(channel ==CommandChannel) {
                Relay_Chat(message);  
            } 
            
            if(channel == channelDialog_removeCharacter) {
                deleteCharacter(message);    
            }

            if(channel == channelDialog_Title) {
                addTitler(message);
                llListenRemove(listenId_g);
            }
            
            if(channel == channelDialog) {
                if(message == "Character") 
                {
                    showCharacterChoices();   
                }
                else if(message == "+ Character")
                {
                    setupCharacter();
                }
                else if(message == "- Character")
                {
                    removeCharacter();
                }            
                else if(message == "+ Animation")
                {
                   setAnimations();  
                }
                else if(message == "Reload")
                {
                    getCharacterData();
                }            
                else if(message == "Chat Chanel")
                {
                    llOwnerSay("Change Chat Chanel from: " + (string)CommandChannel);  
                }
                else  if(message == "Titlers")
                {
                    integer titlerCount = 0;
                    list TitlersButtons = [];
                    TitlersButtons += ["New Titler"];                   

                    integer titlerLength = llGetListLength(Titlers);
                    if(titlerLength > 0) {
                        integer i = 0;
                        while(i < titlerLength) {
                            if((integer)llJsonGetValue(llList2String(Titlers, i),["active"]) == 1) {
                                TitlersButtons += "* " + llJsonGetValue(llList2String(Titlers, i),["title"]);
                            } else {
                                TitlersButtons += llJsonGetValue(llList2String(Titlers, i),["title"]);
                            }
                            i++;
                        }

                        if(titlerOn == 0) {
                            TitlersButtons += ["Enable"];
                        } else {
                            TitlersButtons += ["Disable"];
                        }            
                    }
                    llDialog(owner, "Choose Titler", TitlersButtons, channelDialog);
                } 
                else if(message == "New Titler") {
                    listenId_g = llListen(channelDialog_Title, "", "", "");     
                    llTextBox(owner, "Enter a new Titler.  Format Title|Titler Text, it can include carrage returns.", channelDialog_Title);  
                }
                else if(message == "Enable")
                {
                    setHudEnable(FALSE);
                    //llMessageLinked(LINK_THIS, 50, "Enable", "");
                    llSay(channelDialog_Titler,"Enable");
                }
                else if(message == "Disable")
                {
                    setHudEnable(TRUE);
                    //llMessageLinked(LINK_THIS, 50, "Disable", "");
                    llSay(channelDialog_Titler,"Disable");
                }               
                else if(llListFindList( Characters, [message] ) > -1) // Characters
                {
                    llSetObjectDesc( message );  
                    CharacterName = message;   
                    getCharacterData();
                }
                else if(llListFindList( CombatAnimations, [message] ) > -1) // Characters
                {
                    StopAnimation();
                    if(currentAnimation != "" && currentAnimation != "*STOP*") llStopAnimation(currentAnimation);
                    currentAO = GetCurrentAnimation();
                    currentAnimation = message;  
                }
                else if(llListFindList( SocialAnimations, [message] ) > -1) // Characters
                {
                    StopAnimation();
                    if(currentAnimation != "" && currentAnimation != "*STOP*") llStopAnimation(currentAnimation);
                    currentAO = GetCurrentAnimation();
                    currentAnimation = message;
                    
                }
                else if(llListFindList( RPAnimations, [message] ) > -1) // Characters
                {
                    StopAnimation();                
                    if(currentAnimation != "" && currentAnimation != "*STOP*") llStopAnimation(currentAnimation);
                    currentAO = GetCurrentAnimation();
                    currentAnimation = message; 
     
                }
                else if(llListFindList(TitlerNames, [message] ) > -1) // Characters
                {
                    integer titlerLength = llGetListLength(Titlers);
                    if(titlerLength > 0) {
                        integer i = 0;
                        while(i < titlerLength) {
                            if(llJsonGetValue(llList2String(Titlers, i),["title"]) == message) {
                                activeTitler = llList2String(Titlers, i);
                            }
                            i++;
                        }
                    }                    
                    //llMessageLinked(LINK_THIS, 50, "Set|" + activeTitler, "");     
                    llSay(channelDialog_Titler,"Set|" + activeTitler);
                }                                           
                else {       
                    llOwnerSay("Channel: " + (string)channel);
                    llOwnerSay("Name: " + (string)name);
                    llOwnerSay("Key: " + (string)id);
                    llOwnerSay("Message: " + (string)message);
                }
                
                if(message != "*STOP*") llSetTimerEvent(animRun);   
           }
        }
    }
    
    timer()
    {
        if(currentAnimation != "") {  
            StopAnimations();
            StartAnimation(); 
        }
    }     
    
    http_response(key id, integer status, list metadata, string body)
    {
        //if (id != httprequest) return;  
        string keyValue = llJsonGetValue(body, ["key"]);      
        
        HandleError(status, body, keyValue);
        
        if(keyValue != "") {
            if(keyValue == "getcharacters") { 
                if(status == 201) {
                    Characters = llJson2List(llJsonGetValue(body, ["name"]));
                } else {
                    llOwnerSay("Trouble Loading Character List.");
                }            
            }        
            
            if(keyValue == "getcharacter") {            
                if(status == 201) {
                    processConfiguration(body);
                } else {
                    llOwnerSay("Trouble Loading Character Data.");
                }
            }
            
            if(keyValue == "gethud") {
                if(status == 201) {
                    setDefaultCharacter(body);   
                }   
            }                    
        }
    }    
}
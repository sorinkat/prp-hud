// Primary Operational Variables
key owner;
string ownerName;
string apiPath = "https://prp-hud.herokuapp.com/api/";
key httprequest;
integer listenId;
string messageLoad = "Initializing Hud";

// Channels
integer primaryHudChannel;
integer primaryOperationsChannel;
integer primaryCharacterChennel;
integer primaryTitlerChannel;
integer primaryDiceChannel;

integer dialogObjectTitlerChannel;
integer dialogObjectFollowChannel;

// Hud and Character
string hudData; // Hud Data in Json
string characterData; // The Active Character in Json
list characterList; // Listing of Characters for This Hud
list characterNames; // List of Character Names
string characterName; // The Character Name

// Titler Information
list titleData; // All the titler Data
list titleList; // List of Titlers 
string activeTitler; // The Current Running Titler
integer titlerOn;

// Animations
list CombatAnimations; // Animation Lists
list SocialAnimations; // Animation Lists
list RPAnimations; // Animation Lists
string animationCategory;

// Dice Data
list integers = ["-","0","1","2","3","4","5","6","7","8","9"];

// Follow Script
integer following;

// Chat Data
integer chatChannel;

init()
{
    owner = llGetOwner();
    ownerName = llGetUsername(owner);
    primaryHudChannel = (integer)("0xF" + llGetSubString(llGetOwner(),0,6));
    primaryCharacterChennel = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 1;
    primaryOperationsChannel = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 2;
    primaryTitlerChannel = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 3;
    primaryDiceChannel = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 4;

    dialogObjectTitlerChannel = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 7;
    dialogObjectFollowChannel = (integer)("0xF" + llGetSubString(llGetOwner(),0,6)) + 8;


    chatChannel  = 2;
    characterName = "";

    titlerOn = 0;

    
    // Hide while loading
    rotateHud(FALSE);
}

rotateHud(integer show)
{
    if(show == 0) 
    {
        llMessageLinked(LINK_THIS, 50, "Loading", "");
    } else if (show == 1)
    {
        llMessageLinked(LINK_THIS, 50, "Ready", "");
    }
}

hudDisplayState(integer displayState, string Keep)
{
    integer i = llGetNumberOfPrims();  
    // Display the Hud State
    if(displayState == 1) // Hide/Phantom All Elements for loading
    {
        while(i) {            
            llSetLinkAlpha(i, 0.0, ALL_SIDES);
            --i;    
        } 
        llSetAlpha(0,0); 
    }
    else if(displayState == 2) // Hide/Phantom All Elements But Rotate and Cancel
    {
        while(i) {
            key link = llGetLinkKey(i);
            string desc = llList2String(llGetObjectDetails(link, [OBJECT_DESC]), 0);
            if (desc != "Cancel" && i != 1 && desc != Keep) {
                llSetLinkAlpha(i, 0.0, ALL_SIDES);
            } else if (desc == "Cancel") {
                llSetLinkAlpha(i, 1.0, ALL_SIDES);
            }
            --i;    
        } 
    }
    else // Normal, Show All Elements
    {
        while(i) {
            key link = llGetLinkKey(i);
            string desc = llList2String(llGetObjectDetails(link, [OBJECT_DESC]), 0);  
    
            if (desc != "Cancel" && desc != "") {
                llSetLinkAlpha(i, 1.0, ALL_SIDES);
            } else if (desc == "Cancel" || desc == "" || i == 1) {
                llSetLinkAlpha(i, 0.0, ALL_SIDES);
            }
            --i;    
        }
    }
}

titlerBreakdown(string data)
{
    titleData = llParseString2List(llJsonGetValue(data,["titlers"]),[","],[""]);
    activeTitler = llJsonGetValue(data,["active_titlers"]);
    integer i;
    integer numberOfKeys = llGetListLength(titleData);
    for (i = 0; i < numberOfKeys; ++i) {
        titleList += [llJsonGetValue(llList2String(titleData, i),["title"])];
    }
}

// API Functions
createHud() 
{
    list requestvars = ["id",(string)owner,"account",ownerName,"active",1];
    httprequest = llHTTPRequest(apiPath + "hud", 
        [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],
        llList2Json(JSON_OBJECT,requestvars)
    ); 
}

addCharacter(string name) {
    list requestvars = ["hudid",(string)owner,"name",name,"commandchannel",2,"combatanimations","","socialanimations","","rpanimations",""];
    httprequest = llHTTPRequest(apiPath + "character", 
        [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],
        llList2Json(JSON_OBJECT,requestvars)
    );         
}

selectCharacter(string name) {
    integer i;
    
    for (i = 0; i < llGetListLength(characterList); ++i) {
        if(llJsonGetValue(llList2String(characterList, i),["name"]) == name)
        {
            string characterId = llJsonGetValue(llList2String(characterList, i),["id"]);
            httprequest = llHTTPRequest(apiPath + "character/setactive/" + (string)owner + "/" + characterId, 
                [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],
                "");
        }
    }

}

getActiveCharacter() {
    httprequest = llHTTPRequest(apiPath + "character/active/" + llJsonGetValue(hudData,["active_character"]), 
        [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],
        ""
    ); 
}

removeCharacter() {
    httprequest = llHTTPRequest(apiPath + "character/" + (string)owner + "/" + llJsonGetValue(hudData,["active_character"]), 
        [HTTP_METHOD, "DELETE", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],
        ""
    );    
}

setCommandChannel(integer command)
{
    if(characterName != "" || characterName != JSON_NULL) {
        httprequest = llHTTPRequest(apiPath + "character/" + (string)owner + "/" + characterName, 
            [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],
            llList2Json(JSON_OBJECT,["commandchannel",command])
        );    
    }
}

getCharacterList() {
    httprequest = llHTTPRequest(apiPath + "character/" + (string)owner, 
        [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],
        ""
    );         
}

getTitlerList() {
    httprequest = llHTTPRequest(apiPath + "titler/" + llJsonGetValue(hudData,["active_character"]), 
        [HTTP_METHOD, "GET", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],
        ""
    );     
}

addTitler(string message)
{
    list dataElements = llParseString2List(message, ["|"],[""]);
    list requestvars = ["character",(integer)llJsonGetValue(characterData,["id"]),"title",llList2String(dataElements,0),"text",llList2String(dataElements,1),"active",0];    
    httprequest = llHTTPRequest(apiPath + "titler", [HTTP_METHOD, "POST", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],llList2Json(JSON_OBJECT,requestvars));    
}

removeTitler()
{
    httprequest = llHTTPRequest(apiPath + "titler/"+llJsonGetValue(activeTitler,["id"]), [HTTP_METHOD, "DELETE", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");
    tellTitler("Disable");
}

disableTitler() 
{
    httprequest = llHTTPRequest(apiPath + "titler/"+llJsonGetValue(characterData,["id"])+"/disable", [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");
}

enableTitler() 
{
    httprequest = llHTTPRequest(apiPath + "titler/"+llJsonGetValue(characterData,["id"])+"/enable", [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");
}

setActiveTitler(string message)
{
    
    integer i;
    for(i=0;i<llGetListLength(titleList);++i)
    {
        if(llJsonGetValue(llList2String(titleList,i),["title"]) == message)
        {
            string titleid = (string) llJsonGetValue(llList2String(titleList,i),["id"]);
            string character = (string) llJsonGetValue(llList2String(titleList,i),["character"]);
            llHTTPRequest(apiPath + "titler/"+character+"/"+titleid, [HTTP_METHOD, "PUT", HTTP_MIMETYPE, "application/json",HTTP_EXTENDED_ERROR, TRUE,HTTP_VERIFY_CERT,FALSE],"");
        }        
    }

}

// LSL Error Handling
HandleError(integer status, string body)
{
    if(status > 500 && status < 600) // when 4XX or 5XX
    {
        string errorStr = llJsonGetValue(body, ["error"]);
        string errorCode = llJsonGetValue(errorStr, ["code"]);
        string errorMessage = llJsonGetValue(errorStr, ["message"]);

        llOwnerSay("ERROR CONTACT TO THE OWNER [" + "HTTPStatus: " + 
            (string)status + ", code: " + errorCode + ", message: " + errorMessage + "]");

    }
}

// Main Menu Manager
displayMenu(string menuKey, integer channel) {
    list Buttons = [];
    if(menuKey == "Operations")
    {
        Buttons += ["Characters"];
        Buttons += ["Titlers"];
        Buttons += ["Animations"];
        Buttons += ["Channel"];
        llDialog(owner, "Choose Item to Manage", order_buttons(Buttons), channel);
    }
    if(menuKey == "Animations")
    {
        animationCategory = "";
        Buttons += ["Combat"];
        Buttons += ["Roleplay"];
        Buttons += ["Social"];        
        llDialog(owner, "Choose Animation Category", order_buttons(Buttons), channel);
    }


    listenId = llListen(channel, "", owner, ""); 
}

// Character Stuff
setupCharacter() {
    llTextBox(owner, "Enter Name for Character", primaryHudChannel);  
    listenId = llListen(primaryHudChannel, "", owner, ""); 
}

// Replace String
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

// Say Script
mySay(string objectName, string msg)
{
    string nameBeforeChange = llGetObjectName();

    if(objectName == "" || objectName == " ")
    {
        objectName = "-";
    }
    llSetObjectName(objectName);

    llSay(PUBLIC_CHANNEL, "/me " + msg);

    llSetObjectName(nameBeforeChange);
}

// Chat Relay
RelayChat(string message)
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
            message = strReplace(message, "\%n", characterName);
            mySay(" ", message); 
            
        } else {
            //  Just a Me Statement
            messageParts = llDeleteSubList(messageParts,0,0);
            mySay(characterName, llDumpList2String(messageParts, " "));                
        }
    }
    else
    {
        mySay(characterName, " says \"" + llDumpList2String(messageParts, " ") + "\"");  
    }    
}

// Dice Functions
RollDice()
{
    listenId = llListen(primaryDiceChannel, "", "", "");     
    llTextBox(owner, "Roll a 1d100, leave blank or enter a number to modify (max 20)", primaryDiceChannel);       
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
        string rolltext;
        if(characterName != "") {
            rolltext = "Roll Made by "+characterName+": " + (string) roll;
            if(calc_bonus > 0) {
                rolltext += " (+" + (string)calc_bonus+")";
            }
            if(calc_bonus < 0) {
                rolltext += " (" + (string)calc_bonus + ")";
            }
              
        } else {
            rolltext = "Roll Made by "+llKey2Name(owner)+": " + (string) roll;
            if(calc_bonus > 0) {
                rolltext += " -" + (string)calc_bonus;
            }
            if(calc_bonus < 0) {
                rolltext += " +" + (string)calc_bonus;
            }            
        }
        llSay(0,rolltext);
        
    } 
 
}

list order_buttons(list buttons)
{
    return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4)
         + llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}

tellTitler(string message)
{
    llSay(dialogObjectTitlerChannel,message);
}

default
{    
    state_entry()
    {  
        llOwnerSay(messageLoad);
        messageLoad = "Loading Data";
        hudDisplayState(1, "");
        init();
        createHud();
    }

    on_rez( integer start_param )
    { 
        // Loading element on connect
        llResetScript();
    }

    http_response(key id, integer status, list metadata, string body)
    {
        
        HandleError(status, body);
        // Hud Created or loaded set character
        if(status == 201) {  
            
            if(llJsonGetValue(body,["key"]) == "gethud")
            {     
                hudData = body;
                getCharacterList();                           
            }
            if(llJsonGetValue(body,["key"]) == "getcharacters")
            {
                characterList = [];
                characterNames = [];
                integer i;
                characterList = llJson2List(llJsonGetValue(body,["characters"]));
                for(i = 0; i < llGetListLength(characterList); ++i)
                {
                    characterNames += llJsonGetValue(llList2String(characterList,i),["name"]);
                }                
                if(llJsonGetValue(hudData,["active_character"]) != "" && 
                llJsonGetValue(hudData,["active_character"]) != "0"  && 
                llJsonGetValue(hudData,["active_character"]) != JSON_NULL)
                {          
                    getActiveCharacter();
                } 
                else 
                {
                    state manage_characters;
                }

            }
            if(llJsonGetValue(body,["key"]) == "getactivecharacter")
            {
                if(body != "" && ((llJsonGetValue(body,["name"]) != "" || llJsonGetValue(body,["name"]) != JSON_NULL))) {

                    characterData = body;
                    characterName = llJsonGetValue(body,["name"]);
                    
                    chatChannel = (integer)llJsonGetValue(characterData,["commandchannel"]);
                    if(chatChannel == 0) 
                    {
                        chatChannel = 2; 
                    }
                    llOwnerSay("Chat Channel: " + (string)chatChannel);


                    if(llJsonGetValue(characterData,["activetitler"]) != "" && llJsonGetValue(characterData,["activetitler"]) != JSON_NULL)
                    {                        
                        activeTitler = llJsonGetValue(characterData,["activetitler"]);
                        tellTitler("Set|" + activeTitler);
                        
                        if(llJsonGetValue(characterData,["titler_active"]) == "1") {
                            tellTitler("Enable");
                            titlerOn = 1;
                        } else {
                            tellTitler("Disable");
                            titlerOn = 0;
                        }
                    } else {
                        activeTitler = "";
                    }
                    getTitlerList();                   
                    //state main;
                } else {
                    characterData  = "";
                    state manage_characters;
                }
            }
            if(llJsonGetValue(body,["key"]) == "gettitler")
            {
                if(body != "" && (llJsonGetValue(body,["list"]) != "" || llJsonGetValue(body,["list"]) != JSON_NULL)) {                    
                    titleList = llJson2List(llJsonGetValue(body,["list"]));
                }

                state main;
            }
        }
    }    
}

// State to load/create/remove characters
state manage_characters
{
    // llTextBox(owner, "Enter Name for Character", channelDialog_newCharacter); 
    state_entry()
    {  
        if(llGetListLength(characterList) > 0 && characterName != "")
        {
            hudDisplayState(0, "Operations");
        }
        hudDisplayState(2, "Operations");
        llOwnerSay("Managing Characters");

        list Operations = [];
        Operations += ["Add"];  

        integer i;
        if(llGetListLength(characterNames) > 0) 
        {        
            for (i = 0; i < llGetListLength(characterNames); ++i) {
                if(characterName != llList2String(characterNames,i)) {
                    Operations += llList2String(characterNames,i);  
                }
            }            
        }

        if(characterName != "") { 
            Operations += ["Remove"]; 
            llDialog(owner, "Character Management: " + characterName, order_buttons(Operations), primaryHudChannel);       
        } else {
            llDialog(owner, "Character Management", order_buttons(Operations), primaryHudChannel);  
        }
        
        listenId = llListen(primaryHudChannel, "", owner, "");         
    }

    on_rez( integer start_param )
    { 
        // Loading element on connect
        llResetScript();
    }

    listen(integer channel, string name, key id, string message)
    {   
        if(id == owner) 
        {
            if(channel == primaryHudChannel)
            {
                if(message == "Add")
                {
                    setupCharacter();
                } 
                else if (message == "Remove")
                {
                    removeCharacter();               
                    state default;
                }
                else if(llListFindList( characterNames, [message] ) >= -1) 
                {
                    selectCharacter(message);                
                } 
                else 
                {
                    addCharacter(message);
                }                
            }
        }
    }

    http_response(key id, integer status, list metadata, string body)
    {
        //if (id != httprequest) return;  
        string keyValue = llJsonGetValue(body, ["key"]);
        
        HandleError(status, body);
        // Hud Created or loaded set character
        if(status == 201 || status == 200) {
            state default;
        }
    }  

    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num == 0 && num != 50)
        {
            if(msg == "Cancel")
            {
                state default;
            }
            if(msg == "Operations")
            {
                state manage_operations;
            }
        }        
    }      
}

// State to load/create/remove titlers
state manage_titlers
{
    state_entry()
    {  
        hudDisplayState(2, "Operations");
        
        list titlerCommands = [];

        titlerCommands += ["Get Titler"];
        if(llGetListLength(titleList) < 5) {
            titlerCommands += ["Add"];
        }        
        if(activeTitler != "" && activeTitler != NULL_KEY) {
            titlerCommands += ["Remove"];
            if(titlerOn == 0) {
                titlerCommands += ["Enable"];
            } else {
                titlerCommands += ["Disable"];
            }              
        }

        if(activeTitler != "")
        {
            llDialog(owner, "You have ("+(string)llGetListLength(titleList)+") Titlers.  Clicking remove will remove your active titler which is: " + llJsonGetValue(activeTitler,["title"]) + ".", order_buttons(titlerCommands), primaryHudChannel);
        } else {
            llDialog(owner, "You have ("+(string)llGetListLength(titleList)+") Titlers.", order_buttons(titlerCommands), primaryHudChannel);
        }
        listenId = llListen(primaryHudChannel, "", owner, "");  
    }   

    on_rez( integer start_param )
    { 
        // Loading element on connect
        llResetScript();
    }  

    listen(integer channel, string name, key id, string message)
    {         
        if(id == owner) 
        {
            if(channel == primaryHudChannel)
            {
                if(message == "Add")
                {
                    llTextBox(owner, "Enter the name of the new Titler, a | and then the titler text.", primaryTitlerChannel);
                    listenId = llListen(primaryTitlerChannel, "", owner, ""); 
                }
                if(message == "Remove")
                {
                    //llOwnerSay(activeTitler);
                    disableTitler();
                    removeTitler();
                    state default;
                }
                if(message == "Enable")
                {
                    enableTitler();
                    state default;
                }
                if(message == "Disable")
                {
                    disableTitler();
                    state default;
                } 
                if(message == "Get Titler")
                {
                    llGiveInventory(owner, "PRP Titler");
                    state default;
                }               
            }

            if(channel == primaryTitlerChannel)
            {
                addTitler(message);
                state default;
            }
        }
    }

    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num == 0 && num != 50)
        {
            if(msg == "Cancel")
            {
                state default;
            }
            if(msg == "Operations")
            {
                state manage_operations;
            }
        }        
    }       
}

// State manage Animations, Set, Update
state manage_animations
{
    state_entry()
    {  
        hudDisplayState(2, "Operations");
        llOwnerSay("Managing Animations");
        displayMenu("Animations", primaryHudChannel);

    }

    on_rez( integer start_param )
    { 
        // Loading element on connect
        llResetScript();
    } 

    listen(integer channel, string name, key id, string message)
    {   
        if(id == owner) 
        {
            if(channel == primaryHudChannel)
            {
                if(animationCategory == "")
                {
                    if(message == "Combat")
                    {
                        animationCategory = "Combat";
                        llOwnerSay("Current "+animationCategory+" Animations: " + llDumpList2String(CombatAnimations,","));
                        llTextBox(owner, "Enter " + message + " animations, seperated by a comma (,)", primaryHudChannel); 
                    }
                    if(message == "Social")
                    {
                        animationCategory = "Social";
                        llOwnerSay("Current "+animationCategory+" Animations: " + llDumpList2String(SocialAnimations,","));
                        llTextBox(owner, "Enter " + message + " animations, seperated by a comma (,)", primaryHudChannel); 

                    }
                    if(message == "Roleplay")
                    {
                        animationCategory = "Roleplay";
                        llOwnerSay("Current "+animationCategory+" Animations: " + llDumpList2String(RPAnimations,","));
                        llTextBox(owner, "Enter " + message + " animations, seperated by a comma (,)", primaryHudChannel); 
                    }   
                } else {
                    llOwnerSay(animationCategory);
                    animationCategory == "";
                }                            
            }
        }
    }


    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num == 0 && num != 50)
        {
            if(msg == "Cancel")
            {
                state default;
            }
            if(msg == "Operations")
            {
                state manage_operations;
            }
        }        
    }        
}

// Operations state
state manage_operations
{
    state_entry()
    {
        hudDisplayState(2, "Operations");
        displayMenu("Operations", primaryHudChannel);
    }

    listen(integer channel, string name, key id, string message)
    {   
        if(id == owner) 
        {
            if(channel == primaryHudChannel)
            {
                if(message == "Characters")
                {
                    state manage_characters;
                }
                if(message == "Titlers")  
                {
                    state manage_titlers;
                }
                if(message == "Animations")
                {
                    state manage_animations;
                }
                if(message == "Channel")
                {
                    llTextBox(owner, "Enter Command Channel (This is the channel that you would use to talk as your character, i.e /2)", primaryOperationsChannel);  
                    listenId = llListen(primaryOperationsChannel, "", owner, "");                     
                }
            }
            if(channel == primaryOperationsChannel) {
                setCommandChannel((integer)message);
            }            
        }
    }

    http_response(key id, integer status, list metadata, string body)
    {
       
        HandleError(status, body);

        // Hud Created or loaded set character
        if(status == 201 || status == 200) {
            state default;
        }
    } 

    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num == 0 && num != 50)
        {
            if(msg == "Cancel")
            {
                state default;
            }
            if(msg == "Operations")
            {
                hudDisplayState(2, "Operations");
                displayMenu("Operations", primaryHudChannel);
            }
        }        
    }     
}

// Hud is ready for use clicking on elements changes to management states
state main
{
    state_entry()
    {  
        llOwnerSay("Ready");
        hudDisplayState(0, "");
        rotateHud(TRUE);
        llListen(chatChannel,"",owner,""); 
    }

    on_rez( integer start_param )
    { 
        // Loading element on connect
        llResetScript();
    }

    listen(integer channel, string name, key id, string message)
    {   
        if(id == owner) 
        {
            if(channel == chatChannel)
            {
                RelayChat(message);
            }
            if(channel == primaryTitlerChannel)
            {
                setActiveTitler(message);
                state default;
            }
            if(channel == primaryDiceChannel)
            {
                ProcessDice(message);
            }
        }
    } 

    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num == 0 && num != 50)
        {
            if(msg == "Operations")
            {
                state manage_operations;
            }
            else if(msg == "Titlers")
            {
                list titlerButtons = [];
                integer i;
                for(i = 0; i < llGetListLength(titleList); ++i) 
                {
                    titlerButtons += [llJsonGetValue(llList2String(titleList,i),["title"])];
                }
                llDialog(owner, "Select Active titler.", order_buttons(titlerButtons), primaryTitlerChannel);
                listenId = llListen(primaryTitlerChannel, "", owner, "");
            } else if(msg == "Dice") {
                RollDice();  
            } else if(msg == "Follow") {
                llSay(dialogObjectFollowChannel,"select");
            } else if(msg == "Animations") {
                state manage_animations;
            } else {
                llOwnerSay(msg);
            }
        }        
    }  
}
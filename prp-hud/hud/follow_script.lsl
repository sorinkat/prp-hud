key owner;
integer CHANNEL;  // That's "f" for "follow", haha
 
float DELAY = 0.5;   // Seconds between blinks; lower for more lag
float RANGE = 3.0;   // Meters away that we stop walking towards
float TAU = 1.0;     // Make smaller for more rushed following
 
// Avatar Follower script, by Dale Innis
// Do with this what you will, no rights reserved
// See https://wiki.secondlife.com/wiki/AvatarFollower for instructions and notes
 
float LIMIT = 60.0;   // Approximate limit (lower bound) of llMoveToTarget
 
integer lh = 0;
integer tid = 0;
string targetName = "";
key targetKey = NULL_KEY;
integer announced = FALSE;

integer following;
integer primaryFollowChannel;
 
init() {
  owner = llGetOwner();
  CHANNEL  = (integer)("0xF" + llGetSubString(owner,0,6)) + 8;
  llListenRemove(lh);
  lh = llListen(CHANNEL,"",owner,"");
  llOwnerSay("Ready");
}
 
stopFollowing() {
  llTargetRemove(tid);  
  llStopMoveToTarget();
  llSetTimerEvent(0.0);
  llOwnerSay("No longer following.");
}
 
startFollowingName(string name) {  
  llOwnerSay(name);
  targetName = name;
  llSensor(targetName,NULL_KEY,AGENT_BY_LEGACY_NAME,96.0,PI);  // This is just to get the key
}
 
startFollowingKey(key id) {
  targetKey = id;
  llOwnerSay("Now following "+targetName);
  keepFollowing();
  llSetTimerEvent(DELAY);
}
 
keepFollowing() {
  llTargetRemove(tid);  
  llStopMoveToTarget();
  list answer = llGetObjectDetails(targetKey,[OBJECT_POS]);
  if (llGetListLength(answer)==0) {
    if (!announced) llOwnerSay(targetName+" seems to be out of range.  Waiting for return...");
    announced = TRUE;
  } else {
    announced = FALSE;
    vector targetPos = llList2Vector(answer,0);
    float dist = llVecDist(targetPos,llGetPos());
    if (dist>RANGE) {
      tid = llTarget(targetPos,RANGE);
      if (dist>LIMIT) {
          targetPos = llGetPos() + LIMIT * llVecNorm( targetPos - llGetPos() ) ; 
      }
      llMoveToTarget(targetPos,TAU);
    }
  }
}

followOptions()
{
    
    if(following == 1) 
    {
        stopFollowing();
        following = 0;
    }
    
    list targets = [];
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
    llDialog(owner,  "Choose Target to Follow:", targets, CHANNEL); 
    lh = llListen(CHANNEL, "", owner, "");     
}

default {
 
  state_entry() {
    init();
  }
 
  on_rez(integer x) {
    llResetScript();   // Why not?
  }
 
  listen(integer c,string n,key id,string msg) {
    llOwnerSay(msg);  
    if (msg == "off") {
      stopFollowing();
    } else if(msg == "on") {
      startFollowingName(msg);
    } 
    
  }
 
  link_message(integer sender_num, integer num, string msg, key id)
  {
        if(num == 30)
        {      
            if(msg == "select") {
                  followOptions();      
            }            
        }  
  }  
 
  no_sensor() {
    llOwnerSay("Did not find anyone named "+targetName);
  }
 
  sensor(integer n) {
    startFollowingKey(llDetectedKey(0));  // Can't have two ppl with the same name, so n will be one.  Promise.  :)
  }
 
  timer() {
    keepFollowing();
  }
 
  at_target(integer tnum,vector tpos,vector ourpos) {
    llTargetRemove(tnum);
    llStopMoveToTarget();  
  }
 
}
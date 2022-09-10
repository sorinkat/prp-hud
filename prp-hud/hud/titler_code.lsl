key owner;

default
{
    state_entry()
    {
        owner = llGetOwner();
        //listenId = llListen(channelDialog, "", owner, "");          
        llOwnerSay("Listening for Titler");
    }
    
    link_message(integer sender_num, integer num, string msg, key id)
    {
        if(num == 50 && sender_num == 1) {
            llOwnerSay((string)llSubStringIndex(msg,"Set|"));
            //if(llSubStringIndex(msg,"Set|")) {}
            llOwnerSay((string)sender_num);
            llOwnerSay((string)num);
            llOwnerSay((string)msg);
        }
    }    
}

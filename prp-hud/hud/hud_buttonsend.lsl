integer primaryHudChannel;
string buttonName;

default
{
    state_entry()
    {  
        primaryHudChannel = (integer)("0xF" + llGetSubString(llGetOwner(),0,6));
        buttonName = llGetObjectDesc();
    }

    touch_start(integer num_detected)
    {
        llMessageLinked(LINK_ROOT, 0, buttonName, "");
    }
}
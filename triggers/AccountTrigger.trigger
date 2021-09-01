/*

Account trigger for all events

Class:              Account
Date:               12/18/2014
Version:            1
Last Updated:       12/18/2014
    

////////////////////////////////////////////////////////////////////////////////
*/

trigger AccountTrigger on Account (before insert, after insert, before update, after update) { //before delete, after delete, after undelete
if(Util.isSkipTrigger('AccountTrigger',null)|| util.gethealthyTestSwitch())
    return;
    
    TriggerDispatcher.execute(Account.sObjectType, Trigger.new, Trigger.old, 
        Trigger.newMap, Trigger.oldMap);

    
}
/**
 * Created by cdevarapalli on 8/7/17.
 */

trigger Contact on Contact (before insert, after insert, after update) {
    
    if(Util.isSkipTrigger('Contact', null) || util.gethealthyTestSwitch()) return;

    TriggerDispatcher.execute(Contact.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
/**
 * Created by cdevarapalli on 1/18/18.
 * For Heroku Connect Sunset
 */

trigger ItemTrigger on Item__c (after delete) {
    if(Util.isSkipTrigger('Item__c', null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(Item__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    Diagnostics.pop();
}
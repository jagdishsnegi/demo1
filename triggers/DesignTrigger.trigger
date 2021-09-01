trigger DesignTrigger on Design__c (before insert, before update, before delete, after insert, after update) {
    if(Util.isSkipTrigger('Design', null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(Design__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
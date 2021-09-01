trigger RMATrigger on RMA__c (after insert, after update,before insert) {
    if(Util.isSkipTrigger('RMATrigger', null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(RMA__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
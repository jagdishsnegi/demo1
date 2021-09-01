trigger RMAMilestoneTrigger on RMA_Milestone__c (before insert, before update) {
    if(Util.isSkipTrigger('RMAMilestoneTrigger', null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(RMA_Milestone__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
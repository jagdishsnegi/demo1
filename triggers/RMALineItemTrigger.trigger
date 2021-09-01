trigger RMALineItemTrigger on RMA_Line_Item__c (before insert, before update) {
    if(Util.isSkipTrigger('RMALineItemTrigger', null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(RMA_Line_Item__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
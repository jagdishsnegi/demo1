trigger NIC_Task_Trigger on NIC_Task_Placeholder__c (after insert) {
    if(Util.isSkipTrigger('NIC_Task_Placeholder__c', null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(NIC_Task_Placeholder__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);   
}
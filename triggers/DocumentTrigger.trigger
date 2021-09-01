trigger DocumentTrigger  on Document__c (before insert, before update) {
    if(Util.isSkipTrigger('Document__c', null) || util.gethealthyTestSwitch()) return;
    Diagnostics.push('Document trigger fired');
    TriggerDispatcher.execute(Document__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    Diagnostics.pop();
}
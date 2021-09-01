trigger BusinessRegistrationTrigger on Business_Registration__c (after insert,before insert,before update) {
    if(Util.isSkipTrigger('BusinessRegistrationTrigger',null)|| util.gethealthyTestSwitch())
        return;
    
    TriggerDispatcher.execute(Business_Registration__c.sObjectType, Trigger.new, Trigger.old, 
        Trigger.newMap, Trigger.oldMap);

}
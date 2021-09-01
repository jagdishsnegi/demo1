trigger OpportunityRoleTrigger on Opportunity_Role__c (before insert, after insert, after update) {

    
    if(Util.isSkipTrigger('OpportunityRoleTrigger',null))
        return;
    
    TriggerDispatcher.execute(Opportunity_Role__c.sObjectType, Trigger.new, Trigger.old, 
        Trigger.newMap, Trigger.oldMap);


}
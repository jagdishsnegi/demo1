/*

Opportunity trigger for all events

Date:               01/19/2015
Version:            1
Last Updated:       

////////////////////////////////////////////////////////////////////////////////
*/
trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update){

    Diagnostics.push('Opportunity trigger fired');
    
    if(Util.isSkipTrigger('OpportunityTrigger',null)|| util.gethealthyTestSwitch())
    return;
    
    TriggerDispatcher.execute(Opportunity.sObjectType, Trigger.new, Trigger.old,Trigger.newMap, Trigger.oldMap);
  
    Diagnostics.pop();
}
/*

Lead trigger for all events

Class:              Lead
Date:               03/25/2014
Version:            1
Last Updated:       03/25/2014
    *   Stubbed / Completed

////////////////////////////////////////////////////////////////////////////////
*/

trigger Lead on Lead (before insert, before update,after insert,after update)
{
  Diagnostics.push('Lead trigger fired');
    if(!Util.isSkipTrigger('Lead',null)){
  			TriggerDispatcher.execute(Lead.sObjectType, Trigger.new, Trigger.old,Trigger.newMap, Trigger.oldMap);
        }
  
  Diagnostics.pop();
}
/*************************************************************************************
Trigger Name     :  SiteTrigger
Purpose        :  Site trigger for all events
History:                                                            
-------                                                            
VERSION  AUTHOR                 DATE             DETAIL                                   TICKET REFERENCE/ NO.
1.       Kane Macaspac          09/13/2017       Original Version                         

***************************************************************************************/

trigger SiteTrigger on Site_Information_Form__c (before insert, after insert, after update, before delete, after delete, after undelete) {
    TriggerDispatcher.execute(Site_Information_Form__c.sObjectType, Trigger.new, Trigger.old,Trigger.newMap, Trigger.oldMap);
    Diagnostics.pop();
}
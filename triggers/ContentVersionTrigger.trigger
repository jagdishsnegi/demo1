/*************************************************************************************
Trigger Name   :  ContentVersionTrigger
Purpose        :  Trigger to duplicate the Files in Lightning as
                  Attachments so the community users can access them.
                              
History:                                                            
-------                                                            
VERSION  AUTHOR                 DATE            DETAIL                                  TICKET REFERENCE/ NO.
1.       Alekhya Ravula         04-20-2018      HDR-Upload Files as Attachments         #156827419

******************************************************************************************/

trigger ContentVersionTrigger on ContentVersion (after insert) {
    Diagnostics.push('ContentVersion trigger fired');
    if(!Util.isSkipTrigger('ContentVersion',null)){
        TriggerDispatcher.execute(ContentVersion.sObjectType, Trigger.new, Trigger.old,Trigger.newMap, Trigger.oldMap);
    }
    Diagnostics.pop();
}
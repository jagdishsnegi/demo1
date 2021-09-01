/********************************************************************************************
Name   : beforeInsertUpdateIssueUpdate
Author : Jitendra Kothari
Date   : Sep 26, 2011
Usage  : Trigger on Issue Object to keep mapping of Related Case Owner to Case_Owner__c field.
Case   : 00079081
********************************************************************************************/
trigger beforeInsertUpdateIssueUpdate on Issues__c (before insert, before update) {
    IssueManagement.copyOwnerFromCase(trigger.new, trigger.oldMap);
    if(Trigger.isInsert){
        IssueManagement.CaseHasIssueFieldUpdate(trigger.new);
       }
    
   
}
/*****************************
    Purpose:-Whenever Site Audit Task is mark as Completed send alert to RSM and PSR Users 
    Reference PR"- PR-02115
    Author :- Appirio(Kapil G.)
*****************************/
trigger afterUpdateTask on Task (after update) {
    if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
    {
        return;
    }
    
    if(util.isInContextOfLeadConversion()) return; // Case #00541988
     
    OpportunityManagement.afterUpdateTask(Trigger.newMap,Trigger.oldMap);
    AccountManagement.afterUpdateTask(Trigger.newMap,Trigger.oldMap);    
    ActivityManagement.AfterTaskUpdate(Trigger.new,Trigger.oldMap);
}
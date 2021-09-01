// This trigger only populate Partner Portal User field so 
// As per the  discuss with richard as on 04 the Aug 2009 
// No need to do this becuase the same thing done on insert also,
// so going to comment it  

trigger afterUserUpdate on User(after update)
{
    if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
    {
        return;
    }
    UserManagement.sendMailtoPSR(Trigger.new, Trigger.oldMap);//for case #00068206
    UserTriggerHandler.sharePartnerRecords(trigger.New,trigger.oldMap); //Role Hierarchy Funcionality only for portal users
}
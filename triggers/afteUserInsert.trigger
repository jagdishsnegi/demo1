trigger afteUserInsert on User(after insert)
{
    if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4'){
        
        return;
    }
    if ( UserManagement.IS_TEST ) {
        
        return;
    }
    
    Set<string> userIds= new Set<string>();
    
    for(User u:Trigger.new){
        userIds.add(string.valueOf(u.Id));
    }               
    
    if(userIds.size()>0){
      //UserManagement.afterUserInsertSetPlateau(userIDs);  
      UserManagement.populateSupervisorID(userIDs);
      UserManagement.afterUserInsert (userIDs);       
    }          
    UserTriggerHandler.sharePartnerRecords(trigger.New,null);
}
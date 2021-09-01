trigger afterPartnerApplicationUpdate on Partner_Application__c (before update) {    
    
    if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
	{
		return;
	}
    PartnerApplicationManagement.afterPartnerApplicationUpdate(Trigger.new,Trigger.old);
}
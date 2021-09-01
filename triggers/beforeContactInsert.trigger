trigger beforeContactInsert on Contact (before insert) {
    static List<Account> accList;
/*if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
	{
		return;
	}*/
	if(UserInfo.getUserId()=='00580000003XrG4AAK' || UserInfo.getUserId()=='00580000003XtZwAAK' ||UserInfo.getUserId()=='00580000003Xtm2AAC')
	{
		return;
	}
    ContactManagement.beforeContactInsert(Trigger.newMap,Trigger.new);
    //Prepare a set of Account
    
    Set<String> setAccount = new Set<String>();
    for(Contact c:Trigger.new){
        if(c.LMS_Role__c=='B-Owner/Training Liaison' || c.LMS_Role__c=='TL-Training Liason'){
            setAccount.Add(c.AccountID);
        }
    }

    if(accList == null) {
        accList = [Select id,name,(Select id,LMS_Role__c from Contacts where LMS_Role__c='B-Owner/Training Liaison' or LMS_Role__c='TL-Training Liason') from Account where id in :SetAccount and isPartner=true]; 
    }
    for(Account acc : accList){
        List<Contact> lstC = new List<Contact>();
        lstC = acc.Contacts;
        if(lstC.size()>0){              
            Trigger.new[0].LMS_Role__c.AddError('Only 1 contact may have have a B or TL LMS Function. You already have a contact with a B or TL LMS Function assigned to this account');
        }
    }
    
}
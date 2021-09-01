trigger afterCaseInsert on Case (after insert) {
/*
    // Explicitly set ContactID to null to avoid invalid sharing between partners
    // Invisible Case trigger value should be overwritten
    if(trigger.isInsert){
        list<Case> caseList=new list<Case>();
        for(Case c:trigger.new)
            caseList.add(new Case(ID=c.id, ContactID=null));
        update caseList;
    }

    if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
	{
		return;
	}
    CaseManagement.afterCaseInsert(Trigger.New,Trigger.Old);
*/
}
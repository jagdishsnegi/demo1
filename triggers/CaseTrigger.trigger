trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    if(Util.isSkipTrigger('Case', null) || util.gethealthyTestSwitch()) return;
    if(util.isSkipTrigger()) return;
    
    TriggerDispatcher.execute(Case.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    
    
    if( Trigger.isInsert  && Trigger.isAfter ){
        CaseManagement.afterCaseInsertUpdate(Trigger.oldMap, Trigger.newMap);
        
        if(UserInfo.getUserId()!='00580000003XtZw' && UserInfo.getUserId()!='00580000003Xtm2' && UserInfo.getUserId()!='00580000003XrG4')
        {
            CaseManagement.afterCaseInsert(Trigger.New,Trigger.Old);
        }
        
        // Explicitly set ContactID to null to avoid invalid sharing between partners
        // Invisible Case trigger value should be overwritten
        list<id> recordIdList=new list<id>();
        for(Case c:trigger.new)
            if(c.ContactID != null)
            recordIdList.add(c.id);
        if( recordIdList.size() > 0)
            CaseManagement.resetCaseContactID(recordIdList);
        
    }
    else if( Trigger.isUpdate  && Trigger.isAfter) {
        CaseManagement.afterCaseInsertUpdate(Trigger.oldMap, Trigger.newMap);
        
        
        List<Case> lstCases=new List<Case>();
        if(Trigger.isUpdate)
        {
            CaseManagement.sendEmailOnQAFieldUpdate(Trigger.oldMap, Trigger.newMap);
            for(Case c:Trigger.New)
            {
                System.debug('###'+c.Survey_Sent__c+'::'+Trigger.OldMap.get(c.ID).Survey_Sent__c) ;
                System.debug('####:'+Trigger.OldMap.get(c.Id).RecordTypeId) ;
                if(c.Survey_Sent__c==True && Trigger.OldMap.get(c.ID).Survey_Sent__c==False) //06-19-2018 Added a rework on Recordtype check if the record is CRM or not
                {
                    lstCases.add(c);
                }
            }    
            if(lstCases.size()>0)
            {
                PostCallSurvey.createPostCallSurveyObjectWithContactLastSurveyDateUpdate(lstCases);
            }
        }
    }
    
}
trigger afterCaseInsertUpdate on Case (after insert, after update) 
{
    /*
    if(util.isSkipTrigger())
    {
            return;
    }
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
    } */
}
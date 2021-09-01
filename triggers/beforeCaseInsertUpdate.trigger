trigger beforeCaseInsertUpdate on Case (before insert, before update){
  if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
    {
        return;
    }
  
  if(util.isSkipTrigger())
    {
        return;
    }
    ////Below Methods are Commented For Case#00216417: RMA Re-engineering:Removing all references of RMA related fields. 
//  CaseManagement.checkRmaFieldDependency(Trigger.new, Trigger.old);
// CaseManagement.CheckForTechSupportCases(Trigger.new, Trigger.old);
  CaseManagement.CalculateCalendarWeek(Trigger.new);      
  CaseManagement.beforeCaseInsertUpdate(Trigger.new,Trigger.oldMap);
  if(Trigger.isUpdate){  
    CaseManagement.updateInternalContactName(Trigger.new, Trigger.oldMap);
    //CaseHandler_beforeUpdate.updatecaseRecordType(Trigger.newMap,Trigger.oldMap);
    ServiceCaseTimeCalculator.calculateTime_betweenStatus(Trigger.newmap,Trigger.oldmap);  
  }  
}
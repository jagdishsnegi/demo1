trigger Task_before_Insert on Task (before insert) {

    List<Task> tasksforRecTypes = new List<Task>(); //Case #00541988
    
 if (trigger.new.size() > 0) {
    
    //Added for Case 00062219
    final String taskDescription = '{0} has signed their agreement and joined our North America dealer network. Please order the {1} Welcome Pack and provide them access to the MRC. \n' +

                                 '{2}, please indicate whether you will deliver the pack or it should be delivered directly to the partner. Please let the account team (SM, PDM & PE) know if you foresee a delay in getting this out. \n'+

                                 'Thank You \n'+ 
                                 'Partner Experience';
                                 
    map<ID, ID> taskIdactIdMap = new map<ID, ID>();
    
    //List<Task> lstTasks = new List<Task>();  
      
    String taskID = AccountManagement.getTaskRecordType().get('On-boarding task');
    String casePrefix = Case.SObjectType.getDescribe().getKeyPrefix();
    String accountPrefix = Account.SObjectType.getDescribe().getKeyPrefix();
    String postVisitSurveyPrefix = Post_Visit_Follow_Up_Survey__c.SObjectType.getDescribe().getKeyPrefix(); //Case #00541988     
    Set<Id> caseIdSet = new Set<Id>();    
    
    for (Task tsk : trigger.new) {
        if (tsk.Subject !=null && (tsk.Subject == 'Send Partner Welcome Kit' || tsk.Subject == 'Send Partner Starter Kit' || tsk.Subject.startsWith('MRC Access | Welcome Pack'))){
            tsk.RecordTypeId = taskID;
            tsk.Severity__c='P2 - Significant';      
            //lstTasks.add(tsk);//Added for Case 00062219
        }
        
        if( (tsk.Subject == 'P1 Acknowledgement' || tsk.Subject == 'P5 Acknowledgement' || tsk.Subject == 'P30 Acknowledgement') 
                      && tsk.whatId!=null && ((String)tsk.whatId).startsWith(casePrefix) ){
            caseIdSet.add(tsk.whatId);
        }
        //Added for Case 00062219
        if (tsk.Subject !=null && tsk.Subject.startsWith('MRC Access | Welcome Pack')  &&  tsk.whatId!=null && ((String)tsk.whatId).startsWith(accountPrefix))
                taskIdactIdMap.put(tsk.id, tsk.whatId);
        //Added for Case #00541988
        if((tsk.Subject != null && tsk.Subject.startsWith('Email:')) || 
           ((tsk.whatID != null && String.valueOf(tsk.whatID).startsWith(postVisitSurveyPrefix)) 
            && tsk.Subject != null && (tsk.Subject.contains('Invitation Scheduled') || tsk.Subject.contains('Invitation Sent'))))
            tasksforRecTypes.add(tsk);                                      
    }
    
    //Added for Case 00062219
    map<id, Account> accountIdMap; 
    if(taskIdactIdMap.values().size() > 0)
        accountIdMap = new map<ID, Account>([select id, name, type, Owner.FirstName from Account where id =: taskIdactIdMap.values()]);
    
    Map<Id,Case> caseIdMap;     
    
    if(caseIdSet.size() > 0){
        caseIdMap = new Map<Id,Case>([select id , Complaint_Acknowledgement_Info__c from case where id IN : caseIdSet]);        
    }   
        
    for (Task tsk : trigger.new) {
        if(caseIdMap!=null && caseIdMap.get(tsk.whatId)!=null && caseIdMap.get(tsk.whatId).Complaint_Acknowledgement_Info__c != null){
            tsk.Description = caseIdMap.get(tsk.whatId).Complaint_Acknowledgement_Info__c;
        }
        //Added for Case 00062219
        else if (taskIdactIdMap.containsKey(tsk.id) && accountIdMap != null && accountIdMap.values().size() > 0){
            
            Account tempAcc = accountIdMap.get(tsk.whatId);
            tsk.Subject += ' | '+tempAcc.Name;
            
            list<String> strList = new list<String>();
            strList.add(tempAcc.Name);
            if(tempAcc.type != null)
                strList.add(tempAcc.type);
            else
                strList.add('');
                
            if(tempAcc.Owner.FirstName != null) 
                strList.add(tempAcc.Owner.FirstName);
            else
                strList.add('');
            
            tsk.Description = String.format(taskDescription, strList); 
            //tsk.Status = 'Completed';
        }                    
    }
           
  }
  
  // Done for case # 00050334
  //ActivityManagement.changeTaskRecordType(Trigger.new); //Reduced number of records going to this method for Case #00541988
  if(tasksforRecTypes != null && !tasksforRecTypes.isEmpty())
        ActivityManagement.changeTaskRecordType(tasksforRecTypes);
  
  ActivityManagement.updateCSATActivity(Trigger.new);//for case #00064666
  
  // Done for case # 00073934
  ActivityManagement.BeforeTaskInsert(Trigger.new);  
}
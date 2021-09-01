Trigger Task_After_Insert on Task (after insert, after update) {
if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
    {
        return;
    }
//
// (c) Appirio 2009
// For Tasks related to Cases, set the Case's "Initial Response Timestamp"
// to the current date/time if this is the first related task.
//
// 9/15/2009   Glenn Weinstein
//             Original
// 03/12/2010  Gurvinder Dhillon
//             Customized for SunPower (to use for CRM Case Record Type only)

  final String caseOIDPrefix = '500';    // case IDs always start with 500; we'll identify tasks related to Cases this way
 
  // this trigger should only run on individual task creation, not bulk loads.
  System.debug('Trigger size -> '+Trigger.new.size());
  
  if (Trigger.new.size() == 1) {
    Task t = Trigger.new[0];
    String taskWhatId = t.whatId + '';   // adding a blank string to ensure a non-null value, to avoid a null pointer exception later
    
    // we can identify Tasks associated with outbound emails or logged phone calls, if two conditions are met:
    // 1, the related object is a Case; 2, the task is marked with a Status of Completed (outbound emails and logged
    // calls are automatically marked as Completed upon creation).
    //
    // to avoid having an auto-reply (e.g. via workflow or case auto-response rules) "count" as a reply, start the subject line
    // of the template with "Auto-Reply".
    System.debug('Task subject-> '+t.Subject);
    System.debug('Task Status -> '+t.Status);
    if (taskWhatId.startsWith(caseOIDPrefix) &&
        t.Status == 'Completed' &&
        !t.Subject.startsWith('Email: Auto-Reply')) {
           
      Case c = [SELECT Id, RecordTypeId, CreatedDate, Initial_Response_Timestamp__c, Last_Response_Timestamp__c, BusinessHoursId
                FROM   Case
                WHERE  Id = :t.whatId];
      System.debug('Case -> '+c);
      if (c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRM Case').getRecordTypeId()){          
        c.Last_Response_Timestamp__c = System.now();        
      if (c.Initial_Response_Timestamp__c == null){
        c.Initial_Response_TimeStamp__c = System.now();
        
        // Since this is the first response, let's calculate the Business Hours elapsed from case creation until now.
        Id businessHoursId = c.BusinessHoursId;
        if (businessHoursId == null) {
          BusinessHours bh  = [SELECT Id
                               FROM   BusinessHours
                               WHERE  IsDefault = true];
          businessHoursId = bh.id;
        }

        //The diff method comes back in milliseconds, so we divide by 3600000 to get hours.
        c.Initial_Response_Time_Bus_Hours__c = BusinessHours.diff(businessHoursId, c.CreatedDate, System.now())/3600000.0;
        }
        
        update c;
        
      }
    }
    
  }

//Start for case # 00056861 (Appirio) Jitendra
  List<Task> requiredTaskList = new List<Task>();
  for(Task tsk : Trigger.new) {
          if(tsk.subject != null && tsk.subject.toUpperCase() == 'CREATE ORACLE ACCOUNT') {
          requiredTaskList.add(tsk);   
      }
  }
  
  if(requiredTaskList.size() > 0){
      AccountManagement.sendEmailAfterOracleAccountTaskCreation(requiredTaskList);   
  }
//End for case # 00056861 (Appirio) Jitendra
if(Trigger.isInsert)
	ActivityManagement.sendEmailtoContact(trigger.new, null);//for Case# 00074957
else
	ActivityManagement.sendEmailtoContact(trigger.new, Trigger.oldMap);//for Case# 00074957
//TaskManagement.afterInsertTask(Trigger.newMap);//added for case # 00040489      
}
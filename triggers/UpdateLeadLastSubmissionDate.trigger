/*********************************************************************************
Name : UpdateLeadLastSubmissionDate 
Created By : Bharti Mehta (Appirio)
Created Date : 27 July 2011
Usages : This sets Last_Submission_Date__c of the associated lead with Activity Created date
*********************************************************************************/

trigger UpdateLeadLastSubmissionDate on Task (after insert) {
    Map<Id,Datetime> updateMap = new Map<Id,Datetime>();  
    for(Task tsk : trigger.new)
    {
        if(tsk.WhoId != null && tsk.Subject != null && tsk.Subject.Contains('Form: '))
        {
            updateMap.put(tsk.WhoId ,tsk.CreatedDate);
        }
    }
    if(updateMap == null || updateMap.keyset().isEmpty()) return; //Case#541988
    List<Lead> leadList = [Select Id, Last_Submission_Date__c From Lead where Id In :updateMap.keySet()];
    for(Lead lead: leadList)
    {
        lead.Last_Submission_Date__c = updateMap.get(lead.Id);
    }
    
    if(leadList.size() > 0)
        update leadList;
}
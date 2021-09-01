trigger AccountApprovals on Account_Approvals__c (Before Insert, Before Update, After Insert, After Update) 
{
    //This trigger can potentially fire on all actions of the account approval - make sure to specify the trigger behavior.
	//6/10/2019 - Bharath Rajappan - Removed trigger parameter After delete and Before delete since trigger.new logic is not available for After delete. 
    /**************************** BEGIN: Process Account Approvals Trigger ****************************/
    If(trigger.isAfter)
    {
        List <Account_Approvals__c> approvalsToProcess = new List <Account_Approvals__c>();   
        
        //If trigger is update and the status has changed to "Approved," or record is inserted with "Approved" status,
        //add each Account Approval to the approvalsToProcess List
        for(Account_Approvals__c aa : trigger.new)
        {
            if(trigger.isUpdate)
            {
                Account_Approvals__c oAa = system.trigger.oldMap.get(aa.Id);
                
                if(aa.Status__c == 'Approved' && oAa.Status__c != 'Approved')
                {
                    
                    approvalsToProcess.add(aa); 
                }
            } else if(trigger.isInsert && aa.Status__c == 'Approved') approvalsToProcess.add(aa);
            
        }
        
        //Send all collected Account Approvals to the ProcessAccountApproval Class to begin processing.
        if(!approvalsToProcess.isEmpty())
        {
            ProcessAccountApproval.ProcessAccountApprovalList(approvalsToProcess);
        }
    }
    /**************************** END: Process Account Approvals Trigger ****************************/
}
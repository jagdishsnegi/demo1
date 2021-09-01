trigger SOA2populateDocNoAndPartner on SOA2TransactionDetails__c (before insert,before update,after update) {
     
    /* 
       Workflow update the flag delete_attachment__c after 2 years of transaction date
       at that time we have to delete the transaction detail record as well as the related
       attachment record.
    */
    if(Trigger.isbefore){
        for(SOA2TransactionDetails__c trnDtl:Trigger.New){
            if(trnDtl.Doc_No__c.indexOf('_') > 0){
                /* fetch only transaction no from the pdf file name (Doc_No__c)*/
                trnDtl.Transaction_No__c = trnDtl.Doc_No__c.substring(0,trnDtl.Doc_No__c.indexOf('_'));
            }
        }
    }else{
        List<SOA2TransactionDetails__c> toDelete = new List<SOA2TransactionDetails__c>();   
        List<Attachment> attachmentIdToDel = new List<Attachment>();
        List<EmailRecipient__c> emailRecipientToDel = new List<EmailRecipient__c>();    //Case 00713992 
        Set<Id> SOATransId = new Set<Id>(); //Case 00713992 
        for(SOA2TransactionDetails__c trnDtl:[SELECT ID,Attachment_Id__C,Delete_Attachment__c 
                                                FROM SOA2TransactionDetails__c 
                                                WHERE id in:Trigger.New]){
            
            if(trnDtl.Delete_Attachment__c){
				SOATransId.add(trnDtl.Id);
                toDelete.add(trnDtl);
                if(trnDtl.Attachment_Id__C != NULL)
                    attachmentIdToDel.add(new Attachment(Id=trnDtl.Attachment_Id__C));  
            }       
        }
        //R.Alega (08.JUN.2016) - Case 00713992 - Delete the child EmailRecipient together with the deletion of the parent SOA2TransactionDetails__c
        for(EmailRecipient__c emailRec: [Select Id From EmailRecipient__c Where SOA2TransactionDetail__c IN: SOATransId limit 10000]){
            emailRecipientToDel.add(emailRec);
        }
        
        /* Delete EmailRecipients */
        if(!emailRecipientToDel.isEmpty())
            Database.delete(emailRecipientToDel);
            
        /* Delete transaction details */
        if(!toDelete.isEmpty()){ 
            Database.delete(toDelete);
        }   
        /* Delete attachments */
        if(!attachmentIdToDel.isEmpty()){
            Database.delete(attachmentIdToDel);
        } 
    }
}
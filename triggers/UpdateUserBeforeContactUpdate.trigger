//Shree Prashant & Amit Saha
/*What this trigger does? if the Lease_doc_creation_allowed__c field in Contact is checked, then Lease_doc_creation_allowed__c
in User object would also be checked and i unchecked in Contact, will uncheck in User field.
*/

trigger UpdateUserBeforeContactUpdate on Contact (after insert, after update) {

//START - BIRLASOFT - Paritosh - July-30-2012
//Added this condition below to check if the context is of Lead Conversion then this trigger will not execute anyfurther.
 if(util.isInContextOfLeadConversion()){
 return;
 }
//END - BIRLASOFT - Paritosh

 if(util.isSkipTrigger())
    {
            return;
    }

  Set<id> setContactId = Trigger.newMap.keySet();

 
  List<User> lstU = new List<User>();

  for(User u : [SELECT id, Lease_doc_creation_allowed__c,ContactID FROM User WHERE ContactId IN : setContactId and

ContactID != null])

  {

    if(Trigger.newMap.containsKey(u.ContactID))

    {

              if(Trigger.newMap.get(u.ContactID).Lease_doc_creation_allowed__c == true)

              {

                u.Lease_doc_creation_allowed__c = true;               
                lstU.add(u);

              }

              else if(Trigger.newMap.get(u.ContactID).Lease_doc_creation_allowed__c == false)

              {

                u.Lease_doc_creation_allowed__c = false;                    
                 lstU.add(u); 

              }

    }

  }

  if(!lstU.isEmpty())
  {
      if(System.isFuture())
      {
          Queueable_UserLeaseDocCreation queueLeaseObj = new Queueable_UserLeaseDocCreation(lstU);
          System.enqueueJob(queueLeaseObj);
       }
       else
       {      
          update lstU;
       }
  }
    

}//End Trig UpdateUserBeforeContactUpdate
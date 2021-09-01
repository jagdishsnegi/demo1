/*
This trigger is used to populate the "account" field from the "contact field" 
    of the CSAT object to show the CSAT data on the accounts page.
Name : PopulateAccountfromContact
Creation Date : 14Feb'2011
Related Case : 00055208
*/

trigger PopulateAccountfromContact on CSAT__c (before insert , before update) {
    
    Set<Id> contactIds = new Set<Id>();
    
    for(CSAT__c csat : trigger.new) {
    	//Start 00110370
    	if(csat.Contact__c != null)
    	//End 00110370
        	contactIds.add(csat.contact__c);
    }
    Map<ID, Contact> contactAccountMap = new Map<ID, Contact>([select id, accountid from contact where id in :contactIds]);    
    for(CSAT__c csat : trigger.new) {
        if(trigger.IsUpdate) {
          CSAT__c oldCSAT = trigger.oldMap.get(csat.id);
          if(oldCSAT.account__c != null && oldCSAT.account__c == csat.account__c )
            continue;
        }
        //Start 00110370
    	if(contactAccountMap!= null && contactAccountMap.get(csat.contact__c) != null)
    	//End 00110370
        	csat.account__c = contactAccountMap.get(csat.contact__c).accountId;
    }

}
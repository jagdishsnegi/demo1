//Trigger to check for change in Primary Contact infromation (Phone, Address)
//Only allowed through change in Account information change
//Not applicable for non primary contacts. 

/*** 
MODIFICATION INFORMATION:

version: KCM_12022015 (use this version name to search for the modifications made to the code specific to this version)
author: Kane Chelster Macaspac
last modified date/time: 12/02/2015 08:33 PM PDT
details:
  bug fix in reference to case 00606449 where portal users are not able to 
  create new opportunity records due to a null pointer issue
***/

trigger beforeCheckForPrimaryContactUpdate on Contact(before update){        
    if(Label.Skip_beforeCheckForPrimaryContactUpdate_Trigger=='ON'){
        if(util.isSkipTrigger()){
            return;
        }
    }    
    
    //[KCM_12022015] Commented out below code because it returns a null value when language is not set to English.  
    //               RecordTypeInfosByName() returns the label of the record type, which varies depending on language.
    //               reference: 
    //                         https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_sobject_describe.htm#apex_Schema_DescribeSObjectResult_getRecordTypeInfosByName
    //R.Alega - [07/31/2015] - CRM Case 00502627 - The validation should be limited to Customer Contact only.   
    //System.debug('KCM: Contact Record Type Name is: ' + Schema.SObjectType.Contact.RecordTypeInfosById.get('012800000003KJg').Name); 
    //Id customerContactRecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Customer').RecordTypeId;        
      
    //[KCM_12022015] Replaced above line of code with this one directly below.  
    //               Returns a Contact record type whose DeveloperName/API Name is 'Customer'
    Id customerContactRecordTypeId = SFDCSpecialUtilities.GetRecordTypeIdsByDeveloperName(Contact.SobjectType).get('Customer');
    //RecordType customerContactRecordType = [Select Id from RecordType where (Name = 'Customer' AND SObjectType = 'Contact') Limit 1];    
    System.debug('KCM: Contact Record Type Id is: ' + customerContactRecordTypeId);
    
    for(Contact con : trigger.new) {
        if(!con.isUpdatedFromAccount__c &&             
            con.Primary__c && con.RecordTypeId == customerContactRecordTypeId &&
               (trigger.oldMap.get(con.Id).Phone != con.Phone ||       
               trigger.oldMap.get(con.Id).MailingStreet != con.MailingStreet || 
               trigger.oldMap.get(con.Id).MailingCity != con.MailingCity || 
               trigger.oldMap.get(con.Id).MailingState != con.MailingState ||
               trigger.oldMap.get(con.Id).MailingPostalCode != con.MailingPostalCode || 
               trigger.oldMap.get(con.Id).MailingCountry != con.MailingCountry))
            con.AddError('Primary Contact\'s  phone and address can not be modified. In order to modify, please change the related Account\'s information.');   
        else if(con.isUpdatedFromAccount__c)
            con.isUpdatedFromAccount__c = false;
    }
     
}//End trig beforeCheckForPrimaryContactUpdate
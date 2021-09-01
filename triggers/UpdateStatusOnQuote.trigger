/*** Trigger added in Sunpower TPO Phase 1 -- 20/10/2013, to update the status on Quote ***/
trigger UpdateStatusOnQuote on Case (after update) {

    RecordType rt = [ Select Id from RecordType Where Name='TPO Design System Case'];
    Set<String> set_AccIds = new Set<String>();
    for(Case c : trigger.new){
        //compare recordtype id of a case, status and account
        if(c.RecordTypeId == rt.Id && c.Status != Trigger.oldMap.get(c.Id).status && c.accountId != null){
            set_AccIds.add(c.AccountId);
        }
    }
    Map<Id, Account> map_Account = new Map<Id, Account>([Select Id, Country_Domain__c,billingcountry from Account Where Id IN : set_AccIds]);
    List<Quote> lst_Quote = new List<Quote>();
    for(Case c : trigger.new){
        //comparing record type,status and country domain 
        if(c.RecordTypeId == rt.Id && c.Status != Trigger.oldMap.get(c.Id).status && c.accountId != null && map_Account.containsKey(c.accountId) && map_Account.get(c.AccountId).billingcountry== 'France'){
            if(c.Status == 'Waiting for Partner Response'){
                lst_Quote.add(new Quote(Id=c.Quote__c, Design_Help_Status__c='Awaiting Partner Response'));
            }else if(c.Status == 'Closed'){
                lst_Quote.add(new Quote(Id=c.Quote__c, Design_Help_Status__c='Completed'));
            }else if(c.Status == 'Assigned'){
                lst_Quote.add(new Quote(Id=c.Quote__c, Design_Help_Status__c='Assigned'));
            } else if(c.Status == 'In Process'){
                lst_Quote.add(new Quote(Id=c.Quote__c, Design_Help_Status__c='In Process'));
            } else if(c.Status == 'Cancelled'){
                lst_Quote.add(new Quote(Id=c.Quote__c, Design_Help_Status__c='Cancelled'));
            }else{
                lst_Quote.add(new Quote(Id=c.Quote__c, Design_Help_Status__c=c.status));
            }
        }
    }
    if(!lst_Quote.isEmpty()){
        update lst_Quote;
    }
}
//Trigger to flag DSE_IsCustomer__c to true when an RMA is being created.
trigger RMAAfterInsert on RMA__c (after insert) {

    Map<Id,RMA__c> rmaMap = new Map<Id,RMA__c>([Select Id,Case__r.AccountId from RMA__c where Id IN :Trigger.New]);
    Set<Id> accIdSet = new Set<Id>();
    List<Account> accList = new List<Account>();
    List<Account> toUpdateAccList = new List<Account>();
    
    for(RMA__c rma:Trigger.new){
        //System.debug('rma ----- '+rma);
        accIdSet.add(rmaMap.get(rma.Id).Case__r.AccountId);
    }
    System.debug('accIdSet -----'+accIdSet);
    
    if(!accIdSet.isEmpty())
        accList = [select Id,DSE_IsCustomer__c,DSE_CustomerType__c,Lease_Customer__c,RecordType.Name FROM Account where Id in :accIdSet];
    
    System.debug('accList -----'+accList);  
    for(Account acc:accList){
        //If it's a Lease Customer and is returning material, Customer will not be
        if(acc.DSE_CustomerType__c!='Lease' && acc.DSE_IsCustomer__c!=true && acc.RecordType.Name!='Partner'){
           acc.DSE_IsCustomer__c=true;
           acc.DSE_CustomerType__c='Cash';
           toUpdateAccList.add(acc);
        }
    }
    
    if(!toUpdateAccList.isEmpty())
        update toUpdateAccList;
}
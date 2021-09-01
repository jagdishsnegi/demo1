/**
1. As per the case# updated line#7 :Bharti
**/

trigger beforeInsertUpdateWR_ORACLE_SalesOrder on WR_ORACLE_SalesOrder__c (before insert, before update) {
    
    Map<String, Account> accountMap = new Map<String, Account>();
    Set<String> oracleAccNumbers = new Set<String>();
    List<WR_ORACLE_SalesOrder__c> newSalesOrderList = new List<WR_ORACLE_SalesOrder__c>();
    for(WR_ORACLE_SalesOrder__c so : Trigger.new){
        if(Userinfo.getName() == 'FMW Integration' && Userinfo.getUserId() == '00580000003aECR'){
                so.LastModifiedDateByCastIron__c = System.now();
                System.debug(loggingLevel.INFO, 'so.Not_Modified_by_CastIron__c->' + so.LastModifiedDateByCastIron__c);
        }
        
        if(so.Oracle_Account_Number__c != null){
            oracleAccNumbers.add(so.Oracle_Account_Number__c);
            newSalesOrderList.add(so);
        }
        
    }
    
    if(oracleAccNumbers.size() == 0)
        return;
    
    List<Account> accountList = [SELECT Id,Oracle_Account_Number__c,Theater__c from Account WHERE Oracle_Account_Number__c in: oracleAccNumbers and Theater__c != null];
    for(Account acc : accountList){
        accountMap.put(acc.Oracle_Account_Number__c, acc);
    }
    if(accountMap.size() == 0)
        return;
    for(WR_ORACLE_SalesOrder__c so : newSalesOrderList){
        if(so.Oracle_Account_Number__c != null){
            so.Partner_Account__c = accountMap.get(so.Oracle_Account_Number__c).Id;
        }
    }
    
}
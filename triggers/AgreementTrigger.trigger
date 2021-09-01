trigger AgreementTrigger on echosign_dev1__SIGN_Agreement__c (before insert, after insert, before update, after update,before delete) {
    
    if(Util.isSkipTrigger('AgreementTrigger',null)|| util.gethealthyTestSwitch())
        return;
    
    TriggerDispatcher.execute(echosign_dev1__SIGN_Agreement__c.sObjectType, Trigger.new, Trigger.old, 
        Trigger.newMap, Trigger.oldMap);
     

}
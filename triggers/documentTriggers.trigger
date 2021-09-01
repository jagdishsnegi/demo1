trigger documentTriggers on Document__c (after insert, after Update) {

    if(Trigger.isInsert && Trigger.isAfter){
        DocumentTriggerHandler.afterDocumentInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        DocumentTriggerHandler.afterDocumentUpdate(Trigger.new, Trigger.old); 
    }
}
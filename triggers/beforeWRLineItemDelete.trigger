/**
    Can't delete Warranty Line Item for Warranty_Registration__c  
    that has status = compleated. 
    
    @Author Jitendra Kothari (Appirio Offshore)
**/
trigger beforeWRLineItemDelete on WR_Line_Item__c (before delete) {
    if(util.byPassValidation()) return;//for case#00069241
    Set<Id> wrIds = new Set<Id>();
    
    for(WR_Line_Item__c wrline : trigger.old){
        wrIds.add(wrline.Warranty_Registration__c);
    }
    Map<Id, Warranty_Registration__c> wrMap = new Map<Id, Warranty_Registration__c>([Select Status__c from Warranty_Registration__c where Id in :wrIds and Status__c = 'Completed']);
    if(wrMap.isEmpty()) return;
    for(WR_Line_Item__c wrline : trigger.old){
        if(wrMap.get(wrline.Warranty_Registration__c) != null)
            wrline.addError(System.Label.WR_Line_can_t_be_deleted_if_the_Warranty_Status_is_completed); 
    }
}
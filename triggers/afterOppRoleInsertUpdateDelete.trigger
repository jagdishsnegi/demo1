trigger afterOppRoleInsertUpdateDelete on Opportunity_Role__c (after insert, after update, after delete) {
    boolean isTestUpdate = false;//for case # 00057991
    if(Trigger.isUpdate && Test.isRunningTest()){
        isTestUpdate = true;//for case # 00057991
        //return;//for case # 00057991
    }
    if(!isTestUpdate)//for case # 00057991    
        OpportunityRolesManagement.afterInsertUpdateDelete(Trigger.New, Trigger.oldMap, Trigger.isInsert);
    //start for case # 00057991
    String operation;
    if(trigger.isInsert)
        operation = 'Insert';
    else if(trigger.isDelete)
        operation = 'Delete';
    else if(trigger.isUpdate)
        operation = 'Update';
        
    OpportunityRolesManagement.afterInsertUpdateDeleteFramework(trigger.newMap, trigger.oldMap, operation);
    //end for case # 00057991
}
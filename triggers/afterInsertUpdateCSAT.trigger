/**
    Date :: Mar 10, 2011
    Case :: 00049072
    Case Owner :: (Appirio) Anuradha
*/

trigger afterInsertUpdateCSAT on Customer_Survey_Result__c (before insert, after Insert, after Update) {
    
    if(trigger.isAfter){
        if(Trigger.isInsert){
            PostSurveyCSATClass.afterInsertUpdateCSAT(Trigger.newMap , null , true);
        } 
        if(Trigger.isUpdate) {
            PostSurveyCSATClass.afterInsertUpdateCSAT(Trigger.newMap , Trigger.oldMap , false);
        }
    }
    if(trigger.isBefore && trigger.isInsert){
        PostSurveyCSATClass.updateSysActWalkthrough(trigger.new);
    }
}
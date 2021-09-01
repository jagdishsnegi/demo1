trigger afterUpdatePostVisitFollowupSurvey on Post_Visit_Follow_Up_Survey__c (after update) {
    if(util.isSkipTrigger()){
        return;
    }
    //Start 83101
    PostVisitFollowupSurveyManagement.afterUpdatePostVisitFollowupSurvey(Trigger.newMap,Trigger.oldMap);
    //End 83101
}
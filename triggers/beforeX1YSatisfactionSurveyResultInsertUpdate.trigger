trigger beforeX1YSatisfactionSurveyResultInsertUpdate on X1Y_Satisfaction_Survey_Result__c (before insert,before update) {
    
    X1YSatisfactionSurveyResultManagement.beforeX1YSatisfactionSurveyResultInsertUpdate(Trigger.new , Trigger.oldMap);
}
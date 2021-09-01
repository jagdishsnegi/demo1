trigger LiveChatSurveyResp on Live_Chat_Survey_Response__c (before insert, before update, after insert, after update) {
    if(Util.isSkipTrigger('LiveChatSurveyResp',null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(Live_Chat_Survey_Response__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
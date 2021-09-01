trigger LiveChatTranscript on LiveChatTranscript (before insert, before update, after insert, after update) {
    TriggerDispatcher.execute(LiveChatTranscript.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
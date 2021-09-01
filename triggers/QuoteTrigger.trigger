trigger QuoteTrigger on Quote (before insert,before update,after insert,after update) {
    if(Util.isSkipTrigger('Quote', null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(Quote.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
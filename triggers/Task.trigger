trigger Task on Task (before delete) {
    if(Util.isSkipTrigger('Task', null) || util.gethealthyTestSwitch()) return;
    TriggerDispatcher.execute(Task.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
}
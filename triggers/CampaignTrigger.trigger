trigger CampaignTrigger on Campaign ( after insert , after update ) {
    if(Util.isSkipTrigger('Campaign', null) || util.gethealthyTestSwitch()) return;

    Diagnostics.push('Campaign trigger fired');

    TriggerDispatcher.execute(Campaign.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

    Diagnostics.pop();
}
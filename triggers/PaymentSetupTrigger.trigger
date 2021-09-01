trigger PaymentSetupTrigger on Payment_Setup__c (before insert, before update, after insert, after update) {
	if(Util.isSkipTrigger('Payment Setup', null) || util.gethealthyTestSwitch()) return;

	Diagnostics.push('Payment Setup trigger fired');

	TriggerDispatcher.execute(Payment_Setup__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

	Diagnostics.pop();
}
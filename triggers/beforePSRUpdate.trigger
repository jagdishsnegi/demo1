trigger beforePSRUpdate on PSR__c (before update) {
// bypass DM user

//if(Util.byPassValidation()== true)
//return ;

PSRManagement.beforePSRUpdate (Trigger.new, Trigger.old, Trigger.oldMap);
}
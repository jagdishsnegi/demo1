trigger beforePSRInsert on PSR__c (before insert) {
// bypass DM user
if(Util.byPassValidation()== true)
return ;
  PSRManagement.beforePSRInsert (Trigger.new);

}
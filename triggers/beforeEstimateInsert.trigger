trigger beforeEstimateInsert on Estimate__c(before insert)
{
  // bypass DM user
//if(Util.byPassValidation()== true)
 // return ;

   EstimateManagement.beforeEstimateInsert (Trigger.new);
}
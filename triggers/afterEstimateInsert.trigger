trigger afterEstimateInsert on Estimate__c(after insert)
{
// bypass DM user
//if(Util.byPassValidation()== true)
 // return ;

    EstimateManagement.afterEstimateInsert (Trigger.new);
}
trigger beforeEstimateUpdate on Estimate__c(before update)
{
   // bypass DM user
//if(Util.byPassValidation()== true)
 // return ;
 
 if(UserInfo.getUserId()=='00580000003XrG4AAK' || UserInfo.getUserId()=='00580000003XtZwAAK' ||UserInfo.getUserId()=='00580000003Xtm2AAC')
	{
		return;
	}

   EstimateManagement.beforeEstimateUpdate (Trigger.new, Trigger.old);
}
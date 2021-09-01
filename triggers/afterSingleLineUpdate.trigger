trigger afterSingleLineUpdate on Single_Line__c(after update)
{
   // bypass DM user
    if(Util.byPassValidation()== true)
    
      return ;

    SingleLineManagement.afterSingleLineUpdate (Trigger.new, Trigger.old);
}
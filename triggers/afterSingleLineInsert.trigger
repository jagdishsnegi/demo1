trigger afterSingleLineInsert on Single_Line__c(after insert)
{
 // bypass DM user
    if(Util.byPassValidation()== true)
    
      return ;

   SingleLineManagement.afterSingleLineInsert (Trigger.new);
}
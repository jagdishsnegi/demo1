trigger beforeSingleLineUpdate on  Single_Line__c (before update)
{
    // bypass DM user
    if(Util.byPassValidation()== true)
    
      return ;

    SingleLineManagement.beforeSingleLineUpdate (Trigger.new, Trigger.old);
}
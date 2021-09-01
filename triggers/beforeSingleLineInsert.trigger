trigger beforeSingleLineInsert on Single_Line__c (before insert)
{
 // bypass DM user
    if(Util.byPassValidation()== true)
    
      return ;

    SingleLineManagement.beforeSingleLineInsert (Trigger.new);
}
trigger ConsolidatedLeaseScheduleTriggers on Lease_Schedule__c (Before Insert, Before Update) 
{
 Lease_2_1_PO_Creation__c mc = Lease_2_1_PO_Creation__c.getValues('Year Number');
 Integer year = (Integer)mc.Guarantee_Number__c;

  for(Lease_Schedule__c LS : Trigger.new)
  {
   for (Integer i=1 ; i<= year ; i++)
    {
        if(LS.Annual_Lease_Payments_Year__c == String.valueOf(i) && i == 1)
        {
         LS.Temp_Monthly_Lease_Payments__c = 'Year'+' '+String.valueOf(i)+ ':' + '11 Monthly Lease Payments';
         LS.Monthly_Payments_and_with_automatic_ACH__c = '11 monthly payments of $' + LS.Est_Mthly_Paymt_with_formula__c;
        
        }
        if(LS.Annual_Lease_Payments_Year__c == String.valueOf(i) && i > 1)
        {
         LS.Temp_Monthly_Lease_Payments__c = 'Year'+' '+String.valueOf(i)+ ':' + '12 Monthly Lease Payments';
         LS.Monthly_Payments_and_with_automatic_ACH__c = '12 monthly payments of $' + LS.Est_Mthly_Paymt_with_formula__c;
        
        }// UpdateMonthlyPayment Trigger Condition
        if(LS.Remaining_Lease_Period__c == String.valueOf(i) || LS.Remaining_Lease_Period__c == 'Year'+' '+String.valueOf(i))
        {
            LS.Remaining_Lease_Period__c = 'Year'+' '+String.valueOf(i);
            LS.Guarantee_Year__c = LS.Remaining_Lease_Period__c;
            
        }// UpdateLeasePeriod Trigger Condition

    }
    //String temp = LS.Guarantee_Year__c.substring(5);
    //LS.Record_Count__c = Integer.ValueOf(temp);
    String temp;
    if(LS.Guarantee_Year__c != null && LS.Guarantee_Year__c.contains(' '))
    {
       if(LS.Guarantee_Year__c.split('').size() > 1)
       {
        temp = LS.Guarantee_Year__c.split(' ')[1];
        LS.Record_Count__c = Integer.ValueOf(temp);
       }
       else
       temp = '';
    }
    else
    temp = '';
  }
}
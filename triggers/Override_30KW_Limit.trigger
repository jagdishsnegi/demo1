//--OBSOLITE -- Code moved to QuoteUpdate trigger: 31/08/2012 --//
/* Code Functionality- When the Override_30KW_Limit__c checkbox field is checked, it will check the Override_30KW_Limit__c field in the locked quote and then we can use that to display the 'Create Lease Doc Quote' button at Quote Summary level.*/

/*
trigger Override_30KW_Limit on Quote_Summary__c (After Update) 
{    
  List<Id> lstLockedQID = new List<Id>();
  List<Quote> lstUpdateQ = new List<Quote>(); 
  Map<Id, Quote> mapLockQt = new Map<Id, Quote>();    
   
  for(Quote_Summary__c qs: Trigger.new)
        if(qs.Locked_Scenario__c != null)    
            lstLockedQID.add(qs.Locked_Scenario__c); //Locked Quote Id

        if(!lstLockedQID.isEmpty()) 
            mapLockQt = new Map<Id, Quote>([SELECT id, Override_30KW_Limit__c FROM Quote WHERE Id IN : lstLockedQID ]);
      
    if(!mapLockQt.isEmpty())
    for(Quote_Summary__c qsNew: Trigger.new) 
        if((qsNew.Override_30KW_Limit__c != trigger.OldMap.get(qsNew.Id).Override_30KW_Limit__c) && mapLockQt.containsKey(qsNew.Locked_Scenario__c))          
        lstUpdateQ.add(new Quote(id= qsNew.Locked_Scenario__c, Override_30KW_Limit__c = qsNew.Override_30KW_Limit__c));
                 
        if(!lstUpdateQ.isEmpty()) 
            update lstUpdateQ; 
}//End trig ShowTerminationDocButton
*/


//  START Reetan on 8th Sept.   
trigger Override_30KW_Limit on Quote_Summary__c (After Update) {    
    List<Id> lstLockedQID = new List<Id>();
    List<Quote> lstUpdateQ = new List<Quote>(); 
    Map<Id, Quote> mapLockQt = new Map<Id, Quote>();  

    for(Quote_Summary__c qs: Trigger.new)
        if(qs.Locked_Scenario__c != null)    
            lstLockedQID.add(qs.Locked_Scenario__c); //Locked Quote Id

        if(!lstLockedQID.isEmpty()) 
            mapLockQt = new Map<Id, Quote>([SELECT id, Override_30KW_Limit__c FROM Quote WHERE Id IN : lstLockedQID ]);

    if(!mapLockQt.isEmpty())
    for(Quote_Summary__c qsNew: Trigger.new) {
        if((qsNew.Override_30KW_Limit__c != trigger.OldMap.get(qsNew.Id).Override_30KW_Limit__c || qsNew.Ammendment__c != trigger.OldMap.get(qsNew.Id).Ammendment__c || qsNew.Lease_to_be_Amended__c != trigger.OldMap.get(qsNew.Id).Lease_to_be_Amended__c) && mapLockQt.containsKey(qsNew.Locked_Scenario__c))
            lstUpdateQ.add(new Quote(id= qsNew.Locked_Scenario__c, Override_30KW_Limit__c = qsNew.Override_30KW_Limit__c, Amendment_Type__c = qsNew.Ammendment__c, Lease_tobe_Amended__c = qsNew.Lease_to_be_Amended__c ));
      /**   
        if(qsNew.Ammendment__c != trigger.OldMap.get(qsNew.Id).Ammendment__c )
            lstUpdateQ.add(new Quote(id= qsNew.Locked_Scenario__c, Amendment_Type__c = qsNew.Ammendment__c));       
       
        if(qsNew.Lease_to_be_Amended__c != trigger.OldMap.get(qsNew.Id).Lease_to_be_Amended__c)
            lstUpdateQ.add(new Quote(Id = qsNew.Locked_Scenario__c, Lease_tobe_Amended__c = qsNew.Lease_to_be_Amended__c));
    */
    }              

    if(!lstUpdateQ.isEmpty()) {
        try{
            system.debug('befire update.... ' + lstUpdateQ );
            update lstUpdateQ; 
            system.debug('affffter update.... ' + lstUpdateQ );
        } catch(DMLException e) {system.debug('Excccpyion.... ' + e);}
    }    

}    //  END Reetan on 8th Sept.
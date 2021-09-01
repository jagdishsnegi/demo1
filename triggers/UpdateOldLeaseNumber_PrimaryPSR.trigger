/*PARITOSH SHARMA - May 14
This trigger :- 
-- updates the field "Old_Lease_Number__c" when the "Old_Quote__c" field is updated. 
-- updates the field "Primary_PSR__c" lookup to be Dealer Account's Primary PSR at the time of insert and update.
-- updates the "New_Quote_Lease_Number__c" field value on the Old QS when revision to is done.
*/

trigger UpdateOldLeaseNumber_PrimaryPSR on Quote_Summary__c (before insert, before update, after update)
{
  if(util.isSkipTrigger())
  {
   return;
  }
  
  List<Id> lstQSIds = new List<Id>();
  Set<Id> setoldqsid = new Set<Id>();
  List<Quote_Summary__c> lstoldqs = new List<Quote_Summary__c>();
  List<Account> relAccount = new List<Account>();
  Set<Id> relAccountId = new Set<Id>();
  List<Account> relAccPartnerAcc = new List<Account>();
  //List<Quote_Summary__c> lstQSpopulateOldLeasenumber = new List<Quote_Summary__c>();
  List<Id> lstQSIds1 = new List<Id>();
  Set<Quote_Summary__c> setupdateoldqs = new Set<Quote_Summary__c>();
  List<Quote_Summary__c> lstupdateoldqs = new List<Quote_Summary__c>();
  List<Quote_Summary__c> lstupdateoldqs1 = new List<Quote_Summary__c>();
  List<Quote_Summary__c> lstnewqs = new List<Quote_Summary__c>(); 
  List<Quote_Summary__c> lstAllQs = new List<Quote_Summary__c>(); 
  
  for(Quote_Summary__c qotnew : Trigger.new){
      relAccount.add(qotnew.Account_Name__r);   
      relAccountId.add(qotnew.Account_Name__c);   
  }
  if(relAccountId.size()>0){
  relAccPartnerAcc =[SELECT a.Id, a.Name, a.Partner_Account__c, a.Partner_Account__r.Primary_PSR__c FROM Account a WHERE id IN : relAccountId] ;                
  }
  
// IsUpdate -----START-----    
  if(Trigger.isupdate && Trigger.isbefore)
  {//?? Where does this bracket closed----Amit
  lstQSIds = new List<Id>();
  lstQSIds1 = new List<Id>();
  //relAccount = new List<Account>();
  //relAccountId = new Set<Id>();
  
  setoldqsid = new Set<Id>();
  lstoldqs = new List<Quote_Summary__c>();
  
  for(Quote_Summary__c qotnew : Trigger.new)
  {
     for(Quote_Summary__c qotold : Trigger.old)
     {
         if(qotnew.Old_Quote__c!= null)
         {
          lstQSIds.add(qotnew.id);
         }
         
     //if(qotnew.Old_Quote__c == null && qotnew.Old_Quote__c != qotold.Old_Quote__c)
       {
         if(qotnew.Old_Quote__c != qotold.Old_Quote__c)
         {
          lstQSIds1.add(qotnew.id);
         }
       }
   //relAccount.add(qotnew.Account_Name__r);   
   //relAccountId.add(qotnew.Account_Name__c);  
    }
  
// This section updates the QS field "Old_Lease_Number__c" to null or blank if the "Old_Quote__c" field is made blank from a 
// having a value already.
   if(lstQSIds1.size()>0)
   {
    for(Quote_Summary__c qs : trigger.New){
      for(Quote_Summary__c qsold : trigger.Old){
          if(qs.Old_Quote__c == null && qsold.Old_Quote__c != null){
          qs.Old_Lease_Number__c = ''; 
          }
      }
    }
   }
  }// Amit Saha- Added the braces becoz the SOQL @ 77 was in for loop
  
// This section fetches the Primary PSR from the QS's DealerAccount and updates the field "Primary_PSR__c" on QS.
  /*--AMit
  if(relAccountId.size()>0)
  {  
  relAccPartnerAcc =[SELECT a.Id, a.Name, a.Partner_Account__c, a.Partner_Account__r.Primary_PSR__c FROM Account a //WHERE id IN : relAccountId] ;                
  }
  --Amit */
  if(relAccPartnerAcc.size()>0)
  {
  for(Quote_Summary__c qotnew : Trigger.new)
    {
      for(Account relAcc : relAccPartnerAcc )
      //for(Account relAcc : [SELECT a.Id, a.Name, a.Partner_Account__c, a.Partner_Account__r.Primary_PSR__c FROM Account a WHERE id IN : relAccountId] )
      {
          if(qotnew.Account_Name__c == relAcc.Id){
           qotnew.Primary_PSR__c = relAcc.Partner_Account__r.Primary_PSR__c;
           }
      }
    }
  } 

// This section fetches the details of the RevisionTo QS so that the LeaseNumber can be fetched 
// and populated in "Old_Lease_Number__c" field of the New QS.
  for(Quote_Summary__c qs : trigger.New)
  {
      setoldqsid.add(qs.Old_Quote__c);
  }
  if(setoldqsid.size()>0)
  {
  lstoldqs = [SELECT id, Locked_Scenario__c, Locked_Scenario__r.Final_Lease_Number__c, Old_Lease_Number__c FROM Quote_Summary__c WHERE Id IN :setoldqsid];
  }
  if(lstoldqs.size()>0)
    {
     for(Quote_Summary__c qs : trigger.New)
      {
       for(Quote_Summary__c qsold : lstoldqs)
        {
          if(qs.Old_Quote__c == qsold.Id)
          {
           qs.Old_Lease_Number__c = qsold.Locked_Scenario__r.Final_Lease_Number__c; 
          }
        }
      }
    } 
  }
 
// IsUpdate -----END-----  

// IsInsert -----START---- 
  if(Trigger.isinsert && Trigger.isbefore)
  {
  lstQSIds = new List<Id>();
  lstQSIds1 = new List<Id>();
  //relAccount = new List<Account>();
  //relAccountId = new Set<Id>();
  setoldqsid = new Set<Id>();
  lstoldqs = new List<Quote_Summary__c>();
  /**
  for(Quote_Summary__c qotnew : Trigger.new){
      relAccount.add(qotnew.Account_Name__r);   
      relAccountId.add(qotnew.Account_Name__c);   
  }
  if(relAccountId.size()>0){
  relAccPartnerAcc =[SELECT a.Id, a.Name, a.Partner_Account__c, a.Partner_Account__r.Primary_PSR__c FROM Account a WHERE id IN : relAccountId] ;                
  }
  **/
  if(relAccPartnerAcc.size()>0){
  for(Quote_Summary__c qotnew : Trigger.new){
      for(Account relAcc : relAccPartnerAcc ){
           if(qotnew.Account_Name__c == relAcc.Id && relAcc.Partner_Account__r.Primary_PSR__c != null ){
           qotnew.Primary_PSR__c = relAcc.Partner_Account__r.Primary_PSR__c;
           }
      }
  }
  }
  }
// IsInsert -----END----   

// IsAFTER -----START---- 
  if(Trigger.isupdate && Trigger.isafter){
  lstQSIds = new List<Id>();
  setoldqsid = new Set<Id>();
  lstoldqs = new List<Quote_Summary__c>();
  lstupdateoldqs = new List<Quote_Summary__c>();
  setupdateoldqs = new set<Quote_Summary__c>();
  
// This section updates the Old Quote with the Revised New QS value in field "New_Quote_Lease_Number__c" when a new Revison To is added..  
    for(Quote_Summary__c qotnew : Trigger.new){
        for(Quote_Summary__c qotold : Trigger.old){
             if(qotnew.Old_Quote__c!= null && qotnew.Old_Quote__c != qotold.Old_Quote__c){
             lstQSIds.add(qotnew.id);
             setoldqsid.add(qotnew.Old_Quote__c);
             }
        }
    }
    if(setoldqsid.size()>0 && lstQSIds.size()>0){
    //if(setoldqsid.size()>0){
    //lstoldqs = [SELECT id, Locked_Scenario__c, Locked_Scenario__r.Final_Lease_Number__c, New_Quote_Lease_Number__c, Old_Quote__c FROM Quote_Summary__c WHERE Id IN :setoldqsid];
    lstAllQs = [SELECT id, Locked_Scenario__c, Locked_Scenario__r.Final_Lease_Number__c, New_Quote_Lease_Number__c, Old_Quote__c FROM Quote_Summary__c WHERE Id IN :setoldqsid OR Id IN : lstQSIds];
    }
    
    
    for(Quote_Summary__c qs : lstAllQs){
        
        for(Id oldqsid : setoldqsid){
        if(qs.Id == oldqsid){
        lstoldqs.add(qs);
        }
        }
        
        for(Id newqsid : lstQSIds){
        if(qs.Id == newqsid){
        lstnewqs.add(qs);
        }
        }
    }
    
    if(lstoldqs.size()>0){
      //for(Quote_Summary__c qs : lstnewqs ){
      for(Quote_Summary__c qs : lstnewqs ){
          for(Quote_Summary__c qsold : lstoldqs){
              if(qs.Old_Quote__c == qsold.Id){
              qsold.New_Quote_Lease_Number__c = qs.Locked_Scenario__r.Final_Lease_Number__c; 
              setupdateoldqs.add(qsold);
              }
          }
      }
      lstupdateoldqs.addAll(setupdateoldqs); 
    }   
    
    
// This section updates the Old Quote with NULL value in the field "New_Quote_Lease_Number__c" when a new Revison To is removed from the New QS..     
    lstQSIds = new List<Id>();
    setoldqsid = new Set<Id>();
    lstoldqs = new List<Quote_Summary__c>();
    lstupdateoldqs1 = new List<Quote_Summary__c>();
    
    for(Quote_Summary__c qotnew : Trigger.new){
        for(Quote_Summary__c qotold : Trigger.old){
             if((qotnew.Old_Quote__c == null) && qotnew.Old_Quote__c != qotold.Old_Quote__c ){
             setoldqsid.add(qotold.Old_Quote__c);
             }
        }
    }
    if(setoldqsid.size()>0){
    lstoldqs = [SELECT id, Locked_Scenario__c, Locked_Scenario__r.Final_Lease_Number__c, New_Quote_Lease_Number__c FROM Quote_Summary__c WHERE Id IN :setoldqsid];
    }
    
    if(lstoldqs.size()>0){
      for(Quote_Summary__c qsold : lstoldqs){
         qsold.New_Quote_Lease_Number__c = ''; 
         lstupdateoldqs1.add(qsold);
      }
    }  
  
   if(lstupdateoldqs1.size()>0){
    update lstupdateoldqs1;
    }
    
   if(lstupdateoldqs.size()>0){
    update lstupdateoldqs;
    }
  
  }
// IsAFTER -----END---- 

}// Added by Amit Saha 5/24/2012
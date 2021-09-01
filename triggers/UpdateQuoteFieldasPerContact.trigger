/*** Modified Code -- Sunpower TPO Phase 1 -- 20/10/2013, to implement Primary & Sec contact link to the FR Quote ***/
trigger UpdateQuoteFieldasPerContact on Contact (After Insert, After Update){
    if(util.isInContextOfLeadConversion()) return;

    if(util.isSkipTrigger()) return;
    
    List<Id> lstAccsId = new List<Id>(); //Holder for Related Accounts
    List<Quote> updateQuote = new List<Quote>();  //Holder for Quotes to be updated
    List<Account> Accot = New List<Account>();
    Map<Id, DateTime> mapAccIdvsCon_Lastmod = new Map<Id,DateTime>(); //Account Map to be updated for Contact Change TimeStamp
  
    for(Contact con: Trigger.new) {
        if(trigger.isInsert)
            lstAccsId.add(con.AccountId);       
 
        if(trigger.isUpdate)
        {
            if(con.Primary__c == true && con.RecordTypeId == SFDCSpecialUtilities.getRecordTypeIdsByDeveloperName(Contact.sObjectType).get('Customer') &&
               (con.FirstName != Trigger.oldMap.get(con.Id).FirstName || 
                con.LastName != Trigger.oldMap.get(con.Id).LastName))
                    mapAccIdvsCon_Lastmod.put(con.AccountId, con.LastModifiedDate);
            
            if(con.FirstName != Trigger.oldMap.get(con.Id).FirstName || con.LastName != Trigger.oldMap.get(con.Id).LastName)       
                lstAccsId.add(con.AccountId);
        }
    }
  
    if(!lstAccsId.isEmpty()) {
        for(Account acc : [SELECT id, name, RecordType.name,
                                  Contact_Last_Modified_Date__c,
                                  (SELECT id, Name, 
                                          Include_in_Lease_Doc__c
                                   FROM Contacts 
                                   WHERE Include_in_Lease_Doc__c = true 
                                   ORDER BY CreatedDate ASC   
                                   LIMIT 2),
                                  (SELECT id, Consolidated_Lease_Number__c,
                                          Quote_Steps__c, Status,
                                          Temp_Contact_1__c, Temp_Contact_2__c,PrimaryContact__c,
                                          SecondaryContact__c,Country_Domain__c,Account_Billing_Country__c          //New Code -- Sunpower TPO Phase 1 -- 20/10/2013
                                   FROM Quotes__r where QuoteType__c!='Loan')
                          FROM Account 
                          WHERE Id IN : lstAccsId])
                          
        {
            if(!mapAccIdvsCon_Lastmod.isEmpty() && mapAccIdvsCon_Lastmod.containsKey(acc.id))           
                Accot.add(new Account(id= acc.id, Contact_Last_Modified_Date__c= mapAccIdvsCon_Lastmod.get(acc.id)));
                List<Contact> lstTempCon = acc.Contacts;
                List<Quote> lstTempQot = acc.Quotes__r;
                     
                if(!lstTempQot.isEmpty()) {
                    for(Quote qot: lstTempQot) {
                        if(!lstTempCon.isEmpty()) {
                        if(qot.Quote_Steps__c == 'Binding Offer' && qot.Status == 'Approved' && acc.RecordType.name=='Residential Customer')
                        {
                            String quotenum = String.valueOf(qot.Consolidated_Lease_Number__c);
                            for(Contact con1 : Trigger.new)
                                con1.addError('Contact cannot be created because the related Quote:- '+ quotenum +' Fields:- Quote Type is "Binding Offer" and Status is "Approved".');
                        }
                        else
                        {
                             
                            //New Code -- Sunpower TPO Phase 1 -- 20/10/2013
                            If(lstTempCon.size() == 1 && ((qot.PrimaryContact__c == null || qot.Temp_Contact_1__c == '') && qot.Account_Billing_Country__c.equalsIgnoreCase('France'))){
                                  updateQuote.add(new Quote(id= qot.Id,PrimaryContact__c= lstTempCon[0].Id)); 
                            }
                            //End New Code -- Sunpower TPO Phase 1 -- 20/10/2013
                            else if(lstTempCon.size() == 1 && (qot.Temp_Contact_1__c == null || qot.Temp_Contact_1__c == ''))
                            {
                                updateQuote.add(new Quote(id= qot.Id, Temp_Contact_1__c= lstTempCon[0].Name)); 
                            }
                            else if(lstTempCon.size() >= 2)
                            {
                                Quote qo = new Quote(id= qot.Id);
                                //New Code -- Sunpower TPO Phase 1 -- 20/10/2013        
                                if(qot.Account_Billing_Country__c.equalsIgnoreCase('France'))
                                {
                                     if(qo.PrimaryContact__c != null && qo.PrimaryContact__c == lstTempCon[0].Id)
                                         qo.PrimaryContact__c = lstTempCon[0].Id;
                                     else if(qo.SecondaryContact__c != null && qo.SecondaryContact__c == lstTempCon[1].Id)
                                         qo.SecondaryContact__c = lstTempCon[1].Id;
                                    else
                                    {
                                        qo.PrimaryContact__c = lstTempCon[0].Id;
                                        qo.SecondaryContact__c = lstTempCon[1].Id;
                                    }    
                                }else{
                                //End New Code -- Sunpower TPO Phase 1 -- 20/10/2013
                                    if(qo.Temp_Contact_1__c != null && qo.Temp_Contact_1__c != '' && qo.Temp_Contact_1__c == lstTempCon[0].Name)
                                        qo.Temp_Contact_2__c= lstTempCon[1].Name;
                                    else if(qo.Temp_Contact_1__c != null && qo.Temp_Contact_1__c != '' && qo.Temp_Contact_1__c == lstTempCon[1].Name)
                                        qo.Temp_Contact_2__c= lstTempCon[0].Name;     
                                    else
                                    {
                                        qo.Temp_Contact_1__c = lstTempCon[0].Name;
                                        qo.Temp_Contact_2__c= lstTempCon[1].Name;
                                    }
                                }  //New Code -- Sunpower TPO Phase 1 -- 20/10/2013
                                        updateQuote.add(qo);                                
                            }
                       }  
                    }//End If
                }//End For
            }//End If
        }//End For
        
    }//isEmpty Check
  
    if(!Accot.isEmpty()) {
        try{
            update Accot;
        }
        catch(System.DmlException e){
            for(Contact c : Trigger.new)
                c.addError(e.getMessage());
        }
    }
    
    if(!UpdateQuote.isEmpty()) {
        Util.setContextOfUpdateQuoteFieldasPerContact();
        update updateQuote;
    }
}
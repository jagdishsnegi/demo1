/*
Trigger to update lead status based on call result received from solar advisor in Five9

Trigger:            TaskAfterInsertCallDispoLeadUpdate
Date:               04/03/2015
Version:            1
Last Updated:       12/14/2015
*   Stubbed
*  Completed
Updates: 
Modified By : 
Modified On : 
Summary : 


////////////////////////////////////////////////////////////////////////////////
*/

trigger TaskAfterInsertCallDispoLeadUpdate on Task (after insert, after update){
    //Collections and Variables
    String leadPrefix = String.valueOf(Lead.SObjectType.getDescribe().getKeyPrefix());
    String optyPrefix = String.valueOf(Opportunity.SObjectType.getDescribe().getKeyPrefix());
    String acctPrefix = String.valueOf(Account.SObjectType.getDescribe().getKeyPrefix());
    List<Task> tasksForLeadUpdates = new List<Task>();//tasks that qualify
    List<Task> tasksForOptyUpdates = new List<Task>();//tasks that qualify
    Map<Id, Opportunity> optytoUpdate = new Map<Id, Opportunity>();//collection of opty with new status
    List<Account> acctToUpdate = new List<Account>();
    Map<Id, Lead> leadsToUpdate = new Map<Id, Lead>();//dml collection of leads with new status
    Set<Id> leadIdsForIncrement = new Set<Id>();
    Set<Id> acctIdsForIncrement = new Set<Id>();
    Set<Id> oppIdsForIncrement  = new Set<Id>();
    Map<Id,String> leadIdTaskCallTypeMap = new Map<Id,String>();
    Map<Id,String> accountIdTaskCallTypeMap = new Map<Id,String>();
    
    Map<String, F9CallDispositions__c> callDispoMap = new Map<String, F9CallDispositions__c>();
    //Collect Call Dispositions from F9 setting for comparison
    for(F9CallDispositions__c f : F9CallDispositions__c.getAll().values()) {
        callDispoMap.put(f.Disposition__c, f);
    }
    
    String outboundStr = '';
    Schema.DescribeFieldResult fieldResult = Task.CallType.getDescribe();
    List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry v : values) {
        if(v.getValue().equalsIgnoreCase('Outbound')){
            outboundStr = v.getValue();
        }
    }
    
    if(callDispoMap.isEmpty()) return;//just in case
    
    //Begin qualifying tasks
    for(Task newTask : trigger.new) {
        if(newTask.CallDisposition != null && ( newTask.Subject.Contains('Call') || newTask.CTI_TaskType__c.Contains('Call') || newTask.CallType == 'Outbound' )) {
               //Lead updates
               if(newTask.WhoId != null && String.valueOf(newTask.WhoId).startsWith(leadPrefix)) {
                   
                   if(trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(newTask.Id).CallType == null && newTask.CallType != trigger.oldMap.get(newTask.Id).CallType)){
                       leadIdTaskCallTypeMap.put(newTask.WhoId,String.valueOf(newTask.CallType));
                   }
                   if(newTask.CallType == 'Outbound' && (trigger.isInsert || (trigger.isUpdate && newTask.CallDisposition != Trigger.oldMap.get(newTask.Id).CallDisposition))){ 
                       leadIdsForIncrement.add(newTask.WhoId);
                   }
                   if(callDispoMap.keySet().contains(newTask.CallDisposition)) {
                       tasksForLeadUpdates.add(newTask);
                   }
               }
               else if(newTask.WhatId != null && String.valueOf(newTask.WhatId).startsWith(optyPrefix)) {
                   tasksForOptyUpdates.add(newTask);
                   oppIdsForIncrement.add(newTask.WhatId);
               } else if(newTask.WhatId != null && String.valueOf(newTask.WhatId).startsWith(acctPrefix)) {
                   acctIdsForIncrement.add(newTask.WhatId);
                   
                   if(trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(newTask.Id).CallType == null && newTask.CallType != trigger.oldMap.get(newTask.Id).CallType)){
                       accountIdTaskCallTypeMap.put(newTask.WhatId,String.valueOf(newTask.CallType));
                   }
               }
           }
    }
    
    //Collect all necessary data
    Map<Id, Lead> leadDataMap = new Map<Id, Lead>();
    if(!leadIdsForIncrement.isEmpty()) {
        for(Lead ld : [SELECT Id, Call_Attempt__c, Status, Reason__c, First_Contacted_Date_Time__c FROM Lead WHERE Id IN: leadIdsForIncrement]) {
            leadDataMap.put(ld.Id, ld);
        }
    }
    Map<Id, Account> acctDataMap = new Map<Id, Account>();
    if(!acctIdsForIncrement.isEmpty()) {
        for(Account a : [SELECT Id, Call_Attempt__c FROM Account WHERE Id IN: acctIdsForIncrement]) {
            acctDataMap.put(a.Id, a);
        }
    }
    Map<Id, Opportunity> oppDataMap = new Map<Id, Opportunity>();
    if(!oppIdsForIncrement.isEmpty()){
        for(Opportunity o : [SELECT Id, First_Contacted_Date_Time__c FROM Opportunity WHERE Id IN :oppIdsForIncrement]){
            oppDataMap.put(o.Id, o);
        }
    }
    
    //finally loop through leads/tasks, increment counter and update lead field with status and add to list for dml
    if(!leadIdsForIncrement.isEmpty() && !leadDataMap.isEmpty()) {
        for(Lead l : leadDataMap.values()) {
            
            if(!leadDataMap.isEmpty() && leadDataMap.containsKey(l.Id)) {
                
                l.Call_Attempt__c = l.Call_Attempt__c == null ? 1 : leadDataMap.get(l.Id).Call_Attempt__c + 1;
                
                if(leadDataMap.get(l.Id).First_Contacted_Date_Time__c == null){
                    l.First_Contacted_Date_Time__c = Datetime.now();
                }
            }
            leadsToUpdate.put(l.Id, l); //add to map, replace later if needed
            
            if(trigger.isInsert){
                if(tasksForLeadUpdates != null && !tasksForLeadUpdates.isEmpty()) {
                    for(Task t : tasksForLeadUpdates) {
                        for(String s : callDispoMap.keySet()) {
                            if(s == t.CallDisposition) {
                                if(callDispoMap.get(s).Lead_Status__c != null && l.Status != callDispoMap.get(s).Lead_Status__c)
                                    l.Status = callDispoMap.get(s).Lead_Status__c; //only update the lead status if it needs it
                                if(callDispoMap.get(s).Reason__c != null && l.Reason__c != callDispoMap.get(s).Reason__c)
                                    l.Reason__c = callDispoMap.get(s).Reason__c; //only update the reson if it needs it
                                if(callDispoMap.get(s).Trigger_Eloqua_Follow_Up__c != null && callDispoMap.get(s).Trigger_Eloqua_Follow_Up__c != false) 
                                    l.Fourth_follow_up__c = callDispoMap.get(s).Trigger_Eloqua_Follow_Up__c;
                                if(callDispoMap.get(s).Trigger_No_Contact_Activities__c != null && callDispoMap.get(s).Trigger_No_Contact_Activities__c != false)
                                    l.Fifth_follow_up__c = callDispoMap.get(s).Trigger_No_Contact_Activities__c;
                                if(callDispoMap.get(s).Consultation_Type__c != null && l.Consultation_Type__c != callDispoMap.get(s).Consultation_Type__c)
                                    l.Consultation_Type__c = callDispoMap.get(s).Consultation_Type__c; //only update if it needs it
                                leadsToUpdate.put(l.Id, l);
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //finally loop through oppty/tasks, update oppty field with status and add to list for dml
    if(trigger.isInsert){
        if(!tasksForOptyUpdates.isEmpty()){
            for(Task t : tasksForOptyUpdates) {
                for(String s : callDispoMap.keySet()) {
                    if(s == t.CallDisposition) {
                        Opportunity  O = new Opportunity(Id = t.WhatId);
                        o.StageName = callDispoMap.get(s).Lead_Status__c;
                        o.Reason_Won_Lost__c = callDispoMap.get(s).Reason__c;
                        if(o.StageName =='Opportunity Lost') {
                            o.closeDate = system.today();
                        }
                        optyToUpdate.put(o.Id, o);
                    }
                }
            }
        }
    }
    
    if(!oppDataMap.isEmpty()){
        for(Opportunity o : oppDataMap.values()){
            if(o.First_Contacted_Date_Time__c == null){
                o.First_Contacted_Date_Time__c = Datetime.now();
            }
            optytoUpdate.put(o.Id, o);
        }
    }
    
    //loop over account tasks and increment
    if(!acctDataMap.isEmpty()) {
        for(Id i : acctDataMap.keySet()) {
            if(accountIdTaskCallTypeMap.containsKey(i) && accountIdTaskCallTypeMap.get(i) != null && accountIdTaskCallTypeMap.get(i).equalsIgnoreCase(outboundStr)){
                Decimal counter = acctDataMap.get(i).Call_Attempt__c == null ? 1 : acctDataMap.get(i).Call_Attempt__c + 1;
                acctToUpdate.add(new Account(Id = i, Call_Attempt__c = counter));
            }
        }
    }
    
    //finish with dml
    if(!leadsToUpdate.isEmpty()) {
        update leadsToUpdate.values();
    }
    //finish with dml opty
    if(!optyToUpdate.isEmpty()) {
        update optyToUpdate.values();
    }
    
    //finish with dml acct
    if(!acctToUpdate.isEmpty()) {
        update acctToUpdate;
    }
}
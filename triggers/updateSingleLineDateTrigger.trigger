//Created by: Nikki - CS
//This trigger will update the 1L/Electrical Support Due Due field in PSR object 
//whenever there is change in Negotiated Due Date field in Single Line Object
//Case 00364755

trigger updateSingleLineDateTrigger on Single_Line__c (after update, after insert) {

    Set <Id> psrIdToQuery = new Set <Id>();
    
        for (Single_Line__c singleLine : Trigger.new){
        
            if(trigger.isInsert){
                psrIdToQuery.add(singleLine.PSR__c);
            }else if (singleLine.Negotiated_Due_Date__c != Trigger.oldMap.get(singleLine.Id).Negotiated_Due_Date__c){
                psrIdToQuery.add(singleLine.PSR__c);
            }
        }
        
        //Get Single Obj that has designs
        Map<Id, Single_Line__c> singleLineMap = new Map<Id, Single_Line__c>();
        
        List<Single_Line__c>  singleLineQueryList = [SELECT Id, 
                                                   PSR__c,
                                                   Negotiated_Due_Date__c
                                                   FROM Single_Line__c
                                                   WHERE PSR__c in : psrIdToQuery
                                                   ORDER BY CreatedDate DESC Limit 1];
        if(!singleLineQueryList.isEmpty()){
            for(Single_Line__c singleLine : singleLineQueryList){
                if(singleLine.PSR__c != null){
                singleLineMap.put(singleLine.PSR__c, singleLine);
                }
            }
        }

         //List of Design to update
        List<PSR__c> parentPSRRecToUpdate = new List<PSR__c>();
        if(!singleLineMap.isEmpty()){
            PSR__c psr = [SELECT Id, Electrical_Support_Due__c
                                      FROM PSR__c
                                      WHERE Id IN: singleLineMap.KeySet()
                                      ORDER BY CreatedDate DESC LIMIT 1];
                psr.Electrical_Support_Due__c = singleLineMap.get(psr.Id).Negotiated_Due_Date__c;
                parentPSRRecToUpdate.add(psr);
        }

        //Update the design if the list is not empty
        if(!parentPSRRecToUpdate.isEmpty()){
            update parentPSRRecToUpdate;
        }
}
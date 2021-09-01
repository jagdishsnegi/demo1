//Created by: Nikki - CS
//This trigger will update the Negotiated Due field in Design and Single Line object 
//whenever there is change in Array Layout Due and 1L/Electrical Support Due field in PSR Object
//Case 00364755

trigger updatePSRDateTrigger on PSR__c (after insert, after update) {

    Set<Id> designIdToQuery = new Set<Id>();
    Set<Id> singleLineIdToQuery = new Set<Id>();
    
    for(PSR__c psr : Trigger.new){
        if(trigger.isInsert){
            if(psr.Array_Layout_Due__c != null)
                designIdToQuery.add(psr.Design__c);
                
            if (psr.Electrical_Support_Due__c != null)
                singleLineIdToQuery.add(psr.Single_Line__c);
        }else{
            if(psr.Array_Layout_Due__c != Trigger.oldMap.get(psr.Id).Array_Layout_Due__c){
                designIdToQuery.add(psr.Design__c);
            }
            if (psr.Electrical_Support_Due__c != Trigger.oldMap.get(psr.Id).Electrical_Support_Due__c){
                singleLineIdToQuery.add(psr.Single_Line__c);
            }
        }
        
    }
    
        Map<Id, PSR__c> design_psrMap = new Map<Id, PSR__c>();
        Map<Id, PSR__c> singleLine_psrMap = new Map<Id, PSR__c>();
        
        /*
        List<PSR__c> psrQueryList = [SELECT Id, Design__c, Array_Layout_Due__c, Single_Line__c, Electrical_Support_Due__c
                                                        FROM PSR__c
                                                        WHERE Design__c IN : designIdToQuery
                                                        OR Single_Line__c IN : singleLineIdToQuery];
        */
        
        List<PSR__c> psrQueryList = [SELECT Id, Design__c, Array_Layout_Due__c, Single_Line__c, Electrical_Support_Due__c
                                                        FROM PSR__c
                                                        WHERE (Id IN :Trigger.newMap.keySet()) 
                                                        AND (Design__c IN : designIdToQuery
                                                        OR Single_Line__c IN : singleLineIdToQuery)];                                                        
        
        if(!psrQueryList.isEmpty()){
            for(PSR__c psr: psrQueryList){
                if(psr.Design__c != null){
                    design_psrMap.put(psr.Design__c, psr);
                    System.debug('+++Design : '+psr.Design__c);
                }
                
                if(psr.Single_Line__c != null){
                    singleLine_psrMap.put(psr.Single_Line__c, psr);
                    System.debug('+++Design : '+psr.Design__c);
                }
            }
        }
        
        //List of Design to update
        List<Design__c> designRecToUpdate = new List<Design__c>();
        
        if(!design_psrMap.isEmpty()){
            Design__c design = [SELECT Id, Date_of_Agreed_Delivery__c             
                                    FROM Design__c 
                                    WHERE Id IN: design_psrMap.KeySet()
                                    ORDER BY CreatedDate DESC LIMIT 1];
            if(design_psrMap.containsKey(design.Id)){                        
                design.Date_of_Agreed_Delivery__c = design_psrMap.get(design.Id).Array_Layout_Due__c;
                designRecToUpdate.add(design);
            }                      
        }
        
        //Update the parent design if the list is not empty
        if(!designRecToUpdate.isEmpty()){
            update designRecToUpdate;
        }
        
        //List of SingleLine to update
        List<Single_Line__c> singleLineRecToUpdate = new List<Single_Line__c>();
        
    if(!singleLine_psrMap.isEmpty()){
            Single_Line__c singleLine = [SELECT Id, Negotiated_Due_Date__c
                                             FROM Single_Line__c
                                             WHERE Id IN: singleLine_psrMap.KeySet()
                                             ORDER BY CreatedDate DESC LIMIT 1];
            if(singleLine_psrMap.containsKey(singleLine.Id)){
                singleLine.Negotiated_Due_Date__c = singleLine_psrMap.get(singleLine.Id).Electrical_Support_Due__c;
                singleLineRecToUpdate.add(singleLine);
            }
        }
        
        //Update the parent single line if the list is not empty
        if(!singleLineRecToUpdate.isEmpty()){
            update singleLineRecToUpdate;
        }             
}
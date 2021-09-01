//Created by: Nikki - CS
//This trigger will update the Array Layout Due field in PSR object 
//whenever there is change in Negotiated Due Date field in Design Object
//Case 00364755

trigger updateDesignDateTrigger on Design__c (after insert, after update) {

    Set <Id> psrIdToQuery = new Set <Id>();
    
        for (Design__c design : Trigger.new){
            if(trigger.isInsert){
                psrIdToQuery.add(design.PSR__c);
            }else if (design.Date_of_Agreed_Delivery__c != Trigger.oldMap.get(design.Id).Date_of_Agreed_Delivery__c) {             
                psrIdToQuery.add(design.PSR__c);
            }          
        }
        
        //Get Design Obj that has designs
        Map<Id, Design__c> designMap = new Map<Id, Design__c>();
        
        List<Design__c>  designQueryList = [SELECT Id, 
                                   PSR__c,
                                   Date_of_Agreed_Delivery__c
                                   FROM Design__c
                                   WHERE PSR__c in : psrIdToQuery
                                   ORDER BY CreatedDate DESC Limit 1];
        if(!designQueryList.isEmpty()){
            for(Design__c design : designQueryList){
                if(design.PSR__c != null){
                designMap.put(design.PSR__c, design);
                }
                
                
            }
        }
        
        //List of Design to update
        List<PSR__c> parentPSRRecToUpdate = new List<PSR__c>();
        if(!designMap.isEmpty()){
            PSR__c psr = [SELECT Id, Array_Layout_Due__c
                                      FROM PSR__c
                                      WHERE Id IN: designMap.KeySet()
                                      ORDER BY CreatedDate DESC LIMIT 1];
                  psr.Array_Layout_Due__c = designMap.get(psr.Id).Date_of_Agreed_Delivery__c;
                  parentPSRRecToUpdate.add(psr);
        }

        //Update the design if the list is not empty
        if(!parentPSRRecToUpdate.isEmpty()){
            update parentPSRRecToUpdate;
        }
}
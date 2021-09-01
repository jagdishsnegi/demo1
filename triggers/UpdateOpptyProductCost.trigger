trigger UpdateOpptyProductCost on OpportunityLineItem (before insert, before update) {
    
    Set<Id> sPBEIds = new Set<Id>(); //Set of PriceBook Entry Id associated with the Oppty Line Item
    Set<Id> sOpptyIds = new Set<Id>();//Set Of Oppty Id related to Oppty Line Item  
    
    for(OpportunityLineItem OPPLI : Trigger.new) {
        sPBEIds.add(OPPLI.PricebookEntryId);
        sOpptyIds.add(OPPLI.OpportunityId);
    
        if(OPPLI.Cost__c == null)
         OPPLI.Cost__c = 0.0;
    }
  
    //Extract the related records
    Map<Id, Product2> mP = new Map<Id, Product2>(); //Map of related Products
    Map<Id, PricebookEntry> mPBE = new Map<Id, PricebookEntry>(); //Map of related PriceBookEntry
    if(!sPBEIds.isEmpty()) {
        for(pricebookentry pbid: [SELECT Id, Name, Pricebook2Id, Pricebook2.Name, 
                                         Product2Id, Product2.Name, Product2.Unit__c, 
                                         Product2.Cost__c, Product2.Product_Type__c, 
                                         Product2.Wattage_Out__c, Product2.Family 
                                 FROM pricebookentry 
                                 WHERE Id IN: sPBEIds]) {
            mP.put(pbid.Product2Id, new Product2(
                    Id = pbid.Product2Id,
                    Name = pbid.Product2.Name,
                    Cost__c = pbid.Product2.Cost__c,
                    Product_Type__c = pbid.Product2.Product_Type__c,
                    Wattage_Out__c = pbid.Product2.Wattage_Out__c,
                    Unit__c = pbid.Product2.Unit__c)); //Collect the products
            mPBE.put(pbid.id, pbid);//Collect the PriceBookEntry     
        }
    }
    
    //All the related Opportunity
    Map<Id, Opportunity> mParentOppty = new Map<Id, Opportunity>([SELECT Id, Pricebook2Id, Pricebook2.Name, PV_Cost_Pricing__c 
                                                                  FROM Opportunity 
                                                                  WHERE Id IN: sOpptyIds]);
    
    for(OpportunityLineItem oli: Trigger.new) {
        if(!mPBE.isEmpty() && mPBE.containsKey(oli.PricebookEntryId) 
            && !mP.isEmpty() && mP.containsKey(mPBE.get(oli.PricebookEntryId).Product2Id)) {
            
            PricebookEntry pbe = mPBE.get(oli.PricebookEntryId); //Related PriceBookEntry Record for the Oppty Line Item
            Product2 prod = mP.get(mPBE.get(oli.PricebookEntryId).Product2Id); //Related Product2 Record for the Oppty Line Item
      
            //Various Checks and Calculations
            if(prod.Product_Type__c == 'PV Module' && prod.Name.contains('SPR-') && !pbe.Pricebook2.Name.contains('Components') && 
                (oli.Cost__c == null || oli.Cost__c == 0) && !mParentOppty.isEmpty() && mParentOppty.containsKey(oli.OpportunityId)) {
                    oli.Cost__c = (mParentOppty.get(oli.OpportunityId).PV_Cost_Pricing__c != null) ? mParentOppty.get(oli.OpportunityId).PV_Cost_Pricing__c : 0;
            }

            if(pbe.Pricebook2.Name.contains('Components') ||  pbe.Pricebook2.Name.contains('Cost By Quarter')) {
                oli.Cost__c = (mPBE.get(oli.PricebookEntryId).Product2.Cost__c != null) ? mPBE.get(oli.PricebookEntryId).Product2.Cost__c : 0;
            }
   
            if(!pbe.Pricebook2.Name.contains('CVAR')){
            //KM_08042017: Pivotal 147365117; updated filter to include new price book's name
            if(!mParentOppty.isEmpty() && mParentOppty.containsKey(oli.OpportunityId) && 
                mParentOppty.get(oli.OpportunityId).Pricebook2Id != null && 
                String.isNotBlank(mParentOppty.get(oli.OpportunityId).Pricebook2.Name) && 
                (mParentOppty.get(oli.OpportunityId).Pricebook2.Name.startsWith('Systems Price Book') ||
                mParentOppty.get(oli.OpportunityId).Pricebook2.Name.startsWith('NA Commercial Direct')) && 
                oli.Cost__c != null) {              
                

                // Commercial Direct Section 201 tariff tracking additions
                if(pbe.Product2 != null && pbe.Product2.Family == 'Tariff') {
                    oli.Total_Cost1__c = 0;
                    oli.Tariff_Cost__c = oli.Cost__c;
                } else if(pbe.Product2 != null && pbe.Product2.Family == 'Overhead Cost') { //INC5950058 - Overhead Cost Tracking for Gross Margin
                    oli.Total_Cost1__c = 0;
                    oli.Overhead_Cost__c = oli.Cost__c;
                } else if(pbe.Product2.Unit__c == 1000) {
                    oli.Total_Cost1__c = ((oli.Cost__c != null) ? oli.Cost__c : 0) * ((oli.Quantity != null) ? oli.Quantity : 0) * 1000;
                } else if(pbe.Product2.Unit__c == 1 || pbe.Product2.Unit__c != 1000) {
                    oli.Total_Cost1__c = ((oli.Cost__c != null) ? oli.Cost__c : 0) * ((oli.Quantity != null) ? oli.Quantity : 0) * 1;
                }
            }
            else if(oli.Cost__c != null && prod.Wattage_Out__c != null) {                                
                oli.Total_Cost1__c = ((oli.Cost__c != null) ? oli.Cost__c : 0) * ((oli.Quantity != null) ? oli.Quantity : 0) * ((prod.Wattage_Out__c != null) ? prod.Wattage_Out__c : 0);
            }
            else if(oli.Cost__c == null) {
                oli.Total_Cost1__c = 0;
            }
      
            //KM_08042017: Pivotal 147365117; setting value of Total_Cost_new__c from within this trigger instead of through the workflow
            if (oli.Total_Cost1__c >= 0){
                oli.Total_Cost_new__c = oli.Total_Cost1__c; 
            }
        }
        }
    }//End For
}
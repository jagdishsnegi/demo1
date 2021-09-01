/**
    Set WR_FDS_Product__c  CONVERTED_TO_ASSET = true for Warranty_Registration__c  
    that has status = compleated. 
    
    @Author Shailendra Singh (Appirio Offshore)
    
    Populate Asset's Item__c with Item__c of WR_FDS_Product__c
    Modified By: Anjali Khandelwal (Appirio Offshore)
**/
trigger CreateWRItemAssets on Warranty_Registration__c (after update,after Insert) {
    
    //isCustomer Logic Start
    Set<Id> custAcctIdSet = new Set<Id>();
    List<Account> custAcctList = new List<Account>();
    List<Account> custAcctUpdateList = new List<Account>();
    
    for(Warranty_Registration__c wr : trigger.new) {
        if(wr.Customer_SFDC_ID__c!=null && wr.Status__c == 'Draft') {
            if(trigger.isInsert)
            custAcctIdSet.add(wr.Customer_SFDC_ID__c);
            else 
            if(wr.Status__c != trigger.oldMap.get(wr.Id).Status__c)
            custAcctIdSet.add(wr.Customer_SFDC_ID__c);
        }
    }
    
    if(!custAcctIdSet.isEmpty())
        custAcctList = [select Id,DSE_IsCustomer__c,DSE_CustomerType__c FROM Account where Id in :custAcctIdSet];
    
    for(Account acc:custAcctList){
        //Setting is MDM Customer flag to true and Customer Type to Cash Customer if a Warranty Registration is created to be able to distinguish between Lease Customer and Cash Customer since Warranty Registrations are only created for Cash Customers.
        if(acc.DSE_IsCustomer__c!=true){
            acc.DSE_IsCustomer__c=true;
            if(acc.DSE_CustomerType__c == null || acc.DSE_CustomerType__c == '' ){
            acc.DSE_CustomerType__c='Cash';
            }
            custAcctUpdateList.add(acc);
        }
    }
    
    if(!custAcctUpdateList.isEmpty()){
        update custAcctUpdateList;
    }
    //end of isCustomer Logic
    
    if( Trigger.isUpdate){
          
        String errorMsg = System.Label.If_there_is_no_asset_then_status_can_not_be_completed;
            for(Warranty_Registration__c wr : Trigger.new) {
                if(wr.Status__c == 'Completed' && wr.Assets__c == 0){
                    wr.status__c.addError(errorMsg);
                }  
            }
            
        Set<ID> warrantyIds = new Set<ID>();
        Set<ID> completedWarrantyIds = new Set<ID>();
        Set<ID> draftedWarrantyIds = new Set<ID>();
        List<WR_StagingSelection__c> stagingListToDel;
        for(ID id : Trigger.newMap.keySet()){
            if(Trigger.newMap.get(id).Status__c != Trigger.oldMap.get(id).Status__c){
                    warrantyIds.add(id);
                    if(Trigger.newMap.get(id).Status__c == 'Completed')
                         completedWarrantyIds.add(id);
                    else
                         draftedWarrantyIds.add(id);
            }
        }
        if(warrantyIds.size()==0){
             return;
        }
        List<Asset> assetList = new List<Asset>();
        Map<ID,WR_FDS_Product__c> fdsProductsMap = new Map<ID,WR_FDS_Product__c>();
        List<WR_Line_Item__c> wrLineItemList = new List<WR_Line_Item__c>();
        for(WR_Line_Item__c item : [Select w.Id,WR_FDS_Product__r.Item__c,AssetID__c , w.WR_FDS_Product__r.Product_Type__c,w.WR_FDS_Product__r.Product_Name__c,w.WR_FDS_Product__r.Serial_Number__c,w.Warranty_Registration__r.Customer_SFDC_ID__c,w.Warranty_Registration__r.Customer_SFDC_ID__r.Country_Domain__c,Warranty_Registration__r.Delivery_Date__c,Warranty_Registration__r.Status__c From WR_Line_Item__c w Where w.Warranty_Registration__c IN :warrantyIds]){
            wrLineItemList.add(item);
        }   
        Set<String> productNames = new Set<String>();
        Map<String,String> oracleItemIdsMap = new Map<String,String>(); 
        for(Warranty_Registration__c wr : Trigger.new) {
            if(wr.Status__c == 'Completed' && wrLineItemList.size() == 0){
                wr.status__c.addError(errorMsg);
            }
        }
        stagingListToDel = new List<WR_StagingSelection__c>();
        if(!completedWarrantyIds.isEmpty()){// Completed Warranty
            
            Set<Id> stagingIdsToDel = new Set<Id>();
            for(WR_StagingSelection__c stagingRec : [Select id from WR_StagingSelection__c where Warranty_Registration__c in: completedWarrantyIds]){
                stagingListToDel.adD(stagingRec);
                stagingIdsToDel.add(stagingRec.Id);
            }
            if(stagingListToDel.size() > 0 && stagingListToDel.size() <= 3000){
                //delete stagingListToDel;
                WarrantyRegistrationUtil.deleteStagingDataOfCompletedWR(stagingIdsToDel);
            }
        }
        
        if(wrLineItemList.size() > 3000 || stagingListToDel.size() > 3000){
            WR_CreateAssetsBatch createAsset = new WR_CreateAssetsBatch(warrantyIds);
            Database.executeBatch(createAsset);
            return; 
        }
        // Collecting Names
        for(WR_Line_Item__c wrLineItem : wrLineItemList){
            if(wrLineItem.WR_FDS_Product__r.Product_Name__c != null)
                productNames.add(wrLineItem.WR_FDS_Product__r.Product_Name__c);
        } 
        //Collect map of Product2
        Map<String,Product2> productMap = new Map<String,Product2>(); 
        for(Product2 product : [select ID,Name From Product2 where Name IN :productNames]){
            productMap.put(product.Name,product);
        }
        for(WR_Line_Item__c wrLineItem : wrLineItemList){
                if(wrLineItem.Warranty_Registration__r.Status__c == 'Draft')
                    continue;
                Asset asset = new Asset();
                asset.Name = wrLineItem.WR_FDS_Product__r.Product_Name__c; 
                // set product2 id
                if(productMap.containsKey(wrLineItem.WR_FDS_Product__r.Product_Name__c))
                    asset.Product2Id = productMap.get(wrLineItem.WR_FDS_Product__r.Product_Name__c).id;
                asset.AccountId = wrLineItem.Warranty_Registration__r.Customer_SFDC_ID__c;
                asset.IsCompetitorProduct = false;
                asset.SerialNumber = wrLineItem.WR_FDS_Product__r.Serial_Number__c;
                asset.Quantity = 1;
                asset.InstallDate = wrLineItem.Warranty_Registration__r.Delivery_Date__c;
                //setting Asset currency EU for EU, $ for NA
                if(wrLineItem.Warranty_Registration__r.Customer_SFDC_ID__r.Country_Domain__c != null){
                    if(wrLineItem.Warranty_Registration__r.Customer_SFDC_ID__r.Country_Domain__c.endsWith('us'))
                       asset.CurrencyIsoCode = 'USD';
                    else
                       asset.CurrencyIsoCode = 'EUR';
                }
                asset.Description = ''; 
                asset.item__c = wrLineItem.WR_FDS_Product__r.Item__c;
                assetList.add(asset); 
                // update WR_FDS_Products
                WR_FDS_Product__c product = new WR_FDS_Product__c(id=wrLineItem.WR_FDS_Product__c,CONVERTED_TO_ASSET__c = true, Not_Modified_by_CastIron__c = true);
                fdsProductsMap.put(wrLineItem.WR_FDS_Product__c,product); 
        }
        if(!assetList.isEmpty())
            insert assetList;
        if(!fdsProductsMap.isEmpty())
            update fdsProductsMap.values();
        // update WR_Line_item list for Asset lookup
        for(Integer i=0; i<assetList.size(); i++){
            //setting Asset to WR_Line_iem
                wrLineItemList.get(i).AssetID__c = assetList.get(i).id; 
        }
        update wrLineItemList; 
        
        if(draftedWarrantyIds.size() > 0){
            Set<Id> assetIdsToDel = new Set<Id>();
            List<WR_FDS_Product__c> fdsProductList = new List<WR_FDS_Product__c>();
             for(WR_Line_Item__c wrLineItem : wrLineItemList){ 
                assetIdsToDel.add(wrLineItem.AssetID__c);            
                WR_FDS_Product__c product = new WR_FDS_Product__c(id=wrLineItem.WR_FDS_Product__c,CONVERTED_TO_ASSET__c = false, Not_Modified_by_CastIron__c = true);
                fdsProductList.add(product);
             }
             if(assetIdsToDel.size() > 0){
                List<Asset> assets = [Select id from Asset where id in: assetIdsToDel];
                delete assets;
             }
             if(fdsProductList.size() > 0){
                update fdsProductList;
             } 
        }
    
    }
    
      
}
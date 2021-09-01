/**
 Trigger called before insert/update of WR_FDS_Product__c object and do following task
 1. Set WR_FDS_Product__c.Converted_To_Asset__c true if Asset record is exists having serial number of inserted product
 2. WR_FDS_Product__c.WR_ORACLE_SalesOrder__c if there is WR_ORACLE_SalesOrder__c with matching Packing_Slip__c
 3. If packslip is 2 values seperated by comma then split it and save first value in packslip filed and second in alternate packslip
 4. If Alternate packslip have matched Salesorder instead of Packslip then swap them.
 5. As per the case# upadted line #29 :Bharti
 @Author Shailendra Singh (Appiro Offshore)
 

 Last Modified BY :- Anjali Khandelwal (Appiro Offshore)
 Purpose          :- If WR_FDS_Product__c.Product_Name__c with prefix 'PVM, ' matched with Item__c description field then populate
                     that Item into FDS Product
**/
trigger BeforeInserUpdateWR_FDS_Products on WR_FDS_Product__c (before insert, before update) {
    
    Set<String> newSerialNumbers = new Set<String>();
    Set<String> packSlips = new Set<String>();
    Set<String> alternatePackSlips = new Set<String>();
    Set<String> allPackSlips = new Set<String>();
    String[] packslipArray;
    Set<String> PVM_PrefixPdctName = new Set<String>();
    //Map<Id,String> productIdAndDescriptionMap = new Map<Id,String>();
    for(WR_FDS_Product__c product : Trigger.new){
        //start for case #00064893
        System.debug(loggingLevel.INFO, 'product.Not_Modified_by_CastIron__c->'+product.Not_Modified_by_CastIron__c);
        System.debug(loggingLevel.INFO, 'product.Not_Modified_by_CastIron__c->'+Userinfo.getName());
        System.debug(loggingLevel.INFO, 'product.Not_Modified_by_CastIron__c->'+Userinfo.getUserId());
        if(product.Not_Modified_by_CastIron__c != null && !product.Not_Modified_by_CastIron__c 
            && Userinfo.getName() == 'FMW Integration' && Userinfo.getUserId() == '00580000003aECR'){
            product.LastModifiedDateByCastIron__c = System.now();
            System.debug(loggingLevel.INFO, 'product.Not_Modified_by_CastIron__c->' + product.LastModifiedDateByCastIron__c);
        }
        product.Not_Modified_by_CastIron__c = false;
        //End for case #00064893
        if(product.Packing_Slip__c != null && product.Packing_Slip__c.contains(',')){
            packslipArray = product.Packing_Slip__c.split(',');
            product.Packing_Slip__c = packslipArray[0]; 
            product.Alternate_Packing_Slip__c = packslipArray[1];
        }
        if(product.Serial_Number__c != null)
            newSerialNumbers.add(product.Serial_Number__c);
        if(product.Packing_Slip__c != null)
            packSlips.add(product.Packing_Slip__c);
        if(product.Alternate_Packing_Slip__c != null)
            alternatePackSlips.add(product.Alternate_Packing_Slip__c);
          
        //Anjali  > take all product name and add 'PVM, ' as prefix  
        if(product.Product_Name__c != null){
            PVM_PrefixPdctName.add('PVM, '+product.Product_Name__c);
            //productIdAndDescriptionMap.put(product.Id,'PVM, '+product.Product_Name__c);
        }
    }
    allPackSlips.addAll(packSlips);
    allPackSlips.addAll(alternatePackSlips);   
    
    Map<String,WR_ORACLE_SalesOrder__c> salesOrders = new Map<String,WR_ORACLE_SalesOrder__c>();
    for(List<WR_ORACLE_SalesOrder__c> salesOrderList : [select ID,Packing_Slip__c from WR_ORACLE_SalesOrder__c where Packing_Slip__c IN :allPackSlips]){
        for(WR_ORACLE_SalesOrder__c salesOrder : salesOrderList){
            salesOrders.put(salesOrder.Packing_Slip__c,salesOrder);
        }
    }
    
    Set<String> oldSerialNumbers = new Set<String>(); // create Set of Serial Numbers that has Assets created
    for(List<Asset> assetList : [select SerialNumber from Asset where SerialNumber IN :newSerialNumbers]){
        for(Asset asset : assetList){
            oldSerialNumbers.add(asset.SerialNumber);
        }
    }
    
    //Anjali > Query Items that are in PVM_PrefixPdctName (take those items where description matches with values in PVM_PrefixPdctName)
    Map<String,Set<Id>> itemDescMap = new Map<String,Set<Id>>();   
    for(Item__c item : [Select Id, Description__c from Item__c where Description__c in: PVM_PrefixPdctName]){
        if(item.Description__c != null)
            if(itemDescMap.get(item.Description__c) == null)
                itemDescMap.put(item.Description__c,new Set<ID>());
            itemDescMap.get(item.Description__c).add(item.Id);
    }
    
    String packslip;
    for(WR_FDS_Product__c product : Trigger.new){
        if(oldSerialNumbers.contains(product.Serial_Number__c)) // if there is Asset with Serial Number then set Converted_To_Asset__c = true
            product.Converted_To_Asset__c = true;
        if(salesOrders.containsKey(product.Packing_Slip__c)){
            product.WR_ORACLE_SalesOrder__c = salesOrders.get(product.Packing_Slip__c).id;
           
        }else if(salesOrders.containsKey(product.Alternate_Packing_Slip__c)){// Oracle have alternat packslip so swap it with primary
                product.WR_ORACLE_SalesOrder__c = salesOrders.get(product.Alternate_Packing_Slip__c).id;
                packslip = product.Packing_Slip__c;
                product.Packing_Slip__c = product.Alternate_Packing_Slip__c;
                product.Alternate_Packing_Slip__c = packslip; 
        }
        
        //Anjali > If FDS product Product_Name__c matches with Item description then populate Item__c of FDS product with matched Item Id
        if(product.Product_Name__c != null && itemDescMap != null){
            if(itemDescMap.get('PVM, '+product.Product_Name__c) == null)
                product.Exception_on_ItemID_Populate__c = 'Match Not Found';
            else if(itemDescMap.get('PVM, '+product.Product_Name__c).size()>1){
                product.Exception_on_ItemID_Populate__c = 'Duplicate Match Found';
            }else{
                for(ID idItem:itemDescMap.get('PVM, '+product.Product_Name__c))
                        product.Item__c = idItem;
            }
        }
    }
}
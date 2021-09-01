trigger afterPriceListItemInsertUpdate on Price_List_Item__c (after update,after insert) {

//Get the set of product IDs and IDs of Price List Items which are inserted or updated
Map<String,Price_List_Item__c> mapPriceProduct = new Map<String,Price_List_Item__c>();
Set<String> setPriceID = new Set<String>();
for(Price_List_Item__c lst:Trigger.New){
    //Check if two current pricelist item should not have same product uniqueID with overalping dates.if yes then show error
    if(mapPriceProduct.containsKey(lst.Product_Unique_ID__c)){
        Price_List_Item__c price = mapPriceProduct.get(lst.Product_Unique_ID__c);
        if((lst.Effective_Start_Date__c>=price.Effective_Start_Date__c&&lst.Effective_Start_Date__c<=price.Effective_End_Date__c) || (lst.Effective_End_Date__c>=price.Effective_Start_Date__c&&lst.Effective_End_Date__c<=price.Effective_End_Date__c) || (lst.Effective_Start_Date__c<=price.Effective_Start_Date__c&&lst.Effective_End_Date__c>=price.Effective_End_Date__c)){
            lst.Effective_Start_Date__c.AddError('Please modify your Effective Start and End dates.');
        }
    }
    mapPriceProduct.put(lst.Product_Unique_ID__c,lst);
    setPriceID.Add(lst.ID);
}

//Get those already existing pricelist items which has same Product_Unique_ID__c
List<Price_List_Item__c> lstPriceListItem = new List<Price_List_Item__c>();
lstPriceListItem = [Select id,Product_Unique_ID__c,Effective_Start_Date__c,Effective_End_Date__c from Price_List_Item__c where ID not in :setPriceID and Product_Unique_ID__c in:mapPriceProduct.keySet() ];
//Prepare a map for Product_Unique_ID__c which already exists
Map<String,Price_List_Item__c> mapPriceExisted = new Map<String,Price_List_Item__c>();
for(Price_List_Item__c pList:lstPriceListItem){
    mapPriceExisted.put(pList.Product_Unique_ID__c,pList);
}

//Traverse through each record
for(Price_List_Item__c pList:Trigger.New){
    //Check if current pricelist item should not have same product uniqueID as already existed price list item with overalping dates.if yes then show error
    if(mapPriceExisted.containsKey(pList.Product_Unique_ID__c)){
        Price_List_Item__c price = mapPriceExisted.get(pList.Product_Unique_ID__c);
        if((pList.Effective_Start_Date__c>=price.Effective_Start_Date__c&&pList.Effective_Start_Date__c<=price.Effective_End_Date__c) || (pList.Effective_End_Date__c>=price.Effective_Start_Date__c&&pList.Effective_End_Date__c<=price.Effective_End_Date__c) || (pList.Effective_Start_Date__c<=price.Effective_Start_Date__c&&pList.Effective_End_Date__c>=price.Effective_End_Date__c)){
            pList.Effective_Start_Date__c.AddError('Please modify your Effective Start and End dates.');
        }
    }
    
    //Show error if Effective_End_Date__c is earlier than Effective_Start_Date__c
    if(pList.Effective_Start_Date__c>pList.Effective_End_Date__c){
        pList.Effective_End_Date__c.AddError('Effective End Date can not be before Effective Start Date.');
    }
}
}
/*****************************************************************************************************
 Trigger is called after Insert/update of WR_ORACLE_SalesOrder__c and do following task
 
 1. Update lookup of All WR_FDS_Product__c that has pack_slip_no same as WR_ORACLE_SalesOrder__c
 
 @Author Shailendra Singh (Appirio Offshore)
 
******************************************************************************************************/
trigger PopulateSalesOrderInRelatedProducts on WR_ORACLE_SalesOrder__c (after insert, after update) {
    Map<String,WR_ORACLE_SalesOrder__c> salesOrderMap = new Map<String,WR_ORACLE_SalesOrder__c>();
    for(WR_ORACLE_SalesOrder__c salesOrder :Trigger.new){
    	if(salesOrder.Packing_Slip__c != null){
       		salesOrderMap.put(salesOrder.Packing_Slip__c,salesOrder);
    	}
    }   
    String packslip;
    List<WR_FDS_Product__c> updateProducts = new List<WR_FDS_Product__c>();
    for(List<WR_FDS_Product__c> products : [select ID,Packing_Slip__c,WR_ORACLE_SalesOrder__c,Alternate_Packing_Slip__c,Converted_To_Asset__c From WR_FDS_Product__c where Packing_Slip__c IN :salesOrderMap.keySet() OR Alternate_Packing_Slip__c IN :salesOrderMap.keySet()]){
	  	updateProducts.clear();
	    for(WR_FDS_Product__c product : products){
	    		if(salesOrderMap.get(product.Packing_Slip__c) != null){
	    			if(product.WR_ORACLE_SalesOrder__c != salesOrderMap.get(product.Packing_Slip__c).id && !product.Converted_To_Asset__c){
	            		product.WR_ORACLE_SalesOrder__c = salesOrderMap.get(product.Packing_Slip__c).id;
	            		product.Not_Modified_by_CastIron__c = true;//for case #00064893
	            		updateProducts.add(product);
	    			}
	    		}else{
	    			if(product.WR_ORACLE_SalesOrder__c != salesOrderMap.get(product.Alternate_Packing_Slip__c).id && !product.Converted_To_Asset__c){
		    			product.WR_ORACLE_SalesOrder__c = salesOrderMap.get(product.Alternate_Packing_Slip__c).id;
		    			// make alternat packslip primary 
		    			packslip = product.Alternate_Packing_Slip__c;
		    			product.Alternate_Packing_Slip__c = product.Packing_Slip__c;
		    			product.Packing_Slip__c = packslip;
		    			product.Not_Modified_by_CastIron__c = true;//for case #00064893
		    			updateProducts.add(product);
	    			}
	    		}
	    }
	    if(!updateProducts.isEmpty()) 
        	update updateProducts;   
    }
}
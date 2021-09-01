trigger beforePriceListInsertUpdate on Price_List__c (before insert, before update) {
	
	if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
	{
		return;
	}
	// set of opearating units to be checked for duplicate Oracle_Operating_Unit__c 
	Set<String> operatingUnit = new Set<String>();
	// variable to hold number of duplicate Oracle_Operating_Unit__c 
	integer count = 0;
	
	for(Price_List__c p : Trigger.new){
		//if isInsert then check all the Oracle_Operating_Unit__c
		if(Trigger.isInsert && p.Oracle_Operating_Unit__c != null){	
			operatingUnit.add(p.Oracle_Operating_Unit__c);	
		// if isUpdate then check only if Oracle_Operating_Unit__c has been updated		
		}else if(Trigger.isUpdate && p.Oracle_Operating_Unit__c != null){
			if(p.Oracle_Operating_Unit__c != Trigger.oldMap.get(p.Id).Oracle_Operating_Unit__c){
				// if there are more than one records having same Oracle_Operating_Unit__c in the list Trigger.new 
				// then break 
				if(operatingUnit.contains(p.Oracle_Operating_Unit__c)) {
					count =1; 
					break;
				}	
				operatingUnit.add(p.Oracle_Operating_Unit__c);			
			}
		} 
	}//for ends
	//chek for duplicate price list records
	if(operatingUnit != null && operatingUnit.size()>0 && count == 0){
		count = [select count() from Price_List__c where Oracle_Operating_Unit__c in :operatingUnit];
	}
	// if there are duplicate Oracle_Operating_Unit__c then show error
	if(count > 0){
		Trigger.New[0].addError('Duplicate Price List.');
	}	
}//Trigger ends
/******************************************************************
 * Name: CTIDialerTrigger
 * Description: CTI_dialer__c Trigger
 *******************************************************************/
trigger CTIDialerTrigger on CTI_dialer__c (after update) {

	if(trigger.isAfter && trigger.isUpdate){
		
		//Creates entry in "Sunpower_Spectrum_Debug_Log__c" when CTIDialer's Status updates to Error
		CTIDialerTriggerHandler.handleErrorStatusRecords(trigger.new, trigger.oldMap);
	}
}
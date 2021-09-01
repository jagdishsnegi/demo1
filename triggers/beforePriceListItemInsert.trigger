trigger beforePriceListItemInsert on Price_List_Item__c (before insert) {
if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
	{
		return;
	}
for(Price_List_Item__c pList:Trigger.New){
    
    pList.CurrencyISOCode = pList.Currency_Code__c;

}
}
trigger RoleonOpportunity on Opportunity_Role__c (before insert,before Update){    
   
   // bypass DM user
    //if(Util.byPassValidation()== true)
     //return ;    

      /*Set<Id> opplist = new Set<Id>();
    Map<Id,String> mRole = new Map<Id,String>();
    list<opportunity_Role__c> oprlist = new list<opportunity_Role__c>();
    for(Opportunity_Role__c opprole : Trigger.new){
        opplist.add(opprole.id);
    }
    List<opportunity_Role__c> opList = [select Id,RecordTypeId, RecordType.Name from Opportunity_Role__c where Id IN : opplist];
    for(Opportunity_Role__c o : opList){
        mRole.put(o.Id,o.RecordType.Name);
    }
    for(Id op :opplist){
        opportunity_Role__c orObj = new opportunity_Role__c(Id = op);
        orObj.Role_on_Opportunity__c = mRole.get(op) ;
        oprlist.add(orObj); 
    }
    
    Update oprlist;
    */
    
    //Get recordtype info
    Map<ID,String> oppRoletRecordTypes =new Map<ID,String>();
    Schema.DescribeSObjectResult dopp = Schema.SObjectType.Opportunity_Role__c;
    Map<Id,Schema.RecordTypeInfo> oppRoleMapById = dopp.getRecordTypeInfosById();
    for(ID i:oppRoleMapById.keySet()){
        oppRoletRecordTypes.put(i,oppRoleMapById.get(i).name);
    }
     system.debug('----oppRoletRecordTypes------'+oppRoletRecordTypes);   
    for(Opportunity_Role__c opprole : Trigger.new)    
    {
     system.debug('----opprole.HiddenRecordType__c------'+opprole.HiddenRecordType__c);
      If(Trigger.isupdate && oppRoletRecordTypes.containsKey(opprole.HiddenRecordType__c))
       {
          //RecordType record = [Select Id,Name from RecordType  where RecordType.id =: opprole.HiddenRecordType__c];        
          opprole.Role_on_Opportunity__c =  oppRoletRecordTypes.get(opprole.HiddenRecordType__c);
       }
    }
    
  }
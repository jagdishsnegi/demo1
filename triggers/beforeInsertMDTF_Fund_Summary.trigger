trigger beforeInsertMDTF_Fund_Summary on MDTF_Fund_Summary__c (before insert) {

    Map<String,Id> MapAcbidAndAccountId=new Map<String,Id>();
    Set<String> acbPAranetIDs = new Set<String>();
    
    for(MDTF_Fund_Summary__c mdtfFS: Trigger.New) {
            if(mdtfFS.ACBParanet_ID__c != null && mdtfFS.Account__c == null)
                acbPAranetIDs.add(mdtfFS.ACBParanet_ID__c);
    }
    if (acbPAranetIDs.size() ==0)
        return;
    for(Account acc: [select id,ACBParanet_ID__c from Account where ACBParanet_ID__c in :acbPAranetIDs])
        MapAcbidAndAccountId.put(acc.ACBParanet_ID__c,acc.id);
    
    for(MDTF_Fund_Summary__c mdtfFS: Trigger.New) {
            if(mdtfFS.ACBParanet_ID__c != null && mdtfFS.Account__c == null){
                mdtfFS.Account__c = MapAcbidAndAccountId.get(mdtfFS.ACBParanet_ID__c);
            }
    }
    /*
    for(MDTF_Fund_Summary__c obj: Trigger.new){
        if(obj.Account__c == null){
            obj.Account__c='0018000000UqM4B';
        }
    }*/
}
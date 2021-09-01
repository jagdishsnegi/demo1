/*********************************
Name : populateCampaignOnLead
Created Date: 3 May 2011 
Realted Case # 00062997
Summary: Populates the field Campaign on lead of Lead object on campaign insert and delete.
************************************/

trigger populateCampaignOnLead on CampaignMember (after insert , after delete) {

    Set<Id> leadIdSet = new Set<Id>();
    List<Lead> leadToUpdate = new List<Lead>();
    Map<Id,String> LeadIdCampaignIdMap = new Map<Id,String>();  //cdevarapalli Case 525759
    if(trigger.IsInsert){
        for(CampaignMember camp : Trigger.new){
            leadIdSet.add(camp.LeadId);
            //LeadIdCampaignIdMap.put(camp.LeadId,camp.Campaign.Name);   //cdevarapalli Case 525759
        }
        
        for(CampaignMember cm:[select LeadId, Campaign.Name from CampaignMember where Id in :Trigger.new]){
            LeadIdCampaignIdMap.put(cm.LeadId,cm.Campaign.Name);
        }
        
        for(Lead l : [select id,name,rating,RecordTypeId,BU__c , (select id from CampaignMembers where Id IN: Trigger.new),campaign_on_lead__c from lead where id IN :leadIdSet]){
            // Done for case # 00069328
            if(l.campaign_on_lead__c != true){
                if(isRatingBlank(l)){
                    if(l.CampaignMembers.size() > 0){
                        Trigger.newMap.get(l.CampaignMembers[0].Id).addError('Please enter Rating for the Lead: "'+l.name+'" before inserting its Campaign Memeber.');
                        continue;                       
                    }
                }
                //cdevarapalli Case 525759
                if(LeadIdCampaignIdMap.containsKey(l.Id)){
                    l.Last_Campaign_Name__c =LeadIdCampaignIdMap.get(l.Id);
                }
                
                l.campaign_on_lead__c = true;
                l.Campaign_Association_Date__c = DateTime.now();
                leadToUpdate.add(l);
            }
            else{//cdevarapalli Case 525759
                if(LeadIdCampaignIdMap.containsKey(l.Id)){
                    l.Last_Campaign_Name__c=LeadIdCampaignIdMap.get(l.Id);
                }
                leadToUpdate.add(l);
            }
        }
    }else{
        for(CampaignMember camp : Trigger.old){
            leadIdSet.add(camp.LeadId);
        }
        for(Lead l : [select id,name,rating,RecordTypeId,BU__c , (select id from CampaignMembers), campaign_on_lead__c from lead where id IN :leadIdSet]){
            if(l.CampaignMembers.size()== 0) {
                l.campaign_on_lead__c = false;
                // Done for case # 00069328
                if(isRatingBlank(l)){
                    Trigger.old[0].addError('Please enter Rating for the Lead: "'+l.name+'" before deleting its Campaign Member.');
                    continue;
                }
                leadToUpdate.add(l);
            }
        }
    }
    if(leadToUpdate.size() > 0 ){
        //update leadToUpdate;  //cdevarapalli Case 525759
        Set<Lead> leadsSet = new Set<Lead>();
        List<Lead> finalLeadstoUpdate = new List<Lead>();
        leadsSet.addAll(leadToUpdate);
        finalLeadstoUpdate.addAll(leadsSet);
        update finalLeadstoUpdate;
    }
    
    private Boolean isRatingBlank(Lead l){
        
        if(!util.byPassValidation() && (l.RecordTypeId != null && l.RecordTypeId == Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Systems').getRecordTypeId())){
                    // Done for case # 00066557 consolidating business units IBD and Components into 'UPP Intl'.
                    // if (l.BU__c != null && (l.BU__c == 'NA Commercial' || l.BU__c ==  'IBD' || l.BU__c == 'Components' || l.BU__c == 'RLC') && userInfo.getUserId() != '00580000002hsak'){
                    if (l.BU__c != null && (l.BU__c == 'NA Commercial' || l.BU__c ==  'UPP Intl' || l.BU__c == 'RLC') && userInfo.getUserId() != '00580000002hsak'){ 
                        if (l.Rating == null || l.Rating == '')
                            return true;                    
                    }
        }
        return false;
    }    
}
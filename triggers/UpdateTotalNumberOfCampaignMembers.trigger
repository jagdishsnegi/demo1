/* Insert and Delete the Lead on Campaign Member, 
    it will update the Total_No_Leads__c on Campaign.    */

trigger UpdateTotalNumberOfCampaignMembers on CampaignMember (after Insert, after Delete) 
{
    /*
    List<Id> lstCIds = new List<Id>();
    if(trigger.isInsert)
    {
        for(CampaignMember cm: Trigger.new)
            lstCIds.add(cm.CampaignId);
    }
    else if(trigger.isDelete)
    {
        for(CampaignMember cm: Trigger.old) 
            lstCIds.add(cm.CampaignId);
    }
    
    Map<Id, Campaign> mapCamp = new Map<Id, Campaign>();
    if(!lstCIds.isEmpty())
        mapCamp = new Map<Id, Campaign>([SELECT id, Total_No_Leads__c, 
                                            (SELECT id FROM CampaignMembers
                                             WHERE LeadId != null AND ContactId = null LIMIT 50000)
                                         FROM Campaign 
                                         WHERE id IN: lstCIds LIMIT 50000]);
        system.debug('MAP REcords....... ' + mapCamp);        
        
     
    if(!mapCamp.isEmpty())
    {
        List<Campaign> lstCamp = new List<Campaign>();
        

        for(Id cid: mapCamp.keySet())
        {
            if(mapCamp.get(cid).CampaignMembers != null && !mapCamp.get(cid).CampaignMembers.isEmpty()) {
                lstCamp.add(new Campaign(id= cid, 
                                        Total_No_Leads__c = mapCamp.get(cid).CampaignMembers.size()));
                system.debug('INSERT REcords....... '+ lstCamp);                    
            }
            else
                lstCamp.add(new Campaign(id= cid, 
                                        Total_No_Leads__c = 0));                                      
        }
        
        if(!lstCamp.isEmpty()) 
        {
            update lstCamp;
            system.debug('UPDATE REcords....... '+ lstCamp);
        }
        
    }
    */

}
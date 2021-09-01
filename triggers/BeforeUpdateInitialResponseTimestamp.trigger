//This trigger returns the value in hours-minutes after substracting 'Initial_Response_Time_for_Birlasoft__c' from 'Date_Assigned_to_Birlasoft__c'
// when both the fiels have values and default BusinessHours are active.
trigger BeforeUpdateInitialResponseTimestamp on Case (before update)
{
    if(util.isSkipTrigger())
    {
            return;
    }
    
    
    Set<Id> setCId = new Set<Id>();
    for(Case c: trigger.new)
        if(c.Initial_Response_Timestamp__c != null && c.Date_Assigned_to_Birlasoft__c != null)
            setCId.add(c.id);
            
    if(!setCId.isEmpty())
    {
        BusinessHours bh = [SELECT id, isActive FROM businesshours WHERE IsDefault= true AND isActive= true];
        if(bh != null && bh.id != null)
        {
            for(Id cvIds : setCId)
            {
                try
                {
                    Long diff = BusinessHours.diff(bh.id, trigger.newMap.get(cvIds).Date_Assigned_to_Birlasoft__c, trigger.newMap.get(cvIds).Initial_Response_Timestamp__c);
                    trigger.newMap.get(cvIds).Initial_Response_Time_for_Birlasoft__c = String.ValueOf(Integer.valueOf(diff/3600000) + '.' + Math.abs(Integer.valueOf((diff - (Integer.valueOf(diff/3600000)*60*60*1000))/60000)));
                }
                catch(Exception ex)
                {
                    trigger.newMap.get(cvIds).Initial_Response_Time_for_Birlasoft__c = 'ERROR: calculation failed';
                }
            }
        }
    }
}
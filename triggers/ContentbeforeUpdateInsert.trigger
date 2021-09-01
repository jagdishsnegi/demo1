//Written against the PR-02284 to set the latest version of Content
trigger ContentbeforeUpdateInsert on Content__c (before update, before insert) {
    if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
	{
		return;
	}
    //Preapare set of tilte of Contents
    Set<String> setTitle = new Set<String>();
    Set<String> setContentIDToUpdate = new Set<String>();
    map<String,Double> mapTitleHighVersion = new map<String,Double>();
    for(Content__C con:Trigger.New){
        setTitle.Add(con.Title__c);
        setContentIDToUpdate.Add(con.id);
        if(mapTitleHighVersion.containsKey(con.Title__c)){            
            if(con.version_number__c != null){                
                if(mapTitleHighVersion.get(con.Title__c)<con.version_number__c){
                    mapTitleHighVersion.remove(con.Title__c);                    
                    mapTitleHighVersion.put(con.Title__c,con.version_number__c);                    
                }
            }
        }
        else{
            if(con.version_number__c == null)
                mapTitleHighVersion.put(con.Title__c,-1);
            else
                mapTitleHighVersion.put(con.Title__c,con.version_number__c);
        }
    }
    
    //Get all contents which has the Title in the set and prepare map for Title and list of Content
    map<String,List<Content__c>> mapTitleContentLst = new map<String,List<Content__c>>();
    List<Content__c> conToUpdate = new List<Content__c>();
    for(List<Content__c> lstPreContent:[Select id,Latest_Version__c,Title__c,version_number__c from Content__c where Title__c in :setTitle ]){
        for(Content__c con:lstPreContent){
            if(mapTitleContentLst.containsKey(con.Title__C)){
                mapTitleContentLst.get(con.Title__C).Add(con);
            }
            else{
                List<Content__C> lstCon = new List<Content__C>();
                lstCon.Add(con);
                mapTitleContentLst.put(con.Title__C,lstCon);
            }
        }
    }
    
    //If record updated or inserted
    List<Content__C> contentToUpdate = new List<Content__C>();
    Set<String> setContentID = new Set<String>();
    Set<String> setNullVersion = new Set<String>();
   for(Content__c c:Trigger.New){
        //Do, if trigger is called first time
        if(!c.doNotCallTriggerAgain__c){
            Double highestVersion = -1;
            //Set similar title content's latest version false 
            if(mapTitleContentLst.containsKey(c.Title__c)){                
                //Get the highest version in all records
                for(Content__c cc:mapTitleContentLst.get(c.Title__c)){
                    if(cc.version_number__c == null){                        
                        continue;
                    }
                    if(cc.version_number__c > highestVersion){
                        highestVersion = cc.version_number__c;
                    }                   
                }
                //Check version number of current Content
                if(mapTitleHighVersion.get(c.Title__c) != null && mapTitleHighVersion.get(c.Title__c) != -1){
                    if(mapTitleHighVersion.get(c.Title__c) > highestVersion){
                            highestVersion = mapTitleHighVersion.get(c.Title__c);
                    }  
                }                
                
                 c.Latest_Version__c = false;  
                //Update latest version of Contents according to their version number                
                for(Content__c cc:mapTitleContentLst.get(c.Title__c)){                       
                    boolean isToUpdate = false;
                   
                    //If highest version is null if no content has any specified version then set the current content latest.                    
                    if(highestVersion == -1  && !setNullVersion.contains(c.Title__c)){                        
                        setNullVersion.Add(c.Title__c);
                        c.Latest_Version__c = true;  
                        isToUpdate = true;
                        cc.latest_version__c = false;                      
                    }                    
                    else if(c.version_number__c == highestVersion){                        
                        setNullVersion.Add(c.Title__c);
                        c.Latest_Version__c = true;  
                        isToUpdate = true;
                        cc.latest_version__c = false;                         
                    }
                    //If no version is specified
                    else if(cc.version_number__c == null){
                        isToUpdate = true;
                        cc.latest_version__c = false;
                    }
                    else if(cc.version_number__c >= highestVersion && cc.latest_version__c == false ){
                        isToUpdate = true;
                        cc.latest_version__c = true;
                    }
                    else if(cc.version_number__c < highestVersion && cc.latest_version__c == true ){
                        isToUpdate = true;
                        cc.latest_version__c = false;
                    }
                    //Check if the loop Content is not same as current Content which is coming for updation
                    if(!setContentIDToUpdate.contains(cc.id) && isToUpdate){                        
                        cc.doNotCallTriggerAgain__c = true;                        
                        if(!setContentID.contains(cc.id)){
                            contentToUpdate.Add(cc);
                            setContentID.Add(cc.id);
                        }
                    }
                    if(contentToUpdate.size()>200){
                        update contentToUpdate;
                        contentToUpdate.clear(); 
                    }
                }                                                               
            }
            else{
                //Check version number of current Content
                if(mapTitleHighVersion.get(c.Title__c) != null && mapTitleHighVersion.get(c.Title__c) != -1){
                    if(mapTitleHighVersion.get(c.Title__c) > highestVersion){
                            highestVersion = mapTitleHighVersion.get(c.Title__c);
                    }  
                } 
                 //No content already exists with current Title but there are multiple Content coming for insertion and updation with same Title               
                c.Latest_Version__c = false;
                //If highest version is null if no content has any specified version then set the current content latest.
                if(highestVersion == -1  && !setNullVersion.contains(c.Title__c)){
                    setNullVersion.Add(c.Title__c);
                    c.Latest_Version__c = true;                                              
                }                    
                else if(c.version_number__c == highestVersion){
                    c.Latest_Version__c = true;                         
                }                
            }            
        }
        else{
            c.doNotCallTriggerAgain__c = false;            
        }        
    }
    
    if(contentToUpdate.size()>0){        
        update contentToUpdate;
    }
      
}
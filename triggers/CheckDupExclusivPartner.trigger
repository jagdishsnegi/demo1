trigger CheckDupExclusivPartner on Exclusive_Zip_codes__c (before insert, before update) {
List <Exclusive_Zip_codes__c> ExZipRslt = new List <Exclusive_Zip_codes__c>();


map<String,Exclusive_Zip_codes__c> mapZipcodeExclusive = new map<String,Exclusive_Zip_codes__c>();


 // check if there are duplicates in current batch  
for (Exclusive_Zip_codes__c ExZip : Trigger.new) {
    if(mapZipcodeExclusive.containsKey(ExZip.Zip_code__c+ExZip.Country__c)){               
       Exclusive_Zip_codes__c existingrecord = mapZipcodeExclusive.get(ExZip.Zip_code__c+ExZip.Country__c);
       if(ExZip.Zip_code__c == existingrecord.Zip_code__c && ExZip.Country__c == existingrecord.Country__c){
           if((existingrecord.Start_Date__c == null && ExZip.Start_Date__c == null) || (existingrecord.End_Date__c==null && ExZip.End_Date__c==null)){
               ExZip.addError('Assignment dates clashing with another Partner for this zipcode');  
            }
            if((existingrecord.Start_Date__c == null && ExZip.Start_Date__c <= existingrecord.End_Date__c) || (existingrecord.End_Date__c==null && ExZip.End_Date__c >= existingrecord.Start_Date__c)){
               ExZip.addError('Assignment dates clashing with another Partner for this zipcode');  
            }
            if((existingrecord.Start_Date__c != null && ExZip.Start_Date__c <= existingrecord.End_Date__c && ExZip.Start_Date__c >= existingrecord.Start_Date__c) || (existingrecord.End_Date__c!=null && ExZip.End_Date__c >= existingrecord.Start_Date__c && ExZip.End_Date__c <= existingrecord.End_Date__c)){
               ExZip.addError('Assignment dates clashing with another  Partner for this zipcode');   
            }       
       }
    }
    
mapZipcodeExclusive.put(ExZip.Zip_code__c+ExZip.Country__c , ExZip );
 // check if there are duplicates in database
    ExZipRslt = [SELECT Id, End_Date__c, Partner__c, Start_Date__c, Zip_code__c,Country__c from  Exclusive_Zip_codes__c where Zip_code__c = :ExZip.Zip_code__c and Country__c =:ExZip.Country__c ];
    if(ExZipRslt.size()>0){
        if((ExZipRslt[0].Start_Date__c == null && ExZip.Start_Date__c == null) || (ExZipRslt[0].End_Date__c==null && ExZip.End_Date__c==null)){
           ExZip.addError('Assignment dates clashing with exiting assigned Partner for this zipcode');  
        }
        if((ExZipRslt[0].Start_Date__c == null && ExZip.Start_Date__c <= ExZipRslt[0].End_Date__c) || (ExZipRslt[0].End_Date__c==null && ExZip.End_Date__c >= ExZipRslt[0].Start_Date__c)){
           ExZip.addError('Assignment dates clashing with exiting assigned Partner for this zipcode');  
        }
        if((ExZipRslt[0].Start_Date__c != null && ExZip.Start_Date__c <= ExZipRslt[0].End_Date__c && ExZip.Start_Date__c >= ExZipRslt[0].Start_Date__c) || (ExZipRslt[0].End_Date__c!=null && ExZip.End_Date__c >= ExZipRslt[0].Start_Date__c && ExZip.End_Date__c <= ExZipRslt[0].End_Date__c)){
           ExZip.addError('Assignment dates clashing with exiting assigned Partner for this zipcode');   
        }
     }
  }

 }
trigger beforeUserInsertUpdate on User (before Insert,before Update) {
    if(util.isSkipTrigger()){
        return;
    }
    
    //KCM_09.14.2015: find all the UserCountryDomain values in the custom setting
    Map<String, Account_Country_Domains__c> userCountryDomain_setting = Account_Country_Domains__c.getAll();
    
    //Call on update
    if(Trigger.isInsert){
        UserManagement.beforeUserInsert(Trigger.New);
    }
    
    //Start 00112468
    if(Trigger.isUpdate){
        UserManagement.beforeUserUpdate(Trigger.New, Trigger.oldMap);
    }
    //End 00112468
    
    //Fetch Partner users
    List<User> partnerUsers =new List<User>();
    
    //Fetch all users
    List<User> lstAllUsers = new List<User>();
       
    // Fetch Contact and Account ID
    Set<ID> contactIDs = new Set<ID>();
    
    //Fetch contact Ids
    Set<Id> setAllContactIds = new Set<Id>(); 
    
    for(User u : Trigger.new){
      if(u.contactId != null){
        lstAllUsers.add(u);
        setAllContactIds.add(u.contactId);
      }
      if(u.usertype == 'PowerPartner' && u.contactId != null){
            partnerUsers.add(u);            
            contactIDs.add(u.contactID);
      }
    }
    //populate UserContactRole 
    /* commented out on 5/24/2018
    if(lstAllUsers.size() > 0 && setAllContactIds.size() > 0){
      List<AccountContactRelation> lstAccountContactRelation = new List<AccountContactRelation>();
      Map<Id, AccountContactRelation> mapAccountContactRelation = new Map<Id, AccountContactRelation>();
      
      //get all AccountContactRelation records having contact ids already fetched
      lstAccountContactRelation = [select Id, ContactId, Roles from AccountContactRelation where ContactId in :setAllContactIds];
      
      //put all records in map with contactId as key
      for(AccountContactRelation obj : lstAccountContactRelation){
        mapAccountContactRelation.put(obj.ContactId, obj);
      }
      
      //for all users populate UserContactRole field
      for(User userObj : lstAllUsers){
        if(mapAccountContactRelation.containsKey(userObj.ContactId)){
          userObj.UserContactRole__c = mapAccountContactRelation.get(userObj.ContactId).Roles;
        }
      }
    }
    */
    //end update
    //Partner users Found
    Map<ID,Contact> contacts = null;
    if(partnerUsers.size()>0)
        contacts = new Map<Id,Contact>([select ID,Account.Country_Domain__c,AccountId from Contact where id in :contactIDs]);
                
        for(User u:Trigger.New){
            //For Partner USers only 
            if(u.userType == 'PowerPartner' && u.contactId != null && contacts != null && contacts.containsKey(u.contactId)){
                if(contacts != null && contacts.get(u.contactId).Account.Country_Domain__c != null){
                    u.Country_Domain__c = contacts.get(u.contactId).Account.Country_Domain__c;
                }
             }
            //For only Partner Users.  SunPower Internal users should see English. 
            if(u.Country_Domain__c != null && u.usertype == 'PowerPartner'){
                system.debug('usertype-->'+u.usertype);
                String oldLocale =u.LanguageLocaleKey;
                system.debug('oldLocale-->'+oldLocale);
                String oldSid =u.LocaleSidKey;
                 system.debug('oldSid-->'+oldSid);
                
                String newLanguageLocaleKey = fetchLanguageLocaleKey(u);
                system.debug('u---->'+u);
                system.debug('newLanguageLocaleKey-->'+newLanguageLocaleKey);
                if (newLanguageLocaleKey != null && newLanguageLocaleKey != '') {
                    u.LanguageLocaleKey = newLanguageLocaleKey;
                    system.debug('u.LanguageLocaleKey--->'+u.LanguageLocaleKey);
                }
                String newLocaleSidKey = fetchLocaleSidKey(u);
                if (newLocaleSidKey != null && newLocaleSidKey != '') {
                    u.LocaleSidKey = newLocaleSidKey;
                }
                
                //Here code starts for Currency
                System.debug('Here the Currency before::'+ u.CurrencyIsoCode);
                String newCurrency = fetchUserCurrency(u.Country_Domain__c);
                System.debug('Here the Currency by function::'+newCurrency);
                if(newCurrency != null && newCurrency != ''){
                    u.CurrencyIsoCode = newCurrency;
                    u.DefaultCurrencyIsoCode = newCurrency;
                }
                //Here code ends for Currency
                System.debug('Here the Currency after::'+u.CurrencyIsoCode);
                if(u.LanguageLocaleKey  =='') u.LanguageLocaleKey =oldLocale; 
                if(u.LocaleSidKey =='') u.LocaleSidKey = oldSid ;
            }
         }
//....................................
// 1-(Ends) If the user is a partner user then lookup the account object for this partner user. Retrieve the Account.Country_Domain__c field from the partner Account. Set the user.Country_Domain__c field to the same value as the account. This should only be done for partner users. We should not update this field if the user is not a partner user.
//...................................

    public String fetchLanguageLocaleKey(User usr){
 
         String countryDomain = usr.Country_Domain__c;                  
                
         for(String ucd: userCountryDomain_setting.keySet()) {
              if(countryDomain.trim().tolowercase().equals(ucd)) {
                  //KCM_09.14.2015: if there is only one language locale key listed in the custom setting
                  if (!userCountryDomain_setting.get(ucd).language_locale_key1__c.contains(',')) {
                      return userCountryDomain_setting.get(ucd).language_locale_key1__c;
                  }
                  //KCM_09.14.2015: if there is more than one language locale key listed in the custom setting 
                  else {
                      //KCM_09.14.2015: if a match is found, return the value for usr.languagelocalekey
                      if (userCountryDomain_setting.get(ucd).language_locale_key1__c.contains(usr.languagelocalekey)) {
                          system.debug('usr.languagelocalekey-->'+usr.languagelocalekey);
                          return usr.languagelocalekey;
                      } 
                      //KCM_09.14.2015: otherwise, throw the error below...
                      else 
                      {                                                                                      
                          usr.LanguageLocaleKey.addError('Language for country domain ' + ucd + ' should be ' + 
                                                         userCountryDomain_setting.get(ucd).language_locale_key1__c);
                      }
                  }
             }
         } 
      
      return '';
    }

    public  String fetchLocaleSidKey (User usr){
        String countrydomain = usr.Country_Domain__c;
        
        for(String ucd: userCountryDomain_setting.keySet()) {
            if(countryDomain.trim().tolowercase().equals(ucd)) {
                //KCM_09.14.2015: if there is only one locale sid key listed in the custom setting
                if (!userCountryDomain_setting.get(ucd).locale_sid_key1__c.contains(',')) {
                      return userCountryDomain_setting.get(ucd).locale_sid_key1__c;
                } 
                //KCM_09.14.2015: if there is more than one locale sid key listed in the custom setting
                else {
                    //KCM_09.14.2015: if a match is found, return the user record's locale sid key
                    if (userCountryDomain_setting.get(ucd).locale_sid_key1__c.contains(usr.LocaleSIDKey)) {
                        return usr.LocaleSIDKey;
                    } 
                    //KCM_09.14.2015: otherwise, throw the error below...
                    else {
                        usr.LocaleSIDKey.addError('Language for country domain ' + ucd + ' should be ' + 
                                                  userCountryDomain_setting.get(ucd).locale_sid_key1__c);
                    }
                }
            }
        } 

          return '';
    }  
     
    // Here the function for populating Currency starts
    public String fetchUserCurrency(String countrydomain){        
        //KCM_09.14.2015: start of FOR-LOOP; compare user record's countrydomain with the values in the custom setting
        //return the corresponding currency if a match is found
        for(String ucd: userCountryDomain_setting.keySet()) {
            if(countryDomain.trim().tolowercase().equals(ucd)) {
                return userCountryDomain_setting.get(ucd).currency_code__c;
            }
        } //KCM_09.14.2015: end of FOR-LOOP
        
        // By default return USD
        return 'USD';    
    }            
}
trigger checkContactDuplicate on Contact (before insert) {
    //Whether the user is there in the custom setting and the code exectution need to be skipped
    if(util.isSkipTrigger())
        return;
    
    //do not check duplicate contacts for partner users
    if(UserInfo.getuserType() == 'PowerPartner' || UserInfo.getuserType() == 'Partner')
        return;
        
    // Get the map of Last name with Contact object 
    // and set of last name,First Name,phone,email which being inserted
    // map<String,Contact> mapLastNameContact = new map<String,Contact>();
    // Set<String> setFirstName = new Set<String>();        
    // Set<String> setPhone = new Set<String>();
    // map<String,Contact> mapEmailContact = new map<String,Contact>();
        
    // for(Contact con:Trigger.New)
    // {           
    //     if(con.Override_Duplicate_Check__c)//If the contact is marked for No Duplicate check skip 
    //     {
    //         continue;
    //     }
        
    //     //To check if there is any duplicate contact in contacts being inserted 
    //     // when bulk insertion occurs               
    //     // if(mapLastNameContact.containsKey(con.LastName))
    //     // {               
    //     //     Contact existingContact = mapLastNameContact.get(con.LastName);
    //     //     if(con.FirstName == existingContact.FirstName && con.Phone != null && con.Phone == existingContact.Phone && UserInfo.getFirstName() != 'Loanpath' && UserInfo.getLastName() != 'Integration' && UserInfo.getLastName() != 'Vision Commerce Integration User')//Bypass this check for LoanPath Application : Req from Eric, 24th May 2013
    //     //     {                                                                        
    //     //         con.addError('A possible duplicate was found.  The Name and Phone matche another record in the system');                               
    //     //     }//end-if
    //     // }//end-if
        
    //     // if(mapEmailContact.containsKey(con.Email) && UserInfo.getFirstName() != 'Loanpath' && (UserInfo.getLastName() != 'Integration' && UserInfo.getLastName() != 'Vision Commerce Integration User'))//Bypass this check for LoanPath Application : Req from Eric, 14th May 2013
    //     // {               
    //     //     Contact existingContact = mapEmailContact.get(con.Email);
    //     //     if(con.Email != null && con.Email == existingContact.Email)
    //     //     {                                                                        
    //     //         con.addError('A possible duplicate was found.  The Email matches another record in the system');                               
    //     //     }//end-if
    //     // }//end-if
        
    //     mapLastNameContact.put(con.LastName,con);
    //     setFirstName.Add(con.FirstName);             
    //     setPhone.Add(con.Phone);
    //     mapEmailContact.put(con.Email,con);     
    // }//end-for
        
    // //Get the list of existing Contacts which have  same first name, 
    // //lastname,phone or same email      
    // for(List<Contact> lstExistingContacts : [SELECT id, FirstName, LastName, Phone, Email  
    //                                          FROM Contact  
    //                                          WHERE ((LastName IN: mapLastNameContact.keySet() AND 
    //                                                FirstName IN: setFirstName AND 
    //                                                phone IN: setPhone AND  phone != null) OR 
    //                                                (email IN: mapEmailContact.keySet() AND email != null)) AND
    //                                                (Account.RecordType.DeveloperName = 'Home_Owner')
    //                                                ])
    // {                        
    //     for(Contact existingContact:lstExistingContacts)
    //     {           
    //         //Continue if Last Name or email does not exist in the map
    //         if(!mapLastNameContact.containsKey(existingContact.LastName) && !mapEmailContact.containsKey(existingContact.Email))
    //         {                   
    //             continue;
    //         }
                            
    //         //To check if there is any duplicate contact in already inserted Contacts(based on last name+first name+Phone)
    //         if(mapLastNameContact.containsKey(existingContact.LastName))
    //         {
    //             Contact currentcontact = mapLastNameContact.get(existingContact.LastName);                  
    //             if(currentcontact.Override_Duplicate_Check__c) 
    //             {
    //                 continue;
    //             } 
                
    //             if(currentContact.FirstName == existingContact.FirstName && currentContact.Phone != null && currentContact.Phone == existingContact.Phone && UserInfo.getFirstName() != 'Loanpath' && UserInfo.getLastName() != 'Integration' && UserInfo.getLastName() != 'Vision Commerce Integration User')//Bypass this check for LoanPath Application : Req from Eric, 24th May 2013
    //             {                      
    //                 currentContact.addError('A possible duplicate was found.  The Name and Phone match another record in the system');
    //             }               
    //         }   
            
    //         //To check if there is any duplicate contact in existing Contacts(based on email)
    //         if(mapEmailContact.containsKey(existingContact.Email)  && UserInfo.getFirstName() != 'Loanpath' && (UserInfo.getLastName() != 'Integration' && UserInfo.getLastName() != 'Vision Commerce Integration User'))//Bypass this check for LoanPath Application : Req from Eric, 14th May 2013
    //         {
    //             Contact currentcontact = mapEmailContact.get(existingContact.Email);                    
    //             if(currentcontact.Override_Duplicate_Check__c) 
    //             {
    //                 continue;
    //             }    
    //             if(currentContact.Email!=null && currentContact.Email==existingContact.Email)
    //             {                      
    //                 currentContact.addError('A possible duplicate was found.  The Email matches another record in the system');
    //             }               
    //         }                                            
    //     }//end-for
    // }//end-for
}
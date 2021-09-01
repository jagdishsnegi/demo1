/**************************************************************************************
* Trigger Name        : OpportunityTeamMember Trigger 
* Version             : 1.0 
* Created Date        : 12 Aug 2015
* Function            : It call the function from OpportunityTeamMember_Trigger_Utility. 
* Modification Log    :

* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Ankit                     12 Aug 2015            Original Version
*************************************************************************************/


trigger OpportunityTeamMember on OpportunityTeamMember (before Insert,before update,after insert,before delete,after delete) {
    if(Trigger.isInsert){
         if(Trigger.isBefore){
               OpportunityTeamMember_Trigger_Utility.fPartnerRoleDuplicateCheck(Null,Trigger.new);
         }
         else{
         
         }
     }
   else if (Trigger.isUpdate){
         if(Trigger.isBefore){
              OpportunityTeamMember_Trigger_Utility.fPartnerRoleDuplicateCheck(Trigger.oldMap,Trigger.new);
            }
         else {
              
            } 
      }
   else if(Trigger.isDelete){
       system.debug('------isDelete--------');
       if(Trigger.isBefore){
           // Calling function and changed parameter sequence as Trigger.new do apply for delete.
             OpportunityTeamMember_Trigger_Utility.fCheckUIDelete(null,Trigger.Old);
        } 
       else{
       
       }
    }  

}
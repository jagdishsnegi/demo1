trigger afterContactUpdate on Contact (after update)
{
 
//START - BIRLASOFT - Paritosh - July-30-2012
//Added this condition below to check if the context is of Lead Conversion then this trigger will not execute anyfurther.
 if(util.isInContextOfLeadConversion()){
 return;
 }
//END - BIRLASOFT - Paritosh
 
 if(util.isSkipTrigger())
    {
            return;
    }
    if(UserInfo.getUserId()=='00580000003XtZw' || UserInfo.getUserId()=='00580000003Xtm2' ||UserInfo.getUserId()=='00580000003XrG4')
    {
        return;
    }
    ContactManagement.afterContactUpdate (Trigger.new, Trigger.old);
    
    //Redpoint - Andrew Sync with Spectrum callout and validation
    //ContactUtilities.qualifySpectrumRecordsAfterUpdate(Trigger.newMap, Trigger.oldMap);
    
}
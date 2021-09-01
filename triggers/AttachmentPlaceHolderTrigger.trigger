trigger AttachmentPlaceHolderTrigger on Attachment_PlaceHolder__c ( after insert ) {
        
        if(Util.isSkipTrigger('Attachment PlaceHolder', null) || util.gethealthyTestSwitch()) return;

        Diagnostics.push('Attachment PlaceHolder trigger fired');
    
        TriggerDispatcher.execute(Attachment_PlaceHolder__c.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    
        Diagnostics.pop();
}
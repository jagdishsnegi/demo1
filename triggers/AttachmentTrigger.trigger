/**
 * Created by Ankit on 9/11/17.
 */

trigger AttachmentTrigger on Attachment (before delete, before insert, before update,after insert) {
     if(Util.isSkipTrigger('Attachment', null) || util.gethealthyTestSwitch()) return;
        TriggerDispatcher.execute(Attachment.sObjectType, Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);

}
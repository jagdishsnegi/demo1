/********************************************************************************************
Name   : beforeInsertUpdateDeleteNote
Author : Jitendra Kothari
Date   : July 08, 2011
Usage  : Trigger on Note Object to disallowing insert/update/delete on approved design.
Case   : 00068744
********************************************************************************************/
trigger beforeInsertUpdateDeleteNote on Note (before delete, before insert, before update) {
    if(Trigger.isInsert || Trigger.isUpdate){       
        AttachmentNotesManagement.checkDesignNote(trigger.new);
    }
    else if(Trigger.isDelete){      
        AttachmentNotesManagement.checkDesignNote(trigger.old);
    }
}
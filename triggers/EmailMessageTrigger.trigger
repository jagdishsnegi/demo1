trigger EmailMessageTrigger on EmailMessage (after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete) {
            CaseEmailRollup.rollup(Trigger.New, Trigger.OldMap);
        }
    }
}
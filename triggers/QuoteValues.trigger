trigger QuoteValues on QuoteLineItem (After insert,After Update,After delete) {
    if(Trigger.isInsert || Trigger.isUpdate){
    QuoteFieldvalues.afterInsertUpdate(Trigger.new);
    }
    else if(Trigger.isDelete){
    QuoteFieldvalues.afterInsertUpdate(Trigger.old);
    }

}
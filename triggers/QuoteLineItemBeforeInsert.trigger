trigger QuoteLineItemBeforeInsert on QuoteLineItem (before insert) {
    QuoteManagement.beforeQuoteLineItesInsertMethod(Trigger.new);
}
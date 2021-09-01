trigger QuoteLineItemBeforeInsertUpdate on QuoteLineItem (before insert, before update) {
    QuoteFieldvalues.beforeInsertUpdate(Trigger.New);
}
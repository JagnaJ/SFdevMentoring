trigger CaseTrigger on Case (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        CaseHandler.handleCaseCreation(Trigger.new);
    }
}
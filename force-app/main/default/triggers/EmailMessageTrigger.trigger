trigger EmailMessageTrigger on EmailMessage (after insert) {
    EmailMessageHandler.processNewEmailMessages(Trigger.new);
}

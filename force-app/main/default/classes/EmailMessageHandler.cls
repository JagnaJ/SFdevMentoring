public with sharing class EmailMessageHandler {
    public static void processNewEmailMessages(List<EmailMessage> newEmailMessages) {
        linkCaseAttachmentsToCarService(newEmailMessages);

        Set<Id> carServiceIds = new Set<Id>();
        for (EmailMessage email : newEmailMessages) {
            if (email.ParentId != null) {
                Car_Service__c carService = [
                    SELECT Id FROM Car_Service__c WHERE Case__c = :email.ParentId LIMIT 1
                ];
                if (carService != null) {
                    carServiceIds.add(carService.Id);
                }
            }
        }

        List<ContentDocumentLink> newLinks = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :carServiceIds
        ];

        CarServiceHandler.sendAttachmentNotification(newLinks);
    }
    
    private static void linkCaseAttachmentsToCarService(List<EmailMessage> newEmailMessages) {
        if (newEmailMessages.isEmpty()) return;

        Map<Id, Id> emailToCaseMap = new Map<Id, Id>();
        Set<Id> emailMessageIds = new Set<Id>();

        for (EmailMessage email : newEmailMessages) {
            if (email.ParentId != null) {
                emailToCaseMap.put(email.Id, email.ParentId);
                emailMessageIds.add(email.Id);
            }
        }

        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();

        for (Id emailMessageId : emailMessageIds) {
            List<ContentDocumentLink> attachments = [
                SELECT ContentDocumentId, LinkedEntityId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :emailMessageId
            ];

            for (ContentDocumentLink link : attachments) {
                Id caseId = emailToCaseMap.get(link.LinkedEntityId);
                Id carServiceId = [
                    SELECT Id FROM Car_Service__c WHERE Case__c = :caseId LIMIT 1
                ].Id;
                if (carServiceId != null) {
                    ContentDocumentLink newLink = new ContentDocumentLink();
                    newLink.ContentDocumentId = link.ContentDocumentId;
                    newLink.LinkedEntityId = carServiceId;
                    newLinks.add(newLink);
                }
            }
        }

        if (!newLinks.isEmpty()) {
            insert newLinks;
        }
    }
}

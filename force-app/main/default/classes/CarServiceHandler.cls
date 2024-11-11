public with sharing class CarServiceHandler {
    public static void sendAttachmentNotification(List<ContentDocumentLink> newLinks) {
        Set<Id> carServiceIds = new Set<Id>();

        for (ContentDocumentLink link : newLinks) {
            if (link.LinkedEntityId.getSObjectType() == Car_Service__c.SObjectType) {
                carServiceIds.add(link.LinkedEntityId);
                System.debug('Found Car Service record with ID: ' + link.LinkedEntityId);
            }
        }

        if (!carServiceIds.isEmpty()) {
            List<Car_Service__c> carServices = [
                SELECT Id, Case__c, Case__r.Owner.Email 
                FROM Car_Service__c 
                WHERE Id IN :carServiceIds
            ];

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for (Car_Service__c carService : carServices) {
                if (carService.Case__r.Owner.Email != null) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setToAddresses(new List<String>{carService.Case__r.Owner.Email});
                    email.setSubject('New Attachment Added to Car Service');
                    email.setPlainTextBody('A new attachment has been added to the Car Service record linked to Case ' + carService.Case__c + '.');
                    emails.add(email);
                    System.debug('Email prepared for Case Owner: ' + carService.Case__r.Owner.Email);
                }
            }

            try {
                if (!emails.isEmpty()) {
                    Messaging.sendEmail(emails);
                    System.debug('Emails sent successfully');
                }
            } catch (Exception e) {
                System.debug('Error sending email notifications: ' + e.getMessage());
            }
        }
    }
}
public with sharing class EmailToCaseHandler implements Messaging.InboundEmailHandler {
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String carBrand = extractCarBrand(email.subject);
        String carVinCode = extractCarVinCode(email.subject);

        if (String.isEmpty(carBrand) || String.isEmpty(carVinCode)) {
            result.success = false;
            result.message = 'Missing required fields: CarBrand and/or Car VIN Code.';
            return result;
        }

        Case newCase = new Case();
        newCase.Subject = email.subject;
        newCase.Description = email.plainTextBody;
        newCase.Status = 'New';
        newCase.Origin = 'Email';
        newCase.CarBrand__c = carBrand;
        newCase.Car_VIN_Code__c = carVinCode; 

        try {
            insert newCase;
            result.success = true;

            if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                for (Messaging.InboundEmail.BinaryAttachment attachment : email.binaryAttachments) {
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.Title = attachment.fileName;
                    contentVersion.PathOnClient = attachment.fileName;
                    contentVersion.VersionData = attachment.body;
                    contentVersion.FirstPublishLocationId = newCase.Id;
                    contentVersions.add(contentVersion);
                }
                insert contentVersions;
            }

        } catch (DmlException e) {
            result.success = false;
            result.message = 'Error inserting case or attachments: ' + e.getMessage();
        }
        
        return result;
    }

    private String extractCarBrand(String subject) {
        if (subject.contains('Brand:')) {
            try {
                String[] parts = subject.split('Brand:');
                if (parts.size() > 1) {
                    return parts[1].trim().split(' ')[0];
                }
            } catch (Exception e) {
                System.debug('Error parsing Car Brand: ' + e.getMessage());
            }
        }
        return null;
    }

    private String extractCarVinCode(String subject) {
        if (subject.contains('VIN:')) {
            try {
                String[] parts = subject.split('VIN:');
                if (parts.size() > 1) {
                    return parts[1].trim().split(' ')[0];
                }
            } catch (Exception e) {
                System.debug('Error parsing VIN Code: ' + e.getMessage());
            }
        }
        return null;
    }
}
public with sharing class SalesNotificationQueueable implements Queueable, Database.AllowsCallouts {
    private List<Planned_Sales__c> underperformingRecords;

    public SalesNotificationQueueable(List<Planned_Sales__c> records) {
        this.underperformingRecords = records;
    }

    public void execute(QueueableContext context) {
        List<String> adminEmails = new List<String>{'janaponomarenk@gmail.com'}; 
        
        if (!underperformingRecords.isEmpty()) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(adminEmails);
            email.setSubject('Underperforming Planes Sales Records');
            
            String emailBody = 'The following Planes Sales records did not meet the sales targets:\n\n';
            for (Planned_Sales__c record : underperformingRecords) {
                emailBody += 'Record ID: ' + record.Id + ', Planned: ' + record.Planned_Total_Amount__c + ', Earned: ' + record.Total_Amount_Earned__c + '\n';
            }
            email.setPlainTextBody(emailBody);

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
}
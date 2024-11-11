public class PlannedSalesAsyncUpdater implements Queueable {
    private List<Id> plannedSalesIds;

    public PlannedSalesAsyncUpdater(List<Planned_Sales__c> plannedSales) {
        this.plannedSalesIds = new List<Id>();
        for (Planned_Sales__c ps : plannedSales) {
            this.plannedSalesIds.add(ps.Id);
        }
    }

    public void execute(QueueableContext context) {
        List<Planned_Sales__c> plannedSalesToProcess = [SELECT Id, Name, Total_Amount_Earned__c, Planned_Total_Amount__c, Year__c, Month__c, Car_Type__c
                                                        FROM Planned_Sales__c
                                                        WHERE Id IN :plannedSalesIds];
        
        PlannedSalesHandler.handleAfterInsertOrUpdate(plannedSalesToProcess);
    }
}

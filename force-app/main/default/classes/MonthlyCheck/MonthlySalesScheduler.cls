public with sharing class MonthlySalesScheduler implements Schedulable {

    public void execute(SchedulableContext context) {
        Database.executeBatch(new MonthlySalesBatchJob());
    }

    public static void scheduleMonthlyJob() {
        String cronExpression = '0 0 0 1 * ? *'; 
        System.schedule('Monthly Sales Check Job', cronExpression, new MonthlySalesScheduler());
    }
}
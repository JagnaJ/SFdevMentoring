@isTest
private class MonthlySalesSchedulerTest {
    @isTest static void testScheduler() {
        Test.startTest();
        System.schedule('Monthly Sales Check', '0 0 0 1 * ?', new MonthlySalesScheduler());
        Test.stopTest();
    }
}
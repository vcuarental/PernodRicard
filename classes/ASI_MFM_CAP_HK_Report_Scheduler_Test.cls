@IsTest(SeeAllData=false)
public class ASI_MFM_CAP_HK_Report_Scheduler_Test {
    @isTest static void testReportScheduler() {
        Test.startTest();
        ASI_MFM_CAP_HK_Report_Scheduler sch2 = new ASI_MFM_CAP_HK_Report_Scheduler(); //Schedule apex class name
        String sch = '0 5 9-16 L * ? *'; //schedule interval time
        system.schedule('HK BOI Month End Report TestClass', sch, sch2); //system method to schedule apex class
        Test.stopTest();    
    }
}
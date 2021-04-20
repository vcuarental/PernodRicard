/***********************************************************************************
 * Name: EUR_CRM_MassDeactivateOPSchTest
 * Description: Test Class for EUR_CRM_MassDeactivateOPSch 
 *
 * Version History
 * Date         Developer   			Comments
 * ----------   -------------------  	--------------------------------------------    
 *  5-7-2017  	[Laputa] Kevin Choi  	Created. 
***********************************************************************************/ 

@isTest
public class EUR_CRM_MassDeactivateOPSchTest {
    
    static testMethod void testBatchScheduler(){
        
        Test.StartTest();
        EUR_CRM_MassDeactivateOPSch sh1 = new EUR_CRM_MassDeactivateOPSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        Test.stopTest();
        
    }
}
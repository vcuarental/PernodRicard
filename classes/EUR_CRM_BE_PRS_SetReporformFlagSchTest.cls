/***********************************************************************************
 * Name: EUR_CRM_BE_PRS_SetReporformFlagSchTest
 * Description: Test Class for EUR_CRM_BE_PRS_SetReporformFlagSch 
 *
 * Version History
 * Date         Developer   			Comments
 * ----------   -------------------  	--------------------------------------------    
 *  5-7-2017  	[Laputa] Kevin Choi  	Created. 
***********************************************************************************/

@isTest
public class EUR_CRM_BE_PRS_SetReporformFlagSchTest {
    
    static testMethod void testBatchScheduler(){
        
        Test.StartTest();
        EUR_CRM_BE_PRS_SetReporformFlagSch sh1 = new EUR_CRM_BE_PRS_SetReporformFlagSch();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        
        EUR_CRM_BE_PRS_SetReporformFlagSch.schedule();
        Test.stopTest();
        
    }
}
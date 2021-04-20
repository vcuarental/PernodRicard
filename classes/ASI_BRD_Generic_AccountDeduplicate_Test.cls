/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountDeduplicate_Test
 * Description: Test Class for ASI_BRD_Generic_AccountDeduplicate
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/23/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_AccountDeduplicate_Test{
    static testMethod void ASI_BRD_Generic_AccountDeduplicate_Test1(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        
        Test.startTest();
        Account acc = ASI_BRD_Generic_TestClassHelper.createAcc('test1@test.com','test2@test.com','123','234');
        Account acc2 = ASI_BRD_Generic_TestClassHelper.createAcc('test3@test.com','test4@test.com','1234','2345');
        try{
            Account acc3 = ASI_BRD_Generic_TestClassHelper.createAcc('test1@test.com','test@test.com','123','234');
        }catch(Exception e){
            Account acc4 = ASI_BRD_Generic_TestClassHelper.newAcc('test1@test.com','test@test.com','123','234');
            acc4.ASI_BRD_Ignore_Matching_Records__pc = true;
            insert acc4;
        }
        
        try{
            acc2.PersonEmail = 'test1@test.com';
            acc2.ASI_LUX_Email_Business__c = 'test2@test.com';
            acc2.Phone = '123';
            acc2.PersonMobilePhone = '234';
            update acc2;
        }catch(Exception e){
            acc2.ASI_BRD_Ignore_Matching_Records__pc = true;
            update acc2;   
        }
        Test.stopTest();
    }
    
    //Test for ASI_BRD_Generic_AccountUncheckIgnore
    static testMethod void ASI_BRD_Generic_AccountDeduplicate_Test2(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        
        Test.startTest();
        Account acc = ASI_BRD_Generic_TestClassHelper.createAcc('test1@test.com','test2@test.com','123','234');
        Account acc2 = ASI_BRD_Generic_TestClassHelper.createAcc('test3@test.com','test4@test.com','1234','2345');
        
        Account acc3 = ASI_BRD_Generic_TestClassHelper.newAcc('test1@test.com','test@test.com','123','234');
        acc3.ASI_BRD_Ignore_Matching_Records__pc = true;
        insert acc3;
        
        acc2.PersonEmail = 'test1@test.com';
        acc2.ASI_LUX_Email_Business__c = 'test2@test.com';
        acc2.Phone = '123';
        acc2.PersonMobilePhone = '234';
        try{
            update acc2;
        }catch(Exception e){
        
        }
        acc2.ASI_BRD_Ignore_Matching_Records__pc = true;
        update acc2;   
        Test.stopTest();
    }
}
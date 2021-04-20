/*********************************************************************************
 * Name:ASI_BRD_Generic_AccCreateController_Test
 * Description: Test Class for ASI_BRD_Generic_AccountCreateController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 10/23/2015       Laputa: Hank            Created
*********************************************************************************/
@isTest
private class ASI_BRD_Generic_AccCreateController_Test{
    //With primary market
    static testMethod void ASI_BRD_Generic_AccCreateController_Test1(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        User testUser = ASI_BRD_Generic_TestClassHelper.createUser('Taiwan');
        
        Test.startTest();
        System.runAs(testUser){
            Account acc = ASI_BRD_Generic_TestClassHelper.createAcc();
            PageReference pageRef = Page.ASI_BRD_Generic_AccountCreatePage;
            pageRef.getParameters().put('Id', acc.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            ASI_BRD_Generic_AccountCreateController controller = new ASI_BRD_Generic_AccountCreateController(sc);
            controller.redirect();
        }
        Test.stopTest();
    }
    
    //Without primary market
    static testMethod void ASI_BRD_Generic_AccCreateController_Test2(){
        ASI_BRD_Generic_TestClassHelper.createCrmMapping();
        ASI_BRD_Generic_TestClassHelper.createRunningNo();
        ASI_BRD_Generic_TestClassHelper.createDefValMapping();
        User testUser = ASI_BRD_Generic_TestClassHelper.createUser();
        
        Test.startTest();
        System.runAs(testUser){
            Account acc = ASI_BRD_Generic_TestClassHelper.createAcc();
            PageReference pageRef = Page.ASI_BRD_Generic_AccountCreatePage;
            pageRef.getParameters().put('Id', acc.Id);
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(acc);
            ASI_BRD_Generic_AccountCreateController controller = new ASI_BRD_Generic_AccountCreateController(sc);
            controller.redirect();
        }
        Test.stopTest();
    }
}
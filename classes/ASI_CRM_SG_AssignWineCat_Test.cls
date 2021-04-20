/*********************************************************************************
 * Name: ASI_CRM_SG_AssignWineCat_Test
 * Description: Test Class for ASI_CRM_SG_AssignWineCat_Batch
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 16/05/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_SG_AssignWineCat_Test {
    @TestSetup
    public static void setupData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList);
    }
    
    public static testMethod void testBatch() {
        Database.executeBatch(new ASI_CRM_SG_AssignWineCat_Batch());
    }
}
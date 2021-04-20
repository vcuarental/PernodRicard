/*********************************************************************************
 * Name: ASI_CRM_SG_AutoCreateSKUPrice_Test
 * Description: Test Class for ASI_CRM_SG_AutoCreateSKUPrice
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 13/02/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_SG_AutoCreateSKUPrice_Test {
	
    public static testmethod void testInsertSKUPrice() {
        ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
    }
    
}
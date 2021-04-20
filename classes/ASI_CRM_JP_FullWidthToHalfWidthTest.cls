/**********************************************************************************
 * Name : ASI_CRM_SG_ContractCloneController
 * Created : DC @04/14/2016 1:51 PM
 * Revision History:
 * 1. 04/14/2016 - [DC 1.0] Created
 **********************************************************************************/

@isTest
private class ASI_CRM_JP_FullWidthToHalfWidthTest {
    static testMethod void testConverter() {

        ASI_CRM_JP_FullWidthToHalfWidth converter = ASI_CRM_JP_FullWidthToHalfWidth.GetInstance(); 

        String [] Codes = new String [] { '30EB', 'FF21'}; 
        String str = converter.UnicodeToString(Codes); 

        String restr = converter.replace(str);
    }
}
/*********************************************************************************
 * Name: ASI_CRM_JP_MassUploadItemCtrlTest
 * Description: Test class for ASI_CRM_JP_MassUploadItemController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/07/2017       Hugo Cheung             Created     
 * 14/05/2019       Rutuja Bardapurkar      Modified      
*/
@isTest
public class ASI_CRM_JP_MassUploadItemCtrlTest {
    
    @TestSetup
    public static void setupData() {
   		ASI_CRM_JP_TestHelper.createApprovalRoute();
    }
    
    public static testMethod void testController() {
        Map<String, Object> priceListFieldValueMap = ASI_CRM_JP_TestHelper.PRICE_LIST_DEFAULT_VALUE_MAP;
        priceListFieldValueMap.put('ASI_CRM_JP_Effective_Date__c', Date.today());
        priceListFieldValueMap.put('ASI_CRM_JP_Expiry_Date__c', Date.today());
        
        ASI_CRM_Price_List__c priceList = ASI_CRM_JP_TestHelper.createPriceList(priceListFieldValueMap);
       
        insert priceList;
        
         priceList.ASI_CRM_Price_Type__c = '';
        update priceList;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(priceList);
        ASI_CRM_JP_MassUploadItemController massUploadItemController = new ASI_CRM_JP_MassUploadItemController(sc);
        massUploadItemController.hasCustomer = true;
        massUploadItemController.isDirectSalesPrice = true;
        massUploadItemController.isDCPrice = true;
         massUploadItemController.isWholesalerPrice = true;
    }
    
}
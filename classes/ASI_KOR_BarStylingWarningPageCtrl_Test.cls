/***************************************************************************************************************************
* Name:        ASI_KOR_BarStylingWarningPageController
* Description: Controller for ASI_KOR_BarStylingWarningPage
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-06-17       Wilson Chow                Created
****************************************************************************************************************************/

@isTest
public class ASI_KOR_BarStylingWarningPageCtrl_Test {

    @isTest
    static void testASI_KOR_BarStylingWarningPage() {

        map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c');
        rt_map = ASI_MFM_Function.getRecordTypeId('Account');
        Account supplierAccount = new Account(
                recordTypeId = rt_map.get('ASI_KOR_Venue'),
                Name = 'Name1'
        );
        insert supplierAccount;
        String supplierAccountId = supplierAccount.Id;

        ASI_KOR_Brand__c brand = new ASI_KOR_Brand__c(
                Name = 'brand_name'
        );
        insert brand;

        ASI_KOR_Sub_Brand__c subBrand = new ASI_KOR_Sub_Brand__c(
                Name = 'TestSubBrand',
                ASI_KOR_Brand__c = brand.Id,
                ASI_KOR_Sub_Brand_Code__c = 'sub_brand_code'
        );
        insert subBrand;

        ASI_KOR_POSM_Order_Request__c posmHeader = new ASI_KOR_POSM_Order_Request__c(
                recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_Bar_Styling_POSM_Request'),
                ASI_KOR_POSM_TO_Venue__c = supplierAccountId,
                ASI_KOR_Status__c = 'Draft',
                ASI_KOR_Fiscal_Year__c = 'FY0001',
                ASI_KOR_Sub_Brand__c = subBrand.Id
        );
        insert posmHeader;

        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(posmHeader);

        PageReference warningPage = Page.ASI_KOR_BarStylingWarningPage;
        Test.setCurrentPage(warningPage);
        ApexPages.currentPage().getParameters().put('id', posmHeader.Id);

        Test.setCurrentPageReference(warningPage);

        Test.startTest();
        try {
            ASI_KOR_BarStylingWarningPageController barStylingWarningPageCtrl =
                    new ASI_KOR_BarStylingWarningPageController(sc);
            barStylingWarningPageCtrl.init();
        }
        catch(Exception e) {

        }
        Test.stopTest();
    }
}
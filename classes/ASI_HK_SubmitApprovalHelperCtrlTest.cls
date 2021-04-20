@isTest
public class ASI_HK_SubmitApprovalHelperCtrlTest
{
    static testMethod void testSalesOrderRecall()
    {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        
        Test.startTest();
        PageReference testPage = Page.ASI_HK_SubmitApprovalHelperPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id',so.Id);
        Test.setCurrentPageReference(testPage);
        ASI_HK_SubmitApprovalHelperController controller = new ASI_HK_SubmitApprovalHelperController();
        controller.submitHelper();
        
        so.ASI_CRM_HK_has_rejected__c=true;
        update so;
        controller.submitHelper();
        
        so.ASI_CRM_HK_has_rejected__c=false;
        update so;
        controller.submitHelper();
        
        Test.stopTest();
    }//end method
    
    static testMethod void testSOMT()
    {
        Test.startTest();
        ASI_HK_CRM_SalesOrderManagerTypes.Pricing temp1 = new ASI_HK_CRM_SalesOrderManagerTypes.Pricing();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetail temp2 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetail();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailFinancial temp3 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailFinancial();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailBilling temp4 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailBilling();
        ASI_HK_CRM_SalesOrderManagerTypes.E1Message temp5 = new ASI_HK_CRM_SalesOrderManagerTypes.E1Message();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOCustomer temp6 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOCustomer();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetail temp7 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetail();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOOriginalOrder temp8 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOOriginalOrder();
        ASI_HK_CRM_SalesOrderManagerTypes.E1MessageList temp9 = new ASI_HK_CRM_SalesOrderManagerTypes.E1MessageList();
        ASI_HK_CRM_SalesOrderManagerTypes.GetSalesHeader temp10 = new ASI_HK_CRM_SalesOrderManagerTypes.GetSalesHeader();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader temp11 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesHeader();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailDates temp12 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailDates();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesOrder temp13 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesOrder();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetail temp14 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetail();
        ASI_HK_CRM_SalesOrderManagerTypes.OriginalOrder temp15 = new ASI_HK_CRM_SalesOrderManagerTypes.OriginalOrder();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeaderFinancial temp56 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeaderFinancial();
        ASI_HK_CRM_SalesOrderManagerTypes.Processing temp16 = new ASI_HK_CRM_SalesOrderManagerTypes.Processing();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLinePricing temp17 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLinePricing();
        ASI_HK_CRM_SalesOrderManagerTypes.CategoryCodesSales temp18 = new ASI_HK_CRM_SalesOrderManagerTypes.CategoryCodesSales();
        ASI_HK_CRM_SalesOrderManagerTypes.DocumentKey temp19 = new ASI_HK_CRM_SalesOrderManagerTypes.DocumentKey();
        ASI_HK_CRM_SalesOrderManagerTypes.RelatedOrderKey temp20 = new ASI_HK_CRM_SalesOrderManagerTypes.RelatedOrderKey();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeader temp21 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeader();
        ASI_HK_CRM_SalesOrderManagerTypes.Entity temp57 = new ASI_HK_CRM_SalesOrderManagerTypes.Entity();
        ASI_HK_CRM_SalesOrderManagerTypes.Financial temp22 = new ASI_HK_CRM_SalesOrderManagerTypes.Financial();
        ASI_HK_CRM_SalesOrderManagerTypes.Dates temp23 = new ASI_HK_CRM_SalesOrderManagerTypes.Dates();
        ASI_HK_CRM_SalesOrderManagerTypes.GetItemListPrice temp24 = new ASI_HK_CRM_SalesOrderManagerTypes.GetItemListPrice();
        ASI_HK_CRM_SalesOrderManagerTypes.CategoryCodesPurchasing temp25 = new ASI_HK_CRM_SalesOrderManagerTypes.CategoryCodesPurchasing();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeaderProcessing temp26 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeaderProcessing();
        ASI_HK_CRM_SalesOrderManagerTypes.SalesOrderKey temp27 = new ASI_HK_CRM_SalesOrderManagerTypes.SalesOrderKey();
        ASI_HK_CRM_SalesOrderManagerTypes.GetSalesOrder temp28 = new ASI_HK_CRM_SalesOrderManagerTypes.GetSalesOrder();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSalesOrder temp29 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSalesOrder();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailOriginalOrder temp30 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailOriginalOrder();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesShipTo temp31 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesShipTo();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailDelivery temp32 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailDelivery();
        ASI_HK_CRM_SalesOrderManagerTypes.GetSalesDetail temp33 = new ASI_HK_CRM_SalesOrderManagerTypes.GetSalesDetail();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeaderBilling temp34 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSOHeaderBilling();
        ASI_HK_CRM_SalesOrderManagerTypes.Segment temp35 = new ASI_HK_CRM_SalesOrderManagerTypes.Segment();
        ASI_HK_CRM_SalesOrderManagerTypes.ItemGroupCustomer temp36 = new ASI_HK_CRM_SalesOrderManagerTypes.ItemGroupCustomer();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailProduct temp37 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSODetailProduct();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSalesOrder temp38 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSalesOrder();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailProcessing temp39 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailProcessing();
        ASI_HK_CRM_SalesOrderManagerTypes.Customer temp40 = new ASI_HK_CRM_SalesOrderManagerTypes.Customer();
        ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData temp41 = new ASI_HK_CRM_SalesOrderManagerTypes.UserReservedData();
        ASI_HK_CRM_SalesOrderManagerTypes.Document temp42 = new ASI_HK_CRM_SalesOrderManagerTypes.Document();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessingVersion temp43 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessingVersion();
        ASI_HK_CRM_SalesOrderManagerTypes.Quantity temp44 = new ASI_HK_CRM_SalesOrderManagerTypes.Quantity();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeader temp45 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeader();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowDetailItem temp46 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowDetailItem();
        ASI_HK_CRM_SalesOrderManagerTypes.GetDetailProduct temp47 = new ASI_HK_CRM_SalesOrderManagerTypes.GetDetailProduct();
        ASI_HK_CRM_SalesOrderManagerTypes.RelatedOrder temp48 = new ASI_HK_CRM_SalesOrderManagerTypes.RelatedOrder();
        ASI_HK_CRM_SalesOrderManagerTypes.Configuration temp49 = new ASI_HK_CRM_SalesOrderManagerTypes.Configuration();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLineBilling temp50 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailLineBilling();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeaderDates temp51 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeaderDates();
        ASI_HK_CRM_SalesOrderManagerTypes.ValueObject temp52 = new ASI_HK_CRM_SalesOrderManagerTypes.ValueObject();
        ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeaderDelivery temp53 = new ASI_HK_CRM_SalesOrderManagerTypes.ConfirmSOHeaderDelivery();
        ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailProduct temp54 = new ASI_HK_CRM_SalesOrderManagerTypes.ShowSalesDetailProduct();
        ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailProduct temp55 = new ASI_HK_CRM_SalesOrderManagerTypes.ProcessSODetailProduct();
        Test.stopTest();
    }//end method
}//end class
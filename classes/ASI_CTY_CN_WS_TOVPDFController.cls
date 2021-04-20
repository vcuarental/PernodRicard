public without sharing class ASI_CTY_CN_WS_TOVPDFController {
    public ASI_CRM_TOV__c currentTov {get;set;}
    public List<ASI_CRM_TOV_Detail__c> tovDetails {get;set;}
    public List<TOVDetailWrapper> tovDetailWrappers {get;set;}
    public Decimal totalCaseQty {get; set;}
    public Decimal totalBottleQty {get; set;}
    public Decimal totalAmount {get; set;}
    
    public void init(){
    		String tovId = ApexPages.currentPage().getParameters().get('tovId');
            currentTov = [select id
                                 , ASI_CRM_Customer_Code__c
                                 , ASI_CTY_CN_WS_Customer_Legal_Name__c
                                 , ASI_CRM_SO_Number__c
                                 , ASI_CRM_Order_Date__c
                                 , ASI_CRM_SF_SO_Request_Number__r.Name
                                 , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Address__c
                                 , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Legal_Name__c
                                 , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CRM_Code__c
                                 , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Tel_Mobile__c
                                 , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_SG_Order_Date__c
                                 , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Other_Requirement__c
                                 , ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Contact_Person__c
                                 , ASI_CRM_Free_Goods_Request__r.Name
                                 , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Receiptor_Name__c
                                 , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Deliver_to_Address_Line_1__c
                                 , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Date_of_Delivery__c
                                 , ASI_CRM_Free_Goods_Request__r.ASI_FOC_Receiptor_Mobile__c
                                 , ASI_CRM_Free_Goods_Request__r.ASI_MFM_DetailAddress__c 
                         from ASI_CRM_TOV__c
                         where Id = : tovId
                         AND (RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCN
                         OR RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCNFINAL)];

            tovDetails = [select id,ASI_CRM_SKU__c
                                , ASI_CRM_Order_QTY__c
                                , ASI_CRM_UOM__c 
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.Name
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_BT_Size_C__c
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_MFM_Item_Group_Code__c
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c
                                , ASI_CRM_SF_FOC_Request_Line_Number__r.ASI_FOC_CN_Packing_Description__c
                                , ASI_CRM_SF_FOC_Request_Line_Number__r.ASI_FOC_SKU_Chinese_Description__c
                                , ASI_CRM_SF_FOC_Request_Line_Number__r.ASI_FOC_SKU__r.Name
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Released_Qty__c
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Unit_Price_BT_with_VAT__c
                                , ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Actual_Unit_Price__c
                                , ASI_CRM_PriceWVAT_BT__c
                                , ASI_CRM_SF_SO_Price_BT_with_VAT__c
                                , ASI_CTY_CN_WS_Order_Qty_BT__c
                                , ASI_CTY_CN_WS_Order_Qty_CA__c
                                , ASI_CRM_Item_Group__c
                                , ASI_CRM_Pack_Description__c
                                , ASI_CRM_SKU_Description__c
                                , ASI_CTY_CN_WS_Amount__c
                                , ASI_CRM_TOV__r.ASI_CRM_Status__c
                        from ASI_CRM_TOV_Detail__c
                        where ASI_CRM_TOV__c = : tovId
                        AND (ASI_CRM_TOV__r.RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCN
                        OR ASI_CRM_TOV__r.RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCNFINAL)];
            tovDetailWrappers = new List<TOVDetailWrapper>();
            totalCaseQty = 0;
            totalBottleQty = 0;
            totalAmount = 0;
            for (ASI_CRM_TOV_Detail__c tovDetail : tovDetails) {
                TOVDetailWrapper tovdWrap = new TOVDetailWrapper();
                tovdWrap.cnName = tovDetail.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c;
                tovdWrap.enName = tovDetail.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c;
                tovdWrap.pack = tovDetail.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c;
                tovdWrap.packValue = tovDetail.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c;
                tovdWrap.unitPrice = tovDetail.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Unit_Price_BT_with_VAT__c;
                tovdWrap.actualPrice = tovDetail.ASI_CRM_PriceWVAT_BT__c;
                tovdWrap.releaseCaseQty = tovDetail.ASI_CTY_CN_WS_Order_Qty_CA__c;
                tovdWrap.releaseBottleQty = tovDetail.ASI_CTY_CN_WS_Order_Qty_BT__c;
                tovdWrap.releaseAmount = tovDetail.ASI_CTY_CN_WS_Amount__c;

                // if (tovDetail.ASI_CRM_TOV__r.ASI_CRM_Status__c == ASI_CTY_CN_WS_Utils.TOV_STATUS_RELEASED_EN) {
                    totalCaseQty += tovdWrap.releaseCaseQty == null ? 0 : tovdWrap.releaseCaseQty;
                    totalBottleQty += tovdWrap.releaseBottleQty == null ? 0 : tovdWrap.releaseBottleQty;
                    totalAmount += tovdWrap.releaseAmount == null ? 0 : tovdWrap.releaseAmount;
                // }
                tovDetailWrappers.add(tovdWrap);
            }
            System.debug(LoggingLevel.INFO, '*** tovDetailWrappers: ' + tovDetailWrappers);
    }

    class TOVDetailWrapper{
        public String cnName {get; set;}
        public String enName {get; set;}
        public String pack {get; set;}
        public Decimal packValue {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal actualPrice {get; set;}
        public Decimal releaseCaseQty {get; set;}
        public Decimal releaseBottleQty {get; set;}
        public Decimal releaseAmount {get; set;}
    }
}
public with sharing class ASI_CTY_CN_WS_PriceDiscountDetailCtrl {
    
    private static final String RTDEVNAME_SKU = 'ASI_CRM_CN_CRM_Item_Group';
    private static final String RTDEVNAME_SB = 'ASI_FOC_CN_Sub_brand';
    private static final String RTDEVNAME_CUST_PD_PRICE = 'ASI_CRM_CN_T1_Price';
    private static final String ERROR_MSG_NOT_OPEN_STATUS = 'You can edit item just open status!';
    private static final String ERROR_MSG_CANNOT_FIND_PROMOTIONMASTER = 'The customer cannot find a matching promotion master';

    public String soHeaderId { get; private set; }
    public String acctDAId { get; private set; }
    public String pageTitle { get; private set; }
    public Boolean useCustPrice { get; private set; }
    public List<List<String>> sbSearchOptionsNormal { get; set; }
    public List<List<String>> sbSearchOptionsPOS { get; set; }
    public Boolean hasError { get; set; }
    public static ASI_CRM_Price_And_Discount__c soHeader;
    static List<ASI_CRM_CN_T1_Price__c> t1Price = new list<ASI_CRM_CN_T1_Price__c>([SELECT id, ASI_CRM_CN_T1_Price__c, ASI_CRM_CN_Item_Group__c FROM ASI_CRM_CN_T1_Price__c WHERE recordType.developerName = : RTDEVNAME_CUST_PD_PRICE AND ASI_CRM_CN_Effective_Date__c <= :date.today() order by ASI_CRM_CN_Effective_Date__c desc]);
    public Decimal taxRate{get;set;} 
    
    public ASI_CTY_CN_WS_PriceDiscountDetailCtrl(ApexPages.StandardSetController stdSetController) {
        hasError = false;
        //check is Order Form Exist
        this.soHeaderId = ApexPages.currentPage().getParameters().get('id');
        soHeader = [
            SELECT Id, ASI_CRM_Customer__c, ASI_CRM_Customer__r.RecordType.Name, ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c,
                   ASI_CRM_IHBR_Price_Type__c, ASI_CRM_Effective_From__c, ASI_CRM_Channel__c,ASI_CRM_Status__c, ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__c,
                   ASI_CRM_RTD__c, RecordType.DeveloperName, ASI_CRM_Customer_Region__c,
                   (SELECT ASI_CRM_New_Price_BT_with_VAT__c, ASI_CRM_Item_Group_Description__c FROM Price_And_Discount_Details__r) 
            FROM ASI_CRM_Price_And_Discount__c
            WHERE Id = : soHeaderId
        ];

        if (soHeader.ASI_CRM_Status__c != 'Open') {
            showPageError(ERROR_MSG_NOT_OPEN_STATUS);
            hasError = true;
            return;
        }
        String customerType = '';
        if (soHeader.ASI_CRM_Customer__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS)) {
            customerType = ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS ;
        } else if (soHeader.ASI_CRM_Customer__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET)) {
            customerType = ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET ;
        }

        List<ASI_CRM_Promotion_Master__c> promotionMasters = [SELECT id, Name ,ASI_CTY_CN_WS_Price_Promotion_Type__c,
                                                             ASI_CTY_CN_WS_Trade_a_p_Promotion_Code__c, 
                                                             ASI_CTY_CN_WS_Normal_Promotion_Code__c,
                                                             ASI_CTY_CN_WS_AD_Promotion_Code__c,
                                                             ASI_CRM_Buy_X__c, ASI_CRM_Get_Y__c 
                                                        FROM ASI_CRM_Promotion_Master__c
                                                       WHERE ASI_CTY_CN_WS_Channel__c = :soHeader.ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__c
                                                         AND ASI_CTY_CN_WS_Commercial_Team__c = :soHeader.ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                         AND ASI_CTY_CN_WS_Region__r.Name = :soHeader.ASI_CRM_Customer_Region__c
                                                         AND ASI_CTY_CN_WS_Customer_Type__c = :customerType];
        ASI_CRM_Promotion_Master__c promotionMaster;
        if (promotionMasters.isEmpty()) {
            showPageError(ERROR_MSG_CANNOT_FIND_PROMOTIONMASTER);
            hasError = true;
            return;
        } 
        this.taxRate = ASI_CTY_CN_WS_Utils.getCNTaxRate();
        Map<id, id> mapOrderForm = new Map<id, id>();
        this.useCustPrice = FALSE;
        this.sbSearchOptionsNormal = getSubBrandSearchOptions();
        this.sbSearchOptionsPOS = sbSearchOptionsNormal;
    }

    @RemoteAction
    public static List<ASI_CTY_CN_WS_SOLineItem> lineItemList(ID headerId) {
        List<ASI_CTY_CN_WS_SOLineItem> result = new List<ASI_CTY_CN_WS_SOLineItem>();
        ASI_CRM_Price_And_Discount__c soHeader = [
            SELECT Id, ASI_CRM_Customer__c, ASI_CRM_Customer__r.RecordType.Name, ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c,
                   ASI_CRM_IHBR_Price_Type__c, ASI_CRM_Effective_From__c, ASI_CRM_Channel__c,ASI_CRM_Effective_To__c,
                   ASI_CRM_RTD__c, RecordType.DeveloperName, ASI_CRM_Customer_Region__c,RecordType.Name,ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__c
            FROM ASI_CRM_Price_And_Discount__c
            WHERE Id = : headerId
        ];

        List<ASI_CRM_Price_And_Discount_Detail__c> lineItems = [
            SELECT Id, Name, ASI_CRM_New_Price_BT_with_VAT__c, ASI_CRM_New_Price_BT_non_VAT__c, ASI_CRM_Current_T1_Price_BT_with_VAT__c, ASI_CRM_Item_Group_Description__c, ASI_CRM_Item_Group_Description__r.Name,RecordType.DeveloperName
                  , ASI_CRM_Item_Group_Description__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_Item_Group_Description__r.ASI_MFM_Sub_brand__c, ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c, ASI_CRM_CN_vs_Current_T1_Non_VAT__c, ASI_CRM_Gross_Sales_Impact__c, 
                   ASI_CRM_Total_Estimated_Vol_BT__c, ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c, ASI_CRM_Promotion_Code__r.Name, ASI_CRM_Promotion_Code__c, ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__r.RecordType.Name,
                   ASI_CTY_CN_WS_Level1_Promotion_Code__c, ASI_CTY_CN_WS_Level1_Promotion_Code__r.Name, ASI_CTY_CN_WS_Level2_Promotion_Code__c, ASI_CTY_CN_WS_Promotion_Type__c,ASI_CTY_CN_WS_Value_Type__c,ASI_CTY_CN_WS_Disount_Value__c
            FROM ASI_CRM_Price_And_Discount_Detail__c
            WHERE ASI_CRM_Price_And_Discount__c = :headerId
        ];
        
        String customerType = '';
        if (soHeader.ASI_CRM_Customer__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS)) {
            customerType = ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS ;
        } else if (soHeader.ASI_CRM_Customer__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET)) {
            customerType = ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET ;
        }

        List<ASI_CRM_Promotion_Master__c> promotionMasters = [SELECT id, Name ,ASI_CTY_CN_WS_Price_Promotion_Type__c,
                                                             ASI_CTY_CN_WS_Trade_a_p_Promotion_Code__c, 
                                                             ASI_CTY_CN_WS_Normal_Promotion_Code__c,
                                                             ASI_CTY_CN_WS_AD_Promotion_Code__c,
                                                             ASI_CRM_Buy_X__c, ASI_CRM_Get_Y__c 
                                                        FROM ASI_CRM_Promotion_Master__c
                                                       WHERE ASI_CTY_CN_WS_Channel__c = :soHeader.ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__c
                                                         AND ASI_CTY_CN_WS_Commercial_Team__c = :soHeader.ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                         AND ASI_CTY_CN_WS_Region__r.Name = :soHeader.ASI_CRM_Customer_Region__c
                                                         AND ASI_CTY_CN_WS_Customer_Type__c = :customerType];
        ASI_CRM_Promotion_Master__c promotionMaster;
        if (promotionMasters.size() > 0) {
            promotionMaster = promotionMasters[0];
            System.debug(LoggingLevel.INFO, '*** promotionMaster: ' + promotionMaster);
        }

        Map<ID ,ASI_CRM_CN_T1_Price__c> mapT1Price = new Map<ID ,ASI_CRM_CN_T1_Price__c>();

        for(ASI_CRM_CN_T1_Price__c obj : t1Price){
            if(!mapT1Price.containsKey(obj.ASI_CRM_CN_Item_Group__c))
                mapT1Price.put(obj.ASI_CRM_CN_Item_Group__c, obj);
        }

        String promtionType = soHeader.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P) ? ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P : soHeader.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL) ? ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL : soHeader.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD) ? ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD : null;
        String valuePickListStr = getPickListStr('ASI_CRM_Price_And_Discount_Detail__c', 'ASI_CTY_CN_WS_Value_Type__c', promtionType == ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD);
        System.debug(LoggingLevel.INFO, '*** valuePickListStr: ' + valuePickListStr);

        for (ASI_CRM_Price_And_Discount_Detail__c li : lineItems) {
            ASI_CTY_CN_WS_SOLineItem tempLi = new ASI_CTY_CN_WS_SOLineItem();
            tempLi.id = li.Id;
            tempLi.skuId = li.ASI_CRM_Item_Group_Description__c != null ? li.ASI_CRM_Item_Group_Description__c : null;
            tempLi.skuLabel = li.ASI_CRM_Item_Group_Description__c != null ? li.ASI_CRM_Item_Group_Description__r.Name : null;
            tempLi.subBrandId = li.ASI_CRM_Item_Group_Description__c != null ? li.ASI_CRM_Item_Group_Description__r.ASI_MFM_Sub_brand__c : null;
            tempLi.subBrandLabel = tempLi.subBrandId != null ? li.ASI_CRM_Item_Group_Description__r.ASI_MFM_Sub_brand__r.Name : null;
            tempLi.promotionType = li.ASI_CTY_CN_WS_Promotion_Type__c;
            tempLi.level1PromotionCode = li.ASI_CTY_CN_WS_Level1_Promotion_Code__c != null ? li.ASI_CTY_CN_WS_Level1_Promotion_Code__r.Name : null ;
            tempLi.level1PromotionCodeId = li.ASI_CTY_CN_WS_Level1_Promotion_Code__c != null ? li.ASI_CTY_CN_WS_Level1_Promotion_Code__c : null ;
            tempLi.level2PromotionCode = li.ASI_CTY_CN_WS_Level2_Promotion_Code__c;
            tempLi.discountValue = li.ASI_CTY_CN_WS_Disount_Value__c;
            tempLi.valueType = li.ASI_CTY_CN_WS_Value_Type__c;
            tempLi.valueTypePickList = valuePickListStr;
            if (tempLi.level1PromotionCode == null && promotionMaster != null) {
                tempLi.level1PromotionCode = promotionMaster.Name;
                tempLi.level1PromotionCodeId = promotionMaster.Id;
                if (tempLi.promotionType == ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P) {
                    tempLi.level2PromotionCode = promotionMaster.ASI_CTY_CN_WS_Trade_a_p_Promotion_Code__c;
                } else if (tempLi.promotionType == ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL) {
                    tempLi.level2PromotionCode = promotionMaster.ASI_CTY_CN_WS_Normal_Promotion_Code__c;
                } else if (tempLi.promotionType == ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD) {
                    tempLi.level2PromotionCode = promotionMaster.ASI_CTY_CN_WS_AD_Promotion_Code__c;
                }
            }

            //Decimal newPriceBTNonVAT = tempLi.newPriceBTNonVAT != null ? tempLi.newPriceBTNonVAT : 0;

            result.add(tempLi);
        }

        return result;
    }
    
    @RemoteAction
    public static List<ASI_CTY_CN_WS_NormalProduct> normalProductList(ID headerId, String custId, Boolean onlyCustPrice) {
        
        Map<id, id> mapOrderForm = new Map<id, id>();
        
        
        soHeader = [
            SELECT Id,  ASI_CRM_Item_Master_Reference_Number__r.ASI_CN_NPL_Item_Goup_Code__c, ASI_CRM_Customer__c, 
                ASI_CRM_IHBR_Price_Type__c, ASI_CRM_Effective_From__c, ASI_CRM_Effective_To__c, ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__c,
                ASI_CRM_RTD__c, RecordType.DeveloperName, ASI_CRM_Channel__c, ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c,
                ASI_CRM_Customer_Region__c,ASI_CRM_Customer__r.RecordType.Name,RecordType.Name,
                (SELECT ASI_CRM_New_Price_BT_with_VAT__c, ASI_CRM_Item_Group_Description__c 
            FROM Price_And_Discount_Details__r) FROM ASI_CRM_Price_And_Discount__c
            WHERE Id = : headerId];
        
        List<ASI_CRM_Price_And_Discount__c> soHeaderList = new List<ASI_CRM_Price_And_Discount__c>();
        soHeaderList.add(soHeader);

                List<ASI_CRM_Order_Form_Customer_Relationship__c> ofcrList;
        
        if(soHeader.ASI_CRM_RTD__c == TRUE){
            
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='RTD' AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_Customer__c]);
        }else{
            
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='Normal Item' AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_Customer__c]);
        }
        
        for(ASI_CRM_Order_Form_Customer_Relationship__c obj : ofcrList){
            mapOrderForm.put(obj.ASI_CRM_Customer__c, obj.ASI_CRM_Order_Form__c);
        }
        
        system.debug('check007 ' + mapOrderForm.get(soHeader.ASI_CRM_Customer__c));

        Id orderFormId = mapOrderForm.get(soHeader.ASI_CRM_Customer__c);
        
        List<ASI_CRM_Order_Form_Detail__c> ofList = new List<ASI_CRM_Order_Form_Detail__c>([SELECT id, ASI_CRM_Order_Form__r.ASI_CRM_T1_Master__c, ASI_CRM_Product_Name__c, ASI_CRM_Remark__c FROM ASI_CRM_Order_Form_Detail__c WHERE ASI_CRM_Order_Form__c =: orderFormId]);
        Set<ID> itemGroupID = new Set<id>();
        for(ASI_CRM_Order_Form_Detail__c obj : ofList){
            itemGroupID.add(obj.ASI_CRM_Product_Name__c);
        }
        
        Date todayDate = Date.today();
        List<ASI_CTY_CN_WS_NormalProduct> result = new List<ASI_CTY_CN_WS_NormalProduct>();
        List<ASI_MFM_Item_Group__c> skuList = new List<ASI_MFM_Item_Group__c>();
        
        List<ASI_MFM_SKU_Code__c> tmpSKU = new List<ASI_MFM_SKU_Code__c>([SELECT ASI_MFM_Item_Group__c FROM ASI_MFM_SKU_Code__c
                                                                          WHERE ASI_MFM_Item_Group__r.RecordType.DeveloperName = :RTDEVNAME_SKU 
                                                                          AND ASI_MFM_Item_Group__r.ASI_CRM_CN_Not_In_Use__c = False
                                                                          AND ASI_MFM_Item_Group__r.ASI_CRM_Competitor__c = 'No' 
                                                                          AND ASI_MFM_Item_Group__r.ASI_CRM_CN_Gift_Set_C__c = FALSE
                                                                          AND ASI_MFM_Item_Group__r.ASI_CRM_CN_EMPTY_BOX_C__c = FALSE
                                                                          AND (ASI_CRM_SKU_Status__c LIKE '%000%' OR ASI_CRM_SKU_Status__c LIKE '%001%' OR ASI_CRM_SKU_Status__c LIKE '%997%')
                                                                         ]);
        Set<Id> tmpIGId = new Set<Id>();
        
        if(tmpSKU.size() > 0){
            for(ASI_MFM_SKU_Code__c obj : tmpSKU){
                tmpIGId.add(obj.ASI_MFM_Item_Group__c);
            }
        }
        
        skuList = [
            SELECT Id, Name, ASI_CRM_CN_pack__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name
            , ASI_CRM_CN_BT_Size_C__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name, ASI_CRM_CN_Converion9L_C__c
            //, (SELECT id, ASI_CRM_CN_T1_Price__c FROM T1_Price__r WHERE ASI_CRM_CN_Effective_Date__c >=: todayDate)
            FROM ASI_MFM_Item_Group__c
            WHERE Id IN : tmpIGId
        ];
                
        String customerType = '';
        if (soHeader.ASI_CRM_Customer__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS)) {
            customerType = ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_WS ;
        } else if (soHeader.ASI_CRM_Customer__r.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET)) {
            customerType = ASI_CTY_CN_WS_Utils.PM_CUSTOMER_TYPE_OUTLET ;
        }

        List<ASI_CRM_Promotion_Master__c> promotionMasters = [SELECT id, Name ,ASI_CTY_CN_WS_Price_Promotion_Type__c,
                                                                     ASI_CTY_CN_WS_Trade_a_p_Promotion_Code__c, 
                                                                     ASI_CTY_CN_WS_Normal_Promotion_Code__c,
                                                                     ASI_CTY_CN_WS_AD_Promotion_Code__c,
                                                                     ASI_CRM_Buy_X__c, ASI_CRM_Get_Y__c 
                                                                FROM ASI_CRM_Promotion_Master__c
                                                               WHERE ASI_CTY_CN_WS_Channel__c = :soHeader.ASI_CRM_Customer__r.ASI_CRM_CN_NewChannel__c
                                                                 AND ASI_CTY_CN_WS_Commercial_Team__c = :soHeader.ASI_CRM_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                                 AND ASI_CTY_CN_WS_Region__r.Name = :soHeader.ASI_CRM_Customer_Region__c
                                                                 AND ASI_CTY_CN_WS_Customer_Type__c = :customerType];
        ASI_CRM_Promotion_Master__c promotionMaster;
        if (promotionMasters.size() > 0) {
            promotionMaster = promotionMasters[0];
            System.debug(LoggingLevel.INFO, '*** promotionMaster: ' + promotionMaster);
        }
        String promtionType = soHeader.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P) ? ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P : soHeader.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL) ? ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL : soHeader.RecordType.Name.contains(ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD) ? ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD : null;
        String valuePickListStr = getPickListStr('ASI_CRM_Price_And_Discount_Detail__c', 'ASI_CTY_CN_WS_Value_Type__c', promtionType == ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD);

        for (ASI_MFM_Item_Group__c sku : skuList) {
                ASI_CTY_CN_WS_NormalProduct pd = new ASI_CTY_CN_WS_NormalProduct();
                pd.id = sku.Id;
                pd.qty9Lfactor = sku.ASI_CRM_CN_Converion9L_C__c;
                pd.code = null;
                pd.name = sku.Name;
                pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
                pd.subBrandLabel = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
                pd.inventory = null;
                String Name = '';
                if(sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name != Null && sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name != ''){
                    if(sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name.contains('\'')){
                        String[] splittedName = sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name.split('\'');
                        for(integer i = 0 ; i < splittedName.size() ; i ++){
                            Name += splittedName[i];
                        }
                    }else{
                        Name = sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name;
                    }
                }
            
                pd.brandType = Name;//sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name;
                pd.packaging = sku.ASI_CRM_CN_pack__c;
                pd.stdNum = null;
                pd.dummy = null;
                pd.promotionType = promtionType;
                pd.level1PromotionCode = promotionMaster != null ? promotionMaster.Name : null;
                pd.level1PromotionCodeId = promotionMaster != null ? promotionMaster.Id : null ;
                if (pd.promotionType == ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_TRADE_A_P && promotionMaster != null) {
                    pd.level2PromotionCode = promotionMaster.ASI_CTY_CN_WS_Trade_a_p_Promotion_Code__c;
                } else if (pd.promotionType == ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_NORMAL && promotionMaster != null) {
                    pd.level2PromotionCode = promotionMaster.ASI_CTY_CN_WS_Normal_Promotion_Code__c;
                } else if (pd.promotionType == ASI_CTY_CN_WS_Utils.PD_RECORDTYPE_AD && promotionMaster != null) {
                    pd.level2PromotionCode = promotionMaster.ASI_CTY_CN_WS_AD_Promotion_Code__c;
                }
                pd.discountValue = null;
                pd.valueType = '';
                pd.valueTypePickList = valuePickListStr;
                result.add(pd);
        }
        return result;
    }
    
    
    @RemoteAction
    public static ASI_CTY_CN_WS_SaveResult saveChanges(String headerId, List<ASI_CTY_CN_WS_SOLineItem> remoteLineItems) {
        System.debug(LoggingLevel.INFO, '*** remoteLineItems: ' + remoteLineItems);
        ASI_CTY_CN_WS_SaveResult result = new ASI_CTY_CN_WS_SaveResult();
        result.success = false;
        try {
            if (String.isNotBlank(headerId)) {
                Map<ID, ASI_CRM_Price_And_Discount_Detail__c> existingLineItemMap = new Map<ID, ASI_CRM_Price_And_Discount_Detail__c>(
                (List<ASI_CRM_Price_And_Discount_Detail__c>)[
                    SELECT Id, LastModifiedDate
                    FROM ASI_CRM_Price_And_Discount_Detail__c
                    WHERE ASI_CRM_Price_And_Discount__c = :headerId
                    FOR UPDATE
                ]);
                
                Set<ID> newIdSet = new Set<ID>();
                List<ASI_CRM_Price_And_Discount_Detail__c> insertLineItems = new List<ASI_CRM_Price_And_Discount_Detail__c>();
                List<ASI_CRM_Price_And_Discount_Detail__c> updateLineItems = new List<ASI_CRM_Price_And_Discount_Detail__c>();
                List<ASI_CRM_Price_And_Discount_Detail__c> deleteLineItems = new List<ASI_CRM_Price_And_Discount_Detail__c>();
                if (remoteLineItems != null) {
                    for (ASI_CTY_CN_WS_SOLineItem remoteLineItem : remoteLineItems) {
                        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') {
                            ASI_CRM_Price_And_Discount_Detail__c lineItem = existingLineItemMap.get(remoteLineItem.id);
                            if (lineItem != null) {
                                updateLineItemFromRemote(lineItem, remoteLineItem);
                                updateLineItems.add(lineItem);
                                newIdSet.add(remoteLineItem.id);
                            } else {
                                result.messages.add(String.format('Line item with ID {0} is not found', new String[] {remoteLineItem.id}));
                                break;
                            }
                        } else {
                            ASI_CRM_Price_And_Discount_Detail__c lineItem = new ASI_CRM_Price_And_Discount_Detail__c();
                            updateLineItemFromRemote(lineItem, remoteLineItem);
                            lineItem.ASI_CRM_Price_And_Discount__c = headerId;
                            insertLineItems.add(lineItem);
                        }
                    }
                }
                
                if (existingLineItemMap.size() != newIdSet.size()) {
                    for (ASI_CRM_Price_And_Discount_Detail__c existingLineItem : existingLineItemMap.values()) {
                        if (!newIdSet.contains(existingLineItem.Id))
                            deleteLineItems.add(existingLineItem);
                    }
                }
                System.debug(LoggingLevel.INFO, '*** updateLineItems: ' + deleteLineItems);
                System.debug(LoggingLevel.INFO, '*** updateLineItems: ' + insertLineItems);
                System.debug(LoggingLevel.INFO, '*** updateLineItems: ' + updateLineItems);
                System.Savepoint sp = database.setSavepoint();
                try {
                    delete deleteLineItems;
                    insert insertLineItems;
                    update updateLineItems;
                    result.success = true;
                } catch (DmlException dmle) {
                    database.rollback(sp);
                    Set<String> errMsgs = new Set<String>();
                    Integer size = dmle.getNumDml();
                    for (Integer i = 0; i < size; i++) {
                        errMsgs.add(dmle.getDmlMessage(i));
                    }
                    result.messages.addAll(errMsgs);
                }
                
            } else {
                result.messages.add('Invalid header ID');
            }
        } catch (Exception e) {
            result.messages.add(e.getMessage());
        }
        return result;
    }
    private static void updateLineItemFromRemote(ASI_CRM_Price_And_Discount_Detail__c lineItem, ASI_CTY_CN_WS_SOLineItem remoteLineItem) {
        
        Map<ID ,ASI_CRM_CN_T1_Price__c> mapT1Price = new Map<ID ,ASI_CRM_CN_T1_Price__c>();
        
        for(ASI_CRM_CN_T1_Price__c obj : t1Price){
            if(!mapT1Price.containsKey(obj.ASI_CRM_CN_Item_Group__c))
                mapT1Price.put(obj.ASI_CRM_CN_Item_Group__c, obj);
        }

        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') lineItem.Id = remoteLineItem.id;
        lineItem.ASI_CRM_New_Price_BT_with_VAT__c = remoteLineItem.price;
        lineItem.ASI_CRM_Item_Group_Description__c = remoteLineItem.skuId;
        lineItem.RecordTypeId = Global_RecordTypeCache.getRtID('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail');
        lineItem.ASI_CRM_Promotion_Code__c = remoteLineItem.promotionCodeID;
        lineItem.ASI_CRM_Current_T1_Price_BT_with_VAT__c = remoteLineItem.currentT1PriceBTwithVAT;//mapT1Price.containsKey(remoteLineItem.skuId) ? mapT1Price.get(remoteLineItem.skuId).ASI_CRM_CN_T1_Price__c : null;
        lineItem.ASI_CRM_Total_Estimated_Vol_BT__c = remoteLineItem.totalEstimatedVolBT;
        lineItem.ASI_CTY_CN_WS_Level1_Promotion_Code__c = remoteLineItem.level1PromotionCodeId;
        lineItem.ASI_CTY_CN_WS_Disount_Value__c = remoteLineItem.discountValue;
        lineItem.ASI_CTY_CN_WS_Value_Type__c = remoteLineItem.valueType;
    }
    
    public List<List<String>> getSubBrandSearchOptions() {
        List<List<String>> result = new List<List<String>>();
        List<ASI_MFM_Sub_brand__c> sbList = [
            SELECT Id, Name, ASI_MFM_Sub_brand_Description__c
            FROM ASI_MFM_Sub_brand__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_SB
            ORDER BY Name
        ];
        for (ASI_MFM_Sub_brand__c sb : sbList) {
            List<String> mOption = new String[2];
            mOption[0] = String.escapeSingleQuotes(sb.Id);
            mOption[1] = sb.Name == null ? '' : sb.Name;
            result.add(mOption);
        }
        return result;
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
    private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }
    
    public List<String> getBrandType(){
        
        List<String> BrandType = new List<String>();
        Set<ASI_CRM_CN_Brand_Group__c> BrandTypeSet = new Set<ASI_CRM_CN_Brand_Group__c>([SELECT Name FROM ASI_CRM_CN_Brand_Group__c ORDER BY ASI_CRM_CN_Sequence2__c]);
        
        for(ASI_CRM_CN_Brand_Group__c obj: BrandTypeSet){
            String Name = '';
            
            if(obj.Name.contains('\'')){
                String[] splittedName = obj.Name.split('\'');
                for(integer i = 0 ; i < splittedName.size() ; i ++){
                    
                    Name += splittedName[i];
                }
            }else{
                Name = obj.Name;
            }
               
            BrandType.add(Name);
        }
        
        return BrandType;
    }
    
    
    public class ASI_CTY_CN_WS_SOLineItem {
        public String id { get; set; }
        public String skuId { get; set; }
        public String skuLabel { get; set; }
        public String subBrandId { get; set; }
        public String subBrandLabel { get; set; }
        public String brandType { get; set; }
        public Decimal qty { get; set; }
        public Decimal totalEstimatedVolBT { get; set; }
        public Decimal qty9Lfactor { get; set; }
        public String promotionCodeID { get; set; }
        public String remark { get; set; }
        public Decimal currentT1PriceBTwithVAT { get; set; }
        public Decimal price { get; set; }
        public String pickListValue { get; set; }
        public String promotionValue { get; set; }

        public String promotionType { get; set; }
        //public String subPromotionTypePickList { get; set; }
        public String subPromotionType { get; set; }
        public String level1PromotionCode { get; set; }
        public String level1PromotionCodeId { get; set; }
        public String level2PromotionCode { get; set; }
        public Decimal discountValue { get; set; }
        public String valueType { get; set; }
        public String valueTypePickList { get; set; }
    }
    
    public virtual class ASI_CTY_CN_WS_SKU {
        public String id { get; set; }
        public String code { get; set; }
        public String remark { get; set; }
        public String name { get; set; }
        public Decimal currentT1PriceBTwithVAT { get; set; }
        public Decimal qty9Lfactor { get; set; }
        public String subBrandId { get; set; }
        public String subBrandLabel { get; set; }
        public string packaging { get; set; }
        public Decimal price { get; set; }
        public Decimal inventory { get; set; }
        public String brandType { get; set; }
        public String pickListValue { get; set; }
        public String promotionValue { get; set; }
        public Decimal stdNum { get; set; }     //Std. Bottle Size

        public String dummy { get; set; }

        public String promotionType { get; set; }
        //public String subPromotionTypePickList { get; set; }
        public String subPromotionType { get; set; }
        public String level1PromotionCode { get; set; }
        public String level1PromotionCodeId { get; set; }
        public String level2PromotionCode { get; set; }
        public Decimal discountValue { get; set; }
        public String valueType { get; set; }
        public String valueTypePickList { get; set; }

    }
    
    public class ASI_CTY_CN_WS_NormalProduct extends ASI_CTY_CN_WS_SKU {
    }


    public class ASI_CTY_CN_WS_SaveResult {
        public Boolean success { get; set; }
        public List<String> messages { get; set; }
        
        public ASI_CTY_CN_WS_SaveResult() {
            this.messages = new List<String>();
        }
    }

    private static String getPickListStr(String sObjectName, String sFieldName, Boolean isAD) {
        String picValues = '';

        Map<String, Schema.SObjectType> sObjectDescribeMap = Schema.getGlobalDescribe();
        if (sObjectDescribeMap.containsKey(sObjectName)) {
            Map<String, Schema.SobjectField> sObjectFieldsMap =
                sObjectDescribeMap.get(sObjectName).getDescribe().fields.getMap();
                System.debug(LoggingLevel.INFO, '*** sObjectFieldsMap: ' + sObjectFieldsMap);
            if (sObjectFieldsMap.containsKey(sFieldName)) {
                Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFieldsMap.get(sFieldName).getDescribe();
                List<Schema.PicklistEntry> lPickEntryList = sObjectFieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry tPicklistEntry : lPickEntryList) {
                    if (isAD && tPicklistEntry.getValue() != ASI_CTY_CN_WS_Utils.VALUE_TYPE_PERCENT) {
                        continue;
                    }
                    picValues = picValues + (picValues != '' ? ';' : '') + tPicklistEntry.getLabel() + '-' + tPicklistEntry.getValue() ;
                }
            } else {
                return picValues;
            }
        } else {
            return picValues;
        }
        return picValues;
    }

}
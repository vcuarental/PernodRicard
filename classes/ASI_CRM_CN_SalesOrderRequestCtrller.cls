/*
 * *******************************************************************************
 * Name: ASI_CRM_CN_SalesOrderRequestCtrller
 * Description: 
 * Version History
 * Date 			Developer 			Comments
 * --------------- -------------------- --------------------------------------------------------------------------------
 * ???				???			 		Created
 * 2018-12-24		Vincent Lam			[VL 1.0] Hide approval route criteria City > Sub-region as it's not deployed yet
 * 2019-06-26       Wilson Chow         Apply hierarchy to allocation control logic
 */
public without sharing class ASI_CRM_CN_SalesOrderRequestCtrller {
//Version 0.0.1
//Last modified: 20130813 00:32
    
    //The SalesOrderItem do not allow to added if not within this range
    
    /*private static final Set<String> STATUS_ALLOW_EDIT = new Set<String>{
        'Draft',
        'SA Rejected',
        'Supervisor Rejected'
    };*/

    // TODO: Centralize the record type developer names
    private static final String RTDEVNAME_SKU = 'ASI_CRM_CN_CRM_Item_Group';
    private static final String RTDEVNAME_SB = 'ASI_FOC_CN_Sub_brand';
    private static final String RTDEVNAME_CUST_PD_PRICE = 'ASI_CRM_CN_T1_Price';
    //private static final Set<String> RTDEVNAME_ACCT_HAVE_CUST_PRICE = ASI_HK_CRM_AccountGenerator.RTDEVNAME_ACCT_HAVE_CUST_PRICE;
    //private static final Set<String> RTDEVNAME_ACCT_IS_HK_LUX = ASI_HK_CRM_AccountGenerator.RTDEVNAME_ACCT_IS_HK_LUX ;
    
    private static final String ACCT_TYPE_EXIST = 'exist';
    private static final String ACCT_TYPE_POTENTIAL = 'potential';
    
    //public static Set<String> promotionIDSet = new Set<String>();
    
    public String soHeaderId { get; private set; }
    public String acctId { get; private set; }
    public String acctDAId { get; private set; }  //Get DA Account Abel
    public String pageTitle { get; private set; }
    public Boolean allowEdit { get; private set; }
    public String ACCT_TYPE_EXIST_DISPLAY { get { return ACCT_TYPE_EXIST; } private set; }
    public String ACCT_TYPE_POTENTIAL_DISPLAY { get { return ACCT_TYPE_POTENTIAL; } private set; }
    public String acctType { get; private set; }
    public String customerType { get; private set; } //20181031 Alan Lau
    public Boolean useCustPrice { get; private set; }
    public List<List<String>> sbSearchOptionsNormal { get; set; }
    public List<List<String>> sbSearchOptionsPOS { get; set; }
    Public ASI_KOR_Sales_Order_Request__c headerSO {Get; Set;}//20161124 Elufa
    
    public ASI_CRM_CN_SalesOrderRequestCtrller(ApexPages.StandardSetController stdSetController) {
        this.soHeaderId = ApexPages.currentPage().getParameters().get('id');
        this.useCustPrice = FALSE;
        this.sbSearchOptionsNormal = getSubBrandSearchOptions();
        this.sbSearchOptionsPOS = sbSearchOptionsNormal;
        this.headerSO = [SELECT id, ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c FROM ASI_KOR_Sales_Order_Request__c WHERE ID = : soHeaderId];//20161124 Elufa
        this.customerType = this.headerSO.ASI_CRM_CN_Customer__r.ASI_CRM_Customer_Type_Picklist__c; //20181031 Alan Lau
    }
     
    //Retrieve the SOLineItem under the SO 
    @RemoteAction
    public static List<ASI_HK_CRM_SOLineItem> lineItemList(ID headerId) {
        
        Date todayDate = Date.today();
        Date startDate;//20170527
        Date endDate;//20170527
        
        Map<String, ASI_CRM_Item_Group_Allocation__c> allocationMap = new Map<String, ASI_CRM_Item_Group_Allocation__c>();
        Map<id, id> mapOrderForm = new Map<id, id>();
        List<ASI_CRM_Order_Form_Customer_Relationship__c> ofcrList;
        //Decimal taxRate = [SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC][0].ASI_CRM_CN_Tax_Rate__c;//2019/10/27 CanterDuan 记录税率
        
        ASI_KOR_Sales_Order_Request__c soHeader = [select Id, ASI_CRM_SG_Order_Date__c
                                                   , ASI_CRM_CN_Customer__c
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Order_by_BT__c
                                                   , ASI_CRM_CN_RTD__c ,ASI_CRM_CN_Premium__c
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c //20160803 Ben @ Elufa
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__r.Name
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
												   /* [VL 1.0] BEGIN */
												   /*
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c // 20180320 Introv added
                                                   */
												   /* [VL 1.0] END */
                                                    // 20190626 Wilson Chow
                                                    , ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c
                                                    , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c
                                                    // 20190626 Wilson Chow
												   FROM ASI_KOR_Sales_Order_Request__c 
                                                   WHERE Id = : headerId]; //20160926, edited by Leo, add sletect field - ASI_CRM_CN_Premium__c
        
        startDate = date.newInstance(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month(), 1);
        endDate = date.newInstance(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month(), date.daysInMonth(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month()));
        
		/* [VL 1.0] BEGIN */
		/*
        //20180320 Introv
        Id regionId = soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c != Null && soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c.containsIgnoreCase('Premium') ?
            soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
		*/
		/* [VL 1.0] END */
        
        for(ASI_CRM_Item_Group_Allocation__c allocationItem : [SELECT id
                                                                , ASI_CRM_Allocation_Quantity_Bottle__c
                                                                , ASI_CRM_Item_Group__c
                                                                , ASI_CRM_MTD_Order_Quantity__c
                                                                , ASI_CRM_MTD_Order_Quantity_CA__c
                                                                , ASI_CRM_Remaining_Qty_BT__c
                                                                , ASI_CRM_Remaining_Qty_CA__c
                                                                // 20190626 Wilson Chow
                                                                , ASI_CRM_Commercial_Team__c
                                                                , ASI_CRM_Region__c
                                                                , ASI_CRM_Channel__c
                                                                , ASI_CRM_Customer__c
                                                                // 20190626 Wilson Chow
                                                                FROM ASI_CRM_Item_Group_Allocation__c
                                                                WHERE ASI_CRM_Effective_Date__c >= : startDate
                                                                AND ASI_CRM_Effective_Date__c <= : endDate
                                                                AND ASI_CRM_Commercial_Team__c = : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                                /* [VL 1.0] BEGIN */
                                                                /*
                                                                AND ASI_CRM_Region__c = : regionId //soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, 20180320 Introv commented
                                                                */
                                                                AND ASI_CRM_Region__c = : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                                /* [VL 1.0] END */
                                                                AND recordType.developerName Like '%_CN_%'
                                                            ]){
                                                                // 20190626 Wilson Chow
                                                                /*
                                                                allocationMap.put(allocationItem.ASI_CRM_Item_Group__c, allocationItem);
                                                                */
                                                                String key = allocationItem.ASI_CRM_Item_Group__c + '_'
                                                                            + allocationItem.ASI_CRM_Commercial_Team__c + '_'
                                                                            + allocationItem.ASI_CRM_Region__c + '_'
                                                                            + allocationItem.ASI_CRM_Channel__c + '_'
                                                                            + allocationItem.ASI_CRM_Customer__c;
                                                                system.debug('lineItemList allocation map key:' + key);
                                                                allocationMap.put(key, allocationItem);
                                                                // 20190626 Wilson Chow
                                                            }
        
        if(soHeader.ASI_CRM_CN_RTD__c == TRUE)
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='RTD' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        //20160926, added by Leo
        else if(soHeader.ASI_CRM_CN_Premium__c == TRUE)
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='Premium' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        //20160926, added by Leo
        else
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='Normal Item' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        
        
        for(ASI_CRM_Order_Form_Customer_Relationship__c obj : ofcrList)
            mapOrderForm.put(obj.ASI_CRM_Customer__c, obj.ASI_CRM_Order_Form__c);
        
        
        system.debug('check007 ' + mapOrderForm.get(soHeader.ASI_CRM_CN_Customer__c));
        List<ASI_CRM_Order_Form_Detail__c> ofList = new List<ASI_CRM_Order_Form_Detail__c>([SELECT id, ASI_CRM_Product_Name__c, ASI_CRM_Sequence__c FROM ASI_CRM_Order_Form_Detail__c WHERE ASI_CRM_Order_Form__c =: mapOrderForm.get(soHeader.ASI_CRM_CN_Customer__c)]);
        Map<id, Decimal> mapOrderFormRemark = new Map<id, Decimal>();
        for(ASI_CRM_Order_Form_Detail__c obj : ofList){
            mapOrderFormRemark.put(obj.ASI_CRM_Product_Name__c, obj.ASI_CRM_Sequence__c);
        }
        
        List<ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomerPrice = new List<ASI_CRM_Item_Group_Customer_Price__c>([SELECT ASI_CRM_Customer__c
                                                                                                                            , ASI_CRM_Item_Group__c
                                                                                                                            , ASI_CRM_Price_Type__c
                                                                                                                            , ASI_CRM_Promotion_Code__c
                                                                                                                            , ASI_CRM_Promotion_Expiration_Date__c
                                                                                                                            , ASI_CRM_Unit_Price_BT__c
                                                                                                                            , ASI_CRM_Promotion_Code__r.Name
                                                                                                                            , ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c
                                                                                                                            , ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c
                                                                                                                            , ASI_CRM_Effective_Date_To__c//20161122 Elufa
                                                                                                                            FROM ASI_CRM_Item_Group_Customer_Price__c WHERE ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c//ASI_CRM_Promotion_Expiration_Date__c >=: todayDate
                                                                                                                           ]);
        
        Map<String, ASI_CRM_Item_Group_Customer_Price__c> mapCustomerPrice = new Map<String, ASI_CRM_Item_Group_Customer_Price__c>();
        Map<String, ASI_CRM_Item_Group_Customer_Price__c> mapPrmotionCode = new Map<String, ASI_CRM_Item_Group_Customer_Price__c>();
        
        for(ASI_CRM_Item_Group_Customer_Price__c obj : itemGroupCustomerPrice){
            mapCustomerPrice.put(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c, obj);
            if(obj.ASI_CRM_Promotion_Expiration_Date__c >= date.today()){
                mapPrmotionCode.put(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c, obj);
            }
        }
        
        List<ASI_HK_CRM_SOLineItem> result = new List<ASI_HK_CRM_SOLineItem>();
        List<ASI_KOR_Sales_Order_Transaction__c> lineItems = [
            SELECT Id, Name, ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__c, ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__r.Name,
            ASI_CRM_CN_Product_Name__c, ASI_CRM_CN_Remark__c, ASI_CRM_CN_Product_Name__r.Name, ASI_KOR_Order_Qty__c, ASI_CRM_CN_Logistics_Remark__c,
            ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name, ASI_CRM_CN_UOM__c, ASI_CRM_CN_Promotion_Code__c,
            ASI_CRM_CN_Promotion_Code__r.Name, ASI_CRM_CN_Promotion_Expiration_Date__c, ASI_CRM_CN_Unit_Price_BT_with_VAT__c, 
            ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Converion9L_C__c, ASI_CRM_CN_Unit_Price_Source__c, ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Buy_X__c,
            ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Get_Y__c, ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c, ASI_CRM_CN_Product_Name__r.ASI_MFM_Item_Group_Code__c,
            ASI_CRM_CN_Product_Name__r.ASI_CRM_Allocation_Information__c, //20170205 Elufa
            ASI_CRM_MOT_Price_non_VAT__c, ASI_CRM_MOT_Promotion_Price_non_VAT__c, ASI_CRM_MOT_Discount_Amount__c, //20181031 Alan Lau
            ASI_CRM_CN_Tax_Rate__c //2019/11/6 CanterDuan
            FROM ASI_KOR_Sales_Order_Transaction__c
            WHERE ASI_KOR_Sales_Order_Request__c = :headerId
        ];

        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMapForMOTPrice = createLineItemPriceAndDiscountDetailMap(lineItems, soHeader, 'Contract Price'); //20181101 Alan Lau
        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMapForMOTPromotionPrice = createLineItemPriceAndDiscountDetailMap(lineItems, soHeader, 'Promotion Price'); //20190110 Alan Lau
        Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecordForMOTPrice = getMapOfLineItemToIsNotSinglePriceRecord(lineItems, soHeader, 'Contract Price'); //20190111 Alan Lau
        Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecordForMOTPromotionPrice = getMapOfLineItemToIsNotSinglePriceRecord(lineItems, soHeader, 'Promotion Price'); //20190111 Alan Lau

        for (ASI_KOR_Sales_Order_Transaction__c lineItem : lineItems) {
            ASI_HK_CRM_SOLineItem tempLi = new ASI_HK_CRM_SOLineItem();
            tempLi.id = lineItem.Id;
            tempLi.skuId = lineItem.ASI_CRM_CN_Product_Name__c;
            tempLi.skuLabel = lineItem.ASI_CRM_CN_Product_Name__c != null ? lineItem.ASI_CRM_CN_Product_Name__r.Name : null;
            tempLi.skuInventory = lineItem.ASI_CRM_CN_Product_Name__c != null ? null : null;
            tempLi.unitPriceSource = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c) ? mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Price_Type__c : null;//li.ASI_CRM_CN_Unit_Price_Source__c;
            tempLi.subBrandId = lineItem.ASI_CRM_CN_Product_Name__c != null ? lineItem.ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__c : null;
            tempLi.subBrandLabel = tempLi.subBrandId != null ? lineItem.ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__r.Name : null;
            tempLi.brandType = lineItem.ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name;
            tempLi.buyX = lineItem.ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Buy_X__c;
            tempLi.getY = lineItem.ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Get_Y__c;
            tempLi.qty = lineItem.ASI_KOR_Order_Qty__c;
            tempLi.qty9Lfactor = lineItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Converion9L_C__c;
            tempLi.uom = lineItem.ASI_CRM_CN_UOM__c;
            tempLi.promotionCodeID = mapPrmotionCode.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c) ? mapPrmotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Code__c : Null;//li.ASI_CRM_CN_Promotion_Code__c;
            tempLi.promotionCodeName = mapPrmotionCode.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c) ? mapPrmotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Code__r.Name : Null;//li.ASI_CRM_CN_Promotion_Code__r.Name;
            tempLi.promotionExpirationDate = mapPrmotionCode.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c) ? mapPrmotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Expiration_Date__c.year() + '-' + mapPrmotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Expiration_Date__c.month() + '-' + mapPrmotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Promotion_Expiration_Date__c.day() : Null;/*li.ASI_CRM_CN_Promotion_Expiration_Date__c != null ? String.valueOf(li.ASI_CRM_CN_Promotion_Expiration_Date__c.year() + '-' + li.ASI_CRM_CN_Promotion_Expiration_Date__c.month() + '-' + li.ASI_CRM_CN_Promotion_Expiration_Date__c.day()) : null;*/
            //tempLi.price = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c) ? (mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Unit_Price_BT__c * 1.13).setScale(4) : null;//li.ASI_CRM_CN_Unit_Price_BT_with_VAT__c; //20180426 Introv changed Tax Rate From 17% to 16%//20190415 Laputa Andy changed Tax Rate from 16% to 13%
            tempLi.price = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c) ? (mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Unit_Price_BT__c * (1 + (lineItem.ASI_CRM_CN_Tax_Rate__c != null && lineItem.ASI_CRM_CN_Tax_Rate__c != 0 ? lineItem.ASI_CRM_CN_Tax_Rate__c : 13)/100)).setScale(4) : null;//2019/10/27 CanterDuan将税率修改调整为配置的形式
            tempLi.amount = null;
            tempLi.pack = lineItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c != NULL ? lineItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c : 0;
            tempLi.remark = lineItem.ASI_CRM_CN_Remark__c;
            System.debug('ddk'+ lineItem.ASI_CRM_CN_Product_Name__c);
            tempLi.stdNum = null;
            tempLi.sequence = mapOrderFormRemark.containsKey(lineItem.ASI_CRM_CN_Product_Name__c) ? mapOrderFormRemark.get(lineItem.ASI_CRM_CN_Product_Name__c) : NULL;
            tempLi.itemGroupCode = lineItem.ASI_CRM_CN_Product_Name__r.ASI_MFM_Item_Group_Code__c;
            //20161122 Elufa
            tempLi.effectiveDateTo = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c) && mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Effective_Date_To__c != Null ? mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Effective_Date_To__c.year() + '-' + mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Effective_Date_To__c.month() + '-' + mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Effective_Date_To__c.day() : Null;
            //20170205 Elufa
            tempLi.hasAllocation = lineItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_Allocation_Information__c;
            //20170527
            // 20190626 Wilson Chow
            /*
            tempLi.allocatedQty_BT = allocationMap.containsKey(lineItem.ASI_CRM_CN_Product_Name__c) && allocationMap.get(lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Remaining_Qty_BT__c != Null ? '' + allocationMap.get(lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Remaining_Qty_BT__c : '';
            tempLi.allocatedQty_CA = allocationMap.containsKey(lineItem.ASI_CRM_CN_Product_Name__c) && allocationMap.get(lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Remaining_Qty_CA__c != Null ? '' + integer.valueOf(allocationMap.get(lineItem.ASI_CRM_CN_Product_Name__c).ASI_CRM_Remaining_Qty_CA__c) : '';
            */
            String key1 = lineItem.ASI_CRM_CN_Product_Name__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__c;
            String key2 = lineItem.ASI_CRM_CN_Product_Name__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c + '_null';
            String key3 = lineItem.ASI_CRM_CN_Product_Name__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c + '_null_null';

            system.debug('lineItemList key1:' + key1);
            system.debug('lineItemList key2:' + key2);
            system.debug('lineItemList key3:' + key3);

            tempLi.allocatedQty_BT =
                    allocationMap.containsKey(key1) && allocationMap.get(key1).ASI_CRM_Remaining_Qty_BT__c != Null
                            ? '' + allocationMap.get(key1).ASI_CRM_Remaining_Qty_BT__c
                            : allocationMap.containsKey(key2) && allocationMap.get(key2).ASI_CRM_Remaining_Qty_BT__c != Null
                            ? '' + allocationMap.get(key2).ASI_CRM_Remaining_Qty_BT__c
                            : allocationMap.containsKey(key3) && allocationMap.get(key3).ASI_CRM_Remaining_Qty_BT__c != Null
                                    ? '' + allocationMap.get(key3).ASI_CRM_Remaining_Qty_BT__c
                                    : '';

            tempLi.allocatedQty_CA =
                    allocationMap.containsKey(key1) && allocationMap.get(key1).ASI_CRM_Remaining_Qty_CA__c != Null
                            ? '' + Integer.valueOf(allocationMap.get(key1).ASI_CRM_Remaining_Qty_CA__c)
                            : allocationMap.containsKey(key2) && allocationMap.get(key2).ASI_CRM_Remaining_Qty_CA__c != Null
                            ? '' + Integer.valueOf(allocationMap.get(key2).ASI_CRM_Remaining_Qty_CA__c)
                            : allocationMap.containsKey(key3) && allocationMap.get(key3).ASI_CRM_Remaining_Qty_CA__c != Null
                                    ? '' + Integer.valueOf(allocationMap.get(key3).ASI_CRM_Remaining_Qty_CA__c)
                                    : '';
            //20190626 Wilson Chow
            //20181101 Alan Lau
            tempLi.motPriceWithoutVAT = lineItemPriceAndDiscountDetailMapForMOTPrice.containsKey(lineItem.Id) ? lineItemPriceAndDiscountDetailMapForMOTPrice.get(lineItem.Id).ASI_CRM_New_Price_BT_non_VAT__c.setScale(4) : (lineItem.ASI_CRM_MOT_Price_non_VAT__c != null ? lineItem.ASI_CRM_MOT_Price_non_VAT__c.setScale(4) : 0);
            tempLi.motPromotionPriceWithoutVAT = lineItem.ASI_CRM_MOT_Promotion_Price_non_VAT__c != null ? lineItem.ASI_CRM_MOT_Promotion_Price_non_VAT__c.setScale(4) : (lineItemPriceAndDiscountDetailMapForMOTPromotionPrice.containsKey(lineItem.Id) ? lineItemPriceAndDiscountDetailMapForMOTPromotionPrice.get(lineItem.Id).ASI_CRM_New_Price_BT_non_VAT__c.setScale(4) : 0);
            tempLi.motDiscountAmount = (tempLi.motPriceWithoutVAT != null && tempLi.motPromotionPriceWithoutVAT != null) ? (tempLi.motPromotionPriceWithoutVAT - tempLi.motPriceWithoutVAT).setScale(4) : null;
            //20181101 End
            tempLi.motDiscountRate = (tempLi.motDiscountAmount != null && tempLi.motPriceWithoutVAT != null && tempLi.motPriceWithoutVAT != 0) ? ((tempLi.motDiscountAmount / tempLi.motPriceWithoutVAT) * 100).setScale(2) : null;
            tempLi.isMultiplePriceRecordForMOTPrice = mapOfLineItemToIsNotSinglePriceRecordForMOTPrice.get(lineItem.Id);
            tempLi.isMultiplePriceRecordForMOTPromotionPrice = mapOfLineItemToIsNotSinglePriceRecordForMOTPromotionPrice.get(lineItem.Id);
			
			system.debug(tempLi.itemGroupCode + ' ' + tempLi.isMultiplePriceRecordForMOTPrice);
            result.add(tempLi);
        }
            
        for (ASI_HK_CRM_SOLineItem str: result){ System.debug('kkl.5 Line Item List'+str); }
        return result;
    }

    private static Map<Id, Boolean> getMapOfLineItemToIsNotSinglePriceRecord(List<ASI_KOR_Sales_Order_Transaction__c> lineItemList, ASI_KOR_Sales_Order_Request__c salesOrderHeader, String priceType) {
        Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecord = new Map<Id, Boolean>();
        List<String> lineItemProductNameList = getLineItemProductNameList(lineItemList);
        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = getPriceAndDiscountDetailList(salesOrderHeader, lineItemProductNameList, priceType);

        Map<String, Boolean> mapOfItemGroupDescriptionToIsNotSingleRecord = new Map<String, Boolean>();
        for (ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail : priceAndDiscountDetailList) {
            if (mapOfItemGroupDescriptionToIsNotSingleRecord.containsKey(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c)) {
                mapOfItemGroupDescriptionToIsNotSingleRecord.put(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c, true);
            } else {
                mapOfItemGroupDescriptionToIsNotSingleRecord.put(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c, false);
            }
        }

        for (ASI_KOR_Sales_Order_Transaction__c lineItem : lineItemList) {
            if (mapOfItemGroupDescriptionToIsNotSingleRecord.containsKey(lineItem.ASI_CRM_CN_Product_Name__c)) {
                mapOfLineItemToIsNotSinglePriceRecord.put(lineItem.Id, mapOfItemGroupDescriptionToIsNotSingleRecord.get(lineItem.ASI_CRM_CN_Product_Name__c));
            } else {
                mapOfLineItemToIsNotSinglePriceRecord.put(lineItem.Id, false);
            }
        }

        return mapOfLineItemToIsNotSinglePriceRecord;
    }

    private static Map<Id, Boolean> getMapOfLineItemToIsNotSinglePriceRecord(List<string> itemGroupIdList, ASI_KOR_Sales_Order_Request__c salesOrderHeader, String priceType) {
        Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecord = new Map<Id, Boolean>();
        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = getPriceAndDiscountDetailList(salesOrderHeader, itemGroupIdList, priceType);

        Map<String, Boolean> mapOfItemGroupDescriptionToIsNotSingleRecord = new Map<String, Boolean>();
        for (ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail : priceAndDiscountDetailList) {
            if (mapOfItemGroupDescriptionToIsNotSingleRecord.containsKey(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c)) {
                mapOfItemGroupDescriptionToIsNotSingleRecord.put(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c, true);
            } else {
                mapOfItemGroupDescriptionToIsNotSingleRecord.put(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c, false);
            }
        }

        for (string itemGroupId : itemGroupIdList) {
            if (mapOfItemGroupDescriptionToIsNotSingleRecord.containsKey(itemGroupId)) {
                mapOfLineItemToIsNotSinglePriceRecord.put(itemGroupId, mapOfItemGroupDescriptionToIsNotSingleRecord.get(itemGroupId));
            } else {
                mapOfLineItemToIsNotSinglePriceRecord.put(itemGroupId, false);
            }
        }

        return mapOfLineItemToIsNotSinglePriceRecord;
    }

    private static Map<Id, ASI_CRM_Price_And_Discount_Detail__c> createLineItemPriceAndDiscountDetailMap(List<ASI_KOR_Sales_Order_Transaction__c> lineItemList, ASI_KOR_Sales_Order_Request__c salesOrderHeader, String priceType) { //20181101 Alan Lau
        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMap = new Map<Id, ASI_CRM_Price_And_Discount_Detail__c>();

        List<String> lineItemProductNameList = getLineItemProductNameList(lineItemList);
        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = getPriceAndDiscountDetailList(salesOrderHeader, lineItemProductNameList, priceType);

        for (ASI_KOR_Sales_Order_Transaction__c lineItem : lineItemList) {
            for (ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail : priceAndDiscountDetailList) {
                if (priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c == lineItem.ASI_CRM_CN_Product_Name__c) {
                    lineItemPriceAndDiscountDetailMap.put(lineItem.Id, priceAndDiscountDetail);
                    break;
                }
            }
        }

        return lineItemPriceAndDiscountDetailMap;
    }

    private static Map<Id, ASI_CRM_Price_And_Discount_Detail__c> createLineItemPriceAndDiscountDetailMap(List<Id> itemGroupIdList, ASI_KOR_Sales_Order_Request__c salesOrderHeader, String priceType) { //20181101 Alan Lau
        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMap = new Map<Id, ASI_CRM_Price_And_Discount_Detail__c>();

        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = getPriceAndDiscountDetailList(salesOrderHeader, itemGroupIdList, priceType);

        for (string itemGroupId : itemGroupIdList) {
            for (ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail : priceAndDiscountDetailList) {
                if (priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c == itemGroupId) {
                    lineItemPriceAndDiscountDetailMap.put(itemGroupId, priceAndDiscountDetail);
                    break;
                }
            }
        }

        return lineItemPriceAndDiscountDetailMap;
    }

    private static List<ASI_CRM_Price_And_Discount_Detail__c> getPriceAndDiscountDetailList(ASI_KOR_Sales_Order_Request__c salesOrderHeader, List<String> lineItemProductNameList, String priceType) { //20181106 Alan Lau
        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = [
                SELECT ASI_CRM_Item_Group_Description__c,
                        ASI_CRM_New_Price_BT_non_VAT__c
                FROM ASI_CRM_Price_And_Discount_Detail__c
                WHERE recordtypeid = :Global_RecordTypeCache.getRtID('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
				AND ASI_CRM_Price_And_Discount__r.recordtypeid = :Global_RecordTypeCache.getRtID('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Customer_Price_and_Discount_Request_RO')
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c = :salesOrderHeader.ASI_CRM_CN_Customer__c
                AND ASI_CRM_Item_Group_Description__c IN :lineItemProductNameList
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c <= :salesOrderHeader.ASI_CRM_SG_Order_Date__c
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c >= :salesOrderHeader.ASI_CRM_SG_Order_Date__c
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c = 'Completed'
                AND ASI_CRM_New_Price_BT_non_VAT__c != NULL
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_IHBR_Price_Type__c = :priceType
                ORDER BY ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c DESC
        ];
        return priceAndDiscountDetailList;
    }

    private static List<String> getLineItemProductNameList(List<ASI_KOR_Sales_Order_Transaction__c> lineItemList) { //20181106 Alan Lau
        List<String> lineItemProductNameList = new List<String>();
        for (ASI_KOR_Sales_Order_Transaction__c lineItem : lineItemList) {
            lineItemProductNameList.add(lineItem.ASI_CRM_CN_Product_Name__c);
        }
        return lineItemProductNameList;
    }

    @RemoteAction
    public static List<ASI_HK_CRM_NormalProduct> normalProductList(ID headerId, String custId, Boolean onlyCustPrice) {
        
        Date todayDate = Date.today();
        Date startDate;//20170527
        Date endDate;//20170527
        
        Map<String, ASI_CRM_Item_Group_Allocation__c> allocationMap = new Map<String, ASI_CRM_Item_Group_Allocation__c>();
        Map<id, id> mapOrderForm = new Map<id, id>();
        List<ASI_CRM_Order_Form_Customer_Relationship__c> ofcrList;
        Decimal taxRate = [SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC][0].ASI_CRM_CN_Tax_Rate__c;//2019/10/27 CanterDuan 记录税率
        
        ASI_KOR_Sales_Order_Request__c soHeader = [SELECT Id
                                                   , ASI_CRM_UOM__c
                                                   , ASI_CRM_CN_Customer__c
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Order_by_BT__c
                                                   , ASI_CRM_CN_RTD__c ,ASI_CRM_CN_Premium__c 
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c //20160803 Ben @ Elufa
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__r.Name
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                   /* [VL 1.0] BEGIN */
												   /*
                                                   , ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c //20180320 Introv
                                                   */
												   /* [VL 1.0] END */
												   , ASI_CRM_SG_Order_Date__c
                                                    // 20190626 Wilson Chow
                                                    , ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c
                                                    , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c
                                                    // 20190626 Wilson Chow
                                                   FROM ASI_KOR_Sales_Order_Request__c WHERE Id = : headerId]; //20160926, edited by Leo, add sletect field - ASI_CRM_CN_Premium__c
        
        //20170920
        startDate = date.newInstance(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month(), 1);
        endDate = date.newInstance(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month(), date.daysInMonth(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month()));
        
		/* [VL 1.0] BEGIN */
		/*
        //20180320 Introv
        Id regionId = soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c != Null && soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c.containsIgnoreCase('Premium') ?
            soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_Sub_Region__c : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c;
        */
		/* [VL 1.0] END */
		
        //20170527
        for(ASI_CRM_Item_Group_Allocation__c allocationItem : [SELECT id
                                                               , ASI_CRM_Allocation_Quantity_Bottle__c
                                                               , ASI_CRM_Item_Group__c
                                                               , ASI_CRM_MTD_Order_Quantity__c
                                                               , ASI_CRM_MTD_Order_Quantity_CA__c
                                                               , ASI_CRM_Remaining_Qty_BT__c
                                                               , ASI_CRM_Remaining_Qty_CA__c
                                                                // 20190626 Wilson Chow
                                                                , ASI_CRM_Commercial_Team__c
                                                                , ASI_CRM_Region__c
                                                                , ASI_CRM_Region__r.Name
                                                                , ASI_CRM_Channel__c
                                                                , ASI_CRM_Customer__c
                                                                // 20190626 Wilson Chow
                                                               FROM ASI_CRM_Item_Group_Allocation__c
                                                               WHERE ASI_CRM_Effective_Date__c >= : startDate
                                                               AND ASI_CRM_Effective_Date__c <= : endDate
                                                               AND ASI_CRM_Commercial_Team__c = : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                               /* [VL 1.0] BEGIN */
															   /*
															   AND ASI_CRM_Region__c = : regionId //soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c // 20180320 Introv Commented
                                                               */
															   AND ASI_CRM_Region__c = : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
															   /* [VL 1.0] END */
															   AND recordType.developerName Like '%_CN_%'
                                                            ]){
                                                                // 20190626 Wilson Chow
                                                                /*
                                                                allocationMap.put(allocationItem.ASI_CRM_Item_Group__c, allocationItem);
                                                                */
                                                                String key = allocationItem.ASI_CRM_Item_Group__c + '_'
                                                                        + allocationItem.ASI_CRM_Commercial_Team__c + '_'
                                                                        + allocationItem.ASI_CRM_Region__r.Name + '_'
                                                                        + allocationItem.ASI_CRM_Channel__c + '_'
                                                                        + allocationItem.ASI_CRM_Customer__c;
                                                                system.debug('normalProductList allocation map key:' + key);
                                                                allocationMap.put(key, allocationItem);
                                                                // 20190626 Wilson Chow
                                                            }
        
        if(soHeader.ASI_CRM_CN_RTD__c == TRUE)
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='RTD' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        //20160926, added by Leo
        else if(soHeader.ASI_CRM_CN_Premium__c == TRUE)
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='Premium' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        //20160926, added by Leo
        else
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='Normal Item' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        
        
        for(ASI_CRM_Order_Form_Customer_Relationship__c obj : ofcrList)
            mapOrderForm.put(obj.ASI_CRM_Customer__c, obj.ASI_CRM_Order_Form__c);
        
        
        system.debug('check007 ' + mapOrderForm.get(soHeader.ASI_CRM_CN_Customer__c));
        List<ASI_CRM_Order_Form_Detail__c> ofList = new List<ASI_CRM_Order_Form_Detail__c>([SELECT id, ASI_CRM_Product_Name__c, ASI_CRM_Sequence__c, ASI_CRM_Remark__c FROM ASI_CRM_Order_Form_Detail__c WHERE ASI_CRM_Order_Form__c =: mapOrderForm.get(soHeader.ASI_CRM_CN_Customer__c)]);
        Map<id, ASI_CRM_Order_Form_Detail__c> mapOrderFormRemark = new Map<id, ASI_CRM_Order_Form_Detail__c>();
        Set<ID> itemGroupID = new Set<id>();
        for(ASI_CRM_Order_Form_Detail__c obj : ofList){
            itemGroupID.add(obj.ASI_CRM_Product_Name__c);
            mapOrderFormRemark.put(obj.ASI_CRM_Product_Name__c, obj);
        }
        
        List<ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomerPrice = new List<ASI_CRM_Item_Group_Customer_Price__c>([SELECT ASI_CRM_Customer__c
                                                                                                                            , ASI_CRM_Item_Group__c
                                                                                                                            , ASI_CRM_Price_Type__c
                                                                                                                            , ASI_CRM_Promotion_Code__c
                                                                                                                            , ASI_CRM_Promotion_Expiration_Date__c
                                                                                                                            , ASI_CRM_Unit_Price_BT__c
                                                                                                                            , ASI_CRM_Promotion_Code__r.Name
                                                                                                                            , ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c
                                                                                                                            , ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c
                                                                                                                            , ASI_CRM_Effective_Date_To__c//20161122
                                                                                                                            FROM ASI_CRM_Item_Group_Customer_Price__c WHERE ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c//ASI_CRM_Promotion_Expiration_Date__c >=: todayDate
                                                                                                                           ]);
        
        Map<String, ASI_CRM_Item_Group_Customer_Price__c> mapPromotionCode = new Map<String, ASI_CRM_Item_Group_Customer_Price__c>();
        Map<String, ASI_CRM_Item_Group_Customer_Price__c> mapCustomerPrice = new Map<String, ASI_CRM_Item_Group_Customer_Price__c>();
        Set<id> ihbrItemGroup = new Set<id>();
        
        for(ASI_CRM_Item_Group_Customer_Price__c obj : itemGroupCustomerPrice){
            if(obj.ASI_CRM_Promotion_Expiration_Date__c >= todayDate)
                mapPromotionCode.put(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c, obj);
            mapCustomerPrice.put(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c, obj);
            
            //if(obj.ASI_CRM_Price_Type__c != 'T1')
            ihbrItemGroup.add(obj.ASI_CRM_Item_Group__c);
        }
        
        List<ASI_HK_CRM_NormalProduct> result = new List<ASI_HK_CRM_NormalProduct>();
        List<ASI_MFM_Item_Group__c> skuList = new List<ASI_MFM_Item_Group__c>();
        
        if(!soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c){
            skuList = [SELECT Id, Name, ASI_CRM_CN_pack__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                       , ASI_CRM_CN_BT_Size_C__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name, ASI_CRM_CN_Converion9L_C__c
                       , ASI_CRM_CN_Pack_Value__c, ASI_MFM_Item_Group_Code__c
                       , ASI_CRM_Allocation_Information__c//20170205 Elufa
                       FROM ASI_MFM_Item_Group__c
                       WHERE ID IN : itemGroupID
                       ORDER BY Name
                      ];
        }else{
            //20160503 Ben @ Elufa
            List<ASI_MFM_SKU_Code__c> tmpSKU = new List<ASI_MFM_SKU_Code__c>([SELECT ASI_MFM_Item_Group__c FROM ASI_MFM_SKU_Code__c 
                                                                              WHERE ASI_MFM_Item_Group__c IN : ihbrItemGroup 
                                                                              AND (ASI_CRM_SKU_Status__c LIKE '%000%' OR ASI_CRM_SKU_Status__c LIKE '%001%' OR ASI_CRM_SKU_Status__c LIKE '%997%')]);
            
            Set<Id> ihbrItemGroup2 = new Set<Id>();
            for(ASI_MFM_SKU_Code__c obj : tmpSKU)
                ihbrItemGroup2.add(obj.ASI_MFM_Item_Group__c);
            //20160503 End
            
            skuList = [SELECT Id, Name, ASI_CRM_CN_pack__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                       , ASI_CRM_CN_BT_Size_C__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name, ASI_CRM_CN_Converion9L_C__c
                       , ASI_CRM_CN_Pack_Value__c, ASI_MFM_Item_Group_Code__c
                       , ASI_CRM_Allocation_Information__c//20170205 Elufa
                       FROM ASI_MFM_Item_Group__c
                       WHERE ID IN : ihbrItemGroup2
                       ORDER BY Name
                      ];
        }

        List<Id> itemGroupIdList = getSkuIdList(skuList); //20181109 Alan Lau
        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMapForMOTPrice = createLineItemPriceAndDiscountDetailMap(itemGroupIdList, soHeader, 'Contract Price'); //20181109 Alan Lau
        Map<Id, Decimal> skuPriceWithoutVATMapForMOTPrice = createSKUPriceWithoutVATMap(itemGroupIdList, lineItemPriceAndDiscountDetailMapForMOTPrice); //20181109 Alan Lau

        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMapForMOTPromotionPrice = createLineItemPriceAndDiscountDetailMap(itemGroupIdList, soHeader, 'Promotion Price'); //20190110 Alan Lau
        Map<Id, Decimal> skuPriceWithoutVATMapForMOTPromotionPrice = createSKUPriceWithoutVATMap(itemGroupIdList, lineItemPriceAndDiscountDetailMapForMOTPromotionPrice); //20190110 Alan Lau
        
		Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecordForMOTPrice = getMapOfLineItemToIsNotSinglePriceRecord(itemGroupIdList, soHeader, 'Contract Price'); //20190111 Alan Lau
        Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecordForMOTPromotionPrice = getMapOfLineItemToIsNotSinglePriceRecord(itemGroupIdList, soHeader, 'Promotion Price'); //20190111 Alan Lau

        for (ASI_MFM_Item_Group__c sku : skuList) {
            ASI_HK_CRM_NormalProduct pd = new ASI_HK_CRM_NormalProduct();
            pd.id = sku.Id;
            pd.qty9Lfactor = sku.ASI_CRM_CN_Converion9L_C__c;
            pd.code = null;
            pd.remark = mapOrderFormRemark.containsKey(sku.id) ? mapOrderFormRemark.get(sku.id).ASI_CRM_Remark__c : '';
            pd.sequence = mapOrderFormRemark.containsKey(sku.id) ? mapOrderFormRemark.get(sku.id).ASI_CRM_Sequence__c : NULL;
            pd.name = sku.Name;
            pd.uom = soHeader.ASI_CRM_UOM__c != '' && soHeader.ASI_CRM_UOM__c != NULL ? soHeader.ASI_CRM_UOM__c : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Order_by_BT__c ? 'BT' : 'CA' ;
            pd.promotionCodeID = mapPromotionCode.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id) ? mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Code__c : null;
            pd.promotionCodeName = pd.promotionCodeID != null ? mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Code__r.Name : null ;
            pd.promotionExpirationDate = pd.promotionCodeID != null ? String.valueOf( mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Expiration_Date__c.year() + '-' + 
                                                                                     mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Expiration_Date__c.month() + '-' + 
                                                                                     mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Expiration_Date__c.day() ) : null ;
            //pd.price = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id) ? ( mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Unit_Price_BT__c * 1.13 ).setScale(3) : null; //20180426 Introv changed Tax Rate From 17% to 16%//20190415 Laputa Andy changed Tax Rate from 16% to 13%
            pd.price = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id) ? ( mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Unit_Price_BT__c * (1 + taxRate/100) ).setScale(3) : null; //2019/10/27 CanterDuan将税率修改调整为配置的形式
            pd.unitPriceSource = pd.price != null ? mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Price_Type__c : null ;
            pd.buyX = pd.promotionCodeID != null ? mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c : null;
            pd.getY = pd.promotionCodeID != null ? mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c : null;
            pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
            pd.subBrandLabel = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
            pd.inventory = null;
            pd.itemGroupCode = sku.ASI_MFM_Item_Group_Code__c;
            //20161122 Elufa
            pd.effectiveDateTo = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id) && mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Effective_Date_To__c != Null ? mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Effective_Date_To__c.year() + '-' + mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Effective_Date_To__c.month() + '-' + mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Effective_Date_To__c.day() : Null;
            
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
            pd.pack = sku.ASI_CRM_CN_Pack_Value__c != NULL ? sku.ASI_CRM_CN_Pack_Value__c : 0;
            pd.stdNum = null;
            pd.dummy = null;
            //20170205 Elufa
            pd.hasAllocation = sku.ASI_CRM_Allocation_Information__c;
            //20170527
            // 20190626 Wilson Chow
            /*
            pd.allocatedQty_BT = allocationMap.containsKey(sku.id) && allocationMap.get(sku.id).ASI_CRM_Remaining_Qty_BT__c != Null ? '' + allocationMap.get(sku.id).ASI_CRM_Remaining_Qty_BT__c : '';
            pd.allocatedQty_CA = allocationMap.containsKey(sku.id) && allocationMap.get(sku.id).ASI_CRM_Remaining_Qty_CA__c != Null ? '' + allocationMap.get(sku.id).ASI_CRM_Remaining_Qty_CA__c : '';
            */
            String key1 = sku.id + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__c;
            String key2 = sku.id + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c + '_null';
            String key3 = sku.id + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c + '_'
                    + soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c + '_null_null';

            system.debug('normalProductList key1:' + key1);
            system.debug('normalProductList key2:' + key2);
            system.debug('normalProductList key3:' + key3);

            pd.allocatedQty_BT =
                    allocationMap.containsKey(key1) && allocationMap.get(key1).ASI_CRM_Remaining_Qty_BT__c != Null
                            ? '' + allocationMap.get(key1).ASI_CRM_Remaining_Qty_BT__c
                            : allocationMap.containsKey(key2) && allocationMap.get(key2).ASI_CRM_Remaining_Qty_BT__c != Null
                            ? '' + allocationMap.get(key2).ASI_CRM_Remaining_Qty_BT__c
                            : allocationMap.containsKey(key3) && allocationMap.get(key3).ASI_CRM_Remaining_Qty_BT__c != Null
                                    ? '' + allocationMap.get(key3).ASI_CRM_Remaining_Qty_BT__c
                                    : '';

            pd.allocatedQty_CA =
                    allocationMap.containsKey(key1) && allocationMap.get(key1).ASI_CRM_Remaining_Qty_CA__c != Null
                            ? '' + allocationMap.get(key1).ASI_CRM_Remaining_Qty_CA__c
                            : allocationMap.containsKey(key2) && allocationMap.get(key2).ASI_CRM_Remaining_Qty_CA__c != Null
                            ? '' + allocationMap.get(key2).ASI_CRM_Remaining_Qty_CA__c
                            : allocationMap.containsKey(key3) && allocationMap.get(key3).ASI_CRM_Remaining_Qty_CA__c != Null
                                    ? '' + allocationMap.get(key3).ASI_CRM_Remaining_Qty_CA__c
                                    : '';
            // 20190626 Wilson Chow
            pd.motPriceWithoutVAT = skuPriceWithoutVATMapForMOTPrice.containsKey(sku.Id) ? skuPriceWithoutVATMapForMOTPrice.get(sku.Id).setScale(4) : null; //20181109 Alan Lau
            pd.motPromotionPriceWithoutVAT = skuPriceWithoutVATMapForMOTPromotionPrice.containsKey(sku.Id) ? skuPriceWithoutVATMapForMOTPromotionPrice.get(sku.Id).setScale(4) : null; //20190110 Alan Lau
			pd.motDiscountAmount = (pd.motPriceWithoutVAT != null && pd.motPromotionPriceWithoutVAT != null) ? (pd.motPromotionPriceWithoutVAT - pd.motPriceWithoutVAT).setScale(4) : null;
            pd.motDiscountRate = (pd.motDiscountAmount != null && pd.motPriceWithoutVAT != null) ? ((pd.motDiscountAmount / pd.motPriceWithoutVAT) * 100).setScale(2) : null;
            pd.isMultiplePriceRecordForMOTPrice = mapOfLineItemToIsNotSinglePriceRecordForMOTPrice.get(sku.Id);
            pd.isMultiplePriceRecordForMOTPromotionPrice = mapOfLineItemToIsNotSinglePriceRecordForMOTPromotionPrice.get(sku.Id);
			
			
			system.debug(pd.itemGroupCode + ' ' + pd.isMultiplePriceRecordForMOTPrice);
            result.add(pd);
        }
        for(ASI_HK_CRM_NormalProduct str2: result){
            System.debug('kkl.6 normal product list'+str2);
        }
        return result;
    }

    private static List<Id> getSkuIdList(List<ASI_MFM_Item_Group__c> skuList) { //20181109 Alan Lau
        List<Id> skuIdList = new List<Id>();

        for (ASI_MFM_Item_Group__c sku : skuList) {
            skuIdList.add(sku.Id);
        }
        return skuIdList;
    }

    private static Map<Id, Decimal> createSKUPriceWithoutVATMap(List<Id> itemGroupIdList, Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMap) { //20181109 Alan Lau
        Map<Id, Decimal> skuPriceWithoutVATMap = new Map<Id, Decimal>();

        for (string itemGroupId : itemGroupIdList) {
            if (lineItemPriceAndDiscountDetailMap.containsKey(itemGroupId)) {
                skuPriceWithoutVATMap.put(itemGroupId, lineItemPriceAndDiscountDetailMap.get(itemGroupId).ASI_CRM_New_Price_BT_non_VAT__c);
            }
        }

        return skuPriceWithoutVATMap;
    }

    @RemoteAction
    public static ASI_HK_CRM_SaveResult saveChanges(String headerId, List<ASI_HK_CRM_SOLineItem> remoteLineItems) {
        ASI_HK_CRM_SaveResult result = new ASI_HK_CRM_SaveResult();
        result.success = false;
        
        try {
            if (isNonEmptyId(headerId)) {
                Map<ID, ASI_KOR_Sales_Order_Transaction__c> existingLineItemMap = new Map<ID, ASI_KOR_Sales_Order_Transaction__c>(
                (List<ASI_KOR_Sales_Order_Transaction__c>)[
                    SELECT Id, LastModifiedDate
                    FROM ASI_KOR_Sales_Order_Transaction__c
                    WHERE ASI_KOR_Sales_Order_Request__c = :headerId
                    FOR UPDATE
                ]);
                
                Set<ID> newIdSet = new Set<ID>();
                List<ASI_KOR_Sales_Order_Transaction__c> insertLineItems = new List<ASI_KOR_Sales_Order_Transaction__c>();
                List<ASI_KOR_Sales_Order_Transaction__c> updateLineItems = new List<ASI_KOR_Sales_Order_Transaction__c>();
                List<ASI_KOR_Sales_Order_Transaction__c> deleteLineItems = new List<ASI_KOR_Sales_Order_Transaction__c>();
                if (remoteLineItems != null) {
                    for (ASI_HK_CRM_SOLineItem remoteLineItem : remoteLineItems) {
                        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') {
                            ASI_KOR_Sales_Order_Transaction__c lineItem = existingLineItemMap.get(remoteLineItem.id);
                            if (lineItem != null) {
                                updateLineItemFromRemote(lineItem, remoteLineItem);
                                updateLineItems.add(lineItem);
                                newIdSet.add(remoteLineItem.id);
                            } else {
                                result.messages.add(String.format('Line item with ID {0} is not found', new String[] {remoteLineItem.id}));
                                break;
                            }
                        } else {
                            ASI_KOR_Sales_Order_Transaction__c lineItem = new ASI_KOR_Sales_Order_Transaction__c();
                            updateLineItemFromRemote(lineItem, remoteLineItem);
                            lineItem.ASI_KOR_Sales_Order_Request__c = headerId;
                            insertLineItems.add(lineItem);
                        }
                    }
                }
                
                if (existingLineItemMap.size() != newIdSet.size()) {
                    for (ASI_KOR_Sales_Order_Transaction__c existingLineItem : existingLineItemMap.values()) {
                        if (!newIdSet.contains(existingLineItem.Id))
                            deleteLineItems.add(existingLineItem);
                    }
                }
                
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
        System.debug('kkl.8'+result);
        return result;
    }
    private static void updateLineItemFromRemote(ASI_KOR_Sales_Order_Transaction__c lineItem, ASI_HK_CRM_SOLineItem remoteLineItem) {
        
        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') lineItem.Id = remoteLineItem.id;
        lineItem.ASI_CRM_CN_Product_Name__c = remoteLineItem.skuId;
        lineItem.RecordTypeId = Global_RecordTypeCache.getRtID('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item');
        lineitem.ASI_KOR_Order_Qty__c = remoteLineItem.qty;
        lineItem.ASI_CRM_UOM_Text__c = remoteLineItem.uomText;
        lineItem.ASI_CRM_MOT_Price_non_VAT__c = remoteLineItem.motPriceWithoutVAT; //20181101 Alan Lau
        lineItem.ASI_CRM_MOT_Promotion_Price_non_VAT__c = remoteLineItem.motPromotionPriceWithoutVAT; //20181101 Alan Lau
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
        for(List<String> str3: result){
            System.debug('tky'+str3);
        }
        
        return result;
    }
    
    private void showPageMessage(ApexPages.Severity severity, String msg) { ApexPages.addMessage(new ApexPages.Message(severity, msg)); }
    private void showPageError(String msg) { showPageMessage(ApexPages.Severity.ERROR, msg); }
    
    private static Boolean isNonEmptyId(String theId) {
        if (theId != null && theId.trim() != '') {
            ID testId;
            try {
                testId = theId;
                return true;
            } catch(Exception e) {}
        }
        return false;
    }
    
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
    
    public class ASI_HK_CRM_SOLineItem {
        public String id { get; set; }
        public String skuId { get; set; }
        public String skuLabel { get; set; }
        public Decimal skuInventory { get; set; }
        public String subBrandId { get; set; }
        public String subBrandLabel { get; set; }
        public String brandType { get; set; }
        public Decimal qty { get; set; }
        public String uom { get; set; }
        public Decimal buyX { get; set; }
        public Decimal getY { get; set; }
        public Decimal qty9Lfactor { get; set; }
        public String promotionCodeID { get; set; }
        public String promotionCodeName { get; set; }
        Public String promotionExpirationDate { get; set; }
        public String unitPriceSource { get; set; }
        public String remark { get; set; }
        public string packaging { get; set; }
        public Decimal price { get; set; }
        public Decimal amount { get; set; }
        public Boolean available { get; set; }
        public Boolean isPOS { get; set; }
        public Decimal stdNum { get; set; }   //Std. Bottle Size
        public Decimal pack { get; set; }
        public Decimal sequence { get; set; }
        public string uomText { get; set; }
        public string itemGroupCode { get; set; }
        Public String effectiveDateTo { get; set; }//20161112 Elufa
        Public Boolean hasAllocation { get; set; }//20170205 Elufa
        Public String allocatedQty_BT {get; set;}//20170527 Introv
        Public String allocatedQty_CA {get; set;}//20170527 Introv
        public Decimal motPriceWithoutVAT {get; set;} //20181101 Alan Lau
        public Decimal motPromotionPriceWithoutVAT {get; set;} //20181101 Alan Lau
        public Decimal motDiscountAmount {get; set;} //20181101 Alan Lau
        public Decimal motDiscountRate {get; set;} //20190110 Alan Lau
        public Boolean isMultiplePriceRecordForMOTPrice {get;set;} //20190111 Alan Lau
        public Boolean isMultiplePriceRecordForMOTPromotionPrice {get;set;} //20190111 Alan Lau
    }
    
    public virtual class ASI_HK_CRM_SKU {
        public String uom { get; set; }
        public Decimal qty { get; set; }
        public String id { get; set; }
        public String code { get; set; }
        public String remark { get; set; }
        public String name { get; set; }
        public Decimal buyX { get; set; }
        public Decimal getY { get; set; }
        Public String promotionCodeID { get; Set; }
        public String promotionCodeName { get; set; }
        Public String promotionExpirationDate { get; set; }
        public String unitPriceSource { get; set; }
        public Decimal qty9Lfactor { get; set; }
        public String subBrandId { get; set; }
        public String subBrandLabel { get; set; }
        public string packaging { get; set; }
        public Decimal price { get; set; }
        public Decimal inventory { get; set; }
        public String brandType { get; set; }
        public Decimal stdNum { get; set; }     //Std. Bottle Size
        public String dummy { get; set; }
        public Decimal pack { get; set; }
        public Decimal sequence { get; set; }
        public string itemGroupCode { get; set; }
        Public String effectiveDateTo { get; set; }//20161112 Elufa
        Public Boolean hasAllocation { get; set; }//20170205 Elufa
        Public String allocatedQty_BT {get; set;}//20170527 Introv
        Public String allocatedQty_CA {get; set;}//20170527 Introv
        public Decimal motPriceWithoutVAT {get; set;} //20181101 Alan Lau
        public Decimal motPromotionPriceWithoutVAT {get; set;} //20181101 Alan Lau
        public Decimal motDiscountAmount {get; set;} //20181101 Alan Lau
        public Decimal motDiscountRate {get; set;} //20190110 Alan Lau
        public Boolean isMultiplePriceRecordForMOTPrice {get;set;} //20190111 Alan Lau
        public Boolean isMultiplePriceRecordForMOTPromotionPrice {get;set;} //20190111 Alan Lau
    }
    
    public class ASI_HK_CRM_NormalProduct extends ASI_HK_CRM_SKU {
    }
    
    public class ASI_HK_CRM_POSProduct extends ASI_HK_CRM_SKU {
    }
    
    public class ASI_HK_CRM_DataTableServerInput {
        public String name;
        public Object value;
    }
    
    public class ASI_HK_CRM_SaveResult {
        public Boolean success { get; set; }
        public List<String> messages { get; set; }
        
        public ASI_HK_CRM_SaveResult() {
            this.messages = new List<String>();
        }
    }
}
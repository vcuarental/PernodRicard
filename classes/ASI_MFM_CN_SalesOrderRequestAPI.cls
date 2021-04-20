@RestResource(urlMapping='/ASI_MFM_CN_SalesOrderRequest_API/*')
global without sharing class ASI_MFM_CN_SalesOrderRequestAPI
{
    private static Set<String> customerRTSet = new Set<String>{
        'ASI_CRM_Outlet_CN'
        , 'ASI_CRM_CN_Prospect'
        , 'ASI_CRM_CN_WS'
    };

    private static Set<String> productRTSet = new Set<String>{
        'ASI_CRM_CN_Delivery_Zone_Sales_Order'
        , 'ASI_FOC_CN_Delivery_Zone'
        , 'ASI_MFM_CN_POSM'
    };

    private static ID salesOrderTRID = Global_RecordTypeCache.getRtID('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder');
    private static ID salesOrderItemTRID = Global_RecordTypeCache.getRtID('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item');

    global class APIResponse {
        public ASI_KOR_Sales_Order_Request__c salesOrder;
        public List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItem;
        public String errorMessage;
    }

    public virtual class ASI_HK_CRM_SKU
    {
        public String uom { get; set; }
        public Decimal qty { get; set; }
        public String id { get; set; }
        public String code { get; set; }
        public String remark { get; set; }
        public String name { get; set; }
        public Decimal buyX { get; set; }
        public Decimal getY { get; set; }
        public String promotionCodeID { get; set; }
        public String promotionCodeName { get; set; }
        public String promotionExpirationDate { get; set; }
        public String unitPriceSource { get; set; }
        public Decimal qty9Lfactor { get; set; }
        public String subBrandId { get; set; }
        public String subBrandLabel { get; set; }
        public string packaging { get; set; }
        public Decimal price { get; set; }
        public Decimal inventory { get; set; }
        public String brandType { get; set; }
        public Decimal stdNum { get; set; }
        public String dummy { get; set; }
        public Decimal pack { get; set; }
        public Decimal sequence { get; set; }
        public string itemGroupCode { get; set; }
        public String effectiveDateTo { get; set; }
        public Boolean hasAllocation { get; set; }
        public String allocatedQty_BT { get;set; }
        public String allocatedQty_CA { get;set; }
        public Decimal motPriceWithoutVAT {get; set; }
        public Decimal motPromotionPriceWithoutVAT { get;set; }
        public Decimal motDiscountAmount { get;set; }
        public Decimal motDiscountRate { get;set; }
        public Boolean isMultiplePriceRecordForMOTPrice { get;set; }
        public Boolean isMultiplePriceRecordForMOTPromotionPrice { get;set; }
    }
    
    public class ASI_HK_CRM_NormalProduct extends ASI_HK_CRM_SKU {}
    
    @HttpPost
    global static APIResponse createSalesOrderRequest()
    {
        Date todayDate = Date.today();
        APIResponse response = new APIResponse();
        Map<String, Object> reqMap;
        Map<String, Object> salesOrder;
        
        try
        {
            String jsonStr = RestContext.request.requestBody.toString();
            reqMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
            salesOrder = (Map<String, Object>)reqMap.get('salesOrder');
        }
        catch (Exception e)
        {
            response.errorMessage = e.getMessage();//'Invalid request';
            return response;
        }

        if (salesOrder == null)
        {
            response.errorMessage = 'No header found';
            return response;
        }

        List<ASI_KOR_Sales_Order_Request__c> insertSalesOrder = new List<ASI_KOR_Sales_Order_Request__c>();
        List<ASI_KOR_Sales_Order_Transaction__c> insertSalesOrderItem = new List<ASI_KOR_Sales_Order_Transaction__c>();

        String customerCode = (String)salesOrder.get('customerCode');
        ASI_CRM_AccountsAdditionalField__c customer;

        for (ASI_CRM_AccountsAdditionalField__c cust : [
            select ID, Name, ASI_CRM_CN_Is_IHBR_Outlet__c
            from ASI_CRM_AccountsAdditionalField__c
            where RecordType.DeveloperName in :customerRTSet
            and ASI_CRM_CN_CRM_Code__c = :customerCode
            limit 1
        ])
        {
            customer = cust;
        }

        if (customer == null)
        {
            response.errorMessage = 'Customer not found';
            return response;
        }

        String uom = (String)salesOrder.get('uom');
        String contactPerson = (String)salesOrder.get('contactPerson');
        String requirement = (String)salesOrder.get('requirement');
        Date requestDate = Date.valueOf((String)salesOrder.get('requestDate'));
        String phone = (String)salesOrder.get('phone');
        String address = (String)salesOrder.get('address');
        Boolean premium = (Boolean)salesOrder.get('premium');
        Boolean rtd = (Boolean)salesOrder.get('rtd');
        String email = (String)salesOrder.get('email');		//20191216:AM@introv - fix China owner issue

        if (uom != '' && uom != null && uom != 'BT' && uom != 'CA')
        {
            response.errorMessage = 'Invalid UOM';
            return response;
        }
        
        //20191216:AM@introv - fix China owner issue start
        if (email == '' || email == NULL)
        {
            response.errorMessage = 'Invalid Email';
            return response;
        }
        User oUser;
        for (User oTmpUser : [
            SELECT ID, Name
            FROM User
            WHERE Email = :email
            LIMIT 1
        ])
        {
            oUser = oTmpUser;
        }

        if (oUser == null)
        {
            response.errorMessage = 'Owner not found';
            return response;
        }
        //20191216:AM@introv - fix China owner issue end

        ASI_KOR_Sales_Order_Request__c newSO = new ASI_KOR_Sales_Order_Request__c();
        newSO.RecordTypeId = salesOrderTRID;
        newSO.OwnerId = oUser.Id;			//20191216:AM@introv - fix China owner issue
        newSO.ASI_KOR_Order_Status__c = 'Open';
        newSO.ASI_CRM_CN_Customer__c = customer.ID;
        newSO.ASI_CRM_UOM__c = uom;
        newSO.ASI_CRM_CN_Contact_Person__c = contactPerson;
        newSO.ASI_CRM_CN_Other_Requirement__c = requirement;
        newSO.ASI_KOR_Requested_Date__c = requestDate;
        newSO.ASI_CRM_CN_Tel_Mobile__c = phone;
        newSO.ASI_CRM_CN_Address__c = address;
        newSO.ASI_CRM_CN_Premium__c = premium;
        newSO.ASI_CRM_CN_RTD__c = rtd;

        try
        {
            insert newSO;
        }
        catch (Exception e)
        {
            response.errorMessage = 'SO Header: ' + e.getMessage();
            return response;
        }
        
        List<ASI_HK_CRM_NormalProduct> productList = getProductList(newSO.ID, newSO);
        response.salesOrder = newSO;

        List<Object> items = (List<Object>)reqMap.get('salesOrderItem');
        List<ASI_KOR_Sales_Order_Transaction__c> newSOIList = new List<ASI_KOR_Sales_Order_Transaction__c>();

        for (Object si : items)
        {
            Map<String, Object> item = (Map<String, Object>)si;
            String productCode = (String)item.get('productCode');
            String itemUom = (String)item.get('uom');
            Decimal qty = (Decimal)item.get('qty');

            if (productCode == null)
            {
                response.errorMessage = 'No product selected';
                return response;
            }
            else if (itemUom != '' && itemUom != null && itemUom != 'BT' && itemUom != 'CA')
            {
                response.errorMessage = 'Invalid UOM';
                return response;
            }
            else if (qty <= 0)
            {
                response.errorMessage = 'Please input quantity';
                return response;
            }

            ASI_HK_CRM_NormalProduct product = getProduct(productList, productCode);

            if (product == null)
            {
                response.errorMessage = 'Product not found';
                return response;
            }

            ASI_KOR_Sales_Order_Transaction__c newSOI = new ASI_KOR_Sales_Order_Transaction__c();
            newSOI.RecordTypeId = salesOrderItemTRID;
            newSOI.ASI_KOR_Sales_Order_Request__c = newSO.ID;
            newSOI.ASI_CRM_CN_Product_Name__c = product.id;
            newSOI.ASI_KOR_Order_Qty__c = qty;
            
            //20201012:AM@introv - fix issue of missing UOM
            //newSOI.ASI_CRM_UOM_Text__c = uom;
            newSOI.ASI_CRM_UOM_Text__c = itemUom;
            
            newSOI.ASI_CRM_MOT_Price_non_VAT__c = product.motPriceWithoutVAT;
            newSOI.ASI_CRM_MOT_Promotion_Price_non_VAT__c = product.motPromotionPriceWithoutVAT;
            newSOIList.add(newSOI);
        }

        if (newSOIList.size() > 0)
        {
            try
            {
                insert newSOIList;    
            }
            catch (Exception e)
            {
                response.errorMessage = 'SO Item: ' + e.getMessage();
                return response;
            }

            response.salesOrderItem = getSalesOrderItem(newSO.ID);
        }

        return response;
    }

    private static List<ASI_HK_CRM_NormalProduct> getProductList(ID soID, ASI_KOR_Sales_Order_Request__c newSO)
    {
        Date todayDate = Date.today();
        Date startDate;
        Date endDate;
        
        Map<String, ASI_CRM_Item_Group_Allocation__c> allocationMap = new Map<String, ASI_CRM_Item_Group_Allocation__c>();
        Map<id, id> mapOrderForm = new Map<id, id>();
        List<ASI_CRM_Order_Form_Customer_Relationship__c> ofcrList;
        
        ASI_KOR_Sales_Order_Request__c soHeader = [
            SELECT Id
            , ASI_CRM_UOM__c
            , ASI_CRM_CN_Customer__c
            , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c
            , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Order_by_BT__c
            , ASI_CRM_CN_RTD__c ,ASI_CRM_CN_Premium__c 
            , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
            , ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__r.Name
            , ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
            , ASI_CRM_SG_Order_Date__c
            , ASI_CRM_CN_Customer__r.ASI_CRM_CN_NewChannel__c
            , ASI_CRM_CN_Customer__r.ASI_CRM_CN_Region__c
            FROM ASI_KOR_Sales_Order_Request__c WHERE Id = : soID
        ];
        newSO = soHeader;
        
        startDate = date.newInstance(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month(), 1);
        endDate = date.newInstance(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month(), date.daysInMonth(soHeader.ASI_CRM_SG_Order_Date__c.year(), soHeader.ASI_CRM_SG_Order_Date__c.month()));
        
        for(ASI_CRM_Item_Group_Allocation__c allocationItem : [SELECT id
                                                               , ASI_CRM_Allocation_Quantity_Bottle__c
                                                               , ASI_CRM_Item_Group__c
                                                               , ASI_CRM_MTD_Order_Quantity__c
                                                               , ASI_CRM_MTD_Order_Quantity_CA__c
                                                               , ASI_CRM_Remaining_Qty_BT__c
                                                               , ASI_CRM_Remaining_Qty_CA__c
                                                                , ASI_CRM_Commercial_Team__c
                                                                , ASI_CRM_Region__c
                                                                , ASI_CRM_Region__r.Name
                                                                , ASI_CRM_Channel__c
                                                                , ASI_CRM_Customer__c
                                                               FROM ASI_CRM_Item_Group_Allocation__c
                                                               WHERE ASI_CRM_Effective_Date__c >= : startDate
                                                               AND ASI_CRM_Effective_Date__c <= : endDate
                                                               AND ASI_CRM_Commercial_Team__c = : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Commercial_Team__c
                                                               AND ASI_CRM_Region__c = : soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
															   AND recordType.developerName Like '%_CN_%'
                                                            ])
                                                            {
                                                                String key = allocationItem.ASI_CRM_Item_Group__c + '_'
                                                                        + allocationItem.ASI_CRM_Commercial_Team__c + '_'
                                                                        + allocationItem.ASI_CRM_Region__r.Name + '_'
                                                                        + allocationItem.ASI_CRM_Channel__c + '_'
                                                                        + allocationItem.ASI_CRM_Customer__c;
                                                                system.debug('normalProductList allocation map key:' + key);
                                                                allocationMap.put(key, allocationItem);
                                                            }
        
        if(soHeader.ASI_CRM_CN_RTD__c == TRUE)
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='RTD' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        else if(soHeader.ASI_CRM_CN_Premium__c == TRUE)
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='Premium' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        else
            ofcrList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id, ASI_CRM_Customer__c, ASI_CRM_Order_Form__c FROM ASI_CRM_Order_Form_Customer_Relationship__c WHERE ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c ='Normal Item' AND ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c AND RecordType.DeveloperName = 'ASI_CRM_CN_Order_Form_Customer_Relationship']);
        
        for(ASI_CRM_Order_Form_Customer_Relationship__c obj : ofcrList)
            mapOrderForm.put(obj.ASI_CRM_Customer__c, obj.ASI_CRM_Order_Form__c);
        
        List<ASI_CRM_Order_Form_Detail__c> ofList = new List<ASI_CRM_Order_Form_Detail__c>([SELECT id, ASI_CRM_Product_Name__c, ASI_CRM_Sequence__c, ASI_CRM_Remark__c FROM ASI_CRM_Order_Form_Detail__c WHERE ASI_CRM_Order_Form__c =: mapOrderForm.get(soHeader.ASI_CRM_CN_Customer__c)]);
        Map<id, ASI_CRM_Order_Form_Detail__c> mapOrderFormRemark = new Map<id, ASI_CRM_Order_Form_Detail__c>();
        Set<ID> itemGroupID = new Set<id>();
        for(ASI_CRM_Order_Form_Detail__c obj : ofList){
            itemGroupID.add(obj.ASI_CRM_Product_Name__c);
            mapOrderFormRemark.put(obj.ASI_CRM_Product_Name__c, obj);
        }
        
        List<ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomerPrice = new List<ASI_CRM_Item_Group_Customer_Price__c>([
            SELECT ASI_CRM_Customer__c
            , ASI_CRM_Item_Group__c
            , ASI_CRM_Price_Type__c
            , ASI_CRM_Promotion_Code__c
            , ASI_CRM_Promotion_Expiration_Date__c
            , ASI_CRM_Unit_Price_BT__c
            , ASI_CRM_Promotion_Code__r.Name
            , ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c
            , ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c
            , ASI_CRM_Effective_Date_To__c
            FROM ASI_CRM_Item_Group_Customer_Price__c WHERE ASI_CRM_Customer__c = : soHeader.ASI_CRM_CN_Customer__c//ASI_CRM_Promotion_Expiration_Date__c >=: todayDate
        ]);
        
        Map<String, ASI_CRM_Item_Group_Customer_Price__c> mapPromotionCode = new Map<String, ASI_CRM_Item_Group_Customer_Price__c>();
        Map<String, ASI_CRM_Item_Group_Customer_Price__c> mapCustomerPrice = new Map<String, ASI_CRM_Item_Group_Customer_Price__c>();
        Set<id> ihbrItemGroup = new Set<id>();
        
        for(ASI_CRM_Item_Group_Customer_Price__c obj : itemGroupCustomerPrice){
            if (obj.ASI_CRM_Promotion_Expiration_Date__c >= todayDate)
                mapPromotionCode.put(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c, obj);
            
            mapCustomerPrice.put(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Item_Group__c, obj);
            ihbrItemGroup.add(obj.ASI_CRM_Item_Group__c);
        }
        
        List<ASI_HK_CRM_NormalProduct> result = new List<ASI_HK_CRM_NormalProduct>();
        List<ASI_MFM_Item_Group__c> skuList = new List<ASI_MFM_Item_Group__c>();
        
        if(!soHeader.ASI_CRM_CN_Customer__r.ASI_CRM_CN_Is_IHBR_Outlet__c){
            skuList = [SELECT Id, Name, ASI_CRM_CN_pack__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                       , ASI_CRM_CN_BT_Size_C__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name, ASI_CRM_CN_Converion9L_C__c
                       , ASI_CRM_CN_Pack_Value__c, ASI_MFM_Item_Group_Code__c
                       , ASI_CRM_Allocation_Information__c
                       FROM ASI_MFM_Item_Group__c
                       WHERE ID IN : itemGroupID
                       ORDER BY Name
                      ];
        }
        else
        {
            List<ASI_MFM_SKU_Code__c> tmpSKU = new List<ASI_MFM_SKU_Code__c>([SELECT ASI_MFM_Item_Group__c FROM ASI_MFM_SKU_Code__c 
                                                                              WHERE ASI_MFM_Item_Group__c IN : ihbrItemGroup 
                                                                              AND (ASI_CRM_SKU_Status__c LIKE '%000%' OR ASI_CRM_SKU_Status__c LIKE '%001%' OR ASI_CRM_SKU_Status__c LIKE '%997%')]);
            
            Set<Id> ihbrItemGroup2 = new Set<Id>();
            for (ASI_MFM_SKU_Code__c obj : tmpSKU)
                ihbrItemGroup2.add(obj.ASI_MFM_Item_Group__c);

            skuList = [SELECT Id, Name, ASI_CRM_CN_pack__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                       , ASI_CRM_CN_BT_Size_C__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name, ASI_CRM_CN_Converion9L_C__c
                       , ASI_CRM_CN_Pack_Value__c, ASI_MFM_Item_Group_Code__c
                       , ASI_CRM_Allocation_Information__c
                       FROM ASI_MFM_Item_Group__c
                       WHERE ID IN : ihbrItemGroup2
                       ORDER BY Name
                      ];
        }

        List<Id> itemGroupIdList = getSkuIdList(skuList);
        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMapForMOTPrice = createLineItemPriceAndDiscountDetailMap(itemGroupIdList, soHeader, 'Contract Price'); //20181109 Alan Lau
        Map<Id, Decimal> skuPriceWithoutVATMapForMOTPrice = createSKUPriceWithoutVATMap(itemGroupIdList, lineItemPriceAndDiscountDetailMapForMOTPrice); //20181109 Alan Lau

        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMapForMOTPromotionPrice = createLineItemPriceAndDiscountDetailMap(itemGroupIdList, soHeader, 'Promotion Price'); //20190110 Alan Lau
        Map<Id, Decimal> skuPriceWithoutVATMapForMOTPromotionPrice = createSKUPriceWithoutVATMap(itemGroupIdList, lineItemPriceAndDiscountDetailMapForMOTPromotionPrice); //20190110 Alan Lau
        
		Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecordForMOTPrice = getMapOfLineItemToIsNotSinglePriceRecord(itemGroupIdList, soHeader, 'Contract Price'); //20190111 Alan Lau
        Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecordForMOTPromotionPrice = getMapOfLineItemToIsNotSinglePriceRecord(itemGroupIdList, soHeader, 'Promotion Price'); //20190111 Alan Lau

        for (ASI_MFM_Item_Group__c sku : skuList)
        {
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
            pd.price = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id) ? ( mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Unit_Price_BT__c * 1.13 ).setScale(3) : null; //20180426 Introv changed Tax Rate From 17% to 16%//20190415 Laputa Andy changed Tax Rate from 16% to 13%
            pd.unitPriceSource = pd.price != null ? mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Price_Type__c : null ;
            pd.buyX = pd.promotionCodeID != null ? mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c : null;
            pd.getY = pd.promotionCodeID != null ? mapPromotionCode.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c : null;
            pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
            pd.subBrandLabel = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
            pd.inventory = null;
            pd.itemGroupCode = sku.ASI_MFM_Item_Group_Code__c;
            pd.effectiveDateTo = mapCustomerPrice.containsKey(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id) && mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Effective_Date_To__c != Null ? mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Effective_Date_To__c.year() + '-' + mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Effective_Date_To__c.month() + '-' + mapCustomerPrice.get(soHeader.ASI_CRM_CN_Customer__c + '' + sku.id).ASI_CRM_Effective_Date_To__c.day() : Null;
            
            String Name = '';
            
            if (sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name != Null && sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name != '')
            {
                if (sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name.contains('\''))
                {    
                    String[] splittedName = sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name.split('\'');

                    for (integer i = 0 ; i < splittedName.size() ; i ++)
                    {    
                        Name += splittedName[i];
                    }
                }
                else
                {
                    Name = sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name;
                }
            }
            
            pd.brandType = Name;
            pd.packaging = sku.ASI_CRM_CN_pack__c;
            pd.pack = sku.ASI_CRM_CN_Pack_Value__c != NULL ? sku.ASI_CRM_CN_Pack_Value__c : 0;
            pd.stdNum = null;
            pd.dummy = null;
            pd.hasAllocation = sku.ASI_CRM_Allocation_Information__c;

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

            pd.motPriceWithoutVAT = skuPriceWithoutVATMapForMOTPrice.containsKey(sku.Id) ? skuPriceWithoutVATMapForMOTPrice.get(sku.Id).setScale(4) : null; //20181109 Alan Lau
            pd.motPromotionPriceWithoutVAT = skuPriceWithoutVATMapForMOTPromotionPrice.containsKey(sku.Id) ? skuPriceWithoutVATMapForMOTPromotionPrice.get(sku.Id).setScale(4) : null; //20190110 Alan Lau
			pd.motDiscountAmount = (pd.motPriceWithoutVAT != null && pd.motPromotionPriceWithoutVAT != null) ? (pd.motPromotionPriceWithoutVAT - pd.motPriceWithoutVAT).setScale(4) : null;
            pd.motDiscountRate = (pd.motDiscountAmount != null && pd.motPriceWithoutVAT != null) ? ((pd.motDiscountAmount / pd.motPriceWithoutVAT) * 100).setScale(2) : null;
            pd.isMultiplePriceRecordForMOTPrice = mapOfLineItemToIsNotSinglePriceRecordForMOTPrice.get(sku.Id);
            pd.isMultiplePriceRecordForMOTPromotionPrice = mapOfLineItemToIsNotSinglePriceRecordForMOTPromotionPrice.get(sku.Id);

            result.add(pd);
        }

        return result;
    }

    private static ASI_HK_CRM_NormalProduct getProduct(List<ASI_HK_CRM_NormalProduct> productList, String code)
    {
        ASI_HK_CRM_NormalProduct product;

        for (ASI_HK_CRM_NormalProduct p : productList)
        {
            if (p.itemGroupCode == code)
            {
                product = p;
            }
        }

        return product;
    }

    private static List<Id> getSkuIdList(List<ASI_MFM_Item_Group__c> skuList)
    {
        List<Id> skuIdList = new List<Id>();

        for (ASI_MFM_Item_Group__c sku : skuList)
        {
            skuIdList.add(sku.Id);
        }

        return skuIdList;
    }

    private static Map<Id, ASI_CRM_Price_And_Discount_Detail__c> createLineItemPriceAndDiscountDetailMap(List<Id> itemGroupIdList, ASI_KOR_Sales_Order_Request__c salesOrderHeader, String priceType)
    {
        Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMap = new Map<Id, ASI_CRM_Price_And_Discount_Detail__c>();

        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = getPriceAndDiscountDetailList(salesOrderHeader, itemGroupIdList, priceType);

        for (string itemGroupId : itemGroupIdList)
        {
            for (ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail : priceAndDiscountDetailList)
            {
                if (priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c == itemGroupId)
                {
                    lineItemPriceAndDiscountDetailMap.put(itemGroupId, priceAndDiscountDetail);
                    break;
                }
            }
        }

        return lineItemPriceAndDiscountDetailMap;
    }

    private static List<ASI_CRM_Price_And_Discount_Detail__c> getPriceAndDiscountDetailList(ASI_KOR_Sales_Order_Request__c salesOrderHeader, List<String> lineItemProductNameList, String priceType)
    {
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

    private static Map<Id, Boolean> getMapOfLineItemToIsNotSinglePriceRecord(List<string> itemGroupIdList, ASI_KOR_Sales_Order_Request__c salesOrderHeader, String priceType)
    {
        Map<Id, Boolean> mapOfLineItemToIsNotSinglePriceRecord = new Map<Id, Boolean>();
        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = getPriceAndDiscountDetailList(salesOrderHeader, itemGroupIdList, priceType);

        Map<String, Boolean> mapOfItemGroupDescriptionToIsNotSingleRecord = new Map<String, Boolean>();
        for (ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail : priceAndDiscountDetailList)
        {
            if (mapOfItemGroupDescriptionToIsNotSingleRecord.containsKey(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c))
            {
                mapOfItemGroupDescriptionToIsNotSingleRecord.put(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c, true);
            }
            else
            {
                mapOfItemGroupDescriptionToIsNotSingleRecord.put(priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c, false);
            }
        }

        for (string itemGroupId : itemGroupIdList)
        {
            if (mapOfItemGroupDescriptionToIsNotSingleRecord.containsKey(itemGroupId))
            {
                mapOfLineItemToIsNotSinglePriceRecord.put(itemGroupId, mapOfItemGroupDescriptionToIsNotSingleRecord.get(itemGroupId));
            }
            else
            {
                mapOfLineItemToIsNotSinglePriceRecord.put(itemGroupId, false);
            }
        }

        return mapOfLineItemToIsNotSinglePriceRecord;
    }

    private static Map<Id, Decimal> createSKUPriceWithoutVATMap(List<Id> itemGroupIdList, Map<Id, ASI_CRM_Price_And_Discount_Detail__c> lineItemPriceAndDiscountDetailMap)
    {
        Map<Id, Decimal> skuPriceWithoutVATMap = new Map<Id, Decimal>();

        for (string itemGroupId : itemGroupIdList)
        {
            if (lineItemPriceAndDiscountDetailMap.containsKey(itemGroupId))
            {
                skuPriceWithoutVATMap.put(itemGroupId, lineItemPriceAndDiscountDetailMap.get(itemGroupId).ASI_CRM_New_Price_BT_non_VAT__c);
            }
        }

        return skuPriceWithoutVATMap;
    }

    private static List<ASI_KOR_Sales_Order_Transaction__c> getSalesOrderItem(ID soID)
    {
        List<ASI_KOR_Sales_Order_Transaction__c> soiList = [
            select ID, Name, ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__c, ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__r.Name,
            ASI_CRM_CN_Product_Name__c, ASI_CRM_CN_Remark__c, ASI_CRM_CN_Product_Name__r.Name, ASI_KOR_Order_Qty__c, ASI_CRM_CN_Logistics_Remark__c,
            ASI_CRM_CN_Product_Name__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name, ASI_CRM_CN_UOM__c, ASI_CRM_CN_Promotion_Code__c,
            ASI_CRM_CN_Promotion_Code__r.Name, ASI_CRM_CN_Promotion_Expiration_Date__c, ASI_CRM_CN_Unit_Price_BT_with_VAT__c, 
            ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Converion9L_C__c, ASI_CRM_CN_Unit_Price_Source__c, ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Buy_X__c,
            ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Get_Y__c, ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c, ASI_CRM_CN_Product_Name__r.ASI_MFM_Item_Group_Code__c,
            ASI_CRM_CN_Product_Name__r.ASI_CRM_Allocation_Information__c,
            ASI_CRM_MOT_Price_non_VAT__c, ASI_CRM_MOT_Promotion_Price_non_VAT__c, ASI_CRM_MOT_Discount_Amount__c
            from ASI_KOR_Sales_Order_Transaction__c
            where ASI_KOR_Sales_Order_Request__c = :soID
        ];

        return soiList;
    }
}
public without sharing class ASI_HK_CRM_SalesOrderRequestDtEdCON {
//Version 0.0.1
//Last modified: 20130813 00:32
    
    //The SalesOrderItem do not allow to added if not within this range
    private static final Set<String> STATUS_ALLOW_EDIT = new Set<String>{
        'Draft',
        'SA Rejected',
        'Supervisor Rejected'
    };
    // TODO: Centralize the record type developer names
    private static final String RTDEVNAME_SKU = 'ASI_HK_CRM_SKU';
    private static final String RTDEVNAME_SB = ASI_HK_CRM_SubBrandGenerator.RT_Default;
    private static final String RTDEVNAME_CUST_PD_PRICE = 'ASI_HK_CRM_Customer_Product_Price';
    private static final Set<String> RTDEVNAME_ACCT_HAVE_CUST_PRICE = ASI_HK_CRM_AccountGenerator.RTDEVNAME_ACCT_HAVE_CUST_PRICE;
    private static final Set<String> RTDEVNAME_ACCT_IS_HK_LUX = ASI_HK_CRM_AccountGenerator.RTDEVNAME_ACCT_IS_HK_LUX ;
    
    private static final String ACCT_TYPE_EXIST = 'exist';
    private static final String ACCT_TYPE_POTENTIAL = 'potential';
    
    public String soHeaderId { get; private set; }
    public String acctId { get; private set; }
    public String acctDAId { get; private set; }  //Get DA Account Abel
    public String pageTitle { get; private set; }
    public Boolean allowEdit { get; private set; }
    public String ACCT_TYPE_EXIST_DISPLAY { get { return ACCT_TYPE_EXIST; } private set; }
    public String ACCT_TYPE_POTENTIAL_DISPLAY { get { return ACCT_TYPE_POTENTIAL; } private set; }
    public String acctType { get; private set; }
    public Boolean useCustPrice { get; private set; }
    public List<List<String>> sbSearchOptionsNormal { get; set; }
    public List<List<String>> sbSearchOptionsPOS { get; set; }
    
    private ASI_HK_CRM_Sales_Order__c soHeader;
    
    public ASI_HK_CRM_SalesOrderRequestDtEdCON(ApexPages.StandardSetController stdSetController) {
        this.allowEdit = true;
        this.soHeaderId = ApexPages.currentPage().getParameters().get('id');
        this.soHeader = [SELECT Id, ASI_HK_CRM_Account_PA__c, ASI_HK_CRM_Account_PA__r.RecordType.DeveloperName,ASI_HK_CRM_Customer_DA__c,ASI_HK_CRM_Account_PA__r.ASI_HK_CRM_JDE_Account_Number__c, ASI_HK_CRM_Customer_DA__r.Name, ASI_HK_CRM_Order_Status_Name__c, (SELECT Id, ASI_HK_CRM_SKU__c FROM ASI_HK_CRM_Sales_Order_Request_Items__r) FROM ASI_HK_CRM_Sales_Order__c WHERE Id = :soHeaderId];
        for(String str: STATUS_ALLOW_EDIT){
            System.debug('adk1'+str);
        }
        System.debug('adk2'+soHeader.ASI_HK_CRM_Order_Status_Name__c);

        if (this.soHeader.ASI_HK_CRM_Order_Status_Name__c == null || !STATUS_ALLOW_EDIT.contains(this.soHeader.ASI_HK_CRM_Order_Status_Name__c)) {
            this.allowEdit = false;
            showPageError('You are not allowed to edit the line items for current status');
        }
        this.acctId = soHeader.ASI_HK_CRM_Account_PA__c;
        this.acctDAId = soHeader.ASI_HK_CRM_Customer_DA__c;    //Changed by Abel version 0.0.1 Retrieve customer_DA
        System.debug('fky2'+soHeader.ASI_HK_CRM_Account_PA__r.RecordType.DeveloperName);
        this.pageTitle = soHeader.ASI_HK_CRM_Customer_DA__c != null ? soHeader.ASI_HK_CRM_Customer_DA__r.Name : null;
        this.useCustPrice = soHeader.ASI_HK_CRM_Account_PA__c != null && (RTDEVNAME_ACCT_HAVE_CUST_PRICE.contains(soHeader.ASI_HK_CRM_Account_PA__r.RecordType.DeveloperName) || (RTDEVNAME_ACCT_IS_HK_LUX.contains(soHeader.ASI_HK_CRM_Account_PA__r.RecordType.DeveloperName) && soHeader.ASI_HK_CRM_Account_PA__r.ASI_HK_CRM_JDE_Account_Number__c != ''));
        for( String str: RTDEVNAME_ACCT_HAVE_CUST_PRICE){
            System.debug('fky1'+str);
        }
        for( String str: RTDEVNAME_ACCT_IS_HK_LUX){
            System.debug('fky1'+str);
        }
        System.debug('fky6'+useCustPrice);
        
        this.acctType = this.useCustPrice ? ACCT_TYPE_EXIST : ACCT_TYPE_POTENTIAL;
        this.sbSearchOptionsNormal = getSubBrandSearchOptions();
        this.sbSearchOptionsPOS = sbSearchOptionsNormal;
    }
     
    //Retrieve the SOLineItem under the SO 
    @RemoteAction
    public static List<ASI_HK_CRM_SOLineItem> lineItemList(ID headerId) {
        List<ASI_HK_CRM_SOLineItem> result = new List<ASI_HK_CRM_SOLineItem>();
        List<ASI_HK_CRM_Sales_Order_Item__c> lineItems = [
            SELECT Id, Name, ASI_HK_CRM_Sales_Order__c
                , ASI_HK_CRM_SKU__c, ASI_HK_CRM_SKU__r.Name, ASI_HK_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c, ASI_HK_CRM_SKU__r.ASI_HK_CRM_IsPOSProduct__c
                , ASI_HK_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_HK_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name, ASI_HK_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                , ASI_HK_CRM_Quantity__c, ASI_HK_CRM_UOM__c, ASI_HK_CRM_Price__c
                , ASI_HK_CRM_Amount__c
                , ASI_HK_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c
                , ASI_HK_CRM_SKU_Code__c//20151223
                , ASI_HK_CRM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c //20160411, added by Leo
                , ASI_HK_CRM_SKU__r.ASI_MFM_Item_Group__c,ASI_HK_CRM_SKU__r.ASI_MFM_Item_Group__r.Name //20180507
                , ASI_HK_CRM_Reserve_Stock_No__c  //20180731, by Introv Kelvin
                , ASI_CRM_Request_Release_Qty__c  //20180904, by Wilken
                , ASI_HK_CRM_EDI_Price__c   //20180731, by Introv Kelvin
                , ASI_HK_CRM_Price_Exception__c   //20180731, by Introv Kelvin
            FROM ASI_HK_CRM_Sales_Order_Item__c
            WHERE ASI_HK_CRM_Sales_Order__c = :headerId
        ];
        
        for (ASI_HK_CRM_Sales_Order_Item__c li : lineItems) {
            ASI_HK_CRM_SOLineItem tempLi = new ASI_HK_CRM_SOLineItem();
            tempLi.id = li.Id;
            tempLi.skuId = li.ASI_HK_CRM_SKU__c;
            tempLi.skuLabel = li.ASI_HK_CRM_SKU__c != null ? li.ASI_HK_CRM_SKU__r.Name : null;
            tempLi.skuInventory = li.ASI_HK_CRM_SKU__c != null ? li.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Available_Quantity__c : null;
            tempLi.subBrandId = li.ASI_HK_CRM_SKU__c != null ? li.ASI_HK_CRM_SKU__r.ASI_MFM_Sub_brand__c : null;
            tempLi.subBrandLabel = tempLi.subBrandId != null ? li.ASI_HK_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name : null;
            tempLi.brandType = tempLi.subBrandId != null ? li.ASI_HK_CRM_SKU__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c : null;
            tempLi.qty = li.ASI_HK_CRM_Quantity__c;
            tempLi.uom = li.ASI_HK_CRM_UOM__c; 
            tempLi.price = li.ASI_HK_CRM_Price__c;
            tempLi.amount = li.ASI_HK_CRM_Amount__c;
            tempLi.isPOS = li.ASI_HK_CRM_SKU__c != null ? li.ASI_HK_CRM_SKU__r.ASI_HK_CRM_IsPOSProduct__c == true : false;
            System.debug('ddk'+li.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c);
            tempLi.stdNum = li.ASI_HK_CRM_SKU__r.ASI_HK_CRM_Std_Bottle_Size__c;
            tempLi.skuCode = li.ASI_HK_CRM_SKU_Code__c;//20151223
            tempLi.igCode = li.ASI_HK_CRM_SKU__r.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c; //20160411, added by Leo
            tempLi.igId = (li.ASI_HK_CRM_SKU__c != null)? li.ASI_HK_CRM_SKU__r.ASI_MFM_Item_Group__c : null;  //20180511, by Introv
            tempLi.igName = (li.ASI_HK_CRM_SKU__c != null && li.ASI_HK_CRM_SKU__r.ASI_MFM_Item_Group__c != null)? li.ASI_HK_CRM_SKU__r.ASI_MFM_Item_Group__r.Name : null; //20180511, by Introv
            tempLi.src = li.ASI_HK_CRM_Reserve_Stock_No__c ; //20180731, by Introv Kelvin
            tempLi.requestReleaseQty = li.ASI_CRM_Request_Release_Qty__c ; //20180904, by Wilken
            tempLi.ediPrice = li.ASI_HK_CRM_EDI_Price__c ; //20180731, by Introv Kelvin
            tempLi.priceExcep = li.ASI_HK_CRM_Price_Exception__c ; //20180731, by Introv Kelvin
            result.add(tempLi);
        }        
            
        for (ASI_HK_CRM_SOLineItem str: result){ System.debug('kkl.5 Line Item List'+str); }
        return result;
    }
    
    @RemoteAction
    public static List<ASI_HK_CRM_NormalProduct> normalProductList(String custId, Boolean onlyCustPrice) {
        List<ASI_HK_CRM_NormalProduct> result = new List<ASI_HK_CRM_NormalProduct>();
        List<ASI_MFM_SKU_Code__c> skuList = [
            SELECT Id, Name, ASI_MFM_SKU_Code__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                , ASI_HK_CRM_Base_Price__c, ASI_HK_CRM_Available_Quantity__c, ASI_HK_CRM_Std_Bottle_Size__c
                , ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c //20160411, added by Leo
                , ASI_MFM_Item_Group__c,ASI_MFM_Item_Group__r.Name //20180507
            FROM ASI_MFM_SKU_Code__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_SKU AND ASI_HK_CRM_Active__c = TRUE
                AND ASI_HK_CRM_IsPOSProduct__c != TRUE
        ];
        Date todayDate = Date.today();
        List<ASI_HK_CRM_Customer_Product_Price__c> custPdPriceList = [
            SELECT Id, Name, ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_Bottle_Price__c, ASI_HK_CRM_Case_Price__c
            FROM ASI_HK_CRM_Customer_Product_Price__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_CUST_PD_PRICE AND ASI_HK_CRM_Customer_Name__c = :custId
              //  AND (ASI_HK_CRM_Effective_Date__c = NULL OR ASI_HK_CRM_Expiry_Date__c = NULL
              //      OR (ASI_HK_CRM_Effective_Date__c <= :todayDate AND ASI_HK_CRM_Expiry_Date__c >= :todayDate))
        ];
        Map<ID, ASI_HK_CRM_Customer_Product_Price__c> pdIdToCustPdPriceMap = new Map<ID, ASI_HK_CRM_Customer_Product_Price__c>();
        for (ASI_HK_CRM_Customer_Product_Price__c custPdPrice : custPdPriceList) {
            pdIdToCustPdPriceMap.put(custPdPrice.ASI_HK_CRM_SKU_Lookup__c, custPdPrice);
        }
        
        for (ASI_MFM_SKU_Code__c sku : skuList) {
            ASI_HK_CRM_Customer_Product_Price__c custPdPrice = pdIdToCustPdPriceMap.get(sku.Id);
            if (onlyCustPrice != true || custPdPrice != null) {
                ASI_HK_CRM_NormalProduct pd = new ASI_HK_CRM_NormalProduct();
                pd.id = sku.Id;
                pd.code = sku.ASI_MFM_SKU_Code__c;
                pd.name = sku.Name;
                pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
                pd.subBrandLabel = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
                pd.price = custPdPrice != null ? custPdPrice.ASI_HK_CRM_Bottle_Price__c : sku.ASI_HK_CRM_Base_Price__c;
                pd.inventory = sku.ASI_HK_CRM_Available_Quantity__c;
                pd.brandType = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c : null;
                pd.stdNum = sku.ASI_HK_CRM_Std_Bottle_Size__c;
                pd.dummy = null;
                pd.igCode = sku.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c; //20160411, added by Leo
                pd.igId = sku.ASI_MFM_Item_Group__c; //20180507
                pd.igName = sku.ASI_MFM_Item_Group__c != null ? sku.ASI_MFM_Item_Group__r.Name : ''; //20180507
                result.add(pd);
            }
        }
        for(ASI_HK_CRM_NormalProduct str2: result){
            System.debug('kkl.6 normal product list'+str2);
        }
        return result;
    }
    
    //POS Table
    @RemoteAction
    public static ASI_HK_CRM_DataTableServerResult posProductDataTableResult(List<ASI_HK_CRM_DataTableServerInput> dataTableInputs) {
        Integer skuCount = [
            SELECT COUNT() FROM ASI_MFM_SKU_Code__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_SKU AND ASI_HK_CRM_Active__c = TRUE AND ASI_HK_CRM_IsPOSProduct__c = TRUE
        ];
        System.debug('kkl8'+skuCount);
        Map<String, Object> dataTableInputMap = new Map<String, Object>();
        for (ASI_HK_CRM_DataTableServerInput input : dataTableInputs) {
            if (input.name != null)
                dataTableInputMap.put(input.name, input.value);
        }
        Integer limitNum = integerFromObject(dataTableInputMap.get('iDisplayLength'));
        Integer offsetNum = integerFromObject(dataTableInputMap.get('iDisplayStart'));
        String searchName = stringFromObject(dataTableInputMap.get('sSearch_1'));
        String subBrandStr = stringFromObject(dataTableInputMap.get('sSearch_2'));
        
        Set<String> queryFields = new Set<String> {
            'Id', 'Name', 'ASI_MFM_SKU_Code__c', 'ASI_MFM_Sub_brand__c', 'ASI_MFM_Sub_brand__r.Name'
            , 'ASI_HK_CRM_Base_Price__c', 'ASI_HK_CRM_Available_Quantity__c'
            , 'ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c' //20160411, added by Leo
            , 'ASI_MFM_Item_Group__c', 'ASI_MFM_Item_Group__r.Name' //20180507, by Introv
        };
        String baseWhereStatm = 'RecordType.DeveloperName = :RTDEVNAME_SKU AND ASI_HK_CRM_Active__c = TRUE AND ASI_HK_CRM_IsPOSProduct__c = TRUE';
        String filterWhereStatm = '';
        if (!String.isBlank(searchName)) {
            searchName = '%' + escapeSOQLLikeValue(searchName.trim()) + '%';
            if (filterWhereStatm != '') filterWhereStatm += ' AND';
            filterWhereStatm += ' Name LIKE :searchName';
        }
        if (!String.isBlank(subBrandStr)) {
            if (filterWhereStatm != '') filterWhereStatm += ' AND';
            if (subBrandStr.startsWith('_')) {
                subBrandStr = subBrandStr.substringBetween('_', '_');
                filterWhereStatm += ' ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c = :subBrandStr';
            } else {
                filterWhereStatm += ' ASI_MFM_Sub_brand__c = :subBrandStr';
            }
        }
        String whereStatm = filterWhereStatm != '' ? '(' + filterWhereStatm + ') AND (' + baseWhereStatm + ')' : baseWhereStatm;
        String skuSearchCountQueryStr = ASI_HK_CRM_CommonUtils.genQueryString(new Set<String>{'COUNT()'}, 'ASI_MFM_SKU_Code__c', whereStatm);
        Integer skuSearchCount = database.countQuery(skuSearchCountQueryStr);
        String extraQueryStr = '';
        if (limitNum != null) extraQueryStr += ' LIMIT :limitNum';
        if (offsetNum != null) extraQueryStr += ' OFFSET :offsetNum';
        String skuSearchQueryStr = ASI_HK_CRM_CommonUtils.genQueryString(queryFields, 'ASI_MFM_SKU_Code__c', whereStatm, extraQueryStr);
        List<ASI_MFM_SKU_Code__c> skuList = (List<ASI_MFM_SKU_Code__c>)database.query(skuSearchQueryStr);
        
        ASI_HK_CRM_DataTableServerResult result = new ASI_HK_CRM_DataTableServerResult();
        result.iTotalRecords = skuCount;
        result.iTotalDisplayRecords = skuSearchCount;
        result.sEcho = (Decimal)dataTableInputMap.get('sEcho');
        List<ASI_HK_CRM_POSProduct> pdList = new List<ASI_HK_CRM_POSProduct>();
        for (ASI_MFM_SKU_Code__c sku : skuList) {
            ASI_HK_CRM_POSProduct pd = new ASI_HK_CRM_POSProduct();
            pd.id = sku.Id;
            pd.code = sku.ASI_MFM_SKU_Code__c;
            pd.name = sku.Name;
            pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
            pd.subBrandLabel = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
            pd.price = sku.ASI_HK_CRM_Base_Price__c;
            pd.inventory = sku.ASI_HK_CRM_Available_Quantity__c;
            pd.igCode = sku.ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Code__c; //20160411, added by Leo
            pd.igId = sku.ASI_MFM_Item_Group__c; //20180507
            pd.igName = sku.ASI_MFM_Item_Group__c != null ? sku.ASI_MFM_Item_Group__r.Name : ''; //20180507
            pdList.add(pd);
        }
        result.aaData = pdList;
        for(ASI_HK_CRM_POSProduct res: pdList){
            System.debug('lab1'+res);
        }
        
        return result;
    }
    
    @RemoteAction
    public static ASI_HK_CRM_SaveResult saveChanges(String headerId, List<ASI_HK_CRM_SOLineItem> remoteLineItems) {
        ASI_HK_CRM_SaveResult result = new ASI_HK_CRM_SaveResult();
        result.success = false;
        
        try {
            if (isNonEmptyId(headerId)) {
                Map<ID, ASI_HK_CRM_Sales_Order_Item__c> existingLineItemMap = new Map<ID, ASI_HK_CRM_Sales_Order_Item__c>(
                (List<ASI_HK_CRM_Sales_Order_Item__c>)[
                    SELECT Id, LastModifiedDate
                    FROM ASI_HK_CRM_Sales_Order_Item__c
                    WHERE ASI_HK_CRM_Sales_Order__c = :headerId
                    FOR UPDATE
                ]);
                
                Set<ID> newIdSet = new Set<ID>();
                List<ASI_HK_CRM_Sales_Order_Item__c> insertLineItems = new List<ASI_HK_CRM_Sales_Order_Item__c>();
                List<ASI_HK_CRM_Sales_Order_Item__c> updateLineItems = new List<ASI_HK_CRM_Sales_Order_Item__c>();
                List<ASI_HK_CRM_Sales_Order_Item__c> deleteLineItems = new List<ASI_HK_CRM_Sales_Order_Item__c>();
                if (remoteLineItems != null) {
                    for (ASI_HK_CRM_SOLineItem remoteLineItem : remoteLineItems) {
                        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') {
                            ASI_HK_CRM_Sales_Order_Item__c lineItem = existingLineItemMap.get(remoteLineItem.id);
                            if (lineItem != null) {
                                updateLineItemFromRemote(lineItem, remoteLineItem);
                                updateLineItems.add(lineItem);
                                newIdSet.add(remoteLineItem.id);
                            } else {
                                result.messages.add(String.format('Line item with ID {0} is not found', new String[] {remoteLineItem.id}));
                                break;
                            }
                        } else {
                            ASI_HK_CRM_Sales_Order_Item__c lineItem = new ASI_HK_CRM_Sales_Order_Item__c();
                            updateLineItemFromRemote(lineItem, remoteLineItem);
                            lineItem.ASI_HK_CRM_Sales_Order__c = headerId;
                            insertLineItems.add(lineItem);
                        }
                    }
                }
                
                if (existingLineItemMap.size() != newIdSet.size()) {
                    for (ASI_HK_CRM_Sales_Order_Item__c existingLineItem : existingLineItemMap.values()) {
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
    private static void updateLineItemFromRemote(ASI_HK_CRM_Sales_Order_Item__c lineItem, ASI_HK_CRM_SOLineItem remoteLineItem) {
        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') lineItem.Id = remoteLineItem.id;
        lineItem.ASI_HK_CRM_SKU__c = remoteLineItem.skuId;
        lineItem.ASI_HK_CRM_Quantity__c = remoteLineItem.qty;
        lineItem.ASI_HK_CRM_UOM__c = remoteLineItem.uom;
        lineItem.ASI_HK_CRM_Price__c = remoteLineItem.isPOS == true ? 0 : remoteLineItem.price;
        lineItem.ASI_HK_CRM_Reserve_Stock_No__c  = remoteLineItem.src; //20180731, by Introv Kelvin
        lineItem.ASI_CRM_Request_Release_Qty__c  = remoteLineItem.requestReleaseQty; //20180904, by Wilken
    }
    
    public List<List<String>> getSubBrandSearchOptions() {
        List<List<String>> result = new List<List<String>>();
        List<ASI_MFM_Sub_brand__c> sbList = [
            SELECT Id, Name, ASI_MFM_Sub_brand_Description__c
            FROM ASI_MFM_Sub_brand__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_SB
            AND ASI_MFM_Inactive__c = FALSE
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
    
    private static String escapeSOQLLikeValue(String likeVal) {
        return likeVal.replace('%', '\\%').replace('_', '\\_');
    }
    
    private static Integer integerFromObject(Object obj) {
        return obj != null ? Integer.valueOf(obj) : null;
    }
    private static String stringFromObject(Object obj) {
        return obj != null && !String.isBlank((String)obj) ? (String)obj : null;
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
        public Decimal price { get; set; }
        public Decimal amount { get; set; }
        public Boolean isPOS { get; set; }
        public Decimal stdNum { get; set; }   //Std. Bottle Size
        public String skuCode { get; set; }//20151223
        public String igCode {get; set;} //20160411, added by Leo
        public String igId {get; set;} //20180511, by Introv
        public String igName {get; set;} //20180511, by Introv
        public String src {get; set;} //20180731, by Introv Kelvin : Stock Release Code
        public Decimal requestReleaseQty {get; set;} //20180904, by Wilken : Request Release Qty
        public Decimal ediPrice {get; set;} //20180731, by Introv Kelvin : EDI Price
        public Boolean priceExcep {get; set;} //20180731, by Introv Kelvin : Price Exception
     
    }
    
    public virtual class ASI_HK_CRM_SKU {
        public String id { get; set; }
        public String code { get; set; }
        public String name { get; set; }
        public String subBrandId { get; set; }
        public String subBrandLabel { get; set; }
        public Decimal price { get; set; }
        public Decimal inventory { get; set; }
        public String brandType { get; set; }
        public Decimal stdNum { get; set; }     //Std. Bottle Size
        public String dummy { get; set; }
        public String igCode {get; set;} //20160411, added by Leo
        public String igId {get; set;} //20180511, by Introv
        public String igName {get; set;} //20180511, by Introv
        
    }
    
    public class ASI_HK_CRM_NormalProduct extends ASI_HK_CRM_SKU {
    }
    
    public class ASI_HK_CRM_POSProduct extends ASI_HK_CRM_SKU {
    }
    
    public class ASI_HK_CRM_DataTableServerInput {
        public String name;
        public Object value;
    }
    public class ASI_HK_CRM_DataTableServerResult {
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;
        public Decimal sEcho;
        public List<ASI_HK_CRM_SKU> aaData;
    }
    
    public class ASI_HK_CRM_SaveResult {
        public Boolean success { get; set; }
        public List<String> messages { get; set; }
        
        public ASI_HK_CRM_SaveResult() {
            this.messages = new List<String>();
        }
    }
    
}
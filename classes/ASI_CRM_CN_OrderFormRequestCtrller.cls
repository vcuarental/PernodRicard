public without sharing class ASI_CRM_CN_OrderFormRequestCtrller {
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
    Static List<ASI_CRM_CN_T1_Price__c> t1Price = new list<ASI_CRM_CN_T1_Price__c>([SELECT id, ASI_CRM_CN_T1_Price__c, ASI_CRM_CN_Item_Group__c FROM ASI_CRM_CN_T1_Price__c WHERE recordType.developerName = : RTDEVNAME_CUST_PD_PRICE AND ASI_CRM_CN_Effective_Date__c <= :date.today() order by ASI_CRM_CN_Effective_Date__c desc]);
    private ASI_CRM_Order_Form__c soHeader;
    
    public ASI_CRM_CN_OrderFormRequestCtrller(ApexPages.StandardSetController stdSetController) {
        //this.allowEdit = true;
        this.soHeaderId = ApexPages.currentPage().getParameters().get('id');
        this.soHeader = [SELECT Id, ASI_CRM_Order_Form_Name__c, ASI_CRM_Order_Form_Type__c, ASI_CRM_T1_Master__c, Name FROM ASI_CRM_Order_Form__c WHERE Id = :soHeaderId];
        this.useCustPrice = FALSE;
        this.sbSearchOptionsNormal = getSubBrandSearchOptions();
        this.sbSearchOptionsPOS = sbSearchOptionsNormal;
    }
     
    //Retrieve the SOLineItem under the SO 
    @RemoteAction
    public static List<ASI_HK_CRM_SOLineItem> lineItemList(ID headerId) {
        List<ASI_HK_CRM_SOLineItem> result = new List<ASI_HK_CRM_SOLineItem>();
        List<ASI_CRM_Order_Form_Detail__c> lineItems = [
            SELECT Id, Name, ASI_CRM_Product_Name__r.ASI_MFM_Sub_brand__c, ASI_CRM_Product_Name__r.ASI_MFM_Sub_brand__r.Name, ASI_CRM_Available__c,
            ASI_CRM_Packaging__c, ASI_CRM_Product_Name__c, ASI_CRM_Remark__c, ASI_CRM_Product_Name__r.Name, ASI_CRM_Sub_brand__c, ASI_CRM_T1_Price__c,
            ASI_CRM_Product_Name__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name, ASI_CRM_Sequence__c
            FROM ASI_CRM_Order_Form_Detail__c
            WHERE ASI_CRM_Order_Form__c = :headerId
            ORDER BY ASI_CRM_Product_Name__r.Name
        ];
        
        Map<ID ,ASI_CRM_CN_T1_Price__c> mapT1Price = new Map<ID ,ASI_CRM_CN_T1_Price__c>();
        
        for(ASI_CRM_CN_T1_Price__c obj : t1Price){
            if(!mapT1Price.containsKey(obj.ASI_CRM_CN_Item_Group__c))
            	mapT1Price.put(obj.ASI_CRM_CN_Item_Group__c, obj);
        }
        
        for (ASI_CRM_Order_Form_Detail__c li : lineItems) {
            ASI_HK_CRM_SOLineItem tempLi = new ASI_HK_CRM_SOLineItem();
            tempLi.id = li.Id;
            tempLi.skuId = li.ASI_CRM_Product_Name__c;
            tempLi.skuLabel = li.ASI_CRM_Product_Name__c != null ? li.ASI_CRM_Product_Name__r.Name : null;
            tempLi.skuInventory = null;
            tempLi.subBrandId = li.ASI_CRM_Product_Name__c != null ? li.ASI_CRM_Product_Name__r.ASI_MFM_Sub_brand__c : null;
            tempLi.subBrandLabel = tempLi.subBrandId != null ? li.ASI_CRM_Product_Name__r.ASI_MFM_Sub_brand__r.Name : null;
            tempLi.brandType = li.ASI_CRM_Product_Name__r.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name;
            tempLi.packaging = li.ASI_CRM_Packaging__c;
            tempLi.Available = li.ASI_CRM_Available__c;
            tempLi.qty = null;
            tempLi.uom = null; 
            tempLi.price = mapT1Price.get(li.ASI_CRM_Product_Name__c) !=null ? mapT1Price.get(li.ASI_CRM_Product_Name__c).ASI_CRM_CN_T1_Price__c : null;
            tempLi.amount = null;
            tempLi.isPOS = FALSE;
            tempLi.sequence = li.ASI_CRM_Sequence__c;
            tempLi.remark = li.ASI_CRM_Remark__c;
            System.debug('ddk'+li.ASI_CRM_Product_Name__c);
            tempLi.stdNum = null;
            result.add(tempLi);
        }        
            
        for (ASI_HK_CRM_SOLineItem str: result){ System.debug('kkl.5 Line Item List'+str); }
        return result;
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
    
    @RemoteAction
    public static List<ASI_HK_CRM_NormalProduct> normalProductList(ID headerID, String custId, Boolean onlyCustPrice) {
        List<ASI_HK_CRM_NormalProduct> result = new List<ASI_HK_CRM_NormalProduct>();
        List<ASI_MFM_Item_Group__c> skuList = [
            SELECT Id, Name, ASI_CRM_CN_pack__c, ASI_MFM_Sub_brand__c, ASI_MFM_Sub_brand__r.Name, ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c
                , ASI_CRM_CN_BT_Size_C__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name
            FROM ASI_MFM_Item_Group__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_SKU 
            AND ASI_CRM_CN_Not_In_Use__c = FALSE 
            AND ASI_CRM_Competitor__c = 'No' 
            AND ASI_CRM_CN_Gift_Set_C__c = FALSE
            AND ASI_CRM_CN_EMPTY_BOX_C__c = FALSE
            order by Name
        ];
        Date todayDate = Date.today();
		
        Map<ID ,ASI_CRM_CN_T1_Price__c> mapT1Price = new Map<ID ,ASI_CRM_CN_T1_Price__c>();
        
        for(ASI_CRM_CN_T1_Price__c obj : t1Price){
            if(mapT1Price.get(obj.ASI_CRM_CN_Item_Group__c)==null)
            	mapT1Price.put(obj.ASI_CRM_CN_Item_Group__c, obj);
        }
        
        /*List<ASI_HK_CRM_Customer_Product_Price__c> custPdPriceList = [
            SELECT Id, Name, ASI_HK_CRM_SKU_Lookup__c, ASI_HK_CRM_Bottle_Price__c, ASI_HK_CRM_Case_Price__c
            FROM ASI_HK_CRM_Customer_Product_Price__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_CUST_PD_PRICE AND ASI_HK_CRM_Customer_Name__c = :custId
                AND (ASI_HK_CRM_Effective_Date__c = NULL OR ASI_HK_CRM_Expiry_Date__c = NULL
                    OR (ASI_HK_CRM_Effective_Date__c <= :todayDate AND ASI_HK_CRM_Expiry_Date__c >= :todayDate))
        ];
        Map<ID, ASI_HK_CRM_Customer_Product_Price__c> pdIdToCustPdPriceMap = new Map<ID, ASI_HK_CRM_Customer_Product_Price__c>();
        for (ASI_HK_CRM_Customer_Product_Price__c custPdPrice : custPdPriceList) {
            pdIdToCustPdPriceMap.put(custPdPrice.ASI_HK_CRM_SKU_Lookup__c, custPdPrice);
        }*/
        
        for (ASI_MFM_Item_Group__c sku : skuList) {
            ASI_CRM_CN_T1_Price__c custPdPrice = mapT1Price.get(sku.id);
                ASI_HK_CRM_NormalProduct pd = new ASI_HK_CRM_NormalProduct();
                pd.id = sku.Id;
                pd.code = null;
                pd.name = sku.Name;
                pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
                pd.subBrandLabel = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
                pd.price = custPdPrice != null ? custPdPrice.ASI_CRM_CN_T1_Price__c : null;
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
                result.add(pd);
        }
        for(ASI_HK_CRM_NormalProduct str2: result){
            System.debug('kkl.6 normal product list'+str2);
        }
        return result;
    }
    
    //POS Table
    /*@RemoteAction
    public static ASI_HK_CRM_DataTableServerResult posProductDataTableResult(List<ASI_HK_CRM_DataTableServerInput> dataTableInputs) {
        Integer skuCount = [
            SELECT COUNT() FROM ASI_MFM_Item_Group__c
            WHERE RecordType.DeveloperName = :RTDEVNAME_SKU AND ASI_CRM_CN_Not_In_Use__c = FALSE
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
            'Id', 'Name', 'ASI_MFM_Sub_brand__c', 'ASI_MFM_Sub_brand__r.Name'
            
        };
        String baseWhereStatm = 'RecordType.DeveloperName = :RTDEVNAME_SKU AND ASI_CRM_CN_Not_In_Use__c = FALSE';
        String filterWhereStatm = '';
        if (!String.isBlank(searchName)) {
            searchName = '%' + escapeSOQLLikeValue(searchName.trim()) + '%';
            if (filterWhereStatm != '') filterWhereStatm += ' AND';
            filterWhereStatm += ' ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name LIKE :searchName';
        }
        if (!String.isBlank(subBrandStr)) {
            if (filterWhereStatm != '') filterWhereStatm += ' AND';
            if (subBrandStr.startsWith('_')) {
                subBrandStr = subBrandStr.substringBetween('_', '_');
                //filterWhereStatm += ' ASI_MFM_Sub_brand__r.ASI_HK_CRM_SYS_Brand_Type__c = :subBrandStr';
            } else {
                filterWhereStatm += ' ASI_MFM_Sub_brand__c = :subBrandStr';
            }
        }
        String whereStatm = filterWhereStatm != '' ? '(' + filterWhereStatm + ') AND (' + baseWhereStatm + ')' : baseWhereStatm;
        String skuSearchCountQueryStr = ASI_HK_CRM_CommonUtils.genQueryString(new Set<String>{'COUNT()'}, 'ASI_MFM_Item_Group__c', whereStatm);
        Integer skuSearchCount = database.countQuery(skuSearchCountQueryStr);
        String extraQueryStr = '';
        if (limitNum != null) extraQueryStr += ' LIMIT :limitNum';
        if (offsetNum != null) extraQueryStr += ' OFFSET :offsetNum';
        String skuSearchQueryStr = ASI_HK_CRM_CommonUtils.genQueryString(queryFields, 'ASI_MFM_Item_Group__c', whereStatm, extraQueryStr);
        List<ASI_MFM_Item_Group__c> skuList = (List<ASI_MFM_Item_Group__c>)database.query(skuSearchQueryStr);
        
        ASI_HK_CRM_DataTableServerResult result = new ASI_HK_CRM_DataTableServerResult();
        result.iTotalRecords = skuCount;
        result.iTotalDisplayRecords = skuSearchCount;
        result.sEcho = (Decimal)dataTableInputMap.get('sEcho');
        List<ASI_HK_CRM_POSProduct> pdList = new List<ASI_HK_CRM_POSProduct>();
        for (ASI_MFM_Item_Group__c sku : skuList) {
            ASI_HK_CRM_POSProduct pd = new ASI_HK_CRM_POSProduct();
            pd.id = sku.Id;
            pd.code = null;
            pd.name = sku.Name;
            pd.subBrandId = sku.ASI_MFM_Sub_brand__c;
            pd.subBrandLabel = sku.ASI_MFM_Sub_brand__c != null ? sku.ASI_MFM_Sub_brand__r.Name : '';
            pd.brandType = sku.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Brand_Group_c__r.Name;
            pd.price = null;
            pd.inventory = null;
            pdList.add(pd);
        }
        result.aaData = pdList;
        for(ASI_HK_CRM_POSProduct res: pdList){
            System.debug('lab1'+res);
        }
        
        return result;
    }*/
    
    @RemoteAction
    public static ASI_HK_CRM_SaveResult saveChanges(String headerId, List<ASI_HK_CRM_SOLineItem> remoteLineItems) {
        ASI_HK_CRM_SaveResult result = new ASI_HK_CRM_SaveResult();
        result.success = false;
        
        try {
            if (isNonEmptyId(headerId)) {
                Map<ID, ASI_CRM_Order_Form_Detail__c> existingLineItemMap = new Map<ID, ASI_CRM_Order_Form_Detail__c>(
                (List<ASI_CRM_Order_Form_Detail__c>)[
                    SELECT Id, LastModifiedDate
                    FROM ASI_CRM_Order_Form_Detail__c
                    WHERE ASI_CRM_Order_Form__c = :headerId
                    FOR UPDATE
                ]);
                
                Set<ID> newIdSet = new Set<ID>();
                List<ASI_CRM_Order_Form_Detail__c> insertLineItems = new List<ASI_CRM_Order_Form_Detail__c>();
                List<ASI_CRM_Order_Form_Detail__c> updateLineItems = new List<ASI_CRM_Order_Form_Detail__c>();
                List<ASI_CRM_Order_Form_Detail__c> deleteLineItems = new List<ASI_CRM_Order_Form_Detail__c>();
                if (remoteLineItems != null) {
                    for (ASI_HK_CRM_SOLineItem remoteLineItem : remoteLineItems) {
                        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') {
                            ASI_CRM_Order_Form_Detail__c lineItem = existingLineItemMap.get(remoteLineItem.id);
                            if (lineItem != null) {
                                updateLineItemFromRemote(lineItem, remoteLineItem);
                                updateLineItems.add(lineItem);
                                newIdSet.add(remoteLineItem.id);
                            } else {
                                result.messages.add(String.format('Line item with ID {0} is not found', new String[] {remoteLineItem.id}));
                                break;
                            }
                        } else {
                            ASI_CRM_Order_Form_Detail__c lineItem = new ASI_CRM_Order_Form_Detail__c();
                            updateLineItemFromRemote(lineItem, remoteLineItem);
                            lineItem.ASI_CRM_Order_Form__c = headerId;
                            insertLineItems.add(lineItem);
                        }
                    }
                }
                
                if (existingLineItemMap.size() != newIdSet.size()) {
                    for (ASI_CRM_Order_Form_Detail__c existingLineItem : existingLineItemMap.values()) {
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
    private static void updateLineItemFromRemote(ASI_CRM_Order_Form_Detail__c lineItem, ASI_HK_CRM_SOLineItem remoteLineItem) {
		
        Map<ID ,ASI_CRM_CN_T1_Price__c> mapT1Price = new Map<ID ,ASI_CRM_CN_T1_Price__c>();
        
        for(ASI_CRM_CN_T1_Price__c obj : t1Price){
            if(mapT1Price.get(obj.ASI_CRM_CN_Item_Group__c)==null)
            	mapT1Price.put(obj.ASI_CRM_CN_Item_Group__c, obj);
        }
        
        if (remoteLineItem.id != null && remoteLineItem.id.trim() != '') lineItem.Id = remoteLineItem.id;
        //lineItem.ASI_HK_CRM_Quantity__c = remoteLineItem.qty;
        //lineItem.ASI_HK_CRM_UOM__c = remoteLineItem.uom;
        //lineItem.ASI_CRM_T1_Price__c = remoteLineItem.price;//mapT1Price.get(remoteLineItem.skuId) != null? mapT1Price.get(remoteLineItem.skuId).ASI_CRM_CN_T1_Price__c : null ;
        lineItem.ASI_CRM_Product_Name__c = remoteLineItem.skuId;
        lineItem.ASI_CRM_Remark__c = remoteLineItem.remark;
        lineItem.ASI_CRM_Available__c = remoteLineItem.available;
        lineItem.ASI_CRM_Sequence__c = remoteLineItem.sequence;
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
    
    /*private static String escapeSOQLLikeValue(String likeVal) {
        return likeVal.replace('%', '\\%').replace('_', '\\_');
    }*/
    
    /*private static Integer integerFromObject(Object obj) {
        return obj != null ? Integer.valueOf(obj) : null;
    }*/
    /*private static String stringFromObject(Object obj) {
        return obj != null && !String.isBlank((String)obj) ? (String)obj : null;
    }*/
    
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
        public String remark { get; set; }
        public string packaging { get; set; }
        public Decimal price { get; set; }
        public Decimal amount { get; set; }
        public Boolean available { get; set; }
        public Boolean isPOS { get; set; }
        public Decimal stdNum { get; set; }   //Std. Bottle Size
        public Decimal sequence { get; set; }
    }
    
    public virtual class ASI_HK_CRM_SKU {
        public String id { get; set; }
        public String code { get; set; }
        public String name { get; set; }
        public String subBrandId { get; set; }
        public String subBrandLabel { get; set; }
        public string packaging { get; set; }
        public Decimal price { get; set; }
        public Decimal inventory { get; set; }
        public String brandType { get; set; }
        public Decimal stdNum { get; set; }     //Std. Bottle Size
        public String dummy { get; set; }
        
    }
    
    public class ASI_HK_CRM_NormalProduct extends ASI_HK_CRM_SKU {
    }
    
    public class ASI_HK_CRM_POSProduct extends ASI_HK_CRM_SKU {
    }
    
    public class ASI_HK_CRM_DataTableServerInput {
        public String name;
        public Object value;
    }
    /*public class ASI_HK_CRM_DataTableServerResult {
        public Integer iTotalRecords;
        public Integer iTotalDisplayRecords;
        public Decimal sEcho;
        public List<ASI_HK_CRM_SKU> aaData;
    }*/
    
    public class ASI_HK_CRM_SaveResult {
        public Boolean success { get; set; }
        public List<String> messages { get; set; }
        
        public ASI_HK_CRM_SaveResult() {
            this.messages = new List<String>();
        }
    }
}
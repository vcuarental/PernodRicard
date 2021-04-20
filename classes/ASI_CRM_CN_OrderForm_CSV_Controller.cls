public without sharing class ASI_CRM_CN_OrderForm_CSV_Controller {
    public ASI_CRM_CN_OrderForm_CSV_Controller(ApexPages.StandardController controller) {
        this.header = (ASI_CRM_AccountsAdditionalField__c)controller.getRecord();
    }
    public string xmltag {set;get{return '<?xml version="1.0" encoding="GB2312"?>';}}
    public ASI_CRM_CN_OrderForm_CSV_Controller(){ }
    public id currentHeaderId {set;get;}
    public ASI_CRM_AccountsAdditionalField__c header{get;set;}
    //Oreder Form 
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    //RTD Order Form 
    public Boolean dummyI { get { if (dummyI != true) {dummyI = initI();} return dummyI; } set; }
    
    //20161026 Ben @ Elufa
    Public String orderFormType {Get; Set;}
    
    public List<ASI_CRM_Order_Form_Customer_Relationship__c> OFCR_List{get;set;}
    public List<ASI_CRM_Order_Form_Detail__c> OFD_List {get;set;}
    public List<ASI_CRM_Item_Group_Customer_Price__c> Customer_IGCP {get;set;}
    
    
    public Class interimData{
        public ASI_CRM_Order_Form_Detail__c OFD {get; set;}
        public ASI_CRM_Item_Group_Customer_Price__c IGCP {get; set;}
        public ASI_KOR_Sales_Order_Transaction__c salesOrderRequestItem {get; set;}
    }
    public List<interimData> results {get; set;}
    public Map<String, ASI_CRM_Item_Group_Customer_Price__c> results2 = new Map<String, ASI_CRM_Item_Group_Customer_Price__c>();
    public List<interimData> results3 {get; set;}
    public Map<String, ASI_KOR_Sales_Order_Transaction__c> productNameSalesOrderItemMap {get; set;}
    //2019/10/27 CanterDuan 记录税率
    Public Decimal taxRate {get;set;}

    public boolean init() {
        header=[select name,ASI_CRM_CN_Is_IHBR_Outlet__c, ASI_CRM_Customer_Type_Picklist__c from ASI_CRM_AccountsAdditionalField__c where id=:currentHeaderId];
        //2019/10/27 CanterDuan 获取最新的汇率
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if(!taxRateList.isEmpty()){
            taxRate = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
        //Setup
        Customer_IGCP = new List<ASI_CRM_Item_Group_Customer_Price__c>();
        //OFCR_List=new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
        OFD_List=new List<ASI_CRM_Order_Form_Detail__c>();
        set<id> OFCR_set = new set<id>();
        set<id> OFD_set= new set<id>();
        map<String, ASI_CRM_Order_Form_Detail__c> OFD_map = new map<String, ASI_CRM_Order_Form_Detail__c>();
        
        results = new List<interimData>();
        results3 = new List<interimData>();
        
        if(header.ASI_CRM_CN_Is_IHBR_Outlet__c==true){
            for(ASI_CRM_Item_Group_Customer_Price__c igcp:[select ASI_CRM_Item_Group__c, ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c, ASI_CRM_Promotion_Expiration_Date__c, ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Customer__c=:currentHeaderId AND ASI_CRM_Price_Type__c != 'T1']){ // Customer_IGCP=[select ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c,ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Customer__c=:currentHeaderId];
                interimData temp= new interimData();
                temp.IGCP=igcp;
                results.add(temp);
            }
        }else{
            for(ASI_CRM_Order_Form_Customer_Relationship__c OFCR:[select name,ASI_CRM_Order_Form__c from ASI_CRM_Order_Form_Customer_Relationship__c where ASI_CRM_Customer__c=:currentHeaderId]){ //OFCR_List=[select name,ASI_CRM_Order_Form__c from ASI_CRM_Order_Form_Customer_Relationship__c where ASI_CRM_Customer__c=:currentHeaderId];
                OFCR_set.add(OFCR.ASI_CRM_Order_Form__c);
            }
            
            List<ASI_CRM_Order_Form_Detail__c> tmpOFD = new List<ASI_CRM_Order_Form_Detail__c>([select name, ASI_CRM_Sequence__c
                                                                                                ,ASI_CRM_Product_Name__c
                                                                                                ,ASI_CRM_Product_Name__r.name
                                                                                                ,ASI_CRM_Product_Name__r.ASI_CRM_CN_Eng_Name__c
                                                                                                ,ASI_CRM_Product_Name__r.ASI_CRM_CN_Chinese_Name__c
                                                                                                ,ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_External_ID__c
                                                                                                ,ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_Code__c
                                                                                                ,ASI_CRM_Remark__c 
                                                                                                ,ASI_CRM_Product_Name__r.ASI_CRM_CN_BT_Size_C__c
                                                                                                ,ASI_CRM_Product_Name__r.ASI_CRM_CN_Pack_Value__c
                                                                                                from ASI_CRM_Order_Form_Detail__c where ASI_CRM_Order_Form__c in: OFCR_set and ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c='Normal Item' Order By ASI_CRM_Sequence__c Desc]);
            List<ASI_CRM_Order_Form_Detail__c> tmpOFDSorted = new List<ASI_CRM_Order_Form_Detail__c>();
            for(integer i = tmpOFD.size()-1; i >= 0 ; i--){
                tmpOFDSorted.add(tmpOFD[i]);
            }
            for(ASI_CRM_Order_Form_Detail__c OFD : tmpOFDSorted){ //OFD_List=[select name,ASI_CRM_Product_Name__c,ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Remark__c from ASI_CRM_Order_Form_Detail__c where ASI_CRM_Order_Form__c in: OFCR_set];
                interimData temp= new interimData();
                OFD_set.add(OFD.ASI_CRM_Product_Name__c);
                OFD_map.put(currentHeaderId + '' + OFD.ASI_CRM_Product_Name__c,OFD);
                if (OFD.ASI_CRM_Remark__c != null){
                //string[] strcomment1 = (a.ASI_CRM_Comment__c).split('\n');
                String c = OFD.ASI_CRM_Remark__c;
                String b = '';
                if(c.contains(','))
                {
                    c=c.replace(',','');
                }
                b = b + c;
                OFD.ASI_CRM_Remark__c = b;

            }
                temp.OFD=OFD;
                results.add(temp);
            }
            for(ASI_CRM_Item_Group_Customer_Price__c igcp:[select name, ASI_CRM_Promotion_Expiration_Date__c, ASI_CRM_Customer__c,ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c,ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Item_Group__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Item_Group__c in:OFD_set AND ASI_CRM_Customer__c = : currentHeaderId]){  // Customer_IGCP=[select name,ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c,ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Item_Group__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Item_Group__c in:OFD_set];
                
                ASI_CRM_Item_Group_Customer_Price__c temp= new ASI_CRM_Item_Group_Customer_Price__c();
                
                if(OFD_map.containsKey(igcp.ASI_CRM_Customer__c + '' + igcp.ASI_CRM_Item_Group__c) && taxRate != null){
                    //igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * 1.13).setScale(2); //20180426 Introv changed Tax Rate from 17% to 16% //20190416 Laputa changed Tax Rate from 16% to 13%
                    igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * (1 + taxRate/100)).setScale(2); //2019/10/27 CanterDuan将税率修改调整为配置的形式
                    temp=igcp;
                    results2.put(igcp.ASI_CRM_Customer__c + '' + igcp.ASI_CRM_Item_Group__c, temp);
                }
            }

            if (header.ASI_CRM_Customer_Type_Picklist__c == 'MOT') { //20181102 Alan Lau
                productNameSalesOrderItemMap = new Map<String, ASI_KOR_Sales_Order_Transaction__c>();
                productNameSalesOrderItemMap = mapOrderFormDetailToSalesRequestItem(OFD_set, OFD_map);
            }

            if (results.size() > 0) {
                for (interimData obj : results) {
                    interimData temp = new interimData();
                    temp.OFD = obj.OFD;
                    if (results2.containsKey(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c))
                        temp.IGCP = results2.get(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c);

                    if (header.ASI_CRM_Customer_Type_Picklist__c == 'MOT' && productNameSalesOrderItemMap.containsKey(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c)) { //20181102 Alan Lau
                        temp.salesOrderRequestItem = productNameSalesOrderItemMap.get(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c);
                    }
                    results3.add(temp);
                }
            }
        }
        return true; 
    }

    public boolean initI(){
        header=[select name, ASI_CRM_Customer_Type_Picklist__c from ASI_CRM_AccountsAdditionalField__c where id=:currentHeaderId];
        //2019/10/27 CanterDuan 获取最新的汇率
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        if(!taxRateList.isEmpty()){
            taxRate = taxRateList[0].ASI_CRM_CN_Tax_Rate__c;
        }
        //Setup
        Customer_IGCP=new List<ASI_CRM_Item_Group_Customer_Price__c>();
        OFD_List=new List<ASI_CRM_Order_Form_Detail__c>();
        set<id> OFCR_set = new set<id>();
        set<id> OFD_set= new set<id>();
        map<String, ASI_CRM_Order_Form_Detail__c> OFD_map = new map<String, ASI_CRM_Order_Form_Detail__c>();

        results = new List<interimData>();
        results3 = new List<interimData>();

        for(ASI_CRM_Order_Form_Customer_Relationship__c OFCR:[select name,ASI_CRM_Order_Form__c from ASI_CRM_Order_Form_Customer_Relationship__c where ASI_CRM_Customer__c=:currentHeaderId]){
            OFCR_set.add(OFCR.ASI_CRM_Order_Form__c);
        }

        List<ASI_CRM_Order_Form_Detail__c> tmpOFD = new List<ASI_CRM_Order_Form_Detail__c>([select name
                                                                                            , ASI_CRM_Sequence__c
                                                                                            , ASI_CRM_Product_Name__r.name
                                                                                            , ASI_CRM_Product_Name__c
                                                                                            , ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_Code__c
                                                                                            , ASI_CRM_Remark__c
                                                                                            , ASI_CRM_Product_Name__r.ASI_CRM_CN_Eng_Name__c
                                                                                            , ASI_CRM_Product_Name__r.ASI_CRM_CN_Chinese_Name__c
                                                                                            , ASI_CRM_Product_Name__r.ASI_MFM_Item_Group_External_ID__c
                                                                                            , ASI_CRM_Product_Name__r.ASI_CRM_CN_BT_Size_C__c
                                                                                            , ASI_CRM_Product_Name__r.ASI_CRM_CN_Pack_Value__c
                                                                                            from ASI_CRM_Order_Form_Detail__c
                                                                                            where ASI_CRM_Order_Form__c in: OFCR_set
                                                                                            and ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c = : orderFormType
                                                                                            Order By ASI_CRM_Sequence__c Desc]);
        List<ASI_CRM_Order_Form_Detail__c> tmpOFDSorted = new List<ASI_CRM_Order_Form_Detail__c>();

        for(integer i = tmpOFD.size()-1; i >= 0 ; i--){
            tmpOFDSorted.add(tmpOFD[i]);
        }

        for(ASI_CRM_Order_Form_Detail__c OFD: tmpOFDSorted){
            interimData temp= new interimData();
            OFD_set.add(OFD.ASI_CRM_Product_Name__c);
            OFD_map.put(currentHeaderId + '' + OFD.ASI_CRM_Product_Name__c,OFD);

            if (OFD.ASI_CRM_Remark__c != null && OFD.ASI_CRM_Remark__c != ''){
                if(OFD.ASI_CRM_Remark__c.contains(','))
                {
                    OFD.ASI_CRM_Remark__c = OFD.ASI_CRM_Remark__c.replace(',','');
                }
            }
            temp.OFD=OFD;
            results.add(temp);
        }
        for(ASI_CRM_Item_Group_Customer_Price__c igcp:[select name,ASI_CRM_Customer__c,ASI_CRM_Promotion_Code__r.name,ASI_CRM_Unit_Price_BT__c,ASI_CRM_Item_Group__r.name,ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c,ASI_CRM_Item_Group__c from ASI_CRM_Item_Group_Customer_Price__c where ASI_CRM_Item_Group__c in:OFD_set AND ASI_CRM_Customer__c = : currentHeaderId]){

            ASI_CRM_Item_Group_Customer_Price__c temp= new ASI_CRM_Item_Group_Customer_Price__c();
            if(OFD_map.containsKey(igcp.ASI_CRM_Customer__c + '' + igcp.ASI_CRM_Item_Group__c) && taxRate != null){
                //igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * 1.13).setScale(3); //20180426 Introv changed Tax Rate from 17% to 16% //20190416 Laputa changed Tax Rate from 16% to 13%
                igcp.ASI_CRM_Unit_Price_BT__c = (igcp.ASI_CRM_Unit_Price_BT__c * (1 + taxRate/100)).setScale(3); //2019/10/27 CanterDuan将税率修改调整为配置的形式
                temp=igcp;
                results2.put(igcp.ASI_CRM_Customer__c + '' + igcp.ASI_CRM_Item_Group__c, temp);
            }
        }

        if (header.ASI_CRM_Customer_Type_Picklist__c == 'MOT') { //20181102 Alan Lau
            productNameSalesOrderItemMap = new Map<String, ASI_KOR_Sales_Order_Transaction__c>();
            productNameSalesOrderItemMap = mapOrderFormDetailToSalesRequestItem(OFD_set, OFD_map);
        }

        if (results.size() > 0) {
            for (interimData obj : results) {
                interimData temp = new interimData();
                temp.OFD = obj.OFD;
                if (results2.containsKey(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c))
                    temp.IGCP = results2.get(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c);

                if (header.ASI_CRM_Customer_Type_Picklist__c == 'MOT' && productNameSalesOrderItemMap.containsKey(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c)) { //20181102 Alan Lau
                    temp.salesOrderRequestItem = productNameSalesOrderItemMap.get(currentHeaderId + '' + obj.OFD.ASI_CRM_Product_Name__c);
                }
                results3.add(temp);
            }
        }
        return true;
    }

    //20181102 Alan Lau
    private Map<String, ASI_KOR_Sales_Order_Transaction__c> mapOrderFormDetailToSalesRequestItem(Set<Id> orderFormDetailProductNameSet, Map<String, ASI_CRM_Order_Form_Detail__c> itemGroupOrderFormDetailMap) {
        Map<String, ASI_KOR_Sales_Order_Transaction__c> productNameSalesOrderItemMap = new Map<String, ASI_KOR_Sales_Order_Transaction__c>();

        List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItemList = retrieveSalesOrderItemList(orderFormDetailProductNameSet);

        List<Id> customerIdList = retrieveCustomerIdList(salesOrderItemList);
        List<Id> productNameList = retrieveProductNameList(salesOrderItemList);
        Map<Id, Decimal> mapOfSalesOrderItemIdToDefaultMOTPrice = getMapOfSalesOrderItemIdToDefaultPrice(customerIdList, productNameList, salesOrderItemList, 'Contract Price');
        Map<Id, Decimal> mapOfSalesOrderItemIdToDefaultMOTPromotionPrice = getMapOfSalesOrderItemIdToDefaultPrice(customerIdList, productNameList, salesOrderItemList, 'Promotion Price');

        for (ASI_KOR_Sales_Order_Transaction__c salesOrderItem : salesOrderItemList) {
            salesOrderItem = retrieveLatestMOTPricesWithoutVAT(mapOfSalesOrderItemIdToDefaultMOTPrice, mapOfSalesOrderItemIdToDefaultMOTPromotionPrice, salesOrderItem);
            if (itemGroupOrderFormDetailMap.containsKey(salesOrderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c + '' + salesOrderItem.ASI_CRM_CN_Product_Name__c)) {
                productNameSalesOrderItemMap.put(salesOrderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c + '' + salesOrderItem.ASI_CRM_CN_Product_Name__c, salesOrderItem);
            }
        }

        return productNameSalesOrderItemMap;
    }

    //20181106 Alan Lau
    private Map<Id, Decimal> getMapOfSalesOrderItemIdToDefaultPrice(List<Id> customerIdList, List<Id> productNameList, List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItemList, String priceType) {
        Map<Id, Decimal> salesOrderItemPriceAndDiscountDetailMap = new Map<Id, Decimal>();

        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = retrievePriceAndDiscountDetailList(customerIdList, productNameList, priceType);

        for (ASI_KOR_Sales_Order_Transaction__c salesOrderItem : salesOrderItemList) {
            for (ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail : priceAndDiscountDetailList) {
                if (salesOrderItem.ASI_CRM_CN_Product_Name__c == priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c) {
                    salesOrderItemPriceAndDiscountDetailMap.put(salesOrderItem.Id, priceAndDiscountDetail.ASI_CRM_New_Price_BT_non_VAT__c);
                    break;
                }
            }
        }

        return salesOrderItemPriceAndDiscountDetailMap;
    }

    //20181106 Alan Lau
    private List<ASI_KOR_Sales_Order_Transaction__c> retrieveSalesOrderItemList(Set<Id> orderFormDetailProductNameSet) {
        List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItemList = [
                SELECT Id,
                        ASI_CRM_MOT_Price_non_VAT__c,
                        ASI_CRM_MOT_Promotion_Price_non_VAT__c,
                        ASI_CRM_CN_Product_Name__c,
                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c,
                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c
                FROM ASI_KOR_Sales_Order_Transaction__c
                WHERE ASI_CRM_CN_Product_Name__c IN :orderFormDetailProductNameSet
                AND ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c = :currentHeaderId
        ];

        return salesOrderItemList;
    }

    //20181106 Alan Lau
    private ASI_KOR_Sales_Order_Transaction__c retrieveLatestMOTPricesWithoutVAT(Map<Id, Decimal> mapOfSalesOrderItemIdToDefaultMOTPrice, Map<Id, Decimal> mapOfSalesOrderItemIdToDefaultMOTPromotionPrice, ASI_KOR_Sales_Order_Transaction__c salesOrderItem) {
        ASI_KOR_Sales_Order_Transaction__c salesOrderTransaction = salesOrderItem;

        if (mapOfSalesOrderItemIdToDefaultMOTPrice.containsKey(salesOrderItem.Id)) {
            salesOrderTransaction.ASI_CRM_MOT_Price_non_VAT__c = mapOfSalesOrderItemIdToDefaultMOTPrice.get(salesOrderItem.Id);
        }

        if (mapOfSalesOrderItemIdToDefaultMOTPromotionPrice.containsKey(salesOrderItem.Id)) {//20190111 Alan Lau
            salesOrderTransaction.ASI_CRM_MOT_Promotion_Price_non_VAT__c = mapOfSalesOrderItemIdToDefaultMOTPromotionPrice.get(salesOrderItem.Id);
        }

        return salesOrderTransaction;
    }

    //20181106 Alan Lau
    private List<ASI_CRM_Price_And_Discount_Detail__c> retrievePriceAndDiscountDetailList(List<Id> customerIdList, List<Id> productNameList, String priceType) {
        Date today = Date.today();

        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList =  [
                SELECT ASI_CRM_Item_Group_Description__c
                        ,ASI_CRM_New_Price_BT_non_VAT__c
                FROM ASI_CRM_Price_And_Discount_Detail__c
                WHERE recordtypeid = :Global_RecordTypeCache.getRtID('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Customer__c IN :customerIdList
                AND ASI_CRM_Item_Group_Description__c IN :productNameList
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c <= :today
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c >= :today
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c = 'Completed'
                AND ASI_CRM_Price_And_Discount__r.ASI_CRM_IHBR_Price_Type__c = :priceType
                ORDER BY ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c DESC
        ];

        return priceAndDiscountDetailList;
    }

    //20181106 Alan Lau
    private List<Id> retrieveCustomerIdList(List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItemList) {
        List<Id> customerIdList = new List<Id>();

        for (ASI_KOR_Sales_Order_Transaction__c salesOrderItem : salesOrderItemList) {
            customerIdList.add(salesOrderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__c);
        }

        return customerIdList;
    }

    //20181106 Alan Lau
    private List<Id> retrieveProductNameList(List<ASI_KOR_Sales_Order_Transaction__c> salesOrderItemList) {
        List<Id> productNameList = new List<Id>();

        for (ASI_KOR_Sales_Order_Transaction__c salesOrderItem : salesOrderItemList) {
            productNameList.add(salesOrderItem.ASI_CRM_CN_Product_Name__c);
        }

        return productNameList;
    }
}
/* Filename:    ASI_CTY_CN_WS_Utils.cls
 * Author:      Alex 
 * Date:        2019-12-05
 * Description: Wholesaler Platform Project Util class
 */

public without sharing class ASI_CTY_CN_WS_Utils {
    //price and discount recordtype 
    public static final String PD_RECORDTYPE_TRADE_A_P = Label.ASI_CTY_CN_WS_Price_And_Discount_RecordType_Trade_AP;
    public static final String PD_RECORDTYPE_NORMAL = Label.ASI_CTY_CN_WS_Price_And_Discount_RecordType_Normal;
    public static final String PD_RECORDTYPE_PRICE = Label.ASI_CTY_CN_WS_Price_And_Discount_RecordType_Trade_PD;
    public static final String PD_RECORDTYPE_AD = Label.ASI_CTY_CN_WS_Price_And_Discount_RecordType_AD;

    public static final String SELECT_NONE = '--None--';

    public static final String VALUE_TYPE_PERCENT = '% base price';
    public static final String VALUE_TYPE_AMOUNT = 'add on amount';

    //price and discount status
    public static final String PRICE_AND_DISCOUNT_STATUS_APPROVED = 'Approved';
    public static final String PRICE_AND_DISCOUNT_STATUS_OPEN = 'Open';
    
    //cn price and discount record type api
    public static final String PRICE_AND_DISCOUNT_RECORDTYPE_PD = 'ASI_CRM_CN_Customer_Price_and_Discount_Request';

    public static final String PROMOTION_MASTER_TYPE_DISCOUNT = 'Discount';

    //promoter master 
    public static final String PM_CUSTOMER_TYPE_WS = 'Wholesaler';
    public static final String PM_CUSTOMER_TYPE_OUTLET = 'Outlet';
    
    // Wholesaler Type Premium
    public static final String TYPE_PREMIUMWS = 'PRC Premium Wholesaler';
    
    // Customer RecordType DeveloperName ASI_CRM_CN_WS
    public static final String RTDEVNAME_CUSTOMERCNWS = 'ASI_CRM_CN_WS';

    // SOR Status Open
    public static final String STATUS_SOROPEN = 'Open';
    // SOR RecordType DeveloperName ASI_CRM_CN_SalesOrder
    public static final String RTDEVNAME_SORCN = 'ASI_CRM_CN_SalesOrder';
    // SOR RecordType DeveloperName ASI_CRM_CN_SalesOrder_RO
    public static final String RTDEVNAME_SORCNRO = 'ASI_CRM_CN_SalesOrder_RO';
    
    // SOR Item RecordType DeveloperName ASI_CRM_CN_SalesOrder_Item
    public static final String RTDEVNAME_SORITEMCN = 'ASI_CRM_CN_SalesOrder_Item';
    // SOR Item UOM CA
    public static final String UOM_SORITEMCN = 'CA';

    // TOV RecordType DeveloperName ASI_CRM_CN_TOV
    public static final String RTDEVNAME_TOVCN = 'ASI_CRM_CN_TOV';
    // TOV RecordType DeveloperName ASI_CRM_CN_TOV_Final
    public static final String RTDEVNAME_TOVCNFINAL = 'ASI_CRM_CN_TOV_Final';
    // TOV Type V2
    public static final String TYPE_TOVV2 = 'V2';
    // TOV Status Held
    public static final String STATUS_TOVHELD = 'Held';

    // TOV Detail RecordType DeveloperName ASI_CRM_CN_CN_TOV_Detail
    public static final String RTDEVNAME_TOVDETAILCN = 'ASI_CRM_CN_CN_TOV_Detail';

    // Custom Category Brand RecordType DeveloperName ASI_CTY_CN_WS_Category_Filter
    public static final String RTDEVNAME_CATEGORYFILTER = 'ASI_CTY_CN_WS_Category_Filter';
    // Custom Category Brand RecordType DeveloperName ASI_CTY_CN_WS_Brand_Filter
    public static final String RTDEVNAME_BRANDFILTER = 'ASI_CTY_CN_WS_Brand_Filter';
    // Custom Category Brand RecordType DeveloperName ASI_CTY_CN_WS_Bottle_Size_Filter
    public static final String RTDEVNAME_BOTTLESIZEFILTER = 'ASI_CTY_CN_WS_Bottle_Size_Filter';
    
    // CN WS Category & Brand Relationship RecordType DeveloperName ASI_CTY_CN_WS_Custom_Category_Brand_Relationship
    public static final String RTDEVNAME_CATEGORYBRANDRELATIONSHIP = 'ASI_CTY_CN_WS_Custom_Category_Brand_Relationship';
    
    // Order Form Customer Relationship RecordType DeveloperName ASI_CRM_CN_Order_Form_Customer_Relationship
    public static final String RTDEVNAME_ORDERFORMCUSTOMERRELATIONSHIP = 'ASI_CRM_CN_Order_Form_Customer_Relationship';
    
    // Type Premium
    public static final String TYPE_PREMIUM = 'Premium';
    // Type Prestige
    public static final String TYPE_PRESTIGE = 'Prestige';

    // Order Form Type Normal Item
    public static final String TYPE_NORMALITEM = 'Normal Item';

    // Order Form Detail RecordType DeveloperName ASI_CRM_CN_Order_Form_Detail
    public static final String RTDEVNAME_ORDERFORMDETAIL = 'ASI_CRM_CN_Order_Form_Detail';
    
    // Item Group RecordType DeveloperName ASI_CRM_CN_CRM_Item_Group
    public static final String RTDEVNAME_ITEMGROUP = 'ASI_CRM_CN_CRM_Item_Group';

    // SKU Information Status Completed
    public static final String INFOSTATUS_SKUCOMPLETED = 'Completed';

    // Dilivery status
    public static final String DELIVERTY_STATUS_INTRANSIT_EN = 'In-transit';
    public static final String DELIVERTY_STATUS_INTRANSIT_CN = '配送中';
    public static final String DELIVERTY_STATUS_ARRIVED_EN = 'Arrived';
    public static final String DELIVERTY_STATUS_ARRIVED_CN = '已送达';
    public static final String DELIVERTY_STATUS_PICKED_EN = 'Picked';
    public static final String DELIVERTY_STATUS_PICKED_CN = '已捡选';
    public static final String DELIVERTY_STATUS_CLOSED_EN = 'Closed';
    public static final String DELIVERTY_STATUS_CLOSED_CN = '订单配送完毕';
    public static final String DELIVERTY_STATUS_TOV_GENERATED_EN = 'TOV Generated';
    public static final String DELIVERTY_STATUS_TOV_GENERATED_CN = '发货TOV生成';
    public static final String DELIVERTY_STATUS_SHIPPING_DATE_EN = 'Planned Shipping Date';
    public static final String DELIVERTY_STATUS_SHIPPING_DATE_CN = '计划发货日期';
    public static final String DELIVERTY_STATUS_DISPATCHING_DATE_EN = 'Dispatching Date';
    public static final String DELIVERTY_STATUS_DISPATCHING_DATE_CN = '发货日期';
    public static final String DELIVERTY_STATUS_UNKNOWN = '未知状态';
    
    // TOV status
    public static final String TOV_STATUS_DISPATCHED_CN = '配送中';
    public static final String TOV_STATUS_RECIEVED_CN = '已完成';
    public static final String TOV_STATUS_RELEASED_EN = 'Released';

    public static Set<String> pdPassStatus = new Set<String>{'Approved', 'Completed'};



    //param : customerId,itemgroupIds
    //return : Map<itemGroupId, WSPriceWrap>
    public static Map<Id, WSPriceWrap> calculateWSPriceInfo(Id customerId, Set<Id> itemGroupIds){
        List<PriceDiscountDetailWrap> priceDiscountDetailWraps = calculateDiscountInfo(customerId, itemGroupIds);
        System.debug(LoggingLevel.INFO, '*** priceDiscountDetailWraps: ' + priceDiscountDetailWraps);

        return getWSItemGroupPriceMap(priceDiscountDetailWraps);
    }

    //param : customerId,itemgroupIds
    //return : List<PriceDiscountDetailWrap>
    public static List<PriceDiscountDetailWrap> calculateDiscountInfo(Id customerId, Set<Id> itemGroupIds){
        //map<itemGroup, unitPrice>
        Map<Id, ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomPriceMap = new Map<Id, ASI_CRM_Item_Group_Customer_Price__c>();

        //get price and discount id
        Set<String> priceAndDiscountIds = getItemGroupBasePriceAndAllDiscount(customerId, itemGroupIds, itemGroupCustomPriceMap);
        
        return getPriceDiscountDetailWraps(priceAndDiscountIds, itemGroupCustomPriceMap, itemGroupIds);
    }

    //param : customerId,itemgroupIds
    //return : Map<itemgroupId, unitPriceWithVat>
    public static Map<Id, Decimal> getItemGroupUnitPriceWithVat(Id customerId, Set<Id> itemgroupIds){
        Map<Id, Decimal> itemGroupUnitPriceMap = new Map<Id, Decimal>();
        Decimal taxRate = getCNTaxRate();
         //query parent outlet
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id, ASI_CRM_CN_Parent_Outlet__c 
                                                 FROM ASI_CRM_AccountsAdditionalField__c 
                                                WHERE Id = : customerId];

        for (ASI_CRM_Item_Group_Customer_Price__c customerPrice : [SELECT Id, ASI_CRM_Item_Group__c,
                                                                          ASI_CRM_Customer__c,
                                                                          ASI_CRM_Unit_Price_BT__c
                                                                     FROM ASI_CRM_Item_Group_Customer_Price__c
                                                                    WHERE (ASI_CRM_Customer__c = :customerId 
                                                                           OR ASI_CRM_Customer__c = :customer.ASI_CRM_CN_Parent_Outlet__c)
                                                                      AND ASI_CRM_Customer__c != null
                                                                      AND ASI_CRM_Item_Group__c IN:itemgroupIds]){
            if (!itemGroupUnitPriceMap.containsKey(customerPrice.ASI_CRM_Item_Group__c) 
                || (customerPrice.ASI_CRM_Customer__c == customerId && itemGroupUnitPriceMap.containsKey(customerPrice.ASI_CRM_Item_Group__c))) {
                itemGroupUnitPriceMap.put(customerPrice.ASI_CRM_Item_Group__c, (customerPrice.ASI_CRM_Unit_Price_BT__c)*(1+taxRate));
            }
        }

        for (Id itemgroupId : itemgroupIds) {
            //item group is not queried and set to 0
            if (!itemGroupUnitPriceMap.containsKey(itemgroupId)) {
                itemGroupUnitPriceMap.put(itemgroupId, 0);
            }
        }

        return itemGroupUnitPriceMap;
    }

    public static Map<Id, WSPriceWrap> getWSItemGroupPriceMap(List<PriceDiscountDetailWrap> priceDiscountDetailWraps){
        Map<Id, WSPriceWrap> wsItemGroupPriceMap = new Map<Id, WSPriceWrap>();

        for (PriceDiscountDetailWrap priceDiscountDetailWrap : priceDiscountDetailWraps) {
            String itemGroupId = priceDiscountDetailWrap.priceAndDiscountDetail.ASI_CRM_Item_Group_Description__c;
            if (!wsItemGroupPriceMap.containsKey(itemGroupId)) {
                WSPriceWrap wsPriceInfo = new WSPriceWrap();
                wsPriceInfo.customerPriceId = priceDiscountDetailWrap.customerPrice.Id;
                wsPriceInfo.unitPriceNoVat = priceDiscountDetailWrap.customerPrice != null ? priceDiscountDetailWrap.customerPrice.ASI_CRM_Unit_Price_BT__c : 0;
                wsPriceInfo.unitPriceWithVat = priceDiscountDetailWrap.unitPriceWithVat;
                wsPriceInfo.discountedPrice = wsPriceInfo.unitPriceWithVat;
                wsPriceInfo.discountPercent = 0;
                wsPriceInfo.promotionPercent = 0;
                wsItemGroupPriceMap.put(itemGroupId, wsPriceInfo);
            }
            wsItemGroupPriceMap.get(itemGroupId).discountPercent += priceDiscountDetailWrap.discountPercent;
            wsItemGroupPriceMap.get(itemGroupId).promotionPercent += priceDiscountDetailWrap.promotionPercent;
            wsItemGroupPriceMap.get(itemGroupId).discountedPrice = (wsItemGroupPriceMap.get(itemGroupId).unitPriceWithVat * (1 - (wsItemGroupPriceMap.get(itemGroupId).promotionPercent/100)) * (1 - (wsItemGroupPriceMap.get(itemGroupId).discountPercent)/100)).setScale(4);
        }
        System.debug(LoggingLevel.INFO, '*** : wsItemGroupPriceMap' + wsItemGroupPriceMap);
        return wsItemGroupPriceMap;
    }

    public static List<PriceDiscountDetailWrap> getPriceDiscountDetailWraps(Set<String> priceAndDiscountIds, Map<Id, ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomPriceMap, Set<Id> itemGroupIds){
        List<PriceDiscountDetailWrap> priceDiscountDetailWraps = new List<PriceDiscountDetailWrap>();
        if (priceAndDiscountIds.isEmpty()) {
            return priceDiscountDetailWraps;
        }
        Decimal taxRate = getCNTaxRate();
        List<ASI_CRM_Price_And_Discount_Detail__c> priceAndDiscountDetailList = [SELECT id
                                                                       , ASI_CRM_Promotion_Code__c 
                                                                       , ASI_CRM_Promotion_Code__r.ASI_CRM_Type__c 
                                                                       , ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c 
                                                                       , ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c 
                                                                       , ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c
                                                                       , ASI_CRM_Item_Group_Description__c
                                                                       , ASI_CTY_CN_WS_Level1_Promotion_Code__c
                                                                       , ASI_CTY_CN_WS_Value_Type__c
                                                                       , ASI_CTY_CN_WS_Disount_Value__c
                                                                       , ASI_CRM_Price_And_Discount__r.RecordType.Name
                                                                       FROM ASI_CRM_Price_And_Discount_Detail__c
                                                                       WHERE ASI_CRM_Item_Group_Description__c IN : itemGroupIds
                                                                         AND ASI_CRM_Price_And_Discount__c IN:priceAndDiscountIds];
        for (ASI_CRM_Price_And_Discount_Detail__c priceDiscountDetail : priceAndDiscountDetailList) {
            priceDiscountDetailWraps.add(calculateDiscountPrice(priceDiscountDetail, itemGroupCustomPriceMap, taxRate));
        }

        return priceDiscountDetailWraps;
    }

    public static Decimal getCNTaxRate(){
        //query new tax
        List<ASI_CRM_CN_Tax_Rate_Config__c> taxRateList = new List<ASI_CRM_CN_Tax_Rate_Config__c>([SELECT Id,ASI_CRM_CN_Tax_Rate__c FROM ASI_CRM_CN_Tax_Rate_Config__c ORDER BY ASI_CRM_CN_Effective_From__c DESC]);
        Decimal taxRate = 0.13;//cn default
        if (!taxRateList.isEmpty()) {
          taxRate = taxRateList[0].ASI_CRM_CN_Tax_Rate__c/100;
        }
        return taxRate;
    }


    private static PriceDiscountDetailWrap calculateDiscountPrice(ASI_CRM_Price_And_Discount_Detail__c priceDiscountDetail, Map<Id, ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomPriceMap, Decimal taxRate) {
        PriceDiscountDetailWrap priceDiscountDetailWrap = new PriceDiscountDetailWrap();
        ASI_CRM_Item_Group_Customer_Price__c customerPrice = itemGroupCustomPriceMap.get(priceDiscountDetail.ASI_CRM_Item_Group_Description__c);
        Decimal unitPriceWithVat = customerPrice != null ? customerPrice.ASI_CRM_Unit_Price_BT__c * (1 + taxRate) : 0;
        priceDiscountDetailWrap.priceAndDiscountDetail = priceDiscountDetail;
        priceDiscountDetailWrap.customerPrice = customerPrice;
        priceDiscountDetailWrap.unitPriceWithVat = unitPriceWithVat;
        //trade a&p discount,normal discount, a&d discount
        if (priceDiscountDetail.ASI_CRM_Price_And_Discount__r.RecordType.Name.contains(PD_RECORDTYPE_TRADE_A_P) 
            || priceDiscountDetail.ASI_CRM_Price_And_Discount__r.RecordType.Name.contains(PD_RECORDTYPE_NORMAL)
            || priceDiscountDetail.ASI_CRM_Price_And_Discount__r.RecordType.Name.contains(PD_RECORDTYPE_AD)) {
            if (priceDiscountDetail.ASI_CTY_CN_WS_Value_Type__c == VALUE_TYPE_PERCENT){// % base price
                priceDiscountDetailWrap.discountPercent = priceDiscountDetail.ASI_CTY_CN_WS_Disount_Value__c;
                Decimal discountPrice = priceDiscountDetailWrap.discountPercent / 100 * unitPriceWithVat;
                priceDiscountDetailWrap.discountPrice = discountPrice.setScale(4);
            } else {// add a amount
                priceDiscountDetailWrap.discountPrice = priceDiscountDetail.ASI_CTY_CN_WS_Disount_Value__c;
                Decimal discountPercent = priceDiscountDetailWrap.discountPrice.divide(unitPriceWithVat, 6);
                priceDiscountDetailWrap.discountPercent = discountPercent;
            }
            priceDiscountDetailWrap.promotionPercent = 0;
        } else {//price discount
            if (priceDiscountDetail.ASI_CRM_Promotion_Code__r.ASI_CRM_Type__c == PROMOTION_MASTER_TYPE_DISCOUNT) {//discount
                priceDiscountDetailWrap.promotionPercent = priceDiscountDetail.ASI_CRM_Promotion_Code__r.ASI_CRM_Discount__c;
                Decimal discountPrice = priceDiscountDetailWrap.promotionPercent / 100 * unitPriceWithVat;
                priceDiscountDetailWrap.discountPrice = discountPrice.setScale(4);
            } else {//BUY X GET Y
                priceDiscountDetailWrap.discountPrice = 0;
                Decimal discountPercent = priceDiscountDetail.ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c.divide((priceDiscountDetail.ASI_CRM_Promotion_Code__r.ASI_CRM_Buy_X__c + priceDiscountDetail.ASI_CRM_Promotion_Code__r.ASI_CRM_Get_Y__c), 6);
                priceDiscountDetailWrap.promotionPercent = discountPercent;
            }
            priceDiscountDetailWrap.discountPercent = 0 ;
        }
        return priceDiscountDetailWrap;
    }

    //get all price and discount id
    private static Set<String> getItemGroupBasePriceAndAllDiscount(String customerId, Set<Id> itemGroupIds,Map<Id, ASI_CRM_Item_Group_Customer_Price__c> itemGroupCustomPriceMap) {
        //query parent outlet
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id, ASI_CRM_CN_Parent_Outlet__c 
                                                 FROM ASI_CRM_AccountsAdditionalField__c 
                                                WHERE Id = : customerId];

        Map<Id, String> itemGroupPriceDiscountMap = new Map<Id, String>();
        Map<Id, String> itemGroupTradeAPDiscountMap = new Map<Id, String>();
        Map<Id, String> itemGroupNormalDiscountMap = new Map<Id, String>();
        Map<Id, String> itemGroupADDiscountMap = new Map<Id, String>();


        Set<String> priceAndDiscountIds = new Set<String>();

        for (ASI_CRM_Item_Group_Customer_Price__c customerPrice : [SELECT Id,
                                                                          ASI_CRM_Price_And_Discount__c , 
                                                                          ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c,
                                                                          ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c,
                                                                          ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c,
                                                                          ASI_CTY_CN_WS_Trade_a_p_Discount__c, 
                                                                          ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Effective_To__c,
                                                                          ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Effective_From__c,
                                                                          ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Status__c,
                                                                          ASI_CTY_CN_WS_Normal_Discount__c, 
                                                                          ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Effective_To__c,
                                                                          ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Effective_From__c,
                                                                          ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Status__c,
                                                                          ASI_CTY_CN_WS_AD_Discount__c, 
                                                                          ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Effective_To__c,
                                                                          ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Effective_From__c,
                                                                          ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Status__c,
                                                                          ASI_CRM_Item_Group__c,ASI_CRM_Customer__c,
                                                                          ASI_CRM_Unit_Price_BT__c
                                                                     FROM ASI_CRM_Item_Group_Customer_Price__c
                                                                    WHERE (ASI_CRM_Customer__c = :customerId 
                                                                           OR ASI_CRM_Customer__c = :customer.ASI_CRM_CN_Parent_Outlet__c)
                                                                      AND ASI_CRM_Item_Group__c IN:itemGroupIds
                                                                      AND ASI_CRM_Customer__c != null 
                                                                      AND ASI_CRM_Item_Group__c != null]){
            System.debug(LoggingLevel.INFO, '*** customerPrice.Id: ' + customerPrice.Id);
            if (!itemGroupCustomPriceMap.containsKey(customerPrice.ASI_CRM_Item_Group__c) 
                || (customerPrice.ASI_CRM_Customer__c == customerId && itemGroupCustomPriceMap.containsKey(customerPrice.ASI_CRM_Item_Group__c))) {
                itemGroupCustomPriceMap.put(customerPrice.ASI_CRM_Item_Group__c, customerPrice);
            }

            if (customerPrice.ASI_CRM_Price_And_Discount__c != null && pdPassStatus.contains(customerPrice.ASI_CRM_Price_And_Discount__r.ASI_CRM_Status__c)
                 && customerPrice.ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_To__c >= Date.today()
                 && customerPrice.ASI_CRM_Price_And_Discount__r.ASI_CRM_Effective_From__c <= Date.today()) {
                if (!itemGroupPriceDiscountMap.containsKey(customerPrice.ASI_CRM_Item_Group__c) 
                    || (customerPrice.ASI_CRM_Customer__c == customerId && itemGroupPriceDiscountMap.containsKey(customerPrice.ASI_CRM_Item_Group__c))) {
                    itemGroupPriceDiscountMap.put(customerPrice.ASI_CRM_Item_Group__c, customerPrice.ASI_CRM_Price_And_Discount__c);
                }
            }

            if (customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__c != null && pdPassStatus.contains(customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Status__c)
                && customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Effective_To__c >= Date.today()
                 && customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__r.ASI_CRM_Effective_From__c <= Date.today()) {
                if (!itemGroupTradeAPDiscountMap.containsKey(customerPrice.ASI_CRM_Item_Group__c) 
                    || (customerPrice.ASI_CRM_Customer__c == customerId && itemGroupTradeAPDiscountMap.containsKey(customerPrice.ASI_CRM_Item_Group__c))) {
                    itemGroupTradeAPDiscountMap.put(customerPrice.ASI_CRM_Item_Group__c, customerPrice.ASI_CTY_CN_WS_Trade_a_p_Discount__c);
                }
            }

            if (customerPrice.ASI_CTY_CN_WS_Normal_Discount__c != null && pdPassStatus.contains(customerPrice.ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Status__c)
                && customerPrice.ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Effective_To__c >= Date.today() 
                 && customerPrice.ASI_CTY_CN_WS_Normal_Discount__r.ASI_CRM_Effective_From__c <= Date.today()) {
                if (!itemGroupNormalDiscountMap.containsKey(customerPrice.ASI_CRM_Item_Group__c) 
                    || (customerPrice.ASI_CRM_Customer__c == customerId && itemGroupNormalDiscountMap.containsKey(customerPrice.ASI_CRM_Item_Group__c))) {
                    itemGroupNormalDiscountMap.put(customerPrice.ASI_CRM_Item_Group__c, customerPrice.ASI_CTY_CN_WS_Normal_Discount__c);
                }
            }

            if (customerPrice.ASI_CTY_CN_WS_AD_Discount__c != null && pdPassStatus.contains(customerPrice.ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Status__c)
                && customerPrice.ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Effective_To__c >= Date.today() 
                 && customerPrice.ASI_CTY_CN_WS_AD_Discount__r.ASI_CRM_Effective_From__c <= Date.today()) {
                if (!itemGroupADDiscountMap.containsKey(customerPrice.ASI_CRM_Item_Group__c) 
                    || (customerPrice.ASI_CRM_Customer__c == customerId && itemGroupADDiscountMap.containsKey(customerPrice.ASI_CRM_Item_Group__c))) {
                    itemGroupADDiscountMap.put(customerPrice.ASI_CRM_Item_Group__c, customerPrice.ASI_CTY_CN_WS_AD_Discount__c);
                }
            }
        }

        priceAndDiscountIds.addAll(itemGroupPriceDiscountMap.values());
        priceAndDiscountIds.addAll(itemGroupTradeAPDiscountMap.values());
        priceAndDiscountIds.addAll(itemGroupNormalDiscountMap.values());
        priceAndDiscountIds.addAll(itemGroupADDiscountMap.values());
        System.debug(LoggingLevel.INFO, '*** priceAndDiscountIds: ' + priceAndDiscountIds);
        return priceAndDiscountIds;
    }

    public class PriceDiscountDetailWrap{
        public ASI_CRM_Price_And_Discount_Detail__c priceAndDiscountDetail ;
        public ASI_CRM_Item_Group_Customer_Price__c customerPrice ;
        public Decimal unitPriceWithVat ;
        public Decimal discountPrice ;
        public Decimal discountPercent ;
        public Decimal promotionPercent;
    }

    public class WSPriceWrap{
        public Id customerPriceId {get;set;}
        public Decimal discountedPrice {get;set;}
        public Decimal unitPriceNoVat {get;set;}
        public Decimal unitPriceWithVat {get;set;}
        public Decimal discountPercent {get;set;}
        public Decimal promotionPercent {get;set;}
    }

    /*
    * Method Name: getAccountId
    * Description: Obtain the corresponding Account Id of current User.
    * Return Type: Id
    * Parameter  : 
    */
    @AuraEnabled
    public static Id getAccountId() {
        final String userId = UserInfo.getUserId(); 
        final List <User> usrs = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId];
        if (!usrs.isEmpty()) {
            return (usrs[0].Contact != null) ? usrs[0].Contact.AccountId : null;
        }
        return null;
    }
}
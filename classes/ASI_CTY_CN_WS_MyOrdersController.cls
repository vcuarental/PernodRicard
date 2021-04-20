/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_WS_MyOrdersController       
 * Test Class:  ASI_CTY_CN_WS_MyOrdersControllerTest
 * Description: Wholesaler Community My Orders Page Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-10-26       Sera                    Create AuraEnabled functions
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_WS_MyOrdersController {
    
    /*
    * Method Name: getOpenSOR
    * Description: Obtain the open SORs of current User.
    * Return Type: List<ASI_KOR_Sales_Order_Request__c>
    * Parameter  : 
    */
    @AuraEnabled
    public static List<ASI_KOR_Sales_Order_Request__c> getOpenSOR(){
        Id accountId = ASI_CTY_CN_WS_Utils.getAccountId();
        // System.debug('accountId : ' + accountId);
        if (String.isNotBlank(accountId)){
            return [SELECT Name, 
                        CreatedDate, 
                        ASI_CRM_SG_Order_Date__c, 
                        ASI_CTY_CN_WS_Total_Order_Qty_CA__c,
                        ASI_CTY_CN_WS_Total_Order_Amount__c, 
                        ASI_CTY_CN_WS_Status__c
                    FROM ASI_KOR_Sales_Order_Request__c
                    WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_SORCN
                    AND ASI_KOR_Order_Status__c = :ASI_CTY_CN_WS_Utils.STATUS_SOROPEN 
                    AND ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                    AND CreatedById = :UserInfo.getUserId()
                    ORDER BY createdDate DESC];
        }
        return null;
    }
    /*
    * Method Name: fetchSORs
    * Description: Obtain the SORs(exclude open) of current User.
    * Return Type: List<ASI_KOR_Sales_Order_Request__c>
    * Parameter  : String startDate, String endDate
    */
    @AuraEnabled
    public static List<SORWrapper> fetchSORs(String startDate, String endDate) {
        System.debug(LoggingLevel.INFO, '*** startDate: ' + startDate);
        System.debug(LoggingLevel.INFO, '*** endDate: ' + endDate);

        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);
        if(Date.today() < orgFiscalYear){
            orgFiscalYear = orgFiscalYear.addYears(-1);
        }
        // System.debug(LoggingLevel.INFO, '*** orgFiscalYear: ' + orgFiscalYear);

        Id accountId = ASI_CTY_CN_WS_Utils.getAccountId();
        // System.debug('accountId : ' + accountId);

        if (String.isNotBlank(accountId)){
            String soql = '';
            // String tovRT = ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCN;
            soql += 'SELECT Id, Name, ASI_CRM_SG_Order_Date__c, ASI_CTY_CN_WS_Total_Order_Qty_CA__c, ASI_KOR_Total_Sales_Amount__c, ASI_KOR_Order_Status__c, ASI_CTY_CN_WS_Status__c, ASI_CTY_CN_WS_Total_Order_Amount__c, ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c, ASI_CTY_CN_WS_Discount_Amount_With_VAT__c, ';
            soql += ' (SELECT Id, ASI_CRM_SF_SO_Request_Number__c, ASI_CRM_SO_Number__c, ASI_CRM_Status__c, ASI_CTY_CN_WS_Status__c, ASI_CTY_CN_WS_Total_Order_Qty_CA__c, ASI_CRM_Total_Number_of_Line__c, ASI_MFM_Total_Amount_wTax__c, RecordType.DeveloperName FROM TOVs__r) ';
            soql += ' FROM ASI_KOR_Sales_Order_Request__c';
            
            String soqlWhere = '';

            String sorRT = ASI_CTY_CN_WS_Utils.RTDEVNAME_SORCN;
            String sorRT_RO = ASI_CTY_CN_WS_Utils.RTDEVNAME_SORCNRO;
            soqlWhere += ' WHERE (RecordType.DeveloperName = :sorRT OR RecordType.DeveloperName = :sorRT_RO)';
            
            String openStatus = ASI_CTY_CN_WS_Utils.STATUS_SOROPEN;
            soqlWhere += ' AND ASI_KOR_Order_Status__c != :openStatus ';

            soqlWhere += ' AND ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId ';
            
            // String userId = UserInfo.getUserId();
            // if(!Test.isRunningTest()) {
            //     soqlWhere += ' AND CreatedById = :userId ';
            // }
            
            if (String.isNotBlank(startDate)){
                Date startD = Date.valueOf(startDate);
                // System.debug(LoggingLevel.INFO, '*** startD: ' + startD);
                soqlWhere += ' AND ASI_CRM_SG_Order_Date__c >= :startD ';
            }
            if (String.isNotBlank(endDate)){
                Date endD = Date.valueOf(endDate);
                // System.debug(LoggingLevel.INFO, '*** endD: ' + endD);
                soqlWhere += ' AND ASI_CRM_SG_Order_Date__c <= :endD ';
            }
            if(String.isBlank(startDate) && String.isBlank(endDate)){
                soqlWhere += ' AND ASI_CRM_SG_Order_Date__c >= :orgFiscalYear ';
            }

            soql += soqlWhere;
            System.debug(LoggingLevel.INFO, '*** soql: ' + soql);
            List<ASI_KOR_Sales_Order_Request__c> sorList = Database.query(soql);

            // For payable amount calculation added by jack
            Map<String, ASI_KOR_Sales_Order_Request__c> orderMap = new Map<String, ASI_KOR_Sales_Order_Request__c>();
            for (ASI_KOR_Sales_Order_Request__c sor : sorList) {
                orderMap.put(sor.Id, sor);
            }
            Map<String, List<ASI_CRM_TOV_Detail__c>> sorIdTOVDetailMap = new Map<String, List<ASI_CRM_TOV_Detail__c>>();
            for (ASI_CRM_TOV_Detail__c tovd : [SELECT ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Promotion_Rate__c,
                                                      ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CTY_CN_WS_Disount_Rate__c,
                                                      ASI_CRM_SF_SO_Request_Line_Number__r.ASI_KOR_Sales_Order_Request__c,
                                                      ASI_CRM_SF_SO_Request_Line_Number__r.ASI_CRM_CN_Unit_Price_BT_with_VAT__c,
                                                      ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                      ASI_CRM_SF_SO_Price_BT__c,
                                                      ASI_CTY_CN_WS_Order_Qty_BT__c,
                                                      ASI_CRM_CN_Copy_SUM__c,
                                                      ASI_CRM_TOV__r.RecordType.DeveloperName,
                                                      ASI_CRM_TOV__r.ASI_CRM_SO_Number__c
                                               FROM ASI_CRM_TOV_Detail__c
                                               WHERE ASI_CRM_SF_SO_Request_Line_Number__r.ASI_KOR_Sales_Order_Request__c IN :orderMap.keySet()]) {
                String sorId = tovd.ASI_CRM_SF_SO_Request_Line_Number__r.ASI_KOR_Sales_Order_Request__c;
                if (sorIdTOVDetailMap.containsKey(sorId)) {
                    sorIdTOVDetailMap.get(sorId).add(tovd);
                } else {
                    sorIdTOVDetailMap.put(sorId, new List<ASI_CRM_TOV_Detail__c>{tovd});
                }
            }
            List<SORWrapper> sorWapList = new List<SORWrapper>();
            for (String sorId : orderMap.keySet()) {
                SORWrapper sorw = new SORWrapper();
                sorw.salesOrder = orderMap.get(sorId);
                sorw.tovDetails = sorIdTOVDetailMap.get(sorId);
                sorWapList.add(sorw);
            }
            return sorWapList;
        }
        return null;
    }

    class SORWrapper{
        @AuraEnabled
        public ASI_KOR_Sales_Order_Request__c salesOrder;
        @AuraEnabled
        public List<ASI_CRM_TOV_Detail__c> tovDetails;
    }
    /*
    * Method Name: deleteOpenSOR
    * Description: delete the corresponding SOR according to orderId.
    * Return Type: void
    * Parameter  : String orderId
    */
    @AuraEnabled
    public static void deleteOpenSOR(String orderId) {
        System.debug(LoggingLevel.INFO, '*** orderId: ' + orderId);
        delete [SELECT Id FROM ASI_KOR_Sales_Order_Request__c WHERE Id = :orderId];
    }
    /*
    * Method Name: fetchRefundTOVs
    * Description: Obtain refund TOVs of current User.
    * Return Type: List<RefundTOVWrap>
    * Parameter  : 
    */
    @AuraEnabled
    public static List<RefundTOVWrap> fetchRefundTOVs() {
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);
        if(Date.today() < orgFiscalYear){
            orgFiscalYear = orgFiscalYear.addYears(-1);
        }
        // System.debug(LoggingLevel.INFO, '*** orgFiscalYear: ' + orgFiscalYear);
        
        Id accountId = ASI_CTY_CN_WS_Utils.getAccountId();
        // System.debug('accountId : ' + accountId);
        if (String.isNotBlank(accountId)){
            List<AggregateResult> refundTOVResults =  [SELECT ASI_CRM_TOV__r.ASI_CRM_SO_Number__c tovNo,
                                                            ASI_CRM_SKU__c skuCode,
                                                            Max(CreatedDate) createdDate,
                                                            Max(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c) orderDate,
                                                            Sum(ASI_CTY_CN_WS_Order_Qty_CA__c) qty, 
                                                            Sum(ASI_CTY_CN_WS_Amount__c) amount
                                                        FROM ASI_CRM_TOV_Detail__c 
                                                        WHERE ASI_CRM_TOV__r.RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCNFINAL
                                                        AND ASI_CRM_TOV__r.ASI_CRM_SO_Type__c = :ASI_CTY_CN_WS_Utils.TYPE_TOVV2
                                                        AND ASI_CRM_SF_SO_Request_Line_Number__r.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                                                        AND CreatedDate >= :orgFiscalYear
                                                        GROUP BY ASI_CRM_TOV__r.ASI_CRM_SO_Number__c, ASI_CRM_SKU__c
                                                        ORDER BY Max(CreatedDate) DESC];
            List<RefundTOVWrap> refundTOVWrapList = new List<RefundTOVWrap>();
            // System.debug(LoggingLevel.INFO, '*** refundTOVResults: ' + refundTOVResults);
            for (AggregateResult refundTOVAgg : refundTOVResults) {
                RefundTOVWrap refundTOV = new RefundTOVWrap();
                refundTOV.tovNo = String.valueOf(refundTOVAgg.get('tovNo'));
                refundTOV.skuCode = String.valueOf(refundTOVAgg.get('skuCode'));
                refundTOV.qty = (Double)refundTOVAgg.get('qty');
                refundTOV.amount = (Decimal)refundTOVAgg.get('amount');
                refundTOV.createdDate = Date.valueOf(refundTOVAgg.get('createdDate'));
                refundTOV.orderDate = Date.valueOf(refundTOVAgg.get('orderDate'));
                refundTOVWrapList.add(refundTOV);
            }
            // System.debug(LoggingLevel.INFO, '*** refundTOVWrapList: ' + refundTOVWrapList);
            return refundTOVWrapList;
        }
        return null;
    }
    /*
    * Method Name: fetchHeldTOVs
    * Description: Obtain held TOVs of current User.
    * Return Type: List<ASI_CRM_TOV__c>
    * Parameter  : 
    */
    @AuraEnabled
    public static List<ASI_CRM_TOV__c> fetchHeldTOVs() {
        Id accountId = ASI_CTY_CN_WS_Utils.getAccountId();
        // System.debug('accountId : ' + accountId);
        if (String.isNotBlank(accountId)){
            List<ASI_CRM_TOV__c> heldTOVs = [SELECT Id, 
                                                    ASI_CRM_SO_Number__c, 
                                                    ASI_CRM_Status__c, 
                                                    ASI_CTY_CN_WS_Status__c, 
                                                    ASI_CTY_CN_WS_Total_Order_Qty_CA__c, 
                                                    ASI_CRM_Total_Number_of_Line__c, 
                                                    ASI_MFM_Total_Amount_wTax__c,
                                                    ASI_CRM_SF_SO_Request_Number__c,
                                                    ASI_CRM_SF_SO_Request_Number__r.Name,
                                                    ASI_CRM_Order_Date__c 
                                                FROM ASI_CRM_TOV__c 
                                                WHERE RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVCN
                                                AND ASI_CRM_Status__c = :ASI_CTY_CN_WS_Utils.STATUS_TOVHELD
                                                AND ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId];
            // System.debug(LoggingLevel.INFO, '*** heldTOVs: ' + heldTOVs);
            return heldTOVs;
        }
        return null;
    }

    @AuraEnabled
    public static String copySalesOrder(String sorId) {
        List<ASI_KOR_Sales_Order_Request__c> openSor = getOpenSOR();
        if (!openSor.isEmpty()) return 'hasOpenSor';

        List<ASI_KOR_Sales_Order_Request__c> sorlist = [SELECT Name, ASI_CRM_CN_Address__c, ASI_CRM_CN_Contact_Person__c,
                                                            ASI_CRM_CN_Order_Number__c, ASI_CRM_CN_Tel_Mobile__c, ASI_CTY_CN_WS_Status__c,
                                                             ASI_CRM_CN_Total_Qty__c, ASI_CRM_CN_Other_Requirement__c,ASI_CRM_SG_Order_Date__c,
                                                            ASI_CRM_CN_Customer__r.Name, ASI_KOR_Order_Status__c,ASI_KOR_Sales_Amount__c,
                                                            ASI_CRM_CN_Customer__c,RecordTypeId
                                                    FROM ASI_KOR_Sales_Order_Request__c
                                                    WHERE Id = :sorId];
        
        Set<Id> orderFormIds = new Set<Id>();
        for(ASI_CRM_Order_Form_Customer_Relationship__c ofcr:[SELECT Name, ASI_CRM_Order_Form__c 
                                                                FROM ASI_CRM_Order_Form_Customer_Relationship__c 
                                                                WHERE ASI_CRM_Customer__c = :sorlist[0].ASI_CRM_CN_Customer__c]){ 
            orderFormIds.add(ofcr.ASI_CRM_Order_Form__c);
        }
        // Query order form detail
        List<ASI_CRM_Order_Form_Detail__c> formDetailList = [SELECT Name,ASI_CRM_Product_Name__c
                                                             FROM ASI_CRM_Order_Form_Detail__c 
                                                             WHERE ASI_CRM_Order_Form__c IN: orderFormIds 
                                                             AND ASI_CRM_Order_Form__r.ASI_CRM_Order_Form_Type__c='Premium'];
        Set<Id> itemGroupIds = new Set<Id>();
        for (ASI_CRM_Order_Form_Detail__c formDetail : formDetailList) {
            itemGroupIds.add(formDetail.ASI_CRM_Product_Name__c);
        }

         List<ASI_KOR_Sales_Order_Transaction__c> orderItems = [SELECT ASI_CRM_CN_Sales_Oder_TOV__c,
                                                                    ASI_CRM_CN_Sales_Oder_TOV__r.ASI_CRM_SO_Number__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c,
                                                                    ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c,
                                                                    ASI_CRM_CN_Promotion_Code__r.ASI_CRM_Discount__c,
                                                                    ASI_CRM_CN_Promotion_Code__r.Name,
                                                                    ASI_CRM_CN_Product_Name__c,
                                                                    ASI_CTY_CN_WS_Item_Final_Amount_With_VAT__c,
                                                                    ASI_CTY_CN_WS_Promotion_Rate__c,
                                                                    ASI_CTY_CN_WS_Disount_Rate__c,
                                                                    ASI_KOR_Order_Qty__c,
                                                                    ASI_CRM_CN_Qty_9L__c,
                                                                    ASI_CRM_CN_UOM__c,
                                                                    ASI_CRM_CN_Promotion_Code__c,
                                                                    ASI_CRM_CN_Free_Qty_BT__c,
                                                                    ASI_CRM_CN_Released_Qty__c,
                                                                    ASI_CRM_CN_Unit_Price_BT_with_VAT__c,
                                                                    ASI_CRM_MOT_Promotion_Price_non_VAT__c,
                                                                    ASI_CRM_MOT_Price_non_VAT__c,
                                                                    ASI_CRM_CN_Logistics_Remark__c,
                                                                    ASI_CRM_UOM_Text__c,
                                                                    RecordTypeId
                                                                FROM ASI_KOR_Sales_Order_Transaction__c
                                                                WHERE ASI_KOR_Sales_Order_Request__c = :sorId
                                                                AND ASI_CRM_CN_Product_Name__c IN :itemGroupIds];
        ASI_KOR_Sales_Order_Request__c newSor = sorlist[0].clone();
        newSor.ASI_KOR_Order_Status__c = 'Open';
        newSor.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder');
        insert newSor;
        List<ASI_KOR_Sales_Order_Transaction__c> newSorItems = orderItems.deepClone();
        for (ASI_KOR_Sales_Order_Transaction__c sorItem : newSorItems) {
            sorItem.ASI_KOR_Sales_Order_Request__c = newSor.Id;
            sorItem.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item');
        }
        insert newSorItems;
        return newSor.Id;
    }
    /*
    * Method Name: getSORDetails
    * Description: Obtain SOR Details Information for download as CSV.
    * Return Type: List<List<String>>
    * Parameter  : String startDate, String endDate
    */
    @AuraEnabled
    public static List<List<String>> getSORDetails(String startDate, String endDate) {
        List<List<String>> uploadtemp = new List<List<String>>();
        ASI_CRM_CN_CustomSetting__c customSetting = ASI_CRM_CN_CustomSetting__c.getInstance();

        List<String> tempTitle = new List<String>();
        if (NULL != customSetting) {
            if(String.isNotBlank(customSetting.ASI_CTY_CN_WS_Download_SOR_Item_Header__c)){
                tempTitle = customSetting.ASI_CTY_CN_WS_Download_SOR_Item_Header__c.split(',');
            }
        }
                                              
        uploadtemp.add(tempTitle);

        List<SORWrapper> sors = fetchSORs(startDate, endDate);
        // System.debug(LoggingLevel.INFO, '*** sors: ' + sors);
        Set<String> sorIds = new Set<String>();
        if(sors.size() > 0){
            for(SORWrapper sor : sors){
                sorIds.add(sor.salesOrder.Id);
            }
        }
        // System.debug(LoggingLevel.INFO, '*** sorIds: ' + sorIds);
        List<ASI_KOR_Sales_Order_Transaction__c> orderItems = [SELECT ASI_CRM_CN_Sales_Oder_TOV__c,
                                                                        ASI_CRM_CN_Sales_Oder_TOV__r.ASI_CRM_SO_Number__c,
                                                                        ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c,
                                                                        ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c,
                                                                        ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c,
                                                                        ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c,
                                                                        ASI_KOR_Order_Qty__c,
                                                                        ASI_CRM_CN_Qty_9L__c,
                                                                        ASI_CTY_CN_WS_Order_Qty_CA__c,
                                                                        ASI_CRM_CN_UOM__c,
                                                                        ASI_CTY_CN_WS_Actual_Unit_Price__c,
                                                                        ASI_CTY_CN_WS_Disount_Rate__c,
                                                                        ASI_CTY_CN_WS_Promotion_Rate__c,
                                                                        ASI_CRM_CN_Promotion_Code__r.Name,
                                                                        ASI_CRM_CN_Free_Qty_BT__c,
                                                                        ASI_CRM_CN_Released_Qty__c,
                                                                        ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c,
                                                                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c,
                                                                        ASI_CRM_MOT_Promotion_Price_non_VAT__c,
                                                                        ASI_CRM_MOT_Price_non_VAT__c,
                                                                        ASI_CRM_CN_Logistics_Remark__c,
                                                                        ASI_KOR_Sales_Order_Request__r.Name,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Status__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Contact_Person__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Tel_Mobile__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Total_Order_Qty_CA__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Other_Requirement__c,
                                                                        ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Address__c
                                                                    FROM ASI_KOR_Sales_Order_Transaction__c 
                                                                    WHERE ASI_KOR_Sales_Order_Request__c IN :sorIds
                                                                    AND RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_SORITEMCN];
        Set<String> orderItemIds = new Set<String>();
        for(ASI_KOR_Sales_Order_Transaction__c orderItem : orderItems){
            orderItemIds.add(orderItem.Id);
        }
        List<ASI_CRM_TOV_Detail__c> tovItems = [SELECT ASI_CRM_SF_SO_Request_Line_Number__c,
                                                        ASI_CRM_TOV__r.ASI_CRM_SO_Number__c                                             
                                                FROM ASI_CRM_TOV_Detail__c
                                                WHERE ASI_CRM_SF_SO_Request_Line_Number__c IN :orderItemIds
                                                AND RecordType.DeveloperName = :ASI_CTY_CN_WS_Utils.RTDEVNAME_TOVDETAILCN];
        Map<String, String> tovSORItemMap = new Map<String, String>();
        for(ASI_CRM_TOV_Detail__c tovItem : tovItems){
            tovSORItemMap.put(tovItem.ASI_CRM_SF_SO_Request_Line_Number__c, tovItem.ASI_CRM_TOV__r.ASI_CRM_SO_Number__c);
        }
        for(ASI_KOR_Sales_Order_Transaction__c orderItem : orderItems){
            List<String> tembody = new List<String>();
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.Name == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.Name);
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Status__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Status__c);
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Contact_Person__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Contact_Person__c);
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Tel_Mobile__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Tel_Mobile__c);
            // tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Total_Order_Qty_CA__c == null ? '0' : String.valueOf(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CTY_CN_WS_Total_Order_Qty_CA__c));
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c == null ? '' : String.valueOf(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c));
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Other_Requirement__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Other_Requirement__c);
            tembody.add(orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Address__c == null ? '' : orderItem.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Address__c);
            tembody.add(tovSORItemMap.containsKey(orderItem.Id) ? tovSORItemMap.get(orderItem.Id) : '');
            String name = orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c == null ? '' : orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Chinese_Name__c;
            name += '\n' + orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c == null ? '' : orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Eng_Name__c;
            tembody.add(name);
            tembody.add(orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c == null ? '' : orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_pack__c);
            tembody.add(orderItem.ASI_CTY_CN_WS_Order_Qty_CA__c == null ? '0' : String.valueOf(orderItem.ASI_CTY_CN_WS_Order_Qty_CA__c));
            tembody.add(orderItem.ASI_CRM_CN_Released_Qty__c == null ? '0' : String.valueOf(orderItem.ASI_CRM_CN_Released_Qty__c));
            tembody.add(orderItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c == null ? '0' : String.valueOf(orderItem.ASI_CRM_CN_Unit_Price_BT_with_VAT__c.setScale(2)));
            tembody.add(orderItem.ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c == null ? '0' : String.valueOf(orderItem.ASI_CTY_CN_WS_Promotion_Amount_With_VAT__c));
            tembody.add(orderItem.ASI_CTY_CN_WS_Disount_Rate__c == null ? '0' : String.valueOf(orderItem.ASI_CTY_CN_WS_Disount_Rate__c));
            tembody.add(orderItem.ASI_CTY_CN_WS_Actual_Unit_Price__c == null ? '0' : String.valueOf(orderItem.ASI_CTY_CN_WS_Actual_Unit_Price__c.setScale(2)));
            Double packValue = orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c == null ? 0 : orderItem.ASI_CRM_CN_Product_Name__r.ASI_CRM_CN_Pack_Value__c;
            Double releasedQty = orderItem.ASI_CRM_CN_Released_Qty__c == null ? 0 : orderItem.ASI_CRM_CN_Released_Qty__c;
            Decimal actualPrice = orderItem.ASI_CTY_CN_WS_Actual_Unit_Price__c == null ? 0 : orderItem.ASI_CTY_CN_WS_Actual_Unit_Price__c;
            tembody.add(String.valueOf(packValue * releasedQty * actualPrice));
            uploadtemp.add(tembody);
        }
        return uploadtemp;
    }

    public class RefundTOVWrap{
        @AuraEnabled
        public String tovNo;
        @AuraEnabled
        public String skuCode;
        @AuraEnabled
        public Double qty;
        @AuraEnabled
        public Decimal amount;
        @AuraEnabled
        public Date createdDate;
        @AuraEnabled
        public Date orderDate;
    }

}
public without sharing class ASI_CTY_CN_WS_HomeDashboardController {


    @AuraEnabled
    public static List<WSDashboardOrderShow> getDefaultDashboardList(){
        //get the year and month that dashboard needs to display
        Map<String, List<String>> showYearMothMap = getShowYearMonth();
        //get WS account Id
        Id accountId = getAccountId();
        System.debug(LoggingLevel.INFO, '*** accountId: ' + accountId);
        //get Base show map
        Map<String, WSDashboardOrderShow> dbShowMap = getBaseShowMap(showYearMothMap);
        //getSOR
        getDBShowSOR(accountId, dbShowMap);
        //getTOV
        getDBShowTOV(accountId, dbShowMap);

        System.debug(LoggingLevel.INFO, '*** dbShowMap.values(): ' + dbShowMap.values());
        return dbShowMap.values();
    }

    @AuraEnabled
    public static List<WSDashboardHisShow> getDashboardHistoryList(){
        //get the year and month that dashboard needs to display
        Map<String, List<String>> showYearMothMap = getShowYearMonth();
        //get WS account Id
        Id accountId = getAccountId();
        System.debug(LoggingLevel.INFO, '*** accountId: ' + accountId);
        //get Base show map
        Map<String, WSDashboardHisShow> dbHisShowMap = getDBHistoryList(showYearMothMap);

        List<WSDashboardHisShow> result = getDBHisShow(accountId, dbHisShowMap);
        return result;
    }

    private static Map<String, WSDashboardOrderShow> getBaseShowMap(Map<String, List<String>> showYearMoths) {
        Set<String> showTypeList = new Set<String>{'NumberType', 'AmountType', 'CAType', '9LType'};
        
        Map<String, WSDashboardOrderShow> dbShowMap = new Map<String, WSDashboardOrderShow>();
        for (String year : showYearMoths.keySet()) {
             for (String month : showYearMoths.get(year)) {
                for (String showType : showTypeList) {
                    if (!dbShowMap.containsKey(year + month + showType)) {
                      WSDashboardOrderShow dbOrderShow = new WSDashboardOrderShow(showType, year, month);
                      dbShowMap.put(year + month + showType, dbOrderShow);
                    }
                }
            }
        }
        return dbShowMap;
    }

    public static Map<String, WSDashboardHisShow> getDBHistoryList(Map<String, List<String>> showYearMoths) {
        Map<String, WSDashboardHisShow> dbHisShowMap = new Map<String, WSDashboardHisShow>();
        Set<String> showTypeHisList = new Set<String>{'hisBTType', 'his9LType'};
        List<String> months = new List<String>();
        for (String year : showYearMoths.keySet()) {
            for (String month : showYearMoths.get(year)) {
                if (year == String.valueOf(Date.today().year()) && month == String.valueOf(Date.today().month())) {
                    continue;
                }
                months.add(month + '月');
                for (String showType : showTypeHisList) {
                    if (!dbHisShowMap.containsKey(showType)) {
                        WSDashboardHisShow dbHisOrderShow = new WSDashboardHisShow(showType, year, month);
                        dbHisShowMap.put(year + month + showType, dbHisOrderShow);
                    }
                }
            }
        }

        for (String key : dbHisShowMap.keySet()) {
            WSDashboardHisShow dbHisOrderShow = dbHisShowMap.get(key);
            dbHisOrderShow.months = months;
        }

        return dbHisShowMap;
    }

    public static List<WSDashboardHisShow> getDBHisShow(Id accountId, Map<String, WSDashboardHisShow> dbHisShowMap) {
        Set<Integer> fiscalYears = new Set<Integer>{Date.today().year(), Date.today().year() + 1};
        List<WSDashboardHisShow> results = new List<WSDashboardHisShow>();
        Set<String> showTypeHisList = new Set<String>{'hisBTType', 'his9LType'};
        //roll-up sub brand volume
        List<AggregateResult> subbrandResults = [SELECT ASI_CRM_Year__c year,
                                                       ASI_CRM_Month__c month,
                                                       ASI_CRM_Subbrand__r.ASI_HK_CRM_English_Name__c brandValue,
                                                       ASI_CRM_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c brandLabel,
                                                       SUM(ASI_CRM_PR_Direct_STD__c) offTakeBTAmount,
                                                       SUM(ASI_CRM_WS_INV_BTL__c) inventoryBTAmount,
                                                       SUM(ASI_CRM_PR_Direct__c) offTake9LAmount,
                                                       SUM(ASI_CRM_WS_INV__c) inventory9LAmount,
                                                       SUM(ASI_CRM_T2_DepletiontoT3__c) intake9LAmount,
                                                       SUM(ASI_CRM_T23_DepletiontoALL_BTL__c) intakeBTAmount
                                              FROM ASI_CRM_Subbrand_Volume__c
                                             WHERE ASI_CRM_Account__r.ASI_CRM_Account__c = :accountId
                                               AND FISCAL_YEAR(ASI_CRM_End_Date__c) IN:fiscalYears
                                               group by ASI_CRM_Year__c,ASI_CRM_Month__c,
                                                        ASI_CRM_Subbrand__r.ASI_HK_CRM_English_Name__c,
                                                        ASI_CRM_Subbrand__r.ASI_CRM_CN_CHI_NAME_C__c
                                               order by ASI_CRM_Year__c,ASI_CRM_Month__c];
        for (AggregateResult aggrResult : subbrandResults) {
            String year = String.valueOf(aggrResult.get('year'));
            String month = Integer.valueOf(aggrResult.get('month')) + '';
            String brandValue = String.valueOf(aggrResult.get('brandValue'));
            String brandLabel = String.valueOf(aggrResult.get('brandLabel'));

            Decimal intakeBTAmount = (Decimal)aggrResult.get('intakeBTAmount');
            Decimal intake9LAmount = (Decimal)aggrResult.get('intake9LAmount');
            Decimal inventoryBTAmount = (Decimal)aggrResult.get('inventoryBTAmount');
            Decimal inventory9LAmount = (Decimal)aggrResult.get('inventory9LAmount');
            Decimal offTakeBTAmount = (Decimal)aggrResult.get('offTakeBTAmount');
            Decimal offTake9LAmount = (Decimal)aggrResult.get('offTake9LAmount');

            getWSDBHisShowByType(results, dbHisShowMap, year, month, brandValue, brandLabel, intakeBTAmount, inventoryBTAmount, offTakeBTAmount, 'hisBTType');
            getWSDBHisShowByType(results, dbHisShowMap, year, month, brandValue, brandLabel, intake9LAmount, inventory9LAmount, offTake9LAmount, 'his9LType');
            
        }
        //results.addAll(dbHisShowMap.values());
        return results;
    }

    private static void getDBShowSOR(Id accountId, Map<String, WSDashboardOrderShow> dbShowMap) {
        Set<Integer> fiscalYears = new Set<Integer>{Date.today().year(), Date.today().year() + 1};
        Set<String> inApprovalSORStatus = new Set<String>{'Submitted','Pending for Order Advisor'};
        Set<String> approvedSORStatus = new Set<String>{'Approved','Processing','Closed'};
        //roll-up number&amount&9lNumber
        List<AggregateResult> sorResults = [SELECT ASI_KOR_Order_Status__c status, 
                                                   CALENDAR_YEAR(ASI_CRM_SG_Order_Date__c) year,
                                                   CALENDAR_MONTH(ASI_CRM_SG_Order_Date__c) month,
                                                   COUNT(Id) countNumber, 
                                                   SUM(ASI_CRM_CN_Total_order_Amt__c) totalAmount,
                                                   SUM(ASI_CRM_CN_Total_Order_Qty_9L__c) count9L
                                              FROM ASI_KOR_Sales_Order_Request__c
                                             WHERE ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                                               AND FISCAL_YEAR(ASI_CRM_SG_Order_Date__c) IN:fiscalYears
                                               AND (ASI_KOR_Order_Status__c IN:inApprovalSORStatus 
                                                    OR ASI_KOR_Order_Status__c IN:approvedSORStatus)
                                               group by ASI_KOR_Order_Status__c,
                                                        CALENDAR_YEAR(ASI_CRM_SG_Order_Date__c),
                                                        CALENDAR_MONTH(ASI_CRM_SG_Order_Date__c),
                                                        FISCAL_YEAR(ASI_CRM_SG_Order_Date__c)];
        for (AggregateResult aggrResult : sorResults) {
            String status = String.valueOf(aggrResult.get('status'));
            String year = String.valueOf(aggrResult.get('year'));
            String month = String.valueOf(aggrResult.get('month'));
            Decimal countNumber = (Decimal)aggrResult.get('countNumber');
            Decimal totalAmount = (Decimal)aggrResult.get('totalAmount');
            Decimal count9L = (Decimal)aggrResult.get('count9L');

            getWSDBShowByType(dbShowMap,status,year,month,countNumber,'NumberType',true,false);
            getWSDBShowByType(dbShowMap,status,year,month,totalAmount,'AmountType',true,false);
            getWSDBShowByType(dbShowMap,status,year,month,count9L,'9LType',true,false);
        }

        //roll-up CANumber
        List<AggregateResult> sorItemResults = [SELECT ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c status, 
                                                       CALENDAR_YEAR(ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c) year,
                                                       CALENDAR_MONTH(ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c) month,
                                                       SUM(ASI_CTY_CN_WS_Order_Qty_CA__c) countCA
                                                  FROM ASI_KOR_Sales_Order_Transaction__c
                                                 WHERE ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                                                   AND (ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c IN:inApprovalSORStatus 
                                                        OR ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c IN:approvedSORStatus)
                                                   AND FISCAL_YEAR(ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c) IN:fiscalYears 
                                                   group by ASI_KOR_Sales_Order_Request__r.ASI_KOR_Order_Status__c,
                                                            CALENDAR_YEAR(ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c),
                                                            CALENDAR_MONTH(ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c),
                                                            FISCAL_YEAR(ASI_KOR_Sales_Order_Request__r.ASI_CRM_SG_Order_Date__c)];
        for (AggregateResult aggrResult : sorItemResults) {
            String status = String.valueOf(aggrResult.get('status'));
            String year = String.valueOf(aggrResult.get('year'));
            String month = String.valueOf(aggrResult.get('month'));
            Decimal countCA = (Decimal)aggrResult.get('countCA');

            getWSDBShowByType(dbShowMap,status,year,month,countCA,'CAType',true,false);
        }
        System.debug(LoggingLevel.INFO, '*** dbShowMap: ' + dbShowMap);

    }

    private static void getDBShowTOV(Id accountId, Map<String, WSDashboardOrderShow> dbShowMap) {
        Set<Integer> fiscalYears = new Set<Integer>{Date.today().year(), Date.today().year() + 1};
        Set<String> heldTOVStatus = new Set<String>{'Held'};
        Set<String> inDeliveryTOVStatus = new Set<String>{'Released','Dispatched'};
        Set<String> completedTOVStatus = new Set<String>{'Received'};
        String tovRecordType = 'ASI_CRM_CN_TOV';
        String tovFinalRecordType = 'ASI_CRM_CN_TOV_Final';
        List<AggregateResult> tovResults = [SELECT ASI_CRM_Status__c status, 
                                                   CALENDAR_YEAR(ASI_CRM_Order_Date__c) year, 
                                                   CALENDAR_MONTH(ASI_CRM_Order_Date__c) month,
                                                   COUNT(Id) countNumber,
                                                   SUM(ASI_MFM_Total_Amount_wTax__c) totalAmount
                                              FROM ASI_CRM_TOV__c
                                             WHERE ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                                               AND FISCAL_YEAR(ASI_CRM_Order_Date__c) IN:fiscalYears
                                               AND (((ASI_CRM_Status__c IN:heldTOVStatus OR ASI_CRM_Status__c IN:inDeliveryTOVStatus) 
                                                       AND RecordType.DeveloperName = :tovRecordType)
                                                    OR (ASI_CRM_Status__c IN:completedTOVStatus AND RecordType.DeveloperName = :tovFinalRecordType))
                                               group by ASI_CRM_Status__c,
                                                        CALENDAR_YEAR(ASI_CRM_Order_Date__c),
                                                        CALENDAR_MONTH(ASI_CRM_Order_Date__c),
                                                        FISCAL_YEAR(ASI_CRM_Order_Date__c)];
        for (AggregateResult aggrResult : tovResults) {
            String status = String.valueOf(aggrResult.get('status'));
            String year = String.valueOf(aggrResult.get('year'));
            String month = String.valueOf(aggrResult.get('month'));
            Decimal countNumber = (Decimal)aggrResult.get('countNumber');
            Decimal totalAmount = (Decimal)aggrResult.get('totalAmount');

            getWSDBShowByType(dbShowMap,status,year,month,countNumber,'NumberType',false,false);
            getWSDBShowByType(dbShowMap,status,year,month,totalAmount,'AmountType',false,false);
        }

        List<AggregateResult> tovItemResults = [SELECT ASI_CRM_TOV__r.ASI_CRM_Status__c status, 
                                                       CALENDAR_YEAR(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c) year,
                                                       CALENDAR_MONTH(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c) month,
                                                       SUM(ASI_CTY_CN_WS_Order_Qty_CA__c) totalCAAmount,
                                                       SUM(ASI_CRM_CN_Order_Qty_9L__c) total9LAmount
                                              FROM ASI_CRM_TOV_Detail__c
                                             WHERE ASI_CRM_TOV__r.ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                                               AND FISCAL_YEAR(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c) IN:fiscalYears
                                               AND (((ASI_CRM_TOV__r.ASI_CRM_Status__c IN:heldTOVStatus OR ASI_CRM_TOV__r.ASI_CRM_Status__c IN:inDeliveryTOVStatus) 
                                                       AND ASI_CRM_TOV__r.RecordType.DeveloperName = :tovRecordType)
                                                    OR (ASI_CRM_TOV__r.ASI_CRM_Status__c IN:completedTOVStatus AND ASI_CRM_TOV__r.RecordType.DeveloperName = :tovFinalRecordType))
                                               group by ASI_CRM_TOV__r.ASI_CRM_Status__c,
                                                        CALENDAR_YEAR(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c),
                                                        CALENDAR_MONTH(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c)];
        for (AggregateResult aggrResult : tovItemResults) {
            String status = String.valueOf(aggrResult.get('status'));
            String year = String.valueOf(aggrResult.get('year'));
            String month = String.valueOf(aggrResult.get('month'));
            Decimal totalCAAmount = (Decimal)aggrResult.get('totalCAAmount');
            Decimal total9LAmount = (Decimal)aggrResult.get('total9LAmount');

            getWSDBShowByType(dbShowMap,status,year,month,totalCAAmount,'CAType',false,false);
            getWSDBShowByType(dbShowMap,status,year,month,total9LAmount,'9LType',false,false);
        }

        System.debug(LoggingLevel.INFO, '*** accountId: ' + accountId);
        List<AggregateResult> tovHeldResults = [SELECT COUNT(Id) countNumber,
                                                      SUM(ASI_MFM_Total_Amount_wTax__c) totalAmount
                                              FROM ASI_CRM_TOV__c
                                             WHERE ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                                               AND ASI_CRM_Status__c IN:heldTOVStatus 
                                               AND RecordType.DeveloperName = :tovRecordType];
        for (AggregateResult aggrResult : tovHeldResults) {
            Decimal countNumber = (Decimal)aggrResult.get('countNumber');
            Decimal totalAmount = (Decimal)aggrResult.get('totalAmount');
            getWSDBShowAll(dbShowMap, countNumber,'NumberType');
            getWSDBShowAll(dbShowMap, totalAmount,'AmountType');
        }

        List<AggregateResult> tovHeldItemResults = [SELECT SUM(ASI_CTY_CN_WS_Order_Qty_CA__c) totalCAAmount,
                                                           SUM(ASI_CRM_CN_Order_Qty_9L__c) total9LAmount
                                              FROM ASI_CRM_TOV_Detail__c
                                             WHERE ASI_CRM_TOV__r.ASI_CRM_SF_SO_Request_Number__r.ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                                               AND ASI_CRM_TOV__r.ASI_CRM_Status__c IN:heldTOVStatus 
                                               AND ASI_CRM_TOV__r.RecordType.DeveloperName = :tovRecordType];
        for (AggregateResult aggrResult : tovHeldItemResults) {
            Decimal totalCAAmount = (Decimal)aggrResult.get('totalCAAmount');
            Decimal total9LAmount = (Decimal)aggrResult.get('total9LAmount');

            getWSDBShowAll(dbShowMap, totalCAAmount, 'CAType');
            getWSDBShowAll(dbShowMap, total9LAmount, '9LType');
        }

        ASI_CRM_AccountsAdditionalField__c customer = [SELECT ASI_CRM_CN_JDE_Code__c FROM ASI_CRM_AccountsAdditionalField__c WHERE ASI_CRM_Account__c =:accountId limit 1];
        
        List<AggregateResult> tovReturnResults = [SELECT ASI_CRM_Status__c status, 
                                                         CALENDAR_YEAR(ASI_CRM_Order_Date__c) year, 
                                                         CALENDAR_MONTH(ASI_CRM_Order_Date__c) month,
                                                         COUNT(Id) countNumber,
                                                         SUM(ASI_MFM_Total_Amount_wTax__c) totalAmount
                                                    FROM ASI_CRM_TOV__c
                                                   WHERE ASI_CRM_Customer_Code__c = :customer.ASI_CRM_CN_JDE_Code__c
                                                     AND FISCAL_YEAR(ASI_CRM_Order_Date__c) IN:fiscalYears
                                                     AND RecordType.DeveloperName = :tovFinalRecordType
                                                     AND ASI_CRM_SO_Type__c = 'V2'
                                                     group by ASI_CRM_Status__c,
                                                          CALENDAR_YEAR(ASI_CRM_Order_Date__c),
                                                          CALENDAR_MONTH(ASI_CRM_Order_Date__c),
                                                          FISCAL_YEAR(ASI_CRM_Order_Date__c)];
        for (AggregateResult aggrResult : tovReturnResults) {
            String status = String.valueOf(aggrResult.get('status'));
            String year = String.valueOf(aggrResult.get('year'));
            String month = String.valueOf(aggrResult.get('month'));
            Decimal countNumber = (Decimal)aggrResult.get('countNumber');
            Decimal totalAmount = (Decimal)aggrResult.get('totalAmount');

            getWSDBShowByType(dbShowMap,status,year,month,countNumber,'NumberType',false,true);
            getWSDBShowByType(dbShowMap,status,year,month,totalAmount,'AmountType',false,true);
        }

        List<AggregateResult> tovItemReturnResults = [SELECT ASI_CRM_TOV__r.ASI_CRM_Status__c status, 
                                                             CALENDAR_YEAR(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c) year,
                                                             CALENDAR_MONTH(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c) month,
                                                             SUM(ASI_CTY_CN_WS_Order_Qty_CA__c) totalCAAmount,
                                                             SUM(ASI_CRM_CN_Order_Qty_9L__c) total9LAmount
                                                        FROM ASI_CRM_TOV_Detail__c
                                                       WHERE ASI_CRM_SF_SO_Request_Line_Number__r.ASI_KOR_Sales_Order_Request__r.ASI_CRM_CN_Customer__r.ASI_CRM_Account__c = :accountId
                                                         AND FISCAL_YEAR(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c) IN:fiscalYears
                                                         AND ASI_CRM_TOV__r.RecordType.DeveloperName = :tovFinalRecordType
                                                         AND ASI_CRM_TOV__r.ASI_CRM_SO_Type__c = 'V2'
                                                         group by ASI_CRM_TOV__r.ASI_CRM_Status__c,
                                                                  CALENDAR_YEAR(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c),
                                                                  CALENDAR_MONTH(ASI_CRM_TOV__r.ASI_CRM_Order_Date__c)];
        for (AggregateResult aggrResult : tovItemReturnResults) {
            String status = String.valueOf(aggrResult.get('status'));
            String year = String.valueOf(aggrResult.get('year'));
            String month = String.valueOf(aggrResult.get('month'));
            Decimal totalCAAmount = (Decimal)aggrResult.get('totalCAAmount');
            Decimal total9LAmount = (Decimal)aggrResult.get('total9LAmount');

            getWSDBShowByType(dbShowMap,status,year,month,totalCAAmount,'CAType',false,true);
            getWSDBShowByType(dbShowMap,status,year,month,total9LAmount,'9LType',false,true);
        }
    }

    @AuraEnabled
    public static Map<String, List<String>> getShowYearMonth() {
        //get fiscal month
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
        Map<String, List<String>> showYearMoths = new Map<String, List<String>>();
        List<String> months1 = new List<String>();
        List<String> months2 = new List<String>();
        if (orgFiscalMonth <= Date.today().month()) {
            for (Integer i = orgFiscalMonth; i <= Date.today().month() ; i++) {
                months1.add(i+'');
            }
            showYearMoths.put(String.valueOf(Date.today().year()), months1);
        } else {
            for (Integer i = orgFiscalMonth; i <= 12 ; i++) {
                months1.add(i+'');
            }
            showYearMoths.put(String.valueOf(Date.today().addYears(-1).year()), months1);
            for (Integer i = 1; i <= Date.today().month() ; i++) {
                months2.add(i+'');
            }
            showYearMoths.put(String.valueOf(Date.today().year()), months2);
        }
        return showYearMoths;
    }

    @AuraEnabled
    public static Map<String, String> getDefaultBrand() {
        Map<String, String> result = new Map<String, String>();
        List<ASI_CTY_CN_WS_Setup__c> defalutBrands = [SELECT ASI_CTY_CN_WS_Subbrand__c FROM ASI_CTY_CN_WS_Setup__c WHERE RecordType.DeveloperName = 'ASI_CTY_CN_WS_Subbrand'];
        if (defalutBrands.size() > 0) {
            List<String> brands = defalutBrands.get(0).ASI_CTY_CN_WS_Subbrand__c.split(',');
            Set<String> brandSet = new Set<String>();
            for (String brand : brands) {
                brandSet.add(brand.trim());
            }
            for (ASI_MFM_Sub_brand__c subbrand : [SELECT ASI_HK_CRM_English_Name__c, ASI_CRM_CN_CHI_NAME_C__c FROM ASI_MFM_Sub_brand__c WHERE ASI_HK_CRM_English_Name__c IN:brandSet]) {
                result.put(subbrand.ASI_HK_CRM_English_Name__c, subbrand.ASI_CRM_CN_CHI_NAME_C__c);
            }
        }
        return result;
    }

    public static void getWSDBShowByType(Map<String, WSDashboardOrderShow> dbShowMap, String status, String year, String month, 
                                        Decimal sumValue, String showType, Boolean isSOR, Boolean isReturn) {
        if (!dbShowMap.containsKey(year + month + showType) || sumValue == null) {
            return;
        }
        Set<String> inApprovalSORStatus = new Set<String>{'Submitted','Pending for Order Advisor'};
        Set<String> approvedSORStatus = new Set<String>{'Approved','Processing','Closed'};
        Set<String> heldTOVStatus = new Set<String>{'Held'};
        Set<String> inDeliveryTOVStatus = new Set<String>{'Released','Dispatched'};
        Set<String> completedTOVStatus = new Set<String>{'Received'};
        
        WSDashboardOrderShow dbShowOrder = dbShowMap.get(year + month + showType);

        if (isReturn) {
          dbShowOrder.monthReturnTOV = dbShowOrder.monthReturnTOV + sumValue;
        } else {
            if (isSOR) {
                dbShowOrder.inApprovalSOR = inApprovalSORStatus.contains(status) ? dbShowOrder.inApprovalSOR + sumValue : dbShowOrder.inApprovalSOR;
                dbShowOrder.approvedSOR = approvedSORStatus.contains(status) ? dbShowOrder.approvedSOR + sumValue : dbShowOrder.approvedSOR;
                dbShowOrder.totalSOR = dbShowOrder.inApprovalSOR + dbShowOrder.approvedSOR;
            } else {
                dbShowOrder.pendingPaymentTOV = heldTOVStatus.contains(status) ? dbShowOrder.pendingPaymentTOV + sumValue : dbShowOrder.pendingPaymentTOV;
                dbShowOrder.complatedTOV = completedTOVStatus.contains(status) ? dbShowOrder.complatedTOV + sumValue : dbShowOrder.complatedTOV;
                dbShowOrder.inDeliveryTOV = inDeliveryTOVStatus.contains(status) ? dbShowOrder.inDeliveryTOV + sumValue : dbShowOrder.inDeliveryTOV;
                dbShowOrder.inDeliveryTOV = completedTOVStatus.contains(status) || inDeliveryTOVStatus.contains(status) ? dbShowOrder.inDeliveryTOV - dbShowOrder.complatedTOV : dbShowOrder.inDeliveryTOV;
                dbShowOrder.approvedTOV = dbShowOrder.pendingPaymentTOV + dbShowOrder.inDeliveryTOV + dbShowOrder.complatedTOV;
            }
        }
        
        dbShowMap.put(year + month + showType, dbShowOrder);
    }

    public static void getWSDBShowAll(Map<String, WSDashboardOrderShow> dbShowMap, Decimal sumValue, String showType){
        if (sumValue == null) {
            return;
        }
        for (String key : dbShowMap.keySet()) {
            if (key.contains(showType)) {
                WSDashboardOrderShow dbShowOrder = dbShowMap.get(key);
                dbShowOrder.historyPaymentTOV = dbShowOrder.historyPaymentTOV + sumValue;
            }
        }
    }

    public static void getWSDBHisShowByType(List<WSDashboardHisShow> results, Map<String, WSDashboardHisShow> dbHisShowMap, String year, String month, 
                                            String brandValue, String brandLabel, Decimal intakeValue, Decimal inventoryValue, Decimal tovValue, String showType) {
        if (!dbHisShowMap.containsKey(year + month + showType)) {
            return;
        }
        WSDashboardHisShow hisShow = dbHisShowMap.get(year + month + showType);
        hisShow.intakeHis = hisShow.intakeHis + (intakeValue != null ? intakeValue : 0);
        hisShow.inventoryHis = hisShow.inventoryHis + (inventoryValue != null ? inventoryValue : 0);
        hisShow.tovHis = hisShow.tovHis + (tovValue != null ? tovValue : 0);
        dbHisShowMap.put(year + month + showType, hisShow);

        WSDashboardHisShow result = new WSDashboardHisShow();
        result.showYear = year;
        result.showMonth = month;
        result.historyShowType = showType;
        result.brandValue = brandValue;
        result.brandLabel = brandLabel;
        result.intakeHis = intakeValue;
        result.inventoryHis = inventoryValue;
        result.tovHis = tovValue;
        result.months = hisShow.months;
        results.add(result);
    }

    private static Id getAccountId() {
        final String userId = UserInfo.getUserId(); 
        String accountId = null; 
        final List <User> users = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId];
        
        if (!users.isEmpty()) {
            return (users[0].Contact !=  null ) ? users[0].Contact.AccountId : null;
        }
        return null;
    }

    public class WSDashboardOrderShow{
        @AuraEnabled 
        public String showType {GET;SET;}
        @AuraEnabled 
        public String showYear {GET;SET;}
        @AuraEnabled 
        public String showMonth {GET;SET;}
        @AuraEnabled 
        public Decimal totalSOR {GET;SET;}
        @AuraEnabled 
        public Decimal inApprovalSOR {GET;SET;}
        @AuraEnabled 
        public Decimal approvedSOR {GET;SET;}
        @AuraEnabled 
        public Decimal approvedTOV {GET;SET;}
        @AuraEnabled 
        public Decimal pendingPaymentTOV {GET;SET;}
        @AuraEnabled 
        public Decimal inDeliveryTOV {GET;SET;}
        @AuraEnabled 
        public Decimal complatedTOV {GET;SET;}
        @AuraEnabled 
        public Decimal historyPaymentTOV {GET;SET;}
        @AuraEnabled 
        public Decimal monthReturnTOV {GET;SET;}
        public WSDashboardOrderShow(String showType, String showYear, String showMonth) {
          this.showType = showType;
          this.showYear = showYear;
          this.showMonth = showMonth;
          this.totalSOR = 0;
          this.inApprovalSOR = 0;
          this.approvedSOR = 0;
          this.approvedTOV = 0;
          this.pendingPaymentTOV = 0;
          this.inDeliveryTOV = 0;
          this.complatedTOV = 0;
          this.historyPaymentTOV = 0;
          this.monthReturnTOV = 0;
        }

    }

    public class WSDashboardHisShow{
        @AuraEnabled 
        public String historyShowType {GET;SET;}
        @AuraEnabled 
        public String showYear {GET;SET;}
        @AuraEnabled 
        public String showMonth {GET;SET;}
        @AuraEnabled 
        public String brandLabel {GET;SET;}
        @AuraEnabled 
        public String brandValue {GET;SET;}
        @AuraEnabled 
        public List<String> months {GET;SET;}
        @AuraEnabled 
        public Decimal tovHis {GET;SET;}
        @AuraEnabled 
        public Decimal intakeHis {GET;SET;}
        @AuraEnabled 
        public Decimal inventoryHis {GET;SET;}
        public WSDashboardHisShow(){}

        public WSDashboardHisShow(String historyShowType, String showYear, String showMonth) {
            this.historyShowType = historyShowType;
            this.showYear = showYear;
            this.showMonth = showMonth;
            this.tovHis = 0;
            this.intakeHis = 0;
            this.inventoryHis = 0;
        }
    }

}
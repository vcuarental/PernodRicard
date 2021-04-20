/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_TradePlanUpload
 * Object: ASI_MFM_Plan__c
 * Purpose: 
 * Author:  (jack yuan)
 * Create Date: 2020-3-17
 * Modify History:
 * 2020-3-17        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_TradePlanUpload {
    public String errorHeader {get; set;}
    public static String subHeader = ASI_CRM_CN_CustomSetting__c.getInstance().ASI_CRM_CN_TP_Sub_Brand_Header__c;
    public static String cityHeader = ASI_CRM_CN_CustomSetting__c.getInstance().ASI_CRM_CN_TP_City_Header__c;
    public static String proModeSetting = ASI_CRM_CN_CustomSetting__c.getInstance().ASI_CRM_CN_TP_Promotion_Mode__c;
    public static Decimal taxRate = ASI_CRM_CN_TP_Utils.getCNTaxRate() * 100;
    public String uploadComments {get; set;}
    public static String remarksSetting = Label.ASI_CRM_CN_TP_Remarks;
    public List<String> tpHeaderList{get; set;}
    public String outletMappingUrl {get; set;}
    // public String pilotCustomers {get; set;}

    // public String specialItemGroups {get; set;}

    private static final String TPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Trade_Plan');
    private static final String BPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Budget_Plan');
    private static final String CNITEMGROUPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group');
    private static final String CNPLITEMRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_CRM_CN_TP_Trade_Plan_Line_Item');
    
    public ASI_CRM_CN_TP_TradePlanUpload() {
        ASI_CRM_CN_CustomSetting__c tpSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        tpHeaderList = tpSetting.ASI_CRM_CN_TP_Table_Header__c.split(',');
        uploadComments = tpSetting.ASI_CRM_CN_TP_Upload_Comments__c;
        errorHeader = tpSetting.ASI_CRM_CN_TP_Table_Error_Header__c;
        ASI_CRM_CN_TP_BudgetPlanUpload bpUpload = new ASI_CRM_CN_TP_BudgetPlanUpload();
        outletMappingUrl = bpUpload.listViewURL(bpUpload.prefixList(),'ASI_CRM_AccountsAdditionalField__c','CN Oulet KA Banner Mapping');
        // pilotCustomers = loadPilotCustomer();
        // specialItemGroups = loadSpecialItemGroups();
    }

    // public String loadSpecialItemGroups() {
    //     List<List<String>> specialItemGroups = new List<List<String>>();
    //     List<String> csvHeader = new List<String>{'Item Group Name','Item Group Code'};
    //     specialItemGroups.add(csvHeader);
    //     for (ASI_MFM_Item_Group__c itemGroup : [SELECT Name, ASI_MFM_Item_Group_Code__c, 
    //                                                    ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c
    //                                             FROM ASI_MFM_Item_Group__c
    //                                             WHERE ASI_CRM_CN_TP_Is_For_CN_TP__c = true]) {
    //         String itemGroupName = itemGroup.Name;
    //         if (itemGroupName.contains('\'')) {
    //             itemGroupName = itemGroupName.replace('\'','');
    //         } else if (itemGroupName.contains('\"')) {
    //             itemGroupName = itemGroupName.replace('\"','');
    //         }
    //         List<String> csvBody = new List<String>{itemGroupName, itemGroup.ASI_MFM_Item_Group_Code__c};
    //         specialItemGroups.add(csvBody);
    //     }
    //     return JSON.serialize(specialItemGroups);
    // }

    // public String loadPilotCustomer() {
        // List<List<String>> pilotCustomers = new List<List<String>>();
        // List<String> csvHeader = new List<String>{'KA Account','CRM Code','Customer'};
        // pilotCustomers.add(csvHeader);
        // for (ASI_CRM_AccountsAdditionalField__c customer : [SELECT Name,ASI_CRM_CN_CRM_Code__c,ASI_CRM_CN_TP_KA_Banner__c
        //                                                     FROM ASI_CRM_AccountsAdditionalField__c 
        //                                                     WHERE ASI_CRM_CN_TP_Dummy_Outlet__c = true
        //                                                     ORDER BY ASI_CRM_CN_TP_KA_Banner__c NULLS LAST]) {
        //     String kaBanner = customer.ASI_CRM_CN_TP_KA_Banner__c;
        //     String customerName = customer.Name;
        //     kaBanner = kaBanner != null && kaBanner.contains('\'') ? kaBanner.replace('\'', '##') : kaBanner;
        //     kaBanner = kaBanner != null && kaBanner.contains('\"') ? kaBanner.replace('\"', '@@') : kaBanner;
        //     kaBanner = kaBanner != null && kaBanner.contains('\\') ? kaBanner.replace('\\', '!!') : kaBanner;
        //     customerName = customerName.contains('\'') ? customerName.replace('\'', '##') : customerName;
        //     customerName = customerName.contains('\"') ? customerName.replace('\"', '@@') : customerName;
        //     customerName = customerName.contains('\\') ? customerName.replace('\\', '!!') : customerName;
        //     List<String> csvBody = new List<String>{kaBanner, customer.ASI_CRM_CN_CRM_Code__c, customerName};

        //     pilotCustomers.add(csvBody);

        // }
        // return JSON.serialize(pilotCustomers);
        // return ASI_CRM_CN_TP_TradePlanUploadLoadOutlet.loadPilotCustomer();

    // }

    @RemoteAction
    public static List<List<String>> downloadProducts(){
        List<List<String>> products = new List<List<String>>();
        List<String> csvHeader = subHeader.split(',');
        products.add(csvHeader);

        Set<String> subNameSet = new Set<String>();
        for (ASI_MFM_Item_Group__c itemGroup : [SELECT Name, ASI_MFM_Item_Group_Code__c, 
                                                       ASI_MFM_Sub_brand__r.Name,
                                                       ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c,
                                                       ASI_MFM_Sub_brand__r.ASI_CRM_CN_CHI_NAME_C__c,
                                                       ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c
                                                FROM ASI_MFM_Item_Group__c
                                                WHERE ASI_CRM_CN_TP_Is_For_CN_TP__c = true]) {
            String itemGroupName = itemGroup.Name;
            if (itemGroupName.contains('\'')) {
                itemGroupName = itemGroupName.replace('\'','');
            } else if (itemGroupName.contains('\"')) {
                itemGroupName = itemGroupName.replace('\"','');
            }
            String brandChiName = itemGroup.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c == null ? '' : itemGroup.ASI_MFM_Sub_brand__r.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c;
            List<String> csvBody = new List<String>{brandChiName,
                                                    itemGroup.ASI_MFM_Sub_brand__r.Name,
                                                    itemGroup.ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c,
                                                    itemGroup.ASI_MFM_Sub_brand__r.ASI_CRM_CN_CHI_NAME_C__c,
                                                    itemGroupName,
                                                    itemGroup.ASI_MFM_Item_Group_Code__c};
            products.add(csvBody);
            subNameSet.add(itemGroup.ASI_MFM_Sub_brand__r.Name);
        }

        List<ASI_MFM_Sub_brand__c> subBrands =  [SELECT Name, ASI_MFM_Sub_brand_Code__c, ASI_CRM_CN_CHI_NAME_C__c, ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c
                                                 FROM ASI_MFM_Sub_brand__c 
                                                 WHERE RecordType.DeveloperName = 'ASI_FOC_CN_Sub_brand'
                                                 AND ASI_MFM_Active_for_FOC__c = true
                                                 AND ASI_MFM_Active_for_CRM__c = true
                                                 ORDER BY ASI_MFM_Sub_brand_Code__c];

        for (ASI_MFM_Sub_brand__c brand : subBrands) {
            String brandChiName = brand.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c == null ? '' : brand.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c;
            if (!subNameSet.contains(brand.Name)) {
                List<String> csvBody = new List<String>{brand.ASI_MFM_Brand__r.ASI_CRM_CN_Chinese_Name__c, brand.Name, brand.ASI_MFM_Sub_brand_Code__c, brand.ASI_CRM_CN_CHI_NAME_C__c};
                products.add(csvBody);
            }
            
        }

        return products;
    }

    @RemoteAction
    public static List<List<String>> downloadCitys(){
        List<List<String>> planCitys = new List<List<String>>();
        List<String> csvHeader = cityHeader.split(',');
        planCitys.add(csvHeader);

        List<ASI_CRM_City__c> citys = [SELECT Id,Name, ASI_CRM_Chinese_Name__c, ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name FROM ASI_CRM_City__c WHERE RecordType.DeveloperName = 'ASI_CRM_CN_City' Order by ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c];
        for (ASI_CRM_City__c city : citys) {
            List<String> csvBody = new List<String>{city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name, city.Name, city.ASI_CRM_Chinese_Name__c};
            planCitys.add(csvBody);
        }
        return planCitys;
    }


    @RemoteAction
    public static Map<String, Object> checkUploadData(String input){
        Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
       Map<String, object> result = new Map<String, object>();
        
        String crm = (String)inputMap.get('CRM');
        List<ASI_CRM_AccountsAdditionalField__c> customerList = [SELECT ASI_CRM_CN_TP_KA_Banner__c, ASI_CRM_CN_CRM_Code__c, OwnerId,
                                                                        ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                               FROM ASI_CRM_AccountsAdditionalField__c
                                                               WHERE ASI_CRM_CN_CRM_Code__c = :crm];
        if (customerList.size() == 1) {
            result.put('kaBanner', customerList[0].ASI_CRM_CN_TP_KA_Banner__c);
            result.put('CRM', customerList[0].ASI_CRM_CN_CRM_Code__c);
            result.put('customerId', customerList[0].Id);
            result.put('regionId', customerList[0].ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c);
            result.put('channelId', customerList[0].ASI_CRM_CN_NewChannel__c);
            result.put('ownerId', customerList[0].OwnerId);
        } else if (customerList.size() == 0){
            result.put('CRM', '');
            result.put('kaBanner', '');
        }
        String proMode = (String)inputMap.get('promotionMode');
        proMode = proMode.toLowerCase();
        if (proMode != 'scan data') {
            proMode = proMode.trim();
        }
        List<String> proModeSettings = proModeSetting.split(',');
        if (!proModeSettings.contains(proMode)){
            result.put('promotionMode', 'invalid');
        } else {
            result.put('promotionMode', proMode);
        }
        String remark = (String)inputMap.get('remark');
        List<String> remarkSettings = remarksSetting.split(',');
        if (!remarkSettings.contains(remark)){
            result.put('remark', 'invalid');
        }

        String reg = (String)inputMap.get('region');
        if (String.isBlank(reg)) {
            List<ASI_CRM_Region__c> tpRegion = [SELECT Id,Name FROM ASI_CRM_Region__c WHERE Name = 'Headquarter'];
            if (!tpRegion.isEmpty()) {
                // result.put('regionId', tpRegion[0].Id);
                result.put('regionName', tpRegion[0].Name);
            }
        } else {
            List<ASI_CRM_Region__c> tpRegion = new List<ASI_CRM_Region__c>();
            if (reg == 'North' || reg == 'South' || reg == 'West') {
                String regLike = reg + ' Region';
                tpRegion = [SELECT Id, Name FROM ASI_CRM_Region__c WHERE Name = :regLike];
            } else if (reg != 'Non-Central' && reg != 'Non-Central Region'){
                String regLike = '%' + reg + '%';
                tpRegion = [SELECT Id, Name FROM ASI_CRM_Region__c WHERE Name LIKE :regLike];
            } else if (reg == 'Non-Central' || reg == 'Non-Central Region') {
                result.put('regionName', 'Non-Central Region');
            }
            if (!tpRegion.isEmpty()) {
                // result.put('regionId', tpRegion[0].Id);
                result.put('regionName', tpRegion[0].Name);
            } 
        }
        String planCity = (String)inputMap.get('planCity');
        List<String> cityList = new List<String>();
        if (String.isNotBlank(planCity) && planCity.contains(',')) {
            cityList = planCity.split(',');
        } else if (String.isNotBlank(planCity)){
            cityList.add(planCity);
        }
        List<ASI_CRM_City__c> citys = [SELECT Id, ASI_CRM_Chinese_Name__c,
                                              ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                              ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name
                                       FROM ASI_CRM_City__c 
                                       WHERE ASI_CRM_Chinese_Name__c IN :cityList];
        if (citys.isEmpty()) {
            result.put('planCity', 'Unknown');
        } else {
            result.put('planCity', citys[0].ASI_CRM_Chinese_Name__c);
            for (ASI_CRM_City__c city : citys) {
                System.debug(LoggingLevel.INFO, '*** result.get ' + result.get('regionId'));
                System.debug(LoggingLevel.INFO, '*** city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c: ' + city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c);
                String regionName = city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name;
                if ((result.get('regionId') != null && city.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c != result.get('regionId'))
                    || 
                    (reg == 'Non-Central' || reg == 'Non-Central Region') && regionName.contains('Central')) {
                    result.put('cityRegion', 'unfit');
                }
            }
            
        }
        
        String fiscalYear = (String)inputMap.get('fiscalYear');
               fiscalYear = fiscalYear.trim();
        String currentFiscalYear = Date.today().month() < 7 
                                   ? 'FY' + (Date.today().year() - 2001) + (Date.today().year() - 2000)
                                   : 'FY' + (Date.today().year() - 2000) + (Date.today().year() - 1999);
        if (fiscalYear != null && Integer.valueOf(fiscalYear.substring(2)) >= Integer.valueOf(currentFiscalYear.substring(2)) ) {
            result.put('fiscalYear', fiscalYear);
        } else {
            result.put('fiscalYear', 'errorYear');
        }
        String btlSize = (String)inputMap.get('bottleSize');
        String subBrandCode = (String)inputMap.get('subBrandCode');
        Decimal bottleSize = String.isBlank(btlSize) ? 0 : Decimal.valueOf(btlSize).setScale(2);
        String itemGroupCode = (String)inputMap.get('itemGroupCode');
        String itemGroupSql = 'SELECT ASI_MFM_Sub_brand__c ' + 
                              'FROM ASI_MFM_Item_Group__c ';
        if (String.isNotBlank(itemGroupCode)) {
            String groupCondition = ' WHERE ASI_MFM_Item_Group_Code__c = :itemGroupCode' + 
                                    ' AND ASI_CRM_CN_TP_Is_For_CN_TP__c = true';
            itemGroupSql += groupCondition;
        } else {
            String subCondition = ' WHERE ASI_MFM_Sub_brand__r.ASI_MFM_Sub_brand_Code__c = :subBrandCode' + 
                                  ' AND ASI_CRM_CN_TP_Bottle_Size__c = :bottleSize';
            itemGroupSql += subCondition;
        }
        itemGroupSql += ' AND RecordTypeId = :CNITEMGROUPRTID';
        List<ASI_MFM_Item_Group__c> itemGroups = Database.query(itemGroupSql);
        System.debug(LoggingLevel.INFO, '*** itemGroups: ' + itemGroups);
        if (!itemGroups.isEmpty()) {
            if (String.isNotBlank(itemGroupCode)) {
                result.put('itemGroupId', itemGroups[0].Id);
                result.put('subBrandId', itemGroups[0].ASI_MFM_Sub_brand__c);
            } else {
                result.put('subBrandId', itemGroups[0].ASI_MFM_Sub_brand__c);
            }
        }

        // String btlSize = (String)inputMap.get('bottleSize');
        
        String sellingPriceSql = 'SELECT ASI_CRM_CN_TP_Sub_Brand__c,' + 
                                        'ASI_CRM_CN_TP_Bottle_Size__c,' + 
                                        'ASI_CRM_CN_TP_LPP_Price__c,' + 
                                        'ASI_CRM_CN_TP_Region__c,' + 
                                        'ASI_CRM_CN_TP_Channel__c,' + 
                                        'ASI_CRM_CN_TP_Benchmark__c' + 
                                 ' FROM ASI_CRM_T2_Selling_Price__c '; 
        if (String.isNotBlank(itemGroupCode)) {
            String groupCondition = ' WHERE ASI_CRM_Item_Group__r.ASI_MFM_Item_Group_Code__c = :itemGroupCode' + 
                                    ' AND ASI_CRM_Item_Group__r.ASI_CRM_CN_TP_Is_For_CN_TP__c = true';
            sellingPriceSql += groupCondition;
        } else {
            String subCondition = ' WHERE ASI_CRM_CN_TP_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c = :subBrandCode' + 
                                  ' AND ASI_CRM_CN_TP_Bottle_Size__c = :btlSize';
            sellingPriceSql += subCondition;
        }
        sellingPriceSql += ' AND RecordType.DeveloperName = \'ASI_CRM_CN_TP_LPP\'';
        List<ASI_CRM_T2_Selling_Price__c> lppList = Database.query(sellingPriceSql);
        
        if (!lppList.isEmpty()) {
            result.put('LPPPrice', lppList[0].ASI_CRM_CN_TP_LPP_Price__c);
        } else {
            result.put('LPPPrice', 'invalid');
        }

        try {
            Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
            String startDate = (String)inputMap.get('startDate');
            String endDate = (String)inputMap.get('endDate');
            if (startDate.contains('/')) {
                startDate = startDate.replace('/', '-');
            }
            if (endDate.contains('/')) {
                endDate = endDate.replace('/', '-');
            }
            String tpExternalId = result.get('CRM') + '-' + fiscalYear + '-' + Date.valueOf(startDate) + '-' + Date.valueOf(endDate);
            if (Date.valueOf(startDate) >  Date.valueOf(endDate)) {
                result.put('dateValid', 'invalidDate');
            }
            String fiscalY = fiscalYear.substring(2);
            Integer FYStartYear = Integer.valueOf('20' + fiscalY.substring(0, 2));
            Integer FYEndYear = Integer.valueOf('20' + fiscalY.substring(2));
            Date FYStartDate = Date.newInstance(FYStartYear, orgFiscalMonth, 1);
            Date FYEndDate = Date.newInstance(FYEndYear, orgFiscalMonth - 1, 30);
            if (Date.valueOf(startDate) < FYStartDate || Date.valueOf(startDate) > FYEndDate || Date.valueOf(endDate) > FYEndDate || Date.valueOf(endDate) < FYStartDate) {
                result.put('dateValid', 'invalidFYDate');
            }
            List<ASI_MFM_Plan__c> tplans = [SELECT Name, ASI_CRM_CN_TP_External_ID__c 
                                        FROM ASI_MFM_Plan__c
                                        WHERE RecordTypeId = :TPRTID
                                        AND ASI_CRM_CN_TP_External_ID__c = :tpExternalId
                                        AND ASI_MFM_Status__c = :ASI_CRM_CN_TP_Utils.TPSTATUSFINAL];
            if (!tplans.isEmpty()) {
                result.put('exsitPlan', tplans[0].Name);
            }
        } catch (Exception e) {
            result.put('dateValid', 'errorDate');
        }
        
        String bpExternalId = 'BP' + '-' + result.get('kaBanner') + '-' + fiscalYear;
        List<ASI_MFM_Plan__c> bplans = [SELECT ASI_CRM_CN_TP_External_ID__c 
                                        FROM ASI_MFM_Plan__c
                                        WHERE RecordTypeId = :BPRTID
                                        AND ASI_CRM_CN_TP_External_ID__c = :bpExternalId];
        if (bplans.isEmpty()) {
            result.put('budgetPlan', 'noBP');
        }

        return result;
    }

    @RemoteAction
    public static void saveData(String BPJson){
        // System.debug(LoggingLevel.INFO, '*** BPJson: ' + BPJson);
        List<TradePlan> plans = (List<TradePlan>)JSON.deserialize(BPJson, List<TradePlan>.class);
        Map<String, ASI_MFM_Prefix__c> prefixMap = new Map<String, ASI_MFM_Prefix__c>();
        List<ASI_MFM_Prefix__c> prefixlist = [SELECT Id, Name, ASI_MFM_Fiscal_year__c FROM ASI_MFM_Prefix__c WHERE Name = 'CN Trade Plan'];
        for (ASI_MFM_Prefix__c pre : prefixlist) {
            prefixMap.put(pre.ASI_MFM_Fiscal_year__c, pre);
        }
        Map<String, List<ASI_MFM_Plan_Line_Item__c>> planKeyItemsMap = new Map<String, List<ASI_MFM_Plan_Line_Item__c>>();
        Map<String, ASI_MFM_Plan__c> planMap = new Map<String, ASI_MFM_Plan__c>();
        for (TradePlan plan : plans) {
            ASI_MFM_Plan__c newPlan = new ASI_MFM_Plan__c();
            newplan.ASI_CRM_CN_TP_Activity_NO__c = plan.planNO == null ? String.valueOf(plan.index) : plan.planNO;
            newPlan.RecordTypeId = TPRTID;

            newPlan.ASI_CRM_CN_TP_Cover_City__c = plan.planCity == null || plan.planCity == '' ? '总部' : plan.planCity;
            newPlan.ASI_MFM_Status__c = ASI_CRM_CN_TP_Utils.TPSTATUSDRAFT;
            newPlan.ASI_CRM_CN_TP_Customer__c = plan.customerId;
            newplan.ASI_CRM_CN_TP_Channel__c = String.isNotBlank(plan.channelId) ? plan.channelId : null;
            newPlan.ASI_CRM_CN_TP_Region__c = String.isNotBlank(plan.regionId) ? plan.regionId : null;
            newPlan.ASI_CRM_CN_TP_Region_P__c = plan.regionName;
            newPlan.ASI_MFM_Prefix__c = prefixMap.get(plan.fiscalYear) != null ? prefixMap.get(plan.fiscalYear).Id : null;
            newPlan.ASI_CRM_CN_TP_KA_Banner__c = plan.kaBanner;
            newPlan.ASI_MFM_Fiscal_year__c = plan.fiscalYear;
            newPlan.ASI_MFM_Remarks__c = String.isNotBlank(plan.remark) ? plan.remark : '';
            newPlan.ASI_CRM_CN_TP_CRM_Code__c = plan.CRM;
            newPlan.OwnerId = plan.ownerId;
            if (plan.startDate.contains('/')) {
                plan.startDate = plan.startDate.replace('/', '-');
            }
            if (plan.endDate.contains('/')) {
                plan.endDate = plan.endDate.replace('/', '-');
            }
            newplan.ASI_MFM_Start_Date__c = Date.valueOf(plan.startDate);
            newplan.ASI_MFM_End_Date__c = Date.valueOf(plan.endDate);
            String tpkey = newplan.ASI_CRM_CN_TP_Activity_NO__c + '-' + 
                           plan.CRM + '-' + 
                           newPlan.ASI_MFM_Fiscal_year__c + '-' + 
                           newplan.ASI_MFM_Start_Date__c + '-' + 
                           newplan.ASI_MFM_End_Date__c;
           

            ASI_MFM_Plan_Line_Item__c lineItem = new ASI_MFM_Plan_Line_Item__c();
            lineItem.RecordTypeId = CNPLITEMRTID;
            lineItem.ASI_CRM_CN_TP_DM__c = plan.DM;
            lineItem.ASI_CRM_CN_TP_Promotion_Product__c = plan.itemGroupId;
            lineItem.ASI_CRM_CN_TP_Secend_Display__c = plan.secondDisplay;
            System.debug(LoggingLevel.INFO, '*** plan.posterFee: ' + plan.posterFee);
            lineItem.ASI_CRM_CN_TP_Secend_Display_Stores_NO__c = String.isNotBlank(plan.secondDisplayStoreNO) ?  Decimal.valueOf(plan.secondDisplayStoreNO.trim()) : 0;
            lineItem.ASI_CRM_CN_TP_Posters_Fee__c =  String.isNotBlank(plan.posterFee) ? Decimal.valueOf(plan.posterFee.trim()) : 0;
            lineItem.ASI_CRM_CN_TP_Display_Fee__c =  String.isNotBlank(plan.displayFee) ? Decimal.valueOf(plan.displayFee.trim()) : 0;
            lineItem.ASI_MFM_Sub_brand_Code__c = plan.subBrandId;
            lineItem.ASI_CRM_CN_TP_Bottle_Size__c = plan.bottleSize;
            // lineItem.ASI_CRM_CN_TP_Promotion_Type__c = plan.promotionType;
            if (plan.promotionMode == ASI_CRM_CN_TP_Utils.PMINTAKEVERIFYTAXLABEL) {
                lineItem.ASI_CRM_CN_TP_Promotion_Mode__c = ASI_CRM_CN_TP_Utils.PMINTAKEVERIFYTAXAPI;
            } else if (plan.promotionMode == ASI_CRM_CN_TP_Utils.PMINTAKEVERIFYLABEL) {
                lineItem.ASI_CRM_CN_TP_Promotion_Mode__c = ASI_CRM_CN_TP_Utils.PMINTAKEVERIFYAPI;
            } else if (plan.promotionMode == ASI_CRM_CN_TP_Utils.PMSCANDATATAXLABEL){
                lineItem.ASI_CRM_CN_TP_Promotion_Mode__c = ASI_CRM_CN_TP_Utils.PMSCANDATATAXAPI;
            } else {
                lineItem.ASI_CRM_CN_TP_Promotion_Mode__c = plan.promotionMode;
            }
            newPlan.ASI_CRM_CN_TP_Promotion_Mode__c = lineItem.ASI_CRM_CN_TP_Promotion_Mode__c;
             planMap.put(tpkey, newPlan);
            // lineItem.ASI_CRM_CN_TP_Promotion_Mode_Detail__c = plan.promotionModeDetail;
            lineItem.ASI_CRM_CN_TP_Retail_Price__c =  Decimal.valueOf(plan.unitPrice.trim());
            lineItem.ASI_CRM_CN_TP_Promotion_Content__c = plan.promotionContent;
            lineItem.ASI_CRM_CN_TP_Tax_Rate__c = taxRate;
            lineItem.ASI_CRM_CN_TP_Promotion_Unit_Price__c =  Decimal.valueOf(plan.promotionPrice.trim());
            lineItem.ASI_CRM_CN_TP_Normal_Purchase_Price__c =  Decimal.valueOf(plan.purchasePrice.trim());
            lineItem.ASI_CRM_CN_TP_Promotion_Purchase_Price__c = Decimal.valueOf(plan.promotionPurchasePrice.trim());
            if (lineItem.ASI_CRM_CN_TP_Promotion_Mode__c != ASI_CRM_CN_TP_Utils.PMSCANDATA && lineItem.ASI_CRM_CN_TP_Promotion_Mode__c != ASI_CRM_CN_TP_Utils.PMSCANDATATAXAPI) {
                lineItem.ASI_CRM_CN_TP_Subsidies__c = lineItem.ASI_CRM_CN_TP_Normal_Purchase_Price__c - lineItem.ASI_CRM_CN_TP_Promotion_Purchase_Price__c;
            } else {
                lineItem.ASI_CRM_CN_TP_Subsidies__c = String.isNotBlank(plan.subsidies) ? Decimal.valueOf(plan.subsidies.trim()) : 0 ;
            }
            
            lineItem.ASI_CRM_CN_TP_Estimated_Qty__c = Decimal.valueOf(plan.planQty.trim());
            lineItem.ASI_MFM_Remarks__c = plan.remark;
            lineItem.ASI_MFM_List_Item_Description__c = plan.note;
            // lineItem.ASI_CRM_CN_TP_External_ID__c = newplan.ASI_CRM_CN_TP_Activity_NO__c + '-' + 
            //                                         plan.CRM + '-' + 
            //                                         newPlan.ASI_MFM_Fiscal_year__c + '-' + 
            //                                         newplan.ASI_MFM_Start_Date__c + '-' + 
            //                                         newplan.ASI_MFM_End_Date__c + '-' +
            //                                         lineItem.ASI_MFM_Sub_brand_Code__c + '-' + 
            //                                         lineItem.ASI_CRM_CN_TP_Bottle_Size__c;

            if (planKeyItemsMap.containsKey(tpkey)) {
                planKeyItemsMap.get(tpkey).add(lineItem);
            } else {
                planKeyItemsMap.put(tpkey, new List<ASI_MFM_Plan_Line_Item__c>{lineItem});
            }
        }
        List<ASI_MFM_Plan_Line_Item__c> upsertLineItems = new List<ASI_MFM_Plan_Line_Item__c>();
        System.debug(LoggingLevel.INFO, '*** JSON.serialize(planMap): ' + JSON.serialize(planMap));
        if (!planMap.isEmpty()) {
            insert planMap.values();
            for (String plankey : planMap.keySet()) {
                ASI_MFM_Plan__c plan = planMap.get(plankey);
                List<ASI_MFM_Plan_Line_Item__c> lineItems = planKeyItemsMap.get(plankey);
                for (ASI_MFM_Plan_Line_Item__c lineItem : lineItems) {
                    lineItem.ASI_MFM_Plan__c = plan.Id;
                    upsertLineItems.add(lineItem);
                }
            }
            System.debug(LoggingLevel.INFO, '*** upsertLineItems: ' + upsertLineItems);
            insert upsertLineItems;
           
        }
    }

    public class TradePlan {
        public Integer index;                               
        public Boolean show;                            
        public List<String> errors;
        public String errorStr;                     
        public String selected;                        
        public Boolean loading;                         
        public String status;                        
        public String planNO;                        
        public String region;                        
        public String regionId;
        public String regionName;
        public String ownerId;                       
        public String accType;                        
        public String channel;                        
        public String channelId;                        
        public String kaBanner;                        
        public String kaAccId;                        
        public String customerId;                        
        public String fiscalYear;                        
        public String startDate;                        
        public String endDate;                        
        public String CRM;                        
        public String planCity;                        
        public String DM;                        
        public String secondDisplay;                        
        public String secondDisplayStoreNO;                        
        public String posterFee;                        
        public String displayFee;                        
        // public String subBrandName;                        
        public String subBrandCode;                        
        public String subBrandId;                        
        public String bottleSize;                        
        public String itemGroupId;                        
        public String promotionMode;                        
        // public String promotionModeDetail;                        
        public String promotionContent;                        
        public String unitPrice;                        
        public String promotionPrice;                        
        public String purchasePrice;                        
        public String promotionPurchasePrice;                        
        public String subsidies;                        
        public String planQty;                        
        public String remark;                        
        public String note;                        
        public TradePlan orgData;                        
    }
}
public class ASI_MFM_CN_POSMCatalog_Upload_EXT {
    Private Static Final String WAREHOUSE_ID = Global_recordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
    Private Static Final String OUTLET_ID = Global_recordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
    Private Static Final String WS_ID = Global_recordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
    Private Static Final String CITY_ID = Global_recordTypeCache.getRtId('ASI_CRM_City__cASI_CRM_CN_City');
    Private Static Final String IBD_ID =  Global_recordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy');
    Private Static Final String INV_BALANCE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance');
    Private Static Final String POSMSKU_ID = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU');
    Private Static Final String CART_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM');
    Private Static Final String CART_RO_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only');
    Private Static Final String CART_ITEM_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_POSM_Request_Item');
    Private Static Final String DELIVERYZONE_ID = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_MFM_CN_POSM');
    Private Static Final String USER_ASSI_ID = Global_RecordTypeCache.getRtId('ASI_MFM_RequestItem_UserAssignment__cASI_MFM_CN_UA_POSM');

    private static Final Id ORDER_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_CRM_CN_POSM_Batch_Approval');
    private static Final Id ITEM_APPROVAL_ID = Global_recordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_CRM_CN_POSM_Request_Item_Batch_Approval');
    private static Final Id BATCH_LOG_ID = Global_recordTypeCache.getRtId('ASI_MFM_BatchLog__cASI_MFM_CN_Batch_Log');
    private static Final Id PO_ID = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO');
    private static Final Id PORO_ID = Global_recordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CN_PO_Read_Only');
    
    Private Static Final String EXP_CONTROL_ID = Global_recordTypeCache.getRtId('ASI_MFM_Expense_Control_Form__cASI_MFM_CN_Tax_Saving_Control_Form');

    Private Static String posmRequsetId;
    private static String submitType;
    private static Boolean showBatch;

    
    Public ASI_MFM_CN_POSMCatalog_Upload_EXT(ASI_MFM_CN_POSMCatalog_CTRL controller){}
    
    /*
    @future
    public static void submitFuture(id fgReqId)
    {   
        try{
            ASI_FOC_Free_Goods_Request__c request = new ASI_FOC_Free_Goods_Request__c(Id = fgReqId);
            request.ASI_FOC_Request_Status__c = 'In Progress';
            update request;            
        }catch (Exception e) {
            system.debug(e.getMessage());
        }
    }
    */
    
    // @TestVisible
    // Private Static string getADDomainPrefix() {
    //     string sPrefix = '';
    //     ASI_MFM_CN_Setting__mdt setting = [SELECT id, DeveloperName, ASI_MFM_CN_TextValue__c
    //                                        FROM ASI_MFM_CN_Setting__mdt
    //                                        WHERE DeveloperName LIKE 'ASI_MFM_CN_POSM_ADDomainUser_Prefix'
    //                                        LIMIT 1];
        
    //     if (setting != NULL)
    //         sPrefix = setting.ASI_MFM_CN_TextValue__c;
        
    //     return sPrefix;
    // }
    
    @RemoteAction
    Public Static List<ASI_FOC_Warehouse__c> checkWarehouse(List<String> whCode){       
        // List<ASI_FOC_Warehouse__c> wh = [select id, name , ASI_MFM_Direct_Delivery__c, ASI_FOC_Warehouse_Code__c
        //                                  from ASI_FOC_Warehouse__c
        //                                  where RecordTypeId = :WAREHOUSE_ID
        //                                  and ASI_FOC_Warehouse_Code__c in :whCode];
        
        // 20200511 ASI CN BLS Added control ASI_MFM_Is_Active__c = true to relate active warehouse
        List<ASI_FOC_Warehouse__c> wh = [select id, name , ASI_MFM_Direct_Delivery__c, ASI_FOC_Warehouse_Code__c
                                         from ASI_FOC_Warehouse__c
                                         where RecordTypeId = :WAREHOUSE_ID
                                         and ASI_FOC_Warehouse_Code__c in :whCode
                                         and ASI_MFM_Is_Active__c = true];
        return wh;
    }
    
    @RemoteAction
    Public Static Map<String, Object> checkUploadData(String input){
        Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
        Map<String, object> result = new Map<String, object>();
        
        String ponum = (String)inputMap.get('ponum');
        List<String> excludeList = new List<String>{'Memo', 'Event Memo', 'Other Memo', 'IT Capex', 'IT Opex', 'IT Capex Hardware Region', 'IT Capex Hardware HQ', 'IT Capex Software', 'IT Capex Renovation'};
        Map<String, ASI_MFM_PO__c> resultMap = new Map<String, ASI_MFM_PO__c>();
        if(ponum!=null && ponum!='') {
            for(ASI_MFM_PO__c  po :[SELECT id, Name, ASI_MFM_PO_Type__c
                                    FROM ASI_MFM_PO__c
                                    WHERE (RecordTypeId = :PO_ID OR RecordTypeId = :PORO_ID)
                                    AND ASI_MFM_Status__c = 'Final'
                                    AND ASI_MFM_PO_Type__c NOT IN :excludeList
                                    AND (Name = :ponum)
                                    ORDER BY Name LIMIT 1
                                   ])
            {
                result.put('ponum', po);
            }
        }
        
        String categoryCode = (String)inputMap.get('category');
        Schema.DescribeFieldResult fieldResultReqCate = ASI_FOC_Free_Goods_Request__c.ASI_MFM_Request_Category__c.getDescribe();
        List<Schema.PicklistEntry> pleReqCate = fieldResultReqCate.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pleReqCate){
            if(pickListVal.getValue().contains('ASI_MFM_CN') && pickListVal.getLabel().toLowerCase() == categoryCode.toLowerCase()) {
                result.put('category', pickListVal.getLabel());
                result.put('categoryValue', pickListVal.getValue());

            }
        }
        
        String whCode = (String)inputMap.get('towarehouse');
        for(ASI_FOC_Warehouse__c wh :[SELECT id, name, ASI_FOC_Warehouse_Code__c,
                                      ASI_MFM_User_Assignment_Needed__c,ASI_MFM_Regional_Warehouse__c,
                                      ASI_FOC_Contact__c, ASI_FOC_Phone_Number__c, ASI_MFM_POSM_Sequence__c,
                                      ASI_FOC_Warehouse_Address__c, ASI_FOC_City__c, ASI_FOC_City__r.name,  ASI_FOC_City__r.ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c,
                                      ASI_FOC_City__r.ASI_CRM_Province_Name__c, ASI_MFM_Direct_Delivery__c,
                                      ASI_FOC_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,
                                      ASI_FOC_City__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c,
                                      ASI_MFM_Operation_Team_Email_1__c, ASI_MFM_Operation_Team_Email_2__c, ASI_MFM_Operation_Team_Email_3__c, 
                                      ASI_MFM_Operation_Team_Email_4__c, ASI_MFM_Operation_Team_Email_5__c, ASI_MFM_Operation_Team_Email_6__c, 
                                      ASI_MFM_Operation_Team_Email_7__c, ASI_MFM_Operation_Team_Email_8__c, 
                                      ASI_FOC_SIR_Email_Address_1__c, ASI_FOC_SIR_Email_Address_2__c, ASI_FOC_SIR_Email_Address_3__c, 
                                      ASI_FOC_SIR_Email_Address_4__c, ASI_FOC_SIR_Email_Address_5__c, ASI_FOC_SIR_Email_Address_6__c, 
                                      ASI_FOC_SIR_Email_Address_7__c, ASI_FOC_SIR_Email_Address_8__c
                                      FROM ASI_FOC_Warehouse__c
                                      WHERE RecordTypeId = :WAREHOUSE_ID
                                      AND (ASI_FOC_Warehouse_Code__c = :whCode OR Name = :whCode) 
                                      // 20200511 ASI CN BLS Added control ASI_MFM_Is_Active__c = true to relate active warehouse
                                      AND ASI_MFM_Is_Active__c = true
                                      LIMIT 1]) 
        {
            result.put('towarehouse', wh);
        }
        String outletCode = (String)inputMap.get('outlet');
        for(ASI_CRM_AccountsAdditionalField__c outlet : [SELECT id, name, ASI_CRM_CN_City_Name__c, ASI_CRM_CN_CCity__c, ASI_CRM_CN_CRM_Code__c
                                                         ,ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name
                                                         ,ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                         ,ASI_CRM_CN_Contact_Person__c, ASI_CRM_CN_Phone_Number__c
                                                         ,ASI_CRM_CN_Province__c, ASI_CRM_CN_Address__c, ASI_CRM_CN_Email__c
                                                         ,ASI_CRM_CN_Inactive_Flag__c
                                                         FROM ASI_CRM_AccountsAdditionalField__c
                                                         WHERE (recordtypeId = :OUTLET_ID OR recordtypeId = :WS_ID)
                                                         AND (ASI_CRM_CN_CRM_Code__c = :outletCode OR Name = :outletCode OR ASI_CRM_CN_Chi_Name__c = :outletCode OR ASI_CRM_CN_Eng_Name__c = :outletCode)
                                                         //AND ASI_CRM_CN_Inactive_Flag__c=false
                                                         AND ASI_CRM_CN_Competitor_Outlet__c=false
                                                         AND ASI_CRM_CN_Dummy_Outlet_Flag__c=false 
                                                         //AND (ASI_CRM_CN_JDE_Code__c!='' or ASI_CRM_CN_JDE_Code_Premium__c!='' or ASI_CRM_CN_JDE_Code_RTD__c!='') 
                                                         ORDER BY ASI_CRM_CN_Inactive_Flag__c
                                                         LIMIT 1])
        {
            result.put('outlet', outlet);
        }

        for(Account u :[SELECT id, Name, Phone, ASI_MFM_Address_Line_1__c, ASI_MFM_Address_Line_2__c
                        , ASI_MFM_City__c, ASI_MFM_Customer_Supplier_Name__c, ASI_LUX_Email_Business__c, ASI_MFM_Customer_Supplier_Number__c
                        FROM Account 
                        WHERE (RecordType.DeveloperName = 'ASI_MFM_CN_Supplier')
                        AND ASI_HK_CRM_Inactive__c = false
                        AND (ASI_MFM_Customer_Supplier_Number__c = :outletCode OR Name = :outletCode OR ASI_MFM_Customer_Supplier_Name__c = :outletCode)
                        ORDER BY Name LIMIT 1])
        {
            result.put('agency', u);
        }
        
        String cityCode = (String)inputMap.get('city');
        for(ASI_CRM_City__c city :[SELECT Id, name, ASI_CRM_CN_Province__r.ASI_CRM_Chinese_Name__c, ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name
                                   ,ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c, ASI_CRM_External_ID__c
                                   FROM ASI_CRM_City__c 
                                   WHERE recordtypeId = :CITY_ID
                                   AND (name = :cityCode OR ASI_CRM_External_ID__c = :cityCode OR ASI_CRM_CN_City_Code__c = :cityCode
                                        OR ASI_CRM_English_Name__c = :cityCode OR ASI_CRM_Chinese_Name__c = :cityCode
                                       ) 
                                   LIMIT 1])
        {
            result.put('city', city);
        }
        
        String purposeStr = (String)inputMap.get('purpose');
        for(ASI_MFM_Expense_Control_Form__c purpose :[SELECT id,name, ASI_MFM_Tax_Saving_Purpose__c, ASI_MFM_ChineseDescription__c
                                                       FROM ASI_MFM_Expense_Control_Form__c
                                                       WHERE recordTypeId = :EXP_CONTROL_ID
                                                       AND ASI_MFM_ChineseDescription__c = :purposeStr
                                                       AND ASI_MFM_ForPOSMCart__c = true LIMIT 1])
        {
            result.put('purpose', purpose);
        }
        
        //20200805 edit by Leo Jing BLS strat.
        String vasStr = (String)inputMap.get('vas');
        List<String> vasList = new List<String>();
        if (vasStr != null && vasStr != '') vasList = vasStr.split(';');
        Schema.DescribeFieldResult fieldResultAVS = ASI_FOC_Free_Goods_Request__c.ASI_MFM_Add_ValueSet_Service__c.getDescribe();
        List<Schema.PicklistEntry> pleAVS = fieldResultAVS.getPicklistValues();
        Integer checkNum = 0;
        for (String vas : vasList) {
            for( Schema.PicklistEntry pickListVal : pleAVS){
                String pickValue = pickListVal.getValue();
                if (vas == pickValue) {
                    checkNum ++;
                }                
            }            
            // if(pickValue == vasStr)result.put('vas', pickListVal);  
        }
        if (checkNum == vasList.size()) result.put('vas', vasStr);  
        //20200805 edit by Leo Jing BLS end.
        
        try {
            Set<String> skuCodeList = new Set<String>();
            Set<String> ibCodeList  = new Set<String>();
            Set<String> ibdCodeList = new Set<String>();
            Set<String> adUserList  = new Set<String>();
            Set<String> userNameList = new Set<String>();
            Map<String, ASI_MFM_InventoryBalanceDetail__c> ibdMap = new Map<String, ASI_MFM_InventoryBalanceDetail__c>();
            Map<String, ASI_MFM_Inventory_Balance__c> ibMap = new Map<String, ASI_MFM_Inventory_Balance__c>();
            Map<String, ASI_MFM_SKU_Code__c> skuMap = new Map<String, ASI_MFM_SKU_Code__c>();
            Map<String, User> userMap = new Map<String, User>();

            //modify by BLS 2020-09-23 USER.ADDomainUser__c will be updated remove Domain
            //String adDomain = getADDomainPrefix();

            for(Object itemInput :(List<Object>)inputMap.get('items')){
                Map<String,Object> itemInputMap = (Map<String,Object>)itemInput;
                String skuCode = (String)itemInputMap.get('sku');
                String ibCode  = (String)itemInputMap.get('ib');
                String ibdCode = (String)itemInputMap.get('lot');
                String ownerCode = (String)itemInputMap.get('owner');
                String itemCls = (String)itemInputMap.get('class');
                if(skuCode != null && skuCode != '')skuCodeList.add(skuCode);
                if(ibCode  != null && ibCode  != '')ibCodeList.add(ibCode);
                if(ibdCode != null && ibdCode != '' && itemCls == 'parent')ibdCodeList.add(ibdCode);
                if(ibdCode != null && ibdCode != '' && itemCls == 'child'){
                    //ibdCode = ibdCode.contains('\\')? ibdCode:adDomain+''+ibdCode;
                    //ibdCode = adDomain+''+ibdCode;
                    //system.debug('### adDomain : ' + adDomain);
                    //system.debug('### code : ' + ibdCode);
                    //adUserList.add(ibdCode.toLowerCase());
                    userNameList.add(ibdCode);
                }
                if(ownerCode != null && ownerCode != ''){
                    //ownerCode = ownerCode.contains('\\')? ownerCode:adDomain+''+ownerCode;
                    //ownerCode = adDomain+''+ownerCode;
                    //adUserList.add(ownerCode.toLowerCase());
                    //userNameList.add(ownerCode);
                }
            }
            
            for(ASI_MFM_InventoryBalanceDetail__c ibd :[SELECT id,name, ASI_MFM_SKU__c, ASI_MFM_SKU__r.ASI_MFM_SKU_Code__c, ASI_MFM_InventoryBalance__c, ASI_MFM_CN_SFDC_RemainQty__c
                                                        , ASI_MFM_InventoryBalance__r.name , ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c, ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.Name
                                                        , ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_MFM_User_Assignment_Needed__c
                                                        , ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_MFM_Regional_Warehouse__c
                                                        , ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_FOC_City__c,ASI_MFM_Action__c
                                                        , ASI_MFM_SFDCOwner__c, ASI_MFM_SFDCOwner__r.ADDomainUser__c, ASI_MFM_SFDCOwner__r.Name
                                                        , ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__r.ASI_MFM_Use_Min_Package_Unit__c
                                                        FROM ASI_MFM_InventoryBalanceDetail__c 
                                                        WHERE RecordTypeId = :IBD_ID
                                                        AND name IN :ibdCodeList
                                                        AND ASI_MFM_SKU__r.ASI_MFM_SKU_Code__c IN :skuCodeList
                                                        AND ASI_MFM_InventoryBalance__r.name IN :ibCodeList
                                                        AND ASI_MFM_CN_SFDC_RemainQty__c > 0 ORDER BY id desc]) 
            {
                String key = ibd.ASI_MFM_SKU__r.ASI_MFM_SKU_Code__c + '|' + ibd.ASI_MFM_InventoryBalance__r.name + '|' + ibd.name;
                if(ibd.ASI_MFM_Action__c != null && ibd.ASI_MFM_Action__c !='') key = key + '|' + ibd.ASI_MFM_Action__c;
                ibdMap.put(key, ibd);
            }
            for(ASI_MFM_SKU_Code__c sku :[SELECT id, name , ASI_MFM_SKU_Code__c, ASI_MFM_Item_Group__c, ASI_MFM_Minimum_Packing_Qty__c
                                          FROM ASI_MFM_SKU_Code__c
                                          WHERE RecordTypeId = :POSMSKU_ID
                                          AND ASI_MFM_SKU_Code__c IN :skuCodeList]) 
            {
                skuMap.put(sku.ASI_MFM_SKU_Code__c, sku);
            }
            for(ASI_MFM_Inventory_Balance__c ib :[SELECT id, name
                                                  FROM ASI_MFM_Inventory_Balance__c 
                                                  WHERE RecordTypeId = :INV_BALANCE_ID
                                                  AND name IN :ibCodeList]) 
            {
                ibMap.put(ib.name, ib);
            }
            
            for(User u :[SELECT id, name , ADDomainUser__c, ADDomainUserLower__c, username
                         FROM USER 
                         WHERE isActive = true
                         AND username IN :userNameList
                         //AND ADDomainUserLower__c IN :adUserList
                        ])
            {
                userMap.put(u.username, u);
            }
            result.put('debug', userNameList);
            result.put('adDomain', '');
            result.put('sku',skuCodeList);
            result.put('ib',ibCodeList);
            result.put('ibd',ibdCodeList);
            result.put('aduser',adUserList);

            result.put('ibMap', ibMap);
            result.put('skuMap', skuMap);
            result.put('ibdMap', ibdMap);
            result.put('userMap', userMap);
        } catch (Exception e) {
            result.put('sku','fail');
            result.put('skuFailMsg', e.getMessage());
        }
        
           
        
        return result;
    }
    
    @RemoteAction
    Public Static ASI_FOC_Delivery_Zone__c getLeadTime(String fromCityId, String toCityId) {
        ASI_FOC_Delivery_Zone__c dzone      = null;
        try{
            if(fromCityId!=null && fromCityId!='' && toCityId!=null && toCityId!='') {
                List<ASI_FOC_Delivery_Zone__c> devZoneList = [SELECT id, name, ASI_MFM_TotalLeadTime__c, ASI_MFM_OutStorageTime__c, ASI_MFM_TransportTime__c, ASI_FOC_City_From__c,ASI_FOC_City_From__r.name, ASI_FOC_City_To__c,ASI_FOC_City_To__r.name
                                                              FROM ASI_FOC_Delivery_Zone__c
                                                              WHERE recordtypeId = :DELIVERYZONE_ID 
                                                              AND ASI_FOC_City_From__c = :fromCityId AND ASI_FOC_City_To__c = :toCityId 
                                                              ORDER BY ASI_MFM_TotalLeadTime__c desc LIMIT 1];
                if(devZoneList.size()>0) {
                    dzone = devZoneList[0];
                }
            }
        } catch(Exception e) {
            system.debug(e.getMessage());
        }
        return dzone;
    }
    
    private static ASI_MFM_BatchLog__c InsertDebugMsg(string sDateTime, string sMsg) {
        ASI_MFM_BatchLog__c oLog = new ASI_MFM_BatchLog__c(
            RecordTypeId = BATCH_LOG_ID
            , ASI_MFM_Log_Detail__c  = '[' + sDateTime + ']:{' + sMsg + '}'
            , ASI_MFM_LogType__c = 'POSM Upload'
        );
        insert oLog;
        return oLog;
    }
    private static string assignDebugMsg(string sLabel, string sValue) {
        string sTmpValue = '';
        sTmpValue = sLabel + ':' + (sValue==NULL ? 'NULL' : sValue) + ';';
        return sTmpValue;
    }
    
    //202008 add by edit Jing BLS ：Add input variable key = userid + datetime
    @RemoteAction
    Public Static Map<String, Object> submitOrder(String input,String key, Boolean show_Batch, String submit_Type){
        showBatch = show_Batch;
        submitType = submit_Type;
        Map<String, Object> resultMap = new Map<String,Object>();
        Datetime dtTime = Datetime.now();
        string sDatetime = dtTime.format('yyyyMMddhhmmss');
        ASI_MFM_BatchLog__c oLog = InsertDebugMsg(sDatetime, UserInfo.getUserId() + ';'+assignDebugMsg('input',input));

        Savepoint sp = Database.setSavepoint();
        try{    
            Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
            String categoryValue    = (String)inputMap.get('categoryValue');
            String fromWarehouseId  = (String)inputMap.get('fromWarehouseId');
            String toWarehouseId    = (String)inputMap.get('towarehouseId');
            String outletId         = (String)inputMap.get('outletId'); // will be agency id if categoryValue == 'Agency'
            String deliveryZoneId   = (String)inputMap.get('deliveryZoneId');
            String regionId         = (String)inputMap.get('regionId');
            String cityId           = (String)inputMap.get('cityId');
            String fromCityId       = (String)inputMap.get('fromCityId');
            String address1         = (String)inputMap.get('address1');
            String address2         = (String)inputMap.get('address2');
            String receiptor        = (String)inputMap.get('receipt');
            String purpose          = (String)inputMap.get('purposePickValue');
            String arrivalDate      = (String)inputMap.get('recdate');
            String deliveryTime     = '';
            String timeReason       = '';
            String deliveryInstruction = (String)inputMap.get('spreq');
            Integer leadTime        = (Integer)inputMap.get('leadTime');
            String mail             = (String)inputMap.get('email');
            String addValueService  = (String)inputMap.get('vas');
            String phone            = (String)inputMap.get('phone');
            String ponum            = (String)inputMap.get('ponumValue');

            //add deliveryZone Search
/*
            try{
                if(fromCityId!=null && fromCityId!='' && cityId!=null && cityId!='') {
                    List<ASI_FOC_Delivery_Zone__c> devZoneList = [SELECT id, name, ASI_MFM_TotalLeadTime__c, ASI_MFM_OutStorageTime__c, ASI_MFM_TransportTime__c, ASI_FOC_City_From__c,ASI_FOC_City_From__r.name, ASI_FOC_City_To__c,ASI_FOC_City_To__r.name
                                                                  FROM ASI_FOC_Delivery_Zone__c
                                                                  WHERE recordtypeId = :DELIVERYZONE_ID 
                                                                  AND ASI_FOC_City_From__c = :fromCityId AND ASI_FOC_City_To__c = :cityId 
                                                                  ORDER BY ASI_MFM_TotalLeadTime__c desc LIMIT 1];
                    if(devZoneList.size()>0) {                    
                        deliveryZoneId = devZoneList[0].id;
                        leadTime = Integer.valueOf(devZoneList[0].ASI_MFM_TotalLeadTime__c);                        
                    }
                }
            } catch(Exception e) {
                system.debug(e.getMessage());
            }
*/          

            ASI_FOC_Free_Goods_Request__c fgRequest = createRequestHeader(categoryValue, fromWarehouseId, toWarehouseId, outletId, deliveryZoneId, regionId
                                                                          , cityId, address1, address2, receiptor, phone, purpose, arrivalDate, deliveryTime
                                                                          , timeReason, deliveryInstruction, leadTime, mail, addValueService, ponum);
     
            fgRequest.ASI_FOC_Batch_Import_KEY__c = key;
            insert fgRequest;   

            resultMap.put('header', fgRequest);

            //20200430 - ASI CN BLS added: set up counter to re-call when encounter the deadlocks due to "FOR UPDATE" 10s lockdown
            Map<String,String> itemErrorMap = new Map<String,String>();
            for(Integer counter = 0 ; counter < 10 ; counter ++){
                Boolean lockflag = false;
                itemErrorMap = addItemToCart(fgRequest, (List<Object>)inputMap.get('items'), key);               
                for (String errorVal:itemErrorMap.values()) {
                     if ( (errorVal.contains('Record Currently Unavailable') || errorVal.contains('记录当前不可用') ) && counter < 10) {  lockflag = true; }
                }                  
                if (!lockflag) { break; }
            }
            //20200430 - ASI CN BLS - logic ended, and commented the line below (which is original line):            
            //Map<String,String> itemErrorMap = addItemToCart(fgRequest, (List<Object>)inputMap.get('items'));
            if(itemErrorMap.keySet().Size()>0) {
                Database.rollback( sp );
                oLog.ASI_MFM_Operation_Done__c = TRUE;
                oLog.ASI_MFM_Operation_Error_Message__c = JSON.serialize(itemErrorMap);
                update oLog;
                resultMap.put('error', '请查阅订单摘要');
                resultMap.put('itemErrors', itemErrorMap);
                return resultMap;
            }
            
            //Enoch@ Introv search Free Goods Request Name After insert 
            ASI_FOC_Free_Goods_Request__c fgr = [SELECT id, Name FROM ASI_FOC_Free_Goods_Request__c WHERE Id = :fgRequest.Id];
            resultMap.put('headerName', fgr.Name);

            if (posmRequsetId == null || posmRequsetId == '') posmRequsetId = fgRequest.Id;
            resultMap.put('posmRequsetId', fgRequest.Id);
            // resultMap.put('requestHead', approvalRequestHead.Id);
            System.debug(LoggingLevel.INFO, '*** posmRequsetId: ' + posmRequsetId);
            //ASI_FOC_Free_Goods_Request_TriggerClass.afterUpdateCount = 0;
            
            //replace submit to future function
            //fgRequest.ASI_FOC_Request_Status__c = 'In Progress';
            //update fgRequest;
            //submitFuture(fgRequest.Id);            
        } catch (Exception e) {
            Database.rollback( sp );
            oLog.ASI_MFM_Operation_Done__c = FALSE;
            oLog.ASI_MFM_Operation_Error_Message__c = e.getMessage();
            update oLog;
            resultMap.put('error', e.getMessage()+'|||'+e.getLineNumber());
        }
        oLog.ASI_MFM_Operation_Done__c = TRUE;
        update oLog;
        return resultMap;
    }
    
    Public Static Map<String, String> addItemToCart(ASI_FOC_Free_Goods_Request__c request,List<Object> items, String key) {
        Map<String,String> errorMap = new Map<String,String>();  
        try { //20200430 - ASI CN BLS Joey added: moving from the middle to the first line.
            Set<String> skuIdSet = new Set<String>();
            Map<String, Map<String,Object>> ibdInputMap = new Map<String, Map<String,Object>>();
            for(Object itmObj : items) {
                Map<String,Object> itmMap = (Map<String,Object>)itmObj;
                if(itmMap.get('child') != null) {
                    ibdInputMap.put((String)itmMap.get('ibdId'), itmMap);
                }
                // System.debug(LoggingLevel.INFO, '*** hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh: ' + itmMap.get('skuId'));
                
            }
            List<ASI_FOC_Request_Item__c> insertRequestLine = new List<ASI_FOC_Request_Item__c>();
            Map<id,ASI_MFM_InventoryBalanceDetail__c> ibdMap = new Map<id,ASI_MFM_InventoryBalanceDetail__c>([SELECT id, name, ASI_MFM_CN_SFDC_RemainQty__c, ASI_MFM_SKU__c, ASI_MFM_Action__c, ASI_MFM_ItemGroup__c
                                                                                                              FROM ASI_MFM_InventoryBalanceDetail__c 
                                                                                                              WHERE Id IN :ibdInputMap.keySet() FOR UPDATE]);

            System.debug('####### add item fog');
            //20200430 - ASI CN BLS added: moved the line from below to the top line of this function class.
            //Map<String,String> errorMap = new Map<String,String>();  
            List<ASI_FOC_Request_Item__c> reqItems = new List<ASI_FOC_Request_Item__c>();
            Map<Id, List<ASI_MFM_RequestItem_UserAssignment__c>> lotIdToUasMap = new Map<Id, List<ASI_MFM_RequestItem_UserAssignment__c>>();
            for(Id lotId : ibdMap.keySet()) {
                ASI_MFM_InventoryBalanceDetail__c dbLot = ibdMap.get(lotId);
                Map<String,Object> inputIbd = ibdInputMap.get(lotId);
                Integer submitQty = Integer.valueof((String)inputIbd.get('qty'));
                
                if(submitQty <= dbLot.ASI_MFM_CN_SFDC_RemainQty__c) {
                    ASI_FOC_Request_Item__c reqItem = new ASI_FOC_Request_Item__c();
                    reqItem.ASI_FOC_Request_Order__c = request.Id;
                    reqItem.recordTypeId = CART_ITEM_ID;
                    reqItem.ASI_FOC_SKU__c = (String)inputIbd.get('skuId');
                    reqItem.ASI_MFM_ItemGroup__c = (String)inputIbd.get('itemgroupId');
                    reqItem.ASI_FOC_Original_Request_Quantity_PC_BT__c = submitQty;
                    reqItem.ASI_FOC_Request_Quantity_PC__c = submitQty;
                    reqItem.ASI_MFM_Quantity__c = submitQty;
                    reqItem.ASI_MFM_IBD__c = lotId;
                    
                    reqItem.ASI_MFM_Warehouse__c = request.ASI_FOC_To_Regional_Warehouse__c;
                    reqItem.ASI_MFM_Region__c = request.ASI_MFM_Region__c;
                    reqItem.ASI_MFM_City__c  = request.ASI_MFM_City__c;
                    reqItem.ASI_MFM_Address__c = request.ASI_MFM_DetailAddress__c;
                    reqItem.ASI_FOC_Batch_Import_KEY__c = key;      

                    reqItems.add(reqItem);
                    
                    List<Object> uaChildList = (List<Object>)inputIbd.get('child');
                    system.debug('###### userassignment start');
                    system.debug(uaChildList);
                    if(uaChildList!=null && uaChildList.size() >0){
                        List<ASI_MFM_RequestItem_UserAssignment__c> tmpUaList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
                        for(Object uaObj :uaChildList) {
                            Map<String,Object> uaData = (Map<String,Object>)uaObj;
                            Integer uaQty = Integer.valueOf(uaData.get('qty'));
                            String userId = String.valueOf(uaData.get('userId'));
                            if(userId!=null && userId!='' && uaQty>0) {
                                tmpUaList.add(new ASI_MFM_RequestItem_UserAssignment__c(
                                    RecordTypeId = USER_ASSI_ID,
                                    ASI_MFM_Qty__c = uaQty,
                                    ASI_MFM_User__c = userId
                                ));
                            }
                        }
                        if(tmpUaList.size()>0) lotIdToUasMap.put(lotId,tmpUaList);
                    }
                    system.debug('###### lotIdToUasMap');
                    system.debug(lotIdToUasMap);
                } else {
                    system.debug('######## 库存数量不足');
                    errorMap.put(lotId, '库存数量不足');
                }
            }
            //try {    //20200430 - ASI CN BLS added: moved try bracket from here to the top line of this function class.
            if(reqItems.size()>0 && errorMap.keySet().Size()==0) {
                insert reqItems;                         

                // Create User Assignment
                system.debug('###### loop ua map');
                List<ASI_MFM_RequestItem_UserAssignment__c> insertUaList = new List<ASI_MFM_RequestItem_UserAssignment__c>();
                for(ASI_FOC_Request_Item__c reqItem :reqItems){
                    Id lotId = reqItem.ASI_MFM_IBD__c;
                    List<ASI_MFM_RequestItem_UserAssignment__c> tmpUaList = lotIdToUasMap.get(lotId);
                    system.debug(tmpUaList);
                    if(tmpUaList!=null) {
                        for(ASI_MFM_RequestItem_UserAssignment__c ua :tmpUaList) {
                            ua.ASI_MFM_Request_Item__c = reqItem.Id;
                            insertUaList.add(ua);
                        }                        
                    }
                }

                system.debug('###### insertUaList');
                system.debug(insertUaList);
                if(insertUaList.size()>0) insert insertUaList;
                // Create User Assignment
                List<ASI_MFM_CN_JCT_FGL_IBD__c> jctList = new List<ASI_MFM_CN_JCT_FGL_IBD__c>();
                for(ASI_FOC_Request_Item__c reqItem :reqItems){
                    jctList.add(new ASI_MFM_CN_JCT_FGL_IBD__c(ASI_MFM_Request_Item__c=reqItem.id,ASI_MFM_IBD__c=reqItem.ASI_MFM_IBD__c));
                }
                insert jctList;

                //202009 edit By Leo Jing BLS
                System.debug(LoggingLevel.INFO, '*** ShowBatch: ' + showBatch);
                System.debug(LoggingLevel.INFO, '*** SubmitType: ' + showBatch);
                if (showBatch == false) {  
                  List<Id> lineItemID = new List<Id>();
                  List<ASI_FOC_Request_Item__c> reqitemList = [SELECT id, ASI_FOC_Brand_Director_Approval_Status__c, ASI_FOC_Brand_Director_Approval_Required__c
                                                      , ASI_FOC_Brand_Approver__c, ASI_FOC_Request_Order__c ,ASI_MFM_Request_Item_Approval__c
                                                      , ASI_MFM_IBD__r.ASI_MFM_InventoryBalance__r.ASI_MFM_Warehouse__c
                                                      FROM ASI_FOC_Request_Item__c 
                                                      WHERE ASI_FOC_Request_Order__c = : request.Id];

                  for(ASI_FOC_Request_Item__c item : reqitemList) {
                      if(item.ASI_FOC_Brand_Director_Approval_Status__c != 'In Progress' && item.ASI_FOC_Brand_Director_Approval_Status__c != 'Approved' 
                         && item.ASI_FOC_Brand_Director_Approval_Required__c && item.ASI_FOC_Brand_Approver__c != NULL){
                          lineItemID.add(item.Id);
                      }                         
                  }                
                  System.debug(LoggingLevel.INFO, '*** : lineItemID.size' + lineItemID.size());
                  if(lineItemID.size()>0) {
                      List<Approval.ProcessSubmitRequest> lineItm_req = new List<Approval.ProcessSubmitRequest>();
                      for(ID objID : lineItemID){
                          Approval.ProcessSubmitRequest tmp = new Approval.ProcessSubmitRequest();
                          tmp.setObjectId(objID);
                          lineItm_req.add(tmp);
                      }
                      
                      List<Approval.ProcessResult> lineItm_result = Approval.process(lineItm_req);  
                      for(Approval.ProcessResult obj : lineItm_result){
                          if (!obj.isSuccess()) {
                              return null;
                          }
                      }
                  }
                  // request.RecordTypeId = CART_RO_ID;
                  // update reqItems;

                  request.ASI_FOC_Request_Status__c = 'Approved by Logistic';
                  request.ASI_FOC_Sys_Approved_By_Logistic__c = true;
                  request.ASI_FOC_Sys_Submitted__c = true;
                  update request;               
                  if( lineItemID.size() == 0 ) {
                      List<Approval.ProcessSubmitRequest> header_req = new List<Approval.ProcessSubmitRequest>();                      
                      Approval.ProcessSubmitRequest tmp_header_req = new Approval.ProcessSubmitRequest();
                      tmp_header_req.setObjectId(request.id);                  
                      header_req.add(tmp_header_req);
                      List<Approval.ProcessResult> header_result = Approval.process(header_req);  
                      for(Approval.ProcessResult obj : header_result){
                          if (!obj.isSuccess()) {
                              return null;
                          }
                      }
                  }
                }  

            }
        } catch (Exception e) {
            errorMap.put('error',e.getMessage() + '|||' + e.getLineNumber());
        }
        return errorMap;
    }

    
    Static string getAddrSubstring(string sRawAddr, integer iLength) {
        string sSubstring = '';
        if(sRawAddr!=null && sRawAddr!='') {
            sSubstring = sRawAddr.substring(0, (sRawAddr.length()>iLength?iLength:sRawAddr.length()));
        }
        return sSubstring;
    }
    
    public Static ASI_FOC_Free_Goods_Request__c createRequestHeader(String categoryValue, String fromWarehouseId, String toWarehouseId, String outletId, String deliveryZoneId, String regionId, String cityId
                                       , String address1, String address2, String receiptor, String phone, String purpose
                                       , String arrivalDate, String deliveryTime, String timeReason, String deliveryInstruction, Integer leadTime, String mail, String addValueService, String ponum)
    {
       ASI_FOC_Free_Goods_Request__c freeGoodsReq = new ASI_FOC_Free_Goods_Request__c(RecordTypeId=CART_ID,ASI_FOC_Request_Type__c='POS',ASI_FOC_Description__c='POSM'
                                                                                   ,ASI_FOC_Request_Status__c = 'Open'
                                                                                   ,ASI_CRM_CN_Purpose_Description__c='具体以仓库确认时间为准'
                                                                                   ,ASI_CRM_System_Remark__c = 'POSM Upload Record'
                                                                                   ,ASI_MFM_ForPOSMCart__c = true
                                                              );
        freeGoodsReq.ASI_MFM_Request_Category__c = categoryValue;
        freeGoodsReq.ASI_MFM_SubmitDate__c = system.now();
        //freeGoodsReq.ASI_FOC_Request_Status__c = 'Open';// 'In Progress';
        String address = ''+address1;
        if(address2!=null && address2!='') address += ' '+address2;
        string sDetailAddress = address;
        if(cityId!=null && cityId!='') {
            ASI_CRM_City__c oCity = [SELECT Id, Name From ASI_CRM_City__c WHERE Id = :cityId];
            sDetailAddress = oCity.Name+' '+sDetailAddress;
        }
        if(sDetailAddress!=null && sDetailAddress!='') {
            sDetailAddress = getAddrSubstring(sDetailAddress,60);
            freeGoodsReq.ASI_MFM_DetailAddress__c = sDetailAddress;
        }
        string sInstruction = ''+deliveryInstruction;
        if(addValueService!=null && addValueService!='') sInstruction = sInstruction + ' ' + addValueService;
        if(sInstruction!=null && sInstruction!='') freeGoodsReq.ASI_FOC_Delivery_Instruction_1__c = getAddrSubstring(sInstruction,30);



        freeGoodsReq.ASI_FOC_Deliver_to_Address_Line_1__c='';
        freeGoodsReq.ASI_FOC_Deliver_to_Address_Line_2__c='';
        
        freeGoodsReq.ASI_CRM_Outlet__c              = null;
        freeGoodsReq.ASI_MFM_Supplier_Name__c       = null;
        freeGoodsReq.ASI_FOC_Purpose__c             = null;
        if(outletId!=null && outletId!=''){
            if(categoryValue=='ASI_MFM_CN_Outlet') {freeGoodsReq.ASI_CRM_Outlet__c = outletId;}
            if(categoryValue=='ASI_MFM_CN_Agency') {freeGoodsReq.ASI_MFM_Supplier_Name__c = outletId;}            
        }
        if(fromWarehouseId!=null && fromWarehouseId!='')freeGoodsReq.ASI_MFM_FromWarehouse__c         = fromWarehouseId;
        if(toWarehouseId!=null && toWarehouseId!='')    freeGoodsReq.ASI_FOC_To_Regional_Warehouse__c = toWarehouseId;
        if(deliveryZoneId!=null && deliveryZoneId!='')  freeGoodsReq.ASI_FOC_Delivery_Zone__c         = deliveryZoneId;
        if(regionId!=null && regionId!='')              freeGoodsReq.ASI_MFM_Region__c                = regionId;
        if(cityId!=null && cityId!='')                  freeGoodsReq.ASI_MFM_City__c                  = cityId;
        if(receiptor!=null && receiptor!='')            freeGoodsReq.ASI_FOC_Receiptor_Name__c        = receiptor;
        if(phone!=null && phone!='')                    freeGoodsReq.ASI_FOC_Receiptor_Mobile__c      = phone;
        if(address1!=null && address1!='')              freeGoodsReq.ASI_FOC_Deliver_to_Address_Line_1__c = address1;
        if(address2!=null && address2!='')              freeGoodsReq.ASI_FOC_Deliver_to_Address_Line_2__c = address2;
        if(purpose!=null && purpose!='')                freeGoodsReq.ASI_FOC_Purpose__c       = purpose;
        if(mail!=null)                                  freeGoodsReq.ASI_MFM_RecipientEmail__c = mail;
        if(arrivalDate!=null && arrivalDate!=''){
            List<String> dateSplit = arrivalDate.split('-');
            if(dateSplit.size() >0) freeGoodsReq.ASI_FOC_Date_of_Delivery__c = Date.newInstance( Integer.ValueOf(dateSplit[0]),Integer.ValueOf(dateSplit[1]),Integer.ValueOf(dateSplit[2]));
        }
        if(deliveryTime!=null && deliveryTime!='')      freeGoodsReq.ASI_MFM_DeliveryTime__c  = deliveryTime;
        if(timeReason!=null && timeReason!='')          freeGoodsReq.ASI_MFM_ReasonForTime__c = timeReason;
        if(leadTime!=null)                              freeGoodsReq.ASI_MFM_LeadTimeCart__c  = leadTime;
        if(ponum!=null)                                 freeGoodsReq.ASI_MFM_POSM_PO_Number__c = ponum;
        if (addValueService!=null && addValueService!='') freeGoodsReq.ASI_MFM_Add_ValueSet_Service__c = addValueService;
        
        return freeGoodsReq;
    }

    //202009 added By Leo Jing BLS
    @RemoteAction
    Public static Map<String, Object> finishProcess(String key, Integer batchCount ,Integer batchSuccessCount, String executeCount){
        System.debug(LoggingLevel.INFO, '*** key: '+ key);
        System.debug(LoggingLevel.INFO, '*** batchCount: '+ batchCount);
        System.debug(LoggingLevel.INFO, '*** batchSuccessCount: '+ batchSuccessCount);
        System.debug(LoggingLevel.INFO, '*** executeCount: '+ executeCount);
        Map<String,String> errorMap = new Map<String,String>();  
        try {
          User u = [select id ,ManagerId from user where id =: userinfo.getUserId()];
          //Create Request Approval Heander
          ASI_FOC_Free_Goods_Request__c approvalRequestHead = new ASI_FOC_Free_Goods_Request__c();     
          approvalRequestHead.RecordTypeId = ORDER_APPROVAL_ID;
          approvalRequestHead.ASI_FOC_Batch_Import_KEY__c = key;
          approvalRequestHead.ASI_FOC_Description__c = 'POSM';
          approvalRequestHead.ASI_FOC_Approver_1__c = u.ManagerId;
          approvalRequestHead.ASI_FOC_Batch_Request_Total__c = batchCount;
          approvalRequestHead.ASI_FOC_Batch_Request_Success_Total__c = batchSuccessCount;
          insert approvalRequestHead; 
          //Query this batch of request
          List<ASI_FOC_Free_Goods_Request__c> reqList = [SELECT Id,ASI_FOC_Batch_Request_Total__c,ASI_FOC_Batch_Request_Success_Total__c ,ASI_FOC_POSM_Request_Approval__c
                                                          ,ASI_FOC_Request_Status__c,ASI_FOC_Sys_Approved_By_Logistic__c,ASI_FOC_Sys_Submitted__c
                                                          FROM ASI_FOC_Free_Goods_Request__c 
                                                          WHERE ASI_FOC_Batch_Import_KEY__c =: key 
                                                          AND ( RecordTypeId =: CART_RO_ID OR RecordTypeId =: CART_ID )];

          for (ASI_FOC_Free_Goods_Request__c req: reqList) {
              req.ASI_FOC_POSM_Request_Approval__c = approvalRequestHead.Id;
          }
          update reqList;

          //Query this batch of request items
          List<ASI_FOC_Request_Item__c> reqItems = [SELECT id,ASI_FOC_Brand_Approver__c,ASI_MFM_Request_Item_Approval__c,ASI_FOC_Brand_Director_Approval_Status__c,ASI_FOC_POSM_Request_Approval__c
                                                      FROM ASI_FOC_Request_Item__c 
                                                      WHERE ASI_FOC_Batch_Import_KEY__c =: key
                                                      AND ( RecordTypeId =: CART_ITEM_ID )];
          //Create Request item Approval Heander
          Set<String> uidSet = new Set<String>();
          List<ASI_FOC_Request_Item__c> approvalRequestItemHeadList = new List<ASI_FOC_Request_Item__c>();
          for(ASI_FOC_Request_Item__c item : reqItems) {          
              String uid = item.ASI_FOC_Brand_Approver__c;
              if (approvalRequestHead.Id != null) {
                  if (!uidSet.contains(uid)) {
                    ASI_FOC_Request_Item__c approvalRequestItemHead = new ASI_FOC_Request_Item__c();
                    approvalRequestItemHead.ASI_FOC_POSM_Request_Approval__c = approvalRequestHead.Id;
                    approvalRequestItemHead.RecordTypeId = ITEM_APPROVAL_ID;
                    approvalRequestItemHead.ASI_FOC_Batch_Import_KEY__c =uid+approvalRequestHead.ASI_FOC_Batch_Import_KEY__c;
                    approvalRequestItemHead.ASI_FOC_Request_Order__c = approvalRequestHead.Id;
                    approvalRequestItemHead.ASI_FOC_Brand_Approver__c  = uid;
                    approvalRequestItemHead.ASI_FOC_Brand_Director_Approval_Status__c = 'Open';
                    approvalRequestItemHeadList.add(approvalRequestItemHead);
                    uidSet.add(item.ASI_FOC_Brand_Approver__c);
                  }     
                 
              }
          }
          if (approvalRequestItemHeadList.size() > 0) insert approvalRequestItemHeadList;

          for (ASI_FOC_Request_Item__c item : reqItems) {              
              for (ASI_FOC_Request_Item__c  itemHeader: approvalRequestItemHeadList) {
                    if (item.ASI_FOC_Brand_Approver__c == itemHeader.ASI_FOC_Brand_Approver__c) {
                        item.ASI_MFM_Request_Item_Approval__c = itemHeader.Id;
                    }
              }
          }
          update reqItems;

          //Item Batch Approval
          if(approvalRequestItemHeadList.size()>0){
              List<Approval.ProcessSubmitRequest> lineItm_req = new List<Approval.ProcessSubmitRequest>();
              for(ASI_FOC_Request_Item__c obj : approvalRequestItemHeadList){
                  Approval.ProcessSubmitRequest tmp = new Approval.ProcessSubmitRequest();
                  if (obj.ASI_FOC_Brand_Approver__c!=null) {
                    tmp.setObjectId(obj.Id);
                    lineItm_req.add(tmp);
                  }
                  
              }                    
              List<Approval.ProcessResult> lineItm_result = Approval.process(lineItm_req);  
              for(Approval.ProcessResult obj : lineItm_result){
                  if (!obj.isSuccess()) {
                      return null;
                  }
              }
          }
          if (approvalRequestHead.Id != null) {
              for (ASI_FOC_Request_Item__c item : reqItems) {
                  if (item.ASI_FOC_Brand_Approver__c == null) {
                      item.ASI_FOC_Brand_Director_Approval_Status__c = 'Approved';                      
                  }else{
                      item.ASI_FOC_Brand_Director_Approval_Status__c = 'In Progress';   
                  }
                  // item.RecordTypeId = CART_ITEM_ID;                          
              }
          }                
          update reqItems;
         
          approvalRequestHead.ASI_FOC_Request_Status__c = 'Approved by Logistic';
          approvalRequestHead.ASI_FOC_Sys_Approved_By_Logistic__c = true;
          approvalRequestHead.ASI_FOC_Sys_Submitted__c = true;                            
          update approvalRequestHead;   

          for (ASI_FOC_Free_Goods_Request__c req: reqList) {
              req.ASI_FOC_Request_Status__c = 'Approved by Logistic';
              req.ASI_FOC_Sys_Approved_By_Logistic__c = true;
              req.ASI_FOC_Sys_Submitted__c = true;
              req.RecordTypeId = CART_RO_ID;             
          }
          update reqList;
          
          //auto approval
          for (ASI_FOC_Request_Item__c item :approvalRequestItemHeadList) {
              if (item.ASI_FOC_Brand_Approver__c == userInfo.getUserId()) {
                  Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                  req.setComments('Create user equals approver');
                  req.setAction('Approve');
                  ProcessInstanceWorkitem pItem = [SELECT Id from ProcessInstanceWorkitem 
                                                  WHERE ProcessInstance.TargetObjectId =: Item.Id];
                  req.setWorkitemId(pItem.Id);                     
                  Approval.ProcessResult result = Approval.process(req);
              } 
               //When ASI_FOC_Brand_Approver__c is empty, automatically approve
              if (item.ASI_FOC_Brand_Approver__c == null) {
                 item.ASI_FOC_Brand_Director_Approval_Status__c  = 'Approved';
              }                   
          }
          update approvalRequestItemHeadList;
        } catch (Exception e) {
            errorMap.put('error',e.getMessage()+'||'+e.getLineNumber());
            System.debug(LoggingLevel.ERROR, '*** error: ' + e.getMessage()+'||'+e.getLineNumber());
        }
        return errorMap;

    }
}
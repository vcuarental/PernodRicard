/*********************************************************************************
 * Name: ASI_CRM_MY_Function
 * Description: General Functions for PRMY CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------
 * 2015-01-03       Axel                    Initial
 * 2015-01-04       Daniel WONG             add getContractSKUMapping
 * 2015-01-14       Daniel WONG             add getPicklist value of Contract Setup Code
 * 2018-02          Introv                  add
 *********************************************************************************/
public without sharing class ASI_CRM_MY_Function {
    
    /**********************************************************************************
     Return a mapping of GL Class and A/C code according to Contract Setup Code
        'SPON' [
            'GL' => 'SPON'
            'AC' => '5210.SPON'
            'ID' => a7gM00000004EqC
        ]
        'MGTI' [
            'GL' => 'MGTI'
            'AC' => '5210.MG..........
        ]
    *********************************************************************************/
    public static map<String, map<String, String>> getContractSetupMapping() {
        //id idRT = Global_RecordTypeCache.getRtId('ASI_CRM_Contract_Setup_Code__cASI_CRM_MY_CSC');
        id idRT = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_MY_A_C_Code');
        
        map<String, String> mapAC = new map<String, String>();
        map<String, map<String, String>> mapContractSetup = new map<String, map<String, String>>();
        
        /*list<ASI_CRM_Contract_Setup_Code__c> lstAC = [
            SELECT id, Name, ASI_CRM_AC_Code__c, ASI_CRM_AC_Description__c, ASI_CRM_GL_Class__c 
            FROM ASI_CRM_Contract_Setup_Code__c 
            WHERE RecordTypeID = :idRT
            LIMIT 1000
        ];
        
        for (ASI_CRM_Contract_Setup_Code__c objAC : lstAC) {
            mapAC = new map<String, String>{
                'AC' => objAC.ASI_CRM_AC_Code__c, 
                'GL' => objAC.ASI_CRM_GL_Class__c, 
                'ID' => objAC.id
            };
            mapContractSetup.put(objAC.Name, mapAC);
        }*/
        
        list<ASI_MFM_A_C_Code__c> lstAC = [
            SELECT id, ASI_MFM_A_C_Description__c, ASI_MFM_A_C_Code__c, ASI_CRM_ContractSetupCode__c, ASI_MFM_GL_Class__c FROM ASI_MFM_A_C_Code__c WHERE RecordTypeID = :idRT AND ASI_CRM_ContractSetupCode__c != NULL
        ];
        for (ASI_MFM_A_C_Code__c objAC : lstAC) {
            mapAC = new map<String, String>{
                'AC' => objAC.ASI_MFM_A_C_Code__c, 
                'GL' => objAC.ASI_MFM_GL_Class__c, 
                'ID' => objAC.id
            };
            mapContractSetup.put(objAC.ASI_CRM_ContractSetupCode__c, mapAC);
        }
        
        return mapContractSetup;
    }
    
    /** Get IGC of SKUs
     Debug Code
        //map<id, decimal> res = new map<id, decimal>();
        //res = ASI_CRM_MY_Function.getSKUIGC(new Set<id>(), date.today(), '012M00000000csd');
        //system.debug(res);
    */
    public static map<id, decimal> getSKUIGC(set<id> setKSUIDs, date dteDate, id rtIGC) {
        // Declaration
        map<id, decimal> mapRes = new map<id, decimal>();
        // Declaration - End
                
        for (ASI_MFM_SKU_Code__c objSKU : [SELECT 
                id, Name, (SELECT ASI_CRM_Cost__c FROM ASI_CRM_IGCs__r
                    WHERE ASI_CRM_EffectiveDate__c <= :dteDate
                    AND RecordTypeID = :rtIGC
                    ORDER BY ASI_CRM_EffectiveDate__c DESC LIMIT 1
                )
                FROM ASI_MFM_SKU_Code__c
                WHERE id IN :setKSUIDs
                AND id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE RecordTypeID = :rtIGC)
                LIMIT 10000
            ]) {
            
            for (sObject sobj : objSKU.getSObjects('ASI_CRM_IGCs__r')) {
                mapRes.put(objSKU.id, sobj.get('ASI_CRM_Cost__c') == null ? 0 : (decimal) sobj.get('ASI_CRM_Cost__c'));
            }
        }
        return mapRes;
    }
    
    /** Get Distribution Cost of contracts
     Debug Code
        //map<id, decimal> res = new map<id, decimal>();
        //res = ASI_CRM_MY_Function.getDistributionCost(date.today());
        //system.debug(res);
    */
    public static map<id, map<String, map<String, decimal>>> getDistributionCost(date dteDate) {
        // Declaration
        map<String, decimal> mapMR = new map<String, decimal>(); // [ALLOWANCE] = 123.45;
        map<String, map<String, decimal>> mapMktResp = new map<String, map<String, decimal>>(); // [MktResp][ALLOWANCE] = 123.45;
        map<id, map<String, map<String, decimal>>> mapRes = new map<id, map<String, map<String, decimal>>>(); // res[ProdCatg][MktResp][ALLOWANCE] = 123.45;
        id rtDCR = Global_RecordTypeCache.getRTId('ASI_CRM_Distribution_Cost__cASI_CRM_MY_Revenue'); // Revenue
        id rtDCA = Global_RecordTypeCache.getRTId('ASI_CRM_Distribution_Cost__cASI_CRM_MY_Allowance'); // Allowance
        set<id> setProdCatg = new set<id>();
        set<String> strMktResp = new set<String>();
        // Declaration - End
        
        // To get a list of combination [ProdCatg][MktResp][ALLOWANCE]
        for (ASI_CRM_Distribution_Cost__c objDC : [SELECT 
                    id, RecordTypeID, ASI_CRM_Product_Category__c, ASI_CRM_Market__c, ASI_CRM_Cost__c, ASI_CRM_Effective_Date__c
                FROM ASI_CRM_Distribution_Cost__c
                WHERE (RecordTypeId = :rtDCR OR RecordTypeID = :rtDCA)
                AND ASI_CRM_Effective_Date__c <= :dteDate
                ORDER BY ASI_CRM_Product_Category__c, ASI_CRM_Market__c ASC, ASI_CRM_Effective_Date__c ASC
                LIMIT 10000
            ]) {
            system.debug('Prod: ' + String.valueOf(objDC.ASI_CRM_Product_Category__c) + ', Mkt: ' + String.valueOf(objDC.ASI_CRM_Market__c) + ', Date: ' + String.valueOf(objDC.ASI_CRM_Effective_Date__c) + ', Cost: ' + String.valueOf(objDC.ASI_CRM_Cost__c));
            mapMR = new map<String, decimal>();
            mapMktResp = new map<String, map<String, decimal>>();
            
            if (mapRes.get(objDC.ASI_CRM_Product_Category__c) != null) {
                mapMktResp = mapRes.get(objDC.ASI_CRM_Product_Category__c);
                if (mapMktResp.get(objDC.ASI_CRM_Market__c) != null) {
                    mapMR = mapMktResp.get(objDC.ASI_CRM_Market__c);
                }
            }
        
            if (objDC.RecordTypeID == rtDCA) {
                mapMR.put('ALLOWANCE', objDC.ASI_CRM_Cost__c);
            }
            if (objDC.RecordTypeID == rtDCR) {
                mapMR.put('REVENUE', objDC.ASI_CRM_Cost__c);
            }
            mapMktResp.put(objDC.ASI_CRM_Market__c, mapMR);
            mapRes.put(objDC.ASI_CRM_Product_Category__c, mapMktResp);
        }
        //// Fill empty
        //for (id idPC : setProdCatg) {
        //  for (String s : strMktResp) {
        //      if (mapResA.get(s) == null) {
        //          mapResA.put(s, 0);
        //          mapRes.put(idPC, mapResA);
        //      }
        //      if (mapResR.get(s) == null) {
        //          mapResR.put(s, 0);
        //          mapRes.put(idPC, mapResR);
        //      }
        //  }
        //}
        //system.debug(mapRes.get('a79M00000008OzQIAU'));
        //system.debug(mapRes.get('a79M00000008OzQIAU').get('Duty Free'));
        //system.debug(mapRes.get('a79M00000008OzQIAU').get('Duty Paid'));
        //system.debug(mapRes);
        return mapRes;
    }
    
    /** Dynamic Get Min SP  */
    public static map<id, decimal> getSKUMinSP(set<id> setKSUIDs, date dteDate, id rtMinSP) {
        // Declaration
        map<id, decimal> mapRes = new map<id, decimal>();
        // Declaration - End
                
        for (ASI_MFM_SKU_Code__c objSKU : [SELECT 
                id, Name, (SELECT ASI_CRM_Price__c FROM ASI_CRM_IGCs__r
                    WHERE ASI_CRM_EffectiveDate__c <= :dteDate
                    AND RecordTypeID = :rtMinSP
                    ORDER BY ASI_CRM_EffectiveDate__c DESC LIMIT 1
                )
                FROM ASI_MFM_SKU_Code__c
                WHERE id IN :setKSUIDs
                AND id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE RecordTypeID = :rtMinSP)
                LIMIT 10000
            ]) {
            
            for (sObject sobj : objSKU.getSObjects('ASI_CRM_IGCs__r')) {
                decimal decCost = sobj.get('ASI_CRM_Price__c') == null ? 0 : (decimal) sobj.get('ASI_CRM_Price__c');
               
                mapRes.put(objSKU.id, decCost);
            }
        }
        return mapRes;
    }
    
    /** Dynamic Get WS SP  */
    public static map<id, decimal> getSKUWSSP(set<id> setKSUIDs, date dteDate, id rtWSSP, string CustomerCate) {
        // Declaration
        map<id, decimal> mapRes = new map<id, decimal>();
        // Declaration - End

        for (ASI_MFM_SKU_Code__c objSKU : [SELECT 
                id, Name, (SELECT ASI_CRM_Price__c FROM ASI_CRM_IGCs__r
                    WHERE ASI_CRM_EffectiveDate__c <= :dteDate
                    AND ASI_CRM_Customer_Category_Code_2__c  = :CustomerCate
                    AND RecordTypeID = :rtWSSP
                    ORDER BY ASI_CRM_EffectiveDate__c DESC LIMIT 1
                )
                FROM ASI_MFM_SKU_Code__c
                WHERE id IN :setKSUIDs
                AND id IN (SELECT ASI_CRM_SKU__c FROM ASI_CRM_MY_SKUPriceCost__c WHERE RecordTypeID = :rtWSSP)
                LIMIT 10000
            ]) {
            
            for (sObject sobj : objSKU.getSObjects('ASI_CRM_IGCs__r')) {
                decimal decCost = sobj.get('ASI_CRM_Price__c') == null ? 0 : (decimal) sobj.get('ASI_CRM_Price__c');
               
                mapRes.put(objSKU.id, decCost);
            }
        }
        return mapRes;
    }
    
    /** Dynamic Get SKU Packing Size*/
    public static map<id, decimal> getSKUPackingMap(set<id> setSKUids, id rtSKU) {
        // Declaration
        map<id, decimal> mapRes = new map<id, decimal>();
        // Declaration - End
                
        for (ASI_MFM_SKU_Code__c objSKU : [SELECT 
            id, Name, ASI_HK_CRM_Packaging_Size__c
            FROM ASI_MFM_SKU_Code__c
            WHERE RecordTypeID = :rtSKU
            AND id IN :setSKUids
            LIMIT 5000]) {
            mapRes.put(objSKU.id, objSKU.ASI_HK_CRM_Packaging_Size__c);
        }
        return mapRes;
    }

    public static map<ID, map<String, Decimal>> getContractSKUMapping() {
        id idRT = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_MinSP');
        
        map<String, Decimal> mapSKU = new map<String, Decimal>();
        map<ID, map<String, Decimal>> mapContractSKU = new map<ID, map<String, Decimal>>();
        
        List<AggregateResult> arrRes = new List<AggregateResult>();
        
        arrRes = [
            SELECT ASI_CRM_SKU__c, MIN(ASI_CRM_Price__c)
            FROM ASI_CRM_MY_SKUPriceCost__c
            WHERE RecordTypeID = :idRT
            AND ASI_CRM_SKU__c != NULL
            GROUP BY ASI_CRM_SKU__c
            LIMIT 10000
        ];
        
        for(AggregateResult res : arrRes){
            mapSKU = new map<String, Decimal>{
                'MinSP' => (Decimal) res.get('expr0')
            };
            mapContractSKU.put((ID) res.get('ASI_CRM_SKU__c'), mapSKU);
        }
        return mapContractSKU;
    }
    
    /** Dynamic Get Contract Setup Code from master table */
    public static List<SelectOption> getContractSetupCodeValue() {
        id idRT = Schema.SObjectType.ASI_MFM_A_C_Code__c.RecordTypeInfosByName.get('MY A/C Codes').RecordTypeId;
        
        List<SelectOption> options = new List<SelectOption>();
        List<String> tempLst = new List<String>();
        Set<String> tempSet = new Set<String>();
        
        for(ASI_MFM_A_C_Code__c i : [
            SELECT ASI_CRM_ContractSetupCode__c, Name FROM ASI_MFM_A_C_Code__c WHERE RecordTypeId = :idRT
        ]){
            if(i.ASI_CRM_ContractSetupCode__c != NULL){
                tempLst.add(i.ASI_CRM_ContractSetupCode__c);
                tempSet.add(i.ASI_CRM_ContractSetupCode__c);
                if(tempSet.size() != tempLst.size()){
                    tempLst.remove(tempLst.size()-1);
                }
            }
        }
        
        if(tempLst != NULL && tempLst.size() > 0)
            tempLst.sort();
        
        options.add(new SelectOption('',''));
        for(String i : tempLst){
            options.add(new SelectOption(i,i));
        }
        return options;
    }
    
    public static Map<String, Set<id>> getMYGroup(){ 
        Map<String, Set<id>> mapMYGroup_user = new Map<String, Set<Id>>();
        
        for(GroupMember i :[
                SELECT Group.DeveloperName,  UserOrGroupId 
                FROM GroupMember 
                WHERE GroupId IN (SELECT Id FROM Group WHERE DeveloperName LIKE 'ASI_CRM_MY%')  //'ASI_CRM_MY_StandardUser')
            ]){
            Set<Id> uid = new Set<Id>();
                
            if(mapMYGroup_user.get(i.Group.DeveloperName) != NULL)
                uid = mapMYGroup_user.get(i.Group.DeveloperName);
            uid.add(i.UserOrGroupId);
            
            mapMYGroup_user.put(i.Group.DeveloperName, uid);
        }
        system.debug('mapMYGroup_user : ' + mapMYGroup_user);
        return mapMYGroup_user;
    }
    
    public static Boolean isGroupMember(Id uid, String gName){
        Map<String, Set<Id>> mapMYGroup_user = getMYGroup();
        Set<Id> setRoleId = new Set<Id>();
        Set<Id> roleRelatedGroupIds = new Set<Id>();
        
        //uid = (ID) string.valueof(uid).left(15);
        system.debug('isGroupMember-------------------------------' + uid);
        if(mapMYGroup_user.get(gName) != NULL){
            if(mapMYGroup_user.get(gName).CONTAINS(uid))
                return TRUE;
        }
        
        // CHECK User Role
        for(User r : [SELECT id, UserRoleId FROM User WHERE Id = :uid]){
            setRoleId.add(r.UserRoleId);
        }
        system.debug('setRoleId :' + setRoleId);
        
        if(setRoleId.size() > 0) {
            for(Group g : [SELECT id, RelatedId, Type FROM Group where RelatedId IN :setRoleId]){
                roleRelatedGroupIds.add(g.id);
            }
        }
        system.debug('isGroupMember-------------------------------' + setRoleId);
        for(Id rid : roleRelatedGroupIds){
            if(mapMYGroup_user.get(gName) != NULL){
                system.debug('mapMYGroup_user.get(gName) : ' + mapMYGroup_user.get(gName));
                system.debug('rid :' + rid);
                if(mapMYGroup_user.get(gName).CONTAINS(rid))
                    return TRUE;
            }
        }
        return FALSE;
    }
 
    private static set<string> m_BypassedTriggers = null;
    public static set<string> BypassedTriggers {
        get {
            if(m_BypassedTriggers==null) {
                m_BypassedTriggers = new set<String>();
                list<User> users = [SELECT Id, BypassTriggers__c FROM User WHERE Id = :UserInfo.getUserId()];
                System.debug(users[0]);
                if (users.size() > 0 && users[0].BypassTriggers__c != null) {
                    String bypassTriggerWholeStr = users[0].BypassTriggers__c;                    
                    List<String> bypassTriggerStrs = bypassTriggerWholeStr.split(';', 0);
                    System.debug(bypassTriggerStrs );
                    for (String bypassTriggerStr : bypassTriggerStrs) {
                    system.debug(bypassTriggerStr.toLowerCase());
                        m_BypassedTriggers.add(bypassTriggerStr.toLowerCase());
                    }
                }
            }    
            return m_BypassedTriggers;
        }
    }
    
    public static boolean IsBypassTrigger(string triggerKey) {
        set<string> tempBypassedTriggers = BypassedTriggers;
        system.debug(tempBypassedTriggers);
        system.debug(triggerKey);
        return tempBypassedTriggers!=null && tempBypassedTriggers.contains(triggerKey.toLowerCase());
    }
    
    public static boolean IsValidDate(string strDate){
        boolean validation = FALSE;
        integer dateSize = strDate.split('/').size();
        if(dateSize == 3){
            try{
                integer intY = integer.valueOf(strDate.split('/')[2]);
                integer intM = integer.valueOf(strDate.split('/')[1]);
                integer intD = integer.valueOf(strDate.split('/')[0]);
                //date dateTemp = date.newInstance(intY, intM, intD);
                date mydate = date.parse(strDate);
                //date theDate = Date.valueOf(strDate);
                validation = TRUE;
            }catch(Exception e){
                validation = FALSE;
            }
        }
        return validation;
    }



    public static Map<Id,Id> getLatestSKUByOld(Set<Id> s_oldIds){
        Map<Id,Id> m_OldId_NewId = new Map<Id, Id>();
        if(s_oldIds.size()>0){
            for(ASI_MFM_SKU_Code__c sku: [SELECT Id, Name, ASI_CRM_SKU_Group__c, ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c FROM ASI_MFM_SKU_Code__c WHERE Id in:s_oldIds AND RecordTypeId =:Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU' )]){
                if(sku.ASI_CRM_SKU_Group__c!=null && sku.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c!=null){
                    m_OldId_NewId.put(sku.Id, sku.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__c);
                }else{
                    m_OldId_NewId.put(sku.Id, sku.Id);
                }
            }
        }

        return m_OldId_NewId;
        
    }
}
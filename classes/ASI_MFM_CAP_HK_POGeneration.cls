/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_HK_POGeneration
 * Description: Batch Job Class to generate Aggregated Sub-brand Volume
 * Test Class:  ASI_MFM_CAP_HK_POGenerationTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-04       Hector                  Created
 * 2018-11-21       Jay                     Exception Handling
 * 2019-05-09       Wilken Lee              [WL 1.0] Default Auto Created PO Owner to be Plan Owner, Default ASI_MFM_G_L_Date__c  to be generation date
 * 2019-10-21       Wilken Lee              [WL 2.0] Do not auto assign PO Original Amount that by-pass approval when generate PO from Plan, to allow ATR PO to go through approval
 ****************************************************************************************************************************/

public class ASI_MFM_CAP_HK_POGeneration {
    public static final string PLAN_TYPE_CAPEX = 'CAPEX';
    public static final string PLAN_TYPE_OPEX = 'OPEX';
    public class customException extends Exception {}
        
    public static void GenerateHKCAPEXPOFromPlan(List<ASI_MFM_Plan__c> planList){
        GenerateHKPOFromPlan(planList, PLAN_TYPE_CAPEX);
    }
    
    public static void GenerateHKOPEXPOFromPlan(List<ASI_MFM_Plan__c> planList){
        GenerateHKPOFromPlan(planList, PLAN_TYPE_OPEX);
    }
    
    public static void GenerateHKPOFromPlanLineByType(List<ASI_MFM_Plan_Line_Item__c> planLineItemList){
        Set<Id> planLineItemIDSet = new Set<Id>();
        List<ASI_MFM_Plan_Line_Item__c> capexPlanLineItemList = new List<ASI_MFM_Plan_Line_Item__c>();
        List<ASI_MFM_Plan_Line_Item__c> opexPlanLineItemList = new List<ASI_MFM_Plan_Line_Item__c>();
        
        for (ASI_MFM_Plan_Line_Item__c planLineItem : planLineItemList){
            planLineItemIDSet.add(planLineItem.Id);
        }
        
        List<ASI_MFM_Plan_Line_Item__c> planLineListFull = [SELECT Id, Name, 
                                                                ASI_MFM_AP_Code__c,
                                                                ASI_MFM_A_C_Code__c,
                                                                ASI_MFM_BU_Code__c,
                                                                ASI_MFM_Currency__c,
                                                                ASI_MFM_Dummy_PO__c,
                                                                ASI_MFM_List_Item_Description__c,
                                                                ASI_MFM_Plan__c,
                                                                ASI_MFM_Plan__r.OwnerId,    //WL 1.0
                                                                ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_End_Date__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_Exchange_Rate__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Bypass_Approval__c,
                                                                ASI_MFM_Plan__r.CurrencyIsoCode,
                                                                ASI_MFM_Supplier_Name__c,
                                                                ASI_MFM_Supplier_Name__r.Fax,
                                                                ASI_MFM_Supplier_Name__r.Phone,
                                                                ASI_MFM_T_E__c,
                                                                ASI_MFM_Total_Cost__c
                                                            FROM ASI_MFM_Plan_Line_Item__c
                                                            WHERE Id in :planLineItemIDSet];
        
        for (ASI_MFM_Plan_Line_Item__c planLineItem: planLineListFull){
            system.debug('planLineItem.ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c'+ planLineItem.ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c);
            if (planLineItem.ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c == ASI_MFM_CAP_HK_POGeneration.PLAN_TYPE_CAPEX){                
                capexPlanLineItemList.add(planLineItem);
            } else if (planLineItem.ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c == ASI_MFM_CAP_HK_POGeneration.PLAN_TYPE_OPEX){
                opexPlanLineItemList.add(planLineItem);
            }
        }
        

        if (capexPlanLineItemList.size() > 0)
            GenerateHKPOFromPlanLine(capexPlanLineItemList, PLAN_TYPE_CAPEX);
        if (opexPlanLineItemList.size() > 0)
            GenerateHKPOFromPlanLine(opexPlanLineItemList, PLAN_TYPE_OPEX);

    }
    
    public static void GenerateHKPOFromPlan(List<ASI_MFM_Plan__c> planList, string planType){
        Set<Id> planIDSet = new Set<Id>();
        for (ASI_MFM_Plan__c plan:planList){
            planIDSet.add(plan.Id);
        }
        
        List<ASI_MFM_Plan_Line_Item__c> planLineList = [SELECT Id, Name, 
                                                                ASI_MFM_AP_Code__c,
                                                                ASI_MFM_A_C_Code__c,
                                                                ASI_MFM_BU_Code__c,
                                                                ASI_MFM_Currency__c,
                                                                ASI_MFM_Dummy_PO__c,
                                                                ASI_MFM_List_Item_Description__c,
                                                                ASI_MFM_Plan__c,
                                                                ASI_MFM_Plan__r.OwnerID, //WL 1.0
                                                                ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_End_Date__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_Exchange_Rate__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c,
                                                                ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Bypass_Approval__c,
                                                                ASI_MFM_Plan__r.CurrencyIsoCode,
                                                                ASI_MFM_Supplier_Name__c,
                                                                ASI_MFM_Supplier_Name__r.Fax,
                                                                ASI_MFM_Supplier_Name__r.Phone,
                                                                ASI_MFM_T_E__c,
                                                                ASI_MFM_Total_Cost__c
                                                         FROM ASI_MFM_Plan_Line_Item__c
                                                         WHERE ASI_MFM_Plan__c in :planIDSet];

        GenerateHKPOFromPlanLine(planLineList, planType);
    }
    
    public static void GenerateHKPOFromPlanLine (List<ASI_MFM_Plan_Line_Item__c> planLineList, string planType){
        //Map of Plan Line Item ID to PO 
        String PlanOwnerID ='';
        Map<id, ASI_MFM_PO__c> newPlanLinePOMap = new Map<id, ASI_MFM_PO__c>();
        List<ASI_MFM_PO_Line_Item__c> newPOLineItemList = new List<ASI_MFM_PO_Line_Item__c>();
        
        //Retrieve MFM Prefix
        List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixRelationshipList = getRolePrefixRelationship('PO', 'HK', 'ASI_MFM_CAP_Prefix');
        User userDetails = [SELECT Id, ASI_MFM_Country__c FROM User where Id=:UserInfo.getUserId() LIMIT 1];
        
        
        
        for (ASI_MFM_Plan_Line_Item__c planLine : planLineList){
            PlanOwnerID = planLine.ASI_MFM_Plan__r.OwnerID;
            String mfmPrefix = '';
            system.debug('planLine.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c:' + planLine.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c);
            for (ASI_MFM_Role_Prefix_Relationship__c rolePrefixRelationship : rolePrefixRelationshipList){
                system.debug('rolePrefixRelationship.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c:' + rolePrefixRelationship.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c);
                if (rolePrefixRelationship.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c == planLine.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c){
                    mfmPrefix = rolePrefixRelationship.ASI_MFM_Prefix__c;
                }
            }
            ASI_MFM_PO__c newPO;
            if (!String.isBlank(mfmPrefix)){
                newPO = new ASI_MFM_PO__c(ASI_MFM_PO_Type__c = planLine.ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c,
                                                        //OwnerID = planLine.ASI_MFM_Plan__r.OwnerID, //WL 1.0
                                                        ASI_MFM_Plan__c = planLine.ASI_MFM_Plan__c,
                                                        ASI_MFM_Supplier_Name__c = planLine.ASI_MFM_Supplier_Name__c,
                                                        ASI_MFM_Supplier_Phone_Number__c = planLine.ASI_MFM_Supplier_Name__r.Phone,
                                                        ASI_MFM_Supplier_Fax_Number__c = planLine.ASI_MFM_Supplier_Name__r.Fax,
                                                        ASI_MFM_Dummy_PO__c = planLine.ASI_MFM_Dummy_PO__c,
                                                        ASI_MFM_Status__c = 'Draft',
                                                        ASI_MFM_Prefix__c = mfmPrefix,
                                                        ASI_MFM_PO_Raised_Date__c = Date.today(),
                                                        ASI_MFM_PO_Start_Date__c = planLine.ASI_MFM_Plan__r.ASI_MFM_Start_Date__c,
                                                        ASI_MFM_PO_End_Date__c = planLine.ASI_MFM_Plan__r.ASI_MFM_End_Date__c,
                                                        ASI_MFM_T_E__c = planLine.ASI_MFM_T_E__c,
                                                        ASI_MFM_Sys_Local_Currency__c = 'HKD',
                                                        ASI_MFM_Plan_Line_Item__c = planLine.Id,
                                                        ASI_MFM_Currency__c = planLine.ASI_MFM_Currency__c,
                                                        ASI_MFM_Exchange_Rate__c = planLine.ASI_MFM_Plan__r.ASI_MFM_Exchange_Rate__c,
                                                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__c'+'ASI_MFM_CAP_PO'));
                if (planType == PLAN_TYPE_CAPEX){                                           
                    if (planLine.ASI_MFM_Supplier_Name__c != null){
                        newPO.ASI_MFM_Orginal_PO_Status__c = planLine.ASI_MFM_Supplier_Name__c;
                    } 
                    newPO.ASI_MFM_Orginal_PO_Status__c += planLine.ASI_MFM_Dummy_PO__c ? 'true' : 'false'; 
                }
                newPlanLinePOMap.put(planLine.Id, newPO);
            }
        }
        
        insert newPlanLinePOMap.values();
        
        Boolean POUpdated = false;
        for (ASI_MFM_Plan_Line_Item__c planLine : planLineList){
            ASI_MFM_PO_Line_Item__c newPOLine = new ASI_MFM_PO_Line_Item__c(ASI_MFM_AP_Code__c = planLine.ASI_MFM_AP_Code__c,
                                                                            ASI_MFM_G_L_Date__c  = Date.today(), //WL 1.0
                                                                            ASI_MFM_BU_Code__c = planLine.ASI_MFM_BU_Code__c,
                                                                            ASI_MFM_List_Item_Description__c = planLine.ASI_MFM_List_Item_Description__c,
                                                                            ASI_MFM_Amount__c = planLine.ASI_MFM_Total_Cost__c,
                                                                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__c'+'ASI_MFM_CAP_PO_Line_Item'));
                                                                            
            ASI_MFM_PO__c tempPO = newPlanLinePOMap.get(planLine.Id);

            if (tempPO != null){
                newPOLine.ASI_MFM_PO__c = tempPO.Id;
                ASI_MFM_PO__c PO = tempPO;
                //Logic changed: 
                //Before: If Plan type = CAPEX, generated PO status = final
                //Updated: If ASI_MFM_Prefix__r.ASI_MFM_Bypass_Approval__c = false, generated PO status = final
                if (!planLine.ASI_MFM_Plan__r.ASI_MFM_Prefix__r.ASI_MFM_Bypass_Approval__c){
                    POUpdated = true;
                    
                    PO.ASI_MFM_Status__c = 'Final';
                    //PO.ASI_MFM_PO_Original_Amount__c = planLine.ASI_MFM_Total_Cost__c; //WL 2.0
                    newPlanLinePOMap.put(planLine.Id, PO);
                } 
                PO.ownerId = PlanOwnerID;
                newPlanLinePOMap.put(planLine.Id, PO);
                newPOLineItemList.add(newPOLine);
            }
        }
        
        insert newPOLineItemList;
         
        update newPlanLinePOMap.values();

        //if (POUpdated){
         //   update newPlanLinePOMap.values();
       // }
        /*
        if (planType == PLAN_TYPE_CAPEX){
            for (Id planLineId : newPlanLinePOMap.keySet()){
                ASI_MFM_PO__c PO = newPlanLinePOMap.get(planLineId);
                PO.ASI_MFM_Status__c = 'Final';
                newPlanLinePOMap.put(planLineId, PO);
            }
            
            update newPlanLinePOMap.values();
        }
        */
    }
    
    @testVisible
    private static List<ASI_MFM_Role_Prefix_Relationship__c> getRolePrefixRelationship(String ModuleName, String CountryName, String RecordTypeName){
        Id userId = userinfo.getUserId();
        User userDetails = [SELECT Id, UserRole.DeveloperName FROM User where Id=:userId LIMIT 1];
        String userRoleName = userDetails.UserRole.DeveloperName;
        
        List<ASI_MFM_Role_Prefix_Relationship__c> result = [SELECT Id, 
                                                                ASI_MFM_Prefix__c, 
                                                                ASI_MFM_Prefix__r.ASI_MFM_TR_Rec_Type__c
                                                            FROM ASI_MFM_Role_Prefix_Relationship__c 
                                                            WHERE ASI_MFM_Prefix__r.ASI_MFM_Inactive__c = false
                                                            AND ASI_MFM_Prefix__r.ASI_MFM_Module__c = :ModuleName
                                                            AND ASI_MFM_Prefix__r.ASI_MFM_country_name__c = :CountryName
                                                            AND ASI_MFM_Prefix__r.recordType.DeveloperName = :RecordTypeName
                                                            AND ASI_MFM_Role_Name__c = :userRoleName];
                                                                        
        return result;
    }
    
}
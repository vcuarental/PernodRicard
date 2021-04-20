/*********************************************************************************
 * Name: ASI_CRM_VN_ContractExpenditureThreshold
 * Description: Assign the service pack threshold to contract expenditure
 * Test class : ASI_CRM_VN_ContractExpendTriggerTest
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2017       Hugo Cheung             Created
 * 2018-10-25       Vincent Lam             [VL 1.0] ICM119182106, bypass service pack checking after contract is approved, except POSM
*/
public class ASI_CRM_VN_ContractExpenditureThreshold {
    
    private class ContractServicePackWrapper {
        private ASI_CRM_VN_Contract__c contract    {get; set;}
        private ASI_CRM_ServicePack__c servicePack {get; set;}
        
        private ContractServicePackWrapper(ASI_CRM_VN_Contract__c contract, ASI_CRM_ServicePack__c servicePack) {
            this.contract    = contract;
            this.servicePack = servicePack;
        }
    }
    
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP     = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SERVICE_PACK_FIELD_MAP = Schema.SObjectType.ASI_CRM_ServicePack__c.fields.getMap();
    
    private final static String ITEM_TYPE_LUMP_SUM        = 'CS';
    private final static String ITEM_TYPE_PG_UNIFORM      = 'PG & Uniform';
    private final static String ITEM_TYPE_BRANDING        = 'Branding (Signage)';
    private final static String ITEM_TYPE_FOC_BOTTLES     = 'FOC Bottles';
    private final static String ITEM_TYPE_VIP_ROOMS       = 'VIP Rooms';
    private final static String ITEM_TYPE_GLASSWARE       = 'Glassware (Including Ice Buckets)';
    private final static String ITEM_TYPE_DrinkMenus      = 'Drink Menus';
    private final static String ITEM_TYPE_PodiumStands    = 'Podium Stands & Glorifiers';
    private final static String ITEM_TYPE_DISPLAY_LISTING = 'Display/Listing Fee';
    private final static String ITEM_TYPE_PROMOTION       = 'Promotion';
    private final static String ITEM_TYPE_OUTLET_PROMOTION       = 'Outlet Promotion';    
    
    /* [VL 1.0] BEGIN */
    private final static Id CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Contract_Expenditure__cASI_CRM_VN_Contract_Expenditure_Read_Only');
    private final static Id CAPSULE_AGREEMENT_CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Contract_Expenditure__cASI_CRM_VN_Capsule_Agreement_Contract_Expenditure_Read_Only');
    /* [VL 1.0] END */
    
    public ASI_CRM_VN_ContractExpenditureThreshold() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList   = (List<ASI_CRM_VN_Contract_Expenditure__c>) newList;
        Map<Id, ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureMap = (Map<Id, ASI_CRM_VN_Contract_Expenditure__c>) oldMap;
        
        List<ASI_CRM_VN_Contract_Expenditure__c> filteredContractExpenditureList = filterContractExpenditure(contractExpenditureList, contractExpenditureMap);
        Map<Id, ContractServicePackWrapper> contractServicePackMap = retrieveContractServicePackMap(filteredContractExpenditureList);
        assignServicePack(filteredContractExpenditureList, contractServicePackMap);
    }
    
    private List<ASI_CRM_VN_Contract_Expenditure__c> filterContractExpenditure(List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList, Map<Id, ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureMap) {
        return contractExpenditureList;
    }
    
    private Map<Id, ContractServicePackWrapper> retrieveContractServicePackMap(List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList) {
        Set<Id> contractIdSet = new Set<Id>();
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            contractIdSet.add(contractExpenditure.ASI_CRM_VN_Contract__c);
        }
        
        List<ASI_CRM_VN_Contract__c> contractList = retrieveContractList(contractIdSet);
        Set<Id> servicePackIdSet = new Set<Id>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            if(String.isNotBlank(contract.ASI_CRM_Outlet_WS__r.ASI_CRM_Service_Pack__c)) {
                servicePackIdSet.add(contract.ASI_CRM_Outlet_WS__r.ASI_CRM_Service_Pack__c);
            }
        }
        
        Map<Id, ASI_CRM_ServicePack__c> servicePackMap = new Map<Id, ASI_CRM_ServicePack__c>(retrieveServicePackList(servicePackIdSet));
        
        Map<Id, ContractServicePackWrapper> contractServicePackMap = new Map<Id, ContractServicePackWrapper>();
        for(ASI_CRM_VN_Contract__c contract : contractList) {
            if(String.isNotBlank(contract.ASI_CRM_Outlet_WS__r.ASI_CRM_Service_Pack__c)) {
                ContractServicePackWrapper contractServiceWrapper = new ContractServicePackWrapper(contract, servicePackMap.get(contract.ASI_CRM_Outlet_WS__r.ASI_CRM_Service_Pack__c));
                contractServicePackMap.put(contract.Id, contractServiceWrapper);
            }
        }
        
        return contractServicePackMap;
    }
    
    private void assignServicePack(List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList, Map<Id, ContractServicePackWrapper> contractServicePackMap) {
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
            if(contractServicePackMap.containsKey(contractExpenditure.ASI_CRM_VN_Contract__c) == false) {
                continue;
            }
            
            Boolean isByPassCheck = false;
            ContractServicePackWrapper contractServicePackWrapper = contractServicePackMap.get(contractExpenditure.ASI_CRM_VN_Contract__c);
            if(contractServicePackWrapper.contract.ASI_CRM_Outlet_WS__r.ASI_CRM_Special_Outlet__c) isByPassCheck = true;
            
            /* [VL 1.0] BEGIN */
            if(contractExpenditure.recordtypeid == CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY ||
                contractExpenditure.recordtypeid == CAPSULE_AGREEMENT_CONTRACT_EXPENDITURE_RECORD_TYPE_READ_ONLY
               || ASI_MFM_Function.bypassTriggersFunction('ASI_VN_Admin')
            ){
                isByPassCheck = true;
            }
            /* [VL 1.0] END */
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_PG_UNIFORM) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculatePGUniformThreshold(contractServicePackWrapper.servicePack);
            }
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_BRANDING) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculateBrandingThreshold(contractServicePackWrapper.servicePack);
            }
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_VIP_ROOMS) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculateVIPRoomsThreshold(contractServicePackWrapper.servicePack);
            }
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_GLASSWARE) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculateGlasswareThreshold(contractServicePackWrapper.servicePack);
            }
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_DrinkMenus) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculateDrinkMenuThreshold(contractServicePackWrapper.servicePack);
            }
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_PodiumStands) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculatePodiumStandsThreshold(contractServicePackWrapper.servicePack);
            }
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_DISPLAY_LISTING) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculateDisplayListingThreshold(contractServicePackWrapper.servicePack);
            }
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_PROMOTION) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculatePromotionThreshold(contractServicePackWrapper.servicePack);
            }
            
            if(contractExpenditure.ASI_CRM_VN_Item__c == ITEM_TYPE_OUTLET_PROMOTION) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c = calculatePromotionThreshold(contractServicePackWrapper.servicePack);
            }            
            
            contractExpenditure.ASI_CRM_VN_Service_Pack__c = contractServicePackWrapper.servicePack.Id;
            
            if(contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c == null) {
                continue;
            }
            
            if(contractServicePackWrapper.contract.ASI_CRM_Currency__c == 'VND') {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c *= contractServicePackWrapper.contract.ASI_CRM_To_VND_Exchange_Rate__c;
            }
            
            if(contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c != null) {
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c /= 12;
                contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c *= contractServicePackWrapper.contract.ASI_CRM_No_Of_Months__c;
            }
            
            Decimal totalAmount = (contractExpenditure.ASI_CRM_VN_Amount__c == null ? 0 : contractExpenditure.ASI_CRM_VN_Amount__c)
                                * (contractExpenditure.ASI_CRM_VN_Quantity__c == null ? 0 : contractExpenditure.ASI_CRM_VN_Quantity__c);
            
            if(isByPassCheck == false && 
               totalAmount > contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c) {
                System.debug(contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c.format());
                showError(contractExpenditure, String.format(Label.ASI_CRM_VN_Contract_Expend_Over_Threshold, new String[]{contractExpenditure.ASI_CRM_VN_Service_Pack_Threshold__c.format()}));
            }
        }
    }
    
    //Calculate Threshold Function
    private Decimal calculatePGUniformThreshold(ASI_CRM_ServicePack__c servicePack) {
        Decimal noOfPG          = servicePack.ASI_CRM_No_of_PG_in_one_outlet__c;
        Decimal noOfPGUniform   = servicePack.ASI_CRM_No_of_PG_uniform__c;
        Decimal costOfPG        = servicePack.ASI_CRM_Average_Salary_of_1_PG_per_Year__c;
        Decimal costOfPGUniform = servicePack.ASI_CRM_Cost_per_PG_Uniform_Investment__c;
        
        Decimal threshold = (noOfPG == null ? 0 : noOfPG) 
                          * (costOfPG == null ? 0 : costOfPG) 
                          + (noOfPGUniform == null ? 0 : noOfPGUniform) 
                          * (costOfPGUniform == null ? 0 : costOfPGUniform);
        return threshold;
    }
    
    private Decimal calculateBrandingThreshold(ASI_CRM_ServicePack__c servicePack) {
        Decimal noOfBranding   = servicePack.ASI_CRM_No_of_Signage_per_outlet__c;
        Decimal costOfBranding = servicePack.ASI_CRM_Cost_p_Signage_p_Year_p_Outlet__c;
        
        Decimal threshold = (noOfBranding == null ? 0 : noOfBranding) 
                          * (costOfBranding == null ? 0 : costOfBranding);
        return threshold;
    }
    
    private Decimal calculateVIPRoomsThreshold(ASI_CRM_ServicePack__c servicePack) {
        Decimal noOfVIP   = servicePack.ASI_CRM_No_of_VIP_room__c;
        Decimal costOfVIP = servicePack.ASI_CRM_Cost_per_VIP_Room_Investment__c;
        
        Decimal threshold = (noOfVIP == null ? 0 : noOfVIP) 
                          * (costOfVIP == null ? 0 : costOfVIP);
        return threshold;
    }
    
    private Decimal calculateGlasswareThreshold(ASI_CRM_ServicePack__c servicePack) {
        Decimal noOfGlassware   = servicePack.ASI_CRM_No_of_Glassware__c;
        Decimal costOfGlassware = servicePack.ASI_CRM_Cost_per_Glassware_per_Year__c;
        
        Decimal threshold = (noOfGlassware == null ? 0 : noOfGlassware) 
                          * (costOfGlassware == null ? 0 : costOfGlassware);
        return threshold;
    }
    
    private Decimal calculateDrinkMenuThreshold(ASI_CRM_ServicePack__c servicePack) {
        Decimal noOfDrinkMenu   = servicePack.ASI_CRM_No_of_Drink_menus__c;
        Decimal costOfDrinkMenu = servicePack.ASI_CRM_Cost_per_Drink_menus_per_year__c;
        
        Decimal threshold = (noOfDrinkMenu == null ? 0 : noOfDrinkMenu) 
                          * (costOfDrinkMenu == null ? 0 : costOfDrinkMenu);
        return threshold;
    }
    
    private Decimal calculatePodiumStandsThreshold(ASI_CRM_ServicePack__c servicePack) {
        Decimal noOfPodiumStands   = servicePack.ASI_CRM_No_of_Podium_stand__c;
        Decimal costOfPodiumStands = servicePack.ASI_CRM_Cost_per_Podium_Stand_per_Year__c;
        Decimal noOfGlorifier      = servicePack.ASI_CRM_No_of_Glorifier__c;
        Decimal costOfGlorifier    = servicePack.ASI_CRM_Cost_per_Glorifier_per_Year__c;
        
        Decimal threshold = (noOfPodiumStands == null ? 0 : noOfPodiumStands) 
                          * (costOfPodiumStands == null ? 0 : costOfPodiumStands)
                          + (noOfGlorifier == null ? 0 : noOfGlorifier) 
                          * (costOfGlorifier == null ? 0 : costOfGlorifier);
        return threshold;
    }
    
    private Decimal calculateDisplayListingThreshold(ASI_CRM_ServicePack__c servicePack) {
        return servicePack.ASI_CRM_Display_Listing_Fees__c == null ? 0 : servicePack.ASI_CRM_Display_Listing_Fees__c;
    }
    
    private Decimal calculatePromotionThreshold(ASI_CRM_ServicePack__c servicePack) {
        Decimal noOfPromotion   = servicePack.ASI_CRM_No_of_Promotion_activiti_per_yr__c;
        Decimal costOfPromotion = servicePack.ASI_CRM_Average_Cost_PromotionActivities__c;
        
        Decimal threshold = (noOfPromotion == null ? 0 : noOfPromotion) 
                          * (costOfPromotion == null ? 0 : costOfPromotion);
        return threshold;
    }
    
    private void showError(sObject sObj, String errorMsg) {
        sObj.addError(errorMsg);
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private List<ASI_CRM_VN_Contract__c> retrieveContractList(Set<Id> contractIdSet) {
        String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
                       ', ASI_CRM_Outlet_WS__r.ASI_CRM_Service_Pack__c, ASI_CRM_Outlet_WS__r.ASI_CRM_Special_Outlet__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract__c ' + 
                       'Where Id in :contractIdSet';
        
        return (List<ASI_CRM_VN_Contract__c>) Database.query(query);
    }
    
    private List<ASI_CRM_ServicePack__c> retrieveServicePackList(Set<Id> servicePackIdSet) {
        String query = 'SELECT ' + genQueryField(SERVICE_PACK_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_ServicePack__c ' + 
                       'Where Id in :servicePackIdSet';
        
        return (List<ASI_CRM_ServicePack__c>) Database.query(query);
    }
    
    /***************
    Tools Function
    ***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}
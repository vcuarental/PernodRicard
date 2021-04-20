/*********************************************************************************
 * Name: Jay Chau
 * Description: Controlle  for EUR_CRM_NL_ContractSummaryPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 *  21-04-2017      Jay Chau               Created
*********************************************************************************/

public without sharing class EUR_CRM_NL_ContractPageController extends EUR_CRM_PageControllerBase{

    private ApexPages.StandardController standardController {get;set;}
    public EUR_CRM_Contract__c contractObj {get; set;}

    public List<EUR_CRM_Contract_Account_Mapping__c> contractAcc {get;set;}


    public Set<String> mechanicTypes = new Set<String> {'Pouring Refund','Listing','House Pouring','Exclusivity','Lumpsum','Marketing Tailormade','Brand Activation','Bar Presentation','POS','Drinks Menu','Other Activities','Trainings'};
    public Set<String> mechanicTypesOrder = new Set<String>();
    private List<String> mechanicTypesIds {get; set;}
    public String mechanicTypesIdsString {set;  get{
        String concat = '';
        for(Integer i = 0; i < mechanicTypesIds.size(); i++){
            if(i != 0) concat += ',';
            concat += mechanicTypesIds[i];
        }
        return concat;
    }}

    public String availableActivities {get; set;} // lists available activities according to mechTypes
    public String activitiesWithProducts {get; set;} // lists activities Id with products

    public List<String> mechanicTypeNameList {get; set;}
    public String mechanicTypeName {set; get{
        String concat = '';
        for(Integer i = 0; i < mechanicTypeNameList.size(); i++){
            if(i != 0) concat += ',';
            concat += mechanicTypeNameList[i];
        }
        return concat;
    }
    }
    public Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap {get; set;} // Key is mechanic type name
    public Map<String, EUR_CRM_Contract_Activity_Item__c> activityItemMap {get; set;} // Key is mechanic Type name
    public List<EUR_CRM_Contract_Activity_Item__c> activityItemsWithOtherActivitiesMechanicType {get; set;}
    public Map<id, List<EUR_CRM_Contract_Product_Item__c>> contractProductItemMap {get; set;} //key is contract activity item Id
    public Map<id, Integer> contractProductItemMapSize {get; set;} //key is contract activity item Id
    public Map<Id, EUR_CRM_Contract_Rebate__c> premiumContractRebateByContractActivityItemId { get; set; }
    public Map<Id, EUR_CRM_Contract_Rebate__c> superPremiumContractRebateByContractActivityItemId { get; set; }
    public String premiumContractRebateActivityItemIds { get; set; }
    public String superPremiumContractRebateActivityItemIds { get; set; }

    public Set<String> getMechanicTypes(){
        return mechanicTypes;
    }

    public Boolean isChain {get;set;} {isChain = false;}

    //constructor
    public EUR_CRM_NL_ContractPageController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if (String.isEmpty(this.standardController.getId())){
            addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
        } else {
            contractObj = (EUR_CRM_Contract__c)standardController.getRecord();
            // Retrieve the contract related list data
            retrieveMechanicTypes();
            retrieveActivityLineItems();
            retrieveContractProductItems();
            retrieveContractAccount();
            System.debug('mechanicTypeMap: ' + mechanicTypesIdsString);

            EUR_CRM_Contract__c rt = [SELECT Id,RecordType.DeveloperName FROM EUR_CRM_Contract__c Where Id =: contractObj.Id];

            If(rt.RecordType.DeveloperName == 'EUR_NL_Chain_Contract'){
                isChain = true;
            }

        }
    }
    /***********************************************************************
    *
    *
    *
    ***********************************************************************/
    private void retrieveContractAccount(){
        contractAcc = [ SELECT Id,EUR_CRM_Account__c,EUR_CRM_Account__r.Name,EUR_CRM_Active__c,Name FROM EUR_CRM_Contract_Account_Mapping__c Where EUR_CRM_Contract__c =: contractObj.id];

    }

    /***********************************************************************
    * Description:      Retrieve All Mechanic Types
    *                   mechanicTypeMap
    *
    * Input:            N/A
    * Returns:          void
    * Exception:        N/A
    ***********************************************************************/
    private void retrieveMechanicTypes(){
        mechanicTypeMap = new  Map<String, EUR_CRM_Mechanic_Type__c>();
        mechanicTypesIds = new List<String>();
        mechanicTypeNameList = new List<String>();
        mechanicTypesOrder = new Set<String>();

        for (EUR_CRM_Mechanic_Type__c mechanic: [SELECT Id, Name, EUR_CRM_Country_Code__c
        FROM EUR_CRM_Mechanic_Type__c
        WHERE EUR_CRM_Country_Code__c = 'NL'
        ORDER BY  EUR_CRM_Display_Order__c
        LIMIT 20])
        {
            if(mechanicTypes.contains(mechanic.Name)){
                mechanicTypeMap.put(mechanic.Name, mechanic);
                mechanicTypesIds.add(mechanic.Id);
                mechanicTypeNameList.add(mechanic.Name);
                mechanicTypesOrder.add(mechanic.Name);
            }
        }
        System.debug('mechanicTypeMap:' + mechanicTypeMap);
    }


    /***********************************************************************
    * Description:      Retrieve All Contract Activity Line Items
    *                   populates the Activity product Item map
    *
    * Input:            N/A
    * Returns:          void
    * Exception:        N/A
    ***********************************************************************/
    public void retrieveActivityLineItems(){
        activityItemMap = new Map<String, EUR_CRM_Contract_Activity_Item__c>();
        premiumContractRebateByContractActivityItemId = new Map<Id, EUR_CRM_Contract_Rebate__c>();
        superPremiumContractRebateByContractActivityItemId = new Map<Id, EUR_CRM_Contract_Rebate__c>();
        activityItemsWithOtherActivitiesMechanicType = new List<EUR_CRM_Contract_Activity_Item__c>();
        for (EUR_CRM_Contract_Activity_Item__c activity : [SELECT Id, Name, EUR_CRM_Contract__c,
            EUR_CRM_Mechanic_Type__c, EUR_CRM_Mechanic_Type__r.Name,
            EUR_CRM_Lumpsum_Value__c,EUR_CRM_Amount__c ,
            EUR_CRM_Description__c,
            EUR_CRM_Product_Item_Qty_Total__c,
            EUR_CRM_Total_Actual_Performance_Bottles__c,
            EUR_CRM_Total_Actual_Performance_liters__c,
            EUR_CRM_Performance_Index__c,
            EUR_CRM_Amount_Year_1__c ,EUR_CRM_Amount_Year_2__c ,EUR_CRM_Amount_Year_3__c ,
            EUR_CRM_Premium_Total_Volume_lt__c,EUR_CRM_Super_Premium_Total_Volume_lt__c,EUR_CRM_Total_Volume_lt__c,
            EUR_CRM_Premium_Performance_Rebate__c,EUR_CRM_Premium_Total_Performance_Rebate__c,EUR_CRM_Premium_Give_Conditional_Rebate__c,
            EUR_CRM_Premium_Conditional_Rebate__c,EUR_CRM_Premium_Total_Conditional_Rebate__c,EUR_CRM_SP_Performance_Rebate__c,
            EUR_CRM_SP_Total_Performance_Rebate__c,EUR_CRM_SP_Give_Conditional_Rebate__c,
            EUR_CRM_SP_Conditional_Rebate__c,EUR_CRM_SP_Total_Conditional_Rebate__c,EUR_CRM_Total_Rebate__c
            ,EUR_CRM_Mechanic_Type__r.EUR_CRM_Is_Displayed_Volume__c
        ,   (
            SELECT Id
            ,   EUR_CRM_Product_Sub_Category__c
            ,   EUR_CRM_Performance_Rebate__c
            ,   EUR_CRM_Total_Performance_Rebate__c
            ,   EUR_CRM_Give_Conditional_Rebate__c
            ,   EUR_CRM_Conditional_Rebate__c
            ,   EUR_CRM_Total_Conditional_Rebate__c
            FROM Contract_Rebates_EU__r
            WHERE EUR_CRM_Contract_Activity_Item_EU__r.EUR_CRM_Mechanic_Type__r.Name = 'Pouring Refund'
                AND (EUR_CRM_Product_Sub_Category__c = 'Premium' OR EUR_CRM_Product_Sub_Category__c = 'Super Premium')
            ORDER BY EUR_CRM_Product_Sub_Category__c
        )
        FROM EUR_CRM_Contract_Activity_Item__c
        WHERE EUR_CRM_Contract__c =: contractObj.Id]){
            if (activity.EUR_CRM_Mechanic_Type__c != null && activity.EUR_CRM_Mechanic_Type__r.Name.equalsIgnoreCase('Pouring Refund') && ! activity.Contract_Rebates_EU__r.isEmpty()) {
                for (EUR_CRM_Contract_Rebate__c contractRebate : activity.Contract_Rebates_EU__r) {
                    if (contractRebate.EUR_CRM_Product_Sub_Category__c.equalsIgnoreCase('Premium')) {
                        premiumContractRebateByContractActivityItemId.put(activity.Id, contractRebate);
                    } else {
                        superPremiumContractRebateByContractActivityItemId.put(activity.Id, contractRebate);
                    }
                }
            }
            activityItemMap.put(activity.EUR_CRM_Mechanic_Type__r.Name, activity);
            if (activity.EUR_CRM_Mechanic_Type__c != null && activity.EUR_CRM_Mechanic_Type__r.Name.equalsIgnoreCase('Other Activities')) {
                activityItemsWithOtherActivitiesMechanicType.add(activity);
            }
        }
        System.debug('\n\n activityItemMap.size() => ' + JSON.serializePretty(activityItemMap.size()) + '\n');
        System.debug('\n\n activityItemMap => ' + activityItemMap + '\n');
        System.debug('\n\n activityItemsWithOtherActivitiesMechanicType.size() => ' + JSON.serializePretty(activityItemsWithOtherActivitiesMechanicType.size()) + '\n');
        System.debug('\n\n activityItemsWithOtherActivitiesMechanicType => ' + JSON.serializePretty(activityItemsWithOtherActivitiesMechanicType) + '\n');

        availableActivities = String.join(new List<String>(activityItemMap.keySet()), ', ');
        premiumContractRebateActivityItemIds = String.join(new List<Id>(premiumContractRebateByContractActivityItemId.keySet()), ', ');
        superPremiumContractRebateActivityItemIds = String.join(new List<Id>(superPremiumContractRebateByContractActivityItemId.keySet()), ', ');
    }

    /***********************************************************************
    * Description:      Retrieve All Contract Products
    *                   populates the contractProductItemMap
    *
    * Input:            N/A
    * Returns:          void
    * Exception:        N/A
    ***********************************************************************/
    private void retrieveContractProductItems(){
        contractProductItemMap = new  Map<Id, List<EUR_CRM_Contract_Product_Item__c>>();
        contractProductItemMapSize = new Map<Id, Integer>();
        List<EUR_CRM_Contract_Product_Item__c> contractProductItemList = [SELECT Id, Name,
            EUR_CRM_Quantity__c,
            EUR_CRM_Actual_Performance__c,
            EUR_CRM_Actual_Performance_Liters__c,
            EUR_CRM_Contract_Activity_Item__c, EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
            EUR_CRM_Category_Name__c,
            EUR_CRM_Amount__c,EUR_CRM_Marketing_Amount__c,EUR_CRM_Amount_Spent__c ,
            EUR_CRM_Premium_Super_Premium__c,EUR_CRM_Volume_lt__c,
            //EUR_CRM_House_Pouring__c ,EUR_CRM_Exclusive__c,
            EUR_CRM_Brand_Name__c,EUR_CRM_Description__c ,
            EUR_CRM_Brand__c,EUR_CRM_Brand__r.name,
            EUR_CRM_Brand_Quality__c,EUR_CRM_Brand_Quality__r.name,EUR_CRM_Brand_Quality__r.EUR_CRM_Contributive_Margin_BQ__c, EUR_CRM_Brand_Quality__r.EUR_CMR_Net_Sales__c,EUR_CRM_Brand_Quality__r.EUR_CRM_Sub_Category__c,
            EUR_CRM_Brand_Quality_Size__c,EUR_CRM_Brand_Quality_Size__r.Name,EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c
            ,EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_Is_Displayed_Volume__c
        FROM EUR_CRM_Contract_Product_Item__c
        WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c =: contractObj.id
        LIMIT 49999];
        System.debug('contractProductItemList = '+contractProductItemList);
        for (EUR_CRM_Contract_Product_Item__c productItem: contractProductItemList) {
            String key = productItem.EUR_CRM_Contract_Activity_Item__c;
            if(contractProductItemMap.get(key) == null) {
                contractProductItemMap.put(key, new List<EUR_CRM_Contract_Product_Item__c>());
            }
            contractProductItemMap.get(key).add(productItem);

            if (contractProductItemMapSize.get(key) == null) {
                contractProductItemMapSize.put(key, 0);
            }
            Integer countPfRecords = contractProductItemMapSize.get(key);
            countPfRecords++;
            contractProductItemMapSize.put(key, countPfRecords);
        }
        activitiesWithProducts = String.join(new List<Id>(contractProductItemMap.keySet()), ', ');
        System.debug('contractObj.id = '+contractObj.id);
        System.debug('\n\n contractProductItemMap.size() => ' + JSON.serializePretty(contractProductItemMap.size()) + '\n');
        System.debug('\n\n contractProductItemMap => ' + JSON.serializePretty(contractProductItemMap) + '\n');
        System.debug('\n\n contractProductItemMapSize.size() => ' + JSON.serializePretty(contractProductItemMapSize.size()) + '\n');
        System.debug('\n\n contractProductItemMapSize => ' + JSON.serializePretty(contractProductItemMapSize) + '\n');
    }

    /********************************************************************************
    * Description:      Helper function to display an error message on the page
    *
    * Input:            Severity: the warning level
    *                   message: The mesage to be display
    * Returns:          void
    * Exception:        N/A
    ********************************************************************************/
    private void addMessage(ApexPages.Severity severity, String message){
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }
}
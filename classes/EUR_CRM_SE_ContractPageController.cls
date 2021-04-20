/*********************************************************************************
 * Name: Kevin Choi
 * Description:  Controller that return list of product items in different category
                     for specific contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -------------------------------------
 *  14-03-2017      Kevin Choi               Created
*********************************************************************************/

public without sharing class EUR_CRM_SE_ContractPageController extends EUR_CRM_PageControllerBase{

    private ApexPages.StandardController standardController {get;set;}
    public EUR_CRM_Contract__c contractObj {get; set;}

    
    public Set<String> mechanicTypes = new Set<String> {'Pouring Wine', 'Pouring Spirits', 'Pouring Champagne', 'Pouring Other', 'Listed Wine', 'Listed Spirits', 'Listed Champagne', 'Listed Other', 'Marketing A&P', 'Sales A&P'}; // Set to control the order of the table
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
    public Map<id, List<EUR_CRM_Contract_Product_Item__c>> contractProductItemMap {get; set;} //key is contract activity item Id

    public Set<String> getMechanicTypes(){
        return mechanicTypes;
    }

    //constructor
    public EUR_CRM_SE_ContractPageController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if (String.isEmpty(this.standardController.getId())){
            addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
        } else {
            contractObj = (EUR_CRM_Contract__c)standardController.getRecord();
            // Retrieve the contract related list data
            retrieveMechanicTypes();
            retrieveActivityLineItems();
            retrieveContractProductItems();
            System.debug('mechanicTypeMap: ' + mechanicTypesIdsString);
        }
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
        for (EUR_CRM_Mechanic_Type__c mechanic: [SELECT Id, Name, EUR_CRM_Country_Code__c
                                                FROM EUR_CRM_Mechanic_Type__c
                                                WHERE EUR_CRM_Country_Code__c = 'SE' 
                                                LIMIT 10])
        {
            if(mechanicTypes.contains(mechanic.Name)){
                
                mechanicTypeMap.put(mechanic.Name, mechanic);
                mechanicTypesIds.add(mechanic.Id);
                mechanicTypeNameList.add(mechanic.Name);
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
        for (EUR_CRM_Contract_Activity_Item__c activity : [SELECT Id, Name, EUR_CRM_Contract__c,                                                  
                                                            EUR_CRM_Mechanic_Type__c, EUR_CRM_Mechanic_Type__r.Name,
                                                            EUR_CRM_Lumpsum_Value__c,
                                                            EUR_CRM_Description__c,
                                                            EUR_CRM_Product_Item_Qty_Total__c,
                                                            EUR_CRM_Total_Actual_Performance_Bottles__c,
                                                            EUR_CRM_Total_Actual_Performance_liters__c,
                                                            EUR_CRM_Performance_Index__c
                                                            FROM EUR_CRM_Contract_Activity_Item__c
                                                            WHERE EUR_CRM_Contract__c =: contractObj.Id])
        {
            activityItemMap.put(activity.EUR_CRM_Mechanic_Type__r.Name, activity);
        }
        availableActivities = string.valueof(activityItemMap.keyset()).replace('{', '').replace('{', '');
        System.debug('activityItemMap:' + activityItemMap);
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
        for (EUR_CRM_Contract_Product_Item__c productItem: [SELECT Id, Name,
                                                            EUR_CRM_Brand_Name__c,
                                                            EUR_CRM_Brand__r.Name,
                                                            EUR_CRM_Brand_Quality__c,
                                                            EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Brand_Quality_Size__r.Name,
                                                            EUR_CRM_Quantity__c,
                                                            EUR_CRM_Actual_Performance__c,
                                                            EUR_CRM_Actual_Performance_Liters__c,
                                                            EUR_CRM_Contract_Activity_Item__c, EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
                                                            EUR_CRM_Category_Name__c
                                                            FROM EUR_CRM_Contract_Product_Item__c
                                                            WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c =: contractObj.id                                             
                                                            LIMIT 49999])
        {
            String key = productItem.EUR_CRM_Contract_Activity_Item__c;
            if(contractProductItemMap.get(key) == null) {
                contractProductItemMap.put(key, new List<EUR_CRM_Contract_Product_Item__c>());                
            }
            contractProductItemMap.get(key).add(productItem);
        }
        activitiesWithProducts = string.valueof(contractProductItemMap.keyset()).replace('{', '').replace('{', '');
        System.debug('contractProductItemMap:' + contractProductItemMap); 
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
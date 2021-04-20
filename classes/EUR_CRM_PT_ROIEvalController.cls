public with sharing class EUR_CRM_PT_ROIEvalController {
    private ApexPages.StandardController standardController {get;set;} 
    public EUR_CRM_Contract__c contractObj {get; set;}
    public Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap {get; set;} // Key is mechanic type name
    public Map<String,List<MechanicTypeWrapper>> mechTypeWrapperMap {get; set;}
    public Set<String> mechanicTypes = new Set<String> {'Lump Sum','Volume Targets and Rebates','Events','POS Material','Uniforms','Drinks Menu Participation','Drinks Menu Production','Other Marketing Activities','Bar Styling'}; // Set to control the order of the table
    public String availableActivities   {get{
                                                if(availableActivities == null){
                                                    availableActivities = ', ';      
                                                    for(String key : mechTypeWrapperMap.keyset()){
                                                        availableActivities += key + ', ';
                                                    }
                                                    System.debug('availableActivities: ' + availableActivities);
                                                }
                                                return availableActivities;
                                            }
                                        set;} // lists available activities according to mechTypes

    public Set<String> getMechanicTypes(){ 
        return mechanicTypes;
    }
    
      //constructor
    public EUR_CRM_PT_ROIEvalController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if (String.isEmpty(this.standardController.getId())){
        } else {
            contractObj = (EUR_CRM_Contract__c)standardController.getRecord();
            // Retrieve the contract related list data
            retrieveMechanicTypes(); 
            retrieveActivityLineItems(); 
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
        for (EUR_CRM_Mechanic_Type__c mechanic: [SELECT Id, Name, EUR_CRM_Country_Code__c
                                                FROM EUR_CRM_Mechanic_Type__c
                                                WHERE EUR_CRM_Country_Code__c = 'PT'])
        {
            mechanicTypeMap.put(mechanic.Name, mechanic);         
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
        mechTypeWrapperMap = new Map<String,List<MechanicTypeWrapper>>(); 
        for (EUR_CRM_Contract_Activity_Item__c activity : [SELECT Id, Name, EUR_CRM_Contract__c,                                                  
                                                            EUR_CRM_Mechanic_Type__c, EUR_CRM_Mechanic_Type__r.Name,EUR_CRM_Mechanic_Type__r.EUR_CRM_Country_Code__c,
                                                            EUR_CRM_Lumpsum_Value__c,
                                                            EUR_CRM_Description__c,
                                                            EUR_CRM_Product_Item_Qty_Total__c,
                                                            EUR_CRM_Total_Actual_Performance_Bottles__c,
                                                            EUR_CRM_Performance_Index__c,
                                                            EUR_CRM_Amount__c,EUR_CRM_Product_Items_Total__c,EUR_CRM_Name__c,
                                                            (Select Name,EUR_CRM_Brand__c,EUR_CRM_Brand__r.name,EUR_CRM_Brand_Quality__r.name,EUR_CRM_Brand_Quality_Size__r.name,EUR_CRM_Quantity__c,
                                                                EUR_CRM_Amount__c,EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Contributive_Margin_BQS__c,EUR_CRM_Marketing_Amount__c,EUR_CRM_Amount_Spent__c 
                                                             from Contract_Product_Items__r)
                                                            FROM EUR_CRM_Contract_Activity_Item__c
                                                            WHERE EUR_CRM_Contract__c =: contractObj.Id 
                                                            //LIMIT 49999
                                                            ])
        {

            String key = activity.EUR_CRM_Mechanic_Type__r.Name;
            if(mechTypeWrapperMap.containsKey(key)){
                mechTypeWrapperMap.get(key).add(new MechanicTypeWrapper(key, activity,activity.Contract_Product_Items__r));
            }
            else{
                List<MechanicTypeWrapper> mecTypes = new List<MechanicTypeWrapper>();
                mecTypes.add(new MechanicTypeWrapper(key, activity,activity.Contract_Product_Items__r));
                mechTypeWrapperMap.put(key,mecTypes);
            }
        }
    }
    
    public class MechanicTypeWrapper{
        public String mechTypeName {get; set;}
        public EUR_CRM_Contract_Activity_Item__c activity {get; set;}
        public List<EUR_CRM_Contract_Product_Item__c> productItems {get; set;}
        public Boolean hasItems{get;set;}
        public MechanicTypeWrapper(String mechTypeName, EUR_CRM_Contract_Activity_Item__c activityx,List<EUR_CRM_Contract_Product_Item__c> productItemsx){
            this.mechTypeName = mechTypeName;
            activity = activityx;
            productItems = productItemsx;
            if(productItemsx.size() > 0){
                hasItems = true;
            }
        }
    }
    
}
public class EUR_CRM_PT_ContractPageController {
    private ApexPages.StandardController standardController {get;set;} 
    public EUR_CRM_Contract__c contractObj {get; set;}

    
    public Set<String> mechanicTypes = new Set<String> {'Lump Sum','Listing','House Pour','Volume Targets and Rebates','Events','POS Material','Uniforms','Drinks Menu Participation','Drinks Menu Production','Other Marketing Activities','Bar Styling','Trainings'}; // Set to control the order of the table
    private List<String> mechanicTypesIds {get; set;}
    private List<String> mechanicTypesNames {get; set;}
    private List<String> mechanicTypesNamesIds {get; set;}
    public String mechanicTypesIdsString {set;  get{ 
                                                    String concat = '';
                                                    for(Integer i = 0; i < mechanicTypesIds.size(); i++){
                                                        if(i != 0) concat += ',';
                                                        concat += mechanicTypesIds[i];
                                                    }
                                                    return concat;
                                                }}
     public String mechanicTypesNameString {set;  get{ 
                                                    String concat = '';
                                                    for(Integer i = 0; i < mechanicTypesNames.size(); i++){
                                                        if(i != 0) concat += ',';
                                                        concat += mechanicTypesNames[i];
                                                    }
                                                    return concat;
                                                }}
     public String mechanicTypesNameIdString {set;  get{ 
                                                    String concat = '';
                                                    for(Integer i = 0; i < mechanicTypesNamesIds.size(); i++){
                                                        if(i != 0) concat += ',';
                                                        concat += mechanicTypesNamesIds[i];
                                                    }
                                                    return concat;
                                                }}                                            
    public String availableActivities { get {
                                                if(availableActivities == null){
                                                    availableActivities = ', ';
                                                    for(String key : activityItemMap.KeySet()){
                                                        availableActivities += key + ', ';
                                                    }
                                                    System.debug('availableActivities: ' + availableActivities);
                                                }
                                                return availableActivities;
                                            }
                                        set;
                                        } // lists available activities according to mechTypes
    public String activitiesWithProducts {get; set;} // lists activities Id with products

    public Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap {get; set;} // Key is mechanic type name
    public Map<String, EUR_CRM_Contract_Activity_Item__c> activityItemMap {get; set;} // Key is mechanic Type name
    public Map<id, List<EUR_CRM_Contract_Product_Item__c>> contractProductItemMap {get; set;} //key is contract activity item Id
    public Map<String, List<EUR_CRM_Quality__c>> BQualitiesMap {get; set;} //key is mechanic type name
    public Map<String,List<MechanicTypeWrapper>> mechtypeWrapper {get; set;}
    public Map<String,List<MechanicTypeWrapperByActivity>> mechtypeWrapperActivity {get; set;}

    public Set<String> getMechanicTypes(){ 
        return mechanicTypes;
    }

    //constructor
    public EUR_CRM_PT_ContractPageController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if (String.isEmpty(this.standardController.getId())){
            addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
        } else {
            contractObj = (EUR_CRM_Contract__c)standardController.getRecord();
            // Retrieve the contract related list data
            retrieveMechanicTypes();
            retrieveActivityLineItems();
            retrieveContractProductItems(); 
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
        mechanicTypesNames = new List<String>();
        mechanicTypesNamesIds = new List<String>();
        for (EUR_CRM_Mechanic_Type__c mechanic: [SELECT Id, Name, EUR_CRM_Country_Code__c
                                                FROM EUR_CRM_Mechanic_Type__c
                                                WHERE EUR_CRM_Country_Code__c = 'PT'])
        {
            if(mechanicTypes.contains(mechanic.Name)){
                mechanicTypeMap.put(mechanic.Name, mechanic);
                mechanicTypesIds.add(mechanic.Id);
                mechanicTypesNames.add(mechanic.Name);
                mechanicTypesNamesIds.add(mechanic.Id +'-' +mechanic.Name);
                
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
        mechtypeWrapperActivity = new Map<String,List<MechanicTypeWrapperByActivity>>();
        for (EUR_CRM_Contract_Activity_Item__c activity : [SELECT Id, Name, EUR_CRM_Contract__c,                                                  
                                                            EUR_CRM_Mechanic_Type__c, EUR_CRM_Mechanic_Type__r.Name,
                                                            EUR_CRM_Lumpsum_Value__c,
                                                            EUR_CRM_Description__c,
                                                            EUR_CRM_Product_Item_Qty_Total__c,
                                                            EUR_CRM_Total_Actual_Performance_Bottles__c,
                                                            EUR_CRM_Performance_Index__c,
                                                            EUR_CRM_Amount__c,EUR_CRM_Product_Items_Total__c,EUR_CRM_Name__c,
                                                            (Select Name,EUR_CRM_Brand__c from Contract_Product_Items__r)
                                                            FROM EUR_CRM_Contract_Activity_Item__c
                                                            WHERE EUR_CRM_Contract__c =: contractObj.Id 
                                                            //LIMIT 49999
                                                            ])
        {
            activityItemMap.put(activity.EUR_CRM_Mechanic_Type__r.Name, activity);
            String key = activity.EUR_CRM_Mechanic_Type__r.Name;
            if(mechtypeWrapperActivity.containsKey(key)){
                mechtypeWrapperActivity.get(key).add(new MechanicTypeWrapperByActivity(activity,activity.Contract_Product_Items__r));
            }
            else{
                List<MechanicTypeWrapperByActivity> mecTypes = new List<MechanicTypeWrapperByActivity>();
                mecTypes.add(new MechanicTypeWrapperByActivity(activity,activity.Contract_Product_Items__r));
                mechtypeWrapperActivity.put(key,mecTypes);
            }
        }

        System.debug('activityItemMap:' + activityItemMap);
    }

    /***********************************************************************
    * Description:      Retrieve All Contract Products
    *                   populates the mechtypeWrapper
    *                   
    * Input:            N/A
    * Returns:          void
    * Exception:        N/A
    ***********************************************************************/
    private void retrieveContractProductItems(){
        mechtypeWrapper = new Map<String,List<MechanicTypeWrapper>>();     
        for (EUR_CRM_Contract_Product_Item__c productItem: [SELECT Id, Name,
                                                            EUR_CRM_Brand_Quality__r.EUR_CRM_Category__c,
                                                            EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name,
                                                            EUR_CRM_Brand_Quality_Size__c, EUR_CRM_Brand_Quality_Size__r.Name,
                                                            EUR_CRM_Quantity__c,
                                                            EUR_CRM_Actual_Performance__c,
                                                            EUR_CRM_Contract_Activity_Item__c, EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
                                                            EUR_CRM_Amount__c,EUR_CRM_Amount_Spent__c, 
                                                            EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Name__c,
                                                            EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Amount__c,
                                                            EUR_CRM_Brand__c,EUR_CRM_Description__c,
                                                            EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__c,
                                                            EUR_CRM_Marketing_Amount__c 
                                                        
                                                            FROM EUR_CRM_Contract_Product_Item__c
                                                            WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c =: contractObj.id                                             
                                                            LIMIT 49999])
        {
            String key = productItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name; 

            if(mechtypeWrapper.containsKey(key)){
                mechtypeWrapper.get(key).add(new MechanicTypeWrapper(productItem.EUR_CRM_Brand_Quality__r,productItem.EUR_CRM_Brand_Quality_Size__r,productItem,productItem.EUR_CRM_Contract_Activity_Item__r,productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r));
            }
            else{
                List<MechanicTypeWrapper> mecTypes = new List<MechanicTypeWrapper>();
                mecTypes.add(new MechanicTypeWrapper(productItem.EUR_CRM_Brand_Quality__r,productItem.EUR_CRM_Brand_Quality_Size__r,productItem,productItem.EUR_CRM_Contract_Activity_Item__r,productItem.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r));
                mechtypeWrapper.put(key,mecTypes);
            }
        }
        activitiesWithProducts = string.valueof(mechtypeWrapper.keyset()).replace('{', '').replace('{', '');
    }
    
    public class MechanicTypeWrapper{
        public EUR_CRM_Quality__c quality{get;set;}
        public EUR_CRM_Size__c size{get; set;}
        public EUR_CRM_Contract_Product_Item__c prodItem{get; set;}
        public EUR_CRM_Contract_Activity_Item__c activity{get; set;}
        public EUR_CRM_Brand__c brand {get; set;}
        MechanicTypeWrapper(EUR_CRM_Quality__c qualityx,EUR_CRM_Size__c sizex,EUR_CRM_Contract_Product_Item__c prodItemx,EUR_CRM_Contract_Activity_Item__c activityx,EUR_CRM_Brand__c brandx){
            quality = qualityx;
            size = sizex;
            prodItem = prodItemx;
            activity = activityx;
            brand= brandx;
        }
    }
    
    public class MechanicTypeWrapperByActivity{
        public EUR_CRM_Contract_Activity_Item__c activity{get; set;}
        public List<EUR_CRM_Contract_Product_Item__c> prodItems {get; set;}
        MechanicTypeWrapperByActivity(EUR_CRM_Contract_Activity_Item__c activityx,List<EUR_CRM_Contract_Product_Item__c> prodItemsx){
            activity = activityx;
            prodItems = prodItemsx;
        }
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
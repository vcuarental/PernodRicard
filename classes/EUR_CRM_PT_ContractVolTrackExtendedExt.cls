public with sharing class EUR_CRM_PT_ContractVolTrackExtendedExt {
    private ApexPages.StandardController standardController {get;set;} 
    public EUR_CRM_Contract__c contractObj {get; set;}

    
    public Set<String> mechanicTypes = new Set<String> {'Volume Targets and Rebates'}; // Set to control the order of the table
    private List<String> mechanicTypesNames {get; set;}
    private List<String> mechanicTypesNamesIds {get; set;}
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

    public Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap {get; set;} // Key is mechanic type name
	public Map<String,List<VolumeTrackerWrapper>> VolumeTrackerWrapperMap {get; set;} 
    public String availableActivities {get; set;} // lists available activities according to mechTypes

    public Set<String> getMechanicTypes(){ 
        return mechanicTypes;
    }

    //constructor
    public EUR_CRM_PT_ContractVolTrackExtendedExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        if (String.isEmpty(this.standardController.getId())){
            addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
        } else {
            contractObj = (EUR_CRM_Contract__c)standardController.getRecord();
            // Retrieve the contract related list data
            retrieveMechanicTypes();
            retrieveVolumeTrackerRecords();	

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
        mechanicTypesNames = new List<String>();
        mechanicTypesNamesIds = new List<String>();
        for (EUR_CRM_Mechanic_Type__c mechanic: [SELECT Id, Name, EUR_CRM_Country_Code__c
                                                FROM EUR_CRM_Mechanic_Type__c
                                                WHERE EUR_CRM_Country_Code__c = 'PT' and recordtype.developername='EUR_PT_Volume_Targets_and_Rebates_Mechanic_Type' and name='Volume Targets and Rebates'
                                                
                                                ])
        {
            if(mechanicTypes.contains(mechanic.Name)){
                mechanicTypeMap.put(mechanic.Name, mechanic);
                mechanicTypesNames.add(mechanic.Name);
                mechanicTypesNamesIds.add(mechanic.Id +'-' +mechanic.Name);
                
            }
        }

        for(String key : mechanicTypeMap.keyset()){
            availableActivities += (' ' + key);
        }
        
        System.debug('availableActivities: ' + availableActivities);
        System.debug('mechanicTypeMap:' + mechanicTypeMap); 
    }

    
    /***********************************************************************
    * Description:      Retrieve All Volume Tracker Line records
    *                   populates the VolumeTrackerWrapperMap
    *                   
    * Input:            N/A
    * Returns:          void
    * Exception:        N/A
    ***********************************************************************/
 	private void retrieveVolumeTrackerRecords(){
        VolumeTrackerWrapperMap = new Map<String,List<VolumeTrackerWrapper>>();     
  		for (EUR_CRM_GB_Volume_Tracker_Line_Item__c trackerLine : [                                             
                                                            Select Name,EUR_CRM_Brand_Quality_Size__c,EUR_CRM_Initial_Contract_Volume__c,
                                                            EUR_CRM_Actual_Qty__c,EUR_CRM_Distance_To_Go_Formula__c,EUR_CRM_Distance_To_Go__c,EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name,
                                                            EUR_CRM_Mechanic_Type_Name_Formula__c 
                                                            from EUR_CRM_GB_Volume_Tracker_Line_Item__c
                                                            where EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c =: contractObj.id 
                                                            ])
        {
            String key = trackerLine.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name;
            if(VolumeTrackerWrapperMap.containsKey(key)){   
    	 		VolumeTrackerWrapperMap.get(key).add(new  VolumeTrackerWrapper(key,trackerLine));
            }
	        else
	        {
        		List<VolumeTrackerWrapper> mecTypes = new List<VolumeTrackerWrapper>();
            	mecTypes.add(new  VolumeTrackerWrapper(key,trackerLine));
            	VolumeTrackerWrapperMap.put(key,mecTypes);
	       	}
            
        }

    }
    
    
    /***********************************************************************
    * Description:      Place All Volume Tracker Line records in a wrapper
    *                   
    *                   
    * Input:            N/A
    * Returns:          void
    * Exception:        N/A
    ***********************************************************************/
    public class VolumeTrackerWrapper{
 		public String mechanicTypeName {get; set;}
    	public EUR_CRM_GB_Volume_Tracker_Line_Item__c trackerLine{get; set;}
    	VolumeTrackerWrapper(String mechanicTypeNamex,EUR_CRM_GB_Volume_Tracker_Line_Item__c trackerLinex){
			mechanicTypeName = mechanicTypeNamex;
    		trackerLine = trackerLinex; 
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
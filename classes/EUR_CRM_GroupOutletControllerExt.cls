/*
    Name : EUR_CRM_GroupOutletControllerExt
    Description :  VF page Controller for creating new or editing Group Outlet Types and their outlet types
 */

public with sharing class EUR_CRM_GroupOutletControllerExt {
    
    private final String ACTION_EDIT = 'EDIT';
    private final String ACTION_NEW = 'NEW';
    private final String ACTION;
    private ApexPages.StandardController standardController;
    private List<Schema.PicklistEntry> imageLevelOptions;
    private List<Schema.PicklistEntry> volumePotentialOptions;
    private Map<Id, EUR_CRM_Outlet_Type__c> outletTypes {get;set;}
    private Id affiliateId {get;set;}{affiliateId = null;}

    public Boolean isDisplayed{get; set;}{isDisplayed = true;} 
    public EUR_CRM_Group_Outlet_Type__c groupOutletType{get;set;}
    public List<EUR_CRM_Image_Level__c> imageLevelsList{get;set;}
    public List<EUR_CRM_Volume_Potential__c> volumePotentialsList{get;set;}
    public List<EUR_CRM_Image_Level_Threshold__c> imageLevelsThresholdsList{get;set;}
    public List<EUR_CRM_Volume_Potential_Threshold__c> volumePotentialsThresholdsList{get;set;}
    public Boolean hasImageLevel {get;set;}
    public Boolean hasVolPotential {get;set;}
    public Integer rowIndex{get;set;}
    public List<EUR_CRM_Outlet_Type__c> outletTypesDisplay {get;set;}
    public List<EUR_CRM_Outlet_Type__c> deleteOutletTypes{get;set;}
    
    public String rid;
    public String recordtypeDevName;
    public Id recId;
    public String countrycode;
    public Set<String> imageSetValues {get;set;}
 
    public Boolean hasOutletDescription{get{
        return (countrycode.equalsIgnoreCase('E1'))?true:false;
    }}
    
    public EUR_CRM_GroupOutletControllerExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        hasImageLevel = false;
        hasVolPotential = false;
        rId = ApexPages.currentPage().getParameters().get('RecordType');
        
        system.debug('@@affiliateId' + rId);

        if (this.standardController.getId() == null)
        {
            groupOutletType = new EUR_CRM_Group_Outlet_Type__c();
            groupOutletType.RecordTypeId = rId;
        }
        else if (this.standardController.getId() != null)
        {
            groupOutletType = returnGroupOutletType(this.standardController.getId());
        }
            
        initOutletTypes();
        initImageLevels();
        initVolumePotentials();
    }


    /*
        Retrieves all the outlet types associated with the group outlet type
        If a group outlet type is being created, it will be associated with records of outlet types
        belonging to the same country
    */    
    public void initOutletTypes(){
        outletTypesDisplay = new List<EUR_CRM_Outlet_Type__c>();
        deleteOutletTypes = new List<EUR_CRM_Outlet_Type__c>();
        system.debug('@@DevName :' + recId);

        // If editing existing group outlet type
        if (this.standardController.getId() != null){
            outletTypes = new Map<Id, EUR_CRM_Outlet_Type__c>([SELECT Id, EUR_CRM_Name__c, 
                                                        EUR_CRM_Active__c, RecordTypeId,
                                                        EUR_CRM_Country_Code__c, EUR_CRM_Description__c            
                                                        FROM EUR_CRM_Outlet_Type__c
                                                        WHERE EUR_CRM_Group_Outlet_Type__c =:groupOutletType.Id 
                                                        AND EUR_CRM_Active__c = true
                                                        LIMIT 4999]);               
        }
               
        if (outletTypes != null && outletTypes.size()>0)
        {
            outletTypesDisplay.addAll(outletTypes.values());
            countryCode = outletTypes.values().get(0).EUR_CRM_Country_Code__c;
            recId = outletTypes.values().get(0).RecordTypeId;
        }
        // if creating a new outlet type
        else{
            system.debug('Flag2');

            if(rId == null) {
                // User is only assigned one record type which is defaulted
                for(Schema.RecordTypeInfo rti: EUR_CRM_Group_Outlet_Type__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                    if(rti.isDefaultRecordTypeMapping()) {
                        rId = rti.getRecordTypeId();
                    }
                }
            }

            // assign dynamically the recordtype of Outlet type to be inserted
            Recordtype grpOutletDevName = [Select Id, DeveloperName from Recordtype where Id =:rId];
            recordtypeDevName = grpOutletDevName.DeveloperName; 

            // Get the respective outlet type recordType Dev Name from the recordtype helper
            Map<String, String> recordtypeAndCountryCodeMap = EUR_CRM_RecordTypeHelper.getGroupOutletControllerExt_outletRecordType(recordtypeDevName);
            recId = [Select Id from Recordtype where DeveloperName =:recordtypeAndCountryCodeMap.get('DeveloperName')].Id; 
            countrycode = recordtypeAndCountryCodeMap.get('countrycode');

            system.debug('@@DevName2 :' + recId);

            addOutletType();
        }
    }
    
    /*
        Create the new outlet type with the retrieved recordtype and add them to the newly created group outlet type
    */
    public void addOutletType(){
        system.debug('@@DevName3 :' + recId);
        
        EUR_CRM_Outlet_Type__c newOutletType = new EUR_CRM_Outlet_Type__c();
        newOutletType.EUR_CRM_Group_Outlet_Type__c = this.groupOutletType.Id;
        newOutletType.EUR_CRM_Active__c = true;
        newOutletType.RecordTypeId = recId;
        system.debug('recordtypeDevName' + recordtypeDevName);
        
        outletTypesDisplay.add(newOutletType);
    }
    
    /*
        Delete the outlet types
    */
    public void deleteOutletType(){
        String rowIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        Integer index = Integer.valueOf(rowIndex);
        
        if(this.standardController.getId() != null && outletTypes.containsKey(outletTypesDisplay[index].Id))
        {
            deleteOutletTypes.add(outletTypesDisplay[index]);
        }
        
        outletTypesDisplay.remove(index);     
    }

    public void initImageLevels()
    {   
        system.debug('countrycode' + groupOutletType.EUR_CRM_Country_Code__c + '::' + countrycode);
        imageLevelsThresholdsList = new List<EUR_CRM_Image_Level_Threshold__c>();
        imageLevelsList = new List<EUR_CRM_Image_Level__c>();
        List<Schema.PicklistEntry> imageLevelOptions = returnImageLevels();
        System.debug('Image Level Schema: ' + imageLevelOptions.size());
        Map<String, String> imgOptionsMap = new Map<String, String>();//returnMapIsUK();       
        if (countrycode != 'GB' || groupOutletType.EUR_CRM_Country_Code__c != 'GB'){
            system.debug('TEST1');
            imgOptionsMap = returnMapNotIsUK();
        }
        if (countrycode == 'GB' || groupOutletType.EUR_CRM_Country_Code__c == 'GB'){
            system.debug('TEST2');
            imgOptionsMap = returnMapIsUK();
        }

        system.debug('%%%MapSize' + imgOptionsMap.size());
        System.debug(this.standardController.getId());
        
        if (this.standardController.getId() == null){
            imageLevelsList = [Select Id, EUR_CRM_Name__c from EUR_CRM_Image_Level__c WHERE EUR_CRM_Country_Code__c =: countrycode];
        }
        else if (this.standardController.getId() != null){
            hasImageLevel = true;
            imageLevelsThresholdsList = [SELECT EUR_CRM_Image_Level_Name__c, EUR_CRM_Min_Weight__c, EUR_CRM_Name__c, EUR_CRM_Image_Level__r.EUR_CRM_Name__c
                                    FROM EUR_CRM_Image_Level_Threshold__c
                                    WHERE EUR_CRM_Group_Outlet_Type__c =: groupOutletType.Id
                                    ORDER BY EUR_CRM_Min_Weight__c];   
                                    
            imageLevelsList = [Select Id, EUR_CRM_Name__c from EUR_CRM_Image_Level__c WHERE EUR_CRM_Country_Code__c =: groupOutletType.EUR_CRM_Country_Code__c];
                                  
        }
        
        System.debug(imageLevelsList);
        //TODO HANDLE MISSING IMAGE LEVEL
        System.debug('FLAG - Image level threshold Size: ' + imageLevelsThresholdsList.size());
        
        if (imageLevelsThresholdsList.size() < imageLevelOptions.size()){
            
            // Create Image Level Thresholds Map
            Map<String, EUR_CRM_Image_Level_Threshold__c> imageLevelThresholdMap = new Map<String, EUR_CRM_Image_Level_Threshold__c>();
            for(EUR_CRM_Image_Level_Threshold__c var: imageLevelsThresholdsList){
                imageLevelThresholdMap.put(var.EUR_CRM_Image_Level__r.EUR_CRM_Name__c, var);
            }
            // Create Image Levels Map
            Map<String, EUR_CRM_Image_Level__c> imageLevelsMap = new Map<String, EUR_CRM_Image_Level__c>();
            if (imageLevelsList.size() > 0){
                for(EUR_CRM_Image_Level__c var: imageLevelsList){
                    System.debug(var);
                    imageLevelsMap.put(var.EUR_CRM_Name__c, var);
                }
            }

            system.debug('@@imageLevelThresholdMap' + imageLevelThresholdMap);
            system.debug('imageLevelsMap'+imageLevelsMap);            

            for (Schema.PicklistEntry option: imageLevelOptions){
                
                if(imageLevelThresholdMap.size()<=0 || !imageLevelThresholdMap.containsKey(option.getValue())){
                    EUR_CRM_Image_Level_Threshold__c imageLevel = new EUR_CRM_Image_Level_Threshold__c();
                    imageLevel.EUR_CRM_Name__c = option.getValue();
                    imageLevel.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
                    
                    if (imageLevelsMap.size() > 0){
                        imageLevel.EUR_CRM_Image_Level__c = imageLevelsMap.get(option.getValue()).Id;
                    }
                    imageLevelsThresholdsList.add(imageLevel);
                    System.debug('FLAG - imageLevelOption:' + imageLevel);
                }
            }
        }
        System.debug('imageLevelsThresholdsList:' + imageLevelsThresholdsList);
    }
    
    public void initVolumePotentials()
    {
        volumePotentialsThresholdsList = new List<EUR_CRM_Volume_Potential_Threshold__c>();
        List<Schema.PicklistEntry> volumePotentialOptions = returnVolumePotentials();
        System.debug('Volume Potential Schema: ' + volumePotentialOptions);
        
        volumePotentialsList = new List<EUR_CRM_Volume_Potential__c>();        
        
        if (this.standardController.getId() == null){
            volumePotentialsList = [Select Id, EUR_CRM_Name__c from EUR_CRM_Volume_Potential__c where EUR_CRM_Country_Code__c =: countrycode];
        }
        else if (this.standardController.getId() != null){
            hasVolPotential = true;
            volumePotentialsThresholdsList = [SELECT EUR_CRM_Volume_Potential_Name__c,EUR_CRM_Min_Weight__c, EUR_CRM_Name__c, EUR_CRM_Volume_Potential__r.EUR_CRM_Name__c
                                    FROM EUR_CRM_Volume_Potential_Threshold__c
                                    WHERE EUR_CRM_Group_Outlet_Type__c =: groupOutletType.Id
                                    ORDER BY EUR_CRM_Min_Weight__c];

            volumePotentialsList = [Select Id, EUR_CRM_Name__c from EUR_CRM_Volume_Potential__c where EUR_CRM_Country_Code__c =: groupOutletType.EUR_CRM_Country_Code__c];
        }

        System.debug('FLAG - Volume Potential thresholds Size: ' + volumePotentialsThresholdsList.size());

        if (volumePotentialsThresholdsList.size() < volumePotentialOptions.size()){
            
            // Create Level Potential Thresholds Map
            Map<String, EUR_CRM_Volume_Potential_Threshold__c> volumePotentialsThresholdsMap = new Map<String, EUR_CRM_Volume_Potential_Threshold__c>();
            for(EUR_CRM_Volume_Potential_Threshold__c var: volumePotentialsThresholdsList){
                volumePotentialsThresholdsMap.put(var.EUR_CRM_Volume_Potential__r.EUR_CRM_Name__c, var);
            }                      
            // Create Image Levels Map
            Map<String, EUR_CRM_Volume_Potential__c> volumePotentialsMap = new Map<String, EUR_CRM_Volume_Potential__c>();
            if (volumePotentialsList.size() > 0){
                for(EUR_CRM_Volume_Potential__c var: volumePotentialsList){
                    volumePotentialsMap.put(var.EUR_CRM_Name__c, var);
                }
            }

            for (Schema.PicklistEntry option: volumePotentialOptions){
                if(volumePotentialsThresholdsMap.size()<=0 || !volumePotentialsThresholdsMap.containsKey(option.getValue())){
                    
                    EUR_CRM_Volume_Potential_Threshold__c volumePotential = new EUR_CRM_Volume_Potential_Threshold__c();
                    volumePotential.EUR_CRM_Name__c = option.getValue();
                    volumePotential.EUR_CRM_Group_Outlet_Type__c = groupOutletType.Id;
                    
                    if (volumePotentialsMap.size() > 0){
                        volumePotential.EUR_CRM_Volume_Potential__c = volumePotentialsMap.get(option.getValue()).Id;
                    }
                    volumePotentialsThresholdsList.add(volumePotential);
                    System.debug('FLAG - imageLevelOption:' + volumePotential);
                }
            }
        }        
        System.debug('getVolumePotentials:' + volumePotentialsThresholdsList);
    }
    
    public List<Schema.PicklistEntry> returnImageLevels()
    { 
        Schema.DescribeFieldResult fieldResult = EUR_CRM_Image_Level__c.EUR_CRM_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
        system.debug('++ country code: ' + countryCode);
        for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
            String val = tempPle.getValue();
            if(countryCode == 'UK' || countryCode == 'GB'){
                if(EUR_CRM_ProsSegmentationClass.UK_IMAGE_LEVELS.contains(val)){
                    ple.add(tempPle);
                }
            }else{
                if(EUR_CRM_ProsSegmentationClass.DEFAULT_IMAGE_LEVELS.contains(val)){
                    ple.add(tempPle);
                }
            }
        }
        return ple;
    }
    
    public List<Schema.PicklistEntry> returnVolumePotentials()
    {
        Schema.DescribeFieldResult fieldResult = EUR_CRM_Volume_Potential__c.EUR_CRM_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        return ple;
    }
    
    public Map<String, String> returnMapNotIsUK(){
        Map<String, String> strMap = new Map<String, String>{'I'=>'Iconic', 'L' => 'Leading', 'P' =>'Premium','M'=>'Mainstream'};
        
        return strMap;
    }
    
    public Map<String, String> returnMapIsUK(){
        Map<String, String> strMap = new Map<String, String>{'I'=>'Iconic', 'L' => 'Leading', 'P' =>'Premium','MQ'=>'Mainstream Quality' ,'MS' => 'Mainstream Standard'};
        
        return strMap;
    }
    
    public EUR_CRM_Group_Outlet_Type__c returnGroupOutletType(Id groupOutletTypeId){
        EUR_CRM_Group_Outlet_Type__c tempGroupOutletType = [SELECT Id, EUR_CRM_Name__c, EUR_CRM_Group_Outlet_Name__c,
                                    EUR_CRM_Image_Criteria_Set__c, 
                                    EUR_CRM_Volume_Criteria_Set__c,
                                    EUR_CRM_Affiliate__c, 
                                    EUR_CRM_Affiliate__r.Name,
                                    EUR_CRM_Affiliate__r.EUR_CRM_Decision_Tree__c,
                                    EUR_CRM_Country_Code__c 
                                    FROM EUR_CRM_Group_Outlet_Type__c
                                    WHERE Id=:groupOutletTypeId LIMIT 1];
        
        return tempGroupOutletType;
    }
    
    public PageReference saveGroupOutlet(){
        PageReference pageRef = null;
        Database.Deleteresult[] deleteResultOutlet;
        Database.Upsertresult[] upsertResultOutlet;
        Database.Upsertresult[] upsertResultImage;
        Database.Upsertresult[] upsertResultVolume;
        Database.Upsertresult upsertResultGroupOutlet;
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        try{
            System.debug('Saving Group Outlet Type');
            //Save Group Outlet Type
            upsertResultGroupOutlet = Database.upsert(this.groupOutletType, Schema.EUR_CRM_Group_Outlet_Type__c.Id);
            System.debug('Saving - upsertResultGroupOutlet' + upsertResultGroupOutlet);
            
            //ASSIGN GROUP ID
            if (this.standardController.getId() == null)
            {
                for(EUR_CRM_Image_Level_Threshold__c image: imageLevelsThresholdsList){
                    image.EUR_CRM_Group_Outlet_Type__c = this.groupOutletType.Id;
                }
                for(EUR_CRM_Volume_Potential_Threshold__c volume: volumePotentialsThresholdsList){
                    volume.EUR_CRM_Group_Outlet_Type__c = this.groupOutletType.Id;
                }
                for(EUR_CRM_Outlet_Type__c outlet: outletTypesDisplay){
                    outlet.EUR_CRM_Group_Outlet_Type__c = this.groupOutletType.Id;
                }
            }
            
            //Save Outlet Types
            if(deleteOutletTypes.size()>0){
                deleteResultOutlet = Database.delete(deleteOutletTypes);
                System.debug('Saving - deleteResultOutlet' + deleteResultOutlet);
            }

            upsertResultOutlet = Database.upsert(outletTypesDisplay);
            System.debug('Saving - upsertResultOutlet' + upsertResultOutlet);

            //Save Image Levels
            upsertResultImage = Database.upsert(imageLevelsThresholdsList);
            System.debug('Saving - upsertResultImage' + upsertResultImage);
            
            //Save Volume Potentials
            upsertResultVolume = Database.upsert(volumePotentialsThresholdsList);
            System.debug('Saving - upsertResultVolume' + upsertResultVolume);
            
            if(upsertResultGroupOutlet.isSuccess()){
                pageRef = new PageReference('/'+ this.groupOutletType.Id);
                pageRef.setRedirect(true);
            }
        }
        catch(Exception ex){
            pageRef = null;
            Database.rollback(pSavepoint);      
            String strError = '';
            // Debug
            if(ex.getTypeName() == 'DMLException' && ex.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION )//|| Test.isRunningTest()) 
            {
                String s = ex.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                addPageMessage(strError, ApexPages.Severity.INFO);
            }                   
            addPageMessage(strError, ApexPages.Severity.ERROR); 
        }
        
        return pageRef;
    }
    
    public void addPageMessage(String strMessage, ApexPages.Severity severity)
    {
        ApexPages.Message infoMessage = new ApexPages.Message(severity, strMessage);
        ApexPages.addMessage(infoMessage);      
    }  
    
}
public with sharing class ASI_CRM_GroupOutletControllerExt {
    
    private final String ACTION_EDIT = 'EDIT';
    private final String ACTION_NEW = 'NEW';
    private final String ACTION;
    private ApexPages.StandardController standardController;
    private List<Schema.PicklistEntry> imageLevelOptions;
    private List<Schema.PicklistEntry> volumePotentialOptions;
    private Map<Id, ASI_CRM_Outlet_Type__c> outletTypes {get;set;}
    private Id affiliateId {get;set;}{affiliateId = null;}

    public Boolean isDisplayed{get; set;}{isDisplayed = true;} 
    public ASI_CRM_Group_Outlet_Type__c groupOutletType{get;set;}
    public List<ASI_CRM_Image_Level__c> imageLevelsList{get;set;}
    public List<ASI_CRM_Volume_Potential__c> volumePotentialsList{get;set;}
    public List<ASI_CRM_Image_Level_Threshold__c> imageLevels{get;set;}
    public List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentials{get;set;}
    public Boolean hasImageLevel {get;set;}
    public Boolean hasVolPotential {get;set;}
    public Integer rowIndex{get;set;}
    public List<ASI_CRM_Outlet_Type__c> outletTypesDisplay {get;set;}
    public List<ASI_CRM_Outlet_Type__c> deleteOutletTypes{get;set;}
    
    public String rid;
    public String recordtypeDevName;
    public Id recId;
    public String countrycode;
    public Set<String> imageSetValues {get;set;}
    
    public Boolean hasOutletDescription{get{
        return (countrycode.equalsIgnoreCase('E1'))?true:false;
    }}
    
    public ASI_CRM_GroupOutletControllerExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        //String action = ApexPages.currentPage().getParameters().get('action');
        hasImageLevel = false;
        hasVolPotential = false;
        rId = ApexPages.currentPage().getParameters().get('RecordType');
            system.debug('@@affiliateId' + rId);
            //this.ACTION = action;
            if (this.standardController.getId() == null)
            {
                groupOutletType = new ASI_CRM_Group_Outlet_Type__c();
                /*if (affiliateId==null){
                    ASI_CRM_SG_Affiliate__c tempAffiliate = ASI_CRM_SG_ProsSegmentationClass.returnAffiliate();
                    if(tempAffiliate!=null){
                        affiliateId = tempAffiliate.Id;
                    }
                    else{
                        addPageMessage('Please report to System Administrator - No associated Affiliate to your User instance', ApexPages.Severity.ERROR);
                        isDisplayed = false;
                    }
                }*/
            }
            else if (this.standardController.getId() != null)
            {
                groupOutletType = returnGroupOutletType(this.standardController.getId());
            }
            
            initOutletTypes();
            initImageLevels();
            initVolumePotentials();
    }
    
    public void initOutletTypes(){
        outletTypesDisplay = new List<ASI_CRM_Outlet_Type__c>();
        deleteOutletTypes = new List<ASI_CRM_Outlet_Type__c>();
        system.debug('@@DevName :' + recId);
        if (this.standardController.getId() != null){
            outletTypes = new Map<Id, ASI_CRM_Outlet_Type__c>([SELECT Id, ASI_CRM_SG_Name__c, 
                                                        ASI_CRM_SG_Active__c, 
                                                        ASI_CRM_SG_Description__c            
                                                        FROM ASI_CRM_Outlet_Type__c
                                                        WHERE ASI_CRM_SG_Group_Outlet_Type__c =:groupOutletType.Id 
                                                        AND ASI_CRM_SG_Active__c = true
                                                       LIMIT 4999]);               
        }
        
        
        
        if (outletTypes != null && outletTypes.size()>0)
        {
            outletTypesDisplay.addAll(outletTypes.values());
            
        }
        else{
             
            addOutletType();
        }
    }
    
    public void addOutletType(){
        system.debug('@@DevName3 :' + recId);
        
        ASI_CRM_Outlet_Type__c newOutletType = new ASI_CRM_Outlet_Type__c();
        newOutletType.ASI_CRM_SG_Group_Outlet_Type__c = this.groupOutletType.Id;
        newOutletType.ASI_CRM_SG_Active__c = true;
        system.debug('recordtypeDevName' + recordtypeDevName);
        
        outletTypesDisplay.add(newOutletType);
    }
    
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
        //system.debug('countrycode' + groupOutletType.ASI_CRM_SG_Country_Code__c + '::' + countrycode);
        //public List<ASI_CRM_SG_Image_Level_Threshold__c> imageLevels{get;set;}
        //public List<ASI_CRM_SG_Volume_Potential_Threshold__c> volumePotentials{get;set;}
        imageLevels = new List<ASI_CRM_Image_Level_Threshold__c>();
        imageLevelsList = new List<ASI_CRM_Image_Level__c>();
        List<Schema.PicklistEntry> imageLevelOptions = returnImageLevels();
        System.debug('Image Level Schema: ' + imageLevelOptions.size());
        //TODO Handle empty schema
        Map<String, String> imgOptionsMap = new Map<String, String>();//returnMapIsUK();
        //Map<String, String> imgOptionsMap2 = returnMapNotIsUK();
        
        imgOptionsMap = returnMapIsUK();
        
        system.debug('%%%MapSize' + imgOptionsMap.size());
        
        List<ASI_CRM_Image_Level__c> imageLevelsMainstream = new List<ASI_CRM_Image_Level__c>();
        List<ASI_CRM_Image_Level__c> imageLevelsPremium = new List<ASI_CRM_Image_Level__c>();
        List<ASI_CRM_Image_Level__c> imageLevelsLeading = new List<ASI_CRM_Image_Level__c>();
        List<ASI_CRM_Image_Level__c> imageLevelsIconic = new List<ASI_CRM_Image_Level__c>();
        List<ASI_CRM_Image_Level__c> imageLevelsMainstreamQuality = new List<ASI_CRM_Image_Level__c>();
        List<ASI_CRM_Image_Level__c> imageLevelsMainstreamStandard = new List<ASI_CRM_Image_Level__c>();
        
        if (this.standardController.getId() == null){
    
            imageLevelsPremium    = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Image_Level__c 
                                        where ASI_CRM_SG_Name__c =: 'Premium' LIMIT 1];
            imageLevelsLeading    = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Image_Level__c 
                                        where ASI_CRM_SG_Name__c =: 'Leading'LIMIT 1];
            imageLevelsIconic     = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Image_Level__c 
                                        where ASI_CRM_SG_Name__c =: 'Iconic' LIMIT 1];                         
            imageLevelsMainstream = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Image_Level__c 
                                        where ASI_CRM_SG_Name__c =: 'Mainstream' LIMIT 1];  
          
        }
        if (this.standardController.getId() != null){
            hasImageLevel = true;
            imageLevels = [SELECT ASI_CRM_SG_Image_Level_Name__c, ASI_CRM_SG_Min_Weight__c, ASI_CRM_SG_Name__c, ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c
                                    FROM ASI_CRM_Image_Level_Threshold__c
                                    WHERE ASI_CRM_SG_Group_Outlet_Type__c =: groupOutletType.Id
                                    ORDER BY ASI_CRM_SG_Min_Weight__c];   
                                    
           
            imageLevelsPremium    = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Image_Level__c 
                                        where ASI_CRM_SG_Name__c =: 'Premium' LIMIT 1];
            imageLevelsLeading    = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Image_Level__c 
                                        where ASI_CRM_SG_Name__c =: 'Leading' LIMIT 1];
            imageLevelsIconic     = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Image_Level__c 
                                        where ASI_CRM_SG_Name__c =: 'Iconic' LIMIT 1];
            imageLevelsMainstream = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Image_Level__c 
                                        where ASI_CRM_SG_Name__c =: 'Mainstream' LIMIT 1];                              
                       
        }
        //TODO HANDLE MISSING IMAGE LEVEL
        System.debug('FLAG - Image level Size: ' + imageLevels.size());
        
        if (imageLevels.size() < imageLevelOptions.size()){
            Map<String, ASI_CRM_Image_Level_Threshold__c> imageLevelsMap = new Map<String, ASI_CRM_Image_Level_Threshold__c>();
   
            for(ASI_CRM_Image_Level_Threshold__c var: imageLevels){
                imageLevelsMap.put(var.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c, var);
            }
            system.debug('@@imageLevelsMap' + imageLevelsMap);

            //imageLevels = new List<ASI_CRM_Image_Level__c>();
            
            system.debug('imageLevelsMainstream'+imageLevelsMainstream.size());
            system.debug('imageLevelsPremium'+imageLevelsPremium.size());   
            system.debug('imageLevelsLeading'+imageLevelsLeading.size());
            system.debug('imageLevelsIconic'+imageLevelsIconic.size()); 
            
            /*for (String str : imgOptionsMap.values()){
                system.debug('@@@STR' + str);
                
                if(imageLevelsMap.size()<=0 || !imageLevelsMap.containsKey(str)){
                    system.debug('TESTTESTETS'+!imageLevelsMap.containsKey(str));
                    ASI_CRM_SG_Image_Level_Threshold__c imageLevel = new ASI_CRM_SG_Image_Level_Threshold__c();
                    imageLevel.ASI_CRM_SG_Name__c = str;
                    imageLevel.ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.Id;
                    
                    imageLevels.add(imageLevel);
                }
            }*/
            for (Schema.PicklistEntry option: imageLevelOptions){
                
                if(imageLevelsMap.size()<=0 || !imageLevelsMap.containsKey(option.getValue())){
                    ASI_CRM_Image_Level_Threshold__c imageLevel = new ASI_CRM_Image_Level_Threshold__c();
                    imageLevel.ASI_CRM_SG_Name__c = option.getValue();
                    imageLevel.ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.Id;
                    
                    if (option.getValue() == 'Mainstream' && imageLevelsMainstream.size() == 1){
                        imageLevel.ASI_CRM_SG_Image_Level__c = imageLevelsMainstream[0].Id;
                    }
                    if (option.getValue() == 'Premium' && imageLevelsPremium.size() == 1){
                        imageLevel.ASI_CRM_SG_Image_Level__c = imageLevelsPremium[0].Id;
                    }
                    if (option.getValue() == 'Leading' && imageLevelsLeading.size() == 1){
                        imageLevel.ASI_CRM_SG_Image_Level__c = imageLevelsLeading[0].Id;
                    } 
                    if (option.getValue() == 'Iconic' && imageLevelsIconic.size() == 1){
                        imageLevel.ASI_CRM_SG_Image_Level__c = imageLevelsIconic[0].Id;
                    } 
                    /**/
                    if (option.getValue() == 'Mainstream Quality' && imageLevelsMainstreamQuality.size() == 1){
                        imageLevel.ASI_CRM_SG_Image_Level__c = imageLevelsMainstreamQuality[0].Id;
                    } 
                    if (option.getValue() == 'Mainstream Standard' && imageLevelsMainstreamStandard.size() == 1){
                        imageLevel.ASI_CRM_SG_Image_Level__c = imageLevelsMainstreamStandard[0].Id;
                    }
                    /**/
                    imageLevels.add(imageLevel);
                    System.debug('FLAG - imageLevelOption:' + imageLevel);
                }
            }
        }
        
        System.debug('getImageLevels:' + imageLevels);
        //return imageLevels;
        
    }
    
    public void initVolumePotentials()
    {
        volumePotentials = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        List<Schema.PicklistEntry> volumePotentialOptions = returnVolumePotentials();
        System.debug('Volume Potential Schema: ' + volumePotentialOptions);
        //TODO Handle empty schema
        List<ASI_CRM_Volume_Potential__c> volHighList = new List<ASI_CRM_Volume_Potential__c>();
        List<ASI_CRM_Volume_Potential__c> volMediumList = new List<ASI_CRM_Volume_Potential__c>();
        List<ASI_CRM_Volume_Potential__c> volLowList = new List<ASI_CRM_Volume_Potential__c>();
        
        
        if (this.standardController.getId() == null){
            volHighList   = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Volume_Potential__c 
                                        where ASI_CRM_SG_Name__c =: 'High' LIMIT 1];
            volMediumList = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Volume_Potential__c 
                                        where ASI_CRM_SG_Name__c =: 'Medium' LIMIT 1];
            volLowList    = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Volume_Potential__c 
                                        where ASI_CRM_SG_Name__c =: 'Low' LIMIT 1];
        }
        if (this.standardController.getId() != null){
            hasVolPotential = true;
            volumePotentials = [SELECT ASI_CRM_SG_Volume_Potential_Name__c,ASI_CRM_SG_Min_Weight__c, ASI_CRM_SG_Name__c, ASI_CRM_SG_Volume_Potential__r.ASI_CRM_SG_Name__c
                                    FROM ASI_CRM_Volume_Potential_Threshold__c
                                    WHERE ASI_CRM_SG_Group_Outlet_Type__c =: groupOutletType.Id
                                    ORDER BY ASI_CRM_SG_Min_Weight__c];
            volHighList   = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Volume_Potential__c 
                                        where ASI_CRM_SG_Name__c =: 'High' LIMIT 1];
            volMediumList = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Volume_Potential__c 
                                        where ASI_CRM_SG_Name__c =: 'Medium' LIMIT 1];
            volLowList    = [Select Id, ASI_CRM_SG_Name__c from ASI_CRM_Volume_Potential__c 
                                        where ASI_CRM_SG_Name__c =: 'Low' LIMIT 1];
        
        }
        //TODO HANDLE MISSING IMAGE LEVEL
        System.debug('FLAG - Volume Potential Size: ' + volumePotentials.size());
        if (volumePotentials.size() < volumePotentialOptions.size()){
            Map<String, ASI_CRM_Volume_Potential_Threshold__c> volumePotentialsMap = new Map<String, ASI_CRM_Volume_Potential_Threshold__c>();
            for(ASI_CRM_Volume_Potential_Threshold__c var: volumePotentials){
                volumePotentialsMap.put(var.ASI_CRM_SG_Volume_Potential__r.ASI_CRM_SG_Name__c, var);
            }
            //volumePotentials = new List<ASI_CRM_SG_Volume_Potential__c>();
            
            

            for (Schema.PicklistEntry option: volumePotentialOptions){
                if(volumePotentialsMap.size()<=0 || !volumePotentialsMap.containsKey(option.getValue())){
                    ASI_CRM_Volume_Potential_Threshold__c volumePotential = new ASI_CRM_Volume_Potential_Threshold__c();
                    volumePotential.ASI_CRM_SG_Name__c = option.getValue();
                    volumePotential.ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.Id;
                    
                    if (option.getValue() == 'High'){
                        volumePotential.ASI_CRM_SG_Volume_Potential__c = volHighList[0].Id;
                    }
                    if (option.getValue() == 'Medium'){
                        volumePotential.ASI_CRM_SG_Volume_Potential__c = volMediumList[0].Id;
                    }
                    if (option.getValue() == 'Low'){
                        volumePotential.ASI_CRM_SG_Volume_Potential__c = volLowList[0].Id;
                    } 
                    
                    volumePotentials.add(volumePotential);
                    System.debug('FLAG - imageLevelOption:' + volumePotential);
                }
            }
        }
        
        System.debug('getVolumePotentials:' + volumePotentials);
        //return volumePotentials;
    }
    
    public List<Schema.PicklistEntry> returnImageLevels()
    {  /*system.debug('++ country Code: ' + countryCode);
        Schema.DescribeFieldResult fieldResult = ASI_CRM_SG_Image_Level__c.ASI_CRM_SG_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        return ple;
        */
         Schema.DescribeFieldResult fieldResult = ASI_CRM_Image_Level__c.ASI_CRM_SG_Name__c.getDescribe();
                System.debug('Describe Field: ' + fieldResult);
                //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
                system.debug('++ country code: ' + countryCode);
                for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
                    String val = tempPle.getValue();
                        if(ASI_CRM_ProsSegmentationClass.DEFAULT_IMAGE_LEVELS.contains(val)){
                            ple.add(tempPle);
                        }
                }
                return ple;
    }
    
    public List<Schema.PicklistEntry> returnVolumePotentials()
    {
        Schema.DescribeFieldResult fieldResult = ASI_CRM_Volume_Potential__c.ASI_CRM_SG_Name__c.getDescribe();
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
    
    public ASI_CRM_Group_Outlet_Type__c returnGroupOutletType(Id groupOutletTypeId){
        ASI_CRM_Group_Outlet_Type__c tempGroupOutletType = [SELECT Id, ASI_CRM_SG_Name__c, ASI_CRM_SG_Group_Outlet_Name__c,
                                    ASI_CRM_SG_Image_Criteria_Set__c, 
                                    ASI_CRM_SG_Volume_Criteria_Set__c
                                    FROM ASI_CRM_Group_Outlet_Type__c
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
            upsertResultGroupOutlet = Database.upsert(this.groupOutletType, Schema.ASI_CRM_Group_Outlet_Type__c.Id);
            System.debug('Saving - upsertResultGroupOutlet' + upsertResultGroupOutlet);
            
            //ASSIGN GROUP ID
            if (this.standardController.getId() == null)
            {
                for(ASI_CRM_Image_Level_Threshold__c image: imageLevels){
                    image.ASI_CRM_SG_Group_Outlet_Type__c = this.groupOutletType.Id;
                }
                for(ASI_CRM_Volume_Potential_Threshold__c volume: volumePotentials){
                    volume.ASI_CRM_SG_Group_Outlet_Type__c = this.groupOutletType.Id;
                }
                for(ASI_CRM_Outlet_Type__c outlet: outletTypesDisplay){
                    outlet.ASI_CRM_SG_Group_Outlet_Type__c = this.groupOutletType.Id;
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
            upsertResultImage = Database.upsert(imageLevels);
            System.debug('Saving - upsertResultImage' + upsertResultImage);
            
            //Save Volume Potentials
            upsertResultVolume = Database.upsert(volumePotentials);
            System.debug('Saving - upsertResultVolume' + upsertResultVolume);
            
            if(upsertResultGroupOutlet.isSuccess()){
                //pageRef = new PageReference('/' + this.groupOutletType.ASI_CRM_SG_Affiliate__c);
                //Baltics - modified page reference value
                pageRef = new PageReference('/'+ this.groupOutletType.Id);
                pageRef.setRedirect(true);
            }
        }
        catch(Exception ex){
            pageRef = null;
            Database.rollback(pSavepoint);      
            String strError = '';
            // Debug
            // strError = ex.getMessage() + LINE_NUMBER + String.valueOf(ex.getLineNumber());
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
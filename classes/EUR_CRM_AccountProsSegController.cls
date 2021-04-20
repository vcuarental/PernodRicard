public with sharing class EUR_CRM_AccountProsSegController {
      
    private ApexPages.StandardController standardController;
    private User activeUser{get; set;}
    //private Boolean hasActiveAffiliate {get;set;}{false;}
    private Id affiliateId{get;set;}
    private EUR_CRM_Affiliate__c selectedAffiliate{get;set;}
    
    public EUR_CRM_Pros_Segmentation__c prosSegmentation{get;set;}
    
    public Boolean isDisplayed{get; set;}{isDisplayed = false;}  
    public boolean isRedirect {get;set;}{isRedirect = false;}
    public string url {get;set;}
    
    public Id servicePackId{get;set;}{servicePackId=null;}
    public String groupOutletType {set; get;}
    public String outletType {set; get;}
    public String imageLevel {set; get;}
    public String volumePotential {set; get;}
    
    public List<String> imageLevelLabels{get;set;}
    public List<String> volumePotentialLabels{get;set;}
    public Map<String, Boolean> imageVolumeMap{get;set;}
    private String countryCode;
    public static Set<String> UK_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream Quality','Mainstream Standard'};
    public static Set<String> DEFAULT_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream'};
    private List<EUR_CRM_Account__c> EUAccountList = new List<EUR_CRM_Account__c>();
        public EUR_CRM_AccountProsSegController(ApexPages.StandardController standardController)
        {
                Boolean isCreatePage = true;
                this.standardController = standardController;
                //Get Active User
                String userId = UserInfo.getUserId();
                System.debug('Flag - UserId: ' + userId);
                this.activeUser = [SELECT CompanyName, Country FROM User WHERE Id=:userId LIMIT 1];
                String accId = standardController.getId();
                system.debug('accId' + accId );
                //Retrieve Pros Segmentation
                getProsSeg();
                
                EUAccountList = [Select Id, eur_crm_force_iconic_account__c,EUR_CRM_Country_Code__c, EUR_CRM_Force_Image_Level__c from EUR_CRM_Account__c where Id =:accId];
                
                if (EUAccountList == null || EUAccountList.size() == 0 ){
                    if (prosSegmentation == null){
                        if (!affiliateExists(this.activeUser)){ 
                                this.addPageMessage('Please contact your System Administrator. Affiliate does not exist.', ApexPages.Severity.INFO);
                                isCreatePage = false;
                        }
                    }else{
                        servicePackId = prosSegmentation.EUR_CRM_Service_Pack__c;
                        if (servicePackId==null){
                             servicePackId = EUR_CRM_ProsSegmentationClass.returnServicePackId(prosSegmentation);
                        }
                    }
                }
                else if (EUAccountList.size() > 0 && EUAccountList[0].EUR_CRM_Country_Code__c != 'PRT'){
                    if (prosSegmentation == null){
                        this.addPageMessage('Please contact your System Administrator. No Pros Segmentation Exist.', ApexPages.Severity.INFO);
                          isCreatePage = false;
                    }else{
                         servicePackId = prosSegmentation.EUR_CRM_Service_Pack__c;
                         if (servicePackId==null){
                             servicePackId = EUR_CRM_ProsSegmentationClass.returnServicePackId(prosSegmentation);
                         }
                     }
                    if(EUAccountList[0].eur_crm_force_iconic_account__c){
                     //     commented out 10/8/2014
                     //    this.addPageMessage('PROS Segmentation of this account is forced to be Iconic', ApexPages.Severity.WARNING);
                    }
                }
                
                if (isCreatePage){
                   // system.debug('!!! Test Country Code: ' + prosSegmentation.EUR_CRM_Country_Code__c);
                    
                    isDisplayed = true;
                    createPage();
                    if(prosSegmentation !=null)
                        countryCode = prosSegmentation.EUR_CRM_Country_Code__c;
                    initImageVolumeFieldSet();
                }
                
                

        }
        
    private Boolean affiliateExists(User user){
            this.affiliateId = null;
            if (user != null && user.CompanyName != null){
                    //List<EUR_CRM_Affiliate__c> affiliate = [SELECT Id, EUR_CRM_Country_Code__c from EUR_CRM_Affiliate__c WHERE EUR_CRM_Country__c=:user.CompanyName];
                    EUR_CRM_Affiliate__c affiliate = EUR_CRM_ProsSegmentationClass.returnAffiliate();
                    if (affiliate!=null){
                        this.affiliateId = affiliate.Id;
                        selectedAffiliate = affiliate;
                        this.isDisplayed = true;
                        return true;

                    }else{
                        this.isDisplayed = false;
                        return false;
                    }
            }
            this.isDisplayed = false;
            return false;
    }
    
    public EUR_CRM_Pros_Segmentation__c getProsSeg(){
        Id accountId = this.standardController.getId();
        
        prosSegmentation = null;
        //Baltics - modified query to reference Image Level and Potential Volume lookup name value
        List<EUR_CRM_Pros_Segmentation__c> tempPros = [SELECT Id, EUR_CRM_Account__r.Id,  
        EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c,
                                                        EUR_CRM_Affiliate__r.Id, 
                                                        EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,
                                                        EUR_CRM_Image_Level__c, EUR_CRM_Volume_Potential__c,
                                                        EUR_CRM_Service_Pack__c,
                                                        EUR_CRM_Is_Image_Level_Modified__c, EUR_CRM_Is_Volume_Potential_Modified__c,
                                                        EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Name__c,
                                                        EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c,
                                                        EUR_CRM_Outlet_Type__r.EUR_CRM_Name__c, 
                                                        EUR_CRM_Image_Level__r.EUR_CRM_Name__c, EUR_CRM_Volume_Potential__r.EUR_CRM_Name__c,
                                                        EUR_CRM_Country_Code__c, EUR_CRM_Image_Level_Threshold__c, EUR_CRM_Volume_Potential_Threshold__c,
                                                        EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c, EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c 
                                                        FROM EUR_CRM_Pros_Segmentation__c
                                                        WHERE EUR_CRM_Account__c =: accountId 
                                                        LIMIT 1];
        if(!tempPros.isEmpty()){
                prosSegmentation = tempPros[0];
                this.affiliateId = prosSegmentation.EUR_CRM_Affiliate__r.Id;
        }
        
        return prosSegmentation;
    }
    
    public void initImageVolumeFieldSet(){

        this.imageVolumeMap = new Map<String, Boolean>();
        this.imageLevelLabels = new List<String>();
        this.volumePotentialLabels = new List<String>();
        
        
        List<Schema.PicklistEntry> imageLabels = returnImageLevels();
        //imageLevelLabels = imageLabels;
        List<Schema.PicklistEntry> volumeLabels = returnVolumePotentials();
        //volumePotentialLabels = volumeLabels;
        
        for(Schema.PicklistEntry vol: volumeLabels){
                //volumePotentialLabels.add(new FieldVal(vol.getValue()));
                volumePotentialLabels.add(vol.getValue());
        } 
        //Baltics - modified condition to avoid null values on map
        //02/11/14 - Modified condition(referenced jucntion objs Image Level and Vol Potential Thresholds)
        
        for (Schema.PicklistEntry image: imageLabels){
            for(Schema.PicklistEntry vol: volumeLabels){
                system.debug('%%Imagegetvalue::' + image.getValue());
                system.debug('%%Volumegetvalue::' + vol.getValue());
                system.debug('%%IMG::' + this.prosSegmentation.EUR_CRM_Image_Level_Threshold__c);
                system.debug('%%VOLPOT::' + this.prosSegmentation.EUR_CRM_Volume_Potential_Threshold__c);
                if(this.prosSegmentation!= null && image.getValue().equalsIgnoreCase(this.prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c) && 
                vol.getValue().equalsIgnoreCase(this.prosSegmentation.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c)){
                        imageVolumeMap.put(image.getValue()+vol.getValue(), true);
                }else{
                imageVolumeMap.put(image.getValue()+vol.getValue(), false);
                }
            }
            //imageLevelLabels.add(new FieldVal(image.getValue()));
            imageLevelLabels.add(image.getValue());
            
            system.debug('###imageVolumeMap' + imageVolumeMap + '');
            system.debug('###image' + image );
        }
        
        if(EUAccountList != null && EUAccountList.size() > 0 && EUAccountList[0].EUR_CRM_Force_Iconic_Account__c){
            String imageName = prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c;
            String volumePotentialName = prosSegmentation.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c;
            
            String iconicImage = 'Iconic';
            
            system.debug('!!!  ' + imageName  +volumePotentialName  );
            imageVolumeMap.put(imageName+volumePotentialName, false);
            imageVolumeMap.put(iconicImage +volumePotentialName, true);
        }

        // Display the image level specified by the force image level picklist if it is selected
        if(EUAccountList != null && EUAccountList.size() > 0 && (EUAccountList[0].EUR_CRM_Force_Image_Level__c != null)){
            String imageName = prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c;
            String volumePotentialName = prosSegmentation.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c;
            
            String newImageLevel = EUAccountList[0].EUR_CRM_Force_Image_Level__c;
            
            system.debug('!!!  ' + imageName  +volumePotentialName  );
            imageVolumeMap.put(imageName+volumePotentialName, false);
            imageVolumeMap.put(newImageLevel+volumePotentialName, true);
        }


    }
        
    public List<Schema.PicklistEntry> returnImageLevels(){
        Schema.DescribeFieldResult fieldResult = EUR_CRM_Image_Level__c.EUR_CRM_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
        system.debug('++ country code: ' + countryCode);
        for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
            String val = tempPle.getValue();
            if(countryCode == 'UK' || countryCode == 'GB'){
                if(UK_IMAGE_LEVELS.contains(val)){
                    ple.add(tempPle);
                }
            }else{
                if(DEFAULT_IMAGE_LEVELS.contains(val)){
                    ple.add(tempPle);
                }
            }
        }
        return ple;
    }
        
    public List<Schema.PicklistEntry> returnVolumePotentials() {
        Schema.DescribeFieldResult fieldResult = EUR_CRM_Volume_Potential__c.EUR_CRM_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        return ple;
    }

    public void createPage(){
        //prosSegmentation = getProsSeg();
        
        if (prosSegmentation != null){
            //groupOutletType = prosSegmentation.EUR_CRM_Group_Outlet_Type__c;
            //outletType = prosSegmentation.EUR_CRM_Outlet_Type__c;
            //imageLevel = prosSegmentation.EUR_CRM_Image_Level__c;
            //volumePotential = prosSegmentation.EUR_CRM_Volume_Potential__c;
            
            //Baltics - changed text to lookup fields
            groupOutletType = prosSegmentation.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c;
            outletType = prosSegmentation.EUR_CRM_Outlet_Type__r.EUR_CRM_Name__c;
            imageLevel = prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c;
            volumePotential = prosSegmentation.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c;
        }
    }
        
    public Component.Apex.CommandButton getCustomLink(){
            Component.Apex.CommandButton customLink  = new Component.Apex.CommandButton();
            
            if (prosSegmentation != null){
                //Apex.Component.OutputLink content = new Apex.Component.OutputLink();
                customLink.value = 'Open Pros Segmentation';
                customLink.expressions.action = '{!openProsSeg}';
            }
            else{
                customLink.value = 'Assign Pros Segmentation';
                customLink.expressions.action = '{!createProsSegmentation}';
            }
            customLink.rerender = new Set<String>{'redirectPanel'};
            return customLink;
    }
        
    public PageReference createProsSegmentation(){
        EUR_CRM_Pros_Segmentation__c newProsSegmentation = null;
        try{
           if (this.affiliateId != null) {
                newProsSegmentation = new EUR_CRM_Pros_Segmentation__c();
                newProsSegmentation.EUR_CRM_Affiliate__c = this.affiliateId;
                newProsSegmentation.EUR_CRM_Account__c = this.standardController.getId();
                Database.insert(newProsSegmentation);
                
                //Assign Voluem pOtential Base on Volume Card
                EUR_CRM_ID_Card__c idCard = EUR_CRM_ProsSegmentationClass.returnIdCard(this.standardController.getId());
                if (idCard != null) {
                    EUR_CRM_ProsSegmentationClass.assignVolumePotential(new List<EUR_CRM_Pros_Segmentation__c>{newProsSegmentation},new Map<Id, EUR_CRM_ID_Card__c>{this.standardController.getId()=>idCard});
                }
           } else {
                this.addPageMessage('Please contact your System Administrator. Affiliate does not exist.', ApexPages.Severity.INFO);
           }
        } catch(Exception e) {
            System.debug('Insert Error: ' + e.getMessage());
        }
        
        if (newProsSegmentation != null){                       
            url = '/' + newProsSegmentation.Id;  
            System.debug('Flag - redirect url:' + url);      
                    isRedirect = true;
        }
        return null;
    }
        
    public PageReference openProsSeg() {
        if (prosSegmentation!=null){
            url = '/' + prosSegmentation.Id;
            System.debug('Flag - redirect url:' + url);         
            isRedirect = true;
        }
        return null;
    }

    public PageReference openAccountPlan(){
        url = '/apex/EUR_CRM_AccountPlan?id='+this.prosSegmentation.Id;
        System.debug('Flag - redirect url:' + url);         
        isRedirect = true;
        return null;
                //pageReference pg = new pageReference('/apex/EUR_CRM_AccountPlan?id='+this.prosSegmentation.Id);
        //pg.setRedirect(true);
        //return pg;
    }
    
    
    public void addPageMessage(String strMessage, ApexPages.Severity severity) {
        ApexPages.Message infoMessage = new ApexPages.Message(severity, strMessage);
        ApexPages.addMessage(infoMessage);      
    }
    
    /**
    *   Function: getIsServicePackRendered
    *   Determines whether service pack button is shown for this particular affiliate
    *   Return: a boolean
    */
    public Boolean getIsServicePackRendered() {
        if(EUAccountList != null && EUAccountList.size() > 0) {
	        return EUR_CRM_RecordTypeHelper.getAccountProsSegController_isServicePackRendered(
	            EUAccountList[0].EUR_CRM_Country_Code__c
	        );
        } else {
            return false;
        }
    }
    
}
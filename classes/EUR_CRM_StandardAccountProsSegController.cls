public with sharing class EUR_CRM_StandardAccountProsSegController {
      
    private final String contactAdminMessage = Label.EUR_CRM_ContactAdmin_NoAffiliate_Msg; //Please contact System Admin, affiliate does not exist
    
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
        public EUR_CRM_StandardAccountProsSegController (ApexPages.StandardController standardController)
        {
                //Boolean isCreatePage = true;
                this.standardController = standardController;
                //Get Active User
                String userId = UserInfo.getUserId();
                System.debug('Flag - UserId: ' + userId);
                this.activeUser = [SELECT CompanyName, Country FROM User WHERE Id=:userId LIMIT 1];
               
                //Retrieve Pros Segmentation
                prosSegmentation = getProsSeg();
                //prosSegmentation = EUR_CRM_ProsSegmentationClass.returnProsSegmentationviaId(prosSegmentation.Id);

                if (prosSegmentation != null){
                    servicePackId = prosSegmentation.EUR_CRM_Service_Pack__c;
                    if (servicePackId==null){
                         servicePackId = EUR_CRM_ProsSegmentationClass.returnServicePackId(prosSegmentation);
                    }
                    countryCode = prosSegmentation.EUR_CRM_Country_Code__c;
                    initImageVolumeFieldSet();
                    createPage();
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
        
        List<EUR_CRM_Pros_Segmentation__c> tempPros = [SELECT Id, EUR_CRM_Account__r.Id, 
                                                        EUR_CRM_Affiliate__r.Id, 
                                                        EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,
                                                        EUR_CRM_Image_Level__c, EUR_CRM_Volume_Potential__c,
                                                        EUR_CRM_Service_Pack__c,
                                                        EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c,
                                                        EUR_CRM_Outlet_Type__r.EUR_CRM_Name__c,
                                                        EUR_CRM_Is_Image_Level_Modified__c, EUR_CRM_Is_Volume_Potential_Modified__c,
                                                        EUR_CRM_Country_Code__c,
                                                        EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c,
                                                        EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c
                                                        FROM EUR_CRM_Pros_Segmentation__c
                                                        WHERE EUR_CRM_Standard_Account__c =: accountId 
                                                        ];
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
                
                for (Schema.PicklistEntry image: imageLabels){
                        for(Schema.PicklistEntry vol: volumeLabels){
                                /*if(this.prosSegmentation!= null && image.getValue().equalsIgnoreCase(this.prosSegmentation.EUR_CRM_Image_Level__c) && 
                                vol.getValue().equalsIgnoreCase(this.prosSegmentation.EUR_CRM_Volume_Potential__c))*/
                                
                                if(this.prosSegmentation!= null && image.getValue().equalsIgnoreCase(this.prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c) && 
                                vol.getValue().equalsIgnoreCase(this.prosSegmentation.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c)){
                                        imageVolumeMap.put(image.getValue()+vol.getValue(), true);
                                }else{
                                imageVolumeMap.put(image.getValue()+vol.getValue(), false);}
                        }
                        //imageLevelLabels.add(new FieldVal(image.getValue()));
                        imageLevelLabels.add(image.getValue());
                }
        }
        
        public List<Schema.PicklistEntry> returnImageLevels()
        {        /*
                Schema.DescribeFieldResult fieldResult = EUR_CRM_Image_Level__c.EUR_CRM_Name__c.getDescribe();
                System.debug('Describe Field: ' + fieldResult);
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
                return ple;
                */
                Schema.DescribeFieldResult fieldResult = EUR_CRM_Image_Level__c.EUR_CRM_Name__c.getDescribe();
                System.debug('Describe Field: ' + fieldResult);
                //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
                system.debug('++ country code: ' + countryCode);
                for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
                    String val = tempPle.getValue();
                    if(countryCode == 'UK' || countryCode == 'GB'){
                        if(EUR_CRM_AccountProsSegController.UK_IMAGE_LEVELS.contains(val)){
                            ple.add(tempPle);
                        }
                    }else{
                        if(EUR_CRM_AccountProsSegController.DEFAULT_IMAGE_LEVELS.contains(val)){
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
                
                customLink.value = String.valueOf(Label.EUR_CRM_OpenProsSegmentation);
                customLink.expressions.action = '{!openProsSeg}';
                customLink.onclick='this.disabled = true; this.onclick=function(){return false;}';
                
                /*if (prosSegmentation != null){
                        //Apex.Component.OutputLink content = new Apex.Component.OutputLink();
                        customLink.expressions.action = '{!openProsSeg}';
                }
                else{
                        customLink.expressions.action = '{!createProsSegmentation}';
                }*/
                customLink.rerender = new Set<String>{'redirectPanel'};
                return customLink;
        }
        
        public PageReference createProsSegmentation(){
            PageReference pageRef = null;
            
            Recordtype rtype =[select id from recordtype where developername = 'EUR_PRT_PROS_Segmentation' and 
            sobjecttype = 'EUR_CRM_Pros_Segmentation__c'];
            EUR_CRM_Pros_Segmentation__c newProsSegmentation = null;
            try{
                newProsSegmentation = new EUR_CRM_Pros_Segmentation__c();
                newProsSegmentation.EUR_CRM_Affiliate__c = this.affiliateId;
                newProsSegmentation.EUR_CRM_Standard_Account__c = this.standardController.getId();
                //newProsSegmentation.EUR_CRM_Standard_Account__c = this.standardController.getId();
                
                if(rtype != null){
                    newProsSegmentation.recordtypeid= rtype.id;
                }
                Database.insert(newProsSegmentation);
                /*
                //Assign Volume Potential Base on Volume Card
                EUR_CRM_ID_Card__c idCard = EUR_CRM_ProsSegmentationClass.returnIdCard(this.standardController.getId());
                if (idCard != null)
                {
                    EUR_CRM_ProsSegmentationClass.assignVolumePotential(new List<EUR_CRM_Pros_Segmentation__c>{newProsSegmentation}, 
                                                                    new Map<Id, EUR_CRM_ID_Card__c>{this.standardController.getId()=>idCard});
                }
                */
            }
            catch(Exception e){
                System.debug('Insert Error: ' + e.getMessage());
            }
            
            if (newProsSegmentation != null){                       
                url = '/' + newProsSegmentation.Id;  
                //System.debug('Flag - redirect url:' + url);  
                pageRef = new PageReference('/'+newProsSegmentation.Id);                    
                //pageRef.setRedirect(true);
            }
            return pageRef;
        }
        
        
        
    public PageReference openProsSeg() {
        PageReference pageRef = null;
        if (prosSegmentation!=null){    
            url = '/' + prosSegmentation.Id;
            //System.debug('Flag - redirect url:' + url);         
            pageRef = new PageReference('/'+prosSegmentation.Id);
            //pageRef.setRedirect(true);
        }else{
            pageRef = createProsSegmentation();
        }
        
        isRedirect = true;
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
    
    
        public void addPageMessage(String strMessage, ApexPages.Severity severity)
    {
        ApexPages.Message infoMessage = new ApexPages.Message(severity, strMessage);
        ApexPages.addMessage(infoMessage);      
    }  
    
}
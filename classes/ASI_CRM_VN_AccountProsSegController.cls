/*********************************************************************************
     * Name:ASI_CRM_VN_AccountProsSegController
     * Description: Component Controller for displaying the RES and NON RES table
     *
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    -------------------------------------------------------
     * 19/10/2015       Laputa: Neha             Created
     * 18/12/2018       Laputa: Andy Zhang       Add logic check customer reocrd type
     *                                           display label 'IB29/Vodka Men Volume'
     *                                           for Value and set wine
     * 20/12/2018       Laputa: Andy             Handle Value Segment Customer logic
*********************************************************************************/

public with sharing class ASI_CRM_VN_AccountProsSegController{
    public ASI_CRM_ServicePack__c serPackObj{get;set;}
    public ASI_CRM_AccountsAdditionalField__c customer{get;set;}
    public String url{get;set;}
    public boolean isRedirect {get;set;}{isRedirect = false;}
    public boolean isRedirect2 {get;set;}{isRedirect = false;}
    public ASI_CRM_Pros_Segmentation__c prosSegmentation{get;set;}
    public Boolean isDisplayed{get; set;}{isDisplayed = false;}
    public Boolean isNoPros{get; set;}{isNoPros = false;}
    public String volumePotential {set; get;}
    public String outletType{get;set;}
    public Id servicePackId{get;set;}
    public boolean showservicePack{get;set;}{showservicePack=false;}
    
    public List<String> imageLevelLabels{get;set;}
    public List<String> volumePotentialLabels{get;set;}
    public Map<String, Boolean> imageVolumeMap{get;set;}
    public Map<String, Boolean> imageWineVolumeMap{get;set;}
    public static Set<String> DEFAULT_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream'};
    public static Set<String> DEFAULT_IMAGE_LEVELS_VALUE = new Set<String>{'Platinum','Gold','Silver','Bronze'};
    //DAMD Matrix
    public Map<String, String> damdmatrixMap {get;set;}
    public String accId;

    public ASI_CRM_VN_AccountProsSegController(ApexPages.StandardController standardController){
        customer = (ASI_CRM_AccountsAdditionalField__c)standardController.getRecord();
        if(customer != null){
            customer = [select Id, ASI_CRM_VN_OutletType__c,ASI_CRM_Service_Pack__c, ASI_CRM_SG_Image_Level__c, RecordType.DeveloperName, RecordType.Name from ASI_CRM_AccountsAdditionalField__c where Id = : customer.Id];
            outletType = customer.ASI_CRM_VN_OutletType__c;
            prosSegmentation = getProsSeg();
        }
        System.debug(' -- prosSegmentation --' + prosSegmentation);
        if(prosSegmentation == null || prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c == null || prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c == null){
            if(prosSegmentation == null){
                isNoPros = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.ASI_CRM_VN_NoProsMsg));
            }
            isDisplayed = false;
        }else{
            isDisplayed = true;
            initImageVolumeFieldSet();
        }
        serPackObj = new ASI_CRM_ServicePack__c();
        if(!String.isBlank(customer.ASI_CRM_Service_Pack__c)){
            //Get service pack related to Customer Id
            serPackObj = [select Id,
                    ASI_CRM_No_of_PG_in_one_outlet__c,
                    ASI_CRM_No_of_Signage_per_outlet__c,
                    ASI_CRM_No_of_VIP_room__c,
                    ASI_CRM_No_of_Podium_stand__c,
                    ASI_CRM_No_of_Glorifier__c,
                    ASI_CRM_No_of_Dummy_Bots__c,
                    ASI_CRM_No_of_PG_uniform__c,
                    ASI_CRM_No_of_Glassware__c,
                    ASI_CRM_No_of_Dice_Dice_Cup__c,
                    ASI_CRM_No_of_Drink_menus__c,
                    ASI_CRM_No_of_Promotion_activiti_per_yr__c,
                    ASI_CRM_Incentives_US_year__c,
                    ASI_CRM_SG_Segmentation__c,
                    ASI_CRM_CallFrequency__c,
                    ASI_CRM_CallLength__c
            from ASI_CRM_ServicePack__c where Id =: customer.ASI_CRM_Service_Pack__c
            ];
            servicePackId = serPackObj.Id;
            showservicePack=true;
        }
    }
    public PageReference openAccountPlan(){
        /*
        url = '/apex/ASI_CRM_VN_AccountPlan?id='+customer.Id;
        System.debug('Flag - isRedirect2 url:' + url);
        isRedirect2 = true;
        isRedirect = false;
        return null;
        */
        PageReference pageRef = new PageReference('/apex/ASI_CRM_VN_AccountPlan?id=' + customer.Id);
        return pageRef;
    }

    public PageReference openProsSegmentation(){
        PageReference pageRef = new PageReference('/apex/ASI_CRM_VN_ProsSegmentationPage?id=' + prosSegmentation.Id);
        return pageRef;
        /*
        url = '/apex/ASI_CRM_VN_ProsSegmentationPage?id='+prosSegmentation.Id;
        System.debug('Flag - redirect url:' + url);
        isRedirect = true;
        isRedirect2 = false;
        return null;*/
    }
    public void initImageVolumeFieldSet(){
        this.imageVolumeMap = new Map<String, Boolean>();
        this.imageWineVolumeMap = new Map<String, Boolean>();
        this.imageLevelLabels = new List<String>();
        this.volumePotentialLabels = new List<String>();

        List<Schema.PicklistEntry> imageLabels = returnImageLevels();
        List<Schema.PicklistEntry> volumeLabels = returnVolumePotentials();

        for(Schema.PicklistEntry vol: volumeLabels){
            volumePotentialLabels.add(vol.getValue());
        }
        //Baltics - modified condition to avoid null values on map
        //02/11/14 - Modified condition(referenced jucntion objs Image Level and Vol Potential Thresholds)

        for (Schema.PicklistEntry image: imageLabels){
            for(Schema.PicklistEntry vol: volumeLabels){
                if(this.prosSegmentation!= null && image.getValue().equalsIgnoreCase(this.prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c) &&
                        vol.getValue().equalsIgnoreCase(this.prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c)){
                    imageVolumeMap.put(image.getValue()+vol.getValue(), true);
                }else{
                    imageVolumeMap.put(image.getValue()+vol.getValue(), false);
                }
                if(this.prosSegmentation!= null && image.getValue().equalsIgnoreCase(this.prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c) &&
                        vol.getValue().equalsIgnoreCase(this.prosSegmentation.ASI_CRM_Wine_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c)){
                    imageWineVolumeMap.put(image.getValue()+vol.getValue(), true);
                }else{
                    imageWineVolumeMap.put(image.getValue()+vol.getValue(), false);
                }

            }
            imageLevelLabels.add(image.getValue());
        }
        this.damdmatrixMap = retrieveDAMDMatrix(prosSegmentation);
    }

    public List<Schema.PicklistEntry> returnImageLevels(){
        Schema.DescribeFieldResult fieldResult = ASI_CRM_Image_Level__c.ASI_CRM_SG_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
        System.debug('recordType'+customer.RecordType.DeveloperName);
        String RecordType = customer.RecordType.DeveloperName;
        system.debug(RecordType);
        if(RecordType.contains('ASI_CRM_VN_Value_On_Trade_Outlet'))
        {
            for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
                String val = tempPle.getValue();
                if(DEFAULT_IMAGE_LEVELS_Value.contains(val)){
                    ple.add(tempPle);
                }
            }
        }
        else
        {
            for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
                String val = tempPle.getValue();
                if(DEFAULT_IMAGE_LEVELS.contains(val)){
                    ple.add(tempPle);
                }
            }
        }

        return ple;
    }
    public List<Schema.PicklistEntry> returnVolumePotentials(){
        Schema.DescribeFieldResult fieldResult = ASI_CRM_Volume_Potential__c.ASI_CRM_SG_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        return ple;
    }
    public static List<String> returnMarketShareLabels()
    {
        List<String> msLabels = new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_CRM_DAMD_Threshold__c.ASI_CRM_SG_Market_Share__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ms: values){
            msLabels.add(ms.getValue());
        }
        return msLabels;
    }

    public  Map<String, String> retrieveDAMDMatrix(ASI_CRM_Pros_Segmentation__c prosSeg){
        Map<String, String> temDamdMap = new Map<String, String>();
        for(String vol: volumePotentialLabels){
            if(vol == prosSeg.ASI_CRM_Spirit_Champagne_Volume_Level__c && prosSeg.ASI_CRM_DAMD_Action__c != null){
                temDamdMap.put(vol, prosSeg.ASI_CRM_DAMD_Action__c);
            }else if(vol == prosSeg.ASI_CRM_Spirit_Champagne_Volume_Level__c && prosSeg.ASI_CRM_DAMD_Action__c == null){
                if(prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c != null && prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c != null){
                    temDamdMap.put(vol, 'Drop');
                }else{
                    temDamdMap.put(vol, '--');
                }
            }else{
                temDamdMap.put(vol, '--');
            }
        }

        return temDamdMap;
    }

    public ASI_CRM_Pros_Segmentation__c getProsSeg(){
        prosSegmentation = null;
        List<ASI_CRM_Pros_Segmentation__c> tempPros = [SELECT Id, ASI_CRM_SG_Account__r.Id,ASI_CRM_SG_Customer__r.Id,
                ASI_CRM_SG_Group_Outlet_Type__c, ASI_CRM_SG_Outlet_Type__c,
                ASI_CRM_SG_Image_Level__c, ASI_CRM_SG_Volume_Potential__c,
                ASI_CRM_SG_Service_Pack__c,
                ASI_CRM_SG_Is_Image_Level_Modified__c, ASI_CRM_SG_Is_Volume_Potential_Modified__c,
                ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Name__c,
                ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c,
                ASI_CRM_SG_Outlet_Type__r.ASI_CRM_SG_Name__c,
                ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c, ASI_CRM_SG_Volume_Potential__r.ASI_CRM_SG_Name__c,
                ASI_CRM_SG_Image_Level_Threshold__c, ASI_CRM_SG_Volume_Potential_Threshold__c,
                ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c,
                ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                ASI_CRM_Wine_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                ASI_CRM_SG_Image_Level_Id__c,
                ASI_CRM_SG_Volume_Potential_Id__c,
                ASI_CRM_Spirit_Champagne_Volume_Level__c,
                ASI_CRM_DAMD_Action__c
        FROM ASI_CRM_Pros_Segmentation__c
        WHERE ASI_CRM_SG_Customer__c =: customer.Id
        LIMIT 1];
        if(!tempPros.isEmpty()){
            prosSegmentation = tempPros[0];
            System.debug('--- field 1 ---' + tempPros);
            System.debug('--- prosSegmentation1 ---' + prosSegmentation);
        }
        return prosSegmentation;
    }

    public Component.Apex.CommandButton getCustomLink(){
        Component.Apex.CommandButton customLink  = new Component.Apex.CommandButton();

        if(prosSegmentation != null){
            //Apex.Component.OutputLink content = new Apex.Component.OutputLink();
            customLink.value = 'Open Pros Segmentation';
            customLink.expressions.action = '{!openProsSeg}';
        }else{
            customLink.value = 'Assign Pros Segmentation';
            customLink.expressions.action = '{!createProsSegmentation}';
        }
        customLink.rerender = new Set<String>{'redirectPanel'};
        return customLink;
    }
    public PageReference openProsSeg() {
        if (prosSegmentation!=null){
            url = '/' + prosSegmentation.Id;
            isRedirect = true;
        }
        return null;
    }

    public PageReference updateImage(){
        return null;
    }
}
/*********************************************************************************
     * Name:ASI_CRM_VN_ProsSegButtonController
     * Description: Component Controller for displaying the pros segmentation
     * Test Class: ASI_CRM_VN_ProsSegButtonControllerTest
     * 
     * Version History
     * Date             Developer               Comments
     * ---------------  --------------------    ----------------------------------
     * 26/10/2015       Laputa: Neha             Created
     * 18/12/2018       Laputa: Andy             Add logic check customer reocrd type
     *                                           display label 'IB29/Vodka Men Volume'
     *                                           for Value and set wine
     * 20/12/2018       Laputa: Andy             Handle Value Segment Customer logic
     * 07/05/2019       Wilken                   [WL 1.0] INC0076072 Validate Group Outlet type again when viewing PROS page 
*********************************************************************************/

public with sharing class ASI_CRM_VN_ProsSegButtonController{
    public ASI_CRM_AccountsAdditionalField__c customer{get;set;}
    public ASI_CRM_Pros_Segmentation__c prosSegmentation{get;set;}
    public ASI_CRM_Group_Outlet_Type__c outletType{get;set;}
    public String outletTypeStr{get;set;}
    public Id servicePackId{get;set;}
    public String url{get;set;}
    public Boolean isRedirect{get;set;}{isRedirect = false;}
    public Boolean isDisplay{get;set;}{isDisplay = false;}
    public Boolean isImage{get;set;}{isImage = false;}
    public List<String> imageLevelLabels{get;set;}
    public List<String> volumePotentialLabels{get;set;}
    public Map<String, Boolean> imageVolumeMap{get;set;}
    public Map<String, Boolean> imageWineVolumeMap{get;set;}
    public static Set<String> DEFAULT_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream'};
    public static Set<String> DEFAULT_IMAGE_LEVELS_VALUE = new Set<String>{'Platinum','Gold','Silver','Bronze'};
    public Map<String, String> damdmatrixMap {get;set;}
    public List<ASI_CRM_ServicePack__c> spList{get;set;}
    public String imageStr{get;set;}
    public String thresholdStr1{get;set;}
    public String thresholdStr2{get;set;}

    public ASI_CRM_VN_ProsSegButtonController(ApexPages.StandardController standardController){
        prosSegmentation = (ASI_CRM_Pros_Segmentation__c)standardController.getRecord();
        if(prosSegmentation != null){
            prosSegmentation = [SELECT ASI_CRM_SG_Customer__c,
                    ASI_CRM_SG_DAMD_Threshold__c,    //Neha 11/16/2015
                    ASI_CRM_SG_Group_Outlet_Type__c,
                    ASI_CRM_Spirit_Champagne_Volume__c,
                    ASI_CRM_Wine_Volume__c,
                    ASI_CRM_SG_Service_Pack__c,
                    ASI_CRM_SG_Volume_Potential_Threshold__c,
                    ASI_CRM_SG_Image_Level_Threshold__c,
                    ASI_CRM_DAMD_Action__c,
                    ASI_CRM_Spirit_Champagne_Volume_Level__c,
                    ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                    ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c,
                    ASI_CRM_Wine_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
            (
                    SELECT ASI_CRM_SG_Statement__c,
                            ASI_CRM_SG_Answer__c,
                            ASI_CRM_Score__c
                    FROM ASI_PROS_Pros_Image_Levels__r
            )
            FROM ASI_CRM_Pros_Segmentation__c
            WHERE Id = :prosSegmentation.Id];
            
            if(prosSegmentation.ASI_CRM_SG_Customer__c != null){
                customer = [SELECT Id,
                        RecordType.Name,
                        ASI_TH_CRM_Contracted_With__c,
                        ASI_CRM_Outlet_Sub_Type__c,
                        ASI_CRM_Area__c, //WL 1.0
                        ASI_CRM_VN_OutletType__c,
                        ASI_CRM_Service_Pack__c,
                        ASI_CRM_SG_Image_Level__c,
                        RecordType.DeveloperName
                FROM ASI_CRM_AccountsAdditionalField__c WHERE Id = : prosSegmentation.ASI_CRM_SG_Customer__c];
                outletTypeStr = customer.ASI_CRM_VN_OutletType__c;
                servicePackId = customer.ASI_CRM_Service_Pack__c;
            }
            if(prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c != null){
                outletType = [SELECT Id,
                (SELECT ASI_CRM_Category__c,
                        ASI_CRM_SG_Volume_Potential_Name__c,
                        ASI_CRM_Volume__c
                FROM ASI_CRM_Volume_Potential_Thresholds__r),
                (SELECT ASI_CRM_Image_Level_Name__c,
                        ASI_CRM_SG_Volume_Potential_Name__c,
                        ASI_CRM_Contract_Status__c,
                        ASI_CRM_SG_Action__c
                FROM DAMD_Thresholds__r)
                FROM ASI_CRM_Group_Outlet_Type__c
                WHERE Id = :prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c];
            }
            if(customer.RecordType.Name.Contains('VN Value'))
            {
                prosSegmentation.ASI_CRM_Wine_Volume__c = 0;
                //update prosSegmentation;
            }
            if(prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c != null && prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c != null){
                initImageVolumeFieldSet();
                isDisplay = true;
            }
            if(prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c != null){
                isImage = true;
            }
            spList = [SELECT Id,
                    ASI_CRM_SG_Outlet_Type__c,
                    ASI_CRM_SG_Sub_Outlet_Type__c,
                    ASI_CRM_SG_Segmentation__c,
                    ASI_CRM_SG_DAMD_Action__c
            FROM ASI_CRM_ServicePack__c
            WHERE recordtypeId = :Global_RecordTypeCache.getRTId('ASI_CRM_ServicePack__cASI_CRM_VN_ServicePack')];
        }
    }

    /*[WL 1.0] BEGIN*/
    public PageReference validateGrpOutletType(){
        if (prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c != null){
            Id correctGrpOutletType = ASI_CRM_VN_AccCreateProsSegHandler.getGroupOutletTypeFromAcc(customer);
            
            system.debug('Customer GrpOutletType: ' + prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c + ' Correct GrpOutletType = ' + correctGrpOutletType);
            if (prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c != correctGrpOutletType){
                ASI_CRM_VN_AccCreateProsSegHandler handler = new ASI_CRM_VN_AccCreateProsSegHandler();
                List<ASI_CRM_AccountsAdditionalField__c> accList = new List<ASI_CRM_AccountsAdditionalField__c>();
                accList.add(customer);
                
                handler.manageAccountProsSegRecord(accList);
                
                ASI_CRM_Pros_Segmentation__c newPROS = [SELECT ID FROM ASI_CRM_Pros_Segmentation__c WHERE ASI_CRM_SG_Customer__c = :customer.Id LIMIT 1];
                PageReference ref = new PageReference('/apex/ASI_CRM_VN_ProsSegmentationPage?id=' + newPROS.Id);
                ref.setRedirect(true);
                return ref;
            }
        }
        return null;
    }
    /*[WL 1.0] END*/
    
    public PageReference save(){
        if(prosSegmentation != null){
            if(outletType != null){
                Decimal lowestSpirit = -1;
                Decimal lowestWine = -1;
                for(ASI_CRM_Volume_Potential_Threshold__c vol:outletType.ASI_CRM_Volume_Potential_Thresholds__r){
                    if(prosSegmentation.ASI_CRM_Spirit_Champagne_Volume__c != null){
                        if(vol.ASI_CRM_Category__c == 'Spirit & Champagne' && prosSegmentation.ASI_CRM_Spirit_Champagne_Volume__c >= vol.ASI_CRM_Volume__c && vol.ASI_CRM_Volume__c > lowestSpirit){
                            lowestSpirit = vol.ASI_CRM_Volume__c;
                            prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c = vol.Id;
                            thresholdStr1 = vol.ASI_CRM_SG_Volume_Potential_Name__c;
                        }
                    }
                    if(prosSegmentation.ASI_CRM_Wine_Volume__c != null){
                        if(vol.ASI_CRM_Category__c == 'Wine' && prosSegmentation.ASI_CRM_Wine_Volume__c >= vol.ASI_CRM_Volume__c && vol.ASI_CRM_Volume__c > lowestWine){
                            lowestWine = vol.ASI_CRM_Volume__c;
                            prosSegmentation.ASI_CRM_Wine_Volume_Potential_Threshold__c = vol.Id;
                            thresholdStr2 = vol.ASI_CRM_SG_Volume_Potential_Name__c;
                        }
                    }
                }
                if(prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c != null && prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c != null){
                    System.debug('Debug: volume: ' + prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c + ' image: ' + prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c);
                    updateDAMD();
                }
            }
            update prosSegmentation;
        }
        //PageReference ref = new PageReference('/apex/ASI_CRM_VN_ProsSegmentationPage?id=' + prosSegmentation.Id);
        PageReference ref = new PageReference('/' + customer.Id);
        ref.setRedirect(true);
        return ref;
    }

    public PageReference cancel(){
        return new PageReference('/' + customer.Id);
    }

    public PageReference openAccountPlan(){
        url = '/apex/ASI_CRM_VN_AccountPlan?id='+customer.Id;
        isRedirect = true;
        return null;
    }

    public PageReference updateImage(){
        return new PageReference('/apex/ASI_CRM_VN_UpdateImagePage?id=' + prosSegmentation.Id);
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
        String RecordType = customer.RecordType.DeveloperName;
        if(RecordType.contains('ASI_CRM_VN_Value_On_Trade_Outlet'))
        {
            for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
                String val = tempPle.getValue();
                if(DEFAULT_IMAGE_LEVELS_VALUE.contains(val)){
                    ple.add(tempPle);
                }
            }
        }else {
            System.debug('recordType' + RecordType);
            for (Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()) {
                String val = tempPle.getValue();
                if (DEFAULT_IMAGE_LEVELS.contains(val)) {
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

    public void updateDAMD(){
        Id dropId;
        String damdStr;
        Boolean foundDAMD = false;
        for(ASI_CRM_DAMD_Threshold__c t:outletType.DAMD_Thresholds__r){
            if(outletTypeStr != 'RES'){
                if(customer.ASI_TH_CRM_Contracted_With__c == 'PRVN' && t.ASI_CRM_Contract_Status__c == customer.ASI_TH_CRM_Contracted_With__c){
                    if(t.ASI_CRM_Image_Level_Name__c == prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c &&
                            (t.ASI_CRM_SG_Volume_Potential_Name__c == null || t.ASI_CRM_SG_Volume_Potential_Name__c == thresholdStr1)){
                        prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = t.Id;
                        damdStr = t.ASI_CRM_SG_Action__c;
                        foundDAMD = true;
                        break;
                    }
                }else if(customer.ASI_TH_CRM_Contracted_With__c != 'PRVN' && t.ASI_CRM_Contract_Status__c == null){
                    if(t.ASI_CRM_Image_Level_Name__c == prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c &&
                            (t.ASI_CRM_SG_Volume_Potential_Name__c == null || t.ASI_CRM_SG_Volume_Potential_Name__c == thresholdStr1)){
                        prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = t.Id;
                        damdStr = t.ASI_CRM_SG_Action__c;
                        foundDAMD = true;
                        break;
                    }
                }
            }else{
                String threStr = maxThreshold(thresholdStr1, thresholdStr2);
                if(customer.ASI_TH_CRM_Contracted_With__c == 'PRVN' && t.ASI_CRM_Contract_Status__c == customer.ASI_TH_CRM_Contracted_With__c){
                    if(t.ASI_CRM_Image_Level_Name__c == prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c &&
                            (t.ASI_CRM_SG_Volume_Potential_Name__c == null || t.ASI_CRM_SG_Volume_Potential_Name__c == threStr)){
                        prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = t.Id;
                        damdStr = t.ASI_CRM_SG_Action__c;
                        foundDAMD = true;
                        break;
                    }
                }else if(customer.ASI_TH_CRM_Contracted_With__c != 'PRVN' && t.ASI_CRM_Contract_Status__c == null){
                    if(t.ASI_CRM_Image_Level_Name__c == prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c &&
                            (t.ASI_CRM_SG_Volume_Potential_Name__c == null || t.ASI_CRM_SG_Volume_Potential_Name__c == threStr)){
                        prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = t.Id;
                        damdStr = t.ASI_CRM_SG_Action__c;
                        foundDAMD = true;
                        break;
                    }
                }
            }
            if(t.ASI_CRM_SG_Action__c == 'Drop'){
                dropId = t.Id;
            }
        }
        if(foundDAMD == false){
            prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = dropId;
            damdStr = 'Drop';
        }
        //system.debug('Pros: ' + customer.ASI_CRM_VN_OutletType__c + ' ' + prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c + ' ' + damdStr + ' ' + customer.ASI_CRM_Outlet_Sub_Type__c);
        Boolean foundSP = false;
        for(ASI_CRM_ServicePack__c sp:spList){
            system.debug('Service: ' + sp.ASI_CRM_SG_Outlet_Type__c + ' ' + sp.ASI_CRM_SG_Segmentation__c + ' ' + sp.ASI_CRM_SG_DAMD_Action__c + ' ' + sp.ASI_CRM_SG_Sub_Outlet_Type__c);
            if(sp.ASI_CRM_SG_Outlet_Type__c == customer.ASI_CRM_VN_OutletType__c &&
                    sp.ASI_CRM_SG_Segmentation__c == prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c &&
                    sp.ASI_CRM_SG_DAMD_Action__c == damdStr &&
                    (sp.ASI_CRM_SG_Sub_Outlet_Type__c == null || sp.ASI_CRM_SG_Sub_Outlet_Type__c == customer.ASI_CRM_Outlet_Sub_Type__c)){
                prosSegmentation.ASI_CRM_SG_Service_Pack__c = sp.Id;
                customer.ASI_CRM_Service_Pack__c = sp.Id;
                foundSP = true;
            }
        }
        if(foundSP == false){
            customer.ASI_CRM_Service_Pack__c = null;
        }
        update customer;
    }

    @TestVisible
    private String maxThreshold(String th1, String th2){
        if(th1 == 'High' || th2 == 'High'){
            return 'High';
        }else if(th1 == 'Medium' || th2 == 'Medium'){
            return 'Medium';
        }else{
            return 'Low';
        }
    }
}
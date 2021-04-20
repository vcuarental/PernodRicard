/*********************************************************************************
* Name:ASI_CRM_VN_UpdateImageController
* Description: ASI_CRM_VN_UpdateImageController
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    ----------------------------------
* 28/10/2015       Laputa: Hank             Created
*********************************************************************************/

public with sharing class ASI_CRM_VN_UpdateImageController{
    public ASI_CRM_AccountsAdditionalField__c customer{get;set;}
    public ASI_CRM_Pros_Segmentation__c prosSegmentation{get;set;}
    public List<ASI_CRM_Criteria_Threshold__c> thresholdList{get;set;}
    public Map<String, Question> questionMap{get;set;}
    public Map<String, List<ASI_CRM_Criteria_Threshold__c>> thresDataMap{get;set;}
    public List<Question> questionList{get;set;}
    public ASI_CRM_Group_Outlet_Type__c outletType{get;set;}
    public List<ASI_CRM_ServicePack__c> spList{get;set;}
    public String imageStr{get;set;}
    public ASI_CRM_VN_UpdateImageController(ApexPages.StandardController standardController){
        prosSegmentation = (ASI_CRM_Pros_Segmentation__c)standardController.getRecord();
        prosSegmentation = [Select ASI_CRM_Total_Image_Level_Score__c, 
                                   ASI_CRM_SG_Customer__c,
                                   ASI_CRM_SG_Group_Outlet_Type__c, 
                                   ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c,
                                   ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                                   ASI_CRM_Wine_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                                   ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c,
                                   ASI_CRM_SG_Volume_Potential_Threshold__c,
                                   ASI_CRM_SG_Image_Level_Threshold__c
                                   From ASI_CRM_Pros_Segmentation__c Where Id =:prosSegmentation.Id];
        customer = [select ASI_TH_CRM_Contracted_With__c, ASI_CRM_VN_OutletType__c, ASI_CRM_Outlet_Sub_Type__c, ASI_CRM_Service_Pack__c From ASI_CRM_AccountsAdditionalField__c where Id = :prosSegmentation.ASI_CRM_SG_Customer__c];
        if(prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c != null){
            thresholdList = [Select Id, 
                                    ASI_CRM_SG_Question__c, 
                                    ASI_CRM_Picklist_Value__c,
                                    ASI_CRM_Score__c,
                                    ASI_CRM_Min_Threshold__c,
                                    ASI_CRM_Max_Threshold__c,
                                    ASI_CRM_Condition__c, 
                                    RecordType.Name
                                    From ASI_CRM_Criteria_Threshold__c 
                                    Where ASI_CRM_SG_Criteria_Set__c = :prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c
                                    Order By ASI_CRM_SG_Sequence__c];
            questionMap = new Map<String, Question>();
            createQuestions();
            questionList = questionMap.values();
            if(prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c != null){
                outletType = [Select Id, 
                                     ASI_CRM_SG_Group_Outlet_Name__c,
                                     (Select Id,
                                             ASI_CRM_SG_Image_Level_Name__c,
                                             ASI_CRM_SG_Image_Level__c,
                                             ASI_CRM_Score__c
                                      From ASI_CRM_Image_Level_Thresholds__r),
                                     (Select ASI_CRM_Image_Level_Name__c,
                                             ASI_CRM_SG_Volume_Potential_Name__c,
                                             ASI_CRM_Contract_Status__c,
                                             ASI_CRM_SG_Action__c
                                      From DAMD_Thresholds__r)       
                              From ASI_CRM_Group_Outlet_Type__c 
                              Where Id = :prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c];
            }
        }
        spList = [Select Id,
                             ASI_CRM_SG_Outlet_Type__c,
                             ASI_CRM_SG_Sub_Outlet_Type__c,
                             ASI_CRM_SG_Segmentation__c,
                             ASI_CRM_SG_DAMD_Action__c
                      From ASI_CRM_ServicePack__c 
                      Where recordtypeId = :Global_RecordTypeCache.getRTId('ASI_CRM_ServicePack__cASI_CRM_VN_ServicePack')];
    }
    
    public void createQuestions(){
        thresDataMap = new Map<String, List<ASI_CRM_Criteria_Threshold__c>>();
        for(ASI_CRM_Criteria_Threshold__c t:thresholdList){
            if(thresDataMap.get(t.ASI_CRM_SG_Question__c) == null){
                List<ASI_CRM_Criteria_Threshold__c> tempList = new List<ASI_CRM_Criteria_Threshold__c>();
                tempList.add(t);
                thresDataMap.put(t.ASI_CRM_SG_Question__c, tempList);
            }else{
                thresDataMap.get(t.ASI_CRM_SG_Question__c).add(t);
            }
            
            if(questionMap.get(t.ASI_CRM_SG_Question__c) == null){
                Question q = new Question();
                q.qLabel = t.ASI_CRM_SG_Question__c;
                q.qType = t.RecordType.Name;
                if(q.qType == 'VN Picklist'){
                    List<SelectOption> options = new List<SelectOption>();
                    List<String> strList = t.ASI_CRM_Picklist_Value__c.split(',');
                    for(String s:strList){
                        options.add(new SelectOption(s,s));
                    }
                    q.qOptions = options;
                }
                questionMap.put(q.qLabel,q);
            }
        }
    }
    
    public PageReference updateImage(){
        List<ASI_CRM_Pros_Image_Level__c> oldProsImageList = [Select Id From ASI_CRM_Pros_Image_Level__c Where ASI_CRM_SG_Pros_Segmentation__c =:prosSegmentation.Id];
        delete oldProsImageList;
        List<ASI_CRM_Pros_Image_Level__c> prosImageList = new List<ASI_CRM_Pros_Image_Level__c>();
        for(Question q:questionList){
            ASI_CRM_Pros_Image_Level__c prosImage = new ASI_CRM_Pros_Image_Level__c();
            for(ASI_CRM_Criteria_Threshold__c t:thresDataMap.get(q.qLabel)){
                if((q.qType == 'VN Number Input' || q.qType == 'VN Currency Input' || q.qType == 'VN Picklist') &&
                        (Decimal.valueOf(q.qAnswer) >= t.ASI_CRM_Min_Threshold__c && Decimal.valueOf(q.qAnswer) <= t.ASI_CRM_Max_Threshold__c || Decimal.valueOf(q.qAnswer) >= t.ASI_CRM_Min_Threshold__c && t.ASI_CRM_Max_Threshold__c == null)){
                    prosImage.ASI_CRM_SG_Pros_Segmentation__c =  prosSegmentation.Id;   
                    prosImage.ASI_CRM_SG_Answer__c = q.qAnswer;
                    prosImage.ASI_CRM_SG_Criteria_Threshold__c = t.Id;
                    prosImage.ASI_CRM_Score__c = t.ASI_CRM_Score__c;
                    prosImage.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Pros_Image_Level__cASI_CRM_VN_ProsImageLevel');
                    prosImageList.add(prosImage);
                }else if(q.qType == 'VN Yes/No' && t.ASI_CRM_Condition__c == q.qAnswer){
                    prosImage.ASI_CRM_SG_Pros_Segmentation__c =  prosSegmentation.Id;
                    prosImage.ASI_CRM_SG_Answer__c = q.qAnswer;   
                    prosImage.ASI_CRM_SG_Criteria_Threshold__c = t.Id;
                    prosImage.ASI_CRM_Score__c = t.ASI_CRM_Score__c;
                    prosImage.recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_Pros_Image_Level__cASI_CRM_VN_ProsImageLevel');
                    prosImageList.add(prosImage);
                }
            }
        }
        insert prosImageList;
        prosSegmentation = [Select ASI_CRM_Total_Image_Level_Score__c, 
                                   ASI_CRM_SG_Customer__c,
                                   ASI_CRM_SG_Group_Outlet_Type__c, 
                                   ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c,
                                   ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                                   ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c,
                                   ASI_CRM_SG_Volume_Potential_Threshold__c,
                                   ASI_CRM_SG_DAMD_Threshold__c,
                                   ASI_CRM_Wine_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                                   ASI_CRM_SG_Service_Pack__c,
                                   ASI_CRM_SG_Image_Level_Threshold__c
                                   From ASI_CRM_Pros_Segmentation__c Where Id =:prosSegmentation.Id];
        Decimal minScore = -0.1;
        system.debug('score ' + prosSegmentation.ASI_CRM_Total_Image_Level_Score__c);
        for(ASI_CRM_Image_Level_Threshold__c image:outletType.ASI_CRM_Image_Level_Thresholds__r){
            system.debug(' test score: ' + image.ASI_CRM_Score__c);
            if(prosSegmentation.ASI_CRM_Total_Image_Level_Score__c >= image.ASI_CRM_Score__c && image.ASI_CRM_Score__c > minScore){
                minScore = image.ASI_CRM_Score__c;
                prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c = image.id;
                imageStr = image.ASI_CRM_SG_Image_Level_Name__c;
                customer.ASI_CRM_CN_Image__c = image.ASI_CRM_SG_Image_Level_Name__c;
                system.debug('min :' + minScore);
            }        
        }
        if(prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c != null && prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c != null){
            system.debug('Debug: volume: ' + prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c + ' image: ' + prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c);
            System.debug(' updateDAMD ');
            updateDAMD(); 
        }
        update prosSegmentation;
        update customer;
        return new PageReference('/apex/ASI_CRM_VN_ProsSegmentationPage?id=' + prosSegmentation.Id);
    }
    
    public PageReference cancel(){
        return new PageReference('/apex/ASI_CRM_VN_ProsSegmentationPage?id=' + prosSegmentation.Id);
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        return options;
    }
    
    public void updateDAMD(){
        String damdStr;
        Id dropId;
        for(ASI_CRM_DAMD_Threshold__c t:outletType.DAMD_Thresholds__r){
            if(outletType.ASI_CRM_SG_Group_Outlet_Name__c != 'RES'){
                if(customer.ASI_TH_CRM_Contracted_With__c == 'PRVN' && t.ASI_CRM_Contract_Status__c == customer.ASI_TH_CRM_Contracted_With__c){
                    if(t.ASI_CRM_Image_Level_Name__c == imageStr && 
                            (t.ASI_CRM_SG_Volume_Potential_Name__c == null || t.ASI_CRM_SG_Volume_Potential_Name__c == prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c)){
                        prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = t.Id;
                        damdStr = t.ASI_CRM_SG_Action__c;
                        break;
                    }
                }else if(customer.ASI_TH_CRM_Contracted_With__c != 'PRVN' && t.ASI_CRM_Contract_Status__c == null){
                    if(t.ASI_CRM_Image_Level_Name__c == imageStr && 
                            (t.ASI_CRM_SG_Volume_Potential_Name__c == null || t.ASI_CRM_SG_Volume_Potential_Name__c == prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c)){
                        prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = t.Id;
                        damdStr = t.ASI_CRM_SG_Action__c;
                        break;
                    }
                }
            }else{
                String threStr = maxThreshold(prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c, prosSegmentation.ASI_CRM_Wine_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c);
                if(customer.ASI_TH_CRM_Contracted_With__c == 'PRVN' && t.ASI_CRM_Contract_Status__c == customer.ASI_TH_CRM_Contracted_With__c){
                    if(t.ASI_CRM_Image_Level_Name__c == imageStr && 
                            (t.ASI_CRM_SG_Volume_Potential_Name__c == null || t.ASI_CRM_SG_Volume_Potential_Name__c == threStr)){
                        prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = t.Id;
                        damdStr = t.ASI_CRM_SG_Action__c;
                        break;
                    }
                }else if(customer.ASI_TH_CRM_Contracted_With__c != 'PRVN' && t.ASI_CRM_Contract_Status__c == null){
                    if(t.ASI_CRM_Image_Level_Name__c == imageStr && 
                            (t.ASI_CRM_SG_Volume_Potential_Name__c == null || t.ASI_CRM_SG_Volume_Potential_Name__c == threStr)){
                        prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = t.Id;
                        damdStr = t.ASI_CRM_SG_Action__c;
                        break;
                    }
                }
            }
            if(t.ASI_CRM_SG_Action__c == 'Drop'){
                dropId = t.Id;    
            }
        }
        if(prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c == null){
            prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = dropId;
            damdStr = 'Drop';        
        }
        for(ASI_CRM_ServicePack__c sp:spList){
            if(sp.ASI_CRM_SG_Outlet_Type__c == customer.ASI_CRM_VN_OutletType__c &&
                    sp.ASI_CRM_SG_Segmentation__c == prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c &&
                    sp.ASI_CRM_SG_DAMD_Action__c == damdStr &&
                    (sp.ASI_CRM_SG_Sub_Outlet_Type__c == null || sp.ASI_CRM_SG_Sub_Outlet_Type__c == customer.ASI_CRM_Outlet_Sub_Type__c)){
                prosSegmentation.ASI_CRM_SG_Service_Pack__c = sp.Id;
                customer.ASI_CRM_Service_Pack__c = sp.Id;
                //update customer;
            }
        }
    }
    
    @TestVisible private String maxThreshold(String th1, String th2){
        if(th1 == 'High' || th2 == 'High'){
            return 'High';
        }else if(th1 == 'Medium' || th2 == 'Medium'){
            return 'Medium';
        }else{
            return 'Low';
        }
    }
    
    public class Question{
        Public String qLabel{get;set;}
        Public String qType{get;set;}
        Public String qAnswer{get;set;}
        Public List<SelectOption> qOptions{get;set;}
    }
}
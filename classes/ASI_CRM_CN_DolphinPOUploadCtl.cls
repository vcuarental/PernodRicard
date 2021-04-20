/**************************************************************************************************
 * Name: ASI_CRM_CN_DolphinPOUploadCtl
 * Object: ASI_MFM_Plan__c
 * Purpose: 
 * Author:  (Zhonghui Li)
 * Create Date: 2021-01-18
 * Modify History:
 * 2021-01-18        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_DolphinPOUploadCtl {
    public String errorHeader {get; set;}
    public String uploadComments {get; set;}
    public static String remarksSetting = Label.ASI_CRM_CN_TP_Remarks;
    public List<String> tpHeaderList{get; set;}
    

    public ASI_CRM_CN_DolphinPOUploadCtl() {
        ASI_CRM_CN_CustomSetting__c tpSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        String header = 'PO  No,Outlet/WS Code,PO Owner,PO Start Date,PO End Date,Use PRC Contract Template,Volume/Value Base,Activity Times,Description,PSF Module2 Minimal Achievement,PSF Module2 Rate,Subbrand Code,Subbrand Purchase Value﻿,Contract Monthly QTY (Std. Bottle)';
        tpHeaderList = header.split(',');
        uploadComments = tpSetting.ASI_CRM_CN_TP_Upload_Comments__c;
        errorHeader = header + ',error info';
    }

    @RemoteAction
    public static Map<String, Object> checkUploadData(String input){
        System.debug(LoggingLevel.INFO, '*** input: ' + input);
        Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
       
       Map<String, object> result = new Map<String, object>();
        
        String crm = (String)inputMap.get('outletCode');
        result.put('outletId', [SELECT Id, ASI_CRM_CN_CRM_Code__c, OwnerId,
                                                                        ASI_CRM_CN_NewChannel__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__c
                                                               FROM ASI_CRM_AccountsAdditionalField__c
                                                               WHERE ASI_CRM_CN_CRM_Code__c = :crm
                                                               LIMIT 1]?.Id);
        String volumeBase = (String)inputMap.get('volumeBase');
        if (!('Value,Volume'.contains(volumeBase))){
            result.put('volumeBase', 'invalid');
        } else {
            result.put('volumeBase', volumeBase);
        }
        result.put('ownerId', [SELECT Id
                                FROM User
                                WHERE Email = :(String)inputMap.get('ownerEmail')
                                 AND IsActive = true
                                LIMIT 1]?.Id);
    
        result.put('subBrandId', [SELECT Id, Name
                                FROM ASI_MFM_Sub_brand__c
                                WHERE Name = :(String)inputMap.get('subbrandName')
                                LIMIT 1]?.Id);
        try {
            Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
            String startDate = (String)inputMap.get('startDate');
            String endDate = (String)inputMap.get('endDate');
            if (startDate.contains('/')) {
                startDate = startDate.replace('/', '-');
            }
            if (endDate.contains('/')) {
                endDate = endDate.replace('/', '-');
            }
            if (Date.valueOf(startDate) >  Date.valueOf(endDate)) {
                result.put('dateValid', 'invalidDate');
            }
            if(!ASI_CRM_DateUtilClass.isStartOfMonth(Date.valueOf(startDate))){
                result.put('dateValid', 'invalidStartDate');
            }
            if(!ASI_CRM_DateUtilClass.isEndOfMonth(Date.valueOf(endDate))){
                result.put('dateValid', 'invalidEndDate');
            }
            if(!ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CN_FiscalYearBypass') && ASI_CRM_DateUtilClass.isCrossingFiscalYear(Date.valueOf(startDate),Date.valueOf(endDate))){
                result.put('dateValid', 'invalidCrossdDate');
            }
        } catch (Exception e) {
            result.put('dateValid', 'errorDate');
        }

        return result;
    }

    @RemoteAction
    public static String saveData(String BPJson, String eventId){
        System.debug(LoggingLevel.INFO, '*** BPJson: ' + BPJson);
        List<ASI_MFM_Mass_Upload_Log__c> poList = (List<ASI_MFM_Mass_Upload_Log__c>)JSON.deserialize(BPJson, List<ASI_MFM_Mass_Upload_Log__c>.class);
        System.debug(LoggingLevel.INFO, '*** poList.size(): ' + poList.size());
        insert poList;
        ASI_CRM_CN_DolphinPOUploadBatch batch = new ASI_CRM_CN_DolphinPOUploadBatch();
        batch.query = 'SELECT Id, ASI_CRM_File_Name__c, ASI_MFM_Name__c,ASI_CRM_Result__c,ASI_MFM_Status__c,ASI_CRM_Remark__c,ASI_CRM_Related_Id__c,ASI_CRM_Related_Name__c  ' +
                        'FROM ASI_MFM_Mass_Upload_Log__c WHERE ASI_CRM_File_Name__c=\'' + eventId+'\'';
        batch.eventId = eventId;
        Id jobId = Database.executeBatch(batch, 1);
        return eventId;
    }

    @RemoteAction
    public static List<ResObject> queyBatchResultStatus(String eventId){
        // return JSON.serialize([SELECT Id, ASI_CRM_File_Name__c, ASI_MFM_Name__c,ASI_CRM_Result__c,
        //                ASI_MFM_Status__c,ASI_CRM_Remark__c,ASI_CRM_Related_Id__c,ASI_CRM_Related_Name__c 
        //         FROM ASI_MFM_Mass_Upload_Log__c 
        //         WHERE ASI_CRM_File_Name__c =:eventId]);
        List<ResObject> resList = new List<ResObject>();
        for (ASI_MFM_Mass_Upload_Log__c log: [SELECT Id, ASI_CRM_File_Name__c, ASI_MFM_Name__c,ASI_CRM_Result__c,
                       ASI_MFM_Status__c,ASI_CRM_Remark__c,ASI_CRM_Related_Id__c,ASI_CRM_Related_Name__c 
                FROM ASI_MFM_Mass_Upload_Log__c 
                WHERE ASI_CRM_File_Name__c =:eventId]) {
            DolphinPO po = (DolphinPO)JSON.deserialize(log.ASI_CRM_Result__c, DolphinPO.class);
            log.ASI_CRM_Result__c = '';
            resList.add(new ResObject(po, log));
        }
        return resList;
    }

    public class DolphinPO {
        public Integer index;                               
        public Boolean show;                            
        public List<String> errors;
        public String errorStr;                     
        public String selected;                        
        public Boolean loading;                         
        public String status;                        
        public String PONO;                        
        public String outletCode;                        
        public String outletId;
        public String outletName;
        public String ownerId;                       
        public String ownerEmail;                        
        public String startDate;                        
        public String endDate;                        
        public String usePRCTemplate;                        
        public String volumeBase;                        
        public String activityTimes;                        
        public String description;                        
        public Decimal psfModule2MinAchievement; 
        public Decimal psfModule2Rate; 
        public String subbrandName;
        public String subBrandId;
        public Decimal subbrandPurchaseValue;
        public Decimal subbrandBtl;
        public List<SubbrandInfo> subbrands;                                                                      
        public DolphinPO orgData;                        
    }
    public class ResObject {
        public DolphinPO po;
        public ASI_MFM_Mass_Upload_Log__c log;
        public ResObject(DolphinPO po, ASI_MFM_Mass_Upload_Log__c log) {
            this.po = po;
            this.log = log;
        }
    }
    public class SubbrandInfo {
        public String subbrandName;
        public String subBrandId;
        public Decimal subbrandPurchaseValue;
        public Decimal subbrandBtl;
        public Integer index;
        public SubbrandInfo(String subbrandName, String subBrandId, Decimal subbrandPurchaseValue, Integer index) {
            this.subbrandName = subbrandName;
            this.subBrandId = subBrandId;
            this.subbrandPurchaseValue = subbrandPurchaseValue;
            this.index = index;
        }
    }
}
public class ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL {
	
    Private Static Final String ARTWORK_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Final_Artwork_Photo');
    Private Static Final String POSM_PHOTO_RECORDTYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
    Private Static Final Map<String, Schema.SObjectField> ITEM_GROUP_FIELD_MAP = Schema.SObjectType.ASI_MFM_Item_Group__c.fields.getMap();
    Private Static Final Map<String, Schema.SObjectField> PRODUCT_WAREHOSE_PHOTO_FIELD_MAP = Schema.SObjectType.ASI_CRM_Product_Warehouse_Photo__c.fields.getMap();
    
    Public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    Public ASI_MFM_Item_Group__c header {Get; Set;}
    Public List<ASI_CRM_Product_Warehouse_Photo__c> photoLines {Get; Set;}
    Public List<ASI_CRM_Product_Warehouse_Photo__c> posmPhotoLines {Get; Set;}
    Public Id recordId {Get; Set;}
    Public List<apprivalHistoryClass> apprivalHistoryList {Get; Set;}
    Public Boolean hasLine {Get; Set;}
    Public Boolean hasPOSMLine {Get; Set;}
    
    Public ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL(apexPages.StandardController sc){}
	
    Public ASI_MFM_CN_POSM_ItemGroup_PDF_CTRL(){}
	    
    public boolean init(){
        
        if(recordId != Null){
            
            hasLine = False;
            hasPOSMLine = False;
            
            photoLines = new List<ASI_CRM_Product_Warehouse_Photo__c>();
            posmPhotoLines = new List<ASI_CRM_Product_Warehouse_Photo__c>();
            
            header = (ASI_MFM_Item_Group__c)queryRecords(ITEM_GROUP_FIELD_MAP, ', owner.Name, ASI_MFM_Sub_brand__r.name, ASI_MFM_Category_Level_1__r.Name, ASI_MFM_Category_Level_2__r.Name, ASI_MFM_Category_Level_3__r.Name', ' ASI_MFM_Item_Group__c ',' WHERE id = \'' + recordId + '\'')[0];
            for(ASI_CRM_Product_Warehouse_Photo__c obj : (List<ASI_CRM_Product_Warehouse_Photo__c>)queryRecords(PRODUCT_WAREHOSE_PHOTO_FIELD_MAP, '', ' ASI_CRM_Product_Warehouse_Photo__c ', ' WHERE ASI_CRM_Item_Group__c = \'' + recordId + '\' AND (recordtypeId = \'' + ARTWORK_RECORDTYPE_ID + '\' OR recordtypeId = \'' + POSM_PHOTO_RECORDTYPE_ID + '\')')){
                if(obj.recordtypeId == ARTWORK_RECORDTYPE_ID){
                    photoLines.add(obj);
                }else if(obj.recordtypeId == POSM_PHOTO_RECORDTYPE_ID){
                    posmPhotoLines.add(obj);
                }
            }
            if(photoLines.size() > 0)
                hasLine = True;
            
            if(posmPhotoLines.size() > 0)
                hasPOSMLine = True;
        }
        
        return true;
    }
    
    @TestVisible
    Private Static List<sObject> queryRecords(Map<String, Schema.SObjectField> fieldsMap, String additionalFields, String objectName, String whereClause){
        
        String queryStr = 'SELECT ';
        
        queryStr += String.join(new List<String>(fieldsMap.keySet()), ', ');
        
        queryStr += additionalFields;
        
        queryStr += ' FROM ' + objectName + whereClause;
        
        Return database.query(queryStr);
    }
    
    @TestVisible
    Private List<apprivalHistoryClass> getApprovalHisotry(String paymentId){
        
        List<apprivalHistoryClass> ac = new List<apprivalHistoryClass>();
        
        List<ProcessInstanceWorkitem> piwi = new List<ProcessInstanceWorkitem>([Select Actor.Name, ProcessInstanceId, ProcessInstance.CreatedDate, ProcessInstance.createdBy.Name From ProcessInstanceWorkitem Where ProcessInstance.TargetObjectId = : paymentId Order By CreatedDate DESC Limit 1]);
        
        if(piwi.size() > 0){
            
            for(ProcessInstanceStep obj : [Select Actor.Name, StepStatus, ElapsedTimeInMinutes, createdDate From ProcessInstanceStep Where ProcessInstanceId = : piwi[0].ProcessInstanceId ]){
                
                if(obj.StepStatus == 'Started')
                    continue;
                
                apprivalHistoryClass tmp = new apprivalHistoryClass();

                tmp.approver = obj.Actor.Name;
                tmp.approvalStatus = obj.StepStatus == 'Started' ? 'Submitted' : obj.StepStatus == 'Removed' ? 'Recalled' : obj.StepStatus;
                tmp.approvedDate = obj.createdDate.format('yyyy-MM-dd');
                
                ac.add(tmp);
            }
            
            apprivalHistoryClass tmp2 = new apprivalHistoryClass();
            tmp2.approver = piwi[0].ProcessInstance.createdBy.Name;
            tmp2.approvalStatus = 'Submitted';
            tmp2.approvedDate = piwi[0].ProcessInstance.CreatedDate.format('yyyy-MM-dd');
            
            ac.add(tmp2);
            
            Return ac;
            
        }else{
            
            List<ProcessInstanceStep> pis = new List<ProcessInstanceStep>([Select Actor.Name, StepStatus, ElapsedTimeInMinutes, createdDate, ProcessInstanceId From ProcessInstanceStep Where ProcessInstance.TargetObjectId = : paymentId Order By CreatedDate DESC]);
            
            String piId = '';
            
            if(pis.size() > 0){
                
                for(ProcessInstanceStep obj : pis){
                    
                    if(piId != '' && piId != obj.ProcessInstanceId)
                        Break;
                    
                    apprivalHistoryClass tmp = new apprivalHistoryClass();
                    
                    tmp.approver = obj.Actor.Name;
                    tmp.approvalStatus = obj.StepStatus == 'Started' ? 'Submitted' : obj.StepStatus == 'Removed' ? 'Recalled' : obj.StepStatus;
                    tmp.approvedDate = obj.createdDate.format('yyyy-MM-dd');
                    
                    piId = obj.ProcessInstanceId;
                    ac.add(tmp);
                }
                
                Return ac;
            }else{
                
                Return new List<apprivalHistoryClass>();
            }
        }
    }
    
    Public Class apprivalHistoryClass{
        
        Public String approver{Get; Set;}
        Public String approvedDate{Get; Set;}
        Public String approvalStatus{Get; Set;}
    }
}
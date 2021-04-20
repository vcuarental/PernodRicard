/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_SIRUploadController       
 * Test Class:  ASI_CTY_CN_Vendor_SIRControllerTest
 * Description: Vendor Community PO Detail Page Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-09-09       Baymax                  Create AuraEnabled functions
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_SIRUploadController {
    /*
    * Method Name: insertSIR
    * Description: insert or update SIR Info, according to the information entered by the supplier
    * Return Type: ASI_MFM_Stock_In_Request__c
    * Parameter  : String sirInfo, String warehousePhotoId, String itemGroupId
    */
    @AuraEnabled 
    public static ASI_MFM_Stock_In_Request__c insertSIR(String sirInfo, String warehousePhotoId, String itemGroupId){
        System.debug(LoggingLevel.INFO, '*** sirInfo: ' + sirInfo);
        // Convert the parameters passed to the background into SIR objects
        ASI_MFM_Stock_In_Request__c sir = new ASI_MFM_Stock_In_Request__c();
        sir = (ASI_MFM_Stock_In_Request__c)JSON.deserialize(sirInfo, ASI_MFM_Stock_In_Request__c.class);
        sir.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Stock_In_Request__cASI_MFM_CN_Stock_In_Request');

        System.debug(LoggingLevel.INFO, '*** sirold: ' + sir);

        Savepoint sp = Database.setSavepoint();
        try {
            // Save the latest image and delete all other image
            if (warehousePhotoId != null && warehousePhotoId != '') {
                deleteDocuments(warehousePhotoId, itemGroupId);
            }

            upsert sir;
            System.debug(LoggingLevel.INFO, '*** sirnew: ' + sir);

            // Automatically trigger the approval process of SIR
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(sir.Id);
            Approval.ProcessResult result = Approval.process(request);
            System.debug(LoggingLevel.INFO,'Approval Process submit request：'+ result.isSuccess());
            
            ASI_MFM_Stock_In_Request__c resultSir = [SELECT Id, Name, toLabel(ASI_MFM_Status__c), ASI_MFM_TIV_Number__c, ASI_MFM_Delivery_Address__c, 
            ASI_MFM_Lot_Number__c, ASI_MFM_Net_Weight__c, ASI_MFM_Box_Size_M3__c, 
            ASI_MFM_Min_Unit_Price__c, ASI_MFM_Total_Quantity__c, ASI_MFM_Qty_Per_Bag_Box__c, 
            ASI_MFM_Total_Number_Of_Box__c, ASI_Delivery_Date__c, ASI_MFM_PO_Number__c,  
            ASI_MFM_Lot_Quantity__c, ASI_MFM_PO_POSM_Line_Number__c, ASI_MFM_Length__c, ASI_MFM_Width__c, ASI_MFM_Height__c,
            ASI_MFM_Box_Net_Weight__c, ASI_MFM_Total_Qty_Per_Bag_Box__c, ASI_MFM_Qty_Per_Box__c,
            ASI_MFM_Fraction_Qty__c, toLabel(ASI_CTY_CN_Vendor_SIR_Approval_Status__c), 
            (Select Id, StepStatus, Comments, CreatedDate From ProcessSteps 
                WHERE StepStatus = 'Rejected' ORDER BY CreatedDate DESC LIMIT 1) 
            FROM ASI_MFM_Stock_In_Request__c WHERE Id =: sir.Id];
            System.debug(LoggingLevel.INFO, '*** resultSir: ' + resultSir);
            System.debug(LoggingLevel.INFO, '*** Approval_Status: ' + resultSir.ASI_CTY_CN_Vendor_SIR_Approval_Status__c);
            return resultSir;
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** SIR Info Upsert Exception: ' + e);
            Database.rollback(sp);
            return null;
        }
    }

    /*
    * Method Name: insertDocument
    * Description: insert itemgroup image(keep only one picture)
    * Return Type: String
    * Parameter  : String buyerId, String itemGroupId, String fileVal, String fileName, Integer fileSize, String fileType
    */
    @AuraEnabled 
    public static String insertDocument(String buyerId, String itemGroupId, String fileVal, String fileName, Integer fileSize, String fileType){
        System.debug(LoggingLevel.INFO, '*** itemGroupId: ' + itemGroupId);
        System.debug(LoggingLevel.INFO, '*** fileVal: ' + fileVal);
        System.debug(LoggingLevel.INFO, '*** fileName: ' + fileName);

        String returnStr = null;
        Savepoint sp = Database.setSavepoint();
        try {
            ResultWrapper rw = null;
            // If the content of the file is empty, it means that the SIR image has not been modified, and the image will not be updated
            if (fileVal != '') {
                String reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
                ASI_CRM_Product_Warehouse_Photo__c pwp = new ASI_CRM_Product_Warehouse_Photo__c();
                pwp.ASI_CRM_Item_Group__c = itemGroupId;
                pwp.ASI_File_Name__c = fileName;
                pwp.ASI_File_Size__c = fileSize;
                pwp.ASI_File_Extension__c = fileType;
                pwp.ASI_CRM_Photo_Version__c = 1.0;
                pwp.ASI_CRM_Comments__c = 'SIR Item Group Image';
                pwp.RecordTypeId = reocrdTypeId;
                pwp.OwnerId = Id.valueOf(buyerId);
                upsert pwp;

                System.debug(LoggingLevel.INFO, '*** pwp: ' + pwp);

                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = EncodingUtil.base64Decode(fileVal);
                cv.Title = fileName;
                cv.PathOnClient = fileName;
                insert cv;
                
                Id contentDocumentId;
                Id contentVersionId;
                for (ContentVersion contentVir : [select Id, ContentDocumentId from ContentVersion where Id=:cv.Id]) {
                    contentDocumentId = contentVir.ContentDocumentId;
                    contentVersionId = contentVir.Id;
                }
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = contentDocumentId;
                cdl.LinkedEntityId = pwp.Id;
                cdl.ShareType = 'V';
                insert cdl;

                FeedItem attachment = new FeedItem();
                attachment.ParentId = pwp.Id;
                attachment.Visibility = 'AllUsers';
                attachment.RelatedRecordId = contentVersionId;
                insert attachment;
                System.debug(LoggingLevel.INFO, '*** attachment: ' + attachment);

                FeedItem insertedAttachment = [SELECT RelatedRecordId FROM FeedItem WHERE Id=:attachment.Id];
                pwp.ASI_FileID__c = insertedAttachment.RelatedRecordId;
                pwp.ASI_FeedItemID__c = insertedAttachment.Id;
                update pwp;
                System.debug(LoggingLevel.INFO, '*** attachmentNew: ' + attachment);

                Update new ASI_MFM_Item_Group__c(Id = itemGroupId);
                returnStr = String.valueOf(pwp.Id);
            }
            return returnStr;
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** SIR Image Uploaded Exception: ' + e);
            Database.rollback(sp);
            return returnStr;
        }
    }

    /*
    * Method Name: getSIRImage
    * Description: Get SIR image information
    * Return Type: CustomSIRInfo
    * Parameter  : String itemGroupId
    */
    @AuraEnabled 
    public static CustomSIRInfo getSIRImage(String itemGroupId){
        System.debug(LoggingLevel.INFO, '*** itemGroupId: ' + itemGroupId);
        CustomSIRInfo csInfo = new CustomSIRInfo();
        String reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
        List<ASI_CRM_Product_Warehouse_Photo__c> tmpAttachment = [SELECT Id, ASI_CRM_Photo_Version__c, CreatedDate FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                        WHERE ASI_CRM_Item_Group__c = : itemGroupId
                                                                        AND ASI_CRM_Photo_Version__c != NULL
                                                                        AND RecordTypeId = : reocrdTypeId
                                                                        ORDER BY CreatedDate DESC LIMIT 1];
        Id warehousePhotoId;
        if (tmpAttachment != null && tmpAttachment.size() > 0) {
            warehousePhotoId = tmpAttachment[0].Id;
            csInfo.Id = warehousePhotoId;
            set<String> documentIdSet = new set<String>();
            for (ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId
               FROM ContentDocumentLink
               WHERE LinkedEntityId =: warehousePhotoId]) {
                documentIdSet.add(link.ContentDocumentId);
            }

            if (!documentIdSet.isEmpty()) {
                for (ContentDocument link : [SELECT Id, LastModifiedDate, CreatedBy.Name, ContentSize, FileExtension, OwnerId,
                   (SELECT Id, ContentDocumentId, PathOnClient FROM ContentVersions WHERE IsLatest = true)
                   FROM ContentDocument
                   WHERE Id IN :documentIdSet ORDER BY LastModifiedDate ASC]) {
                    if (link.ContentVersions[0] != null) {
                        csInfo.versionId = link.ContentVersions[0].Id;
                        csInfo.Title = link.ContentVersions[0].PathOnClient;
                    }
                    csInfo.Size = link.ContentSize;
                    csInfo.OwnerId = link.OwnerId;
                    csInfo.Type = link.FileExtension;
                    csInfo.LastModifiedDate = link.LastModifiedDate;
                    csInfo.CreatedBy = link.CreatedBy.Name;
                }
            }
        }
        
        System.debug(LoggingLevel.INFO, '*** csInfo: ' + csInfo);
        return csInfo;
    }

    /*
    * Method Name: getDocumentContent
    * Description: Get SIR image content
    * Return Type: String
    * Parameter  : String warehousePhotoId
    */
    @AuraEnabled 
    public static String getDocumentContent(String warehousePhotoId){
        System.debug(LoggingLevel.INFO, '*** warehousePhotoId: ' + warehousePhotoId);
        Id contentDocumentId;
        String result;
        set<String> documentIdSet = new set<String>();
        ContentDocumentLink link = [SELECT Id, LinkedEntityId, ContentDocumentId
           FROM ContentDocumentLink
           WHERE LinkedEntityId =: warehousePhotoId LIMIT 1];
        if (link != null) {
            contentDocumentId = link.ContentDocumentId;
            ContentVersion cv = [SELECT Id, ContentDocumentId, FileExtension, VersionData
                FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId =:contentDocumentId];
            String content = EncodingUtil.base64Encode(cv.VersionData);
            result = 'data:image/' + cv.FileExtension + ';base64,' + content;
        }
        return result;
    }

    /*
    * Method Name: recallSIR
    * Description: Recall SIR And OverWrite SIR Info
    * Return Type: String
    * Parameter  : String sirId
    */
    @AuraEnabled 
    public static ResultWrapper recallSIR(String sirId){
        System.debug(LoggingLevel.INFO, '*** sirId: ' + sirId);
        ResultWrapper rw = null;
        try {
            //Get Process Instance Work Items
            ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :sirId
                                                     AND ProcessInstance.Status = 'Pending']; 
            System.debug(LoggingLevel.INFO, '*** piWorkItems: ' + piWorkItems);
            if(piWorkItems.size() > 0){
                //Create Process Work Item Request
                Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                pwiRequest.setAction('Removed');
                pwiRequest.setWorkItemId(piWorkItems[0].Id);
                Approval.ProcessResult result = Approval.process(pwiRequest);
                rw = new ResultWrapper(1, 'SIR Recall Success');
            } else {
                rw = new ResultWrapper(0, 'SIR Recall Not Found Approval Process Instance');
            }
        } catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** SIR Recall Exception: ' + e.getMessage());
            rw = new ResultWrapper(0, e.getMessage()+':'+e.getStackTraceString());
        }
        return rw;
    }

    /*
    * Method Name: deleteDocument
    * Description: delete one SIR image
    * Return Type: ResultWrapper
    * Parameter  : String warehousePhotoId
    */
    @AuraEnabled 
    public static ResultWrapper deleteDocument(String warehousePhotoId) {
        System.debug(LoggingLevel.INFO, '*** warehousePhotoId: ' + warehousePhotoId);
        ResultWrapper rw = null;
        try {
            ASI_CRM_Product_Warehouse_Photo__c record = [SELECT Id FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                WHERE Id =: warehousePhotoId];

            delete record;
            rw = new ResultWrapper(1, 'SIR Image Delete Success');
        } catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** SIR Image Delete Exception: ' + e.getMessage());
            rw = new ResultWrapper(0, e.getMessage()+':'+e.getStackTraceString());
        }
        return rw;
    }

    /*
    * Method Name: deleteDocuments
    * Description: batch delete SIR image
    * Return Type: ResultWrapper
    * Parameter  : String warehousePhotoId, String itemGroupId
    */
    @AuraEnabled 
    public static ResultWrapper deleteDocuments(String warehousePhotoId, String itemGroupId) {
        System.debug(LoggingLevel.INFO, '*** warehousePhotoId: ' + warehousePhotoId);
        System.debug(LoggingLevel.INFO, '*** itemGroupId: ' + itemGroupId);
        ResultWrapper rw = null;
        Savepoint sp = Database.setSavepoint();
        try {
            String reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
            List<ASI_CRM_Product_Warehouse_Photo__c> records = [SELECT Id, ASI_CRM_Item_Group__c FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                WHERE (Id != :warehousePhotoId) 
                                                                AND (ASI_CRM_Item_Group__c = :itemGroupId)
                                                                AND (RecordTypeId = :reocrdTypeId)];            
            System.debug(LoggingLevel.INFO, '*** records: ' + records);
            if (records.size() > 0) {
                delete records;
                rw = new ResultWrapper(1, 'SIR Image Batch Delete Success');
            }
        } catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** SIR Image Batch Delete Exception: ' + e.getMessage());
            rw = new ResultWrapper(0, e.getMessage()+':'+e.getStackTraceString());
            Database.rollback(sp);
        }
        return rw;
    }

    /*
    * Method Name: getPoInfo
    * Description: get PO Detail Info
    * Return Type: CustomPO
    * Parameter  : String contractId
    */
    @AuraEnabled 
    public static CustomPO getPoInfo(String contractId) {
        System.debug(LoggingLevel.INFO, '*** contractId: ' + contractId);
        CustomPO cpo = new CustomPO();
        ASI_MFM_PO__c po = [SELECT Id, Name, toLabel(ASI_MFM_Status__c), ASI_CTY_CN_Vendor_Fill_Sir__c,ASI_MFM_PO_Start_Date__c, ASI_MFM_PO_End_Date__c, ASI_MFM_PO_Type__c,
         ASI_MFM_CN_PO_Amount_RMB__c, ASI_MFM_eMarket_Buyer__r.Name, ASI_MFM_eMarket_Buyer__c, ASI_MFM_Plan__r.Name, ASI_CTY_CN_Vendor_Purchase_Request_Line__r.Name,
         ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Name, ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Merge_Quotation__c,
         ASI_CTY_CN_Vendor_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Merge_Quotation__r.Name, ASI_MFM_Supplier_Name__c, ASI_CTY_CN_Vendor_Purchase_Request_Line__c,
         ASI_MFM_PO_Final_Date__c, ASI_MFM_Total_Paid_Amount__c, ASI_MFM_Remarks__c, RecordType.Name, ASI_CTY_CN_Vendor_Sample_Price__c, ASI_CTY_CN_Vendor_Model_Price__c,
         (SELECT Id, Name, toLabel(ASI_MFM_Status__c), ASI_MFM_TIV_Number__c, ASI_MFM_Delivery_Address__c, 
            ASI_MFM_Lot_Number__c, ASI_MFM_Net_Weight__c, ASI_MFM_Box_Size_M3__c, 
            ASI_MFM_Min_Unit_Price__c, ASI_MFM_Total_Quantity__c, ASI_MFM_Qty_Per_Bag_Box__c, 
            ASI_MFM_Total_Number_Of_Box__c, ASI_Delivery_Date__c, ASI_MFM_PO_Number__c,  
            ASI_MFM_Lot_Quantity__c, ASI_MFM_PO_POSM_Line_Number__c, ASI_MFM_Length__c, ASI_MFM_Width__c, ASI_MFM_Height__c,
            ASI_MFM_Box_Net_Weight__c, ASI_MFM_Total_Qty_Per_Bag_Box__c, ASI_MFM_Qty_Per_Box__c,
            ASI_MFM_Fraction_Qty__c, toLabel(ASI_CTY_CN_Vendor_SIR_Approval_Status__c) FROM Stock_In_Requests__r), 
         (SELECT ASI_MFM_Item_Group_Code__c, ASI_MFM_Item_Group__r.Name, 
            ASI_MFM_Item_Group__r.ASI_MFM_Item_Group_Remark__c, ASI_MFM_Item_Group__r.ASI_MFM_Period_of_Validity__c, 
            ASI_MFM_Item_Group_Chinese_Name__c, ASI_MFM_Minimum_Order_Qty__c, 
            ASI_MFM_Unit_Price__c, ASI_MFM_Total_Price_w_VAT__c, ASI_MFM_Quantity__c, ASI_MFM_Contact_Person__c, 
            ASI_MFM_Phone_Number__c, ASI_MFM_Detail_Address__c, ASI_MFM_Delivery_Address_Warehouse__r.Name,
            ASI_MFM_Delivery_Address_Warehouse__r.ASI_FOC_Warehouse_Code__c, ASI_MFM_City__c, ASI_MFM_Province__c, 
            ASI_MFM_Delivery_Address_Outlet__c, ASI_MFM_Delivery_Address_Outlet__r.Name, ASI_MFM_Email__c FROM PO_POSM_Lines__r),
         (SELECT Id, Name, ASI_MFM_PO_Remark__c, ASI_MFM_Quantity__c, ASI_MFM_Unit_Price__c, ASI_MFM_Amount__c, ASI_MFM_CN_Paid_Amount__c,
         ASI_MFM_Remaining_Balance__c, ASI_MFM_List_Item_Description__c FROM PO_Line_Items__r)
         FROM ASI_MFM_PO__c WHERE Id = :contractId];

         if (po != null) {
            List<ASI_CRM_Quotation__c> q = [SELECT Id, Name, ASI_CTY_CN_Vendor_Quotation__c, ASI_CTY_CN_Vendor_Quotation__r.Name FROM ASI_CRM_Quotation__c 
            WHERE ASI_CTY_CN_Vendor_Supplier__c = :po.ASI_MFM_Supplier_Name__c AND ASI_CTY_CN_Purchase_Request_Line__c = :po.ASI_CTY_CN_Vendor_Purchase_Request_Line__c
            AND RecordTypeId = : ASI_CTY_CN_Vendor_Util.quotationRecordId LIMIT 1];

            if (q != null && q.size() > 0) {
                cpo.q = q.get(0);
            }
         }
 
         Set<Id> sirIds = new Set<Id>();
         List<ASI_MFM_Stock_In_Request__c> sirs = po.Stock_In_Requests__r;
         System.debug(LoggingLevel.INFO, '*** sirs: ' + sirs);
         if (sirs != null && sirs.size() > 0) {
            for (ASI_MFM_Stock_In_Request__c sir : sirs) {
                sirIds.add(sir.Id);
            }
         }

        List<ASI_MFM_Stock_In_Request__c> sirsNew = [SELECT s.Id, (Select Id,
            StepStatus, Comments, CreatedDate From ProcessSteps 
                WHERE StepStatus = 'Rejected' ORDER BY CreatedDate DESC LIMIT 1) 
                FROM ASI_MFM_Stock_In_Request__c s WHERE Id IN :sirIds];
        
        cpo.po = po;
        cpo.sirs = sirsNew;
        return cpo;
    }

    public class CustomSIRInfo {
        @AuraEnabled 
        public String Id;
        @AuraEnabled 
        public String versionId;
        @AuraEnabled 
        public String Title;
        @AuraEnabled 
        public Integer Size;
        @AuraEnabled 
        public String OwnerId;
        @AuraEnabled 
        public String Type;
        @AuraEnabled 
        public DateTime LastModifiedDate;
        @AuraEnabled 
        public String CreatedBy;
        @AuraEnabled 
        public String Content;
    }

    public class CustomPO {
        @AuraEnabled 
        public ASI_MFM_PO__c po;
        @AuraEnabled 
        public List<ASI_MFM_Stock_In_Request__c> sirs;
        @AuraEnabled
        public ASI_CRM_Quotation__c q;
    }

    public class ResultWrapper {
        @AuraEnabled
        public Integer state;
        @AuraEnabled
        public String message;

        public ResultWrapper(Integer state, String message) {
            this.state = state;
            this.message = message;
        }
    }
}
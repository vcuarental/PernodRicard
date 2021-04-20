public with sharing class ASI_CTY_CN_WS_ProductPhotoDisplayCtrl {
    public List<ASI_CRM_Product_Warehouse_Photo__c> attachmentList {Get; Set;}
    public List<ASI_CRM_Product_Warehouse_Photo__c> deleteSeqList {Get; Set;}
    public Boolean isView {Get; Set;}
    public Id recordId;
    public List<SelectOption> sequences { get; set; }


    public ASI_CTY_CN_WS_ProductPhotoDisplayCtrl(ApexPages.StandardController ctrl) {
        recordId = ctrl.getId();

        String sObjType = recordId.getSObjectType().getDescribe().getName();

        if (sObjType == 'ASI_MFM_Item_Group__c') {
            isView = true;
            attachmentList = new List<ASI_CRM_Product_Warehouse_Photo__c>();
            sequences = new List<SelectOption>();
            List<ASI_CRM_Product_Warehouse_Photo__c> tmpAttachmentList = [SELECT Id
                                                                                , ASI_Name__c
                                                                                , ASI_Preview__c
                                                                                , ASI_CRM_Photo_Category__c
                                                                                , ASI_CRM_Photo_Version__c
                                                                                , ASI_CRM_Comments__c
                                                                                , ASI_CRM_Preview_URL__c
                                                                                , ASI_Image_URL__c
                                                                                , ASI_FileID__c
                                                                                , ASI_File_Extension__c
                                                                                , ASI_CTY_CN_WS_Premium_Display_Seq__c
                                                                                FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                                WHERE ASI_CRM_Item_Group__c = : recordId
                                                                                  AND ASI_CRM_Photo_Version__c != NULL
                                                                                  AND RecordType.DeveloperName = 'ASI_CRM_CN_Product_Warehouse_Photo' //'ASI_CRM_CN_Product_Warehouse_Photo'
                                                                             ORDER BY ASI_CTY_CN_WS_Premium_Display_Seq__c ASC
                                                                                    , ASI_CRM_Photo_Category__c ASC
                                                                                    , ASI_CRM_Photo_Version__c DESC
                                                                                    , ASI_Name__c ASC
                                                                             ];

            Map<String, ASI_CRM_Product_Warehouse_Photo__c> tmpMap = new Map<String, ASI_CRM_Product_Warehouse_Photo__c>();
            for (ASI_CRM_Product_Warehouse_Photo__c obj : tmpAttachmentList) {
                if (!tmpMap.containsKey(obj.ASI_CRM_Photo_Category__c)) {
                    tmpMap.put(obj.ASI_CRM_Photo_Category__c, obj);
                } else if (tmpMap.containsKey(obj.ASI_CRM_Photo_Category__c)) {
                    if (tmpMap.get(obj.ASI_CRM_Photo_Category__c).ASI_CRM_Photo_Version__c < obj.ASI_CRM_Photo_Version__c) {
                        tmpMap.put(obj.ASI_CRM_Photo_Category__c, obj);
                    } else if (tmpMap.get(obj.ASI_CRM_Photo_Category__c).ASI_CRM_Photo_Version__c == obj.ASI_CRM_Photo_Version__c) {
                        tmpMap.put('' + obj.ASI_CRM_Photo_Category__c + obj.Id, obj);
                    } 
                }
            }
            attachmentList = tmpMap.values();
            deleteSeqList = new List<ASI_CRM_Product_Warehouse_Photo__c>();
            for (ASI_CRM_Product_Warehouse_Photo__c obj : tmpAttachmentList) {
                if (tmpMap.containsKey(obj.ASI_CRM_Photo_Category__c) 
                    && obj.ASI_CTY_CN_WS_Premium_Display_Seq__c != null 
                    && tmpMap.get(obj.ASI_CRM_Photo_Category__c).ASI_CRM_Photo_Version__c != obj.ASI_CRM_Photo_Version__c) {
                    obj.ASI_CTY_CN_WS_Premium_Display_Seq__c = null;
                    deleteSeqList.add(obj);
                }
            }
            if (attachmentList.size() == 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please attach photos first'));
            }
            SetSequnenceList(attachmentList.size());
        }
    }

    private void SetSequnenceList(Integer size){
        sequences.add(new SelectOption('', '---Not Display---'));
        for (Integer i = 0 ; i < size; i++) {
            //max sequence is 5
            if (i >= 5){
                return;
            }
            sequences.add(new SelectOption(String.valueOf(i+1), String.valueOf(i+1)));
        }
    }

    public void editSeq(){
        isView = false;
    }

    public PageReference saveSeq(){
        System.debug(LoggingLevel.INFO, '*** attachmentList: ' + attachmentList);
        for (ASI_CRM_Product_Warehouse_Photo__c photo : attachmentList) {
            if (String.isBlank(photo.ASI_CTY_CN_WS_Premium_Display_Seq__c)) {
                continue;
            }
            for (ASI_CRM_Product_Warehouse_Photo__c photo1 : attachmentList) {
                if (String.isNotBlank(photo1.ASI_CTY_CN_WS_Premium_Display_Seq__c) && photo.Id != photo1.Id && photo.ASI_CTY_CN_WS_Premium_Display_Seq__c == photo1.ASI_CTY_CN_WS_Premium_Display_Seq__c) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'The sequence is repeated'));
                    return null;
                }
            }
        }
        Savepoint sp = Database.setSavepoint();
        attachmentList.addAll(deleteSeqList);
        try{
            update attachmentList;
            PageReference ref = new PageReference('/' + recordId);
            ref.setRedirect(true);
            return ref;
        }catch (Exception ex) {
            System.debug(LoggingLevel.INFO, '*** ex: ' + ex);
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }
    }


}
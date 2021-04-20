public with sharing class ASI_CRM_CN_ProductWarehouse_ListCTRL {
    
    Public List<ASI_CRM_Product_Warehouse_Photo__c> attachmentList{Get; Set;}
    Public List<ASI_CRM_SKU_Photo__c> attachmentList_SKU{Get; Set;}
    //20180719 Introv
    Private Static Final Map<String, String> MAP_RECORDTYPE_BY_PAGE_NAME = new Map<String, String>{
        	'asi_crm_cn_productwarehouse_listpage' => 'ASI_CRM_CN_Product_Warehouse_Photo'
            , 'asi_mfm_cn_posm_final_artwork_listpage' => 'ASI_MFM_CN_POSM_Final_Artwork_Photo'
            , 'asi_mfm_cn_posm_itemgroup_photolistpage' => 'ASI_MFM_CN_POSM_Photo'
            , 'asi_mfm_cn_po_photolistpage' => 'ASI_MFM_CN_PO_Photo'};
    //Public Map<Id, String> mapFile{Get; Set;}
    
    Public ASI_CRM_CN_ProductWarehouse_ListCTRL(ApexPages.StandardController controller){
        
        Id headerId = controller.getId();
        
        String sObjType = headerId.getSObjectType().getDescribe().getName();    
        
        if(sObjType == 'ASI_MFM_Item_Group__c'){
            
            //Set<Id> fileIdSet = new Set<Id>();
            //mapFile = new Map<Id, String>();
            attachmentList = new List<ASI_CRM_Product_Warehouse_Photo__c>();
            
            //20180719 Introv
            String pageName = ApexPages.currentPage().getURL();
            String recordTypeName = '';
            
            if(String.isNotBlank(pageName)){
                
                pageName = pageName.split('/apex/')[1];
                pageName = pageName.split('\\?')[0];
                
                if(String.isNotBlank(pageName) && MAP_RECORDTYPE_BY_PAGE_NAME.containsKey(pageName.toLowerCase())){
                    recordTypeName = MAP_RECORDTYPE_BY_PAGE_NAME.get(pageName.toLowerCase());
                }
            }
            
            if(recordTypeName == 'ASI_CRM_CN_Product_Warehouse_Photo'){
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
                                                                              FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                              WHERE ASI_CRM_Item_Group__c = : headerId
                                                                              AND ASI_CRM_Photo_Version__c != NULL
                                                                              AND RecordType.DeveloperName = : recordTypeName //'ASI_CRM_CN_Product_Warehouse_Photo'
                                                                              ORDER BY ASI_CRM_Photo_Category__c ASC
                                                                              , ASI_CRM_Photo_Version__c DESC
                                                                              , ASI_Name__c ASC
                                                                             ];
                
                
                /*for(ASI_CRM_Product_Warehouse_Photo__c obj : tmpAttachmentList){
                    fileIdSet.add(obj.ASI_FileID__c);
                }
                
                List<ContentVersion> fileList = new List<ContentVersion>([SELECT VersionData FROM ContentVersion WHERE ID IN : fileIdSet]);
                
                for(ContentVersion obj : fileList){
                    
                    String data = EncodingUtil.base64Encode(obj.VersionData);
                    
                    mapFile.put(obj.id, data);
                }*/
                
                Map<String, ASI_CRM_Product_Warehouse_Photo__c> tmpMap = new Map<String, ASI_CRM_Product_Warehouse_Photo__c>();
                for(ASI_CRM_Product_Warehouse_Photo__c obj : tmpAttachmentList){
                    
                    if(!tmpMap.containsKey(obj.ASI_CRM_Photo_Category__c)){
                        
                        tmpMap.put(obj.ASI_CRM_Photo_Category__c, obj);
                    }else if(tmpMap.containsKey(obj.ASI_CRM_Photo_Category__c)){
                        
                        if(tmpMap.get(obj.ASI_CRM_Photo_Category__c).ASI_CRM_Photo_Version__c < obj.ASI_CRM_Photo_Version__c){
                            tmpMap.put(obj.ASI_CRM_Photo_Category__c, obj);
                        }else if(tmpMap.get(obj.ASI_CRM_Photo_Category__c).ASI_CRM_Photo_Version__c == obj.ASI_CRM_Photo_Version__c){
                            tmpMap.put('' + obj.ASI_CRM_Photo_Category__c + obj.Id, obj);
                        }
                    }
                }
                attachmentList = tmpMap.values();
                
            }else{
                
                attachmentList = [SELECT Id
                                  , ASI_Name__c
                                  , ASI_Preview__c
                                  , ASI_CRM_Photo_Category__c
                                  , ASI_CRM_Photo_Version__c
                                  , ASI_CRM_Comments__c
                                  , ASI_CRM_Preview_URL__c
                                  , ASI_Image_URL__c
                                  , ASI_FileID__c
                                  , ASI_File_Extension__c
                                  FROM ASI_CRM_Product_Warehouse_Photo__c
                                  WHERE ASI_CRM_Item_Group__c = : headerId
                                  AND RecordType.DeveloperName = : recordTypeName //'ASI_CRM_CN_Product_Warehouse_Photo'
                                  ORDER BY createdDate DESC
                                  LIMIT 20
                                 ];
            }
            
        }else if(sObjType == 'ASI_MFM_SKU_Code__c'){
            attachmentList_SKU = new List<ASI_CRM_SKU_Photo__c>([SELECT Id
                                                                 , ASI_CRM_Attachment__c
                                                                 , ASI_CRM_Attachment__r.ASI_Name__c
                                                                 , ASI_CRM_Attachment__r.ASI_Preview__c
                                                                 , ASI_CRM_Attachment__r.ASI_CRM_Photo_Category__c
                                                                 , ASI_CRM_Attachment__r.ASI_CRM_Photo_Version__c
                                                                 , ASI_CRM_Attachment__r.ASI_CRM_Comments__c
                                                                 , ASI_CRM_Attachment__r.ASI_CRM_Preview_URL__c
                                                                 , ASI_CRM_Attachment__r.ASI_Image_URL__c
                                                                 , ASI_CRM_Attachment__r.ASI_FileID__c
                                                                 , ASI_CRM_Attachment__r.ASI_File_Extension__c
                                                                 FROM ASI_CRM_SKU_Photo__c
                                                                 WHERE ASI_CRM_SKU__c = : headerId
                                                                 ORDER BY ASI_CRM_Attachment__r.ASI_CRM_Photo_Category__c ASC
                                                                 , ASI_CRM_Photo_Version__c DESC
                                                                 , ASI_CRM_Attachment__r.ASI_Name__c ASC
                                                                ]);
        }else if(sObjType == 'ASI_MFM_PO__c'){
            attachmentList = [SELECT Id
                              , ASI_Name__c
                              , ASI_Preview__c
                              , ASI_CRM_Photo_Category__c, ASI_MFM_Document__c, ASI_MFM_Latest_Version__c, ASI_MFM_Final_Spot_Plan_Amount__c 
                              , ASI_CRM_Photo_Version__c
                              , ASI_CRM_Comments__c
                              , ASI_CRM_Preview_URL__c
                              , ASI_Image_URL__c
                              , ASI_FileID__c
                              , ASI_File_Extension__c
                              FROM ASI_CRM_Product_Warehouse_Photo__c
                              WHERE ASI_MFM_PO__c = : headerId
                              	AND RecordType.DeveloperName = 'ASI_MFM_CN_PO_Photo'
                              ORDER BY createdDate DESC
                             ];
        }
    }
}
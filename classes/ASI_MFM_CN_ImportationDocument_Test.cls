@isTest
public class ASI_MFM_CN_ImportationDocument_Test {

    Static List<ASI_CRM_Fix_Approval_Route__c> tmpFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
    
    Static testmethod void ASI_MFM_CN_ImportationDocNoticCtrl_test(){
        
        ASI_MFM_CN_ImportationDocNoticCtrl con = new ASI_MFM_CN_ImportationDocNoticCtrl();
        con.redirect();
    }
    
    Static testmethod void ASI_MFM_CN_ImportationDocRedirect_Ctrl_test(){
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approver_2__c = userinfo.getUserId(), ASI_CRM_Sys_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Type__c = 'Importation Document'));
        
        insert tmpFixRoute;
        
        
        
        ASI_MFM_Importation_Document__c impdoc = new ASI_MFM_Importation_Document__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Importation_Document__cASI_MFM_CN_Importation_Document')
                                                                                     , ASI_MFM_Status__c = 'Draft'
                                                                                    );
        Insert impdoc;
        
        ApexPages.StandardController scon = new ApexPages.StandardController(impdoc);
        ASI_MFM_CN_ImportationDocRedirect_Ctrl con = new ASI_MFM_CN_ImportationDocRedirect_Ctrl(scon);
        
        con.redirect();
        
        ASI_MFM_Importation_Document__c impdoc2 = new ASI_MFM_Importation_Document__c();
        //Insert impdoc2;
        
        ApexPages.StandardController scon2 = new ApexPages.StandardController(impdoc2);
        ASI_MFM_CN_ImportationDocRedirect_Ctrl con2 = new ASI_MFM_CN_ImportationDocRedirect_Ctrl(scon2);
        
        con2.redirect();
        
        Update impdoc;
        
        ASI_MFM_CN_ImportationDoc_TriggerCls.setApprover(impdoc, tmpFixRoute[0]);
        ASI_MFM_CN_ImportationDoc_TriggerCls.setApproverToNull(impdoc);
    }
    
    Static testmethod void ASI_MFM_CN_ImportationDoc_TriggerCls_test(){
        ASI_CRM_Region__c oTmpRegion = new ASI_CRM_Region__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'),Name='Test Region');
        insert oTmpRegion;

        ASI_MFM_Importation_Document__c impdoc = new ASI_MFM_Importation_Document__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Importation_Document__cASI_MFM_CN_Importation_Document')
                                                                                     , ASI_MFM_Status__c = 'Draft', ASI_MFM_Region__c = oTmpRegion.Id, ASI_MFM_Purpose__c = 'A'
                                                                                    );
        Insert impdoc;
        
        ASI_MFM_Importation_Document__c oNewImpDoc = [SELECT Id, ASI_MFM_Region__r.Name FROM ASI_MFM_Importation_Document__c WHERE ID = :impdoc.Id LIMIT 1];
        string sRegion = oNewImpDoc.ASI_MFM_Region__r.Name;
        
        ASI_CRM_Fix_Approval_Route__c oFixRoute_Default = new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approver_2__c = userinfo.getUserId(), ASI_CRM_Sys_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Region_Area_Channel__c = sRegion, ASI_CRM_CN_Type__c = 'Importation Document');
        ASI_CRM_Fix_Approval_Route__c oFixRoute_A = new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approver_2__c = userinfo.getUserId(), ASI_CRM_Sys_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Region_Area_Channel__c = sRegion, ASI_CRM_Commercial_Team__c = 'A', ASI_CRM_CN_Type__c = 'Importation Document');
        ASI_CRM_Fix_Approval_Route__c oFixRoute_B = new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approver_2__c = userinfo.getUserId(), ASI_CRM_Sys_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Region_Area_Channel__c = sRegion, ASI_CRM_Commercial_Team__c = 'B', ASI_CRM_CN_Type__c = 'Importation Document');
        ASI_CRM_Fix_Approval_Route__c oFixRoute_C = new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approver_2__c = userinfo.getUserId(), ASI_CRM_Sys_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Region_Area_Channel__c = sRegion, ASI_CRM_Commercial_Team__c = 'C', ASI_CRM_CN_Type__c = 'Importation Document');
        
        tmpFixRoute.add(oFixRoute_Default);
        tmpFixRoute.add(oFixRoute_A);
        tmpFixRoute.add(oFixRoute_B);
        tmpFixRoute.add(oFixRoute_C);
        
        insert tmpFixRoute;
        
        impdoc.ASI_MFM_Purpose__c = 'B';
        update impdoc;
        
        impdoc.ASI_MFM_Purpose__c = 'A';
        update impdoc;
    }
    
    Static testmethod void ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl_test(){
        
        List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        insert tmpItemGroup;
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        insert tmpSku;
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approver_2__c = userinfo.getUserId(), ASI_CRM_Sys_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Type__c = 'Importation Document'));
        
        insert tmpFixRoute;
        
        ASI_MFM_Importation_Document__c impdoc = new ASI_MFM_Importation_Document__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Importation_Document__cASI_MFM_CN_Importation_Document')
                                                                                     , ASI_MFM_Status__c = 'Draft'
                                                                                    );
        Insert impdoc;
        
        List<ASI_MFM_Importation_Document_Detail__c> impdocLineList = new List<ASI_MFM_Importation_Document_Detail__c>();
        
        impdocLineList.add(new ASI_MFM_Importation_Document_Detail__c(ASI_MFM_Remarks__c = 'test'
                                                                      , ASI_MFM_SKU_Code__c = tmpsku.Id
                                                                      , ASI_MFM_Document_Type__c = 'test'
                                                                      , ASI_MFM_Required_Documents_Year__c = 'test'
                                                                      , ASI_MFM_Contract_Number__c = 'test'
                                                                      , ASI_MFM_Use_of_Document__c = 'test'
                                                                      , ASI_MFM_Possible_to_Replace__c = 'test'
                                                                      , ASI_MFM_Importation_Document__c = impdoc.id
                                                                      , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail') 
                                                                      , ASI_MFM_Gov_Proof__c = 'Test'));
        
        Insert impdocLineList;
        
        test.setCurrentPage(new pageReference('/apex/ASI_MFM_CN_ImportationDoc_ManageAll_Page?id=' + impdoc.id));
        ApexPages.StandardSetController scon = new ApexPages.StandardSetController(new List<ASI_MFM_Importation_Document_Detail__c>());
        ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl con = new ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl(scon);
        
        ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.getAllSKU();
        ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine(impdoc.id);
        
        List<ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine> upsertList = new List<ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine>();
        List<ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine> deleteList = new List<ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine>();
        
        ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine tmp = new ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine();
        ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine tmp2 = new ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine();
        
        tmp.skuId = tmpSku.id;
        tmp.docType = 'test';
        tmp.docYear = 'test';
        tmp.contractNum = 'test';
        tmp.useOfDoc = 'test';
        tmp.possibleReplace = 'test';
        tmp.remark = 'test';
        tmp.isDelete = false;
        
        upsertList.add(tmp);
        
        tmp2.skuId = tmpSku.id;
        tmp2.lineId = impdocLineList[0].id;
        tmp2.docType = 'test';
        tmp2.docYear = 'test';
        tmp2.contractNum = 'test';
        tmp2.useOfDoc = 'test';
        tmp2.possibleReplace = 'test';
        tmp2.remark = 'test';
        tmp2.isDelete = true;
        
        deleteList.add(tmp2);
        
        ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.documentLine(impdoc.id);
        ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl.saveDocumentLine(upsertList, deleteList, impdoc.id);
    }
    
    Static testmethod void ASI_MFM_CN_ImportationDoc_PDF_Ctrller_test(){
        
        List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = userinfo.getUserId()
                                                  ));
        insert tmpItemGroup;
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        insert tmpSku;
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route'), ASI_CRM_CN_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Approver_2__c = userinfo.getUserId(), ASI_CRM_Sys_Approver_1__c = userinfo.getUserId(), ASI_CRM_CN_Type__c = 'Importation Document'));
        
        insert tmpFixRoute;
        
        ASI_MFM_Importation_Document__c impdoc = new ASI_MFM_Importation_Document__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Importation_Document__cASI_MFM_CN_Importation_Document')
                                                                                     , ASI_MFM_Status__c = 'Draft'
                                                                                     , ASI_MFM_Request_Purpose__c = 'ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_DetailASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail'
                                                                                    );
        Insert impdoc;
        
        List<ASI_MFM_Importation_Document_Detail__c> impdocLineList = new List<ASI_MFM_Importation_Document_Detail__c>();
        
        impdocLineList.add(new ASI_MFM_Importation_Document_Detail__c(ASI_MFM_Remarks__c = 'ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_DetailASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail'
                                                                      , ASI_MFM_SKU_Code__c = tmpsku.Id
                                                                      , ASI_MFM_Document_Type__c = 'ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_DetailASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail'
                                                                      , ASI_MFM_Required_Documents_Year__c = 'ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_DetailASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail'
                                                                      , ASI_MFM_Contract_Number__c = 'ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_DetailASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail'
                                                                      , ASI_MFM_Use_of_Document__c = 'ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_DetailASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail'
                                                                      , ASI_MFM_Possible_to_Replace__c = 'ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_DetailASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail'
                                                                      , ASI_MFM_Importation_Document__c = impdoc.id
                                                                      , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail') 
                                                                      , ASI_MFM_Gov_Proof__c = 'ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_DetailASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail'));
        
        Insert impdocLineList;
        
        ApexPages.StandardController scon = new ApexPages.StandardController(impdoc);
        ASI_MFM_CN_ImportationDoc_PDF_Ctrller con = new ASI_MFM_CN_ImportationDoc_PDF_Ctrller(scon);
        ASI_MFM_CN_ImportationDoc_PDF_Ctrller tmp = new ASI_MFM_CN_ImportationDoc_PDF_Ctrller();
        con.dummyVar = false;
        con.headerId = impdoc.id;
        con.init();
    }
}
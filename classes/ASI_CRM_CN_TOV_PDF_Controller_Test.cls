@IsTest
public class ASI_CRM_CN_TOV_PDF_Controller_Test {

	static testMethod void testTOVPDF() {

        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'teamLea', Email='teamLeader@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='teamLeader', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = p1.Id, IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='testLeader@wholesaler.com',
                            CompanyName = 'Pernod Ricard China',  BypassTriggers__c = 'Autofollow_User_InsertUpdate');
        insert u;
       
        System.runAs(u) {

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
                                                                 , ASI_CRM_Location_Owner_JDE__c = 'Testing 666'
                                                                 , ASI_FOC_Brand_Director_Approval_Required__c = True
                                                                );
            
            Insert tmpSku;
            //新增税率
            ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
            insert rateConf;

            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
            insert region;        
            Id strRTId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_NPL_CN_Normal_Goods_Warehouse');
            ASI_FOC_Warehouse__c G_WH = new ASI_FOC_Warehouse__c(ASI_FOC_Warehouse_Code__c='XXX999SH', ASI_MFM_Location_Code__c='SH', Recordtypeid=strRTId,ASI_FOC_Warehouse_Type__c='Region Warehouse',ASI_FOC_Region__c = region.Id);
            insert G_WH;
            
            List<ASI_CRM_Dynamic_Approval_Route__c> LDynApproval = new List<ASI_CRM_Dynamic_Approval_Route__c >();
            LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'Free Goods Request',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
            LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'POSM',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
            LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'HQ STK4 Order',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
            LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'Central STK4 Order',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
            LDynApproval.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Approval_Limit__c=0,ASI_CRM_End_of_Dynamic_Route__c=true,ASI_CRM_Type__c = 'MKT STK4 Order',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')));
            insert LDynApproval ;
            
            Id currentUserId = UserInfo.getUserId(); 
            List<ASI_CRM_Fix_Approval_Route__c> listFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
            listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Type__c='POSM', ASI_CRM_CN_Region_Area_Channel__c='TEST', ownerid=currentUserId,recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')));
            listFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c=currentUserId, ASI_CRM_CN_Type__c='POSM', ownerid=currentUserId,recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')));
            insert listFixRoute;
            
            // user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
            ASI_FOC_Route_Type__c rt = new ASI_FOC_Route_Type__c(ASI_FOC_Role_Name__c=u.userRole.developerName);
            insert rt;
            ASI_FOC_Route_Criteria__c rc = new ASI_FOC_Route_Criteria__c(ASI_FOC_Route_Type__c=rt.id, 
                                                                         ASI_FOC_Threshold__c=0, ASI_FOC_Approver__c=userInfo.getUserId());
            insert rc;  
            ASI_FOC_PO__c po = new ASI_FOC_PO__c(name='test', ASI_FOC_PO_Final_Amount__c=200, ASI_FOC_Date__c=date.today());
            insert po;
            
            final Integer numOfSKU = 5;
            List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
            ASI_FOC_SKUGenerator skuGen = new ASI_FOC_SKUGenerator();
            for (Integer i = 0; i < numOfSKU; i++) {
                skuList.add(skuGen.generateSKU(null));   
            }
            insert skuList;
            
            test.startTest();
            ASI_FOC_Free_Goods_Request__c fr = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P',ASI_FOC_Request_Status__c='In Progress',ASI_MFM_FromWarehouse__c=G_WH.Id,ASI_FOC_Purpose__c='MKT STK4 Order',ASI_MFM_ForPOSMCart__c =true, ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_POSM_Read_Only'));
            insert fr;
            ASI_FOC_Free_Goods_Request__c fr2 = new ASI_FOC_Free_Goods_Request__c(ASI_FOC_Request_Type__c='Consumer A&P',ASI_FOC_Request_Status__c='In Progress',ASI_MFM_FromWarehouse__c=G_WH.Id,ASI_FOC_Purpose__c='MKT STK4 Order',ASI_MFM_ForPOSMCart__c =true, ASI_FOC_PO__c=po.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Free_Goods_Request__cASI_FOC_CN_Free_Goods_Request_Read_Only'));
            insert fr2;
            
            List<ASI_FOC_Request_Item__c> riList =new List<ASI_FOC_Request_Item__c>();
            
            ASI_FOC_Request_Item__c ri = new ASI_FOC_Request_Item__c(ASI_FOC_Request_Order__c=fr.id, ASI_FOC_SKU__c = skuList[0].id, ASI_FOC_Free_Good_Cost__c=100, ASI_FOC_Brand_Director_Approval_Required__c=true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'));
            ASI_FOC_Request_Item__c ri2 = new ASI_FOC_Request_Item__c(ASI_FOC_SKU__c = tmpSku.id, recordtypeid = Global_RecordTypeCache.getRtId('ASI_FOC_Request_Item__cASI_FOC_CN_Request_Item'), ASI_FOC_Request_Order__c=fr.id, ASI_FOC_Free_Good_Cost__c=30, ASI_FOC_Brand_Director_Approval_Required__c=true, ASI_FOC_Brand_Approver__c=userInfo.getUserId(), ASI_FOC_Brand_Director_Approval_Status__c='Approved');
            insert ri;
            // riList.add(ri);
            // riList.add(ri2);
            
            // insert riList;

            ASI_CRM_TOV__c tmpTOV = new ASI_CRM_TOV__c(ASI_CRM_Status__c = 'Draft'
                                                       , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV')
                                                       , ASI_CRM_Free_Goods_Request__c = fr.Id
                                                      );
            insert tmpTOV;        

            ASI_MFM_RequestItem_UserAssignment__c reqUser = new ASI_MFM_RequestItem_UserAssignment__c(
                                                                ASI_MFM_User__c = u.Id,  ASI_MFM_Request_Item__c = ri.Id);
            insert reqUser;

            ASI_CRM_TOV_Detail__c tovDetail = new ASI_CRM_TOV_Detail__c(
                                                ASI_CRM_TOV__c = tmpTOV.Id, ASI_CRM_SF_FOC_Request_Line_Number__c = ri.Id);
            insert tovDetail;

            ASI_CRM_CN_TOV_PDF_Controller ctrl = new ASI_CRM_CN_TOV_PDF_Controller();
            ASI_CRM_CN_TOV_PDF_Controller.IineItemShowBean bean = new ASI_CRM_CN_TOV_PDF_Controller.IineItemShowBean();
            ctrl.currentHeaderID = tmpTOV.id;
            ctrl.init();
            
            boolean dummyVar = ctrl.dummyVar;
            List<ASI_FOC_Request_Item__c> lineItemFGR = ctrl.lineItemFGR;
            Double totalQty = ctrl.totalQty;
            test.stopTest();

        }


    }
}
/*
 * 20200329:AM@introv - test class for ASI_MFM_TW_Payment_ApprovalCls
 * ***please include "ASI_MFM_Payment_Trigger_TestClass" for business flow
 * this test class is for other logic functions
 */

@isTest
public class ASI_MFM_TW_Payment_ApprovalCls_Test {

    //copy from "TWTest"
	static testMethod void TW_Payment_Approval_Test(){
        user u = [SELECT id, userRole.developerName FROM user WHERE id = :userInfo.getUserId()];    
        u.ASI_MFM_Country__c ='TW';
        u.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - OnTrade';
        update u;
        
        System.runAs(u) {
            List<Account> listAcc = new List<Account>();
            listAcc.add(new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'),Name='Test Outlet',ASI_TH_CRM_Region__c ='North'));  
            listAcc.add(new Account(RecordTypeid = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'),Name='Test Customer'));  
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_TW_Outlet'), Name='Name3')); 
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Supplier'), Name='Name2'));
            listAcc.add(new Account(recordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_TW_Customer'), Name='Name3'));    
            insert listAcc;            
            
            List<ASI_MFM_A_C_Code__c> ACList = new List<ASI_MFM_A_C_Code__c> ();
            ASI_MFM_A_C_Code__c ac = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',
            ASI_MFM_A_and_P_Tree__c='TOTAL A&P' , ASI_MFM_Reporting_Category__c ='Trade A&P');

            ACList.add(ac);
 
            ASI_MFM_A_C_Code__c ac2 = new ASI_MFM_A_C_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_TW_A_C_Code'), name='testAC',
            ASI_MFM_A_and_P_Tree__c='TOTAL A&P' , ASI_MFM_Reporting_Category__c ='MKT A&P');

            ACList.add(ac2);

            insert ACList;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_MFM_TW_AP_Code'), name='testAP');
            insert ap;
            
            ASI_MFM_Sub_brand__c sub = new ASI_MFM_Sub_brand__c(name='testSubBrand',ASI_CRM_TW_Company__c='PRT', ASI_CRM_Active__c=TRUE, ASI_TH_CRM_Active__c=TRUE,recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_TW_Sub_brand'));
            insert sub;
            
            
            List<ASI_MFM_Prefix__c> prList = new List<ASI_MFM_Prefix__c> (); 
            ASI_MFM_Prefix__c pxp = new ASI_MFM_Prefix__c(name='Ftest', ASI_MFM_Module__c='Plan', Plan_Type__c='rade A&P Plan',ASI_MFM_Over_Spending_Checking__c=true,ASI_MFM_Tolerance__c=1, ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxp);
            ASI_MFM_Prefix__c pxo = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='PO', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxo);
            ASI_MFM_Prefix__c pxy = new ASI_MFM_Prefix__c(name='test', ASI_MFM_Module__c='Payment', ASI_MFM_Fiscal_year__c = ASI_MFM_KR_CSVTestClass.getFiscalYear());
            prList.add(pxy);
            insert prList;
            
            List<ASI_MFM_Role_Prefix_Relationship__c> rprList = new List<ASI_MFM_Role_Prefix_Relationship__c> (); 
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxp.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            rprList.add(new ASI_MFM_Role_Prefix_Relationship__c(ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Role_Name__c=u.userRole.developerName));
            insert rprList;
            
            ASI_MFM_Route_Type__c rt = new ASI_MFM_Route_Type__c(name='testRT',ASI_MFM_Module__c='PO',ASI_MFM_ByPassThreshold__c=true);
            insert rt;
            
            List<ASI_MFM_Route_Rule_Detail__c> rrdlist = new List<ASI_MFM_Route_Rule_Detail__c>();
            ASI_MFM_Route_Rule_Detail__c rrd1 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=1);
            ASI_MFM_Route_Rule_Detail__c rrd2 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=2);
            ASI_MFM_Route_Rule_Detail__c rrd3 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=3);
            ASI_MFM_Route_Rule_Detail__c rrd4 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=4);
            ASI_MFM_Route_Rule_Detail__c rrd5 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=5);
            ASI_MFM_Route_Rule_Detail__c rrd6 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=6);
            ASI_MFM_Route_Rule_Detail__c rrd7 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=7);
            ASI_MFM_Route_Rule_Detail__c rrd8 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=8);
            ASI_MFM_Route_Rule_Detail__c rrd9 = new ASI_MFM_Route_Rule_Detail__c(ASI_MFM_Approver__c=u.id, ASI_MFM_Minimum_Amount__c=0, ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Sequence__c=9);
            rrdlist.add(rrd1);
            rrdlist.add(rrd2);
            rrdlist.add(rrd3);
            rrdlist.add(rrd4);
            rrdlist.add(rrd5);
            rrdlist.add(rrd6);
            rrdlist.add(rrd7);
            rrdlist.add(rrd8);
            rrdlist.add(rrd9);
            insert rrdlist;
            
            ASI_MFM_Brand_Route_Type_Map__c rtm = new ASI_MFM_Brand_Route_Type_Map__c(ASI_MFM_Route_Type__c=rt.id,ASI_MFM_Responsible_By__c=u.id,ASI_MFM_Prefix__c=pxo.id );
            insert rtm;
            
            ASI_MFM_Route_Type_Brands_Relationship__c rtbr= new ASI_MFM_Route_Type_Brands_Relationship__c(ASI_MFM_Route_Type__c=rt.id);
            insert rtbr;
                        
            List<ASI_MFM_Plan__c> listPlan = new List<ASI_MFM_Plan__c>();
            listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
                                             ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
            //listPlan.add(new ASI_MFM_Plan__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_TW_Plan'), name='test', ASI_MFM_End_Date__c=Date.today().addMonths(1), ASI_MFM_Prefix__c=pxp.id,
              //                               ASI_MFM_Plan_Description__c='testPlanDescription', ASI_MFM_Plan_Name__c='testPlan', ASI_MFM_Start_Date__c=Date.today(), ASI_MFM_Status__c = 'Final'));
            insert listPlan;      
            
            List<ASI_MFM_Plan_Line_Item__c> listPL = new List<ASI_MFM_Plan_Line_Item__c>();
            listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing1',ASI_MFM_Customer_Name__c =listAcc[4].id,
                                                     ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac.id, ASI_MFM_Total_Cost__c=1000));
            listPL.add(new ASI_MFM_Plan_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Plan_Line_Item__cASI_MFM_TW_Plan_Line_Item'), ASI_MFM_List_Item_Description__c='testing2',ASI_MFM_Customer_Name__c =listAcc[4].id,
                                                     ASI_MFM_Plan__c=listPlan[0].id, ASI_MFM_A_C_Code__c=ac2.id,ASI_MFM_Total_Cost__c=2000));
            insert listPL;
            
            List<ASI_MFM_Exchange_Rate__c> listXR = new List<ASI_MFM_Exchange_Rate__c>();
            listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='TWD',ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1)); 
            listXR.add(new ASI_MFM_Exchange_Rate__c(ASI_MFM_Application__c='MFM', ASI_MFM_Base_Currency__c='SGD',ASI_MFM_Counter_Currency__c='TWD', ASI_MFM_Country__c='TW', ASI_MFM_Effective_Date__c=date.today(), ASI_MFM_Exchange_Rate__c=1)); 
            insert listXR;    
           
            System.debug(Limits.getDMLRows());
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Status__c='Draft',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_TW_PO'), ASI_MFM_Plan__c=listPlan[0].id,ASI_MFM_Supplier_Name__c = listAcc[3].id, ASI_MFM_Prefix__c=pxo.id, ASI_MFM_Currency__c='TWD');
            insert po;            
            
            List<ASI_MFM_PO_Line_Item__c> poLinelist= new List<ASI_MFM_PO_Line_Item__c> ();
            ASI_MFM_PO_Line_Item__c poi1 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac.id, ASI_MFM_Customer_Name__c=listAcc[4].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
            poLinelist.add(poi1);
            ASI_MFM_PO_Line_Item__c poi2 = new ASI_MFM_PO_Line_Item__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_TW_PO_Line_Item'), ASI_MFM_PO__c=po.id, ASI_MFM_Amount__c=100,ASI_MFM_Quantity__c=10, ASI_MFM_Unit_Price__c=10, ASI_MFM_A_C_Code__c = ac2.id, ASI_MFM_Customer_Name__c=listAcc[4].id, ASI_MFM_G_L_Date__c=Date.today(), ASI_MFM_List_Item_Description__c='testDescription', ASI_MFM_Sub_brand_Code__c=sub.id);
            poLinelist.add(poi2);
            insert poLinelist;
            
            //dynamic route
            string sRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Dynamic_Approval_Route__cASI_MFM_TW_Dynamic_Approval_Route');
            List<ASI_MFM_Dynamic_Approval_Route__c> ltDynRoute = new List<ASI_MFM_Dynamic_Approval_Route__c>();
            ltDynRoute.add(new ASI_MFM_Dynamic_Approval_Route__c(RecordTypeId=sRTID,ASI_MFM_Inactive__c=FALSE,ASI_MFM_User__c=u.Id,ASI_MFM_End_of_1st_Route__c=FALSE,ASI_MFM_Skip_to_Next_Level__c=FALSE));
            insert ltDynRoute;
            
            //fix route
            sRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_TW_Fix_Approval_Route');
            List<ASI_MFM_Fix_Approval_Route__c> ltFixRoute = new List<ASI_MFM_Fix_Approval_Route__c>();
            ltFixRoute.add(new ASI_MFM_Fix_Approval_Route__c(RecordTypeId=sRTID,ASI_MFM_Company__c='NON-TRADE',ASI_MFM_Department__c='FIN',ASI_MFM_Corporate_Approver_1__c=u.Id));
            ltFixRoute.add(new ASI_MFM_Fix_Approval_Route__c(RecordTypeId=sRTID,ASI_MFM_Company__c='NON-TRADE',ASI_MFM_Department__c='HR',ASI_MFM_Corporate_Approver_1__c=u.Id));
            ltFixRoute.add(new ASI_MFM_Fix_Approval_Route__c(RecordTypeId=sRTID,ASI_MFM_Company__c='NON-TRADE',ASI_MFM_Department__c='MKT',ASI_MFM_Corporate_Approver_1__c=u.Id));
            ltFixRoute.add(new ASI_MFM_Fix_Approval_Route__c(RecordTypeId=sRTID,ASI_MFM_Company__c='NON-TRADE',ASI_MFM_Department__c='Sales',ASI_MFM_Corporate_Approver_1__c=u.Id,ASI_MFM_Region_Area_Channel__c='TRADE-ON'));
            ltFixRoute.add(new ASI_MFM_Fix_Approval_Route__c(RecordTypeId=sRTID,ASI_MFM_Company__c='NON-TRADE',ASI_MFM_Department__c='Sales',ASI_MFM_Corporate_Approver_1__c=u.Id,ASI_MFM_Region_Area_Channel__c='TRADE-OFF'));
            ltFixRoute.add(new ASI_MFM_Fix_Approval_Route__c(RecordTypeId=sRTID,ASI_MFM_Company__c='NON-TRADE',ASI_MFM_Department__c='Sales',ASI_MFM_Corporate_Approver_1__c=u.Id,ASI_MFM_Region_Area_Channel__c='SD'));
            insert ltFixRoute;
            
            Test.startTest();

            // Create Payment  
			ASI_MFM_Payment__c py = new ASI_MFM_Payment__c(recordTypeId=Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_TW_Payment'), ASI_MFM_Prefix__c=pxy.id, ASI_MFM_Payment_Date__c=date.today(),
                                                               ASI_MFM_Currency__c='SGD', ASI_MFM_Payment_Amount__c=99,ASI_MFM_Supplier_Name__c = ListAcc[3].id,ASI_MFM_Status__c='Draft',OwnerId=u.Id);  
            List<ASI_MFM_Payment__c> ltPayment = new List<ASI_MFM_Payment__c>();
            ltPayment.add(py);
            insert ltPayment;
            
            //Sales-TRADE-ON
            ltPayment[0].ASI_MFM_Payment_Amount__c = 1000;
            update ltPayment;
            
            //Sales-TRADE-OFF
            u.ASI_MFM_Department__c = 'Sales (Domestic & International Markets) - HYPER';
        	update u;
            ltPayment[0].ASI_MFM_Payment_Amount__c = 1001;
            update ltPayment;
            
            //FIN
            u.ASI_MFM_Department__c = 'Finance';
        	update u;
            ltPayment[0].ASI_MFM_Payment_Amount__c = 1002;
            update ltPayment;
            
            //HR
            u.ASI_MFM_Department__c = 'Human Resources';
        	update u;
            ltPayment[0].ASI_MFM_Payment_Amount__c = 1003;
            update ltPayment;
            
            //MKT
            u.ASI_MFM_Department__c = 'Marketing';
        	update u;
            ltPayment[0].ASI_MFM_Payment_Amount__c = 1004;
            update ltPayment;
            
            
            test.stopTest();
        }
    }

}
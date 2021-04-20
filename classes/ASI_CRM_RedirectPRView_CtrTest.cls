/**
 * @File Name          : ASI_CRM_RedirectPRView_CtrTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/17/2020, 2:42:49 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/17/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_RedirectPRView_CtrTest {
    static testMethod void ASI_CRM_RedirectPayment_Test() {
        //---- covered classes: ----
        //---- 1. ASI_CRM_RedirectPREdit_Ctr ----
        //---- 2. ASI_CRM_RedirectPRNew_Ctr ----
        //---- 3. ASI_CRM_RedirectPRView_Ctr ----

        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c'));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c'));
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved');
        insert ct;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_TH_CRM_Payment_Request')));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        //prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_SG_CRM_Payment_Request')));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request')));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')));
        //prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_MY_Payment_Request')));
        insert prs;

        test.startTest();
        prs[0].recordTypeId = NULL;

        ApexPages.currentPage().getParameters().put('a', '1');
        ApexPages.currentPage().getParameters().put('b', null);

        ApexPages.StandardController stdController1 = new ApexPages.StandardController(prs[0]);
        ApexPages.StandardController stdController2 = new ApexPages.StandardController(prs[1]);
        ApexPages.StandardController stdController3 = new ApexPages.StandardController(prs[2]);
        ApexPages.StandardController stdController4 = new ApexPages.StandardController(prs[3]);
        ApexPages.StandardController stdController5 = new ApexPages.StandardController(prs[4]);
        //ApexPages.StandardController stdController6 = new ApexPages.StandardController(prs[5]);
        //ApexPages.StandardController stdController7 = new ApexPages.StandardController(prs[6]);

        ASI_CRM_RedirectPRNew_Ctr controllerNew1 = new ASI_CRM_RedirectPRNew_Ctr(stdController1);        
        ASI_CRM_RedirectPRNew_Ctr controllerNew2 = new ASI_CRM_RedirectPRNew_Ctr(stdController2);
        ASI_CRM_RedirectPRNew_Ctr controllerNew3 = new ASI_CRM_RedirectPRNew_Ctr(stdController3);
        ASI_CRM_RedirectPRNew_Ctr controllerNew4 = new ASI_CRM_RedirectPRNew_Ctr(stdController4);
        ASI_CRM_RedirectPRNew_Ctr controllerNew5 = new ASI_CRM_RedirectPRNew_Ctr(stdController5);
        //ASI_CRM_RedirectPRNew_Ctr controllerNew6 = new ASI_CRM_RedirectPRNew_Ctr(stdController6);
        //ASI_CRM_RedirectPRNew_Ctr controllerNew7 = new ASI_CRM_RedirectPRNew_Ctr(stdController7);
        controllerNew1.redirect();
        controllerNew2.redirect();
        controllerNew3.redirect();
        controllerNew4.redirect();
        controllerNew5.redirect();
        //controllerNew6.redirect();
        //controllerNew7.redirect();

        ASI_CRM_RedirectPREdit_Ctr controllerEdit1 = new ASI_CRM_RedirectPREdit_Ctr(stdController1);        
        ASI_CRM_RedirectPREdit_Ctr controllerEdit2 = new ASI_CRM_RedirectPREdit_Ctr(stdController2);
        ASI_CRM_RedirectPREdit_Ctr controllerEdit3 = new ASI_CRM_RedirectPREdit_Ctr(stdController3);
        ASI_CRM_RedirectPREdit_Ctr controllerEdit4 = new ASI_CRM_RedirectPREdit_Ctr(stdController4);
        ASI_CRM_RedirectPREdit_Ctr controllerEdit5 = new ASI_CRM_RedirectPREdit_Ctr(stdController5);
        //ASI_CRM_RedirectPREdit_Ctr controllerEdit6 = new ASI_CRM_RedirectPREdit_Ctr(stdController6);
        //ASI_CRM_RedirectPREdit_Ctr controllerEdit7 = new ASI_CRM_RedirectPREdit_Ctr(stdController7);
        controllerEdit1.redirect();
        controllerEdit2.redirect();
        controllerEdit3.redirect();
        controllerEdit4.redirect();
        controllerEdit5.redirect();
        //controllerEdit6.redirect();
        //controllerEdit7.redirect();


        ASI_CRM_RedirectPRView_Ctr controllerView1 = new ASI_CRM_RedirectPRView_Ctr(stdController1);        
        ASI_CRM_RedirectPRView_Ctr controllerView2 = new ASI_CRM_RedirectPRView_Ctr(stdController2);
        ASI_CRM_RedirectPRView_Ctr controllerView3 = new ASI_CRM_RedirectPRView_Ctr(stdController3);
        ASI_CRM_RedirectPRView_Ctr controllerView4 = new ASI_CRM_RedirectPRView_Ctr(stdController4);
        ASI_CRM_RedirectPRView_Ctr controllerView5 = new ASI_CRM_RedirectPRView_Ctr(stdController5);
        //ASI_CRM_RedirectPRView_Ctr controllerView6 = new ASI_CRM_RedirectPRView_Ctr(stdController6);
        //ASI_CRM_RedirectPRView_Ctr controllerView7 = new ASI_CRM_RedirectPRView_Ctr(stdController7);
        controllerView1.redirect();
        controllerView2.redirect();
        controllerView3.redirect();
        controllerView4.redirect();
        controllerView5.redirect();
        //controllerView6.redirect();
        //controllerView7.redirect();

        test.stopTest();
    }

    static testMethod void ASI_CRM_RedirectPayment_Test2() {
        //---- covered classes: ----
        //---- 1. ASI_CRM_RedirectPREdit_Ctr ----
        //---- 2. ASI_CRM_RedirectPRNew_Ctr ----
        //---- 3. ASI_CRM_RedirectPRView_Ctr ----

        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c'));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c'));
        insert rns;
             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(ASI_TH_CRM_Outlet__c=acc.Id, ASI_TH_CRM_Contract_Status__c = 'Contract Approved',ASI_TH_CRM_Promotion_Type__c='Heavy Contract On'); 
        insert ct;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'), Name='Test-000'));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'), Name='Test-001'));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        
        insert prs;

        User u = new User();
        u.id = UserInfo.getUserId();
        u.BypassTriggers__c = 'ASI_CRM_CN_Contract_TriggerClass';
        update u;

        test.startTest();
        prs[0].recordTypeId = NULL;

        ApexPages.currentPage().getParameters().put('a', '1');
        ApexPages.currentPage().getParameters().put('b', null);

        ApexPages.StandardController stdController1 = new ApexPages.StandardController(prs[0]);
        ApexPages.StandardController stdController2 = new ApexPages.StandardController(prs[1]);

        ASI_CRM_RedirectPRNew_Ctr controllerNew1 = new ASI_CRM_RedirectPRNew_Ctr(stdController1);        
        ASI_CRM_RedirectPRNew_Ctr controllerNew2 = new ASI_CRM_RedirectPRNew_Ctr(stdController2);
        controllerNew1.redirect();
        controllerNew2.redirect();

        ASI_CRM_RedirectPREdit_Ctr controllerEdit1 = new ASI_CRM_RedirectPREdit_Ctr(stdController1);        
        ASI_CRM_RedirectPREdit_Ctr controllerEdit2 = new ASI_CRM_RedirectPREdit_Ctr(stdController2);
        controllerEdit1.redirect();
        controllerEdit2.redirect();

        ASI_CRM_RedirectPRView_Ctr controllerView1 = new ASI_CRM_RedirectPRView_Ctr(stdController1);        
        ASI_CRM_RedirectPRView_Ctr controllerView2 = new ASI_CRM_RedirectPRView_Ctr(stdController2);
        controllerView1.redirect();
        controllerView2.redirect();


        ct.ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Contract';  
        update ct;
        ApexPages.StandardController stdController3 = new ApexPages.StandardController(prs[2]);
        ASI_CRM_RedirectPRNew_Ctr controllerNew3 = new ASI_CRM_RedirectPRNew_Ctr(stdController3);
        controllerNew3.redirect();

        ASI_CRM_RedirectPREdit_Ctr controllerEdit3 = new ASI_CRM_RedirectPREdit_Ctr(stdController3);
        controllerEdit3.redirect();
        
        ASI_CRM_RedirectPRView_Ctr controllerView3 = new ASI_CRM_RedirectPRView_Ctr(stdController3);
        controllerView3.redirect();

        // ct.ASI_TH_CRM_Promotion_Type__c = 'Wholesaler Promotion';
        // update ct;
        // ApexPages.StandardController stdController4 = new ApexPages.StandardController(prs[3]);
        // ASI_CRM_RedirectPRNew_Ctr controllerNew4 = new ASI_CRM_RedirectPRNew_Ctr(stdController4);
        // controllerNew4.redirect();

        // ASI_CRM_RedirectPREdit_Ctr controllerEdit4 = new ASI_CRM_RedirectPREdit_Ctr(stdController4);
        // controllerEdit4.redirect();

        // ASI_CRM_RedirectPRView_Ctr controllerView4 = new ASI_CRM_RedirectPRView_Ctr(stdController4);
        // controllerView4.redirect();

        test.stopTest();
    }
}
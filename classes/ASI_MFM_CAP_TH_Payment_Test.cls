/*********************************************************************************
 * Name:ASI_MFM_CAP_TH_Payment_Test
 * Description: Test Class for payment object components
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 17/05/2016       Laputa: Hugo            Created
*********************************************************************************/

@isTest
public class ASI_MFM_CAP_TH_Payment_Test {

  static testmethod void testDirectPayment() {
    User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
    Account acc;
    User u;
    System.runAs (thisUser) {
      acc = ASI_MFM_CAP_TH_TestClassHelper.createAccountSupplier();
      u = ASI_MFM_CAP_TH_TestClassHelper.createUser(userInfo.getUserRoleId());
    }

    ASI_MFM_A_C_Code__c acCode = ASI_MFM_CAP_TH_TestClassHelper.createAcCode();
    ASI_MFM_AP_Code__c apCode = ASI_MFM_CAP_TH_TestClassHelper.createApCode(acCode);

    ASI_MFM_Prefix__c prefixPayment = ASI_MFM_CAP_TH_TestClassHelper.createPrefixPayment(u);
    ASI_MFM_Prefix__c prefixPO = ASI_MFM_CAP_TH_TestClassHelper.createPrefixPO(u);

    ASI_MFM_Payment__c payment = ASI_MFM_CAP_TH_TestClassHelper.createPayment(acc, prefixPayment);
        payment.ASI_MFM_Is_Direct_Payment__c = true;
        update payment;
    ASI_MFM_PO__c po = ASI_MFM_CAP_TH_TestClassHelper.createPO(prefixPO);
    ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TH_TestClassHelper.createPOLine(po);
	
        ASI_MFM_Payment_Line_Item__c paymentLinesItem = new ASI_MFM_Payment_Line_Item__c
        (
        recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_CAP_TH_Payment_Line_Item'),
          ASI_MFM_Payment__c=payment.id, 
          ASI_MFM_Payment_Amount__c=10, 
          ASI_MFM_PO_Line_Item__c=poLine.id, 
          ASI_MFM_Invoice_Date__c = date.today(), 
          ASI_MFM_Invoice_Number__c = '123456',
          ASI_MFM_AP_Code__c = apCode.id,
          ASI_MFM_A_C_Code__c = acCode.id,
          ASI_MFM_Payee__c = acc.Id
          );                       
        insert paymentLinesItem;
        
    delete paymentLinesItem;

    System.runAs(u) {
      ApexPages.currentPage().getParameters().put('paid', payment.Id);
      ApexPages.currentPage().getParameters().put('poid', po.Id);

      Test.StartTest();
      Test.setCurrentPage(Page.ASI_MFM_CAP_TH_EditSmallAmountPay_Page);
      ApexPages.currentPage().getHeaders().put('referer', 'test');

      ASI_MFM_CAP_TH_EditSmallAmountPay_Ctrl controller = new ASI_MFM_CAP_TH_EditSmallAmountPay_Ctrl();
      List<SelectOption> SelectOption = controller.getTypeItems();
      String[] testString = controller.getSelectedType();
      controller.setSelectedType(testString);

      controller.LSAPHeader[0].type   = '--None--';
          controller.LSAPHeader[0].isTnE  = true;
          controller.LSAPHeader[0].po     = po.clone(false, true, false, false);
          controller.LSAPHeader[0].po.id  = null;
              
          controller.payment_prefixes.id                   = payment.ASI_MFM_Prefix__c;
          controller.LSAPHeader[0].pay                     = payment.clone(false, true, false, false);
          controller.LSAPHeader[0].pay.id                  = null;
    
      System.currentPageReference().getParameters().put('SupplierName', acc.Name);
            controller.updateDefaultACCode();
            
          controller.AddNew_SAPL();

          ASI_MFM_CAP_TH_EditSmallAmountPay_Ctrl.SAPLineObj sapl_Clone = controller.SAPL_Item_Map.get(0);
          String id = sapl_Clone.id;
          sapl_Clone.pl = new ASI_MFM_Payment_Line_Item__c();
          sapl_Clone.pl.ASI_MFM_Payment_List_Item_Description__c = 'abcd';
          sapl_Clone.pl.ASI_MFM_Payment_Date__c = Date.today() ;
          sapl_Clone.pl.ASI_MFM_Payment_Amount__c = 50;
          sapl_Clone.ACSelected = acCode.id;
          sapl_clone.updateAC();
          
          String[] testPlan = ASI_MFM_CAP_TH_EditSmallAmountPay_Ctrl.findSObjects('ASI_MFM_Plan__c', '');
          String[] testAccount = ASI_MFM_CAP_TH_EditSmallAmountPay_Ctrl.findCustSObjects('account', 'ASI_MFM_HK_Supplier');
          sapl_Clone.pol= new ASI_MFM_PO_Line_Item__c();
              
          System.currentPageReference().getParameters().put('ACChoice', (String)acCode.id);
          System.currentPageReference().getParameters().put('cpiKey', '0');
          controller.updateACPick();
              
          controller.rowidSAPL = 0;
          controller.Clone_SAPL();
          controller.rowidSAPL = 1;
          controller.RemoveRow_SAPL();
          controller.SaveRecord();
          controller.LSAPHeader[0].type = 'Brand Owner Invoice';
          controller.SaveRecord();
          controller.cancel();
          
          Test.StopTest();
      }
  }

  static testmethod void testManageAllPayment() {
    User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
    Account acc;
    User u;
    System.runAs ( thisUser ) {
      acc = ASI_MFM_CAP_TH_TestClassHelper.createAccountSupplier();
      u = ASI_MFM_CAP_TH_TestClassHelper.createUser(userInfo.getUserRoleId());
    }

    ASI_MFM_Prefix__c prefixPayment = ASI_MFM_CAP_TH_TestClassHelper.createPrefixPayment(u);
    ASI_MFM_Prefix__c prefixPO = ASI_MFM_CAP_TH_TestClassHelper.createPrefixPO(u);

    System.runAs(u) {

      ASI_MFM_A_C_Code__c acCode = ASI_MFM_CAP_TH_TestClassHelper.createAcCode();
      ASI_MFM_AP_Code__c apCode = ASI_MFM_CAP_TH_TestClassHelper.createApCode(acCode);

      ASI_MFM_Payment__c payment = ASI_MFM_CAP_TH_TestClassHelper.createPayment(acc, prefixPayment);
      ASI_MFM_PO__c po = ASI_MFM_CAP_TH_TestClassHelper.createPO(prefixPO);
      ASI_MFM_PO_Line_Item__c poLine = ASI_MFM_CAP_TH_TestClassHelper.createPOLine(po);

      ASI_MFM_Payment_Line_Item__c paymentLinesItem = ASI_MFM_CAP_TH_TestClassHelper.createPaymentLines(payment, poLine, apCode, acCode);
      paymentLinesItem.ASI_MFM_A_C_Code__c = acCode.Id;
      update paymentLinesItem;

      Test.StartTest();
      Test.setCurrentPage(Page.ASI_MFM_CAP_TH_MgAll_PaymentPage);
      ApexPages.currentPage().getHeaders().put('referer', 'test');
      ApexPages.currentPage().getParameters().put('Id', payment.Id);

      ApexPages.StandardController stdCon = new ApexPages.StandardController(payment);

      ASI_MFM_CAP_TH_MgAll_PaymentController controller = new ASI_MFM_CAP_TH_MgAll_PaymentController(stdCon);
      controller.updateACPick();
      controller.addPaymentLine();
      System.currentPageReference().getParameters().put('PARAM_Payment_SOURCE_ITEM_ID', (String)paymentLinesItem.id);
          controller.clonePaymentLine();
          System.currentPageReference().getParameters().put('PARAM_PAYMENT_LINE_ID', 'zzzzzzPaymentNEWZ0');
          controller.removePaymentLine();
          controller.savePayment();
          controller.cancel();
          payment.ASI_MFM_Invoice_Date__c = date.today().addDays(1);
          payment.ASI_MFM_Status__c = 'Submitted';
          update payment;
          payment.ASI_MFM_Status__c = 'Draft';
          update payment;
          delete payment;
          Test.StopTest();
      }  
  }

}
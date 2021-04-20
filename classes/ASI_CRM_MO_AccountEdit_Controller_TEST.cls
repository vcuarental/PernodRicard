@isTest
public class ASI_CRM_MO_AccountEdit_Controller_TEST{

    static testMethod void ASI_CRM_MO_AccountEdit_Controller_TEST() {
        ASI_CRM_MO_TestClassHelper.createRunningNumbers();
        
        Account acc1 = ASI_CRM_MO_TestClassHelper.createAccount('acc1');
        
        ApexPages.StandardController standardCtl = new ApexPages.StandardController(acc1);
        ASI_CRM_MO_AccountEdit_Controller ctl = new ASI_CRM_MO_AccountEdit_Controller(standardCtl);
        ctl.getAccountAT();
        ctl.getAccountContract();
        ctl.getAccountContractALL();
        ctl.getAccountVPD();
        ctl.getAccountVPDALL();
        ctl.save();
        List<SelectOption> outletTypeList = new List<SelectOption>();
        outletTypeList = ctl.OutletTypeList;
        List<SelectOption> outletImageList = new List<SelectOption>();
        outletImageList = ctl.OutletImageList;
          
    }
}
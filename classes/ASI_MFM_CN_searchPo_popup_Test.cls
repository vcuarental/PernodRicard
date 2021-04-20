@isTest
public class ASI_MFM_CN_searchPo_popup_Test {
    Static Testmethod Void testCtrl(){
        Test.startTest();
        ASI_MFM_CN_SearchPO_PopupCtrl ctrl = new ASI_MFM_CN_SearchPO_PopupCtrl();
        ctrl.search();
        ctrl.getFormTag();
		ctrl.getTextBox();
        Test.stopTest();
    }
}
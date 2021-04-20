@isTest
public class ASI_MFM_CN_POSM_ItemGroupPopup_Test {
    Static Testmethod Void testCtrl(){
        Test.startTest();
        ASI_MFM_CN_POSM_ItemGroupPopupCtrl ctrl = new ASI_MFM_CN_POSM_ItemGroupPopupCtrl();
        ctrl.search();
        ctrl.getFormTag();
		ctrl.getTextBox();
        Test.stopTest();
    }
}
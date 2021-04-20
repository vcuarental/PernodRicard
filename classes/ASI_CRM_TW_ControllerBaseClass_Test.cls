@isTest
public class ASI_CRM_TW_ControllerBaseClass_Test {

    public static testmethod void testBase_Controller () {
        ASI_CRM_TW_ComponentControllerBase compCont = new ASI_CRM_TW_ComponentControllerBase();
        ASI_CRM_TW_PageControllerBase pageCont = new ASI_CRM_TW_PageControllerBase();
        compCont.pageController = pageCont;
        compCont.key = 'test';
        compCont.pageController = pageCont;
        Map<String, ASI_CRM_TW_ComponentControllerBase> testMap = pageCont.getComponentControllerMap();
        
        pageCont.setComponentControllerMap('keyTest', null);
        ASI_CRM_TW_PageControllerBase testTemp2 = pageCont.getThis();
        
        ASI_CRM_TW_PageControllerBase testPageControllerBase2 = compCont.pageController;
    }

}
@isTest
public class ASI_CRM_CN_Abstract_Test {
    
    private class ASI_CRM_CN_PageInterface_1 implements ASI_CRM_CN_PageInterface {
        public void setComponentController(ASI_CRM_CN_ComponentInterface cController) {}
        public void setComponentController(String key, ASI_CRM_CN_ComponentInterface cController) {}
        public ASI_CRM_CN_ComponentInterface getComponentController() { return null; }
        public ASI_CRM_CN_ComponentInterface getComponentController(String key) { return null; }
    }
    
    static testMethod void ASI_CRM_CN_AbstractComponentController_TEST() {
        
        test.startTest();
        
        ASI_CRM_CN_AbstractComponentController con = new ASI_CRM_CN_AbstractComponentController();
        
        con.pageController = con.pageController;
        con.componentKey  = null;
        string k = con.componentKey;
        con.componentKey = 'TEST';
        k = con.componentKey;
        
        con.setPageController(new ASI_CRM_CN_PageInterface_1());
        con.getPageController();
        
        test.stopTest();
    }
}
@isTest
public class EUR_CRM_TestMultiselectController {
    static testMethod void testMultiselectController() {
        EUR_CRM_MultiselectController c = new EUR_CRM_MultiselectController();
        
        c.leftOptionsX = new List<SelectOption>();
        c.rightOptionsX = new List<SelectOption>();

        c.leftOptionsHidden = 'A&a&b&b&C&c';
        c.rightOptionsHidden = '';
        
        System.assertEquals(c.leftOptionsX.size(), 3);
        System.assertEquals(c.rightOptionsX.size(), 0);
    }
}
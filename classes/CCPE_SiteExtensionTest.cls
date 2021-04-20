@isTest

public class CCPE_SiteExtensionTest{
    
    public static testMethod void testSiteExtension(){project_cloud__Project__c p = new project_cloud__Project__c(Name = 'Test Project');insert p;
    
    CCPE_SiteExtension c = new CCPE_SiteExtension(new ApexPages.standardController(p)); c.getProjectTasks();
    
        // ADDING CODE 20161109 GDT_SG DEB
        C.getProjectTicketsIssues();
        c.getProjectTicketsRisks();
        
        System.debug('CCPE_SiteExtension c = ' + c);
        // ADDING CODE 20161109 GDT_SG FIN
		}

}
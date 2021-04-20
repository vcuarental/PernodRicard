@isTest
public class ASI_MFM_CAP_HK_GenPOPageExtensionTest {
	
     static testMethod void testASI_MFM_CAP_HK_GenPOPageExtension()
    {
     /*   userrole Role_Test= new userrole(Name='XXXTrade Marketing',developerName = 'test');
        insert Role_Test;
        
        user u = [select userRole.developerName, ASI_MFM_Country__c,UserRoleid,CompanyName from user where id = :userInfo.getUserId() limit 1]; 
        u.ASI_MFM_Country__c = 'HK';
        u.UserRoleid =Role_Test.id;
        u.CompanyName = 'Pernod Ricard Hong Kong';
        update u;
        
        System.runAs(u){ 
       */ 
            Test.startTest();
            ASI_MFM_CAP_TestClassHelper.createRoutePOType();
            ASI_MFM_Plan__c plan = ASI_MFM_CAP_TestClassHelper.createPlan();
            
            Test.stopTest();
            List<ASI_MFM_Plan_Line_Item__c> planLines = [select ID,ASI_MFM_Plan__c,ASI_MFM_Plan_Type__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c =: plan.id];
			system.debug('plan:'+ plan.ASI_MFM_Plan_Type__c);
        	system.debug('planLines plan:'+ planLines[0].ASI_MFM_Plan__c);
        	system.debug('planLines plan type:'+ planLines[0].ASI_MFM_Plan_Type__c);
        	system.debug('ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c:'+ planLines[0].ASI_MFM_Plan__r.ASI_MFM_Plan_Type__c);
            ASI_MFM_CAP_HK_GeneratePOPageExtension con = new ASI_MFM_CAP_HK_GeneratePOPageExtension(new ApexPages.Standardcontroller(planLines[0]));
            ASI_MFM_CAP_HK_GeneratePOPageExtension setcon = new ASI_MFM_CAP_HK_GeneratePOPageExtension(new ApexPages.StandardSetController(planLines));
            con.generatePOFromPage();
        	con.back();
            //PageReference generatePOFromPage = con.generatePOFromPage();
       // }
    }
    static testMethod void testASI_MFM_CAP_HK_GenPOPageExtension_exception()
    {
        try{
            ASI_MFM_Plan__c pitem = new ASI_MFM_Plan__c();
            insert pitem;
        }catch(DmlException e){
            system.debug('Catch DML');
            ASI_MFM_CAP_HK_GeneratePOPageExtension.ExtractMessage(e);
        }catch(Exception e){
            system.debug('Catch E');
            ASI_MFM_CAP_HK_GeneratePOPageExtension.ExtractMessage(e);
        }
    }
    public class TestingException extends Exception{}
    
    static testMethod void testASI_MFM_CAP_HK_GenPOPageExtension_exception2()
    {
        try{
            throw new TestingException();
        }catch(DmlException e){
            system.debug('Catch DML');
            ASI_MFM_CAP_HK_GeneratePOPageExtension.ExtractMessage(e);
        }catch(Exception e){
            system.debug('Catch E');
            ASI_MFM_CAP_HK_GeneratePOPageExtension.ExtractMessage(e);
        }
    }
}
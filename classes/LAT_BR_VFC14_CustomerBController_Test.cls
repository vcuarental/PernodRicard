/********************************************************************************
* Test Class for LAT_BR_VFC14_CustomerBehaviorController
*
* NAME: LAT_BR_VFC14_CustomerBController_Test.cls
* AUTHOR: Mariano Boezio                           DATE: 23/09/2014
********************************************************************************/

@isTest
public with sharing class LAT_BR_VFC14_CustomerBController_Test {
    
    static testMethod void ConstructorTest(){
        BasicData();
        
        Test.StartTest();
            LAT_BR_VFC14_CustomerBehaviorController cbc = new LAT_BR_VFC14_CustomerBehaviorController();
            system.AssertEquals(cbc.cbList.size(), 1);
            system.AssertEquals(cbc.NameCb.values().size(), 1);
            system.AssertEquals(cbc.NameCb.keySet().size(), 1);
        Test.StopTest();
    }
    
    static testMethod void SaveTest(){
        BasicData();
        
        Test.StartTest();
            LAT_BR_VFC14_CustomerBehaviorController cbc = new LAT_BR_VFC14_CustomerBehaviorController();
            cbc.addBehavior();
            cbc.cbList.get(1).cb.Name = 'Test Name 1';
            cbc.cbList.get(1).cb.LAT_BR_Value__c = '10';
            cbc.cbList.get(1).cb.LAT_BR_Weight__c = 20;
            
            system.assertEquals(LAT_BR_CustomerBehaviorDAO.getCustomerBehaviors().keySet().size(), 1);
            cbc.save();
            system.assertEquals(LAT_BR_CustomerBehaviorDAO.getCustomerBehaviors().keySet().size(), 2);
            
            // Test Catch Exception
            cbc.cbList = null;
            cbc.save();
        Test.StopTest();
    }
    
    static testMethod void removeTest(){
        BasicData();
        
        Test.StartTest();
            LAT_BR_VFC14_CustomerBehaviorController cbc = new LAT_BR_VFC14_CustomerBehaviorController();
            cbc.addBehavior();
            cbc.cbList.get(1).cb.Name = 'Test Name 1';
            cbc.cbList.get(1).cb.LAT_BR_Value__c = '10';
            cbc.cbList.get(1).cb.LAT_BR_Weight__c = 20;
            cbc.cbList.get(1).remove = true;
            
            system.assertEquals(cbc.cbList.size(), 2);
            cbc.removeSelected();
            system.assertEquals(cbc.cbList.size(), 1);
        Test.StopTest();
    }
    
    static void BasicData() {
        LAT_BR_CustomerBehaviorDAO cbdao = new LAT_BR_CustomerBehaviorDAO();
        cbdao.setName('Test Name');
        cbdao.setValue('20');
        cbdao.setWeight(20);
        List<LAT_BR_CustomerBehaviorDAO> cbdaoList = new List<LAT_BR_CustomerBehaviorDAO>{cbdao};
        LAT_BR_CustomerBehaviorDAO.upsertList(cbdaoList);

        // Insert an email to deliver
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
            Name = 'COMPORTAMENTO_DO_CLIENTE',
            LAT_Value__c = 'Test1');
        insert cfg;
    }
    
}
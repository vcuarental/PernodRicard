/*********************************************************************************
 * Name:ASI_MFM_CAP_Plan_TriggerClassTest
 * Description: Test Class for ASI_MFM_CAP_Plan_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
  * 2018-11-22      Jay Chau				Create
*********************************************************************************/
@isTest
public class ASI_MFM_CAP_Plan_TriggerClassTest {
    private static ASI_MFM_Plan__c plan;
    private static ASI_MFM_Plan_Line_Item__c planLines;
    private static ASI_MFM_PO__c po;
    private static ASI_MFM_PO_Line_Item__c poLineItem;
    
   
    
    @testSetup static void testSetupMethod(){
        ASI_MFM_CAP_TestClassHelper.assigeRoleToCurrentUser();
        ASI_MFM_CAP_TestClassHelper.createRoutePlanType();
        plan = ASI_MFM_CAP_TestClassHelper.createPlan();
        planLines = ASI_MFM_CAP_TestClassHelper.createPlanLines(plan);
        ASI_MFM_CAP_TestClassHelper.createRoutePOType();
        po = ASI_MFM_CAP_TestClassHelper.createPo('CAPEX', plan);
        poLineItem = ASI_MFM_CAP_TestClassHelper.createPoLines(po);
    }
    
	static testMethod void routineAfterDelete(){
        
    }
    static testMethod void routineBeforeDelete(){
        ASI_MFM_Plan__c plan = [SELECT id,ASI_MFM_Status__c FROM ASI_MFM_Plan__c Limit 1];
        System.Debug(plan);
        Savepoint sp = Database.setSavepoint();
        plan.ASI_MFM_Status__c = 'Final';
        update plan;
        try{
            delete plan;
        }catch(Exception e){
            System.Debug('Delete 1');
        }
        
		Database.rollback( sp );
        
        Savepoint sp2 = Database.setSavepoint();
        try{
            delete plan;
        }catch(Exception e){
            System.Debug('Delete 2');
		}
        Database.rollback( sp2 ); 
        
        
        List<ASI_MFM_Role_Prefix_Relationship__c> rolePrefixRelationshipList = ASI_MFM_CAP_HK_POGeneration.getRolePrefixRelationship('PO', 'HK', 'ASI_MFM_CAP_Prefix');
        system.debug('rolePrefixRelationshipList:' + rolePrefixRelationshipList);
        
        //List<ASI_MFM_Plan__c> opexPlan = [select id from ASI_MFM_Plan__c where ASI_MFM_Plan_Type__c ='OPEX' limit 1];
        ASI_MFM_CAP_HK_POGeneration.GenerateHKCAPEXPOFromPlan(new List<ASI_MFM_Plan__c>{plan});
        try{
            delete plan;
        }catch(Exception e){
            System.Debug('Delete 3');
		}
        
        Database.rollback( sp2 );
        
    }
    static testMethod void routineAfterInsert(){
        
        List<ASI_MFM_Role_Prefix_Relationship__c> prex = [SELECT id,ASI_MFM_Prefix__c,ASI_MFM_Role_Name__c,CreatedById FROM ASI_MFM_Role_Prefix_Relationship__c];
        List<ASI_MFM_Plan__c> planx = [Select id,ASI_MFM_Prefix__c,OwnerId From ASI_MFM_Plan__c];
        
        system.debug('prex' + prex);
        system.debug('planx' + planx);
        
        ASI_MFM_Plan__c plan2 = [SELECT id,ASI_MFM_Status__c,OwnerId FROM ASI_MFM_Plan__c Limit 1];
        //User u = [Select id,Name FROM User Where UserRoleId =: r.Id and ASI_MFM_Country__c = 'HK' Limit 1];
        User u = [Select id,userroleid,Name from user Where id =: plan2.OwnerId];
        userRole r = [SELECT ID, name, DeveloperName FROM userRole WHERE id =: u.userroleid Limit 1];
        

        System.Debug('Run As User:' + u);
        System.Debug('Run As Role:' + r);
        //Clone Test
        System.runAS(u){
            ASI_MFM_Plan__c plan = [SELECT id,ASI_MFM_Status__c FROM ASI_MFM_Plan__c Limit 1];
            system.debug([Select ASI_MFM_Prefix__c,ASI_MFM_Role_Name__c FROM ASI_MFM_Role_Prefix_Relationship__c]);
            system.debug(r.DeveloperName);
            //id prefix = [Select ASI_MFM_Prefix__c FROM ASI_MFM_Role_Prefix_Relationship__c Where ASI_MFM_Role_Name__c =: r.DeveloperName Limit 1].ASI_MFM_Prefix__c;
            List<ASI_MFM_Role_Prefix_Relationship__c> prefixrelist = [Select ASI_MFM_Prefix__c,ASI_MFM_Role_Name__c FROM ASI_MFM_Role_Prefix_Relationship__c];
            for(ASI_MFM_Role_Prefix_Relationship__c pr : prefixrelist){
                pr.ASI_MFM_Role_Name__c= r.DeveloperName;
			}
            update prefixrelist;
            ASI_MFM_Plan__c newPlan = new ASI_MFM_Plan__c
            (
                Name = 'AP Plan2',  
                recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_CAP_Plan'),
                ASI_MFM_Estimated_Depreciation_Start_Dat__c = date.today().adddays(1),
                ASI_MFM_Prefix__c = prefixrelist[0].ASI_MFM_Prefix__c,
                ASI_MFM_Plan_Type__c = 'CAPEX'
            );
            newPlan.ASI_MFM_Cloned_Plan_ID__c = plan.id;
            insert newPlan;
        }

    }
    static testMethod void routineAfterUpsert(){
        
    }
    static testMethod void routineBeforeInsert(){
        
    }
    static testMethod void routineBeforeUpdate(){
        
    }
    static testMethod void routineBeforeUpsert(){
 	}
    static testMethod void populateApprovers(){
        
    }
}
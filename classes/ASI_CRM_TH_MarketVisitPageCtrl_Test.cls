/*Created by Kevani Chow @introv 28/04/2016
*
* Testclass for ASI_CRM_TH_MarketVisitPageCtrl
*/


@isTest
public class ASI_CRM_TH_MarketVisitPageCtrl_Test{

public static testMethod void ASI_CRM_TH_MarketVisitPageCtrl_Test() {
        user u = [SELECT id FROM user WHERE profile.Name = 'System Administrator' and isactive = true LIMIT 1];
        
   
   ASI_CRM_Account_Group__c acc = new ASI_CRM_Account_Group__c(Name='Acc', ownerid=u.id);
   insert acc;
        
   Id RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Category__cASI_TH_CRM_Category');
   ASI_TH_CRM_Category__c Category = new ASI_TH_CRM_Category__c(RecordTypeId=RecordTypeId, Name='category', ownerid=u.id);
   insert Category;                                                                    
   
   RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Brand__cASI_TH_CRM_BRAND');
   ASI_MFM_Brand__c Brand= new ASI_MFM_Brand__c(RecordTypeId=RecordTypeId, Name='brand', ownerid=u.id, ASI_TH_CRM_Category__c=Category.id);
   insert Brand;
   
   RecordTypeId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_TH_CRM_Sub_brand');
   ASI_MFM_Sub_brand__c subBrand = new ASI_MFM_Sub_brand__c(RecordTypeId=RecordTypeId, Name='subbrand', ownerid=u.id, ASI_MFM_Brand__c=Brand.id, ASI_TH_CRM_Active__c=true);
   insert subBrand;
 
   ASI_CRM_TH_Picklist_Setting__c objectives = new ASI_CRM_TH_Picklist_Setting__c(ASI_CRM_Value__c ='objects1;objectives2', ASI_CRM_Object__c = 'ASI_CRM_Market_Visit__c', ASI_CRM_Record_Type__c = 'ASI_CRM_TH_MarketVisit', ASI_CRM_Field__c = 'ASI_CRM_Objectives__c', Name = 'MV Objectives');
   insert objectives;
   
   ASI_CRM_TH_Picklist_Setting__c who = new ASI_CRM_TH_Picklist_Setting__c(ASI_CRM_Value__c='who1;who2' , ASI_CRM_Object__c = 'ASI_CRM_Market_Visit__c', ASI_CRM_Record_Type__c = 'ASI_CRM_TH_MarketVisit', ASI_CRM_Field__c = 'ASI_CRM_Who__c' , Name = 'MV Who');
   insert who;

   RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Market_Visit__cASI_CRM_TH_MarketVisit');   
   ASI_CRM_Market_Visit__c mv = new ASI_CRM_Market_Visit__c(RecordTypeId=RecordTypeId, ownerid=u.id);
   insert mv;
 
     System.runAs(u) {
     //ASI_CRM_Market_Visit__c marketvisit = new ASI_CRM_Market_Visit__c();
     ApexPages.StandardController stdController = new ApexPages.StandardController(mv);
     ApexPages.currentPage().getParameters().put('accid', acc.id); 
      ApexPages.currentPage().getParameters().put('mvid', mv.id);
     ASI_CRM_TH_MarketVisitPageCtrl controller = new ASI_CRM_TH_MarketVisitPageCtrl(stdController);
       
       controller.idAcc=acc.id;
       controller.MarketVisit.ASI_CRM_Action_Plans__c='a';
       controller.MarketVisit.ASI_CRM_Insight__c='a';
       controller.MarketVisit.ASI_CRM_KeyIssuesOpportunities__c='a';
       controller.MarketVisit.ASI_CRM_Report_Summary__c='a';
       controller.MarketVisit.ASI_CRM_Objectives__c ='Others';
       controller.MarketVisit.ASI_CRM_Who__c ='Others';
       controller.getObjectiveList();
       controller.getWhoList();
       
       
       controller.getCategoryList();
       controller.SalesMovementList[0].CategoryId='0';
       controller.getBrandOption();
       controller.SalesMovementList[0].BrandId='0';
       controller.getsubBrandOption();
       controller.SalesMovementList[0].SubBrandId='0';
       controller.SalesMovementList[0].PromotionFrom=date.today();
       controller.SalesMovementList[0].PromotionTo=date.today();
       controller.SalesMovementList[0].SelectedPromoType=controller.getMultiSelectValues('Others');
       
       
       controller.addRow();
       controller.removeRow();
       controller.quickSave();
       
       controller.selectedObjectives = controller.getMultiSelectValues('Others');
       controller.selectedWho = controller.getMultiSelectValues('Others');
       
       controller.quickSave();
       
       
       controller.MarketVisit.ASI_CRM_Account_Name__c='a';
       controller.MarketVisit.ASI_CRM_Branch_Name__c='a';
       controller.MarketVisit.ASI_CRM_Attendee__c='a';
       controller.VisitDate=date.today();
       controller.SalesMovementList[0].CategoryId=Category.id;
       controller.getBrandOption();
       controller.SalesMovementList[0].BrandId=Brand.id;
       controller.getsubBrandOption();
       controller.SalesMovementList[0].SubBrandId=subBrand.id;
       controller.SalesMovementList[0].RSP=1;
       controller.MarketVisit.ASI_CRM_Objectives_Others__c='a';
       controller.MarketVisit.ASI_CRM_Who_Others__c='a';
       controller.SalesMovementList[0].PromotionOther='other';
       controller.SalesMovementList[0].Remark='a';
       
       controller.quickSave();
       controller.Save();
       controller.idMv=mv.id;
       controller.initial();
       
     
     
          }        
    }
}
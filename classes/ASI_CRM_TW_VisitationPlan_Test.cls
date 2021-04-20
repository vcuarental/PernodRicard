/*Created by Twinkle Li @introv 04/21/2015
*
* Testclass for:
* ASI_CRM_TW_VisitationPlanEditController,
* ASI_CRM_TW_MerchanVisitationPlan_Ctrl,
* ASI_CRM_TW_VisitationPlanClone_Ctrl,
* ASI_CRM_TW_VPDTodayMassCancel_Ctrl
* ASI_CRM_TW_VisitationPlanCalendarCtl
* 
*/

@isTest
public class ASI_CRM_TW_VisitationPlan_Test {
    static Id checkRecordType(string strsobject, string rt_name){
        id RT_id;
        List<recordType> sobjectlist = Global_RecordTypeCache.getRtList(strsobject);
            for (recordtype pl : sobjectlist ){
                if (pl.developername == rt_name)
                RT_id = pl.id;
            }
            system.debug('RT_id: ' + RT_id);
            return RT_id;           
    }
    
    static String getMonthString(Integer month){
        if(month == 1) return 'January';
        else if(month == 2) return 'February';
        else if(month == 3) return 'March';
        else if(month == 4) return 'April';
        else if(month == 5) return 'May';
        else if(month == 6) return 'June';
        else if(month == 7) return 'July';
        else if(month == 8) return 'August';
        else if(month == 9) return 'September';
        else if(month == 10) return 'October';
        else if(month == 11) return 'November';
        else if(month == 12) return 'December';
        return null;
    }
    
    /* For ASI_CRM_TW_VisitationPlanEditController, ASI_CRM_TW_VisitationPlanClone_Ctrl*/
    public static testMethod void ASI_CRM_TW_VisitationPlanEditController_Test() {          
        user u = [SELECT id, Name, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
        from user where id = :userInfo.getUserId()];
        System.runAs(u) {
            String recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            insertAccountList.add(new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id));    
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Wholesaler');        
            insertAccountList.add(new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id));            
            insert insertAccountList;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = insertAccountList[0].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12'
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
        
            recordTypeid = checkRecordType('ASI_HK_CRM_Visitation_Plan__c','ASI_CRM_TW_Visitation_Plan');
            List<ASI_HK_CRM_Visitation_Plan__c> visitationPlan = new List<ASI_HK_CRM_Visitation_Plan__c>();
            
            Date curMonth = Date.Today();
            Date preMonth = Date.Today().addMonths(-1);
            Date nextMonth = Date.Today().addMonths(1);
            
            visitationPlan.add(new ASI_HK_CRM_Visitation_Plan__c(
                Name = 'Test Visitation Plan (This Month)', 
                RecordTypeid = recordTypeid, 
                ASI_HK_CRM_Year__c = String.valueof(curMonth.year()), 
                ASI_HK_CRM_Month__c = getMonthString(curMonth.month()))
            );
            visitationPlan.add(new ASI_HK_CRM_Visitation_Plan__c(
                Name = 'Test Visitation Plan (Previous Month)', 
                RecordTypeid = recordTypeid, 
                ASI_HK_CRM_Year__c = String.valueof(preMonth.year()), 
                ASI_HK_CRM_Month__c = getMonthString(preMonth.month()))
            );
            insert visitationPlan;
            
            ASI_HK_CRM_Visitation_Plan__c visitationPlanToClone = new ASI_HK_CRM_Visitation_Plan__c(
                Name = 'Test Visitation Plan 2', 
                RecordTypeid = recordTypeid, 
                ASI_HK_CRM_Year__c = String.valueof(nextMonth.year()), 
                ASI_HK_CRM_Month__c = getMonthString(nextMonth.month()));
            insert visitationPlanToClone;
            
            Integer intYear = curMonth.year();
            Date myDate = Date.newInstance(curMonth.year() , curMonth.month(), curMonth.addDays(-1).day());
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> vpDetail = new List<ASI_HK_CRM_Visitation_Plan_Detail__c>();
            recordTypeid = checkRecordType('ASI_HK_CRM_Visitation_Plan_Detail__c','ASI_CRM_TW_Visitation_Plan_Detail');
            vpDetail.add(new ASI_HK_CRM_Visitation_Plan_Detail__c(RecordTypeid = recordTypeid,
                ASI_HK_CRM_Account__c = insertAccountList[0].id, ASI_HK_CRM_Visit_Date__c = myDate, ASI_HK_CRM_Visitation_Plan__c = visitationPlan[0].id,
                ASI_TH_CRM_Visit_Date_Time_From__c = myDate, ASI_TH_CRM_Visit_Date_Time_To__c = myDate)
            );
            
            myDate = Date.newInstance(preMonth.year(), preMonth.month(), 20);
            vpDetail.add(new ASI_HK_CRM_Visitation_Plan_Detail__c(RecordTypeid = recordTypeid, 
                ASI_HK_CRM_Account__c = insertAccountList[0].id, ASI_HK_CRM_Visit_Date__c = myDate, ASI_HK_CRM_Visitation_Plan__c = visitationPlan[1].id)
            );
            
            //today's VPD
            recordTypeid = checkRecordType('ASI_HK_CRM_Visitation_Plan_Detail__c','ASI_CRM_TW_Visitation_Plan_Detail');
            vpDetail.add(new ASI_HK_CRM_Visitation_Plan_Detail__c(RecordTypeid = recordTypeid, 
                ASI_HK_CRM_Account__c = insertAccountList[0].id, ASI_HK_CRM_Visit_Date__c = system.today(), ASI_HK_CRM_Visitation_Plan__c = visitationPlan[0].id, ASI_CRM_To_be_Cancelled__c = TRUE)
            );
            insert vpDetail;
            
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = [Select id, ASI_HK_CRM_Visitation_Plan__c from ASI_HK_CRM_Visitation_Plan_Detail__c limit 1];
            
            List<ASI_CRM_Holiday__c> listHoliday = new List<ASI_CRM_Holiday__c>();
            recordTypeid = checkRecordType('ASI_CRM_Holiday__c','ASI_CRM_TW_Holiday');
            Date myDateFrom = Date.newInstance(intYear , 5, 2);
            Date myDateTo = Date.newInstance(intYear , 5, 2);
            listHoliday.add(new ASI_CRM_Holiday__c(RecordTypeid = recordTypeid, ASI_CRM_Date_From__c=myDateFrom, ASI_CRM_Date_To__c=myDateTo));
            myDateFrom = Date.newInstance(intYear , 6, 1);
            myDateTo = Date.newInstance(intYear , 6, 1);
            listHoliday.add(new ASI_CRM_Holiday__c(RecordTypeid = recordTypeid, ASI_CRM_Date_From__c=myDateFrom, ASI_CRM_Date_To__c=myDateTo));
            /*myDateFrom = Date.newInstance(intYear , 3, 1);
            myDateTo = Date.newInstance(intYear , 7, 1);
            listHoliday.add(new ASI_CRM_Holiday__c(RecordTypeid = recordTypeid, ASI_CRM_Date_From__c=myDateFrom, ASI_CRM_Date_To__c=myDateTo));*/
            insert listHoliday;
            
            //Insert promotion
            recordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
            ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(Name = 'Promotion', RecordTypeid = recordTypeid, ASI_CRM_PurchaseDueDate__c = date.today(), ASI_HK_CRM_Promotion_Start_Date__c = date.today()-1, ASI_HK_CRM_Promotion_End_Date__c = date.today()+1);
            insert promotion;
            
            //Insert Promotion Status
            recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
            List<ASI_CRM_Promotion_Status__c> listPromoStatus = new List<ASI_CRM_Promotion_Status__c>();
            listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = insertAccountList[0].id, ASI_CRM_Supplier__c = insertAccountList[1].id, ASI_CRM_Unit__c = 100));
            insert listPromoStatus;
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(visitationPlanDetailList);
            ApexPages.currentPage().getParameters().put('id', visitationPlan[0].id);    
            ASI_CRM_TW_VisitationPlanEditController controller = new ASI_CRM_TW_VisitationPlanEditController(stdSetController);                          
            
            controller.initPage();       
            controller.quickSaveChanges();
            controller.saveChanges();          
            
            controller.searchAccountName = 'XXXXXX';
            controller.searchGrade= '';
            controller.searchCity = 'Test';
            controller.searchTown = 'Test';
            
            controller.ViewData();
            controller.quickSaveChanges();
            controller.saveChanges();
            
            controller.getSortDirection();
            controller.NameSearch();
            controller.ResetNameSearch();
            
            controller.sortExpression = 'ASC';
            controller.sortExpression = 'ASI_HK_CRM_Grade__c';        
            controller.setSortDirection('ASC');
            
            ApexPages.currentPage().getParameters().put('id', null);    
            controller = new ASI_CRM_TW_VisitationPlanEditController(stdSetController); 
            
            //clone VP
            ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(visitationPlanToClone);
            ApexPages.currentPage().getParameters().put('id', visitationPlanToClone.id);  
            
            ASI_CRM_TW_VisitationPlanClone_Ctrl controller1 = new ASI_CRM_TW_VisitationPlanClone_Ctrl(stdController); 
            controller1.inputVpd = visitationPlanDetailList[0];
            controller1.cloneVP();
            
            //Mass cancel today's VPD
            ASI_CRM_TW_VPDTodayMassCancel_Ctrl controller2 = new ASI_CRM_TW_VPDTodayMassCancel_Ctrl(stdController);
            controller2.vpdCancelReason.ASI_CRM_Cancel_Reason__c = 'cancel';
            controller2.Save();
            
            try {	
                delete vpDetail;
            }    
            catch(Exception ex){
                 Boolean expectedExceptionThrown = ex.getMessage().contains('Script-thrown exception') ? true : false; 
                 System.assertEquals(expectedExceptionThrown, false);
            }
            delete visitationPlanToClone;
        }
    }
}
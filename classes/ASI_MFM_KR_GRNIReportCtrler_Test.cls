/*
	Test Class for
	ASI_MFM_KR_GRNIReport_Batch
	ASI_MFM_KR_GRNIReportCtrler
*/
@isTest
public class ASI_MFM_KR_GRNIReportCtrler_Test {

	static testMethod void ASI_MFM_KR_GRNIReportCtrler_GenFail(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'test', Email='TestKR@testabc.com', 
            EmailEncodingKey='UTF-8', LastName='TestKR', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestKR@testabc.com');
        
        System.runAs(u) {
            
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            
			system.test.startTest();
			PageReference testPage = Page.ASI_MFM_KR_GRNIReport_Page;
			system.test.setCurrentPageReference(testPage);
            
            ASI_MFM_KR_GRNIReportCtrler con = new ASI_MFM_KR_GRNIReportCtrler();
            con.refreshReportStatus();
            con.GenerateGRNIReport();
            con.ViewGRNIReport();
            
            con.isGenerating = true;
            con.refreshReportStatus();
			system.test.stopTest();
            
        }
	}
    
    static testMethod void ASI_MFM_KR_GRNIReportCtrler_GenSuccess(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'test', Email='TestKR@testabc.com', 
            EmailEncodingKey='UTF-8', LastName='TestKR', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='TestKR@testabc.com');
        u.CompanyName = 'Pernod Ricard Korea';
        u.ASI_MFM_Country__c  = 'KR';
        u.BypassTriggers__c='ASI_MFM_KR_SetPOToDraft';
        insert u;
        
        System.runAs(u) {
            
            String fiscalYear = getFiscalYear();
                
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042');
            insert pjCode;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test Name',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c = true,
                                                                 ASI_MFM_Attachments_for_Plan__c = 'Test',
                                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_KR_AP_Code'));
            insert AP_Code;
            
            //Insert Custom Setting : ASI MFM Field ID Mappings
            List<ASI_MFM_Field_ID_Mappings__c> FieldIDDateList  = new List<ASI_MFM_Field_ID_Mappings__c>();
            ASI_MFM_Field_ID_Mappings__c f1 = new ASI_MFM_Field_ID_Mappings__c(Name='1',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Plan__c',ASI_MFM_Field_ID__c='1');
            FieldIDDateList.add(f1);
            ASI_MFM_Field_ID_Mappings__c f2 = new ASI_MFM_Field_ID_Mappings__c(Name='2',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_Prefix__c',ASI_MFM_Field_ID__c='2');
            FieldIDDateList.add(f2);// 
            ASI_MFM_Field_ID_Mappings__c f3 = new ASI_MFM_Field_ID_Mappings__c(Name='3',ASI_MFM_Object_Name__c= 'ASI_MFM_PO__c',ASI_MFM_Field_Name__c= 'ASI_MFM_PO_Name__c',ASI_MFM_Field_ID__c='3');
            FieldIDDateList.add(f3);
            insert FieldIDDateList;
        
            //Insert Plan
            ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c
                (
                    Name = 'Test Plan2',
                    ASI_MFM_Project_Code__c=pjCode.id,
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_MFM_KR_Plan_Read_Only'),
                    ASI_MFM_Start_Date__c =date.today(),
                    ASI_MFM_End_Date__c = date.today(),
                    ASI_MFM_Status__c='Approved',
                    OwnerId =u.id,
                    ASI_MFM_Plan_Name__c = 'Test Plan2',
                    ASI_MFM_Need_Attachment__c = true,
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
               
            insert plan;
            
            List<string> PlanIdList = new List<string>();
            PlanIdList.add(plan.id);
            
            //Insert Plan Line
            ASI_MFM_Plan_Line_Item__c planLine = new ASI_MFM_Plan_Line_Item__c
                (
                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Plan_Line_Item__cASI_MFM_KR_Plan_Line_Item'),
                    ASI_MFM_List_Item_Description__c = 'test description',
                    ASI_MFM_Total_Cost__c = 12,
                    ASI_MFM_Plan__c = plan.id,
                    //ASI_MFM_KR_subLedger__c = BrandCode.id,
                    ASI_MFM_AP_Code__c = AP_Code.id,    
                    ASI_MFM_Month_1_Cost__c = 1,
                    ASI_MFM_Month_2_Cost__c = 1,
                    ASI_MFM_Month_3_Cost__c = 1,
                    ASI_MFM_Month_4_Cost__c = 1,
                    ASI_MFM_Month_6_Cost__c = 1,
                    ASI_MFM_Month_7_Cost__c = 1,
                    ASI_MFM_Month_8_Cost__c = 1,
                    ASI_MFM_Month_9_Cost__c = 1,
                    ASI_MFM_Month_10_Cost__c = 1,
                    ASI_MFM_Month_11_Cost__c = 1,
                    ASI_MFM_Month_12_Cost__c = 1
                    //ASI_MFM_Sub_brand_Code__c = SubBrand.id
                );
            insert planLine;
            
            List<ASI_MFM_Plan_Line_Item__c> PlanLineList = new List<ASI_MFM_Plan_Line_Item__c>();
            PlanLineList.add(planLine);
            
            // Insert PR Header:
           ASI_MFM_Purchase_Request__c PR_Header = new ASI_MFM_Purchase_Request__c (ASI_MFM_Raised_Date__c = date.today(),
                                                                                     ASI_MFM_Comment__c = 'comment',
                                                                                     ASI_MFM_PR_Name__c='PR Name',
                                                                                     ASI_MFM_Company_Code__c = 'PRK',
                                                                                     ASI_MFM_PR_Date__c = date.today(), 
                                                                                     ASI_MFM_Plan__c = plan.id,
                                                                                     ASI_MFM_Currency__c = 'KRW',
                                                                                     ASI_MFM_Service_Item_POSM__c = 'POSM',
                                                                                     //ASI_MFM_Ship_To__c = acc1.ID,
                                                                                     ASI_MFM_Status__c = 'Approved',
                                                                                     recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request__cASI_MFM_KR_Purchase_Request_Read_Only'));
            
            insert PR_Header; 
            
            ASI_MFM_Purchase_Request_Line__c PR_Line = new ASI_MFM_Purchase_Request_Line__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_MFM_KR_Purchase_Request_Line'),
                                                                                             ASI_MFM_Plan_Line_Item__c = planLine.id,
                                                                                             ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                                                             ASI_MFM_AP_Code__c = AP_Code.ID,
                                                                                             ASI_MFM_Quantity__c = 10,
                                                                                             ASI_MFM_UOM__c = 'EA',
                                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                                             ASI_MFM_Estimated_PR_budget__c = 100,
                                                                                             ASI_MFM_Delivery_Date__c= date.today(),
                                                                                             ASI_MFM_Description__c = 'Description',
                                                                                             ASI_MFM_Unit_Cost__c = 100);
            insert PR_Line;
            
            
            //Supplier: 
            Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
            insert acc2;
            
            ASI_MFM_PO__c po = new ASI_MFM_PO__c(ASI_MFM_Supplier_Name__c = acc2.id,
                                                 ASI_MFM_Purchase_Request__c = PR_Header.id,
                                                 ASI_MFM_PO_Raised_Date__c = date.today(),  
                                                 ASI_MFM_Status__c = 'Approved',
                                                 ASI_MFM_Plan__c = plan.id,
                                                 ASI_MFM_VAT__c = 10.00,
                                                 ASI_MFM_Company_Code__c = '222',
                                                 recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO'));
            insert po; 
            
            
            ASI_MFM_PO_Line_Item__c po_line = new ASI_MFM_PO_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_KR_PO_Line_Item'),
                                                                            ASI_MFM_PO__c = po.id,
                                                                            //ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                            ASI_MFM_Unit_Price__c = 1000,  
                                                                            ASI_MFM_KR_Quantity__c = 100,    
                                                                            ASI_MFM_Amount__c = 100000,
                                                                            ASI_MFM_Delivery_Date__c =  date.today(),
                                                                            ASI_MFM_G_L_Date__c = date.today(),   
                                                                            ASI_MFM_Purchase_Request_Line__c = PR_Line.id   
                                                                            );
            
            insert po_line;
            
    
            System.debug(Limits.getDMLRows());
           
            
             ASI_MFM_PO_Receipt__c POR_Header = new ASI_MFM_PO_Receipt__c(ASI_MFM_PO__c = po.id,
                                                                        ASI_MFM_Status__c = 'Draft',
                                                                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_KR_PO_Receipt'));
            insert POR_Header;
     
            ASI_MFM_PO_Receipt_Item__c POR_Line = new ASI_MFM_PO_Receipt_Item__c (ASI_MFM_PO_Receipt__c = POR_Header.id,
                                                                                  ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                  ASI_MFM_Plan_Line_Item__c=planLine.id,
                                                                                  ASI_MFM_Quantity__c = 1,
                                                                                  ASI_MFM_PO__c = po.id,
                                                                                  ASI_MFM_Paid__c= false,
                                                                                  ASI_MFM_ACC_Verify__c=false,
                                                                                  ASI_MFM_ETL__c =true,
                                                                                  ASI_MFM_Receipt_Date__c = date.today(),
                                                                                  recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_KR_PO_Receipt_item'));
            
            insert POR_Line;
            Test.startTest();   
            List<string> POReceiptIdList = new List<string>();
            POReceiptIdList.add(POR_Line.id);
            
            ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Submitted',
                                                                       recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                       ASI_MFM_Supplier_Name__c = acc2.id,
                                                                       ASI_MFM_PO__c = po.id,
                                                                       ASI_MFM_Company_Code__c = '222',
                                                                       ASI_MFM_Send_Approval_Email__c=true,
                                                                       ASI_MFM_Is_Direct_Payment__c = true,
                                                                       ASI_MFM_Invoice_Number__c = 'OLD INVOICE NUMBER');  
            
            insert PaymentHeader;
            
            
            ASI_MFM_Payment_Line_Item__c PaymentLine = new ASI_MFM_Payment_Line_Item__c (recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_KR_Payment_Line_Item'),
                                                                                         ASI_MFM_Payment__c = PaymentHeader.id,
                                                                                         ASI_MFM_Payment_Amount__c = 1,
                                                                                         ASI_MFM_Invoice_Number__c = 'Invoice Number',
                                                                                         ASI_MFM_PO__c = po.id,
                                                                                         ASI_MFM_PO_Line_Item__c = po_line.id,
                                                                                         ASI_MFM_ETL__c =true,
                                                                                         ASI_MFM_Beneficiary_Customer__c = customer1.id);
            //ASI_MFM_PO_Receipt_Item__c = POR_Line.id);
            insert PaymentLine;
            
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId()); 
            
            
			PageReference testPage = Page.ASI_MFM_KR_GRNIReport_Page;
			system.test.setCurrentPageReference(testPage);
            
            ASI_MFM_KR_GRNIReportCtrler con = new ASI_MFM_KR_GRNIReportCtrler();
            con.refreshReportStatus();
            con.GenerateGRNIReport();
            con.ViewGRNIReport();
            
            con.isGenerating = true;
            con.refreshReportStatus();
			Test.stopTest();   

            
        }
	}
    
    public static string getFiscalYear(){
        Integer orgFiscalMonth = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;  //i.e. 7
        Date orgFiscalYear = Date.newinstance(system.today().year(), orgFiscalMonth, 1);    
        Datetime GMTdate = Datetime.now();
        String yearA1 = GMTdate.format('YY');
        Integer yearA0 = Integer.valueOf(yearA1) -1;
        Integer yearA2 = Integer.valueOf(yearA1) +1;
        String Current_Fiscal_year;
        
        if(system.today()< orgFiscalYear){
            Current_Fiscal_year = 'FY' + yearA0 + yearA1 ;
        }else{
            Current_Fiscal_year = 'FY' + yearA1 + yearA2 ;
        }
        
        return Current_Fiscal_year;
    }
    
}
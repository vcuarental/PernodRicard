/*
	Test Class for
	ASI_MFM_KR_OffsetPaymentUploadCtrl
	ASI_MFM_KR_OffsetPaymentLineExport
*/

@isTest
public class ASI_MFM_KR_OffsetPaymentUploadCtrl_Test {

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
    
	static testMethod void ASI_MFM_KR_OffsetPaymentUploadCtrl_Test1(){
        
        	String fiscalYear = getFiscalYear();
                        
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042',ASI_MFM_Offset__c=true);
            insert pjCode;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test Name',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c = false,
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
                    //OwnerId =u.id,
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
        
        
        	
        	PageReference testPage = Page.ASI_MFM_KR_OffsetPaymentUpload;
	        testPage.getParameters().put('pId', plan.id);
			system.test.setCurrentPageReference(testPage);
        
	        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);
            ASI_MFM_KR_OffsetPaymentUploadCtrl con = new ASI_MFM_KR_OffsetPaymentUploadCtrl(stdController);
	        String CurrencyName = con.CurrencyName;
	        ASI_MFM_KR_OffsetPaymentUploadCtrl.retrieveExchangeRate();
        
        	PageReference testPage2 = Page.ASI_MFM_KR_OffsetPaymentLineExportPage;
	        testPage2.getParameters().put('Planid', String.valueOf(plan.id));
	        testPage2.getParameters().put('CompanyName', 'PRKI');
			system.test.setCurrentPageReference(testPage2);
        
        	ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(plan);
            ASI_MFM_KR_OffsetPaymentLineExport con2 = new ASI_MFM_KR_OffsetPaymentLineExport(stdController2);
			con2.exportToExcel();
        	
    }
    
	static testMethod void ASI_MFM_KR_OffsetPaymentUploadCtrl_Test2(){
        
        String fiscalYear = getFiscalYear();
                        
            ASI_MFM_Project_Code__c pjCode = new ASI_MFM_Project_Code__c(name='PJ Code',recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Project_Code__cASI_MFM_KR_Project_Code'),ASI_MFM_Code__c='1042',ASI_MFM_Offset__c=false);
            insert pjCode;
            
            ASI_CRM_AccountsAdditionalField__c customer1 = new ASI_CRM_AccountsAdditionalField__c(Name='Test Name',recordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_KR_Venue'));
            insert customer1;
            
            //Insert AP Code
            ASI_MFM_AP_Code__c  AP_Code = new ASI_MFM_AP_Code__c(ASI_MFM_AP_Code__c = 'Code', 
                                                                 Name = 'AP Code Test',
                                                                 ASI_MFM_PRPO_Needed__c = false,
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
                    //OwnerId =u.id,
                    ASI_MFM_Plan_Name__c = 'Test Plan2',
                    ASI_MFM_Need_Attachment__c = true,
                    ASI_MFM_Fiscal_year__c = FiscalYear
                );
               
            insert plan;
        
        	PageReference testPage = Page.ASI_MFM_KR_OffsetPaymentUpload;
	        testPage.getParameters().put('pId', plan.id);
			system.test.setCurrentPageReference(testPage);
        
	        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(plan);
            ASI_MFM_KR_OffsetPaymentUploadCtrl con = new ASI_MFM_KR_OffsetPaymentUploadCtrl(stdController);
	        String CurrencyName = con.CurrencyName;
	        ASI_MFM_KR_OffsetPaymentUploadCtrl.retrieveExchangeRate();
        
        	PageReference testPage2 = Page.ASI_MFM_KR_OffsetPaymentLineExportPage;
	        testPage2.getParameters().put('Planid', String.valueOf(plan.id));
	        testPage2.getParameters().put('CompanyName', 'PRKI');
			system.test.setCurrentPageReference(testPage2);
        
        	ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(plan);
            ASI_MFM_KR_OffsetPaymentLineExport con2 = new ASI_MFM_KR_OffsetPaymentLineExport(stdController2);
			con2.exportToExcel();
    }
    
}
/**
 * @File Name          : ASI_CRM_CN_Payment_Header_ControlleTest.cls
 * @Description        : 
 * @Author             : pengchen@bluelinksys.com
 * @Group              : 
 * @Last Modified By   : pengchen@bluelinksys.com
 * @Last Modified On   : 5/18/2020, 9:42:03 AM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/18/2020   pengchen@bluelinksys.com     Initial Version
**/
@isTest
public class ASI_CRM_CN_Payment_Header_ControlleTest {
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
            ASI_CRM_CN_Overpayment_Reason__c='其他－需填写具体原因',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
            ASI_TH_CRM_Status__c='Submitted',
            ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
            
        test.startTest();
            System.debug(Limits.getDMLRows());
            ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
            ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_PaymentRequest__c());
            ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            // con.refresh();
            // con.updateRecord();
            // con.BRSFReport();
            
        
        
            ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
            sc = new ApexPages.standardController(prs[0]);
            con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            con.GoReturn();
            con.CancelBRSFChange();
            con.cancel();
            con.digit_formatting(3,19999999);
            con.digit_formatting(3,1);
            con.saveDate();
            con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addDays(10);
            con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addDays(10);
            con.saveDate();
            con.PSFReport();
            con.BRSFReport();
            con.doCancel();
            con.GoURL();
            con.GoEditHeader();
            con.GoEditDetail();
            con.GoEditPayee();
            
            con.updatePOVersion();
            con.updateRecord();
            con.regenerateBRSFVol();
            con.updatePayeeRecord();
            con.submitApproval();
            con.refresh();
            List<SObject> sobj =  ASI_CRM_CN_Payment_Header_Controller.retrieveFreeGoods('ASI_MFM_Item_Group__c',null);
            String freeGoodsJSON = '{"WSCDE001OFCSH0011":{"paymentRequestLines":[],"paymentRequestLineOutletWS":{"attributes":{"type":"ASI_TH_CRM_PaymentRequestLineItem__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_TH_CRM_PaymentRequestLineItem__c/aC29E0000004aj8SAA"},"ASI_CRM_CN_Actual_Vol__c":0,"ASI_CRM_CN_Allow_Changing_Incentive__c":false,"ASI_CRM_Customer__c":"aBpD00000008n69KAA","'+
            'ASI_CRM_CN_Rebate_Percent__c":0.00,"ASI_CRM_CN_Total_Payable__c":0.00,"ASI_CRM_CN_Wholesaler__c":"aBpD00000008pSkKAI","ASI_CRM_CTD_Actual_Purchase_Value__c":11933243.16,"ASI_CRM_CTD_Actual_Vol__c":'+
            '140.0300000000000001,"ASI_TH_CRM_Payment_Request__c":"aC39E0000004H5cSAE","ASI_CRM_CN_WS_Intake_9L__c":1546.82000000000003,"ASI_CRM_CN_Outlet_Intake_9L__c":140.0300000000000001,"'+
            'ASI_CRM_CN_POS_Volume__c":0.00,"ASI_CRM_CN_POS_Value__c":0.00,"ASI_CRM_CTD_Actual_Retail_Value__c":1008109.86,"ASI_CRM_Actual_Value_Base__c":1008109.86,"Id":"aC29E0000004aj8SAA","RecordTypeId":"'+
            '0129E000000XBWgQAO","ASI_CRM_CN_CRM_Code__c":"WSCDE001OFCSH0011","CurrencyIsoCode":"JPY","ASI_CRM_Customer__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/'+
            'sobjects/ASI_CRM_AccountsAdditionalField__c/aBpD00000008n69KAA"},"ASI_CRM_CN_CRM_Code__c":"OFCSH0011","Name":"长沙携手酒业营销有限公司(OFCSH0011)","Id":"aBpD00000008n69KAA","RecordTypeId":"'+
            '012D00000007NLPIA2","CurrencyIsoCode":"HKD"},"ASI_CRM_CN_Wholesaler__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_CRM_AccountsAdditionalField__c/aBpD00000008pSkKAI"},"ASI_CRM_CN_CRM_Code__c":"WSCDE001","Name":"湖南星城一品(WSCDE001)","Id":"aBpD00000008pSkKAI","RecordTypeId":"012D00000007NLOIA2","CurrencyIsoCode'+
            '":"HKD"},"ASI_TH_CRM_Payment_Request__r":{"attributes":{"type":"ASI_TH_CRM_PaymentRequest__c","url":"/services/data/v46.0/sobjects/ASI_TH_CRM_PaymentRequest__c/aC39E0000004H5cSAE"},"'+
            'ASI_CRM_CN_Promotion_Type__c":"Outlet Promotion","Id":"aC39E0000004H5cSAE","RecordTypeId":"012D00000007NMIIA2","CurrencyIsoCode":"JPY"},"RecordType":{"attributes":{"type":"RecordType","url":"/services'+
            '/data/v46.0/sobjects/RecordType/0129E000000XBWgQAO"},"DeveloperName":"ASI_CRM_CN_Payment_Request_Detail_Outlet_WS","Id":"0129E000000XBWgQAO"}},"moduleWrappers":[],"module":{"attributes":{"type":"'+
            'ASI_CRM_Module__c"}},"ASI_CRM_Application_Payment_Amount":null}}';
            ApexPages.currentPage().getParameters().put('freeGoodsJSON',freeGoodsJSON);
            ApexPages.currentPage().getParameters().put('pricePromotionJSON',freeGoodsJSON);
            con.updateDetailRecord();
            
            con.addNew_Cash();
            con.addNew_Discount();
            con.addNew_CD(); 
            con.updatePayeeRecord();
            
            // con.addNew_Cash();
            // con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
            // con.clone_Cash();
            // for(integer i : con.Payee_Item_Map_CASH.keyset()){
            //     con.rowidCASH = i;
            //     con.RemoveRow_Cash();
            // }
            
            // con.addNew_Discount();
            // con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
            // con.clone_Discount();
            // for(integer i : con.Payee_Item_Map_Discount.keyset()){
            //     con.rowidDiscount = i;
            //     con.RemoveRow_Discount();
            // }
            
            // con.addNew_CD();            
            // con.rowidCD = con.Payee_Item_Map_CD.size()-1;
            // con.clone_CD();
            // for(integer i : con.Payee_Item_Map_CD.keyset()){
            //     con.rowidCD = i;
            //     con.RemoveRow_CD();
            // }
            // con.updatePayeeRecord();
            
            
            // con.addNew_PSF();
            // con.updatePSF();
            // con.rowidPSF = con.PSF_Item_Map.size()-1;
            // con.clone_PSF();
            // for(integer i : con.PSF_Item_Map.keyset()){
            //     con.rowidPSF = i;
            //     con.removeRow_PSF();
            // }            
            // con.updatePSF();
  
            // ASI_CRM_CN_Payment_Header_Controller.findCashPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            // //ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            // ASI_CRM_CN_Payment_Header_Controller.findDiscountPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            // //ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            // //ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();   
    }

    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST3() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1),
            ASI_TH_CRM_Status__c='Submitted',
            ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
            
        test.startTest();
            System.debug(Limits.getDMLRows());
            ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
            ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_PaymentRequest__c());
            ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            con.refresh();
            con.updateRecord();
            con.BRSFReport();
            
        
        
            ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
            sc = new ApexPages.standardController(prs[0]);
            con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            // con.GoReturn();
            // con.CancelBRSFChange();
            // con.cancel();
            // con.digit_formatting(3,19999999);
            // con.digit_formatting(3,1);
            // con.saveDate();
            // con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addDays(10);
            // con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addDays(10);
            // con.saveDate();
            // con.PSFReport();
            // con.BRSFReport();
            // con.doCancel();
            // con.GoURL();
            // con.GoEditHeader();
            // con.GoEditDetail();
            // con.GoEditPayee();
            
            // con.updatePOVersion();
            // con.updateRecord();
            // con.regenerateBRSFVol();
            // con.updatePayeeRecord();
            // con.submitApproval();
            // con.refresh();
            // con.updateDetailRecord();
            
            // con.addNew_Cash();
            // con.addNew_Discount();
            // con.addNew_CD(); 
            // con.updatePayeeRecord();
            
            con.addNew_Cash();
            con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
            con.clone_Cash();
            for(integer i : con.Payee_Item_Map_CASH.keyset()){
                con.rowidCASH = i;
                con.RemoveRow_Cash();
            }
            
            con.addNew_Discount();
            con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
            con.clone_Discount();
            for(integer i : con.Payee_Item_Map_Discount.keyset()){
                con.rowidDiscount = i;
                con.RemoveRow_Discount();
            }
            
            con.addNew_CD();            
            con.rowidCD = con.Payee_Item_Map_CD.size()-1;
            con.clone_CD();
            for(integer i : con.Payee_Item_Map_CD.keyset()){
                con.rowidCD = i;
                con.RemoveRow_CD();
            }
            con.updatePayeeRecord();
            
            
            con.addNew_PSF();
            con.updatePSF();
            con.rowidPSF = con.PSF_Item_Map.size()-1;
            con.clone_PSF();
            for(integer i : con.PSF_Item_Map.keyset()){
                con.rowidPSF = i;
                con.removeRow_PSF();
            }            
            con.updatePSF();
  
            ASI_CRM_CN_Payment_Header_Controller.findCashPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            //ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            ASI_CRM_CN_Payment_Header_Controller.findDiscountPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            //ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            //ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();   
    }

    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST4() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-90),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(-30),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        ASI_TH_CRM_PaymentRequest__c pr1 = new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-90),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-30),
            ASI_TH_CRM_Status__c = 'Draft',
            ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'));
        prs.add(pr1);

        ASI_TH_CRM_PaymentRequest__c pr2 = new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-90),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-30), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request'));
        prs.add(pr2);
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
            
        test.startTest();
            System.debug(Limits.getDMLRows());
            ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
            ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
            ApexPages.standardController sc = new ApexPages.standardController(prs[0]);
            ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            con.refresh();
            con.PH.ASI_CRM_CN_Adjustment__c = 110;
            List<SObject> sobj =  ASI_CRM_CN_Payment_Header_Controller.retrieveFreeGoods('ASI_MFM_Item_Group__c',null);
            String freeGoodsJSON = '{"WSCDE001OFCSH0011":{"paymentRequestLines":[],"paymentRequestLineOutletWS":{"attributes":{"type":"ASI_TH_CRM_PaymentRequestLineItem__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_TH_CRM_PaymentRequestLineItem__c/aC29E0000004aj8SAA"},"ASI_CRM_CN_Actual_Vol__c":0,"ASI_CRM_CN_Allow_Changing_Incentive__c":false,"ASI_CRM_Customer__c":"aBpD00000008n69KAA","'+
            'ASI_CRM_CN_Rebate_Percent__c":0.00,"ASI_CRM_CN_Total_Payable__c":0.00,"ASI_CRM_CN_Wholesaler__c":"aBpD00000008pSkKAI","ASI_CRM_CTD_Actual_Purchase_Value__c":11933243.16,"ASI_CRM_CTD_Actual_Vol__c":'+
            '140.0300000000000001,"ASI_TH_CRM_Payment_Request__c":"aC39E0000004H5cSAE","ASI_CRM_CN_WS_Intake_9L__c":1546.82000000000003,"ASI_CRM_CN_Outlet_Intake_9L__c":140.0300000000000001,"'+
            'ASI_CRM_CN_POS_Volume__c":0.00,"ASI_CRM_CN_POS_Value__c":0.00,"ASI_CRM_CTD_Actual_Retail_Value__c":1008109.86,"ASI_CRM_Actual_Value_Base__c":1008109.86,"Id":"aC29E0000004aj8SAA","RecordTypeId":"'+
            '0129E000000XBWgQAO","ASI_CRM_CN_CRM_Code__c":"WSCDE001OFCSH0011","CurrencyIsoCode":"JPY","ASI_CRM_Customer__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/'+
            'sobjects/ASI_CRM_AccountsAdditionalField__c/aBpD00000008n69KAA"},"ASI_CRM_CN_CRM_Code__c":"OFCSH0011","Name":"长沙携手酒业营销有限公司(OFCSH0011)","Id":"aBpD00000008n69KAA","RecordTypeId":"'+
            '012D00000007NLPIA2","CurrencyIsoCode":"HKD"},"ASI_CRM_CN_Wholesaler__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_CRM_AccountsAdditionalField__c/aBpD00000008pSkKAI"},"ASI_CRM_CN_CRM_Code__c":"WSCDE001","Name":"湖南星城一品(WSCDE001)","Id":"aBpD00000008pSkKAI","RecordTypeId":"012D00000007NLOIA2","CurrencyIsoCode'+
            '":"HKD"},"ASI_TH_CRM_Payment_Request__r":{"attributes":{"type":"ASI_TH_CRM_PaymentRequest__c","url":"/services/data/v46.0/sobjects/ASI_TH_CRM_PaymentRequest__c/aC39E0000004H5cSAE"},"'+
            'ASI_CRM_CN_Promotion_Type__c":"Outlet Promotion","Id":"aC39E0000004H5cSAE","RecordTypeId":"012D00000007NMIIA2","CurrencyIsoCode":"JPY"},"RecordType":{"attributes":{"type":"RecordType","url":"/services'+
            '/data/v46.0/sobjects/RecordType/0129E000000XBWgQAO"},"DeveloperName":"ASI_CRM_CN_Payment_Request_Detail_Outlet_WS","Id":"0129E000000XBWgQAO"}},"moduleWrappers":[],"module":{"attributes":{"type":"'+
            'ASI_CRM_Module__c"}},"ASI_CRM_Application_Payment_Amount":null}}';
            ApexPages.currentPage().getParameters().put('freeGoodsJSON',freeGoodsJSON);
            ApexPages.currentPage().getParameters().put('pricePromotionJSON',freeGoodsJSON);
            con.UpdateDetailRecord();
            con.regenerateBRSFVol();
            con.reDirectToTaxSavingPage();
            con.GoReturn();

            con.PH.ASI_CRM_New_FY_Payment__c = false;
            con.GetAllSpecialPromotionTypeSetting();

            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-120);
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(60);
            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-60);
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-120);
            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-120);
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-60);
            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = null;
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-60);
            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(60);
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = null;
            con.checkBRSFDate();
            con.CutOffDate(0);
            con.CutOffDate(-1);
            con.CutOffDate(32);

            User u = new User();
            u.id = UserInfo.getUserId();
            u.LanguageLocaleKey ='zh_CN';
            update u;

            con.refresh();
            con.PH.ASI_CRM_CN_Adjustment__c = 110;
            con.UpdateDetailRecord();
            con.regenerateBRSFVol();
            con.reDirectToTaxSavingPage();
            con.GoReturn();

            con.PH.ASI_CRM_New_FY_Payment__c = false;
            con.GetAllSpecialPromotionTypeSetting();

            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-120);
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(60);
            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-60);
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-120);
            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-120);
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-60);
            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = null;
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-60);
            con.checkBRSFDate();

            con.PH.ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(60);
            con.PH.ASI_CRM_CN_BRSF_End_Date__c = null;
            con.checkBRSFDate();
            con.CutOffDate(0);
            con.CutOffDate(-1);
            con.CutOffDate(32);

            con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addDays(-60);
            con.ph.ASI_CRM_CN_BRSF_End_Date__c  = con.CutOffDate(16);
            con.regenerateBRSFVol();
        test.stopTest();   
    }
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST_2() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;

        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-8),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(8),
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c=system.today().addDays(-2),
            ASI_CRM_CN_BRSF_End_Date__c=system.today().addDays(-1), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
       
        test.startTest();
            ASI_CRM_CN_Payment_Header_Controller.findDiscountWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            ASI_CRM_CN_Payment_Header_Controller.findOtherWholesalerSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
            ASI_CRM_CN_Payment_Header_Controller.findOtherPayeeSObjects('ASI_TH_CRM_PaymentRequest__c','',prs[0].id);
        test.stopTest();
    }
    
    
    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST2() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        ASI_CRM_SpecialPromotionTypeSetting__c specialPromotion = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_New_FY_Promotion_Type__c = true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert specialPromotion;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-90),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(-30),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
            ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-90),
            ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-30),
            ASI_TH_CRM_Status__c='Submitted',
            ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_TH_CRM_Status__c='Approved',
            ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-90),
            ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(-30), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
            
        test.startTest();
            ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
            ApexPages.StandardController sc = new ApexPages.standardController(new ASI_TH_CRM_PaymentRequest__c());
            ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            con.othertype = null;
            con.payableAmount = null;
            con.OverPaymentReason = null;
            con.OtherReason = null;
            con.division = null;
            con.BRSF_Item_Map = null;
            con.Save_BRSF_Item = null;
            con.OTP_Item_Map = null;
            con.Save_OTP_Item = null;
            // con.refresh();
            // con.updateRecord();
            // con.BRSFReport();
        
            
        
            ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
            sc = new ApexPages.standardController(prs[0]);
            con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            //con.GoReturn();
            con.CancelBRSFChange();
            //con.cancel();
            con.digit_formatting(3,19999999);
            con.digit_formatting(3,1);
            con.saveDate();
            con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addMonths(-8);
            con.ph.ASI_CRM_CN_BRSF_End_Date__c  = date.today().addMonths(1);
            con.saveDate();
            //con.PSFReport();
            //con.BRSFReport();
            //con.doCancel();
            //con.GoURL();
            con.GoEditHeader();
            con.GoEditDetail();
            con.GoEditPayee();
            
            con.updatePOVersion();
            con.updateRecord();
            con.regenerateBRSFVol();
            con.updatePayeeRecord();
            //con.submitApproval();
            con.refresh();
            List<SObject> sobj =  ASI_CRM_CN_Payment_Header_Controller.retrieveFreeGoods('ASI_MFM_Item_Group__c',null);
            String freeGoodsJSON = '{"WSCDE001OFCSH0011":{"paymentRequestLines":[],"paymentRequestLineOutletWS":{"attributes":{"type":"ASI_TH_CRM_PaymentRequestLineItem__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_TH_CRM_PaymentRequestLineItem__c/aC29E0000004aj8SAA"},"ASI_CRM_CN_Actual_Vol__c":0,"ASI_CRM_CN_Allow_Changing_Incentive__c":false,"ASI_CRM_Customer__c":"aBpD00000008n69KAA","'+
            'ASI_CRM_CN_Rebate_Percent__c":0.00,"ASI_CRM_CN_Total_Payable__c":0.00,"ASI_CRM_CN_Wholesaler__c":"aBpD00000008pSkKAI","ASI_CRM_CTD_Actual_Purchase_Value__c":11933243.16,"ASI_CRM_CTD_Actual_Vol__c":'+
            '140.0300000000000001,"ASI_TH_CRM_Payment_Request__c":"aC39E0000004H5cSAE","ASI_CRM_CN_WS_Intake_9L__c":1546.82000000000003,"ASI_CRM_CN_Outlet_Intake_9L__c":140.0300000000000001,"'+
            'ASI_CRM_CN_POS_Volume__c":0.00,"ASI_CRM_CN_POS_Value__c":0.00,"ASI_CRM_CTD_Actual_Retail_Value__c":1008109.86,"ASI_CRM_Actual_Value_Base__c":1008109.86,"Id":"aC29E0000004aj8SAA","RecordTypeId":"'+
            '0129E000000XBWgQAO","ASI_CRM_CN_CRM_Code__c":"WSCDE001OFCSH0011","CurrencyIsoCode":"JPY","ASI_CRM_Customer__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/'+
            'sobjects/ASI_CRM_AccountsAdditionalField__c/aBpD00000008n69KAA"},"ASI_CRM_CN_CRM_Code__c":"OFCSH0011","Name":"长沙携手酒业营销有限公司(OFCSH0011)","Id":"aBpD00000008n69KAA","RecordTypeId":"'+
            '012D00000007NLPIA2","CurrencyIsoCode":"HKD"},"ASI_CRM_CN_Wholesaler__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_CRM_AccountsAdditionalField__c/aBpD00000008pSkKAI"},"ASI_CRM_CN_CRM_Code__c":"WSCDE001","Name":"湖南星城一品(WSCDE001)","Id":"aBpD00000008pSkKAI","RecordTypeId":"012D00000007NLOIA2","CurrencyIsoCode'+
            '":"HKD"},"ASI_TH_CRM_Payment_Request__r":{"attributes":{"type":"ASI_TH_CRM_PaymentRequest__c","url":"/services/data/v46.0/sobjects/ASI_TH_CRM_PaymentRequest__c/aC39E0000004H5cSAE"},"'+
            'ASI_CRM_CN_Promotion_Type__c":"Outlet Promotion","Id":"aC39E0000004H5cSAE","RecordTypeId":"012D00000007NMIIA2","CurrencyIsoCode":"JPY"},"RecordType":{"attributes":{"type":"RecordType","url":"/services'+
            '/data/v46.0/sobjects/RecordType/0129E000000XBWgQAO"},"DeveloperName":"ASI_CRM_CN_Payment_Request_Detail_Outlet_WS","Id":"0129E000000XBWgQAO"}},"moduleWrappers":[],"module":{"attributes":{"type":"'+
            'ASI_CRM_Module__c"}},"ASI_CRM_Application_Payment_Amount":null}}';
            ApexPages.currentPage().getParameters().put('freeGoodsJSON',freeGoodsJSON);
            ApexPages.currentPage().getParameters().put('pricePromotionJSON',freeGoodsJSON);
            con.updateDetailRecord();
            
            con.addNew_Cash();
            con.addNew_Discount();
            con.addNew_CD(); 
            con.updatePayeeRecord();
            
            con.addNew_Cash();
            con.rowidCASH = con.Payee_Item_Map_CASH.size()-1;
            con.clone_Cash();
            for(integer i : con.Payee_Item_Map_CASH.keyset()){
                con.rowidCASH = i;
                con.RemoveRow_Cash();
            }
            
            con.addNew_Discount();
            con.rowidDiscount = con.Payee_Item_Map_Discount.size()-1;
            con.clone_Discount();
            for(integer i : con.Payee_Item_Map_Discount.keyset()){
                con.rowidDiscount = i;
                con.RemoveRow_Discount();
            }
            
            con.addNew_CD();            
            con.rowidCD = con.Payee_Item_Map_CD.size()-1;
            con.clone_CD();
            for(integer i : con.Payee_Item_Map_CD.keyset()){
                con.rowidCD = i;
                con.RemoveRow_CD();
            }
            con.updatePayeeRecord();
            
            
            con.addNew_PSF();
            con.updatePSF();
            con.rowidPSF = con.PSF_Item_Map.size()-1;
            con.clone_PSF();
            for(integer i : con.PSF_Item_Map.keyset()){
                con.rowidPSF = i;
                con.removeRow_PSF();
            }            
            con.updatePSF();
        test.stopTest();   
    }

    static testMethod void ASI_CRM_CN_Payment_Header_Controller_TEST5() {
        Account acc = new Account(Name='TEST', RecordTypeId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Outlet'));
        insert acc;

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
        insert newChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',
            RecordTypeId=rtOutlet,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id,ASI_CRM_CN_NewChannel__c=newChannel.Id));
        insert a2s;
        
        a2s = [SELECT Id, ASI_CRM_Account__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id=:a2s[0].Id OR Id=:a2s[1].Id];
        
        User currentUser = [SELECT id, name, Managerid, ASI_CRM_CN_Prefix__c FROM USER WHERE id =:UserInfo.getUserId()];
        
        ASI_CRM_SpecialPromotionTypeSetting__c specialPromotion = new ASI_CRM_SpecialPromotionTypeSetting__c(ASI_CRM_New_FY_Promotion_Type__c = true, recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_SpecialPromotionTypeSetting__cASI_CRM_CN_SpecialPromotionTypeSetting'));
        insert specialPromotion;
        
        list<ASI_HK_CRM_Running_Number__c> rns = new list<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;

        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c (
            ASI_CRM_CN_Competitor__c=false);
        insert brand;
        
        list<ASI_CRM_Sub_Brand_Grade__c> grades = new list<ASI_CRM_Sub_Brand_Grade__c>();
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST1'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST2'));
        grades.add(new ASI_CRM_Sub_Brand_Grade__c (Name='TEST3'));
        insert grades;

        list<ASI_CRM_Sub_Brand_Group__c> groups = new list<ASI_CRM_Sub_Brand_Group__c>();
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='TEST'));
        groups.add(new ASI_CRM_Sub_Brand_Group__c(Name='Chivas 12'));
        insert groups;
            
        list<ASI_MFM_Sub_brand__c> subBrands = new list<ASI_MFM_Sub_brand__c>();
        for(ASI_CRM_Sub_Brand_Grade__c grade :grades) {
            for(ASI_CRM_Sub_Brand_Group__c gp: groups) {
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST1',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST2',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
                subBrands.add(new ASI_MFM_Sub_brand__c (
                    Name='TEST3',
                    ASI_MFM_Brand__c=brand.Id,
                    ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                    ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                    ASI_CRM_CN_SubBrand_Group_c__c=gp.Id));
            }
            subBrands.add(new ASI_MFM_Sub_brand__c (
                Name='TEST3',
                ASI_MFM_Brand__c=brand.Id,
                ASI_CRM_CN_COnvfactor_Ltocr12_C__c=1,
                ASI_CRM_CN_Sub_brand_Grade__c=grade.Id,
                ASI_CRM_CN_SubBrand_Group_c__c=null));
        }
        insert subBrands;

             
        ASI_TH_CRM_Contract__c ct = new ASI_TH_CRM_Contract__c(
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Final',
            ASI_CRM_CN_PO_Start_Date__c = system.today().addDays(-90),
            ASI_CRM_CN_PO_End_Date__c = system.today().addDays(30),
            ASI_TH_CRM_Outlet__c=a2s[0].ASI_CRM_Account__c, 
            ASI_CRM_CN_PO_Version__c = '0.0',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=a2s[0].Id,ASI_CRM_Volume_Option__c = 'Normal'
            );
        insert ct;
        
        ASI_CRM_Contract_Cost__c contractCost = new ASI_CRM_Contract_Cost__c(
            ASI_CRM_CN_Contract__c = ct.id,
            ASI_CRM_CN_Estimate_Amount__c = 100000,
            ASI_CRM_CN_Cost_Type__c = 'Variable',
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_Contract_Cost__cASI_CRM_CN_Contract_Cost')
        );
        insert contractCost;

        list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ctis = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        list<ASI_CRM_CN_Covered_Outlet__c> cos = new list<ASI_CRM_CN_Covered_Outlet__c>();
        for(ASI_MFM_Sub_brand__c subBrand :subBrands) {
            ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=subBrand.Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        }
        ctis.add(new ASI_CRM_CN_Contract_BRSF_Line_Item__c(
                ASI_CRM_CN_Contract__c=ct.Id,
                ASI_CRM_CN_Est_Monthly_Qty__c=1,
                ASI_CRM_CN_Contract_Monthly_Qty__c=1,
                ASI_CRM_CN_Est_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Contract_BRSF_Per_Bottle__c=10,
                ASI_CRM_CN_Sub_Brand__c=null,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Contract_BRSF_Line_Item__cASI_CRM_CN_Contract_BRSF_Line_Item')
            ));
        cos.add(new ASI_CRM_CN_Covered_Outlet__c(
            ASI_CRM_CN_Contract__c=ct.Id,
            ASI_CRM_CN_Outlet__c=a2s[0].Id,
                recordtypeid = Global_RecordTypeCache.getRTID('ASI_CRM_CN_Covered_Outlet__cASI_CRM_CN_Covered_Outlet')));
        
        insert ctis;
        insert cos;
        
        list<ASI_TH_CRM_PaymentRequest__c> prs = new list<ASI_TH_CRM_PaymentRequest__c>();
        prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
            ASI_CRM_CN_Payment_Type__c = 'Cash',
            ASI_CRM_CN_Adjustment__c=80,
            ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-90),
            ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(30),
            ASI_TH_CRM_Status__c='Submitted',
            ASI_CRM_CN_Return_Comments__c='a', recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));

        // prs.add(new ASI_TH_CRM_PaymentRequest__c(ASI_TH_CRM_Contract__c=ct.Id,
        //     ASI_TH_CRM_Status__c='Approved',
        //     ASI_CRM_CN_BRSF_Start_Date__c = system.today().addDays(-90),
        //     ASI_CRM_CN_BRSF_End_Date__c = system.today().addDays(30), recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_CN_Payment_Request')));
        insert prs;
        
        Id rtPRI = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_BRSF');
        
        list<ASI_TH_CRM_PaymentRequestLineItem__c> pris = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {            
            //brsf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=rtPRI,
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1
            ));
            //psf
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_Other'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
            pris.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
                ASI_TH_CRM_Payment_Request__c=pr.Id,
                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_CN_Payment_Request_Detail_PSF'),
                ASI_CRM_CN_Target_BT__c=1, ASI_CRM_CN_Actual_Vol__c=1, ASI_CRM_CN_Total_Payable__c=1, ASI_CRM_CN_Bottle_Collected__c=1,
                ASI_CRM_CN_Expense_Type__c='PRC - Down Payment - On Premise'
            ));
        }
        insert pris;
        
        list<ASI_CRM_CN_PH_Payee_Line_Item__c> LPayee = new List<ASI_CRM_CN_PH_Payee_Line_Item__c>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs) {
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Cash'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'Discount'));
            LPayee.add(new ASI_CRM_CN_PH_Payee_Line_Item__c(recordtypeid =Global_RecordTypeCache.getRTID('ASI_CRM_CN_PH_Payee_Line_Item__cASI_CRM_CN_Payee'),ASI_CRM_CN_Payment_Request__c = pr.id,ASI_CRM_CN_Type__c = 'CD'));
        }
        insert LPayee;
        
        list<ApexPages.StandardController> scons = new list<ApexPages.StandardController>();
        for(ASI_TH_CRM_PaymentRequest__c pr :prs)
            scons.add(new ApexPages.StandardController(pr));
        
        User u = new User();
        u.id = UserInfo.getUserId();
        u.LanguageLocaleKey ='zh_CN';
        update u;
        test.startTest();
            ApexPages.CurrentPage().getparameters().put('contractid', ct.id);
            ApexPages.CurrentPage().getparameters().put('id', prs[0].id);
            ApexPages.StandardController sc = new ApexPages.standardController(prs[0]);
            ASI_CRM_CN_Payment_Header_Controller con = new ASI_CRM_CN_Payment_Header_Controller(sc);
            con.digit_formatting(3,19999999);
            con.digit_formatting(3,1);
            List<SObject> sobj =  ASI_CRM_CN_Payment_Header_Controller.retrieveFreeGoods('ASI_MFM_Item_Group__c',null);
            String freeGoodsJSON = '{"WSCDE001OFCSH0011":{"paymentRequestLines":[],"paymentRequestLineOutletWS":{"attributes":{"type":"ASI_TH_CRM_PaymentRequestLineItem__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_TH_CRM_PaymentRequestLineItem__c/aC29E0000004aj8SAA"},"ASI_CRM_CN_Actual_Vol__c":0,"ASI_CRM_CN_Allow_Changing_Incentive__c":false,"ASI_CRM_Customer__c":"aBpD00000008n69KAA","'+
            'ASI_CRM_CN_Rebate_Percent__c":0.00,"ASI_CRM_CN_Total_Payable__c":0.00,"ASI_CRM_CN_Wholesaler__c":"aBpD00000008pSkKAI","ASI_CRM_CTD_Actual_Purchase_Value__c":11933243.16,"ASI_CRM_CTD_Actual_Vol__c":'+
            '140.0300000000000001,"ASI_TH_CRM_Payment_Request__c":"aC39E0000004H5cSAE","ASI_CRM_CN_WS_Intake_9L__c":1546.82000000000003,"ASI_CRM_CN_Outlet_Intake_9L__c":140.0300000000000001,"'+
            'ASI_CRM_CN_POS_Volume__c":0.00,"ASI_CRM_CN_POS_Value__c":0.00,"ASI_CRM_CTD_Actual_Retail_Value__c":1008109.86,"ASI_CRM_Actual_Value_Base__c":1008109.86,"Id":"aC29E0000004aj8SAA","RecordTypeId":"'+
            '0129E000000XBWgQAO","ASI_CRM_CN_CRM_Code__c":"WSCDE001OFCSH0011","CurrencyIsoCode":"JPY","ASI_CRM_Customer__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/'+
            'sobjects/ASI_CRM_AccountsAdditionalField__c/aBpD00000008n69KAA"},"ASI_CRM_CN_CRM_Code__c":"OFCSH0011","Name":"长沙携手酒业营销有限公司(OFCSH0011)","Id":"aBpD00000008n69KAA","RecordTypeId":"'+
            '012D00000007NLPIA2","CurrencyIsoCode":"HKD"},"ASI_CRM_CN_Wholesaler__r":{"attributes":{"type":"ASI_CRM_AccountsAdditionalField__c","url":"/services/data/v46.0/sobjects/'+
            'ASI_CRM_AccountsAdditionalField__c/aBpD00000008pSkKAI"},"ASI_CRM_CN_CRM_Code__c":"WSCDE001","Name":"湖南星城一品(WSCDE001)","Id":"aBpD00000008pSkKAI","RecordTypeId":"012D00000007NLOIA2","CurrencyIsoCode'+
            '":"HKD"},"ASI_TH_CRM_Payment_Request__r":{"attributes":{"type":"ASI_TH_CRM_PaymentRequest__c","url":"/services/data/v46.0/sobjects/ASI_TH_CRM_PaymentRequest__c/aC39E0000004H5cSAE"},"'+
            'ASI_CRM_CN_Promotion_Type__c":"Outlet Promotion","Id":"aC39E0000004H5cSAE","RecordTypeId":"012D00000007NMIIA2","CurrencyIsoCode":"JPY"},"RecordType":{"attributes":{"type":"RecordType","url":"/services'+
            '/data/v46.0/sobjects/RecordType/0129E000000XBWgQAO"},"DeveloperName":"ASI_CRM_CN_Payment_Request_Detail_Outlet_WS","Id":"0129E000000XBWgQAO"}},"moduleWrappers":[],"module":{"attributes":{"type":"'+
            'ASI_CRM_Module__c"}},"ASI_CRM_Application_Payment_Amount":null}}';
            ApexPages.currentPage().getParameters().put('freeGoodsJSON',freeGoodsJSON);
            ApexPages.currentPage().getParameters().put('pricePromotionJSON',freeGoodsJSON);
            con.ph.ASI_CRM_CN_BRSF_Start_Date__c  = date.today().addDays(-60);
            con.ph.ASI_CRM_CN_BRSF_End_Date__c  = con.CutOffDate(16);
            con.updateDetailRecord();
            
            
        test.stopTest();   
    }

}
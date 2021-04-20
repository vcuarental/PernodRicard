@isTest(seealldata=true)
/***************************
Tested Classes: 
1. ASI_CRM_CN_InputWSEvaluationItemCon 
2. ASI_CRM_CN_WSEvaluationPDFCtrl
3. ASI_CRM_WS_Evaluation_TriggerClass
4. ASI_CRM_WS_Evaluation_BeforeInsert
*****************************/
public class ASI_CRM_CN_WSEvaluation_Test{
    static testMethod void ASI_CRM_CN_InputWSEvaluation_Test() {
               
        //Account required field objects
        ASI_CRM_Region__c region = new ASI_CRM_Region__c(name='test');
        insert region;
        
        ASI_CRM_Division__c divi = new ASI_CRM_Division__c(name='test',ASI_CRM_Region__c=region.id);
        insert divi;
            
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(name='test',ASI_CRM_Division__c=divi.id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST',ASI_CRM_CN_Area__c=area.id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        //create T1 WS
        string WSRTid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        ASI_CRM_AccountsAdditionalField__c acc = new ASI_CRM_AccountsAdditionalField__c(Name='TEST',ASI_CRM_CN_WS_Tier__c='T1',RecordTypeId=WSRTid,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        insert acc;
        
        //create T2
        list<ASI_CRM_AccountsAdditionalField__c> allT2 = new list<ASI_CRM_AccountsAdditionalField__c>();
        string T2RTid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        ASI_CRM_AccountsAdditionalField__c t2 = new ASI_CRM_AccountsAdditionalField__c(Name='T2',ASI_CRM_CN_T1_WS1__c=acc.id,RecordTypeId=T2RTId,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        allT2.add(t2);
        ASI_CRM_AccountsAdditionalField__c t3 = new ASI_CRM_AccountsAdditionalField__c(Name='T3',ASI_CRM_CN_T1_WS1__c=acc.id,RecordTypeId=T2RTId,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        allT2.add(t3);
        insert allT2;
        
        //WS Evaluation
        string WSEvalRTId = Global_RecordTypeCache.getRTId('ASI_CRM_WS_Evaluation__cASI_CRM_CN_WS_Target');
        list<ASI_CRM_WS_Evaluation__c> lstWSEval = new list<ASI_CRM_WS_Evaluation__c>();
        lstWSEval.add(new ASI_CRM_WS_Evaluation__c(ASI_CRM_T1_WS_Addition__c=acc.id,ASI_CRM_Fiscal_Year__c='2013/2014',ASI_CRM_Quarter__c='Q1 (Jul - Sept)'));
        lstWSEval.add(new ASI_CRM_WS_Evaluation__c(ASI_CRM_T1_WS_Addition__c=acc.id,ASI_CRM_Fiscal_Year__c='2013/2014',ASI_CRM_Quarter__c='Q1 (Jul - Sept)'));
        insert lstWSEval;
        
        //Target List
        string TargetRTId = Global_RecordTypeCache.getRTId('ASI_CRM_WS_Target__cASI_CRM_CN_WS_Target');
        ASI_CRM_WS_Target__c Target1 = new ASI_CRM_WS_Target__c(ASI_CRM_T2_WS__c=t2.id,RecordTypeId=TargetRTId,ASI_CRM_Fiscal_Year__c='2013/2014',ASI_CRM_Quarter__c='Q1 (Jul - Sept)',ASI_CRM_GS_Target__c=1000,ASI_CRM_Vol_Target__c=800);
        insert Target1;
        
        ASI_TH_CRM_Category__c category = new ASI_TH_CRM_Category__c(ASI_TH_CRM_English_Name__c='Wine');
        insert category;
        
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(ASI_TH_CRM_Category__c=category.id);
        insert brand;
        
        //Subbrand
        string SBRTId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
        ASI_MFM_Sub_brand__c Sb1 = new ASI_MFM_Sub_brand__c(Name='sb',RecordTypeId=SBRTId,ASI_MFM_Brand__c=brand.id,ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_CRM__c=true,ASI_MFM_Active_for_FOC__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=2,ASI_CRM_CN_Standard_Bottle_Size__c=700,ASI_MFM_Sub_brand_Code__c='TEST');
        ASI_MFM_Sub_brand__c Sb2 = new ASI_MFM_Sub_brand__c(Name='sb',RecordTypeId=SBRTId,ASI_MFM_Brand__c=brand.id,ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_CRM__c=true,ASI_MFM_Active_for_FOC__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=2,ASI_CRM_CN_Standard_Bottle_Size__c=700,ASI_MFM_Sub_brand_Code__c='AB1');
        ASI_MFM_Sub_brand__c Sb3 = new ASI_MFM_Sub_brand__c(Name='sb',RecordTypeId=SBRTId,ASI_MFM_Brand__c=brand.id,ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_CRM__c=true,ASI_MFM_Active_for_FOC__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=2,ASI_CRM_CN_Standard_Bottle_Size__c=700,ASI_MFM_Sub_brand_Code__c='GL5');
        ASI_MFM_Sub_brand__c Sb4 = new ASI_MFM_Sub_brand__c(Name='sb',RecordTypeId=SBRTId,ASI_MFM_Brand__c=brand.id,ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_CRM__c=true,ASI_MFM_Active_for_FOC__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=2,ASI_CRM_CN_Standard_Bottle_Size__c=700,ASI_MFM_Sub_brand_Code__c='JCO');
        ASI_MFM_Sub_brand__c Sb5 = new ASI_MFM_Sub_brand__c(Name='sb',RecordTypeId=SBRTId,ASI_MFM_Brand__c=brand.id,ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_CRM__c=true,ASI_MFM_Active_for_FOC__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=2,ASI_CRM_CN_Standard_Bottle_Size__c=700,ASI_MFM_Sub_brand_Code__c='HLM');
        ASI_MFM_Sub_brand__c Sb6 = new ASI_MFM_Sub_brand__c(Name='sb',RecordTypeId=SBRTId,ASI_MFM_Brand__c=brand.id,ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_CRM__c=true,ASI_MFM_Active_for_FOC__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=2,ASI_CRM_CN_Standard_Bottle_Size__c=700,ASI_MFM_Sub_brand_Code__c='ABS');
        insert new List<ASI_MFM_Sub_brand__c>{Sb1,Sb2,Sb3,Sb4,Sb5,Sb6};
        
        //Subbrand Volume Data for T2
        list<ASI_CRM_Subbrand_Volume__c> sbList = new list<ASI_CRM_Subbrand_Volume__c>();
        ASI_CRM_Subbrand_Volume__c Vol1 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-06-30'),ASI_CRM_T1_Depletion__c=1000,ASI_CRM_T2_Depletion__c=2000,ASI_CRM_PR_Direct__c=0,ASI_CRM_WS_INV__c=100,ASI_CRM_PR_DIRECT_L50__c=30,ASI_CRM_T2_Depletion_L50__c=20,ASI_CRM_PR_DIRECT_GS_L50__c=30,ASI_CRM_T1_Depletion_L50__c=45,ASI_CRM_T2_DepletiontoT3__c=500,ASI_CRM_T1_Depletion_GS__c=200,ASI_CRM_T2_receive_scan__c=100);
        ASI_CRM_Subbrand_Volume__c Vol2 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-07-31'),ASI_CRM_T1_Depletion__c=450,ASI_CRM_T2_Depletion__c=100,ASI_CRM_PR_Direct__c=100,ASI_CRM_WS_INV__c=-50,ASI_CRM_PR_DIRECT_L50__c=30,ASI_CRM_T2_Depletion_L50__c=20,ASI_CRM_PR_DIRECT_GS_L50__c=50,ASI_CRM_T1_Depletion_L50__c=50,ASI_CRM_T2_DepletiontoT3__c=500,ASI_CRM_T1_Depletion_GS__c=200,ASI_CRM_T2_receive_scan__c=100);
        ASI_CRM_Subbrand_Volume__c Vol3 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-08-31'),ASI_CRM_T1_Depletion__c=1000,ASI_CRM_T2_Depletion__c=2000,ASI_CRM_PR_Direct__c=1500,ASI_CRM_WS_INV__c=-50,ASI_CRM_PR_DIRECT_L50__c=30,ASI_CRM_T2_Depletion_L50__c=20,ASI_CRM_PR_DIRECT_GS_L50__c=30,ASI_CRM_T1_Depletion_L50__c=45,ASI_CRM_T2_DepletiontoT3__c=500,ASI_CRM_T1_Depletion_GS__c=200,ASI_CRM_T2_receive_scan__c=100);
        ASI_CRM_Subbrand_Volume__c Vol4 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-09-30'),ASI_CRM_T1_Depletion__c=1000,ASI_CRM_T2_Depletion__c=2000,ASI_CRM_PR_Direct__c=1500,ASI_CRM_WS_INV__c=-40,ASI_CRM_PR_DIRECT_L50__c=30,ASI_CRM_T2_Depletion_L50__c=20,ASI_CRM_PR_DIRECT_GS_L50__c=30,ASI_CRM_T1_Depletion_L50__c=45,ASI_CRM_T2_DepletiontoT3__c=500,ASI_CRM_T1_Depletion_GS__c=200,ASI_CRM_T2_receive_scan__c=100);
        ASI_CRM_Subbrand_Volume__c Vol5 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb2.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-07-31'));
        ASI_CRM_Subbrand_Volume__c Vol6 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb3.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-07-31'));
        ASI_CRM_Subbrand_Volume__c Vol7 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb4.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-07-31'));
        ASI_CRM_Subbrand_Volume__c Vol8 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb5.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-07-31'));
        ASI_CRM_Subbrand_Volume__c Vol9 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb6.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-07-31'));
        

        insert new List<ASI_CRM_Subbrand_Volume__c>{Vol1,Vol2,Vol3,Vol4,Vol5,Vol6,Vol7,Vol8,Vol9};
        
        Test.startTest();
        
        ApexPages.StandardController scons = new ApexPages.StandardController(lstWSEval[0]);
        ApexPages.currentPage().getParameters().put('id', scons.getId());
        ASI_CRM_CN_InputWSEvaluationItemCon con = new ASI_CRM_CN_InputWSEvaluationItemCon(scons);
        con.init();
        con.CreateLineItems();
        con.Save();
        
        ASI_CRM_CN_InputWSEvaluationItemCon.AbsExeptionClass AbsExeption = new ASI_CRM_CN_InputWSEvaluationItemCon.AbsExeptionClass();
        
        scons = new ApexPages.StandardController(lstWSEval[1]);
        ApexPages.currentPage().getParameters().put('id', scons.getId());
        con = new ASI_CRM_CN_InputWSEvaluationItemCon(scons);
        con.init();
        con.CreateLineItems();
        con.Save();
        
        Test.stopTest();
    }
    static testMethod void ASI_CRM_CN_WSEvaluationPDF_Test() {
        
        //Account required field objects
        ASI_CRM_Region__c region = new ASI_CRM_Region__c(name='test');
        insert region;
        
        ASI_CRM_Division__c divi = new ASI_CRM_Division__c(name='test',ASI_CRM_Region__c=region.id);
        insert divi;
            
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(name='test',ASI_CRM_Division__c=divi.id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST',ASI_CRM_CN_Area__c=area.id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        //Approval User
        User user1 = [SELECT name FROM User where IsActive=true AND Profile.Name LIKE '%Administrator%' ORDER BY Name DESC LIMIT 1];
        
        //Fix Route Approval List
        ASI_CRM_Fix_Approval_Route__c far = new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c='WS Evaluation',ASI_CRM_CN_Region_Area_Channel__c=divi.name,ASI_CRM_CN_Approver_1__c=UserInfo.getUserId(),ASI_CRM_CN_Approver_2__c=user1.id);
        insert far;
        
        //create T1 WS
        string WSRTid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        ASI_CRM_AccountsAdditionalField__c acc = new ASI_CRM_AccountsAdditionalField__c(Name='TEST',ASI_CRM_CN_WS_Tier__c='T1',RecordTypeId=WSRTid,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        insert acc;
        
        //create T2
        list<ASI_CRM_AccountsAdditionalField__c> allT2 = new list<ASI_CRM_AccountsAdditionalField__c>();
        string T2RTid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        ASI_CRM_AccountsAdditionalField__c t2 = new ASI_CRM_AccountsAdditionalField__c(Name='T2',ASI_CRM_CN_T1_WS1__c=acc.id,RecordTypeId=T2RTId,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        allT2.add(t2);
        ASI_CRM_AccountsAdditionalField__c t3 = new ASI_CRM_AccountsAdditionalField__c(Name='T3',ASI_CRM_CN_T1_WS1__c=acc.id,RecordTypeId=T2RTId,ASI_CRM_CN_CCity__c=city.id,ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        allT2.add(t3);
        insert allT2;
        
        //WS Evaluation
        string WSEvalRTId = Global_RecordTypeCache.getRTId('ASI_CRM_WS_Evaluation__cASI_CRM_CN_WS_Target');
        ASI_CRM_WS_Evaluation__c WSEval = new ASI_CRM_WS_Evaluation__c(ASI_CRM_T1_WS_Addition__c=acc.id,ASI_CRM_Fiscal_Year__c='2013/2014',ASI_CRM_Quarter__c='Q1 (Jul - Sept)');
        insert WSEval;
        
        //Target List
        string TargetRTId = Global_RecordTypeCache.getRTId('ASI_CRM_WS_Target__cASI_CRM_CN_WS_Target');
        ASI_CRM_WS_Target__c Target1 = new ASI_CRM_WS_Target__c(ASI_CRM_T2_WS__c=t2.id,RecordTypeId=TargetRTId,ASI_CRM_Fiscal_Year__c='2013/2014',ASI_CRM_Quarter__c='Q1 (Jul - Sept)',ASI_CRM_GS_Target__c=1000,ASI_CRM_Vol_Target__c=800);
        insert Target1;
        
        //Subbrand
        string SBRTId = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand');
        ASI_MFM_Sub_brand__c Sb1 = new ASI_MFM_Sub_brand__c(Name='sb',RecordTypeId=SBRTId,ASI_TH_CRM_Active__c=true,ASI_MFM_Active_for_CRM__c=true,ASI_MFM_Active_for_FOC__c=true,ASI_CRM_CN_COnvfactor_Ltocr12_C__c=2,ASI_CRM_CN_Standard_Bottle_Size__c=700);
        insert Sb1;
        
        //Subbrand Volume Data for T2
        list<ASI_CRM_Subbrand_Volume__c> sbList = new list<ASI_CRM_Subbrand_Volume__c>();
        ASI_CRM_Subbrand_Volume__c Vol1 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-06-30'),ASI_CRM_T1_Depletion__c=1000,ASI_CRM_T2_Depletion__c=2000,ASI_CRM_PR_Direct__c=0,ASI_CRM_WS_INV__c=100,ASI_CRM_PR_DIRECT_L50__c=30,ASI_CRM_T2_Depletion_L50__c=20,ASI_CRM_PR_DIRECT_GS_L50__c=30,ASI_CRM_T1_Depletion_L50__c=45,ASI_CRM_T2_DepletiontoT3__c=500,ASI_CRM_T1_Depletion_GS__c=200,ASI_CRM_T2_receive_scan__c=100);
        sbList.add(Vol1);
        ASI_CRM_Subbrand_Volume__c Vol2 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-07-31'),ASI_CRM_T1_Depletion__c=450,ASI_CRM_T2_Depletion__c=100,ASI_CRM_PR_Direct__c=100,ASI_CRM_WS_INV__c=-50,ASI_CRM_PR_DIRECT_L50__c=30,ASI_CRM_T2_Depletion_L50__c=20,ASI_CRM_PR_DIRECT_GS_L50__c=50,ASI_CRM_T1_Depletion_L50__c=50,ASI_CRM_T2_DepletiontoT3__c=500,ASI_CRM_T1_Depletion_GS__c=200,ASI_CRM_T2_receive_scan__c=100);
        sbList.add(Vol2);
        ASI_CRM_Subbrand_Volume__c Vol3 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-08-31'),ASI_CRM_T1_Depletion__c=1000,ASI_CRM_T2_Depletion__c=2000,ASI_CRM_PR_Direct__c=1500,ASI_CRM_WS_INV__c=-50,ASI_CRM_PR_DIRECT_L50__c=30,ASI_CRM_T2_Depletion_L50__c=20,ASI_CRM_PR_DIRECT_GS_L50__c=30,ASI_CRM_T1_Depletion_L50__c=45,ASI_CRM_T2_DepletiontoT3__c=500,ASI_CRM_T1_Depletion_GS__c=200,ASI_CRM_T2_receive_scan__c=100);
        sbList.add(Vol3);
        ASI_CRM_Subbrand_Volume__c Vol4 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-09-30'),ASI_CRM_T1_Depletion__c=1000,ASI_CRM_T2_Depletion__c=2000,ASI_CRM_PR_Direct__c=1500,ASI_CRM_WS_INV__c=-40,ASI_CRM_PR_DIRECT_L50__c=30,ASI_CRM_T2_Depletion_L50__c=20,ASI_CRM_PR_DIRECT_GS_L50__c=30,ASI_CRM_T1_Depletion_L50__c=45,ASI_CRM_T2_DepletiontoT3__c=500,ASI_CRM_T1_Depletion_GS__c=200,ASI_CRM_T2_receive_scan__c=100);
        sbList.add(Vol4);
        ASI_CRM_Subbrand_Volume__c Vol5 = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Subbrand__c=Sb1.id,ASI_CRM_Account__c=t2.id,ASI_CRM_End_Date__c=Date.valueof('2013-07-31'));
        sbList.add(Vol5);
        insert sbList;
        
        //create WS Evaluation line item
        list<ASI_CRM_WS_Evaluation_Items__c> wsli = new list<ASI_CRM_WS_Evaluation_Items__c>();
        ASI_CRM_WS_Evaluation_Items__c li = new ASI_CRM_WS_Evaluation_Items__c(ASI_CRM_WS_Evaluation__c=WSEval.id,ASI_CRM_WS2__c=t3.id,ASI_CRM_Achieve_Rate__c=90,ASI_CRM_CN_Actual_Value__c=0,ASI_CRM_CN_Actual_Volume__c=2800,ASI_CRM_Calculated_Incentive__c=98,ASI_CRM_Data_Quality_Rate__c=80,ASI_CRM_incentive__c=100,ASI_CRM_Scan_Rate__c=90,ASI_CRM_Target__c=100,ASI_CRM_CN_Target_Value__c=0,ASI_CRM_CN_Target_Volume__c=299,ASI_CRM_CN_WS_Code__c='0.029887.03',ASI_CRM_WS_GS__c=1082,ASI_CRM_Comment__c='comments');
        wsli.add(li);
        ASI_CRM_WS_Evaluation_Items__c li1 = new ASI_CRM_WS_Evaluation_Items__c(ASI_CRM_WS_Evaluation__c=WSEval.id,ASI_CRM_WS2__c=t3.id,ASI_CRM_Achieve_Rate__c=90,ASI_CRM_CN_Actual_Value__c=25000,ASI_CRM_CN_Actual_Volume__c=0,ASI_CRM_Calculated_Incentive__c=98,ASI_CRM_Data_Quality_Rate__c=80,ASI_CRM_incentive__c=100,ASI_CRM_Scan_Rate__c=98,ASI_CRM_Target__c=100,ASI_CRM_CN_Target_Value__c=200,ASI_CRM_CN_Target_Volume__c=0,ASI_CRM_CN_WS_Code__c='0.029887.03',ASI_CRM_WS_GS__c=1082,ASI_CRM_Comment__c='comments');
        wsli.add(li1);
        ASI_CRM_WS_Evaluation_Items__c li2 = new ASI_CRM_WS_Evaluation_Items__c(ASI_CRM_WS_Evaluation__c=WSEval.id,ASI_CRM_WS2__c=t3.id);
        wsli.add(li2);
        ASI_CRM_WS_Evaluation_Items__c li3 = new ASI_CRM_WS_Evaluation_Items__c(ASI_CRM_WS_Evaluation__c=WSEval.id,ASI_CRM_WS2__c=t3.id,ASI_CRM_Achieve_Rate__c=90,ASI_CRM_CN_Actual_Value__c=10,ASI_CRM_CN_Actual_Volume__c=0,ASI_CRM_Calculated_Incentive__c=98,ASI_CRM_Data_Quality_Rate__c=80,ASI_CRM_incentive__c=100,ASI_CRM_Scan_Rate__c=98,ASI_CRM_Target__c=100,ASI_CRM_CN_Target_Value__c=2,ASI_CRM_CN_Target_Volume__c=0,ASI_CRM_CN_WS_Code__c='0.029887.03',ASI_CRM_WS_GS__c=1082,ASI_CRM_Comment__c='comments');
        wsli.add(li3);
        ASI_CRM_WS_Evaluation_Items__c li4 = new ASI_CRM_WS_Evaluation_Items__c(ASI_CRM_WS_Evaluation__c=WSEval.id,ASI_CRM_WS2__c=t3.id,ASI_CRM_Achieve_Rate__c=90,ASI_CRM_CN_Actual_Value__c=0,ASI_CRM_CN_Actual_Volume__c=100,ASI_CRM_Calculated_Incentive__c=98,ASI_CRM_Data_Quality_Rate__c=80,ASI_CRM_incentive__c=100,ASI_CRM_Scan_Rate__c=90,ASI_CRM_Target__c=2,ASI_CRM_CN_Target_Value__c=0,ASI_CRM_CN_Target_Volume__c=2,ASI_CRM_CN_WS_Code__c='0.029887.03',ASI_CRM_WS_GS__c=1082,ASI_CRM_Comment__c='comments');
        wsli.add(li4);
        ASI_CRM_WS_Evaluation_Items__c li5 = new ASI_CRM_WS_Evaluation_Items__c(ASI_CRM_WS_Evaluation__c=WSEval.id,ASI_CRM_WS2__c=t3.id,ASI_CRM_Achieve_Rate__c=90,ASI_CRM_CN_Actual_Value__c=100,ASI_CRM_CN_Actual_Volume__c=0,ASI_CRM_Calculated_Incentive__c=98,ASI_CRM_Data_Quality_Rate__c=80,ASI_CRM_incentive__c=100,ASI_CRM_Scan_Rate__c=98,ASI_CRM_Target__c=100,ASI_CRM_CN_Target_Value__c=20,ASI_CRM_CN_Target_Volume__c=0,ASI_CRM_CN_WS_Code__c='0.029887.03',ASI_CRM_WS_GS__c=1082,ASI_CRM_Comment__c='comments');
        wsli.add(li5);
        ASI_CRM_WS_Evaluation_Items__c li6 = new ASI_CRM_WS_Evaluation_Items__c(ASI_CRM_WS_Evaluation__c=WSEval.id,ASI_CRM_WS2__c=t3.id,ASI_CRM_Achieve_Rate__c=90,ASI_CRM_CN_Actual_Value__c=0,ASI_CRM_CN_Actual_Volume__c=3200,ASI_CRM_Calculated_Incentive__c=98,ASI_CRM_Data_Quality_Rate__c=80,ASI_CRM_incentive__c=100,ASI_CRM_Scan_Rate__c=90,ASI_CRM_Target__c=2,ASI_CRM_CN_Target_Value__c=0,ASI_CRM_CN_Target_Volume__c=40,ASI_CRM_CN_WS_Code__c='0.029887.03',ASI_CRM_WS_GS__c=1082,ASI_CRM_Comment__c='comments');
        wsli.add(li6);
        ASI_CRM_WS_Evaluation_Items__c li7 = new ASI_CRM_WS_Evaluation_Items__c(ASI_CRM_WS_Evaluation__c=WSEval.id,ASI_CRM_WS2__c=t3.id,ASI_CRM_Achieve_Rate__c=90,ASI_CRM_CN_Actual_Value__c=3200,ASI_CRM_CN_Actual_Volume__c=0,ASI_CRM_Calculated_Incentive__c=98,ASI_CRM_Data_Quality_Rate__c=80,ASI_CRM_incentive__c=100,ASI_CRM_Scan_Rate__c=98,ASI_CRM_Target__c=100,ASI_CRM_CN_Target_Value__c=40,ASI_CRM_CN_Target_Volume__c=0,ASI_CRM_CN_WS_Code__c='0.029887.03',ASI_CRM_WS_GS__c=1082,ASI_CRM_Comment__c='comments');
        wsli.add(li7);
        insert wsli;
        
        //create Approval Process
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(WSEval.Id);
        //req1.setNextApproverIds(new Id[] {User1.id});
        Approval.ProcessResult result1 = Approval.process(req1);
        
        List<Id> newWorkItemIds = result1.getNewWorkitemIds();
        
        system.debug('newWorkItemIds: ' + newWorkItemIds.size());
        if (newWorkItemIds.size() > 0){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(newWorkItemIds.get(0));
            Approval.ProcessResult result2 =  Approval.process(req2);
        }
        Test.startTest();
        
        ApexPages.StandardController scons = new ApexPages.StandardController(WSEval);
        ApexPages.currentPage().getParameters().put('id', scons.getId());
        ASI_CRM_CN_WSEvaluationPDFCtrl conpdf = new ASI_CRM_CN_WSEvaluationPDFCtrl(scons);
        
        Test.stopTest();
    }
}
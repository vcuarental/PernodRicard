/***********************************************************************************
Created by Stella Sing 2014-07-11
CTD Period
Object : 
For Contract
        ASI_TH_CRM_Contract__c (Contract Period : Start to Cutoff Date)
        ASI_CRM_CN_Contract_BRSF_Line_Item__c (Estimate BRSF Subbrand item)
        ASI_CRM_Subbbrand_Volume__c (Actual Data)
        
For Payment Request (Defer) 
        ASI_TH_CRM_PaymentRequest__c
        ASI_TH_CRM_PaymentRequestLineItem__c (Multiple PSF Period)
        ASI_CRM_CN_Contract_BRSF_Line_Item__c (Contract Estimate BRSF Subbrand item)
        ASI_CRM_Subbbrand_Volume__c (Actual Data)
************************************************************************************/
public without sharing class ASI_CRM_CN_PSFForm_CTD_Ctrl{

    public ASI_CRM_CN_PSFForm_CTD_Ctrl() {

    }

    //Component
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public string ContractPid {set;get;}
    public map<string, map<string, map<string, DataClass>>> PSFList_Map {set;get;}
    public map<string, map<string, DataClass>> SBGrade_PSFList_Map {set;get;}
    // Add by Alan Wong (Elufa) 20150602 - Outlet Summary
    public map<string, map<string, DataClass>> OutletSummaryList_Map {set;get;}
    public DataClass OutletTotal {set;get;}
    // -- End -- //
    public map<string, DataClass> TotalAllProducts_Map {set;get;}
    public map<string, DataClass> TotalAllProductsCR12_Map {set;get;}
    public map<string, DataClass> TotalChivas12_Map {set;get;}
    public map<string, DataClass> TotalNONChivas12_Map {set;get;}
    public integer ContractPeriod {set;get;}
    public DataClass TotalAllProducts {set;get;}
    public DataClass TotalAllProductsCR12 {set;get;}
    public DataClass TotalChivas12 {set;get;}
    public DataClass TotalNONChivas12 {set;get;}
    
    //Setup Cutoff Date
    public date CutOffDay {set;get;}
    public integer strCutOffDay {set;get;}
    
    //Contract
    public string ContractId {set;get;}
    public ASI_TH_CRM_Contract__c thisContract {set;get;}
    public list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> thisContract_BRSFList {set;get;}
    public list<ASI_CRM_Subbrand_Volume__c> Contract_SBVolList {set;get;}
    
    //Covered Outlet
    public list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_List {set;get;}
    
    //Null Data
    public boolean noData {set;get;}
    public boolean noVolume {set;get;}
    
    //V0 Contract ID
    public id v0ContractId {set;get;} //Added by Twinkle 20141218
    
    public ASI_CRM_CN_PSFForm_CTD_Ctrl(ApexPages.StandardController controller){
        ContractId = ApexPages.currentPage().getParameters().get('id');

        if (ContractId != null){
            try{
                thisContract = [SELECT id, ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_End_Date__c,
                                ASI_CRM_CN_PO_No__c, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c,
                                ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_CCity__r.Name, ASI_CRM_Volume_Option__c,
                                ASI_CRM_CN_Region__c, Owner.Name, ASI_CRM_CN_V0_0_PO_version__c
                                ,ASI_CRM_New_FY_PO__c,ASI_CRM_PO_Channel__r.Name,ASI_CRM_PO_Province__r.Name //20160624, Leo@Elufa
                                ,ASI_CRM_PO_City__c //20160621 Ben @ Elufa
                                ,ASI_CRM_PO_City__r.Name //20160621 Ben @ Elufa
                                ,ASI_CRM_PO_City__r.ASI_CRM_CN_City_Tier__c //20160621 Ben @ Elufa
                                FROM ASI_TH_CRM_Contract__c
                                WHERE Id = :ContractId];
            }catch(exception e){
                system.debug('Try thisContract failed: ' + e);
                noData = true;
            }
            noData = false;
            
            init();
            
        }else{
            thisContract = new ASI_TH_CRM_Contract__c();
            noData = true;
        }
    }
    public boolean init(){
        /****************************** SET CUTOFF Date ***********************************/
        strCutOffDay = 16; // 0 = ASI_CRM_CN_PO_End_Date__c
        /****************************** SET CUTOFF Date ***********************************/
        //Added by Twinkle 20141218 - Get V0.0 Contract (thisContract is referred to V0.0 Contract)
        if (thisContract != null && thisContract.ASI_CRM_CN_V0_0_PO_version__c != null){ 
           v0ContractId = thisContract.ASI_CRM_CN_V0_0_PO_version__c;
        }
        else{
            v0ContractId = thisContract.id;
        }
        //End by Twinkle 20141218  
            
        init_Data();
        system.debug('thisContract: ' + thisContract);
        if (thisContract != null){
            CutOffDay = CutOffDate(strCutOffDay, thisContract.ASI_CRM_CN_PO_End_Date__c, thisContract.ASI_CRM_CN_PO_Start_Date__c);
            system.debug('CutOffDay:::' + CutOffDay);
            if (CutOffDay != null)
                init_Contractdata();
            else
                noData = true;
        }
        return true;
    }
    public void init_Contractdata(){
        PSFList_Map = new map<string, map<string, map<string, DataClass>>>();
        SBGrade_PSFList_Map = new map<string, map<string, DataClass>>();
        // Added by Alan Wong (Elufa) 20150602 
        OutletSummaryList_Map = new map<string, map<string, DataClass>>();
        // -- End -- //
        TotalAllProducts_Map = new map<string, DataClass>();
        TotalAllProductsCR12_Map = new map<string, DataClass>();
        TotalChivas12_Map = new map<string, DataClass>();
        TotalNONChivas12_Map = new map<string, DataClass>();
        Contract_SBVolList = new list<ASI_CRM_Subbrand_Volume__c>();
        
        string CTDPeriod = ConvertDate(thisContract.ASI_CRM_CN_PO_Start_Date__c) + ' - ' + ConvertDate(CutOffDay);
        system.debug('CTDPeriod: ' + CTDPeriod);
        system.debug('PO Start: ' + thisContract.ASI_CRM_CN_PO_Start_Date__c);
//get Contract BRSF Subbrand Items
        try{            
            thisContract_BRSFList = [SELECT id, ASI_CRM_CN_Sub_Brand__c, 
                                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                    ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                    ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract__c,
                                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c ,
                                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name,
                                    ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c,
                                    ASI_CRM_CN_Contract_Monthly_Qty__c
                                    FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                    WHERE ASI_CRM_CN_Contract__c = :v0ContractId];
        }catch(exception e){
            thisContract_BRSFList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        system.debug('thisContract_BRSFList: ' + thisContract_BRSFList );
        
        ContractPeriod = ConvertPeriod(thisContract.ASI_CRM_CN_PO_Start_Date__c, CutOffDay);
        if (thisContract_BRSFList.size() > 0){
            string SBGradeSort;
            string SBGradeName;
            decimal SBSortNo;
            string SBName;
            string SBGroup;
            decimal strTarget;
            decimal strTargetCR12;
            decimal CR12Factor;
            for (ASI_CRM_CN_Contract_BRSF_Line_Item__c brsftemp: thisContract_BRSFList){
                //Setup for Map keyset
                SBName = null;
                SBGroup = null;
                SBSortNo = null;
                SBGradeName = null;
                if (brsftemp.ASI_CRM_CN_Sub_Brand__c != null){
                    SBName = brsftemp.ASI_CRM_CN_Sub_Brand__r.Name;
                    if (brsftemp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null)
                        CR12Factor = brsftemp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                    else
                        CR12Factor = 1;
                    
                    //Sub brand Group Name
                    if (brsftemp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c != null)
                        SBGroup = brsftemp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name;
                    else
                        SBGroup = null;
                        
                    //Sub brand Grade Name
                    if (brsftemp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                        SBGradeName = brsftemp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        SBSortNo = brsftemp.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c;
                    }else{
                        SBGradeName = 'Not Specified';
                        SBSortNo = null;
                    }
                }else{
                    SBName = null;
                    SBGroup = null;
                    SBSortNo = null;
                    SBGradeName = null;
                }
                SBGradeSort = sbGradeSorting(SBSortNo) + SBGradeName;
                
//Contract Volume Target 
                strTarget = 0;
                strTargetCR12 = 0;
                //Updated by Twinkle 20141219 - Use Contract Monthly Qty to calculate
                if (brsftemp.ASI_CRM_CN_Contract_Monthly_Qty__c!= null){
                    strTarget = brsftemp.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractPeriod;
                    strTargetCR12 = brsftemp.ASI_CRM_CN_Contract_Monthly_Qty__c * ContractPeriod * CR12Factor;
                }    
                
                //Subbrand Grade + Subbrand Name Sorting
                if (PSFList_Map.containskey(CTDPeriod)){
                    if (PSFList_Map.get(CTDPeriod).containskey(SBGradeSort)){
                        if (PSFList_Map.get(CTDPeriod).get(SBGradeSort).containskey(SBName)){
                            DataClass temp = PSFList_Map.get(CTDPeriod).get(SBGradeSort).get(SBName);
                            temp.targetvol += strTarget;
                            //PSFList_Map.get(CTDPeriod).get(SBGradeSort).get(SBName).targetvol += strTarget;
                            PSFList_Map.get(CTDPeriod).get(SBGradeSort).put(SBName, temp);
                            
                        }else{
                            DataClass newdata = new DataClass();
                            newdata.targetvol = strTarget;
                            newdata.offtakevol = 0;
                            newdata.intakevol= 0;
                            newdata.btlcollection = 0;
                            newdata.sbname = SBName;
                            newdata.strSubBrand = SBName;
                            PSFList_Map.get(CTDPeriod).get(SBGradeSort).put(SBName, newdata);
                        }
                    }else{
                        map<string, DataClass> newDataMap = new map<string, DataClass>();
                        DataClass newdata = new DataClass();
                        newdata.targetvol = strTarget;
                        newdata.offtakevol = 0;
                        newdata.intakevol= 0;
                        newdata.btlcollection = 0;
                        newdata.sbname = SBName;
                        newdata.strSubBrand = SBName;
                        newDataMap.put(SBName, newdata);
                        PSFList_Map.get(CTDPeriod).put(SBGradeSort, newDataMap);
                    }
                }else{
                    map<string, DataClass> newDataMap = new map<string, DataClass>();
                    DataClass newdata = new DataClass();
                    newdata.targetvol = strTarget;
                    newdata.offtakevol = 0;
                    newdata.intakevol= 0;
                    newdata.btlcollection = 0;
                    newdata.sbname = SBName;
                    newdata.strSubBrand = SBName;
                    newDataMap.put(SBName, newdata);
                    map<string, map<string, DataClass>> newDataMap_Map = new map<string, map<string, DataClass>>();
                    newDataMap_Map.put(SBGradeSort, newDataMap);
                    PSFList_Map.put(CTDPeriod, newDataMap_Map);
                }
                
                //Subbrand Grade Total
                if (SBGrade_PSFList_Map.containskey(CTDPeriod)){
                    if (SBGrade_PSFList_Map.get(CTDPeriod).containskey(SBGradeSort)){
                        DataClass temp = SBGrade_PSFList_Map.get(CTDPeriod).get(SBGradeSort);
                        temp.targetvol += strTarget;
                        SBGrade_PSFList_Map.get(CTDPeriod).put(SBGradeSort, temp);
                    }else{
                        DataClass newdata = new DataClass();
                        newdata.targetvol = strTarget;
                        newdata.offtakevol = 0;
                        newdata.intakevol= 0;
                        newdata.btlcollection = 0;
                        newdata.sbname = SBName;
                        newdata.strSubBrand = SBName;
                        SBGrade_PSFList_Map.get(CTDPeriod).put(SBGradeSort, newdata);
                    }
                }else{
                    map<string, DataClass> newDataTotalMap = new map<string, DataClass>();
                    DataClass newdata = new DataClass();
                    newdata.targetvol = strTarget;
                    newdata.offtakevol = 0;
                    newdata.intakevol= 0;
                    newdata.btlcollection = 0;
                    newDataTotalMap.put(SBGradeSort, newdata);
                    SBGrade_PSFList_Map.put(CTDPeriod, newDataTotalMap);
                }
                
                //Total All Products Target Vol
                //TotalAllProducts.targetvol += strTarget;
                if (TotalAllProducts_Map.containskey(CTDPeriod)){
                    DataClass temp = TotalAllProducts_Map.get(CTDPeriod);
                    temp.targetvol += strTarget;
                    TotalAllProducts_Map.put(CTDPeriod, temp);
                }else{
                    DataClass newdata = new DataClass();
                    newdata.targetvol = strTarget;
                    newdata.offtakevol = 0;
                    newdata.intakevol= 0;
                    newdata.btlcollection = 0;
                    TotalAllProducts_Map.put(CTDPeriod, newdata);
                }
                //Total All Products Target Vol eq CR12 
                //TotalAllProductsCR12.targetvol += strTargetCR12;
                if (TotalAllProductsCR12_Map.containskey(CTDPeriod)){
                    DataClass temp = TotalAllProductsCR12_Map.get(CTDPeriod);
                    temp.targetvol += strTargetCR12;
                    TotalAllProductsCR12_Map.put(CTDPeriod, temp);
                }else{
                    DataClass newdataCR12 = new DataClass();
                    newdataCR12.targetvol = strTargetCR12;
                    newdataCR12.offtakevol = 0;
                    newdataCR12.intakevol= 0;
                    newdataCR12.btlcollection = 0;
                    TotalAllProductsCR12_Map.put(CTDPeriod, newdataCR12);
                }
                //Total All Chivas 12
                if (SBGroup == 'Chivas Extra'){// changed by laputa 20171123
                    //TotalChivas12.targetvol += strTarget;
                    if (TotalChivas12_Map.containskey(CTDPeriod)){
                        DataClass temp = TotalChivas12_Map.get(CTDPeriod);
                        temp.targetvol += strTarget;
                        TotalChivas12_Map.put(CTDPeriod, temp);
                    }else{
                        DataClass newdata = new DataClass();
                        newdata.targetvol = strTarget;
                        newdata.offtakevol = 0;
                        newdata.intakevol= 0;
                        newdata.btlcollection = 0;
                        TotalChivas12_Map.put(CTDPeriod, newdata);
                    }
                //Total NON Chivas 12
                }else{
                    if (TotalNONChivas12_Map.containskey(CTDPeriod)){
                        DataClass temp = TotalNONChivas12_Map.get(CTDPeriod);
                        temp.targetvol += strTarget;
                        TotalNONChivas12_Map.put(CTDPeriod, temp);
                    }else{
                        DataClass newdata = new DataClass();
                        newdata.targetvol = strTarget;
                        newdata.offtakevol = 0;
                        newdata.intakevol= 0;
                        newdata.btlcollection = 0;
                        TotalNONChivas12_Map.put(CTDPeriod, newdata);
                    }
                    
                }
                if (!TotalChivas12_Map.containskey(CTDPeriod)){
                    DataClass newdata = new DataClass();
                    newdata.targetvol = 0;
                    newdata.offtakevol = 0;
                    newdata.intakevol= 0;
                    newdata.btlcollection = 0;
                    TotalChivas12_Map.put(CTDPeriod, newdata);
                }
                if (!TotalNONChivas12_Map.containskey(CTDPeriod)){
                    DataClass newdata = new DataClass();
                    newdata.targetvol = 0;
                    newdata.offtakevol = 0;
                    newdata.intakevol= 0;
                    newdata.btlcollection = 0;
                    TotalNONChivas12_Map.put(CTDPeriod, newdata);
                }
            }
        }
        //Covered Outlet
        set<id> OutletIdSet = new set<id>();
        try{
            CoveredOutlet_List = [SELECT ASI_CRM_CN_Outlet__c,ASI_CRM_CN_Outlet__r.Name,ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c
                                   FROM ASI_CRM_CN_Covered_Outlet__c
                                   WHERE ASI_CRM_CN_Contract__c = :thisContract.id ORDER BY ASI_CRM_CN_Outlet__r.Name ASC];
        }catch(exception e){
            system.debug('Try CoveredOutlet_List failed: ' + e);
            CoveredOutlet_List = new list<ASI_CRM_CN_Covered_Outlet__c>();
        }
        system.debug('CoveredOutlet_List: ' + CoveredOutlet_List);
        ASI_TH_CRM_Contract__c tempCC =  [SELECT id, ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_Contract__c WHERE Id = :thisContract.id];
        if (tempCC.ASI_CRM_Volume_Option__c == 'Normal' || tempCC.ASI_CRM_Volume_Option__c == 'Wholesaler Only' || tempCC.ASI_CRM_Volume_Option__c == null){
        	OutletIdSet.add(thisContract.ASI_CRM_CN_Outlet_WS__c); 
            if (!OutletSummaryList_Map.containskey(CTDPeriod))
                OutletSummaryList_Map.put(CTDPeriod, new map<string, DataClass>());
            if(!OutletSummaryList_Map.get(CTDPeriod).containskey(thisContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c)) {
                DataClass newdata = new DataClass();
                newdata.offtakevol = 0;
                newdata.intakevol= 0;
                newdata.btlcollection = 0;
                OutletSummaryList_Map.get(CTDPeriod).put(thisContract.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Chi_Name__c, newdata);
            }
        }
        if (tempCC.ASI_CRM_Volume_Option__c == 'Normal' || tempCC.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || tempCC.ASI_CRM_Volume_Option__c == null){
            if (CoveredOutlet_List.size() > 0){
                for (ASI_CRM_CN_Covered_Outlet__c co_temp : CoveredOutlet_List){
                    OutletIdSet.add(co_temp.ASI_CRM_CN_Outlet__c);
                    if (!OutletSummaryList_Map.containskey(CTDPeriod))
                         OutletSummaryList_Map.put(CTDPeriod, new map<string, DataClass>());
                     if(!OutletSummaryList_Map.get(CTDPeriod).containskey(co_temp.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c)) {
                         DataClass newdata = new DataClass();
                         newdata.offtakevol = 0;
                         newdata.intakevol= 0;
                         newdata.btlcollection = 0;
                         OutletSummaryList_Map.get(CTDPeriod).put(co_temp.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c, newdata);
                     }
                }
            }
        }
        //Subbrand Volume 
        // try{
            /*
            Contract_SBVolList = [SELECT ASI_CRM_Offtake_Std_Billing__c, ASI_CRM_Offtake_CR12__c,
                                  ASI_CRM_T1_Depletion_STD_Billing__c, ASI_CRM_T2_Depletion_STD_Billing__c,
                                  ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
                                  ASI_CRM_PR_Direct_CR12__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Green_Cap_Std_Billing__c,
                                  ASI_CRM_Green_Cap_CR12__c, ASI_CRM_Empty_Bottle_CR12__c,ASI_CRM_Bottle_Collected__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name,
                                  ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c
                                  FROM ASI_CRM_Subbrand_Volume__c
                                  WHERE ASI_CRM_End_Date__c >= :thisContract.ASI_CRM_CN_PO_Start_Date__c
                                  AND ASI_CRM_End_Date__c <= :CutOffDay
                                  AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                                  AND ASI_CRM_Account__c IN :OutletIdSet];
			*/
            // Added by Alan Wong (Elufa) 20160602
            // system.debug('now OutletSet:'+OutletIdSet);
            // system.debug('debug StartDate:'+thisContract.ASI_CRM_CN_PO_Start_Date__c);
            // system.debug('debug CutOffDay:'+CutOffDay);
            // Contract_SBVolList = [SELECT ASI_CRM_Offtake_Std_Billing__c, ASI_CRM_Offtake_CR12__c,ASI_CRM_Account__c,ASI_CRM_Account__r.Name,
            //                       ASI_CRM_T1_Depletion_STD_Billing__c, ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c,
            //                       ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
            //                       ASI_CRM_PR_Direct_CR12__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Green_Cap_Std_Billing__c,
            //                       ASI_CRM_Green_Cap_CR12__c, ASI_CRM_Empty_Bottle_CR12__c,ASI_CRM_Bottle_Collected__c,
            //                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
            //                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
            //                       ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
            //                       ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c,
            //                       ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name,
            //                       ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__c,
            //                       ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c
            //                       FROM ASI_CRM_Subbrand_Volume__c
            //                       WHERE ASI_CRM_End_Date__c >= :thisContract.ASI_CRM_CN_PO_Start_Date__c
            //                       AND ASI_CRM_End_Date__c <= :CutOffDay
            //                       AND ASI_CRM_CN_Competitor_Sub_brand__c != true
            //                       AND ASI_CRM_Account__c IN :OutletIdSet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =FALSE];
            // //20170117 Elufa Add: ASI_CRM_CN_Exclude_From_Payment_Volume__c =false 
            // -- End -- //
        // }catch(exception e){
        //     system.debug('Try Contract_SBVolList failed: ' + e);
        //     Contract_SBVolList = new list<ASI_CRM_Subbrand_Volume__c>();
        // }
        // system.debug('Contract_SBVolList: ' + Contract_SBVolList );
        // if (Contract_SBVolList.size() > 0){
            string SBGradeSort;
            string SBGradeName;
            // Added by Alan Wong (Elufa) 20160602
            string OutletName;
            // -- End -- //
            decimal SBSortNo;
            string SBName;
            string SBGroup;
            decimal intakevol;
            decimal intakevolCR12;
            decimal offtakevol;
            decimal offtakevolCR12;
            decimal btlcollection;
            decimal btlcollectionCR12;
            decimal CR12Factor;
            decimal offtakeVSintake;
            decimal collectionVSofftake;
            decimal collectionVSintake;
            decimal collectionVScontract;
            decimal intakeVScontract;
            for (ASI_CRM_Subbrand_Volume__c sbtemp : [SELECT ASI_CRM_Offtake_Std_Billing__c, ASI_CRM_Offtake_CR12__c,ASI_CRM_Account__c,ASI_CRM_Account__r.Name,
                                  ASI_CRM_T1_Depletion_STD_Billing__c, ASI_CRM_T2_Depletion_STD_Billing__c,ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c,
                                  ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c,
                                  ASI_CRM_PR_Direct_CR12__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Green_Cap_Std_Billing__c,
                                  ASI_CRM_Green_Cap_CR12__c, ASI_CRM_Empty_Bottle_CR12__c,ASI_CRM_Bottle_Collected__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name,
                                  ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__c,
                                  ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c
                                  FROM ASI_CRM_Subbrand_Volume__c
                                  WHERE ASI_CRM_End_Date__c >= :thisContract.ASI_CRM_CN_PO_Start_Date__c
                                  AND ASI_CRM_End_Date__c <= :CutOffDay
                                  AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                                  AND ASI_CRM_Account__c IN :OutletIdSet and ASI_CRM_CN_Exclude_From_Payment_Volume__c =FALSE] ){
                 //setup key set
                SBName = null;
                SBGroup = null;
                SBSortNo = null;
                SBGradeName = null;
                OutletName = null;
                if (sbtemp.ASI_CRM_Subbrand__c != null){
                    SBName = sbtemp.ASI_CRM_Subbrand__r.Name;
                    OutletName = sbtemp.ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c;
                    if (sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null)
                        CR12Factor = sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                    else
                        CR12Factor = 1;
                    
                    //Sub brand Group Name
                    if (sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c != null)
                        SBGroup = sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name;
                    else
                        SBGroup = null;
                        
                    //Sub brand Grade Name
                    if (sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                        SBGradeName = sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        SBSortNo = sbtemp.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c;
                    }else{
                        SBGradeName = 'Not Specified';
                        SBSortNo = null;
                    }
                }else{
                    SBName = null;
                    SBGroup = null;
                    SBSortNo = null;
                    SBGradeName = null;
                    OutletName = null;
                }
                SBGradeSort = sbGradeSorting(SBSortNo) + SBGradeName;
                
                //Offtake
                offtakevol = 0;
                if (sbtemp.ASI_CRM_Offtake_Std_Billing__c != null)
                    offtakevol = sbtemp.ASI_CRM_Offtake_Std_Billing__c;
                    
                offtakevolCR12 = 0;
                if (sbtemp.ASI_CRM_Offtake_CR12__c != null)
                    offtakevolCR12 = sbtemp.ASI_CRM_Offtake_CR12__c;
                
                //Intake
                intakevol = 0;
                if (sbtemp.ASI_CRM_T1_Depletion_STD_Billing__c != null)
                    intakevol = sbtemp.ASI_CRM_T1_Depletion_STD_Billing__c ;
                if (sbtemp.ASI_CRM_T2_Depletion_STD_Billing__c != null)
                    intakevol += sbtemp.ASI_CRM_T2_Depletion_STD_Billing__c;
                if (sbtemp.ASI_CRM_PR_Direct_STD_Billing__c != null)
                    intakevol += sbtemp.ASI_CRM_PR_Direct_STD_Billing__c;
                
                intakevolCR12 = 0;
                if (sbtemp.ASI_CRM_T1_Depletion_CR12__c != null)
                    intakevolCR12 = sbtemp.ASI_CRM_T1_Depletion_CR12__c;
                if (sbtemp.ASI_CRM_T2_Depletion_CR12__c != null)
                    intakevolCR12 += sbtemp.ASI_CRM_T2_Depletion_CR12__c;
                if (sbtemp.ASI_CRM_PR_Direct_CR12__c != null)
                    intakevolCR12 += sbtemp.ASI_CRM_PR_Direct_CR12__c;
                
//Bottle Collection - ASI_CRM_Bottle_Collected__c
                btlcollection = 0;
                if (sbtemp.ASI_CRM_Bottle_Collected__c != null)
                    btlcollection = sbtemp.ASI_CRM_Bottle_Collected__c;
                /*
                if (sbtemp.ASI_CRM_Empty_Bottle__c != null)
                    btlcollection = sbtemp.ASI_CRM_Empty_Bottle__c;
                if (sbtemp.ASI_CRM_Green_Cap_Std_Billing__c != null)
                    btlcollection += sbtemp.ASI_CRM_Green_Cap_Std_Billing__c;
                */
                
                btlcollectionCR12 = 0;
                if (sbtemp.ASI_CRM_Empty_Bottle_CR12__c != null)
                    btlcollectionCR12 = sbtemp.ASI_CRM_Empty_Bottle_CR12__c;
                if (sbtemp.ASI_CRM_Green_Cap_CR12__c != null)
                    btlcollectionCR12 += sbtemp.ASI_CRM_Green_Cap_CR12__c;
                    
                //Offtake VS Intake
                if (offtakevol != 0 && intakevol != 0)
                    offtakeVSintake = offtakevol / intakevol;
                    
                //Collection VS Offtake
                if (Btlcollection != 0 && offtakevol != 0)
                    collectionVSofftake = Btlcollection / offtakevol;
                    
                //Collection VS Intake
                if (Btlcollection != 0 && intakevol != 0)
                    collectionVSintake = btlcollection / intakevol;
                 
                 if (!PSFList_Map.containskey(CTDPeriod))
                     PSFList_Map.put(CTDPeriod, new map<string, map<string, DataClass>>());
                 if(!PSFList_Map.get(CTDPeriod).containskey(SBGradeSort))
                     PSFList_Map.get(CTDPeriod).put(SBGradeSort, new map<string, DataClass>());
                 if(!PSFList_Map.get(CTDPeriod).get(SBGradeSort).containskey(SBName)) {
                     DataClass newdata = new DataClass();
                     newdata.targetvol = 0;
                     newdata.offtakevol = 0;
                     newdata.intakevol= 0;
                     newdata.btlcollection = 0;
                     newdata.sbname = SBName;
                     newdata.strSubBrand = SBName;
                     PSFList_Map.get(CTDPeriod).get(SBGradeSort).put(SBName, newdata);
                 }
                 {
                     DataClass tempData = PSFList_Map.get(CTDPeriod).get(SBGradeSort).get(SBName);
                     tempData.offtakevol += offtakevol;
                     tempData.intakevol += intakevol;
                     tempData.btlcollection += btlcollection;
                 }
                 
                 if (!SBGrade_PSFList_Map.containskey(CTDPeriod))
                     SBGrade_PSFList_Map.put(CTDPeriod, new map<string, DataClass>());
                 if(!SBGrade_PSFList_Map.get(CTDPeriod).containskey(SBGradeSort)) {
                     DataClass newdata = new DataClass();
                     newdata.targetvol = 0;
                     newdata.offtakevol = 0;
                     newdata.intakevol= 0;
                     newdata.btlcollection = 0;
                     SBGrade_PSFList_Map.get(CTDPeriod).put(SBGradeSort, newdata);
                 }
                 {
                     DataClass tempData = SBGrade_PSFList_Map.get(CTDPeriod).get(SBGradeSort);
                     tempData.offtakevol += offtakevol;
                     tempData.intakevol += intakevol;
                     tempData.btlcollection += btlcollection;
                 }
                 // Added by Alan Wong (Elufa) 20160602
                 if (!OutletSummaryList_Map.containskey(CTDPeriod))
                     OutletSummaryList_Map.put(CTDPeriod, new map<string, DataClass>());
                 if(!OutletSummaryList_Map.get(CTDPeriod).containskey(OutletName)) {
                     DataClass newdata = new DataClass();
                     newdata.offtakevol = offtakevol;
                     newdata.intakevol= intakevol;
                     newdata.btlcollection = btlcollection;
                     OutletSummaryList_Map.get(CTDPeriod).put(OutletName, newdata);
                 }else
                 {
                     DataClass tempData = OutletSummaryList_Map.get(CTDPeriod).get(OutletName);
                     
                     tempData.offtakevol += offtakevol;
                     tempData.intakevol += intakevol;
                     tempData.btlcollection += btlcollection;
                 }
                // -- End -- //
                 
                //Total All Products Target Vol
                if (TotalAllProducts_Map.containskey(CTDPeriod)){
                    DataClass temp = TotalAllProducts_Map.get(CTDPeriod);
                    temp.offtakevol += offtakevol;
                    temp.intakevol += intakevol;
                    temp.btlcollection += btlcollection;
                    TotalAllProducts_Map.put(CTDPeriod, temp);
                }else{
                    DataClass newdata = new DataClass();
                    newdata.targetvol = 0;
                    newdata.offtakevol = offtakevol;
                    newdata.intakevol= intakevol;
                    newdata.btlcollection = btlcollection;
                    TotalAllProducts_Map.put(CTDPeriod, newdata);
                }
                //Total All Products Target Vol eq CR12 
                if (TotalAllProductsCR12_Map.containskey(CTDPeriod)){
                    DataClass temp = TotalAllProductsCR12_Map.get(CTDPeriod);
                    temp.offtakevol += offtakevolCR12;
                    temp.intakevol += intakevolCR12;
                    temp.btlcollection += btlcollectionCR12;
                    TotalAllProductsCR12_Map.put(CTDPeriod, temp);
                }else{
                    DataClass newdataCR12 = new DataClass();
                    newdataCR12.targetvol = 0;
                    newdataCR12.offtakevol = offtakevolCR12;
                    newdataCR12.intakevol= intakevolCR12;
                    newdataCR12.btlcollection = btlcollectionCR12;
                    TotalAllProductsCR12_Map.put(CTDPeriod, newdataCR12);
                }
                //Total All Chivas 12
                if (SBGroup == 'Chivas Extra'){// changed by laputa 20171123,Chivas 12 changed to  Chivas Extra
                    if (TotalChivas12_Map.containskey(CTDPeriod)){
                        DataClass temp = TotalChivas12_Map.get(CTDPeriod);
                        temp.offtakevol += offtakevol;
                        temp.intakevol += intakevol;
                        temp.btlcollection += btlcollection;
                        TotalChivas12_Map.put(CTDPeriod, temp);
                    }else{
                        DataClass newdata = new DataClass();
                        newdata.targetvol = 0;
                        newdata.offtakevol = offtakevol;
                        newdata.intakevol= intakevol;
                        newdata.btlcollection = btlcollection;
                        TotalChivas12_Map.put(CTDPeriod, newdata);
                    }
                //Total NON Chivas 12
                }else{
                    if (TotalNONChivas12_Map.containskey(CTDPeriod)){
                        DataClass temp = TotalNONChivas12_Map.get(CTDPeriod);
                        temp.offtakevol += offtakevol;
                        temp.intakevol += intakevol;
                        temp.btlcollection += btlcollection;
                        TotalNONChivas12_Map.put(CTDPeriod, temp);
                    }else{
                        DataClass newdata = new DataClass();
                        newdata.targetvol = 0;
                        newdata.offtakevol = offtakevol;
                        newdata.intakevol= intakevol;
                        newdata.btlcollection = btlcollection;
                        TotalNONChivas12_Map.put(CTDPeriod, newdata);
                    }
                }
                if (!TotalChivas12_Map.containskey(CTDPeriod)){
                    DataClass newdata = new DataClass();
                    newdata.targetvol = 0;
                    newdata.offtakevol = 0;
                    newdata.intakevol= 0;
                    newdata.btlcollection = 0;
                    TotalChivas12_Map.put(CTDPeriod, newdata);
                }
                if (!TotalNONChivas12_Map.containskey(CTDPeriod)){
                    DataClass newdata = new DataClass();
                    newdata.targetvol = 0;
                    newdata.offtakevol = 0;
                    newdata.intakevol= 0;
                    newdata.btlcollection = 0;
                    TotalNONChivas12_Map.put(CTDPeriod, newdata);
                }
            }
            
            //Added by Twinkle 20141218 - Remove RP6 code in sub-brand name
            integer intlength;
            integer intRP6;
            set<string> remove_keys;
            for (String key : PSFList_Map.keySet()) {
                for(String key2 : PSFList_Map.get(key).keySet()) {
                    for(String key3 : PSFList_Map.get(key).get(key2).keySet()) {
                        if(key3 != null){
                            intlength = key3.length();
                            intRP6 = key3.lastIndexOf('-');  
                        }   
                        if(intlength >= 4){
                            if(intRP6 == (intlength-4) && PSFList_Map.get(key) != null && PSFList_Map.get(key).get(key2) != null && PSFList_Map.get(key).get(key2).get(key3) != null){
                                PSFList_Map.get(key).get(key2).get(key3).strSubBrand = key3.substring(0, (intlength-4));
                            }
                            else{
                                if(PSFList_Map.get(key) != null && PSFList_Map.get(key).get(key2) != null && PSFList_Map.get(key).get(key2).get(key3) != null)
                                    PSFList_Map.get(key).get(key2).get(key3).strSubBrand = key3;
                            }
                        }
                    }
                }
            }
            //End Twinkle 20141218
        // }
        //Sb Grade Grouping
        if (PSFList_Map.size() > 0){
            for (string a : PSFList_Map.keyset()){
                for (string b : PSFList_Map.get(a).keyset()){
                    for (DataClass c : PSFList_Map.get(a).get(b).values()){
                        if (c.offtakevol != 0 && c.intakevol != 0)
                            c.offtakeVSintake = c.offtakevol / c.intakevol *100;
                        if (c.btlcollection != 0 && c.offtakevol!= 0)
                            c.collectionVSofftake = c.btlcollection / c.offtakevol *100;
                        if (c.btlcollection != 0 && c.intakevol != 0)
                            c.collectionVSintake = c.btlcollection / c.intakevol *100;
                        if (c.btlcollection != 0 && c.targetvol != 0)
                            c.collectionVScontract = c.btlcollection / c.targetvol *100;
                        if (c.intakevol != 0 && c.targetvol != 0)
                            c.intakeVScontract = c.intakevol / c.targetvol *100;
                    }
                }
            }
        }
        //SB Grade Total
        if (SBGrade_PSFList_Map.size() > 0 ){
            for (string a : SBGrade_PSFList_Map.keyset()){
                for (DataClass c : SBGrade_PSFList_Map.get(a).values()){
                    if (c.offtakevol != 0 && c.intakevol != 0)
                        c.offtakeVSintake = c.offtakevol / c.intakevol *100;
                    if (c.btlcollection != 0 && c.offtakevol!= 0)
                        c.collectionVSofftake = c.btlcollection / c.offtakevol *100;
                    if (c.btlcollection != 0 && c.intakevol != 0)
                        c.collectionVSintake = c.btlcollection / c.intakevol *100;
                    if (c.btlcollection != 0 && c.targetvol != 0)
                        c.collectionVScontract = c.btlcollection / c.targetvol *100;
                    if (c.intakevol != 0 && c.targetvol != 0)
                        c.intakeVScontract = c.intakevol / c.targetvol *100;
                }
            }
        }
        //Cover Outlet Total
        if (OutletSummaryList_Map.size() > 0 ){
            for (string a : OutletSummaryList_Map.keyset()){
                for (DataClass c : OutletSummaryList_Map.get(a).values()){
                    OutletTotal.offtakevol += c.offtakevol;
        			OutletTotal.intakevol += c.intakevol;
       			 	OutletTotal.btlcollection += c.btlcollection;
                }
            }
        }else
        {
            noVolume = true;
        }
        system.debug('OutletSummaryList_Map:::' + OutletSummaryList_Map);
        system.debug('OutletTotal:::' + OutletTotal);
        //Chivas 12 Total
        if (TotalChivas12_Map.size() > 0){
            for (DataClass c : TotalChivas12_Map.values()){
                if (c.offtakevol != 0 && c.intakevol != 0)
                    c.offtakeVSintake = c.offtakevol / c.intakevol *100;
                if (c.btlcollection != 0 && c.offtakevol!= 0)
                    c.collectionVSofftake = c.btlcollection / c.offtakevol *100;
                if (c.btlcollection != 0 && c.intakevol != 0)
                    c.collectionVSintake = c.btlcollection / c.intakevol *100;
                if (c.btlcollection != 0 && c.targetvol != 0)
                    c.collectionVScontract = c.btlcollection / c.targetvol *100;
                if (c.intakevol != 0 && c.targetvol != 0)
                    c.intakeVScontract = c.intakevol / c.targetvol *100;
            }
        }
        //NON Chivas 12 Total
        if (TotalNONChivas12_Map.size() > 0){
            for (DataClass c : TotalNONChivas12_Map.values()){
                if (c.offtakevol != 0 && c.intakevol != 0)
                    c.offtakeVSintake = c.offtakevol / c.intakevol *100;
                if (c.btlcollection != 0 && c.offtakevol!= 0)
                    c.collectionVSofftake = c.btlcollection / c.offtakevol *100;
                if (c.btlcollection != 0 && c.intakevol != 0)
                    c.collectionVSintake = c.btlcollection / c.intakevol *100;
                if (c.btlcollection != 0 && c.targetvol != 0)
                    c.collectionVScontract = c.btlcollection / c.targetvol *100;
                if (c.intakevol != 0 && c.targetvol != 0)
                    c.intakeVScontract = c.intakevol / c.targetvol *100;
            }
        }
        //Total All Products
        if (TotalAllProducts_Map.size() > 0){
            for (DataClass c : TotalAllProducts_Map.values()){
                if (c.offtakevol != 0 && c.intakevol != 0)
                    c.offtakeVSintake = c.offtakevol / c.intakevol *100;
                if (c.btlcollection != 0 && c.offtakevol!= 0)
                    c.collectionVSofftake = c.btlcollection / c.offtakevol *100;
                if (c.btlcollection != 0 && c.intakevol != 0)
                    c.collectionVSintake = c.btlcollection / c.intakevol *100;
                if (c.btlcollection != 0 && c.targetvol != 0)
                    c.collectionVScontract = c.btlcollection / c.targetvol *100;
                if (c.intakevol != 0 && c.targetvol != 0)
                    c.intakeVScontract = c.intakevol / c.targetvol *100;
            }
        }
        //Total All Products CR12 
        if (TotalAllProductsCR12_Map.size() > 0){
            for (DataClass c : TotalAllProductsCR12_Map.values()){
                if (c.offtakevol != 0 && c.intakevol != 0)
                    c.offtakeVSintake = c.offtakevol / c.intakevol *100;
                if (c.btlcollection != 0 && c.offtakevol!= 0)
                    c.collectionVSofftake = c.btlcollection / c.offtakevol *100;
                if (c.btlcollection != 0 && c.intakevol != 0)
                    c.collectionVSintake = c.btlcollection / c.intakevol *100;
                if (c.btlcollection != 0 && c.targetvol != 0)
                    c.collectionVScontract = c.btlcollection / c.targetvol *100;
                if (c.intakevol != 0 && c.targetvol != 0)
                    c.intakeVScontract = c.intakevol / c.targetvol *100;
            }
        }
    }
    public void init_Data(){
    
        TotalAllProducts = new DataClass();
        TotalAllProducts.targetvol = 0;
        TotalAllProducts.offtakevol = 0;
        TotalAllProducts.intakevol = 0;
        TotalAllProducts.btlcollection = 0;
        
        TotalAllProductsCR12 = new DataClass();
        TotalAllProductsCR12.targetvol = 0;
        TotalAllProductsCR12.offtakevol = 0;
        TotalAllProductsCR12.intakevol = 0;
        TotalAllProductsCR12.btlcollection = 0;
        
        TotalChivas12 = new DataClass();
        TotalChivas12.targetvol = 0;
        TotalChivas12.offtakevol = 0;
        TotalChivas12.intakevol = 0;
        TotalChivas12.btlcollection = 0;
        
        TotalNONChivas12 = new DataClass();
        TotalNONChivas12.targetvol = 0;
        TotalNONChivas12.offtakevol = 0;
        TotalNONChivas12.intakevol = 0;
        TotalNONChivas12.btlcollection = 0;
        
        OutletTotal = new DataClass();
        OutletTotal.offtakevol = 0;
        OutletTotal.intakevol = 0;
        OutletTotal.btlcollection = 0;
    }
    
    //Set CutOff Date
    public date CutOffDate(integer strDay, date defaultDate, date startdate){
        Date returnDate;
        Integer strDate = Date.Today().Day();
        Integer strMonth;
        Integer strEndDay;
        system.debug('strDate: ' + strDate);
        if (defaultDate != null && startdate != null && strDay != null){
            if (strDay != 0){
                    if (strDate >= strDay){
                        strMonth = Date.Today().Month() - 1;
                    }
                    if (strDate < strDay){
                        strMonth = Date.Today().Month() - 2;
                    }
                    system.debug('strMonth: ' + strMonth );
                    strEndDay = Date.daysInMonth(Date.Today().Year(), strMonth);
                    system.debug('strEndDay: ' + strEndDay );
                    returnDate = Date.newinstance(Date.Today().Year(),strMonth,strEndDay);
                    system.debug('CutOffDate: ' + returnDate);
                    if (returnDate < startdate){
                        return null;
                    }
                    if (returnDate >= defaultDate){
                        returnDate = defaultDate;
                    }
            }else{
                returnDate = defaultDate;
            }
        }
        system.debug('CutOffDate: ' + returnDate);
        return returnDate;
    }
    //Convert two dates into Period (No of Months)
    public integer ConvertPeriod(date startDate, date endDate){
        integer strPeriod;
        if (startDate != null && endDate != null){
            strPeriod = ((endDate.YEAR() - startDate.YEAR() - 1) *12) + (12 - startDate.MONTH() +1) + endDate.MONTH();
        }else{
            strPeriod = 0;
        }
        system.debug('ConvertPeriod: ' + strPeriod);
        return strPeriod;
    }
    //Convert Date to String
    public string ConvertDate(date strDate){
        string datestring;
        if (strDate != null){
            datestring = string.valueof(strDate.DAY()) + '/' + string.valueof(strDate.MONTH()) + '/' + string.valueof(strDate.YEAR());
        }else{
            datestring = '';
        }
        system.debug('ConvertDate: ' + datestring);
        return datestring;
    }
    
    //Sort Descending for Subbrand Grade
    public string SBGradeSorting(decimal strSeq){
        string returnString;
        if (strSeq != null){
            if (strSeq < 10){
                returnString = '0000' + string.valueof(strSeq);
            }else if (strSeq > 9 && strSeq < 100){
                returnString = '000' + string.valueof(strSeq);
            }else if (strSeq > 99 && strSeq < 1000){
                returnString = '00' + string.valueof(strSeq);
            }else if (strSeq > 999 && strSeq < 10000){
                returnString = '0' + string.valueof(strSeq);
            }
        }else{
            returnString = '00000';
        }
        returnString = string.valueof(99999 - integer.valueof(returnString));
        system.debug('SBGradeSorting: ' + returnString);
        return returnString;
    }
    public class DataClass{
        public string sbname {set;get;}
        public string sbgrade {set;get;}
        public decimal targetvol {set;get;}
        public decimal offtakevol {set;get;} 
        public decimal intakevol {set;get;}
        public decimal btlcollection {set;get;}
        public decimal offtakeVSintake {set;get;}
        public decimal collectionVSofftake {set;get;}
        public decimal collectionVSintake {set;get;}
        public decimal collectionVScontract {set;get;}
        public decimal intakeVScontract {set;get;}
        public string strSubBrand {set;get;} //Added by Twinkle 20141218
    }
}
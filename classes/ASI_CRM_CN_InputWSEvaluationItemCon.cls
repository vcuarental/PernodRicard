public without sharing class ASI_CRM_CN_InputWSEvaluationItemCon {
    public string PageId {set;get;}
    
    //Query 
    public ASI_CRM_WS_Evaluation__c thisWS {set;get;}
    public list<ASI_CRM_WS_Evaluation_Items__c> thisWSLineItem {set;get;}
    public list<ASI_CRM_WS_Evaluation_Items__c> showWSLineItem {set;get;}
    Transient public list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List {set;get;}
    Transient public list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List_Opening {set;get;}
    Transient public list<ASI_CRM_Subbrand_Volume__c> SB_Vol_List_Closing {set;get;}
    public list<ASI_CRM_WS_Target__c> Target_List {set;get;}
    
    public map<string, DataClass> AllData {set;get;}
    public map<string, AbsExeptionClass> AbsExeptionData {set;get;}
    
    public ASI_CRM_CN_InputWSEvaluationItemCon (ApexPages.StandardController con){
        PageId = ApexPages.currentPage().getParameters().get('id');
        AllData = new map<string, DataClass>();
        AbsExeptionData = new map<string, AbsExeptionClass>();
        if (PageId != null){
            try{
                thisWS = [Select name, id, ASI_CRM_T1_WS__c, ASI_CRM_T1_WS_Addition__c, ASI_CRM_Quarter__c, ASI_CRM_Fiscal_Year__c, ASI_CRM_Period_End__c, 
                            ASI_CRM_Period_Start__c, ASI_CRM_T1_WS_Addition__r.ASI_CRM_Account__c, ASI_CRM_CN_Period_End_Date__c, ASI_CRM_CN_Period_Start_Date__c
                            FROM ASI_CRM_WS_Evaluation__c 
                            WHERE id = :PageId];
            }catch(exception e){
      //          system.debug('Try thisWS Failed: ' + e);
                thisWS = new ASI_CRM_WS_Evaluation__c();
            }
            try{
                thisWSLineItem = [Select name, id, ASI_CRM_Achieve_Rate__c, ASI_CRM_Calculated_Incentive__c, ASI_CRM_City__c,
                                    ASI_CRM_Comment__c, ASI_CRM_Data_Quality_Rate__c, ASI_CRM_WS_Evaluation__c, ASI_CRM_incentive__c,  
                                    ASI_CRM_Scan_Rate__c, ASI_CRM_Target__c, ASI_CRM_WS_Code__c, ASI_CRM_WS_GS__c, ASI_CRM_WS__c, ASI_CRM_WS2__c,
                                    ASI_CRM_CN_Actual_Volume__c, ASI_CRM_CN_Actual_Value__c, ASI_CRM_CN_Target_Volume__c, ASI_CRM_CN_Target_Value__c,
                                    ASI_CRM_CN_WS_Code__c
                                    FROM ASI_CRM_WS_Evaluation_Items__c 
                                    WHERE RecordType.DeveloperName = 'ASI_CRM_CN_WS_Evaluation_Item' AND ASI_CRM_WS_Evaluation__c = :PageId];
            }catch(exception e){
      //          system.debug('Try thisWSLineItem Failed: ' + e);
                thisWSLineItem = new list<ASI_CRM_WS_Evaluation_Items__c>();
            }
        }else{
            thisWS = new ASI_CRM_WS_Evaluation__c();
            thisWSLineItem = new list<ASI_CRM_WS_Evaluation_Items__c>();
        }
        if (thisWSLineItem.size() > 0){
            showWSLineItem = thisWSLineItem;
        }else{
            showWSLineItem = new list<ASI_CRM_WS_Evaluation_Items__c>();
            Init();
        }
    }
    public void Init(){
        //get thisWS T2 Target List
        try{
            Target_List = [SELECT ASI_CRM_T2_WS__r.ASI_CRM_Account__c, ASI_CRM_Fiscal_Year__c, ASI_CRM_GS_Target__c, ASI_CRM_Quarter__c,  
                            ASI_CRM_Vol_Target__c , ASI_CRM_CN_Period_Start_Date__c, ASI_CRM_CN_Period_End_Date__c, ASI_CRM_T2_WS__c
                            FROM ASI_CRM_WS_Target__c
                            WHERE ASI_CRM_T2_WS__r.ASI_CRM_CN_T1_WS1__c = :thisWS.ASI_CRM_T1_WS_Addition__c AND
                            ASI_CRM_CN_Period_Start_Date__c >= :thisWS.ASI_CRM_CN_Period_Start_Date__c AND
                            ASI_CRM_CN_Period_End_Date__c <= :thisWS.ASI_CRM_CN_Period_End_Date__c
                            ORDER BY Createddate DESC]; 
        }catch(exception e){
       //     system.debug('Try Target_List Failed: ' + e);
            Target_List = new list<ASI_CRM_WS_Target__c>();
        }
     //   system.debug('Target_list: ' + Target_List );
        //Map thisWS T2 Target
        map<id, ASI_CRM_WS_Target__c> Target_Data_Map = new map<id, ASI_CRM_WS_Target__c>();
        if (Target_List.size() > 0){
            id strkey;
            for (ASI_CRM_WS_Target__c tltemp : Target_List){
                strkey = tltemp.ASI_CRM_T2_WS__c;
                if (!Target_Data_Map.containskey(strkey)){
                    Target_Data_Map.put(strkey, tltemp);
                }
            }
        }
        //get Subbrand Volume Data
        date SubmitInv_Pdate = thisWS.ASI_CRM_CN_Period_Start_Date__c.addMonths(-1);
        string wsid = string.valueof(thisWS.ASI_CRM_T1_WS_Addition__c).left(15);
        try{
            SB_Vol_List = [SELECT ASI_CRM_Empty_Bottle__c, ASI_CRM_Green_Cap__c, ASI_CRM_Red_Cap__c, ASI_CRM_Month__c, 
                            ASI_CRM_Offtake__c, ASI_CRM_PR_Direct__c,ASI_CRM_PR_DIRECT_L50__c, 
                            ASI_CRM_T2_Depletion_L50__c,ASI_CRM_PR_DIRECT_GS_L50__c,
                            ASI_CRM_T1_Depletion_L50__c,
                            ASI_CRM_PR_DIRECT_GS__c, 
                            ASI_CRM_PR_SHIPMENT__c, ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.Name, 
                            ASI_CRM_T1_Depletion__c, ASI_CRM_T2_Depletion_GS__c, ASI_CRM_T2_DepletiontoT3__c,
                            ASI_CRM_T1_Depletion_GS__c,  
                            ASI_CRM_WS_INV__c, ASI_CRM_T2_Depletion__c, ASI_CRM_T2_receive_scan__c, 
                            ASI_CRM_T1_DepletiontoT2__c, ASI_CRM_Account__c, ASI_CRM_Account__r.Name, ASI_CRM_Account__r.ASI_CRM_Account__c, 
                            ASI_CRM_CN_Account_Id__c  ,ASI_CRM_Yellow_Cap__c, ASI_CRM_End_Date__c, ASI_CRM_Sub_brand_Code__c, ASI_CRM_Brand_Code__c, ASI_CRM_CN_Product_Category__c 
                            FROM ASI_CRM_Subbrand_Volume__c
                            WHERE ASI_CRM_WS_T1__c = :wsid
                            AND ASI_CRM_End_Date__c >= : thisWS.ASI_CRM_CN_Period_Start_Date__c
                            AND ASI_CRM_End_Date__c <= : thisWS.ASI_CRM_CN_Period_End_Date__c
                            AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                            ORDER BY ASI_CRM_End_Date__c DESC];
        }catch(exception e){
       //     system.debug('Try SB_Vol_List Failed: ' + e);
            SB_Vol_List = new list<ASI_CRM_Subbrand_Volume__c>();
        }
        //get Opening Inventory
        try{
            SB_Vol_List_Opening = [SELECT ASI_CRM_Subbrand__c, ASI_CRM_Account__c, ASI_CRM_End_Date__c ,ASI_CRM_WS_INV__c, ASI_CRM_Sub_brand_Code__c, ASI_CRM_Brand_Code__c
                            FROM ASI_CRM_Subbrand_Volume__c
                            WHERE ASI_CRM_WS_T1__c = :wsid
                            AND ASI_CRM_End_Date__c >= : SubmitInv_Pdate
                            AND ASI_CRM_End_Date__c <= : thisWS.ASI_CRM_CN_Period_Start_Date__c
                            AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                            ORDER BY ASI_CRM_End_Date__c DESC];
        }catch(exception e){
            SB_Vol_List_Opening  = new list<ASI_CRM_Subbrand_Volume__c>();
        }
        //get Closing Inventory
        Integer numberOfDays = Date.daysInMonth(thisWS.ASI_CRM_CN_Period_End_Date__c.year(), (thisWS.ASI_CRM_CN_Period_End_Date__c).month());
        Date lastDayOfMonth = Date.newInstance(thisWS.ASI_CRM_CN_Period_End_Date__c.year(), (thisWS.ASI_CRM_CN_Period_End_Date__c).month(), numberOfDays);
        try{
            SB_Vol_List_Closing = [SELECT ASI_CRM_Subbrand__c, ASI_CRM_Account__c, ASI_CRM_End_Date__c ,ASI_CRM_WS_INV__c, ASI_CRM_Sub_brand_Code__c, ASI_CRM_Brand_Code__c
                            FROM ASI_CRM_Subbrand_Volume__c
                            WHERE ASI_CRM_WS_T1__c = :wsid
                            AND ASI_CRM_End_Date__c = : lastDayOfMonth 
                            AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                            ORDER BY ASI_CRM_End_Date__c DESC];
        }catch(exception e){
            SB_Vol_List_Closing = new list<ASI_CRM_Subbrand_Volume__c>();
        }
      //  system.debug('SB_Vol_List : ' + SB_Vol_List );
        
        map<string, DataClass> MonthData = new map<string, DataClass>();  //Master Data
        map<string, decimal> EndMonthSubmitted = new map<string, decimal>();
        map<string, decimal> StartMonthSubmitted = new map<string, decimal>();
        //map<string, decimal> AllMonthSubmitted = new map<string, decimal>();
        map<string, DataClass> Opening_Map = new map<string, DataClass>();
        string strkey;
        string strAcc;
        decimal Intake;
        decimal intakeExclusion; //for scan rate
        decimal Opening;
        string PreviousMonth;
        if (SB_Vol_List_Opening.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c opentemp : SB_Vol_List_Opening){
                strkey = string.valueof(opentemp.ASI_CRM_Account__c) + string.valueof(opentemp.ASI_CRM_Subbrand__c);
                if (StartMonthSubmitted.containsKey(strkey)) {
                    if (opentemp.ASI_CRM_WS_INV__c != null) {
                        decimal inv = StartMonthSubmitted.get(strkey) + opentemp.ASI_CRM_WS_INV__c;
                        StartMonthSubmitted.put(strkey, inv);
                    }
                        
                } else {
                    if (opentemp.ASI_CRM_WS_INV__c != null)
                        StartMonthSubmitted.put(strkey, opentemp.ASI_CRM_WS_INV__c);
                    else
                        StartMonthSubmitted.put(strkey, 0);
                }
            }
        }
        if (SB_Vol_List_Closing.size() > 0){
            for (ASI_CRM_Subbrand_Volume__c closetemp : SB_Vol_List_Closing){
                strkey = string.valueof(closetemp.ASI_CRM_Account__c) + string.valueof(closetemp.ASI_CRM_Subbrand__c);
                if (EndMonthSubmitted.containsKey(strkey)) {
                    if (closetemp.ASI_CRM_WS_INV__c != null) {
                        decimal inv = EndMonthSubmitted.get(strkey) + closetemp.ASI_CRM_WS_INV__c;
                        EndMonthSubmitted.put(strkey, inv);
                    }
                } else {
                    if (closetemp.ASI_CRM_WS_INV__c != null)
                        EndMonthSubmitted.put(strkey, closetemp.ASI_CRM_WS_INV__c);
                    else
                        EndMonthSubmitted.put(strkey, 0);
                }
                
            }
        }
        
        //Put Actual Data 
        if (SB_Vol_List.size() > 0){
            decimal strGS;
            decimal buyout;
            decimal ReceiveScan;
			decimal IntakeExclT2;
            decimal ActualIntake;
            decimal receiveScanExclusion; //for scan rate
            decimal exclusion; //for less than 50 ml
            decimal exclusionScanRate; //for less than 50 ml and for scan rate
            decimal submit;
            //Integer numberOfDays;
            for ( ASI_CRM_Subbrand_Volume__c sbtemp : SB_Vol_List){
                strAcc = sbtemp.ASI_CRM_Account__c;
                //strkey = strAcc + string.valueof(sbtemp.ASI_CRM_End_Date__c) + sbtemp.ASI_CRM_Subbrand__c;
                strkey = strAcc + sbtemp.ASI_CRM_Subbrand__c;
             //   system.debug('Put Actual Data');
                if (sbtemp.ASI_CRM_End_Date__c >= thisWS.ASI_CRM_CN_Period_Start_Date__c && sbtemp.ASI_CRM_End_Date__c <= thisWS.ASI_CRM_CN_Period_End_Date__c){
             //   system.debug('Actual Data within Start End Date');
                //Intake    
                    Intake = 0;
                    IntakeExclT2 = 0;
                    if (sbtemp.ASI_CRM_T1_Depletion__c != null){
                        Intake += sbtemp.ASI_CRM_T1_Depletion__c;
						IntakeExclT2 += sbtemp.ASI_CRM_T1_Depletion__c;
                    }
              //      system.debug('Intake ASI_CRM_T1_Depletion__c : ' + sbtemp.ASI_CRM_T1_Depletion__c + ' + ' +  Intake);
                    if (sbtemp.ASI_CRM_T2_Depletion__c != null){
                        Intake += sbtemp.ASI_CRM_T2_Depletion__c;
                    }
            //        system.debug('Intake ASI_CRM_T2_Depletion__c: ' + sbtemp.ASI_CRM_T2_Depletion__c+ ' + ' +  Intake);
                    if (sbtemp.ASI_CRM_PR_Direct__c != null){
                        Intake += sbtemp.ASI_CRM_PR_Direct__c;
						IntakeExclT2 += sbtemp.ASI_CRM_PR_Direct__c;
                    }
                    intakeExclusion = 0;
                    exclusionScanRate = 0;
                    //Special Exclusion logic for Scan Rate
                    if (sbtemp.ASI_CRM_CN_Product_Category__c!= null && sbtemp.ASI_CRM_Sub_brand_Code__c != null && (sbtemp.ASI_CRM_CN_Product_Category__c == 'Wine' || sbtemp.ASI_CRM_CN_Product_Category__c =='RTD' || sbtemp.ASI_CRM_CN_Product_Category__c =='Baijiu') && sbtemp.ASI_CRM_Sub_brand_Code__c != 'JCS'){
                       // intakeExclusion = 0;
                        if (sbtemp.ASI_CRM_T1_Depletion__c != null){
                            intakeExclusion += sbtemp.ASI_CRM_T1_Depletion__c;
                        }
                        
                    /*    if (sbtemp.ASI_CRM_T2_Depletion__c != null){
                            intakeExclusion += sbtemp.ASI_CRM_T2_Depletion__c;
                        }*/
                        
                        if (sbtemp.ASI_CRM_PR_Direct__c != null){
                            intakeExclusion += sbtemp.ASI_CRM_PR_Direct__c;
                        }
                       // exclusionScanRate = 0;
                    
                        if (sbtemp.ASI_CRM_PR_DIRECT_L50__c != null){
                            exclusionScanRate += sbtemp.ASI_CRM_PR_DIRECT_L50__c ;
                        }
                        
                        if (sbtemp.ASI_CRM_T1_Depletion_L50__c != null){
                            exclusionScanRate += sbtemp.ASI_CRM_T1_Depletion_L50__c ;
                        }
                        
                     /*   if (sbtemp.ASI_CRM_T2_Depletion_L50__c != null){
                            exclusionScanRate += sbtemp.ASI_CRM_T2_Depletion_L50__c ;
                        }*/
                        
                        
                    }
                    
                    
               //     system.debug('Intake ASI_CRM_PR_Direct__c: ' + sbtemp.ASI_CRM_PR_Direct__c + ' + ' + Intake);
                //Actual Intake
                    ActualIntake = 0;
                    if (sbtemp.ASI_CRM_T1_Depletion__c != null){
                        ActualIntake += sbtemp.ASI_CRM_T1_Depletion__c;
                    }
           //         system.debug('ActualIntake: ' + ActualIntake );
                //Exclusion 
                    exclusion = 0;
                    
                    if (sbtemp.ASI_CRM_PR_DIRECT_L50__c != null){
                        exclusion += sbtemp.ASI_CRM_PR_DIRECT_L50__c ;
                    }
                //    system.debug('exclusion : ' + sbtemp.ASI_CRM_PR_DIRECT_L50__c  + ' + ' +  exclusion );
                    if (sbtemp.ASI_CRM_T1_Depletion_L50__c != null){
                        exclusion += sbtemp.ASI_CRM_T1_Depletion_L50__c ;
                    }
               //     system.debug('exclusion : ' + sbtemp.ASI_CRM_T1_Depletion_L50__c + ' + ' +  exclusion );
              /*      if (sbtemp.ASI_CRM_T2_Depletion_L50__c != null){
                        exclusion += sbtemp.ASI_CRM_T2_Depletion_L50__c ;
                    }*/
              //      system.debug('exclusion : ' + sbtemp.ASI_CRM_T2_Depletion_L50__c + ' + ' +  exclusion );
                    
                //Buy Out
                    buyout = 0;
                    if (sbtemp.ASI_CRM_T2_DepletiontoT3__c != null)
                        buyout = sbtemp.ASI_CRM_T2_DepletiontoT3__c;
              //      system.debug('buyout: ' + buyout);
              //      system.debug('Wilson buyout: ' + sbtemp.ASI_CRM_Account__c + ' ' + sbtemp.ASI_CRM_Sub_brand_Code__c + ' ' + sbtemp.ASI_CRM_End_Date__c);

                //GS
                    strGS = 0;
                    if (sbtemp.ASI_CRM_T1_Depletion_GS__c != null){
                        strGS += sbtemp.ASI_CRM_T1_Depletion_GS__c ;
                    }
                //ReceiveScan
                    ReceiveScan = 0;
                    receiveScanExclusion = 0;
                    if (sbtemp.ASI_CRM_T2_receive_scan__c!= null){
                        ReceiveScan += sbtemp.ASI_CRM_T2_receive_scan__c;
                        //Special Exclusion logic for Scan Rate
                        if (sbtemp.ASI_CRM_CN_Product_Category__c!= null && sbtemp.ASI_CRM_Sub_brand_Code__c != null && (sbtemp.ASI_CRM_CN_Product_Category__c == 'Wine' || sbtemp.ASI_CRM_CN_Product_Category__c =='RTD' || sbtemp.ASI_CRM_CN_Product_Category__c =='Baijiu') && sbtemp.ASI_CRM_Sub_brand_Code__c != 'JCS')
                        {
                            receiveScanExclusion += sbtemp.ASI_CRM_T2_receive_scan__c;
                        }
                    }
                    


                    DataClass newitem = new DataClass();
                    newitem.sbname = sbtemp.ASI_CRM_Subbrand__c;
                    newitem.accname = sbtemp.ASI_CRM_Account__c;
                    newitem.sbcode = sbtemp.ASI_CRM_Sub_brand_Code__c;
                    newitem.bcode = sbtemp.ASI_CRM_Brand_Code__c;
                    newitem.strTarget = 0;
                    newitem.strAcheiveRate = 0;
                    newitem.strScanRate = 0;
                    newitem.strDataQty = 0;
                    newitem.strWSGS = strGS;
                    newitem.strCalcIncentive = 0;
                    newitem.strTargetGS = 0;
                    newitem.strTargetVol = 0;
                    //newitem.Previous_Submitted = Opening;
                    newitem.Intake = Intake;
					newitem.IntakeExclT2 = IntakeExclT2;
                    newitem.BuyOut = buyout;
                    newitem.exclusion = exclusion;
                    newitem.strActualIntake = ActualIntake;
                    newitem.strAbs = 0;
                    newitem.receiveScan = ReceiveScan;
                    newitem.receiveScanExclusion = receiveScanExclusion;
                    newitem.intakeExclusion = intakeExclusion;
                    newitem.exclusionScanRate = exclusionScanRate;
                    //newitem.strsubmit = submit;
                    
                    if (MonthData.containskey(strkey)){
                        MonthData.get(strkey).strWSGS += strGS;
                        //MonthData.get(strkey).Previous_Submitted += Opening;
                        MonthData.get(strkey).Intake += Intake;
						MonthData.get(strkey).IntakeExclT2 += IntakeExclT2;
                        MonthData.get(strkey).exclusion += exclusion;
                        MonthData.get(strkey).strActualIntake += ActualIntake;
                        MonthData.get(strkey).BuyOut += buyout;
                        MonthData.get(strkey).receiveScan += ReceiveScan;
                        MonthData.get(strkey).receiveScanExclusion = receiveScanExclusion;
                        MonthData.get(strkey).intakeExclusion += intakeExclusion;
                        //MonthData.get(strkey).strsubmit += submit;
                    }else{
                        MonthData.put(strkey, newitem);
                    }

                }
            }
        } //End of put actual data
        
        
        
        
      //  system.debug('MonthData : ' + MonthData);
//Calculate KPI per sub-brand        
    if (MonthData.size() > 0){
        
            //string strAcc;
            decimal strTargetGS;
            decimal strTargetVol;
            decimal EndMonthSubmit;
            decimal receiveScan;
            decimal t1depletion;
            decimal receiveScanExclusion;
            decimal t1depletionExclusion;
            decimal strAbs;
            decimal strBeforeAbs;
            string strAccSb;
            decimal strclose;
            for (DataClass datatemp : MonthData.values()){
                strAcc = datatemp.accname;
                strAccSb = strAcc + datatemp.sbname;
        //Target
                strTargetGS = 0;
                strTargetVol = 0;
                if (Target_Data_Map.containskey(strAcc)){
                    if (Target_Data_Map.get(strAcc).ASI_CRM_GS_Target__c != null)
                        strTargetGS = Target_Data_Map.get(strAcc).ASI_CRM_GS_Target__c ;
                    if (Target_Data_Map.get(strAcc).ASI_CRM_Vol_Target__c != null)
                        strTargetVol = Target_Data_Map.get(strAcc).ASI_CRM_Vol_Target__c ;
                }
                
        //Scan Rate (receive scan & t1depletion
                t1depletion = 0;
                if (datatemp.IntakeExclT2 != null && datatemp.exclusion != null){
                    //t1depletion += datatemp.Intake - datatemp.exclusion;
					t1depletion += datatemp.IntakeExclT2- datatemp.exclusion;
                }
                receiveScan = 0;
                if (datatemp.receiveScan != null){
                    receiveScan += datatemp.receiveScan;
                }
                
                //Special Exclusion logic for scan rate
                t1depletionExclusion = 0;
                if (datatemp.intakeExclusion != null && datatemp.exclusionScanRate != null){
                    t1depletionExclusion += datatemp.intakeExclusion - datatemp.exclusionScanRate;
                }
                receiveScanExclusion = 0;
                if (datatemp.receiveScanExclusion != null){
                    receiveScanExclusion += datatemp.receiveScanExclusion;
                }
        //Data Quality Rate
                strAbs = 0;
                if (datatemp.Intake != null){
                    strAbs = datatemp.Intake; 
                    if(datatemp.sbcode == 'JCG'){
                            system.debug('Wilson:Intake: ' + datatemp.sbcode + ' ' + datatemp.Intake + ' ' + datatemp.accname);
                        }
                }
                /*if (datatemp.Previous_Submitted != null){
                    strAbs += datatemp.Previous_Submitted;
                }*/
                if (datatemp.buyout != null){
                    strAbs -= datatemp.buyout;
                    if(datatemp.sbcode == 'JCG'){
                            system.debug('Wilson:Buyout: ' + datatemp.sbcode + ' ' + datatemp.buyout + ' ' + datatemp.accname);
                        }
                }
             //   system.debug('strAbs: ' + strAbs);
                /*if (AllMonthSubmitted.containskey(datatemp.accname)){
                    strAbs -= AllMonthSubmitted.get(datatemp.accname);
                }
                if (datatemp.strsubmit != null){
                    strAbs -= datatemp.strsubmit;
                }*/
                if (StartMonthSubmitted.containskey(strAccSb)){
                    if (StartMonthSubmitted.get(strAccSb) != null){
                        strAbs += StartMonthSubmitted.get(strAccSb);
                        if(datatemp.sbcode == 'JCG'){
                            system.debug('Wilson:Opening inventory: ' + datatemp.sbcode + ' ' + StartMonthSubmitted.get(strAccSb) + ' ' + datatemp.accname);
                        }
                    }
                }
                strclose = 0;
                if (EndMonthSubmitted.containskey(strAccSb)){
                    if (EndMonthSubmitted.get(strAccSb) != null){
                        strclose = EndMonthSubmitted.get(strAccSb);
                        if(datatemp.sbcode == 'JCG'){
                            system.debug('Wilson:Closing inventory: ' + datatemp.sbcode + ' ' + EndMonthSubmitted.get(strAccSb) + ' ' + datatemp.accname);
                        }
                    }
                }
                strAbs -= strclose;
                strBeforeAbs = strAbs;
                if (strAbs < 0){
                    strAbs = (-1) * strAbs;
                }
                if(datatemp.sbcode == 'JCG'){
                system.debug('Wilson:Sub-brand ABS Difference: ' + datatemp.sbcode + ' ' + strAbs + ' ' + datatemp.accname);
                }
                if (datatemp.sbcode == 'AB1' || datatemp.sbcode == 'AB2' || datatemp.bcode == 'HLM' || datatemp.bcode == 'ABS' || datatemp.sbcode == 'JCO' || datatemp.sbcode == 'JCS' || datatemp.sbcode == 'GL5' || datatemp.sbcode == 'TG7')
                {
                    /*
                    AB1 or AB2 map to AB1_AB2
                    Brand ABS exclude AB1, AB2 map to Brand_ABS
                    Brand HLM map to Brand_HLM
                    TG7 or GL5 map to TG7_GL5
                    JCO or JCS map to JCO_JCS
                    */                
                    AbsExeptionClass a = new AbsExeptionClass();
                    a.strAcc = datatemp.accname;
                    a.absDiff_AB1 = 0;
                    a.absDiffB4_AB1 = 0;
                    a.absDiff_ABS = 0;
                    a.absDiffB4_ABS = 0;
                    a.absDiff_GL5 = 0;
                    a.absDiffB4_GL5 = 0;
                    a.absDiff_HLM = 0;
                    a.absDiffB4_HLM = 0;
                    a.absDiff_JCO = 0;
                    a.absDiffB4_JCO = 0;
        
                    if (datatemp.sbcode == 'AB1' || datatemp.sbcode == 'AB2')
                    {
                        a.absDiff_AB1 = strAbs;
                        a.absDiffB4_AB1 = strBeforeAbs;
                    }
                    else if (datatemp.sbcode == 'GL5' || datatemp.sbcode == 'TG7')
                    {
                        a.absDiff_GL5 = strAbs;
                        a.absDiffB4_GL5 = strBeforeAbs;
                         system.debug('Wilson: GL5 OR TG7: ' + datatemp.sbcode + ' ' + strAbs + ' ' + datatemp.accname);
                    }
                    else if (datatemp.sbcode == 'JCO' || datatemp.sbcode == 'JCS')
                    {
                        a.absDiff_JCO = strAbs;
                        a.absDiffB4_JCO = strBeforeAbs;
                    }
                    else if (datatemp.bcode == 'ABS')
                    {
                        a.absDiff_ABS = strAbs;
                        a.absDiffB4_ABS = strBeforeAbs;
                    }
                    else if (datatemp.bcode == 'HLM')
                    {
                        a.absDiff_HLM = strAbs;
                        a.absDiffB4_HLM = strBeforeAbs;
                    }
                    else
                    {
                    }
                    
                    if (AbsExeptionData.containskey(strAcc)){
                            system.debug('Wilson Debug 0.3: Each customer: ' + strAcc+ ' - ' + AbsExeptionData.get(strAcc)); 
                            AbsExeptionData.get(strAcc).strAcc = a.strAcc;
                            AbsExeptionData.get(strAcc).absDiff_AB1 += a.absDiff_AB1;
                            AbsExeptionData.get(strAcc).absDiffB4_AB1 += a.absDiffB4_AB1;
                            AbsExeptionData.get(strAcc).absDiff_GL5 += a.absDiff_GL5;
                            AbsExeptionData.get(strAcc).absDiffB4_GL5 += a.absDiffB4_GL5;
                            AbsExeptionData.get(strAcc).absDiff_JCO += a.absDiff_JCO;
                            AbsExeptionData.get(strAcc).absDiffB4_JCO += a.absDiffB4_JCO;
                            AbsExeptionData.get(strAcc).absDiff_ABS += a.absDiff_ABS;
                            AbsExeptionData.get(strAcc).absDiffB4_ABS += a.absDiffB4_ABS;
                            AbsExeptionData.get(strAcc).absDiff_HLM += a.absDiff_HLM;
                            AbsExeptionData.get(strAcc).absDiffB4_HLM += a.absDiffB4_HLM;

                        }else{
                            AbsExeptionData.put(strAcc, a);
                        }                             
                }           
                        
                                
                DataClass newitem = new DataClass();
                newitem.sbname = datatemp.sbname;
                newitem.accname = datatemp.accname;
                newitem.strTarget = 0;
                newitem.strAcheiveRate = 0; 
                newitem.strScanRate = 0;
                newitem.strDataQty = 0;
                newitem.strWSGS = datatemp.strWSGS;
                newitem.strCalcIncentive = 0;
                newitem.strTargetGS = strTargetGS;
                newitem.strTargetVol = strTargetVol;
                newitem.Previous_Submitted = 0;
                newitem.Intake = t1depletion;
                newitem.BuyOut = 0;
                newitem.exclusion = 0;
                newitem.strActualIntake = datatemp.strActualIntake;
                newitem.strAbs = strAbs;
                newitem.strSubmitted = strclose ;
                newitem.receiveScan = receiveScan;
                newitem.receiveScanExclusion = receiveScanExclusion;
                newitem.intakeExclusion = t1depletionExclusion;
                
                if (AllData.containskey(strAcc)){
                    AllData.get(strAcc).strWSGS += datatemp.strWSGS;
                    AllData.get(strAcc).Intake += t1depletion;
                    AllData.get(strAcc).strActualIntake += datatemp.strActualIntake;
                    AllData.get(strAcc).strAbs += strAbs;
                    AllData.get(strAcc).strSubmitted += strclose;
                    AllData.get(strAcc).receiveScan += receiveScan;
                    //Special exclusion logic for Scan rate
                    AllData.get(strAcc).receiveScanExclusion += receiveScanExclusion;
                    AllData.get(strAcc).intakeExclusion += t1depletionExclusion;
                    
                    
                }else{
                    AllData.put(strAcc, newitem);
                }
        }
    }   
 
        //End Calculate KPI per sub-brand
        for(AbsExeptionClass absExp : AbsExeptionData.values())
        {   
            if (AllData.containskey(absExp.strAcc)){
        //    system.debug('All Exception Data: ' + absExp);
                if (absExp.absDiffB4_AB1 < 0){
                    absExp.absDiffB4_AB1 = (-1) * absExp.absDiffB4_AB1;
                }
                if (absExp.absDiffB4_JCO < 0){
                    absExp.absDiffB4_JCO = (-1) * absExp.absDiffB4_JCO;
                }
                if (absExp.absDiffB4_GL5 < 0){
                    absExp.absDiffB4_GL5 = (-1) * absExp.absDiffB4_GL5;
                }
                if (absExp.absDiffB4_HLM < 0){
                    absExp.absDiffB4_HLM = (-1) * absExp.absDiffB4_HLM;
                }
                if (absExp.absDiffB4_ABS < 0){
                    absExp.absDiffB4_ABS = (-1) * absExp.absDiffB4_ABS;
                }
                //add the difference before absolute of those exception
             //   system.debug('Wilson Debug : Abs Difference: ' + AllData.get(absExp.strAcc).strAbs);
                AllData.get(absExp.strAcc).strAbs = AllData.get(absExp.strAcc).strAbs + absExp.absDiffB4_AB1 + absExp.absDiffB4_JCO + absExp.absDiffB4_GL5 + absExp.absDiffB4_ABS + absExp.absDiffB4_HLM;
            //    system.debug('Wilson Debug : add Difference: ' + AllData.get(absExp.strAcc).strAbs);
                //minus the absolute difference of those exception
                AllData.get(absExp.strAcc).strAbs = AllData.get(absExp.strAcc).strAbs - absExp.absDiff_AB1 - absExp.absDiff_JCO - absExp.absDiff_GL5 - absExp.absDiff_ABS - absExp.absDiff_HLM;
         //       system.debug('Wilson Debug : After Difference: ' + AllData.get(absExp.strAcc).strAbs);
            }   
        }       
        
      //  system.debug('AllData: ' + AllData.size() + ' - ' + AllData);
        if (AllData.size()>0){
            decimal strB;
            decimal strC;
            decimal strD;
            decimal lastmonthsubmit;
            list<ASI_CRM_AccountsAdditionalField__c> checkWSCode = new list<ASI_CRM_AccountsAdditionalField__c>();
            try{
                checkWSCode = [SELECT ASI_CRM_CN_CRM_Code__c, id
                                FROM ASI_CRM_AccountsAdditionalField__c 
                                WHERE ASI_CRM_CN_T1_WS1__c = :thisWS.ASI_CRM_T1_WS_Addition__c];
            }catch(exception e){
          //      system.debug('CheckWSCode try failed: ' + e);
            }
            map<id, string> wscode_map = new map<id, string>();
            if (checkWSCode.size() > 0){
                for (ASI_CRM_AccountsAdditionalField__c wscodetemp : checkWSCode){
                    wscode_map.put(wscodetemp.id, wscodetemp.ASI_CRM_CN_CRM_Code__c);
                }
            }
            for (DataClass alltemp : AllData.values()){
                //Acheive Rate
                if (alltemp.strTargetGS != 0){
                    alltemp.strAcheiveRate = alltemp.strWSGS / alltemp.strTargetGS * 100;
                    alltemp.strTarget = alltemp.strTargetGS;
                }else if (alltemp.strTargetVol != 0){
                    alltemp.strAcheiveRate = alltemp.strActualIntake / alltemp.strTargetVol * 100;
                    alltemp.strTarget = alltemp.strTargetVol;
                }
             //   system.debug('alltemp.strTarget: ' + alltemp.strTarget);
                //Scan Rate
                if (alltemp.receiveScanExclusion == null)
                alltemp.receiveScanExclusion = 0;
                if (alltemp.intakeExclusion == null)
                alltemp.intakeExclusion = 0;
                
                //if (alltemp.Intake != 0 && alltemp.receiveScan != 0){
                if ((alltemp.Intake-alltemp.intakeExclusion) != 0 && (alltemp.receiveScan-alltemp.receiveScanExclusion) != 0){
                    alltemp.strScanRate = (alltemp.receiveScan-alltemp.receiveScanExclusion) / (alltemp.Intake-alltemp.intakeExclusion) *100;
                //    alltemp.strScanRate = alltemp.receiveScan / alltemp.Intake *100;
                }
                else
                {
                    alltemp.strScanRate = 0;
                }
             //   system.debug('alltemp.strScanRate : ' + alltemp.strScanRate );
                //Data Quality Rate
                lastmonthsubmit = 0;
                if (EndMonthSubmitted.containskey(alltemp.accname)){
                    lastmonthsubmit = EndMonthSubmitted.get(alltemp.accname);
                }
                if (alltemp.strAbs != 0 && alltemp.strSubmitted != 0){
                    alltemp.strDataQty = (1-(alltemp.strAbs / alltemp.strSubmitted )) *100;
                }else if(alltemp.strAbs != 0 && alltemp.strSubmitted == 0){
                    alltemp.strDataQty = 0;
                }else{
                    alltemp.strDataQty = 100;
                }
             //   system.debug('alltemp.strDataQty : ' + alltemp.strAbs + ' / ' + lastmonthsubmit );
             //   system.debug('alltemp.strDataQty : ' + alltemp.strDataQty );
                //Calculated Incentive
                strB = 0;
                if (alltemp.strAcheiveRate < 80){
                    strB = 0;
                }else if (alltemp.strAcheiveRate >= 80 && alltemp.strAcheiveRate < 100){
                    strB = 0.5;
                }else if (alltemp.strAcheiveRate >= 100){
                    strB = 1;
                }
                strC = 0;
                if (alltemp.strScanRate < 90 ){
                    strC = 0;
                }else if (alltemp.strScanRate >= 90  && alltemp.strScanRate  <= 94){
                    strC = 0.5;
                }else if (alltemp.strScanRate >94){
                    strC = 1;
                }
                strD = 0;
                if (alltemp.strDataQty < 90){
                    strD = 0;
                }else if (alltemp.strDataQty >=90){
                    strD = 1;
                }
                alltemp.strCalcIncentive = alltemp.strWSGS * 1.5/100 * strB * strC * strD;
                
                if (wscode_map.containskey(alltemp.accname)){
                    alltemp.wscode = wscode_map.get(alltemp.accname);
                }
            }
        }
    } //End of Init
    public void CreateLineItems(){
        if (showWSLineItem.size() == 0){
             RecordType rt = Global_RecordTypeCache.getRtRec('ASI_CRM_WS_Evaluation_Items__c'+ 'ASI_CRM_CN_WS_Evaluation_Item');
            
        
            list<ASI_CRM_WS_Evaluation_Items__c> InsertLine = new list<ASI_CRM_WS_Evaluation_Items__c>();
            if (AllData.size() > 0){
                for (string finaltemp : AllData.keyset()){
                    ASI_CRM_WS_Evaluation_Items__c newitem = new ASI_CRM_WS_Evaluation_Items__c();
                    newitem.ASI_CRM_WS_Evaluation__c = PageId;
                    newitem.ASI_CRM_WS2__c = finaltemp;
                    newitem.ASI_CRM_Target__c  = AllData.get(finaltemp).strTarget;
                    newitem.ASI_CRM_Achieve_Rate__c = AllData.get(finaltemp).strAcheiveRate;
                    newitem.ASI_CRM_CN_Target_Value__c = AllData.get(finaltemp).strTargetGS;
                    newitem.ASI_CRM_CN_Target_Volume__c = AllData.get(finaltemp).strTargetVol;
                    newitem.ASI_CRM_CN_Actual_Value__c = AllData.get(finaltemp).strWSGS;
                    newitem.ASI_CRM_CN_Actual_Volume__c = AllData.get(finaltemp).strActualIntake;
                    newitem.ASI_CRM_Scan_Rate__c  = AllData.get(finaltemp).strScanRate;
                    newitem.ASI_CRM_Data_Quality_Rate__c   = AllData.get(finaltemp).strDataQty;
                    newitem.ASI_CRM_WS_GS__c = AllData.get(finaltemp).strWSGS;
                    newitem.ASI_CRM_Calculated_Incentive__c = AllData.get(finaltemp).strCalcIncentive;
                    newitem.ASI_CRM_incentive__c = AllData.get(finaltemp).strCalcIncentive;
                    newitem.ASI_CRM_CN_WS_Code__c = AllData.get(finaltemp).wscode;
                    newitem.RecordTypeId = rt.id;
                    
                    InsertLine.add(newitem);
                }
                insert InsertLine;
                showWSLineItem = InsertLine;
            }
        }
    }
    public pageReference Save(){
        boolean canSave = true;
        string errormsg;
        if (showWSLineItem.size() >0){
            for (ASI_CRM_WS_Evaluation_Items__c a : showWSLineItem){
            //2014-07-30 Comment field is not needed if proposed amount < calculated amount
                if(a.ASI_CRM_Calculated_Incentive__c == NULL)
                    a.ASI_CRM_Calculated_Incentive__c = 0;
                if ((a.ASI_CRM_Incentive__c - a.ASI_CRM_Calculated_Incentive__c)>1 && (a.ASI_CRM_Comment__c == null || a.ASI_CRM_Comment__c == '') ){
                    a.ASI_CRM_Comment__c.addError('Required Field.');
                    return null;
                }
            }
            try{
                update showWSLineItem;
            }catch(exception e){
                canSave = false;
            }
        }
        if (canSave != true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Save Error.'));
            return null;
        }else{
            string url = '/'+ PageId ;
            PageReference returnPage = new PageReference(url);
            returnPage.setRedirect(true);
            return returnPage;
        }
    }
    public class DataClass{
        public string sbname {set;get;}
        public string accname {set;get;}
        public string sbcode {set;get;}
        public string bcode {set;get;}
        public decimal strTarget {set;get;}
        public decimal strAcheiveRate {set;get;}
        public decimal strScanRate {set;get;}
        public decimal strDataQty {set;get;}
        public decimal strWSGS {set;get;}
        public decimal strCalcIncentive {set;get;}
        public decimal strTargetGS {set;get;}
        public decimal strTargetVol {set;get;}
        public decimal strActualIntake {set;get;}
        public string wscode {set;get;}
        
        public decimal Previous_Submitted {set;get;}
        public decimal Intake {set;get;}
		public decimal IntakeExclT2 {set;get;}
        public decimal exclusion {set;get;}
        public decimal BuyOut {set;get;}
        public decimal receiveScan {set;get;}
        public decimal strAbs {set;get;}
        public decimal strSubmitted {set;get;}
        public decimal strsubmit {set;get;}
        //To exclude the category baijiu, wine, RTD but include JCS subbrand
        public decimal receiveScanExclusion {set;get;}
        public decimal intakeExclusion {set;get;}
        public decimal exclusionScanRate{set;get;}
        
    }
    
    public class AbsExeptionClass{  
        public string strAcc {set;get;}
        public decimal absDiff_AB1 {set;get;}
        public decimal absDiffB4_AB1 {set;get;}
        public decimal absDiff_ABS {set;get;}
        public decimal absDiffB4_ABS {set;get;}
        public decimal absDiff_GL5 {set;get;}
        public decimal absDiffB4_GL5 {set;get;}
        public decimal absDiff_HLM {set;get;}
        public decimal absDiffB4_HLM {set;get;}
        public decimal absDiff_JCO {set;get;}
        public decimal absDiffB4_JCO {set;get;}
    }
}
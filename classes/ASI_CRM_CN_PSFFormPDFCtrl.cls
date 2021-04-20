/***********************************************************
Created by Stella Sing (IntroV Limited)     7 May 2014
Modified by Stella Sing (IntroV Limited)    5 June 2014

Added:
1. Competitor Subbrand Filtering
2. CutOffDay
3. Covered Outlet

************************************************************/
public with sharing class ASI_CRM_CN_PSFFormPDFCtrl {

    public ASI_CRM_CN_PSFFormPDFCtrl() {

    }
    public date CutOffDay {set;get;} //Pending Custom Setting follow for Sub Brand Volume 
    public String PageId {set;get;}
    public ASI_TH_CRM_PaymentRequest__c thisPR {set;get;}
    public List<ASI_TH_CRM_PaymentRequestLineItem__c> PSFList {set;get;}
    public List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractBRSFList {set;get;}
    public List<ASI_TH_CRM_Contract__c> vLatestContract {set;get;}
    public Map<string, ASI_CRM_CN_Contract_BRSF_Line_Item__c> contractBRSF_Map {set;get;}    
    public Map<string, map<string, Map<string, objPSF>>> PSFList_Map {set;get;}
    public map<string, Map<string, objPSF>> OutletSummary_Map {set;get;}
    public Map<string, objPSF> OutletTotal {set;get;}
    public map<string, Map<string, objPSF>> PSFSBGradeTotal_Map {set;get;}
    public List<ASI_CRM_Subbrand_Volume__c> SBVolList {set;get;}
    public map<string, map<string, objPSF>> TotalSummary_map {set;get;} 
    public map<string, integer> PSFPeriod_map {set;get;}
    public boolean noData {set;get;}
	public boolean inited {set;get;}
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet_List {set;get;}
    public integer periodSize {set;get;}
    public Map<id,string> CoveredOutletName {set;get;}
    public set<id> OuteletIdSet {set;get;}
    
    //2014-07-11 Add CTD Period
    public string isCTD {set;get;}
    
    public ASI_CRM_CN_PSFFormPDFCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
        noData = false;
		inited = false;
        if (PageId != null){
            //get the Master Payment Request
            thisPR = [SELECT id, ASI_CRM_CN_PSF_Start__c, ASI_CRM_CN_PSF_End__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_OutletWS__r.Name, ASI_CRM_CN_Region__c,
            ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_CCity__r.Name, ASI_TH_CRM_Total_Amount__c, Owner.Name, ASI_TH_CRM_Contract__c, ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Chi_Name__c,
            ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_Start_Date__c, ASI_TH_CRM_Contract__r.ASI_CRM_CN_PO_End_Date__c, ASI_CRM_Volume_Option__c
            FROM ASI_TH_CRM_PaymentRequest__c 
            WHERE id = :PageId];
            
            init();
        }else{
            noData = true;
            thisPR = new ASI_TH_CRM_PaymentRequest__c ();
        }
    }
    public boolean init(){
        /****************************** SET CUTOFF Date ***********************************/
        CutOffDay = CutOffDate(16); // 0 = ASI_CRM_CN_PO_End_Date__c
        /****************************** SET CUTOFF Date ***********************************/
        
        
        //Initialize all Display Data container 
        init_DataDisplay();
        
        if (thisPR != null){
            //Query Data
            if(inited == null || inited ==false){
                QueryData();
                //Call to Do First step calculation
                getPSFSBVolume();
				system.debug('Init Executed once');
        	}
        }else{
            NewPR_Init();
			system.debug('NewPR_Init Executed once');
        }
        return true;
    }
    public date CutOffDate(integer strDay){
        Date returnDate;
        Integer strDate = Date.Today().Day();
        Integer strMonth;
        Integer strEndDay;
        if (strDay != 0){
            if (strDate >= strDay){
                strMonth = Date.Today().Month() - 1;
            }
            if (strDate < strDay){
                strMonth = Date.Today().Month() - 2;
            }
            strEndDay = Date.daysInMonth(Date.Today().Year(), strMonth);
            returnDate = Date.newinstance(Date.Today().Year(),strMonth,strEndDay);
            if (returnDate > thisPR.ASI_CRM_CN_PSF_End__c){
                returnDate = thisPR.ASI_CRM_CN_PSF_End__c;
            }
        }else{
            returnDate = thisPR.ASI_CRM_CN_PSF_End__c;
        }
        system.debug('CutOffDate: ' + returnDate);
        return returnDate;
    }
    
    public void QueryData(){
        inited = true;
        //get PSF child items 
        PSFList = [SELECT ASI_CRM_CN_Period_End__c, ASI_CRM_CN_Period_Start__c
                    FROM ASI_TH_CRM_PaymentRequestLineItem__c 
                    WHERE ASI_TH_CRM_Payment_Request__c = :thisPR.id
                    AND RecordType.DeveloperName = 'ASI_CRM_CN_Payment_Request_Detail_PSF'];
//        system.debug('PSFList: ' + PSFList.size());
		map<string, string> periodMap = new map<string, string>();
		String strPeriod1;
		Integer j = 0;
		while (j < PSFList.size())
		{
            strPeriod1= PeriodConversion(PSFList.get(j).ASI_CRM_CN_Period_Start__c, PSFList.get(j).ASI_CRM_CN_Period_End__c);
			if(periodMap.containsKey(strPeriod1))
            {
    			PSFList.remove(j);
  			}else
  			{
				periodMap.put(strPeriod1, strPeriod1);
    			j++;
  			}
		}
        //Get BRFS Sub Brand Items
        OuteletIdSet = new set<id>();
        CoveredOutletName = new Map<id, string>();
        // Added by Alan Wong (Elufa) 20150626 
        ASI_TH_CRM_PaymentRequest__c tempPR = [SELECT id, ASI_CRM_Volume_Option__c FROM ASI_TH_CRM_PaymentRequest__c WHERE id = :thisPR.id];       
        if (tempPR.ASI_CRM_Volume_Option__c == 'Normal' || tempPR.ASI_CRM_Volume_Option__c == 'WholeSaler Only' || tempPR.ASI_CRM_Volume_Option__c == null) {
        	OuteletIdSet.add(thisPR.ASI_CRM_CN_OutletWS__c);
            CoveredOutletName.put(thisPR.ASI_CRM_CN_OutletWS__c,thisPR.ASI_CRM_CN_OutletWS__r.ASI_CRM_CN_Chi_Name__c);
        }
        // -- End -- //
        String v0contract;  
        if (thisPR.ASI_TH_CRM_Contract__c != null){
            vLatestContract = [SELECT ASI_CRM_CN_V0_0_PO_version__c 
                                FROM ASI_TH_CRM_Contract__c
                                WHERE id =:thisPR.ASI_TH_CRM_Contract__c];
                                }
                              
        if (vLatestContract.size() > 0 &&  vLatestContract[0].ASI_CRM_CN_V0_0_PO_version__c != null){ 
           v0contract = vLatestContract[0].ASI_CRM_CN_V0_0_PO_version__c;
        }
        else if (thisPR.ASI_TH_CRM_Contract__c != null)
        {
           v0contract = thisPR.ASI_TH_CRM_Contract__c;
        }
                          
        if (thisPR.ASI_TH_CRM_Contract__c != null){
            contractBRSFList = [SELECT id, ASI_CRM_CN_Sub_Brand__c, 
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name, ASI_CRM_CN_Contract_Monthly_Qty__c,
                                ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,
                                ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c ,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c
                                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c
                                WHERE ASI_CRM_CN_Contract__c =:v0contract];
                                
            //Covered Outlet            
            try{
                CoveredOutlet_List =[SELECT ASI_CRM_CN_Outlet__c,ASI_CRM_CN_Outlet__r.Name,ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c
                FROM ASI_CRM_CN_Covered_Outlet__c 
                WHERE ASI_CRM_CN_Contract__c =:thisPR.ASI_TH_CRM_Contract__c ];
            }catch(exception e){
//                system.debug('Try CoveredOutlet_List failed: ' + e);
                CoveredOutlet_List = new list<ASI_CRM_CN_Covered_Outlet__c>();
            }
            // Added By Alan Wong (Elufa) 20150626
            if (tempPR.ASI_CRM_Volume_Option__c == 'Normal' || tempPR.ASI_CRM_Volume_Option__c == 'Covered Outlet Only' || tempPR.ASI_CRM_Volume_Option__c == null) {
                if (CoveredOutlet_List.size() > 0){
                    for (ASI_CRM_CN_Covered_Outlet__c co_temp : CoveredOutlet_List){
                        OuteletIdSet.add(co_temp.ASI_CRM_CN_Outlet__c);
                        CoveredOutletName.put(co_temp.ASI_CRM_CN_Outlet__c,co_temp.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c);
                    }
                }
            }
            // -- End -- //
//            system.debug('CoveredOutletName:::' + CoveredOutletName);
        }else{
            contractBRSFList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        }
        
        //Get data from Sub Brand Volume import database
        system.debug('PSF Start: ' + thisPR.ASI_CRM_CN_PSF_Start__c + ' PSF End: ' + thisPR.ASI_CRM_CN_PSF_End__c + ' CutOff: ' + CutOffDay);
//        system.debug('thisPR.ASI_CRM_CN_OutletWS__c: ' + thisPR.ASI_CRM_CN_OutletWS__c);

        if (PSFList.size() > 0 && thisPR.ASI_CRM_CN_PSF_Start__c != null && thisPR.ASI_CRM_CN_PSF_End__c != null){
            SBVolList = [SELECT ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                         ASI_CRM_Offtake_Std_Billing__c , ASI_CRM_T1_Depletion_STD_Billing__c, ASI_CRM_T2_Depletion_STD_Billing__c, 
                         ASI_CRM_PR_Direct_STD_Billing__c, ASI_CRM_T1_Depletion_CR12__c, ASI_CRM_T2_Depletion_CR12__c, ASI_CRM_PR_Direct_CR12__c,
                         ASI_CRM_Green_Cap_Std_Billing__c, ASI_CRM_Green_Cap_CR12__c, ASI_CRM_Empty_Bottle_Std_Billing__c, ASI_CRM_Bottle_Collected__c, ASI_CRM_Offtake_CR12__c, 
                         ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c, ASI_CRM_End_Date__c ,
                         ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c,
                         ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c,
                         ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name,
                         ASI_CRM_Account__c,ASI_CRM_Account__r.Name,ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c,
                         ASI_CRM_Empty_Bottle_CR12__c
                         FROM ASI_CRM_Subbrand_Volume__c
                         WHERE ASI_CRM_End_Date__c >= :thisPR.ASI_CRM_CN_PSF_Start__c
                         //AND ASI_CRM_End_Date__c <= :thisPR.ASI_CRM_CN_PSF_End__c
                         AND ASI_CRM_End_Date__c <= :CutOffDay
                         AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                         AND ASI_CRM_Account__c IN :OuteletIdSet
                         AND ASI_CRM_CN_Exclude_From_Payment_Volume__c = False//20170213 Elufa
                        ];
                       // AND ASI_CRM_Account__c = :thisPR.ASI_CRM_CN_OutletWS__c];
            system.debug('SBVolList: ' + SBVolList.size());
        }else{
            SBVolList = new List<ASI_CRM_Subbrand_Volume__c>();
			system.debug('SBVolList: None' );
        }
        
    }
    //First step calculation (table part 1)
    public void getPSFSBVolume(){
//        system.debug('getPSFSBVolume: ' + SBVolList.size());
//        system.debug('PSFList.size(): ' + PSFList.size());
        if (PSFList.size() > 0){
        decimal strA;
        decimal strATotal;
        string sbName;
        string sbGrade;
        string sbGradeSort;
        decimal CR12Factor;
        decimal strA12;
        decimal strNONA12;
        string strTotal;
        string strTotal2;
        string strTotal3;
        string strTotal4;
//        system.debug('contractBRSFList.size(): ' + contractBRSFList.size());
        string strPeriod;
        Integer PSFPeriod;
        Integer intlength;
        Integer intRP6;
        string strSubBrand;
            for (ASI_TH_CRM_PaymentRequestLineItem__c temppsf : PSFList){
                strPeriod = PeriodConversion(temppsf.ASI_CRM_CN_Period_Start__c, temppsf.ASI_CRM_CN_Period_End__c);
                PSFPeriod = ((temppsf.ASI_CRM_CN_Period_End__c.YEAR() - temppsf.ASI_CRM_CN_Period_Start__c.YEAR() - 1) *12) + (12 - temppsf.ASI_CRM_CN_Period_Start__c.MONTH() +1) + temppsf.ASI_CRM_CN_Period_End__c.MONTH();      
                if (contractBRSFList.size() > 0){
                    for (ASI_CRM_CN_Contract_BRSF_Line_Item__c a : contractBRSFList){
                        sbName = a.ASI_CRM_CN_Sub_Brand__r.Name;
                        // Added by Alan Wong
                        if(sbName != null){
                            intlength = sbName.length();
                            intRP6 = sbName.lastIndexOf('-');  
                        }   
                        if(intlength >= 4){
                            if(intRP6 == (intlength-4)){
                                strSubBrand = sbName.substring(0, (intlength-4));
                            }
                            else{
                                strSubBrand = sbName;
                            }
                        }
                        // -- End -- //
                        if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                            sbGrade = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        }else{
                            sbGrade = 'Sub Brand Grade not specified';
                        }
                        if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                            sbGradeSort = sbGradeSorting(a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+sbGrade;
                        }
                        // Sub Brand Convert Factor
                        if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null){
                            CR12Factor = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                        }else{
                            CR12Factor = 1;
                        }
                        
                        //if (a.ASI_CRM_CN_Est_Monthly_Qty__c != null){
                            //strA = a.ASI_CRM_CN_Est_Monthly_Qty__c * PSFPeriod;
                            //strATotal= a.ASI_CRM_CN_Est_Monthly_Qty__c* CR12Factor * PSFPeriod;
                        
                        if (a.ASI_CRM_CN_Contract_Monthly_Qty__c != null){
                            strA = a.ASI_CRM_CN_Contract_Monthly_Qty__c * PSFPeriod;
                            strATotal= a.ASI_CRM_CN_Contract_Monthly_Qty__c* CR12Factor * PSFPeriod;
                        }else{
                            strA = 0;
                            strATotal = 0;
                        }
                        map<string, objPSF> objPSFMap = new map<string, objPSF>();
                        map<string, map<string, objPSF>> PSFList_Map1 = new map<string, map<string, objPSF>>();
                        objPSF newobjPSF = new objPSF();
                        newobjPSF.strSubBrand = strSubBrand;
                        newobjPSF.strA = strA;
                        newobjPSF.strB = 0;
                        newobjPSF.strC = 0;
                        newobjPSF.strD = 0;
                        if (PSFList_Map.containskey(strPeriod)){
                            if (PSFList_Map.get(strPeriod).containskey(sbGradeSort)){
                                if (PSFList_Map.get(strPeriod).get(sbGradeSort).containskey(sbName)){
                                    PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strA += strA;
                                }else{
                                    PSFList_Map.get(strPeriod).get(sbGradeSort).put(sbName, newobjPSF);
                                }
                            }else{
                                objPSFMap.put(sbName, newobjPSF);
                                PSFList_Map.get(strPeriod).put(sbGradeSort, objPSFMap);
                            }
                        }else{
                            objPSFMap.put(sbName, newobjPSF);
                            PSFList_Map1.put(sbGradeSort, objPSFMap);
                            PSFList_Map.put(strPeriod, PSFList_Map1 );
                        }
                        objPSF newobjPSF_total = new objPSF();
                        newobjPSF.strSubBrand = strSubBrand;
                        newobjPSF_total.strA = strA;
                        newobjPSF_total.strB = 0;
                        newobjPSF_total.strC = 0;
                        newobjPSF_total.strD = 0;
                        if (PSFSBGradeTotal_Map.containskey(strPeriod)){
                            if (PSFSBGradeTotal_Map.get(strPeriod).containskey(sbGradeSort)){
                                PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strA += strA;
                            }else{
                                PSFSBGradeTotal_Map.get(strPeriod).put(sbGradeSort, newobjPSF_total);
                            }
                        }else{
                            map <string, objPSF> PSFSBGradeTotal_Map2 = new map <string, objPSF>();
                            PSFSBGradeTotal_Map2.put(sbGradeSort, newobjPSF_total);
                            PSFSBGradeTotal_Map.put(strPeriod, PSFSBGradeTotal_Map2);
                        }
                        
                        objPSF TotalChivas12 = new objPSF();
                        objPSF TotalNONChivas12 = new objPSF();
                        TotalChivas12.strA = 0;
                        TotalChivas12.strB = 0;
                        TotalChivas12.strC = 0;
                        TotalChivas12.strD = 0;
                        TotalNONChivas12.strA = 0;
                        TotalNONChivas12.strB = 0;
                        TotalNONChivas12.strC = 0;
                        TotalNONChivas12.strD = 0;
                        if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c != null){
                            if ((a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name)=='Chivas 12'){  
                                TotalChivas12.strA = strA;
                                strA12 = strA;
                                strNONA12 = 0;
                            }else{
                                strA12 = 0;
                                strNONA12 = strA;
                                TotalNONChivas12.strA = strA;
                            }
                        }else{
                            strA12 = 0;
                            strNONA12 = strA;
                            TotalNONChivas12.strA = strA;
                        }
                        
                        //Place in map
                        strTotal = '1. Total Chivas 12 Extra';
                        if (TotalSummary_map.containskey(strPeriod)){
                            if (TotalSummary_map.get(strPeriod).containskey(strTotal)){
                                TotalSummary_map.get(strPeriod).get(strTotal).strA += strA12;
                            }else{
                                TotalSummary_map.get(strPeriod).put(strTotal, TotalChivas12);
                            }
                        }else{
                            map<string, objPSF> newMap = new map<string, objPSF>();
                            newMap.put(strTotal, TotalChivas12);
                            TotalSummary_map.put(strPeriod, newMap);
                        } 
                            
                        //Total Non Chivas 12
                        strTotal2 = '2. Total Non Chivas 12 Extra';
                        if (TotalSummary_map.containskey(strPeriod)){
                            if (TotalSummary_map.get(strPeriod).containskey(strTotal2)){
                                TotalSummary_map.get(strPeriod).get(strTotal2).strA += strNONA12;
                            }else{
                                TotalSummary_map.get(strPeriod).put(strTotal2, TotalNONChivas12);
                            }
                        }else{
                            map<string, objPSF> newMap = new map<string, objPSF>();
                            newMap.put(strTotal2, TotalNONChivas12);
                            TotalSummary_map.put(strPeriod, newMap);
                        }   
                        
                        
                        //Total All Products
                        objPSF TotalProducts = new objPSF();
    
                        TotalProducts.strA = strA;
                        TotalProducts.strB = 0;
                        TotalProducts.strC = 0;
                        TotalProducts.strD = 0;
                        
                        strTotal3 = '3. Total All Products';
                        if (TotalSummary_map.containskey(strPeriod)){
                            if (TotalSummary_map.get(strPeriod).containskey(strTotal3)){
                                TotalSummary_map.get(strPeriod).get(strTotal3).strA += strA;
                            }else{
                                TotalSummary_map.get(strPeriod).put(strTotal3, TotalProducts);
                            }
                        }else{
                            map<string, objPSF> newMap = new map<string, objPSF>();
                            newMap.put(strTotal3, TotalProducts);
                            TotalSummary_map.put(strPeriod, newMap);
                        }
                        //Total All Products CR12
                        objPSF TotalProductsCR12 = new objPSF();
                        
                        TotalProductsCR12.strA = strATotal;
                        TotalProductsCR12.strB = 0;
                        TotalProductsCR12.strC = 0;
                        TotalProductsCR12.strD = 0;
                        
                        strTotal4 = '4. Total All Products equal to CR12 Extra';
                        if (TotalSummary_map.containskey(strPeriod)){
                            if (TotalSummary_map.get(strPeriod).containskey(strTotal4)){
                                TotalSummary_map.get(strPeriod).get(strTotal4).strA += strATotal;
                            }else{
                                TotalSummary_map.get(strPeriod).put(strTotal4, TotalProductsCR12);
                            }
                        }else{
                            map<string, objPSF> newMap = new map<string, objPSF>();
                            newMap.put(strTotal4, TotalProductsCR12);
                            TotalSummary_map.put(strPeriod, newMap);
                        }
                    }
                }
            }
        }
        if (SBVolList.size()>0){
            string sbGrade;
            string sbName;
            string outletName;
            decimal strJ; //BRSF Collection
            decimal strK; //BRSF Intake
            decimal strA;
            decimal strB;
            decimal strC;
            decimal strD;
            decimal strE;
            decimal strF;
            decimal strG;
            decimal strH;
            decimal strI;
            
            //Variables for Total Calculation
            decimal strJTotal;
            decimal strKTotal;
            decimal strATotal;
            decimal strBTotal;
            decimal strCTotal;
            decimal strDTotal;
            decimal strETotal;
            decimal strFTotal;
            decimal strGTotal;
            decimal strHTotal;
            decimal strITotal;
            
            //Variable for Chivas 12 & non Chivas 12
            decimal strA12;
            decimal strB12;
            decimal strC12;
            decimal strD12;
            decimal strE12;
            decimal strF12;
            decimal strG12;
            decimal strH12;
            decimal strI12;
            
            decimal strNONA12;
            decimal strNONB12;
            decimal strNONC12;
            decimal strNOND12;
            decimal strNONE12;
            decimal strNONF12;
            decimal strNONG12;
            decimal strNONH12;
            decimal strNONI12;
            
            decimal CR12Factor;
            string strTotal;
            string strTotal2;
            string strTotal3;
            string strTotal4;
            
            string sbGradeSort;
            string strPeriod;
            Integer PSFPeriod;
            Integer intlength;
            Integer intRP6;
            string strSubBrand;
            for (ASI_TH_CRM_PaymentRequestLineItem__c temppsf : PSFList){
                strPeriod = PeriodConversion(temppsf.ASI_CRM_CN_Period_Start__c, temppsf.ASI_CRM_CN_Period_End__c);
                PSFPeriod = ((temppsf.ASI_CRM_CN_Period_End__c.YEAR() - temppsf.ASI_CRM_CN_Period_Start__c.YEAR() - 1) *12) + (12 - temppsf.ASI_CRM_CN_Period_Start__c.MONTH() +1) + temppsf.ASI_CRM_CN_Period_End__c.MONTH();      
                for (ASI_CRM_Subbrand_Volume__c a : SBVolList ){
                    if (a.ASI_CRM_End_Date__c >= temppsf.ASI_CRM_CN_Period_Start__c && a.ASI_CRM_End_Date__c  <= temppsf.ASI_CRM_CN_Period_End__c ){
                        if (a.ASI_CRM_Subbrand__c != null){
                            objPSF newobjPSF = new objPSF();
                            sbName = a.ASI_CRM_Subbrand__r.Name;
                            // Added by Alan Wong
                            if(sbName != null){
                                intlength = sbName.length();
                                intRP6 = sbName.lastIndexOf('-');  
                            }   
                            if(intlength >= 4){
                                if(intRP6 == (intlength-4)){
                                    strSubBrand = sbName.substring(0, (intlength-4));
                                }
                                else{ 
                                    strSubBrand = sbName;
                               }
                            } 
                            // -- End -- //
                            outletName = a.ASI_CRM_Account__r.ASI_CRM_CN_Chi_Name__c;
                            if (a.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                                sbGrade = a.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                            }else{
                                sbGrade = 'Sub Brand Grade not specified';
                            }
                            if (a.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__c != null){
                                sbGradeSort = sbGradeSorting(a.ASI_CRM_Subbrand__r.ASI_CRM_CN_Sub_brand_Grade__r.ASI_CRM_CN_Sequence__c)+sbGrade;
                            }
                            // Sub Brand Convert Factor
                            if (a.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c != null){
                                CR12Factor = a.ASI_CRM_Subbrand__r.ASI_CRM_CN_COnvfactor_Ltocr12_C__c;
                            }else{
                                CR12Factor = 1;
                            }
//                            system.debug('PSFPeriod: ' + PSFPeriod);
                            
                            
                            /*if (contractBRSF_Map.containskey(sbName)){ 
                                if (contractBRSF_Map.get(sbName).ASI_CRM_CN_Est_Monthly_Qty__c!= null){
                                    strA = contractBRSF_Map.get(sbName).ASI_CRM_CN_Est_Monthly_Qty__c * PSFPeriod;
                                    strATotal = contractBRSF_Map.get(sbName).ASI_CRM_CN_Est_Monthly_Qty__c* CR12Factor * PSFPeriod;
                                }else{
                                    strA = 0;
                                    strATotal = 0;
                                }
                            }else{
                                strA = 0;
                                strATotal = 0;
                            }*/
//                            system.debug('strA: ' + strA);
                            // (B) - Offtake Volume
                            if (a.ASI_CRM_Offtake_Std_Billing__c != null){ 
                                strB = a.ASI_CRM_Offtake_Std_Billing__c;
                            }else{
                                strB = 0;
                                strBTotal = 0;
                            }   
                            if (a.ASI_CRM_Offtake_CR12__c != null){
                                strBTotal = a.ASI_CRM_Offtake_CR12__c;
                            }else{
                                strBTotal = 0;
                            }
//                            system.debug('strB: ' + strB);
                            // (C) - Intake Volume
                            if (a.ASI_CRM_T1_Depletion_STD_Billing__c != null){ 
                                strC = a.ASI_CRM_T1_Depletion_STD_Billing__c;
                            }else{
                                strC = 0;
                            }
                            if (a.ASI_CRM_T2_Depletion_STD_Billing__c != null){
                                strC += a.ASI_CRM_T2_Depletion_STD_Billing__c;
                            }
                            if (a.ASI_CRM_PR_Direct_STD_Billing__c != null){
                                strC += a.ASI_CRM_PR_Direct_STD_Billing__c;
                            }                           
//                            system.debug('strC: ' + strC);
                            if (a.ASI_CRM_T1_Depletion_CR12__c != null){
                                strCTotal = a.ASI_CRM_T1_Depletion_CR12__c;
                            }else{
                                strCTotal = 0;
                            }
                            if (a.ASI_CRM_T2_Depletion_CR12__c != null){
                                strCTotal += a.ASI_CRM_T2_Depletion_CR12__c;
                            }
                            if (a.ASI_CRM_PR_Direct_CR12__c != null){
                                strCTotal += a.ASI_CRM_PR_Direct_CR12__c;
                            }
                            // (D) - Bottle Collection
                            
                            if (a.ASI_CRM_Bottle_Collected__c != null){ 
                                strD = a.ASI_CRM_Bottle_Collected__c;
                            }else{
                                strD = 0;
                            }
                            /*
                            if (a.ASI_CRM_Empty_Bottle_Std_Billing__c != null){ 
                                strD = a.ASI_CRM_Empty_Bottle_Std_Billing__c;
                            }else{
                                strD = 0;
                            }
                            if (a.ASI_CRM_Green_Cap_Std_Billing__c != null){
                                strD += a.ASI_CRM_Green_Cap_Std_Billing__c;
                            }
                            */
//                            system.debug('strD: ' + strD);
                            if (a.ASI_CRM_Empty_Bottle_CR12__c!= null){
                                strDTotal = a.ASI_CRM_Empty_Bottle_CR12__c;
                            }else{
                                strDTotal = 0;
                            }
                            if (a.ASI_CRM_Green_Cap_CR12__c != null){
                                strDTotal += a.ASI_CRM_Green_Cap_CR12__c;
                            }
                            
                            // (E) - Offtake VS Intake
                            if (strB != 0 && strC != 0){ 
                                strE = (strB/strC)*100;
                                strETotal = (strB/strC)*100;
                            }else{
                                strE = 0;
                                strETotal = 0;
                            }
//                            system.debug('strE: ' + strE);
                            // (F) - Collection VS Offtake
                            if (strB != 0 && strD != 0){ 
                                strF = (strD/strB)*100;
                                strFTotal = (strD/strB)*100;
                            }else{
                                strF = 0;
                                strFTotal = 0;
                            }
//                            system.debug('strF: ' + strF);
                            // (G) - Collection VS Intake
                            if (strC != 0 && strD != 0){ 
                                strG = (strD/strC)*100;
                                strGTotal = (strD/strC)*100;
                            }else{
                                strG = 0;
                                strGTotal = 0;
                            }
//                            system.debug('strF: ' + strF);
                            // (H) - Collection VS Contract %
                            if (strA != 0 && strD != 0 && strA != null){ 
                                strH = (strD / strA)*100;
                                strHTotal = (strD / strA)*100;
                            }else{
                                strH = 0;
                                strHTotal = 0;
                            }
//                            system.debug('strH: ' + strH);
                            // (I) - Intake VS Contract %
                            if (strA != 0 && strc != 0 && strA != null){ 
                                strI = (strC / strA)*100;
                                strITotal = (strC / strA)*100;
                            }else{
                                strI = 0;
                                strITotal = 0;
                            }   
//                            system.debug('strI: ' + strI);
                            //Put into display map for Sub Brands
                            Map<string, objPSF> objPSFMap = new map <string, objPSF>();
                            Map<string, map<string, objPSF>> PSFList_Map1 = new map<string, map<string, objPSF>>();
                            //newobjPSF.strA = strA;
                            newobjPSF.strSubBrand = strSubBrand;
                            newobjPSF.strB = strB;
                            newobjPSF.strC = strC;
                            newobjPSF.strD = strD;
                            if (newobjPSF.strC != 0 && newobjPSF.strB != 0)
                            newobjPSF.strE = (newobjPSF.strB / newobjPSF.strC)*100;
                            if (newobjPSF.strD != 0 && newobjPSF.strB != 0)
                            newobjPSF.strF = (newobjPSF.strD / newobjPSF.strB)*100;
                            if (newobjPSF.strD != 0 && newobjPSF.strC != 0)
                            newobjPSF.strG = (newobjPSF.strD / newobjPSF.strC)*100;
                            if (newobjPSF.strD != 0 && newobjPSF.strA != 0 && newobjPSF.strA != null)
                            newobjPSF.strH = (newobjPSF.strD/newobjPSF.strA)*100;
                            if (newobjPSF.strC != 0 && newobjPSF.strA != 0 && newobjPSF.strA != null)
                            newobjPSF.strI = (newobjPSF.strC/strA)*100;
                            if (PSFList_Map.containskey(strPeriod)){
                                if (PSFList_Map.get(strPeriod).containskey(sbGradeSort)){
                                    if (PSFList_Map.get(strPeriod).get(sbGradeSort).containskey(sbName)){
                                        //PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strA = strA;
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strB += strB;
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strC += strC;
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strD += strD;
                                        if (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strB != 0 && PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strC !=0)
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strE = (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strB / PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strC)*100;
                                        if (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strD != 0 && PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strB !=0)
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strF = (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strD / PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strB)*100;
                                        if (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strD != 0 && PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strC !=0)
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strG = (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strD / PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strC)*100;
                                        if (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strD != 0 && PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strA != 0 && PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strA != null)    
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strH = (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strD / PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strA)*100;
                                        if (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strC != 0 && PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strA != 0 && PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strA != null)
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strI = (PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strC / PSFList_Map.get(strPeriod).get(sbGradeSort).get(sbName).strA)*100;
                                    }else{
                                        PSFList_Map.get(strPeriod).get(sbGradeSort).put(sbName, newobjPSF);
                                    }
                                }else{
                                    objPSFMap.put(sbName, newobjPSF);
                                    PSFList_Map.get(strPeriod).put(sbGradeSort, objPSFMap);
                                }
                            }else{
                                objPSFMap.put(sbName, newobjPSF);
                                PSFList_Map1.put(sbGradeSort, objPSFMap);
                                PSFList_Map.put(strPeriod, PSFList_Map1);
                            }
                            //system.debug('PSFList_Map: ' + PSFList_Map);
                            
                            //Added by Twinkle 20141205 - Remove RP6 code in sub-brand name
                            /*
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
*/
                            //End Twinkle 20141205
        
                            //Put into display Sub Brand Grades TOTAL
                            strA = 0;
                            strATotal = 0;
                            
                            objPSF newobjPSFTotal = new objPSF();
							objPSF newobjPSFTotal2 = new objPSF();
                            map <string, objPSF> PSFSBGradeTotal_Map1 = new map <string, objPSF>();
                            newobjPSFTotal.strA = 0;
                            newobjPSFTotal.strB = strB;                            
                            newobjPSFTotal.strC = strC;
                            newobjPSFTotal.strD = strD;
                            if (newobjPSFTotal.strC != 0 && newobjPSFTotal.strB != 0)
                            newobjPSFTotal.strE = (newobjPSFTotal.strB / newobjPSFTotal.strC)*100;
                            if (newobjPSFTotal.strD != 0 && newobjPSFTotal.strB != 0)
                            newobjPSFTotal.strF = (newobjPSFTotal.strD / newobjPSFTotal.strB)*100;
                            if (newobjPSFTotal.strD != 0 && newobjPSFTotal.strC != 0)
                            newobjPSFTotal.strG = (newobjPSFTotal.strD / newobjPSFTotal.strC)*100;
                            if (newobjPSFTotal.strD != 0 && newobjPSFTotal.strA != 0 && newobjPSFTotal.strA != null)
                            newobjPSFTotal.strH = (newobjPSFTotal.strD/newobjPSFTotal.strA)*100;
                            if (newobjPSFTotal.strC != 0 && newobjPSFTotal.strA != 0 && newobjPSFTotal.strA != null)
                            newobjPSFTotal.strI = (newobjPSFTotal.strC/newobjPSFTotal.strA)*100;

                            //To fix Wrong Total
							newobjPSFTotal2.strA = newobjPSFTotal.strA;
                            newobjPSFTotal2.strB = newobjPSFTotal.strB;                            
                            newobjPSFTotal2.strC = newobjPSFTotal.strC;
							if(newobjPSFTotal.strD != null)
                            newobjPSFTotal2.strD = newobjPSFTotal.strD;
                            if(newobjPSFTotal.strE != null)
                            newobjPSFTotal2.strE = newobjPSFTotal.strE;
                            if(newobjPSFTotal.strF != null)
                            newobjPSFTotal2.strF = newobjPSFTotal.strF;
                            if(newobjPSFTotal.strG != null)
                            newobjPSFTotal2.strG = newobjPSFTotal.strG;
                            if(newobjPSFTotal.strH != null)
                            newobjPSFTotal2.strH = newobjPSFTotal.strH;
                            if(newobjPSFTotal.strI != null)
                            newobjPSFTotal2.strI = newobjPSFTotal.strI;
                          //  system.debug('sbGrade: ' + sbGrade);
                         //   system.debug('PSFSBGradeTotal: ' + newobjPSFTotal);
                          //  system.debug('sbGrade: ' + sbGrade);
                           // system.debug('SubTotal Debug1:' + sbGradeSort + ' ' + strC + ' ' + strPeriod + ' ' +  sbName);
                            if (PSFSBGradeTotal_Map.containskey(strPeriod)){
                                if (PSFSBGradeTotal_Map.get(strPeriod).containskey(sbGradeSort)){
                                   // system.debug('SubTotal Before ' + sbGrade + ' ' + PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC);
								//	system.debug('SubTotal Debug2:' + sbGradeSort + ' ' + strC + ' ' + strPeriod + ' ' +  sbName);
                                    //PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strA += strA;
                                    PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strB += strB;
                                    PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC += strC;
                                    PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strD += strD;
                                    if (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strB != 0 && PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC != 0)
                                        PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strE = (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strB/PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC)*100;
                                    if (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strB != 0 && PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strD != 0)
                                        PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strF = (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strD/PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strB)*100;
                                    if (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC != 0 && PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strD != 0)
                                        PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strG = (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strD/PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC)*100;
                                    if (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strD != 0 && PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strA != 0 &&PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strA != null)
                                        PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strH = (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strD/PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strA)*100;
                                    if (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC != 0 && PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strA != 0 && PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strA != null)
                                        PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strI = (PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC/PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strA)*100;
                                    
                                }else{
                                    system.debug('Containskey strPeriod, put sbGrade');
                                    system.debug(newobjPSFTotal2);
                                    PSFSBGradeTotal_Map.get(strPeriod).put(sbGradeSort, newobjPSFTotal );
                                }
                            }else{
                                system.debug('Put strPeriod, sbGrade');
                                map <string, objPSF> PSFSBGradeTotal_Map2 = new map <string, objPSF>();
                                PSFSBGradeTotal_Map2.put(sbGradeSort, newobjPSFTotal );
                                PSFSBGradeTotal_Map.put(strPeriod, PSFSBGradeTotal_Map2);
                            }
                            
                            
                            
                            
                            // Add by Alan Wong (Elufa) 20150603
                           
                            if (OutletSummary_Map.containskey(strPeriod)){
                                if (OutletSummary_Map.get(strPeriod).containskey(outletName)){
                                   // system.debug('IN PSFSBGradeTotal_Map: ' + PSFSBGradeTotal_Map);
                                    OutletSummary_Map.get(strPeriod).get(outletName).strB += strB;
                                    OutletSummary_Map.get(strPeriod).get(outletName).strC += strC;
                                  //  system.debug('sbGradeSort::: ' + sbGradeSort + ' TotalstrC::: ' + PSFSBGradeTotal_Map.get(strPeriod).get(sbGradeSort).strC + ' StrC::: ' + strC);
                                    OutletSummary_Map.get(strPeriod).get(outletName).strD += strD;   
                                  //  system.debug('OUT PSFSBGradeTotal_Map: ' + PSFSBGradeTotal_Map);
                                }else{
                                    OutletSummary_Map.get(strPeriod).put(outletName, newobjPSFTotal2 );
                                }
                            }else{
                                map <string, objPSF> tmpMap = new map <string, objPSF>();
                                tmpMap.put(outletName, newobjPSFTotal2 );
                                OutletSummary_Map.put(strPeriod, tmpMap);
                            }
                            
//                            system.debug('OutletSummary_Map: ' + OutletSummary_Map);                                                    
                            if (OutletTotal.containskey(strPeriod)){
                                objPSF temp = OutletTotal.get(strPeriod);
                                temp.strB += strB;
                                temp.strC += strC;
                                temp.strD += strD;
                                OutletTotal.put(strPeriod, temp);
                            }else{
                                objPSF newdata = new objPSF();
                                newdata.strB = strB;
                                newdata.strC = strC;
                                newdata.strD = strD;
                                OutletTotal.put(strPeriod, newdata);
                            }                            
                            // -- End -- //
                            
                            
                            
                            
                            
                            //Put into Last Table Total
                            objPSF TotalChivas12 = new objPSF();
                            objPSF TotalNONChivas12 = new objPSF();
                            
                            //Total Chivas 12
                            if (a.ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__c != null){
                                if ((a.ASI_CRM_Subbrand__r.ASI_CRM_CN_SUBBRAND_GROUP_C__r.Name)=='Chivas Extra'){ // changed by laputa 20171123
                                    //if ((a.ASI_CRM_Subbrand__r.Name).contains('Chivas 12'))
                                    //strA12 = strA;
                                    strB12 = strB;
                                    strC12 = strC;
                                    strD12 = strD;
                                    strE12 = strE;
                                    strF12 = strF;
                                    strG12 = strG;
                                    strH12 = strH;
                                    strI12 = strI;
                                    
                                    //TotalChivas12.strA = strA;
                                    TotalChivas12.strB = strB;
                                    TotalChivas12.strC = strC;
                                    TotalChivas12.strD = strD;
                                    if (TotalChivas12.strC != 0 && TotalChivas12.strB != 0)
                                        TotalChivas12.strE = (TotalChivas12.strB / TotalChivas12.strC)*100;
                                    if (TotalChivas12.strD != 0 && TotalChivas12.strB != 0)
                                        TotalChivas12.strF = (TotalChivas12.strD / TotalChivas12.strB)*100;
                                    if (TotalChivas12.strD != 0 && TotalChivas12.strC != 0)
                                        TotalChivas12.strG = (TotalChivas12.strD / TotalChivas12.strC)*100;
                                    //Updated 5 june 2014                        
                                    if (TotalChivas12.strD != 0 && TotalChivas12.strA != 0 && TotalChivas12.strA != null)
                                        TotalChivas12.strH = TotalChivas12.strD / TotalChivas12.strA * 100;   
                                    if (TotalChivas12.strC != 0 && TotalChivas12.strA != 0 && TotalChivas12.strA != null)   
                                        TotalChivas12.strI = TotalChivas12.strC / TotalChivas12.strA * 100;
                                    
                                    //TotalNONChivas12.strA = 0;
                                    TotalNONChivas12.strB = 0;
                                    TotalNONChivas12.strC = 0;
                                    TotalNONChivas12.strD = 0;
                                    TotalNONChivas12.strE = 0;
                                    TotalNONChivas12.strF = 0;
                                    TotalNONChivas12.strG = 0;
                                    TotalNONChivas12.strH = 0;
                                    TotalNONChivas12.strI = 0;
                                    //strNONA12 = 0;
                                    strNONB12 = 0;
                                    strNONC12 = 0;
                                    strNOND12 = 0;
                                    strNONE12 = 0;
                                    strNONF12 = 0;
                                    strNONG12 = 0;
                                    strNONH12 = 0;
                                    strNONI12 = 0;
                                }else{
                                    //TotalChivas12.strA = 0;
                                    TotalChivas12.strB = 0;
                                    TotalChivas12.strC = 0;
                                    TotalChivas12.strD = 0;
                                    TotalChivas12.strE = 0;
                                    TotalChivas12.strF = 0;
                                    TotalChivas12.strG = 0;
                                    TotalChivas12.strH = 0;
                                    TotalChivas12.strI = 0;
                                    
                                    //strA12 = 0;
                                    strB12 = 0;
                                    strC12 = 0;
                                    strD12 = 0;
                                    strE12 = 0;
                                    strF12 = 0;
                                    strG12 = 0;
                                    strH12 = 0;
                                    strI12 = 0;
                                    
                                    //Total NON Chivas 12
                                    //strNONA12 = strA;
                                    strNONB12 = strB;
                                    strNONC12 = strC;
                                    strNOND12 = strD;
                                    strNONE12 = strE;
                                    strNONF12 = strF;
                                    strNONG12 = strG;
                                    strNONH12 = strH;
                                    strNONI12 = strI;
                                     
                                    //TotalNONChivas12.strA = strA;
                                    TotalNONChivas12.strB = strB;
                                    TotalNONChivas12.strC = strC;
                                    TotalNONChivas12.strD = strD;
                                    if (TotalNONChivas12.strC != 0 && TotalNONChivas12.strB != 0)
                                    TotalNONChivas12.strE = (TotalNONChivas12.strB / TotalNONChivas12.strC)*100;
                                    if (TotalNONChivas12.strD != 0 && TotalNONChivas12.strB != 0)
                                    TotalNONChivas12.strF = (TotalNONChivas12.strD / TotalNONChivas12.strB)*100;
                                    if (TotalNONChivas12.strD != 0 && TotalNONChivas12.strC != 0)
                                    TotalNONChivas12.strG = (TotalNONChivas12.strD / TotalNONChivas12.strC)*100;
                                    //Updated 5 june 2014
                                    if (TotalNONChivas12.strD != 0 && TotalNONChivas12.strA != 0 && TotalNONChivas12.strA != null)
                                    TotalNONChivas12.strH = TotalNONChivas12.strD / TotalNONChivas12.strA * 100;   
                                    if (TotalNONChivas12.strC != 0 && TotalNONChivas12.strA != 0 && TotalNONChivas12.strA != null)   
                                    TotalNONChivas12.strI = TotalNONChivas12.strC / TotalNONChivas12.strA * 100;
                                 
                                  }
                              }else{
                                //TotalChivas12.strA = 0;
                                TotalChivas12.strB = 0;
                                TotalChivas12.strC = 0;
                                TotalChivas12.strD = 0;
                                TotalChivas12.strE = 0;
                                TotalChivas12.strF = 0;
                                TotalChivas12.strG = 0;
                                TotalChivas12.strH = 0;
                                TotalChivas12.strI = 0;
                                
                                //strA12 = 0;
                                strB12 = 0;
                                strC12 = 0;
                                strD12 = 0;
                                strE12 = 0;
                                strF12 = 0;
                                strG12 = 0;
                                strH12 = 0;
                                strI12 = 0;
                                
                                //Total NON Chivas 12
                                //strNONA12 = strA;
                                strNONB12 = strB;
                                strNONC12 = strC;
                                strNOND12 = strD;
                                strNONE12 = strE;
                                strNONF12 = strF;
                                strNONG12 = strG;
                                strNONH12 = strH;
                                strNONI12 = strI;
                                 
                                //TotalNONChivas12.strA = strA;
                                TotalNONChivas12.strB = strB;
                                TotalNONChivas12.strC = strC;
                                TotalNONChivas12.strD = strD;
                                if (TotalNONChivas12.strC != 0 && TotalNONChivas12.strB != 0)
                                TotalNONChivas12.strE = (TotalNONChivas12.strB / TotalNONChivas12.strC)*100;
                                if (TotalNONChivas12.strD != 0 && TotalNONChivas12.strB != 0)
                                TotalNONChivas12.strF = (TotalNONChivas12.strD / TotalNONChivas12.strB)*100;
                                if (TotalNONChivas12.strD != 0 && TotalNONChivas12.strC != 0)
                                TotalNONChivas12.strG = (TotalNONChivas12.strD / TotalNONChivas12.strC)*100;
                                //Updated 5 june 2014
                                if (TotalNONChivas12.strD != 0 && TotalNONChivas12.strA != 0 && TotalNONChivas12.strA != null)
                                TotalNONChivas12.strH = TotalNONChivas12.strD / TotalNONChivas12.strA * 100;   
                                if (TotalNONChivas12.strC != 0 && TotalNONChivas12.strA != 0 && TotalNONChivas12.strA != null)   
                                TotalNONChivas12.strI = TotalNONChivas12.strC / TotalNONChivas12.strA * 100;
                                 
                              }
                              //Put PSF Period in table (no. of months)
                              if (!PSFPeriod_map.containskey(strPeriod)){
                                  PSFPeriod_map.put(strPeriod, PSFPeriod);
                              }
                            //Place in map
                            strTotal = '1. Total Chivas 12 Extra';
                            if (TotalSummary_map.containskey(strPeriod)){
                                if (TotalSummary_map.get(strPeriod).containskey(strTotal)){
                                    //TotalSummary_map.get(strPeriod).get(strTotal).strA = strA12;
                                    TotalSummary_map.get(strPeriod).get(strTotal).strB += strB12;
                                    TotalSummary_map.get(strPeriod).get(strTotal).strC += strC12;
                                    TotalSummary_map.get(strPeriod).get(strTotal).strD += strD12;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal).strB != 0 && TotalSummary_map.get(strPeriod).get(strTotal).strC != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal).strE = (TotalSummary_map.get(strPeriod).get(strTotal).strB/TotalSummary_map.get(strPeriod).get(strTotal).strC)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal).strB != 0 && TotalSummary_map.get(strPeriod).get(strTotal).strD != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal).strF = (TotalSummary_map.get(strPeriod).get(strTotal).strD/TotalSummary_map.get(strPeriod).get(strTotal).strB)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal).strC != 0 && TotalSummary_map.get(strPeriod).get(strTotal).strD != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal).strG = (TotalSummary_map.get(strPeriod).get(strTotal).strD/TotalSummary_map.get(strPeriod).get(strTotal).strC)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal).strD != 0 && TotalSummary_map.get(strPeriod).get(strTotal).strA != 0 && TotalSummary_map.get(strPeriod).get(strTotal).strA != null)
                                    TotalSummary_map.get(strPeriod).get(strTotal).strH = (TotalSummary_map.get(strPeriod).get(strTotal).strD/TotalSummary_map.get(strPeriod).get(strTotal).strA)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal).strC != 0 && TotalSummary_map.get(strPeriod).get(strTotal).strA != 0 && TotalSummary_map.get(strPeriod).get(strTotal).strA != null)
                                    TotalSummary_map.get(strPeriod).get(strTotal).strI = (TotalSummary_map.get(strPeriod).get(strTotal).strC/TotalSummary_map.get(strPeriod).get(strTotal).strA)*100;
                                }else{
                                    TotalSummary_map.get(strPeriod).put(strTotal, TotalChivas12);
                                }
                            }else{
                                map<string, objPSF> newMap = new map<string, objPSF>();
                                newMap.put(strTotal, TotalChivas12);
                                TotalSummary_map.put(strPeriod, newMap);
                            } 
                                
                            //Total Non Chivas 12
                            strTotal2 = '2. Total Non Chivas 12 Extra';
                            if (TotalSummary_map.containskey(strPeriod)){
                                if (TotalSummary_map.get(strPeriod).containskey(strTotal2)){
                                    //TotalSummary_map.get(strPeriod).get(strTotal2).strA += strNONA12;
                                    TotalSummary_map.get(strPeriod).get(strTotal2).strB += strNONB12;
                                    TotalSummary_map.get(strPeriod).get(strTotal2).strC += strNONC12;
                                    TotalSummary_map.get(strPeriod).get(strTotal2).strD += strNOND12;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal2).strB != 0 && TotalSummary_map.get(strPeriod).get(strTotal2).strC != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal2).strE = (TotalSummary_map.get(strPeriod).get(strTotal2).strB/TotalSummary_map.get(strPeriod).get(strTotal2).strC)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal2).strB != 0 && TotalSummary_map.get(strPeriod).get(strTotal2).strD != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal2).strF = (TotalSummary_map.get(strPeriod).get(strTotal2).strD/TotalSummary_map.get(strPeriod).get(strTotal2).strB)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal2).strC != 0 && TotalSummary_map.get(strPeriod).get(strTotal2).strD != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal2).strG = (TotalSummary_map.get(strPeriod).get(strTotal2).strD/TotalSummary_map.get(strPeriod).get(strTotal2).strC)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal2).strD != 0 && TotalSummary_map.get(strPeriod).get(strTotal2).strA != 0 && TotalSummary_map.get(strPeriod).get(strTotal2).strA != null)
                                    TotalSummary_map.get(strPeriod).get(strTotal2).strH = (TotalSummary_map.get(strPeriod).get(strTotal2).strD/TotalSummary_map.get(strPeriod).get(strTotal2).strA)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal2).strC != 0 && TotalSummary_map.get(strPeriod).get(strTotal2).strA != 0 && TotalSummary_map.get(strPeriod).get(strTotal2).strA != null)
                                    TotalSummary_map.get(strPeriod).get(strTotal2).strI = (TotalSummary_map.get(strPeriod).get(strTotal2).strC/TotalSummary_map.get(strPeriod).get(strTotal2).strA)*100;
                                }else{
                                    TotalSummary_map.get(strPeriod).put(strTotal2, TotalNONChivas12);
                                }
                            }else{
                                map<string, objPSF> newMap = new map<string, objPSF>();
                                newMap.put(strTotal2, TotalNONChivas12);
                                TotalSummary_map.put(strPeriod, newMap);
                            }   
                            
                            
                            //Total All Products
                            objPSF TotalProducts = new objPSF();
        
                            //TotalProducts.strA = strA;
                            TotalProducts.strB = strB;
                            TotalProducts.strC = strC;
                            TotalProducts.strD = strD;
                            if (TotalProducts.strC != 0 && TotalProducts.strB != 0)
                                TotalProducts.strE = (TotalProducts.strB / TotalProducts.strC)*100;
                            if (TotalProducts.strD != 0 && TotalProducts.strB != 0)
                                TotalProducts.strF = (TotalProducts.strD / TotalProducts.strB)*100;
                            if (TotalProducts.strD != 0 && TotalProducts.strC != 0)
                                TotalProducts.strG = (TotalProducts.strD / TotalProducts.strC)*100;
                            //Updated 5 june 2014
                            if (TotalProducts.strD != 0 && TotalProducts.strA != 0 && TotalProducts.strA != null)
                                TotalProducts.strH = TotalProducts.strD / TotalProducts.strA * 100;   
                            if (TotalProducts.strC != 0 && TotalProducts.strA != 0 && TotalProducts.strA != null)   
                                TotalProducts.strI = TotalProducts.strC / TotalProducts.strA * 100;
                            
                            strTotal3 = '3. Total All Products';
                            if (TotalSummary_map.containskey(strPeriod)){
                                if (TotalSummary_map.get(strPeriod).containskey(strTotal3)){
                                    //TotalSummary_map.get(strPeriod).get(strTotal3).strA = strA;
                                    TotalSummary_map.get(strPeriod).get(strTotal3).strB += strB;
                                    TotalSummary_map.get(strPeriod).get(strTotal3).strC += strC;
                                    TotalSummary_map.get(strPeriod).get(strTotal3).strD += strD;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal3).strB != 0 && TotalSummary_map.get(strPeriod).get(strTotal3).strC != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal3).strE = (TotalSummary_map.get(strPeriod).get(strTotal3).strB/TotalSummary_map.get(strPeriod).get(strTotal3).strC)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal3).strB != 0 && TotalSummary_map.get(strPeriod).get(strTotal3).strD != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal3).strF = (TotalSummary_map.get(strPeriod).get(strTotal3).strD/TotalSummary_map.get(strPeriod).get(strTotal3).strB)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal3).strC != 0 && TotalSummary_map.get(strPeriod).get(strTotal3).strD != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal3).strG = (TotalSummary_map.get(strPeriod).get(strTotal3).strD/TotalSummary_map.get(strPeriod).get(strTotal3).strC)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal3).strD != 0 && TotalSummary_map.get(strPeriod).get(strTotal3).strA != 0 && TotalSummary_map.get(strPeriod).get(strTotal3).strA != null)
                                    TotalSummary_map.get(strPeriod).get(strTotal3).strH = (TotalSummary_map.get(strPeriod).get(strTotal3).strD/TotalSummary_map.get(strPeriod).get(strTotal3).strA)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal3).strC != 0 && TotalSummary_map.get(strPeriod).get(strTotal3).strA != 0 && TotalSummary_map.get(strPeriod).get(strTotal3).strA != null)
                                    TotalSummary_map.get(strPeriod).get(strTotal3).strI = (TotalSummary_map.get(strPeriod).get(strTotal3).strC/TotalSummary_map.get(strPeriod).get(strTotal3).strA)*100;
                                }else{
                                    TotalSummary_map.get(strPeriod).put(strTotal3, TotalProducts);
                                }
                            }else{
                                map<string, objPSF> newMap = new map<string, objPSF>();
                                newMap.put(strTotal3, TotalProducts);
                                TotalSummary_map.put(strPeriod, newMap);
                            }
                            //Total All Products CR12
                            objPSF TotalProductsCR12 = new objPSF();
                            
                            //TotalProductsCR12.strA = strATotal;
                            TotalProductsCR12.strB = strBTotal;
                            TotalProductsCR12.strC = strCTotal;
                            TotalProductsCR12.strD = strDTotal;
                            if (TotalProductsCR12.strC != 0 && TotalProductsCR12.strB != 0)
                                TotalProductsCR12.strE = (TotalProductsCR12.strB / TotalProductsCR12.strC)*100;
                            if (TotalProductsCR12.strD != 0 && TotalProductsCR12.strB != 0)
                                TotalProductsCR12.strF = (TotalProductsCR12.strD / TotalProductsCR12.strB)*100;
                            if (TotalProductsCR12.strD != 0 && TotalProductsCR12.strC != 0)
                                TotalProductsCR12.strG = (TotalProductsCR12.strD / TotalProductsCR12.strC)*100;
                            //Updated 5 june 2014
                            if (TotalProductsCR12.strD != 0 && TotalProductsCR12.strA != 0 && TotalProductsCR12.strA != null)
                                TotalProductsCR12.strH = TotalProductsCR12.strD / TotalProductsCR12.strA * 100;   
                            if (TotalProductsCR12.strC != 0 && TotalProductsCR12.strA != 0 && TotalProductsCR12.strA != null)   
                                TotalProductsCR12.strI = TotalProductsCR12.strC / TotalProductsCR12.strA * 100;
                            
                           
                            strTotal4 = '4. Total All Products equal to CR12 Extra';
                            if (TotalSummary_map.containskey(strPeriod)){
                                if (TotalSummary_map.get(strPeriod).containskey(strTotal4)){
                                    //TotalSummary_map.get(strPeriod).get(strTotal4).strA = strATotal;
                                    TotalSummary_map.get(strPeriod).get(strTotal4).strB += strBTotal;
                                    TotalSummary_map.get(strPeriod).get(strTotal4).strC += strCTotal;
                                    TotalSummary_map.get(strPeriod).get(strTotal4).strD += strDTotal;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal4).strB != 0 && TotalSummary_map.get(strPeriod).get(strTotal4).strC != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal4).strE = (TotalSummary_map.get(strPeriod).get(strTotal4).strB/TotalSummary_map.get(strPeriod).get(strTotal4).strC)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal4).strB != 0 && TotalSummary_map.get(strPeriod).get(strTotal4).strD != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal4).strF = (TotalSummary_map.get(strPeriod).get(strTotal4).strD/TotalSummary_map.get(strPeriod).get(strTotal4).strB)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal4).strC != 0 && TotalSummary_map.get(strPeriod).get(strTotal4).strD != 0)
                                    TotalSummary_map.get(strPeriod).get(strTotal4).strG = (TotalSummary_map.get(strPeriod).get(strTotal4).strD/TotalSummary_map.get(strPeriod).get(strTotal4).strC)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal4).strD != 0 && TotalSummary_map.get(strPeriod).get(strTotal4).strA != 0 && TotalSummary_map.get(strPeriod).get(strTotal4).strA != null)
                                    TotalSummary_map.get(strPeriod).get(strTotal4).strH = (TotalSummary_map.get(strPeriod).get(strTotal4).strD/TotalSummary_map.get(strPeriod).get(strTotal4).strA)*100;
                                    if (TotalSummary_map.get(strPeriod).get(strTotal4).strC != 0 && TotalSummary_map.get(strPeriod).get(strTotal4).strA != 0 && TotalSummary_map.get(strPeriod).get(strTotal4).strA != null)
                                    TotalSummary_map.get(strPeriod).get(strTotal4).strI = (TotalSummary_map.get(strPeriod).get(strTotal4).strC/TotalSummary_map.get(strPeriod).get(strTotal4).strA)*100;
                                }else{
                                    TotalSummary_map.get(strPeriod).put(strTotal4, TotalProductsCR12);
                                }
                            }else{
                                map<string, objPSF> newMap = new map<string, objPSF>();
                                newMap.put(strTotal4, TotalProductsCR12);
                                TotalSummary_map.put(strPeriod, newMap);
                            }
                        }
                    }//Within dates
                }//subbrand not null
                objPSF emptyobjPSFTotal = new objPSF();
                emptyobjPSFTotal.strB = 0;
                emptyobjPSFTotal.strC = 0;
                emptyobjPSFTotal.strD = 0;
                for (id oid : OuteletIdSet){
                    if (!OutletSummary_Map.containskey(strPeriod)){
                        map <string, objPSF> PSFSBGradeTotal_Map2 = new map <string, objPSF>();
                        PSFSBGradeTotal_Map2.put(CoveredOutletName.get(oid), emptyobjPSFTotal);
                        OutletSummary_Map.put(strPeriod, PSFSBGradeTotal_Map2);    
                    }else{
                        if (!OutletSummary_Map.get(strPeriod).containskey(CoveredOutletName.get(oid))){
                            OutletSummary_Map.get(strPeriod).put(CoveredOutletName.get(oid), emptyobjPSFTotal);
                        }
                    }
                }               
            }
        }else{
            SBVolList = new List<ASI_CRM_Subbrand_Volume__c>();
            noData = true;
        }
        periodSize = PSFList_Map.size();
//        system.debug('PSFList_Map: ' + PSFList_Map);
//        system.debug('TotalSummary_map: ' + TotalSummary_map);    
    }

    public string PeriodConversion(Date strStart, Date strEnd){
//        system.debug('strStart: ' + strStart + ' strEnd: ' + strEnd);
        string startMonth;
        string endMonth;
        string startDay;
        string endDay;
        if (strStart.Month() <10)
        startMonth = '0' + strStart.Month();
        else
        startMonth = string.valueof(strStart.Month());
        if (strEnd.Month() <10)
        endMonth = '0' + strEnd.Month();
        else
        endMonth = string.valueof(strEnd.Month());
        if (strStart.Day() <10)
        startDay = '0' + strStart.Day();
        else
        startDay = string.valueof(strStart.Day());
        if (strEnd.Day() <10)
        endDay = '0' + strEnd.Day();
        else
        endDay = string.valueof(strEnd.Day());
        string strKey = string.valueof(strStart.Year()) + startMonth +  startDay  + ' - ' + string.valueof(strEnd.Year()) + endMonth + endDay;
//        system.debug('PeriodConversion: ' + strKey);
        return strKey;
    }

    public void init_DataDisplay(){
        PSFList_Map = new Map<string, Map<string, Map<string, objPSF>>>();
        PSFSBGradeTotal_Map = new map<string, Map<string, objPSF>>();
        OutletSummary_Map = new map<string, Map<string, objPSF>>();
        OutletTotal = new Map<string, objPSF>();
        TotalSummary_map = new map<string, map<string, objPSF>>();
        contractBRSF_Map = new map <string, ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        PSFPeriod_map = new map<string, integer>();
    }
    public void NewPR_Init(){
        thisPR = new ASI_TH_CRM_PaymentRequest__c();
        PSFList = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
        contractBRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        SBVolList = new List<ASI_CRM_Subbrand_Volume__c>();
    }
    public class objPSF{
        public decimal strA {set;get;}
        public decimal strB {set;get;}
        public decimal strC {set;get;}
        public decimal strD {set;get;}
        public decimal strE {set;get;}
        public decimal strF {set;get;}
        public decimal strG {set;get;}
        public decimal strH {set;get;}
        public decimal strI {set;get;}
        public integer strPeriod {set;get;}     
        public string strSubBrand {set;get;} //Added by Twinkle 20141205
    }
    public class objMap{
        public string strPeriod {set;get;}
        public date strStart {set;get;}
        public date strEnd {set;get;}
    }
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
//        system.debug('SBGradeSorting: ' + returnString);
        return returnString;
    }
}
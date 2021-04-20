/*****************************************************
For ASI_CRM_Image_Outlet_Request__c Visualforce Email Template:  CN Image Outlet Site Request Approval Template


********************************************************/

public without sharing class ASI_CRM_CN_ImageOutletRequestController {

    public ASI_CRM_CN_ImageOutletRequestController(ApexPages.StandardController controller) {
        UserId = UserInfo.getUserId();
        chooseLocale();
        LImageSite_del = new List <ASI_CRM_Image_Outlet_Site__c>();
        IOMOffSB_del = new List<ASI_CRM_Image_Outlet_Request_SubBrand__c>();
        MappingP = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        MappingP1 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        MappingP2 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        MappingP3 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        MappingParent = new ASI_CRM_CN_Channel_Strategy__c();
        mapSubbrandGrade = new Map<string, map<string, IOMG_Data>>();
        MATPRC_Map = new map<string, map<string, IOMG_Data>>();
        RTList = Global_RecordTypeCache.getRtList('ASI_CRM_Image_Outlet_Request__c');
        for (RecordType rt : RTList){
            if (rt.DeveloperName == 'ASI_CRM_ON')
            RTId = rt.id;
            if (rt.DeveloperName == 'ASI_CRM_OFF')
            OFFRTId = rt.id;
        }
        ImageReqId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('ImageReqId: ' + ImageReqId);
        RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        system.debug('RecordType: ' + ApexPages.currentPage().getParameters().get('RecordType'));
        listContract = new ASI_TH_CRM_Contract__c();
        ContractType = new set<string>();
        ContractType.add('New Contract ON');
        ContractType.add('New Contract OFF');
        if (ImageReqId != null){
            init();
            showMapping();
            showAllBrands();
            if (ImageReq.RecordTypeId == RTId){
                getContractInfo();
                isON = true;
                showOutlet = false;
                
            }else{
                isOFF = true;
                showOutlet = false;
                
                MATOutletTotal();
            }
            //show request hq budget button
            if (ImageReq.ASI_CRM_Status__c == 'Approved by AD')
                isHQrequest = true;
            else
                isHQrequest = false;
        }else{
            ImageReq = new ASI_CRM_Image_Outlet_Request__c ();
            LImageSite = new List<ASI_CRM_Image_Outlet_Site__c >();
            IOMOffSBList = new List<ASI_CRM_Image_Outlet_Request_SubBrand__c >();
            showOutlet = true;
            
            isON = false;
            isOFF = false;
        }
        
    }
    //Identify User locale
    public string UserId {set;get;}
    public boolean showCN {set;get;}
    public string Recordtypeid {set;get;}
    public id ImageReqId {set;get;}
    public ASI_CRM_Image_Outlet_Request__c ImageReq {set;get;}
    public ASI_CRM_AccountsAdditionalField__c Acc {set;get;}
    public ASI_CRM_CN_Channel_Strategy__c MappingParent {set;get;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> MappingP {set;get;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> MappingP1 {set;get;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> MappingP2 {set;get;}
    public List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> MappingP3 {set;get;}
    public List<ASI_CRM_Image_Outlet_Site__c> LImageSite {set;get;}
    //for Remove Row
    public boolean showSaveON {set;get;} //Not allow to save when no contract (On Only)
    public List<ASI_CRM_Image_Outlet_Site__c> LImageSite_del {set;get;}
    public List<ASI_CRM_Image_Outlet_Request_SubBrand__c> IOMOffSB_del {set;get;}
    public string rowid {set;get;}
    public decimal index =0;
    public integer removepos{get;set;}
    public id RTId {set;get;}
    public id OFFRTId {set;get;}
    public string ONOFF {set;get;}
    public boolean isON {set;get;}
    public boolean isOFF {set;get;}
    public boolean showOutlet{set;get;}
    public string RTName {set;get;}
    public List <RecordType> RTList {set;get;}
    public string strImage {set;get;}
    public string strsubchannel {set;get;}
    public string strsubchannelName {set;get;}
    public string strAddress {set;get;}
    public string strRegion {set;get;}
    public string strDivision {set;get;}
    public string strGrade {set;get;}
    public string strCRMCode {set;get;}
    public decimal strNumofRoom {set;get;}
    public decimal strNumoftable {set;get;}
    public decimal strNumofcart {set;get;}
    public id strArea {set;get;}
    
    //MAT Outlet Business Size (OFF)
    public List <IOMG_Data> data1_list {set;get;}
    public Map <string, IOMG_Data> data2_list {set;get;}
    public IOMG_Data data2 {set;get;}
    public IOMG_Data data1 {set;get;}
    public List<ASI_CRM_Subbrand_Volume__c> SBVolumeList {set;get;}
    public decimal strTotal {set;get;}
    public decimal strTotalP {set;get;}
    public decimal strTotalGS {set;get;}
    public decimal strTotalPGS {set;get;}
    
    //MAT PRC Business Size (OFF)
    public List<ASI_CRM_Subbrand_Volume__c> SBVolumeList1 {set;get;}
    public decimal strTotal_prc {set;get;}
    public decimal strTotalP_prc {set;get;}
    public list <IOMG_Data> data3_list {set;get;}
    public IOMG_Data data1t {set;get;}
    public map <string, IOMG_Data> Totaldata_temp1 {set;get;}
    public map <string, IOMG_Data> Totaldata1 {set;get;}
    public map <string, map<string, IOMG_Data>> Totaldata2 {set;get;}
    public map <string, map<string, IOMG_Data>> Totaldata3 {set;get;}
    public boolean showMATPRC {set;get;}
    public decimal strTotalQty {set;get;}
    public decimal strTotalQtyP {set;get;}
    public decimal strTotalVal {set;get;}
    public decimal strTotalValP {set;get;}
    public string sb1name {set;get;}
    public string sb1 {set;get;}
    public string sb2name{set;get;}
    public string sb2 {set;get;}
    public string sb3name {set;get;}
    public string sb3 {set;get;}
    
    
    public Integer numAtts {set;get;}
    
    //AllBrands (OFF)
    public IOMG_Data data3 {set;get;}
    public map <string, Map<string, IOMG_Data>> AllBrands {set;get;}
    public map <string, IOMG_Data> AllSB {set;get;}
    
    //Image Outlet Application Form
    public List<ASI_CRM_Image_Outlet_Request_SubBrand__c> IOMOffSBList {set;get;}
    
    //Outlet Suppliementary Information
    public ASI_TH_CRM_Contract__c listContract {set;get;}
    public list<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFSbList {set;get;}
    public set<id> BRSFSBSet {set;get;}
    public List<ASI_CRM_Subbrand_Volume__c> SBVolumeListOn {set;get;}
    public map<string, map<string, IOMG_Data>> mapSubbrandGrade {set;get;}
    public date POStart {set;get;}
    public date POEnd {set;get;}
    public map<string, map<string, IOMG_Data>> MATPRC_Map {set;get;}
    public boolean showMsg {set;get;}
    
    public boolean isHQrequest {set;get;}
    public set<string> ContractType {set;get;}
    
    //Choose the right locale for User
    public void chooseLocale(){
        User thisUser = [SELECT LanguageLocaleKey FROM User WHERE id = :UserId];
        if (thisUser.LanguageLocaleKey == 'zh_CN'){
            showCN = true;
        }
    }
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init2();} return dummyVar; } set; }
    
    public ASI_CRM_CN_ImageOutletRequestController(){
        
    }
    
    public boolean init2(){
        init();  
        return true;
    }
    
    public void init(){
        ImageReq = [SELECT Name, ASI_CRM_Status__c, RecordTypeId, ASI_CRM_Outlet__c,  ASI_CRM_Address__c,  ASI_CRM_Sub_Channel__c,
        ASI_CRM_Sys_Approver__r.name,
        ASI_CRM_Division__c, ASI_CRM_Outlet_Segment_Image__c, ASI_CRM_Outlet_Segment_Volume__c, ASI_CRM_Sub_brand_1__c, ASI_CRM_Sub_brand_2__c, ASI_CRM_CRM_Code__c, ASI_CRM_Region__c,
        ASI_CRM_Sub_brand_3__c, ASI_CRM_Application_Date__c, ASI_CRM_Application_Person__c, ASI_CRM_Outlet__r.ASI_CRM_CN_CRM_Code__c,ASI_CRM_Sub_brand_1__r.Name, 
        ASI_CRM_Sub_brand_2__r.Name, ASI_CRM_Sub_brand_3__r.Name, ASI_CRM_Sub_brand_1__r.ASI_MFM_Brand__r.Name, ASI_CRM_Sub_brand_1__r.ASI_MFM_Brand__c,
        ASI_CRM_Sub_brand_2__r.ASI_MFM_Brand__r.Name, ASI_CRM_Sub_brand_2__r.ASI_MFM_Brand__c,ASI_CRM_Sub_brand_3__r.ASI_MFM_Brand__r.Name, ASI_CRM_Sub_brand_3__r.ASI_MFM_Brand__c,
        ASI_CRM_Image_Production_1__c, ASI_CRM_Image_Production_2__c, ASI_CRM_Image_Production_3__c, ASI_CRM_Application_Reason__c,
        ASI_CRM_CN_Last_Contract__c, ASI_CRM_CN_Last_Contract__r.Name, CreatedDate, ASI_CRM_Outlet__r.ASI_CRM_CN_Sub_Channel__r.Name,
        ASI_CRM_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name,ASI_CRM_Outlet__r.ASI_CRM_CN_Phone_Number__c,
        ASI_CRM_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.Name,ASI_CRM_Need_HQ_Sponsor__c,ASI_CRM_Mobile_Phone__c,
        ASI_CRM_Outlet__r.ASI_CRM_CN_CCity__r.Name,Owner.Name,LastModifiedBy.name,CreatedBy.name,ASI_CRM_Sys_Approver_Channel__c,
        ASI_CRM_Outlet__r.ASI_CRM_CN_CCity__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Sys_Approver__r.Phone,
        ASI_CRM_Outlet__r.name, ASI_MFM_Outlet_Contacts__c, ASI_CRM_Outlet_Mobile_Phone__c
        FROM ASI_CRM_Image_Outlet_Request__c WHERE id = :ImageReqId];
        LImageSite = [SELECT Name, ASI_CRM_Expected__r.name,ASI_CRM_Site__c, ASI_CRM_Type__c, ASI_CRM_Previous__c, ASI_CRM_Expected__c,ASI_CRM_Description__c,ASI_CRM_Size__c FROM ASI_CRM_Image_Outlet_Site__c WHERE ASI_CRM_Image_Outlet_Request__c = :ImageReqId];
        IOMOffSBList = [SELECT Name, ASI_CRM_Image_Production__c, ASI_CRM_Sub_Brand__c FROM ASI_CRM_Image_Outlet_Request_SubBrand__c WHERE ASI_CRM_IOM__c = :ImageReqId];
        system.debug('IOMOffSBList: ' + IOMOffSBList);
        //searchOutlet();
        
        UserId = UserInfo.getUserId();
        chooseLocale();
        LImageSite_del = new List <ASI_CRM_Image_Outlet_Site__c>();
        IOMOffSB_del = new List<ASI_CRM_Image_Outlet_Request_SubBrand__c>();
        MappingP = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        MappingP1 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        MappingP2 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        MappingP3 = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
        MappingParent = new ASI_CRM_CN_Channel_Strategy__c();
        mapSubbrandGrade = new Map<string, map<string, IOMG_Data>>();
        MATPRC_Map = new map<string, map<string, IOMG_Data>>();
        RTList = Global_RecordTypeCache.getRtList('ASI_CRM_Image_Outlet_Request__c');
        numAtts=0;
        showMapping();
        getContractInfo();
        numAtts=[select count() from attachment where parentid =: ImageReqId];
    }
    
 

       /*lokman 30/6/2014 SIT issue 213 end*/
    public string checkFY(Date strDate){
        string returnFY;
        integer strMonth ;
        integer strYr;
        integer strPyr;
        integer strNYr;
        strMonth = strDate.Month();
        strYr = strDate.YEAR();
        strPYr = strYr - 1;
        strNYr = strYr + 1;
        system.debug('strMonth : ' + strMonth + ' strYR: ' + strYr);
        if (strMonth > 6 && strMonth < 13)
        returnFY = strYr + '/' + strNYr;
        if (strMonth > 0 && strMonth < 7)
        returnFY = strPYr + '/' + strYr;
        system.debug('returnFY: ' + returnFY);
        return returnFY;
    }
    public void searchOutlet(){
        system.debug('searchOutlet()');
        Acc = [SELECT ASI_CRM_CN_No_of_Tables__c,ASI_CRM_CN_Nb_of_Vehicles__c,ASI_CRM_CN_No_of_Room__c,ASI_CRM_CN_CRM_Code__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.Name , ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name, ASI_CRM_CN_Sub_Channel__r.Name, ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c, ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c,  ASI_CRM_CN_Grade__c, ASI_CRM_CN_Address__c, ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Image__c FROM ASI_CRM_AccountsAdditionalField__c WHERE id = :ImageReq.ASI_CRM_Outlet__c];
        if (Acc.id != null){
            strImage = Acc.ASI_CRM_CN_Image__c ;
            strsubchannel = Acc.ASI_CRM_CN_Sub_Channel__c;
            strArea = Acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__c;
            strAddress = Acc.ASI_CRM_CN_Address__c;
            strGrade = Acc.ASI_CRM_CN_Grade__c;
            strDivision = Acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.Name ;
            strRegion = Acc.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name;
            strsubchannelName = Acc.ASI_CRM_CN_Sub_Channel__r.Name;
            strCRMCode = Acc.ASI_CRM_CN_CRM_Code__c;
            strNumofRoom=Acc.ASI_CRM_CN_No_of_Room__c;
            strNumoftable=Acc.ASI_CRM_CN_No_of_Tables__c;
            strNumofcart=Acc.ASI_CRM_CN_Nb_of_Vehicles__c;
            if (Acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c != null){
                ONOFF = Acc.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_On_Off__c;
            }else{
                ONOFF = 'ON';
            }
        }
    }
    public void getContractInfo(){
        system.debug('getContractInfo()');
        if (ImageReq.ASI_CRM_Outlet__c != null){
            system.debug('ImageReq.ASI_CRM_Outlet__c: ' + ImageReq.ASI_CRM_Outlet__c);
            system.debug('ContractType: ' + ContractType);
            if (ImageReq.ASI_CRM_CN_Last_Contract__c == null){
                try{
                    listContract = [SELECT id, ASI_CRM_CN_Outlet_WS__c , ASI_CRM_CN_PO_Start_Date__c, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_CRM_CN_PO_End_Date__c
                                    FROM ASI_TH_CRM_Contract__c 
                                    WHERE ASI_CRM_CN_PO_End_Date__c >= Today
                                    AND ASI_CRM_CN_Outlet_WS__c = :ImageReq.ASI_CRM_Outlet__c
                                    AND ASI_TH_CRM_Promotion_Type__c IN : ContractType
                                    ORDER BY ASI_CRM_CN_PO_End_Date__c DESC Limit 1];     
                }catch(exception e){
                    system.debug('no listContract found.' + e);
                    listContract = new ASI_TH_CRM_Contract__c();
                    showSaveON = false;
                    showMsg = true;
                }
            }else{
                listContract = [SELECT id, ASI_CRM_CN_Outlet_WS__c , ASI_CRM_CN_PO_Start_Date__c, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c, ASI_CRM_CN_PO_End_Date__c
                                    FROM ASI_TH_CRM_Contract__c 
                                    WHERE id = :ImageReq.ASI_CRM_CN_Last_Contract__c]; 
            }
            if (listContract.id != null){
                ImageReq.ASI_CRM_CN_Last_Contract__c = listContract.id;
                showSaveON = true;
                system.debug('listContract: '+ listContract);
                POStart = listContract.ASI_CRM_CN_PO_Start_Date__c;
                POEnd = listContract.ASI_CRM_CN_PO_End_Date__c;
                try{
                    BRSFSbList = [SELECT id, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Sub_Brand__r.Name,
                                ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_No_of_Months__c,
                                ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name
                                FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c WHERE
                                ASI_CRM_CN_Contract__c = :listContract.id];
                }catch(exception e){
                    system.debug(e);
                    BRSFSbList = new list<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
                }
                //BRSFSbSet = new set<id>();
                if (BRSFSbList.size()>0)
                    for (ASI_CRM_CN_Contract_BRSF_Line_Item__c a : BRSFSbList){
                        //BRSFSbSet.add(a.ASI_CRM_CN_Sub_Brand__c);
                        decimal vol = 0;
                        string sbgrade;
                        string sbname;
                        if (a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c != null)
                            sbgrade = a.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name;
                        else
                            sbgrade = 'No Sub Brand Grade Specified';
                        sbname = a.ASI_CRM_CN_Sub_Brand__r.Name;
                        map <string, IOMG_Data> sb_vol = new map <string, IOMG_Data>();
                        IOMG_Data sbvol_data = new IOMG_Data();
                        sbvol_data.value = 0;
                        if (a.ASI_CRM_CN_Contract_Monthly_Qty__c != null && a.ASI_CRM_CN_No_of_Months__c != null){
                            vol += a.ASI_CRM_CN_Contract_Monthly_Qty__c  * a.ASI_CRM_CN_No_of_Months__c ;
                            sbvol_data.value += vol;
                        }
                        if (mapSubbrandGrade.containskey(sbgrade)){
                            if (mapSubbrandGrade.get(sbgrade).containskey(sbname)){
                                mapSubbrandGrade.get(sbgrade).get(sbname).value += vol;
                            }else{
                                mapSubbrandGrade.get(sbgrade).put(sbname, sbvol_data);
                            }
                        }else{
                            sb_vol.put(sbname, sbvol_data);
                            mapSubbrandGrade.put(sbgrade, sb_vol);
                        }
                    }
                system.debug('mapSubbrandGrade: ' + mapSubbrandGrade);
                showMapping();
                showAllBrands();
            }
        }else{
            listContract = new ASI_TH_CRM_Contract__c();
            showSaveON = false;
            showMsg = true;
        }
    }
    public PageReference showMapping(){
        MappingP1.clear();
        MappingP2.clear();
        MappingP3.clear();
        string FY = checkFY(Date.TODAY());
        string MPId;
        searchOutlet();
        system.debug('Search Channel Stategy: ' + strImage  + ', ' + FY + ', ' + strsubchannel + ', ' + strArea );
        try{
            MappingParent = [SELECT id FROM ASI_CRM_CN_Channel_Strategy__c WHERE ASI_CRM_CN_Image__c = :strImage 
            AND ASI_CRM_CN_Fiscal_Year__c = :FY 
            AND ASI_CRM_CN_Sub_Channel__c = :strsubchannel AND RecordType.DeveloperName = 'ASI_CRM_CN_Area'
            AND ASI_CRM_CN_Status__c = 'Final' 
            AND ASI_CRM_CN_Area__c = :strArea LIMIT 1];
            system.debug('MappingParent (Area): ' + MappingParent );
        }catch(exception e){
            system.debug('Try get Area Strategy failed: ' + e);
            try{
                MappingParent = [SELECT id FROM ASI_CRM_CN_Channel_Strategy__c WHERE ASI_CRM_CN_Image__c = :strImage 
                AND ASI_CRM_CN_Fiscal_Year__c = :FY 
                AND ASI_CRM_CN_Sub_Channel__c = :strsubchannel 
                AND RecordType.DeveloperName = 'ASI_CRM_CN_National'
                AND ASI_CRM_CN_Status__c = 'Final' 
                ORDER BY CreatedDate DESC LIMIT 1];
            }catch(exception ae){
                MappingParent = new ASI_CRM_CN_Channel_Strategy__c();
            }
        }
        

        
        if (MappingParent != null){ 
            try{      
                MappingP = [SELECT Name, ASI_CRM_CN_Sub_brand__c, ASI_CRM_CN_Sub_brand__r.name,ASI_CRM_CN_Brand__c FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c WHERE ASI_CRM_CN_Channel_Strategy__c = :MappingParent.id];
            }catch(exception e){
                MappingP = new list<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            }
        }
        if (MappingP.size() > 0){
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c a : MappingP){
                if (a.ASI_CRM_CN_Brand__c == 'Priority 1')
                MappingP1.add(a);
                if (a.ASI_CRM_CN_Brand__c == 'Priority 2')
                MappingP2.add(a);
                if (a.ASI_CRM_CN_Brand__c == 'Priority 3')
                MappingP3.add(a);
            }
        }else{
            MappingP1.clear();
            MappingP2.clear();
            MappingP3.clear();
            
        }
        return null;
    }
    
    public void addRow(){
        ASI_CRM_Image_Outlet_Site__c a = new ASI_CRM_Image_Outlet_Site__c();
        a.Name= 'a' + index++;
        index = index++;
        LImageSite.add(a);
    }
    public void addIOMATRow(){
        ASI_CRM_Image_Outlet_Request_SubBrand__c a = new ASI_CRM_Image_Outlet_Request_SubBrand__c();
        a.Name= 'a' + index++;
        index = index++;
        IOMOffSBList.add(a);
    }
    public void removeSBRow(){
        system.debug('rowid: ' + rowid);
        if(IOMOffSBList.size()>0){
            for(Integer i=0;i<IOMOffSBList.size();i++){
                system.debug('IOMOffSBList[i].Name:'+ IOMOffSBList[i].Name);
                system.debug('rowid:'+ rowid);
                if(IOMOffSBList[i].Name == rowid){
                    IOMOffSB_del.add(IOMOffSBList[i]);
                    removepos=i;
                }
            }
            IOMOffSBList.remove(removepos);
        }
    }
    public void removeRow(){
        system.debug('rowid: ' + rowid);
        system.debug('LImageSite.size(): ' + LImageSite.size());
        if(LImageSite.size()>0){
            for(Integer i=0;i<LImageSite.size();i++){
                system.debug('Integer i: ' + i);
                system.debug('LImageSite[i].Name: ' + LImageSite[i].Name);
                system.debug('rowid rowid: ' + rowid);
                if(LImageSite[i].Name == rowid){
                    LImageSite_del.add(LImageSite[i]);
                    removepos=i;
                }
            }
            LImageSite.remove(removepos);
        }
    }
    public pageReference OutletSelected(){
        system.debug('OutletSelected()');

        searchOutlet();
        if (ONOFF == 'ON'){
            isON = true;
            showOutlet = false;
           
            ImageReq.RecordTypeid = RTId;
            //url += '&RecordType=' + RTId;
            getContractInfo();
        }else if (ONOFF == 'OFF'){
            isOFF = true;
            showOutlet = false;
            
            ImageReq.RecordTypeid = OFFRTId;
            MATOutletTotal();

        }
        system.debug('ONOFF: ' + ONOFF);

        return null;
    }
    
    public pageReference selectRT(){   
        //String Recordtypeid;
        string obj_id = sObjectType.ASI_CRM_Image_Outlet_Request__c.getKeyPrefix();
        string url = '/apex/ASI_CRM_CN_InputImageOutletRequest?ent=' + obj_id + '/e?ret=/'+obj_id+'/o';
        Recordtypeid = ApexPages.currentPage().getParameters().get('RecordType');
        if (RecordTypeId != null){
            url += '&RecordType=' + Recordtypeid.left(15);
        }
        if (RecordTypeId == RTId)
        isON = true;
        if (RecordTypeId == OFFRTId){
            isOFF = true;
            MATOutletTotal();
        }    
        ImageReq.RecordTypeId = Recordtypeid;
        return new pageReference(url);
    }
    public PageReference SaveAll(){
        if (ImageReq.id != null)
            update ImageReq;
        else
            insert ImageReq;
            
        List<ASI_CRM_Image_Outlet_Site__c> UpdateList = new List<ASI_CRM_Image_Outlet_Site__c>();   
        List<ASI_CRM_Image_Outlet_Site__c> InsertList = new List<ASI_CRM_Image_Outlet_Site__c>();
        List<ASI_CRM_Image_Outlet_Request_SubBrand__c> UpdateSBList = new List<ASI_CRM_Image_Outlet_Request_SubBrand__c>();
        List<ASI_CRM_Image_Outlet_Request_SubBrand__c> InsertSBList = new List<ASI_CRM_Image_Outlet_Request_SubBrand__c>();
        if (LImageSite.size() > 0){    
            for (ASI_CRM_Image_Outlet_Site__c  a : LImageSite){
                if (a.id != null){
                    UpdateList.add(a);
                    //update a;
                }else{
                    a.ASI_CRM_Image_Outlet_Request__c = ImageReq.id;
                    a.name = '';
                    InsertList.add(a);
                    //insert a;
                }
            }
            insert InsertList;
            update UpdateList;
            if (LImageSite_del.size() > 0){
                list <ASI_CRM_Image_Outlet_Site__c> DelList = new List<ASI_CRM_Image_Outlet_Site__c>();
                for (ASI_CRM_Image_Outlet_Site__c c : LImageSite_del){
                    if (c.id != null){
                        DelList.add(c);
                    }
                }
                if (DelList.size() > 0)
                    delete DelList;
            }
        }
        if (IOMOffSBList.size() >0){
            for (ASI_CRM_Image_Outlet_Request_SubBrand__c b : IOMOffSBList){
                if (b.id != null){
                    UpdateSBList.add(b);
                }else{
                    b.ASI_CRM_IOM__c = ImageReq.Id;
                    b.Name = '';
                    InsertSBList.add(b);
                }
            }
            update UpdateSBList;
            insert InsertSBList;
            if (IOMOffSB_del.size() > 0){
                list <ASI_CRM_Image_Outlet_Request_SubBrand__c> DelList = new List<ASI_CRM_Image_Outlet_Request_SubBrand__c>();
                for (ASI_CRM_Image_Outlet_Request_SubBrand__c c : IOMOffSB_del){
                    if (c.id != null){
                        DelList.add(c);
                    }
                }
                if (DelList.size() > 0)
                    delete DelList;
            }
        }
        
        string url = '/' + ImageReq.id;
        PageReference returnPage = new PageReference(url);
        returnPage.setRedirect(true);
        return returnPage;
    }
    public pageReference EditIOM(){
        string url = '/apex/ASI_CRM_CN_InputImageOutletRequest?id=' + ImageReq.id;
        PageReference returnPage = new PageReference(url);
        returnPage.setRedirect(true);
        return returnPage;
    }
    public pageReference BackIOM(){
        string url = '/a9r/o';
        PageReference returnPage = new PageReference(url);
        returnPage.setRedirect(true);
        return returnPage;
    }
    public pageReference createPO(){
        string url = '/apex/asi_mfm_selectPOPrefixPage?rType=CN';
        if(ImageReq != null && ImageReq.id != null){
            url  += '&iomid=' + ImageReq.id;
        }
        PageReference returnPage = new PageReference(url);
        returnPage.setRedirect(true);
        return returnPage; 
    }
    
    public void MATOutletTotal(){
        strTotal =0;
        strTotalP = 0;
        strTotalGS = 0;
        system.debug('MATOutletTotal()');
        data1_list = new List <IOMG_Data>();
        AllBrands = new Map <string, map<string, IOMG_Data>>();
        
        //Query Covered Outlet
        system.debug('listcontract for covered outlet (MAT): ' + listcontract.id);
        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
            FROM ASI_CRM_CN_Covered_Outlet__c
            WHERE ASI_CRM_CN_Contract__c = :listContract.id];
        }catch(exception e){
            system.debug('Try CoveredOutlet failed: ' + e);
        }
        set<id> CoveredOutletset = new set<id>();
        CoveredOutletset.add(ImageReq.ASI_CRM_Outlet__c);
        if (CoveredOutlet.size() > 0){
            for (ASI_CRM_CN_Covered_Outlet__c CO_temp : CoveredOutlet){
                CoveredOutletset.add(CO_temp.ASI_CRM_CN_Outlet__c);
            }
        }
        
        SBVolumeList = [SELECT ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.Name, 
        ASI_CRM_Month__c, ASI_CRM_Year__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name, ASI_CRM_Subbrand__r.ASI_MFM_Brand__c, ASI_CRM_Subbrand__r.Name,
        ASI_CRM_Offtake_GS__c, ASI_CRM_Offtake__c FROM ASI_CRM_Subbrand_Volume__c WHERE //ASI_CRM_Account__c = :ImageReq.ASI_CRM_Outlet__c
        ASI_CRM_Account__c IN : CoveredOutletset
        AND ASI_CRM_CN_Competitor_Sub_brand__c != true];
        system.debug('SBVolumeList.size(): ' + SBVolumeList );
        for (ASI_CRM_Subbrand_Volume__c a : SBVolumeList ){
            boolean calc = checkPeriod(a.ASI_CRM_Month__c, a.ASI_CRM_Year__c);
            
            if (calc == true){
                system.debug('calc: true');
                data1 = new IOMG_Data();
                data1.value=0;
                data1.percentage=0;
                data1.totalvalue=0;
                data1.totalpercentage=0;

                //data1
                if (a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__c != null){
                    data1.subcat = a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.Name;
                     data1.sc = a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.Name;
                }else{
                    data1.subcat = 'Not Specified';
                    data1.sc = 'Not Specified';
                }
                data1.sb = a.ASI_CRM_Subbrand__r.Name;
                if (a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__c != null)
                    data1.brand = a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name;
                else
                    data1.brand = 'Not Specified';
                if (a.ASI_CRM_Offtake_GS__c != null){
                    data1.value = a.ASI_CRM_Offtake_GS__c;
                    strTotal += a.ASI_CRM_Offtake_GS__c;
                }
                if (a.ASI_CRM_Offtake__c != null){
                    data1.totalvalue += a.ASI_CRM_Offtake__c ;
                    strTotalGS += a.ASI_CRM_Offtake__c;
                }
                
                system.debug('ASI_CRM_Offtake_GS__c ' + a.ASI_CRM_Offtake_GS__c);
                data1_list.add(data1);
            }
        }
        data2_list = new Map <String, IOMG_Data>();
        strTotalP = 100;
        strTotalPGS = 0;
        for ( IOMG_Data b: data1_list){
            data2 = new IOMG_Data();
            data3 = new IOMG_Data();
            data2.value = 0;
            data2.percentage = 0;
            data3.totalvalue = 0;
            data3.totalpercentage = 0;
            if (b.value != null){
                data2.value = b.value;
                if (strTotal != 0 && b.value != 0){
                    data2.percentage = (b.value/strTotal)*100;
                }
            }  
            
            if (b.totalvalue != null){
                data3.totalvalue += b.totalvalue;
                if (strTotalGS!= 0 && b.totalvalue != 0)
                    data3.totalpercentage = (b.totalvalue/strTotalGS)*100;
            } 
            
            strTotalPGS += data3.totalpercentage;
            
            if (data2_list.containskey(b.subcat)){
                data2_list.get(b.subcat).value += b.value;
                if (data2_list.get(b.subcat).value != 0 && strTotal != 0)
                    data2_list.get(b.subcat).percentage = (data2_list.get(b.subcat).value/strTotal)*100;
            }else{
                system.debug('data2_list: ' + data2_list);
                system.debug('b.subcat: ' + b.subcat);
                system.debug('data2: ' + data2);  
                data2_list.put(b.subcat , data2);   
            }
            
            system.debug('AllBrands: ' + AllBrands.size());
            if (AllBrands.containskey(b.brand)){
                system.debug('allbrands.get');
                if (AllBrands.get(b.brand).containskey(b.sb)){
                    system.debug('allbrands.allsb.get');
                    AllBrands.get(b.brand).get(b.sb).totalvalue += b.totalvalue;
                    system.debug('AllBrands.get(b.brand).get(b.sb).totalvalue ' + AllBrands.get(b.brand).get(b.sb).totalvalue);
                    if (AllBrands.get(b.brand).get(b.sb).totalvalue != 0 && strTotalGS != 0){
                        AllBrands.get(b.brand).get(b.sb).totalpercentage = (AllBrands.get(b.brand).get(b.sb).totalvalue/strTotalGS)*100;
                        //strTotalPGS +=  AllBrands.get(b.brand).get(b.sb).totalpercentage;
                    }
                    system.debug('AllBrands.get(b.brand).get(b.sb).totalpercentage ' + AllBrands.get(b.brand).get(b.sb).totalpercentage);
                    }else{
                        AllBrands.get(b.brand).put(b.sb, data3);
                    }
            }else{ 
                system.debug('allsb.put');
                AllSB = new Map <string, IOMG_Data>();
                AllSB.put(b.sb, data3);
                system.debug('allbrands.put');
                AllBrands.put(b.brand , AllSB);   
            }

        }
        
    }
        public void showAllBrands(){
            set<id> SubbrandId = new set<id>();
            data3_list = new List <IOMG_Data>();
            for (ASI_CRM_Image_Outlet_Request_SubBrand__c sb : IOMOffSBList){
                SubbrandId.add(sb.ASI_CRM_Sub_Brand__c);
            }
            system.debug('SubbrandId: ' + SubbrandId.size());
            //Query Covered Outlet
        system.debug('listcontract for covered outlet: ' + listcontract.id);
        list<ASI_CRM_CN_Covered_Outlet__c> CoveredOutlet = new list<ASI_CRM_CN_Covered_Outlet__c>();
        try{
            CoveredOutlet = [SELECT ASI_CRM_CN_Outlet__c
            FROM ASI_CRM_CN_Covered_Outlet__c
            WHERE ASI_CRM_CN_Contract__c = :listContract.id];
        }catch(exception e){
            system.debug('Try CoveredOutlet failed: ' + e);
        }
        set<id> CoveredOutletset = new set<id>();
        CoveredOutletset.add(ImageReq.ASI_CRM_Outlet__c);
        if (CoveredOutlet.size() > 0){
            for (ASI_CRM_CN_Covered_Outlet__c CO_temp : CoveredOutlet){
                CoveredOutletset.add(CO_temp.ASI_CRM_CN_Outlet__c);
            }
        }
            SBVolumeList1 = [SELECT ASI_CRM_Subbrand__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.Name, 
                        ASI_CRM_Month__c, ASI_CRM_Year__c, ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name, ASI_CRM_Subbrand__r.ASI_MFM_Brand__c, ASI_CRM_Subbrand__r.Name,
                        ASI_CRM_Offtake__c, ASI_CRM_Offtake_GS__c FROM ASI_CRM_Subbrand_Volume__c WHERE //ASI_CRM_Account__c = :ImageReq.ASI_CRM_Outlet__c 
                        ASI_CRM_Account__c IN :CoveredOutletset
                        AND ASI_CRM_CN_Competitor_Sub_brand__c != true
                        AND ASI_CRM_Subbrand__c IN : SubbrandId];
                        //(ASI_CRM_Subbrand__c = :ImageReq.ASI_CRM_Sub_brand_1__c OR ASI_CRM_Subbrand__c = :ImageReq.ASI_CRM_Sub_brand_2__c OR ASI_CRM_Subbrand__c = :ImageReq.ASI_CRM_Sub_brand_3__c)];
            
            strTotalQty = 0;
            strTotalVal = 0;
            decimal strvalue;
            decimal strvolume;
            decimal strValuePer = 0;
            decimal strVolumePer = 0;
            for (ASI_CRM_Subbrand_Volume__c a : SBVolumeList1 ){
                boolean calc = checkPeriod(a.ASI_CRM_Month__c, a.ASI_CRM_Year__c);
                string sbCat_name = a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.Name;
                string sbname = a.ASI_CRM_Subbrand__r.Name;
                if (calc == true){
                   //data1t
                    Totaldata_temp1 = new map <string, IOMG_Data>();
                    data1t = new IOMG_Data();
                    data1t.totalvalue=0;
                    data1t.totalpercentage=0;
                    data1t.value=0;
                    data1t.percentage=0;
                    data1t.subcat = a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.Name;
                    data1t.sc = a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.ASI_TH_CRM_Sub_category__r.Name;
                    data1t.sb = a.ASI_CRM_Subbrand__r.Name;
                    data1t.brand = a.ASI_CRM_Subbrand__r.ASI_MFM_Brand__r.Name;
                    
//Sub brand value
                    if (a.ASI_CRM_Offtake_GS__c != null){
                        //data1t.value = a.ASI_CRM_Offtake_GS__c;
                        strTotalVal += a.ASI_CRM_Offtake_GS__c; //Total value
                        strvalue = a.ASI_CRM_Offtake_GS__c;
                    }else{
                        strvalue = 0;
                    }
//Sub brand volume
                    if (a.ASI_CRM_Offtake__c != null){
                        //data1t.totalvalue += a.ASI_CRM_Offtake__c;
                        strTotalQty += a.ASI_CRM_Offtake__c; //Total volume
                        strvolume = a.ASI_CRM_Offtake__c;
                    }else{
                        strvolume = 0;
                    }
                    if (strvolume != 0 && strTotalQty != 0){
                        strVolumePer = strvolume  / strTotalQty *100;
                    }else{
                        strVolumePer = 0;
                    }
                    if (strvalue != 0 && strTotalVal != 0){
                        strValuePer = strvalue / strTotalVal *100;
                    }else{
                        strValuePer = 0;
                    }
                    data1t.totalvalue = strvolume;
                    data1t.value = strvalue;
                    data1t.totalpercentage = strValuePer;
                    data1t.percentage = strValuePer ;
                    data3_list.add(data1t);

                    if (MATPRC_Map.containskey(sbCat_name)){
                        if (MATPRC_Map.get(sbCat_name).containskey(sbname)){
                            MATPRC_Map.get(sbCat_name).get(sbname).value += strvalue;
                            MATPRC_Map.get(sbCat_name).get(sbname).totalvalue += strvolume;
                        }else{
                            MATPRC_Map.get(sbCat_name).put(sbname, data1t);
                        }
                        
                    }else{
                        Totaldata_temp1.put(sbname, data1t);
                        MATPRC_Map.put(sbCat_name, Totaldata_temp1);
                    }
                }
            }
            if (MATPRC_Map.size() > 0){
            strTotalQtyP = 0;
            strTotalValP = 0;
                for (string a : MATPRC_map.keyset()){
                    for (IOMG_Data tempMAT : MATPRC_Map.get(a).values()){
                        if (tempMAT.totalvalue != 0 && strTotalQty  != 0){
                            tempMAT.totalpercentage = tempMAT.totalvalue / strTotalQty * 100;
                        }else{
                            tempMAT.totalpercentage = 0;
                            }
                        strTotalQtyP += tempMAT.totalpercentage;
                        if (tempMAT.value != 0 && strTotalVal  != 0)
                            tempMAT.percentage = tempMAT.value / strTotalVal * 100;
                        else
                            tempMAT.percentage = 0;
                        strTotalValP += tempMAT.percentage;
                        tempMAT.rows = MATPRC_Map.get(a).size();
                    }
                }
            }
        }
        
        public boolean checkPeriod(string strMonth, string strYear){
            boolean returnYES = false;
            integer nowYear = integer.valueof(Date.Today().Year());
            integer nowMonth = integer.valueof(Date.Today().Month());
            integer strSMonth = integer.valueof(strMonth);
            integer strSYear = integer.valueof(strYear);
            system.debug('nowYear: ' + nowYear + ' nowMonth: ' + nowMonth );
            if (nowMonth - 12 <0){
                if ((strSMonth > (nowMonth - 1) && strSYear == (nowYear - 1)) || (strSMonth < nowMonth && strSYear == nowYear))
                returnYES = true;
            }else if (nowMonth == 0){
                if (strSMonth < nowMonth && strSYear == nowYear)
                returnYES = true;
            }
            system.debug('returnYES: ' + returnYES);
            return returnYES;
        }

            
        public class IOMG_Data{
            public sObject IOMG_Data {set;get;}
            public string sb {set;get;}
            public String brand {set;get;}
            public decimal value {set;get;}
            public decimal percentage {set;get;}
            public decimal totalvalue {set;get;}
            public decimal totalpercentage {set;get;}
            public string subcat {set;get;}
            public string sc {set;get;}
            public integer rows{set;get;}
            
            public IOMG_Data(){
                
            }
        }
        
    public pageReference requestHQ(){
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(ImageReq.id);
        Approval.ProcessResult result = Approval.process(req1);
        
        PageReference PageRef = new PageReference('/apex/ASI_CRM_CN_ImageOutletRequestView?id=' + ImageReq.id);
        PageRef.setredirect(true);
        return PageRef;
    }
        
}
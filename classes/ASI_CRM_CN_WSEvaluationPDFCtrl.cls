/***********************************************************
Created by Stella Sing (IntroV Limited)     10 May 2014
************************************************************/
public with sharing class ASI_CRM_CN_WSEvaluationPDFCtrl {
    public String PageId {set;get;}
    public ASI_CRM_WS_Evaluation__c thisWS {set;get;}
    public List<ASI_CRM_WS_Evaluation_Items__c> WSChildList {set;get;}
    public List<WSEvaluationPDF> showData {set;get;}
    public WSEvaluationPDF showTotal {set;get;}
    public list<ProcessInstanceHistory> processInstList {set;get;}
    public string LastModDate {set;get;}
    public string highlight {set;get;}
    public string highlightno {set;get;}
    public string highlightend {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public list<ASI_ApprHist_LineItem> appHistList {get;set;}
    
    public ASI_CRM_CN_WSEvaluationPDFCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
        WSChildList = new list<ASI_CRM_WS_Evaluation_Items__c>();
        if (PageId != null){
            thisWS = [SELECT Name, ASI_CRM_Fiscal_Year__c, ASI_CRM_Quarter__c, Owner.Name, LastModifiedDate,
                      ASI_CRM_T1_WS_Addition__c, ASI_CRM_T1_WS_Addition__r.Name, ASI_CRM_Status__c,
                      ASI_CRM_Submission_Date__c,
                      ASI_CRM_T1_WS_Addition__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Area__r.ASI_CRM_Division__r.ASI_CRM_Region__r.Name
                      FROM ASI_CRM_WS_Evaluation__c WHERE id = :PageId];
           // if(thisWS.LastModifiedDate != null)
			//	LastModDate = thisWS.LastModifiedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
        }else{
            thisWS = new ASI_CRM_WS_Evaluation__c();
            WSChildList = new List<ASI_CRM_WS_Evaluation_Items__c>();
            processInstList = new list<ProcessInstanceHistory>();
			Datetime myDatetime = Datetime.now();
			LastModDate = myDatetime.format('yyyy/MM/dd HH:mm ', 'Hongkong');
        }
        init();
        }
    public ASI_CRM_CN_WSEvaluationPDFCtrl() {
        //PageId = ApexPages.currentPage().getParameters().get('id');
        //WSChildList = new list<ASI_CRM_WS_Evaluation_Items__c>();
        //showData = new List<WSEvaluationPDF>();
        //highlight = '<td width="5%" style="border-bottom: 1px solid black; border-left: 1px solid black;" align="right" bgcolor="yellow">';
        //highlightno = '<td width="5%" style="border-bottom: 1px solid black; border-left: 1px solid black;" align="right">';
        //highlightend = '</td>';
        //init();
        Datetime myDatetime = Datetime.now();
        //LastModDate = myDatetime.format('yyyy/MM/dd HH:mm ', 'Hongkong');
        //20160324 Ben @ Elufa
        /*if(thisWS != NULL)
        	LastModDate = thisWS.ASI_CRM_Submission_Date__c.format('yyyy/MM/dd HH:mm ', 'Hongkong');
        else
            LastModDate = myDatetime.format('yyyy/MM/dd HH:mm ', 'Hongkong');*/
        //20160324 End
    }
    public boolean init(){
        showData = new List<WSEvaluationPDF>();
        highlight = '<td width="5%" style="border-bottom: 1px solid black; border-left: 1px solid black;" align="right" bgcolor="yellow">';
        highlightno = '<td width="5%" style="border-bottom: 1px solid black; border-left: 1px solid black;" align="right">';
        highlightend = '</td>';
        
        system.debug('thisWS: ' + thisWS);
        if (thisWS.id != null){
			
            try{
                WSChildList = [SELECT id, ASI_CRM_WS2__c, ASI_CRM_WS2__r.Name, ASI_CRM_Comment__c, 
                            ASI_CRM_Achieve_Rate__c, ASI_CRM_Calculated_Incentive__c, ASI_CRM_Data_Quality_Rate__c,
                            ASI_CRM_incentive__c, ASI_CRM_Scan_Rate__c, ASI_CRM_Target__c,
                            ASI_CRM_WS_GS__c, ASI_CRM_City__c, ASI_CRM_WS2__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__r.Name,
                            ASI_CRM_WS2__r.ASI_CRM_CN_CRM_Code__c, ASI_CRM_WS2__r.ASI_CRM_CN_Chi_Name__c,ASI_CRM_WS2__r.ASI_CRM_CN_Eng_Name__c,
                            ASI_CRM_CN_Target_Value__c, ASI_CRM_CN_Target_Volume__c, ASI_CRM_CN_Actual_Value__c, ASI_CRM_CN_Actual_Volume__c
                            FROM ASI_CRM_WS_Evaluation_Items__c WHERE ASI_CRM_WS_Evaluation__c = :thisWS.id];           
                if(thisWS.ASI_CRM_Submission_Date__c != null)
					LastModDate = thisWS.ASI_CRM_Submission_Date__c.format('yyyy/MM/dd HH:mm ', 'Hongkong');//20160324 Ben @ Elufa
                else
                    LastModDate = Datetime.now().format('yyyy/MM/dd HH:mm ', 'Hongkong');//20160324 Ben @ Elufa
                system.debug('WSChildList: ' + WSChildList.size());
            }catch(Exception e){
                system.debug(e);
            }
            if (WSChildList.size()>0)
                Calculation();
    //****** Generate approval history - by leo (start) copied by Stella ******
            ASI_MFM_ApprovalHistoryHelper appHistHelper = new ASI_MFM_ApprovalHistoryHelper ('ASI_CRM_WS_Evaluation__c' , thisWS.id );
            
            System.Debug('appHistHelper: ' + appHistHelper);
            
            if (appHistHelper.appHistorySObjList != null) {
                this.processInstList = appHistHelper.appHistorySObjList;
                //hasHistroy=true;
                
                System.Debug('appHistHelper.appHistorySObjList: ' + appHistHelper.appHistorySObjList);
                
                appHistList  = new List<ASI_ApprHist_LineItem >();
                Boolean isExit = false;
                ASI_CRM_WS_Evaluation__c header = [SELECT ASI_CRM_Status__c FROM ASI_CRM_WS_Evaluation__c WHERE id = : thisWS.id];
                for (ProcessInstanceHistory li : this.processInstList ) {
                      System.Debug('ProcessInstanceHistory li: ' + li);
                      if(li.StepStatus != 'Approved' && header.ASI_CRM_Status__c == 'Final')
                      {
                          isExit = true;
                      }
                      else if(li.StepStatus == 'Approved' && header.ASI_CRM_Status__c != 'Draft')
                      {
                        addToApprHistList(li);
                      }else if(li.StepStatus == 'Started' || header.ASI_CRM_Status__c == 'Draft')
                          isExit = true;
                    
                      if(isExit) break;  
                }
                 
                if (appHistList.size() <=0)
                    //hasHistroy=false;
                    appHistList = new list<ASI_ApprHist_LineItem>();
            }
            else
            {
                //hasHistroy=false;
                appHistList = new list<ASI_ApprHist_LineItem>();
            }
    //***************** Approval History Ends    ******************/
    
        }
        return true;
    }

    public void Calculation(){
		
        integer i = 0;
        for (ASI_CRM_WS_Evaluation_Items__c a : WSChildList){
            WSEvaluationPDF item = new WSEvaluationPDF();
            item.index = i + 1;
            item.Province = a.ASI_CRM_WS2__r.ASI_CRM_CN_CCity__r.ASI_CRM_CN_Province__r.Name;
            item.city = a.ASI_CRM_City__c;
            item.CRMCode = a.ASI_CRM_WS2__r.ASI_CRM_CN_CRM_Code__c;
            item.WSChiName = a.ASI_CRM_WS2__r.ASI_CRM_CN_Chi_Name__c;
            item.WSName = a.ASI_CRM_WS2__r.ASI_CRM_CN_Eng_Name__c;
//Quarterly Target in Vol = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_CN_Target_Volume__c
            if (a.ASI_CRM_CN_Target_Volume__c != null)
                item.strA = a.ASI_CRM_CN_Target_Volume__c;
            else
                item.strA = 0;
//Acheivement in Vol = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_CN_Actual_Volume__c
            if (a.ASI_CRM_CN_Actual_Volume__c != null)
                item.strB = a.ASI_CRM_CN_Actual_Volume__c;
            else
                item.strB = 0;
//Completion Rate % = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_CN_Actual_Volume__c/ASI_CRM_CN_Target_Volume__c * 100%
            if (item.strB != 0 && item.strA != 0)
                item.strC = item.strB/item.strA *100;
            else
                item.strC = 0;
//Quarterly Target in Value = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_CN_Target_Value__c
            if (a.ASI_CRM_CN_Target_Value__c != null)
                item.strD = a.ASI_CRM_CN_Target_Value__c;
            else
                item.strD = 0;
//Acheivement in Value = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_CN_Actual_Value__c
            if (a.ASI_CRM_CN_Actual_Value__c != null)
                item.strE = a.ASI_CRM_CN_Actual_Value__c;
            else
                item.strE = 0;
//Completion Rate % = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_CN_Actual_Value__c/ASI_CRM_CN_Target_Value__c * 100%
            if (item.strD != 0 && item.strE != 0)
                item.strF = item.strE/item.strD*100;
            else
                item.strF = 0;
            /*
            if (a.ASI_CRM_Achieve_Rate__c != null)
                item.strF = a.ASI_CRM_Achieve_Rate__c;
            */
//Acheivement Rate % = if (Completion Rate % < 80% (= 0), 80-99% ()= 50%), >= 100 (= 100%))
            if (item.strC != 0 && item.strF ==0){
                if (item.strC < 80)
                    item.strG = 0;
                else if (item.strC > 79 && item.strC < 91)
                    item.strG = 50;
                else if (item.strC > 99)
                    item.strG = 100;
            }else if (item.strF != 0 && item.strC ==0){    
                if (item.strF < 80)
                    item.strG = 0;
                else if (item.strF > 79 && item.strF < 91)
                    item.strG = 50;
                else if (item.strF > 99)
                    item.strG = 100;
            }
//Accuracy Rate % = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_Data_Quality_Rate__c
            if (a.ASI_CRM_Data_Quality_Rate__c != null)
                item.strH = a.ASI_CRM_Data_Quality_Rate__c;
            else
                item.strH = 0;
//Acheivement Rate % = if (Accuracy Rate % < 00% (= 0), >= 100 (= 100%))
            if (item.strH < 90)
                item.strI = 0;
            else if (item.strH > 89)
                item.strI = 100;
//Scan Rate % = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_Scan_Rate__c
            if (a.ASI_CRM_Scan_Rate__c != null)
                item.strJ = a.ASI_CRM_Scan_Rate__c;
            else
                item.strJ = 0;
//Acheivement Rate % = if (Scan Rate % <90% (= 0), 90-94% (=50), >=100% (=100))
            if (item.strJ < 90)
                item.strK = 0;
            else if (item.strJ > 89 && item.strJ < 95)
                item.strK = 50;
            else if (item.strJ > 94 )
                item.strK = 100;
            /*if (item.strE != null && item.strG != null && item.strI != null && item.strK != null)
                item.strL = item.strE * item.strF * item.strI * item.strK * 0.015;
            */
//Total (Calculated) Incentive Amount = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_Calculated_Incentive__c
            if (a.ASI_CRM_Calculated_Incentive__c != null)
                item.strL = a.ASI_CRM_Calculated_Incentive__c;
            else
                item.strL = 0;
//Total Incentive Amount = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_incentive__c
            if (a.ASI_CRM_incentive__c != null)
                item.strM = a.ASI_CRM_incentive__c;
            else
                item.strM = 0;
//Justification for % over-ruling by Region = ASI_CRM_WS_Evaluation_Items__c : ASI_CRM_Comment__c
            if (a.ASI_CRM_Comment__c != null){
                //string[] strcomment1 = (a.ASI_CRM_Comment__c).split('\n');
                String c = a.ASI_CRM_Comment__c;
                String b = '';
                while(c.length() >= 10 )
                {
                    b = b + c.subString(0,10) + '\n';
                	c = c.subString(10);
                }
                b = b + c;
                item.strN = b; //a.ASI_CRM_Comment__c;

            }
            if(item.strM > 0 && item.strE > 0)// && item.strL > 0)
            	item.strO = (item.strM/item.strE);
            else
                item.strO = NULL;
            
            if ((item.strL - item.strM)>1 || (item.strL - item.strM)<-1)
                item.hasDifference = true;
            i++;
            showData.add(item);
        }
    
        if (showData.size() > 0)
            showTotal = new WSEvaluationPDF();
            showTotal.strA = 0;
            showTotal.strB = 0;
            showTotal.strC = 0;
            showTotal.strD = 0;
            showTotal.strE = 0;
            showTotal.strF = 0;
            showTotal.strL = 0;
        	showTotal.strM = 0;
            for(WSEvaluationPDF b : showData){
                
                
                showTotal.strA += b.strA;
                showTotal.strB += b.strB;
                if (b.strA != 0 && b.strB != 0)
                    showTotal.strC = (b.strB / b.strA)*100;
                showTotal.strD += b.strD;
                showTotal.strE += b.strE;
                if (b.strD != 0 && b.strE != 0)
                    showTotal.strF = (b.strE / b.strD)*100;
                showTotal.strL += b.strL;
                showTotal.strM += b.strM;
            }
    }
    public class WSEvaluationPDF{
        public integer index {set;get;}
        public string Province {set;get;}
        public string city {set;get;}
        public string CRMCode {set;get;}
        public string WSChiName {set;get;}
        public string WSName {set;get;}
        public decimal strA {set;get;}
        public decimal strB {set;get;}
        public decimal strC {set;get;}
        public decimal strD {set;get;}
        public decimal strE {set;get;}
        public decimal strF {set;get;}
        public decimal strG {set;get;}
        public decimal strH {set;get;}
        public decimal strI {set;get;}
        public decimal strJ {set;get;}
        public decimal strK {set;get;}
        public decimal strL {set;get;}
        public decimal strM {set;get;}
        public string strN {set;get;}
        public boolean hasDifference {set;get;}
        public decimal strO {set;get;}
        
    }
//****** generate approval history: functions - by leo (start) ******
    public static User getApprDetailInfo(String userId) {
        String queryStr = '';
        User appHistoryApprover = new User();
        queryStr = 'select id, name, title, department from user ';
        queryStr += ' where id =\'' +userId+ '\'';
        System.debug('ahh3' + queryStr);    
        appHistoryApprover = Database.query(queryStr);
        return appHistoryApprover ;
    }

    public class ASI_ApprHist_LineItem {
        public String id { get; set; }
        public String StepStatus{ get; set; }
        public String Comments{ get; set; }
        public DateTime CreatedDate{ get; set; }
        public String CreatedDateString{ get; set; }
        public String oriActorId { get; set; }
        public String oriActorName { get; set; }
        public String oriActorTitle { get; set; }
        public String oriActorDepartment { get; set; }
        public String actActorId { get; set; }
        public String actActorName { get; set; }
        public String actActorTitle { get; set; }
        public String actActorDepartment { get; set; }
      
    }
    
    private void addToApprHistList(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
      
        tempLi.oriActorId =  li.OriginalActor.Id;
        User oriApprover = getApprDetailInfo(li.OriginalActor.Id);
        tempLi.oriActorName =  oriApprover.Name;
        tempLi.oriActorTitle =  oriApprover.Title;
      
        tempLi.actActorId =  li.Actor.Id;
        User actApprover = getApprDetailInfo(li.Actor.Id);
        tempLi.actActorName =  actApprover.Name;
        tempLi.actActorTitle =  actApprover.Title;
        tempLi.actActorDepartment = actApprover.Department;
        if (appHistList.size() <=0)
            appHistList.add(tempLi);
        else
            appHistList.add(0, tempLi);
    }
//****** generate approval history: functions - by leo (end) Copied by Stella ******
}
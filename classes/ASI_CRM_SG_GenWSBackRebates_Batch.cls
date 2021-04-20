/*********************************************************************************
 * Name: ASI_CRM_SG_GenWSBackRebates_Batch
 * Description: Generation wholesaler back rebates credit / debit not and line item
 *
 * Version History
 * Date 			Developer 			Comments
 * --------------- -------------------- --------------------------------------------------------------------------------
 * 2018-03-16		Vincent Lam			Create
*/
global class ASI_CRM_SG_GenWSBackRebates_Batch implements Database.Batchable<AggregateResult>, Database.stateful, Schedulable {
    
	public static final Id ACTUALOFFTAKE_RECORDTYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake');
	public static final Id CREDITNOTE_RECORDTYPE_ID = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Back_Rebate_Credit_Note');
	public static final Id DEBITNOTE_RECORDTYPE_ID = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Back_Rebate_Debit_Note');
	public static final Id CREDITNOTELINE_RECORDTYPE_ID = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note_Line_Item__cASI_CRM_SG_Back_Rebate_Credit_Note_Line_Item');
	public static final Id DEBITNOTELINE_RECORDTYPE_ID = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note_Line_Item__cASI_CRM_SG_Back_Rebate_Debit_Note_Line_Item');
	public static final Id PAYMENTREQUEST_RECORDTYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request');
	public static final Id PAYMENTREQUESTLINE_RECORDTYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail');
		
    public static final map<string, string> MAP_HEADER_RTID_CREDITORDEBIT = new map<string, string>{
        CREDITNOTE_RECORDTYPE_ID=>'Credit Note',
        DEBITNOTE_RECORDTYPE_ID=>'Debit Note'
    };
    	
	public static final String OPENOUTLET = 'Open Outlet';
	public static final String ISSUETYPE_PAYMENTREQUEST = 'Payment Request';
	public static final String ISSUETYPE_CREDITNOTE = 'Credit Note';
	
	public static final String REASON_PREFIX = 'BackRebate_';
	public static final String CREDITNOTE_TYPE = 'Back Rebate';
	public static final String PAYMENT_TYPE = 'Back Rebates';
	public static final String PAYMENT_REMARK = 'Wholesaler Back Rebate Payment';
	public static final String DEFAULT_CURRENCY = 'SGD';
	public static final Integer DEFAULT_EXCHANGERATE = 1;

	//Variable for init query
	global string monthStr, yearStr;
	global Id wholesalerOwnerId;
	global Id wholesalerId;
    global String issueType;
	global Map<string, list<AggregateResult>> map_wholesalerIdSign_results;
	global Map<string, wholesalerSkuWrapper> map_wholesalerSkuWrapper;
	public datetime dateInstance;

	global ASI_CRM_SG_GenWSBackRebates_Batch(String fromYear, String fromMonth, String issueType) {
		this(fromYear, fromMonth, issueType, null, UserInfo.getUserId());
	}
    
	global ASI_CRM_SG_GenWSBackRebates_Batch(String fromYear, String fromMonth, String issueType, String wholesalerId) {
		this(fromYear, fromMonth, issueType, wholesalerId, UserInfo.getUserId());
	}
    
	global ASI_CRM_SG_GenWSBackRebates_Batch(String fromYear, String fromMonth, String issueType, String wholesalerId, String wholesalerOwnerId) {
		this.yearStr = fromYear;
		this.monthStr = fromMonth;
		this.wholesalerId = wholesalerId; 
		this.wholesalerOwnerId = wholesalerOwnerId;        
		this.issueType = issueType;
		this.map_wholesalerIdSign_results = new Map<string, list<AggregateResult>>();
		this.map_wholesalerSkuWrapper = new Map<string, wholesalerSkuWrapper>();
		this.dateInstance = Datetime.newInstance(Integer.valueOf(this.yearStr), Integer.valueOf(this.monthStr), 15);
	}
    
	global class AggregateResultIterable implements Iterable<AggregateResult> {
        public string yearStr;  
        public string monthStr;  
        public string wholesalerId; 
        public string wholesalerOwnerId;  
        global AggregateResultIterable (string yearStr, string monthStr, string wholesalerId, string wholesalerOwnerId){
             this.yearStr = yearStr;
             this.monthStr = monthStr;
			 this.wholesalerId = wholesalerId;
			 this.wholesalerOwnerId = wholesalerOwnerId;
         }
        global Iterator<AggregateResult> Iterator(){
            return new AggregateResultIterator(yearStr, monthStr, wholesalerId, wholesalerOwnerId);
       }
    }
 
    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results {get;set;}
        Integer index {get; set;} 
 
        global AggregateResultIterator(string yearStr, string monthStr, string wholesalerId, string wholesalerOwnerId) {
            index = 0;
            if(wholesalerId == null){
                results = [Select 
                         sum(ASI_CRM_Wholesaler_Back_Rebates_Total__c) sumAmount,
						 sum(ASI_TH_CRM_Quantity__c) sumBottle,
						 sum(ASI_CRM_Converted_Qty_9L__c) sum9L,
						 avg(ASI_CRM_Open_Outlet_Price__c) openOutletPrice,
						 avg(ASI_CRM_Special_Incentive_Price__c) specialIncentivePrice,
						 avg(ASI_CRM_Wholesaler_Back_Rebates__c) backRebate,
						 ASI_CRM_FromWS__c wholesaler,
						 ASI_CRM_SG_Customer__c customer,
						 ASI_CRM_SKU__c sku,
                         ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c subBrand,
						 ASI_CRM_Is_Offtake_Qty_Positive__c sign
                     From 
                         ASI_TH_CRM_Actual_Offtake__c 
                     where 
                       recordtypeid = :ACTUALOFFTAKE_RECORDTYPE_ID
					   AND ASI_CRM_FromWS__c != null
					   AND ASI_CRM_SG_Customer__c != null
					   AND ASI_CRM_SKU__c != null
					   AND ASI_CRM_FromWS__r.ownerid = :wholesalerOwnerId
					   AND ASI_CRM_SG_Customer__r.ASI_CRM_Outlet_Type__c = :OPENOUTLET
                       AND calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c) = :Integer.valueOf(yearStr) 
                       AND calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c)  = :Integer.valueOf(monthStr)
					   AND ASI_CRM_Wholesaler_Back_Rebates__c != 0
					   AND (ASI_CRM_SKU__r.ASI_CRM_Missing_PricesForWSBackRebate__c = false OR 
						(ASI_CRM_SKU__r.ASI_CRM_Missing_PricesForWSBackRebate__c = true AND ASI_CRM_SKU__r.ASI_CRM_Bypass_for_WS_Back_Rebate__c = true)
					   )
                     group by 
                       ASI_CRM_FromWS__c ,
					   ASI_CRM_SG_Customer__c ,
                       ASI_CRM_SKU__c ,
                       ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, 
					   ASI_CRM_Is_Offtake_Qty_Positive__c
                      ];     
            } else{
                results = [Select 
                         sum(ASI_CRM_Wholesaler_Back_Rebates_Total__c) sumAmount,
						 sum(ASI_TH_CRM_Quantity__c) sumBottle,
						 sum(ASI_CRM_Converted_Qty_9L__c) sum9L,
						 avg(ASI_CRM_Open_Outlet_Price__c) openOutletPrice,
						 avg(ASI_CRM_Special_Incentive_Price__c) specialIncentivePrice,
						 avg(ASI_CRM_Wholesaler_Back_Rebates__c) backRebate,
						 ASI_CRM_FromWS__c wholesaler,
						 ASI_CRM_SG_Customer__c customer,
						 ASI_CRM_SKU__c sku,
                         ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c subBrand,
						 ASI_CRM_Is_Offtake_Qty_Positive__c sign
                     From 
                         ASI_TH_CRM_Actual_Offtake__c 
                     where 
                       recordtypeid = :ACTUALOFFTAKE_RECORDTYPE_ID
					   AND ASI_CRM_FromWS__c != null
					   AND ASI_CRM_SG_Customer__c != null
					   AND ASI_CRM_SKU__c != null
					   AND ASI_CRM_FromWS__c = :wholesalerId
					   AND ASI_CRM_FromWS__r.ownerid = :wholesalerOwnerId
					   AND ASI_CRM_SG_Customer__r.ASI_CRM_Outlet_Type__c = :OPENOUTLET
                       AND calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c) = :Integer.valueOf(yearStr) 
                       AND calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c)  = :Integer.valueOf(monthStr)
					   AND ASI_CRM_Wholesaler_Back_Rebates__c != 0
					   AND (ASI_CRM_SKU__r.ASI_CRM_Missing_PricesForWSBackRebate__c = false OR 
						(ASI_CRM_SKU__r.ASI_CRM_Missing_PricesForWSBackRebate__c = true AND ASI_CRM_SKU__r.ASI_CRM_Bypass_for_WS_Back_Rebate__c = true)
					   )
                     group by 
                       ASI_CRM_FromWS__c ,
					   ASI_CRM_SG_Customer__c ,
                       ASI_CRM_SKU__c ,
                       ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, 
					   ASI_CRM_Is_Offtake_Qty_Positive__c
                      ];     
            }
            
        } 
 
        global boolean hasNext(){ 
           return results != null && !results.isEmpty() && index < results.size(); 
        }    
 
        global AggregateResult next(){ 
            return results[index++];            
        }       
    }    
 
    global Iterable<AggregateResult> start(Database.batchableContext info){
        // just instantiate the new iterable here and return
        return new AggregateResultIterable(this.yearStr, this.monthStr, this.wholesalerId, this.wholesalerOwnerId);
    }
	
	global void execute(Database.BatchableContext contextInstance, list<AggregateResult> pLstFetchedRecords){
		for(AggregateResult ar : pLstFetchedRecords){
			/*
			Boolean isPositive = Boolean.valueOf(ar.get('sign'));
			String key = String.valueOf(ar.get('wholesaler')) + '_' + (isPositive ? 'true' : 'false');
			List<AggregateResult> list_ar = map_wholesalerIdSign_results.containsKey(key) ? map_wholesalerIdSign_results.get(key) : new List<AggregateResult>();
			list_ar.add(ar);
			map_wholesalerIdSign_results.put(key, list_ar);
			*/
			String wholesalerId = String.valueOf(ar.get('wholesaler'));
			String skuId = String.valueOf(ar.get('sku'));
			String key = wholesalerId + '_' + skuId;
			wholesalerSkuWrapper w = map_wholesalerSkuWrapper.containsKey(key) ? map_wholesalerSkuWrapper.get(key) : new wholesalerSkuWrapper(wholesalerId, skuId);
			w.list_ar.add(ar);
			map_wholesalerSkuWrapper.put(key, w);
		}
	}
	
	global void finish(Database.BatchableContext contextInstance){
		
		for(wholesalerSkuWrapper w : map_wholesalerSkuWrapper.values()){
			Boolean isPositive = w.getTotalBottle() >= 0 ? true : false;
			String key = w.wholesalerId + '_' + (isPositive ? 'true' : 'false');
			List<AggregateResult> list_ar = w.list_ar;
			List<AggregateResult> list_arFinal = map_wholesalerIdSign_results.containsKey(key) ? map_wholesalerIdSign_results.get(key) : new List<AggregateResult>();
			list_arFinal.addall(list_ar);
			map_wholesalerIdSign_results.put(key, list_arFinal);
		}
			
			
		dateInstance = Datetime.newInstance(Integer.valueOf(this.yearStr), Integer.valueOf(this.monthStr), 15);
		
		Map<string, ASI_CRM_Credit_Debit_Note__c> map_wholesalerId_creditDebitNote = new Map<string, ASI_CRM_Credit_Debit_Note__c>();
		Map<string, List<ASI_CRM_Credit_Debit_Note_Line_Item__c>> map_wholesalerId_creditDebitNoteLine = new Map<string, List<ASI_CRM_Credit_Debit_Note_Line_Item__c>>();
		Map<string, ASI_TH_CRM_PaymentRequest__c> map_wholesalerId_payment = new Map<string, ASI_TH_CRM_PaymentRequest__c>();
		Map<string, List<ASI_TH_CRM_PaymentRequestLineItem__c>> map_wholesalerId_paymentLine = new Map<string, List<ASI_TH_CRM_PaymentRequestLineItem__c>>();
		
		Set<string> set_creditNoteID = new Set<string>();
		Set<string> set_paymentID = new Set<string>();
		
		for(String key : map_wholesalerIdSign_results.keySet()){
			List<AggregateResult> list_ar = map_wholesalerIdSign_results.get(key);
			String wholesalerId = key.split('_')[0];
			Boolean isPositive = Boolean.valueOf(key.split('_')[1]);
			
			if(issueType == ISSUETYPE_PAYMENTREQUEST && isPositive){
				ASI_TH_CRM_PaymentRequest__c p = createPaymentRequest(wholesalerId);
				List<ASI_TH_CRM_PaymentRequestLineItem__c> list_pl = createPaymentRequestLine(list_ar);
				map_wholesalerId_payment.put(key, p);
				map_wholesalerId_paymentLine.put(key, list_pl);
			} else
			if(issueType == ISSUETYPE_CREDITNOTE && isPositive){
				ASI_CRM_Credit_Debit_Note__c c = createCreditNote(wholesalerId, CREDITNOTE_RECORDTYPE_ID);
				List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_cl = createCreditNoteLine(list_ar, CREDITNOTELINE_RECORDTYPE_ID/*, '+'*/, isPositive);
				map_wholesalerId_creditDebitNote.put(key, c);
				map_wholesalerId_creditDebitNoteLine.put(key, list_cl);
			} else
			if(!isPositive){
				ASI_CRM_Credit_Debit_Note__c d = createCreditNote(wholesalerId, DEBITNOTE_RECORDTYPE_ID);
				List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_dl = createCreditNoteLine(list_ar, DEBITNOTELINE_RECORDTYPE_ID/*, '-'*/, isPositive);
				map_wholesalerId_creditDebitNote.put(key, d);
				map_wholesalerId_creditDebitNoteLine.put(key, list_dl);
			}
		}
		
		if(map_wholesalerId_payment != null){
			insert map_wholesalerId_payment.values();
			List<ASI_TH_CRM_PaymentRequestLineItem__c> list_l = new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
    
            for(string key : map_wholesalerId_payment.keySet()) {
                Id recordId = map_wholesalerId_payment.get(key).Id;
                set_paymentID.add(recordId);
                for(ASI_TH_CRM_PaymentRequestLineItem__c l : map_wholesalerId_paymentLine.get(key)) {
                    l.ASI_TH_CRM_Payment_Request__c = recordId;
                    list_l.add(l);
                }
            }
            insert list_l;
		}
		
		if(map_wholesalerId_creditDebitNote != null){
			insert map_wholesalerId_creditDebitNote.values();
			List<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_l = new List<ASI_CRM_Credit_Debit_Note_Line_Item__c>();
    
            for(string key : map_wholesalerId_creditDebitNote.keySet()) {
                Id recordId = map_wholesalerId_creditDebitNote.get(key).Id;
                set_creditNoteID.add(recordId);
                for(ASI_CRM_Credit_Debit_Note_Line_Item__c l : map_wholesalerId_creditDebitNoteLine.get(key)) {
                    l.ASI_CRM_Credit_Debit_Note__c = recordId;
                    list_l.add(l);
                }
            }
            insert list_l;
		}
		
        sendEMailNotification(contextInstance.getJobId(), set_paymentID, set_creditNoteID);
  		
	}
	
	public void execute(SchedulableContext contextInstance) {}
	
	public ASI_CRM_Credit_Debit_Note__c createCreditNote(string wholesalerId, string recordtypeid){
		ASI_CRM_Credit_Debit_Note__c creditNote = new ASI_CRM_Credit_Debit_Note__c();
		creditNote.ASI_CRM_Wholesaler__c = wholesalerId;
		creditNote.ASI_CRM_Reason__c = REASON_PREFIX + dateInstance.format('MMMyy', UserInfo.getTimeZone().getId());
		creditNote.ASI_CRM_Status__c = 'Draft';
		creditNote.ASI_CRM_Invoice_Date__c = Date.today();
		creditNote.ASI_CRM_GL_Date__c = Date.today();
		creditNote.ASI_CRM_Year__c = this.yearStr;
		creditNote.ASI_CRM_Month__c = this.monthStr;
		creditNote.ASI_CRM_SYS_System_Generated__c = true;
		creditNote.ASI_CRM_Currency__c = DEFAULT_CURRENCY;
		creditNote.ASI_CRM_Base_Currency__c = DEFAULT_CURRENCY;
		creditNote.ASI_CRM_Exchange_Rate__c = DEFAULT_EXCHANGERATE;
		creditNote.RecordTypeId = recordtypeid;
		return creditNote;
	}
	
	public ASI_TH_CRM_PaymentRequest__c createPaymentRequest(string wholesalerId){
		Integer yearInt = Integer.valueOf(this.yearStr);
		Integer monthInt = Integer.valueOf(this.monthStr);
		Integer endDayInt = Date.daysInMonth(yearInt, monthInt);
		Date fromDate = Date.newInstance(yearInt, monthInt, 1);
		Date toDate = Date.newInstance(yearInt, monthInt, endDayInt);
		
		ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c();
        paymentRequest.ASI_CRM_CN_OutletWS__c = wholesalerId;
        paymentRequest.ASI_CRM_SG_Invoice_No__c = REASON_PREFIX + dateInstance.format('MMMyy', UserInfo.getTimeZone().getId());
        paymentRequest.ASI_TH_CRM_Status__c = 'Draft';
        paymentRequest.ASI_CRM_System_Generated__c = true;
		paymentRequest.ASI_CRM_System_Remark__c = PAYMENT_REMARK;
		paymentRequest.ASI_CRM_Generation_From_Date__c = fromDate;
        paymentRequest.ASI_CRM_Generation_To_Date__c = toDate;
        paymentRequest.RecordTypeId = PAYMENTREQUEST_RECORDTYPE_ID;
		
		return paymentRequest;
	}
	
	public List<ASI_TH_CRM_PaymentRequestLineItem__c> createPaymentRequestLine(list<AggregateResult> list_ar){
		list<ASI_TH_CRM_PaymentRequestLineItem__c> list_pl = new list<ASI_TH_CRM_PaymentRequestLineItem__c>();
		for(AggregateResult ar : list_ar){
			ASI_TH_CRM_PaymentRequestLineItem__c pl = new ASI_TH_CRM_PaymentRequestLineItem__c();
			pl.ASI_CRM_Customer__c = String.valueOf(ar.get('customer'));
			pl.ASI_CRM_SKU__c = String.valueOf(ar.get('sku'));
			pl.ASI_CRM_SG_Sub_brand__c = String.valueOf(ar.get('subBrand'));
			pl.ASI_CRM_CN_Offtake_Vol__c = (Decimal)ar.get('sumBottle');
			pl.ASI_CRM_Volume_9L__c = (Decimal)ar.get('sum9L');
			pl.ASI_CRM_Back_Rebate_per_Bottle__c = math.abs((Decimal)ar.get('backRebate'));
			pl.ASI_TH_CRM_Amount__c = (Decimal)ar.get('sumAmount');
			pl.ASI_CRM_Adjusted_Amount__c = (Decimal)ar.get('sumAmount');
			pl.ASI_CRM_SG_Type__c = PAYMENT_TYPE;
			pl.RecordTypeId = PAYMENTREQUESTLINE_RECORDTYPE_ID;
			list_pl.add(pl);
		}
		return list_pl;
	}
	
	public List<ASI_CRM_Credit_Debit_Note_Line_Item__c> createCreditNoteLine(list<AggregateResult> list_ar, String recordtypeid/*, String sign*/, boolean isCredit){
		list<ASI_CRM_Credit_Debit_Note_Line_Item__c> list_cl = new list<ASI_CRM_Credit_Debit_Note_Line_Item__c>();
		for(AggregateResult ar : list_ar){
			string actualSign = (Decimal)ar.get('sumBottle') >= 0 ? '+' : '-';
			decimal factor = isCredit ? 1 : -1;
			ASI_CRM_Credit_Debit_Note_Line_Item__c cl = new ASI_CRM_Credit_Debit_Note_Line_Item__c();
			cl.ASI_CRM_SKU__c = String.valueOf(ar.get('sku'));
			cl.ASI_CRM_Sub_brand__c = String.valueOf(ar.get('subBrand'));
			cl.ASI_CRM_Customer__c = String.valueOf(ar.get('customer'));
			cl.ASI_CRM_Volume_9L__c = (Decimal)ar.get('sum9L');
			cl.ASI_CRM_Volume_Bottle__c = (Decimal)ar.get('sumBottle');
			cl.ASI_CRM_Back_Rebate_per_Bottle__c = math.abs((Decimal)ar.get('backRebate'));
			cl.ASI_CRM_Amount__c = (Decimal)ar.get('sumAmount') * factor;
			cl.ASI_CRM_Actual_Amount__c = (Decimal)ar.get('sumAmount') * factor;
			cl.ASI_CRM_Type__c = CREDITNOTE_TYPE;
			cl.ASI_CRM_Offtake_Qty_Sign__c = actualSign;
			cl.RecordTypeId = recordtypeid;
			list_cl.add(cl);
		}
		return list_cl;
	}
	
    public void sendEMailNotification(Id BC_ID, set<string> set_paymentID, set<string> set_creditNoteID){
         AsyncApexJob a = 
           [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC_ID];
                          
        // Send an email to the Apex job's submitter 
        //   notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Wholesaler Back Rebate Generation ' + a.Status);
        if (set_creditNoteID.size()>0 || set_paymentID.size()>0){
            string ebody = '<p>The Wholesaler Back Rebate generation for ' + this.monthStr + '/' + this.yearStr + 
                ' is completed with '+ a.NumberOfErrors + ' errors.</p>';
            ebody += '<table width="100%" border="1">';
            ebody += '<tr><th>Record No.</th><th>Type</th><th>Wholesaler</th><th>Total Taxable Amount</th>';
			for (ASI_TH_CRM_PaymentRequest__c p :[
                select id, name, ASI_CRM_CN_OutletWS__r.name, ASI_TH_CRM_Total_Amount__c from ASI_TH_CRM_PaymentRequest__c
                where id in :set_paymentID
				order by ASI_CRM_CN_OutletWS__r.name
            ]){
				ebody += '<tr><td>'+p.name+'</td><td>Payment</td><td>'+p.ASI_CRM_CN_OutletWS__r.name+'</td><td style="text-align:right">'+doFormatting(p.ASI_TH_CRM_Total_Amount__c, 2, ',', '.')+'</td></tr>';
			}
            for (ASI_CRM_Credit_Debit_Note__c p : [
                select id, name, ASI_CRM_Wholesaler__r.name, ASI_CRM_Total_Amount__c, recordtypeid from ASI_CRM_Credit_Debit_Note__c
                where id in :set_creditNoteID
				order by ASI_CRM_Wholesaler__r.name, recordtype.developername
            ]){
                ebody += '<tr><td>'+p.name+'</td><td>'+MAP_HEADER_RTID_CREDITORDEBIT.get(p.recordtypeid)+'</td><td>'+p.ASI_CRM_Wholesaler__r.name+'</td><td style="text-align:right">'+doFormatting(p.ASI_CRM_Total_Amount__c, 2, ',', '.')+'</td></tr>';
            }
            ebody += '</table>';
            mail.setHtmlBody(ebody);
        } else {
            mail.setPlainTextBody
           ('The Wholesaler Back Rebate generation for ' + this.monthStr + '/' + this.yearStr + 
           ' completed with '+ a.NumberOfErrors + ' errors. No credit/debit note or payment is generated.');
        }
       
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
	private String doFormatting(Decimal val, integer dec, String tSep, String dSep) {
		String s, tmp;
		Integer i = 4 + dec;
	   
		// If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
		if(dec==0){
		  i--;
		}
	   
		s = val.setScale(dec).toPlainString().replace(tSep, dSep);
		while(s.length() > i) {
		  tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
		  s = tmp;
		  i += 4;
		}
	   
		// If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
		if (s.substring(0,1) == '-') {
		  if (s.substring(1,2) == tSep) {
			s = '-' + s.substring(2);
		  }
		}
	   
		return s;
	}
	
	public class wholesalerSkuWrapper{
		public string wholesalerId {get;set;}
		public string skuId {get;set;}
		public List<AggregateResult> list_ar {get;set;}
		
		public wholesalerSkuWrapper(string wholesalerId, string skuId){
			this.wholesalerId = wholesalerId;
			this.skuId = skuId;
			this.list_ar = new List<AggregateResult>();
		}
		
		public decimal getTotalBottle(){
			decimal sumBottle = 0;
			for(AggregateResult ar : this.list_ar){
				sumBottle += (Decimal)ar.get('sumBottle');
			}
			return sumBottle;
		}
	}
	
}
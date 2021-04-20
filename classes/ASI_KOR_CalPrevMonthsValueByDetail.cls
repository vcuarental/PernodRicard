/**********************************************************************************
 * Name : ASI_KOR_CalPrevMonthsValueByDetail 
 * Created : Vincent Lam
 * Revision History:
 * 1. 2017-07-12 - [VL] Created; 
 **********************************************************************************/

global class ASI_KOR_CalPrevMonthsValueByDetail
    implements Database.Batchable<AggregateResult>, Database.Stateful, Schedulable {

    global static final Map<String,String> MAP_MONTH = new Map<String,String>{
        '1'=>'January',
        '2'=>'February',
        '3'=>'March',
        '4'=>'April',
        '5'=>'May',
        '6'=>'June',
        '7'=>'July',
        '8'=>'August',
        '9'=>'September',
        '10'=>'October',
        '11'=>'November',
        '12'=>'December'
    };
        
    global static final Map<String,Integer> MAP_MONTH_FULL_TO_NUM = new Map<String,Integer>{
        'January'=>1,
        'February'=>2,
        'March'=>3,
        'April'=>4,
        'May'=>5,
        'June'=>6,
        'July'=>7,
        'August'=>8,
        'September'=>9,
        'October'=>10,
        'November'=>11,
        'December'=>12
    };
        
		// initial parameter
		public List<string> list_salesPlanningID = new List<string>();
		public set<string> set_yearMonth = new set<string>();
		public set<string> set_owner = new set<string>();
		    
	public ASI_KOR_CalPrevMonthsValueByDetail(){
		list<string> list_salesPlanningID_temp = new list<string>();
		for (ASI_KOR_SR_Proposal_Header__c sr : [
			select id
			from ASI_KOR_SR_Proposal_Header__c
			where ASI_KOR_Status__c in ('Draft', 'Rejected')
			and ASI_KOR_BM_Proposal_Header__r.ASI_KOR_RSD_Proposal_Header__r.ASI_KOR_Status__c <> 'Approved by NSD'
		]){
			list_salesPlanningID_temp.add(sr.id);
		}
		init(list_salesPlanningID_temp);
	}
	
	public void init(list<string> list_salesPlanningID){
		this.list_salesPlanningID = list_salesPlanningID;
        this.set_yearMonth.add('0000_00');
		
		for (ASI_KOR_SR_Proposal_Header__c sr : [
			select ASI_KOR_Year__c, ASI_KOR_Month__c, ownerid
			from ASI_KOR_SR_Proposal_Header__c
			where id in :list_salesPlanningID
		]){
			Date srDate = Date.newInstance(Integer.valueOf(sr.ASI_KOR_Year__c), Integer.valueOf(sr.ASI_KOR_Month__c), 1);
			for (Integer i=1; i<=2; i++){
				Date tempDate = srDate.addMonths(-i);
				Datetime tempDateTime = Datetime.newInstance(tempDate.year(),tempDate.month(),tempDate.day());
				String yearMonth = tempDateTime.format('YYYY') + '_' + tempDateTime.format('MMMM');
				this.set_yearMonth.add(yearMonth);
			}
			this.set_owner.add(sr.ownerid);
		}
	}
	
    global class AggregateResultIterable implements Iterable<AggregateResult> {
        public set<string> set_owner;
        public set<string> set_yearMonth;
        global AggregateResultIterable (set<string> set_owner, set<string> set_yearMonth){
             this.set_owner = set_owner;
             this.set_yearMonth = set_yearMonth;
         }
        global Iterator<AggregateResult> Iterator(){
            return new AggregateResultIterator(set_owner, set_yearMonth);
       }
    }
 
    global class AggregateResultIterator implements Iterator<AggregateResult> {
        AggregateResult [] results {get;set;}
        Integer index {get; set;} 
 
        global AggregateResultIterator(set<string> set_owner, set<string> set_yearMonth) {
            index = 0;
			string query = 
                    'Select ' +
                    '     sum(ASI_KOR_Venue_Depl_Actual_Volume__c) bottleAmount, ' +
                    '     sum(ASI_KOR_Venue_Depl_Actual_Case__c) caseAmount, ' +
                    '   sum(ASI_KOR_Venue_Depl_Promotion_Number__c) prePayAmount, ' +
                    '   ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c venue, ' +
                    '   ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c brand, ' +
					'   ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c month, ' +
                    '   ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c year ' +
                    ' From  ' +
                    '     ASI_KOR_Venue_Depletion_Detail__c  ' +
                    ' where  (';
			for (string yearMonth : set_yearMonth){
				String yearStr = yearMonth.split('_')[0];
				String monthStr = yearMonth.split('_')[1];
				query += '(ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c = \'' + yearStr + '\' and ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c = \'' + monthStr + '\') OR ' ;
			}
			query = query.subString(0,query.length()-4);
			query += ') ' +
                    '   AND ASI_KOR_Pay_Type__c in (\'Pre-Pay\',\'Normal-Pay\') ' +
                    '   AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__r.ownerid in :set_owner ' +
					'   AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__r.ASI_KOR_Venue_Status__c = \'Active\'' + 
					'   AND ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__r.recordtype.developername = \'ASI_KOR_Venue\'' + 
                    ' group by ' +
                    '   ASI_KOR_Venue_Depletion__r.ASI_KOR_Year__c , ' +
                    '   ASI_KOR_Venue_Depletion__r.ASI_KOR_Month__c , ' +
                    '   ASI_KOR_Venue_Depletion__r.ASI_KOR_Venue__c , ' +
                    '   ASI_KOR_Item_Group_Code__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c ';
			results = (List<AggregateResult>)Database.query(query);
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
        return new AggregateResultIterable(set_owner, set_yearMonth);
    }
 
    global void execute(Database.BatchableContext contextInstance, list<AggregateResult> pLstFetchedRecords) {
        
		map<string, list<AggregateResult>> map_key_listDepletion = new map<string, list<AggregateResult>>();
		
        for (AggregateResult ar : pLstFetchedRecords){
			String venue = String.valueOf(ar.get('venue'));
            String brand = String.valueOf(ar.get('brand'));
			String yearNum = String.valueOf(ar.get('year'));
			Integer monthNum = MAP_MONTH_FULL_TO_NUM.get(String.valueOf(ar.get('month')));
			Date arDate = Date.newInstance(Integer.valueOf(yearNum), monthNum, 1);
			for (Integer i=1; i<=2; i++){
				Date tempDate = arDate.addMonths(i);
				Datetime tempDateTime = Datetime.newInstance(tempDate.year(),tempDate.month(),tempDate.day());
				String key = venue + '_' + brand + '_' + tempDateTime.format('YYYY') + '_' + Integer.valueOf(tempDateTime.format('MM'));
				List<AggregateResult> listDepletion = map_key_listDepletion.containsKey(key) ? map_key_listDepletion.get(key) : new List<AggregateResult>();
				listDepletion.add(ar);
				map_key_listDepletion.put(key, listDepletion);
			}
        }
		
		system.debug(map_key_listDepletion);
		list<ASI_KOR_SR_Proposal_Detail__c> list_updateSRbyDetail = new list<ASI_KOR_SR_Proposal_Detail__c>();
		
		if (map_key_listDepletion.keySet().size()>0){
			string query = 
                    'Select ' +
                    '     id, ' +
                    '     ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c, ' +
                    '     ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c, ' +
                    '     ASI_KOR_Venue__c, ' +
                    '     ASI_KOR_Brand__c, ' +
                    '     ASI_KOR_Brand__r.ASI_KOR_UOM__c ' +
                    ' From  ' +
                    '     ASI_KOR_SR_Proposal_Detail__c  ' +
                    ' where  (';
			for (string key : map_key_listDepletion.keySet()){
				String venue = key.split('_')[0];
				String brand = key.split('_')[1];
				String year = key.split('_')[2];
				String month = key.split('_')[3];
				query += 	'(' + 
							'ASI_KOR_Venue__c = \'' + venue + '\'' +
							'AND ASI_KOR_Brand__c = \'' + brand + '\'' +
							'AND ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c = \'' + year + '\'' +
							'AND ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c = \'' + month + '\'' +
							') OR ' ;
			}
			query = query.subString(0,query.length()-4);
			query += ') ' +
                    '   AND ASI_KOR_SR_Proposal_ID__c in :list_salesPlanningID ';
			
			for (ASI_KOR_SR_Proposal_Detail__c srBrand : (List<ASI_KOR_SR_Proposal_Detail__c>)Database.query(query)){
				String venue = srBrand.ASI_KOR_Venue__c;
				String brand = srBrand.ASI_KOR_Brand__c;
				String year = srBrand.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Year__c;
				String month = srBrand.ASI_KOR_SR_Proposal_ID__r.ASI_KOR_Month__c;
				String key = venue + '_' + brand + '_' + year + '_' + month;
				Date srBrandDate = Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), 1);
				String UOM = srBrand.ASI_KOR_Brand__r.ASI_KOR_UOM__c;
				
				if (map_key_listDepletion.containsKey(key)){
					List<AggregateResult> listDepletion = map_key_listDepletion.get(key);
					for (AggregateResult ar : listDepletion){
						String yearNum = String.valueOf(ar.get('year'));
						Integer monthNum = MAP_MONTH_FULL_TO_NUM.get(String.valueOf(ar.get('month')));
						Date arDate = Date.newInstance(Integer.valueOf(yearNum), monthNum, 1);
						
						Decimal actualVolume = UOM == 'Bottle' ? (Decimal)(ar.get('bottleAmount')) : (Decimal)(ar.get('caseAmount'));
						Decimal actualVI = (Decimal)(ar.get('prePayAmount'));
						if (arDate.monthsBetween(srBrandDate)==1){
							srBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c = actualVolume;
							srBrand.ASI_KOR_Total_VI_1_Month_Ago__c = actualVI;
						} else
						if (arDate.monthsBetween(srBrandDate)==2){
							srBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c = actualVolume;
							srBrand.ASI_KOR_Total_VI_2_Months_Ago__c = actualVI;
						}
					}
					list_updateSRbyDetail.add(srBrand);
				}
			}
		}
		
		if (list_updateSRbyDetail.size()>0){
			
			try {
				update list_updateSRbyDetail;
			} catch(DmlException exceptionInstance) {
				// DC - TODO : Nothing
			}
			
		}

    }
    
        
    /* [DC 3.1] BEGIN */
    public void execute(SchedulableContext contextInstance) {}
    /* [DC 3.1] END */

    // do the final proposal data update / insert in finish
    global void finish(Database.BatchableContext contextInstance) {
        
            
    }
        
        
    
}
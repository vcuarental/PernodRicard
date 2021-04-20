/*********************************************************************************
 * Name: ASI_CRM_SG_OfftakeChangeEmailPage_Ctrl
 * Description: Controller class for ASI_CRM_SG_OfftakeChangeEmailPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-21		Laputa: Vincent			Create
 */

public class ASI_CRM_SG_OfftakeChangeEmailPage_Ctrl {
	
    public List<String> list_contractId;
	
	public List<Wrapper_Contract> list_wrapper {get; set;}
	
	public class Wrapper_Contract{
		public ASI_TH_CRM_Contract__c c {get; set;}
		public List<ASI_TH_CRM_PaymentRequest__c> list_p {get; set;}
		public List<ASI_CRM_ContractSalesStaffIncentive__c> list_s {get; set;}
		
		public Wrapper_Contract(ASI_TH_CRM_Contract__c c, List<ASI_TH_CRM_PaymentRequest__c> list_p, List<ASI_CRM_ContractSalesStaffIncentive__c> list_s){
			this.c = c;
			this.list_p = list_p;
			this.list_s = list_s;
		}
		
        public Decimal getSalesRevenueTarget(){
            return c.ASI_CRM_Sales_Revenue_Target__c != null ? (c.ASI_CRM_Sales_Revenue_Target__c != 0 ? c.ASI_CRM_Sales_Revenue_Target__c : 1) : 1;
        }
        
		public Integer getPaymentSize(){
			return this.list_p.size();
		}
		
		public String getYear_this(){
			return this.list_s.size()>0 ? this.list_s[0].ASI_CRM_Year__c : '';
		}
		
		public String getMonth_this(){
			return this.list_s.size()>0 ? this.list_s[0].ASI_CRM_Month__c : '';
		}
		
		public decimal getSalesRevenue_this(){
			return (c.ASI_CRM_Sales_Revenue__c*100/getSalesRevenueTarget()).setScale(2);
		}
		
		public String getYear_previous(){
			return this.list_s.size()>1 ? this.list_s[1].ASI_CRM_Year__c : '';
		}
		
		public String getMonth_previous(){
			return this.list_s.size()>1 ? this.list_s[1].ASI_CRM_Month__c : '';
		}
		
		public decimal getSalesRevenue_previous(){
			return ((c.ASI_CRM_Sales_Revenue__c - (this.list_s.size()>0 ? this.list_s[0].ASI_CRM_Sales_Revenue__c : 0))*100/getSalesRevenueTarget()).setScale(2);
		}
		
		public decimal getSalesRevenue_var(){
			return ((this.list_s.size()>0 ? this.list_s[0].ASI_CRM_Sales_Revenue__c : 0)*100/getSalesRevenueTarget()).setScale(2);
		}
	}

    public ASI_CRM_SG_OfftakeChangeEmailPage_Ctrl() {
        String string_contractId = APexPages.currentPage().getParameters().get('Id');
        list_contractId = string_contractId.split(',');
    }
    
    public void init(){
        list_wrapper = getContractWrapper(list_contractId);
    }
    
	private List<Wrapper_Contract> getContractWrapper(List<String> list_contractId){
		List<Wrapper_Contract> list_wrapper = new List<Wrapper_Contract>();
		
		for (ASI_TH_CRM_Contract__c c : [
			select 
				id, Name, 
				ASI_CRM_CN_Outlet_WS__r.name,
				Owner.Name,
				ASI_CRM_Sales_Revenue__c, ASI_CRM_Sales_Revenue_Target__c, ASI_CRM_Sales_Revenue_Monthly_Actual_Avg__c,
				(select 
					id, Name, ASI_CRM_CN_Description__c 
				from 
					ASI_TH_CRM_PaymentRequests_Contract__r 
				where 
					ASI_CRM_System_Generated__c = true
					//and (ASI_CRM_CN_Description__c = 'Upfront Payment Upon Signing' or (ASI_CRM_CN_Description__c like 'Pymt upon %' and ASI_CRM_CN_Description__c like '% sales achieved'))
				//order by
					//ASI_CRM_CN_Description__c asc
				),
				(select 
					id, ASI_CRM_Year__c, ASI_CRM_Month__c, ASI_CRM_Sales_Revenue__c
				from Sales_Staff_Incentives__r
				order by 
					ASI_CRM_Year__c desc, ASI_CRM_Month__c desc
				limit 2
				)
			from 
				ASI_TH_CRM_Contract__c
			where id in :list_contractId
		]){
			Wrapper_Contract w = new Wrapper_Contract(c, c.ASI_TH_CRM_PaymentRequests_Contract__r, c.Sales_Staff_Incentives__r);
			list_wrapper.add(w);
		}
		
		return list_wrapper;
	}
}
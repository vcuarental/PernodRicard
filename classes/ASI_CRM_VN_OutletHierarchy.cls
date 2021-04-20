/*********************************************************************************
 * Name: ASI_CRM_VN_OutletHierarchy
 * Description: Build Hierarchy Relationship base on input list
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/01/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_OutletHierarchy {
    
    public class HierarchyWrapper {	
    	public ASI_CRM_AccountsAdditionalField__c parentOutlet {get; set;}
    	public Map<Id, HierarchyWrapper> childOutletMap {get; set;}
        
        public HierarchyWrapper(ASI_CRM_AccountsAdditionalField__c parentOutlet) {
            this.parentOutlet = parentOutlet;
        	this.childOutletMap = new Map<Id, HierarchyWrapper>();
        }
        
        public void addChildOutlet(HierarchyWrapper wrapper) {
            childOutletMap.put(wrapper.parentOutlet.Id, wrapper);
        }
        
        public List<ASI_CRM_AccountsAdditionalField__c> getAllOutlet() {
        	List<ASI_CRM_AccountsAdditionalField__c> outletList = new List<ASI_CRM_AccountsAdditionalField__c>();
            for(Id key : childOutletMap.keySet()) {
                outletList.addAll(childOutletMap.get(key).getAllOutlet());
            }
            outletList.add(parentOutlet);
            return outletList;
        }
    }
    
    public Map<Id, HierarchyWrapper> hierarchyWrapperMap {get; set;}
    
    public ASI_CRM_VN_OutletHierarchy(List<ASI_CRM_AccountsAdditionalField__c> outletList) {
        this.buildOutletHierarchy(outletList);
    }
    
    public List<ASI_CRM_AccountsAdditionalField__c> getAllOutlet(Id parentOutletId) {
    	return hierarchyWrapperMap.containsKey(parentOutletId)
             ? hierarchyWrapperMap.get(parentOutletId).getAllOutlet() 
             : new List<ASI_CRM_AccountsAdditionalField__c>();
    }
    
    public void buildOutletHierarchy(List<ASI_CRM_AccountsAdditionalField__c> outletList) {
		hierarchyWrapperMap = new Map<Id, HierarchyWrapper>();
        for(ASI_CRM_AccountsAdditionalField__c outlet : outletList) {
        	HierarchyWrapper wrapper = new HierarchyWrapper(outlet);
            hierarchyWrapperMap.put(outlet.Id, wrapper);
        }
        
        Set<Id> outletIdSet = hierarchyWrapperMap.keySet();
        for(Id key : outletIdSet) {
            HierarchyWrapper tempWrapper = hierarchyWrapperMap.get(key);
            hierarchyWrapperMap = buildOutletHierarchy(hierarchyWrapperMap, tempWrapper);
        }
    }
    
    private Map<Id, HierarchyWrapper> buildOutletHierarchy(Map<Id, HierarchyWrapper> hierarchyWrapperMap, HierarchyWrapper hierarchyWrapper) {
        if(hierarchyWrapper.parentOutlet.ASI_CRM_CN_Parent_Outlet__c == null) {
            return hierarchyWrapperMap;
        }
        
        HierarchyWrapper tempWrapper = hierarchyWrapperMap.get(hierarchyWrapper.parentOutlet.ASI_CRM_CN_Parent_Outlet__c);
        tempWrapper.addChildOutlet(hierarchyWrapper);
        hierarchyWrapperMap.put(tempWrapper.parentOutlet.Id, tempWrapper);
        
        return buildOutletHierarchy(hierarchyWrapperMap, tempWrapper);
    }
}
public with sharing class EUR_CRM_DataModelController {
        
        public List<SobjectResultClass> EUR_DataModels { get; set; }
        public List<SobjectResultClass> PRH_DataModels { get; set; } //added aug.13.14
        public List<SobjectResultClass> StdSObjects { get; set; }
        
        private static final Set<String> stdSobjNameSet = new Set<String>{'Account', 'Contact', 'Event'};
        
        public EUR_CRM_DataModelController(){
                init();
        }
        
        private void init(){
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                EUR_DataModels = new List<SobjectResultClass>();
                PRH_DataModels = new List<SobjectResultClass>();
                StdSObjects = new List<SobjectResultClass>();
                for(Schema.SObjectType sobj : gd.values()){
                        Schema.DescribeSObjectResult result = sobj.getDescribe();
                        if(result.name.startsWith('EUR_') && !result.name.endsWith('__Share') && !result.name.endsWith('__History') && !result.name.endsWith('__Feed'))
                                EUR_DataModels.add(new SobjectResultClass(result));
                        if(result.name.startsWith('PRH_') && !result.name.endsWith('__Share') && !result.name.endsWith('__History') && !result.name.endsWith('__Feed'))
                                PRH_DataModels.add(new SobjectResultClass(result));
                        if(stdSobjNameSet.contains(result.name))
                                StdSObjects.add(new SobjectResultClass(result));
                }
                EUR_DataModels.sort();
                PRH_DataModels.sort();
                StdSObjects.sort();
        }
        
        public class SobjectResultClass implements Comparable{
                public Schema.DescribeSObjectResult sobjResult { get; set; }
                public String sobjLabel { get; set; }
                public String sobjName { get; set; }
                public SobjectResultClass(Schema.DescribeSObjectResult result){
                        sobjResult = result;
                        sobjLabel = result.Label;
                        sobjName = result.Name;
                }
                
                public Integer compareTo(Object compareTo) {
                SobjectResultClass compareToResult = (SobjectResultClass)compareTo;
                if (sobjName == compareToResult.sobjName) return 0;
                if (sobjName > compareToResult.sobjName) return 1;
                return -1;        
        }
        }
        
}
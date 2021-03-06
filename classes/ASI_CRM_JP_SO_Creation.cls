/*********************************************************************************
 * Name: ASI_CRM_JP_SOA_FOCIntegrationProcess
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 4/6/2019         SH Ho                 Created
*********************************************************************************/
//Generated by wsdl2apex

public class ASI_CRM_JP_SO_Creation {
    public class process_element {
        public String input;
        private String[] input_type_info = new String[]{'input','http://xmlns.oracle.com/PernodRicard_JP_CRM/JP_CRM_SO_Creation/JP_CRM_SO_Creation',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.oracle.com/PernodRicard_JP_CRM/JP_CRM_SO_Creation/JP_CRM_SO_Creation','true','false'};
        private String[] field_order_type_info = new String[]{'input'};
    }
    public class processResponse_element {
        public String result;
        private String[] result_type_info = new String[]{'result','http://xmlns.oracle.com/PernodRicard_JP_CRM/JP_CRM_SO_Creation/JP_CRM_SO_Creation',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xmlns.oracle.com/PernodRicard_JP_CRM/JP_CRM_SO_Creation/JP_CRM_SO_Creation','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class JP_CRM_SO_Creation_pt {
        
        //public String endpoint_x = 'http://132.145.160.212:80/soa-infra/services/JP/JP_CRM_SO_Creation/jp_crm_so_creation_client_ep';
        public String endpoint_x = ASI_SOA_Setting__c.getValues('ASI_CRM_JP_SO_Interface_URL').ASI_SOA_URL__c;
        
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://xmlns.oracle.com/PernodRicard_JP_CRM/JP_CRM_SO_Creation/JP_CRM_SO_Creation', 'ASI_CRM_JP_SO_Creation'};
        public String process(String input) {
            ASI_CRM_JP_SO_Creation.process_element request_x = new ASI_CRM_JP_SO_Creation.process_element();
            request_x.input = input;
            ASI_CRM_JP_SO_Creation.processResponse_element response_x;
            Map<String, ASI_CRM_JP_SO_Creation.processResponse_element> response_map_x = new Map<String, ASI_CRM_JP_SO_Creation.processResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              'process',
              'http://xmlns.oracle.com/PernodRicard_JP_CRM/JP_CRM_SO_Creation/JP_CRM_SO_Creation',
              'process',
              'http://xmlns.oracle.com/PernodRicard_JP_CRM/JP_CRM_SO_Creation/JP_CRM_SO_Creation',
              'processResponse',
              'ASI_CRM_JP_SO_Creation.processResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
    }
}
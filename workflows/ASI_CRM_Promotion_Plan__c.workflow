<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_SG_Promotion_Plan_Rejected_Alert</fullName>
        <description>ASI CRM SG Promotion Plan Rejected Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ASI_CRM_SG_Template/ASI_CRM_SG_PromotionPlanRejectedTemp</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Allow_Submit_False</fullName>
        <field>ASI_CRM_SYS_Allow_Submit_Approval__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM SG Allow Submit False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Outlet_Final_Approved</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Outlet_Promotion_Plan_Final_Approved</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Outlet (Final Approved)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Outlet_Promotion_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Outlet_Promotion_Plan_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Outlet Promotion (Read-Only)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Approved</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI CRM SG Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Draft</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>ASI CRM SG Status Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Final_Approved</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Final Approved</literalValue>
        <name>ASI CRM SG Status Final Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Rejected</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>ASI CRM SG Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Status_Submitted</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI CRM SG Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Wholesaler_Final_Approved</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Wholesaler_Promotion_Plan_Final_Approved</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Wholesaler (Final Approved)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_SG_Wholesaler_Promotion_RO</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_SG_Wholesaler_Promotion_Plan_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM SG Wholesaler Promotion (RO)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>

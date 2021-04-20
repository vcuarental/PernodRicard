<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ASI_CRM_VN_Promotion_Plan_Approved_Email</fullName>
        <description>ASI CRM VN Promotion Plan Approved Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_PromotionPlanApprovedEmailTmp</template>
    </alerts>
    <alerts>
        <fullName>ASI_CRM_VN_Promotion_Plan_Rejected_Email</fullName>
        <description>ASI CRM VN Promotion Plan Rejected Email</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>itservicedesk@pernod-ricard.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ASI_CRM_VN_Email_Templates/ASI_CRM_VN_PromotionPlanRejectedEmailTmp</template>
    </alerts>
    <fieldUpdates>
        <fullName>ASI_CRM_Set_Sys_Pending_Approval_False</fullName>
        <field>ASI_CRM_Sys_Pending_Approval__c</field>
        <literalValue>0</literalValue>
        <name>ASI CRM Set Sys Pending Approval False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Promotion_Plan_Approved</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>ASI CRM VN Promotion Plan Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Promotion_Plan_Open</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Draft</literalValue>
        <name>ASI CRM VN Promotion Plan Open</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Promotion_Plan_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>ASI_CRM_VN_Promotion_Plan_Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ASI CRM VN Promotion Plan Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ASI_CRM_VN_Promotion_Plan_Submitted</fullName>
        <field>ASI_CRM_Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>ASI CRM VN Promotion Plan Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
